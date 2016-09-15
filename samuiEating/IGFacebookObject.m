//
//  IGFacebookManager.m
//  samuiEating
//
//  Created by Mac on 22/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGFacebookObject.h"

#import "IGClient.h"

@implementation IGFacebookObject

- (id)initWithViewController:(id)controller
{
    self = [super init];
    if (self) {
        _viewController = controller;
    }
    return self;
}

#pragma mark ---------- FACEBOOK LOGIN ----------
- (void)facebookLogin
{
    if ([[IGClient sharedClient] internetConnection])
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.loginBehavior = FBSDKLoginBehaviorWeb;
        [login logInWithReadPermissions:@[@"public_profile", @"user_friends", @"user_tagged_places"] fromViewController:self.viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error)
            {
                // Process error
                [_delegate facebookError:self error:[NSString stringWithFormat:@"%@", error]];
            }
            else if (result.isCancelled)
            {
                // Handle cancellations
                [_delegate facebookDisconnected:self];
            }
            else
            {
                if ([result.grantedPermissions containsObject:@"public_profile"])
                {
                    NSLog(@"result is:%@",result);
                    [self getFacebookData];
                }
                else
                {
                    [_delegate facebookError:self error:@"friends list was not send"];
                }
            }
        }];
    }
    else
    {
        NSLog(@"No internet!");
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:STR_NO_INTERNET
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Close"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        [_delegate facebookError:self error:@"No internet"];                                        
                                    }];
        
        
        [alert addAction:yesButton];
        [self.viewController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark ---------- FACEBOOK LOGOUT ----------
- (void)facebookLogout
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    
    [_delegate facebookDisconnected:self];
}

#pragma mark ---------- FACEBOOK TEST ----------
- (BOOL)getFacebookData
{
    __block BOOL connectedToFacebook = YES;
    /* PART TO REMOVE FOR FACEBOOK CONNEXION */
    // We fake connexion
//    [_delegate facebookConnected:self];
    
    /* PART TO ENABLE FOR FACEBOOK CONNECTION */
    if ([FBSDKAccessToken currentAccessToken])
    {
        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setValue:FACEBOOK_REQUEST forKey:@"fields"];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 connectedToFacebook = YES;
                 [[IGClient sharedClient] postFacebookInfoUser:result];
                 NSString *myFacebookID = [result objectForKey:@"id"];
                 [self facebookFriendsUser:myFacebookID];
                 
                 // Delegate open
                 [_delegate facebookConnected:self];
             }
             else
             {
                 connectedToFacebook = NO;
                 [_delegate facebookError:self error:[NSString stringWithFormat:@"%@",error.description]];
             }
         }];
    }
    else
    {
        connectedToFacebook = NO;
        [_delegate facebookDisconnected:self];
    }
    return connectedToFacebook;
}

#pragma mark ---------- FACEBOOK LIKE --------------
- (void)facebookFriendsUser:(NSString*)facebookID
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"])
    {
       
        NSString *graphPath = [NSString stringWithFormat:@"%@/friends",facebookID];
        FBSDKGraphRequest *requestLikes = [[FBSDKGraphRequest alloc]
                                           initWithGraphPath:graphPath
                                           parameters:nil];
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
        
        [connection addRequest:requestLikes
             completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 //TODO: process like information
                 if (error == nil)
                 {
//                     NSLog(@"MEthod graph :%@",result);
                     NSDictionary *data = [result objectForKey:@"data"];
                     for (NSDictionary *friend in data)
                     {
                         NSString *friendName   = [friend objectForKey:@"name"];
                         NSString *idFriend     = [friend objectForKey:@"id"];
                         
                         [self facebookTaggedPlace:idFriend friendName:friendName];
                         
                         NSLog(@"%@ use this application too",friendName);
                     }
                 }
                 else
                     NSLog(@"%@",error.description);
             }];
        [connection start];
    }
}

#pragma mark ---------- FACEBOOK TAGGED PLACE --------------
- (void)facebookTaggedPlace:(NSString*)idFriends friendName:(NSString*)friendName
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_tagged_places"])
    {
        NSString *path = [NSString stringWithFormat:@"%@/tagged_places",idFriends];
        FBSDKGraphRequest *requestLikes = [[FBSDKGraphRequest alloc]
                                           initWithGraphPath:path
                                           parameters:@{@"fields" : @"tagged_places"}];
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
        
        [connection addRequest:requestLikes
             completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 //TODO: process like information
                 if (error == nil)
                 {
                     NSLog(@"result is:%@",result);
                     NSDictionary *data = [result objectForKey:@"data"];
                     for (NSDictionary *data_tagged in data)
                     {
                         NSString *idPlace = [data_tagged objectForKey:@"id"];
                         [self getPlaceTag:idPlace friend:idFriends friendName:friendName];
                     }
                 }
                 else
                     NSLog(@"%@",error.description);
             }];
        [connection start];
    }
}

- (void)getPlaceTag:(NSString*)placeTagID friend:(NSString*)friend friendName:(NSString*)friendName
{
    NSString *ID = [NSString stringWithFormat:@"/%@",placeTagID];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:ID
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        [[IGClient sharedClient] setFriendsPlace:result friend:friend friendName:friendName];
    }];
}

#pragma mark ---------- FACEBOOK DELEGATE ----------
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

@end
