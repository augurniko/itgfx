//
//  IGTableViewController.m
//  samuiEating
//
//  Created by Mac on 15/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGTableViewController.h"
#import "IGPanelTableViewCell.h"
#import "IGMainViewController.h"
#import "IGListViewController.h"
#import "IGWebViewController.h"
#import "SWRevealViewController.h"
#import "UIImageView+AFNetworking.h"
#import "IGFacebookObject.h"
#import "IGClient.h"

#import "IGMeteoObject.h"

@interface IGTableViewController () <UITableViewDataSource, UITableViewDelegate, IGFacebookDelegate>
{
    NSArray     *button;
    NSInteger   selectedType;
    BOOL        facebookLogin;
}

@property (nonatomic, weak) IBOutlet UITableView    *panelTableView;
@property (nonatomic, weak) IBOutlet UIImageView    *facebookProfile;
@property (nonatomic, weak) IBOutlet UILabel        *facebookName;
@property (nonatomic, strong) IGFacebookObject      *facebook;

@end

@implementation IGTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set facebook profile Picture & Name
    self.facebook           = [[IGFacebookObject alloc] initWithViewController:self];
    self.facebook.delegate  = self;
    
    [self setFacebookParameters];
    
    // Set the button
    NSArray *discountList = [[IGClient sharedClient] getDiscountEntity];
    if ((discountList == nil) || ([discountList count] == 0))
    {
        button = @[@"Home",        @"home.png",
                   @"Favorits",    @"favorit.png",
                   @"Facebook",    @"facebook.png"];
    }
    else
    {
        button = @[@"Home",        @"home.png",
                   @"Favorits",    @"favorit.png",
                   @"Facebook",    @"facebook.png",
                   @"Promotion",   @"discount.png"];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[IGClient sharedClient] setTypeList:TYPE_NORMAL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFacebookParameters
{
    NSString *facebookProfileImageUrl = [[IGClient sharedClient] facebookProfileImageUrl];
    if (facebookProfileImageUrl != nil)
    {
        facebookLogin = YES;
        _facebookProfile.hidden = NO;
        [_facebookProfile setImageWithURL:[NSURL URLWithString:facebookProfileImageUrl]];
        
        _facebookProfile.layer.borderWidth  = 2.f;
        _facebookProfile.layer.borderColor  = [UIColor whiteColor].CGColor;
        _facebookProfile.clipsToBounds      = YES;
        
        NSString *facebookName = [[IGClient sharedClient] facebookName];
        if (facebookName != nil)
        {
            _facebookName.text = facebookName;
            
            [self updateFacebookStatus];
        }
        else
        {
            facebookLogin           = NO;
            _facebookProfile.hidden = YES;
            _facebookName.text      = @"Guest";
            
            [self updateFacebookStatus];
        }
    }
    else
    {
        facebookLogin           = NO;
        _facebookProfile.hidden = YES;
        _facebookName.text      = @"Guest";
        
        [self updateFacebookStatus];
    }
}

/* UPDATE FACEBOOK DATA IN MAINVIEW */
- (void)updateFacebookStatus
{
    UINavigationController *frontNavigationController = (UINavigationController*)self.revealViewController.frontViewController;
    
    if ([frontNavigationController.topViewController isKindOfClass:[IGListViewController class]])
    {
        IGListViewController* myController = (IGListViewController*)frontNavigationController.topViewController;
        [myController.infoBar updateFacebookStatus];
        [myController.listTableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [button count] / 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat{
    
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"panelCellIdentifier";
    
    IGPanelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[IGPanelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSInteger row = indexPath.row;
    
    NSString *pict              = [button objectAtIndex:(row * 2) + 1];
    cell.panelImageView.image   = [UIImage imageNamed:pict];
    
    NSString *text              = [button objectAtIndex:(row * 2)];
    if ([text isEqualToString:@"Facebook"])
    {
        if ([[IGClient sharedClient] facebookName] != nil)
        {
            NSString *facebookText  = @"Facebook logout";
            cell.panelLabel.text    = facebookText;
        }
        else
        {
            NSString *facebookText  = @"Facebook login";
            cell.panelLabel.text    = facebookText;
        }
    }
    else
    {
        cell.panelLabel.text        = text;
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger   row = indexPath.row;
    switch(row)
    {
        case 0:     // Close Panel
            [[IGClient sharedClient] setTypeList:TYPE_NORMAL];
            [[IGClient sharedClient] returnAvailableTypeList];            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"passToListView" object:self];
            [self.revealViewController revealToggleAnimated:YES];
            break;
        
        case 1:     // Display Favorit
        {
            NSArray *nbFav = [[IGClient sharedClient] getFavoritEntity:YES];
            if ([nbFav count] > 0)
            {
                [[IGClient sharedClient] setTypeList:TYPE_FAVORIT];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passToListView" object:self];
                [self.revealViewController revealToggleAnimated:YES];
            }
            else
            {
                [self displayMessage:STR_NO_FAVORIT];
            }
        }
        break;
            
            
        case 3:     // Display Discount
        {
            NSArray *discountList = [[IGClient sharedClient] getDiscountEntity];
            if ((discountList == nil) || ([discountList count] == 0))
            {
                [self displayMessage:STR_NO_DISCOUNT];
            }
            else
            {
                [[IGClient sharedClient] setTypeList:TYPE_DISCOUNT];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passToListView" object:self];
                [self.revealViewController revealToggleAnimated:YES];
            }
        }
        break;
            
        case 2:     // Login / Logout Facebook
            if (facebookLogin == YES)
            {
                [_facebook facebookLogout];
                [[IGClient sharedClient] setDataFriendsPlace:nil];
            }
            else
            {
                [_facebook facebookLogin];
            }
        break;
            
        case 4:     // Website
            if ([[IGClient sharedClient] internetConnection])
            {
//                [self performSegueWithIdentifier:@"panelToMapSegue" sender:self];
                [self performSegueWithIdentifier:@"panelToWebSegue" sender:self];
            }
            else
            {
                [self displayMessage:STR_NO_INTERNET];
            }
        break;
    }
}

/* POPUP MESSAGE */
- (void)displayMessage:(NSString*)message
{
    UIAlertController *alert =   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Close"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"panelToWebSegue"]) {
        IGWebViewController* tvc = [segue destinationViewController];
        tvc.myUrl = URL_ITGRAFIX_WEB;
    }
}

#pragma mark    ---------- FACEBOOK DELEGATE ----------
- (void)facebookConnected:(IGFacebookObject*)IGFacebookObject
{
    [self setFacebookParameters];
    [self.panelTableView reloadData];
}

- (void)facebookDisconnected:(IGFacebookObject*)IGFacebookObject
{
    [[IGClient sharedClient] resetFacebookInfoUser];
    [self setFacebookParameters];
    [self.panelTableView reloadData];    
}

- (void)facebookError:(IGFacebookObject*)IGFacebookObject error:(NSString*)error
{

}

@end
