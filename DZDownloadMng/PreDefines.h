//
//  PreDefines.h
//  DZDownloadMng
//
//  Created by Guangyu Zhang on 4/14/13.
//  Copyright (c) 2013 Guangyu Zhang. All rights reserved.
//

#ifndef DZDownloadMng_PreDefines_h
#define DZDownloadMng_PreDefines_h
#define $safe(obj)        ((NSNull *)(obj) == [NSNull null] ? nil : (obj))
#define $str(...)   [NSString stringWithFormat:__VA_ARGS__]


#ifndef ELog
#   define ELog(err) {if(err) DLog(@"ERROR>> %@", err)}
#endif

#ifdef DEBUG
#ifndef DLog
#   define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#endif
#else
#ifndef DLog
#   define DLog(...)
#endif
#endif

#endif


#import "GHNSString+Utils.h"
#import "GHNSError+Utils.h"
#import "GHNSFileManager+Utils.h"
#import "GHNSNumber+Utils.h"


