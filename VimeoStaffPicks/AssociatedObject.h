//
//  AssociatedObject.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/15/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#ifndef AssociatedObject_h
#define AssociatedObject_h
#import <objc/runtime.h>

@interface NSObject (Associating)

@property (nonatomic, retain) id associatedObject;

@end

@implementation NSObject (Associating)

- (id)associatedObject
{
  return objc_getAssociatedObject(self, @selector(associatedObject));
}

- (void)setAssociatedObject:(id)associatedObject
{
  objc_setAssociatedObject(self,
                           @selector(associatedObject),
                           associatedObject,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#endif /* AssociatedObject_h */
