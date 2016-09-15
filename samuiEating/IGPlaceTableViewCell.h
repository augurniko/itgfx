//
//  IGPlaceTableViewCell.h
//  samuiEating
//
//  Created by Mac on 21/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGPlaceTableViewCell : UITableViewCell

// Normal call
@property (nonatomic, weak) IBOutlet UILabel        *placeCellHeaderLabel;
@property (nonatomic, weak) IBOutlet UIImageView    *placeIconImageView;
@property (nonatomic, weak) IBOutlet UITextView     *placeCellDescriptionTextView;
@property (nonatomic, weak) IBOutlet UIView         *placeSeparatorView;
@property (nonatomic, weak) IBOutlet UIScrollView   *placeSimilarScrollView;
@property (nonatomic, weak) IBOutlet UIView         *placeSimilarContentView;
@property (nonatomic, weak) IBOutlet UIImageView    *placeDiscountImageView;

// Button Cell --> Phone, mail, web, favorit
@property (nonatomic, weak) IBOutlet UIButton       *placeCellButton;

@end
