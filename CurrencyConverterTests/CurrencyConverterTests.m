//
//  CurrencyConverterTests.m
//  CurrencyConverterTests
//
//  Created by Sorin Cioban on 02/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "CurrencyConverterTests.h"
#import "CurrencyDownloader.h"
#import "Currency.h"

@implementation CurrencyConverterTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCurrencyPairCreation {
    CurrencyDownloader *downloader = [[CurrencyDownloader alloc] init];
    
    downloader.currencySymbols = @[@"EUR", @"GBP", @"USD"].copy;
    [downloader initCurrencyPairs];
    
    STAssertTrue([downloader.currencyPairs containsObject:@"EURGBP"], @"Currency pairing works correctly.");
    STAssertTrue(![downloader.currencyPairs containsObject:@"EUREUR"], @"Currencies don't pair themselves (i.e, EUREUR).");
}

@end
