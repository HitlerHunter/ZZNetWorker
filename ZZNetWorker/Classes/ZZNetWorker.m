//
//  NetworkHelper.m
//  FlowerField
//
//  Created by zlz on 2017/8/20.
//  Copyright © 2017年 Triangle. All rights reserved.
//

#import "ZZNetWorker.h"
#import "CTMediator+CTMediatorModuleLoginActions.h"

@interface ZZNetWorker ()

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

+ (ZZNetWorker *)FormData{
    ZZNetWorker *woker = [ZZNetWorker woker];
    [woker clearData];
    woker.method = FormData;
    return woker;
}

+ (ZZNetWorker *)GET{
    ZZNetWorker *woker = [ZZNetWorker woker];
    [woker clearData];
    woker.method = GET;
    return woker;
}

+ (ZZNetWorker *)DELETE{
    ZZNetWorker *woker = [ZZNetWorker woker];
    [woker clearData];
    woker.method = DELETE;
    return woker;
}

+ (ZZNetWorker *)PUT{
    ZZNetWorker *woker = [ZZNetWorker woker];
    [woker clearData];
    woker.method = PUT;
    return woker;
}

//+ (ZZNetWorker *)UpLoadFile{
//    ZZNetWorker *woker = [ZZNetWorker woker];
//    [woker clearData];
//    woker.method = UpLoadFile;
//    return woker;
//}

- (void)clearData{
    
    self.url = @"";
    self.param = nil;
    self.isOpenLog = NO;
    
    if (self.defaultHandlerBlock) {
        self.defaultHandlerBlock(self);
    }
}

- (void)requestMethod:(ZZNetWorkerMethod)method url:(NSString *)url parameters:(id)parameters finishBlock:(ZZNetWorkerCompletionBlock)finishBlock {
    
    //set token
    if (self.Authorization.length) {
        [self.manager.requestSerializer setValue:self.Authorization forHTTPHeaderField:@"Authorization"];
    }
    
    SDLog(@"\n ZZNetWorker.Authorization: \n%@",self.Authorization);
    
    if (![url hasPrefix:@"http"] && self.baseUrl) {
        url = [self.baseUrl stringByAppendingString:url];
    }
    
    if (method == GET) {
        [self GET:url parameters:parameters finishBlock:finishBlock];
    }else if (method == DELETE) {
        [self sendRequestWithMethod:method URLString:url parameters:parameters finishBlock:finishBlock];
    }else if (method == PUT) {
        [self sendRequestWithMethod:method URLString:url parameters:parameters finishBlock:finishBlock];
    }else if (method == FormData) {
        [self FormData:url parameters:parameters finishBlock:finishBlock];
    }else {
        if (self.isPostByURLSession) {
            [self sendRequestWithMethod:POST URLString:url parameters:parameters finishBlock:finishBlock];
        }else{
            [self POST:url parameters:parameters finishBlock:finishBlock];
        }
        
    }
}

- (void)GET:(NSString *)URLString parameters:(id)parameters finishBlock:(void (^)(id, NSError *))finishBlock {
    
    [self.manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [ZZNetWorkHandler jsonFromResponseObject:responseObject];
        if (self.isOpenLog) {
            SDLog(@"\n ZZNetWorker:\n url:%@ \n param:%@ \n response :%@ \n message = %@ \n",URLString,parameters,dic,dic[@"msg"]);
        }
        if (![self checkResult:dic]) {
            return ;
        }
        finishBlock(dic,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.isOpenLog) {
            NSData *datae = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
            NSString *errorStr = [[ NSString alloc ] initWithData:datae encoding:NSUTF8StringEncoding];
            NSLog(@"\n ZZNetWorker:\n  url:%@ \n param:%@ \n error:%@ \n ",URLString,parameters,errorStr);
        }
        finishBlock(nil,error);
    }];
}

- (void)POST:(NSString *)URLString parameters:(id)parameters finishBlock:(void (^)(id, NSError *))finishBlock {
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [ZZNetWorkHandler jsonFromResponseObject:responseObject];
        if (self.isOpenLog) {
            SDLog(@"\n ZZNetWorker:\n url:%@ \n param:%@ \n response :%@ \n message = %@ \n",URLString,parameters,dic,dic[@"msg"]);
        }
        if (![self checkResult:dic]) {
            return ;
        }
        finishBlock(dic,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.isOpenLog) {
            NSData *datae = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
            NSString *errorStr = [[ NSString alloc ] initWithData:datae encoding:NSUTF8StringEncoding];
            NSLog(@"\n ZZNetWorker:\n  url:%@ \n param:%@ \n error:%@ \n ",URLString,parameters,errorStr);
        }
        finishBlock(nil,error);
    }];
    
}

- (void)FormData:(NSString *)URLString parameters:(id)parameters finishBlock:(void (^)(id, NSError *))finishBlock {
    
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    [self.manager POST:URLString parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if ([parameters isKindOfClass:[NSDictionary class]]) {
            NSArray *keys = [parameters allKeys];
            
            for (NSString *key in keys) {
                id obj = parameters[key];
                
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
                    [formData appendPartWithFormData:jsonData name:key];
                }else if ([obj isKindOfClass:[NSString class]]) {
                    NSData *jsonData = [obj dataUsingEncoding:NSUTF8StringEncoding];
                    [formData appendPartWithFormData:jsonData name:key];
                }
                
            }
        }

        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [ZZNetWorkHandler jsonFromResponseObject:responseObject];
        if (self.isOpenLog) {
            SDLog(@"\n ZZNetWorker:\n url:%@ \n param:%@ \n response :%@ \n message = %@ \n",URLString,parameters,dic,dic[@"msg"]);
        }
        if (![self checkResult:dic]) {
            return ;
        }
        finishBlock(dic,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.isOpenLog) {
            NSData *datae = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
            NSString *errorStr = [[ NSString alloc ] initWithData:datae encoding:NSUTF8StringEncoding];
            NSLog(@"\n ZZNetWorker:\n  url:%@ \n param:%@ \n error:%@ \n ",URLString,parameters,errorStr);
        }
        finishBlock(nil,error);
    }];
    
}

- (void)sendRequestWithMethod:(ZZNetWorkerMethod)method URLString:(NSString *)URLString parameters:(id)parameters finishBlock:(void (^)(id, NSError *))finishBlock {
    
    NSURL *url = nil;
     if (self.isAddDataAfterURL) {
         
         NSMutableString *dataStr = [[NSMutableString alloc] initWithString:URLString];
         [dataStr appendString:@"?"];
         
         NSArray *keys = [parameters allKeys];
         for (NSString *key in keys) {
             id obj = parameters[key];
             [dataStr appendFormat:@"%@=%@&",key,obj];
         }
         
         [dataStr deleteCharactersInRange:NSMakeRange(dataStr.length-1, 1)];
         
         url=[NSURL URLWithString:[dataStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
     }else{
         url=[NSURL URLWithString:URLString];
     }
    
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    
    if (method == POST) {
        request.HTTPMethod = @"POST";
    }else if (method == GET) {
        request.HTTPMethod = @"GET";
    }else if (method == DELETE) {
        request.HTTPMethod = @"DELETE";
    }else if (method == PUT) {
        request.HTTPMethod = @"PUT";
    }
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if (self.Authorization) {
        [request setValue:self.Authorization forHTTPHeaderField:@"Authorization"];
    }
    
    if (!self.isAddDataAfterURL) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        
        request.HTTPBody = data;
    }
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dic = [ZZNetWorkHandler jsonFromResponseObject:data];
            if (self.isOpenLog) {
                SDLog(@"\n ZZNetWorker:\n url:%@ \n param:%@ \n response :%@ \n message = %@ \n",URLString,parameters,dic,dic[@"msg"]);
                
            }
            dispatch_main_async_safe(^{
                if (![self checkResult:dic]) {
                    return ;
                }
                finishBlock(dic,nil);
            });
            
        }else{
            if (self.isOpenLog) {
                NSData *datae = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
                NSString *errorStr = [[ NSString alloc ] initWithData:datae encoding:NSUTF8StringEncoding];
                NSLog(@"\n ZZNetWorker:\n  url:%@ \n param:%@ \n error:%@ \n ",URLString,parameters,errorStr);
            }
            
            dispatch_main_async_safe(^{
                finishBlock(nil,error);
            });
        }
    }];
    
    [sessionDataTask resume];
}

- (NSURLSessionDataTask *)UploadImage:(NSString *)URLString
         parameters:(id)parameters
               data:(NSData *)data
           progress:(void (^)(NSProgress * uploadProgress))progress
        finishBlock:(ZZNetWorkerCompletionBlock)finishBlock {
    
   return [self.manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg"];
       
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if(progress)progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [ZZNetWorkHandler jsonFromResponseObject:responseObject];
        if (self.isOpenLog) {
            SDLog(@"\n ZZNetWorker:\n url:%@ \n param:%@ \n response :%@ \n message = %@ \n",URLString,parameters,dic,dic[@"msg"]);
        }
        if (![self checkResult:dic]) {
            return ;
        }
        finishBlock(dic,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.isOpenLog) {
            NSData *datae = error.userInfo[@"com.alamofire.serialization.response.error.data"] ;
            NSString *errorStr = [[ NSString alloc ] initWithData:datae encoding:NSUTF8StringEncoding];
            NSLog(@"\n ZZNetWorker:\n  url:%@ \n param:%@ \n error:%@ \n ",URLString,parameters,errorStr);
        }
        finishBlock(nil,error);
    }];
    
    
}

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
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

- (ZZNetWorker *(^)(NSString *))zz_authorization{
    return ^id (NSString *authorization){
        self.Authorization = authorization;
        return self;
    };
}

- (ZZNetWorker *(^)(NSString *))zz_baseUrl{
    return ^id (NSString *baseUrl){
        self.baseUrl = baseUrl;
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

- (ZZNetWorker *(^)(void))zz_setContentTypeJson{
    return ^id (){
        
        return self;
    };
}

- (ZZNetWorker *(^)(void))zz_setContentTypeNil{
    return ^id (){
        [self.manager.requestSerializer setValue:nil forHTTPHeaderField:@"Content-Type"];
        return self;
    };
}


- (ZZNetWorker *(^)(BOOL))zz_isPostByURLSession{
    return ^id (BOOL isPostByURLSession){
        self.isPostByURLSession = isPostByURLSession;
        return self;
    };
}

- (ZZNetWorker *(^)(BOOL))zz_isAddDataAfterURL{
    return ^id (BOOL isAddDataAfterURL){
        self.isAddDataAfterURL = isAddDataAfterURL;
        return self;
    };
}

- (void)showMessage:(NSString *)message{
    [SVProgressHUD showImage:nil status:message];
}

- (BOOL)checkResult:(NSDictionary *)dic{
    NSInteger code = [dic[@"code"] integerValue];
    if (code == 9999) {
        [self  showLoginViewController];
        return NO;
    }
    
//    if ([dic[@"error"] length] > 0) {
//        [self showMessage:dic[@"error"]];
//        return YES;
//    }
    
    return YES;
}

- (void)showLoginViewController{
    [self showMessage:@"登录信息已过期，请重新登录！"];
    [CurrentUser loginOut];
    [[CTMediator sharedInstance] CTMediator_showLoginViewController];
    [self.manager.operationQueue cancelAllOperations];
}

@end
