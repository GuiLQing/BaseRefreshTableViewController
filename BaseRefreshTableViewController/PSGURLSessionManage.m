//
//  PSGURLSessionManage.m
//  BaseRefreshTableViewController
//
//  Created by SNICE on 2018/8/7.
//  Copyright © 2018年 G. All rights reserved.
//

#import "PSGURLSessionManage.h"

typedef NS_ENUM(NSUInteger, HttpMethod) {
    HttpMethodPost,
    HttpMethodGet,
};

static NSTimeInterval const timeoutInterval = 15.0;

@implementation PSGURLSessionManage

+ (instancetype)sharedManage {
    static PSGURLSessionManage *_manage = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _manage = [[PSGURLSessionManage alloc] init];
    });
    return _manage;
}

- (void)getDataWithPath:(NSString *)path params:(NSDictionary *)params header:(NSDictionary *)header success:(Success)success failure:(Failure)failure {
    [self requestDataWithHttpMethod:HttpMethodGet path:path params:params header:header isJsonSerializer:NO success:success failure:failure];
}

- (void)postDataWithPath:(NSString *)path params:(NSDictionary *)params header:(NSDictionary *)header isJsonSerializer:(BOOL)isJsonSerializer success:(Success)success failure:(Failure)failure {
    [self requestDataWithHttpMethod:HttpMethodPost path:path params:params header:header isJsonSerializer:isJsonSerializer success:success failure:failure];
}

- (void)requestDataWithHttpMethod:(HttpMethod)httpMethod path:(NSString *)path params:(NSDictionary *)params header:(NSDictionary *)header isJsonSerializer:(BOOL)isJsonSerializer success:(Success)success failure:(Failure)failure {
    
    path = [SERVER_API_STRING stringByAppendingString:path];
    
    NSMutableString *paramsString = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [paramsString appendFormat:@"%@=%@&", key, obj];
    }];
    [paramsString deleteCharactersInRange:NSMakeRange(paramsString.length - 1, 1)];
    
    if (httpMethod == HttpMethodGet) {
        path = [NSString stringWithFormat:@"%@?%@", path, paramsString];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeoutInterval];
    request.HTTPMethod = httpMethod == HttpMethodGet ? @"GET" : @"POST";
    if (httpMethod == HttpMethodPost) {
        if (isJsonSerializer) {
            NSError *error = nil;
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        } else {
            request.HTTPBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    request.allHTTPHeaderFields = header;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"data--------%@", data);
        NSLog(@"response----%@", response);
        NSLog(@"error-------%@", error);
        if (data) {
            NSLog(@"json--------%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
        }
        [self handleDataWithData:data response:response error:error success:success failure:failure];
    }];
    [dataTask resume];
}

- (void)handleDataWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error success:(Success)success failure:(Failure)failure {
    id json = nil;
    if (data) {
        json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if (!error) {
        success(0, @"", json);
    } else {
        failure(error);
    }
}

@end
