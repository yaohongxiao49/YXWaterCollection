//
//  BaseViewController.m
//  YXCollectionTest
//
//  Created by Believer Just on 2019/7/5.
//  Copyright © 2019 August. All rights reserved.
//

#import "BaseViewController.h"
#import "YXHomePageVC.h"
#import "NormalCollectionViewController.h"

@interface BaseViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataSourceArr;
    UITableView *_tableView;
}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dataSourceArr = [[NSMutableArray alloc] initWithObjects:@"普通collection", @"瀑布流collection", nil];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}
#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellID = @"123yd";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _dataSourceArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NormalCollectionViewController *vc = [[NormalCollectionViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        YXHomePageVC *vc = [[YXHomePageVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
