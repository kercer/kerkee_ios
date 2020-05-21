//
//  KCWKWebView.m
//  kerkee
//
//  Created by zihong on 2016/11/29.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCWKWebView.h"
#import "NSObject+KCSelector.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "KCBaseDefine.h"


@interface WKWebView()
{
}

-(void)_updateVisibleContentRects;

@end

@interface KCWKWebView()

@property (nonatomic, weak) id scrollViewDelegate;

@end

@implementation KCWKWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark -
#pragma mark UIScrollViewDelegate

// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if ([WKWebView instancesRespondToSelector:@selector(scrollViewDidScroll:)])
//        [super scrollViewDidScroll:scrollView];
    
    if (self.scrollViewDelegate)
    {
        [self.scrollViewDelegate kc_performSelectorSafetyWithArgs:@selector(scrollViewDidScroll:), scrollView, nil];
    }

    if ([self respondsToSelector:@selector(_updateVisibleContentRects)]) {
        ((void(*)(id,SEL,BOOL))objc_msgSend)(self,@selector(_updateVisibleContentRects),NO);
    }
    
    
}


- (void)dealloc
{
    self.scrollViewDelegate = nil;
    
    KCDealloc(super);
}

@end
