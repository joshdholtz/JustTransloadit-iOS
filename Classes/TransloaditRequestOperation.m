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

typedef void(^SuccessBlock) (AFHTTPRequestOperation* operation, id responseObject);
typedef void(^FailureBlock) (AFHTTPRequestOperation* operation, NSError* error);

@interface TransloaditRequestOperation ()

@property (nonatomic, assign) NSInteger tries;
@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

@end

@implementation TransloaditRequestOperation

- (instancetype)initWithKey:(NSString*)key withTemplateId:(NSString*)templateId withData:(NSData*)data withMimeType:(NSString*)mimeType {
    NSDictionary *params = @{
                             @"auth" : @{ @"key" : key },
                             @"template_id" : templateId
                             };
    
    NSError *error;
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:kUrlAssemply parameters:@{@"params" : [self toJson:params]} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"name" fileName:@"name" mimeType:mimeType];
        
    } error:&error];
    
    self.wait = NO;
    self.delayInterval = kPollInterval;
    self.numTries =  kNumTries;
    
    self = [super initWithRequest:request];
    if (self) {
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    
    return self;
}

- (void) setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    self.successBlock = success;
    self.failureBlock = failure;
    
    __block __weak TransloaditRequestOperation *this = self;
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

- (void)pollAssembly:(NSString *)url {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id response) {
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

- (NSString*)toJson:(id)json {
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
