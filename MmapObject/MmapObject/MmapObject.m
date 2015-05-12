//
//  MmapObject.m
//  MmapObject
//
//  Created by Richard Ross III on 5/12/15.
//
//

@import Foundation;
@import CustomZones;
@import ObjectiveC.runtime;

void class_setRequiresRawIsa(Class);

@interface MmapZone : NSObject<CustomZone>

@property NSFileHandle *fileHandle;
@property size_t size;

-(id) initWithFileHandle:(NSFileHandle *) fh size:(size_t) size;

@end

@implementation NSObject(MmapObject)

+(Class) _mmapZone_mmappedObjectClass {
    NSString *mmapedClassName = [NSStringFromClass(self) stringByAppendingString:@"_mmap_no_tagged_isa"];
    Class results = NSClassFromString(mmapedClassName);
    if (results) {
        return results;
    }

    results = objc_allocateClassPair(self, [mmapedClassName UTF8String], 0);
    class_setRequiresRawIsa(results);

    objc_registerClassPair(results);

    return results;
}

+(instancetype) allocAsMMappedObjectInFile:(NSFileHandle *) fh {
    Class mmapClass = [self _mmapZone_mmappedObjectClass];
    MmapZone *targetZone = [[MmapZone alloc] initWithFileHandle:fh size:class_getInstanceSize(mmapClass)];

    return CZAllocInZone(targetZone, mmapClass);
}

@end

@implementation MmapZone

+(void) initialize {
    if (self == [MmapZone class]) {
        CZRegisterZoneClass(self);
    }
}

-(id) initWithFileHandle:(NSFileHandle *) fh size:(size_t)size {
    if (self = [super init]) {
        self.fileHandle = fh;
        self.size = size;
    }

    return self;
}

-(const char *) name {
    return "MmapZone";
}

-(void *) allocate:(size_t)bytes {
    return mmap(NULL, self.size, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_FILE, [self.fileHandle fileDescriptor], 0);
}

-(void) deallocate:(void *)ptr {
    munmap(ptr, self.size);
}

@end