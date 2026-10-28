Calculation: Last swing low = most recently confirmed pivot low, whose low is below the lows in the configured lookback bars before and after it.
Calculation: Last swing high = most recently confirmed pivot high, whose high is above the highs in the configured lookback bars before and after it.
Calculation: Filter A = its configured VWAP of hlc3 (reset at the selected anchor) or HMA, EMA, or SMA of close; it may be disabled.
Calculation: Filter B = its configured VWAP of hlc3 (reset at the selected anchor) or HMA, EMA, or SMA of close; it may be disabled.
Long: low < Last swing low AND close > Last swing low AND previous bar low > Last swing low AND (Filter A is disabled OR close > Filter A) AND (Filter B is disabled OR close > Filter B)
Short: high > Last swing high AND close < Last swing high AND previous bar high < Last swing high AND (Filter A is disabled OR close < Filter A) AND (Filter B is disabled OR close < Filter B)