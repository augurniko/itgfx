//
//  ViewController.m
//  samuiEating
//
//  Created by Mac on 12/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGMainViewController.h"

#import "SWRevealViewController.h"
#import "IGMainTableViewCell.h"
#import "IGListViewController.h"
#import "IGClient.h"
#import "UIImageView+AFNetworking.h"
#import "IGMeteoObject.h"

@interface IGMainViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray     *buttonCell;
}

@property (nonatomic, weak) IBOutlet    UITableView *mainTableView;
@property (nonatomic, weak) IBOutlet    UILabel     *welcomeLabel;
@property (nonatomic, weak) IBOutlet    UILabel     *signUpLabel;
@property (nonatomic, weak) IBOutlet    UILabel     *samuiTimeLabel;
@property (nonatomic, weak) IBOutlet    UILabel     *samuiDateLabel;
@property (nonatomic, weak) IBOutlet    UILabel     *samuiTemperatureLabel;
@property (nonatomic, weak) IBOutlet    UIImageView *backgroundImageView;

@end


@implementation IGMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set mainView
    [[IGClient sharedClient] setTypeList:TYPE_NORMAL];
    
    // Set bitmap on header
    self.navigationController.navigationBar.barStyle        = UIBarStyleDefault;
    
    // Init SWRevealView
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        revealViewController.rearViewRevealWidth = 320.0f;
        [self.buttonSidebar setTarget: self.revealViewController];
        [self.buttonSidebar setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    // Adapt tableViewCell size and add extra space on top
    [self.mainTableView setContentInset:UIEdgeInsetsMake(50,0,0,0)]; // Extra space
    
    self.mainTableView.estimatedRowHeight   = 200.0f;
    self.mainTableView.rowHeight            = UITableViewAutomaticDimension;

    [[IGClient sharedClient] generateTypeList];
    buttonCell                      = [[IGClient sharedClient] typeListArray];
    NSSortDescriptor *descriptor    = [NSSortDescriptor sortDescriptorWithKey:@"comment" ascending:YES];
    [buttonCell sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    
    // Set Time,Date and Meteo
    IGMeteoObject *meteoObject      = [[IGMeteoObject alloc] init];
    self.samuiTimeLabel.text        = [meteoObject getTime];
    self.samuiDateLabel.text        = [meteoObject getDate];
    self.samuiTemperatureLabel.text = @"29°C";
    
    // Set blur to background image
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.backgroundImageView.bounds;
    [self.backgroundImageView addSubview:visualEffectView];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openListView:) name:@"passToListView" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"KOH SAMUI GUIDE";
    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithRed:247.f / 255.f
                                                                              green:33.f  / 255.f
                                                                               blue:25.f  / 255.f
                                                                              alpha:1.f];
    
    [[IGClient sharedClient] setTypeList:TYPE_NORMAL];
    
    // Set Welcome & sign up label
    if ([[IGClient sharedClient] facebookName] == nil)
    {
        self.welcomeLabel.text = @"Welcome Guest,";
        self.signUpLabel.text = STR_WELCOME_GUEST;
    }
    else
    {
        self.welcomeLabel.text = [NSString stringWithFormat:@"Hi %@,",[[IGClient sharedClient] facebookName] ];
        self.signUpLabel.text = STR_WELCOME_FACEBOOK;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
    [[IGClient sharedClient] setTypeList:TYPE_NORMAL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---------- UITABLEVIEW DELEGATE ----------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [buttonCell count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 200;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"mainCellIdentifier";
    
    IGMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[IGMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSInteger row = indexPath.row;

    NSArray *color = [[[buttonCell objectAtIndex:row] objectForKey:@"option"] componentsSeparatedByString:@","];
    
    CGFloat r = [[color objectAtIndex:0] floatValue];
    CGFloat g = [[color objectAtIndex:1] floatValue];
    CGFloat b = [[color objectAtIndex:2] floatValue];
    [cell.mainCellLabelView setColor:r green:g blue:b];
    
    cell.backgroundColor = [UIColor clearColor];
    [cell.mainCellImage setImage:[UIImage imageNamed:[[buttonCell objectAtIndex:row] objectForKey:@"picture"]]];
    cell.mainCellTitle.text = [[buttonCell objectAtIndex:row] objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"mainToListSegue" sender:self];
}
/*
- (void)openListView:(NSNotification*)notification
{
    [self performSegueWithIdentifier:@"mainToListSegue" sender:self];
}
*/
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"mainToListSegue"])
    {
        IGListViewController* tvc = [segue destinationViewController];
        
        NSInteger type = [[IGClient sharedClient] getTypeList];
        switch (type)
        {
            case TYPE_NORMAL:
            {
                NSInteger row = [self.mainTableView indexPathForSelectedRow].row;
                tvc.myType = [buttonCell objectAtIndex:row];
            }
            break;
                
            case TYPE_FAVORIT:
                tvc.myType = [NSDictionary dictionaryWithObjectsAndKeys:@"favorit", @"name", @"247,33,25", @"option", nil];
                break;
                
            case TYPE_DISCOUNT:
                tvc.myType = [NSDictionary dictionaryWithObjectsAndKeys:@"discount", @"name", nil];
                break;
        }
    }
}


@end
