//
//  ViewController.m
//  CurrencyConverter
//
//  Created by Sorin Cioban on 02/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "ConverterViewController.h"
#import "CurrencyCell.h"

@interface ConverterViewController ()

@property (nonatomic) CGFloat screenHeight;
@property (strong) UIPickerView *picker;
@property (strong) NSArray *currencies;
@property (strong) NSMutableArray *currencyPairs;
@property (strong) NSMutableDictionary *forex;
@property (strong) UITableView *currencyTable;

@end

@implementation ConverterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currencies = @[@"EUR", @"USD", @"GBP", @"INR", @"AUD", @"CAD", @"AED", @"JPY"];
    
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    [self initCurrencyPairs];
    
    [self getTodaysExchangeRates];
    
    [self setupTableView];
}

- (void)initCurrencyPairs {
    self.forex = [[NSMutableDictionary alloc] init];
    self.currencyPairs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.currencies.count; i++) {
        NSString *firstCurrency = self.currencies[i];
        for (int j = i+1; j < self.currencies.count; j++) {
            NSString *currencyPair = [NSString stringWithFormat:@"%@%@", firstCurrency, self.currencies[j]];
            if (currencyPair.length > 0)
                [self.currencyPairs addObject:currencyPair];
        }
    }
}

- (void)getTodaysExchangeRates {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSString *apiString = @"http://quote.yahoo.com/d/quotes.csv?f=l1";
    
    for (int i = 0; i < self.currencyPairs.count; i++) {
        NSString *stringToInsertToAPI = [NSString stringWithFormat:@"&s=%@=X", self.currencyPairs[i]];
        
        apiString = [apiString stringByAppendingString:stringToInsertToAPI];
    }
    
    NSURL *url = [NSURL URLWithString:apiString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60.0];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             NSString *exchangeRates = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
             exchangeRates = [exchangeRates stringByTrimmingCharactersInSet:charSet];
             
             NSMutableArray *array = [exchangeRates componentsSeparatedByCharactersInSet:charSet].copy;
             
             NSMutableArray *todayRates = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < array.count; i+=2) {
                 [todayRates addObject:array[i]];
             }
             self.forex = [[NSMutableDictionary alloc] initWithObjects:todayRates forKeys:self.currencyPairs];
             
             array = nil;
             
             [self.currencyTable reloadData];
             
             NSLog(@"%@", self.forex);
         }else if ([data length] == 0 && error == nil){
             //[self emptyReply];
         }else if (error != nil && error.code == NSURLErrorTimedOut){ //used this NSURLErrorTimedOut from foundation error responses
             //[self timedOut];
         }else if (error != nil){
             //[self downloadError:error];
         }
     }];

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
    
    NSString *currencyPair = [self.currencyPairs objectAtIndex:indexPath.row];
    cell.leftCurrency.text = [currencyPair substringToIndex:3];
    cell.rightCurrency.text = [currencyPair substringFromIndex:3];
    
    CGFloat rate = ((NSString *)[self.forex valueForKey:currencyPair]).floatValue;
    
    cell.leftRightExRate.text = [NSString stringWithFormat:@"%.2f", rate];
    
    CGFloat revRate = 1/rate;
    
    cell.rightLeftExRate.text = [NSString stringWithFormat:@"%.3f", revRate];
    
    cell.leftCurrencyImage.image = [UIImage imageNamed:cell.leftCurrency.text];
    cell.rightCurrencyImage.image = [UIImage imageNamed:cell.rightCurrency.text];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*NSArray *array = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    NSArray *array2 = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil];
    [tableView beginUpdates];
    [self.forex removeObjectForKey:@"USDGBP"];
    [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
    //[tableView insertRowsAtIndexPaths:array2 withRowAnimation:UITableViewRowAnimationBottom];
    
    [tableView endUpdates];*/
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.forex.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
