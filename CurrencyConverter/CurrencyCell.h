//
//  CurrencyCell.h
//  CurrencyConverter
//
//  Created by Sorin Cioban on 02/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConverterViewController.h"

@interface CurrencyCell : UITableViewCell

@property (strong) UIImageView *currencyImage;
@property (strong) UILabel *currencySymbolLabel;
@property (strong) UITextField *textField;
@property (strong) UILabel *valueLabel;

@end
