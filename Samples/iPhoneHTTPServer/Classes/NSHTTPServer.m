//
//  NSHTTPServer.m
//  iPhoneHTTPServer
//
//  Created by gadmyth on 8/28/16.
//  Copyright © 2016 gadmyth. All rights reserved.
//

#import "NSHTTPServer.h"
#import <iPhoneServer/iPhoneServer.h>

@implementation NSHTTPServer

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

static HTTPServer *httpServer;

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLaunchingWithOptions:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

+ (void)didFinishLaunchingWithOptions:(NSNotification *)notification {
    
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"inner_server" ofType:@"plist"];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:pathStr];
    if (!config) {
        NSLog(@"Warning: Can't find the inner_server.plist!");
        return;
    }
    else {
        NSLog(@"Load the inner_server.plist config file succeed!");
    }
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    httpServer = [[HTTPServer alloc] init];
    
    // set document root
    NSString *p = config[@"webPath"] ?: @"/";
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:p];
    DDLogInfo(@"Setting document root: %@", webPath);
    [httpServer setDocumentRoot:webPath];
    
    // set port
    NSInteger port = config[@"port"] ? [config[@"port"] integerValue] : 6688;
    [httpServer setPort:port];
    
    // connection class
    [httpServer setConnectionClass:[NSHTTPConnection class]];
    
    // set handlers
    if (config[@"handlers"]) {
        for (NSDictionary *handler in config[@"handlers"]) {
            NSString *className = handler[@"name"];
            NSString *path = handler[@"path"];
            [[NSHttpRouter defaultRouter] setHandler:NSClassFromString(className) forPath:path];
            DDLogInfo(@"load handler: %@ -> %@", className, path);
        }
    }
    [self startServer];
}

+ (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self startServer];
}

+ (void)applicationDidEnterBackground:(NSNotification *)notification {
    [httpServer stop];
}

+ (void)startServer
{
    // Start the server (and check for problems)
    
    NSError *error;
    if([httpServer start:&error])
    {
        DDLogInfo(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
    }
    else
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
}

@end
