//
//  NetworkHelper.h
//  FlowerField
//
//  Created by 郑佳 on 2017/8/20.
//  Copyright © 2017年 Triangle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, ZZNetWorkerMethod) {
    GET = 0,
    POST = 1,
};

typedef void(^ZZNetWorkerCompletionBlock)(NSDictionary *data, NSError *error);
typedef void(^ZZNetWorkerManagerBlock)(AFHTTPSessionManager *manager);
typedef id(^ZZNetWorkerParamBlock)(id param);

@class ZZNetWorker;
typedef void(^ZZNetWorkerDefaultBlock)(ZZNetWorker *worker);

@interface ZZNetWorker : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) id param;
@property (nonatomic, assign) ZZNetWorkerMethod method;
@property (nonatomic, assign) BOOL isOpenLog;

@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_url)(NSString *url);
@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_baseUrl)(NSString *baseUrl);
@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_param)(id param);
@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_log)(BOOL isOpenLog);
@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_completion)(ZZNetWorkerCompletionBlock block);

/**
  设置manager.
  设置一次, 每次都会调用.
 */
@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_manager)(ZZNetWorkerManagerBlock block);
/**
 设置param后, 每次都会调用.
 */
@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_handlerParam)(ZZNetWorkerParamBlock block);
/**
 对worker 初始化.
 请求开始前, 每次都会调用.
 */
@property (nonatomic, strong, readonly) ZZNetWorker * (^zz_defaultRequest)(ZZNetWorkerDefaultBlock block);

+ (ZZNetWorker *)POST;
+ (ZZNetWorker *)GET;

/**
 获取单例对象
 @return ZZNetWorker.new
 */
+ (ZZNetWorker *)woker;

- (void)requestMethod:(ZZNetWorkerMethod)method
                  url:(NSString *)url
           parameters:(id)parameters
          finishBlock:(ZZNetWorkerCompletionBlock)finishBlock;
@end
