//
//  RoomListViewController.m
//  MetaChatDemo
//
//  Created by FanPengpeng on 2022/8/9.
//

#import "MCRoomListViewController.h"
#import "MCRoomItemCell.h"
#import "Game2035OCNew-swift.h"
#import "MBProgressHUD+Extension.h"
#import "UIViewController+Extension.h"
#import "MJRefresh/MJRefresh.h"
#import "SelectRoleViewController.h"
#import "SelectRoleShowUnityManager.h"


static CGFloat const kItemWidth = 159;
static CGFloat const kItemHeight = 172;


@interface MCRoomListViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,MCRoomManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

// 房间为空的图
@property (weak, nonatomic) IBOutlet UIView *emptyRoomView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImgView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createBtnBottomCons;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) NSArray<MCRoom *> * roomList;

@property (strong, nonatomic) SelectRoleShowUnityManager *unityManger;

@end

@implementation MCRoomListViewController

- (void)dealloc {
    [[MCRoomManager shared] remoteDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self loginRoom];
    [self setUpUIForEmpty:YES];
    [self addObserver];
    [self addRefresh];
    [self addTapGesture];
//    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getRooms:NO];
    });
    [self forcePortrait];  
}

- (void)forcePortrait{
    if (@available(iOS 16.0, *)) {
        @try {
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene *ws = (UIWindowScene *)array[0];
            NSArray *windows = [ws windows];
            for (UIWindow *win in windows) {
                if(win.bounds.size.width > win.bounds.size.height && self.view.window != win) {
                    win.hidden = YES;
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
            
        }
    }
}

- (void)loginRoom {
    __weak typeof(self) weakSelf = self;
    self.createButton.hidden = YES;
    [MBProgressHUD showLoadingInView:self.view];
    [[MCRoomManager shared] loginEMWithSuccess:^{
        [[MCRoomManager shared] leaveAllJoinedGroupsWithCompletion:^{
            [weakSelf getRooms:YES];
        }];
    }];
}

- (void)getRooms:(BOOL)showLoading {
    if (showLoading) {
        [MBProgressHUD showLoadingInView:self.view];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD dismissLoadingInView:self.view];
//        weakSelf.createButton.hidden = NO;
        NSArray *roomList = [self createRoomList];
        BOOL isEmpty = roomList.count == 0;
        weakSelf.roomList = roomList;
        [weakSelf setUpUIForEmpty:isEmpty];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    });
}

- (NSArray<MCRoom *> *)createRoomList {
    NSArray *nameArray = @[@"欢迎",@"古风",@"夜店",@"劈瓜"];
    NSMutableArray *roomList = [NSMutableArray arrayWithCapacity:nameArray.count];
    for (int i = 0; i < nameArray.count; i ++) {
        MCRoom *room = [MCRoom new];
        room.roomId = [NSString stringWithFormat:@"%d", 111 + i];
        room.roomName = nameArray[i];
        room.sceneId = @(i - 1);
        room.img = [NSString stringWithFormat:@"room_cover_%d",i % 4];
        [roomList addObject:room];
    }
    return roomList;
}

- (void)addObserver{
    [[MCRoomManager shared] addDelegate:self];
}

- (void)addRefresh {
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getRooms:NO];
    }];
}

- (void)addTapGesture {
    [self.emptyRoomView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapEmptyRoomView)]];
}

- (void)didTapEmptyRoomView {
    [self getRooms:YES];
}

- (void)setUpUIForEmpty:(BOOL) isEmpty{
    self.title = @"Game2035";
    self.progressImgView.image = [UIImage imageNamed:MCLocalizedString(@"progress_image_name")];
    self.emptyRoomView.hidden = !isEmpty;
    self.collectionView.hidden = isEmpty;
    CGFloat emptyConstant = [UIScreen mainScreen].bounds.size.height - 534 - self.view.safeAreaInsets.top;
    DLog("emptyConstant === %.f, [UIScreen mainScreen].bounds.size.height = %.f, self.view.safeAreaInsets.top = %.f",emptyConstant, [UIScreen mainScreen].bounds.size.height,self.view.safeAreaInsets.top);
    self.createBtnBottomCons.constant = isEmpty ? emptyConstant : 0;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 48, 0);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = 22;
    style.maximumLineHeight = 22;
    self.welcomeLabel.attributedText = [[NSAttributedString alloc] initWithString:MCLocalizedString(@"Welcome to 2035") attributes:@{NSParagraphStyleAttributeName: style}];
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)tryJoinRoom:(MCRoom *)room {
    if (room.pwd.length > 0) {
        [self showInputPasswordAlertWithRoom:room];
    }else{
        [self joinRoom:room];
    }
}

- (void)showInputPasswordAlertWithRoom:(MCRoom *)room {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MCLocalizedString(@"Please enter the password") message:nil preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *tf;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"密码";
        textField.keyboardType = UIKeyboardTypeNumberPad;
        tf = textField;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:MCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *conmfirmAction = [UIAlertAction actionWithTitle:MCLocalizedString(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([tf.text isEqualToString:room.pwd]) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self joinRoom:room];
        }else{
            [MBProgressHUD showError:@"密码错误" inView:self.view];
        }
    }];
    [alert addAction:conmfirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)joinRoom:(MCRoom *)room{
    if ([room.roomId isEqual:@"111"]) {
        WelComeViewController *vc = [WelComeViewController new];
//        vc.isWelcome = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    SelectRoleShowUnityManager *manager  = [SelectRoleShowUnityManager new];
    manager.roomId = room.roomId;
    manager.sceneId = [room.sceneId integerValue];
//    if ([room.roomName isEqualToString:@"夜店"]) {
//        manager.sceneId = 1;
//    }else {
//        manager.sceneId = 0;
//    }
    self.unityManger = manager;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.unityManger showUnityVC];        
    });
    
    
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    SelectRoleViewController *selectVC = [storyboard instantiateViewControllerWithIdentifier:@"SelectVC"];
    selectVC.roomId = room.roomId;
    selectVC.title = room.roomName;
    if ([room.roomName isEqualToString:@"夜店"]) {
        selectVC.sceneId = 1;
    }else {
        selectVC.sceneId = 0;
    }
    [self.navigationController pushViewController:selectVC animated:YES];
     */
    
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - collection view delegate & data source

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCRoomItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MCRoomItemCell" forIndexPath:indexPath];
    MCRoom *room = self.roomList[indexPath.item];
    cell.room = room;
    __weak typeof(self) wSelf = self;
    cell.joinButtonCliced = ^{
        [wSelf tryJoinRoom:room];
    };
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.roomList.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MCRoom *room = self.roomList[indexPath.item];
    [self tryJoinRoom:room];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat left = 20;
    CGFloat right = 20;
    CGFloat top = 20;
    CGFloat bottom = 20;
    if (self.roomList.count == 1) {
        right = CGRectGetWidth(collectionView.bounds) - left - kItemWidth;
    }
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kItemWidth, kItemHeight);
}

- (void)tryDeleteAllRooms {
    __weak typeof(self) wSelf = self;
    [self ex_showAlertWithTitle:@"确定删除所有房间吗" message:nil cancelHandler:^(UIAlertAction * _Nonnull action) {
    } comfirmHandler:^(UIAlertAction * _Nonnull action) {
        for (MCRoom *room in wSelf.roomList) {
            [[MCRoomManager shared] deleteRoom:room.roomId];
        }
    }];
}

- (void)roomListDidUpdate:(NSArray<NSString *> *)roomList {
    DLog(@"------群组发生变化-------grouplist count === %@",roomList);
    [self getRooms:NO];
}

@end


@interface MCTouchView : UIView

@end

@implementation MCTouchView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.tapCount > 5) {
        
    }
}

@end
