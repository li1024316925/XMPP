//
//  FriendsViewController.m
//  XMPP登录注册
//
//  Created by LLQ on 16/6/21.
//  Copyright © 2016年 LLQ. All rights reserved.
//

#import "FriendsViewController.h"
#import "XMPPFramework.h"
#import "XMPPShare.h"
#import "CharViewController.h"

@interface FriendsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *friendsTableView;
}
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置好友同步到好友管理模块的通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsSuccess) name:kXMPP_Friends_Success object:nil];
}

//接收到通知后调用的方法
- (void)friendsSuccess{
    
    //数组初始化
    _dataList = [NSArray array];
    
    //获取好友花名册模块中的好友数组
    _dataList = [[XMPPShare shareXMPP].xmppRosterMemoryStorage unsortedUsers];

    //刷新表视图
    [friendsTableView reloadData];
    
}

//点击单元格时将好友数据传递给下一个页面
//获取storyboard中点击的连线推出控制器事件
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //判断是否为名字“chat“的操作
    if ([segue.identifier isEqualToString:@"chat"]) {
        //获取当前选中的单元格下标
        NSIndexPath *indexPath = [friendsTableView indexPathForSelectedRow];
        //获取当前好友信息
        XMPPUserMemoryStorageObject *user = _dataList[indexPath.row];
        
        //获取将要被退出的控制器
        CharViewController *charVC = segue.destinationViewController;
        
        //数据传递
        charVC.friendJid = user.jid;
    }
}

#pragma mark ------ UITableViewDelegate

//返回每组单元格个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataList.count;
    
}
//返回单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //单元格复用
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    //获取数据
    XMPPUserMemoryStorageObject *user = _dataList[indexPath.row];
    
    //通过tag获取label
    UILabel *nameLabel = [cell.contentView viewWithTag:100];
    UILabel *onlineLabel = [cell.contentView viewWithTag:101];
    
    nameLabel.text = user.jid.user;
    
    //判断是否为在线装态
    if ([user isOnline]) {
        onlineLabel.text = @"在线";
    }else{
        onlineLabel.text = @"离线";
    }
    
    return cell;
    
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
