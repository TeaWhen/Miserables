//
//  LesDetailViewController.h
//  miserables
//
//  Created by Yan Zheng on 13-3-2.
//  Copyright (c) 2013年 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LesDetailViewController : UIViewController <UISplitViewControllerDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UITextField *addressBar;
    UIActivityIndicatorView *activityIndicatorView;
}
- (IBAction)goURL:(id)sender;

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
