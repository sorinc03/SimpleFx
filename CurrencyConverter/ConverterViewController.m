/*
 File: ConverterViewController.m
 
 The ConverterViewController is a subclass of UITableViewController and is the main view controller for the app.
 
 When the app first loads, we initialise the CurrencyDownloader, the table view, the UIRefreshControl and enable calculating the currencies when the user types in a UITextField through the UITextFieldDelegate
 */

#import "ConverterViewController.h"
#import "CurrencyDownloader.h"
#import "CurrencyCell.h"
#import "Currency.h"
#import "UITextFieldAccessoryView.h"
#import "OptionsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#define REFRESH_HEIGHT 52.0f

@interface ConverterViewController () <CurrencyDownloaderDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, OptionsVCDelegate>

@property (strong) NSString *lastUpdated;
@property (nonatomic) CGFloat screenHeight;
@property (strong) NSString *editingCurrency;
@property (strong) UITableView *currencyTable;
@property (strong) CurrencyDownloader *downloader;
@property (strong) NSMutableDictionary *urlMappings;
@property (strong) UITextFieldAccessoryView *textFieldAccessoryView;
@property (strong) OptionsViewController *optionsVC;
@property (strong) MBProgressHUD *hud;
@property (strong) NSString *mainCurrency;

@end

@implementation ConverterViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {}
    
    return self;
}

/*
 viewDidLoad initializes the view, registers the CurrencyCell class and initializes the CurrencyDownloader object
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self showOptionsController];
    
    self.mainCurrency = [[NSUserDefaults standardUserDefaults] valueForKey:@"mainCurrency"];
    
    if (self.mainCurrency == nil) {
        self.mainCurrency = @"EUR";
        [self saveMainCurrency];
    }
    
    
    [self.tableView registerClass:[CurrencyCell class] forCellReuseIdentifier:@"CurrencyExchange"];
    
    self.textFieldAccessoryView = [[UITextFieldAccessoryView alloc]
                                   initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    self.navigationItem.title = @"Converter";
    
    self.editingCurrency = @"";
        
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.downloader = [[CurrencyDownloader alloc] init];
    self.downloader.delegate = self;
    
    [self.downloader initDownloader];
    
    [self setupRefreshControl];
}

- (NSString *)getMainCurrency {
    return self.mainCurrency;
}

- (void)saveMainCurrency {
    [[NSUserDefaults standardUserDefaults] setValue:self.mainCurrency forKey:@"mainCurrency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showOptionsController {
    self.optionsVC = [[OptionsViewController alloc] initWithNibName:nil bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.optionsVC];
    self.optionsVC.delegate = self;
    [self presentViewController:navController animated:YES completion:^{}];
}

- (void)doneWithOptions {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

/*
 setupRefreshControl sets the action for the UIRefreshControl and it updates it calls updateRefreshControlText
 */
- (void)setupRefreshControl {    
    [self.refreshControl addTarget:self action:@selector(getNewRates:) forControlEvents:UIControlEventValueChanged];
    
    [self updateRefreshControlText];
}

/*
 updateRefreshControlText sets the UIRefreshControl's attributedTitle value to the latest time new data was pulled
 */
- (void)updateRefreshControlText {    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[self getLastUpdatedDate]];
}

/*
 getNewRates: is the method called by the refresh control and initialises a download of new currency data
 provided there is an internet connection available
 */
- (void)getNewRates:(id)sender {
    if ([self.downloader hasInternetConnection])
        [self.downloader getECBExchangeRates];
}

/*
 showOldData simply updates the values based on a value of 1.0 for EUR and then calls setupTableView
 */
- (void)showOldData {
    [self updateValuesFrom:self.mainCurrency withAmount:@"1.0"];
    [self setupTableView];
}

/*
 noNewData is called by the downloader object if no new data has been pulled/found for any reason and stops the refresh animation for the UIRefreshControl
 */
- (void)noNewData {
    if ([self.refreshControl isRefreshing])
        [self.refreshControl endRefreshing];
    [self updateRefreshControlText];
}

/*
 downloadCompleted is called when new data actually exists and it causes the table view's data to reload with the new exchange rates
 */
- (void)downloadCompleted {
    [self updateValuesFrom:@"EUR" withAmount:@"1.0"];
    
    if ([self.refreshControl isRefreshing]) {
        [self setupTableView];
    }
    
    else {
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"firstStart"] isEqualToString:@"Passed"]) {
            [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
            [[NSUserDefaults standardUserDefaults] setValue:@"Passed" forKey:@"firstStart"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Updated"
                                                            message:@"Exchange rates have been updated."
                                                           delegate:self
                                                  cancelButtonTitle:@"Keep current rates"
                                                  otherButtonTitles:@"Refresh rates", nil];
            alert.tag = 1;
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 0: {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
                break;
            }
                
            case 1: {
                [self setupTableView];
                break;
            }
        }
    }
}

/*
 unableToDownload is typically called from the downloader object if there is no internet connectivity available
 */
- (void)unableToDownload {
    [self.refreshControl endRefreshing];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Please check your internet connection and try again"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
    
    [alert show];
}

/*
 getLlastUpdatedDate returns a string with the latest date the data has been updated based on the value stored in the downloader's forex object.
 */
- (NSString *)getLastUpdatedDate {
    self.lastUpdated = [self.downloader.rates valueForKey:@"lastUpdated"];
    if (self.lastUpdated == nil) {
        self.lastUpdated = @"Never";
    }
    
    self.lastUpdated = [NSString stringWithFormat:@"Last updated: %@", self.lastUpdated];
    
    return self.lastUpdated;
}

- (void)resetTable {
    [self setupTableView];
}

/*
 setupTableView calls updateRefreshControlText, stops its refreshing and then reloads the table data 
 */
- (void)setupTableView {
    [self updateRefreshControlText];
    
    if ([self.refreshControl isRefreshing])
        [self.refreshControl endRefreshing];
    
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurrencyExchange"];
    cell.textField.delegate = self;
    
    Currency *c = (Currency *)self.downloader.currencies[indexPath.row];

    NSString *currencyName = [NSString stringWithFormat:@"%@ - %@", c.symbol, c.name];
    
    cell.currencySymbolLabel.text = currencyName;
        
    cell.currencyImage.image = [UIImage imageNamed:c.symbol];
    
    cell.textField.text = c.value;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [cell enableTextField:NO];
    
    [cell.textField addTarget:self
                       action:@selector(textFieldTextHasChanged:)
             forControlEvents:UIControlEventEditingChanged];
    
    if (indexPath.row == 0) {
        UIImageView *defaultTick = [[UIImageView alloc] initWithFrame:CGRectMake(280, 20, 20, 20)];
        defaultTick.image = [UIImage imageNamed:@"19-circle-check"];
        defaultTick.tag = 999;
        [cell addSubview:defaultTick];
    }
    
    else {
        for (UIImageView *view in cell.subviews) {
            if (view.tag == 999)
                [view removeFromSuperview];
        }
    }
    
    //NSLog(@"%d, %@", indexPath.row, cell.currencySymbolLabel.text);
    
    [self addLongPressGestureTo:cell];
    
    return cell;
}

- (void)addLongPressGestureTo:(CurrencyCell *)cell {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.delegate = self;
    [longPress setMinimumPressDuration:1.0];
    [cell addGestureRecognizer:longPress];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
    
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
        self.hud.labelText = @"Loading";
        [self.hud showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    }
    
    if (longPress.state == UIGestureRecognizerStateEnded) {
        CurrencyCell *cell = (CurrencyCell *)longPress.view;
        
        self.mainCurrency = [cell.currencySymbolLabel.text substringToIndex:3];
        
        [self saveMainCurrency];
        
        [self.downloader resetTableForMainCurrency];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CurrencyCell *cell = (CurrencyCell *)[tableView cellForRowAtIndexPath:indexPath
                                          ];
    
    [cell enableTextField:YES];
    
    [cell.textField becomeFirstResponder];
}

- (void)myProgressTask {
	// This just increases the progress indicator in a loop
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		self.hud.progress = progress;
		usleep(5000);
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloader.currencies.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.textFieldAccessoryView setEditingField:textField];
    textField.inputAccessoryView = self.textFieldAccessoryView;
    
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    NSIndexPath *cellPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView scrollToRowAtIndexPath:cellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideFieldShowValue:textField];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideFieldShowValue:textField];
    [textField resignFirstResponder];
    return NO;
}

/*
 hideFieldShowvalue: gets the textField's superview cell and calls its enableTextField: function to enable/disable textField
 */
- (void)hideFieldShowValue:(UITextField *)textField {
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    
    [cell enableTextField:NO];
}

- (void)textFieldTextHasChanged:(UITextField *)textField {
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    NSString *currencySymbol = [cell.currencySymbolLabel.text substringToIndex:3];
    
    self.editingCurrency = currencySymbol;
    
    [self updateValuesFrom:currencySymbol withAmount:textField.text];
    
}

/*
 updateValuesFrom:withAmount: simply updates the current value of a given currency in the Downloader's Currency object
 */
- (void)updateValuesFrom:(NSString *)currencySymbol withAmount:(NSString *)amount{
    NSInteger initialCurrencyIndex = [self getIndexForSymbol:currencySymbol];
    
    Currency *c = (Currency *)self.downloader.currencies[initialCurrencyIndex];
    
    c.value = amount;
    
    CGFloat amountToConvert = amount.floatValue;
    CGFloat amountToConvertInMainCurrency = amountToConvert/((NSString *)[self.downloader.rates valueForKey:currencySymbol]).floatValue;
    
    for (Currency *currency in self.downloader.currencies) {
        if (![currency.symbol isEqualToString:currencySymbol]) {
            //NSString *currencyPair = [NSString stringWithFormat:@"%@%@", currencySymbol, currency.symbol];
            NSInteger indexToUpdate = [self getIndexForSymbol:currency.symbol];
            //CGFloat forexRate = ((NSString *)[self.downloader.forex valueForKey:currencyPair]).floatValue;
            CGFloat forexRate = ((NSString *)[self.downloader.rates valueForKey:currency.symbol]).floatValue;
            
            CGFloat result = amountToConvertInMainCurrency * forexRate;
            
            Currency *c = (Currency *)self.downloader.currencies[indexToUpdate];
            
            c.value = [NSString stringWithFormat:@"%.4f", result];
        }
    }
    
    if (![self.editingCurrency isEqualToString:@""]) {
        [self reloadTextFields];
    }
}

/*
 reloadTextFields plugs the new value for the currencies in the textFields
 */
- (void)reloadTextFields {
    for (int i = 0; i < self.downloader.currencies.count; i++) {
        Currency *c = (Currency *)self.downloader.currencies[i];
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        
        CurrencyCell *cell = (CurrencyCell *)[self.tableView cellForRowAtIndexPath:path];
        
        cell.textField.text = c.value;
    }
}

/*
 getIndexForSymbol returns the index a symbol is at in the currencies array (and hence, the table)
 */
- (NSInteger)getIndexForSymbol:(NSString *)symbol {
    for (int i = 0; i < self.downloader.currencies.count; i++) {
        Currency *c = (Currency *)self.downloader.currencies[i];
        if ([c.symbol isEqualToString:symbol])
            return i;
    }
    
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
