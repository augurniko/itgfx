//
//  IGModelFriendTaggedPlace.h
//  samuiEating
//
//  Created by Mac on 13/07/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGModelFriendTaggedPlace : NSObject

@property (nonatomic, strong, readonly) NSString        *placeID;
@property (nonatomic, strong, readonly) NSString        *friendName;
@property (nonatomic, strong, readonly) NSString        *friendID;
@property (nonatomic, strong, readonly) NSString        *friendDate;

- (id)initWithValue:(NSString*)placeID
         friendName:(NSString*)friendName
           friendID:(NSString*)friendID
         friendDate:(NSString*)friendDate;

@end
