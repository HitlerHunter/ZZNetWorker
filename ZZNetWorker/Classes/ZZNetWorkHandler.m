//
//  ZZNetWorkHandler.m
//  AFNetworking
//
//  Created by zenglizhi on 2018/8/25.
//

#import "ZZNetWorkHandler.h"

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
            NSString *logStr = [NSString stringWithFormat:@"获取到的数据是字符串:\n %@",str];
            NSLog(@"%@",logStr);
            NSAssert(!str, logStr);
        }
    }
    
    return responseDict;
}
@end
