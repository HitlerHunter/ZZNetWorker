//
//  ZZNetWorkHandler.m
//  AFNetworking
//
//  Created by zenglizhi on 2018/8/25.
//

#import "ZZNetWorkHandler.h"
#import <MJExtension.h>
@implementation ZZNetWorkModel

+ (ZZNetWorkModel *)modelWithJson:(NSDictionary *)json{
    ZZNetWorkModel *model = [ZZNetWorkModel mj_objectWithKeyValues:json];
    return model;
}

- (BOOL)success{
    return self.code == 0;
}

- (NSString *)message{
    if (!_message) {
        _message = _msg;
    }
    return _message;
}
@end

@implementation ZZNetWorkHandler

+ (NSDictionary *)jsonFromResponseObject:(id)responseObject{
    id responseDict;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        responseDict = responseObject;
    }else if([responseObject isKindOfClass:[NSData class]]){
            //将返回的数据转成json数据格式
        responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
            //NSData -> NSString
        if(!responseDict){
          NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString *log = [NSString stringWithFormat:@"获取到的数据是字符串:\n %@",str];
            NSAssert(str, log);
            
        }
    }
    
    return responseDict;
}
@end
