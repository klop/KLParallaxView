//
//  KLParallaxView.m
//  KLParallaxView
//
//  Created by Dara on 09/11/2015.
//  Copyright (c) 2015 Dara. All rights reserved.
//

#import "KLParallaxView.h"

static CGFloat const kInitialParallaxOffset = 15.0;
static CGFloat const kInitialZoomMultiplier = 1.05;
static CGFloat const kInitialParallaxOffsetDuringPick = 15.0;
static CGFloat const kInitialParallaxMultiplier = 1.0;
static CGFloat const kInitialShadowOpacity = 0.8;
static CGFloat const kInitialShadowRadius = 10.0;
static CGFloat const kFinalShadowRadius = 20.0;
static NSString *const kGlowImageName = @"gloweffect";

@interface KLParallaxView ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *glowEffect;

@end

@implementation KLParallaxView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame subviews:(NSArray *)subviews
{
    if ((self = [super initWithFrame:frame])) {
        _contentView = [UIView new];
        _parallaxMultiplier = kInitialParallaxMultiplier;
        _initialShadowRadius = kInitialShadowRadius;
        _finalShadowRadius = kFinalShadowRadius;
        _zoomMultiplier = kInitialZoomMultiplier;
        _basedOnHierachy = NO;
        _glows = YES;

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

        _contentView.frame = frame;
        _contentView.layer.masksToBounds = YES;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.translatesAutoresizingMaskIntoConstraints = YES;

        for (UIView *subview in subviews) {
            CGRect frame = subview.frame;
            frame.origin.x -= kInitialParallaxOffset;
            frame.origin.y -= kInitialParallaxOffset;
            frame.size.width += kInitialParallaxOffset * 2.0;
            frame.size.height += kInitialParallaxOffset * 2.0;
            subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            subview.translatesAutoresizingMaskIntoConstraints = YES;
            subview.frame = frame;
            [_contentView addSubview:subview];
        }

        NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:nil ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        UIImage *glowImage = [UIImage imageNamed:kGlowImageName inBundle:bundle compatibleWithTraitCollection:nil];
        _glowEffect = [[UIImageView alloc] initWithImage:glowImage];
        _glowEffect.image = [_glowEffect.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _glowEffect.tintColor = [UIColor whiteColor];
        _glowEffect.alpha = 0.0;
        _glowEffect.layer.zPosition = MAXFLOAT;
        [_contentView addSubview:_glowEffect];

        [self addSubview:_contentView];
    }
    return self;
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
        transform = CATransform3DScale(transform, self.zoomMultiplier, self.zoomMultiplier, 1.0);
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
    CGFloat secondaryMultiplier = 2.0;
    if (!self.basedOnHierachy) {
        return (CGFloat)view.tag * secondaryMultiplier * self.parallaxMultiplier;
    } else {
        CGFloat index = [view.superview.subviews indexOfObject:view];
        return index * secondaryMultiplier * self.parallaxMultiplier;
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

#pragma mark - Glow effect

- (void)glowEffectAtPoint:(CGPoint)point
{
    CGFloat delta = 0.05;
    if (point.y > self.bounds.size.height / 2) {
        self.glowEffect.center = point;
        [self applyGlowAlpha:self.glowEffect.alpha + delta];
    } else {
        [self applyGlowAlpha:self.glowEffect.alpha - delta];
    }
}

- (void)applyGlowAlpha:(CGFloat)alpha
{
    if (alpha < 1.0 && alpha > 0.0) {
        self.glowEffect.alpha = alpha;
    }
}

#pragma mark - Start/stop animations

- (void)startAnimationsWithTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.superview];
    [self createShadow];
    [self parallaxEffectAtPoint:point];
    if (self.glows) [self glowEffectAtPoint:point];
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

#pragma mark - backgroundColor accessors

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.contentView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor
{
    return self.contentView.backgroundColor;
}

#pragma mark - cornerRadius accessors

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.contentView.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.contentView.layer.cornerRadius;
}

#pragma mark - shadowOpacity accessors

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    self.layer.shadowOpacity = shadowOpacity;
}

- (CGFloat)shadowOpacity
{
    return self.layer.shadowOpacity;
}

#pragma mark - shadowColor accessors

- (void)setShadowColor:(UIColor *)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

#pragma mark - glowColor accessors

- (void)setGlowColor:(UIColor *)glowColor
{
    self.glowEffect.tintColor = glowColor;
}

- (UIColor *)glowColor
{
    return self.glowEffect.tintColor;
}

#pragma mark - glows accessors

- (void)setGlows:(BOOL)glows
{
    _glows = glows;
    self.glowEffect.hidden = !glows;
}

@end