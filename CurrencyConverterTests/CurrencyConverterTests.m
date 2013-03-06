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

- (void)testCurrencyAllocation {
    Currency *c = [[Currency alloc] initWithSymbol:@"CNY" name:@"Yuan" andValue:@"1.0"];
    STAssertTrue([c.name isEqualToString:@"Yuan"], @"Property allocation works");
    
}

@end
