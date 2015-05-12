//
//  MmapObjectTests.m
//  MmapObjectTests
//
//  Created by Richard Ross III on 5/11/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "MmapObject.h"

@interface MappedObject : NSObject

@property int x, y;
@property float z;

@end

@implementation MappedObject
@end

@interface MmapObjectTests : XCTestCase

@property NSFileHandle *fileHandle;

@end

@implementation MmapObjectTests

- (void)setUp {
    [super setUp];

    self.fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:0];
}

- (void)testObjectHasReadwriteProperties {
    MappedObject *mappedObject = [[MappedObject allocAsMMappedObjectInFile:self.fileHandle] init];

    mappedObject.x = 5;
    mappedObject.y = 7;
    mappedObject.z = M_PI;

    XCTAssertEqual(mappedObject.x, 5);
    XCTAssertEqual(mappedObject.y, 7);
    XCTAssertEqual(mappedObject.z, M_PI);
}

- (void)testSharedObjectChangesPropagate {
    MappedObject *object1 = [[MappedObject allocAsMMappedObjectInFile:self.fileHandle] init];
    MappedObject *object2 = [[MappedObject allocAsMMappedObjectInFile:self.fileHandle] init];

    XCTAssertNotEqual(object1, object2);

    object1.x = 5;

    XCTAssertEqual(object1.x, object2.x);

    object2.y = 7;

    XCTAssertEqual(object1.y, object2.y);

    object1.z = M_PI;
    object2.z = object2.z / 2;

    XCTAssertEqual(object1.z, object2.z);
    XCTAssertEqual(object1.z, M_PI_2);
}

@end
