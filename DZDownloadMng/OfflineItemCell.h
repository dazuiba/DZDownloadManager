//
//  OfflineStoreItemCell.h
//  hzbus
//
//  Created by Guangyu Zhang on 4/12/13.
//
//

#import <UIKit/UIKit.h>
#import "DZDownloadItem.h"
@interface OfflineItemCell : UITableViewCell<OfflineItemDownloadDelegate>
@property(nonatomic,strong)DZDownloadItem *offlineItem;
@end
