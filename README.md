# KLParallaxView

KLParallaxView is an Objective-C `UIView` subclass that imitates [Apple TV's parallax effect](https://www.youtube.com/watch?v=Py21jv6kCnI), based on the [MPParallaxView](https://github.com/DroidsOnRoids/MPParallaxView) Swift implementation.

![KLParallaxView](http://i.imgur.com/W6uH4Bt.gif)

## Usage

```Objective-C

#import "ViewController.h"
#import "KLParallaxView.h"

@interface ViewController ()

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSArray<UIImageView *> *interstellar;
@property (strong, nonatomic) NSArray<UIImageView *> *spectre;
@property (nonatomic) CGRect parallaxFrame;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1"]];
    imageView1.tag = 0;
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2"]];
    imageView2.tag = 11;
    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3"]];
    imageView3.tag = 2;
    NSArray *subviews = @[ imageView1, imageView2, imageView3 ];
    
    KLParallaxView *parallaxView = [[KLParallaxView alloc] initWithFrame:self.view.bounds subviews:subviews];
    [self.view addSubview:parallaxView];
  }
