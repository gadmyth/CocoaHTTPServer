//
//  NSHttpHandler.h
//  iPhoneHTTPServer
//
//  Created by gadmyth on 8/16/16.
//
//

#import <Foundation/Foundation.h>

@protocol HTTPResponse;

@protocol NSHttpHandler <NSObject>

- (NSObject<HTTPResponse> *)handle:(NSDictionary *)params;

@end
