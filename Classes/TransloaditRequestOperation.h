//
//  TransloaditRequestOperation.h
//  JustTransloadit
//
//  Created by Josh Holtz on 4/22/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface TransloaditRequestOperation : AFHTTPRequestOperation

// Assembly
+ (instancetype)assemblyGET:(NSString*)urll;
+ (instancetype)assemblyGET:(NSString*)url withPollInterval:(NSInteger)pollInterval withMaxTries:(NSInteger)maxTries;

+ (instancetype)assemblyPOST:(NSString*)key withTemplateId:(NSString*)templateId withData:(NSData*)data withMimeType:(NSString*)mimeType;

@end

@interface TransloaditPollRequestOperation : TransloaditRequestOperation

- (void)setPollInterval:(NSInteger)pollInterval withMaxTries:(NSInteger)maxTries;

@end
