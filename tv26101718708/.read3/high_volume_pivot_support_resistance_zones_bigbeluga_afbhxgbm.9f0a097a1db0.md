Calculation: Latest resistance zone = [max(open, close)[resistance pivot lookback], max(open, close)[resistance pivot lookback] + ATR(ATR lookback)[resistance pivot lookback]] at each confirmed pivot high(high, resistance pivot lookback, resistance pivot lookback); retain the latest zone
Calculation: Latest support zone = [min(open, close)[support pivot lookback] - ATR(ATR lookback)[support pivot lookback], min(open, close)[support pivot lookback]] at each confirmed pivot low(low, support pivot lookback, support pivot lookback); retain the latest zone
Long: close > latest resistance zone top AND no earlier bar since that zone formed closed above its top
Long: low[1] <= latest support zone top AND low > latest support zone top
Long: low[1] <= latest resistance zone top AND low > latest resistance zone top AND the resistance zone's broken status was unchanged on this and the previous bar
Short: close < latest support zone bottom AND no earlier bar since that zone formed closed below its bottom
Short: high[1] >= latest resistance zone bottom AND high < latest resistance zone bottom
Short: high[1] >= latest support zone bottom AND high < latest support zone bottom