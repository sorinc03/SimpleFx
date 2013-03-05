//
//  CurrencyDownloader.h
//  CurrencyConverter
//
//  Created by Sorin Cioban on 04/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyDownloader : NSObject

@property (strong) NSMutableArray *currencySymbols;
@property (strong) NSMutableArray *currencyNames;
@property (strong) NSMutableArray *currencyValues;
@property (strong) NSMutableArray *currencyPairs;
@property (strong) NSMutableDictionary *forex;
@property (nonatomic, weak) id delegate;
- (void)initDownloader;
- (void)getTodaysExchangeRates;

@end

@protocol CurrencyDownloaderDelegate

- (void)showNewDataInfoMessage;
- (void)downloadCompleted;
- (void)showOldData;

@end
