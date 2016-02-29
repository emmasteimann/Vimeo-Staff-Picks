//
//  CoreDataManager.m
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/14/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager {
  NSManagedObjectModel *_managedObjectModel;
  NSManagedObjectContext *_managedObjectContext;
  NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

+ (CoreDataManager *)sharedInstance {
  static CoreDataManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

#pragma mark - Core Data Methods

- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"VimeoStaffPicks" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"VimeoStaffPicks.sqlite"];
  NSError *error = nil;
  NSString *failureReason = @"There was an error creating or loading the application's saved data.";
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
  dict[NSLocalizedFailureReasonErrorKey] = failureReason;
  dict[NSUnderlyingErrorKey] = error;
  
  ZAssert([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error], @"Failed to create PSC: \n%@\n%@", [error localizedDescription], [error userInfo]);
  
  return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (!coordinator) {
    return nil;
  }
  _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
  [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    NSError *error = nil;
    if ([managedObjectContext hasChanges]) {
      ZAssert([managedObjectContext save:&error], @"The save failed: %@\n%@", [error localizedDescription], [error userInfo]);
    }
  }
}

@end