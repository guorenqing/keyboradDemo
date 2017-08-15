//
//  TextViewCell.h
//  TestDemo
//
//  Created by guorenqing on 2017/8/15.
//  Copyright © 2017年 guorenqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextModel.h"

@interface TextViewCell : UITableViewCell



/** cellModel */
@property (strong, nonatomic) TextModel *cellModel;

+ (CGFloat)cellHeightWithText:(NSString *)text;

@end
