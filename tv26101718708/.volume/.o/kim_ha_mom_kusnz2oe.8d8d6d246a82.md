Calculation: Daily VWAP = cumulative (open + high + low + close)/4 × volume since the UTC+7 day began, divided by cumulative volume; use current chart bars.
Calculation: 5-minute Heikin Ashi swing high/low = pivot high/low with equal parameterized lookbacks on both sides; use confirmed pivots.
Calculation: Bullish/bearish sweep = current high above the latest confirmed swing high and close below it / current low below the latest confirmed swing low and close above it.
Calculation: Bullish CHoCH/BOS = close crosses above the latest confirmed swing high from at or below it, with a prior bearish/bullish sweep respectively; bearish CHoCH/BOS = close crosses below the latest confirmed swing low from at or above it, with a prior bullish/bearish sweep respectively.
Calculation: Daily VWAP ROC = 100 × (current daily VWAP − daily VWAP at the parameterized lookback) / daily VWAP at the lookback; valid only after that many bars since the UTC+7 day began.
Calculation: Session CVD = cumulative lower-timeframe up-candle volume minus down-candle volume, reset at session start; use the active UTC+7 session, prioritizing New York over London over Asia. Lower-timeframe bars are those aggregated within the current chart bar.
Calculation: EMA spread ratio = absolute difference between short-lookback and long-lookback close EMAs, divided by ATR; the short EMA lookback is shorter than the long EMA lookback.
Long: Bullish CHoCH or BOS occurs while close > daily VWAP; within the parameterized pullback window, a red Heikin Ashi candle occurs, then a green Heikin Ashi candle occurs while close > daily VWAP, session CVD is rising, and absolute(close − open)/(high − low) ≥ the parameterized entry-body ratio; the entry must occur within the parameterized maximum wait after the structure event.
Long: Close > daily VWAP and active session CVD > 0.
Long: Daily VWAP ROC crosses above either positive parameterized threshold.
Long: EMA spread ratio crosses above its parameterized start threshold while short-lookback EMA > long-lookback EMA.
Long: Close > short-lookback EMA.
Short: Bearish CHoCH or BOS occurs while close < daily VWAP; within the parameterized pullback window, a green Heikin Ashi candle occurs, then a red Heikin Ashi candle occurs while close < daily VWAP, session CVD is falling, and absolute(close − open)/(high − low) ≥ the parameterized entry-body ratio; the entry must occur within the parameterized maximum wait after the structure event.
Short: Close < daily VWAP and active session CVD < 0.
Short: Daily VWAP ROC crosses below either negative parameterized threshold.
Short: EMA spread ratio crosses above its parameterized start threshold while short-lookback EMA < long-lookback EMA.
Short: Close < short-lookback EMA.
Exit: Long, EMA spread ratio crosses below its parameterized end threshold while bullish momentum is active.
Exit: Short, EMA spread ratio crosses below its parameterized end threshold while bearish momentum is active.