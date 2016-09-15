//
//  IGMainTableViewCell.h
//  samuiEating
//
//  Created by Mac on 20/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGView.h"

@interface IGMainTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView    *mainCellImage;
@property (nonatomic, weak) IBOutlet UILabel        *mainCellTitle;
@property (nonatomic, weak) IBOutlet IGView         *mainCellLabelView;

@end
