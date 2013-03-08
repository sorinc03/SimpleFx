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
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.frame];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil
                                      action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                   target:nil
                                   action:@selector(removeAccessoryView:)];
    
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
    
    [self addSubview:toolbar];
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
