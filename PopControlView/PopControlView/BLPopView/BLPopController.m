//
//  BLPopControlView.m
//  ihc
//
//  Created by apple on 2017/4/5.
//  Copyright © 2017年 broadlink. All rights reserved.
//

#import "BLPopController.h"
#import "PresentationTransition.h"
#import "BLPopControlViewButton.h"

#define kRadius [[UIScreen mainScreen]bounds].size.width*120.0f/320.0f
#define BL_ADDCOLUMNVIEW_LABEL_HEIGHT  20


@interface BLPopAction()
@property (nullable, nonatomic, readwrite) NSString *title;
@property (nullable, nonatomic, readwrite) NSString *imgName;
@property (nonatomic, copy) void (^event)(BLPopAction *action);
@end

@implementation BLPopAction

+ (instancetype)actionWithTitle:(nullable NSString *)title withImageName:(NSString *)imgName handler:(void (^__nullable)(BLPopAction *action))handler
{
    BLPopAction *action = [[BLPopAction alloc]init];
    action.title = title;
    action.imgName = imgName;
    action.event = handler;
    return action;
}

@end


@interface BLPopController ()
@property (nonatomic, readwrite) NSMutableArray<BLPopAction *> *actions;
@property (nonatomic, strong) NSMutableArray *btnArr;
@property (nonatomic, strong) NSMutableArray *lineImgVArray;
@property (nonatomic, strong) PresentationTransition *transition;
@property (nonatomic, strong) UIImageView *centerImageView;
@end

@implementation BLPopController

+ (instancetype)popControllerWithCenterImage:(UIImage *)centerImg originFrame:(CGRect)originFrame
{
    BLPopController *vc = [[BLPopController alloc]init];
    vc.centerImageView = [[UIImageView alloc]init];
    vc.centerImageView.image = centerImg;
    vc.centerImageView.frame = CGRectMake(0, 0, 150, 150);
    vc.centerImageView.center = vc.view.center;
    [vc.view addSubview:vc.centerImageView];
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transition=[[PresentationTransition alloc]initOriginFrame:originFrame];
    vc.transitioningDelegate = vc.transition;

    return vc;
}

- (void)addAction:(BLPopAction *)action
{
    if(_actions == nil){
        _actions = [[NSMutableArray alloc]init];
    }
    [_actions addObject:action];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated]; 
    [self showSubButton];
}

- (void)showSubButton
{
    if (!_btnArr) {
        _btnArr = [NSMutableArray arrayWithCapacity:0];
    } else {
        [_btnArr removeAllObjects];
    }
    if (!self.lineImgVArray) {
        self.lineImgVArray = [NSMutableArray arrayWithCapacity:0];
    } else {
        [self.lineImgVArray removeAllObjects];
    }
    
    for (int i = 0; i < self.actions.count; i++) {
        UIButton *button = [self buttonWithTitle:self.actions[i].title index:i image:[UIImage imageNamed:self.actions[i].imgName]];
        [_btnArr addObject:button];
        [self.view addSubview:button];
    }
    UIImage *buttonImage = [UIImage imageNamed:@"imgc"];
//    NSString *buttonTitle = BLLocalizedString(@"str_scene_batch_switch_more", nil);
    UIButton *moreBtn = [self buttonWithTitle:@"more" index:self.actions.count image:buttonImage];;
    [_btnArr addObject:moreBtn];
    [moreBtn setCenter:self.view.center];
    [moreBtn setBounds:CGRectMake(0, 0, (buttonImage.size.width + 20.0f) * 0.5f +20.0f, (buttonImage.size.height + 20.0f) * 0.5f + BL_ADDCOLUMNVIEW_LABEL_HEIGHT + 20.0f)];
    [moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    moreBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:moreBtn];
    
    int angle = 360/self.btnArr.count;
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    float radian = angle*M_PI/180.0;

    [UIView animateWithDuration:0.3f animations:^{
        for (int i = 0; i < self.btnArr.count; i++) {
            UIButton *button = self.btnArr[i];
            float x = centerX + kRadius*sinf(radian * (i + 1));
            float y = centerY + kRadius*cosf(radian * (i + 1));
            button.center = CGPointMake(x, y);
            button.alpha = 1.0f;
            [self.lineImgVArray addObject:[self drawLineFromAngle:angle andCenterX:centerX andCenterY:centerY andRadian:radian andIndex:i andInView:self.view]];
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

- (UIButton *)buttonWithTitle:(NSString *)title index:(NSInteger)index image:(UIImage *)image
{
    UIButton *button = [BLPopControlViewButton buttonWithType:UIButtonTypeCustom];
    button.tag = index;
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    const CGFloat width = 51 + 20.0f;
    const CGFloat height = 51 + 20 + 20.0f;
    [button setBounds:CGRectMake(0, 0, width, height)];
    button.center = self.view.center;
    [button setImage:image forState:UIControlStateNormal];

    return button;
}

- (void)btnClick:(UIButton *)btn
{
    if(btn.tag != self.actions.count){
        _actions[btn.tag].event(_actions[btn.tag]);
    }
    else{
    
    }
}

- (UIImageView *)drawLineFromAngle:(int)angle andCenterX:(float)centerX andCenterY:(float)centerY andRadian:(float)radian andIndex:(int)idx andInView:(UIView *)view
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.frame];
    [view addSubview:imageView];
    
    CGPoint start;
    CGPoint end;
    float tmpAngle = angle * (idx+1);
    float tmpX = kRadius * sinf(radian * (idx + 1));
    float tmpY = kRadius * cosf(radian * (idx + 1));
    if (tmpAngle > 0 && tmpAngle < 90.0f) {
        start = CGPointMake(centerX + tmpX / 2 + 3.0f, centerY + tmpY / 2 + 3.0f);
        end   = CGPointMake(centerX + tmpX / 2 + 12.0f, centerY + tmpY / 2 + 12.0f);
    } else if (tmpAngle > 90.0f && tmpAngle < 180.0f) {
        start = CGPointMake(centerX + tmpX / 2 + 3.0f, centerY + tmpY / 2 - 3.0f);
        end   = CGPointMake(centerX + tmpX / 2 + 12.0f, centerY + tmpY / 2 - 12.0f);
    } else if (tmpAngle > 180.0f && tmpAngle < 270.0f) {
        start = CGPointMake(centerX + tmpX / 2 - 3.0f, centerY + tmpY / 2 - 3.0f);
        end   = CGPointMake(centerX + tmpX / 2 - 12.0f, centerY + tmpY / 2 - 12.0f);
    } else if ((tmpAngle > 270.0f && tmpAngle < 360.0f)) {
        start = CGPointMake(centerX + tmpX / 2 - 3.0f, centerY + tmpY / 2 + 3.0f);
        end   = CGPointMake(centerX + tmpX / 2 - 12.0f, centerY + tmpY / 2 + 12.0f);
    } else if (tmpAngle == 360.0f || tmpAngle == 0.0f) {
        start = CGPointMake(centerX, centerY + tmpY / 2 + 3.0f);
        end   = CGPointMake(centerX, centerY + tmpY / 2 + 18.0f);
    } else if (tmpAngle == 180.0f) {
        start = CGPointMake(centerX, centerY + tmpY / 2 - 3.0f);
        end   = CGPointMake(centerX, centerY + tmpY / 2 - 18.0f);
    } else if (tmpAngle == 90.0f) {
        start = CGPointMake(centerX + tmpX / 2 + 3.0f, centerY);
        end   = CGPointMake(centerX + tmpX / 2 + 18.0f, centerY);
    } else if (tmpAngle == 270.0f) {
        start = CGPointMake(centerX + tmpX / 2 - 3.0f, centerY);
        end   = CGPointMake(centerX + tmpX / 2 - 18.0f, centerY);
    }
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    [imageView setBackgroundColor:[UIColor clearColor]];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapSquare);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 0.3);
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 255, 255, 255, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x, start.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageView;
}

-(void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewDismiss" object:self];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissView];
}

@end
