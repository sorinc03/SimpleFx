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
        //[self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self setupCurrencyImage];
        [self setupLabels];
        [self setupTextField];
        
        [self addSubview:self.currencySymbolLabel];
        [self addSubview:self.currencyImage];
        [self addSubview:self.textField];
    }
    return self;
}

- (void)setupCurrencyImage {
    self.currencyImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 66, 40)];
    self.currencyImage.image = [UIImage imageNamed:@"us-flag.jpg"];
}

- (void)setupTextField {
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(81, 10, 200, 25)];
    self.textField.textAlignment = NSTextAlignmentLeft;
    self.textField.font = [UIFont systemFontOfSize:15.0];
    //self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
}

- (void)setupLabels {
    self.currencySymbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 40, 170, 12)];
    self.currencySymbolLabel.font = [UIFont systemFontOfSize:14.0];
    self.currencySymbolLabel.textAlignment = NSTextAlignmentLeft;
    self.currencySymbolLabel.text = @"EUR - Australian Dollar";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
