//
//  DZDownloadMng.h
//  DZDownloadMng
//
//  Created by Guangyu Zhang on 4/14/13.
//  Copyright (c) 2013 Guangyu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"
#import "AFJSONUtilities.h"

@class DZDownloadItem;


typedef enum {
    LIDownloadStatusNone = 0,
    LIDownloadStatusFinished = 1,
    LIDownloadStatusPaused = 12,
    LIDownloadStatusIng = 13,
    LIDownloadStatusFailed = 14
} LIDownloadStatus;



static NSString * const kDownloadMngListUpdatedNotifyKey = @"DownloadMngListUpdated";

@interface DZDownloadManager : NSObject
+ (DZDownloadManager *)sharedInstance;
@property(nonatomic,strong)NSMutableArray *itemList;
- (void)renderItemArray:(NSArray *)array;


- (BOOL)startDownload:(DZDownloadItem *)item;
- (BOOL)pauseDownload:(DZDownloadItem *)item;

+ (NSString *)rootDirectory;

@end