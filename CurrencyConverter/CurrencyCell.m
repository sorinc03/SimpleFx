/*
 File: CurrencyCell.m
 
 CurrencyCell is a custom UITableViewCell implementation containing an image, two labels and a text field
 */

#import "CurrencyCell.h"

@implementation CurrencyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        [self setupCurrencyImage];
        [self setupLabel];
        [self setupTextField];
        
        [self addSubview:self.currencySymbolLabel];
        [self addSubview:self.currencyImage];
        [self addSubview:self.textField];
    }
    return self;
}

/*
 The setupCurrencyImage function gives the UIImageView a frame and a default image
 */
- (void)setupCurrencyImage {
    self.currencyImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 66, 40)];
    self.currencyImage.image = [UIImage imageNamed:@"us-flag.jpg"];
}

/*
 The setupTextField function initialises the textField with a frame, font, borderstyle
 */
- (void)setupTextField {
    CGRect frame = CGRectMake(81, 10, 150, 25);
    self.textField = [[UITextField alloc] initWithFrame:frame];
    self.textField.textAlignment = NSTextAlignmentLeft;
    self.textField.font = [UIFont systemFontOfSize:15.0];
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

/*
 setupLabel, as per its name, initialises the symbol label value and frame
 */
- (void)setupLabel {
    self.currencySymbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(83, 37, 170, 16)];
    self.currencySymbolLabel.font = [UIFont systemFontOfSize:13.0];
    self.currencySymbolLabel.textAlignment = NSTextAlignmentLeft;
    self.currencySymbolLabel.text = @"EUR - Australian Dollar";
}

/*
 enableTextField sets the textField enabled property to YES or NO and based on this, its border to RoundedRect
 or None
 */
- (void)enableTextField:(BOOL)enabled {
    self.textField.enabled = enabled;
    
    self.textField.borderStyle = enabled == YES ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
