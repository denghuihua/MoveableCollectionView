//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import <UIKit/UIKit.h>

@interface Cell : UICollectionViewCell<UITextViewDelegate>

@property (retain, nonatomic) UITextView *textView;

@end
