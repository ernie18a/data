Calculation: Short-lookback EMA = EMA of close on the chart timeframe; its lookback is shorter than the long-lookback EMA.
Calculation: Long-lookback EMA = EMA of close on the chart timeframe.
Calculation: Daily trend = daily close > long-lookback EMA calculated on daily bars; use the current daily bar, which may still be forming.
Calculation: 4-hour trend = 4-hour close > long-lookback EMA calculated on 4-hour bars; use the current 4-hour bar, which may still be forming.
Calculation: Volume confirmation = volume > simple moving average of volume over a longer lookback.
Calculation: Long stop = signal-bar low × (1 − stop buffer); long risk = entry price − long stop; long target = entry price + (long risk × third risk/reward multiplier).
Calculation: Short stop = signal-bar high × (1 + stop buffer); short risk = short stop − entry price; short target = entry price − (short risk × third risk/reward multiplier).
Long: low <= short-lookback EMA AND close > short-lookback EMA AND close > long-lookback EMA AND daily trend AND 4-hour trend AND volume confirmation
Short: high >= short-lookback EMA AND close < short-lookback EMA AND close < long-lookback EMA AND NOT daily trend AND NOT 4-hour trend AND volume confirmation
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target