//
//  IGListTableViewController.h
//  samuiEating
//
//  Created by Mac on 20/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGInfosBar.h"

@interface IGListViewController : UIViewController

@property (nonatomic, strong)           NSDictionary *myType;

@property (nonatomic, weak) IBOutlet    UITableView *listTableView;
@property (nonatomic, weak) IBOutlet    IGInfosBar  *infoBar;

@end
