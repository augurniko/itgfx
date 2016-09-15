//
//  IGSimilarView.m
//  samuiEating
//
//  Created by Mac on 24/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGSimilarView.h"

#import "IGConstants.h"
#import "IGClient.h"
#import "UIImageView+AFNetworking.h"

@implementation IGSimilarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 10.f;
        self.layer.borderWidth  = 2.f;
        self.layer.borderColor  = [UIColor whiteColor].CGColor;
        self.backgroundColor    = [UIColor grayColor];
        self.clipsToBounds      = YES;
    }
    return self;
}

- (void)setParameters:(NSString *)pict title:(NSString *)title star:(NSNumber*)star
{
    _similarPicture = pict;
    _similarTitle   = title;
    _similarStar    = star;
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame            = self.frame;
    float mySpace           = 10.f;
    CGFloat widthPicture    = frame.size.height * 1.861111f;
    
    UIImageView *pict = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, widthPicture-2, frame.size.height-2)];
    pict.backgroundColor = [UIColor redColor];
    NSString *pictUrl   = [NSString stringWithFormat:@"%@%@",URL_ITGRAFIX_VIGNETTE, _similarPicture];
    [pict setImageWithURL:[NSURL URLWithString:pictUrl] placeholderImage:[UIImage imageNamed:@"place_holder_list.png"]];
    
    CGRect frameTitle = CGRectMake(widthPicture + mySpace, 0, frame.size.width - widthPicture - (mySpace * 2), (frame.size.height / 4) * 3);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frameTitle];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = _similarTitle;
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:[[IGClient sharedClient] setFontByDeviceType:17.f]]];
    titleLabel.numberOfLines = 3;
    
    // Set Rating
    if (_similarStar != nil)
    {
        CGSize sizeRate = CGSizeMake(frame.size.width / 4.f, (frame.size.width / 4.f) / 4.7f);
        
        CGRect frameStar = CGRectMake(widthPicture + mySpace,
                                      frame.size.height - (sizeRate.height * 1.5f),
                                      sizeRate.width,
                                      sizeRate.height);
        int nbrStar = [_similarStar intValue];
        NSString *ratingName = [NSString stringWithFormat:@"rating%i.png",nbrStar];

        UIImageView *starView = [[UIImageView alloc] initWithFrame:frameStar];
        starView.image = [UIImage imageNamed:ratingName];
        [self addSubview:starView];
    }
    [self addSubview:pict];
    [self addSubview:titleLabel];
}

@end
