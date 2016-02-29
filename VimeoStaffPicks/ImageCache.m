//
//  ImageCache.m
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/13/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

+ (ImageCache *)sharedInstance {
  
  static ImageCache *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  
  if (self = [super init]) {
    self.imgCache = [[NSCache alloc] init];
  }
  
  return self;
}

- (void)addImageURL:(NSString *)imageURL withImage:(UIImage *)image {
  
  [self.imgCache setObject:image forKey:imageURL];
}

- (UIImage *)getImageForURL:(NSString *)imageURL {
  
  return [self.imgCache objectForKey:imageURL];
}

- (BOOL)doesImageForURLExist:(NSString *)imageURL {
  
  if ([self.imgCache objectForKey:imageURL] == nil)
  {
    return NO;
  }
  
  return YES;
}


@end