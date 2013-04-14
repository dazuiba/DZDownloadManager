//
//  OfflineStoreItemCell.m
//  hzbus
//
//  Created by Guangyu Zhang on 4/12/13.
//
//

#import "OfflineItemCell.h"

@interface OfflineItemCell ()
@property(nonatomic,strong)IBOutlet UILabel *nameLabel;
@property(nonatomic,strong)IBOutlet UILabel *sizeLabelDownloadingMode;
@property(nonatomic,strong)IBOutlet UILabel *sizeLabelNormalMode;
@property(nonatomic,strong)IBOutlet UIProgressView *progressView;


@property(nonatomic,strong)IBOutlet UIButton *downloadBtn;
@property(nonatomic,strong)IBOutlet UILabel *downloadedLabel;
@end

@implementation OfflineItemCell

- (void)awakeFromNib{
    _nameLabel.text = nil;
    _sizeLabelNormalMode.text = nil;
    _sizeLabelDownloadingMode.text = nil;
//    [self setDownloadBtnState:LIDownloadStatusNone];
    [_downloadBtn addTarget:self action:@selector(downloadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)downloadBtnClicked:(id)sender{
    switch (self.offlineItem.downloadStatus) {
        case LIDownloadStatusFailed:
        case LIDownloadStatusPaused:
        case LIDownloadStatusNone:
            [self.offlineItem startDownload];
            break;
        case LIDownloadStatusIng:
            [self.offlineItem pauseDownload];
        default:
            break;
    }
}

- (void)setOfflineItem:(DZDownloadItem *)offlineItem{
    if (_offlineItem!=offlineItem) {
        _offlineItem.downloadDelegate = nil;
        _offlineItem = offlineItem;
        _offlineItem.downloadDelegate = self;
        
        _nameLabel.text = offlineItem.title;
        _sizeLabelDownloadingMode.text = _sizeLabelNormalMode.text = [offlineItem.displayingFileSize gh_humanSize];
        
        [self setDownloadBtnState:offlineItem.downloadStatus];
    }
}

- (void)offlineItemDownloadStarted:(DZDownloadItem *)item{
    [self setDownloadBtnState:LIDownloadStatusIng];
}

- (void)offlineItemDownloadPaused:(DZDownloadItem *)item{
    [self setDownloadBtnState:LIDownloadStatusPaused];
}

- (void)offlineItemDownloadFinished:(DZDownloadItem *)item{
    [self setDownloadBtnState:LIDownloadStatusFinished];
}

- (void)offlineItem:(DZDownloadItem *)item downloadFailed:(NSError *)error{
    [self setDownloadBtnState:LIDownloadStatusFailed];
}

- (void)offlineItem:(DZDownloadItem *)item downloadProgressUpdated:(float)progress{
    self.progressView.hidden = NO;
    self.progressView.progress = progress;
}

- (void)setDownloadBtnState:(LIDownloadStatus)status{
    NSString *imgKey = nil;
    switch (status) {
//        case LIDownloadStatusNone:
//            imgKey = @"goon";
//            _sizeLabelDownloadingMode.hidden = NO;
//            _sizeLabelNormalMode.hidden = YES;
//            _progressView.hidden = self.offlineItem.downloadProgress == 0;
//            break;
        case LIDownloadStatusIng:
            imgKey = @"pause";
            _sizeLabelDownloadingMode.hidden = NO;
            _sizeLabelNormalMode.hidden = YES;
            _progressView.hidden = self.offlineItem.downloadProgress == 0;
            break;
        case LIDownloadStatusPaused:
            imgKey = @"goon";
            _sizeLabelDownloadingMode.hidden = NO;
            _sizeLabelNormalMode.hidden = YES;
            _downloadedLabel.hidden = YES;
            break;
        case LIDownloadStatusFailed:
            imgKey = @"goon";
            break;
        case LIDownloadStatusFinished:
            _progressView.progress = 0;
            _progressView.hidden = YES;
            _downloadBtn.hidden = YES;
            _downloadedLabel.hidden = NO;
            break;
        default:
            imgKey = @"download";
            _sizeLabelDownloadingMode.hidden = YES;
            _sizeLabelNormalMode.hidden = NO;
            _progressView.hidden = YES;
            _downloadedLabel.hidden = YES;
            break;
    }
    if (imgKey) {
        [self.downloadBtn setImage:[UIImage imageNamed:$str(@"list_button_%@.png",imgKey)] forState:UIControlStateNormal];
        [self.downloadBtn setImage:[UIImage imageNamed:$str(@"list_button_%@_press.png",imgKey)] forState:UIControlStateHighlighted];
    }else{
        self.downloadBtn.hidden = YES;
    }
}

@end
