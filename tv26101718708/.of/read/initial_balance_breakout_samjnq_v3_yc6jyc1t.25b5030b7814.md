Calculation: IB high = highest high during the initial balance window
Calculation: IB low = lowest low during the initial balance window
Long: after the initial balance is locked, its range is within the allowed minimum and maximum, during the trade window, no long entry has already occurred that day, position is flat, and close > VWAP or the VWAP filter is disabled, and current close > IB high AND previous close <= IB high
Short: after the initial balance is locked, its range is within the allowed minimum and maximum, during the trade window, no short entry has already occurred that day, position is flat, and close < VWAP or the VWAP filter is disabled, and current close < IB low AND previous close >= IB low
Exit: long, low <= IB low OR high >= IB high + target multiple × (IB high − IB low) OR datetime is in the end-of-day flatten window
Exit: short, high >= IB high OR low <= IB low − target multiple × (IB high − IB low) OR datetime is in the end-of-day flatten window