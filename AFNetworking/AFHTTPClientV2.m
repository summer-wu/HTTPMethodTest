
#import "AFHTTPClientV2.h"
#import "AFNetworking.h"

@implementation AFHTTPClientV2

+ (AFHTTPClientV2 *)requestWithBaseURLStr:(NSString *)URLString
                                   params:(NSDictionary *)params
                               httpMethod:(HttpMethod)httpMethod
                             successBlock:(HTTPRequestV2SuccessBlock)successReqBlock
                              failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock
{
    CGFloat  sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (sysVersion < 7.0 ) {
        //AFHTTPRequestOperationManager   *httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        AFHTTPRequestOperationManager   *httpClient = [AFHTTPRequestOperationManager manager];
        if (httpMethod == HttpMethodGet) {
            
            NSString   *urlStr = URLString;
            if ([params count]>0) {
                NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:0];
                [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
                }];
                
                NSString  *paramsString = [pairs componentsJoinedByString:@"&"];
                NSInteger questLocation = [URLString rangeOfString:@"?"].location;
                if (questLocation != NSNotFound) {
                    urlStr = [NSString stringWithFormat:@"%@&%@",URLString,paramsString];
                }else{
                    urlStr = [NSString stringWithFormat:@"%@?%@",URLString,paramsString];
                }
            }
            
            [httpClient GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(responseObject);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(error);
                }
            }];
            
        }else if (httpMethod == HttpMethodPost){
            
            
            [httpClient POST:URLString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(responseObject);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(error);
                }
            }];
            
        }else if (httpMethod == HttpMethodDelete){
            
            
            [httpClient DELETE:URLString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(responseObject);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(error);
                }
            }];
            
        }
        
    }else{
        AFHTTPSessionManager   *httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        if (httpMethod == HttpMethodGet) {
            NSString   *urlStr = URLString;
            if ([params count]>0) {
                NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:0];
                [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
                }];
                
                NSString  *paramsString = [pairs componentsJoinedByString:@"&"];
                NSInteger questLocation = [URLString rangeOfString:@"?"].location;
                if (questLocation != NSNotFound) {
                    urlStr = [NSString stringWithFormat:@"%@&%@",URLString,paramsString];
                }else{
                    urlStr = [NSString stringWithFormat:@"%@?%@",URLString,paramsString];
                }
            }
            
            [httpClient GET:urlStr parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(responseObject);
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(error);
                }
            }];
            
        }else if (httpMethod == HttpMethodPost){
            
            [httpClient POST:URLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(responseObject);
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(error);
                }
            }];
            
        }else if (httpMethod == HttpMethodDelete){
            
            [httpClient DELETE:URLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(responseObject);
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(error);
                }
            }];
            
            
        }
        
    }
    
    return [[AFHTTPClientV2 alloc] init];
}


+(AFHTTPClientV2 *)requestURLString:(NSString *)urlstring
                             params:(NSDictionary *)params
                         httpMethod:(HttpMethod)httpMethod
                       successBlock:(HTTPRequestV2SuccessBlock2)successReqBlock
                        failedBlock:(HTTPRequestV2FailedBlock2)failedReqBlock
{
    CGFloat  sysVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (sysVersion < 7.0 ) {
        AFHTTPRequestOperationManager   *httpClient = [AFHTTPRequestOperationManager manager];
        if (httpMethod == HttpMethodGet) {
            
            NSString   *urlStr = urlstring;
            if ([params count]>0) {
                NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:0];
                [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
                }];
                
                NSString  *paramsString = [pairs componentsJoinedByString:@"&"];
                NSInteger questLocation = [urlstring rangeOfString:@"?"].location;
                if (questLocation != NSNotFound) {
                    urlStr = [NSString stringWithFormat:@"%@&%@",urlstring,paramsString];
                }else{
                    urlStr = [NSString stringWithFormat:@"%@?%@",urlstring,paramsString];
                }
            }
            
            [httpClient GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(operation.response,responseObject);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(operation.response,error);
                }
            }];
            
        }else if (httpMethod == HttpMethodPost){
            
            
            [httpClient POST:urlstring parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(operation.response,responseObject);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(operation.response,error);
                }
            }];
            
        }else if (httpMethod == HttpMethodDelete){

            [httpClient DELETE:urlstring parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(operation.response,responseObject);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(operation.response,error);
                }
            }];
            
        }
        
    }else{
        AFHTTPSessionManager   *httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        if (httpMethod == HttpMethodGet) {
            NSString   *urlStr = urlstring;
            if ([params count]>0) {
                NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:0];
                [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
                }];
                
                NSString  *paramsString = [pairs componentsJoinedByString:@"&"];
                NSInteger questLocation = [urlstring rangeOfString:@"?"].location;
                if (questLocation != NSNotFound) {
                    urlStr = [NSString stringWithFormat:@"%@&%@",urlstring,paramsString];
                }else{
                    urlStr = [NSString stringWithFormat:@"%@?%@",urlstring,paramsString];
                }
            }
            
            [httpClient GET:urlStr parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(task.response,responseObject);
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(task.response,error);
                }
            }];
            
        }else if (httpMethod == HttpMethodPost){
            
            [httpClient POST:urlstring parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(task.response,responseObject);
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(task.response,error);
                }
            }];
            
        }else if (httpMethod == HttpMethodDelete){
            
            [httpClient DELETE:urlstring parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                if (successReqBlock) {
                    successReqBlock(task.response,responseObject);
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failedReqBlock) {
                    failedReqBlock(task.response,error);
                }
            }];
            
            
        }
        
    }
    
    return [[AFHTTPClientV2 alloc] init];
}

@end
