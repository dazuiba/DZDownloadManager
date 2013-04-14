#import "DZDownloadMng.h"
#import "DZDownloadItem.h"


@interface DZDownloadManager()
@property(nonatomic,strong)NSString *directory;
@property(nonatomic,strong)NSOperationQueue *operationQueue;
@end

@implementation DZDownloadManager

- (void)renderItemArray:(NSArray *)array{
    for (DZDownloadItem *item in array) {
        for (DZDownloadItem *localItem in self.itemList) {
            if ([localItem.uid isEqualToString:item.uid]) {
                item.downloadStatus = localItem.downloadStatus;
                item.downloadProgress = localItem.downloadProgress;
                break;
            }
        }
    }
}

- (BOOL)pauseDownload:(DZDownloadItem *)item{
    AFDownloadRequestOperation *downloadOperation = [self fetchDownloadOperation:item createIfNeed:NO];
    if (downloadOperation) {
        if ([downloadOperation isExecuting]) {
            [downloadOperation pause];
            return YES;
        }
    }
    return NO;
}

- (BOOL)startDownload:(DZDownloadItem *)item{
    
    if (item.downloadStatus == LIDownloadStatusIng || item.downloadStatus == LIDownloadStatusFinished) {
        return NO;
    }
    
    
    AFDownloadRequestOperation *downloadOperation = [self fetchDownloadOperation:item createIfNeed:NO];
    if (!downloadOperation) {
        downloadOperation = [self fetchDownloadOperation:item createIfNeed:YES];
        [self.operationQueue addOperation:downloadOperation];
    }
    
    [self addToListIfNeeds:item];
    
    if ([downloadOperation isPaused]) {
        [downloadOperation resume];
    }else{
        [downloadOperation start];
    }
    item.downloadStatus = LIDownloadStatusIng;
    return YES;
}

- (void)addToListIfNeeds:(DZDownloadItem *)itemToAdd{
    BOOL contains = NO;
    for (DZDownloadItem *item in self.itemList) {
        if([itemToAdd.uid isEqualToString:item.uid]){
            contains = YES;
            break;
        }
    }
    
    if (!contains) {
        [self.itemList addObject:itemToAdd];
        [self synchronize];
    }
}

- (void)synchronize{
    NSError *error;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.itemList.count];
    for (DZDownloadItem *item in self.itemList) {
        [array addObject:item.dict];
    }
    NSData *data = AFJSONEncode(array, &error);
    ELog(error);
    
    if (data) {
        [data writeToFile:self.mainJsonFilePath atomically:YES];
        //        ELog(error);
    }
}

- (void)callbackWhenDownloadSuccessed:(DZDownloadItem *) item operation:(AFDownloadRequestOperation *)operation{
    [item operationSucceed:(AFDownloadRequestOperation *)operation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadMngListUpdatedNotifyKey object:nil];
}

- (AFDownloadRequestOperation *)fetchDownloadOperation:(DZDownloadItem *)downloadItem createIfNeed:(BOOL)createIfNeed{
    AFDownloadRequestOperation *operation = nil;
    for (NSOperation *theOpt in self.operationQueue.operations) {
        AFDownloadRequestOperation *opt = (AFDownloadRequestOperation *)theOpt;
        if ([opt isFinished]||[opt isCancelled]) {
            continue;
        }
        if ([opt.targetPath isEqualToString:downloadItem.downloadTargetPath]) {
            operation = opt;
            break;
        }
    }
    
    if(operation == nil && createIfNeed){
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadItem.downloadURL];
        NSError *error = nil;
        [NSFileManager gh_ensureDirectoryExists:self.directory created:nil error:&error];
        if (error) {
            NSLog(@"fetchDownloadOperation--error: %@",error);
        }
        
        AFDownloadRequestOperation *downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                                                                 targetPath:downloadItem.downloadTargetPath
                                                                                               shouldResume:YES];
        
        AFDownloadRequestOperation * __weak weakDownloadOperation = downloadOperation;
        DZDownloadManager * __weak weekSelf = self;
        
        [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [weekSelf callbackWhenDownloadSuccessed:downloadItem operation:(AFDownloadRequestOperation *)operation];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [downloadItem operation:weakDownloadOperation failed:error];
        }];
        
        [downloadOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            float progress = ((float)totalBytesReadForFile)/((float)totalBytesExpectedToReadForFile);
            [downloadItem operation:weakDownloadOperation progressUpdated:progress];
            
        }];
        operation = downloadOperation;
    }
    return operation;
    
}

- (NSString *)mainJsonFilePath{
    return [self.directory stringByAppendingPathComponent:@"mainfile.json"];
}



- (id)init
{
    self = [super init];
    if (self) {
        self.directory = [DZDownloadManager rootDirectory];
        self.itemList = [NSMutableArray array];
        
        if( [NSFileManager gh_exist:self.mainJsonFilePath] ){
            NSData *data = [NSData dataWithContentsOfFile:self.mainJsonFilePath];
            NSError *error = nil;
            NSArray *array = AFJSONDecode(data, &error);
            ELog(error);
            if (array) {
                for (NSDictionary *dict in array) {
                    DZDownloadItem *item = [[DZDownloadItem alloc] initWithDict:dict];
                    [item readInfoFromDownloadFile];
                    [self.itemList addObject:item];
                }
            }
        }
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:6];
    }
    return self;
}

+ (NSString *)rootDirectory{
    return  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"mapv2/Download"];
    
}

+ (DZDownloadManager *)sharedInstance {
    static DZDownloadManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DZDownloadManager alloc] init];
    });
    return _sharedInstance;
}

@end