//
//  YXHomePageVC.m
//  YXCollectionTest
//
//  Created by ios on 2019/5/8.
//  Copyright © 2019 August. All rights reserved.
//

#import "YXHomePageVC.h"
#import "YXWaterFallLayout.h"
#import "CollectionViewCell.h"

@interface YXHomePageVC () <UICollectionViewDelegate, UICollectionViewDataSource, YXWaterFallLayoutDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation YXHomePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    YXWaterFallLayout *layout = [[YXWaterFallLayout alloc] init];
    layout.delegate = self;
    layout.needPinSectionHeaders = YES;
    layout.distanceFromVisibleTopPosition = 88;//64;
//    layout.pinSectionHeadersArr = [[NSMutableArray alloc] initWithObjects:@"1", nil];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout] ;
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class])];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView"];
    
    [self.view addSubview:_collectionView];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }
    return 4;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CollectionViewCell class]) forIndexPath:indexPath];
    
    // 设置圆角
    cell.layer.cornerRadius = 5.0;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [UIColor redColor];
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
        if (indexPath.section == 0) {
            reusableview.backgroundColor = [UIColor blackColor];
        }
        else {
            reusableview.backgroundColor = [UIColor greenColor];
        }
        
        return reusableview;
    }
    else {
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
        reusableview.backgroundColor = [UIColor blueColor];
        return reusableview;
    }
    return reusableview;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

#pragma mark - <YXWaterFallLayoutDataSource>
/** 每个item的高度 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout heightForRowAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth {
    
    if (indexPath.section == 1) {
        if (indexPath.row == 2) {
            return 100;
        }
    }
    return 300;
}
/** 有多少列 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout columnNumberAtSection:(NSInteger)section {
    
    return 2;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(40, 15, 0, 15);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 20;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout spacingWithLastSectionForSectionAtIndex:(NSInteger)section {
    
    return 0.f;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout referenceSizeForHeaderInSection:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return CGSizeMake(self.view.frame.size.width, 60);
    }
    return CGSizeMake(self.view.frame.size.width, 120);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(YXWaterFallLayout *)collectionViewLayout referenceSizeForFooterInSection:(nonnull NSIndexPath *)indexPath {
    
    return CGSizeMake(self.view.frame.size.width, 667);
}

@end
