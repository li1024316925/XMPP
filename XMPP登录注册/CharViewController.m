//
//  CharViewController.m
//  XMPP登录注册
//
//  Created by LLQ on 16/6/23.
//  Copyright © 2016年 LLQ. All rights reserved.
//

#import "CharViewController.h"
#import "XMPPShare.h"

@interface CharViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSArray *_dataList;
    
    UIView *_view;
}
@property (weak, nonatomic) IBOutlet UITableView *charTableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *sendView;

@end

@implementation CharViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _friendJid.user;
    //设置有新消息时通知的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMsg) name:kXMPP_MESSAGE_CHANGE object:nil];
    
    //第一次加载时可能通知的发出在设置监听之前，手动调用获取消息的方法
    [self getMsg];
    
    //键盘的弹出与收起，系统都会发送通知，设置通知监听，来调用方法
    //设置键盘通知监听
    //键盘将要弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘将要收起
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //创建手势识别器
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
    //点击次数
    singleTap.numberOfTapsRequired = 1;
    //作用到表视图
    [_charTableView addGestureRecognizer:singleTap];
    
}

//手势事件
- (void)singleTapAction{
    
    //结束编辑（可以收起键盘）
    [self.view endEditing:YES];
    
}

//监听到通知时调用的方法
- (void)getMsg{
    
    //获取消息数组
    //获取上下文
    NSManagedObjectContext *context = [XMPPShare shareXMPP].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    //获取被查询的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:[XMPPShare shareXMPP].xmppMessageArchivingCoreDataStorage.messageEntityName inManagedObjectContext:context];
    //创建查询条件
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置被查询的实体
    [request setEntity:entity];
    //设置查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@",self.friendJid.bare];
    //设置谓词条件
    [request setPredicate:predicate];
    //设置排序条件
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:@[sort]];
    //执行查询条件
    NSArray *msgs = [context executeFetchRequest:request error:nil];
    
    //存入数据数组
    if (msgs.count>0) {
        _dataList = [NSArray arrayWithArray:msgs];
    }else{
        _dataList = [NSArray array];
    }
    
    //刷新表视图
    [_charTableView reloadData];
    
    if (_dataList.count>0) {
        //滑动到最底部
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataList.count-1 inSection:0];
        [_charTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
}

//监听到键盘将要弹出时调用的方法
- (void)keyboardWillShow:(NSNotification *)notification{
    
    //获取键盘frame
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    //获取键盘动画时间
    NSTimeInterval keyboardAnimationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //动画
    [UIView animateWithDuration:keyboardAnimationTime animations:^{
    
//        _charTableView.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight);
//        _sendView.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight);
        self.view.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight);
    
    } completion:nil];
    
}
//键盘将要收起时调用
- (void)keyboardWillHide:(NSNotification *)notification{
    
    [UIView animateWithDuration:0.3 animations:^{
    
        //修改发送视图frame
//        _charTableView.transform = CGAffineTransformIdentity;
//        _sendView.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformIdentity;
    
    } completion:nil];
    
}

//发送消息
- (IBAction)sendMsg:(UIButton *)sender {
    
    //设置消息 类型  发送给谁（JID）
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //添加消息
    [msg addBody:_textField.text];
    //发送消息
    [[XMPPShare shareXMPP].xmppStream sendElement:msg];
    //刷新消息数组
    [self getMsg];
    
    _textField.text = @"";
    
}


#pragma mark ------ UITableViewDataSource

//返回每组单元格个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataList.count;
    
}

//返回单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //从消息数组中取出消息
    XMPPMessageArchiving_Message_CoreDataObject *msg = _dataList[indexPath.row];
    //判断是否是自己发出去的消息
    NSString *identifier = [msg isOutgoing] ? @"selfCell" : @"friendCell";
    //使用单元格的identifier复用单元格
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //给单元格的label赋值
    UILabel *msgLabel = [cell.contentView viewWithTag:100];
    msgLabel.text = msg.body;
    
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
