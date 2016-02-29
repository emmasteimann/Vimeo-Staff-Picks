//
//  StaffPickDownloadOperation.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/14/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "ConcurrentOperation.h"

@interface StaffPickDownloadOperation : ConcurrentOperation
@property (nonatomic, strong) NSDictionary *loadedData;
@property (assign, nonatomic) NSUInteger currentPage;

@end
