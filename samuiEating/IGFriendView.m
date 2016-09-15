//
//  IGFriendView.m
//  samuiEating
//
//  Created by Mac on 13/07/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGFriendView.h"

#import "IGConstants.h"
#import "IGClient.h"
#import "UIImageView+AFNetworking.h"

@implementation IGFriendView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 10.f;
        self.layer.borderWidth  = 2.f;
        self.layer.borderColor  = [UIColor clearColor].CGColor;
        self.backgroundColor    = [UIColor clearColor];
        self.clipsToBounds      = YES;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setParameters:(NSString *)pict name:(NSString *)name date:(NSString*)date
{
    _friendPicture  = pict;
    _friendName     = name;
    _friendDate     = date;
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame            = self.frame;
    float mySpace           = 10.f;
    CGFloat widthPicture    = frame.size.height / 2.f;
    
    UIImageView *pict = [[UIImageView alloc] initWithFrame:CGRectMake(mySpace, (frame.size.height / 2) - 3, widthPicture, widthPicture)];
    pict.backgroundColor = [UIColor redColor];
    pict.layer.cornerRadius = widthPicture / 2;
    pict.layer.borderWidth  = 3.f;
    pict.layer.borderColor  = [UIColor grayColor].CGColor;
    pict.clipsToBounds      = YES;
    
    NSString *pictUrl   = [NSString stringWithFormat:URL_PICTURE_FACEBOOK, _friendPicture];
    [pict setImageWithURL:[NSURL URLWithString:pictUrl] placeholderImage:[UIImage imageNamed:@"place_holder_list.png"]];
    
    CGRect frameTitle = CGRectMake(widthPicture * 1.5f, (frame.size.height / 2) - 3, frame.size.width - widthPicture - (mySpace * 2), [[IGClient sharedClient] setFontByDeviceType:17.f] + (mySpace/2));
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frameTitle];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = _friendName;
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:[[IGClient sharedClient] setFontByDeviceType:17.f]]];
    
    // Set Date
    CGRect frameDate = CGRectMake(frameTitle.origin.x, frameTitle.origin.y + frameTitle.size.height, frameTitle.size.width, [[IGClient sharedClient] setFontByDeviceType:15.f]+(mySpace/2));
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:frameDate];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.text = _friendDate;
    [dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:[[IGClient sharedClient] setFontByDeviceType:14.f]]];
  
    
    [self addSubview:pict];
    [self addSubview:titleLabel];
    [self addSubview:dateLabel];
}

@end
