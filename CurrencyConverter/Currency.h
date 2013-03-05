//
//  Currency.h
//  CurrencyConverter
//
//  Created by Sorin Cioban on 05/03/2013.
//  Copyright (c) 2013 Sorin Cioban. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject

@property (strong) NSString *symbol;
@property (strong) NSString *name;
@property (strong) NSString *value;

- (Currency *)initWithSymbol:(NSString *)symbol name:(NSString *)name andValue:(NSString *)value;

@end
