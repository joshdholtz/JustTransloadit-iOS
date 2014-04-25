//
//  TransloaditRequestOperation.h
//  JustTransloadit
//
//  Created by Josh Holtz on 4/22/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

#pragma mark - TransloaditRequestOperation

@interface TransloaditRequestOperation : AFHTTPRequestOperation

/*
 * Assembly API Requests
 */
+ (instancetype)assemblyGET:(NSString*)urll;
+ (instancetype)assemblyGET:(NSString*)url withPollInterval:(NSInteger)pollInterval withMaxTries:(NSInteger)maxTries;

+ (instancetype)assemblyPOST:(NSString*)key withTemplateId:(NSString*)templateId withData:(NSData*)data withMimeType:(NSString*)mimeType;
+ (instancetype)assemblyPOST:(NSString*)key withTemplateId:(NSString*)templateId withData:(NSData*)data withMimeType:(NSString*)mimeType withPollInterval:(NSInteger)pollInterval withMaxTries:(NSInteger)maxTries;

@end

#pragma mark - TransloaditPollRequestOperation

@interface TransloaditPollRequestOperation : TransloaditRequestOperation

@end
