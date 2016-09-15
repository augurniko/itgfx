//
//  IGListTableViewCell.h
//  samuiEating
//
//  Created by Mac on 20/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGViewLeft.h"

@interface IGListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView    *listCellImage;
@property (nonatomic, weak) IBOutlet UIImageView    *listCellRatingImage;
@property (nonatomic, weak) IBOutlet UILabel        *listCellTitle;
@property (nonatomic, weak) IBOutlet UILabel        *listCellOption;
@property (nonatomic, weak) IBOutlet IGViewLeft     *listCellOptionView;
@property (nonatomic, weak) IBOutlet UILabel        *listCellDiscount;
@property (nonatomic, weak) IBOutlet IGViewLeft     *listCellDiscountView;
@property (nonatomic, weak) IBOutlet UIView         *gradientViewTitle;

@end
