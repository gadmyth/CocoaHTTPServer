//
//  NSHttpRouter.m
//  iPhoneHTTPServer
//
//  Created by gadmyth on 8/16/16.
//
//

#import "NSHttpRouter.h"
#import "NSHttpHandler.h"


@interface NSHttpRouter()

@property (strong, nonatomic) NSMutableDictionary *routeMap;

@end

@implementation NSHttpRouter

+ (instancetype)defaultRouter {
    static dispatch_once_t onceToken;
    static NSHttpRouter *instRouter;
    dispatch_once(&onceToken, ^{
        if (!instRouter) {
            instRouter = [[NSHttpRouter alloc] init];
        }
    });
    return instRouter;
}

- (instancetype)init {
    if (self = [super init]) {
        _routeMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)loadHandlerMap:(NSDictionary *)handlerMap {
    [_routeMap setValuesForKeysWithDictionary:handlerMap];
}

- (void)setHandler:(Class)handlerClass forPath:(NSString *)path {
    if (path) {
        [_routeMap setObject:handlerClass forKey:path];
    }
}

- (NSObject<HTTPResponse> *)route:(NSString *)path params:(NSDictionary *)params {
    
    Class handlerClass = [_routeMap objectForKey:path];
    if (handlerClass) {
        if ([handlerClass conformsToProtocol:@protocol(NSHttpHandler)])  {
            NSObject<NSHttpHandler> *handler = [[handlerClass alloc] init];
            return [handler handle:params];
        } else {
            return nil;
        }
    }
    return nil;
}

@end
