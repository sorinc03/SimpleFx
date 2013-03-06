//
//  NavigationBarTitleView.h
//  CurrencyConverter
//
//  Created by Sorin Cioban on 06/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBarTitleView : UIView

@property (strong) UILabel *titleLabel;
@property (strong) UILabel *subtitleLabel;
- (id)initWithNavBarFrame:(CGRect)frame;
- (void)showTitleOnly;
- (void)showTitleAndSubtitle;

@end
