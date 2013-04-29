/*
 File: Currency.m
 
 The Currency class is used to provide a Currency object containing the name, symbol and curent value for 
 a given currency
 */

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
