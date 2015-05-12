//
//  StackObject.h
//  StackObject
//
//  Created by Richard Ross III on 5/11/15.
//
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define STACK_OBJECT  __attribute__((objc_precise_lifetime)) __strong
#define __stack(kls) stackObject(alloca(class_getInstanceSize([kls class])), [kls class])

__strong id stackObject(void *ptr, Class kls) NS_RETURNS_RETAINED;