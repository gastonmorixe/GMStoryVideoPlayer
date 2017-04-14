//
//  AppViewController.m
//  StoryVideoPlayer
//
//  Created by Gaston Morixe on 3/11/17.
//  Copyright © 2017 Gaston Morixe. All rights reserved.
//

#import "GMAppViewController.h"
@import GMStoryVideoPlayer;
@import SDWebImage;
#import "GMImageButton.h"

@interface GMAppViewController ()
@property (nonatomic, strong) GMStoryViewController* storyPlayerVC;
@property (nonatomic, strong) GMImageButton* button;
@property (nonatomic, strong) UIView* buttonContainer;
@end


@interface GMAppViewController () <GMStoryViewControllerDelegate>

@end

@implementation GMAppViewController


- (void) viewDidLoad {

    [super viewDidLoad];
    
    //
    // Story VC
    
    self.storyPlayerVC = [[GMStoryViewController alloc] init];
    self.storyPlayerVC.view.frame = self.view.bounds;
    self.storyPlayerVC.delegate = self;
    
    [self.storyPlayerVC prepare];
    self.storyPlayerVC.videos = @[
                                @[@"https://cdn.vvvvvvv.space/v/4f566b31-2640-4446-b3a0-9b5c59664641.mp4", @"https://cdn.vvvvvvv.space/v/4f566b31-2640-4446-b3a0-9b5c59664641.png"],
                                  @[@"https://cdn.vvvvvvv.space/v/18c3f1f0-63ad-4378-acd1-0ddc9e9bd595.mp4", @"https://cdn.vvvvvvv.space/v/18c3f1f0-63ad-4378-acd1-0ddc9e9bd595.png"],
                                  @[@"https://cdn.vvvvvvv.space/v/b79e3002-1465-478a-bd53-202189d00114.mp4", @"https://cdn.vvvvvvv.space/v/b79e3002-1465-478a-bd53-202189d00114.png"],
                                  @[@"https://cdn.vvvvvvv.space/v/baed6f59-92ea-4612-a1e0-28d3e182a904.mp4", @"https://cdn.vvvvvvv.space/v/baed6f59-92ea-4612-a1e0-28d3e182a904.png"],
                                  @[@"https://cdn.vvvvvvv.space/v/0dab26e9-adb7-4259-8315-891c628be016.mp4", @"https://cdn.vvvvvvv.space/v/0dab26e9-adb7-4259-8315-891c628be016.png"],
                                  @[@"https://cdn.vvvvvvv.space/v/797bcb7d-8a13-4cde-b60e-ed22d4b7c2be.mp4", @"https://cdn.vvvvvvv.space/v/797bcb7d-8a13-4cde-b60e-ed22d4b7c2be.png"],
                                  @[@"https://cdn.vvvvvvv.space/v/17132723-59bd-4916-9d28-4369504773c4.mp4", @"https://cdn.vvvvvvv.space/v/17132723-59bd-4916-9d28-4369504773c4.png"]
                                ];
    [self.storyPlayerVC preload];
    
    
    //
    // Video Thumb Button

    UIImageView* imageViewButton = [[UIImageView alloc] init];
    [imageViewButton sd_setImageWithURL:[NSURL URLWithString:self.storyPlayerVC.videos[0][1]]];
    imageViewButton.contentMode = UIViewContentModeScaleAspectFit;
    imageViewButton.frame = self.button.bounds;
    imageViewButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.button = [GMImageButton buttonWithType:UIButtonTypeCustom];
    self.button.backgroundColor = [UIColor colorWithWhite:.95f alpha:1.0f];
    self.button.frame = CGRectMake(0, 0, 200, 200);
    self.button.center = self.view.center;
    self.button.myImageView = imageViewButton;
    [self.view addSubview:self.button];
    self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.button addTarget:self
                    action:@selector(onButtonTap)
          forControlEvents:UIControlEventTouchUpInside];

}

- (BOOL)prefersStatusBarHidden {
    return false;
}

- (void) onButtonTap {
    [self presentViewController:self.storyPlayerVC
                       animated:YES
                     completion:^
     {
         NSLog(@"Story presented!");
     }];
}

@end
