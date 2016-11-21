//
//  YTCarouselView.m
//  YTCarouselView
//
//  Created by songyutao on 2016/11/21.
//  Copyright © 2016年 Creditease. All rights reserved.
//

#import "YTCarouselView.h"
#import "YTTimer.h"

struct ImageViewModelStruct
{
    __unsafe_unretained UIView                  *view;
    NSUInteger                                  index;
    struct ImageViewModelStruct   *prev;
    struct ImageViewModelStruct   *next;
    
};

/**********************************************************************************************/

@interface YTCarouselView ()
{
    struct ImageViewModelStruct        *headViewModelStruct;
    struct ImageViewModelStruct        *currentModelStruct;
}

@property(nonatomic, strong)NSMutableArray          *loopViewArray;
@property(nonatomic, strong)UIView                  *contentView;

@property(nonatomic, strong)YTTimer                 *carouselTimmer;
@property(nonatomic, strong)UIPanGestureRecognizer  *panRecognizer;
@property(nonatomic, assign)CGPoint                 startPoint;
@property(nonatomic, assign)BOOL                    canLoop;
@property(nonatomic, strong)UIPageControl           *pageControl;

@end

@implementation YTCarouselView

- (void)dealloc
{
    [self loopStop];
    
    [self _clearImageModel];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _loopViewArray = [NSMutableArray array];
        
        _interval = 2.0f;
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
        
        _pageControl = [[UIPageControl alloc]init];
        [_pageControl setUserInteractionEnabled:NO];
        [_pageControl setCurrentPage:0];
        [self addSubview:_pageControl];
        
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRecognizer:)];
        self.panRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self;
        [self.contentView addGestureRecognizer:self.panRecognizer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    
    [_pageControl setFrame:CGRectMake(0, self.bounds.size.height-30, self.bounds.size.width, 20)];
    
    [self layoutCurrentModel];
}

- (void)layoutCurrentModel
{
    if (currentModelStruct == NULL)
    {
        return;
    }
    
    if (_loopViewArray.count == 1)
    {
        currentModelStruct->view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
    else
    {
        currentModelStruct->prev->view.frame = CGRectMake(-self.contentView.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        currentModelStruct->view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        currentModelStruct->next->view.frame = CGRectMake(self.contentView.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (currentModelStruct == NULL)
    {
        return;
    }
    
    UITouch *touch = touches.anyObject;
    CGPoint pt = [touch locationInView:self.contentView];
    if (CGRectContainsPoint(currentModelStruct->view.frame, pt))
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelected:forIndex:)])
        {
            [self.delegate didSelected:self forIndex:currentModelStruct->index];
        }
    }
}

- (void)reloadData
{
    [self loopStop];
    
    [self _clearImageModel];
    
    [_loopViewArray removeAllObjects];
    
    for (UIView *view in _contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfLoopImageView:)])
    {
        NSUInteger count = [self.delegate numberOfLoopImageView:self];
        
        if ([self.delegate respondsToSelector:@selector(loopImageView:viewForIndex:)] && count!=0)
        {
            for (NSInteger i=0; i<count; i++)
            {
                UIView *view = [self.delegate loopImageView:self viewForIndex:i];
                view.frame = self.bounds;
                
                [_loopViewArray addObject:view];
                
                [_contentView addSubview:view];
            }
            
            [self _createImageModelStruct];
        }
        
        [_pageControl setNumberOfPages:count];
    }
    
    if (_loopViewArray.count > 1)
    {
        [self loopStart];
        
        self.canLoop = YES;
    }
    else
    {
        self.canLoop = NO;
    }
    
    currentModelStruct = headViewModelStruct;
    
    [self setNeedsLayout];
}

- (void)loopStart
{
    [self loopStop];
    
    self.carouselTimmer = [YTTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(doLoop) userInfo:nil repeats:YES];
}

- (void)loopStop
{
    [self.carouselTimmer invalidate];
    self.carouselTimmer = nil;
}

- (void)doLoop
{
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self _moveModel:-self.contentView.frame.size.width];
        
    } completion:^(BOOL finished) {
        
        currentModelStruct = currentModelStruct->next;
        self.pageControl.currentPage = currentModelStruct->index;
        
        [self layoutCurrentModel];
    }];
}

#pragma - mark - private
- (void)_appendStruct:(struct ImageViewModelStruct *)currentModel prev:(struct ImageViewModelStruct *)prev next:(struct ImageViewModelStruct *)next
{
    prev->next = next->prev = currentModel;
    currentModel->prev = prev;
    currentModel->next = next;
}

- (void)_createImageModelStruct
{
    NSUInteger index = 0;
    
    headViewModelStruct = (struct ImageViewModelStruct *) malloc(sizeof(struct ImageViewModelStruct));
    headViewModelStruct->view = [_loopViewArray objectAtIndex:index];
    headViewModelStruct->view.frame = CGRectMake(self.bounds.size.width, 0, headViewModelStruct->view.frame.size.width, headViewModelStruct->view.frame.size.height);
    headViewModelStruct->index = index;
    headViewModelStruct->next = headViewModelStruct->prev = headViewModelStruct;
    
    index ++;
    while (index < _loopViewArray.count)
    {
        struct ImageViewModelStruct *model = (struct ImageViewModelStruct *) malloc(sizeof(struct ImageViewModelStruct));
        model->index = index;
        model->view = [_loopViewArray objectAtIndex:index];
        model->view.frame = CGRectMake(self.bounds.size.width, 0, model->view.frame.size.width, model->view.frame.size.height);
        [self _appendStruct:model prev:headViewModelStruct->prev next:headViewModelStruct];
        
        index++;
    }
}

- (void)_clearImageModel
{
    while (headViewModelStruct)
    {
        struct ImageViewModelStruct *p = headViewModelStruct->next;
        headViewModelStruct->next = p->next;
        if (p == headViewModelStruct)
        {
            free(p);
            p = NULL;
            
            headViewModelStruct = NULL;
            break;
        }
        free(p);
        p = NULL;
    }
    
    currentModelStruct = NULL;
}

- (void)_moveModel:(CGFloat)offset
{
    if (offset >= 0)
    {
        currentModelStruct->view.frame = CGRectMake(offset, currentModelStruct->view.frame.origin.y, currentModelStruct->view.frame.size.width, currentModelStruct->view.frame.size.height);
        currentModelStruct->prev->view.frame = CGRectMake(offset - self.contentView.frame.size.width, currentModelStruct->prev->view.frame.origin.y, currentModelStruct->prev->view.frame.size.width, currentModelStruct->prev->view.frame.size.height);
    }
    else
    {
        currentModelStruct->view.frame = CGRectMake(offset, currentModelStruct->view.frame.origin.y, currentModelStruct->view.frame.size.width, currentModelStruct->view.frame.size.height);
        currentModelStruct->next->view.frame = CGRectMake(offset + self.contentView.frame.size.width, currentModelStruct->next->view.frame.origin.y, currentModelStruct->next->view.frame.size.width, currentModelStruct->next->view.frame.size.height);
    }
}

- (void)_handleRecognizer:(UIPanGestureRecognizer*)panGesture
{
    CGPoint pt = [panGesture locationInView:self.contentView];
    
    if (!self.canLoop)
    {
        return;
    }
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self loopStop];
            
            self.startPoint = pt;
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat offx = pt.x-self.startPoint.x;
            
            [self _moveModel:offx];
            
            break;
        }
        default:
        {
            if (ABS(pt.x-self.startPoint.x) > self.contentView.frame.size.width/3 || ABS([panGesture velocityInView:self.contentView].x)> 100)
            {
                CGFloat offx = pt.x-self.startPoint.x > 0 ? self.contentView.frame.size.width : -self.contentView.frame.size.width;
                
                [UIView animateWithDuration:0.2f animations:^{
                    
                    [self _moveModel:offx];
                    
                } completion:^(BOOL finished) {
                    
                    currentModelStruct = offx > 0 ? currentModelStruct->prev : currentModelStruct->next;
                    self.pageControl.currentPage = currentModelStruct->index;
                    
                    [self layoutCurrentModel];
                    
                    [self loopStart];
                    
                }];
            }
            else
            {
                CGFloat offx = pt.x-self.startPoint.x > 0 ? 0.1 : -0.1;
                
                [UIView animateWithDuration:0.2f animations:^{
                    
                    [self _moveModel:offx];
                    
                } completion:^(BOOL finished) {
                    
                    [self layoutCurrentModel];
                    
                    [self loopStart];
                    
                }];
            }
            
            self.startPoint = CGPointZero;
            
            break;
        }
    }
}

#pragma - mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if ( recognizer == self.panRecognizer )
    {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        CGPoint translation = [panRecognizer translationInView:self.superview];
        return fabs(translation.y) <= fabs(translation.x);
    }
    else
    {
        return NO;
    }
}


@end
