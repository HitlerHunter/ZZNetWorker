//
//  NetworkHelper.m
//  FlowerField
//
//  Created by 郑佳 on 2017/8/20.
//  Copyright © 2017年 Triangle. All rights reserved.
//

#import "ZZNetWorker.h"

#import "ZZNetWorkHandler.h"

@interface ZZNetWorker ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) ZZNetWorkerParamBlock paramHandlerBlock;
@property (nonatomic, strong) ZZNetWorkerDefaultBlock defaultHandlerBlock;
@end

@implementation ZZNetWorker

+ (instancetype)woker {
    
    static ZZNetWorker *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZZNetWorker alloc]init];
        _instance.method = GET;
        _instance.url = @"";
        _instance.param = nil;
    });
    return _instance;
}

+ (ZZNetWorker *)POST{
   ZZNetWorker *woker = [ZZNetWorker woker];
    [woker clearData];
    woker.method = POST;
    return woker;
}

+ (ZZNetWorker *)GET{
    ZZNetWorker *woker = [ZZNetWorker woker];
    [woker clearData];
    woker.method = GET;
    return woker;
}

- (void)clearData{
    
    self.url = @"";
    self.param = nil;
    self.isOpenLog = NO;
    
    if (self.defaultHandlerBlock) {
        self.defaultHandlerBlock(self);
    }
}

- (void)requestMethod:(ZZNetWorkerMethod)method url:(NSString *)url parameters:(id)parameters finishBlock:(ZZNetWorkerCompletionBlock)finishBlock {
    if (method == GET) {
        [self GET:url parameters:parameters finishBlock:finishBlock];
    } else {
        [self POST:url parameters:parameters finishBlock:finishBlock];
    }
}

- (void)GET:(NSString *)URLString parameters:(id)parameters finishBlock:(void (^)(id, NSError *))finishBlock {
    [self.manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [ZZNetWorkHandler jsonFromResponseObject:responseObject];
        if (self.isOpenLog) {
            NSLog(@"\n ZZNetWorker:\n url:%@ \n param:%@ \n response :%@ \n",URLString,parameters,dic);
        }
        finishBlock(dic,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.isOpenLog) {
            NSLog(@"\n ZZNetWorker:\n error:%@ \n ",error);
        }
        finishBlock(nil,error);
    }];
}

- (void)POST:(NSString *)URLString parameters:(id)parameters finishBlock:(void (^)(id, NSError *))finishBlock {
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [ZZNetWorkHandler jsonFromResponseObject:responseObject];
        if (self.isOpenLog) {
            NSLog(@"\n ZZNetWorker:\n url:%@ \n param:%@ \n response :%@ \n",URLString,parameters,dic);
        }
        finishBlock(dic,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.isOpenLog) {
            NSLog(@"\n ZZNetWorker:\n error:%@ \n ",error);
        }
        finishBlock(nil,error);
    }];
}

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html", @"text/plain", @"text/json", @"text/javascript", @"application/json"]];
        _manager.requestSerializer.timeoutInterval = 15;
    }
    return _manager;
}

- (ZZNetWorker *(^)(NSString *))zz_url{
    return ^id (NSString *url){
        self.url = url;
        return self;
    };
}

- (ZZNetWorker *(^)(NSString *))zz_baseUrl{
    return ^id (NSString *baseUrl){
        self.url = [baseUrl stringByAppendingString:self.url];
        return self;
    };
}

- (ZZNetWorker *(^)(id))zz_param{
    return ^id (id param){
        if (self.paramHandlerBlock) {
            self.param = self.paramHandlerBlock(param);
        }else{
            self.param = param;
        }
        return self;
    };
}

- (ZZNetWorker *(^)(BOOL))zz_log{
    return ^id (BOOL isOpenLog){
        self.isOpenLog = isOpenLog;
        return self;
    };
}

- (ZZNetWorker *(^)(ZZNetWorkerCompletionBlock))zz_completion{
    return ^id (ZZNetWorkerCompletionBlock block){
        [self requestMethod:self.method url:self.url parameters:self.param finishBlock:block];
        return self;
    };
}

- (ZZNetWorker *(^)(ZZNetWorkerManagerBlock))zz_manager{
    return ^id (ZZNetWorkerManagerBlock block){
        if(block) block(self.manager);
        return self;
    };
}

- (ZZNetWorker *(^)(ZZNetWorkerParamBlock))zz_handlerParam{
    return ^id (ZZNetWorkerParamBlock block){
        self.paramHandlerBlock = block;
        return self;
    };
}

- (ZZNetWorker *(^)(ZZNetWorkerDefaultBlock))zz_defaultRequest{
    return ^id (ZZNetWorkerDefaultBlock block){
        self.defaultHandlerBlock = block;
        return self;
    };
}
@end
