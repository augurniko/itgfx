//
//  IGSimilarView.h
//  samuiEating
//
//  Created by Mac on 24/05/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGSimilarView : UIView

@property (nonatomic, strong) NSString   *similarPicture;
@property (nonatomic, strong) NSString   *similarTitle;
@property (nonatomic, strong) NSNumber   *similarStar;

- (void)setParameters:(NSString*)pict title:(NSString*)title star:(NSNumber*)star;

@end
