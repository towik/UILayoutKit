//
//  FormularViewController.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FormularViewController.h"
#import "UILayoutKit.h"

@implementation FormularViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ULKScrollView *scrollView = [[ULKScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    
    ULKLinearLayout *linearLayout = [ULKLinearLayout new]; //[[ULKLinearLayout alloc] initWithFrame:self.view.bounds];
    linearLayout.orientation = LinearLayoutOrientationVertical;
//    linearLayout.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [scrollView addSubview:linearLayout];

    ULKLinearLayout *linearLayout1 = [ULKLinearLayout new];
    linearLayout1.ulk_layoutGravity = ULKGravityRight | ULKGravityTop;
    linearLayout1.orientation = LinearLayoutOrientationVertical;
    linearLayout1.ulk_layoutHeight = 0;
    linearLayout1.ulk_layoutWeight = 1;
    [linearLayout addSubview:linearLayout1];
    UILabel *label11 = [UILabel new];
    label11.text = @"测试11";
    [linearLayout1 addSubview:label11];
    UILabel *label12 = [UILabel new];
    label12.text = @"测试12";
    label12.ulk_layoutMargin = UIEdgeInsetsMake(20, 10, 30, 10);
    [linearLayout1 addSubview:label12];
    UILabel *label13 = [UILabel new];
    label13.text = @"测试13";
    [linearLayout1 addSubview:label13];
    
    ULKLinearLayout *linearLayout2 = [ULKLinearLayout new];
    linearLayout2.orientation = LinearLayoutOrientationHorizontal;
    linearLayout2.ulk_layoutHeight = 0;
    linearLayout2.ulk_layoutWeight = 1;
    [linearLayout addSubview:linearLayout2];
    UILabel *label21 = [UILabel new];
    label21.text = @"测试21";
    label21.ulk_layoutMargin = UIEdgeInsetsMake(20, 0, 0, 0);
    [linearLayout2 addSubview:label21];
    UILabel *label22 = [UILabel new];
    label22.text = @"测试22";
    label22.ulk_layoutMargin = UIEdgeInsetsMake(20, 10, 30, 20);
    [linearLayout2 addSubview:label22];
    UIButton *label23 = [UIButton new];
    label23.titleLabel.numberOfLines = 0;
//    [label23 setTitle:@"测试说的方法是发发撒发撒发发沙发舒服撒发生发放撒" forState:UIControlStateNormal];
    [label23 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    label23.ulk_layoutWidth = 150;
//    label23.ulk_layoutHeight = 150;
//    label23.contentEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
//    label23.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    label23.backgroundColor = [UIColor blackColor];
    [label23 setImage:[UIImage imageNamed:@"icon_customer_avatar"] forState:UIControlStateNormal];
    [linearLayout2 addSubview:label23];

    ULKFrameLayout *frameLayout = [ULKFrameLayout new];
    frameLayout.ulk_layoutHeight = 0;
    frameLayout.ulk_layoutWeight = 1;
    [linearLayout addSubview:frameLayout];
    UILabel *label31 = [UILabel new];
    label31.text = @"测试31";
    label31.ulk_layoutMargin = UIEdgeInsetsMake(20, 10, 0, 0);
    [frameLayout addSubview:label31];
    UILabel *label32 = [UILabel new];
    label32.text = @"测试32";
    label32.ulk_layoutGravity = ULKGravityRight | ULKGravityTop;
    label32.ulk_layoutMargin = UIEdgeInsetsMake(20, 0, 0, 20);
    [frameLayout addSubview:label32];
    UILabel *label33 = [UILabel new];
    label33.text = @"测试33";
    label33.ulk_layoutGravity = ULKGravityLeft | ULKGravityBottom;
    label33.ulk_layoutMargin = UIEdgeInsetsMake(0, 10, 10, 0);
    [frameLayout addSubview:label33];
    UILabel *label34 = [UILabel new];
    label34.text = @"测试34";
    label34.ulk_layoutGravity = ULKGravityRight | ULKGravityBottom;
    label34.ulk_layoutMargin = UIEdgeInsetsMake(0, 0, 10, 20);
    [frameLayout addSubview:label34];
    UIImageView *label35 = [UIImageView new];
    label35.image = [UIImage imageNamed:@"icon_customer_avatar"];
    label35.ulk_layoutGravity = ULKGravityCenter;
    [frameLayout addSubview:label35];
    
//    [self updateAndroidStatus];
}

- (void)didPressSubmitButton {
    UIButton *submitButton = (UIButton *)[self.view ulk_findViewById:@"submitButton"];
    submitButton.selected = TRUE;
    UILabel *username = (UILabel *)[self.view ulk_findViewById:@"username"];
    UILabel *password = (UILabel *)[self.view ulk_findViewById:@"password"];
    UITextView *freeText = (UITextView *)[self.view ulk_findViewById:@"freeText"];
    [username resignFirstResponder];
    [password resignFirstResponder];
    [freeText resignFirstResponder];
    NSString *message = [NSString stringWithFormat:@"Username: %@\nPassword: %@\nText: %@", username.text, password.text, freeText.text];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)didPressToggleButton {
    UIView *androidView = [self.view ulk_findViewById:@"android"];
    if (androidView.ulk_visibility == ULKViewVisibilityVisible) {
        ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)androidView.ulk_layoutParams;
        if (lp.gravity == ULKGravityLeft) {
            lp.gravity = ULKGravityCenterHorizontal;
        } else if (lp.gravity == ULKGravityCenterHorizontal) {
            lp.gravity = ULKGravityRight;
        } else {
            lp.gravity = ULKGravityLeft;
            androidView.ulk_visibility = ULKViewVisibilityInvisible;
        }
        androidView.ulk_layoutParams = lp;
    } else if (androidView.ulk_visibility == ULKViewVisibilityInvisible) {
        androidView.ulk_visibility = ULKViewVisibilityGone;
    } else {
        androidView.ulk_visibility = ULKViewVisibilityVisible;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    [self updateAndroidStatus];
}

- (void)updateAndroidStatus {
    UILabel *label = (UILabel *)[self.view ulk_findViewById:@"androidStatus"];
    UIView *androidView = [self.view ulk_findViewById:@"android"];
    NSString *ulk_visibility;
    switch (androidView.ulk_visibility) {
        case ULKViewVisibilityVisible:
            ulk_visibility = @"visible";
            break;
        case ULKViewVisibilityInvisible:
            ulk_visibility = @"invisible";
            break;
        case ULKViewVisibilityGone:
            ulk_visibility = @"gone";
            break;
    }
    NSString *gravity = @"";
    ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)androidView.ulk_layoutParams;
    switch (lp.gravity) {
        case ULKGravityLeft:
            gravity = @"left";
            break;
        case ULKGravityCenterHorizontal:
            gravity = @"center_horizontal";
            break;
        case ULKGravityRight:
            gravity = @"right";
            break;
        default:
            gravity = @"unknown";
            break;
    }
    
    label.text = [NSString stringWithFormat:@"andrdoid[ulk_visibility=%@,layout_gravity=%@]", ulk_visibility, gravity];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return TRUE;
}

@end
