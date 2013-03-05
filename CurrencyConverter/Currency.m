//
//  Currency.m
//  CurrencyConverter
//
//  Created by Sorin Cioban on 05/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import "Currency.h"

@implementation Currency

- (Currency *)initWithSymbol:(NSString *)symbol name:(NSString *)name andValue:(NSString *)value {
    self = [super init];
    
    self.symbol = symbol;
    self.name = name;
    self.value = value;
    
    return self;
}

@end
