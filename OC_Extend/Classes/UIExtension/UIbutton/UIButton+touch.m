//
//  UIButton.m
//  testAPP
//
//  Created by 红军张 on 2018/3/26.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "UIButton+touch.h"
#import <objc/runtime.h>

@interface UIButton()

/**
 bool 类型 YES 不允许点击   NO 允许点击   设置是否执行点UI方法
 */
@property (nonatomic, assign) BOOL isIgnoreEvent;

@end

@implementation UIButton (touch)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selA = @selector(sendAction:to:forEvent:);
        SEL selB = @selector(mySendAction:to:forEvent:);
        Method methodA = class_getInstanceMethod(self, selA);
        Method methodB = class_getInstanceMethod(self, selB);
        //将 methodB的实现 添加到系统方法中 也就是说 将methodA方法指针指向方法methodB  返回值表示是否添加成功
        BOOL isAdd = class_addMethod(self, selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        //添加成功了 说明 本类中不存在methodB 所以此时必须将方法b的实现指针换成方法A的，否则 调用A也就调用了B，B方法却没有实现就那么就成了空方法事件。
        if (isAdd) {
            class_replaceMethod(self, selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }else{
            //添加失败了 说明本类中 有methodB的实现，此时只需要将 methodA和methodB的IMP互换一下即可。
            method_exchangeImplementations(methodA, methodB);
        }
    });
}



//当我们按钮点击事件 sendAction 时  将会执行  mySendAction
- (void)mySendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([NSStringFromClass(self.class) isEqualToString:@"UIButton"]) {
        self.timeInterval = (self.timeInterval == 0 ?defaultInterval:self.timeInterval);
        if (self.isIgnoreEvent){
            return;
        }else if (self.timeInterval > 0){
//            多做一步 确保 保证下次进来的时候 走YES return出去
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }
    }
    
    self.isIgnoreEvent = YES;
    
    //此处 methodA和methodB方法IMP互换了，实际上执行 sendAction；所以不会死循环
    [self mySendAction:action to:target forEvent:event];
}

- (void)resetState {
    [self setIsIgnoreEvent:NO];
}

//=================================================================
//                           get set 方法
//=================================================================
#pragma mark - property
- (NSTimeInterval)timeInterval {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    objc_setAssociatedObject(self, @selector(timeInterval), @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//runtime 动态绑定 属性
- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent {
    // 注意BOOL类型 需要用OBJC_ASSOCIATION_RETAIN_NONATOMIC 不要用错，否则set方法会赋值出错
    objc_setAssociatedObject(self, @selector(isIgnoreEvent), @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isIgnoreEvent {
    //_cmd == @select(isIgnore); 和set方法里一致
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
