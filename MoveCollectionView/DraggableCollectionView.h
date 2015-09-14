//
//  DraggableCollectionView.h
//  MoveCollectionView
//
//  Created by huihuadeng on 15/7/14.
//  Copyright (c) 2015年 huihuadeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICollectionViewDataSource_Draggable <UICollectionViewDataSource>
@required

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView didMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end


@interface DraggableCollectionView : UICollectionView
@property(nonatomic,assign)BOOL draggable;
@property (nonatomic, assign) CGFloat scrollingSpeed;
@property (nonatomic, assign) UIEdgeInsets scrollingEdgeInsets;
@end
