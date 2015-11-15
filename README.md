# KLParallaxView

`KLParallaxView` is an Objective-C `UIView` subclass that imitates [Apple TV's parallax effect](https://www.youtube.com/watch?v=Py21jv6kCnI), based on the [MPParallaxView](https://github.com/DroidsOnRoids/MPParallaxView) Swift implementation.

![KLParallaxView](http://i.imgur.com/W6uH4Bt.gif)

## Usage

`KLParallaxView` is initialized with an array of subviews whose ordering reflects their positioning in a view hierachy i.e. `firstObject` is the bottommost view while `lastObject` is the topmost. By default, `KLParallaxView` controls each subview's movement during the parallax effect by the value of their `tag` property.

```Objective-C

#import "ViewController.h"
#import "KLParallaxView.h"

@interface ViewController ()

@property (strong, nonatomic) KLParallaxView *parallaxView;

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
    
    self.parallaxView = [[KLParallaxView alloc] initWithFrame:self.view.bounds subviews:subviews];
    [self.view addSubview:parallaxView];
}
```

## Configuration

### Parallax settings

Use the subviews' positions in the view hierachy rather than their `tag` property.
```Objective-C
self.parallaxView.basedOnHierachy = YES;
```
Multiply the parallax effect on all views by a given factor.
```Objective-C
self.parallaxView.parallaxMultiplier = YES;
```
Multiply the zoom effect on all views by a given factor.
```Objective-C
self.parallaxView.zoomMultiplier = YES;
```
### Glow settings

Toggle the glowing effect that follows touches.
```Objective-C
self.parallaxView.glows = NO;
```
Change the glow's color.
```Objective-C
self.parallaxView.glowColor = [UIColor aqua];
```
### Shadow settings

Change the shadow opacity.
```Objective-C
self.parallaxView.shadowOpacity = 0.3;
```
Change the shadow radius for when the view is not animating.
```Objective-C
self.parallaxView.initalShadowRadius = 3.5;
```
Change the shadow radius for when the view is animating.
```Objective-C
self.parallaxView.finalShadowRadius = 9.5;
```
Change the color of the shadow.
```Objective-C
self.parallaxView.shadowColor = [UIColor cerulean];
```
### Other

Set the view's corner radius.
```Objective-C
self.parallaxView.cornerRadius = 5.0;
```
