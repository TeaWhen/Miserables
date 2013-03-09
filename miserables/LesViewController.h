//
//  LesViewController.h
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LesViewController : UIViewController {
    IBOutlet UISearchBar *searchBar;
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UIWebView *webView;
    IBOutlet UITapGestureRecognizer *tapNavigation;
    
    NSMutableArray *wikiIndex;
}

- (void) doneSearchingClicked:(id)sender;

@end
