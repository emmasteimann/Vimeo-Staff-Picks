//
//  StaffPickVideoTableViewCell.m
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/15/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import "StaffPickVideoTableViewCell.h"

@implementation StaffPickVideoTableViewCell

- (void)swapImageInImageView:(UIImage *)image {
  self.videoImage.image = image;
  
  [self.videoImage reloadInputViews];
  [self.videoImage setNeedsDisplay];
  
}

@end
