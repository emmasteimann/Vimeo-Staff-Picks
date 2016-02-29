//
//  StaffPickPersistOperation.m
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/15/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "StaffPickPersistOperation.h"
#import "Video.h"
#import "CoreDataManager.h"

@interface StaffPickPersistOperation ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectcontext;
@property (strong, nonatomic) NSDictionary *results;
@end

@implementation StaffPickPersistOperation

-(instancetype)initWithResults:(NSDictionary *)results {
  if (self = [super init]) {
    self.results = results;
    self.managedObjectcontext = [CoreDataManager sharedInstance].managedObjectContext;
  }
  return self;
}

-(void)main {
  
  // The following code is basically an "upsert" update or insert
  
  // Make sure you're only adding what doesn't exist
  NSSortDescriptor *idDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
  NSArray *sortDescriptors = @[idDescriptor];
  NSArray *sortedResultsArray = [self.results[@"data"] sortedArrayUsingDescriptors:sortDescriptors];
  NSMutableArray *entityIDs = [[NSMutableArray alloc] init];
  
  for (NSDictionary *video in self.results[@"data"]) {
    id value = [video objectForKey:@"uri"];
    [entityIDs addObject:value];
  }
  
  [entityIDs sortUsingSelector:@selector(compare:)];
  
  // Check database to see what exists
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
  
  NSString *filter = @"(%K IN %@)";
  
  // Fetch by sorted entity ids
  [fetchRequest setPredicate: [NSPredicate predicateWithFormat: filter, @"id", entityIDs]];
  
  // Make sure results are sorted
  [fetchRequest setSortDescriptors: @[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES]]];
  
  NSError *fetchError;
  NSArray *entityMatchingIds = [_managedObjectcontext executeFetchRequest:fetchRequest error:&fetchError];
  
  // Update matching...
  NSMutableDictionary *currentMatches = [NSMutableDictionary dictionary];
  
  for (Video *video in entityMatchingIds) {
    currentMatches[video.id] = video;
  }
  
  for (NSDictionary *resultItem in sortedResultsArray) {
    Video *videoToUpdate;
    
    if ([currentMatches objectForKey:[resultItem valueForKey:@"uri"]]){
      // Update
      videoToUpdate = [currentMatches objectForKey:[resultItem valueForKey:@"uri"]];
    } else {
      // Insert
      videoToUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:_managedObjectcontext];
    }
    
    if (videoToUpdate) {
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
      [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
      [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
      NSDate *date = [dateFormat dateFromString:resultItem[@"created_time"]];
      
      [videoToUpdate setId:resultItem[@"uri"]];
      [videoToUpdate setDate:date];
      [videoToUpdate setTitle:resultItem[@"name"]];
      [videoToUpdate setImage:[[resultItem[@"pictures"][@"sizes"] firstObject] valueForKey:@"link"]];
      
      [videoToUpdate setVideo_url:resultItem[@"link"]];
    }
    
  }
  
  [[CoreDataManager sharedInstance] saveContext];
  [self completeOperation];
}
@end
