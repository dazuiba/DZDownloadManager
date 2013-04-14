//
//  GHNSError+Utils.h
//  GHKitIPhone
//
//  Created by Gabriel Handford on 3/9/09.
//  Copyright 2009. All rights reserved.
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

/*!
 Utilities for generating errors.
 */
@interface NSError(GHUtils)

/*!
 Create error with localized description. (userInfo includes NSLocalizedDescriptionKey=localizedDescription)

 @param domain Domain
 @param code Code
 @param localizedDescription Localized description
 @result NSError
 */
+ (NSError *)gh_errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription;

/*!
 Create error from exception.
 
 @param exception Exception
 */
+ (NSError *)gh_errorFromException:(NSException *)exception;

/*!
 Get full error description, recusively for any errors within the userInfo.
 Useful for getting at CoreData validation errors, for example.

 @result Full error description
 */
- (NSString *)gh_fullDescription;

@end
