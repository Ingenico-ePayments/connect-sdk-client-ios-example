//
//  ICViewType.h
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#ifndef ICDemo_ICViewType_h
#define ICDemo_ICViewType_h

typedef enum {
    // Switches
    ICSwitchType,
    
    // PickerViews
    ICPickerViewType,
    
    // TextFields
    ICTextFieldType,
    ICIntegerTextFieldType,
    ICFractionalTextFieldType,

    // Buttons
    ICPrimaryButtonType,
    ICSecondaryButtonType,
    
    // Labels
    ICLabelType,

    // TableViewCells
    ICPaymentProductTableViewCellType,
    ICTextFieldTableViewCellType,
    ICCurrencyTableViewCellType,
    ICErrorMessageTableViewCellType,
    ICSwitchTableViewCellType,
    ICPickerViewTableViewCellType,
    ICButtonTableViewCellType,
    ICLabelTableViewCellType,
    ICTooltipTableViewCellType,
    ICCoBrandsSelectionTableViewCellType,
    ICCoBrandsExplanationTableViewCellType,

    // TableHeaderView
    ICSummaryTableHeaderViewType,
    
    //TableFooterView
    ICButtonsTableFooterViewType
} ICViewType;

#endif
