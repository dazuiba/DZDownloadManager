//
//  OfflineItem.h
//  hzbus
//
//  Created by Guangyu Zhang on 4/12/13.
//
//

#import <Foundation/Foundation.h>
#import "DZDownloadMng.h"

@class AFDownloadRequestOperation;

@class DZDownloadItem;

@protocol OfflineItemDownloadDelegate <NSObject>
- (void)offlineItem:(DZDownloadItem *)item downloadProgressUpdated:(float)progress;
- (void)offlineItem:(DZDownloadItem *)item downloadFailed:(NSError *)error;
- (void)offlineItemDownloadFinished:(DZDownloadItem *)item;
- (void)offlineItemDownloadStarted:(DZDownloadItem *)item;
- (void)offlineItemDownloadPaused:(DZDownloadItem *)item;
@end


@interface DZDownloadItem : NSObject
@property(nonatomic,strong)NSDictionary *dict;
@property(nonatomic,readonly) NSString *title;
@property(nonatomic,readonly) NSString *uid;
@property(nonatomic,readonly) NSURL *downloadURL;
@property(nonatomic,readonly) NSString *downloadTargetPath;
@property(nonatomic,assign)LIDownloadStatus downloadStatus;
@property(nonatomic,assign)float downloadProgress;
@property(nonatomic,assign)id<OfflineItemDownloadDelegate> downloadDelegate;

+ (NSArray *)buildArrayFromDictArray:(NSArray *)array;

- (id)initWithDict:(NSDictionary *)dict;
- (void)readInfoFromDownloadFile;
- (NSNumber *)displayingFileSize;

- (BOOL)startDownload;
- (BOOL)pauseDownload;
- (BOOL)destroyManually;

- (void)operation:(AFDownloadRequestOperation *)operation failed:(NSError *)error;
- (void)operation:(AFDownloadRequestOperation *)operation progressUpdated:(float)progress;
- (void)operationSucceed:(AFDownloadRequestOperation *)operation;
@end

