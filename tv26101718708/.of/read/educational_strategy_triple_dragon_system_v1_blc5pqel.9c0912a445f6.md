Calculation: EPVT zero-cross price = close at the latest crossing of cumulative sum of ((close − prior close) / prior close × volume) minus the midpoint of its rolling highest and lowest values
Calculation: SAR cross price = close at the latest crossing of close and the ATR-scaled Parabolic SAR
Calculation: Upper drag = maximum of EPVT zero-cross price and SAR cross price
Calculation: Lower drag = minimum of EPVT zero-cross price and SAR cross price
Long: close crosses above Upper drag OR close crosses above Lower drag
Short: close crosses below Upper drag OR close crosses below Lower drag
Exit: Long, close crosses below Upper drag OR close crosses below Lower drag
Exit: Short, close crosses above Upper drag OR close crosses above Lower drag