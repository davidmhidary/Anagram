//
//  NSString+MD5ofString.m
//  Anagram
//
//  Created by Ashok Choudhary on 04/06/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import "NSString+MD5ofString.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5ofString)



- (NSString *)MD5String {
//    const char *cstr = [self UTF8String];
//    unsigned char result[16];
//    CC_MD5(cstr, strlen(cstr), result);
//    
//    return [NSString stringWithFormat:
//            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//            result[0], result[1], result[2], result[3],
//            result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11],
//            result[12], result[13], result[14], result[15]
//            ];
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1],
            result[2], result[3],
            result[4], result[5],
            result[6], result[7],
            result[8], result[9],
            result[10], result[11],
            result[12], result[13],
            result[14], result[15]
            ];

}

/*
+ (NSDictionary *)anagramMap
{
    static NSDictionary *anagramMap;
//    if (anagramMap != nil)
//        return anagramMap;
    
    // this file is present on Mac OS and other unix variants
    NSString *allWords = [NSString stringWithContentsOfFile:@"/usr/share/dict/words"
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    @autoreleasepool {
        [allWords enumerateLinesUsingBlock:^(NSString *word, BOOL *stop) {
            NSString *key = [word anagramKey];
            if (key == nil)
                return;
            NSMutableArray *keyWords = [map objectForKey:key];
            if (keyWords == nil) {
                keyWords = [NSMutableArray array];
                [map setObject:keyWords forKey:key];
            }
            [keyWords addObject:word];
        }];
    }
    
    anagramMap = map;
    return anagramMap;
}

- (NSString *)anagramKey
{
    NSString *lowercaseWord = [self lowercaseString];
    
    // make sure to take the length *after* lowercase. it might change!
    NSUInteger length = [lowercaseWord length];
    
    // in this case we're only interested in anagrams 4 - 9 characters long
//    if (length < 4 || length > 9)
//        return nil;
    
    unichar sortedWord[length];
    [lowercaseWord getCharacters:sortedWord range:(NSRange){0, length}];
    
    qsort_b(sortedWord, length, sizeof(unichar), ^int(const void *aPtr, const void *bPtr) {
        int a = *(const unichar *)aPtr;
        int b = *(const unichar *)bPtr;
        return b - a;
    });
    
    return [NSString stringWithCharacters:sortedWord length:length];
}

- (NSSet *)findAnagrams
{
    unichar nineCharacters[9];
    NSString *anagramKey = [self anagramKey];
    
    // make sure this word is not too long/short.
    if (anagramKey == nil)
        return nil;
    [anagramKey getCharacters:nineCharacters range:(NSRange){0, 9}];
    NSUInteger middleCharPos = [anagramKey rangeOfString:[self substringWithRange:(NSRange){4, 1}]].location;
    
    NSMutableSet *anagrams = [NSMutableSet set];
    
    // 0x1ff means first 9 bits set: one for each character
    for (NSUInteger i = 0; i <= 0x1ff; i += 1) {
        
        // skip permutations that do not contain the middle letter
        if ((i & (1 << middleCharPos)) == 0)
            continue;
        
        NSUInteger length = 0;
        unichar permutation[9];
        for (int bit = 0; bit <= 9; bit += 1) {
            if (i & (1 << bit)) {
                permutation[length] = nineCharacters[bit];
                length += 1;
            }
        }
        
        if (length < 4)
            continue;
        
        NSString *permutationString = [NSString stringWithCharacters:permutation length:length];
        NSArray *matchingAnagrams = [[self class] anagramMap][permutationString];
        
        for (NSString *word in matchingAnagrams)
            [anagrams addObject:word];
    }
    
    return anagrams;
}

*/
@end
