//
//  IGWebViewController.m
//  samuiEating
//
//  Created by Mac on 25/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGWebViewController.h"

@interface IGWebViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation IGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:self.myUrl];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
