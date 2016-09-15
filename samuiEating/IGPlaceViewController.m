//
//  IGPlaceViewController.m
//  samuiEating
//
//  Created by Mac on 21/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGPlaceViewController.h"
#import "IGPlaceTableViewCell.h"
#import "IGMapViewController.h"
#import "IGWebViewController.h"
#import "IGModelPlace.h"
#import "IGSimilarView.h"
#import "IGFriendView.h"

#import "IGClient.h"
#import "UIImageView+AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import <MessageUI/MessageUI.h>

//#define INSET_VIEW      211
//#define PAGE_WIDTH      375


#define LABEL_HEIGHT    50.f
#define LABEL_CELL      0
#define TEXTVIEW_CELL   1
#define BUTTON_CELL     2
#define SIMILAR_CELL    3
#define BLANK_CELL      4
#define FRIEND_CELL     6

#define HIDE_VOUCHER    0
#define LOAD_VOUCHER    1
#define DISPLAY_VOUCHER 2

@interface IGPlaceViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate>
{
    NSString    *urlWeb;
    int         stateDiscount;
}

@property (nonatomic, weak) IBOutlet UIView         *containerScrollView;
@property (nonatomic, weak) IBOutlet UIPageControl  *placePicturePageControl;
@property (nonatomic, weak) IBOutlet UIScrollView   *placePictureScrollView;
@property (nonatomic, weak) IBOutlet UITableView    *placeTableView;
@property (nonatomic, strong) NSArray               *dataDict;
@property (nonatomic, strong) NSMutableArray        *elementInTable;
@property (nonatomic, strong) NSMutableArray        *friendList;
@property (nonatomic, strong) UIImage               *discountImgae;

@end

@implementation IGPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Set the elements of the view
    [self setElementWithPlaceName];
//    [self.placeTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setElementWithPlaceName
{
    NSLog(@"set elements");
    self.dataDict       = [[IGClient sharedClient] getEntity:self.myName forKey:@"name"];
    NSDictionary *dict  = [self.dataDict objectAtIndex:0];
    
    self.navigationItem.title       = [dict objectForKey:@"name"];
    NSString *pict                  = [dict objectForKey:@"picture"];
    NSArray *pictList               = [pict componentsSeparatedByString:@","];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect fr                       = self.view.bounds;
    CGRect frame                    = self.placePictureScrollView.bounds;
    frame.origin.x                  = 0;
    frame.size.width                = fr.size.width;
    frame.size.height               = fr.size.width / 1.5f;
    self.containerScrollView.frame  = frame;
    
    // Remove all view from scrollView
    NSArray *viewsToRemove = [self.containerScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    // Add pictures in scrollView
    for (NSString *img in pictList)
    {
        UIImageView *newPict = [[UIImageView alloc] initWithFrame:frame];
        NSString *pictUrl   = [NSString stringWithFormat:@"%@%@",URL_ITGRAFIX_VIGNETTE, img];
        [newPict setImageWithURL:[NSURL URLWithString:pictUrl]
                placeholderImage:[UIImage imageNamed:@"place_holder_place.png"]];
        frame.origin.x += frame.size.width;
        [self.containerScrollView addSubview:newPict];
    }
    self.containerScrollView.frame = CGRectMake(0, 0, frame.origin.x, frame.size.height);
//    self.placePictureScrollView.contentSize = CGSizeMake([pictList count] * frame.size.width, frame.size.height);
    self.placePictureScrollView.contentOffset = CGPointMake(0,0);
    [self.placePicturePageControl setNumberOfPages:[pictList count]];
    self.placePicturePageControl.currentPage = 0;

    // Add gesture recognizer
    UISwipeGestureRecognizer *leftRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    UISwipeGestureRecognizer *rightRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [self.placeTableView addGestureRecognizer:leftRecognizer];
    [self.placeTableView addGestureRecognizer:rightRecognizer];
    
    // Set inset tableView
    
//    self.placeTableView.estimatedRowHeight = 1000.0f;
//    self.placeTableView.rowHeight = UITableViewAutomaticDimension;
    CGFloat ratio = 375.f / 250.f;
    CGFloat insetFrame = fr.size.width / ratio;
//    [self.placeTableView setContentOffset:CGPointMake(0, -insetFrame) animated:YES];
//    CGRect insetFrame = _placePictureScrollView.frame;
    [self.placeTableView setContentInset:UIEdgeInsetsMake(insetFrame, 0, 0, 0)]; // Extra space
    
    // Fill Dictionnary with element
    // List of option
    CGFloat height = LABEL_HEIGHT;
    if (_elementInTable != nil)
        _elementInTable = nil;
    _elementInTable = [NSMutableArray new];
    
    // Distance
    if ([[IGClient sharedClient] isLocationEnable])
    {
        CLLocationCoordinate2D to;
        NSString *finalDist = nil;
        to.latitude         = [[dict objectForKey:@"latitude"] doubleValue];
        to.longitude        = [[dict objectForKey:@"longitude"] doubleValue];
        double distInMeter  = [[IGClient sharedClient] returnDistance:to];
        if (distInMeter < 1000.0)
            finalDist = [NSString stringWithFormat:@"      %.0f m", distInMeter];
        else
        {
            distInMeter /= 1000.0;
            finalDist = [NSString stringWithFormat:@"      %.2f km", distInMeter];
        }
        IGModelPlace *dist = [[IGModelPlace alloc] initWithValue:@"distance"
                                                           value:finalDist
                                                            type:LABEL_CELL
                                                          height:height * 0.6f];
   
        [_elementInTable addObject:dist];
    }
    
    // Friends list
    _friendList = [[IGClient sharedClient] returnFriendForPlace:[dict objectForKey:@"facebook"]];
    if ((_friendList != nil) && ([_friendList count] > 0))
    {
        CGFloat height = (self.view.frame.size.width / 15.f) * 4.f;
        NSString *headerTitle = nil;
        if ([_friendList count] > 1)
        {
            headerTitle = [NSString stringWithFormat:@"%i of your friends was at this place", (int)[_friendList count]];
        }
        else
        {
            headerTitle = @"1 of your friends was at this place";
        }
            
        IGModelPlace *sim = [[IGModelPlace alloc] initWithValue:headerTitle
                                                          value:@""
                                                           type:FRIEND_CELL
                                                         height:height];
        
        [_elementInTable addObject:sim];
    }
    // Comment
    NSString *comment = [dict objectForKey:@"comment"];
    if (comment != nil)
    {
        if (![comment isEqualToString:@""])
        {
            height = [self textViewHeight:comment];
            NSString *convertString = [comment stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            IGModelPlace *comm = [[IGModelPlace alloc] initWithValue:@"About"
                                                               value:convertString
                                                                type:TEXTVIEW_CELL
                                                              height:height + (LABEL_HEIGHT / 1.0)];
    
            [_elementInTable addObject:comm];
        }
    }
    
    CGFloat heightButton = LABEL_HEIGHT * 1.2f;
    if (IPAD)
        heightButton = LABEL_HEIGHT * 2.2f;
    
    // promotion
    NSString *promotion  = [dict objectForKey:@"discount"];
//    NSArray *facebook = [[dict objectForKey:@"facebook"] componentsSeparatedByString:@"/"];
//    NSString *facebookID = [facebook objectAtIndex:[facebook count]-1];
    if ((promotion != nil) && (![promotion isEqualToString:@""]))
    {
/*        if (([[IGClient sharedClient] facebookName] != nil) &&
            (![[[IGClient sharedClient] facebookName] isEqualToString:@""]) &&
            ([[IGClient sharedClient] checkLikeUser:facebookID]))
        {*/
            IGModelPlace *prom = [[IGModelPlace alloc] initWithValue:@"Promotion"
                                                               value:promotion
                                                               type:BUTTON_CELL
                                                             height:LABEL_HEIGHT * 1.5];
            
            [_elementInTable addObject:prom];
//        }
    }
    // Adress
    NSString *address = [dict objectForKey:@"address"];
    if (address != nil)
    {
        if (![address isEqualToString:@""])
        {
            height = [self textViewHeight:address];
            NSString *convertString = [address stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            IGModelPlace *add = [[IGModelPlace alloc] initWithValue:@"Address"
                                                              value:convertString
                                                               type:TEXTVIEW_CELL
                                                             height:height + (LABEL_HEIGHT / 1)];
    
            [_elementInTable addObject:add];
        }
    }
    // Average
    NSString *average = [dict objectForKey:@"average"];
    if (average != nil)
    {
        if (![average isEqualToString:@""])
        {
            height = [self textViewHeight:average];
            NSString *convertString = [average stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            IGModelPlace *avg = [[IGModelPlace alloc] initWithValue:@"Average cost per person"
                                                              value:convertString
                                                               type:TEXTVIEW_CELL
                                                             height:height + (LABEL_HEIGHT / 1)];
            
            [_elementInTable addObject:avg];
        }
    }
    // Credit card
    NSString *credit = [dict objectForKey:@"credit_card"];
    if (credit != nil)
    {
        if (![credit isEqualToString:@""])
        {
            height = [self textViewHeight:credit];
            NSString *convertString = [credit stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            IGModelPlace *crd = [[IGModelPlace alloc] initWithValue:@"Credit Card"
                                                              value:convertString
                                                               type:TEXTVIEW_CELL
                                                             height:height + (LABEL_HEIGHT / 1)];
            
            [_elementInTable addObject:crd];
        }
    }
    // Service & Tax
    NSString *service = [dict objectForKey:@"service_tax"];
    if (service != nil)
    {
        if (![service isEqualToString:@""])
        {
            height = [self textViewHeight:service];
            NSString *convertString = [service stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            IGModelPlace *srv = [[IGModelPlace alloc] initWithValue:@"Service & Tax"
                                                              value:convertString
                                                               type:TEXTVIEW_CELL
                                                             height:height + (LABEL_HEIGHT / 1)];
            
            [_elementInTable addObject:srv];
        }
    }
    // Opening Time
    NSString *opening = [dict objectForKey:@"opening"];
    if (opening != nil)
    {
        if (![opening isEqualToString:@""])
        {
            height = [self textViewHeight:opening];
            NSString *convertString = [opening stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            IGModelPlace *opn = [[IGModelPlace alloc] initWithValue:@"Opening time"
                                                              value:convertString
                                                               type:TEXTVIEW_CELL
                                                             height:height + (LABEL_HEIGHT / 1)];
            
            [_elementInTable addObject:opn];
        }
    }
    
    /* MEDIAS PHONE,MAIL,WEBSITE */
    // Phone
    NSString *phone = [dict objectForKey:@"phone"];
    if (IPAD)
    {
        
    }
    else
    {
        if (phone != nil)
        {
            if (![phone isEqualToString:@""])
            {
                IGModelPlace *pho = [[IGModelPlace alloc] initWithValue:@"Phone"
                                                                value:phone
                                                                type:BUTTON_CELL
                                                                height:LABEL_HEIGHT * 1.2];
        
                [_elementInTable addObject:pho];
            }
        }
    }
    // email
    NSString *email = [dict objectForKey:@"email"];
    if (email != nil)
    {
        if (![email isEqualToString:@""])
        {
            IGModelPlace *mail = [[IGModelPlace alloc] initWithValue:@"Mail"
                                                               value:email
                                                                type:BUTTON_CELL
                                                              height:heightButton];
        
            [_elementInTable addObject:mail];
        }
    }
    // website
    NSString *website = [dict objectForKey:@"website"];
    if (website != nil)
    {
        if (![website isEqualToString:@""])
        {
            IGModelPlace *web = [[IGModelPlace alloc] initWithValue:@"Website"
                                                               value:website
                                                                type:BUTTON_CELL
                                                              height:heightButton];
            
            [_elementInTable addObject:web];
        }
    }
    
    // ADD TO FAVORIT
    BOOL fav = [[dict objectForKey:@"favorit"] boolValue];
    if (!fav)
    {
        IGModelPlace *fav = [[IGModelPlace alloc] initWithValue:@"Add to wish list"
                                                           value:@"Add to wish list"
                                                            type:BUTTON_CELL
                                                         height:heightButton];
        
        [_elementInTable addObject:fav];
    }
    
    // SIMILAR
    NSArray *similar = [[dict objectForKey:@"similar"] componentsSeparatedByString:@","];
    if ([similar count] > 0)
    {
        if (![[similar objectAtIndex:0] isEqualToString:@""])
        {
            CGFloat height = (self.view.frame.size.width / 15.f) * 4.f;
/*            if ([similar count] == 1)
                 height = (self.view.frame.size.width / 15.f) * 4.f;
            else
                height = ((self.view.frame.size.width * 0.9f) / 15.f) * 4.f;*/
            IGModelPlace *sim = [[IGModelPlace alloc] initWithValue:@"Similar"
                                                              value:@""
                                                               type:SIMILAR_CELL
                                                             height:height];
        
            [_elementInTable addObject:sim];
        }
    }
    
    // ADD BLANK SPACE AT THE END
    IGModelPlace *sim = [[IGModelPlace alloc] initWithValue:@"Blank"
                                                      value:@""
                                                       type:BLANK_CELL
                                                     height:(LABEL_HEIGHT / 2)];
    
    [_elementInTable addObject:sim];
    
    stateDiscount = HIDE_VOUCHER;
    NSLog(@"finish set elements");
    
/*    FBSDKLikeControl *likeButton = [[FBSDKLikeControl alloc] init];
    likeButton.objectID = [dict objectForKey:@"facebook"];;
    likeButton.center = self.view.center;
    [self.view addSubview:likeButton];
    [likeButton addTarget:self action:@selector(FBLikeButtonClicked:) forControlEvents:UIControlEventValueChanged];*/
}

- (void)removeFavoritCell
{
    for(IGModelPlace *item in _elementInTable)
    {
        if([[item placeTitle] isEqual:@"Add to wich list"])
        {
            [_elementInTable removeObject:item];
            break;
        }
    }
}

- (CGFloat)textViewHeight:(NSString*)string
{
    CGRect frameView = self.view.frame;
    frameView.size.width *= 0.92;
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(15,0,frameView.size.width,200)];
    CGFloat fixedWidth = tv.frame.size.width;
    
    NSString *convertString = [string stringByReplacingOccurrencesOfString: @"\\n" withString: @"\n"];
    [tv setText:convertString];
    
    [tv setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:[[IGClient sharedClient] setFontByDeviceType:14.f]]];
    CGSize newSize = [tv sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = tv.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height + 0);
    return newFrame.size.height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_elementInTable count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0.f;
    NSInteger row = indexPath.row;
    height = [[[_elementInTable objectAtIndex:row] placeHeight] floatValue];
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"placeCellIdentifier";
    
    IGPlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[IGPlaceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
   
    cell.backgroundColor            = [UIColor whiteColor];
    NSInteger row                   = indexPath.row;
    
    int type = [[[_elementInTable objectAtIndex:row] placeType] intValue];
    if (type == LABEL_CELL)
    {
        cell.placeCellButton.hidden                 = YES;
        cell.placeDiscountImageView.hidden          = YES;
        cell.placeCellHeaderLabel.hidden            = NO;
        cell.placeIconImageView.hidden              = NO;
        cell.placeCellDescriptionTextView.hidden    = YES;
        cell.placeSimilarScrollView.hidden          = YES;
        cell.placeSeparatorView.hidden              = YES;
        
        cell.backgroundColor            = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];

        cell.placeCellHeaderLabel.textColor = [UIColor blackColor];
        cell.placeCellHeaderLabel.text  = [[_elementInTable objectAtIndex:row] placeValue];
        [cell.placeCellHeaderLabel setFont:[cell.placeCellHeaderLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
        
//        CGRect frameCell = cell.frame;
        CGRect frameHeader = cell.placeCellHeaderLabel.frame;
        CGFloat frameHeight = LABEL_CELL * 0.6;
        frameHeader.size.height = frameHeight;
        cell.placeCellHeaderLabel.frame = frameHeader;
    }
    if (type == FRIEND_CELL)
    {
        cell.placeCellButton.hidden                 = YES;
        cell.placeCellHeaderLabel.hidden            = NO;
        cell.placeIconImageView.hidden              = YES;
        cell.placeCellDescriptionTextView.hidden    = YES;
        cell.placeSeparatorView.hidden              = YES;
        cell.placeDiscountImageView.hidden          = YES;
        cell.placeSimilarScrollView.hidden          = NO;

        for (UIView *view in cell.placeSimilarContentView.subviews)
        {
            if ([view isKindOfClass:[IGSimilarView class]])
            [view removeFromSuperview];
        }
        
        cell.placeCellHeaderLabel.text  = [[_elementInTable objectAtIndex:row] placeTitle];
        [cell.placeCellHeaderLabel setFont:[cell.placeCellHeaderLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
        
        cell.placeCellHeaderLabel.textColor = [UIColor colorWithRed:10.f / 255.f green:101.f / 255.f blue:1.f alpha:1.f];
        
        CGRect frame = cell.placeSimilarScrollView.frame;
        frame.size.height = [[[_elementInTable objectAtIndex:row] placeHeight] floatValue];
        cell.placeSimilarScrollView.frame = frame;
        
        cell.placeSimilarContentView.backgroundColor = [UIColor clearColor];
        
        CGFloat width = 0;//frame.size.width;
        width = self.view.frame.size.width;
        
        frame.size.width = width;
        for (int nbFriend = 0;nbFriend < [_friendList count];nbFriend ++)
        {
            NSString *name = [[_friendList objectAtIndex:nbFriend] friendName];
            NSString *pict = [[_friendList objectAtIndex:nbFriend] friendID];
            NSString *date = [[_friendList objectAtIndex:nbFriend] friendDate];
            IGFriendView *friend = [[IGFriendView alloc] initWithFrame:frame];
            [friend setParameters:pict name:name date:date];
            
            [cell.placeSimilarContentView addSubview:friend];
            frame.origin.x += width;
        }
        frame.size.height = [[[_elementInTable objectAtIndex:row] placeHeight] floatValue];
        cell.placeSimilarContentView.frame = CGRectMake(0,0,width * [_friendList count], frame.size.height);
        CGRect viewFrame = cell.frame;
        
        cell.placeSimilarScrollView.contentSize = CGSizeMake(viewFrame.size.width * [_friendList count], frame.size.height);
        
        cell.placeSimilarScrollView.pagingEnabled = YES;
        cell.placeSimilarScrollView.scrollEnabled = YES;
        cell.placeSimilarScrollView.contentOffset = CGPointMake(0,0);
        
        cell.placeSimilarScrollView.tag = 0;
        
        UISwipeGestureRecognizer *leftRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSimilarSwipeLeft:)];
        [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        UISwipeGestureRecognizer *rightRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSimilarSwipeRight:)];
        [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        
        [cell.placeSimilarScrollView addGestureRecognizer:leftRecognizer];
        [cell.placeSimilarScrollView addGestureRecognizer:rightRecognizer];
        
    }
    if (type == TEXTVIEW_CELL)
    {
        cell.placeCellButton.hidden                 = YES;
        cell.placeDiscountImageView.hidden          = YES;
        cell.placeCellHeaderLabel.hidden            = NO;
        cell.placeIconImageView.hidden              = YES;
        cell.placeCellDescriptionTextView.hidden    = NO;
        cell.placeSimilarScrollView.hidden          = YES;
        
        if (row > 0)
        {
            if ([[[_elementInTable objectAtIndex:row - 1] placeType] intValue] == TEXTVIEW_CELL)
                cell.placeSeparatorView.hidden = NO;
            else
                cell.placeSeparatorView.hidden = YES;
        }
        else
            cell.placeSeparatorView.hidden = YES;
        
        cell.placeCellHeaderLabel.text  = [[_elementInTable objectAtIndex:row] placeTitle];
        [cell.placeCellHeaderLabel setFont:[cell.placeCellHeaderLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
        
        cell.placeCellHeaderLabel.textColor = [UIColor colorWithRed:10.f / 255.f green:101.f / 255.f blue:1.f alpha:1.f];
        cell.placeCellDescriptionTextView.text = [[_elementInTable objectAtIndex:row] placeValue];
        [cell.placeCellDescriptionTextView setFont:[cell.placeCellDescriptionTextView.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:14.f]]];
    }
    if (type == BUTTON_CELL)
    {
        cell.placeCellButton.hidden                 = NO;
        
        cell.placeCellHeaderLabel.hidden            = YES;
        cell.placeIconImageView.hidden              = YES;
        cell.placeCellDescriptionTextView.hidden    = YES;
        cell.placeDiscountImageView.hidden          = YES;
        cell.placeSimilarScrollView.hidden          = YES;
        cell.placeSeparatorView.hidden              = YES;

        cell.placeCellButton.layer.cornerRadius     = 10.f;
        cell.placeCellButton.layer.borderWidth      = 1.f;
        if ([[[_elementInTable objectAtIndex:row] placeTitle] isEqualToString:@"Promotion"])
        {
            if (stateDiscount == HIDE_VOUCHER)
            {
                [cell.placeCellButton setTitle:@"Promotion Click Here" forState:UIControlStateNormal];
                [cell.placeCellButton.titleLabel setFont:[cell.placeCellButton.titleLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
                [cell.placeCellButton setTitleColor:[UIColor whiteColor]
                                                            forState:UIControlStateNormal];
                cell.placeCellButton.layer.borderColor = [UIColor colorWithRed:247.f / 255.f
                                                                         green:33.f / 255.f
                                                                            blue:25.f / 255.f
                                                                         alpha:1.f].CGColor;
                cell.placeCellButton.layer.backgroundColor = [UIColor colorWithRed:247.f / 255.f
                                                                         green:33.f / 255.f
                                                                          blue:25.f / 255.f
                                                                         alpha:1.f].CGColor;
            }
            if (stateDiscount == LOAD_VOUCHER)
            {
                cell.placeCellButton.hidden                 = YES;
                cell.placeDiscountImageView.hidden          = NO;
                
                NSString *urlPromotion = [NSString stringWithFormat:@"%@", [[_elementInTable objectAtIndex:row] placeValue]];
//                NSString *urlPromotion = @"http://cdn2.greatdeals.com.sg/wp-content/uploads/2009/01/tony_roma-jan-voucher-300x189.jpg";
                
                NSLog(@"%@",urlPromotion);
                NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPromotion] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
                
                [cell.placeDiscountImageView setImageWithURLRequest:urlRequest placeholderImage:[UIImage imageNamed:@"icon"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    
                    _discountImgae = image;
                    NSNumber *imageHeight = [[NSNumber alloc] initWithFloat:image.size.height];
                    NSNumber *imageWidth = [[NSNumber alloc] initWithFloat:image.size.width];
                    
                    CGRect frameCell = cell.frame;
                    float ratio = [imageWidth floatValue] / [imageHeight floatValue];
                    frameCell.size.height = frameCell.size.width / ratio;

                    IGModelPlace *prom = [[IGModelPlace alloc] initWithValue:@"Promotion"
                                                                       value:@""
                                                                        type:BUTTON_CELL
                                                                      height:frameCell.size.height];
                    
                    [_elementInTable replaceObjectAtIndex:row withObject:prom];
                    stateDiscount = DISPLAY_VOUCHER;
                    [_placeTableView reloadData];
                    
                    NSLog(@"ok");
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"failed");
                    stateDiscount = HIDE_VOUCHER;
                    [_placeTableView reloadData];
                }];
            }
            if (stateDiscount == DISPLAY_VOUCHER)
            {
                cell.placeCellButton.hidden                 = YES;
                cell.placeDiscountImageView.hidden          = NO;
                
                cell.placeDiscountImageView.image = _discountImgae;
            }
        }
        else
        {
            if (IPAD)
            {
                CGRect frameButton = cell.placeCellButton.frame;
                frameButton.size.height *= 2;
                cell.placeCellButton.frame = frameButton;
            }
            [cell.placeCellButton setTitle:[[_elementInTable objectAtIndex:row] placeTitle] forState:UIControlStateNormal];
            [cell.placeCellButton.titleLabel setFont:[cell.placeCellButton.titleLabel.font fontWithSize:[[IGClient sharedClient] setFontByDeviceType:15.f]]];
            [cell.placeCellButton setTitleColor:[UIColor colorWithRed:10.f / 255.f
                                                                green:101.f / 255.f
                                                                 blue:255.f / 255.f
                                                                alpha:1.f]
                                       forState:UIControlStateNormal];
            cell.placeCellButton.layer.borderColor      = [UIColor colorWithRed:10.f / 255.f
                                                                          green:101.f / 255.f
                                                                           blue:255.f / 255.f
                                                                          alpha:1.f].CGColor;
            cell.placeCellButton.layer.backgroundColor      = [UIColor colorWithRed:1.f
                                                                              green:1.f
                                                                               blue:1.f                                                               
                                                                              alpha:1.f].CGColor;
            
            [cell setNeedsDisplay];
            [cell setNeedsLayout];
        }
        
        cell.placeCellButton.tag = row;
        [cell.placeCellButton addTarget:self
                                 action:@selector(buttonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    if (type == SIMILAR_CELL)
    {
        cell.placeCellButton.hidden                 = YES;
        cell.placeCellHeaderLabel.hidden            = YES;
        cell.placeIconImageView.hidden              = YES;
        cell.placeCellDescriptionTextView.hidden    = YES;
        cell.placeSeparatorView.hidden              = YES;
        cell.placeDiscountImageView.hidden          = YES;
        cell.placeSimilarScrollView.hidden          = NO;

//        cell.placeSimilarScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *dict  = [self.dataDict objectAtIndex:0];
        NSArray *similar = [[dict objectForKey:@"similar"] componentsSeparatedByString:@","];
        
//        NSArray *similar = @[ @"Jahn Restaurant at Conrad Koh Samui",
//                                @"Saffron Restaurant at Banyan Tree Koh Samui",
//                                @"Drink Gallery"];
        CGRect frame = cell.placeSimilarScrollView.frame;
        frame.size.height = [[[_elementInTable objectAtIndex:row] placeHeight] floatValue];
        cell.placeSimilarScrollView.frame = frame;
        
        CGFloat width = 0;//frame.size.width;
        if ([similar count] == 1)
            width = self.view.frame.size.width;
        else
            width = self.view.frame.size.width * 0.9f;
            
        frame.size.width = width;
        for (int nbSimilar = 0;nbSimilar < [similar count];nbSimilar ++)
        {
            NSArray *data  = [[IGClient sharedClient] getEntity:[similar objectAtIndex:nbSimilar] forKey:@"name"];
            NSDictionary *similarDict  = [data objectAtIndex:0];
            NSString *title = [similar objectAtIndex:nbSimilar];
            NSString *pict = [similarDict objectForKey:@"vignette"];
            NSNumber *star = [NSNumber numberWithInt:[[similarDict objectForKey:@"rating"] intValue]];
            IGSimilarView *sim = [[IGSimilarView alloc] initWithFrame:frame];
            [sim setParameters:pict title:title star:star];
            
            [cell.placeSimilarContentView addSubview:sim];
            frame.origin.x += width;
        }
        frame.size.height = [[[_elementInTable objectAtIndex:row] placeHeight] floatValue];
        cell.placeSimilarContentView.frame = CGRectMake(0,0,width * [similar count], frame.size.height);
        CGRect viewFrame = cell.frame;

        cell.placeSimilarScrollView.contentSize = CGSizeMake(viewFrame.size.width * [similar count], frame.size.height);
        
        cell.placeSimilarScrollView.pagingEnabled = NO;
        cell.placeSimilarScrollView.scrollEnabled = NO;
        cell.placeSimilarScrollView.contentOffset = CGPointMake(0,0);

        cell.placeSimilarScrollView.tag = 1;
        
        if ([similar count] > 1)
            cell.placeSimilarScrollView.delegate = self;
        else
            cell.placeSimilarScrollView.delegate = nil;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapSimilarScrollView:)];
        UISwipeGestureRecognizer *leftRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSimilarSwipeLeft:)];
        [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        UISwipeGestureRecognizer *rightRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSimilarSwipeRight:)];
        [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        
        [cell.placeSimilarScrollView addGestureRecognizer:leftRecognizer];
        [cell.placeSimilarScrollView addGestureRecognizer:rightRecognizer];
        [cell.placeSimilarScrollView addGestureRecognizer:singleTap];
    }
    if (type == BLANK_CELL)
    {
        cell.placeCellButton.hidden                 = YES;
        cell.placeCellHeaderLabel.hidden            = YES;
        cell.placeIconImageView.hidden              = YES;
        cell.placeCellDescriptionTextView.hidden    = YES;
        cell.placeSimilarScrollView.hidden          = YES;
        cell.placeDiscountImageView.hidden          = YES;
        cell.placeSeparatorView.hidden              = YES;
    }
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)singleTapSimilarScrollView:(UITapGestureRecognizer *)sender
{
    UIScrollView *tapped    = (UIScrollView*)sender.view;
    CGFloat offset          = tapped.contentOffset.x;
    CGRect frame            = tapped.frame;
    
    NSDictionary *dict      = [self.dataDict objectAtIndex:0];
    NSArray *similar        = [[dict objectForKey:@"similar"] componentsSeparatedByString:@","];
    
    int widthView = 0;
    if ([similar count] == 1)
        widthView = frame.size.width;
    else
        widthView = (int)(frame.size.width * 0.9f);
   
    int placeSelected       = offset / widthView;
    self.myName = nil;
    self.myName = [similar objectAtIndex:placeSelected];
    
    [self setElementWithPlaceName];
    
    [self.placeTableView reloadData];
    
    CGRect fr                       = self.view.bounds;
    CGFloat ratio = 375.f / 250.f;
    CGFloat insetFrame = fr.size.width / ratio;
    [self.placeTableView setContentOffset:CGPointMake(0, -insetFrame) animated:YES];
    
    NSLog(@"%@",[similar objectAtIndex:placeSelected]);
}

- (void)handleSimilarSwipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"swap left");
    
    NSInteger tag = [(UISwipeGestureRecognizer*)recognizer view].tag;
    
    if (tag == 0)   // Friends list
    {
        UIScrollView *swiped    = (UIScrollView*)recognizer.view;
        CGFloat offset          = swiped.contentOffset.x;
        CGRect frame            = swiped.frame;
        
        int widthView = frame.size.width;
        
        int placeSelected       = offset / widthView;
        if (placeSelected < [_friendList count]-1)
            [swiped setContentOffset:CGPointMake((placeSelected + 1) * widthView, 0) animated:YES];
    }
    if (tag == 1)   // Similar place
    {
        UIScrollView *swiped    = (UIScrollView*)recognizer.view;
        CGFloat offset          = swiped.contentOffset.x;
        CGRect frame            = swiped.frame;

        NSDictionary *dict      = [self.dataDict objectAtIndex:0];
        NSArray *similar        = [[dict objectForKey:@"similar"] componentsSeparatedByString:@","];
        
        int widthView = 0;
        if ([similar count] == 1)
            widthView = frame.size.width;
        else
            widthView = (int)(frame.size.width * 0.9f);
        
        int placeSelected       = offset / widthView;
        if (placeSelected < [similar count]-1)
            [swiped setContentOffset:CGPointMake((placeSelected + 1) * widthView, 0) animated:YES];
    }
}

- (void)handleSimilarSwipeRight:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"swap right");
    UIScrollView *swiped    = (UIScrollView*)recognizer.view;
    CGFloat offset          = swiped.contentOffset.x;
    CGRect frame            = swiped.frame;
    
    NSInteger tag = [(UISwipeGestureRecognizer*)recognizer view].tag;
    
    if (tag == 0)
    {
        int widthView = frame.size.width;
       
        int placeSelected       = offset / widthView;
        if (placeSelected > 0)
            [swiped setContentOffset:CGPointMake((placeSelected - 1) * widthView, 0) animated:YES];
    }
    if (tag == 1)
    {
        NSDictionary *dict      = [self.dataDict objectAtIndex:0];
        NSArray *similar        = [[dict objectForKey:@"similar"] componentsSeparatedByString:@","];
        
        int widthView = 0.f;
        if ([similar count] == 1)
            widthView = frame.size.width;
        else
            widthView = (int)(frame.size.width * 0.9f);
        
        int placeSelected       = offset / widthView;
        if (placeSelected > 0)
            [swiped setContentOffset:CGPointMake((placeSelected - 1) * widthView, 0) animated:YES];
    }
}


#pragma mark ---------- BUTTON ACTION ----------
- (void)FBLikeButtonClicked:(id)sender
{
    
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint swipeLocation = [recognizer locationInView:self.placeTableView];
    if (swipeLocation.y < 0)
    {
        CGPoint offset          = self.placePictureScrollView.contentOffset;
        NSInteger nbrPict       = self.placePicturePageControl.numberOfPages;
        NSInteger currentPict   = self.placePicturePageControl.currentPage;
        CGFloat pageWidth       = self.placePictureScrollView.frame.size.width;
        
        if (currentPict + 1 < nbrPict)
        {
            [self.placePictureScrollView setContentOffset:CGPointMake(offset.x + pageWidth, offset.y) animated:YES];
            self.placePicturePageControl.currentPage ++;
        }
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint swipeLocation = [recognizer locationInView:self.placeTableView];
    if (swipeLocation.y < 0)
    {
        CGPoint offset          = self.placePictureScrollView.contentOffset;
        NSInteger currentPict   = self.placePicturePageControl.currentPage;
        CGFloat pageWidth       = _containerScrollView.frame.size.width;
        
        if (currentPict > 0)
        {
            [self.placePictureScrollView setContentOffset:CGPointMake(offset.x - pageWidth, offset.y) animated:YES];
            self.placePicturePageControl.currentPage --;
        }
    }
}

/* OPEN MAP */
- (IBAction)openMap:(id)sender
{
    if ([[IGClient sharedClient] internetConnection])
        [self performSegueWithIdentifier:@"placeToMapSegue" sender:self];
    else
    {
        UIAlertController *alert =   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:STR_NO_INTERNET
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
}

/* DETECT BUTTON CLICKED IN TABLEVIEW */
- (void)buttonClicked:(UIButton*)sender
{
    NSInteger button = sender.tag;
    
    NSString *type = [[_elementInTable objectAtIndex:button] placeTitle];
    if ([type isEqualToString:@"Mail"])
        [self sendMail:(int)button];
    
    if ([type isEqualToString:@"Add to wish list"])
    {
        [self addFavorit:(int)button];
        [self removeFavoritCell];
        [_placeTableView reloadData];
    }
    
    if ([type isEqualToString:@"Phone"])
    {
       [self callPhone:(int)button];
    }
    if ([type isEqualToString:@"Website"])
        [self openWeb:(int)button];
    
    if ([type isEqualToString:@"Promotion"])
        [self displayPromotion:(int)button];
}

/* CALL PHONE NUMBER */
- (void)callPhone:(int)place
{
    NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",
                             [[_elementInTable objectAtIndex:place] placeValue]];
    if (![phoneNumber	isEqualToString:@"tel:"])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

/* SEND MAIL */
- (void)sendMail:(int)place
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
            
        [mailer setSubject:@"From Eating Samui application"];
            
        NSArray *toRecipients = [NSArray arrayWithObjects:[[_elementInTable objectAtIndex:place] placeValue], nil];
        [mailer setToRecipients:toRecipients];
            
        NSString *emailBody = @"Dear,";
        [mailer setMessageBody:emailBody isHTML:NO];
            
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alert =   [UIAlertController
                                      alertControllerWithTitle:@"Failure"
                                      message:@"Your device doesn't support the composer sheet"
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
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"ficheViewController : Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"ficheViewController : Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"ficheViewController : Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"ficheViewController : Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"ficheViewController : Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:NO completion:nil];
}

/* OPEN WEBSITE */
- (void)openWeb:(int)place
{
    if ([[IGClient sharedClient] internetConnection])
    {
        urlWeb = [[_elementInTable objectAtIndex:place] placeValue];
        [self performSegueWithIdentifier:@"placeToWebSegue" sender:self];
    }
    else
    {
        UIAlertController *alert =   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:STR_NO_INTERNET
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
}

/* ADD TO WICH LIST */
- (void)addFavorit:(int)place
{
    NSDictionary *dict  = [self.dataDict objectAtIndex:0];
    
    int id_place = [[dict objectForKey:@"id"] intValue];
    [[IGClient sharedClient] setEntityForFavorit:id_place];
}

/* DISPLAY PROMOTION */
- (void)displayPromotion:(int)place
{
//    NSString *urlPromotion = [[_elementInTable objectAtIndex:place] placeValue];
    stateDiscount = LOAD_VOUCHER;
    [_placeTableView reloadData];
}


#pragma mark ---------- SCROLLVIEW DELEGATE / ANIMATION ----------
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
/*    if (([scrollView isKindOfClass:[UIScrollView class]]) &&
        (scrollView != self.placeTableView))
    {
        CGPoint point       = scrollView.contentOffset;
        CGRect frameView    = self.view.frame;
        CGFloat width       = frameView.size.width * 0.9f;
        
        int nextPage = point.x / width;
        float posInNextPage = (int)(point.x - (width * nextPage)) % (int)width;
        if (posInNextPage > width / 2.f)
        {
            CGRect newRect = CGRectMake((nextPage+1) * width, 0, frameView.size.width,frameView.size.height);
            [scrollView scrollRectToVisible:newRect animated:YES];
        }
        else
        {
            CGRect newRect = CGRectMake(nextPage * width, 0, frameView.size.width,frameView.size.height);
            [scrollView scrollRectToVisible:newRect animated:YES];
        }
        NSLog(@"scrolling:%i",nextPage);
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (([scrollView isKindOfClass:[UIScrollView class]]) &&
        (scrollView != self.placeTableView))
    {
        CGPoint point       = scrollView.contentOffset;
        CGRect frameView    = self.view.frame;
        CGFloat width       = frameView.size.width * 0.9f;
        
        int nextPage = point.x / width;
        float posInNextPage = (int)(point.x - (width * nextPage)) % (int)width;
        if (posInNextPage > width / 2.f)
        {
            CGRect newRect = CGRectMake((nextPage+1) * width, 0, frameView.size.width,frameView.size.height);
            [scrollView scrollRectToVisible:newRect animated:YES];
        }
        else
        {
            CGRect newRect = CGRectMake(nextPage * width, 0, frameView.size.width,frameView.size.height);
            [scrollView scrollRectToVisible:newRect animated:YES];
        }
        NSLog(@"draggin:%i",nextPage);
        
    }*/
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeToMapSegue"]) {
        IGMapViewController* tvc = [segue destinationViewController];
        tvc.dataDict = self.dataDict;
    }
    if ([[segue identifier] isEqualToString:@"placeToWebSegue"]) {
        IGWebViewController* tvc = [segue destinationViewController];
        tvc.myUrl = urlWeb;
    }
}


@end
