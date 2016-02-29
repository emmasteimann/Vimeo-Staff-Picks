//
//  ImageCache.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/13/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

@import UIKit;

@interface ImageCache : NSObject

@property (nonatomic, retain) NSCache *imgCache;


#pragma mark - Methods

+ (ImageCache*)sharedInstance;
- (void)addImageURL:(NSString *)imageURL withImage:(UIImage *)image;
- (UIImage *)getImageForURL:(NSString *)imageURL;
- (BOOL)doesImageForURLExist:(NSString *)imageURL;

@end