//
//  RegisterViewController.m
//  XMPP登录注册
//
//  Created by LLQ on 16/6/22.
//  Copyright © 2016年 LLQ. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPShare.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置注册成功的通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSelf) name:kXMPP_Register_Success object:nil];
    
}

//点击完成时
- (IBAction)finish:(UIBarButtonItem *)sender {
    
    if (_passWord.text.length>0 && _userName.text.length>0) {
        //注册
        [[XMPPShare shareXMPP] registerWithUserName:_userName.text withPassword:_passWord.text];
    }
    
}

//点击取消时
- (IBAction)cancel:(UIBarButtonItem *)sender {
    
    //模态消失
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//接收到通知后调用的方法  弹出警告控制器
- (void)dismissSelf{
    
    //创建警告控制器
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"注册成功" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        [alertVC dismissViewControllerAnimated:YES completion:nil];
        //清除输入框文字
        _userName.text = @"";
        _passWord.text = @"";
        
    }];
    [alertVC addAction:action];
    
    //弹出警告控制器
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
