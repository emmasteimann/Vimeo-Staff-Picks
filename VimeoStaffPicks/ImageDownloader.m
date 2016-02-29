//
//  ImageDownloader.m
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/13/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "ImageDownloader.h"
#import "ImageCache.h"

@implementation ImageDownloader
- (void) loadImageFromURLString: (NSString*)url callback:(void (^)(UIImage *image, NSString *imageUrl))callback {
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    if (![[ImageCache sharedInstance] doesImageForURLExist:url]) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
          
          if (!error){
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            
            if (httpResp.statusCode == 200){
              UIImage *image = [[UIImage alloc] initWithData:data];
              [[ImageCache sharedInstance] addImageURL:url withImage:image];
              dispatch_async(dispatch_get_main_queue(), ^{
                callback(image, url);
              });
            }
          } else{
            NSLog(@"%@", error.localizedDescription);
          }
          
        }];
        
        [dataTask resume];
      }
    });
}
@end
