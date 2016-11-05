// AFHTTPRequestOperationManager.m
//
// Copyright (c) 2013-2015 AFNetworking (http://afnetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

#import <Availability.h>
#import <Security/Security.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

#import "APUtils+Foundation.h"
#import "TargetConditionals.h"

#if TARGET_IPHONE_SIMULATOR
static const BOOL wantDebugGetResponseURL=YES;
static const BOOL wantDebugDELETEResponseURL = YES;
static const BOOL wantDebugPOSTResponseURL = YES;
static const BOOL logToConsole = NO;
#else
static const BOOL wantDebugGetResponseURL=NO;
static const BOOL wantDebugDELETEResponseURL = NO;
static const BOOL wantDebugPOSTResponseURL = NO;
static const BOOL logToConsole = NO;
#endif

#define BLog(formatString, ...) NSLog((@"%s " formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);
typedef void(^SuccessBlockType)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^FailureBlockType)(AFHTTPRequestOperation *operation, NSError *error);
@interface AFHTTPRequestOperationManager ()
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@end

@implementation AFHTTPRequestOperationManager

+ (instancetype)manager {
    return [[self alloc] initWithBaseURL:nil];
}

- (instancetype)init {
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }

    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }

    self.baseURL = url;

    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];

    self.securityPolicy = [AFSecurityPolicy defaultPolicy];

    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];

    self.operationQueue = [[NSOperationQueue alloc] init];

    self.shouldUseCredentialStorage = YES;

    return self;
}

#pragma mark -

#ifdef _SYSTEMCONFIGURATION_H
#endif

- (void)setRequestSerializer:(AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer {
    NSParameterAssert(requestSerializer);

    _requestSerializer = requestSerializer;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer {
    NSParameterAssert(responseSerializer);

    _responseSerializer = responseSerializer;
}

#pragma mark -

- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }

        return nil;
    }

    return [self HTTPRequestOperationWithRequest:request success:success failure:failure];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;

    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;

    return operation;
}

+ (SuccessBlockType) successWithBLogFromSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success method:(NSString *)method URL:(NSString *)URLString parameters:(id)parameters{
    
    void(^successWithBlog)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL isCollection=([responseObject isKindOfClass:[NSDictionary class]]||[responseObject isKindOfClass:[NSArray class]]);
        BOOL output;
        if (!isCollection) {
            output = NO;
        }else {
            output = [self checkOutputWithMethod:method];
        }

        if (output) {//output为真，才保存到disk、才可能打印到console
            NSString *paramJson = [parameters toJSONString];
            NSString *responseJson = [responseObject toJSONString];
            if(logToConsole) BLog(@"\n\n▶️%@:%@\nparametersJson:%@\n返回值:\n%@\n◀️\n",method,URLString,paramJson,responseJson);
            [self saveToDiskWithMethod:method URL:URLString paramJson:paramJson responseJson:responseJson];
        }
        success(operation,responseObject);
    };
    return successWithBlog;
}

+ (FailureBlockType) failureWithBLogFromFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure method:(NSString *)method URL:(NSString *)URLString parameters:(id)parameters{
    //暂时不需要再这里做log。因为BasicRequestManager中log过了。
    return failure;
}

+ (BOOL)checkOutputWithMethod:(NSString*)method{
    BOOL output = NO;
    if (wantDebugGetResponseURL&&[method isEqualToString:@"GET"]) {
        output=YES;
    }else if (wantDebugPOSTResponseURL&&[method isEqualToString:@"POST"]){
        output=YES;
    }else if (wantDebugDELETEResponseURL&&[method isEqualToString:@"DELETE"]){
        output=YES;
    }
    return output;
}

+ (void)saveToDiskWithMethod:(NSString *)method URL:(NSString *)URLString paramJson:(NSString*)paramJson responseJson:(NSString *)responseJson{
    //创建文件
    static NSString * plistLogFilePath;
    if (!plistLogFilePath) {
        NSString *dateStr = [self.class currentDateStr];
        plistLogFilePath = [NSString stringWithFormat:@"/tmp/oneTakeHTTPLog%@.xml",dateStr];
        BOOL created = [[NSFileManager defaultManager]createFileAtPath:plistLogFilePath contents:nil attributes:nil];
        if (!created) {
            BLog(@"创建文件%@失败",plistLogFilePath);
        }
    }
    //创建mutableLogArray
    static NSMutableArray *mutableLogArray;
    if (!mutableLogArray) {
        mutableLogArray = [NSMutableArray array];
    }
    //在ma中添加一条数据，并保存到文件
    NSString *dateStr = [self.class currentDateStr];
    NSDictionary *d = @{@"date":dateStr,
                        @"method":method,
                        @"URL":URLString,
                        @"paramJson":paramJson?:@"未返回",
                        @"responseJson":responseJson?:@"未返回"};
    [mutableLogArray addObject:d];
    [mutableLogArray writeToFile:plistLogFilePath atomically:YES];
    [self.class addXMLStyleSheet:plistLogFilePath];
}

+(NSString*)currentDateStr{
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH_mm_ss"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

+(void)addXMLStyleSheet:(NSString*)xmlFilePath{
    NSError * error;
    NSString *stringFromFile = [[NSString alloc] initWithContentsOfFile:xmlFilePath encoding:NSUTF8StringEncoding error:&error];
    if (error)  BLog(@"error:%@",error);

    NSString *xmlTopStrBeforeReplace = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
    NSString *xmlTopStrAfterReplace = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/css\" href=\"/Users/n/Documents/0FORK_WORK/Fork/UILocal/forkHTTPLogStyle.css\" ?>";

    NSString *replacedString = [stringFromFile stringByReplacingOccurrencesOfString:xmlTopStrBeforeReplace withString:xmlTopStrAfterReplace];
    [replacedString writeToFile:xmlFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)  BLog(@"error:%@",error);
}

#pragma mark -

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    SuccessBlockType successWithBlog=[self.class successWithBLogFromSuccess:success method:@"GET" URL:URLString parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"GET" URLString:URLString parameters:parameters success:successWithBlog failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *)HEAD:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"HEAD" URLString:URLString parameters:parameters success:^(AFHTTPRequestOperation *requestOperation, __unused id responseObject) {
        if (success) {
            success(requestOperation);
        }
    } failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    SuccessBlockType successWithBlog = [self.class successWithBLogFromSuccess:success method:@"POST" URL:URLString parameters:parameters];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"POST" URLString:URLString parameters:parameters success:successWithBlog failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }

        return nil;
    }

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"PUT" URLString:URLString parameters:parameters success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(id)parameters
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"PATCH" URLString:URLString parameters:parameters success:success failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(id)parameters
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    SuccessBlockType successWithBlog = [self.class successWithBLogFromSuccess:success method:@"DELETE" URL:URLString parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:@"DELETE" URLString:URLString parameters:parameters success:successWithBlog failure:failure];

    [self.operationQueue addOperation:operation];

    return operation;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, baseURL: %@, operationQueue: %@>", NSStringFromClass([self class]), self, [self.baseURL absoluteString], self.operationQueue];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSURL *baseURL = [decoder decodeObjectForKey:NSStringFromSelector(@selector(baseURL))];

    self = [self initWithBaseURL:baseURL];
    if (!self) {
        return nil;
    }

    self.requestSerializer = [decoder decodeObjectOfClass:[AFHTTPRequestSerializer class] forKey:NSStringFromSelector(@selector(requestSerializer))];
    self.responseSerializer = [decoder decodeObjectOfClass:[AFHTTPResponseSerializer class] forKey:NSStringFromSelector(@selector(responseSerializer))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.baseURL forKey:NSStringFromSelector(@selector(baseURL))];
    [coder encodeObject:self.requestSerializer forKey:NSStringFromSelector(@selector(requestSerializer))];
    [coder encodeObject:self.responseSerializer forKey:NSStringFromSelector(@selector(responseSerializer))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AFHTTPRequestOperationManager *HTTPClient = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL];

    HTTPClient.requestSerializer = [self.requestSerializer copyWithZone:zone];
    HTTPClient.responseSerializer = [self.responseSerializer copyWithZone:zone];

    return HTTPClient;
}

@end
