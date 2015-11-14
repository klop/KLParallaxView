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
static CGFloat const kInitialZoomMultiplier = 1.5;
static CGFloat const kInitialParallaxOffsetDuringPick = 15.0;
static CGFloat const kInitialParallaxMultiplier = 2.0;
static CGFloat const kInitialShadowOpacity = 0.8;
static CGFloat const kInitialShadowRadius = 10.0;
static CGFloat const kFinalShadowRadius = 20.0;
static NSString *const kGlowImageName = @"gloweffect";

@interface KLParallaxView ()

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
        _parallaxMultiplier = kInitialParallaxMultiplier;
        _initialShadowRadius = kInitialShadowRadius;
        _finalShadowRadius = kFinalShadowRadius;
        _zoomMultiplier = kInitialZoomMultiplier;

        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowRadius = _initialShadowRadius;
        self.layer.shadowOpacity = kInitialShadowOpacity;
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
            frame.origin.x = -kInitialParallaxOffset * 3.0;
            frame.origin.y = -kInitialParallaxOffset * 3.0;
            frame.size.width += kInitialParallaxOffset * 6.0;
            frame.size.height += kInitialParallaxOffset * 6.0;
            subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    self.contentView.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.contentView.layer.cornerRadius;
}

#pragma mark - _shadowOpacity accessors

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    self.layer.shadowOpacity = shadowOpacity;
}

- (CGFloat)shadowOpacity
{
    return self.layer.shadowOpacity;
}

#pragma mark - _shadowColor accessors

- (void)setShadowColor:(UIColor *)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

#pragma mark - Shadow animations

- (void)createShadow
{
    CGSize shadowOffset = CGSizeMake(0.0, 30.0);
    [self addGroupAnimationWithShadowOffset:shadowOffset
                               shadowRadius:self.finalShadowRadius
                                   duration:0.1
                                      layer:self.layer];
}

- (void)removeShadow
{
    CGSize shadowOffset = CGSizeZero;
    [self addGroupAnimationWithShadowOffset:shadowOffset
                               shadowRadius:self.initialShadowRadius
                                   duration:0.3
                                      layer:self.layer];
}

- (void)addGroupAnimationWithShadowOffset:(CGSize)shadowOffset
                             shadowRadius:(CGFloat)shadowRadius
                                 duration:(NSTimeInterval)duration
                                    layer:(CALayer *)layer
{
    if (!CGSizeEqualToSize(layer.shadowOffset, shadowOffset) && layer.shadowRadius != shadowRadius) {
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

        [layer addAnimation:animationGroup forKey:@"shadowRadius"];
        layer.shadowRadius = shadowRadius;
        layer.shadowOffset = shadowOffset;
    }
}

#pragma mark - Parallax effect

- (void)parallaxEffectAtPoint:(CGPoint)point
{
    UIView *superview = self.superview;
    CGFloat offsetX = (0.5 - point.x / superview.bounds.size.width) * -1;
    CGFloat offsetY = (0.5 - point.y / superview.bounds.size.height) * -1;

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
        transform = CATransform3DScale(transform, 1.05, 1.05, 1.0);
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
                return 0.0;
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
    CATransform3D transform = CATransform3DIdentity;
    animation.fromValue = [NSValue valueWithCATransform3D:presentationLayer.transform];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.duration = 0.25;
    [self.layer addAnimation:animation forKey:@"transform"];
    self.layer.transform = transform;

    for (UIView *subview in self.contentView.subviews) {
        presentationLayer = (CALayer *)subview.layer.presentationLayer;
        animation.fromValue = [NSValue valueWithCATransform3D:presentationLayer.transform];
        [subview.layer addAnimation:animation forKey:@"transform"];
        subview.layer.transform = transform;
    }
}

#pragma mark - Start/stop animations

- (void)startAnimationsWithTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.superview];
    [self createShadow];
    [self parallaxEffectAtPoint:point];
}

- (void)endAnimations
{
    [self removeShadow];
    [self removeParallaxEffect];
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self startAnimationsWithTouch:[touches anyObject]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self startAnimationsWithTouch:[touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self endAnimations];
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