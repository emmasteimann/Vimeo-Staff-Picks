//
//  Video+CoreDataProperties.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/16/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Video.h"

NS_ASSUME_NONNULL_BEGIN

@interface Video (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *video_url;

@end

NS_ASSUME_NONNULL_END
