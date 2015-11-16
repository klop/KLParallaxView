//
//  KLViewController.m
//  KLParallaxView
//
//  Created by dara on 11/15/2015.
//  Copyright (c) 2015 dara. All rights reserved.
//

#import "KLViewController.h"
#import <KLParallaxView/KLParallaxView.h>

@interface KLViewController ()

@property (nonatomic) CGRect parallaxFrame;

@end

@implementation KLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.parallaxFrame = CGRectMake(0.0, 0.0, 300, 469); // This is a good size to fit the images
    [self setupSegmentedControl];
    [self addSpectreParallaxView];
}

- (NSArray *)loadSpectreResources
{
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"007"]];
    imageView1.tag = 34;

    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lea"]];
    imageView2.tag = 8;

    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"james"]];
    imageView3.tag = 11;

    UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spectrelogo"]];
    imageView4.tag = 18;

    NSMutableArray<UIImageView *> *imageViews = [@[ imageView1, imageView2, imageView3, imageView4 ] mutableCopy];

    for (UIImageView *imageView in imageViews) {
        imageView.frame = self.parallaxFrame;
    }

    imageViews.firstObject.frame = CGRectMake(-50, 0, 600, 469); // One of the images (007 backdrop) is a different size
    return [imageViews copy];
}

- (NSArray *)loadInterstellarResources
{
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1"]];
    imageView1.tag = 0;

    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2"]];
    imageView2.tag = 11;

    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3"]];
    imageView3.tag = 2;

    UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4"]];
    imageView4.tag = 4;

    UIImageView *imageView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"5"]];
    imageView5.tag = 13;

    NSMutableArray *imageViews = [@[ imageView1, imageView2, imageView3, imageView4, imageView5 ] mutableCopy];

    for (UIImageView *imageView in imageViews) {
        imageView.frame = self.parallaxFrame;
    }

    return [imageViews copy];
}

- (void)setupSegmentedControl
{
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Spectre", @"Interstellar" ]];
    segmentedControl.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 20);
    [segmentedControl addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}

- (void)addSpectreParallaxView
{

    NSArray *subviews = [self loadSpectreResources];
    [self addParallaxViewWithSubviews:subviews];
}

- (void)addInterstellarParallaxView
{
    NSArray *subviews = [self loadInterstellarResources];
    [self addParallaxViewWithSubviews:subviews];
}

- (void)addParallaxViewWithSubviews:(NSArray *)subviews
{
    [self clearParallaxViews];
    KLParallaxView *parallaxView = [[KLParallaxView alloc] initWithFrame:self.parallaxFrame subviews:subviews];
    parallaxView.cornerRadius = 5.0;
    parallaxView.layer.zPosition = 100.0;
    parallaxView.backgroundColor = [UIColor whiteColor];
    parallaxView.center = self.view.center;
    [self.view addSubview:parallaxView];
}

- (void)clearParallaxViews
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[KLParallaxView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)segmentDidChange:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self addSpectreParallaxView];
            break;

        case 1:
            [self addInterstellarParallaxView];
            break;
    }
}

@end
