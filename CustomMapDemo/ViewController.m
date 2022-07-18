//
//  ViewController.m
//  CustomMapDemo
//
//  Created by 雷俊博 on 2022/6/21.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface ViewController ()<MAMapViewDelegate> {
    NSMutableArray * _speedColors;
    CLLocationCoordinate2D * _runningCoords;
    NSUInteger _count;
    
    MAMultiPolyline * _polyline;
    
    NSMutableArray * _speedColors2;
    CLLocationCoordinate2D * _runningCoords2;
    NSUInteger _count2;
    MAMultiPolyline * _polyline2;
}

/// 地图
@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAMapView *hiddenMap;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView addOverlay:_polyline];
    
    const CGFloat screenEdgeInset = 20;
    UIEdgeInsets inset = UIEdgeInsetsMake(screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
    [self.mapView setVisibleMapRect:_polyline.boundingMapRect edgePadding:inset animated:NO];
}

#pragma mark - setupUI
- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //add view
    [self.view addSubview:self.hiddenMap];
    [self.view addSubview:self.mapView];
    
    self.mapView.frame = self.view.bounds;
    self.hiddenMap.frame = self.view.bounds;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"截图" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(snapClick) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 80, 80, 80);
    [self.view addSubview:btn];
}

#pragma mark - event response
- (void)snapClick
{
    
    [self init2Data];
    [self.hiddenMap addOverlay:_polyline2];
    
    const CGFloat screenEdgeInset = 20;
    UIEdgeInsets inset = UIEdgeInsetsMake(screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
    [self.hiddenMap setVisibleMapRect:_polyline2.boundingMapRect edgePadding:inset animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.hiddenMap takeSnapshotInRect:CGRectMake(0, (self.view.bounds.size.height - self.view.bounds.size.width) / 2.0, self.view.bounds.size.width, self.view.bounds.size.width) withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
            if (resultImage && state) {
                UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, nil);
            }
        }];
    });
    
}

#pragma mark - init data
- (UIColor *)getColorForSpeed:(float)speed
{
    const float lowSpeedTh = 2.f;
    const float highSpeedTh = 3.5f;
    const CGFloat warmHue = 0.02f; //偏暖色
    const CGFloat coldHue = 0.4f; //偏冷色
    
    float hue = coldHue - (speed - lowSpeedTh)*(coldHue - warmHue)/(highSpeedTh - lowSpeedTh);
    return [UIColor colorWithHue:hue saturation:1.f brightness:1.f alpha:1.f];
}

- (void)dealloc
{
    if (_runningCoords)
    {
        free(_runningCoords);
        _count = 0;
    }
    
    if (_runningCoords2) {
        free(_runningCoords2);
        _count2 = 0;
    }
}

- (void)initData
{
    _speedColors = [NSMutableArray array];
    
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"running_record" ofType:@"json"]];
    
    NSMutableArray * indexes = [NSMutableArray array];
    if (jsdata)
    {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
        
        _count = dataArray.count;
        _runningCoords = (CLLocationCoordinate2D *)malloc(_count * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0; i < _count; i++)
        {
            @autoreleasepool
            {
                NSDictionary * data = dataArray[i];
                _runningCoords[i].latitude = [data[@"latitude"] doubleValue];
                _runningCoords[i].longitude = [data[@"longtitude"] doubleValue];
                
                UIColor * speedColor = [self getColorForSpeed:[data[@"speed"] floatValue]];
                [_speedColors addObject:speedColor];
                
                [indexes addObject:@(i)];
            }
        }
    }
    
    _polyline = [MAMultiPolyline polylineWithCoordinates:_runningCoords count:_count drawStyleIndexes:indexes];
    
}

- (void)init2Data
{
    _speedColors2 = [NSMutableArray array];
    
    NSData *jsdata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"running_record" ofType:@"json"]];
    
    NSMutableArray * indexes = [NSMutableArray array];
    if (jsdata)
    {
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:jsdata options:NSJSONReadingAllowFragments error:nil];
        
        _count2 = dataArray.count;
        _runningCoords2 = (CLLocationCoordinate2D *)malloc(_count2 * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0; i < _count2; i++)
        {
            @autoreleasepool
            {
                NSDictionary * data = dataArray[i];
                _runningCoords2[i].latitude = [data[@"latitude"] doubleValue];
                _runningCoords2[i].longitude = [data[@"longtitude"] doubleValue];
                
                UIColor * speedColor = [self getColorForSpeed:[data[@"speed"] floatValue]];
                [_speedColors2 addObject:speedColor];
                
                [indexes addObject:@(i)];
            }
        }
    }
    
    _polyline2 = [MAMultiPolyline polylineWithCoordinates:_runningCoords2 count:_count2 drawStyleIndexes:indexes];
    
}

#pragma mark - action handle
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - mapview delegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
    
    polylineRenderer.lineWidth = 8.f;
    polylineRenderer.strokeColors = _speedColors;
    polylineRenderer.gradient = YES;
    
    return polylineRenderer;
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
        _mapView.delegate = self;
    }
    return _mapView;
}

- (MAMapView *)hiddenMap {
    if (!_hiddenMap) {
        MAMapView.metalEnabled = YES;
        _hiddenMap = [[MAMapView alloc] init];
        _hiddenMap.showsBuildings = NO;
        _hiddenMap.rotateCameraEnabled = NO;
        _hiddenMap.showsCompass = NO;
        _hiddenMap.showsScale = NO;
        _hiddenMap.showsUserLocation = NO;
        _hiddenMap.minZoomLevel = 3;
        _hiddenMap.zoomLevel = 15;
        _hiddenMap.delegate = self;
        _hiddenMap.hidden = YES;
    }
    return _hiddenMap;
}


@end
