//
//  PGSlotPicker.h
//  CCPickerView
//
//  Created by yiplee on 5/19/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCPickerView.h"

@interface PGSlotPicker : CCPickerView<CCPickerViewDataSource, CCPickerViewDelegate>

@property (nonatomic,retain) NSMutableIndexSet* ignoreIndexs;
@property (nonatomic,copy) void (^spinDone)(NSString *name);

+ (instancetype) pickerWithComponentData:(NSDictionary*)data;
- (id) initWithComponentData:(NSDictionary*)data;

@end

@interface CCLayer (slotPicker)

- (void) addSlotPickerWithData:(NSDictionary*)data at:(CGPoint)pos;

@end
