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

@interface TransloaditRequestOperation ()

@property (nonatomic) int tries;
@property (copy) void(^success) (AFHTTPRequestOperation*, id);
@property (copy) void(^failure) (AFHTTPRequestOperation*, NSError*);

@end

@implementation TransloaditRequestOperation

- (instancetype)initWithKey:(NSString*)key withTemplateId:(NSString*)templateId withData:(NSData*)data withMimeType:(NSString*)mimeType waitUntilExecuted:(BOOL)wait withSuccess:(void(^)(AFHTTPRequestOperation*, id))success withFailure:(void(^)(AFHTTPRequestOperation*, NSError*))failure{
    NSDictionary *params = @{
                             @"auth" : @{ @"key" : key },
                             @"template_id" : templateId
                             };
    
    NSError *error;
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:kUrlAssemply parameters:@{@"params" : [self toJson:params]} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"name" fileName:@"name" mimeType:mimeType];
        
    } error:&error];
    
    self = [super initWithRequest:request];
    if (self) {
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
        self.tries = 0;
        self.wait = wait;
        
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"SUCCESS");
            if(self.wait) {
                [self pollAssembly:[responseObject valueForKey:@"assembly_url"]];
            }else {
                self.success(operation, responseObject);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.failure(operation, error);
        }];
    }
    
    return self;
}

- (void)pollAssembly:(NSString *)url {
    NSLog(@"POLLING");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id response) {
        self.tries++;
        NSLog(@"Poll Success - %@", response);
        if([[response valueForKey:@"ok"] isEqualToString:@"ASSEMBLY_COMPLETED"]) {
            self.success(operation, response);
        }else {
            if(self.tries < kNumTries) {
                [self performSelector:@selector(pollAssembly:) withObject:url afterDelay:kPollInterval];
            }else {
                NSDictionary *details = [NSMutableDictionary dictionary];
                [details setValue:@"Exceeded Number Of Requests" forKey:NSLocalizedDescriptionKey];
                self.failure(operation, [NSError errorWithDomain:@"TransloaditRequestOperation" code:200 userInfo:details]);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.failure(operation, error);
    }];
}

- (NSString*)toJson:(id)json {
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
