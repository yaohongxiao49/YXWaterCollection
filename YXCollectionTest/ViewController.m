//
//  ViewController.m
//  YXCollectionTest
//
//  Created by ios on 2019/5/8.
//  Copyright © 2019 August. All rights reserved.
//

#import "YXHomePageVC.h"
#import "YXWaterFallLayout.h"

static NSString *const cellID = @"cellID";

@interface YXHomePageVC () <UICollectionViewDataSource, YXWaterFallLayoutDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation YXHomePageVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //创建布局
    YXWaterFallLayout *layout = [[YXWaterFallLayout alloc] init];
    layout.delegate = self;
    
    //创建collectionView
    CGFloat collectionViewW = self.view.frame.size.width;
    CGFloat collectionViewH = self.view.frame.size.height;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, collectionViewW, collectionViewH) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    //注册
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 50;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    //设置圆角
    cell.layer.cornerRadius = 5.0;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

#pragma mark - <UICollectionViewDataSource>
- (NSUInteger)columnCountInWaterFallLayout:(YXWaterFallLayout *)waterFallLayout {
    return 2;
}
- (CGFloat)columnMarginInWaterFallLayout:(YXWaterFallLayout *)waterFallLayout {
    
    return 10.f;
}
- (CGFloat)rowMarginInWaterFallLayout:(YXWaterFallLayout *)waterFallLayout {
    
    return 10.f;
}
- (UIEdgeInsets)edgeInsetsInWaterFallLayout:(YXWaterFallLayout *)waterFallLayout {
    
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
- (CGFloat)waterFallLayout:(YXWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth {
    
    if (indexPath == 1) {
        return 200;
    }
    return itemWidth;
}

@end
