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
    [self updateAndroidStatus];
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
        ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)androidView.layoutParams;
        if (lp.gravity == ULKViewContentGravityLeft) {
            lp.gravity = ULKViewContentGravityCenterHorizontal;
        } else if (lp.gravity == ULKViewContentGravityCenterHorizontal) {
            lp.gravity = ULKViewContentGravityRight;
        } else {
            lp.gravity = ULKViewContentGravityLeft;
            androidView.ulk_visibility = ULKViewVisibilityInvisible;
        }
        androidView.layoutParams = lp;
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
    ULKLinearLayoutParams *lp = (ULKLinearLayoutParams *)androidView.layoutParams;
    switch (lp.gravity) {
        case ULKViewContentGravityLeft:
            gravity = @"left";
            break;
        case ULKViewContentGravityCenterHorizontal:
            gravity = @"center_horizontal";
            break;
        case ULKViewContentGravityRight:
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
