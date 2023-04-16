//
//  GBLoginViewController.m
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/16.
//

#import "GBLoginViewController.h"
#import "VLLoginInputPhoneView.h"
#import "VLLoginInputVerifyCodeView.h"
#import "VLPrivacyCustomView.h"
#import "VLToast.h"
#import "LSTPopView.h"
#import "NSString+Helper.h"
#import "Game2035OCNew-swift.h"
#import "VLPopImageVerifyView.h"
#import "AttributedTextView.h"

@import Masonry;
@import SDWebImage;
@import LEEAlert;

static NSString *const kURLPathH5UserAgreement = @"";
static NSString *const kURLPathH5Privacy = @"";


@interface GBLoginViewController ()<UITextViewDelegate,VLLoginInputVerifyCodeViewDelegate, VLPrivacyCustomViewDelegate,VLPopImageVerifyViewDelegate>

@property (nonatomic, strong) UIImageView *backGroundImgView;
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) VLLoginInputPhoneView *phoneView;
@property (nonatomic, strong) VLLoginInputVerifyCodeView *verifyView;
@property (nonatomic, strong) VLPrivacyCustomView *privacyCustomView;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *agreeButton;    // 同意按钮
@property (nonatomic, strong) LSTPopView *popView;
@property (nonatomic, assign) bool policyAgreed;
@property (nonatomic, strong) AttributedTextView *textView;

@end

@implementation GBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self showAlertPrivacyView];
}

- (void)showAlertPrivacyView
{
    if(_policyAgreed == NO) {
        [self alertPrivacyAlertView:0];
    }
}

- (void)setupViews {
    
    [self.view addSubview:self.backGroundImgView];
    self.backGroundImgView.image = [UIImage imageNamed:@"home_bg_image"];
    
    [self.view addSubview:self.appNameLabel];
    [self.view addSubview:self.phoneView];
    [self.view addSubview:self.verifyView];
    [self.view addSubview:self.agreeButton];
    [self addAttributeView];
    [self.view addSubview:self.loginButton];
}

- (void)setupLayout {
    
    [self.appNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(kStatusBarHeight + 125);

    }];
    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.appNameLabel);
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(self.appNameLabel.mas_bottom).offset(24);
    }];

    [self.verifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.appNameLabel);
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(self.phoneView.mas_bottom).offset(24);
    }];

    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.width.height.mas_equalTo(24);
        make.top.mas_equalTo(self.verifyView.mas_bottom).offset(20);
    }];

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.agreeButton.mas_right).offset(5);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.agreeButton).offset(-3);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(self.verifyView.mas_bottom).offset(64);
    }];
}

-(void)addAttributeView {
    NSString *textString = @"我已阅读并同意 用户协议 及 隐私政策 ";
    NSRange range1 = NSMakeRange(8, 4);
    NSRange range2 = NSMakeRange(15, 4);
    NSArray *array = [[NSArray alloc]initWithObjects:@"用户协议",@"隐私政策", nil];
    NSMutableArray *ranges = [[NSMutableArray alloc]init];
    [ranges addObject:[NSValue valueWithRange:range1]];
    [ranges addObject:[NSValue valueWithRange:range2]];
    _textView = [[AttributedTextView alloc]initWithFrame:CGRectZero text: textString AttributedStringS:array ranges:ranges textColor: [[UIColor alloc] initWithHexString:@"#6C7192"] attributeTextColor:[[UIColor alloc] initWithHexString:@"#009FFF"]];
    _textView.delegate = self;
    [self.view addSubview:_textView];
}

- (void)alertPrivacyAlertView:(int)pass {
    __weak typeof(self) wSelf = self;
    [LEEAlert alert].config
    .LeeMaxWidth(300)
    .LeeMaxHeight(380)
    .LeeHeaderColor([UIColor whiteColor])
    .LeeAddTitle(^(UILabel * _Nonnull label) {
        label.text = MCLocalizedString(@"个人信息保护指引");
        label.textColor = [[UIColor alloc] initWithHexString:@"#040925"];
        label.font = [UIFont systemFontOfSize:16];
    })
    .LeeItemInsets(UIEdgeInsetsMake(20, 10, 10, 0))
    .LeeAddCustomView(^(LEECustomView *custom) {
        wSelf.privacyCustomView = [wSelf getPrivacyCustomView:pass];
        custom.view = wSelf.privacyCustomView;
        custom.view.superview.layer.masksToBounds = NO;
        custom.positionType = LEECustomViewPositionTypeCenter;
    })
    // 想为哪一项设置间距范围 直接在其后面设置即可 ()
    .LeeItemInsets(UIEdgeInsetsMake(10, 10, 20, 10))
    .LeeShow();
}

#pragma mark - Public Methods

- (void)configNavigationBar:(UINavigationBar *)navigationBar {
//    [super configNavigationBar:navigationBar];
}
- (BOOL)preferredNavigationBarHidden {
    return YES;
}

#pragma mark - Request

- (void)loadVerifyCodeRequest {
 
}

#pragma mark - VLPrivacyCustomViewDelegate

- (void)privacyCustomViewDidClick:(VLPrivacyClickType)type {
    switch (type) {
        case VLPrivacyClickTypeAgree:
            self.agreeButton.selected = NO;
            _policyAgreed = NO;
            [self closePrivaxyAlertView];
            break;
        case VLPrivacyClickTypeDisagree:
            self.agreeButton.selected = NO;
            if(self.privacyCustomView.pass == 0) {
                self.privacyCustomView = nil;
                [self alertPrivacyAlertView:1];
            }
            else if(self.privacyCustomView.pass != 0) {
                exit(0);
            }
            break;
        case VLPrivacyClickTypePrivacy:
            [self pushToWebView:kURLPathH5Privacy];
            [self closePrivaxyAlertView];
            break;
        case VLPrivacyClickTypeUserAgreement:
            [self pushToWebView:kURLPathH5UserAgreement];
            [self closePrivaxyAlertView];
            break;
        default:
            break;
    }
}

- (void)closePrivaxyAlertView {
    [LEEAlert closeWithCompletionBlock:^{
    }];
}

#pragma mark - VLLoginInputVerifyCodeViewDelegate

- (void)verifyCodeViewDidClickSendVerifyCode:(UIButton *)sender{
    if (![self checkPhoneNo]) return;

    NSDictionary *param = @{
        @"phone":self.phoneView.phoneNo
    };
    //TODO: 实现网络请求
    /*
    [VLAPIRequest getRequestURL:kURLPathVerifyCode parameter:param showHUD:YES success:^(VLResponseDataModel * _Nonnull response) {
        if (response.code == 0) {
            [self.verifyView startTime:sender];
        } else {
            [VLToast toast:response.message];
        }
    } failure:^(NSError * _Nullable error, NSURLSessionDataTask * _Nullable task) {
    }];
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL success = YES;
        if (success) {
            [self.verifyView startTime:sender];
        } else {
            [VLToast toast:@"获取验证码失败"];
        }
    });
}

#pragma mark - Action

- (void)loginClick:(UIButton *)button {
    if (![self checkPhoneNo]) return;
    if (![self checkPrivacyAgree]) return;
    if (![self checkVerifyCode]) return;
    
    [self popImageVerifyView];
}

-(BOOL)checkVerifyCode {
    
    if (_verifyView.isVerifyCodeSent == NO || [_verifyView.verifyCode isEqualToString:@""] || !_verifyView.verifyCode) {
        [VLToast toast:MCLocalizedString(@"请输入验证码")];
        return NO;
    }
    return YES;
}

-(BOOL)checkPrivacyAgree {
    if (!self.agreeButton.selected) {
        [VLToast toast:MCLocalizedString(@"请您认真阅读用户协议及隐私政策的条款内容，同意后可开始使用我们的服务")];
        return NO;
    }
    return YES;
}

-(BOOL)checkPhoneNo {
    if ([_phoneView.phoneNo isEqualToString:@""] || !_phoneView.phoneNo) {
        [VLToast toast:MCLocalizedString(@"请输入手机号")];
        return NO;
    }
    
    if (![NSString isValidateTelNumber:_phoneView.phoneNo]) {
        [VLToast toast:MCLocalizedString(@"手机号码格式错误")];
        return NO;
    }
    
    return YES;
}

- (void)agreeButtonAction {
    self.agreeButton.selected = !self.agreeButton.selected;
}

- (void)navigatorToWebviewOfUserProtocol{
    [self pushToWebView:kURLPathH5UserAgreement];
}

- (void)navigatorToWebviewOfPrivacyProtocol{
    [self pushToWebView:kURLPathH5Privacy];
}

- (void)pushToWebView:(NSString *)url {
//    VLCommonWebViewController *webVC = [[VLCommonWebViewController alloc] init];
//    webVC.urlString = url;
//    if (!self.navigationController) {
//        [self presentViewController:webVC animated:YES completion:nil];
//    } else {
//        [self.navigationController pushViewController:webVC animated:YES];
//    }
}

- (void)popImageVerifyView {
    
    VLPopImageVerifyView *imageVerifyView = [[VLPopImageVerifyView alloc]initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH-80, 198+(SCREEN_WIDTH-120)*0.65) withDelegate:self];
    
    LSTPopView *popView = [LSTPopView initWithCustomView:imageVerifyView parentView:self.view popStyle:LSTPopStyleFade dismissStyle:LSTDismissStyleFade];
    popView.hemStyle = LSTHemStyleCenter;
    popView.popDuration = 0.5;
    popView.dismissDuration = 0.5;
    popView.cornerRadius = 16;
    self.popView = popView;
    popView.isClickFeedback = NO;
    [popView pop];
}

#pragma mark --delegate
- (void)closeBtnAction {
    [self.popView dismiss];
}

- (void)slideSuccessAction {
    [self.popView dismiss];
    
    NSDictionary *param = @{
        @"phone" : self.phoneView.phoneNo,
        @"code": self.verifyView.verifyCode
    };
    //TODO: 实现网络请求
    /*
    [VLAPIRequest getRequestURL:kURLPathLogin parameter:param showHUD:YES success:^(VLResponseDataModel * _Nonnull response) {
        if (response.code == 0) {
            VLLoginModel *model = [VLLoginModel vj_modelWithDictionary:response.data];
            [[VLUserCenter center] storeUserInfo:model];
            [UIApplication.sharedApplication.delegate.window configRootViewController];
        }
        else {
            dispatch_main_async_safe(^{
                [VLToast toast:AGLocalizedString(@"验证码校验失败，请重试")];
            })
        }
    } failure:^(NSError * _Nullable error, NSURLSessionDataTask * _Nullable task) {
        dispatch_main_async_safe(^{
            [VLToast toast:AGLocalizedString(@"验证码校验失败，请重试")];
        })
    }];
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.loginSuccessCallback) {
            self.loginSuccessCallback();
            AppContext.currentUserId = self.phoneView.phoneNo;
        }
    });
}

#pragma mark - Lazy

- (UILabel *)appNameLabel {
    if (!_appNameLabel) {
        _appNameLabel = [[UILabel alloc] init];
        _appNameLabel.font = [UIFont systemFontOfSize:26];
        _appNameLabel.textColor = [[UIColor alloc] initWithHexString:@"#040925"];
        _appNameLabel.text = MCLocalizedString(@"欢迎体验声网服务");
    }
    return _appNameLabel;
}

- (VLLoginInputPhoneView *)phoneView {
    if (!_phoneView) {
        _phoneView = [[VLLoginInputPhoneView alloc] init];
    }
    return _phoneView;
}

- (VLLoginInputVerifyCodeView *)verifyView {
    if (!_verifyView) {
        _verifyView = [[VLLoginInputVerifyCodeView alloc] init];
        _verifyView.delegate = self;
    }
    return _verifyView;
}

- (UIImageView *)backGroundImgView {
    if (!_backGroundImgView) {
        _backGroundImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backGroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backGroundImgView;
}

- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeButton setImage:[UIImage imageNamed:@"online_create_screatNormalIcon"] forState:UIControlStateNormal];
        [_agreeButton setImage:[UIImage imageNamed:@"online_create_screatSelIcon"] forState:UIControlStateSelected];
        [_agreeButton addTarget:self action:@selector(agreeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeButton;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if([URL isEqual:[NSURL URLWithString:@"0"]]){
        [self navigatorToWebviewOfUserProtocol];
    } else {
        [self navigatorToWebviewOfPrivacyProtocol];
    }
    return YES;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:MCLocalizedString(@"登录") forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
        [_loginButton setBackgroundColor:[[UIColor alloc] initWithHexString:@"#345DFF"]];
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(30,445,315,48);
        gl.startPoint = CGPointMake(0.43, 0.01);
        gl.endPoint = CGPointMake(0.43, 1);
        gl.colors = @[(__bridge id)[UIColor colorWithRed:33/255.0 green:155/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:52/255.0 green:93/255.0 blue:255/255.0 alpha:1.0].CGColor];
        gl.locations = @[@(0), @(1.0f)];
        _loginButton.layer.cornerRadius = 24;
        _loginButton.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:139/255.0 blue:250/255.0 alpha:0.2000].CGColor;
        _loginButton.layer.shadowOffset = CGSizeMake(0,4);
        _loginButton.layer.shadowOpacity = 1;
        _loginButton.layer.shadowRadius = 8;
    }
    return _loginButton;
}

- (VLPrivacyCustomView *)getPrivacyCustomView:(int)pass {
    if (!_privacyCustomView) {
        _privacyCustomView = [[VLPrivacyCustomView alloc] initWithPass:pass];
        if(pass == 0) {
            _privacyCustomView.frame = CGRectMake(0, 0, 250, 260);
        }
        else {
            _privacyCustomView.frame = CGRectMake(0, 0, 250, 100);
        }
        _privacyCustomView.backgroundColor = [UIColor whiteColor];
        _privacyCustomView.delegate = self;
    }
    return _privacyCustomView;
}



@end
