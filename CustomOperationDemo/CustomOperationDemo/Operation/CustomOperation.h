//
//  CustomOperation.h
//  CustomOperationDemo
//
//  Created by Mac on 2019/11/10.
//  Copyright © 2019 Baoger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CustomOperation;


/// 使用delegate在外面完成对应的操作
@protocol CustomOperationDelegate <NSObject>

-(void)startOperation:(CustomOperation *)operation;

@end

@interface CustomOperation : NSOperation

@property (nonatomic, copy, readonly) NSString *taskName;

@property(nonatomic, weak) id <CustomOperationDelegate>delegate;

- (instancetype)initWithTaskName:(NSString *)taskName;
/// 操作完成时候外部调用改变状态
-(void)completeOperation;

@end

NS_ASSUME_NONNULL_END
