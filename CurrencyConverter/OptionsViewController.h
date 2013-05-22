//
//  OptionsViewController.h
//  CurrencyConverter
//
//  Created by Sorin Cioban on 21/05/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsViewController : UITableViewController

@property id delegate;

@end

@protocol OptionsVCDelegate <NSObject>

- (void)doneWithOptions;

@end