//
//  StoryPlayerVCViewController.m
//  StoryVideoPlayer
//
//  Created by Gaston Morixe on 3/11/17.
//  Copyright © 2017 Gaston Morixe. All rights reserved.
//

#import "GMStoryViewController.h"

#import "VIMediaCache.h"

@interface GMStoryViewController ()

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) NSMutableDictionary* playersState;

@end

int cmod(int num, int op){
    int result = num % op;
    if (result < 0) result += op;
    return result;
}

@implementation GMStoryViewController

-(void) dealloc {
    self.playerA = nil;
    self.playerB = nil;
    self.playerC = nil;
}

- (void) setupTransition {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didPanWithGestureRecognizer:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (CGPoint) boundsCenterPoint {
    return CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void) didPanWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

static NSString* PLAYER_STATE_PRELOADING = @"PLAYER_STATE_PRELOADING";
static NSString* PLAYER_STATE_PLAYING = @"PLAYER_STATE_PLAYING";
static NSString* PLAYER_STATE_PAUSED = @"PLAYER_STATE_PAUSED";

static NSString* PLAYER_WAY = @"PLAYER_WAY";
static NSString* PLAYER_WAY_FORWARD = @"PLAYER_WAY_FORWARD";
static NSString* PLAYER_WAY_BACKWARDS = @"PLAYER_WAY_BACKWARDS";

static NSString* PLAYER_VIDEO_INDEX = @"PLAYER_VIDEO_INDEX";

static NSString* PLAYER_A = @"PLAYER_A";
static NSString* PLAYER_B = @"PLAYER_B";
static NSString* PLAYER_C = @"PLAYER_C";


- (void) preload {
    
    self.playersState = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                        PLAYER_WAY: @(NAN),
                                                                        PLAYER_VIDEO_INDEX: @(-1),
                                                                        PLAYER_A: PLAYER_STATE_PLAYING,
                                                                        PLAYER_B: PLAYER_STATE_PRELOADING,
                                                                        PLAYER_C: PLAYER_STATE_PAUSED,
                                                                        }];
    
    [self preloadPlayer:self.playerA
                  video:self.videos.firstObject];
    
    [self preloadPlayer:self.playerB
                  video:self.videos[1]];
    
    [self preloadPlayer:self.playerC
                  video:self.videos.lastObject];
   
}

- (void) prepare {
    
    [self resetIndex];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(tap:)];
    
    [self.view addGestureRecognizer:self.tapGesture];
    
    self.playerB = [[GMVideoViewController alloc] init];
    [self displayContentController:self.playerB];
    
    self.playerA = [[GMVideoViewController alloc] init];
    [self displayContentController:self.playerA];

    self.playerC = [[GMVideoViewController alloc] init];
    [self displayContentController:self.playerC];
    
    [self setupTransition];
    
    [self viewDidLayoutSubviews];
    
}

- (void) resetIndex {
    [self.playersState setObject:@(-1) forKey:PLAYER_VIDEO_INDEX];
}

- (void) loadNextVideo {
    [self loadNextVideo:PLAYER_WAY_FORWARD];
}

- (void) loadPreviousVideo {
    [self loadNextVideo:PLAYER_WAY_BACKWARDS];
}

- (void) loadNextVideo:(NSString*)way {
    
    NSString* oldWay = self.playersState[PLAYER_WAY];
    
    int videosCount = (int)self.videos.count;
    
    int currentVideoIndex = ((NSNumber*)self.playersState[PLAYER_VIDEO_INDEX]).intValue;
    
    int step = way == PLAYER_WAY_FORWARD ? 1 : -1;
    int nextVideoIndex = cmod((currentVideoIndex + step), videosCount);

    // Play Video
    if (currentVideoIndex == -1) {
        [self playPlayer:self.playerA];
    }else{
        GMVideoViewController *player;
        NSString* playerKey;
        
        if (oldWay == way) {
            if (self.playersState[PLAYER_A] == PLAYER_STATE_PRELOADING) {
                player = self.playerA;
                playerKey = PLAYER_A;
            }else if (self.playersState[PLAYER_B] == PLAYER_STATE_PRELOADING) {
                player = self.playerB;
                playerKey = PLAYER_B;
            }else if (self.playersState[PLAYER_C] == PLAYER_STATE_PRELOADING) {
                player = self.playerC;
                playerKey = PLAYER_C;
            }
        }else{ // CHANGE IN DIRECTION
            if (self.playersState[PLAYER_A] == PLAYER_STATE_PAUSED) {
                player = self.playerA;
                playerKey = PLAYER_A;
            }else if (self.playersState[PLAYER_B] == PLAYER_STATE_PAUSED) {
                player = self.playerB;
                playerKey = PLAYER_B;
            }else if (self.playersState[PLAYER_C] == PLAYER_STATE_PAUSED) {
                player = self.playerC;
                playerKey = PLAYER_C;
            }
        }
        [self playPlayer:player];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playersState setObject:PLAYER_STATE_PLAYING forKey:playerKey];
        });
        
    }
    
    // Pause
    if (currentVideoIndex == -1) {
        // NO OP
    }else{
        GMVideoViewController *player;
        NSString* playerKey;
        
        if (self.playersState[PLAYER_A] == PLAYER_STATE_PLAYING) {
            player = self.playerA;
            playerKey = PLAYER_A;
        }else if (self.playersState[PLAYER_B] == PLAYER_STATE_PLAYING) {
            player = self.playerB;
            playerKey = PLAYER_B;
        }else if (self.playersState[PLAYER_C] == PLAYER_STATE_PLAYING) {
            player = self.playerC;
            playerKey = PLAYER_C;
        }
        [self pausePlayer:player];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playersState setObject:PLAYER_STATE_PAUSED forKey:playerKey];
        });
    }
    
    // Preload
    if (currentVideoIndex == -1) {
        // NO OP
    }else{
        
        int preloadIndexStep = way == PLAYER_WAY_FORWARD ? -1 : 1;
        int preloadIndex = cmod(currentVideoIndex + preloadIndexStep, videosCount);
        int preloadJumpStep = way == PLAYER_WAY_FORWARD ? 3 : -3;
        int preloadVideoIndex = cmod(preloadIndex + preloadJumpStep, videosCount);
        
        GMVideoViewController *player = nil;
        NSString* playerKey;
        
        if (oldWay == way) {
            if (self.playersState[PLAYER_A] == PLAYER_STATE_PAUSED) {
                player = self.playerA;
                playerKey = PLAYER_A;
            }else if (self.playersState[PLAYER_B] == PLAYER_STATE_PAUSED) {
                player = self.playerB;
                playerKey = PLAYER_B;
            }else if (self.playersState[PLAYER_C] == PLAYER_STATE_PAUSED) {
                player = self.playerC;
                playerKey = PLAYER_C;
            }
        }else{
            if (self.playersState[PLAYER_A] == PLAYER_STATE_PRELOADING) {
                player = self.playerA;
                playerKey = PLAYER_A;
            }else if (self.playersState[PLAYER_B] == PLAYER_STATE_PRELOADING) {
                player = self.playerB;
                playerKey = PLAYER_B;
            }else if (self.playersState[PLAYER_C] == PLAYER_STATE_PRELOADING) {
                player = self.playerC;
                playerKey = PLAYER_C;
            }
        }
        [self preloadPlayer:player
                      video:self.videos[preloadVideoIndex]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playersState setObject:PLAYER_STATE_PRELOADING forKey:playerKey];
        });

    }
    
    [self.playersState setObject:way forKey:PLAYER_WAY];
    [self.playersState setObject:@(nextVideoIndex) forKey:PLAYER_VIDEO_INDEX];
    
}

- (void) preloadPlayer:(GMVideoViewController*)_aPlayer
                 video:(NSArray*)_video {
    
    _aPlayer.view.hidden = true;
    NSString* videoURLString = _video[0];
    NSString* thumbURLString = _video[1];

    [_aPlayer prepareWithVideoURLString:videoURLString
                      andThumbURLString:thumbURLString];

}

- (void) pausePlayer:(GMVideoViewController*)_aPlayer {
    _aPlayer.view.hidden = true;
    [_aPlayer pause];
}

- (void) playPlayer:(GMVideoViewController*)_aPlayer {
    self.currentPlayer = _aPlayer;
    _aPlayer.view.hidden = false;
    [_aPlayer play];
}

- (void) tap:(UITapGestureRecognizer*)_aTap {
    CGPoint touchPoint = [_aTap locationInView: _aTap.view];
    BOOL nextVideo = touchPoint.x >= (_aTap.view.bounds.size.width/2.0f) ? true : false;
    if(nextVideo){
        NSLog(@"Tap Next! x:%f y:%f", touchPoint.x, touchPoint.y);
        [self loadNextVideo];
    }else{
        NSLog(@"Tap Prev! x:%f y:%f", touchPoint.x, touchPoint.y);
        [self loadPreviousVideo];
    }
}

- (BOOL) prefersStatusBarHidden {
    return true;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadNextVideo];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.playerA.view.frame = self.view.bounds;
    self.playerB.view.frame = self.view.bounds;
    self.playerC.view.frame = self.view.bounds;
}

- (void)displayContentController:(UIViewController *)vc {

    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];

}

- (void) resetPlayers {
    [self resetIndex];
    [self.playerA pause];
    [self.playerB pause];
    [self.playerC pause];
    
    [self preload];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self resetPlayers];
}

- (void) viewDidLoad {
    self.modalPresentationCapturesStatusBarAppearance = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaCacheDidChanged:)
                                                 name:VICacheManagerDidUpdateCacheNotification
                                               object:nil];
}


- (void)string:(NSMutableString *)string appendString:(NSString *)appendString muti:(NSInteger)muti {
    for (NSInteger i = 0; i < muti; i++) {
        [string appendString:appendString];
    }
}

- (void)mediaCacheDidChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    VICacheConfiguration *configuration = userInfo[VICacheConfigurationKey];
    NSArray<NSValue *> *cachedFragments = configuration.cacheFragments;
    long long contentLength = configuration.contentInfo.contentLength;
    
    NSInteger number = 100;
    NSMutableString *progressStr = [NSMutableString string];
    
    [cachedFragments enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.rangeValue;
        
        NSInteger location = roundf((range.location / (double)contentLength) * number);
        
        NSInteger progressCount = progressStr.length;
        [self string:progressStr appendString:@"0" muti:location - progressCount];
        
        NSInteger length = roundf((range.length / (double)contentLength) * number);
        [self string:progressStr appendString:@"1" muti:length];
        
        
        if (idx == cachedFragments.count - 1 && (location + length) <= number + 1) {
            [self string:progressStr appendString:@"0" muti:number - (length + location)];
        }
    }];
    
    NSLog(@"%@", progressStr);
}

@end
