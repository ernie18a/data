Calculation: Previous RTH close = close of the final chart bar in the previous RTH session
Calculation: Gap % = if previous RTH close > 0, 100 × (close − previous RTH close) / previous RTH close; otherwise 0
Calculation: ORB High = highest high of chart bars during the opening-range duration after RTH open
Calculation: ORB Low = lowest low of chart bars during the opening-range duration after RTH open
Calculation: Premarket high = highest high of chart bars in the premarket session
Calculation: Volume surge = if SMA(volume, volume lookback) > 0, volume / SMA(volume, volume lookback) ≥ volume surge multiplier; otherwise 0 ≥ volume surge multiplier
Calculation: Setup score = count of: Gap % ≥ minimum gap threshold; Gap % ≥ Tier-A gap threshold; close > previous RTH close; premarket high exists and close > premarket high; opening range complete and close > ORB High; close > VWAP; volume surge; EMA(close, shorter lookback) > EMA(close, longer lookback); RSI(close, RSI lookback) > RSI threshold
Calculation: Long stop = ORB Low − ATR(ATR lookback) × stop distance multiplier, fixed at primary entry
Calculation: Target 1 = entry price + ATR(ATR lookback) × first target multiplier, fixed at primary entry
Calculation: Target 2 = entry price + ATR(ATR lookback) × second target multiplier, fixed at primary entry
Long: During RTH after the opening range is complete, close crosses above ORB High AND Gap % ≥ minimum gap threshold AND close > previous RTH close AND (VWAP filter disabled OR close > VWAP) AND (premarket-high filter disabled OR premarket high is absent OR close > premarket high) AND (EMA-stack filter disabled OR EMA(close, shorter lookback) > EMA(close, longer lookback)) AND (volume filter disabled OR volume surge) AND (RSI filter disabled OR RSI(close, RSI lookback) > RSI threshold) AND (early-session filter disabled OR elapsed time since RTH open ≤ early-session cutoff) AND Setup score ≥ A+ score threshold
Long: After a primary long signal, starting with the second counted chart bar (counting the signal bar as first), once a retest-zone touch has occurred since that signal (low ≤ ORB High × (1 + retest buffer percent) AND close ≥ ORB High × (1 − retest buffer percent)), and before a retest signal has fired for that primary signal, close > ORB High AND close > open AND (VWAP filter disabled OR close > VWAP) AND (EMA-stack filter disabled OR EMA(close, shorter lookback) > EMA(close, longer lookback)) AND (early-session filter disabled OR elapsed time since RTH open ≤ early-session cutoff) AND Setup score ≥ A+ score threshold; retest signal enabled
Exit: long, after primary entry, low ≤ Long stop
Exit: long, after primary entry, high ≥ Target 1
Exit: long, after primary entry, high ≥ Target 2