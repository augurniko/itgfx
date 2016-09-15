//
//  IGLoaderViewController.m
//  samuiEating
//
//  Created by Mac on 17/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGLoaderViewController.h"

#import "IGClient.h"
#import "IGFacebookObject.h"

#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "IGListViewController.h"

@interface IGLoaderViewController () <IGFacebookDelegate>

@property (nonatomic, weak)   IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IGFacebookObject *facebook;

@end

@implementation IGLoaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *launchScreen = [self getLaunchImage];
    self.backgroundImageView.image = [UIImage imageNamed:launchScreen];
    
    self.facebook = [[IGFacebookObject alloc] initWithViewController:self];
    self.facebook.delegate = self;
    
    // delegate IGClient loader
    [[IGClient sharedClient] setDelegate:self];
    
    // Start GeoLocation
    [[IGClient sharedClient] startLocation];
    
    // Replace constraint for iphone // BUG IOS ??????
    if (IPAD)
    {
        
    }
    else
    {
        UIImageView *subView    = self.backgroundImageView;
        UIView *parent          = self.view;
        
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        
        //Trailing
        NSLayoutConstraint *trailing =[NSLayoutConstraint
                                       constraintWithItem:subView
                                       attribute:NSLayoutAttributeTrailing
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:parent
                                       attribute:NSLayoutAttributeTrailing
                                       multiplier:1.0f
                                       constant:0.f];
        
        //Leading
        NSLayoutConstraint *leading = [NSLayoutConstraint
                                       constraintWithItem:subView
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:parent
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1.0f
                                       constant:0.f];
        
        [parent addConstraint:trailing];
        [parent addConstraint:leading];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Design connect button
    float cornerButton = self.connectWithFacebookButton.frame.size.height / 2;
    [self.connectWithFacebookButton.titleLabel setFont:[self.connectWithFacebookButton.titleLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
    self.connectWithFacebookButton.layer.cornerRadius = cornerButton;
    self.connectWithFacebookButton.layer.borderColor = [UIColor colorWithRed:36.f/255.F green:75.f/255.f blue:140.f/255.f alpha:1.0f].CGColor;
    self.connectWithFacebookButton.layer.borderWidth = 1.0f;
    self.connectWithFacebookButton.backgroundColor = [UIColor colorWithRed:36.f/255.f green:75.f/255.f blue:140.f/255.f alpha:1.0f];

    self.connectAsGuestButton.layer.cornerRadius = cornerButton;
    [self.connectAsGuestButton.titleLabel setFont:[self.connectAsGuestButton.titleLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
    self.connectAsGuestButton.layer.borderColor = [UIColor colorWithRed:1.f green:0.f blue:0.f alpha:1.0f].CGColor;
    self.connectAsGuestButton.layer.borderWidth = 1.0f;
    self.connectAsGuestButton.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:0.f alpha:1.0f];
    
    [self.connectLabel setFont:[self.connectLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)getLaunchImage
{
    CGSize viewSize = self.view.bounds.size;
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize))
            return dict[@"UILaunchImageName"];
    }
    return nil;
}

#pragma mark    ---------- FADE IN ANIMATION ----------
-(void) fadeIn
{
    [self.connectWithFacebookButton setAlpha:0];
    [UIButton beginAnimations:NULL context:nil];
    [UIButton setAnimationDuration:TIMER_FADE_IN];
    [self.connectWithFacebookButton setAlpha:1];
    [UIButton commitAnimations];
    
    [self.connectAsGuestButton setAlpha:0];
    [UIButton beginAnimations:NULL context:nil];
    [UIButton setAnimationDuration:TIMER_FADE_IN];
    [self.connectAsGuestButton setAlpha:1];
    [UIButton commitAnimations];
    
    [self.connectLabel setAlpha:0];
    [UILabel beginAnimations:NULL context:nil];
    [UILabel setAnimationDuration:TIMER_FADE_IN];
    [self.connectLabel setAlpha:1];
    [UILabel commitAnimations];
}

#pragma mark    ---------- LOGIN REQUEST ----------
- (void)requestLogin
{
    [[IGClient sharedClient] generateTypeList];
    [self.facebook getFacebookData];
}

#pragma mark    ---------- BUTTON ACTION ----------
- (IBAction)facebookButton:(id)sender
{
    [self.facebook facebookLogin];
}

- (IBAction)guestButton:(id)sender
{
    [self performSegueWithIdentifier:@"loaderToMainView" sender:self];
}

#pragma mark    ---------- IGCLIENT DELEGATE -----------
- (void)jsonDownloaded:(IGClient*)IGClient
{
    // Download ok
    [self requestLogin];
}

- (void)jsonError:(IGClient*)IGClient error:(NSString*)error
{
    // Error in download
    if ([error isEqualToString:STR_FIRST_LAUNCH])
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:STR_FIRST_LAUNCH
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([error isEqualToString:STR_SERVER_ERROR])
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:STR_SERVER_ERROR
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self requestLogin];
    }
}

#pragma mark    ---------- FACEBOOK DELEGATE ----------
- (void)facebookConnected:(IGFacebookObject*)IGFacebookObject
{
    [self performSegueWithIdentifier:@"loaderToMainView" sender:self];
}

- (void)facebookDisconnected:(IGFacebookObject*)IGFacebookObject
{
    self.activtyView.hidden                 = YES;
    self.connectWithFacebookButton.hidden   = NO;
    self.connectAsGuestButton.hidden        = NO;
    self.connectLabel.hidden                = NO;
    
    [self fadeIn];
}

- (void)facebookError:(IGFacebookObject*)IGFacebookObject error:(NSString*)error
{
    self.activtyView.hidden                 = YES;
    self.connectWithFacebookButton.hidden   = NO;
    self.connectAsGuestButton.hidden        = NO;
    self.connectLabel.hidden                = NO;
    
    [self fadeIn];
}

#pragma mark    ---------- SEGUE NAVIGATION ----------
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"loaderToMainView"])
    {
        SWRevealViewController *revealController = [segue destinationViewController];
        UINavigationController *navigationController = nil;
        
        if ([[IGClient sharedClient] returnAvailableTypeList] == 1)
        {
            navigationController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"navigationControllerList"];
        }
        else
        {
            navigationController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"navigationControllerMain"];
        }
        [revealController setFrontViewController:navigationController animated:YES];

    }
}

@end
