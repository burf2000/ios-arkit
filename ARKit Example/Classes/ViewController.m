//
//  ViewController.m
//  ARKit Example
//
//  Created by Carlos on 21/10/13.
//
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad
{
    selectedIndex = -1;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:51.145981 longitude:-0.971460];
    ARGeoCoordinate *a = [ARGeoCoordinate coordinateWithLocation:location];
    a.dataObject = @"ALTON";

    location = [[CLLocation alloc] initWithLatitude:51.259251 longitude:-1.089974];
    ARGeoCoordinate *b = [ARGeoCoordinate coordinateWithLocation:location];
    b.dataObject = @"Basingstoke";
    
    location = [[CLLocation alloc] initWithLatitude:51.215831 longitude:-0.799694];
    ARGeoCoordinate *c = [ARGeoCoordinate coordinateWithLocation:location];
    c.dataObject = @"Farnham";
    
    location = [[CLLocation alloc] initWithLatitude:51.008030 longitude:-0.936921];
    ARGeoCoordinate *d = [ARGeoCoordinate coordinateWithLocation:location];
    d.dataObject = @"Peterfield";
    
    
    points = @[a,b,c,d];
}

- (IBAction)showAR:(id)sender
{
    ARKitConfig *config = [ARKitConfig defaultConfigFor:self];
    config.orientation = self.interfaceOrientation;
    
    CGSize s = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        config.radarPoint = CGPointMake(s.width - 50, 50);
        //config.radarPoint = CGPointMake(s.width - 50, s.height - 50);
    } else
    {
        config.radarPoint = CGPointMake(50, s.width - 50);
        //config.radarPoint = CGPointMake(s.height - 50, s.width - 50);
    }
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [closeBtn sizeToFit];
    [closeBtn addTarget:self action:@selector(closeAr) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.center = CGPointMake(50, 50);
    
    engine = [[ARKitEngine alloc] initWithConfig:config];
    
    [engine addCoordinates:points];
    [engine addExtraView:closeBtn];
    [engine addExtraView:self.slider];
    [engine startListening];
    
    engine.MAX_DISTANCE = self.slider.value  * 1000;
}

- (void) closeAr
{
    [engine hide];
}

- (IBAction)sliderChanged
{
    engine.MAX_DISTANCE = self.slider.value  * 1000;
}

#pragma mark - ARViewDelegate protocol Methods

- (ARObjectView *)viewForCoordinate:(ARGeoCoordinate *)coordinate floorLooking:(BOOL)floorLooking
{
    NSString *text = (NSString *)coordinate.dataObject;
    
    ARObjectView *view = nil;
    
    if (floorLooking)
    {
        UIImage *arrowImg = [UIImage imageNamed:@"arrow.png"];
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImg];
        view = [[ARObjectView alloc] initWithFrame:arrowView.bounds];
        [view addSubview:arrowView];
        view.displayed = NO;
    }
    else
    {
        UIImageView *boxView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box.png"]];
        boxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
       
        view = [[ARObjectView alloc] initWithFrame:boxView.frame];
        [view addSubview:boxView];
        
        view.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 16, boxView.frame.size.width - 8, 20)];
        view.nameLabel.font = [UIFont systemFontOfSize:17];
        view.nameLabel.minimumFontSize = 2;
        view.nameLabel.backgroundColor = [UIColor clearColor];
        view.nameLabel.textColor = [UIColor whiteColor];
        view.nameLabel.textAlignment = NSTextAlignmentCenter;
        view.nameLabel.text = text;
        view.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        [view addSubview:view.nameLabel];
        
        view.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 50, boxView.frame.size.width - 8, 20)];
        view.distanceLabel.font = [UIFont systemFontOfSize:17];
        view.distanceLabel.minimumFontSize = 2;
        view.distanceLabel.backgroundColor = [UIColor clearColor];
        view.distanceLabel.textColor = [UIColor whiteColor];
        view.distanceLabel.textAlignment = NSTextAlignmentCenter;
        view.distanceLabel.text = text;
        view.distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        [view addSubview:view.distanceLabel];
    }
    
    [view sizeToFit];
    return view;
}

- (void) itemTouchedWithIndex:(NSInteger)index
{
    selectedIndex = index;
    NSString *name = (NSString *)[engine dataObjectWithIndex:index];
    currentDetailView = [[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:nil options:nil][0];
    currentDetailView.nameLbl.text = name;
    [engine addExtraView:currentDetailView];
}

- (void) didChangeLooking:(BOOL)floorLooking
{
    if (floorLooking) {
        if (selectedIndex != -1) {
            [currentDetailView removeFromSuperview];
            ARObjectView *floorView = [engine floorViewWithIndex:selectedIndex];
            floorView.displayed = YES;
        }
    } else {
        if (selectedIndex != -1) {
            ARObjectView *floorView = [engine floorViewWithIndex:selectedIndex];
            floorView.displayed = NO;
            selectedIndex = -1;
        }
    }
}

@end
