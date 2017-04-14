//
//  ViewController.h
//  StoryVideoPlayer
//
//  Created by Gaston Morixe on 3/11/17.
//  Copyright © 2017 Gaston Morixe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpinKit/RTSpinKitView.h>

@interface GMVideoViewController : UIViewController

- (void) loadThumb:(NSString*)thumbUrlString;
- (void) prepareWithVideoURLString:(NSString*)_aVideoURLString
                 andThumbURLString:(NSString*)_aThumbURLString;
- (void) play;
- (void) pause;

@end
