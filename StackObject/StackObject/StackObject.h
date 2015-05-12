//
//  StackObject.h
//  StackObject
//
//  Created by Richard Ross III on 5/11/15.
//
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define __stack  __attribute__((objc_precise_lifetime)) __strong
#define stack(kls) ((kls *) stackObject(alloca(class_getInstanceSize([kls class])), [kls class]))

id stackObject(void *ptr, Class kls) NS_RETURNS_RETAINED;