//
//  YXWaterFallLayout.h
//  YXCollectionTest
//
//  Created by ios on 2019/5/8.
//  Copyright © 2019 August. All rights reserved.
//
// TODO 如果在controller中，如果没有navigation，这需要先加入navigation.
/// 瀑布流使用的layout

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString *const UICollectionElementKindSectionHeader;
UIKIT_EXTERN NSString *const UICollectionElementKindSectionFooter;
#define WeakSelf __weak typeof(self) weakSelf = self;

@class YXWaterFallLayout;

@protocol YXWaterFallLayoutDataSource <NSObject>

/** cell高度 */
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(YXWaterFallLayout *)collectionViewLayout
  heightForRowAtIndexPath:(NSIndexPath *)indexPath
                itemWidth:(CGFloat)itemWidth;

@optional
/** headerSize */
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(YXWaterFallLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSIndexPath *)indexPath;

/** footerSize */
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(YXWaterFallLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSIndexPath *)indexPath;

/** 组边距 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(YXWaterFallLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section;

/** cell数 */
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(YXWaterFallLayout *)collectionViewLayout
      columnNumberAtSection:(NSInteger)section;

/** 行距 */
- (CGFloat)collectionView:(UICollectionView *)collectionView
                     layout:(YXWaterFallLayout *)collectionViewLayout
lineSpacingForSectionAtIndex:(NSInteger)section;

/** 列距 */
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(YXWaterFallLayout*)collectionViewLayout
interitemSpacingForSectionAtIndex:(NSInteger)section;

/** 组间距（一般没用） */
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(YXWaterFallLayout*)collectionViewLayout
spacingWithLastSectionForSectionAtIndex:(NSInteger)section;

@end

@interface YXWaterFallLayout : UICollectionViewLayout

@property (nonatomic, weak) id<YXWaterFallLayoutDataSource>delegate;
/** 是否需要粘滞 */
@property (nonatomic, assign) BOOL needPinSectionHeaders;
/** 粘滞的距离，只有当needPinSectionHeaders为YES才生效（默认0.f，即导航栏底部粘滞) */
@property (nonatomic, assign) CGFloat distanceFromVisibleTopPosition;
/** 粘滞组集合 */
@property (nonatomic, strong) NSMutableArray *pinSectionHeadersArr;
/** 行间距 */
@property (nonatomic, assign) CGFloat minimumRowSpace;
/** 列间距 */
@property (nonatomic, assign) CGFloat minimumColumnSpace;
/** 组间距 */
@property (nonatomic, assign) CGFloat minimumSectionSpace;
/** 列数 */
@property (nonatomic, assign) NSUInteger columnCountsPerRow;
/** 内边距 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
/** sectionHeader的size */
@property (nonatomic, assign) CGSize headerReferenceSize;
/** sectionFooter的size */
@property (nonatomic, assign) CGSize footerReferenceSize;
/** 获取collectionView的contentSize */
@property (nonatomic, copy) void(^layoutCompletedContentSize)(CGSize);

@end

NS_ASSUME_NONNULL_END
