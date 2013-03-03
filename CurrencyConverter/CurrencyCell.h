//
//  CurrencyCell.h
//  CurrencyConverter
//
//  Created by Sorin Cioban on 02/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyCell : UITableViewCell

@property (strong) UIImageView *leftCurrencyImage;
@property (strong) UILabel *leftCurrency;
@property (strong) UIImageView *rightCurrencyImage;
@property (strong) UILabel *rightCurrency;
@property (strong) UILabel *leftRightExRate;
@property (strong) UILabel *rightLeftExRate;

@end
