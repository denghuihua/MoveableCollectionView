//
//  DraggableCollectionViewFlowLayout.h
//  MoveCollectionView
//
//  Created by huihuadeng on 15/7/14.
//  Copyright (c) 2015年 huihuadeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DraggableCollectionViewFlowLayout : UICollectionViewFlowLayout
@property(nonatomic,strong)NSIndexPath *hiddenIndexPath;
@property(nonatomic,strong)NSIndexPath *fromIndexPath;
@property(nonatomic,strong)NSIndexPath *toIndexPath;
@end
