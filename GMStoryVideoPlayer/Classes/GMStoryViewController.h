//
//  StoryPlayerVCViewController.h
//  StoryVideoPlayer
//
//  Created by Gaston Morixe on 3/11/17.
//  Copyright © 2017 Gaston Morixe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMVideoViewController.h"

@protocol GMStoryViewControllerDelegate <NSObject>

@optional

- (UIView *)presenterViewController:(UIViewController*)vc
            referenceViewForVideoID:(NSString*)videoID;

@end

@interface GMStoryViewController : UIViewController

@property (nonatomic, weak) id <GMStoryViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray* videos;

@property (nonatomic, strong) GMVideoViewController* playerA;
@property (nonatomic, strong) GMVideoViewController* playerB;
@property (nonatomic, strong) GMVideoViewController* playerC;
@property (nonatomic, weak)   GMVideoViewController* currentPlayer;

- (void) prepare;
- (void) preload;

@end
