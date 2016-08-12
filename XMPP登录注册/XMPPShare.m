//
//  XMPPShare.m
//  XMPP登录注册
//
//  Created by LLQ on 16/6/22.
//  Copyright © 2016年 LLQ. All rights reserved.
//

#import "XMPPShare.h"

@interface XMPPShare ()<XMPPStreamDelegate,XMPPRosterDelegate,XMPPRosterMemoryStorageDelegate>
{
    NSString *_passWord;
    BOOL _isLogin;
}
@end

@implementation XMPPShare

//单例
+ (instancetype)shareXMPP{
    
    static XMPPShare *xmppShare;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        xmppShare = [[XMPPShare alloc] init];
        
    });
    
    return xmppShare;
}

//在init方法中创建XMPPStream
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self createStream];
        
    }
    return self;
}

//创建XMPPStream
- (void)createStream{
    
    //创建XMPPStream并设置服务器地址和端口号
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream setHostName:@"192.168.1.24"];
    [_xmppStream setHostPort:5222];
    //设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    //加载好友花名册模块
    _xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
    //初始化好友管理模块
    XMPPRoster *xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterMemoryStorage dispatchQueue:dispatch_get_main_queue()];
    //激活好友管理模块
    [xmppRoster activate:_xmppStream];
    //设置代理
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //同步服务器好友到本地
    [xmppRoster setAutoFetchRoster:YES];
    
    
    //加载消息存储模块
    _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    //初始化消息管理模块
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(0, 0)];
    //激活聊条模块
    [_xmppMessageArchiving activate:_xmppStream];
    
}

//登录
- (void)loginWithUserName:(NSString *)userName withPassword:(NSString *)password{
    
    _isLogin = YES;
    
    _passWord = password;
    
    //登录前判断有无链接
    if ([_xmppStream isConnected]) {
        //断开链接
        [_xmppStream disconnect];
    }
    
    //创建JID
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kXMPP_DOMAIN resource:@"iOS"];
    //将JID设置给XMPPStream
    [_xmppStream setMyJID:jid];
    
    //链接服务器
    [_xmppStream connectWithTimeout:10 error:nil];
    
}

//注册
- (void)registerWithUserName:(NSString *)userName withPassword:(NSString *)password{
    
    _isLogin = NO;
    
    _passWord = password;
    
    //注册前判断有无链接
    if ([_xmppStream isConnected]) {
        //断开链接
        [_xmppStream disconnect];
    }
    
    //创建JID
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kXMPP_DOMAIN resource:@"iOS"];
    //将设置给XMPPStream
    [_xmppStream setMyJID:jid];
    
    //链接服务器
    [_xmppStream connectWithTimeout:10 error:nil];
    
}

#pragma mark ------ XMPPStreamDelegate

#pragma mark -- 链接
//链接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    
    if (_isLogin == YES) {
        //登录
        [sender authenticateWithPassword:_passWord error:nil];
    }else{
        //注册
        [sender registerWithPassword:_passWord error:nil];
    }
    
    
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    NSLog(@"链接失败 %@",error);
    
}

#pragma mark -- 登录
//登录验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_Login_Success object:self userInfo:nil];
    
    //初始化在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    //发送在线状态
    [sender sendElement:presence];
    
}
//验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    
    NSLog(@"验证失败");
    
}

#pragma mark -- 注册
//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_Register_Success object:self userInfo:nil];
    
}
//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    
    NSLog(@"注册失败");
    
}

#pragma mark -- 好友状态更改
//好友状态更改时调用
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    //获取自己的用户名
    NSString *userName = sender.myJID.user;
    //获取当前改变状态的用户名
    NSString *currentName = presence.from.user;
    
    //当改变状态的不是自己时
    if (![currentName isEqualToString:userName]) {
    
        if ([[presence type] isEqualToString:@"available"]) {
            //如果当前状态为在线，发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_Friends_Success object:nil];
        }else if ([[presence type] isEqualToString:@"unavailable"]){
            //如果当前状态为离线，发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_Friends_Success object:nil];
        }
        
    }
    
}

#pragma mark -- 聊天
//当有新消息时调用
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    //当有新消息时发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_MESSAGE_CHANGE object:nil];
    
}

#pragma mark ------ XMPPRosterDelegate

#pragma mark -- 同步好友
//开始同步好友
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{

}
//好友同步结束
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_Friends_Success object:nil];
    
}



@end
