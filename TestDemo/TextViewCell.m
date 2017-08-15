//
//  TextViewCell.m
//  TestDemo
//
//  Created by guorenqing on 2017/8/15.
//  Copyright © 2017年 guorenqing. All rights reserved.
//

#import "TextViewCell.h"
#import <Masonry.h>

@interface TextViewCell ()<UITextViewDelegate>

/** textView */
@property (strong, nonatomic) UITextView *textView;

@end

@implementation TextViewCell


+ (CGFloat)cellHeightWithText:(NSString *)text
{
    static UITextView *textView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        textView = [[UITextView alloc] init];
        textView.font = [UIFont systemFontOfSize:17];
    });
    
    textView.text = text ?: @" ";
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake([[UIScreen mainScreen] bounds].size.width -20, CGFLOAT_MAX)];
    
    CGFloat height = 10; // label height
    height += (ceil(textViewSize.height) + 10);
    return height;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self.contentView addSubview:self.textView];
        [self setupConstraints];
    }
    
    return self;
}


- (void)setupConstraints
{
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.top.bottom.mas_equalTo(10);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
    }];
}





- (void)setCellModel:(TextModel *)cellModel
{
    if (cellModel)
    {
        _cellModel = cellModel;
        self.textView.text = cellModel.text;
    }
}


- (void)textViewDidChange:(UITextView *)textView
{
    self.cellModel.text = textView.text;
    //resize the tableview if required
    UITableView *tableView = [self tableView];
    [tableView beginUpdates];
    [tableView endUpdates];
    
    //scroll to show cursor
    CGRect cursorRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.end];
    [tableView scrollRectToVisible:[tableView convertRect:cursorRect fromView:self.textView] animated:YES];
}

- (UITableView *)tableView
{
    UITableView *view = (UITableView *)[self superview];
    while (![view isKindOfClass:[UITableView class]])
    {
        view = (UITableView *)[view superview];
    }
    return view;
}


- (void)textViewDidEndEditing:(__unused UITextView *)textView
{
    self.cellModel.text = textView.text;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [self.textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.textView resignFirstResponder];
}



- (UITextView *)textView
{
    if (!_textView)
    {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.textColor = [UIColor colorWithRed:0.275f green:0.376f blue:0.522f alpha:1.000f];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.delegate = self;
        _textView.scrollEnabled = NO;

    }
    
    return _textView;
}
@end
