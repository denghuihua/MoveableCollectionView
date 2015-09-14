//
//  DraggableCollectionView.m
//  MoveCollectionView
//
//  Created by huihuadeng on 15/7/14.
//  Copyright (c) 2015年 huihuadeng. All rights reserved.
//


#import "DraggableCollectionView.h"
#import  "DraggableCollectionViewFlowLayout.h"


#ifndef CGGEOMETRY__SUPPORT_H_
CG_INLINE CGPoint
_CGPointAdd(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}
#endif

typedef NS_ENUM(NSInteger, _ScrollingDirection) {
    _ScrollingDirectionUnknown = 0,
    _ScrollingDirectionUp,
    _ScrollingDirectionDown,
    _ScrollingDirectionLeft,
    _ScrollingDirectionRight
};

@interface DraggableCollectionView()
{
    UIView *_moveCellScreenView;
    CGPoint _lastPressPoint;
    UIView *_insertAlertView;
    NSIndexPath *_lastInsertIndexPath;
    NSIndexPath *_fromIndexPath;
    _ScrollingDirection scrollingDirection;
    CADisplayLink *timer;
    BOOL canScroll;
    BOOL _isMoveEnable;
}

@property(nonatomic,strong)UILongPressGestureRecognizer *longPressGesture;
@end

@implementation DraggableCollectionView

-(void)setDraggable:(BOOL)draggable
{
    if (draggable)
    {
       //添加gesture
        [self addGestureRecognizer:self.longPressGesture];
        _scrollingEdgeInsets = UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);
        _scrollingSpeed = 300.f;
        canScroll = YES;
    }else
    {
      //移除gesture
        [self removeGestureRecognizer:self.longPressGesture];
    }
    _draggable = draggable;
}

-(UILongPressGestureRecognizer *)longPressGesture
{
    if (!_longPressGesture)
    {
        _longPressGesture  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    }
    return _longPressGesture;
}

-(void)addSubViewMoveView:(UICollectionViewCell *)needScreenCell
{
    _moveCellScreenView = [needScreenCell snapshotViewAfterScreenUpdates:YES];
    [self addSubview:_moveCellScreenView];
    _moveCellScreenView.bounds = needScreenCell.bounds;
    _moveCellScreenView.center = needScreenCell.center;
    [UIView
     animateWithDuration:0.3
     animations:^{
         _moveCellScreenView.alpha = 0.5;
         _moveCellScreenView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
     }
     completion:nil];
}

#pragma mark - nomalMethods

- (NSIndexPath *)indexPathForItemClosestToPoint:(CGPoint)point
{
    NSArray *layoutAttrsInRect;
    NSInteger closestDist = NSIntegerMax;
    NSIndexPath *indexPath;
    NSIndexPath *toIndexPath;
    
    // We need original positions of cells
    DraggableCollectionViewFlowLayout *layOut = (DraggableCollectionViewFlowLayout *)self.collectionViewLayout;
    toIndexPath  = layOut.toIndexPath;
    layOut.toIndexPath = nil;
    layoutAttrsInRect = [layOut layoutAttributesForElementsInRect:self.bounds];
    layOut.toIndexPath = toIndexPath;
    
    // What cell are we closest to?
    for (UICollectionViewLayoutAttributes *layoutAttr in layoutAttrsInRect) {
        CGFloat yd = layoutAttr.center.y - point.y;
        NSInteger dist = fabs(yd);
        if (dist < closestDist) {
            closestDist = dist;
            indexPath = layoutAttr.indexPath;
        }
    }
    NSLog(@"closet indexPath:%zd",indexPath.item);
    return indexPath;
}

#pragma mark - ScrollingMethods

-(void)scrollWhenScrollNeeded
{
    // Scroll when necessary
    if (canScroll) {
        UICollectionViewFlowLayout *scrollLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
        if([scrollLayout scrollDirection] == UICollectionViewScrollDirectionVertical) {
            if (_moveCellScreenView.center.y < (CGRectGetMinY(self.bounds) + self.scrollingEdgeInsets.top)) {
                [self setupScrollTimerInDirection:_ScrollingDirectionUp];
            }
            else {
                if (_moveCellScreenView.center.y > (CGRectGetMaxY(self.bounds) - self.scrollingEdgeInsets.bottom)) {
                    [self setupScrollTimerInDirection:_ScrollingDirectionDown];
                }
                else {
                    [self invalidatesScrollTimer];
                }
            }
        }
        else {
            if (_moveCellScreenView.center.x < (CGRectGetMinX(self.bounds) + self.scrollingEdgeInsets.left)) {
                [self setupScrollTimerInDirection:_ScrollingDirectionLeft];
            } else {
                if (_moveCellScreenView.center.x > (CGRectGetMaxX(self.bounds) - self.scrollingEdgeInsets.right)) {
                    [self setupScrollTimerInDirection:_ScrollingDirectionRight];
                } else {
                    [self invalidatesScrollTimer];
                }
            }
        }
    }
    
    // Avoid warping a second time while scrolling
    if (scrollingDirection > _ScrollingDirectionUnknown) {
        return;
    }
}

- (void)setupScrollTimerInDirection:(_ScrollingDirection)direction {
    scrollingDirection = direction;
    if (timer == nil) {
        timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScroll:)];
        [timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)invalidatesScrollTimer {
    if (timer != nil) {
        NSLog(@"invalidatesScrollTimer");
        [timer invalidate];
        timer = nil;
    }
    scrollingDirection = _ScrollingDirectionUnknown;
}

- (void)handleScroll:(NSTimer *)timer {
    if (scrollingDirection == _ScrollingDirectionUnknown) {
        return;
    }
    
    CGSize frameSize = self.bounds.size;
    CGSize contentSize = self.contentSize;
    CGPoint contentOffset = self.contentOffset;
    CGFloat distance = self.scrollingSpeed / 60.f;
    CGPoint translation = CGPointZero;
    
    switch(scrollingDirection) {
        case _ScrollingDirectionUp: {
            NSLog(@"before:%f",distance);
            distance = -distance;
            NSLog(@"middle:%f",distance);
            if ((contentOffset.y + distance) <= 0.f) {
                distance = -contentOffset.y;
            }
            NSLog(@"after:%f",distance);
            translation = CGPointMake(0.f, distance);
        } break;
        case _ScrollingDirectionDown: {
            CGFloat maxY = MAX(contentSize.height, frameSize.height) - frameSize.height;
            if ((contentOffset.y + distance) >= maxY) {
                distance = maxY - contentOffset.y;
            }
            translation = CGPointMake(0.f, distance);
        } break;
        default: break;
    }
    self.contentOffset = _CGPointAdd(contentOffset, translation);
}

#pragma mark - actions

-(void)handleLongPressGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint point  = [gestureRecognizer locationInView:self];
    NSIndexPath *currentIndexPath = [self indexPathForItemAtPoint:point];
    UICollectionViewCell *currentCell = [self cellForItemAtIndexPath:currentIndexPath];
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (![(id<UICollectionViewDataSource_Draggable>)self.dataSource
                  collectionView:self
                  canMoveItemAtIndexPath:currentIndexPath]) {
                _isMoveEnable = NO;
                return;
            }else
            {
                _isMoveEnable = YES;
            }
            
           //添加当天cell截图  获取当前cell== 截图当前视图图片==放大 ---透明度降低  ----
            [self addSubViewMoveView:currentCell];
            //隐藏当前cell
            DraggableCollectionViewFlowLayout *layout = (DraggableCollectionViewFlowLayout *)self.collectionViewLayout;
            layout.hiddenIndexPath = currentIndexPath;
            layout.fromIndexPath = currentIndexPath;
            layout.toIndexPath  = currentIndexPath;
            [self.collectionViewLayout invalidateLayout];
            _fromIndexPath = currentIndexPath;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"UIGestureRecognizerStateChanged");
            if (_isMoveEnable)
            {
                [self scrollWhenScrollNeeded];
                
                NSIndexPath *closetIndexPath = [self indexPathForItemClosestToPoint:point];
                if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:toIndexPath:)] == YES
                    && [(id<UICollectionViewDataSource_Draggable>)self.dataSource
                        collectionView:self
                        canMoveItemAtIndexPath:_fromIndexPath
                        toIndexPath:closetIndexPath] == NO)
                {
                    _isMoveEnable = NO;
                    return;
                }
                
                CGFloat delta_Y = point.y - _lastPressPoint.y;
                _moveCellScreenView.center = CGPointMake(_moveCellScreenView.center.x ,_moveCellScreenView.center.y + delta_Y);
                _lastInsertIndexPath = closetIndexPath;

                NSIndexPath *fromIndexPath  = _fromIndexPath;
                NSIndexPath *toIndexPath = closetIndexPath;
                [self performBatchUpdates:^{
                                    NSLog(@"操作前");
                    DraggableCollectionViewFlowLayout *layout = (DraggableCollectionViewFlowLayout *)self.collectionViewLayout;
                    NSLog(@"change==performBatchUpdates==fromIndexPathItem:%zd===toIndexPathItem:%zd==closeIndexPathItem:%zd",fromIndexPath.item,toIndexPath.item,_lastInsertIndexPath.item);
                    layout.hiddenIndexPath = toIndexPath;
                    layout.fromIndexPath = fromIndexPath;
                    layout.toIndexPath = toIndexPath;
                    NSLog(@"操作后");
                } completion:nil];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"UIGestureRecognizerStateEnded");
            //前面任何一步停止的安全判断
        
            NSIndexPath *closetIndexPath = _lastInsertIndexPath;
            id<UICollectionViewDataSource_Draggable> dataSource = (id<UICollectionViewDataSource_Draggable>)self.dataSource;
            if ([dataSource respondsToSelector:@selector(collectionView:moveItemAtIndexPath:toIndexPath:)])
            {
                [dataSource collectionView:self moveItemAtIndexPath:_fromIndexPath toIndexPath:closetIndexPath];
            }
            DraggableCollectionViewFlowLayout *layout = (DraggableCollectionViewFlowLayout *)self.collectionViewLayout;
            // Move the item
            [self performBatchUpdates:^{
                [self moveItemAtIndexPath:_fromIndexPath toIndexPath:closetIndexPath];
                layout.fromIndexPath = nil;
                layout.toIndexPath = nil;
            } completion:^(BOOL finished) {
                if (finished) {
                    if ([dataSource respondsToSelector:@selector(collectionView:didMoveItemAtIndexPath:toIndexPath:)]) {
                        [dataSource collectionView:self didMoveItemAtIndexPath:_fromIndexPath toIndexPath:closetIndexPath];
                    }
                }
            }];
            // Switch mock for cell
            UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:layout.hiddenIndexPath];
            [UIView
             animateWithDuration:0.3
             animations:^{
                 _moveCellScreenView.center = layoutAttributes.center;
                 _moveCellScreenView.transform = CGAffineTransformMakeScale(1.f, 1.f);
             }
             completion:^(BOOL finished) {
                 [_moveCellScreenView removeFromSuperview];
                 _moveCellScreenView = nil;
                 layout.hiddenIndexPath = nil;
                 [self.collectionViewLayout invalidateLayout];
             }];
            
            // Reset
            //停止定时器
            [self invalidatesScrollTimer];
            //显示 orignal cell
            _fromIndexPath = nil;
            _lastInsertIndexPath = nil;
        }
            break;
        default:
            break;
    }
    _lastPressPoint = point;
}

@end
