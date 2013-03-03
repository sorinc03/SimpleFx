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
@property (strong) NSArray *currencySymbols;
@property (strong) NSArray *currencyNames;
@property (strong) NSMutableArray *currencyValues;
@property (strong) NSMutableArray *currencyPairs;
@property (strong) NSMutableDictionary *forex;
@property (strong) UITableView *currencyTable;

@end

@implementation ConverterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currencySymbols = @[@"EUR", @"USD", @"GBP", @"INR", @"AUD", @"CAD", @"AED", @"JPY"];
    self.currencyNames = @[@"Euro", @"US Dollar", @"British Pound", @"Indian Rupee", @"Australian Dollar", @"Canadian Dollar", @"Emirate Dirham", @"Japanese Yen"];
    self.currencyValues = [NSMutableArray arrayWithCapacity:self.currencySymbols.count];
    self.currencyValues[0] = @"1.0";
    
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    [self initCurrencyPairs];
    
    [self getTodaysExchangeRates];
    
    [self setupTableView];
}

- (void)initCurrencyPairs {
    self.forex = [[NSMutableDictionary alloc] init];
    self.currencyPairs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.currencySymbols.count; i++) {
        NSString *firstCurrency = self.currencySymbols[i];
        for (int j = i+1; j < self.currencySymbols.count; j++) {
            NSString *currencyPair = [NSString stringWithFormat:@"%@%@", firstCurrency, self.currencySymbols[j]];
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
             
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [self.currencyTable reloadData];
             }];
             
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
    cell.textField.delegate = self;
    
    NSString *currencySymbol = [self.currencySymbols objectAtIndex:indexPath.row];
    
    NSString *currencyValueKey = [NSString stringWithFormat:@"EUR%@", currencySymbol];
    
    NSString *currencyName = [NSString stringWithFormat:@"%@ - %@",
                              currencySymbol,
                              [self.currencyNames objectAtIndex:indexPath.row]
                              ];
    
    cell.currencySymbolLabel.text = currencyName;
        
    cell.currencyImage.image = [UIImage imageNamed:currencySymbol];
    
    if ([currencySymbol isEqualToString:@"EUR"]) {
        cell.textField.text = @"1.0";
    }
    else {
        cell.textField.text = [self.forex valueForKey:currencyValueKey];
    }
    
    if (cell.textField.text != nil)
        self.currencyValues[indexPath.row] = cell.textField.text;
    
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
    return self.currencySymbols.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"%@", textField.text);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
