//
//  StaffPickDownloadOperation.m
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/14/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "StaffPickDownloadOperation.h"
#import "CoreDataManager.h"


// Insert your token here...
static NSString *token = @"b8e31bd89ba1ee093dc6ab0f863db1bd";

@interface StaffPickDownloadOperation()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectcontext;
@end

@implementation StaffPickDownloadOperation {
  NSURLSessionDataTask *_dataTask;
}
-(id)init {
  if (self = [super init])  {
    self.currentPage = 1;
  }
  return self;
}
- (void)main {
    if ([token isEqualToString:@""]) {
      NSLog(@"Hey... you haven't set your token... :-/ ");
    }
    self.managedObjectcontext = [CoreDataManager sharedInstance].managedObjectContext;
    NSString *urlString = [NSString stringWithFormat:@"https://api.vimeo.com/channels/staffpicks/videos?page=%lu", (unsigned long)self.currentPage];
    NSLog(@"%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *tokenBearer = [NSString stringWithFormat:@"bearer %@", token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:tokenBearer forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    _dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
      
      if (!error){
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        
        if (httpResp.statusCode == 200){
          NSError *jsonErr;
          
          NSDictionary *videoDictionary =
          [NSJSONSerialization JSONObjectWithData:data
                                          options:NSJSONReadingAllowFragments
                                            error:&jsonErr];
          
          if (!jsonErr){
            _loadedData = videoDictionary;
            self.currentPage++;
            [self completeOperation];
            return;
          }
          else{
            NSLog(@"%@", jsonErr.localizedDescription);
          }
        }
      } else{
        NSLog(@"%@", error.localizedDescription);
      }
      
      [self completeOperation];
    }];
    
    [_dataTask resume];
}

@end
