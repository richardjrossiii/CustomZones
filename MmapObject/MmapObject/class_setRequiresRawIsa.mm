//
//  class_setRequiresRawIsa.m
//  MmapObject
//
//  Created by Richard Ross III on 5/12/15.
//
//
#include <objc-private.h>

// Explanation:
//
// In the 'new' 64-bit objc runtime, the runtime will store information in an object's `isa` pointer itself,
// such as retain count, associated object keys, etc.
//
// For some custom allocators, (such as our mmap'd one), we have to ensure that our retain count is safely
// stored away from the object itself, otherwise we'll have conflicts with what the retain count actually is,
// causing the runtime to flip a shit if we have multiple objects pointing to MAP_SHARED memory.
//
// Normally, you don't want to do this to every single object of a class, so your best bet is to only apply
// this to a subclass and only allocate with a raw isa when absolutely necessary (as using the objc sidetable is
// significantly slower than the isa mangling).
extern "C" void class_setRequiresRawIsa(objc_class *kls) {
    kls->bits.setRequiresRawIsa();
}