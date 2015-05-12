//
//  CustomZones.m
//  CustomZones
//
//  Created by Richard Ross III on 5/11/15.
//
//

#import "CustomZones.h"

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import <malloc/malloc.h>

#include <map>
#include <memory>

#if __has_feature(objc_arc)
#error Cannot be compiled with ARC!
#endif

extern "C" {
    static size_t CZZoneSize(malloc_zone_t *zone, const void *ptr);
    static void *CZZoneMalloc(malloc_zone_t *zone, size_t size);
    static void *CZZoneCalloc(malloc_zone_t *zone, size_t num, size_t count);
    static void *CZZoneValloc(malloc_zone_t *zone, size_t size);
    static void CZZoneFree(malloc_zone_t *zone, void *ptr);
    static void *CZZoneRealloc(malloc_zone_t *zone, void *ptr, size_t size);
    static void CZZoneDestroy(malloc_zone_t *zone);
}

// Maps malloc_zones to their object counterparts
static std::map<
    malloc_zone_t *,
    id<CustomZone>
> CZZonesMap;

// Maps objc objects to their malloc_zones.
static std::map<
    void *,
    malloc_zone_t *
> CZAllocationsMap;

FOUNDATION_EXPORT void CZRegisterZoneClass(Class<CustomZone> kls) {
    // Does nothing for now. In the future we may need
    // a reason to keep track of the individual classes being used.
}

FOUNDATION_EXPORT id CZAllocInZone(id<CustomZone> zone, Class targetKls) {
    malloc_zone_t *malloc_zone = new malloc_zone_t;

    malloc_zone->zone_name = [zone name];

    malloc_zone->size = CZZoneSize;
    malloc_zone->malloc = CZZoneMalloc;
    malloc_zone->calloc = CZZoneCalloc;
    malloc_zone->valloc = CZZoneValloc;
    malloc_zone->free = CZZoneFree;
    malloc_zone->realloc = CZZoneRealloc;
    malloc_zone->destroy = CZZoneDestroy;

    CZZonesMap[malloc_zone] = [zone retain];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    id obj = class_createInstanceFromZone(targetKls, 0, malloc_zone);
    CZAllocationsMap[obj] = malloc_zone;

    return obj;

#pragma clang diagnostic pop
}

@implementation NSObject(CZZone)

static void (*originalDeallocIMP)(id, SEL) = NULL;

+(void) load {
    if (self == [NSObject class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Method originalDealloc = class_getInstanceMethod([NSObject class], @selector(dealloc));
            Method newDealloc = class_getInstanceMethod([NSObject class], @selector(_CZZone_dealloc));

            assert(originalDealloc != nil);
            assert(newDealloc != nil);

            originalDeallocIMP = (void (*)(id, SEL)) method_getImplementation(originalDealloc);
            method_exchangeImplementations(originalDealloc, newDealloc);
        });
    }
}

-(void) _CZZone_dealloc {
    if (__builtin_expect((uintptr_t) CZAllocationsMap[self], 0)) {
        // Call original dealloc implementation
        return originalDeallocIMP(self, _cmd);
    }

    objc_destructInstance(self);

    malloc_zone_t *zone = CZAllocationsMap[self];
    zone->free(zone, self);
}

@end

// CZZone internals
extern "C" {
    __attribute__((used))
    static size_t CZZoneSize(malloc_zone_t *zone, const void *ptr) {
        return 0;
    }

    __attribute__((used))
    static void *CZZoneMalloc(malloc_zone_t *zone, size_t size) {
        return CZZoneCalloc(zone, 1, size);
    }

    __attribute__((used))
    static void *CZZoneCalloc(malloc_zone_t *zone, size_t num, size_t count) {
        auto zoneIter = CZZonesMap.find(zone);
        if (zoneIter == CZZonesMap.end()) return nullptr;
        id<CustomZone> zoneObject = zoneIter->second;

        return [zoneObject allocate:num * count];
    }

    __attribute__((used))
    static void *CZZoneValloc(malloc_zone_t *zone, size_t size) {
        return CZZoneMalloc(zone, MAX(PAGE_SIZE, size));
    }

    __attribute__((used))
    static void CZZoneFree(malloc_zone_t *zone, void *ptr) {
        auto zoneIter = CZZonesMap.find(zone);
        if (zoneIter == CZZonesMap.end()) return;
        id<CustomZone> zoneObject = zoneIter->second;

        [zoneObject deallocate:ptr];
    }

    __attribute__((used))
    static void *CZZoneRealloc(malloc_zone_t *zone, void *ptr, size_t size) {
        auto zoneIter = CZZonesMap.find(zone);
        if (zoneIter == CZZonesMap.end()) return nullptr;
        id<CustomZone> zoneObject = zoneIter->second;

        return [zoneObject reallocate:ptr toSize:size];
    }

    __attribute__((used))
    static void CZZoneDestroy(malloc_zone_t *zone) {
        auto zoneIter = CZZonesMap.find(zone);
        if (zoneIter == CZZonesMap.end()) return;
        
        malloc_zone_t *zonePtr = zoneIter->first;
        id<CustomZone> zoneObject = zoneIter->second;
        
        CZZonesMap.erase(zoneIter);
        [zoneObject release];
        
        delete zonePtr;
    }
}