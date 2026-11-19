Calculation: Latest confirmed swing high = most recent confirmed Pivot High(high, swing lookback, swing lookback)
Calculation: Latest confirmed swing low = most recent confirmed Pivot Low(low, swing lookback, swing lookback)
Long: low < latest confirmed swing low AND close > latest confirmed swing low
Short: high > latest confirmed swing high AND close < latest confirmed swing high
Calculation: Pending bullish sweep = a bullish sweep occurred within the sweep expiry on chart bars and no bullish BOS has since consumed it
Calculation: Pending bearish sweep = a bearish sweep occurred within the sweep expiry on chart bars and no bearish BOS has since consumed it
Long: pending bullish sweep AND close > latest confirmed swing high AND close[1] <= latest confirmed swing high
Short: pending bearish sweep AND close < latest confirmed swing low AND close[1] >= latest confirmed swing low
Calculation: Structure direction = bullish after the latest bullish BOS, bearish after the latest bearish BOS, and neutral before either
Calculation: HTF bias = compare close and EMA(close, HTF EMA lookback) on T1 bars, sampled on chart bars with lookahead off (current T1 bar in real time and last completed T1 bar historically); bullish when close > EMA and bearish when close < EMA
Long: HTF close > HTF EMA
Short: HTF close < HTF EMA
Calculation: Active bullish order block = at bullish BOS, set bounds to the nearest bearish candle within the order-block scan lookback; retain prior bounds if none is found; clear when close < its low or a long entry consumes it
Calculation: Active bearish order block = at bearish BOS, set bounds to the nearest bullish candle within the order-block scan lookback; retain prior bounds if none is found; clear when close > its high or a short entry consumes it
Calculation: Active bullish breaker = when structure direction is bullish, the preceding consecutive bearish candles meet the breaker lookback and close > their highest body top, set bounds to their highest high and lowest low; clear when close < its low or a long entry consumes it
Calculation: Active bearish breaker = when structure direction is bearish, the preceding consecutive bullish candles meet the breaker lookback and close < their lowest body bottom, set bounds to their highest high and lowest low; clear when close > its high or a short entry consumes it
Calculation: Latest bullish FVG = when structure direction is bullish, high[FVG lookback] < low and low - high[FVG lookback] >= minimum gap size, set bounds to high[FVG lookback] and low; retain until overwritten by another bullish FVG or consumed by a long entry
Calculation: Latest bearish FVG = when structure direction is bearish, low[FVG lookback] > high and low[FVG lookback] - high >= minimum gap size, set bounds to high and low[FVG lookback]; retain until overwritten by another bearish FVG or consumed by a short entry
Long: an active bullish order block exists
Short: an active bearish order block exists
Long: an active bullish breaker exists
Short: an active bearish breaker exists
Long: structure direction is bullish AND high[FVG lookback] < low AND low - high[FVG lookback] >= minimum gap size
Short: structure direction is bearish AND low[FVG lookback] > high AND low[FVG lookback] - high >= minimum gap size
Long: structure direction is bullish AND current close is within an active bullish order block, bullish FVG, or bullish breaker AND current chart bar is in an enabled NY-time session AND HTF bias is bullish AND no position is open
Short: structure direction is bearish AND current close is within an active bearish order block, bearish FVG, or bearish breaker AND current chart bar is in an enabled NY-time session AND HTF bias is bearish AND no position is open
Calculation: Long stop = lower bound of the tapped bullish order block if tapped, otherwise the tapped bullish FVG if tapped, otherwise the tapped bullish breaker, minus the stop buffer; fix at the entry signal
Calculation: Long target = entry-signal bar close + (entry-signal bar close - long stop) * reward-to-risk parameter; fix at the entry signal
Calculation: Short stop = upper bound of the tapped bearish order block if tapped, otherwise the tapped bearish FVG if tapped, otherwise the tapped bearish breaker, plus the stop buffer; fix at the entry signal
Calculation: Short target = entry-signal bar close - (short stop - entry-signal bar close) * reward-to-risk parameter; fix at the entry signal
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target