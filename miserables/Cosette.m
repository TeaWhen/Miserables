//
//  Cosette.m
//  miserables
//
//  Created by Xhacker on 2013-04-08.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "Cosette.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

NSString * const baseURL = @"http://42.121.18.11:24601/";

@interface Cosette ()

@property AFHTTPClient *httpClient;

- (void)requestJSONWithPath:(NSString *)path success:(void (^)(id))success failure:(void (^)(NSError *))failure;

@end

@implementation Cosette

+ (Cosette *)me
{
    static Cosette *theOnly = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{theOnly = [[self alloc] init];});
    return theOnly;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [self.httpClient setParameterEncoding:AFJSONParameterEncoding];
    }
    return self;
}

- (void)requestJSONWithPath:(NSString *)path success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:path parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Got JSON: %@", JSON);
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Failed to get JSON: %@", [error userInfo]);
        failure(error);
    }];
    [operation start];
}

- (void)requestVersionWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self requestJSONWithPath:@"app/version/" success:success failure:failure];
}

- (void)requestNoticeWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{    
    [self requestJSONWithPath:@"app/notice/" success:success failure:failure];
}

- (void)getNewNoticeWithCallback:(void (^)(NSString *))callback
{
    NSDate *lastNoticed = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastNoticed"];
    if (!lastNoticed) {
        lastNoticed = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:lastNoticed forKey:@"LastNoticed"];
    }
    
    [self requestNoticeWithSuccess:^(id JSON) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-mm-dd hh:mm:ss"];
        NSDate *noticeTime = [dateFormatter dateFromString:JSON[@"time"]];
        if (noticeTime > lastNoticed) {
            callback(JSON[@"content"]);
        }
        else {
            callback(nil);
        }
    } failure:^(NSError *error) {
        callback(nil);
    }];
}

- (void)requestLibrariesWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self requestJSONWithPath:@"library/" success:success failure:failure];
}

@end