//
//  ViewController.m
//  Screenshot
//
//  Created by xiaofei on 2017/5/18.
//  Copyright © 2017年 xiaofei. All rights reserved.
//

#import "ViewController.h"

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong)UIView *screenshotView;
@property (nonatomic, strong)UIImageView *showImgView1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 40, 100, 100)];
    imgView.backgroundColor = [UIColor lightGrayColor];
    self.showImgView1 = imgView;
    [self.view addSubview:imgView];
    
    self.screenshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.screenshotView.backgroundColor = [UIColor cyanColor];
    self.screenshotView.center = self.view.center;
    [self.view addSubview:self.screenshotView];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, kScreenHeight - 80, 100, 40);
    btn1.backgroundColor = [UIColor brownColor];
    btn1.tag = 101;
    [btn1 setTitle:@"部分屏" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(150,kScreenHeight - 80, 100, 40);
    btn2.backgroundColor = [UIColor brownColor];
    btn2.tag = 102;
    [btn2 setTitle:@"全屏" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

- (void)btnClick:(UIButton *)sender {
    UIImage *img = nil;
    if (sender.tag == 101) {
        img = [self snapshot:self.screenshotView];
    }else {
        img = [self captureScreenshot];
        NSLog(@"%@", NSStringFromCGSize(img.size));
    }
    // self.showImgView1.image = img;
    self.showImgView1.image = [self scaleImg:img ToSize:self.showImgView1.frame.size];
}

//等比例缩放
-(UIImage*)scaleImg:(UIImage *)img ToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(img.CGImage);
    CGFloat height = CGImageGetHeight(img.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

//
/**
 * 截部分屏
 * view 要截取的部分
 */
- (UIImage *)snapshot:(UIView *)view {
    
    // 第二个参数 设置为YES后,这些方法会等在view update结束在执行,如果在update结束前view被release了,会出现找不到view的问题.所以需要设置为NO.
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    
    if (CGRectIsEmpty(view.frame)) {
        return nil;
    }
    
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    }else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/** 截全屏 */
- (UIImage *)captureScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    // IOS7及其后续版本
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [self methodSignatureForSelector:
                                     @selector(drawViewHierarchyInRect:afterScreenUpdates:)]];
//        [invocation setTarget:self];
        invocation.target = self;
        [invocation setSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)];
        CGRect arg2 = self.view.bounds;
        BOOL arg3 = YES;
        [invocation setArgument:&arg2 atIndex:2];
        [invocation setArgument:&arg3 atIndex:3];
        [invocation invoke];
    } else { // IOS7之前的版本
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
