//
//  CurrencyDownloader.h
//  CurrencyConverter
//
//  Created by Sorin Cioban on 04/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyDownloader : NSObject

@property (strong) NSMutableArray *currencyNames;
@property (strong) NSMutableArray *currencySymbols;
@property (strong) NSMutableArray *currencyPairs;
@property (strong) NSMutableArray *currencies;
@property (strong) NSMutableDictionary *rates;
@property (nonatomic, weak) id delegate;
- (void)initDownloader;
- (BOOL)hasInternetConnection;
- (void)initCurrencyPairs;
- (void)getECBExchangeRates;
- (void)resetTableForMainCurrency;

@end

@protocol CurrencyDownloaderDelegate

- (void)unableToDownload;
- (void)downloadCompleted;
- (void)showOldData;
- (void)noNewData;
- (void)resetTable;
- (NSString *)getMainCurrency;

@end
