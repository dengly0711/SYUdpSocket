//
//  UdpSocket.m
//  SYUdpSocket
//
//  Created by 王声远 on 2017/6/2.
//  Copyright © 2017年 王声远. All rights reserved.
//

#import "SYUdpSocket.h"
#import "GCDAsyncUdpSocket.h"

//公用日志打印LOG
#ifdef DEBUG
#define HYString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define SLOG(...) printf("%s 第%d行: %s\n", [HYString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define SLOG(...)
#endif

@interface SYUdpSocket()<GCDAsyncUdpSocketDelegate>

@property (nonatomic,strong) GCDAsyncUdpSocket *mSocket;
@property (nonatomic,assign) int myPort;

@end

@implementation SYUdpSocket

#pragma mark - 初始化网络
- (void) initUdpSocketWithMyPort:(int)port
{
    self.myPort = port;
    NSError *error = nil;
    self.mSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if (![self.mSocket bindToPort:port error:&error]) {
        SLOG(@"UDP -> Error starting server (bind): %@", error);
        return;
    }
    if (![self.mSocket enableBroadcast:YES error:&error]) {
        SLOG(@"UDP -> Error enableBroadcast (bind): %@", error);
        return;
    }
    if (![self.mSocket joinMulticastGroup:@"224.0.0.1"  error:&error]) {
        SLOG(@"UDP -> Error joinMulticastGroup (bind): %@", error);
        return;
    }
    if (![self.mSocket beginReceiving:&error]) {
        [self.mSocket close];
        SLOG(@"UDP -> Error starting server (recv): %@", error);
        return;
    }
    SLOG(@"UDP初始化成功：本地的端口：%d",port);
}

#pragma mark - 接收到数据的方法
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *ip = [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding];
    Byte *cc = (Byte *)[address bytes];
    ip = [NSString stringWithFormat:@"%d.%d.%d.%d",cc[4],cc[5],cc[6],cc[7]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(udpSocket:receverData:remote:)]) {
        [self.delegate udpSocket:self receverData:data remote:ip];
    }
}

#pragma mark - 关闭的代理方法
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    SLOG(@"UDP关闭了: socket=%@ -> error=%@",sock,error);
    [self closeUdp];
    sleep(0.2);
    [self initUdpSocketWithMyPort:self.myPort];
}

- (void)closeUdp
{
    if (self.mSocket != nil) {
        [self.mSocket close];
        self.mSocket = nil;
    }
}

#pragma mark - 发送的代理方法
- (void)udpSendDatas:(NSData *)datas ip:(NSString *)ip port:(NSInteger)port
{
    if (self.mSocket) {
        [self.mSocket sendData:datas toHost:ip port:port withTimeout:-1 tag:1];
    }
}

@end
