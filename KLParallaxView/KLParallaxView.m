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
static CGFloat const kInitialParallaxMultiplier = 1.0;
static CGFloat const kInitialShadowRadius = 10.0;
static CGFloat const kFinalShadowRadius = 20.0;
static NSString *const kGlowImageName = @"gloweffect";

@interface KLParallaxView ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *glowEffect;
@property (nonatomic, getter=isZoomed) BOOL zoomed;

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
        _zoomed = NO;
        _parallaxMultiplier = kInitialParallaxMultiplier;
        _initialShadowRadius = kInitialShadowRadius;
        _finalShadowRadius = kFinalShadowRadius;

        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowRadius = _initialShadowRadius;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowColor = [UIColor blackColor].CGColor;

        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(4, CGRectGetHeight(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 4,
                                         CGRectGetHeight(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 4, 20)];
        [path addLineToPoint:CGPointMake(4, 20)];
        [path closePath];
        self.layer.shadowPath = path.CGPath;

        _contentView.frame = self.bounds;
        _contentView.layer.masksToBounds = YES;

        for (UIView *subview in subviews) {
            subview.frame = self.bounds;
            CGRect frame = subview.frame;
            frame.origin.x = -kInitialParallaxOffset * 2.5;
            frame.origin.y = -kInitialParallaxOffset * 2.5;
            frame.size.width += kInitialParallaxOffset * 5.0;
            frame.size.height += kInitialParallaxOffset * 5.0;
            subview.translatesAutoresizingMaskIntoConstraints = YES;
            subview.frame = frame;
            [_contentView addSubview:subview];
        }

        UIImage *glow = [UIImage imageNamed:kGlowImageName];
        if (glow) {
            _glowEffect.image = glow;
            _glowEffect.alpha = 0.0;
            [_contentView addSubview:_glowEffect];
        }

        [self addSubview:_contentView];
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

- (void)setZoomed:(BOOL)zoomed
{
    if (_zoomed != zoomed) _zoomed = zoomed;
}

#pragma mark - Pick/put animations

- (void)animatePick
{
    [self createShadow];
    if (!self.isZoomed) [self makeZoomInEffect];
    self.zoomed = YES;
}

- (void)animatePutDown
{
    [self removeShadow];
    if (self.isZoomed) [self makeZoomOutEffect];
    self.zoomed = NO;
}

#pragma mark - Shadow animations

- (void)createShadow
{
    CGSize shadowOffset = CGSizeMake(0.0, 30.0);
    CGFloat shadowRadius = 20.0;
    [self addGroupAnimationWithShadowOffset:shadowOffset
                               shadowRadius:shadowRadius
                                   duration:0.1
                                      layer:self.layer];
}

- (void)removeShadow
{
    CGSize shadowOffset = CGSizeZero;
    [self addGroupAnimationWithShadowOffset:shadowOffset
                               shadowRadius:kInitialShadowRadius
                                   duration:0.3
                                      layer:self.layer];
}

- (void)addGroupAnimationWithShadowOffset:(CGSize)shadowOffset
                             shadowRadius:(CGFloat)shadowRadius
                                 duration:(NSTimeInterval)duration
                                    layer:(CALayer *)layer
{
    CALayer *presentationLayer = (CALayer *)layer.presentationLayer;
    CABasicAnimation *offsetAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    offsetAnimation.fromValue = [NSValue valueWithCGSize:presentationLayer.shadowOffset];
    offsetAnimation.toValue = [NSValue valueWithCGSize:shadowOffset];

    CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    radiusAnimation.fromValue = [NSNumber numberWithFloat:presentationLayer.shadowRadius];
    radiusAnimation.toValue = [NSNumber numberWithFloat:shadowRadius];

    CAAnimationGroup *animationGroup = [CAAnimationGroup new];
    animationGroup.duration = duration;
    animationGroup.animations = @[ offsetAnimation, radiusAnimation ];

    [layer addAnimation:animationGroup forKey:@"shadowKey"];
    layer.shadowRadius = shadowRadius;
    layer.shadowOffset = shadowOffset;
}

#pragma mark - Zoom effect

- (void)makeZoomInEffect
{
    [UIView animateWithDuration:0.05 animations:^{
        for (UIView *subview in self.contentView.subviews) {
            CGFloat widthZoom = [self widthZoomForView:subview];
            CGFloat heightZoom = [self heightZoomForView:subview];
            subview.center = CGPointMake(subview.center.x - widthZoom,
                                         subview.center.y - heightZoom);
            CGRect frame = subview.frame;
            frame.size = CGSizeMake(frame.size.width + widthZoom * 2,
                                    frame.size.height + heightZoom * 2);
            subview.frame = frame;
        }

    }];
}

- (void)makeZoomOutEffect
{
    [UIView animateWithDuration:0.1 animations:^{
        for (UIView *subview in self.contentView.subviews) {
            CGFloat widthZoom = [self widthZoomForView:subview];
            CGFloat heightZoom = [self heightZoomForView:subview];
            subview.center = CGPointMake(subview.center.x + widthZoom,
                                         subview.center.y + heightZoom);

            CGRect frame = subview.frame;
            frame.size = CGSizeMake(frame.size.width - widthZoom * 2,
                                    frame.size.height - heightZoom * 2);
            subview.frame = frame;
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

#pragma mark - Parallax effect

- (void)parallaxEffectFromTouch:(UITouch *)touch
{
    UIView *superview = self.superview;
    CGPoint location = [touch locationInView:superview];

    CGFloat offsetX = (0.5 - location.x / superview.bounds.size.width) * -1;
    CGFloat offsetY = (0.5 - location.y / superview.bounds.size.height) * -1;

    CATransform3D transform = CATransform3DMakeScale(1.1, 1.1, 1.1);
    transform.m34 = 1.0/-500;

    CGFloat radiansPerDegree = M_PI / 180.0;

    CGFloat xAngle = (offsetX * kInitialParallaxOffsetDuringPick) * radiansPerDegree;
    CGFloat yAngle = (offsetY * kInitialParallaxOffsetDuringPick) * radiansPerDegree;


    transform = CATransform3DRotate(transform, xAngle, 0, -(0.5 - offsetY), 0);
    transform = CATransform3DRotate(transform, yAngle, (0.5 - offsetY) * 2, 0, 0);

    CALayer *presentationLayer = (CALayer *)self.layer.presentationLayer;
    CGFloat currentScale = [[presentationLayer valueForKeyPath: @"transform.scale"] floatValue];

    if (currentScale < 1.1) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:presentationLayer.transform];
        animation.toValue = [NSValue valueWithCATransform3D:transform];
        animation.duration = 0.1;
        [self.layer addAnimation:animation forKey:@"transform"];
    }

    self.layer.transform = transform;
    [self parallaxSubviewsForOffset:CGPointMake(offsetX, offsetY)];
}

- (void)parallaxSubviewsForOffset:(CGPoint)offset
{
    CGFloat parallaxOffset;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    for (UIView *subview in self.contentView.subviews) {
        parallaxOffset = [self parallaxOffsetForView:subview];
        CGFloat xParallaxOffsetAndSuperviewOffset = offset.x * parallaxOffset;
        CGFloat yParallaxOffsetAndSuperviewOffset = offset.y * parallaxOffset;
        CATransform3D transform = CATransform3DMakeTranslation(xParallaxOffsetAndSuperviewOffset,
                                                               yParallaxOffsetAndSuperviewOffset,
                                                               0);

        CALayer *presentationLayer = (CALayer *)subview.layer;
        animation.fromValue = [NSValue valueWithCATransform3D:presentationLayer.transform];
        animation.toValue = [NSValue valueWithCATransform3D:transform];
        animation.duration = 0.05;
        [subview.layer addAnimation:animation forKey:@"transform"];
        subview.layer.transform = transform;
    }
}

- (CGFloat)parallaxOffsetForView:(UIView *)view
{
    switch (self.parallaxType) {
        case KLParallaxViewTypeHierachy: {
            if (view.superview.subviews.count) {
                CGFloat index = [view.superview.subviews indexOfObject:view];
                return index * self.parallaxMultiplier;
            } else {
                return 5.0;
            }
            break;
        }

        case KLParallaxViewTypeTag:
            return (CGFloat)view.tag * self.parallaxMultiplier;
            break;

        case KLParallaxViewTypeIntensityValue:
            return view.parallaxIntensity * self.parallaxMultiplier;
            break;

        default:
            return 0.0;
            break;
    }
}

- (void)removeParallaxEffect
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CALayer *presentationLayer = (CALayer *)self.layer.presentationLayer;
    animation.fromValue = [NSValue valueWithCATransform3D:presentationLayer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.duration = 0.25;
    [self.layer addAnimation:animation forKey:@"transform"];
    self.layer.transform = CATransform3DIdentity;

        [UIView animateWithDuration:0.5 animations:^{
            for (UIView *subview in self.contentView.subviews) {
                subview.layer.transform = CATransform3DIdentity;
            }
        }];
}

#pragma mark - Touch handling

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self animatePick];
    [self parallaxEffectFromTouch:[touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self animatePutDown];
    [self removeParallaxEffect];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self animatePick];
    [self parallaxEffectFromTouch:[touches anyObject]];
}

@end

#pragma mark - UIImageView+KLParallaxView category

@implementation UIView (KLParallaxView)

- (void)setParallaxIntensity:(CGFloat)parallaxIntensity
{
    objc_setAssociatedObject(self, @selector(parallaxIntensity),
                             [NSNumber numberWithFloat:parallaxIntensity],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)parallaxIntensity
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(parallaxIntensity));
    if (!number) {
        number = [NSNumber numberWithFloat:0];
        objc_setAssociatedObject(self, @selector(parallaxIntensity),
                                 number,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [number floatValue];
}

@end