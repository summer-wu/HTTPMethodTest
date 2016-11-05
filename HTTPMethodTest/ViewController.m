//
//  ViewController.m
//  HTTPMethodTest
//
//  Created by n on 16/11/5.
//  Copyright © 2016年 summerwu. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIView+APUtils.h"

#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar0;
@property (weak, nonatomic) IBOutlet UITextView *tv0;
@property (weak, nonatomic) IBOutlet UITextField *tf0;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolbar0.top = 20;
    [self.toolbar0 sizeToFit];
    self.toolbar0.centerX = self.view.width*0.5;

    self.tf0.text = @"http://onetake.dafork.com/api/v2/users/flypig/photos";
    self.tf0.top = self.toolbar0.bottom;
    self.tf0.height = 44;
    self.tf0.left = 0;
    self.tf0.width = self.view.width;


    self.tv0.top = self.tf0.bottom;
    self.tv0.left = 0;
    self.tv0.layer.borderWidth = 1;
    self.tv0.width = self.view.width;
    self.tv0.height = self.view.height - self.tf0.bottom;

    [self createManager];
}

- (NSString *)url{
    return self.tf0.text;
}


- (void)createManager{
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];
    NSMutableIndexSet *acceptableCodes = [self.manager.responseSerializer.acceptableStatusCodes mutableCopy];
    [acceptableCodes addIndex:404];
    self.manager.responseSerializer.acceptableStatusCodes = acceptableCodes;
}

- (void)changeTv0Requesting{
    self.tv0.text = @"请求中...";
}

- (IBAction)get:(id)sender {
    [self changeTv0Requesting];
    [self.manager GET:self.url parameters:nil success:^(AFHTTPRequestOperation *operation, NSData * responseObject) {
        NSString *s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        self.tv0.text = [NSString stringWithFormat:@"HTTP GET %@ 返回:\n %@",self.url,s];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.tv0.text = [NSString stringWithFormat:@"HTTP GET %@ 请求失败\n error:\n %@",self.url,error];
    }];
}


- (IBAction)post:(id)sender {
    [self changeTv0Requesting];
    [self.manager POST:self.url parameters:nil success:^(AFHTTPRequestOperation *operation, NSData * responseObject) {
        NSString *s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        self.tv0.text = [NSString stringWithFormat:@"HTTP POST %@ 返回:\n %@",self.url,s];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.tv0.text = [NSString stringWithFormat:@"HTTP POST %@ 请求失败\n error:\n %@",self.url,error];
    }];
}

- (IBAction)delete:(id)sender {
    [self changeTv0Requesting];
    [self.manager DELETE:self.url parameters:nil success:^(AFHTTPRequestOperation *operation, NSData * responseObject) {
        NSString *s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        self.tv0.text = [NSString stringWithFormat:@"HTTP DELETE %@ 返回:\n %@",self.url,s];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.tv0.text = [NSString stringWithFormat:@"HTTP DELETE %@ 请求失败\n error:\n %@",self.url,error];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
