//
//  ViewController.m
//  CustomMapDemo
//
//  Created by 雷俊博 on 2022/6/21.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface ViewController ()

/// 地图
@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

#pragma mark - setupUI
- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //add view
    [self.view addSubview:self.mapView];
    
    self.mapView.frame = self.view.bounds;
}

#pragma mark - getters

- (MAMapView *)mapView {
    if (!_mapView) {
        MAMapView.metalEnabled = YES;
        _mapView = [[MAMapView alloc] init];
        _mapView.showsBuildings = NO;
        _mapView.rotateCameraEnabled = NO;
        _mapView.showsCompass = NO;
        _mapView.showsScale = NO;
        _mapView.showsUserLocation = NO;
        _mapView.minZoomLevel = 3;
        _mapView.zoomLevel = 15;
        
        NSString *path = [NSString stringWithFormat:@"%@/running_detail_style.data", [NSBundle mainBundle].bundlePath];
        NSData *data = [NSData dataWithContentsOfFile:path];
        MAMapCustomStyleOptions *options = [[MAMapCustomStyleOptions alloc] init];
        options.styleData = data;
        [_mapView setCustomMapStyleOptions:options];
        [_mapView setCustomMapStyleEnabled:YES];
    }
    return _mapView;
}


@end
