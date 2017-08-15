//
//  ViewController.m
//  TestDemo
//
//  Created by guorenqing on 2017/8/15.
//  Copyright © 2017年 guorenqing. All rights reserved.
//

#import "ViewController.h"

#import "TextViewCell.h"
#import "TextModel.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

/** tableView */
@property (strong, nonatomic) UITableView *tableView;
/** dataSource */
@property (strong, nonatomic) NSMutableArray *dataSource;

@property (nonatomic, assign) UIEdgeInsets originalTableContentInset;
@end

@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    
    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark -


#pragma mark  获取第一响应者
static UIView *GetFirstResponder(UIView *view)
{
    if ([view isFirstResponder])
    {
        return view;
    }
    for (UIView *subview in view.subviews)
    {
        UIView *responder = GetFirstResponder(subview);
        if (responder)
        {
            return responder;
        }
    }
    return nil;
}


- (UITableViewCell *)cellContainingView:(UIView *)view
{
    if (view == nil || [view isKindOfClass:[UITableViewCell class]])
    {
        return (UITableViewCell *)view;
    }
    return [self cellContainingView:view.superview];
}

#pragma mark 键盘事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    UITableViewCell *cell = [self cellContainingView:GetFirstResponder(self.tableView)];
    if (cell)
    {
        // calculate the size of the keyboard and how much is and isn't covering the tableview
        NSDictionary *keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardFrame = [self.tableView.window convertRect:keyboardFrame toView:self.tableView.superview];
        CGFloat heightOfTableViewThatIsCoveredByKeyboard = self.tableView.frame.origin.y + self.tableView.frame.size.height - keyboardFrame.origin.y;
        CGFloat heightOfTableViewThatIsNotCoveredByKeyboard = self.tableView.frame.size.height - heightOfTableViewThatIsCoveredByKeyboard;
        
        UIEdgeInsets tableContentInset = self.tableView.contentInset;
        self.originalTableContentInset = tableContentInset;
        tableContentInset.bottom = heightOfTableViewThatIsCoveredByKeyboard;
        
        UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        tableScrollIndicatorInsets.bottom += heightOfTableViewThatIsCoveredByKeyboard;
        
        
        
        [UIView beginAnimations:nil context:nil];
        
        
        self.tableView.contentInset = tableContentInset;
        self.tableView.scrollIndicatorInsets = tableScrollIndicatorInsets;
        
        
        UIView *firstResponder = GetFirstResponder(self.tableView);
        if ([firstResponder isKindOfClass:[UITextView class]])
        {
            UITextView *textView = (UITextView *)firstResponder;
            
            // calculate the position of the cursor in the textView
            NSRange range = textView.selectedRange;
            UITextPosition *beginning = textView.beginningOfDocument;
            UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
            UITextPosition *end = [textView positionFromPosition:start offset:range.length];
            CGRect caretFrame = [textView caretRectForPosition:end];
            
            // convert the cursor to the same coordinate system as the tableview
            CGRect caretViewFrame = [textView convertRect:caretFrame toView:self.tableView.superview];
            
            // padding makes sure that the cursor isn't sitting just above the
            // keyboard and will adjust to 3 lines of text worth above keyboard
            CGFloat padding = textView.font.lineHeight * 2;
            CGFloat keyboardToCursorDifference = (caretViewFrame.origin.y + caretViewFrame.size.height) - heightOfTableViewThatIsNotCoveredByKeyboard + padding;
            
            // if there is a difference then we want to adjust the keyboard, otherwise
            // the cursor is fine to stay where it is and the keyboard doesn't need to move
            if (keyboardToCursorDifference > 0)
            {
                // adjust offset by this difference
                CGPoint contentOffset = self.tableView.contentOffset;
                contentOffset.y += keyboardToCursorDifference;
                [self.tableView setContentOffset:contentOffset animated:NO];
            }
        }
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UITableViewCell *cell = [self cellContainingView:GetFirstResponder(self.tableView)];
    if (cell)
    {
        NSDictionary *keyboardInfo = [note userInfo];
        UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        tableScrollIndicatorInsets.bottom = 0;
        
        //restore insets
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:(UIViewAnimationCurve)keyboardInfo[UIKeyboardAnimationCurveUserInfoKey]];
        [UIView setAnimationDuration:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [self.tableView setContentInset:tableScrollIndicatorInsets];
        
       
        [UIView commitAnimations];
    }
}

#pragma mark - tableView 数据源代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextModel *textModel = self.dataSource[indexPath.row];
    return [TextViewCell cellHeightWithText:textModel.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cellID";
    
    TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {
        cell = [[TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.cellModel = self.dataSource[indexPath.row];
    return cell;
}



#pragma mark - -------------------Getters----------------
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [NSMutableArray array];
        
        
        for (int i = 0; i < 20; i++)
        {
            [_dataSource addObject:[[TextModel alloc] init]];
        }
        
    }
    
    return _dataSource;
}


@end
