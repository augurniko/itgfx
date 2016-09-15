//
//  IGListTableViewCell.m
//  samuiEating
//
//  Created by Mac on 20/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGListTableViewCell.h"
#import "IGViewLeft.h"

@implementation IGListTableViewCell

- (void)awakeFromNib {
    // Initialization code    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    if ([self isKindOfClass:[IGViewLeft class]])
        NSLog(@"find");
        
}

@end
