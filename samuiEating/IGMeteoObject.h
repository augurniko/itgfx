//
//  IGMeteo.h
//  samuiEating
//
//  Created by Mac on 26/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGMeteoObject : NSObject

@property (nonatomic, strong)   NSString *temperatureInSamui;
@property (nonatomic, strong)   NSString *timeInSamui;
@property (nonatomic, strong)   NSString *dateInSamui;

- (id)init;

- (void)requestTemperature;

- (NSString*)getTemperature;
- (NSString*)getTime;
- (NSString*)getDate;

@end
