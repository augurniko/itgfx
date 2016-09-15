//
//  IGLocation.h
//  samuiEating
//
//  Created by Mac on 25/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface IGLocation : NSObject

@property (nonatomic) BOOL    isLocationActive;

- (id)init;

- (CLLocationCoordinate2D)returnLocation;
- (CLLocationDistance)getDistance:(CLLocationCoordinate2D)to;

@end
