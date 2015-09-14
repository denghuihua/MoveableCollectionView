//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "Cell.h"

@implementation Cell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(30, 0, 320, 60)];
        [self addSubview:self.textView];
        self.textView.backgroundColor = [UIColor redColor];
        self.textView.delegate = self;
        
        [self disableTextViewLongGestureRegnizer];
           }
    return self;
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if([text isEqualToString:@"\n"]){
        [self disableTextViewLongGestureRegnizer];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)disableTextViewLongGestureRegnizer
{
    for (UIGestureRecognizer *gesture in self.textView.gestureRecognizers)
    {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]])
        {
            [gesture addTarget:nil action:nil];
            gesture.enabled = NO;
        }
    }
}

@end
