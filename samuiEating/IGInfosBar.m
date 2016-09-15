//
//  IGInfosBar.m
//  samuiEating
//
//  Created by Mac on 30/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGInfosBar.h"
#import "IGMeteoObject.h"
#import "IGClient.h"

@interface IGInfosBar ()

@property (nonatomic, strong)   IGMeteoObject   *meteoObject;

@end

UILabel         *welcome;
UILabel         *signup;
UILabel         *celcius;

@implementation IGInfosBar

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor    = [UIColor clearColor];
        // Initialize Meteo
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_meteoObject == nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTemperature:) name:@"temperatureOk" object:nil];
        
        self.backgroundColor    = [UIColor clearColor];
        _meteoObject            = [[IGMeteoObject alloc] init];
        CGRect frame            = self.frame;
        CGFloat space           = 5.f;
        CGFloat fontSize        = 14.f;//frame.size.width / 23.f;
        CGFloat tier            = frame.size.width / 3.f;
        
        // Set bar infos with time,date and meteo
        CGRect infoFrame = CGRectMake(frame.origin.x, 0,frame.size.width, 24);
        UIView *backgroundInfoBar = [[UIView alloc] initWithFrame:infoFrame];
        backgroundInfoBar.backgroundColor = [UIColor clearColor];
        // Add element
        // Watch
        CGRect watchFrame = CGRectMake(0,
                                       0,
                                       infoFrame.size.height,
                                       infoFrame.size.height);
        UIImageView *watchImage = [[UIImageView alloc] initWithFrame:watchFrame];
        watchImage.image = [UIImage imageNamed:@"watch.png"];
        CGRect stringWatchFrame = CGRectMake(watchFrame.origin.x + watchFrame.size.width + space,
                                             0,
                                             tier - watchFrame.size.width,
                                             watchFrame.size.height);
        UILabel *time = [[UILabel alloc] initWithFrame:stringWatchFrame];
        
        time.text = [_meteoObject getTime];
        time.textColor = [UIColor darkGrayColor];
        time.textAlignment = NSTextAlignmentLeft;
        time.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
        
        // Date
        CGRect dateFrame = CGRectMake(tier, 0, infoFrame.size.height, infoFrame.size.height);
        UIImageView *dateImage = [[UIImageView alloc] initWithFrame:dateFrame];
        dateImage.image = [UIImage imageNamed:@"calendar.png"];
        CGRect stringDateFrame = CGRectMake(dateFrame.origin.x + dateFrame.size.width + space,
                                            0,
                                            tier + dateFrame.size.width,
                                            dateFrame.size.height);
        
        UILabel *calendar       = [[UILabel alloc] initWithFrame:stringDateFrame];
        calendar.text           = [_meteoObject getDate];
        calendar.textColor      = [UIColor darkGrayColor];
        calendar.textAlignment  = NSTextAlignmentLeft;
        calendar.font           = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
        
        // Celcius
        CGRect celciusFrame = CGRectMake(stringDateFrame.origin.x + stringDateFrame.size.width,
                                         0,
                                         frame.size.width - (stringDateFrame.origin.x + stringDateFrame.size.width),
                                         infoFrame.size.height);
        
        celcius                 = [[UILabel alloc] initWithFrame:celciusFrame];
        celcius.textColor       = [UIColor darkGrayColor];
        celcius.textAlignment   = NSTextAlignmentLeft;
        celcius.font            = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
//        [self setTemperature];
        
        // Welcome
        CGFloat heightWelcome = frame.size.height - 24;
        heightWelcome *= 0.3846f;
        
        CGRect welcomeFrame = CGRectMake(0,
                                         infoFrame.size.height,// + 6,
                                         infoFrame.size.width,
                                         heightWelcome);//26);
        welcome             = [[UILabel alloc] initWithFrame:welcomeFrame];
        welcome.textColor   = [UIColor whiteColor];
        welcome.font        = [UIFont fontWithName:@"HelveticaNeue" size:[[IGClient sharedClient] setFontByDeviceType:21.f]];
        CGFloat heightSignup = (frame.size.height - 24) - heightWelcome;
        CGRect signFrame    = CGRectMake(0,
                                         welcomeFrame.origin.y + welcomeFrame.size.height,
                                         infoFrame.size.width,
                                         heightSignup);//44);
        signup                  = [[UILabel alloc] initWithFrame:signFrame];
        signup.textColor        = [UIColor whiteColor];
        signup.font             = [UIFont fontWithName:@"HelveticaNeue" size:[[IGClient sharedClient] setFontByDeviceType:15.f]];
        signup.numberOfLines    = 2;
        
        [self updateFacebookStatus];
        
        [backgroundInfoBar addSubview:watchImage];
        [backgroundInfoBar addSubview:time];
        [backgroundInfoBar addSubview:dateImage];
        [backgroundInfoBar addSubview:calendar];
        [backgroundInfoBar addSubview:celcius];
        
        [backgroundInfoBar addSubview:welcome];
        [backgroundInfoBar addSubview:signup];
        
        [self addSubview:backgroundInfoBar];
    }
}

- (void)fadeInformation:(float)alpha
{
    welcome.alpha   = 1.f - alpha;
    signup.alpha    = 1.f - alpha;
}

- (void)setTemperature:(NSNotification*)notification
{
    if ([_meteoObject getTemperature] != nil)
    {
        celcius.text = [NSString stringWithFormat:@"%@°C",[_meteoObject getTemperature]];
    }
}

- (void)updateFacebookStatus
{
    if ([[IGClient sharedClient] facebookName] == nil)
    {
        welcome.text    = @"Welcome Guest,";
        signup.text     = STR_WELCOME_GUEST;
    }
    else
    {
        welcome.text = [NSString stringWithFormat:@"Hi %@,",[[IGClient sharedClient] facebookName] ];
        signup.text = STR_WELCOME_FACEBOOK;
    }
}

@end
