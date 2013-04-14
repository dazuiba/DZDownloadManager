//
//  OfflineItem.m
//  hzbus
//
//  Created by Guangyu Zhang on 4/12/13.
//
//

#import "DZDownloadItem.h"
#import "DZDownloadMng.h"

@implementation DZDownloadItem
+ (NSArray *)buildArrayFromDictArray:(NSArray *)array{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dic in array) {
        DZDownloadItem *r = [[self alloc] init];
        r.dict = dic;
        [result addObject:r];
    }
    return result ;
}

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.dict = dict;
    }
    return self;
}

- (void)readInfoFromDownloadFile{
    if([NSFileManager gh_exist:self.downloadTargetPath]){
        self.downloadStatus = LIDownloadStatusFinished;
    }else if([NSFileManager gh_exist:self.downloadTempPath]){
        self.downloadStatus = LIDownloadStatusPaused;
        
        NSError *error = nil;
        NSNumber *fileSize =  [NSFileManager gh_fileSize:self.downloadTempPath error:&error];        
        if (fileSize) {
            self.downloadProgress =  fileSize.doubleValue/self.displayingFileSize.doubleValue;
        }
    }else{
        self.downloadStatus = LIDownloadStatusNone;
    }
}

- (BOOL)startDownload{
    BOOL started = [[DZDownloadManager sharedInstance] startDownload:self];
    if (started) {
        [self.downloadDelegate offlineItemDownloadStarted:self];
    }
    return started;
}

- (BOOL)pauseDownload{
    BOOL paused = [[DZDownloadManager sharedInstance]  pauseDownload:self];
    if (paused) {
        [self.downloadDelegate offlineItemDownloadPaused:self];
    }
    return paused;
}

- (BOOL)destroyManually{
    return YES;
}

- (NSString *)title{
    return $safe(self.dict[@"title"]);
}

- (NSString *)uid{
    return $safe(self.dict[@"uid"]);
}

- (NSURL *)downloadURL{
    return [NSURL URLWithString:$safe(self.dict[@"url"])];
}

- (NSNumber *)displayingFileSize{
    return $safe(self.dict[@"fileSize"]);
}

- (NSString *)downloadTempPath{
    return [self.downloadTargetPath stringByAppendingFormat:@".part"];
}

- (NSString *)downloadTargetPath{
    return [[DZDownloadManager rootDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.uid]];
}

- (void)operation:(AFDownloadRequestOperation *)operation failed:(NSError *)error{
    self.downloadStatus = LIDownloadStatusFailed;
    [self.downloadDelegate offlineItem:self downloadFailed:error];
}

- (void)operation:(AFDownloadRequestOperation *)operation progressUpdated:(float)progress{
    self.downloadProgress = progress;
    [self.downloadDelegate offlineItem:self downloadProgressUpdated:progress];
}


- (void)operationSucceed:(AFDownloadRequestOperation *)operation {
    self.downloadStatus = LIDownloadStatusFinished;
    [self.downloadDelegate offlineItemDownloadFinished:self];
}


@end