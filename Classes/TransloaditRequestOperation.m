//
//  TransloaditRequestOperation.m
//  JustTransloadit
//
//  Created by Josh Holtz on 4/22/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kUrlAssemply @"http://api2.transloadit.com/assemblies"
#define kPollInterval 8
#define kNumTries 3

#import "TransloaditRequestOperation.h"

#import <AFNetworking/AFNetworking.h>

typedef void(^TransloadidSuccessBlock) (AFHTTPRequestOperation* operation, id responseObject);
typedef void(^TransloadidFailureBlock) (AFHTTPRequestOperation* operation, NSError* error);

@interface TransloaditPollRequestOperation ()

@property (nonatomic, assign) BOOL wait;
@property (nonatomic, assign) NSInteger delayInterval;
@property (nonatomic, assign) NSInteger numTries;

@property (nonatomic, assign) NSInteger tries;
@property (nonatomic, copy) TransloadidSuccessBlock successBlock;
@property (nonatomic, copy) TransloadidFailureBlock failureBlock;

@end

@interface TransloaditRequestOperation ()

@end

#pragma mark - TransloaditRequestOperation

@implementation TransloaditRequestOperation

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (self) {
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    return self;
}

// POST an assembly
+ (instancetype)assemblyPOST:(NSString*)key withTemplateId:(NSString*)templateId withData:(NSData*)data withMimeType:(NSString*)mimeType {
    NSDictionary *params = @{
                             @"auth" : @{ @"key" : key },
                             @"template_id" : templateId
                             };
    
    NSError *error;
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:kUrlAssemply parameters:@{@"params" : [self toJson:params]} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"name" fileName:@"name" mimeType:mimeType];
        
    } error:&error];
    
    return [[self alloc] initWithRequest:request];
}

// POST an assembly
+ (instancetype)assemblyGET:(NSString*)url {
    return [self assemblyGET:url withPollInterval:0 withMaxTries:0];
}

+ (instancetype)assemblyGET:(NSString*)url withPollInterval:(NSInteger)pollInterval withMaxTries:(NSInteger)maxTries {

    NSError *error;
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:&error];
    
    if (maxTries > 0) {
        TransloaditPollRequestOperation *pollOperation = [[TransloaditPollRequestOperation alloc] initWithRequest:request];
        [pollOperation setPollInterval:pollInterval withMaxTries:maxTries];
        return pollOperation;
    }

    return [[self alloc] initWithRequest:request];
}

+ (NSString*)toJson:(id)json {
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

#pragma mark - TransloaditPollRequestOperation

@implementation TransloaditPollRequestOperation

- (void) setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    self.successBlock = success;
    self.failureBlock = failure;
    
    __weak TransloaditPollRequestOperation *this = self;
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(this.wait) {
            [this pollAssembly:[responseObject valueForKey:@"assembly_url"]];
        }else {
            this.successBlock(operation, responseObject);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        this.failureBlock(operation, error);
    }];
}

- (void)setPollInterval:(NSInteger)pollInterval withMaxTries:(NSInteger)maxTries {
    [self setWait:YES];
    [self setDelayInterval:pollInterval];
    [self setNumTries:maxTries];
}

- (void)pollAssembly:(NSString *)url {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"Tries - %d", self.tries);
        self.tries++;
        if([[response valueForKey:@"ok"] isEqualToString:@"ASSEMBLY_COMPLETED"]) {
            self.successBlock(operation, response);
        }else {
            if(self.tries < self.numTries) {
                [self performSelector:@selector(pollAssembly:) withObject:url afterDelay:kPollInterval];
            }else {
                NSDictionary *details = [NSMutableDictionary dictionary];
                [details setValue:@"Exceeded Number Of Requests" forKey:NSLocalizedDescriptionKey];
                self.failureBlock(operation, [NSError errorWithDomain:@"TransloaditRequestOperation" code:200 userInfo:details]);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.failureBlock(operation, error);
    }];
}

@end
