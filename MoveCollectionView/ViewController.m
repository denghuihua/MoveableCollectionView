//
//  ViewController.m
//  MoveCollectionView
//
//  Created by huihuadeng on 15/7/14.
//  Copyright (c) 2015年 huihuadeng. All rights reserved.
//
#define SECTION_COUNT 5
#define ITEM_COUNT 20

#import "ViewController.h"
#import "Cell.h"
#import "DraggableCollectionView.h"
#import "DraggableCollectionViewFlowLayout.h"
@interface ViewController ()< UICollectionViewDataSource_Draggable,UICollectionViewDelegate>
{
   NSMutableArray *dataArray;
}
@property (retain, nonatomic)  DraggableCollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initCollectionView];
    dataArray = [[NSMutableArray alloc] initWithCapacity:ITEM_COUNT];
    for(int i = 0; i < ITEM_COUNT; i++) {
        [dataArray addObject:[NSString stringWithFormat:@"%@", @(i)]];
    }
}

-(void)initCollectionView
{
    // 设置cell的UICollectionViewFlowLayout
    DraggableCollectionViewFlowLayout *flowLayout = [[DraggableCollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(320, 60);
    // 每行内部cell item的间距
    flowLayout.minimumInteritemSpacing = 10;
    // 每行的间距
    flowLayout.minimumLineSpacing = 20;
    // 布局方式改为从上至下，默认从左到右
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    // Section Inset就是某个section中cell的边界范围
    flowLayout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    _collectionView = [[DraggableCollectionView alloc]initWithFrame:CGRectMake(0, 20, screenRect.size.width, screenRect.size.height) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.draggable = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    //cell注册
    [_collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:_collectionView];
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForItemAtIndexPath");
    Cell *cell = (Cell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textView.text = [dataArray objectAtIndex:indexPath.item];
    
    return cell;
}

- (BOOL)collectionView:(DraggableCollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0)
    {
        return NO;
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(toIndexPath.item == 0)
    {
        return NO;
    }
    return YES;
}

- (void)collectionView:(DraggableCollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [dataArray exchangeObjectAtIndex:fromIndexPath.item withObjectAtIndex:toIndexPath.item];
}



@end
