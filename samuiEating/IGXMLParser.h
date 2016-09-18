//
//  XMLParser.h
//  AugmentedR
//
//  Created by NICOLAS DEMOGUE on 25/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#define 	kName		@"name"
#define 	kKind		@"kind"
#define		kLatitude	@"lat"				// lat
#define		kLongitude	@"lon"			// lng
#define 	kStartNode	@"snode"
#define 	kEndNode	@"enode"
#define 	kMeter		@"meter"

@interface IGXMLParser : NSObject <NSXMLParserDelegate>
{

	NSMutableString *currentElementValue;
	NSMutableArray	*data;
	
	NSMutableString	*theString;
}

- (IGXMLParser*)initXMLParser:(NSMutableArray*)thedata;
- (NSMutableArray*)returnData;

- (void)generateRoad:(CLLocationCoordinate2D)oldLoc toPoint:(CLLocationCoordinate2D)newLoc;

@end
