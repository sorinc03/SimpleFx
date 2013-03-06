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
@property (strong) UIImageView *refreshImageView;
@property (strong) NavigationBarTitleView *titleView;

@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *pullToRefreshLabel;
@property (nonatomic, retain) UIImageView *refreshImage;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@property BOOL isPulling;
@property BOOL isDownloading;

@end

@implementation ConverterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupURLMappings];
    
    self.titleView = [[NavigationBarTitleView alloc] initWithNavBarFrame:self.navigationController.navigationBar.frame];
    
    self.navigationItem.titleView = self.titleView;
    
    self.editingCurrency = @"";
        
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.downloader = [[CurrencyDownloader alloc] init];
    self.downloader.delegate = self;
    
    [self setupInitialRefreshAnimation];
    [self.downloader initDownloader];
    
    [self addPullToRefreshHeader];
    [self setupStrings];
    self.isDownloading = NO;
    self.isPulling = NO;
    
        
    
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)setupInitialRefreshAnimation {
    self.refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 10, 25, 26)];
    self.refreshImageView.image = [UIImage imageNamed:@"01-refresh"];
    
    [self.view addSubview:self.refreshImageView];
    
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0.0f];
    rotation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotation.duration = 10;
    rotation.repeatCount = 5000;
    
    [self.refreshImageView.layer addAnimation:rotation forKey:@"360"];
    
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
    
    [self setupStrings];
    if (self.isDownloading) {
        [self stopLoading];
    }
    
    else {
        if (self.currencyTable == nil)
            [self setupTableView];
        
        else {
            UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTableData:)];
            self.navigationItem.rightBarButtonItem = shareButton;
            
            self.titleView.subtitleLabel.text = @"Tap refresh button to refresh table";
            
            [self.refreshImageView removeFromSuperview];
        }
        
        //[self.titleView showTitleOnly];
    }
}

- (void)refreshTableData:(id)refreshButton {
    self.navigationItem.rightBarButtonItem = nil;
    self.titleView.subtitleLabel.text = self.lastUpdated;
    [self.currencyTable reloadData];
}

- (void)setupTableView {
    self.currencyTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.screenHeight-64)];
    [self.currencyTable setDelegate:self];
    [self.currencyTable setDataSource:self];
    
    [self.currencyTable registerClass:[CurrencyCell class] forCellReuseIdentifier:@"CurrencyExchange"];
    
    [self.view insertSubview:self.currencyTable belowSubview:self.refreshImageView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurrencyExchange"];
    cell.textField.delegate = self;
    
    Currency *c = (Currency *)self.downloader.currencies[indexPath.row];
    
    NSString *currencyName = [NSString stringWithFormat:@"%@ - %@", c.symbol, c.name];
    
    cell.currencySymbolLabel.text = currencyName;
        
    cell.currencyImage.image = [UIImage imageNamed:c.symbol];
    
    cell.textField.text = c.value;
    
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
    
    cell.valueLabel.text = c.value;
    
    if (indexPath.row == 0) {
        UITextFieldAccessoryView *accessoryView = [[UITextFieldAccessoryView alloc]
                                                   initWithFrame:CGRectMake(0, self.screenHeight-44, 320, 44)
                                                   andTextField:cell.textField];
        
        [cell.textField setInputAccessoryView:accessoryView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //NSString *currency = self.downloader.currencySymbols[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (indexPath.row != 0) {
        NSArray *array = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:indexPath.row inSection:0] , nil];
        
        Currency *currencyToReplace = (Currency *)[self.downloader.currencies objectAtIndex:0];
        Currency *replacementCurrency = (Currency *)[self.downloader.currencies objectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        
        [self.downloader.currencies setObject:currencyToReplace atIndexedSubscript:indexPath.row];
        [self.downloader.currencies setObject:replacementCurrency atIndexedSubscript:0];
        
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
    return self.downloader.currencies.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    NSIndexPath *cellPath = [self.currencyTable indexPathForCell:cell];
    cellPath = [NSIndexPath indexPathForRow:self.downloader.currencies.count-cellPath.row inSection:0];
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
        
        CurrencyCell *cell = (CurrencyCell *)[self.currencyTable cellForRowAtIndexPath:path];
        
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

- (void)setupStrings{
    self.lastUpdated = [self.downloader.forex valueForKey:@"lastUpdated"];
    if (self.lastUpdated == nil) {
        self.lastUpdated = @"Never";
    }
    
    self.lastUpdated = [NSString stringWithFormat:@"Last updated: %@", self.lastUpdated];
    
    self.textPull = @"Pull down to refresh...";
    
    self.textRelease = @"Release to refresh...";
    self.textLoading = @"Loading...";
}

- (void)addPullToRefreshHeader {
    self.refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEIGHT, 320, REFRESH_HEIGHT)];
    self.refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    self.pullToRefreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEIGHT)];
    self.pullToRefreshLabel.backgroundColor = [UIColor clearColor];
    self.pullToRefreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.pullToRefreshLabel.textAlignment = NSTextAlignmentCenter;
    self.pullToRefreshLabel.numberOfLines = 2;
    
    self.refreshImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"02-redo.png"]];
    self.refreshImage.frame = CGRectMake(45, 15, 30, 25);
    
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner.frame = CGRectMake(50, floorf((REFRESH_HEIGHT - 20) / 2), 20, 20);
    self.refreshSpinner.hidesWhenStopped = YES;
    
    [self.refreshHeaderView addSubview:self.pullToRefreshLabel];
    [self.refreshHeaderView addSubview:self.refreshImage];
    [self.refreshHeaderView addSubview:self.refreshSpinner];
    [self.currencyTable addSubview:self.refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isDownloading)
        return;
    self.isPulling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isDownloading)
        return;
    
    self.isPulling = NO;
    
    if (scrollView.contentOffset.y <= -REFRESH_HEIGHT) {
        [self startLoading];
    }
}

- (void)startLoading {
    self.isDownloading = YES;
    
    if (self.navigationItem.rightBarButtonItem != nil)
        self.navigationItem.rightBarButtonItem = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.currencyTable.contentInset = UIEdgeInsetsMake(REFRESH_HEIGHT, 0, 0, 0);
        self.pullToRefreshLabel.text = self.textLoading;
        self.refreshImage.hidden = YES;
        [self.refreshSpinner startAnimating];
    }];
    
    if ([self.downloader hasInternetConnection])
        [self.downloader getTodaysExchangeRates];
}

- (void)unableToDownload {
    [self.refreshImageView removeFromSuperview];
    self.isDownloading = NO;
    [self stopLoading];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Please check your internet connection and try again"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
    
    [alert show];
}

- (void)stopLoading {
    self.isDownloading = NO;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.currencyTable.contentInset = UIEdgeInsetsZero;
                         [self.refreshImage layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }
     ];
}

- (void)stopLoadingComplete {
    self.titleView.subtitleLabel.text = self.lastUpdated;
    self.pullToRefreshLabel.text = self.textPull;
    self.refreshImage.hidden = NO;
    [self.refreshSpinner stopAnimating];
    [self.currencyTable reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isDownloading) {
        if (scrollView.contentOffset.y > 0)
            self.currencyTable.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEIGHT)
            self.currencyTable.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (self.isPulling && scrollView.contentOffset.y < 0) {
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEIGHT) {
                self.pullToRefreshLabel.text = self.textRelease;
                [self.refreshImage layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            }
            
            else {
                self.pullToRefreshLabel.text = self.textPull;
                [self.refreshImage layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
