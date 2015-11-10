//
//  KLParallaxView.m
//  KLParallaxView
//
//  Created by Dara on 09/11/2015.
//  Copyright (c) 2015 Dara. All rights reserved.
//

#import "KLParallaxView.h"
#import <objc/runtime.h>

static CGFloat const kInitialParallaxOffset = 5.0;
static CGFloat const kInitialZoomMultiplier = 0.02;
static CGFloat const kInitialParallaxOffsetDuringPick = 15.0;
static CGFloat const kInitialMultiplierOfIndexHieracyToParallaxOffset = 7.0;
static CGFloat const kInitialShadowRadius = 10.0;
static NSString *const kGlowImageName = @"gloweffect";

@interface KLParallaxView ()

@property (nonatomic) KLParallaxViewState parallaxState;
@property (nonatomic) KLParallaxViewType parallaxType;
@property (nonatomic) CGFloat cornerRadius;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *glowEffect;

@end

@implementation KLParallaxView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame subviews:nil];
}

- (instancetype)initWithFrame:(CGRect)frame subviews:(NSArray *)subviews
{
    if ((self = [super initWithFrame:frame])) {
        _contentView = [UIView new];
        _glowEffect = [UIImageView new];
        _parallaxType = KLParallaxViewTypeTag;
        _parallaxState = KLParallaxViewStateInitial;

        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowRadius = kInitialShadowRadius;
        self.layer.shadowOpacity = 0.6;
        self.layer.shadowColor = [UIColor blackColor].CGColor;

        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(4, CGRectGetHeight(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 4, CGRectGetWidth(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 4, 20)];
        [path addLineToPoint:CGPointMake(4, 20)];
        [path closePath];
        self.layer.shadowPath = path.CGPath;

        _contentView.frame = self.bounds;
        _contentView.layer.masksToBounds = YES;

        for (UIView *subview in self.subviews) {
            subview.translatesAutoresizingMaskIntoConstraints = YES;
            [subview removeFromSuperview];
            // need to make a cgrect here then set it to frame.
            CGRect frame = subview.frame;
            frame.origin.x = -kInitialParallaxOffset;
            frame.origin.y = -kInitialParallaxOffset;
            frame.size.width += kInitialParallaxOffset * 2.0;
            frame.size.height += kInitialParallaxOffset * 2.0;
            [_contentView addSubview:subview];
        }
        UIImage *glow = [UIImage imageNamed:kGlowImageName];
        if (glow) {
            _glowEffect.image = glow;
            _glowEffect.alpha = 0.0;
            [_contentView addSubview:_glowEffect];
        }
    }
    return self;
}

#pragma mark - _cornerRadius accessors

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.contentView.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.contentView.layer.cornerRadius;
}

#pragma mark _parallaxState accessors

- (void)setParallaxState:(KLParallaxViewState)parallaxState
{
    if (parallaxState != _parallaxState) [self animateForGivenState:parallaxState];
    _parallaxState = parallaxState;
}

#pragma mark

- (void)animateForGivenState:(KLParallaxViewState)state
{
    switch (state) {
        case KLParallaxViewStatePick:
            [self animatePick];
            break;

        case KLParallaxViewStatePutDown:
            [self animatePutDown];
            break;

        case KLParallaxViewStateInitial:
            break;

        default:
            break;
    }
}

- (void)animatePick
{
    [self.layer addAnimation:[self pickAnimation] forKey:nil];
    [self makeZoomInEffect];
}

- (void)animatePutDown
{
    [self.layer addAnimation:[self putDownAnimation] forKey:nil];
    [self makeZoomOutEffect];
}

- (CAAnimationGroup *)pickAnimation
{
    return [self groupAnimationWithShadowOffset:CGSizeMake(0.0, 30.0)
                                   shadowRadius:20.0
                                       duration:0.02];

}

- (CAAnimationGroup *)putDownAnimation
{
    return [self groupAnimationWithShadowOffset:CGSizeMake(0.0, 0.0)
                                   shadowRadius:kInitialShadowRadius
                                       duration:0.4];
}

- (CAAnimationGroup *)groupAnimationWithShadowOffset:(CGSize)shadowOffset
                                        shadowRadius:(CGFloat)shadowRadius
                                            duration:(NSTimeInterval)duration
{
    CABasicAnimation *offsetAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    offsetAnimation.toValue = [NSValue valueWithCGSize:shadowOffset];

    CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    radiusAnimation.toValue = [NSNumber numberWithFloat:shadowRadius];

    CAAnimationGroup *animationGroup = [CAAnimationGroup new];
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = false;
    animationGroup.duration = duration;
    animationGroup.animations = @[ offsetAnimation, radiusAnimation ];

    return animationGroup;
}

- (void)makeZoomInEffect
{
    for (UIView *subview in self.contentView.subviews) {
        CGFloat widthZoom = [self widthZoomForView:subview];
        CGFloat heightZoom = [self heightZoomForView:subview];
        subview.center = CGPointMake(subview.center.x - widthZoom, subview.center.y - heightZoom);

        CGRect frame = subview.frame;
        frame.size = CGSizeMake(frame.size.width + widthZoom * 2, frame.size.height + heightZoom * 2);
        subview.frame = frame;
    }
}

- (void)makeZoomOutEffect
{
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *subview in self.contentView.subviews) {
            CGFloat widthZoom = [self widthZoomForView:subview];
            CGFloat heightZoom = [self heightZoomForView:subview];
            subview.center = CGPointMake(subview.center.x + widthZoom, subview.center.y + heightZoom);

            CGRect frame = subview.frame;
            frame.size = CGSizeMake(frame.size.width - widthZoom * 2, frame.size.height - heightZoom * 2);
        }
    }];
}

#pragma mark - Zoom calculations

- (CGFloat)heightZoomForView:(UIView *)view
{
    return view.bounds.size.height * kInitialZoomMultiplier;
}

- (CGFloat)widthZoomForView:(UIView *)view
{
    return view.bounds.size.width * kInitialZoomMultiplier;
}

@end

#pragma mark - UIView+KLParallaxView category

@implementation UIView (KLParallaxView)

- (void)setParallaxIntensity:(CGFloat)parallaxIntensity
{
    objc_setAssociatedObject(self, @selector(parallaxIntensity), [NSNumber numberWithFloat:parallaxIntensity], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)parallaxIntensity
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(parallaxIntensity));
    return [number floatValue];
}


@end
