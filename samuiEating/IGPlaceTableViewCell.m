//
//  IGPlaceTableViewCell.m
//  samuiEating
//
//  Created by Mac on 21/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGPlaceTableViewCell.h"

@implementation IGPlaceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //Calling from here fixed issue for coming back to the tableview from other ViewConroller
    CGRect frame = self.frame;
    CGRect textViewFrame = _placeCellDescriptionTextView.frame;
    textViewFrame.size.height = frame.size.height;
    _placeCellDescriptionTextView.frame = textViewFrame;
    
    CGRect separatorFrame = _placeSeparatorView.frame;
    frame.origin.y = 1;//frame.size.height - 1;
    frame.origin.x = separatorFrame.origin.x;
    frame.size.height = 1;
    frame.size.width = separatorFrame.size.width;
    
    _placeSeparatorView.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
