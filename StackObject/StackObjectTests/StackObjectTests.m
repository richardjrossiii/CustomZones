//
//  StackObjectTests.m
//  StackObjectTests
//
//  Created by Richard Ross III on 5/11/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "StackObject.h"

@interface StackObjectTests : XCTestCase

@end

@implementation StackObjectTests

- (void)testStackObjectIsObject {
    __stack NSObject *obj = [stack(NSObject) init];

    XCTAssertNotNil(obj);
    XCTAssertNotNil([obj description]);
}

- (void)testStackObjectIsOnStack {
    __stack NSObject *obj = [stack(NSObject) init];
    ptrdiff_t diff = ((void *) &obj - (__bridge void *) (obj));

    // the two pointers should be nearly identical
    XCTAssertLessThan(diff, PAGE_SIZE);
}

@end
