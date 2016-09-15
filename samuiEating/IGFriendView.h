//
//  IGFriendView.h
//  samuiEating
//
//  Created by Mac on 13/07/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGFriendView : UIView

@property (nonatomic, strong) NSString   *friendPicture;
@property (nonatomic, strong) NSString   *friendName;
@property (nonatomic, strong) NSString   *friendDate;

- (void)setParameters:(NSString*)pict name:(NSString*)name date:(NSString*)date;

@end
