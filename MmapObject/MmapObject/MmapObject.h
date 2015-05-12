//
//  MmapObject.h
//  MmapObject
//
//  Created by Richard Ross III on 5/11/15.
//
//

#import <Cocoa/Cocoa.h>

@interface NSObject(MmapObject)

+(instancetype) allocAsMMappedObjectInFile:(NSFileHandle *) fh;

@end