//
//  PSGURLSessionManage.h
//  BaseRefreshTableViewController
//
//  Created by SNICE on 2018/8/7.
//  Copyright © 2018年 G. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define SERVER_API_STRING @""
#else
#define SERVER_API_STRING @""
#endif

typedef void(^Success)(NSInteger code, NSString *msg, id json);
typedef void(^Failure)(NSError *error);

@interface PSGURLSessionManage : NSObject

+ (instancetype)sharedManage;

- (void)getDataWithPath:(NSString *)path params:(NSDictionary *)params header:(NSDictionary *)header success:(Success)success failure:(Failure)failure;

- (void)postDataWithPath:(NSString *)path params:(NSDictionary *)params header:(NSDictionary *)header isJsonSerializer:(BOOL)isJsonSerializer success:(Success)success failure:(Failure)failure;

@end
