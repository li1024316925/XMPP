//
//  ViewController.m
//  XMPP登录注册
//
//  Created by LLQ on 16/6/21.
//  Copyright © 2016年 LLQ. All rights reserved.
//

#import "ViewController.h"
//导入头文件
#import "XMPPFramework.h"
#import "FriendsViewController.h"
#import "XMPPShare.h"

@interface ViewController ()
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsVC) name:kXMPP_Login_Success object:nil];

    
}

//登录按钮点击事件
- (IBAction)login:(UIButton *)sender {
    
    if (_passWord.text.length>0 && _userName.text.length>0) {
        //登录
        [[XMPPShare shareXMPP] loginWithUserName:_userName.text withPassword:_passWord.text];
    }
    
}

//接收到登录成功的通知后调用的方法
- (void)friendsVC{
    
    //通过storyboard中链接的Identifier弹出控制器
    [self performSegueWithIdentifier:@"login" sender:self];
    
}


@end
