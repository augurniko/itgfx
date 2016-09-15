//
//  IGModelFriendTaggedPlace.m
//  samuiEating
//
//  Created by Mac on 13/07/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGModelFriendTaggedPlace.h"

@implementation IGModelFriendTaggedPlace

- (id)initWithValue:(NSString*)placeID
         friendName:(NSString*)friendName
           friendID:(NSString*)friendID
         friendDate:(NSString*)friendDate
{
    self = [super init];
    if (self)
    {
        _placeID        = placeID;
        _friendName     = friendName;
        _friendID       = friendID;
        _friendDate     = friendDate;
    }
    return self;
}

@end
