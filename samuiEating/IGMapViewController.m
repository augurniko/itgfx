//
//  IGMapViewController.m
//  samuiEating
//
//  Created by Mac on 22/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGMapViewController.h"

#import "IGClient.h"

#import <MapKit/MapKit.h>

@interface IGMapViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView      *mapView;
@property (nonatomic, strong) MKMapItem             *destination;
@property (nonatomic, strong) MKMapItem             *origin;

@end

CLLocationCoordinate2D  dst;

BOOL askRoute;

@implementation IGMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = [self.dataDict objectAtIndex:0];
    
    askRoute = YES;
    double latitude = [[dict objectForKey:@"latitude"] doubleValue];
    double longitude = [[dict objectForKey:@"longitude"] doubleValue];
    dst.latitude = latitude;
    dst.longitude = longitude;
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
    self.destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    [self.destination setName:@"Name of your location"];
    //[self.destination openInMapsWithLaunchOptions:nil];
    [self.mapView addAnnotation:placemark];
    self.mapView.delegate = self;
    
    if ([[IGClient sharedClient] isLocationEnable])
    {
        [self getPathWay];
    }
    else
    {
        CLLocationCoordinate2D place;
        place.latitude = latitude;
        place.longitude = longitude;
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.025;             // 0.0 is min value u van provide for zooming
        span.longitudeDelta= 0.025;
        
        region.span = span;
        region.center = place;        // to locate to the center
        
        [self.mapView setRegion:region animated:TRUE];
        [self.mapView regionThatFits:region];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDirections
{
    askRoute = NO;
    MKDirectionsRequest *request =
    [[MKDirectionsRequest alloc] init];
    
    request.source = _origin;//[MKMapItem mapItemForCurrentLocation];
    
    request.destination = _destination;
    request.requestsAlternateRoutes = NO;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error)
         {
             NSLog(@"error:%@",error.description);
         }
         else
         {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

-(void)getPathWay{

    CLLocationCoordinate2D currentLocation = [[IGClient sharedClient] retrunLocation];
    
    double lat = currentLocation.latitude;
    double lng = currentLocation.longitude;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.025;             // 0.0 is min value u van provide for zooming
    span.longitudeDelta= 0.025;

    region.span = span;
    region.center = currentLocation;        // to locate to the center

    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng) addressDictionary:nil];
    self.origin = [[MKMapItem alloc] initWithPlacemark:placemark];
    [self.origin setName:@"Origin"];
  
    if (askRoute)
        [self getDirections];

    [self centerMapWithPoint:currentLocation];
}

- (void)centerMapWithPoint:(CLLocationCoordinate2D)ori
{
    double lon1 = ori.longitude * M_PI / 180;
    double lon2 = dst.longitude * M_PI / 180;
    
    double lat1 = ori.latitude * M_PI / 180;
    double lat2 = dst.latitude * M_PI / 180;
    
    double dLon = lon2 - lon1;
    
    double x = cos(lat2) * cos(dLon);
    double y = cos(lat2) * sin(dLon);
    
    double lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
    double lon3 = lon1 + atan2(y, cos(lat1) + x);
    
    CLLocationCoordinate2D center;
    
    center.latitude  = lat3 * 180 / M_PI;
    center.longitude = lon3 * 180 / M_PI;
    
    
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = fabs(ori.latitude - dst.latitude) * 1.5;
    locationSpan.longitudeDelta = fabs(ori.longitude - dst.longitude) * 1.5;
    MKCoordinateRegion region = {center, locationSpan};
    
    [_mapView setRegion:region];
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
