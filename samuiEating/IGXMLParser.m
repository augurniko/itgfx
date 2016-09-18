//
//  XMLParser.m
//  AugmentedR
//
//  Created by NICOLAS DEMOGUE on 25/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IGXMLParser.h"

@implementation IGXMLParser

NSString *currentNodeName;
int numberOfCoord = 0;
int totalVertice = 0;
int actualType = 0;
int compteurRoute = 0;

-(IGXMLParser*)initXMLParser:(NSMutableArray*)thedata
{
    self = [super init];
    if (self)
    {
        data = thedata;
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict 
{	
	if([elementName isEqualToString:@"rows"]) 
	{
		// Début de liste
        NSLog(@"Start Parsing");
//		data = [[NSMutableArray	alloc] init];
    }
    if([elementName isEqualToString:@"Road"]) 
	{
		// Objet trouvé
		temp = [[myStreet	alloc] init];
        temp.latitude = [[NSMutableArray alloc] init];
        temp.longitude = [[NSMutableArray alloc] init];
        numberOfCoord = 0;
        totalVertice = 0;
        firstLoc = YES;
//        temp.vertice = malloc(sizeof(GLfloat));
    }
    if([elementName isEqualToString:kName])
	{
		// copie le nom
		theString = [[[NSMutableString	alloc] init] autorelease];
		[theString setString:@""];
//        NSLog(@"Find Name %@", theString);
    }
    if([elementName isEqualToString:kKind])
	{
		// copie le nom
		theString = [[[NSMutableString	alloc] init] autorelease];
		[theString setString:@""];
        //        NSLog(@"Find Name %@", theString);
    }
    if([elementName isEqualToString:kStartNode])
	{
		// copie le nom
		theString = [[[NSMutableString	alloc] init] autorelease];
		[theString setString:@""];
        //        NSLog(@"Find Name %@", theString);
    }
    if([elementName isEqualToString:kEndNode])
	{
		// copie le nom
		theString = [[[NSMutableString	alloc] init] autorelease];
		[theString setString:@""];
        //        NSLog(@"Find Name %@", theString);
    }
    if([elementName isEqualToString:kMeter])
	{
		// copie le nom
		theString = [[[NSMutableString	alloc] init] autorelease];
		[theString setString:@""];
        //        NSLog(@"Find Name %@", theString);
    }
	if([elementName isEqualToString:kLatitude])
	{
		// copie la latitude
//    	numberOfCoord ++;
//        temp.vertice = realloc(temp.vertice,numberOfCoord*3*sizeof(GLfloat));
//        temp.vertice = realloc(temp.vertice,(1 + (numberOfCoord*18)) * sizeof(GLfloat));
		theString = [[[NSMutableString	alloc] init] autorelease];
		[theString setString:@""];
//        NSLog(@"Find Latitude %i", numberOfCoord);
    }
    if([elementName isEqualToString:kLongitude])
	{
		// copie la longitude
		theString = [[[NSMutableString	alloc] init] autorelease];
		[theString setString:@""];
//        NSLog(@"Find Longitude %@", theString);
    }
	currentNodeName = elementName;
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([currentNodeName isEqualToString:kName])
	{
		[theString appendString:string];
    }
    if([currentNodeName isEqualToString:kKind])
	{
		[theString appendString:string];
    }
    if([currentNodeName isEqualToString:kStartNode])
	{
		[theString appendString:string];
    }
    if([currentNodeName isEqualToString:kEndNode])
	{
		[theString appendString:string];
    }
    if([currentNodeName isEqualToString:kMeter])
	{
		[theString appendString:string];
    }
	if([currentNodeName isEqualToString:kLatitude])
	{
		[theString appendString:string];
    }
    if([currentNodeName isEqualToString:kLongitude])
	{
		[theString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if([elementName isEqualToString:@"Road"]) 
	{
        temp.numberOfCoord = [NSNumber numberWithInt:numberOfCoord];//]totalVertice];//]numberOfCoord];
/*        temp.startNode = [NSNumber numberWithInt:99999];
        temp.endNode = [NSNumber numberWithInt:99999];
        temp.meter = [NSNumber numberWithInt:99999];*/
        temp.area = [NSNumber numberWithInt:99999];
		[data	addObject:temp];
        [temp.latitude release];
        [temp.longitude release];
		[temp release];
//        NSLog(@"object :%i",[data count]);
    }
    if([elementName isEqualToString:kName])
	{
		// copie le nom
		NSString *tempString = [NSString stringWithString:theString];
//		temp.name = [NSString stringWithString:tempString];
        temp.name = [NSString stringWithFormat:@"%i", compteurRoute];
        compteurRoute ++;
    }
    if([elementName isEqualToString:kKind])
	{
		// copie la type
		NSString *tempString = [NSString stringWithString:theString];
		temp.kind = [NSNumber numberWithInt:[tempString intValue]];
        actualType = temp.kind;
    }
    if([elementName isEqualToString:kStartNode])
	{
		// copie le node de depart
		NSString *tempString = [NSString stringWithString:theString];
		temp.startNode = [NSNumber numberWithInt:[tempString intValue]];
    }
    if([elementName isEqualToString:kEndNode])
	{
		// copie le node de end
		NSString *tempString = [NSString stringWithString:theString];
		temp.endNode = [NSNumber numberWithInt:[tempString intValue]];
    }
    if([elementName isEqualToString:kMeter])
	{
		// copie la distance de la route
		NSString *tempString = [NSString stringWithString:theString];
		temp.meter = [NSNumber numberWithInt:[tempString intValue]];
    }
 	if([elementName isEqualToString:kLatitude])
	{
		// copie la latitude
		NSString *tempString = [NSString stringWithString:theString];
//		[temp.latitude.addObject:[NSNumber numberWithDouble:[tempString doubleValue]]];
        GLfloat latitude = [tempString floatValue];
        [temp.latitude addObject:[NSNumber numberWithFloat:latitude]];
//       	temp.vertice[(numberOfCoord-1)*3] = (latitude - 9.0f) * PRECISION_MAP;

    }
	if([elementName isEqualToString:kLongitude]) 
	{
		// copie la longitude
		NSString *tempString = [NSString stringWithString:theString];
//		temp.longitude = [NSNumber numberWithDouble:[tempString doubleValue]];
        GLfloat longitude = [tempString floatValue];
        [temp.longitude addObject:[NSNumber numberWithFloat:longitude]];
//       	temp.vertice[((numberOfCoord-1)*3)+1] = (longitude-100.0f) * -PRECISION_MAP;
//        temp.vertice[((numberOfCoord-1)*3)+2] = 0.0f;
        
/*        CLLocationCoordinate2D newLocation;
        newLocation.latitude = [[temp.latitude objectAtIndex:numberOfCoord] floatValue];
        newLocation.longitude = longitude;
        
        if (!firstLoc)
        {
            [self generateRoad:oldLocation toPoint:newLocation];
        }
        else
        {
            firstLoc = NO;
        }
        oldLocation.latitude = newLocation.latitude;
        oldLocation.longitude = newLocation.longitude;*/
        numberOfCoord ++;
    }
	if([elementName isEqualToString:@"rows"]) 
	{
		// fin du parsing
        NSLog(@"End of parsing");
	}
}

- (void)generateRoad:(CLLocationCoordinate2D)oldLoc toPoint:(CLLocationCoordinate2D)newLoc
{
    myStepperPoint = 5.0f;
    float meter = [self distanceFromCoordinate:oldLoc toCoord:newLoc];
    int stepper = meter / myStepperPoint;
    
//    float roadSize = 0.0025f;
    
//    double stepperLatitude = (oldLoc.latitude - newLoc.latitude) / stepper;
//    double stepperLongitude = (oldLoc.longitude - newLoc.longitude) / stepper;
    
    int reallocVertice = totalVertice + (stepper*9);
    
//    temp.vertice = realloc(temp.vertice,reallocVertice*sizeof(GLfloat));
    
    for (int i = 0;i < stepper;i ++)
    {
/*        temp.vertice[totalVertice+i] = (((oldLoc.latitude + (stepperLatitude*i)) - 9.0f) * PRECISION_MAP) + roadSize;
        temp.vertice[totalVertice+i+1] = (((oldLoc.longitude + (stepperLongitude*i)) - 100.0f) * -PRECISION_MAP) + roadSize;
        temp.vertice[totalVertice+i+2] = 0.0f;
        
        temp.vertice[totalVertice+i+3] = (((oldLoc.latitude + (stepperLatitude*i)) - 9.0f) * PRECISION_MAP) + roadSize;
        temp.vertice[totalVertice+i+4] = (((oldLoc.longitude + (stepperLongitude*i)) - 100.0f) * -PRECISION_MAP) - roadSize;
        temp.vertice[totalVertice+i+5] = 0.0f;
        
        temp.vertice[totalVertice+i+6] = (((oldLoc.latitude + (stepperLatitude*i)) - 9.0f) * PRECISION_MAP) - roadSize;
        temp.vertice[totalVertice+i+7] = (((oldLoc.longitude + (stepperLongitude*i)) - 100.0f) * -PRECISION_MAP) - roadSize;
        temp.vertice[totalVertice+i+8] = 0.0f;*/
        
        totalVertice += 9;
    }
//    NSLog(@"total vertice :%i",totalVertice);
}

- (CLLocationDistance) distanceFromCoordinate:(CLLocationCoordinate2D)fromCoord toCoord:(CLLocationCoordinate2D)toCoord;
{
    double earthRadius = 6371.01; // Earth's radius in Kilometers
    
    // Get the difference between our two points then convert the difference into radians
    double nDLat = (fromCoord.latitude - toCoord.latitude) * kDegreesToRadians;
    double nDLon = (fromCoord.longitude - toCoord.longitude) * kDegreesToRadians;
    
    double fromLat =  toCoord.latitude * kDegreesToRadians;
    double toLat =  fromCoord.latitude * kDegreesToRadians;
    
    double nA = pow ( sin(nDLat/2), 2 ) + cos(fromLat) * cos(toLat) * pow ( sin(nDLon/2), 2 );
    
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = earthRadius * nC;
    
    return nD * 1000; // Return our calculated distance in meters
}

-(NSMutableArray*)returnData
{
	return data;
}

@end
