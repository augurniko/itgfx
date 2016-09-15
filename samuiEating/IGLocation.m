//
//  IGLocation.m
//  samuiEating
//
//  Created by Mac on 25/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGLocation.h"

@interface IGLocation () <CLLocationManagerDelegate>

@end

CLLocationManager       *locationManager;
CLLocationCoordinate2D  myLocation;

@implementation IGLocation

- (id)init
{
    self = [super init];
    if (self)
    {
        [self startLocationManager];
    }
    return self;
}

- (void)startLocationManager
{
    // Do any additional setup after loading the view.
    _isLocationActive           = NO;
    locationManager             = [[CLLocationManager alloc] init];
    locationManager.delegate    = self;
    [locationManager requestWhenInUseAuthorization];
    // 3
    if (CLLocationManager.locationServicesEnabled)
    {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager requestLocation];
    }
}

- (CLLocationCoordinate2D)returnLocation
{
    return myLocation;
}

- (CLLocationDistance)getDistance:(CLLocationCoordinate2D)to
{
    __block CLLocationDistance distance;
    
/*    MKDirectionsRequest *request    = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *placemark =
    [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(myLocation.latitude, myLocation.longitude) addressDictionary:nil];
    MKMapItem *origin               = [[MKMapItem alloc] initWithPlacemark:placemark];
    request.source                  = origin;
    
    MKPlacemark *placemark2 =
    [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(to.latitude, to.longitude) addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark2];
    request.destination             = destination;
    request.requestsAlternateRoutes = NO;
    MKDirections *directions        = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error)
         {
             NSLog(@"error:%@",error.description);
             distance = 0.0;
         }
         else
         {
             MKRoute *route = response.routes[0];
             distance = route.distance;
         }
     }];*/
    
    CLLocation *locationFrom = [[CLLocation alloc] initWithLatitude:myLocation.latitude
                                                          longitude:myLocation.longitude];
    
    CLLocation *locationTo  = [[CLLocation alloc] initWithLatitude:to.latitude
                                                         longitude:to.longitude];
    
    distance = [locationFrom distanceFromLocation:locationTo];
    
    return distance;
}

#pragma mark - Delegate location manager
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // Assigning the last object as the current location of the device
    _isLocationActive = YES;
    CLLocation *currentLocation = [locations lastObject];
    double lat = currentLocation.coordinate.latitude;
    double lng = currentLocation.coordinate.longitude;
    myLocation.latitude = lat;
    myLocation.longitude = lng;
    
    if ((lat > 9.403825) && (lat < 9.598335) && (lng > 99.904103) && (lng < 100.095630))
    {
        NSLog(@"in samui");
    }
    else
    {
        _isLocationActive = NO;
    }
    // 9.598335, 100.095630
    // 9.403825, 99.904103
    NSLog(@"%f,%f",lat,lng);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch(status)
    {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Unknow");
            break;
            
        case    kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"can");
            break;
        case    kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"can");
            break;
        default:
            NSLog(@"Unknow");
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error : %@",error.description);
}

@end
