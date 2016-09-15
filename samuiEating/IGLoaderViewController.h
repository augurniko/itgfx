//
//  IGLoaderViewController.h
//  samuiEating
//
//  Created by Mac on 17/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGLoaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton                   *connectWithFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton                   *connectAsGuestButton;
@property (weak, nonatomic) IBOutlet UILabel                    *connectLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *activtyView;

- (IBAction)facebookButton:(id)sender;
- (IBAction)guestButton:(id)sender;

@end
