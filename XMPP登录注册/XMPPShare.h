//
//  XMPPShare.h
//  XMPP登录注册
//
//  Created by LLQ on 16/6/22.
//  Copyright © 2016年 LLQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPShare : NSObject

@property(nonatomic,strong)XMPPStream *xmppStream;
@property(nonatomic,strong)XMPPRosterMemoryStorage *xmppRosterMemoryStorage;
@property(nonatomic,strong)XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property(nonatomic,strong)XMPPMessageArchiving *xmppMessageArchiving;

+ (instancetype)shareXMPP;

//登录
- (void)loginWithUserName:(NSString *)userName withPassword:(NSString *)password;

//注册
- (void)registerWithUserName:(NSString *)userName withPassword:(NSString *)password;

@end
