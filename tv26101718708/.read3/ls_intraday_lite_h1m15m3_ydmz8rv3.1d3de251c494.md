Calculation: minimum overshoot = max(close * overshoot-fraction parameter, ATR(ATR-lookback parameter) * ATR-multiplier parameter), evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: T2 swing pivots = PivotHigh(high, swing-pivot lookback, swing-pivot lookback) and PivotLow(low, swing-pivot lookback, swing-pivot lookback); each new non-null output replaces its latest level, evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: bullish raw sweep = high > latest T2 swing high + minimum overshoot AND close < latest T2 swing high AND high - max(open, close) > wick-fraction parameter * (high - low), evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: bearish raw sweep = low < latest T2 swing low - minimum overshoot AND close > latest T2 swing low AND min(open, close) - low > wick-fraction parameter * (high - low), evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: bullish confirmed sweep = a newly confirmed PivotLow(low, swing-pivot lookback, swing-pivot lookback) is above the lowest low recorded by pending bullish raw sweeps; clear the pending low on confirmation and otherwise retain the lowest raw-sweep low, evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: bearish confirmed sweep = a newly confirmed PivotHigh(high, swing-pivot lookback, swing-pivot lookback) is below the highest high recorded by pending bearish raw sweeps; clear the pending high on confirmation and otherwise retain the highest raw-sweep high, evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: T2 internal pivots = PivotHigh(high, internal-pivot lookback, internal-pivot lookback) and PivotLow(low, internal-pivot lookback, internal-pivot lookback); each new non-null output replaces its latest level and resets that level's crossed flag. The internal-pivot lookback is a separate parameter from the swing-pivot lookback, evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: bullish internal break = close > the latest T2 internal pivot high whose crossed flag is unset; set its crossed flag on the break, evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: bearish internal break = close < the latest T2 internal pivot low whose crossed flag is unset; set its crossed flag on the break, evaluated on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: T1 bias = initially neutral; on each T1 bar set bullish if close > the latest confirmed PivotHigh(high, bias-pivot lookback, bias-pivot lookback), then set bearish if close < the latest confirmed PivotLow(low, bias-pivot lookback, bias-pivot lookback); otherwise retain the prior bias. The bearish update takes precedence if both conditions hold. Evaluate on T1 bars using the latest available T1 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: T2 structure trend = initially neutral; set bullish on a bullish internal break, then bearish on a bearish internal break; otherwise retain the prior trend. The bearish update takes precedence if both conditions hold. Evaluate on T2 bars using the latest available T2 bar (last completed historically; possibly still forming in real time), with values sampled on chart bars
Calculation: bullish MSS event = bullish confirmed sweep AND bullish internal break AND T1 bias is bullish or neutral AND no bullish MSS is active, evaluated on chart bars using the sampled T1 and T2 values
Calculation: bearish MSS event = bearish confirmed sweep AND bearish internal break AND T1 bias is bearish or neutral AND no bearish MSS is active, evaluated on chart bars using the sampled T1 and T2 values
Calculation: bullish MSS active = becomes true on a bullish MSS event; becomes false on a bearish MSS event or when chart close < the T2 internal pivot high stored at activation; otherwise retains its state, evaluated on chart bars
Calculation: bearish MSS active = becomes true on a bearish MSS event; becomes false on a bullish MSS event or when chart close > the T2 internal pivot low stored at activation; otherwise retains its state, evaluated on chart bars
Long: T1 bias is bullish
Short: T1 bias is bearish
Long: T2 structure trend is bullish
Short: T2 structure trend is bearish
Long: bullish internal break
Short: bearish internal break
Long: bullish raw sweep
Short: bearish raw sweep
Long: bullish confirmed sweep
Short: bearish confirmed sweep
Long: bullish MSS event
Short: bearish MSS event
Long: bullish MSS active
Short: bearish MSS active