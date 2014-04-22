//
//  TransloaditRequestOperation.m
//  JustTransloadit
//
//  Created by Josh Holtz on 4/22/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kUrlAssemply @"http://api2.transloadit.com/assemblies"

#import "TransloaditRequestOperation.h"

#import <AFNetworking/AFNetworking.h>

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
    
    self = [super initWithRequest:request];
    if (self) {
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    
    return self;
}

- (NSString*)toJson:(id)json {
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
