#import "ViewController.h"
#import "CMSFileDownloadMeta.h"
#import "CMSTrackable.h"
#import "Reachability.h"
#import "CMSContentManagement.h"
#import "SMImageTrackable.h"
#import "Base64.h"
#import "AJViewController.h"
@interface ViewController()

@property (nonatomic, strong) NSDictionary *contentDictionary;
@property (nonatomic, strong) NSArray *arrTrackableArray;
@property (nonatomic, strong) CMSContentManagement *appContent;

@property (nonatomic, weak) IBOutlet UILabel *downloadLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *downloadProgressView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (nonatomic, weak) IBOutlet UIView *loadingSplashScreen;
@property (nonatomic, weak) IBOutlet UILabel *trackableTextLabel;
@property (nonatomic, weak) IBOutlet UIView *downloadInfoView;
@property(nonatomic, strong)ARCameraView *myCameraView;
@property(nonatomic, strong)UIButton *btn;
@property(nonatomic, assign)BOOL isFirst;
@end

@implementation ViewController

#pragma mark - Setup
/// Sets up content to be displayed by the ARCameraViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.myCameraView) {
        self.cameraView = self.myCameraView;
        [self.view addSubview:self.cameraView];
        [self.view addSubview:self.btn];
        
    }
}



-(void)btnClick
{
    
    AJViewController *VC = [AJViewController new];
    [self.navigationController pushViewController:VC animated:YES];
}






- (void)setupContent
{
    
    self.appContent = [CMSContentManagement new];
    self.appContent.downloadTask = [CMSNetworking new];
    self.appContent.downloadTask.progressDelegate = self;
    
    self.contentDictionary = [self.appContent getTrackables];
    self.arrTrackableArray = self.contentDictionary[@"Trackables"];
    
    [self setDownloadProgressHidden];
    
    if (![self.contentDictionary[@"InternetConncection"] boolValue]) {
        [self showLackOfConnectivityAlert];
    }
    
    [self setupTrackers];
    [self setLoadingProgressHidden];
    self.myCameraView = self.cameraView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //测试按钮
        if (!self.btn) {
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(100, 100, 100, 100);
            btn.backgroundColor = [UIColor redColor];
            [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview: btn];
            self.btn = btn;
        }
       
        
        
    });
}

#pragma mark - AR
/// Adds trackables to the tracker manager
- (void)setupTrackers
{
    ARImageTrackerManager *trackerManager = [ARImageTrackerManager getInstance];
    [trackerManager initialise];
    
    for (CMSTrackable *trackable in self.arrTrackableArray) {
        if (trackable.augmentationComplete && trackable.markerComplete) {
            [self setupTrackableSet:trackable];
        }
    }
}

- (void)setupTrackableSet:(CMSTrackable *)cmsTrackable
{
    ARImageTrackerManager *trackerManager = [ARImageTrackerManager getInstance];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cmsTrackable.markerFilePath] ||
        ![[NSFileManager defaultManager] fileExistsAtPath:cmsTrackable.augmentationFilePath]) {
        NSLog(@"Local files have been removed");
    }
    else {
        //cmsTrackable.markerFilePath
       
        ARImageTrackableSet *trackableSet = [[ARImageTrackableSet alloc] initWithPath:cmsTrackable.markerFilePath];
         NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        for (ARImageTrackable *trackable in trackableSet.trackables) {

//            NSInteger max = [trackable.name length];
//            char *nbytes = malloc(max + 1);
//            for (int i = 0; i < max; i++)
//            {
//                unichar ch = [trackable.name  characterAtIndex: i];
//                nbytes[i] = (char) ch;
//            }
//            nbytes[max] = '\0';
//            NSString *result=[NSString stringWithCString: nbytes
//                                      encoding: NSUTF8StringEncoding];
         
            
            NSLog(@"识别的名字%@",trackable.name);
            
            if ([cmsTrackable.augmentationType isEqualToString:@"video"]) {
                ARVideoNode *videoNode = [[ARVideoNode alloc] initWithBundledFile:cmsTrackable.augmentationFilePath];
                
                [trackable.world addChild:videoNode];
                [videoNode rotateByDegrees:[cmsTrackable.augmentationRotation floatValue] axisX:0 y:0 z:1];
                float scaleFactor = 1;
                
                if (cmsTrackable.fillMarker) {
                    if ([cmsTrackable.augmentationRotation intValue] == 90) {
                        scaleFactor = (float)trackable.width / videoNode.videoTexture.height;
                    }
                    else {
                        scaleFactor = (float)trackable.width / videoNode.videoTexture.width; 
                    }
                    [videoNode scaleByUniform:scaleFactor];
                }
                videoNode.videoTextureMaterial.fadeInTime = [cmsTrackable.displayFade floatValue];
                videoNode.videoTexture.resetThreshold = [cmsTrackable.resetTime doubleValue];
                [videoNode play];
            }
            else {
                [trackable addTrackingEventTarget:self action:@selector(textTracking:) forEvent:ARImageTrackableEventDetected];
                [trackable addTrackingEventTarget:self action:@selector(textLost:) forEvent:ARImageTrackableEventLost];
            }
        }
        [trackerManager addTrackableSet:trackableSet];
    }
}

- (void)textTracking:(ARImageTrackable *)trackable
{
    dispatch_async(dispatch_get_main_queue(), ^{
         NSString *decode1 = [trackable.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *path = [[decode1
                           stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                          stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.trackableTextLabel.text = path;
        self.trackableTextLabel.hidden = NO;
    });
    
}

- (void)textLost:(ARImageTrackable *)trackable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.trackableTextLabel.text = @"";
        self.trackableTextLabel.hidden = YES;
    });
}

#pragma mark UI
/// Shows alert if app not connected to internet
- (void)showLackOfConnectivityAlert
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"No network connection"
                                  message:@"Please connect to the internet to download new markers"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

/// Recieves delegate callback and updates progress view
- (void)updateProgressView:(NSNumber *)percentage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressView.progress = [percentage doubleValue];
    });
}

- (void)setDownloadProgressHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.downloadInfoView.alpha = 0.f;
        }];
    });
}

- (void)setLoadingProgressHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.loadingSplashScreen.alpha = 0.f;
        }];
    });
}

- (void)downloadFinishedLoadTrackable
{
    [self setDownloadProgressHidden];
}

@end
