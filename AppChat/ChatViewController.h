//
//  ChatViewController.h
//  AppChat
//
//  Created by ravimalviya on 3/5/17.
//  Copyright © 2017 ravimalviya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    
    __weak IBOutlet NSLayoutConstraint *bottomLayoutConstrain;
    __weak IBOutlet UIView *sendButtonView;
    __weak IBOutlet UITextView *messageTextView;
    
    NSMutableArray *tableData;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
