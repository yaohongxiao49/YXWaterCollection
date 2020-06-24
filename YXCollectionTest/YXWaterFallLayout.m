//
//  YXWaterFallLayout.m
//  YXCollectionTest
//
//  Created by ios on 2019/5/8.
//  Copyright © 2019 August. All rights reserved.
//

#import "YXWaterFallLayout.h"

//默认行距
static CGFloat const kDefaultMinimumRowSpacing = 0.0f;
//默认列距
static CGFloat const kDefaultMinimumColumnSpacing = 0.0f;
//默认section间距
static NSUInteger const kDefaultMinimumSectionSpacing = 0.0f;
//默认列数
static NSUInteger const kDefaultColumnCountPerRow = 2;
//默认边距
static UIEdgeInsets const kDefaultEdgeInsets = {0, 0, 0, 0};

@interface YXWaterFallLayout ()
{
    NSUInteger _curSection;
}

//相对较大的cells高组合
@property (nonatomic, strong) NSMutableArray *maxHeightForColumns;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes;
@property (nonatomic, strong) NSMutableDictionary<id, UICollectionViewLayoutAttributes *> *cacheCell;
@property (nonatomic, strong) NSMutableDictionary<id, UICollectionViewLayoutAttributes *> *cacheHeaders;
@property (nonatomic, strong) NSMutableDictionary<id, UICollectionViewLayoutAttributes *> *cacheFooters;
//当前collectionView需要显示的contentSize的高度
@property (nonatomic, assign) CGFloat curContentSizeHeight;

@property (nonatomic, weak) id<UICollectionViewDataSource>dataSource;

@end

@implementation YXWaterFallLayout
@synthesize columnCountsPerRow = _columnCountsPerRow;

- (void)dealloc {
    
}

#pragma mark - 初始化
- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - 初始化数据
- (void)setUp {
    
    self.minimumRowSpace = kDefaultMinimumRowSpacing;
    self.minimumColumnSpace = kDefaultMinimumColumnSpacing;
    self.minimumSectionSpace = kDefaultMinimumSectionSpacing;
    self.distanceFromVisibleTopPosition = 0.0f;
    self.edgeInsets = kDefaultEdgeInsets;
    self.headerReferenceSize = CGSizeZero;
    self.footerReferenceSize = CGSizeZero;
    _columnCountsPerRow = kDefaultColumnCountPerRow;
    
    _curSection = 0;
    _maxHeightForColumns = [NSMutableArray array];
    _layoutAttributes = [NSMutableArray array];
    _cacheCell = [NSMutableDictionary dictionary];
    _cacheHeaders = [NSMutableDictionary dictionary];
    _cacheFooters = [NSMutableDictionary dictionary];
}

#pragma mark - 创建属性
- (void)prepareLayout {
    [super prepareLayout];
    
    //清除缓存
    [_cacheCell removeAllObjects];
    [_cacheHeaders removeAllObjects];
    [_cacheFooters removeAllObjects];
    
    _curContentSizeHeight = 0;
    //清除原来的高度并新增起始高度
    [_maxHeightForColumns removeAllObjects];
    
    //总组数
    NSInteger sectionCount = [self.collectionView numberOfSections];
    //初始每组数据
    for (NSInteger i = 0; i < sectionCount; i ++) {
        NSIndexPath *indexPat = [NSIndexPath indexPathWithIndex:i];
        [self updateValueBySec:indexPat.section];
    }
    
    //初始最高高度
    for (NSInteger i = 0; i < _columnCountsPerRow; i++) {
        [_maxHeightForColumns addObject:@(0)];
    }
    
    //清除之前所有的布局属性
    [self.layoutAttributes removeAllObjects];
    //创建Attributes
    [self prepareLayoutAttributes];
}

#pragma mark - 更新值
- (void)updateValueBySec:(NSInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:columnNumberAtSection:)]) {
        _columnCountsPerRow = [self.delegate collectionView:self.collectionView layout:self columnNumberAtSection:section];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:lineSpacingForSectionAtIndex:)]) {
        self.minimumRowSpace = [self.delegate collectionView:self.collectionView layout:self lineSpacingForSectionAtIndex:section];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:interitemSpacingForSectionAtIndex:)]) {
        self.minimumColumnSpace = [self.delegate collectionView:self.collectionView layout:self interitemSpacingForSectionAtIndex:section];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        self.edgeInsets = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
}

#pragma mark - 数值变化时，重绘视图
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray<UICollectionViewLayoutAttributes *> *willShowAttributes = [self willShowAttributesForElementsInVisibleBounds];
    if (!self.needPinSectionHeaders) {
        return willShowAttributes;
    }
    UICollectionView *const collection = self.collectionView;
    CGPoint const contentOffset = collection.contentOffset;
    //位移
    for (UICollectionViewLayoutAttributes *layoutAttributes in willShowAttributes) {
        //header
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger section = layoutAttributes.indexPath.section;
            //判定悬浮条件
            if (self.pinSectionHeadersArr.count != 0) {
                [self.pinSectionHeadersArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj integerValue] == section) {
                        [self updateWillShowAttibutes:collection section:section layoutAttributes:layoutAttributes contentOffset:contentOffset];
                        *stop = YES;
                    }
                }];
            }
            else {
                [self updateWillShowAttibutes:collection section:section layoutAttributes:layoutAttributes contentOffset:contentOffset];
            }
        }
    }
    return willShowAttributes;
}

#pragma mark - 更新item显示信息（悬浮效果）
- (void)updateWillShowAttibutes:(UICollectionView *)collection section:(NSInteger)section layoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes contentOffset:(CGPoint)contentOffset {
    
    NSInteger numberOfItemsInSection = [collection numberOfItemsInSection:section];
    
    NSIndexPath *firstObjectIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
    
    BOOL cellsExist;
    UICollectionViewLayoutAttributes *firstObjectAttrs;
    UICollectionViewLayoutAttributes *lastObjectAttrs;
    
    if (numberOfItemsInSection > 0) {
        cellsExist = YES;
        firstObjectAttrs = [self layoutAttributesForItemAtIndexPath:firstObjectIndexPath];
        lastObjectAttrs = [self layoutAttributesForItemAtIndexPath:lastObjectIndexPath];
    }
    else {
        cellsExist = NO;
        firstObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:firstObjectIndexPath];
        lastObjectAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:lastObjectIndexPath];
    }
    
    if (firstObjectAttrs && lastObjectAttrs) {
        CGFloat topHeaderHeight = (cellsExist) ? CGRectGetHeight(layoutAttributes.frame) : 0;
        CGRect frameWithEdgeInsets = UIEdgeInsetsInsetRect(layoutAttributes.frame,
                                                           collection.contentInset);

        CGPoint origin = frameWithEdgeInsets.origin;
        //停滞高度、header高度、footer高度
        CGFloat stayY = contentOffset.y + self.distanceFromVisibleTopPosition + collection.contentInset.top;
        origin.y = MIN(MAX(stayY, (CGRectGetMinY(firstObjectAttrs.frame) - topHeaderHeight - self.edgeInsets.top)), (CGRectGetMaxY(lastObjectAttrs.frame)));
        layoutAttributes.zIndex = 1024;
        layoutAttributes.frame = (CGRect) {
            .origin = origin,
            .size = layoutAttributes.frame.size
        };
    }
}

#pragma mark - cells
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *cellAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if (_cacheCell[indexPath]) {
        UICollectionViewLayoutAttributes *cacheAttributes = _cacheCell[indexPath];
        cellAttributes.frame = cacheAttributes.frame;
        return cellAttributes;
    }
    //取当前UICollectionView的宽度
    CGFloat collectioViewWidth = CGRectGetWidth(self.collectionView.frame);
    //计算cell的宽高 宽：（collectionView宽 - 左边距 - 右边距 - cell间距之和）/列数
    CGFloat cellWidth = (collectioViewWidth - self.edgeInsets.left - self.edgeInsets.right - (_columnCountsPerRow - 1) *self.minimumColumnSpace) /_columnCountsPerRow;
    CGFloat cellHeight = [self.delegate collectionView:self.collectionView layout:self heightForRowAtIndexPath:indexPath itemWidth:cellWidth];
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        self.edgeInsets = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:indexPath.section];
    }
    
    //是否切换section
    //当前列高度
    __block CGFloat curColumnHeight = 0;
    //目标列下标
    __block NSUInteger targetColumnIndex = 0;
    if (indexPath.section > _curSection) {
        _curSection = indexPath.section;
        //取最大
        [self find:YES completion:^(NSUInteger index, CGFloat height) {
            
            curColumnHeight = height;
        }];
        //更换section后均从第0列开始布局
        targetColumnIndex = 0;
        //换section后的更新统一高度
//        curColumnHeight -= self.minimumRowSpace;
        for (NSInteger i = 0; i < _columnCountsPerRow; i++) {
            _maxHeightForColumns[i] = @(curColumnHeight);
        }
    }
    else {
        //取最小
        [self find:NO completion:^(NSUInteger index, CGFloat height) {
            
            curColumnHeight = height;
            targetColumnIndex = index;
        }];
    }
    //计算当前cell的frame X：左边距 + 目标列下标 *（目标列宽度 + 列间距）
    CGFloat cellX = self.edgeInsets.left + targetColumnIndex *(cellWidth + self.minimumColumnSpace);
    CGFloat cellY = curColumnHeight;
    if (cellY != self.edgeInsets.top || cellY != self.edgeInsets.bottom) {
        //当显示列总数小于或等于分割列数时
        if ([self.collectionView numberOfItemsInSection:indexPath.section] <= _columnCountsPerRow) {
            //TODO 多个组时，组间距需要加入，但是单行时高度有问题，所以先注释掉
//            cellY += self.edgeInsets.bottom + self.edgeInsets.top;
            cellY += self.edgeInsets.top;
        }
        else {
            //当显示行不为第一行时
            if (indexPath.row > _columnCountsPerRow - 1) {
                cellY += self.minimumRowSpace;
            }
            //当显示行为最后一行时
            else if (indexPath.row == [self.collectionView numberOfItemsInSection:indexPath.section] - 1) {
                cellY += self.edgeInsets.bottom;
            }
            else {
                cellY += self.edgeInsets.top;
            }
        }
    }
    else {}
    
    cellAttributes.frame = CGRectMake(cellX, cellY, cellWidth, cellHeight);
    //更新最短那列的高度
    _maxHeightForColumns[targetColumnIndex] = @(CGRectGetMaxY(cellAttributes.frame));
    //记录内容的高度
    CGFloat curContentHeight = CGRectGetMaxY(cellAttributes.frame);
    if (_curContentSizeHeight < curContentHeight) {
        _curContentSizeHeight = curContentHeight;
    }
    if (cellAttributes && !CGSizeEqualToSize(CGSizeZero, cellAttributes.frame.size)) {
        [_cacheCell setObject:cellAttributes forKey:indexPath];
        return cellAttributes;
    }
    return nil;
}

#pragma mark - 获取section信息
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [self attributesForElementKindSectionHeaderAtIndexPath:indexPath];
    }
    else {
        return [self attributesForElementKindSectionFooterAtIndexPath:indexPath];
    }
}

#pragma mark - 是否更新视图信息
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    if (self.needPinSectionHeaders) {
        return YES;
    }
    if (CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size)) {
        return NO;
    }
    return YES;
}

#pragma mark - 更新整体frame
- (CGSize)collectionViewContentSize {
    
    CGFloat contentSizeW = CGRectGetWidth(self.collectionView.frame);
    CGFloat contentSizeH = _curContentSizeHeight + self.edgeInsets.bottom;
    if (self.layoutCompletedContentSize) {
        self.layoutCompletedContentSize(CGSizeMake(contentSizeW, contentSizeH));
    }
    return CGSizeMake(0, contentSizeH);
}

#pragma mark - 计算sectionHeader的Attributes
- (nullable UICollectionViewLayoutAttributes *)attributesForElementKindSectionHeaderAtIndexPath:(NSIndexPath *)indexPath {
    
    WeakSelf
    //查询缓存
    if (_cacheHeaders[indexPath]) {
        return _cacheHeaders[indexPath];
    }
    UICollectionViewLayoutAttributes *headerAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    //取当前kind的Size
    CGSize headerSize = self.headerReferenceSize;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        headerSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath];
    }
    UICollectionViewLayoutAttributes *attributes = [self combineAttributes:headerAttributes withElementSize:headerSize indexPath:indexPath completion:^(UICollectionViewLayoutAttributes *attributes) {
        
        attributes.frame = CGRectMake(CGRectGetMinX(attributes.frame), CGRectGetMinY(attributes.frame) , CGRectGetWidth(attributes.frame), CGRectGetHeight(attributes.frame));
        //重组headerAttributes，成功后缓存
        [weakSelf.cacheHeaders setObject:attributes forKey:indexPath];
    }];
    attributes.frame = CGRectMake(CGRectGetMinX(attributes.frame), CGRectGetMinY(attributes.frame), CGRectGetWidth(attributes.frame), CGRectGetHeight(attributes.frame));
    return attributes;
}

#pragma mark - 计算sectionFooter的Attributes
- (nullable UICollectionViewLayoutAttributes *)attributesForElementKindSectionFooterAtIndexPath:(NSIndexPath *)indexPath {
    
    WeakSelf
    //查询缓存
    if (_cacheFooters[indexPath]) {
        return _cacheFooters[indexPath];
    }
    UICollectionViewLayoutAttributes *footerAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
    //取当前kind的Size
    CGSize footerSize = self.footerReferenceSize;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        footerSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:indexPath];
    }
    
    UICollectionViewLayoutAttributes *attributes = [self combineAttributes:footerAttributes withElementSize:footerSize indexPath:indexPath completion:^(UICollectionViewLayoutAttributes *attributes) {
        
        attributes.frame = CGRectMake(CGRectGetMinX(attributes.frame), CGRectGetMinY(attributes.frame) , CGRectGetWidth(attributes.frame), CGRectGetHeight(attributes.frame));
        //重组footerAttributes，成功后缓存
        [weakSelf.cacheFooters setObject:attributes forKey:indexPath];
    }];
    attributes.frame = CGRectMake(CGRectGetMinX(attributes.frame), CGRectGetMinY(attributes.frame), CGRectGetWidth(attributes.frame), CGRectGetHeight(attributes.frame));
    return attributes;
}

#pragma mark - 重组headerAttributes/footerAttributes，成功后缓存
- (nullable UICollectionViewLayoutAttributes *)combineAttributes:(UICollectionViewLayoutAttributes * _Nullable)attributes withElementSize:(CGSize)elementSize indexPath:(NSIndexPath *)indexPath completion:(void(^)(UICollectionViewLayoutAttributes *attributes))completion {
    
    __block CGFloat headerY = 0;
    [self find:YES completion:^(NSUInteger index, CGFloat height) {
      
        headerY = height;
    }];
    //过滤size为CGSizeZero的footer
    if (!CGSizeEqualToSize(CGSizeZero, elementSize)) {
        self.minimumSectionSpace = [self minimumSectionSpaceAtSection:indexPath.section];
        
        attributes.frame = CGRectMake(0, headerY, elementSize.width, elementSize.height);
        CGFloat curColumnHeight = CGRectGetMaxY(attributes.frame) + self.minimumSectionSpace;
        for (NSInteger i = 0; i < _columnCountsPerRow; i++) {
            _maxHeightForColumns[i] = @(curColumnHeight);
        }
        //记录内容的高度
        CGFloat curContentHeight = CGRectGetMaxY(attributes.frame);
        if (_curContentSizeHeight < curContentHeight) {
            _curContentSizeHeight = curContentHeight;
        }
        if (completion) {
            completion(attributes);
        }
        return attributes;
    }
    return nil;
}

#pragma mark - 查找最大或者最小的一行高度所在的columnInde. maxOrMinHeight 最大或最小（YES:最大 | NO:最小）
- (void)find:(BOOL)maxOrMinHeight
   completion:(void(^)(NSUInteger index, CGFloat height))completion {
    
    NSUInteger targetColumnIndex = 0;
    CGFloat columnHeight = [_maxHeightForColumns[0] floatValue];
    if (_columnCountsPerRow >= _maxHeightForColumns.count) {
        _columnCountsPerRow = _maxHeightForColumns.count;
    }
    for (NSInteger i = 1; i < _columnCountsPerRow; i++) {
        CGFloat curColumnHeight = [_maxHeightForColumns[i] floatValue];
        if (maxOrMinHeight) {
            if (columnHeight < curColumnHeight) {
                columnHeight = curColumnHeight;
                targetColumnIndex = i;
            }
        }
        else {
            if (columnHeight > curColumnHeight) {
                columnHeight = curColumnHeight;
                targetColumnIndex = i;
            }
        }
    }
    if (completion) {
        completion(targetColumnIndex, columnHeight);
    };
}

#pragma mark - 获取组间距
- (CGFloat)minimumSectionSpaceAtSection:(NSUInteger)section {
    
    CGFloat minimumSectionSpace = self.minimumSectionSpace;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:spacingWithLastSectionForSectionAtIndex:)]) {
        minimumSectionSpace = [self.delegate collectionView:self.collectionView layout:self spacingWithLastSectionForSectionAtIndex:section];
    }
    return minimumSectionSpace;
}

- (void)prepareLayoutAttributes {
    
    NSUInteger curSectionCount = [self.collectionView numberOfSections];
    for (NSUInteger section = 0; section < curSectionCount; section++) {
        //headers
        _dataSource = self.collectionView.dataSource;
        if (_dataSource && [_dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];;
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath];
            if (attrs) {
                [_layoutAttributes addObject:attrs];
            }
        }
        //cells
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger i = 0; i < itemsCount; i++) {
            //创建cell位置
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:i inSection:section];
            //获取indexPath位置cell对应的布局属性
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:cellIndexPath];
            if (attrs) {
                [_layoutAttributes addObject:attrs];
            }
        }
        //footers
        if (_dataSource && [_dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            NSInteger footerItemsCount = itemsCount != 0 ? itemsCount - 1 : 0;
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForRow:footerItemsCount inSection:section];
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:footerIndexPath];
            if (attrs) {
                [_layoutAttributes addObject:attrs];
            }
        }
    }
}

#pragma mark - 获取将要展示的item的信息
- (NSArray<UICollectionViewLayoutAttributes *> *)willShowAttributesForElementsInVisibleBounds {
    
    CGRect visibleRect = (CGRect) {
        .origin = self.collectionView.contentOffset,
        .size = self.collectionView.bounds.size
    };
    NSMutableArray<UICollectionViewLayoutAttributes *> *willShowAttributes = [NSMutableArray array];
    [self.layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (CGRectIntersectsRect(attributes.frame, visibleRect)) {
            [willShowAttributes addObject:attributes];
        }
    }];
    
    if (self.needPinSectionHeaders) {
        [_cacheHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, UICollectionViewLayoutAttributes * _Nonnull obj, BOOL * _Nonnull stop) {
            
            [willShowAttributes addObject:obj];
        }];
    }
    return [willShowAttributes copy];
}

#pragma mark - 与source相比较，target是否是有有效的数据
- (BOOL)isValid:(CGFloat)target compare:(CGFloat)source {
    
    return (target >= 0 && target != source);
}

#pragma mark - Getter & Setter
- (NSUInteger)columnCountsPerRow {
    
    if (_columnCountsPerRow) {
        return _columnCountsPerRow;
    }
    else {
        return kDefaultColumnCountPerRow;
    }
}

@end
