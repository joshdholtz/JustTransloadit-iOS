//
//  TransloaditRequestOperation.h
//  JustTransloadit
//
//  Created by Josh Holtz on 4/22/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface TransloaditRequestOperation : AFHTTPRequestOperation

@property (nonatomic, assign) BOOL wait;
@property (nonatomic, assign) NSInteger delayInterval;
@property (nonatomic, assign) NSInteger numTries;

- (instancetype)initWithKey:(NSString*)key withTemplateId:(NSString*)templateId withData:(NSData*)data withMimeType:(NSString*)mimeType;

@end
