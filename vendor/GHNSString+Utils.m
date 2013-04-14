//
//  GHNSString+Utils.m
//
//  Created by Gabe on 3/30/08.
//  Copyright 2008 Gabriel Handford
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "GHNSString+Utils.h"

#import <CommonCrypto/CommonDigest.h>

//! @cond DEV

@protocol GHKit_NSString_GTMRegex
- (NSString *)gtm_stringByReplacingMatchesOfPattern:(NSString *)pattern withReplacement:(NSString *)replacementPattern;
@end

//! @endcond

@implementation NSString(GHUtils)

+ (id)gh_stringWithFormat:(NSString *)format arguments:(NSArray *)arguments {
  char *argList = (char *)malloc(sizeof(NSString *) * [arguments count]);
  [arguments getObjects:(id *)argList];
  NSString *result = [[[NSString alloc] initWithFormat:format arguments:(void *)argList] autorelease];
  free(argList);
  return result;
}

- (NSString *)gh_strip {
  return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)gh_rightStrip {
  if (![self respondsToSelector:@selector(gtm_stringByReplacingMatchesOfPattern:withReplacement:)])
    [NSException raise:NSDestinationInvalidException format:@"This method required GTMRegexAdditions from GTMRegex."];
  return [(id)self gtm_stringByReplacingMatchesOfPattern:@"[ \t]+$" withReplacement:@""];
}

- (NSString *)gh_leftStrip {
  if (![self respondsToSelector:@selector(gtm_stringByReplacingMatchesOfPattern:withReplacement:)])
    [NSException raise:NSDestinationInvalidException format:@"This method required GTMRegexAdditions from GTMRegex."];

	return [(id)self gtm_stringByReplacingMatchesOfPattern:@"^[ \t]+" withReplacement:@""];
}

- (BOOL)gh_isBlank {
  return ([@"" isEqualToString:[self gh_strip]]);
}

+ (BOOL)gh_isBlank:(NSString *)s {
  if (!s) return YES;
  return [s gh_isBlank];
}

- (BOOL)gh_isEqualIgnoreCase:(NSString *)s {
	return [self compare:s options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

#if !TARGET_OS_IPHONE
static NSDictionary *gh_gTruncateMiddle = nil;

- (NSAttributedString *)gh_truncateMiddle {
  if (!gh_gTruncateMiddle) {
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByTruncatingMiddle];
    gh_gTruncateMiddle = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
		[style release];
  }
 
  return [[[NSAttributedString alloc] initWithString:self attributes:gh_gTruncateMiddle] autorelease];
}

- (NSString *)gh_mimeTypeForExtension {
	// TODO(gabe): Doesn't look like css extension gets the mime type?
  CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)self, NULL);    
  NSString *mime = (NSString *)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
  CFRelease(uti);
  return [NSMakeCollectable(mime) autorelease];
}
#endif

- (BOOL)gh_contains:(NSString *)contains options:(NSStringCompareOptions)options {
  NSRange range = [self rangeOfString:contains options:options];
  return (range.location != NSNotFound);
}

- (NSString *)gh_lastSplitWithString:(NSString *)s options:(NSStringCompareOptions)options {
  NSRange range = [self rangeOfString:s options:options];
  if (range.location != NSNotFound) {
    return [self substringWithRange:NSMakeRange(range.location + [s length], [self length] - range.location - [s length])];
  }
  return self;
}

- (NSArray *)gh_componentsSeparatedByString:(NSString *)separator include:(BOOL)include {
	if (!include) return [self componentsSeparatedByString:separator];
	NSArray *strings = [self componentsSeparatedByString:separator];
	NSMutableArray *components = [NSMutableArray arrayWithCapacity:[strings count] * 2];
	NSInteger i = -1;
	NSInteger count = [strings count];
	for(NSString *s in strings) {
		i++;
		if (![s isEqualToString:@""]) [components addObject:s];
		if ((i+1) < count) [components addObject:separator];
	}
	return components;
}

- (BOOL)gh_containsCharacters:(NSString *)characters {
  return [self gh_containsAny:[NSCharacterSet characterSetWithCharactersInString:characters]];
}

- (BOOL)gh_containsAny:(NSCharacterSet *)charSet {
  NSRange range = [self rangeOfCharacterFromSet:charSet];
  return (range.location != NSNotFound);
}

- (BOOL)gh_only:(NSCharacterSet *)charSet {
  return ![self gh_containsAny:[charSet invertedSet]];
}

- (BOOL)gh_startsWithAny:(NSCharacterSet *)charSet {
  NSString *firstChar = [self substringToIndex:1];
  return [firstChar gh_containsAny:charSet];
}

- (BOOL)gh_startsWith:(NSString *)startsWith {
  return [self hasPrefix:startsWith];
}

- (BOOL)gh_startsWith:(NSString *)startsWith options:(NSStringCompareOptions)options {
  if ([self length] < [startsWith length]) return NO;
  NSString *beginning = [self substringToIndex:[startsWith length]];
  return ([beginning compare:startsWith options:options] == NSOrderedSame);  
}

- (BOOL)gh_endsWith:(NSString *)endsWith options:(NSStringCompareOptions)options {
  if ([self length] < [endsWith length]) return NO;
  NSString *lastString = [self substringFromIndex:[self length] - 1];
  return ([lastString compare:endsWith options:options] == NSOrderedSame);
}

- (NSString *)gh_attributize {
  NSString *end = [self substringFromIndex:1];
  NSString *start = [[self substringToIndex:1] lowercaseString];
  return [start stringByAppendingString:end];
}

- (NSString *)gh_fullPathExtension {
  NSString *extension = [self pathExtension];
  if (![extension isEqualToString:@""]) extension = [NSString stringWithFormat:@".%@", extension];
  return extension;
}

+ (NSString *)gh_uuid {
  CFUUIDRef	uuidRef = CFUUIDCreate(nil);
  
  NSString *uuid = (NSString *)CFUUIDCreateString(nil, uuidRef);
  CFRelease(uuidRef);
  
  return [NSMakeCollectable(uuid) autorelease];
}

- (NSString *)gh_reverse {
	NSInteger length = [self length];
	unichar *buffer = calloc(length, sizeof(unichar));
	
	// TODO(gabe): Apparently getCharacters: is really slow
	[self getCharacters:buffer range:NSMakeRange(0, length)];
	
	for(int i = 0, mid = ceil(length/2.0); i < mid; i++) {
		unichar c = buffer[i];
		buffer[i] = buffer[length-i-1];
		buffer[length-i-1] = c;
	}
	
	NSString *s = [[NSString alloc] initWithCharacters:buffer length:length];
	free(buffer);
	return [s autorelease];
}

- (NSInteger)gh_count:(NSString *)s {
	NSRange inRange = NSMakeRange(0, [self length]);
	NSInteger count = 0;
	while(YES) {
		NSRange range = [self rangeOfString:s options:0 range:inRange];
		if (range.location == NSNotFound) break;
		inRange.location = range.location + range.length;
		inRange.length = [self length] - range.location - 1;
		count++;
	}
	return count;
}

+ (NSMutableCharacterSet *)gh_characterSetsUnion:(NSArray *)characterSets {
  NSMutableCharacterSet *charSet = [NSMutableCharacterSet characterSetWithCharactersInString:@""];
  for(NSCharacterSet *set in characterSets)
    [charSet formUnionWithCharacterSet:set];
  
  return charSet;
}

- (NSArray *)gh_substringSegmentsWithinStart:(NSString *)start end:(NSString *)end {
	NSMutableArray *segments = [NSMutableArray array];
	BOOL within = NO;

	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:nil];

	// If we start with start token, the scanner ignores it... 
	if ([self gh_startsWith:start]) {
		[scanner scanString:start intoString:nil];
		within = YES;
	}
	
	NSString *scanned = nil;
	
	while([scanner scanUpToString:(within ? end : start) intoString:&scanned]) {
		if (scanned && [scanned length] > 0)
			[segments addObject:[GHNSStringSegment string:scanned isMatch:within]];
		
		[scanner scanString:(within ? end : start) intoString:&scanned]; // Eat start or end token
		scanned = nil;
		within = !within;
	}
	NSUInteger length = [self length] - [scanner scanLocation];
	if (length > 0)
		[segments addObject:[GHNSStringSegment string:[self substringWithRange:NSMakeRange([scanner scanLocation], length)] isMatch:NO]];
	return segments;
}

// Based on code by powidl
// http://www.codecollector.net/view/4900E3BB-032E-4E89-81C7-34097E98C286
- (NSString *)gh_rot13 {
  const char *cString = [self cStringUsingEncoding:NSASCIIStringEncoding];
  NSInteger stringLength = [self length];
  char newString[stringLength + 1];
  
  NSInteger i;
  for (i = 0; i < stringLength; i++) {
    unsigned char character = cString[i];
    // Check if character is A - Z
    if(0x40 < character && character < 0x5B)
      newString[i] = (((character - 0x41) + 0x0D) % 0x1A) + 0x41;
    // Check if character is a - z
    else if( 0x60 < character && character < 0x7B )
      newString[i] = (((character - 0x61) + 0x0D) % 0x1A) + 0x61;
    else
      newString[i] = character;
  }
  
  newString[i] = '\0';
  
  return [NSString stringWithCString:newString encoding:NSASCIIStringEncoding];
}

- (NSString *)gh_MD5 {
  const char *str = [self UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, strlen(str), result);  
  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

@end

@implementation GHNSStringSegment

@synthesize string=string_, match=isMatch_;

- (id)initWithString:(NSString *)string isMatch:(BOOL)isMatch {
	if ((self = [super init])) {
		string_ = [string retain];
		isMatch_ = isMatch;
	}
	return self;	
}

+ (GHNSStringSegment *)string:(NSString *)string isMatch:(BOOL)isMatch {
	return [[[self alloc] initWithString:string isMatch:isMatch] autorelease];
}

- (BOOL)isEqual:(id)obj {
	return ([[obj string] isEqual:string_] && [obj isMatch] == isMatch_);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"string=%@, isMatch=%d", string_, isMatch_];
}

- (void)dealloc {
	[string_ release];
	[super dealloc];
}

@end
