//
//  ViewController.m
//  QQ聊天布局
//
//  Created by TianGe-ios on 14-8-19.
//  Copyright (c) 2014年 TianGe-ios. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "ViewController.h"
#import "MessageModel.h"
#import "CellFrameModel.h"
#import "MessageCell.h"

#define kToolBarH 44
#define kTextFieldH 30
#define Label_Normal_Color [UIColor colorWithRed:41/255.0 green:40/255.0 blue:41/255.0 alpha:1.]

typedef enum
{
    KSendSoundBtn = 99,
    KAddMoreBtn,
    KExpressBtn,
}ButtonCliked;


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *_cellFrameDatas;
    UITableView *_chatView;
    UIImageView *_toolBar;
    UITextField *_myTextField;
    UIView *_sendSoundView;
    UIView *_addMoreView;
    UIView *_expressView;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.view.frame = CGRectMake(0, 0, 320, 568+160);
    
    //0.加载数据
    [self loadData];
    
    //1.tableView
    [self addChatView];
    
    //2.工具栏
    [self addToolBar];
}

/**
 *  记载数据
 */
- (void)loadData
{
    _cellFrameDatas =[NSMutableArray array];
    NSURL *dataUrl = [[NSBundle mainBundle] URLForResource:@"messages.plist" withExtension:nil];
    NSArray *dataArray = [NSArray arrayWithContentsOfURL:dataUrl];
    for (NSDictionary *dict in dataArray) {
        MessageModel *message = [MessageModel messageModelWithDict:dict];
        CellFrameModel *lastFrame = [_cellFrameDatas lastObject];
        CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
        message.showTime = ![message.time isEqualToString:lastFrame.message.time];
        cellFrame.message = message;
        [_cellFrameDatas addObject:cellFrame];
    }
}
/**
 *  添加TableView
 */
- (void)addChatView
{
    self.view.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];
    UITableView *chatView = [[UITableView alloc] init];
    chatView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - kToolBarH-160);
    chatView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];
    chatView.delegate = self;
    chatView.dataSource = self;
    chatView.separatorStyle = UITableViewCellSeparatorStyleNone;
    chatView.allowsSelection = NO;
    [chatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
    _chatView = chatView;
    
    [self.view addSubview:chatView];
}
/**
 *  添加工具栏
 */
- (void)addToolBar
{
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.frame = CGRectMake(0, self.view.frame.size.height - kToolBarH-160, self.view.frame.size.width, kToolBarH);
    bgView.image = [UIImage imageNamed:@"chat_bottom_bg"];
    bgView.userInteractionEnabled = YES;
    _toolBar = bgView;
    [self.view addSubview:bgView];
    
    UIButton *sendSoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendSoundBtn.frame = CGRectMake(0, 0, kToolBarH, kToolBarH);
    [sendSoundBtn setImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
    [sendSoundBtn setImage:[UIImage imageNamed:@"chat_bottom_voice_press"] forState:UIControlStateHighlighted];
    sendSoundBtn.tag = KSendSoundBtn;
    [sendSoundBtn addTarget:self action:@selector(buttonCliked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:sendSoundBtn];
    
    UIButton *addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreBtn.frame = CGRectMake(self.view.frame.size.width - kToolBarH, 0, kToolBarH, kToolBarH);
    [addMoreBtn setImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
    [addMoreBtn setImage:[UIImage imageNamed:@"chat_bottom_up_press"] forState:UIControlStateHighlighted];
    addMoreBtn.tag = KAddMoreBtn;
    [addMoreBtn addTarget:self action:@selector(buttonCliked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:addMoreBtn];
    
    UIButton *expressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    expressBtn.frame = CGRectMake(self.view.frame.size.width - kToolBarH * 2, 0, kToolBarH, kToolBarH);
    [expressBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [expressBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
    expressBtn.tag = KExpressBtn;
    [expressBtn addTarget:self action:@selector(buttonCliked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:expressBtn];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.returnKeyType = UIReturnKeySend;
    textField.enablesReturnKeyAutomatically = YES;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 1)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.frame = CGRectMake(kToolBarH, (kToolBarH - kTextFieldH) * 0.5, self.view.frame.size.width - 3 * kToolBarH, kTextFieldH);
    textField.background = [UIImage imageNamed:@"chat_bottom_textfield"];
    textField.delegate = self;
    _myTextField = textField;
    [bgView addSubview:textField];
    
    //语音部分
    UIView *sendSoundView = [[UIView alloc] init];
    sendSoundView.frame = CGRectMake(0, bgView.frame.origin.y+kToolBarH, self.view.frame.size.width, 160);
    _sendSoundView = sendSoundView;
    [self.view addSubview:sendSoundView];

    UIImage *image = [UIImage imageNamed:@"aio_voiceChange_effect_0"];
    UIButton *sendSoundButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    sendSoundButton.frame = CGRectMake(sendSoundView.frame.size.width/2-image.size.width/2, 60, image.size.width,image.size.height);
    [sendSoundButton setImage:image forState:UIControlStateNormal];
    [sendSoundButton addTarget:self action:@selector(buttonClikeds:) forControlEvents:UIControlEventTouchUpInside];
    [sendSoundView addSubview:sendSoundButton];
    
    UILabel *sendSoundLable = [[UILabel alloc] initWithFrame:CGRectMake(0, sendSoundButton.frame.origin.y -40, self.view.frame.size.width, 40)];
    sendSoundLable.textAlignment = NSTextAlignmentCenter;
    sendSoundLable.text = @"按住说话";
    sendSoundLable.font = [UIFont systemFontOfSize:13];
    sendSoundLable.textColor = [UIColor darkGrayColor];
    [sendSoundView addSubview:sendSoundLable];
    
    //拍照录音
    UIView *addMoreView = [[UIView alloc] init];
    addMoreView.frame = CGRectMake(0,  bgView.frame.origin.y+kToolBarH, self.view.frame.size.width, 160);
    _addMoreView = addMoreView;
    [self.view addSubview:addMoreView];
    
    NSArray *arrayAddMoreImage = [NSArray arrayWithObjects:@"aio_icons_freeaudio",@"aio_icons_camera",@"aio_icons_groupvideo",@"aio_icons_camera_video",@"aio_icons_location",@"aio_icons_music",@"aio_icons_pic",@"aio_icons_favorite", nil];
    NSArray *arrayAddMoreName = [NSArray arrayWithObjects:@"QQ电话",@"拍照",@"视频",@"录制",@"位置",@"QQ音乐",@"图片",@"收藏", nil];
    NSInteger speas = 20;
    NSInteger btnWidth = 55;
    
    for (int i = 0; i < arrayAddMoreImage.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(speas + (speas + btnWidth) * (i % 4), (i / 4) * (btnWidth + 15) , btnWidth, btnWidth);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth - 40) / 2, 10, 40, 40)];
        imgView.image = [UIImage imageNamed:arrayAddMoreImage[i]];
        [btn addSubview:imgView];
        [btn setTitle:arrayAddMoreName[i] forState:UIControlStateNormal];
        [btn setTitleColor:Label_Normal_Color forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, -70, 0);
        [addMoreView addSubview:btn];
    }
    
    //表情部分
    UIView *expressView = [[UIView alloc] init];
    expressView.frame = CGRectMake(0, bgView.frame.origin.y+kToolBarH, self.view.frame.size.width, 160);
    _expressView = expressView;
    [self.view addSubview:expressView];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"];
    NSArray *data = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSInteger speasExpress = 30;
    NSInteger btnWidthExpress = 20;
    
    UIScrollView *expressScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, expressView.frame.size.width, expressView.frame.size.height)];
    expressScroll.userInteractionEnabled = YES;
    expressScroll.contentSize = CGSizeMake(expressView.frame.size.width*(data.count/18 + 1), expressView.frame.size.height);
    expressScroll.showsHorizontalScrollIndicator = NO;
    expressScroll.showsVerticalScrollIndicator = NO;
    expressScroll.pagingEnabled = YES;
    expressScroll.scrollEnabled = YES;
    [expressView addSubview:expressScroll];
    
    UIPageControl *pagaControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, expressScroll.frame.origin.y+expressScroll.frame.size.height-30, expressView.frame.size.width, 30)];
    pagaControl.backgroundColor = [UIColor clearColor];
    pagaControl.numberOfPages = (data.count/18+1);
    pagaControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    pagaControl.currentPageIndicatorTintColor = [UIColor redColor];
    pagaControl.currentPage = 0;
    [expressView addSubview:pagaControl];
    
    NSLog(@"%@",expressScroll);
    
    for (int i = 0; i < 18; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((speasExpress + (speasExpress + btnWidthExpress) * (i % 6))+(i/18)*expressView.frame.size.width, (i / 6) * (btnWidthExpress + 20) , btnWidthExpress, btnWidthExpress);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidthExpress - 40) / 2, 10, 30, 30)];
        imgView.image = [UIImage imageNamed:data[i]];
        [btn addSubview:imgView];
        [btn addTarget:self action:@selector(buttonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [expressScroll addSubview:btn];
        NSLog(@"%@",btn);
    }
    
    for (int i = 18; i < 36; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((speasExpress + (speasExpress + btnWidthExpress) * (i % 6))+(i/18)*expressView.frame.size.width, ((i-18) / 6) * (btnWidthExpress + 20) , btnWidthExpress, btnWidthExpress);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidthExpress - 40) / 2, 10, 30, 30)];
        imgView.image = [UIImage imageNamed:data[i]];
        [btn addSubview:imgView];        [expressScroll addSubview:btn];
        NSLog(@"%@",btn);
    }
    
    for (int i = 36; i < 54; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((speasExpress + (speasExpress + btnWidthExpress) * (i % 6))+(i/18)*expressView.frame.size.width, ((i-36) / 6) * (btnWidthExpress + 20) , btnWidthExpress, btnWidthExpress);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidthExpress - 40) / 2, 10, 30, 30)];
        imgView.image = [UIImage imageNamed:data[i]];
        [btn addSubview:imgView];
        [expressScroll addSubview:btn];
        NSLog(@"%@",btn);
    }
    
    for (int i = 54; i < data.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((speasExpress + (speasExpress + btnWidthExpress) * (i % 6))+(i/18)*expressView.frame.size.width, ((i-54) / 6) * (btnWidthExpress + 20) , btnWidthExpress, btnWidthExpress);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidthExpress - 40) / 2, 10, 30, 30)];
        imgView.image = [UIImage imageNamed:data[i]];
        [btn addSubview:imgView];        [expressScroll addSubview:btn];
        
        NSLog(@"%@",btn);
    }
    
}


#pragma mark -ButtonCliked

- (void)buttonCliked:(UIButton *)btn
{
    [_myTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -160);
    }];

    switch (btn.tag)
    {
        case KSendSoundBtn:
        {
            _sendSoundView.hidden = NO;
            _addMoreView.hidden = YES;
            _expressView.hidden = YES;
        }
            break;
        case KAddMoreBtn:
        {
            _sendSoundView.hidden = YES;
            _addMoreView.hidden = NO;
            _expressView.hidden = YES;
        }
            break;
        case KExpressBtn:
        {
            _sendSoundView.hidden = YES;
            _addMoreView.hidden = YES;
            _expressView.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - tableView的数据源和代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellFrameDatas.count;
}

- (MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.cellFrame = _cellFrameDatas[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellFrameModel *cellFrame = _cellFrameDatas[indexPath.row];
    return cellFrame.cellHeght;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField的代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //1.获得时间
    NSDate *senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    //2.创建一个MessageModel类
    MessageModel *message = [[MessageModel alloc] init];
    message.text = textField.text;
    message.time = locationString;
    message.type = 0;
    
    //3.创建一个CellFrameModel类
    CellFrameModel *cellFrame = [[CellFrameModel alloc] init];
    CellFrameModel *lastCellFrame = [_cellFrameDatas lastObject];
    message.showTime = ![lastCellFrame.message.time isEqualToString:message.time];
    cellFrame.message = message;
    
    //4.添加进去，并且刷新数据
    [_cellFrameDatas addObject:cellFrame];
    [_chatView reloadData];
    
    //5.自动滚到最后一行
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_cellFrameDatas.count - 1 inSection:0];
    [_chatView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    textField.text = @"";
    
    return YES;
}

- (void)endEdit
{
    [self.view endEditing:YES];
}

/**
 *  键盘发生改变执行
 */
- (void)keyboardWillChange:(NSNotification *)note
{
    NSLog(@"%@", note.userInfo);
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, moveY);
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
