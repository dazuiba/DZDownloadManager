//
//  OfflineStoreController.m
//  hzbus
//
//  Created by Guangyu Zhang on 4/12/13.
//
//

#import "DemoController.h"
#import "DZDownloadItem.h"
#import "AFJSONUtilities.h"
#import "OfflineItemCell.h"


@interface DemoController()
@property(nonatomic,strong)NSArray *itemArray;
@property(nonatomic,strong)UITableView *tableview;
@end

@implementation DemoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tmp_offline_store" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    NSDictionary *dict = AFJSONDecode(jsonData, &error);
    self.itemArray = [DZDownloadItem buildArrayFromDictArray:dict[@"items"]];
    [[DZDownloadManager sharedInstance] renderItemArray:self.itemArray];
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:_tableview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellId = @"OfflineItemCell";
    OfflineItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell==nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellId owner:self options:nil];
        cell = (OfflineItemCell *)[nib objectAtIndex:0];
    }
    
    cell.offlineItem = self.itemArray[indexPath.row];
    return cell;
}



@end
