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
@property (strong) NSMutableArray *currencySymbols;
@property (strong) NSMutableArray *currencyNames;
@property (strong) NSMutableArray *currencyValues;
@property (strong) NSMutableArray *currencyPairs;
@property (strong) NSMutableDictionary *forex;
@property (strong) UITableView *currencyTable;
@property (strong) NSString *editingCurrency;

@end

@implementation ConverterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currencySymbols = [[NSMutableArray alloc] initWithArray:@[@"EUR", @"USD", @"GBP", @"INR", @"AUD", @"CAD", @"AED", @"JPY"]];
    self.currencyNames = [[NSMutableArray alloc] initWithArray:@[@"Euro", @"US Dollar", @"British Pound", @"Indian Rupee", @"Australian Dollar", @"Canadian Dollar", @"Emirate Dirham", @"Japanese Yen"]];
    self.currencyValues = [NSMutableArray arrayWithCapacity:self.currencySymbols.count];
    
    self.editingCurrency = @"";
    
    for (int i = 0; i < self.currencyValues.count; i++) {
        self.currencyValues[i] = @"";
    }
    self.currencyValues[0] = @"1.0";
    
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
    [self initCurrencyPairs];
    
    [self getTodaysExchangeRates];
    
    //[self setupTableView];
}

- (void)initCurrencyPairs {
    self.forex = [[NSMutableDictionary alloc] init];
    self.currencyPairs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.currencySymbols.count; i++) {
        NSString *firstCurrency = self.currencySymbols[i];
        for (int j = 0; j < self.currencySymbols.count; j++) {
            if (![self.currencySymbols[j] isEqualToString:firstCurrency]) {
                NSString *currencyPair = [NSString stringWithFormat:@"%@%@", firstCurrency, self.currencySymbols[j]];
                if (currencyPair.length > 0)
                    [self.currencyPairs addObject:currencyPair];
            }
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
                 [self updateValuesFrom:@"EUR" withAmount:@"1.0"];
                 
                 [self setupTableView];
                 //[self.currencyTable reloadData];
             }];
             
             NSLog(@"%@", self.forex);
         } else if ([data length] == 0 && error == nil){
             //[self emptyReply];
         } else if (error != nil && error.code == NSURLErrorTimedOut){ //used this NSURLErrorTimedOut from foundation error responses
             //[self timedOut];
         } else if (error != nil){
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
    
    NSString *currencyName = [NSString stringWithFormat:@"%@ - %@",
                              currencySymbol,
                              [self.currencyNames objectAtIndex:indexPath.row]
                              ];
    
    cell.currencySymbolLabel.text = currencyName;
        
    cell.currencyImage.image = [UIImage imageNamed:currencySymbol];
    
    cell.textField.text = self.currencyValues[indexPath.row];
    
    if (indexPath.row > 0) {
        //cell.textField.enabled = NO;
    }
    
    [cell.textField addTarget:self
                       action:@selector(textFieldTextHasChanged:)
             forControlEvents:UIControlEventEditingChanged];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*NSArray *array = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    NSArray *array2 = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil];
    [tableView beginUpdates];
    [self.forex removeObjectForKey:@"USDGBP"];
    [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
    //[tableView insertRowsAtIndexPaths:array2 withRowAnimation:UITableViewRowAnimationBottom];*/
    
    if (indexPath.row != 0) {
        NSArray *array = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:indexPath.row inSection:0] , nil];
        
        NSString *symbolToReplace = [self.currencySymbols objectAtIndex:0];
        NSString *replacementSymbol = [self.currencySymbols objectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        
        [self.currencySymbols setObject:symbolToReplace atIndexedSubscript:indexPath.row];
        [self.currencySymbols setObject:replacementSymbol atIndexedSubscript:0];
        
        symbolToReplace = [self.currencyNames objectAtIndex:0];
        replacementSymbol = [self.currencyNames objectAtIndex:indexPath.row];
        
        [self.currencyNames setObject:symbolToReplace atIndexedSubscript:indexPath.row];
        [self.currencyNames setObject:replacementSymbol atIndexedSubscript:0];
        
        symbolToReplace = [self.currencyValues objectAtIndex:0];
        replacementSymbol = [self.currencyValues objectAtIndex:indexPath.row];
        
        [self.currencyValues setObject:symbolToReplace atIndexedSubscript:indexPath.row];
        [self.currencyValues setObject:replacementSymbol atIndexedSubscript:0];
        
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
        
        [tableView endUpdates];
    }
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
    //NSLog(@"%@", textField.text);
    CurrencyCell *cell = (CurrencyCell *)textField.superview;
    NSIndexPath *cellPath = [self.currencyTable indexPathForCell:cell];
    cellPath = [NSIndexPath indexPathForRow:self.currencyValues.count-cellPath.row inSection:0];
    //CGFloat heightIndex = cell.frame.size.height * (self.currencyValues.count-cellPath.row);
    //[self.currencyTable setContentOffset:CGPointMake(0, heightIndex) animated:YES];
    //[self.currencyTable scrollToRowAtIndexPath:cellPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    self.currencyValues[initialCurrencyIndex] = amount;
    
    CGFloat amountToConvert = amount.floatValue;
    
    for (NSString *symbol in self.currencySymbols) {
        if (![symbol isEqualToString:currencySymbol]) {
            NSString *currencyPair = [NSString stringWithFormat:@"%@%@", currencySymbol, symbol];
            NSInteger indexToUpdate = [self getIndexForSymbol:symbol];
            CGFloat forexRate = ((NSString *)[self.forex valueForKey:currencyPair]).floatValue;
            
            CGFloat result = amountToConvert * forexRate;
            
            self.currencyValues[indexToUpdate] = [NSString stringWithFormat:@"%.3f", result];
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
    for (int i = 0; i < self.currencyValues.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        
        CurrencyCell *cell = (CurrencyCell *)[self.currencyTable cellForRowAtIndexPath:path];
        
        cell.textField.text = self.currencyValues[i];
    }
}

- (NSInteger)getIndexForSymbol:(NSString *)symbol {
    for (int i = 0; i < self.currencySymbols.count; i++) {
        if ([self.currencySymbols[i] isEqualToString:symbol])
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
