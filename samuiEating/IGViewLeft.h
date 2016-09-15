//
//  IGViewLeft.h
//  samuiEating
//
//  Created by Mac on 10/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGViewLeft : UIView

@property (nonatomic, strong)   NSNumber    *red;
@property (nonatomic, strong)   NSNumber    *green;
@property (nonatomic, strong)   NSNumber    *blue;

- (id)initWithFrame:(CGRect)frame;

- (void)setColor:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end
