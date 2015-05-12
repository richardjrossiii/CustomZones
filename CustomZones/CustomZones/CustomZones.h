//
//  CustomZones.h
//  CustomZones
//
//  Created by Richard Ross III on 5/11/15.
//
//

#import <Foundation/Foundation.h>

@protocol CustomZone <NSObject>

-(const char *) name;

@optional
-(void *) allocate:(size_t) bytes;
-(void *) reallocate:(void *) ptr toSize:(size_t) bytes;

-(void) deallocate:(void *) ptr;

@end

FOUNDATION_EXPORT void CZRegisterZoneClass(Class<CustomZone> kls);
FOUNDATION_EXPORT id CZAllocInZone(id<CustomZone> zone, Class targetKls) NS_RETURNS_RETAINED;