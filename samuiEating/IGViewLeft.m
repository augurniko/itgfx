//
//  IGViewLeft.m
//  samuiEating
//
//  Created by Mac on 10/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGViewLeft.h"

@implementation IGViewLeft

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame = self.frame;
    CGFloat widthAdd = 7.f;//frame.size.height / 4.f;
    CGFloat heightAdd = frame.size.height / 2.f;
    
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    /*
     __________________________________
     \
      \
      /
     /_________________________________
     */
    CGContextMoveToPoint   (ctx, minX,              maxY);  // top left
    CGContextAddLineToPoint(ctx, maxX,              maxY);  // top right
    CGContextAddLineToPoint(ctx, maxX,              minY); // bottom right
    CGContextAddLineToPoint(ctx, minX,              minY);  // bottom left
    CGContextAddLineToPoint(ctx, minX + widthAdd,   maxY - heightAdd); // mid right
    
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx
                             , [_red floatValue]    /255.0
                             , [_green floatValue]  /255.0
                             , [_blue floatValue]   /255.0
                             , 1);
    CGContextFillPath(ctx);
    
    // Add shadow
    self.layer.masksToBounds    = NO;
    self.layer.shadowOffset     = CGSizeMake(2, 2);
    self.layer.shadowRadius     = 3;
    self.layer.shadowOpacity    = 0.7;
    
}

- (void)setColor:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    _red     = [NSNumber numberWithFloat:red];
    _green   = [NSNumber numberWithFloat:green];
    _blue    = [NSNumber numberWithFloat:blue];
}


@end
