//
//  ICPickerViewTableViewCell.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import <IngenicoConnectExample/ICPickerViewTableViewCell.h>

@interface ICPickerViewTableViewCell ()

@property (strong, nonatomic) ICPickerView *pickerView;

@end

@implementation ICPickerViewTableViewCell

+ (NSString *)reuseIdentifier {
    return @"picker-view-cell";
}

- (void)setItems:(NSArray<ICValueMappingItem *> *)items {
    _items = items;
    if (items != nil) {
        NSMutableArray *names = [[NSMutableArray alloc]initWithCapacity:items.count];
        for (ICValueMappingItem *item in items) {
            [names addObject:item.displayName];
        }
        self.pickerView.content = names;
    }
}

- (NSObject<UIPickerViewDelegate> *)delegate {
    return self.pickerView.delegate;
}

- (void)setDelegate:(NSObject<UIPickerViewDelegate> *)delegate {
    self.pickerView.delegate = delegate;
}

- (NSObject<UIPickerViewDataSource> *)dataSource {
    return self.pickerView.dataSource;
}

- (void)setDataSource:(NSObject<UIPickerViewDataSource> *)dataSource {
    self.pickerView.dataSource = dataSource;
}

- (NSInteger)selectedRow {
    return [self.pickerView selectedRowInComponent:0];
}

- (void)setSelectedRow:(NSInteger)selectedRow {
    [self.pickerView selectRow:selectedRow inComponent:0 animated:false];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.pickerView = [ICPickerView new];
    
    [self addSubview:self.pickerView];
    
    self.clipsToBounds = YES;
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.pickerView != nil) {
        CGFloat width = self.contentView.frame.size.width;
        self.pickerView.frame = CGRectMake(10, 0, width - 20, 162);
    }
}

- (void)prepareForReuse {
    self.items = [[NSArray alloc] init];
    self.delegate = nil;
    self.dataSource = nil;
}

@end
