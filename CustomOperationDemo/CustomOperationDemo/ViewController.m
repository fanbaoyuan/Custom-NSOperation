//
//  ViewController.m
//  CustomOperationDemo
//
//  Created by Mac on 2019/11/10.
//  Copyright © 2019 Baoger. All rights reserved.
//

#import "ViewController.h"
#import "CustomOperation.h"
#import "CustomOperation.h"

@interface ViewController ()<CustomOperationDelegate>

@property(nonatomic, strong) NSOperationQueue *compressQueue;
@property(nonatomic, strong) NSOperationQueue *uploadQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.compressQueue = [[NSOperationQueue alloc]init];
    // 设置最大压缩操作为1
    self.compressQueue.maxConcurrentOperationCount = 1;
    
    self.uploadQueue = [[NSOperationQueue alloc]init];
    // 设置上传最大操作为4
    self.uploadQueue.maxConcurrentOperationCount = 4;
}


- (IBAction)didClickStartButton:(UIButton *)sender {
    NSInteger taskCount = 6;
    for (NSInteger index = 0; index < taskCount; index++) {
       NSString *name = [NSString stringWithFormat:@"task_%zd",index];
        // 创建压缩操作,压缩是串行操作，代码j走完就算结束，使用NSBlockOperation
        NSBlockOperation *compressOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"%@ 压缩中...", name);
            // 模拟压缩延时
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%@ 结束压缩", name);
        }];
        
        // 创建上传操作
        CustomOperation *uploadOperation = [[CustomOperation alloc]initWithTaskName:name];
        // 设置上传操作代理，完成对应的上传任务
        uploadOperation.delegate = self;
        
        // 添加依赖，当压缩完成后在执行上传任务
        [uploadOperation addDependency:compressOperation];
        
        if (!compressOperation.isCancelled) {
            // 如果压缩没有取消，添加到压缩操作到压缩队列
            [self.compressQueue addOperation:compressOperation];
            
            if (!uploadOperation.isCancelled) {
                // 如果压缩没有取消，且上传任务没有取消，将上传操作添加到上传队列中
                [self.uploadQueue addOperation:uploadOperation];
            }
        }
    }
    
}

- (IBAction)didClickCancelButton:(UIButton *)sender {
    NSLog(@"取消任务");
    // 取消压缩队列中的内容
    [self.compressQueue cancelAllOperations];
    // 取消上传队列中的内容，CustomOperation 需要重写cancel方法，修改状态，不然operation不会从queue中移除，会一直存在，这点在网上搜了一圈都没有写到，最后是看sdwebimage中的SDAsyncBlockOperation也重写cancel，在cancel改变operation的状态才知道；阅读优秀第三方源码还是很有用
    [self.uploadQueue cancelAllOperations];
    // 最后在调用上传的取消 等等
}

#pragma - mark CustomOperationDelegate
// 开始上传，完成后主动修改operation的状态
- (void)startOperation:(CustomOperation *)operation {
    // 模拟上传任务
//    __weak typeof(self)weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"%@ 上传中...%@",operation.taskName,[NSThread currentThread]);
        // 延时
        [NSThread sleepForTimeInterval:10];
        
        // 主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@ 上传完成",operation.taskName);
            // 上传完成后一定要改变当前operation的状态，
            [operation completeOperation];
        });
    });
}


@end
