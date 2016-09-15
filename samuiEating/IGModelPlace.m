//
//  IGModelPlace.m
//  samuiEating
//
//  Created by Mac on 19/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGModelPlace.h"

@implementation IGModelPlace

- (id)initWithValue:(NSString*)title
              value:(NSString*)value
               type:(int)type
             height:(float)height
{
    self = [super init];
    if (self)
    {
        _placeTitle       = title;
        _placeValue       = value;
        _placeType        = [NSNumber numberWithInt:type];
        _placeHeight      = [NSNumber numberWithFloat:height];
    }
    return self;
}

@end
