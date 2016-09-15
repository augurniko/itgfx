//
//  IGFacebookManager.h
//  samuiEating
//
//  Created by Mac on 22/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@class IGFacebookObject;

// define the protocol for the delegate
@protocol IGFacebookDelegate

- (void)facebookConnected:(IGFacebookObject*)IGFacebookObject;
- (void)facebookDisconnected:(IGFacebookObject*)IGFacebookObject;
- (void)facebookError:(IGFacebookObject*)IGFacebookObject error:(NSString*)error;


@end


@interface IGFacebookObject : NSObject <FBSDKLoginButtonDelegate>

@property (nonatomic, weak)   id  delegate;
@property (nonatomic, strong) id  viewController;

- (id)initWithViewController:(id)controller;

- (void)facebookLogin;
- (void)facebookLogout;
- (BOOL)getFacebookData;

// Delegate
- (void)setDelegate:(id)delegate;

@end
