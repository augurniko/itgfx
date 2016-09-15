//
//  IGClient.h
//  samuiEating
//
//  Created by Mac on 19/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreData/CoreData.h>
#import "IGConstants.h"
#import "IGLocation.h"
#import "IGModelFriendTaggedPlace.h"

#import "IGMainViewController.h"


@class IGClient;

// define the protocol for the delegate
@protocol IGClientDelegate

- (void)jsonDownloaded:(IGClient*)IGClient;
- (void)jsonError:(IGClient*)IGClient error:(NSString*)error;

@end

@interface IGClient : NSObject

@property (nonatomic, weak)    id                   delegate;
@property (nonatomic, strong)  NSMutableArray       *dataArray;
@property (nonatomic, strong)  NSMutableArray       *dataFriendsPlace;
@property (nonatomic, strong)  NSArray              *typeListArray;
@property (nonatomic, strong)  NSArray              *likeArray;
@property (nonatomic)          BOOL                 internetConnection;
@property (nonatomic, strong)  IGLocation           *locationManager;
@property (nonatomic)          BOOL                 islocationManager;
@property (nonatomic, strong)  NSString             *facebookName;
@property (nonatomic, strong)  NSString             *facebookProfileImageUrl;
@property (nonatomic, strong)  NSDictionary         *onlyOneType;

@property (nonatomic)           NSInteger           typeList;

+ (IGClient*)sharedClient;

- (void)reachability;
- (CGFloat)setFontByDeviceType:(CGFloat)size;

- (void)postFacebookInfoUser:(id)data;
- (void)resetFacebookInfoUser;

- (void)setLikeUser:(id)data;
- (BOOL)checkLikeUser:(NSString*)facebookID;

- (void)setFriendsPlace:(id)data friend:(NSString*)friend friendName:(NSString*)friendName;
- (NSMutableArray*)returnFriendForPlace:(NSString*)idFacebook;

- (NSArray*)getEntity:(NSString*)data forKey:(NSString*)key;
- (void)setEntityForFavorit:(int)entity_id;
- (NSArray*)getFavoritEntity:(BOOL)data;
- (NSArray*)getDiscountEntity;

- (void)generateTypeList;

- (void)setTypeList:(NSInteger)type;
- (NSInteger)getTypeList;
- (int)returnAvailableTypeList;

- (void)startLocation;
- (BOOL)isLocationEnable;
- (CLLocationCoordinate2D)retrunLocation;
- (CLLocationDistance)returnDistance:(CLLocationCoordinate2D)to;

// Delegate
- (void)setDelegate:(id)delegate;

@end
