

#import <Foundation/Foundation.h>

typedef enum HttpMethod{
    HttpMethodGet      = 0,
    HttpMethodPost     = 1,
    HttpMethodDelete   = 2,
}HttpMethod;

@class AFHTTPClientV2;

typedef void (^HTTPRequestV2SuccessBlock)(id responseObject);
typedef void (^HTTPRequestV2FailedBlock)(NSError *error);

typedef void (^HTTPRequestV2SuccessBlock2)(NSURLResponse *response,id responseObject);
typedef void (^HTTPRequestV2FailedBlock2)(NSURLResponse *response,NSError *error);


@interface AFHTTPClientV2 : NSObject


+ (AFHTTPClientV2 *)requestWithBaseURLStr:(NSString *)URLString
                                   params:(NSDictionary *)params
                               httpMethod:(HttpMethod)httpMethod
                             successBlock:(HTTPRequestV2SuccessBlock)successReqBlock
                              failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

+(AFHTTPClientV2 *)requestURLString:(NSString *)urlstring
                             params:(NSDictionary *)params
                         httpMethod:(HttpMethod)httpMethod
                       successBlock:(HTTPRequestV2SuccessBlock2)successReqBlock
                        failedBlock:(HTTPRequestV2FailedBlock2)failedReqBlock;


@end
