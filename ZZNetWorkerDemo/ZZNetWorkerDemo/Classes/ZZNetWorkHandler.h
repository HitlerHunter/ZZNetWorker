//
//  ZZNetWorkHandler.h
//  AFNetworking
//
//  Created by zenglizhi on 2018/8/25.
//

#import <Foundation/Foundation.h>

#define ZZNetWorkModelWithJson(json) ZZNetWorkModel *model_net = [ZZNetWorkModel modelWithJson:json];
@interface ZZNetWorkModel: NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) id data;

+ (ZZNetWorkModel *)modelWithJson:(NSDictionary *)json;
@end

@interface ZZNetWorkHandler : NSObject

+ (NSDictionary *)jsonFromResponseObject:(id)responseObject;
@end
