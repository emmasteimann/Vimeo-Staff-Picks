//
//  StaffPicksTableViewController.m
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/13/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "StaffPicksTableViewController.h"
#import "CoreDataManager.h"
#import "Video.h"
#import "StaffPickDownloadOperation.h"
#import "StaffPickPersistOperation.h"
#import "StaffPickVideoTableViewCell.h"
#import "ImageCache.h"
#import "ImageDownloader.h"
#import "AssociatedObject.h"

static NSString* cellIdentifier = @"VideoCell";

@interface StaffPicksTableViewController ()
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *videoFetchRequest;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) ImageDownloader *imageDownloader;
@property (nonatomic, assign) NSUInteger page;
@end

@implementation StaffPicksTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.imageDownloader = [[ImageDownloader alloc] init];
  self.isFetching = NO;
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.tableView addSubview:self.refreshControl];
  
  NSUInteger page = [self getCurrentPage];
  if (page && page != 0) {
    self.page = page;
  } else {
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"currentPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.page = 1;
  }
  
  [self buildFetchVideoRequest];
  
  if ([self hasPreviouslyStoredItems]){
    [self performVideoFetch];
    [self fetchNewWithPage:1];
  } else {
    [self fetchNew];
  }
  
  self.clearsSelectionOnViewWillAppear = NO;
}

- (NSUInteger)getCurrentPage {
  return [[NSUserDefaults standardUserDefaults] integerForKey:@"currentPage"];
}

#pragma mark - Fetch Methods

- (BOOL)hasPreviouslyStoredItems {
  NSError *error = nil;
  NSUInteger count = [[CoreDataManager sharedInstance].managedObjectContext countForFetchRequest:self.videoFetchRequest error:&error];
  
  if (!error && count > 0) {
    return YES;
  } else {
    return NO;
  }
}

- (void)fetchNew {
  [self fetchNewWithPage:self.page];
  self.page++;
  [[NSUserDefaults standardUserDefaults] setInteger:self.page forKey:@"currentPage"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fetchNewWithPage:(NSUInteger)page {
  self.isFetching = YES;
  
  StaffPickDownloadOperation *staffPickOp = [[StaffPickDownloadOperation alloc] init];
  staffPickOp.currentPage = page;
  __weak StaffPickDownloadOperation *weakStaffPickOp = staffPickOp;
  
  [staffPickOp setCompletionBlock:^{
    StaffPickDownloadOperation *strongSearchOp = weakStaffPickOp;
    [self maintainResultsCache:strongSearchOp.loadedData];
    [self.refreshControl endRefreshing];
  }];
  
  [[NSOperationQueue mainQueue] addOperation: staffPickOp];
}

-(void)maintainResultsCache:(NSDictionary *)results {
  StaffPickPersistOperation *persistVideoOp = [[StaffPickPersistOperation alloc] initWithResults:results];
  
  [persistVideoOp setCompletionBlock:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self performVideoFetch];
    });
  }];
  
  [[NSOperationQueue mainQueue] addOperation:persistVideoOp];
}

-(void)performVideoFetch {
  NSError *error;
  BOOL success = [self.fetchedResultsController performFetch:&error];
  if (success && !error) {
    self.isFetching = NO;
    [self.tableView reloadData];
  }
}

- (void)buildFetchVideoRequest {
  self.videoFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
  NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
  [self.videoFetchRequest setSortDescriptors:sortDescriptors];
  
  self.fetchedResultsController =[[NSFetchedResultsController alloc] initWithFetchRequest:self.videoFetchRequest managedObjectContext:[CoreDataManager sharedInstance].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
  [self.fetchedResultsController setDelegate:self];
}

#pragma mark - UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Video *video = [self.fetchedResultsController objectAtIndexPath:indexPath];
  StaffPickVideoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if (cell == nil) {
    cell = [[StaffPickVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
  
  cell.titleLabel.text = video.title;
  
  // Yes, I'm using associated object.
  // Not super necessary (appears to work fine without it)
  // The reference should be maintained, but a userful check anyhow.
  
  cell.videoImage.associatedObject = video.image;
  
  cell.videoImage.image = [UIImage imageNamed:@"placeholder.png"];
  
  if ([[ImageCache sharedInstance] doesImageForURLExist:video.image]) {
    cell.videoImage.image = [[ImageCache sharedInstance] getImageForURL:video.image];
  } else {
    [self.imageDownloader loadImageFromURLString:video.image callback:^(UIImage *image, NSString *url){
      if ([cell.videoImage.associatedObject isEqualToString:url]) {
        [cell swapImageInImageView:image];
      }
    }];
  }
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    Video *video = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (video && video.video_url) {
      NSURL *urlString = [NSURL URLWithString:video.video_url];
      SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:urlString];
      [self presentViewController:svc animated:YES completion:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (self.refreshControl.refreshing) {
    [self fetchNewWithPage:1];
  }
  
  float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
  if (bottomEdge >= scrollView.contentSize.height - 60 && !self.isFetching) {
    [self fetchNew];
  }
}

// Boilerplate beyond this point

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  if ([[self.fetchedResultsController sections] count] > 0) {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
  } else {
    return 0;
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if ([[self.fetchedResultsController sections] count] > 0) {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
  } else
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
  return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - NSFetchedResultsController Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeUpdate:
      break;
    case NSFetchedResultsChangeMove:
      break;
  }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  
  UITableView *tableView = self.tableView;
  
  switch(type) {
      
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeUpdate:
      break;
  }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.tableView endUpdates];
}
@end
