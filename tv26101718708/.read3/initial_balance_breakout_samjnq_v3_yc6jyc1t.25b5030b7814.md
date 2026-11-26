Calculation: IB high = maximum(high of chart bars in the IB-session parameter during the current T1 period)
Calculation: IB low = minimum(low of chart bars in the IB-session parameter during the current T1 period)
Calculation: IB range = IB high - IB low
Calculation: IB midpoint = (IB high + IB low) / 2
Long: IB session has ended AND IB range >= minimum-range parameter AND IB range <= maximum-range parameter AND datetime is within the trade-window parameter (ET) AND no earlier long entry in the current T1 period AND position is flat AND (VWAP filter is disabled OR close > VWAP(hlc3)) AND close crosses above IB high
Short: IB session has ended AND IB range >= minimum-range parameter AND IB range <= maximum-range parameter AND datetime is within the trade-window parameter (ET) AND no earlier short entry in the current T1 period AND position is flat AND (VWAP filter is disabled OR close < VWAP(hlc3)) AND close crosses below IB low
Exit: long, low <= (IB midpoint if the stop-mode parameter selects midpoint, otherwise IB low) OR high >= IB high + target-multiple parameter × IB range OR datetime is within the EOD-flattening window (ET)
Exit: short, high >= (IB midpoint if the stop-mode parameter selects midpoint, otherwise IB high) OR low <= IB low - target-multiple parameter × IB range OR datetime is within the EOD-flattening window (ET)