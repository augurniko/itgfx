//
//  IGClient.m
//  samuiEating
//
//  Created by Mac on 19/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import "IGClient.h"

@implementation IGClient


+ (id)sharedClient
{
    static IGClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    
    return sharedClient;
}

/* SET TYPE LIST */
- (void)setTypeList:(NSInteger)type
{
    _typeList = type;
}

/* GET TYPE LIST */
- (NSInteger)getTypeList
{
    return _typeList;
}

/* SET TYPE LIST ARRAY */
- (void)generateTypeList
{
    if (_typeListArray == nil)
        _typeListArray = [self getEntity:@"interface_type" forKey:@"type"];
}

/* RETURN AVAILABLE TYPE LIST */
- (int)returnAvailableTypeList
{
    int countTypeList = 0;
    for (NSDictionary *type in _typeListArray)
    {
        NSString *typeName = [type objectForKey:@"name"];
        NSArray *temp = [self getEntity:typeName forKey:@"type"];
        if ([temp count] > 0)
        {
            countTypeList ++;
        }
    }
    if (countTypeList == 1)
    {
        _onlyOneType = [NSDictionary dictionaryWithObjectsAndKeys:@"Restaurant", @"name", @"247,33,25", @"option", nil];
    }
    
    return countTypeList;
}

/* START LOCATION MANAGER */
- (void)startLocation
{
    _locationManager = [[IGLocation alloc] init];
}

/* RETURN LOCATION */
- (CLLocationCoordinate2D)retrunLocation
{
    return [_locationManager returnLocation];
}

/* LOCATION ENABLE */
- (BOOL)isLocationEnable
{
    return _locationManager.isLocationActive;
}

/* RETURN DISTANCE FROM --> TO */
- (CLLocationDistance)returnDistance:(CLLocationCoordinate2D)to
{
    return [_locationManager getDistance:to];
}

/* SET IDIO IPAD / IPHONE */
- (CGFloat)setFontByDeviceType:(CGFloat)size
{
    CGFloat returnSize = 0.0f;
    if (IPAD)
    {
        if (size == 14.f)
            returnSize = 25.f;
        if (size == 15.f)
            returnSize = 28.f;
        if (size == 17.f)
            returnSize = 31.f;
        if (size == 19.f)
            returnSize = 35.f;
        if (size == 21.f)
            returnSize = 40.f;
    }
    else
    {
        returnSize = size;
    }
    return returnSize;
}

/* CHECK INTERNET CONNEXION */
- (void)reachability {

    __block BOOL haveInternetConnection     = NO;
    __block BOOL internetConnectionChecked  = NO;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                haveInternetConnection = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                haveInternetConnection = NO;
                break;
            default:
                break;
        }
        
        if (!internetConnectionChecked)
        {
            internetConnectionChecked = YES;
            if (haveInternetConnection)
                [self getJsonResponse];
            else
            {
                if ([self countEntity] > 0)
                {
                    NSLog(@"%@",@"\nNo connection");
                    [_delegate jsonError:self error:@"No internet"];
                }
                else
                {
                    NSLog(@"%@",@"\nError no connection and database empty!");
                    [_delegate jsonError:self error:STR_FIRST_LAUNCH];
                }
            }
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

/* SET THE CACHE FOR PICTURE */
- (void)setupCache
{
/*    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*4 // 1MB mem cache
                                                         diskCapacity:1024*1024*5 // 5MB disk cache
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:urlCache];*/
}

/* GET JSON FILE FROM SERVER */
- (void)getJsonResponse
{
    [self setupCache];
    NSLog(@"%@",@"\njson from internet");
    
    self.internetConnection     = YES;
    NSString *stringFromDate    = nil;
    
    if ([self countEntity] == 0)
        stringFromDate = @"0000-00-00 00:00:00";
    else
        stringFromDate = [self lastModifiedEntity];;

    NSDictionary *parameters    = @{@"date": stringFromDate};
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",
                           URL_ITGRAFIX_PHP_REQUEST,
                           @"getJsonForDate.php"];

//    NSString *urlString = [NSString stringWithFormat:@"%@",
//                           URL_ITGRAFIX_PHP_REQUEST];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager GET:URL.absoluteString parameters:parameters progress:nil success:^(NSURLSessionTask *task, id _Nullable responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            // Remove Entity deleted in sql database server
            [self removeEntityDeleted:responseObject];
            // Create / Update Entity
            [self createUpdateCoreDataBase:responseObject];
        }
        [_delegate jsonDownloaded:self];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        if ([self countEntity] > 0)
        {
            [_delegate jsonError:self error:error.description];
        }
        else
        {
            NSLog(@"\nError cannot start application database is empty!");
            [_delegate jsonError:self error:STR_FIRST_LAUNCH];
        }
    }];
}

/* POST FACEBOOK ACCOUNT DATA TO SERVER */
- (void)postFacebookInfoUser:(id)data
{

    NSDictionary *parameters    = @{@"name": [data objectForKey:@"name"],
                                    @"email": @""};//[data objectForKey:@"email"]};
    
    NSDictionary *pict          = [data objectForKey:@"picture"];
    NSDictionary *pictdata      = [pict objectForKey:@"data"];
    NSString *pictUrl           = [pictdata objectForKey:@"url"];
    
    _facebookName               = [data objectForKey:@"name"];
    _facebookProfileImageUrl    = [NSString stringWithFormat:@"%@", pictUrl];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",
                           URL_ITGRAFIX_PHP_REQUEST,
                           @"saveUpdateFacebookUser.php"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"Facebook: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"\nFacebook failed %@", error.description);
    }];
}

/* RESET FACEBOOK INFO USER DATA */
- (void)resetFacebookInfoUser
{
    _facebookName               = nil;
    _facebookProfileImageUrl    = nil;
}

/* SET FRIENDS PLACES */
- (void)setFriendsPlace:(id)data friend:(NSString*)friend friendName:(NSString*)friendName
{
    if (_dataFriendsPlace == nil)
        _dataFriendsPlace = [NSMutableArray new];
    NSDictionary *friendsDict   = [data objectForKey:@"place"];
    NSString *placeID           = [friendsDict objectForKey:@"id"];
    NSString *dateTagged        = [data objectForKey:@"created_time"];
    NSString *myDate = nil;
    if ([dateTagged length] >= 10)
        myDate = [dateTagged substringToIndex:10];
    
    NSString *taggedSince = nil;
    if (myDate != nil)
        taggedSince = [self daySince:myDate];
    else
        taggedSince = @"";
    
    NSArray *facebookList       = [self getFacebookEntity:placeID];
    if ((facebookList != nil) && ([facebookList count] > 0))
    {
        IGModelFriendTaggedPlace *temp = [[IGModelFriendTaggedPlace alloc]
                                          initWithValue:placeID
                                          friendName:friendName
                                          friendID:friend
                                          friendDate:taggedSince];

//        [_dataFriendsPlace addObject:temp];
//10153539490734115
        IGModelFriendTaggedPlace *temp1 = [[IGModelFriendTaggedPlace alloc]
                                          initWithValue:placeID
                                          friendName:@"Julius Deware"
                                          friendID:@"767234114"
                                          friendDate:@"1 Month ago"];
        [_dataFriendsPlace addObject:temp1];
        IGModelFriendTaggedPlace *temp2 = [[IGModelFriendTaggedPlace alloc]
                                           initWithValue:placeID
                                           friendName:@"Gaby Forsaken"
                                           friendID:@"100000818712430"
                                           friendDate:@"1 week ago"];
        [_dataFriendsPlace addObject:temp2];
        IGModelFriendTaggedPlace *temp3 = [[IGModelFriendTaggedPlace alloc]
                                           initWithValue:placeID
                                           friendName:@"Pat Pady"
                                           friendID:@"1430413459"
                                           friendDate:@"8 days ago"];
        [_dataFriendsPlace addObject:temp3];
    }
}

- (NSMutableArray*)returnFriendForPlace:(NSString*)idFacebook
{
    NSMutableArray *list = [NSMutableArray new];
    for (IGModelFriendTaggedPlace *friend in _dataFriendsPlace)
    {
        if ([friend.placeID isEqualToString:idFacebook])
            [list addObject:friend];
    }
    return list;
}

- (NSString*)daySince:(NSString*)date
{
    
    NSDateFormatter *formatter  = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *taggedDate    = [NSDate new];
    taggedDate            = [formatter dateFromString:date];
    
    NSDate *today = [NSDate new];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:taggedDate
                                                          toDate:today
                                                         options:0];
    
    NSString *returnDate = [NSString stringWithFormat:@"Visited %ld day(s) ago",[components day]];
    
    return returnDate;
}


/* SAVE LIKE INFO USER */
- (void)setLikeUser:(id)data
{
    _likeArray = [data objectForKey:@"data"];
}

/* CHECK LIKE INFO USER */
- (BOOL)checkLikeUser:(NSString*)facebookID
{
    BOOL isLiked = NO;
    
    for (NSDictionary *likes in _likeArray)
    {
        NSString *like = [likes  objectForKey:@"id"];
        if ([like isEqualToString:facebookID])
            isLiked = YES;
    }    
    return isLiked;
}

#pragma mark ----------- COREDATA MANAGMENT -----------
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

/* FIND LAST MODIFIED DATE ENTITY */
- (NSString*)lastModifiedEntity
{
    NSString *nullDate          = @"2015-01-01 10:10:10";
    NSDateFormatter *formatter  = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//   [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSDate *lastModifiedDate    = [NSDate new];
    lastModifiedDate            = [formatter dateFromString:nullDate];
    
    if ([self countEntity] > 0)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *request         = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
        
        NSError *error                  = nil;
        NSArray *results                = [context executeFetchRequest:request error:&error];
        
        for (NSManagedObject *obj in results)
        {
            NSArray *keys               = [[[obj entity] attributesByName] allKeys];
            NSDictionary *dictionary    = [obj dictionaryWithValuesForKeys:keys];
            NSDate *modifiedDate        = [dictionary objectForKey:@"modifiedDate"];
            if ([modifiedDate compare:lastModifiedDate] == NSOrderedDescending)
                lastModifiedDate = modifiedDate;
        }
    }
    return [formatter stringFromDate:lastModifiedDate];
}

/* ENTITY COUNTER */
- (NSUInteger)countEntity
{
    NSFetchRequest *fetchRequest    = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    fetchRequest.resultType         = NSCountResultType;
    NSError *fetchError             = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSUInteger itemsCount           = [context countForFetchRequest:fetchRequest error:&fetchError];
    if (itemsCount == NSNotFound)
    {
        NSLog(@"Fetch error: %@", fetchError);
        return 0;
    }
    return itemsCount;
}

/* CHECK ENTITY IN DATABASE */
- (NSArray*)checkThisEntity:(int)place_id
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request         = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id = %i", place_id]];
    [request setFetchLimit:1];
    NSError *error      = nil;
    NSUInteger count    = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound)
        return nil;
    else if (count == 0)
        return nil;
    else
        return [context executeFetchRequest:request error:&error];
}

/* FIND ENTITY IN DATABASE */
- (NSArray*)getEntity:(NSString*)data forKey:(NSString*)key
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request         = [[NSFetchRequest alloc]initWithEntityName:@"Place"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", key, data]];
    
    NSError *error                  = nil;
    NSUInteger count                = [context countForFetchRequest:request error:&error];
    request.fetchLimit              = count;
    NSArray *fetchedResults         = [context executeFetchRequest:request error:&error];
    
    NSMutableArray *arrayDict       = [NSMutableArray new];
    for (NSManagedObject *obj in fetchedResults)
    {
        NSArray *keys       = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dict  = [obj dictionaryWithValuesForKeys:keys];
        [arrayDict addObject:dict];
    }
    return arrayDict;
}

/* ADD ENTITY IN FAVORIT */
- (void)setEntityForFavorit:(int)entity_id
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *entityUpdated          = [self checkThisEntity:entity_id];
    // If Entity already exist
    if (entityUpdated != nil)
    {
        // Update
        NSLog(@"Update favorit");
        [entityUpdated setValue:[NSNumber numberWithBool:YES]      forKey:@"favorit"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error])
        {
            NSLog(@"Can't add to favorit! %@ %@", error, [error localizedDescription]);
        }
    }
}

/* GET FAVORIT ENTITY IN DATABASE */
- (NSArray*)getFavoritEntity:(BOOL)data
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request         = [[NSFetchRequest alloc]initWithEntityName:@"Place"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %c", @"favorit", data]];
    
    NSError *error                  = nil;
    NSUInteger count                = [context countForFetchRequest:request error:&error];
    request.fetchLimit              = count;
    NSArray *fetchedResults         = [context executeFetchRequest:request error:&error];
    
    NSMutableArray *arrayDict       = [NSMutableArray new];
    for (NSManagedObject *obj in fetchedResults)
    {
        NSArray *keys       = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dict  = [obj dictionaryWithValuesForKeys:keys];
        [arrayDict addObject:dict];
    }
    return arrayDict;
}

/* GET DISCOUNT ENTITY IN DATABASE */
- (NSArray*)getDiscountEntity
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request         = [[NSFetchRequest alloc]initWithEntityName:@"Place"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(%K != %@) AND (%K != %@)", @"discount", @"", @"type", @"interface_type"]];
    
    NSError *error                  = nil;
    NSUInteger count                = [context countForFetchRequest:request error:&error];
    request.fetchLimit              = count;
    NSArray *fetchedResults         = [context executeFetchRequest:request error:&error];
    
    NSMutableArray *arrayDict       = [NSMutableArray new];
    for (NSManagedObject *obj in fetchedResults)
    {
        NSArray *keys       = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dict  = [obj dictionaryWithValuesForKeys:keys];
        [arrayDict addObject:dict];
    }

    return arrayDict;
}

/* GET FACEBOOK ENTITY IN DATABASE */
- (NSArray*)getFacebookEntity:(NSString*)idFacebook
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request         = [[NSFetchRequest alloc]initWithEntityName:@"Place"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", @"facebook", idFacebook]];
    
    NSError *error                  = nil;
    NSUInteger count                = [context countForFetchRequest:request error:&error];
    request.fetchLimit              = count;
    NSArray *fetchedResults         = [context executeFetchRequest:request error:&error];
    
    NSMutableArray *arrayDict       = [NSMutableArray new];
    for (NSManagedObject *obj in fetchedResults)
    {
        NSArray *keys       = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dict  = [obj dictionaryWithValuesForKeys:keys];
        [arrayDict addObject:dict];
    }
    return arrayDict;
}

/* CREATE OR UPDATE ENTITY */
- (void)createUpdateCoreDataBase:(id)response
{
    int updatedEntity = 0;
    int createdEntity = 0;
    
    NSDictionary *myDict    = response;
    NSEnumerator *keyEnum   = [myDict keyEnumerator];
    id key;
    while ((key = [keyEnum nextObject]))
    {
        id place = [myDict objectForKey:key];
        if ([place objectForKey:@"name"] != [NSNull null])
        {
            NSManagedObjectContext *context = [self managedObjectContext];
            NSArray *entityUpdated          = [self checkThisEntity:[[place objectForKey:@"id"] intValue]];
            // If Entity already exist
            if (entityUpdated != nil)
            {
                // Update
                NSLog(@"Update");
                [entityUpdated setValue:[place objectForKey:@"name"]     forKey:@"name"];
                NSString *comment = [[place objectForKey:@"comment"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [entityUpdated setValue:comment forKey:@"comment"];
                NSString *address = [[place objectForKey:@"address"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [entityUpdated setValue:address forKey:@"address"];
                [entityUpdated setValue:[place objectForKey:@"picture"]  forKey:@"picture"];
                [entityUpdated setValue:[place objectForKey:@"vignette"] forKey:@"vignette"];
                [entityUpdated setValue:[place objectForKey:@"type"]     forKey:@"type"];
                [entityUpdated setValue:[place objectForKey:@"option"]   forKey:@"option"];
                double lat = [[place objectForKey:@"latitude"]  doubleValue];
                double lng = [[place objectForKey:@"longitude"] doubleValue];
                [entityUpdated setValue:[NSNumber numberWithDouble:lat]  forKey:@"latitude"];
                [entityUpdated setValue:[NSNumber numberWithDouble:lng]  forKey:@"longitude"];
                [entityUpdated setValue:[place objectForKey:@"discount"] forKey:@"discount"];
                int rate = [[place objectForKey:@"star"] intValue];
                [entityUpdated setValue:[NSNumber numberWithInt:rate]    forKey:@"rating"];
                [entityUpdated setValue:[place objectForKey:@"similar"]  forKey:@"similar"];
                [entityUpdated setValue:[place objectForKey:@"facebook"] forKey:@"facebook"];
                [entityUpdated setValue:[place objectForKey:@"phone"]    forKey:@"phone"];
                [entityUpdated setValue:[place objectForKey:@"email"]    forKey:@"email"];
                [entityUpdated setValue:[place objectForKey:@"website"]  forKey:@"website"];
                NSString *average = [[place objectForKey:@"average"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [entityUpdated setValue:average forKey:@"average"];
                NSString *credit_card = [[place objectForKey:@"credit_card"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [entityUpdated setValue:credit_card forKey:@"credit_card"];
                NSString *service_tax = [[place objectForKey:@"service_tax"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [entityUpdated setValue:service_tax forKey:@"service_tax"];
                NSString *opening = [[place objectForKey:@"opening"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [entityUpdated setValue:opening forKey:@"opening"];
                
                NSDate *now = [NSDate new];
                [entityUpdated setValue:now forKey:@"modifiedDate"];
                
                updatedEntity ++;
            }
            else
            {
                // Create a new managed object
                NSManagedObject *newPlace = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
                int id_place = [[place objectForKey:@"id"] intValue];
                [newPlace setValue:[NSNumber numberWithInt:id_place] forKey:@"id"];
                [newPlace setValue:[place objectForKey:@"name"]      forKey:@"name"];
                NSString *comment = [[place objectForKey:@"comment"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [newPlace setValue:comment forKey:@"comment"];
                NSString *address = [[place objectForKey:@"address"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [newPlace setValue:address forKey:@"address"];
                [newPlace setValue:[place objectForKey:@"picture"]   forKey:@"picture"];
                [newPlace setValue:[place objectForKey:@"vignette"]  forKey:@"vignette"];
                [newPlace setValue:[place objectForKey:@"type"]      forKey:@"type"];
                [newPlace setValue:[place objectForKey:@"option"]    forKey:@"option"];
                double lat = [[place objectForKey:@"latitude"] doubleValue];
                double lng = [[place objectForKey:@"longitude"] doubleValue];
                [newPlace setValue:[NSNumber numberWithDouble:lat]   forKey:@"latitude"];
                [newPlace setValue:[NSNumber numberWithDouble:lng]   forKey:@"longitude"];
                [newPlace setValue:[NSNumber numberWithBool:NO]      forKey:@"favorit"];
                [newPlace setValue:[place objectForKey:@"discount"]  forKey:@"discount"];
                int rate = [[place objectForKey:@"star"] intValue];
                [newPlace setValue:[NSNumber numberWithInt:rate]     forKey:@"rating"];
                [newPlace setValue:[place objectForKey:@"similar"]   forKey:@"similar"];
                [newPlace setValue:[place objectForKey:@"facebook"]  forKey:@"facebook"];
                [newPlace setValue:[place objectForKey:@"phone"]     forKey:@"phone"];
                [newPlace setValue:[place objectForKey:@"email"]     forKey:@"email"];
                [newPlace setValue:[place objectForKey:@"website"]   forKey:@"website"];
                NSString *average = [[place objectForKey:@"average"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [newPlace setValue:average forKey:@"average"];
                NSString *credit_card = [[place objectForKey:@"credit_card"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [newPlace setValue:credit_card forKey:@"credit_card"];
                NSString *service_tax = [[place objectForKey:@"service_tax"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [newPlace setValue:service_tax forKey:@"service_tax"];
                NSString *opening = [[place objectForKey:@"opening"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                [newPlace setValue:opening   forKey:@"opening"];
                
                NSDate *now = [NSDate new];
                [newPlace setValue:now                               forKey:@"modifiedDate"];
                
                createdEntity ++;
            }
            NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error])
            {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }
    }
    NSLog(@"\nCreated Entity:%i\nUpdated Entity:%i",createdEntity, updatedEntity);
}

/* REMOVE ENTITY */
- (void)removeEntityDeleted:(id)response
{
    int deletedEntity       = 0;
    NSDictionary *myDict    = response;
    // Remove Entity
    if ([self countEntity] > 0)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *request         = [[NSFetchRequest alloc]initWithEntityName:@"Place"];
        
        NSError *error                  = nil;
        NSArray *results                = [context executeFetchRequest:request error:&error];
        
        for (NSManagedObject *obj in results)
        {
            BOOL iFoundIt               = NO;
            NSArray *keys               = [[[obj entity] attributesByName] allKeys];
            NSDictionary *dictionary    = [obj dictionaryWithValuesForKeys:keys];
            int place_id                = [[dictionary objectForKey:@"id"] intValue];
            
            NSEnumerator *keyEnum = [myDict keyEnumerator];
            id key;
            // Parse json
            while ((key = [keyEnum nextObject]) && (iFoundIt == NO))
            {
                id value = [myDict objectForKey:key];
                if ([[value objectForKey:@"id"] intValue] == place_id)
                    iFoundIt = YES;
            }
            if (iFoundIt == NO)
            {
                NSFetchRequest *fetch   = [[NSFetchRequest alloc] init];
                fetch.entity            = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
                fetch.predicate         = [NSPredicate predicateWithFormat:@"id == %i", place_id];
                NSArray *array          = [context executeFetchRequest:fetch error:nil];
                
                for (NSManagedObject *managedObject in array)
                {
                    [context deleteObject:managedObject];
                }
                deletedEntity ++;
            }
        }
        if (error != nil)
        {
            //Deal with failure
        }
        else
        {
            //Deal with success
        }
    }
    NSLog(@"\nDeleted Entity:%i", deletedEntity);
}

@end
