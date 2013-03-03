//
//  CurrencyCell.m
//  CurrencyConverter
//
//  Created by Sorin Cioban on 02/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "CurrencyCell.h"

@implementation CurrencyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLeftRightLabels];
        
        [self setupImages];
        
        [self addSubview:self.leftCurrency];
        [self addSubview:self.leftCurrencyImage];
        [self addSubview:self.leftRightExRate];
        [self addSubview:self.rightCurrency];
        [self addSubview:self.rightCurrencyImage];
        [self addSubview:self.rightLeftExRate];
    }
    return self;
}

- (void)setupImages {
    self.leftCurrencyImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 30)];
    self.leftCurrencyImage.image = [UIImage imageNamed:@"us-flag.jpg"];
    
    self.rightCurrencyImage = [[UIImageView alloc] initWithFrame:CGRectMake(260, 5, 50, 30)];
    self.rightCurrencyImage.image = [UIImage imageNamed:@"INR_flag.jpg"];
}

- (void)setupLeftRightLabels {
    self.leftCurrency = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 30, 10)];
    self.leftCurrency.font = [UIFont systemFontOfSize:13.0];
    self.leftCurrency.textAlignment = NSTextAlignmentCenter;
    self.leftCurrency.text = @"EUR";
    self.rightCurrency = [[UILabel alloc] initWithFrame:CGRectMake(270, 40, 30, 10)];
    self.rightCurrency.font = [UIFont systemFontOfSize:13.0];
    self.rightCurrency.textAlignment = NSTextAlignmentCenter;
    self.rightCurrency.text = @"USD";
    
    self.leftRightExRate = [[UILabel alloc] initWithFrame:CGRectMake(135, 10, 70, 20)];
    self.leftRightExRate.font = [UIFont systemFontOfSize:17.0];
    self.leftRightExRate.textAlignment = NSTextAlignmentCenter;
    self.leftRightExRate.text = @"1.675";
    
    self.rightLeftExRate = [[UILabel alloc] initWithFrame:CGRectMake(140, 30, 70, 20)];
    self.rightLeftExRate.font = [UIFont systemFontOfSize:12.0];
    self.rightLeftExRate.textAlignment = NSTextAlignmentCenter;
    self.rightLeftExRate.text = @"86.75";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
