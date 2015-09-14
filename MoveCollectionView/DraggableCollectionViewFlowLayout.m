//
//  DraggableCollectionViewFlowLayout.m
//  MoveCollectionView
//
//  Created by huihuadeng on 15/7/14.
//  Copyright (c) 2015年 huihuadeng. All rights reserved.
//

#import "DraggableCollectionViewFlowLayout.h"

@implementation DraggableCollectionViewFlowLayout

- (void)prepareLayout
{
   [super prepareLayout];
    NSLog(@"prepareLayout");
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *elements  = [super layoutAttributesForElementsInRect:rect];
    
    NSIndexPath *fromIndexPath  = self.fromIndexPath;
    NSIndexPath *toIndexPath = self.toIndexPath;
    NSIndexPath *hiddenIndexPath = self.hiddenIndexPath;
    if (self.hiddenIndexPath)
    {
        for (UICollectionViewLayoutAttributes *layoutAttributes in elements)
        {
            if(layoutAttributes.representedElementCategory != UICollectionElementCategoryCell)
            {
                continue;
            }
            NSIndexPath *indexPath = layoutAttributes.indexPath;
            
            if ([indexPath isEqual:hiddenIndexPath]) {
                layoutAttributes.hidden = YES;
            }
            
            if([indexPath isEqual:toIndexPath]) {
                // Item's new location
                layoutAttributes.indexPath = fromIndexPath;
                continue;
            }
            
            if (fromIndexPath && toIndexPath)
            {
                if(indexPath.item <= fromIndexPath.item && indexPath.item > toIndexPath.item) {
                    // Item moved back
                    layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
                }
                else if(indexPath.item >= fromIndexPath.item && indexPath.item < toIndexPath.item) {
                    // Item moved forward
                    layoutAttributes.indexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
                }
            }
        }
        return elements;
    }
    else
    {
        return [super layoutAttributesForElementsInRect:rect];
    }
 }

@end
