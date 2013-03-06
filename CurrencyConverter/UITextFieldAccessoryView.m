//
//  UITextFieldAccessoryView.m
//  CurrencyConverter
//
//  Created by Sorin Cioban on 06/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "UITextFieldAccessoryView.h"

@interface UITextFieldAccessoryView ()

@end

@implementation UITextFieldAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andTextField:(UITextField *)textField {
    self = [super initWithFrame:frame];
    if (self) {
        self.editingField = textField;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self setBackgroundColor:[UIColor grayColor]];
    UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    b.frame = CGRectMake(270, 4, 40, 36);
    
    [b setTitle:@"Done" forState:UIControlStateNormal];
    [b addTarget:self action:@selector(removeAccessoryView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:b];
}

- (void)removeAccessoryView:(id)sender {
    [self.editingField resignFirstResponder];
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
