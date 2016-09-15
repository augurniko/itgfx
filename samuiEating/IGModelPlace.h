//
//  IGModelPlace.h
//  samuiEating
//
//  Created by Mac on 19/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGModelPlace : NSObject

@property (nonatomic, strong, readonly) NSString        *placeTitle;
@property (nonatomic, strong, readonly) NSString        *placeValue;
@property (nonatomic, strong, readonly) NSNumber        *placeType;
@property (nonatomic, strong, readonly) NSNumber        *placeHeight;

- (id)initWithValue:(NSString*)title
              value:(NSString*)value
               type:(int)type
             height:(float)height;

@end
