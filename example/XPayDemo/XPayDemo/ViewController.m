//
//  ViewController.m
//  XPayDemo
//
//  Created by Casum Leung on 2017/3/24.
//  Copyright © 2017年 Zhimou. All rights reserved.
//

#import "ViewController.h"
#import "XpassSDK.h"
#import "XP_QRCodeTool.h"

#define kWaiting          @"正在获取支付凭据,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"

#define kPlaceHolder      @"支付金额"
#define kMaxAmount        9999999

#define kUrlScheme      @"com.zhimou.XPayDemo" // 这个是你定义的 URL Scheme，支付宝、微信支付、银联和测试模式需要。
#define kUrl            @"https://wx.bilifoo.com/demo/api/order_sign" // 你的服务端创建并返回 charge 的 URL 地址，此地址仅供测试用。

@interface ViewController (){
    UIAlertView *mAlert;
}
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *goodsNameTextField;
@property (nonatomic, copy) NSString *channel;
@property (weak, nonatomic) IBOutlet UIView *qrcodeView;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;

- (IBAction)click_done:(id)sender;
- (IBAction)click_item:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"XPay Demo";
    [XpassSDK setDebugMode:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)click_done:(id)sender {
    [self.textField resignFirstResponder];
    [self.goodsNameTextField resignFirstResponder];
}

- (IBAction)click_item:(id)sender {
    if(self.goodsNameTextField.text.length == 0){
        [self showAlertMessage:@"商品名称不能为空"];
        return;
    }
    [self normalPayAction:sender];
}

- (IBAction)click_qrcodeView:(id)sender {
    self.qrcodeView.hidden = YES;
}

- (void)normalPayAction:(id)sender
{
    NSInteger tag = ((UIButton*)sender).tag;
    if (tag == 1) {
        self.channel = @"wx";
        [self normalPayAction:nil];
    } else if (tag == 2) {
        self.channel = @"alipay";
    } else if (tag == 3){
        self.channel = @"dian_zhi_wx_scan";
    } else if(tag == 4){
        self.channel = @"dian_zhi_quick";
    } else if(tag == 5){
        self.channel = @"wap_zhimou";
    } else {
        return;
    }
    
    [self.textField resignFirstResponder];
    long long amount = [[self.textField.text stringByReplacingOccurrencesOfString:@"." withString:@""] longLongValue];
    if (amount == 0) {
        return;
    }
    NSString *amountStr = [NSString stringWithFormat:@"%lld", amount];
    NSURL* url = [NSURL URLWithString:kUrl];
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:url];
    
    NSDictionary* dict = @{
                           @"channel" : self.channel,
                           @"total_fee"  : amountStr,
                           @"goods_name":self.textField.text
                           };
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    ViewController * __weak weakSelf = self;
    [self showAlertWait];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:postRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            [weakSelf hideAlert];
            if (httpResponse.statusCode != 200) {
                NSLog(@"statusCode=%ld error = %@", (long)httpResponse.statusCode, error);
                [weakSelf showAlertMessage:kErrorNet];
                return;
            }
            if (error != nil) {
                NSLog(@"error = %@", error);
                [weakSelf showAlertMessage:kErrorNet];
                return;
            }
            NSString* charge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"charge = %@", charge);
            NSDictionary *charge_dic = [self dictionaryWithJsonString:charge];
            [XpassSDK createPassment:charge_dic viewController:weakSelf appURLScheme:kUrlScheme withCompletion:^(NSString *result, XPassError *error) {
                NSLog(@"completion block: %@", result);
                if (error == nil) {
                    NSLog(@"Error is nil");
                } else {
                    NSLog(@"Error: code=%lu msg=%@", (unsigned  long)error.code, [error getMsg]);
                }
                if ([charge_dic[@"channel"] isEqualToString:@"dian_zhi_wx_scan"]) {
                    [weakSelf hideAlert];
                    weakSelf.qrcodeView.hidden = NO;
                    weakSelf.qrcodeImageView.image = [XP_QRCodeTool XP_generateWithDefaultQRCodeData:result imageViewWidth:240];
                }else{
                    [weakSelf showAlertMessage:result];
                }
            }];
        });
    }];
    [task resume];
}

#pragma mark private
- (void)showAlertWait
{
    mAlert = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(mAlert.frame.size.width / 2.0f - 15, mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [mAlert addSubview:aiv];
}

- (void)showAlertMessage:(NSString*)msg
{
    mAlert = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:nil cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [mAlert show];
}

- (void)hideAlert
{
    if (mAlert != nil)
    {
        [mAlert dismissWithClickedButtonIndex:0 animated:YES];
        mAlert = nil;
    }
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
