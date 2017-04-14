//
//  ViewController.m
//  StoryVideoPlayer
//
//  Created by Gaston Morixe on 3/11/17.
//  Copyright © 2017 Gaston Morixe. All rights reserved.
//

#import "GMStoryViewController.h"
@import AVFoundation;
@import SDWebImage;
#import "VIMediaCache.h"

@interface GMVideoViewController ()

@property (nonatomic, strong) VIResourceLoaderManager* resourceLoaderManager;

@property (nonatomic) bool isLoading;

@property (nonatomic, weak) UIImageView* thumbImage;

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;

@property (nonatomic, strong) UIView* bufferView;
@property (nonatomic, strong) UIView* progressView;

@property (nonatomic, weak) RTSpinKitView *spinner;

@end

@implementation GMVideoViewController

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.playerLayer.frame = self.view.layer.bounds;
    self.thumbImage.frame = self.view.bounds;
}

- (void) play {
    //[self.player pause];
    [self.player setVolume:1.0f];
    [self.player seekToTime:CMTimeMakeWithSeconds(0.4f, 60)];
    [self.player play];
}

- (void) pause {
    [self.player pause];
}

- (void) loadThumb:(NSString*)thumbUrlString {
    [self.thumbImage sd_setImageWithURL:[NSURL URLWithString:thumbUrlString]
                       placeholderImage:nil];
    
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    
    self.resourceLoaderManager = [VIResourceLoaderManager new];
    
    UIImageView* thumbImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:thumbImage];
    self.thumbImage = thumbImage;
    [self.view addSubview:thumbImage];
    
    self.view.opaque = false;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.opaque = false;
    self.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:self.playerLayer];

    self.bufferView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bufferView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8f];
    [self.view addSubview:_bufferView];
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectZero];
    self.progressView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_progressView];
    
    RTSpinKitView* spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave];
    spinner.color = [UIColor colorWithWhite:0.7f alpha:1.0f];
    [self.view addSubview:spinner];
    spinner.center = self.view.center;
    self.spinner = spinner;
    
    __typeof(self) selfWeak = self;
    [NSNotificationCenter.defaultCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification * _Nonnull note)
     {
         if (note.object == selfWeak.playerItem) {
             [selfWeak.player pause];
             [selfWeak.player seekToTime:kCMTimeZero];
             [selfWeak.player play];
         }
     }];

}

- (void) setupPlayerWithPlayerItem:(AVPlayerItem*)_aPlayerItem {
    
    if (self.player) {
        [self.player pause];
        self.player = nil;
    }
    
    self.player = [AVPlayer playerWithPlayerItem:_aPlayerItem];
    self.playerLayer.player = self.player;
    
    __typeof(self) selfWeak = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(3, 10)
                                              queue:dispatch_get_main_queue()
                                         usingBlock:^(CMTime time)
     {
         
         if(!selfWeak){
             return;
         }
         
         float currentBuffer = [selfWeak currentBuffer];
         float currentProgress = [selfWeak currentProgress];
         
         [selfWeak updateProgressBuffer:currentBuffer progress:currentProgress];
         
         NSLog(@"Buffered: %f | CurrentPosition %f", currentBuffer, currentProgress);
         
     }];
    
}

- (void) releasePlayerItemKVOs {
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"currentTime"];
}

- (void)prepareWithVideoURLString:(NSString*)_aVideoURLString
                andThumbURLString:(NSString*)_aThumbURLString {
    
    [self loadThumb:_aThumbURLString];
    
    if (!_aVideoURLString) {
        NSAssert(_aVideoURLString, @"Missing _aVideoURLString");
    }
    
    if (self.playerItem) {
        [self releasePlayerItemKVOs];
    }
    
    self.isLoading = true;
    
    self.playerItem = [self.resourceLoaderManager playerItemWithURL:[NSURL URLWithString:_aVideoURLString]];
    
    [self setupPlayerWithPlayerItem:self.playerItem];
    
    [self.player setVolume:0.0f];
    [self.player play];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackBufferEmpty"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackLikelyToKeepUp"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"playbackBufferFull"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"loadedTimeRanges"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self.playerItem addObserver:self
                      forKeyPath:@"currentTime"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    [self viewDidLayoutSubviews];
    
}



-(void) updateProgressBuffer:(float)_buffer progress:(float)_position{
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^
    {
        float bufferProgress = _buffer > 0.0f ? _buffer : 0.00001f;
        self.bufferView.frame = CGRectMake(0, self.view.bounds.size.height - 4,
                                           self.view.bounds.size.width * bufferProgress, 4);
    }
                     completion:nil];
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         float positionProgress = _position > 0.0f ? _position : 0.00001f;         
         self.progressView.frame = CGRectMake(0, self.view.bounds.size.height - 4,
                                              self.view.bounds.size.width * positionProgress, 4);
     }
                     completion:nil];
    

}


-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            self.isLoading = true;
        }
        
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
//            self.isLoading = false;
        }
        
        if ([keyPath isEqualToString:@"playbackBufferFull"]) {
//            self.isLoading = false;
        }
        
        AVPlayerItem* item = object;
        if (item.status == AVPlayerStatusReadyToPlay) {
            self.isLoading = false;
        }else{
//            self.isLoading = true;
        }
        
    }
}

-(void)setIsLoading:(bool)isLoading{
    _isLoading = isLoading;
    [self.spinner setHidden:!isLoading];
}

-(float) currentProgress {
    return CMTimeGetSeconds(self.playerItem.currentTime) / CMTimeGetSeconds(self.playerItem.duration);
}

-(float) currentBuffer {
    NSValue* firstBufferedRange = self.playerItem.loadedTimeRanges.firstObject;
    CMTimeRange firstBufferedRangeValue = firstBufferedRange.CMTimeRangeValue;
    CMTime firstBufferedRangeEndTime = CMTimeRangeGetEnd(firstBufferedRangeValue);
    return CMTimeGetSeconds(firstBufferedRangeEndTime) / CMTimeGetSeconds(self.playerItem.duration);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.bufferView.frame = CGRectMake(0, self.view.bounds.size.height - 4,
                                       self.view.bounds.size.width * 0.0f, 4);
    
    self.progressView.frame = CGRectMake(0, self.view.bounds.size.height - 4,
                                         self.view.bounds.size.width * 0.0f, 4);
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player pause];
}

-(void) dealloc{
    [self releasePlayerItemKVOs];
    
    [self.playerLayer removeFromSuperlayer];
    
    self.resourceLoaderManager = nil;
    self.player = nil;
    self.playerItem = nil;
    self.playerLayer = nil;
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
