//
//  ImageDownloader.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/13/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

@import UIKit;

@interface ImageDownloader : NSObject
@property (nonatomic, copy) void (^completionHandler)(void);
- (void) loadImageFromURLString: (NSString*)url callback:(void (^)(UIImage *image, NSString *imageUrl))callback;
@end
