
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
@property (strong) NSDateFormatter *dateFormatter;

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
    
    NSUserDefaults *storedData = [NSUserDefaults standardUserDefaults];
    
    self.rates = [storedData valueForKey:@"rates"];
    
    if (self.rates.count > 0) {
        [self.delegate showOldData];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    [self.dateFormatter setDateFormat:@"dd.MM.yyy HH:mm"];
    
    if ([self hasInternetConnection])
        [self getECBExchangeRates];
}

/*
 The getSymbolsAndNames function is called from initDownloader and is used to retrieve data from NSUserDefaults.
 */
- (void)getSymbolsAndNames {
    NSUserDefaults *storedData = [NSUserDefaults standardUserDefaults];
    
    self.currencySymbols = [storedData valueForKey:@"currencySymbols"];
    
    if (self.currencySymbols == nil)
        self.currencySymbols = [[NSMutableArray alloc] init];
    
    self.currencyNames = [storedData valueForKey:@"currencyNames"];
    
    if (self.currencyNames == nil)
        self.currencyNames = [[NSMutableArray alloc] init];
    
    if (self.currencyNames.count && self.currencySymbols.count) {
        [self setupCurrencies];
    }
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
    self.currencies = [[NSMutableArray alloc] init];
    NSString *value = @"1.0";
    
    bool getValueFromRates = self.rates.count == self.currencySymbols.count+1 ? YES : NO;
    
    for (int i = 0; i < self.currencySymbols.count; i++) {
        if (getValueFromRates) {
            value = [self.rates valueForKey:self.currencySymbols[i]];
            NSString *mainCurrencyRate = [self.rates valueForKey:[self.delegate getMainCurrency]];
            
            value = [NSString stringWithFormat:@"%.4f", value.floatValue/mainCurrencyRate.floatValue];
        }
        
        Currency *c = [[Currency alloc] initWithSymbol:self.currencySymbols[i]
                                                  name:self.currencyNames[i]
                                              andValue:value];
        
        
        [self.currencies addObject:c];
    }
}

- (void)resetTableForMainCurrency {
    NSMutableDictionary *names = [[NSMutableDictionary alloc] initWithObjects:self.currencyNames forKeys:self.currencySymbols];
    
    [self orderTableForMainCurrency:self.rates forNames:names];
    
    [self saveSymbolsAndNames];
    
    [self setupCurrencies];
    
    [self.delegate resetTable];
}

/*
 The initCurrencyPairs function goes through the list of currencySymbols and sets up pairs (i.e, EURUSD, EURGBP etc.)
 */
- (void)initCurrencyPairs {
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

- (void)getECBExchangeRates {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSString *apiString = @"http://www.airplanesandapps.com/CurrencyApp/currencies.php";
    
    NSURL *url = [NSURL URLWithString:apiString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60.0];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             NSArray *jsonData = [
                                  [
                                   [NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding]
                                  componentsSeparatedByString:@"sep"
                                  ];
             
             NSMutableDictionary *todayRates = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[jsonData[0] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil]];
             [todayRates setValue:@"1.0" forKey:@"EUR"];
             NSMutableDictionary *names = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[jsonData[1] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil]];
             [names setValue:@"Euro" forKey:@"EUR"];
             
             if (self.currencySymbols.count == 0) {
                 [self orderTableForMainCurrency:todayRates forNames:names];
                 
                 [self saveSymbolsAndNames];
             }         
         
             BOOL newRates = [self areNewRates:todayRates];
             
             if (newRates || self.rates.count == 0) {
                 self.rates = [[NSMutableDictionary alloc] initWithDictionary:todayRates];
                 
                 NSString *date = [NSString stringWithFormat:@"%@", [self formattedDate]];
                 
                 [self.rates setValue:date forKey:@"lastUpdated"];
                 
                 if (self.currencyNames.count) {
                     [self setupCurrencies];
                 }
                 
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

- (void)orderTableForMainCurrency:(NSMutableDictionary *)orderRates forNames:(NSMutableDictionary *)names {
    self.currencySymbols = [[NSMutableArray alloc] initWithArray:[[orderRates allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    if ([self.currencySymbols containsObject:@"lastUpdated"])
        [self.currencySymbols removeObject:@"lastUpdated"];
    
    self.currencyNames = [[NSMutableArray alloc] initWithCapacity:self.currencySymbols.count];
    
    int index = 0;
    for (int i = 0; i < self.currencySymbols.count; i++) {
        if ([self.currencySymbols[i] isEqualToString:[self.delegate getMainCurrency]]) {
            index = i;
        }
        
        if ([names valueForKey:self.currencySymbols[i]] != nil) {
            
            [self.currencyNames addObject:[names valueForKey:self.currencySymbols[i]]];
            //NSLog(@"%@", self.currencyNames);
        }
    }
    
    NSString *name = self.currencyNames[index];
    
    NSString *symbol = self.currencySymbols[index];
    
    [self.currencyNames removeObject:name];
    [self.currencySymbols removeObject:symbol];
    
    NSMutableArray *symbolArray = [NSMutableArray arrayWithObject:symbol];
    NSMutableArray *nameArray = [NSMutableArray arrayWithObject:name];
    
    [symbolArray addObjectsFromArray:self.currencySymbols];
    [nameArray addObjectsFromArray:self.currencyNames];
    
    self.currencyNames = nameArray;
    self.currencySymbols = symbolArray;
}

- (BOOL)areNewRates:(NSDictionary *)todayRates {
    for (NSString *key in todayRates.allKeys) {
        if (![[self.rates valueForKey:key] isEqualToString:[todayRates valueForKey:key]]) {
            return YES;
        }
    }
    
    return NO;
}

/*
 noNewData updates the latest "refresh" date in the forex dictionary and it notifies the delegate that the
 latest pulled rates are the same as the previous ones.
 */
- (void)noNewData {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *date = [NSString stringWithFormat:@"%@", [self formattedDate]];
        
        [self.rates setValue:date forKey:@"lastUpdated"];
        
        [self.delegate noNewData];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

/*
 formattedDate returns a string for the current date and time
 */
- (NSString *)formattedDate {
    return [self.dateFormatter stringFromDate:[NSDate date]];
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
    [[NSUserDefaults standardUserDefaults] setValue:self.rates forKey:@"rates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
