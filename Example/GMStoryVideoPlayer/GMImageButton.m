//
//  BKImageButton.m
//  GMStoryVideoPlayer
//
//  Created by Gaston Morixe on 3/16/17.
//  Copyright © 2017 Gaston Morixe. All rights reserved.
//

#import "GMImageButton.h"

@implementation GMImageButton

- (instancetype)init{
    if(self=[super init]){
        //[self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super initWithCoder:aDecoder]){
        //[self setup];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        //[self setup];
    }
    return self;
}

-(void)dealloc{
    self.myImageView = nil;
}

-(void)setMyImageView:(UIImageView *)myImageView{
    _myImageView = myImageView;
    [self addSubview:myImageView];
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    self.myImageView.frame = self.bounds;
}

@end
