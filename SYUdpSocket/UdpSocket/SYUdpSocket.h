//
//  UdpSocket.m
//  SYUdpSocket
//
//  Created by 王声远 on 2017/6/2.
//  Copyright © 2017年 王声远. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYUdpSocket;

@protocol SYUdpSocketDelegate <NSObject>
@optional

- (void)udpSocket:(SYUdpSocket *)udpSocket receverData:(NSData *)data remote:(NSString *)address;

@end

@interface SYUdpSocket : NSObject

@property (nonatomic,assign) id <SYUdpSocketDelegate> delegate;

- (void)initUdpSocketWithMyPort:(int)port;
- (void)closeUdp;
- (void)udpSendDatas:(NSData *)datas ip:(NSString *)ip port:(NSInteger)port;

@end
