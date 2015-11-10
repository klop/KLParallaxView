//
//  KLParallaxView.h
//  KLParallaxView
//
//  Created by Dara on 09/11/2015.
//  Copyright (c) 2015 Dara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KLParallaxViewState) {
    KLParallaxViewStateInitial,
    KLParallaxViewStatePick,
    KLParallaxViewStatePutDown
};

typedef NS_ENUM(NSInteger, KLParallaxViewType) {
    KLParallaxViewTypeHierachy,
    KLParallaxViewTypeTag,
    KlParallaxViewTypeCustom
};

@interface KLParallaxView : UIView

/**
 *  The designated initializer for KLParallaxView.
 *
 *  @param frame    <#frame description#>
 *  @param subviews <#subviews description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame subviews:(NSArray *)subviews;

@end

@interface UIView (KLParallaxView)

@property (nonatomic) CGFloat parallaxIntensity;

@end
