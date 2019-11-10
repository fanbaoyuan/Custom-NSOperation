//
//  CustomOperation.m
//  CustomOperationDemo
//
//  Created by Mac on 2019/11/10.
//  Copyright © 2019 Baoger. All rights reserved.
//

#import "CustomOperation.h"

@interface CustomOperation ()

/// 是否正在进行
@property (nonatomic, assign) BOOL bees_executing;

/// 是否完成
@property (nonatomic, assign) BOOL bees_finished;

@end

@implementation CustomOperation

-(instancetype)initWithTaskName:(NSString *)taskName {
  if (self = [super init]) {
    _bees_executing = NO;
    _bees_finished = NO;
    _taskName = taskName;
//    NSLog(@"%@ CustomOperation alloc %@", _taskName,self);
  }
  return self;
}

- (void)dealloc {
    NSLog(@"%@ dealloc %@", self.taskName,self);
}


- (void)start {
  if (self.isCancelled) {
    // 若当前操作为取消，则结束操作，且要修改isExecuting和isFinished的值，通过kvo的方式告诉对应的监听者其值的改变
    NSLog(@"%@ cancel %@", self.taskName,self);
    [self completeOperation];
  } else {
    // 正在执行操作
    self.bees_executing = YES;
    // 通过代理，在外部实现对应的异步操作
    if (self.delegate && [self.delegate respondsToSelector:@selector(startOperation:)]) {
      [self.delegate startOperation:self];
    }
  }
}

/// 结束当前操作，改变对应的状态
- (void)completeOperation {
  self.bees_executing = NO;
  self.bees_finished = YES;
}

// 一定要重写cancel方法，结束状态
- (void)cancel {
  [super cancel];
  // 取消后一定要调用完成，删除queue中的operation
  [self completeOperation];
}

#pragma mark - settter and getter
// setter 修改自己状态的同时，发送父类对应属性状态改变的kvo通知
- (void)setBees_executing:(BOOL)bees_executing {
  [self willChangeValueForKey:@"isExecuting"];
  _bees_executing = bees_executing;
  [self didChangeValueForKey:@"isExecuting"];
}

- (void)setBees_finished:(BOOL)bees_finished {
  [self willChangeValueForKey:@"isFinished"];
  _bees_finished = bees_finished;
  [self didChangeValueForKey:@"isFinished"];
}

// 父类返回自己维护的对应的状态
- (BOOL)isExecuting {
  return self.bees_executing;
}

- (BOOL)isFinished {
  return self.bees_finished;
}

@end
