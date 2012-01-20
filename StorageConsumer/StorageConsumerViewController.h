//
//  StorageConsumerViewController.h
//  StorageConsumer
//
//  Created by Yoichi Tagaya on 12/01/20.
//  Copyright (c) 2012 Yoichi Tagaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorageConsumerViewController : UIViewController
<UIPickerViewDataSource, UIPickerViewDelegate>

@property (retain, nonatomic) NSArray *gigaByteValues;
@property (retain, nonatomic) NSArray *megaByteValues;
@property (retain, nonatomic) IBOutlet UIPickerView *sizePicker;
- (IBAction)consumeButtonDidTouchUpInside:(id)sender;
- (IBAction)clearButtonDidTouchUpInside:(id)sender;

@end
