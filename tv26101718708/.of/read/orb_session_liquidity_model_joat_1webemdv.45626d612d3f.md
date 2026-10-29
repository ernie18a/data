Calculation: Opening-range high/low = highest high and lowest low during the configured opening window, fixed when that window ends
Calculation: Breakout buffer = ATR × configured buffer multiplier
Calculation: Stop = opposite opening-range boundary, or entry price minus (long) / plus (short) ATR × configured stop multiplier; if the resulting risk distance is nonpositive, use that ATR stop
Calculation: TP1 = entry price plus (long) / minus (short) risk distance × configured TP1 R multiple
Long: opening window has ended AND current bar is in the configured trade session AND long signals used today < configured daily limit AND current close > current opening-range high + current breakout buffer AND previous close <= previous opening-range high + previous breakout buffer
Short: opening window has ended AND current bar is in the configured trade session AND short signals used today < configured daily limit AND current close < current opening-range low - current breakout buffer AND previous close >= previous opening-range low - previous breakout buffer
Exit: long position, bar high >= TP1 OR bar low <= stop
Exit: short position, bar low <= TP1 OR bar high >= stop