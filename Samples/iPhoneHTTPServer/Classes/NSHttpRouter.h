//
//  NSHttpRouter.h
//  iPhoneHTTPServer
//
//  Created by gadmyth on 8/16/16.
//
//

#import <Foundation/Foundation.h>

@protocol HTTPResponse;

@interface NSHttpRouter : NSObject

+ (instancetype)defaultRouter;

- (NSObject<HTTPResponse> *)route:(NSString *)path params:(NSDictionary *)params;

- (void)loadHandlerMap:(NSDictionary *)handlerMap;

- (void)setHandler:(Class)handlerClass forPath:(NSString *)path;

@end
