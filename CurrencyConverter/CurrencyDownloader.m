//
//  CurrencyDownloader.m
//  CurrencyConverter
//
//  Created by Sorin Cioban on 04/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "CurrencyDownloader.h"
#import "Currency.h"
#import "Reachability.h"

@interface CurrencyDownloader ()

@property (strong) NSMutableArray *currencySymbols;
@property (strong) NSMutableArray *currencyNames;
@property (strong) NSMutableArray *currencyValues;
@property (strong) NSMutableArray *currencyPairs;
@property (strong) Reachability *reachability;

@end

@implementation CurrencyDownloader

- (void)initDownloader {
    self.reachability = [Reachability reachabilityForInternetConnection];
    
    self.currencies = [[NSMutableArray alloc] init];
    
    [self getSymbolsAndNames];
    [self initCurrencyPairs];
    [self saveSymbolsAndNames];
    [self setupCurrencies];
    [self clearSymbolsAndNames];    
    
    NSUserDefaults *storedData = [NSUserDefaults standardUserDefaults];
    
    self.forex = [storedData valueForKey:@"exchangeRates"];
    
    if (self.forex.count > 0) {
        [self.delegate showOldData];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([self hasInternetConnection])
        [self getTodaysExchangeRates];
}

- (BOOL)hasInternetConnection {
    NetworkStatus internetStatus = [self.reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) {
        [self.delegate unableToDownload];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return NO;
    }
    
    else if (internetStatus != ReachableViaWiFi && internetStatus != ReachableViaWWAN) {
        [self.delegate unableToDownload];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return NO;
    }
    
    return YES;
}

- (void)getSymbolsAndNames {
    NSUserDefaults *storedData = [NSUserDefaults standardUserDefaults];
    
    self.currencySymbols = [storedData valueForKey:@"currencySymbols"];
    
    if (self.currencySymbols == nil)
        self.currencySymbols = [[NSMutableArray alloc] initWithArray:@[@"EUR", @"USD", @"GBP", @"INR", @"AUD", @"CAD", @"AED", @"JPY"]];
    
    self.currencyNames = [storedData valueForKey:@"currencyNames"];
    
    if (self.currencyNames == nil)
        self.currencyNames = [[NSMutableArray alloc] initWithArray:@[@"Euro", @"US Dollar", @"British Pound", @"Indian Rupee", @"Australian Dollar", @"Canadian Dollar", @"Emirate Dirham", @"Japanese Yen"]];
}

- (void)clearSymbolsAndNames {
    self.currencySymbols = nil;
    self.currencyNames = nil;
}

- (void)setupCurrencies {
    NSString *value = @"1.0";
    
    for (int i = 0; i < self.currencyNames.count; i++) {
        Currency *c = [[Currency alloc] initWithSymbol:self.currencySymbols[i]
                                                  name:self.currencyNames[i]
                                              andValue:value];
        
        value = @"0.0";
        
        [self.currencies addObject:c];
    }
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
             
             BOOL newRates = [self areNewRates:todayRates];
             if (newRates || self.forex.count == 0) {
                 self.forex = [[NSMutableDictionary alloc] initWithObjects:todayRates forKeys:self.currencyPairs];
                 
                 NSString *date = [NSString stringWithFormat:@"%@", [self formattedDate]];
                 
                 [self.forex setValue:date forKey:@"lastUpdated"];
             
                 array = nil;
             
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self saveRates];
                     
                     [self.delegate downloadCompleted];
                     
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }];
             }
         } else if ([data length] == 0 && error == nil){
             //[self emptyReply];
         } else if (error != nil && error.code == NSURLErrorTimedOut){ //used this NSURLErrorTimedOut from foundation error responses
             //[self timedOut];
         } else if (error != nil){
             //[self downloadError:error];
         }
     }];
}

- (NSString *)formattedDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd.MM.yyy HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (BOOL)areNewRates:(NSMutableArray *)todayRates {
    for (int i = 0; i < todayRates.count; i++) {
        NSString *local = [self.forex valueForKey:self.currencyPairs[i]];
        NSString *new = todayRates[i];
        
        if ([local isEqualToString:new]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)saveSymbolsAndNames {
    [[NSUserDefaults standardUserDefaults] setValue:self.currencySymbols forKey:@"currencySymbols"];
    [[NSUserDefaults standardUserDefaults] setValue:self.currencyNames forKey:@"currencyNames"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveRates {
    [[NSUserDefaults standardUserDefaults] setValue:self.forex forKey:@"exchangeRates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
