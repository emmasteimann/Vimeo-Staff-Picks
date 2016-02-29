//
//  StaffPickPersistOperation.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/15/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "ConcurrentOperation.h"

@interface StaffPickPersistOperation : ConcurrentOperation
-(instancetype)initWithResults:(NSDictionary *)results;
@end
