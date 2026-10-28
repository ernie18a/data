Calculation: Buffer = ATR × buffer multiplier
Calculation: Swing high/low = highest high/lowest low over the lookback, including the current bar
Long: On a completed bar, close > VWAP + buffer AND close > open AND close > previous bar high AND RSI > 50
Short: On a completed bar, close < VWAP - buffer AND close < open AND close < previous bar low AND RSI < 50
Exit: Long, low <= entry-bar swing low - entry-bar buffer OR high >= entry price + entry-bar ATR × TP1 multiplier
Exit: Short, high >= entry-bar swing high + entry-bar buffer OR low <= entry price - entry-bar ATR × TP1 multiplier