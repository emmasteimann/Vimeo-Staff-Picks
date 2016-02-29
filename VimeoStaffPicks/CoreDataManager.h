//
//  CoreDataManager.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/14/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface CoreDataManager : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (CoreDataManager *)sharedInstance;
@end
