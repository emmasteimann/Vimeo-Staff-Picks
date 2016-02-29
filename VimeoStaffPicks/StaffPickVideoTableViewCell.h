//
//  StaffPickVideoTableViewCell.h
//  VimeoStaffPicks
//
//  Created by Emma Steimann on 2/15/16.
//  Copyright © 2016 Vimeo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaffPickVideoTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)swapImageInImageView:(UIImage *)image;
@end
