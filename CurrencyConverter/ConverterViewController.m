//
//  ViewController.m
//  CurrencyConverter
//
//  Created by Sorin Cioban on 02/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "ConverterViewController.h"
#import "CurrencyDownloader.h"
#import "CurrencyCell.h"
#import "Currency.h"
#import "UITextFieldAccessoryView.h"
#import "NavigationBarTitleView.h"
#import <QuartzCore/QuartzCore.h>
#define REFRESH_HEIGHT 52.0f

@interface ConverterViewController () <CurrencyDownloaderDelegate>

@property (nonatomic) CGFloat screenHeight;
@property (strong) UITableView *currencyTable;
@property (strong) NSMutableDictionary *urlMappings;
@property (strong) NSString *editingCurrency;
@property (strong) NSString *lastUpdated;
@property (strong) CurrencyDownloader *downloader;
@property (strong) NavigationBarTitleView *titleView;
@property (strong) UITextFieldAccessoryView *textFieldAccessoryView;

@end

@implementation ConverterViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupURLMappings];
    
    [self.tableView registerClass:[CurrencyCell class] forCellReuseIdentifier:@"CurrencyExchange"];
    
    self.textFieldAccessoryView = [[UITextFieldAccessoryView alloc]
                                   initWithFrame:CGRectMake(0, self.screenHeight-44, 320, 44)];
    
    self.navigationItem.title = @"Converter";
    //self.titleView = [[NavigationBarTitleView alloc] initWithNavBarFrame:self.navigationController.navigationBar.frame];
    
    self.navigationItem.titleView = self.titleView;
    
    self.editingCurrency = @"";
        
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.downloader = [[CurrencyDownloader alloc] init];
    self.downloader.delegate = self;
    
    [self.downloader initDownloader];
    
    [self setupRefreshControl];
}

- (void)setupRefreshControl {    
    [self.refreshControl addTarget:self action:@selector(getNewRates:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Downloading data"];
}

- (void)getNewRates:(id)sender {
    if ([self.downloader hasInternetConnection])
        [self.downloader getTodaysExchangeRates];
}

- (void)setupURLMappings {
    self.urlMappings = [[NSMutableDictionary alloc] initWithDictionary:
                        @{@"EUR" : @"Euro", @"GBP" : @"Pound_sterling", @"JPY" : @"Japanese_yen",
                        @"AED" : @"United_Arab_Emirates_dirham", @"AUD" : @"Australian_dollar",
                        @"CAD" : @"Canadian_dollar", @"INR" : @"Indian_rupee"}];
}

- (void)showOldData {
    [self updateValuesFrom:@"EUR" withAmount:@"1.0"];
    [self setupTableView];
}

- (void)downloadCompleted {
    [self updateValuesFrom:@"EUR" withAmount:@"1.0"];
    
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    
    if ([self.refreshControl isRefreshing]) {
        [self setupTableView];
    }
}

- (void)unableToDownload {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Please check your internet connection and try again"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
    
    [alert show];
}

- (void)refreshTableData:(id)refreshButton {
    self.navigationItem.rightBarButtonItem = nil;
    self.titleView.subtitleLabel.text = self.lastUpdated;
    [self.tableView reloadData];
}

- (void)setupTableView {
    self.lastUpdated = [self.downloader.forex valueForKey:@"lastUpdated"];
    if (self.lastUpdated == nil) {
        self.lastUpdated = @"Never";
    }
    
    self.lastUpdated = [NSString stringWithFormat:@"Last updated: %@", self.lastUpdated];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:self.lastUpdated];
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurrencyExchange"];
    cell.textField.delegate = self;
    
    Currency *c = (Currency *)self.downloader.currencies[indexPath.row];
    
    NSString *currencyName = [NSString stringWithFormat:@"%@ - %@", c.symbol, c.name];
    
    cell.currencySymbolLabel.text = currencyName;
        
    cell.currencyImage.image = [UIImage imageNamed:c.symbol];
    
    cell.textField.text = c.value;
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    cell.textField.alpha = 0.0;
    
    [cell.textField addTarget:self
                       action:@selector(textFieldTextHasChanged:)
             forControlEvents:UIControlEventEditingChanged];
    
    cell.valueLabel.text = c.value;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //NSString *currency = self.downloader.currencySymbols[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CurrencyCell *cell = (CurrencyCell *)[tableView cellForRowAtIndexPath:indexPath
                                          ];
    cell.valueLabel.alpha = 0.0;
    cell.textField.alpha = 1.0;
    [cell.textField becomeFirstResponder];
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

- (void)hideFieldShowValue:(UITextField *)textField {
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    
    textField.alpha = 0.0;
    cell.valueLabel.alpha = 1.0;
}

- (void)textFieldTextHasChanged:(UITextField *)textField {
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    NSString *currencySymbol = [cell.currencySymbolLabel.text substringToIndex:3];
    
    self.editingCurrency = currencySymbol;
    
    [self updateValuesFrom:currencySymbol withAmount:textField.text];
    
}

- (void)updateValuesFrom:(NSString *)currencySymbol withAmount:(NSString *)amount{
    NSInteger initialCurrencyIndex = [self getIndexForSymbol:currencySymbol];
    Currency *c = (Currency *)self.downloader.currencies[initialCurrencyIndex];
    
    c.value = amount;
    
    CGFloat amountToConvert = amount.floatValue;
    
    for (Currency *currency in self.downloader.currencies) {
        if (![currency.symbol isEqualToString:currencySymbol]) {
            NSString *currencyPair = [NSString stringWithFormat:@"%@%@", currencySymbol, currency.symbol];
            NSInteger indexToUpdate = [self getIndexForSymbol:currency.symbol];
            CGFloat forexRate = ((NSString *)[self.downloader.forex valueForKey:currencyPair]).floatValue;
            
            CGFloat result = amountToConvert * forexRate;
            
            Currency *c = (Currency *)self.downloader.currencies[indexToUpdate];
            
            c.value = [NSString stringWithFormat:@"%.4f", result];
        }
    }
    
    if (![self.editingCurrency isEqualToString:@""]) {
        [self reloadTextFields];
    }
}

- (void)reloadTextFields {
    for (int i = 0; i < self.downloader.currencies.count; i++) {
        Currency *c = (Currency *)self.downloader.currencies[i];
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        
        CurrencyCell *cell = (CurrencyCell *)[self.tableView cellForRowAtIndexPath:path];
        
        cell.textField.text = c.value;
        cell.valueLabel.text = c.value;
    }
}

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
