//
//  NavigationBarTitleView.m
//  CurrencyConverter
//
//  Created by Sorin Cioban on 06/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "NavigationBarTitleView.h"
#define TITLE_FONT_ALONE 18
#define TITLE_FONT_SUB 17
#define SUBTITLE_FONT 12

@implementation NavigationBarTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithNavBarFrame:(CGRect)frame {
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(CGRectGetWidth(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, CGRectGetWidth(frame), 18)];
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, CGRectGetWidth(frame), 14)];
        
        [self configureLabels];
        
        [self showTitleAndSubtitle];
    }
    return self;
}

- (void)showTitleOnly {
    CGRect frame = self.titleLabel.frame;
    
    frame.origin.y = 10;
    self.titleLabel.frame = frame;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_ALONE];
    
    if (self.titleLabel.superview != self)
        [self addSubview:self.titleLabel];
    
    [self.subtitleLabel removeFromSuperview];
}

- (void)showTitleAndSubtitle {
    CGRect frame = self.titleLabel.frame;
    
    frame.origin.y = 6;
    self.titleLabel.frame = frame;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SUB];
    
    if (self.titleLabel.superview != self) {
        [self addSubview:self.titleLabel];
    }
    
    if (self.subtitleLabel.superview != self) {
        [self addSubview:self.subtitleLabel];
    }
}

- (void)configureLabels {
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SUB];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"Converter";
    
    self.subtitleLabel.backgroundColor = [UIColor clearColor];
    self.subtitleLabel.textColor = [UIColor whiteColor];
    self.subtitleLabel.font = [UIFont systemFontOfSize:SUBTITLE_FONT];
    self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.text = @"Downloading latest exchange rates";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
