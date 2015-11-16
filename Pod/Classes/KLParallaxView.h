//
//  KLParallaxView.h
//  KLParallaxView
//
//  Created by Dara on 09/11/2015.
//  Copyright (c) 2015 Dara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KLParallaxView : UIView

/**
 *  The initializer for KLParallaxView.
 *
 *  @param frame    Frame of the view.
 *  @param subviews An array of views. The strength of the parallax effect on each view is determined by
 *  its tag property or position in the view hierachy if basedOnHierchy is YES.
 *
 *  @return An KLParallaxView instance.
 */
- (instancetype)initWithFrame:(CGRect)frame subviews:(NSArray *)subviews;

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat parallaxMultiplier;
@property (nonatomic) CGFloat zoomMultiplier;
@property (nonatomic) CGFloat initialShadowRadius;
@property (nonatomic) CGFloat finalShadowRadius;
@property (nonatomic) CGFloat shadowOpacity;
@property (nonatomic, getter=isBasedOnHierachy) BOOL basedOnHierachy;
@property (strong, nonatomic) UIColor *shadowColor;
@property (strong, nonatomic) UIColor *glowColor;
@property (nonatomic) BOOL glows;


@end
