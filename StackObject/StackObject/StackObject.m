//
//  StackObject.m
//  StackObject
//
//  Created by Richard Ross III on 5/11/15.
//
//

#import "StackObject.h"

@import CustomZones;

@interface StackZone : NSObject<CustomZone>

@property void *stackPtr;

@end

@implementation StackZone

+(StackZone *) instance {
    static __thread StackZone *zone;
    if (zone == nil) {
        zone = [StackZone new];
    }

    return zone;
}

-(const char *) name {
    return "StackZone";
}

-(void *) allocate:(size_t)bytes {
    return self.stackPtr;
}

-(void) deallocate:(void *)ptr {
    // Do nothing, already on the stack.
}

@end

__strong id stackObject(void *ptr, Class kls) NS_RETURNS_RETAINED {
    StackZone *zone = [StackZone instance];
    zone.stackPtr = ptr;

    return CZAllocInZone([StackZone instance], kls);
}