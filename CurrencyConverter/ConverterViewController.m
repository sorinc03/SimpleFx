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

@interface ConverterViewController () <CurrencyDownloaderDelegate>

@property (nonatomic) CGFloat screenHeight;
@property (strong) UITableView *currencyTable;
@property (strong) NSMutableDictionary *urlMappings;
@property (strong) NSString *editingCurrency;
@property (strong) CurrencyDownloader *downloader;

@end

@implementation ConverterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupURLMappings];
    
    self.editingCurrency = @"";
        
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.downloader = [[CurrencyDownloader alloc] init];
    self.downloader.delegate = self;
    
    [self.downloader initDownloader];
    
    //[self setupTableView];
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
    
    if (self.currencyTable == nil)
        [self setupTableView];
}

- (void)showNewDataInfoMessage {
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.frame = CGRectMake(60, 10, 200, 44);
    infoButton.alpha = 0.0;
    [infoButton addTarget:self action:@selector(refreshTableData:) forControlEvents:UIControlEventTouchUpInside];
    [infoButton setTitle:@"Refresh" forState:UIControlStateNormal];
    
    [self.view addSubview:infoButton];
    
    [UIView animateWithDuration:0.8 animations:^{
        infoButton.alpha = 1.0;
    }];
}

- (void)refreshTableData:(UIButton *)refreshButton {
    [refreshButton removeFromSuperview];
    [self.currencyTable reloadData];
}

- (void)setupTableView {
    self.currencyTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.screenHeight-64)];
    [self.currencyTable setDelegate:self];
    [self.currencyTable setDataSource:self];
    
    [self.currencyTable registerClass:[CurrencyCell class] forCellReuseIdentifier:@"CurrencyExchange"];
    
    [self.view addSubview:self.currencyTable];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurrencyExchange"];
    cell.textField.delegate = self;
    
    NSString *currencySymbol = [self.downloader.currencySymbols objectAtIndex:indexPath.row];
    
    NSString *currencyName = [NSString stringWithFormat:@"%@ - %@",
                              currencySymbol,
                              [self.downloader.currencyNames objectAtIndex:indexPath.row]
                              ];
    
    cell.currencySymbolLabel.text = currencyName;
        
    cell.currencyImage.image = [UIImage imageNamed:currencySymbol];
    
    cell.textField.text = self.downloader.currencyValues[indexPath.row];
    
    if (indexPath.row > 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textField.alpha = 0.0;
    }
    
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.alpha = 1.0;
    }
    
    [cell.textField addTarget:self
                       action:@selector(textFieldTextHasChanged:)
             forControlEvents:UIControlEventEditingChanged];
    
    cell.valueLabel.text = self.downloader.currencyValues[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *currency = self.downloader.currencySymbols[indexPath.row];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (indexPath.row != 0) {
        NSArray *array = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:indexPath.row inSection:0] , nil];
        
        NSString *symbolToReplace = [self.downloader.currencySymbols objectAtIndex:0];
        NSString *replacementSymbol = [self.downloader.currencySymbols objectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        
        [self.downloader.currencySymbols setObject:symbolToReplace atIndexedSubscript:indexPath.row];
        [self.downloader.currencySymbols setObject:replacementSymbol atIndexedSubscript:0];
        
        symbolToReplace = [self.downloader.currencyNames objectAtIndex:0];
        replacementSymbol = [self.downloader.currencyNames objectAtIndex:indexPath.row];
        
        [self.downloader.currencyNames setObject:symbolToReplace atIndexedSubscript:indexPath.row];
        [self.downloader.currencyNames setObject:replacementSymbol atIndexedSubscript:0];
        
        symbolToReplace = [self.downloader.currencyValues objectAtIndex:0];
        replacementSymbol = [self.downloader.currencyValues objectAtIndex:indexPath.row];
        
        [self.downloader.currencyValues setObject:symbolToReplace atIndexedSubscript:indexPath.row];
        [self.downloader.currencyValues setObject:replacementSymbol atIndexedSubscript:0];
        
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        
        [tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
        
        [tableView endUpdates];
        
        CurrencyCell *cell = (CurrencyCell *)[tableView cellForRowAtIndexPath:
                                              [NSIndexPath indexPathForRow:0
                                                                 inSection:0]
                                              ];
        [cell.textField becomeFirstResponder];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloader.currencySymbols.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    NSIndexPath *cellPath = [self.currencyTable indexPathForCell:cell];
    cellPath = [NSIndexPath indexPathForRow:self.downloader.currencyValues.count-cellPath.row inSection:0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldTextHasChanged:(UITextField *)textField {
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    NSString *currencySymbol = [cell.currencySymbolLabel.text substringToIndex:3];
    
    self.editingCurrency = currencySymbol;
    
    [self updateValuesFrom:currencySymbol withAmount:textField.text];
    
}

- (void)updateValuesFrom:(NSString *)currencySymbol withAmount:(NSString *)amount{
    NSInteger initialCurrencyIndex = [self getIndexForSymbol:currencySymbol];
    self.downloader.currencyValues[initialCurrencyIndex] = amount;
    
    CGFloat amountToConvert = amount.floatValue;
    
    for (NSString *symbol in self.downloader.currencySymbols) {
        if (![symbol isEqualToString:currencySymbol]) {
            NSString *currencyPair = [NSString stringWithFormat:@"%@%@", currencySymbol, symbol];
            NSInteger indexToUpdate = [self getIndexForSymbol:symbol];
            CGFloat forexRate = ((NSString *)[self.downloader.forex valueForKey:currencyPair]).floatValue;
            
            CGFloat result = amountToConvert * forexRate;
            
            self.downloader.currencyValues[indexToUpdate] = [NSString stringWithFormat:@"%.4f", result];
        }
    }
    
    if (![self.editingCurrency isEqualToString:@""]) {
        [self reloadTextFields];
        //[self.keyboardHackTextField becomeFirstResponder];
        //[self.currencyTable reloadData];
    }
    
    //NSLog(@"%@, %d", currencySymbol, [self getIndexForSymbol:currencySymbol]);
}

- (void)reloadTextFields {
    for (int i = 0; i < self.downloader.currencyValues.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        
        CurrencyCell *cell = (CurrencyCell *)[self.currencyTable cellForRowAtIndexPath:path];
        
        cell.textField.text = self.downloader.currencyValues[i];
        cell.valueLabel.text = self.downloader.currencyValues[i];
    }
}

- (NSInteger)getIndexForSymbol:(NSString *)symbol {
    for (int i = 0; i < self.downloader.currencySymbols.count; i++) {
        if ([self.downloader.currencySymbols[i] isEqualToString:symbol])
            return i;
    }
    
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
