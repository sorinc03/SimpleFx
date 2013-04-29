/*
 File: UITextFieldAcccessoryView.m
 
 The UITextFieldAccessoryView class is a subclass of UIView and is used to provide an accessory view for a given
 textField when the keyboard is displayed
 */

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

/*
 setupView adds a UIToolbar as a subview
 The UIToolbar contains a flexible space item and a done button item
 */
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

/*
 The removeAccessoryView: method is called when the UIBarButtonItem is tapped and it makes the keyboard disappear
 */
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
