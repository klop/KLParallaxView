//
//  KLParallaxView.h
//  KLParallaxView
//
//  Created by Dara on 09/11/2015.
//  Copyright (c) 2015 Dara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KLParallaxViewType){
    KLParallaxViewTypeHierachy,
    KLParallaxViewTypeTag,
    KLParallaxViewTypeIntensityValue,
};

@interface KLParallaxView : UIView

/**
 *  The designated initializer for KLParallaxView.
 *
 *  @param frame    Frame of the view.
 *  @param subviews An array of views. The strength of the parallax effect on each view is determined by
 *  its parallaxIntensity, its position in the view hierachy, or its tag, depending on the parallax view type.
 *
 *  @return An KLParallaxView instance.
 */
- (instancetype)initWithFrame:(CGRect)frame subviews:(NSArray *)subviews;

@property (nonatomic) KLParallaxViewType parallaxType;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat parallaxMultiplier;
@property (nonatomic) CGFloat zoomMultiplier;
@property (nonatomic) CGFloat initialShadowRadius;
@property (nonatomic) CGFloat finalShadowRadius;
@property (nonatomic) CGFloat shadowOpacity;

@end

@interface UIView (KLParallaxView)

@property (nonatomic) CGFloat parallaxIntensity;

@end
