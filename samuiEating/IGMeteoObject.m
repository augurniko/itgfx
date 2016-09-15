//
//  IGMeteo.m
//  samuiEating
//
//  Created by Mac on 26/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGMeteoObject.h"

#import "IGClient.h"

@interface IGMeteoObject () < NSXMLParserDelegate >

@end

@implementation IGMeteoObject

- (id)init
{
    self = [super init];
    if (self)
    {
        [self getInfos];
    }
    return self;
}

/* GET THE INFOS TIME, DATE, METEO */
- (void)getInfos
{
    NSLocale *samuiLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"th_TH"];
    [[NSDate date] descriptionWithLocale:samuiLocale];
    
    NSDate *dateInSamui = [NSDate new];
    NSDateFormatter *formatterTime  = [NSDateFormatter new];
    [formatterTime setDateFormat:@"HH:mm"];
    NSDateFormatter *formatterDate  = [NSDateFormatter new];
    [formatterDate setDateFormat:@"dd-MMM-yyyy"];
    
    self.timeInSamui = [NSString stringWithFormat:@"KST %@",[formatterTime stringFromDate:dateInSamui]];
    self.dateInSamui = [formatterDate stringFromDate:dateInSamui];
    
    [self requestTemperature];
}

/* REQUEST XML FOR METEO */
- (void)requestTemperature
{
    NSURL *aUrl = [NSURL URLWithString:URL_METEO_BY_HOUR];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =  [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml"];
    NSURLSessionDataTask *task =
    [manager dataTaskWithRequest:request
               completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
               {
                   [self startParsing:(NSData*)responseObject];
               }
    ];
    [task resume];
}

/* XML PARSER FUNCTION & DELEGATE */
- (void)startParsing:(NSData*)data
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    [xmlParser setDelegate:self];
    BOOL parsing = [xmlParser parse];
    
    if (parsing)
        NSLog(@"temperature:%@",_temperatureInSamui);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"temperature"])
    {
        if (_temperatureInSamui == nil)
        {
            _temperatureInSamui = [attributeDict objectForKey:@"value"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"temperatureOk" object:self];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{

}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{

}

/* RETURN TEMPERATURE IN CELCIUS */
- (NSString*)getTemperature
{
    return self.temperatureInSamui;
}

/* RETURN CURRENT TIME IN SAMUI */
- (NSString*)getTime
{
    return self.timeInSamui;
}

/* RETURN CURRENT DATE IN SAMUI */
- (NSString*)getDate
{
    return self.dateInSamui;
}

@end
