//
//  TestHttpHandler.m
//  iPhoneHTTPServer
//
//  Created by gadmyth on 8/16/16.
//
//

#import "TestHttpHandler.h"
#import "HTTPDataResponse.h"

@implementation TestHttpHandler

- (NSObject<HTTPResponse> *)handle:(NSDictionary *)params {
    NSData *data = [@"<html><body>{\"errorCode\": \"0000\"}</body></html>" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSObject<HTTPResponse> *response = [[HTTPDataResponse alloc] initWithData:data];
    return response;
}

@end
