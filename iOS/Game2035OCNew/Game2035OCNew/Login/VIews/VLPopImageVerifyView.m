//
//  VLPopImageVerifyView.m
//  VoiceOnLine
//

#import "VLPopImageVerifyView.h"
#import "WMZCodeView.h"
#import "Game2035OCNew-swift.h"
#import "VLHotSpotBtn.h"

@import YYCategories;

@interface VLPopImageVerifyView ()

@property(nonatomic, weak) id <VLPopImageVerifyViewDelegate>delegate;
@property(nonatomic,strong)WMZCodeView *codeView;
@property(nonatomic, assign) int verifyFailTimes;
@end

@implementation VLPopImageVerifyView

- (instancetype)initWithFrame:(CGRect)frame withDelegate:(id<VLPopImageVerifyViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = delegate;
        [self setupView];
        _verifyFailTimes = 0;
    }
    return self;
}

- (void)setupView {
    @weakify(self)
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 16;
    bgView.layer.masksToBounds = YES;
    [self addSubview:bgView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 22, 80, 20)];
    titleLabel.text = MCLocalizedString(@"完成验证");
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [[UIColor alloc] initWithHexString:@"#6C7192"];
    [self addSubview:titleLabel];
    
    VLHotSpotBtn *closeBtn = [[VLHotSpotBtn alloc]initWithFrame:CGRectMake(self.width-24-15, titleLabel.centerY-12, 24, 24)];
    [closeBtn setImage: [UIImage imageNamed:@"login_pop_closeIcon"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClickEvent) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
    UILabel *slideLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, titleLabel.bottom+5, 170, 22)];
    slideLabel.text = MCLocalizedString(@"拖动下方滑块完成拼图");
    slideLabel.font = [UIFont systemFontOfSize:16];
    slideLabel.textColor = [[UIColor alloc] initWithHexString:@"#040925"];
    [self addSubview:slideLabel];
    
    //使用方法
    self.codeView = [[WMZCodeView sharedInstance] addCodeViewWithFrame:CGRectMake(10, slideLabel.bottom+15, self.width-20, (self.width-20)*0.64+63)  withBlock:^(BOOL success) {
        @strongify(self)
        if (success) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(slideSuccessAction)]) {
                [self.delegate slideSuccessAction];
            }
        }
        else {
            self.verifyFailTimes += 1;
            if(self.verifyFailTimes >= 3) {
                self.verifyFailTimes = 0;
                [self changeImage];
            }
        }
    }];
    
    [self addSubview:self.codeView];
    
}

- (void)changeImage
{
    [self.codeView refreshAction];
}

- (void)closeBtnClickEvent{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeBtnAction)]) {
        [self.delegate closeBtnAction];
    }
}

@end
