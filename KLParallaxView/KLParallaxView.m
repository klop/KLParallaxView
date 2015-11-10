//
//  KLParallaxView.m
//  KLParallaxView
//
//  Created by Dara on 09/11/2015.
//  Copyright (c) 2015 Dara. All rights reserved.
//

#import "KLParallaxView.h"

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

@synthesize cornerRadius = _cornerRadius;

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _cornerRadius = self.layer.cornerRadius;
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
    _cornerRadius = cornerRadius;
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

}


@end
