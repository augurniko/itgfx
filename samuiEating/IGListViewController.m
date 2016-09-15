//
//  IGListTableViewController.m
//  samuiEating
//
//  Created by Mac on 20/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGListViewController.h"

#import "SWRevealViewController.h"
#import "IGListTableViewCell.h"
#import "IGPlaceViewController.h"
#import "IGClient.h"
#import "UIImageView+AFNetworking.h"


@interface IGListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    CGRect frame;
}

@property (nonatomic, weak) IBOutlet    UIView      *limitTableView;
@property (nonatomic, weak) IBOutlet    UIImageView *backgroundImageView;

@property (strong) NSArray *placeArray;

@end

@implementation IGListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.myType == nil)
    {
        [self forOnlyOneType];
    }
        
    [self populateArray:[self.myType objectForKey:@"name"]];
    
    // Adapt tableViewCell size
//    self.listTableView.estimatedRowHeight = 205.0f;
//    self.listTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Set blur to background image
    // Becarefull the blur make flashing when come back from SWRevealView
/*    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.view.bounds;//self.backgroundImageView.bounds;
    [self.backgroundImageView addSubview:visualEffectView];*/
    
    // Observer for Favorit & Promotion
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFavoritOrDiscount:) name:@"passToListView" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    // Set title& color navigationbar
    if (([[IGClient sharedClient] returnAvailableTypeList] == 1) && ([[IGClient sharedClient] getTypeList] == TYPE_NORMAL))
    {
        self.navigationItem.title = @"EATING ON SAMUI";
    }
    else
    {
        if ([[IGClient sharedClient] getTypeList] == TYPE_NORMAL)
            self.navigationItem.title = [self.myType objectForKey:@"name"];
        if ([[IGClient sharedClient] getTypeList] == TYPE_FAVORIT)
            self.navigationItem.title = @"FAVORIT";
        if ([[IGClient sharedClient] getTypeList] == TYPE_DISCOUNT)
            self.navigationItem.title = @"PROMOTION";
    }
    
    NSArray *color = [[self.myType objectForKey:@"option"] componentsSeparatedByString:@","];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:
                                               [[color objectAtIndex:0] floatValue] / 255
                                         green:[[color objectAtIndex:1] floatValue] / 255
                                          blue:[[color objectAtIndex:2] floatValue] / 255
                                         alpha:1.f];
    
    // Camlculate size of cell
    frame = self.view.frame;
    frame.size.height = frame.size.width / 1.82926f;// (frame.size.width / 2.025f);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----------- COREDATA MANAGMENT ------------
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark ----------- TYPE TO DISPLAY ------------
- (void)forOnlyOneType
{
    self.myType = nil;
    self.myType = [[IGClient sharedClient] onlyOneType];
    
    CGRect mainFrame        = self.view.frame;
    CGFloat heightInfo      = mainFrame.size.height * 0.15f;
    CGRect infoFrame        = _infoBar.frame;
    infoFrame.size.height   = heightInfo;
    _infoBar.frame          = infoFrame;
    _infoBar.hidden         = NO;
    CGRect frameLimit       = _limitTableView.frame;
    frameLimit.size.height  = 24; // Constant
    _limitTableView.frame   = frameLimit;
    CGRect frameTableView   = self.listTableView.frame;
    frameTableView.origin.y = frameLimit.origin.y + frameLimit.size.height;
    
    self.listTableView.frame = frameTableView;
    _limitTableView.backgroundColor = [UIColor whiteColor];
    [self.listTableView setContentInset:UIEdgeInsetsMake(heightInfo - frameLimit.size.height, 0, 0, 0)]; // Extra space
    
    // Init SWRevealView
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        UIImage *icon_menu  = [UIImage imageNamed:@"Icon menu e"];
        CGRect frameimg     = CGRectMake(15,5, 25,25);
        
        UIButton *menuButton = [[UIButton alloc] initWithFrame:frameimg];
        [menuButton setBackgroundImage:icon_menu forState:UIControlStateNormal];
        [menuButton addTarget:self.revealViewController action:@selector( revealToggle: )
             forControlEvents:UIControlEventTouchUpInside];
        [menuButton setShowsTouchWhenHighlighted:NO];
        
        UIBarButtonItem *buttonSidebar =[[UIBarButtonItem alloc] initWithCustomView:menuButton];
        
        self.navigationItem.leftBarButtonItem =buttonSidebar;
        revealViewController.rearViewRevealWidth = 280.0f;
        [buttonSidebar setTarget: self.revealViewController];
        [buttonSidebar setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)displayFavoritOrDiscount:(NSNotification*)notification
{
    if ([[IGClient sharedClient] getTypeList] == TYPE_NORMAL)
    {
        [self forOnlyOneType];
        [self populateArray:[self.myType objectForKey:@"name"]];
    }
    else
    {
        CGRect frameTable           = _listTableView.frame;
        CGRect infoFrame            = _limitTableView.frame;
        frameTable.origin.y        -= infoFrame.size.height;
        frameTable.size.height     += infoFrame.size.height;
        self.listTableView.frame    = frameTable;
    
        infoFrame.size.height       = 0;
        self.limitTableView.frame   = infoFrame;
        [self.listTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)]; // Extra space
    
        if ([[IGClient sharedClient] getTypeList] == TYPE_FAVORIT)
            [self populateArray:@"favorit"];
        if ([[IGClient sharedClient] getTypeList] == TYPE_DISCOUNT)
            [self populateArray:@"discount"];
    }
}

- (void)populateArray:(NSString*)type
{
    if ([type isEqualToString:@"favorit"])
    {
        self.placeArray = [[IGClient sharedClient] getFavoritEntity:YES];
        self.navigationItem.title = @"FAVORITS";
        _infoBar.hidden = YES;
    }
    else if ([type isEqualToString:@"discount"])
    {
        self.placeArray = [[IGClient sharedClient] getDiscountEntity];
        self.navigationItem.title = @"PROMOTION";
        _infoBar.hidden = YES;
    }
    else
    {
        self.placeArray = [[IGClient sharedClient] getEntity:type forKey:@"type"];
    }
    [self.listTableView reloadData];
}

#pragma mark ----------- CALCULATE SIZE OF UILABEL ------------
- (float)returnWidthForText:(NSString*)text
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:20]};
    CGSize stringSize = [text sizeWithAttributes:attributes];

    return stringSize.width;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger row = [self.placeArray count];
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"listCellIdentifier";
 
    IGListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
 
    if (cell == nil) {
        cell = [[IGListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
 
    // Add shadow
    cell.layer.masksToBounds    = NO;
    cell.layer.shadowOffset     = CGSizeMake(2, 2);
    cell.layer.shadowRadius     = 3;
    cell.layer.shadowOpacity    = 0.9;
    
    NSInteger row = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    
    // Set picture
    NSString *pictUrl = [NSString stringWithFormat:@"%@%@",URL_ITGRAFIX_VIGNETTE, [[self.placeArray objectAtIndex:row] objectForKey:@"vignette"]];

    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:pictUrl]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:30];
//    [cell.listCellImage setImageWithURL:[NSURL URLWithString:pictUrl]];
    
    [cell.listCellImage setImageWithURLRequest:imageRequest
                              placeholderImage:[UIImage imageNamed:@"place_holder_list.png"]
                                       success:nil
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                                          {
                                              NSLog(@"Unable to retrieve image");
                                          }];
/*
    [cell.listCellImage setImageWithURLRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:pictUrl]
                      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                  timeoutInterval:30.0]
                              placeholderImage:[UIImage imageNamed:@"logo-3.png"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            [cell.listCellImage setImage:image];
                                        } failure:nil];*/
    
    
    // Set Title
    cell.listCellTitle.text = [[self.placeArray objectAtIndex:row] objectForKey:@"name"];
    [cell.listCellTitle setFont:[cell.listCellTitle.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:19.f]]];
    
    // Set Rating
    if ([[self.placeArray objectAtIndex:row] objectForKey:@"rating"] != [NSNull null])
    {
        int nbrStar = [[[self.placeArray objectAtIndex:row] objectForKey:@"rating"] intValue];
        NSString *ratingName = [NSString stringWithFormat:@"rating%i.png",nbrStar];
        cell.listCellRatingImage.image = [UIImage imageNamed:ratingName];
    }
    // Set Option
    if ([[self.placeArray objectAtIndex:row] objectForKey:@"option"] != [NSNull null])
    {
        cell.listCellOption.hidden = NO;
        NSArray *color = [[self.myType objectForKey:@"option"] componentsSeparatedByString:@","];
        
        CGFloat r = [[color objectAtIndex:0] floatValue];
        CGFloat g = [[color objectAtIndex:1] floatValue];
        CGFloat b = [[color objectAtIndex:2] floatValue];
        [cell.listCellOptionView setColor:r green:g blue:b];
        
        cell.listCellOption.text = [[self.placeArray objectAtIndex:row] objectForKey:@"option"];
        [cell.listCellOption setFont:[cell.listCellOption.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
    }
    else
    {
        cell.listCellOption.hidden = YES;
    }
    
    // Set discount
    if (([[self.placeArray objectAtIndex:row] objectForKey:@"discount"] == [NSNull null]) ||
        ([[[self.placeArray objectAtIndex:row] objectForKey:@"discount"] isEqualToString:@""]))
    {
        cell.listCellDiscountView.hidden = YES;
    }
    else
    {
//        if (([[IGClient sharedClient] facebookName] != nil) &&
//            (![[[IGClient sharedClient] facebookName] isEqualToString:@""]))
//        {
            cell.listCellDiscountView.hidden = NO;
            CGFloat r = 255.f;
            CGFloat g = 70.f;
            CGFloat b = 15.f;
            [cell.listCellDiscountView setColor:r green:g blue:b];
            
            [cell.listCellDiscount setFont:[cell.listCellDiscount.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
            
            [cell.listCellDiscountView setNeedsDisplay];
/*        }
        else
        {
            cell.listCellDiscountView.hidden = YES;
        }*/
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"listToPlaceSegue" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = self.listTableView.contentOffset.y;
    
    CGRect mainFrame        = self.view.frame;
    CGFloat heightInfo      = mainFrame.size.height * 0.15f;
    
    int height = (int)heightInfo - 24;
    float value = height + offset;
    value = value / height;
    if (value > 1.f)
        value = 1.f;
    if (value < 0.f)
        value = 0.f;
    
    [_infoBar fadeInformation:value];
    
    NSLog(@"%f",value);
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"listToPlaceSegue"]) {
        IGPlaceViewController* tvc = [segue destinationViewController];
        tvc.myName = [[self.placeArray objectAtIndex:[self.listTableView indexPathForSelectedRow].row] objectForKey:@"name"];
    }
}


@end
