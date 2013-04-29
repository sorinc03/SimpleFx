
/*
 File: CurrencyDownloader.m
 
 The CurrencyDownloader class is used for downloading latest currency data.
 
 Currency data is pulled using the Yahoo Finance API http://quote.yahoo.com/d/quotes.csv?f=l1
 
 This returns a text file with the exchange rate for each given pair on a different line.
 */

#import "CurrencyDownloader.h"
#import "Currency.h"
#import "Reachability.h"

@interface CurrencyDownloader ()

@property (strong) Reachability *reachability;

@end

@implementation CurrencyDownloader

/*
 The initDownloader method initializes the CurrencyDownloader object as well as the objects it contains
 When the app first starts, the most recent set of exchange rates is obtained from NSUserDefaults.
 Then, a new set of data is pulled off the internet
 */
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

/*
 The getSymbolsAndNames function is called from initDownloader and is used to retrieve data from NSUserDefaults.
 */
- (void)getSymbolsAndNames {
    NSUserDefaults *storedData = [NSUserDefaults standardUserDefaults];
    
    self.currencySymbols = [storedData valueForKey:@"currencySymbols"];
    
    if (self.currencySymbols == nil)
        self.currencySymbols = [[NSMutableArray alloc] initWithArray:@[@"EUR", @"USD", @"GBP", @"INR", @"AUD", @"CAD", @"AED", @"JPY"]];
    
    self.currencyNames = [storedData valueForKey:@"currencyNames"];
    
    if (self.currencyNames == nil)
        self.currencyNames = [[NSMutableArray alloc] initWithArray:@[@"Euro", @"US Dollar", @"British Pound", @"Indian Rupee", @"Australian Dollar", @"Canadian Dollar", @"Emirate Dirham", @"Japanese Yen"]];
}

/*
 The clearSymbolsAndNames function cleares the currencySymbols and currencyNames arrays
 */
- (void)clearSymbolsAndNames {
    self.currencySymbols = nil;
    self.currencyNames = nil;
}

/*
 setupCurrencies initialises the currencies array with default values. Default value for EUR will be 1.0, the rest
 will have a default value of 0.0
 */
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

/*
 The initCurrencyPairs function goes through the list of currencySymbols and sets up pairs (i.e, EURUSD, EURGBP etc.)
 */
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

/*
 The hasInternetConnection method returns YES if there is an internet connection available
 and NO if there isn't. In order to check for internet access, the Reachability class is used.
 */
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

/*
 getTodaysExchangeRates sets up an asynchronous request for the latest exchange rate data
 when it finishes, it notifies the CurrencyDownloader delegate that new data has been retrieved
 */
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
                 NSString *rate = array[i];
                 
                 [todayRates addObject:rate];
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
             
             else {
                 [self noNewData];
             }
         } else if ([data length] == 0 && error == nil){
             [self noNewData];
         } else if (error != nil && error.code == NSURLErrorTimedOut) {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [self.delegate unableToDownload];
             }];
         } else if (error != nil){
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [self.delegate unableToDownload];
             }];
         }
     }];
}

/*
 noNewData updates the latest "refresh" date in the forex dictionary and it notifies the delegate that the
 latest pulled rates are the same as the previous ones.
 */
- (void)noNewData {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *date = [NSString stringWithFormat:@"%@", [self formattedDate]];
        
        [self.forex setValue:date forKey:@"lastUpdated"];
        
        [self.delegate noNewData];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

/*
 formattedDate returns a string for the current date and time
 */
- (NSString *)formattedDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd.MM.yyy HH:mm"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

/*
 areNewRates: checks whether the pulled rates are the same as the old ones or different
 */
- (BOOL)areNewRates:(NSMutableArray *)todayRates {
    for (int i = 0; i < todayRates.count; i++) {
        NSString *local = [self.forex valueForKey:self.currencyPairs[i]];
        NSString *new = todayRates[i];
        
        if (![local isEqualToString:new]) {
            return YES;
        }
    }
    
    return NO;
}

/*
 saveSymbolsAndNames stores the currency names and symbols in NSUserDefaults
 */
- (void)saveSymbolsAndNames {
    [[NSUserDefaults standardUserDefaults] setValue:self.currencySymbols forKey:@"currencySymbols"];
    [[NSUserDefaults standardUserDefaults] setValue:self.currencyNames forKey:@"currencyNames"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 saveRates stores the latest currency exchange rates NSUserDefaults
 */
- (void)saveRates {
    [[NSUserDefaults standardUserDefaults] setValue:self.forex forKey:@"exchangeRates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
