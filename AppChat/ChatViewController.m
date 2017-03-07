//
//  ChatViewController.m
//  AppChat
//
//  Created by ravimalviya on 3/5/17.
//  Copyright © 2017 ravimalviya. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageCell.h"

@interface ChatViewController (){
    CGRect keyboardFrameBeginRect;
    BOOL isMessageTFPresented;
    CGPoint lastContentOffset;
    BOOL isViewDidAppear;
    NSMutableDictionary *cellHeightsDictionary;
}

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isViewDidAppear = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    cellHeightsDictionary = [NSMutableDictionary new];
    tableData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Messages"] mutableCopy];
    if (!tableData) {
        tableData = [NSMutableArray new];
    }
    //    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 5.0, 0);
    //    _tableView.estimatedRowHeight = 44.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    isViewDidAppear = true;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if (isViewDidAppear == false) {
        [self tableScrollDown:false];
    }
//    else{
//        [self updateContentInsetForTableView:self.tableView animated:NO];
//    }
}

-(void)dealloc{
    
    [[NSUserDefaults standardUserDefaults] setObject:tableData forKey:@"Messages"];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{                                               // any offset changes
    //    NSLog(@"scrollViewDidScroll");
    if (scrollView == _tableView) {
        lastContentOffset = _tableView.contentOffset;
    }
    if (isMessageTFPresented && scrollView == _tableView) {
        
        switch (scrollView.panGestureRecognizer.state) {
                
            case UIGestureRecognizerStateBegan:
                NSLog(@"UIGestureRecognizerStateBegan");
                // User began dragging
                break;
                
            case UIGestureRecognizerStateChanged:{
                NSLog(@"UIGestureRecognizerStateChanged");
                CGPoint touchPoint = [scrollView.panGestureRecognizer locationInView:self.view];
                CGRect rect = sendButtonView.frame;
                if (CGRectContainsPoint(rect, touchPoint) ) {
                    if (messageTextView!=nil && messageTextView.isFirstResponder){
                        [messageTextView resignFirstResponder];
                    }
                }
                // User is currently dragging the scroll view
            }break;
                
            case UIGestureRecognizerStatePossible:
                //                NSLog(@"UIGestureRecognizerStatePossible");
                // The scroll view scrolling but the user is no longer touching the scrollview (table is decelerating)
                break;
                
            default:
                break;
        }
    }
}

-(void) keyboardWillShowNotification:(NSNotification *) notification{
    NSDictionary *keyboardInfo = notification.userInfo;
    keyboardFrameBeginRect = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self.view layoutIfNeeded];
    bottomLayoutConstrain.constant = keyboardFrameBeginRect.size.height;
    
    CGRect tableViewRect = _tableView.frame;
    CGSize contentSize =  _tableView.contentSize;                  // default CGSizeZero
    
    CGFloat keyboardHeight = keyboardFrameBeginRect.size.height;
    CGFloat contentSizeHeight =  contentSize.height;                  // default CGSizeZero
    CGFloat tableViewRectHeight = tableViewRect.size.height;
    
    CGPoint contentOffset = _tableView.contentOffset;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    CGFloat keyboardY = (tableViewRectHeight - keyboardHeight);
    if (contentSizeHeight>keyboardY) {
        
        if (contentSizeHeight>tableViewRectHeight) {
            scrollPoint = CGPointMake(0.0, contentOffset.y + keyboardHeight);
            [_tableView setContentOffset:scrollPoint animated:false];
        }
        else{
            CGFloat a = contentSizeHeight - keyboardY;
            scrollPoint = CGPointMake(0.0, contentOffset.y + a + 5.0);
            [_tableView setContentOffset:scrollPoint animated:false];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded]; // Called on parent view
    }];
}

-(void) keyboardWillHideNotification:(NSNotification *) notification{
    NSDictionary *keyboardInfo = notification.userInfo;
    keyboardFrameBeginRect = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self.view layoutIfNeeded];
    bottomLayoutConstrain.constant = 0;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0.0, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];// Called on parent view
    }];
}

-(void) keyboardDidShowNotification:(NSNotification *) notification{
    //    NSDictionary *keyboardInfo = notification.userInfo;
    isMessageTFPresented = true;
}

-(void) keyboardDidHideNotification:(NSNotification *) notification{
    //    NSDictionary *keyboardInfo = notification.userInfo;
    isMessageTFPresented = false;
}

- (IBAction)sendMessageButtonTouched:(id)sender {
    NSString *trimmed = [messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmed == nil || [trimmed isEqualToString:@""]) {
        return;
    }
    [self addMessageInTable:trimmed];
    
    messageTextView.text = @"";
}


-(void) addAndScrollDownInTableView{
    if (tableData.count > 0){
        NSInteger section = [self.tableView numberOfSections]-1;
        NSInteger row = [self.tableView numberOfRowsInSection:section] -1;
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        CGRect lastCellFrame = [self.tableView rectForRowAtIndexPath:lastIndexPath];
        
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, (self.tableView.contentOffset.y + lastCellFrame.size.height)) animated:true];
    }
}

-(void)addMessageInTable:(NSString *)message{
    
    [tableData addObject:message];
    
    [self.tableView reloadData];
//    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self addAndScrollDownInTableView];
    
//    [self addAnotherRow];
    
//    [self.tableView reloadData];
//    [self.tableView layoutIfNeeded];
//    [self tableScrollDown:true];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tableData.count-1 inSection:0];//[_chatSectionManager indexPathForMessage:message];
//    if (indexPath == nil) return;
//    
//    //table should know about new index first//It need to do it otherwise your code goes crash anywhy
//    //    NSInteger section = [self.tableView numberOfSections];//0 means nothing
//    
////    BOOL isSectionNotExist = false;
//    //    if (section <= indexPath.section) {
//    //        isSectionNotExist = true;
//    //    }
//    //    NSInteger row = [self.tableView numberOfRowsInSection:indexPath.section];
//    @try {
//        [self.tableView beginUpdates];
////        if (isSectionNotExist) {
////            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
////        }
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView endUpdates];
////        [self.tableView layoutIfNeeded];
//        
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        dispatch_async(dispatch_get_main_queue(), ^{
//            [self tableScrollDown:true];
//        });
//    } @catch (NSException *exception) {
//        
//    }
}

//- (void)addAnotherRow {
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(tableData.count - 1) inSection:0];
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
//    [self updateContentInsetForTableView:self.tableView animated:YES];
//    
//    // TODO: if the scroll offset was at the bottom it can be scrolled down (allow user to scroll up and not override them)
//    
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//}
//
//- (void)updateContentInsetForTableView:(UITableView *)tableView animated:(BOOL)animated {
//    NSUInteger lastRow = [self tableView:tableView numberOfRowsInSection:0];
//    NSLog(@"last row: %lu", (unsigned long)lastRow);
//    NSLog(@"items count: %lu", (unsigned long)tableData.count);
//    
//    NSUInteger lastIndex = lastRow > 0 ? lastRow - 1 : 0;
//    
//    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:lastIndex inSection:0];
//    CGRect lastCellFrame = [self.tableView rectForRowAtIndexPath:lastIndexPath];
//    
//    // top inset = table view height - top position of last cell - last cell height
//    CGFloat topInset = MAX(CGRectGetHeight(self.tableView.frame) - lastCellFrame.origin.y - CGRectGetHeight(lastCellFrame), 0);
//    
//    // What about this way? (Did not work when tested)
//    // CGFloat topInset = MAX(CGRectGetHeight(self.tableView.frame) - self.tableView.contentSize.height, 0);
//    
//    NSLog(@"top inset: %f", topInset);
//    
//    UIEdgeInsets contentInset = tableView.contentInset;
//    contentInset.top = topInset;
//    NSLog(@"inset: %f, %f : %f, %f", contentInset.top, contentInset.bottom, contentInset.left, contentInset.right);
//    
//    NSLog(@"table height: %f", CGRectGetHeight(self.tableView.frame));
//    
//    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
//    [UIView animateWithDuration:animated ? 0.25 : 0.0 delay:0.0 options:options animations:^{
//        tableView.contentInset = contentInset;
//        
//    } completion:^(BOOL finished) {
//    }];
//}

-(void)tableScrollDown:(BOOL)isAnimation{
    if (tableData.count > 0){
        
        NSInteger section = [self.tableView numberOfSections]-1;
        NSInteger row = [self.tableView numberOfRowsInSection:section] -1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:isAnimation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark UITableDataSource
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSNumber *height = [cellHeightsDictionary objectForKey:indexPath];
//    if (height)
//        return height.doubleValue;
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [cellHeightsDictionary objectForKey:indexPath];
    if (height)
        return height.doubleValue;
    return UITableViewAutomaticDimension;
}

//Jerky Scrolling After Updating UITableViewCell in place with UITableViewAutomaticDimension
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *height = @(cell.frame.size.height);
    [cellHeightsDictionary setObject:height forKey:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger indexSection = indexPath.section;
    NSUInteger indexRow = indexPath.row;
    NSLog(@"section %ld row %lu",(long)indexSection, (unsigned long)indexRow);
    NSString *message = tableData[indexRow];
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.lblMessage.text = message;
    
    return cell;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
