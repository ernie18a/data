Calculation: Swing highs/lows = confirmed pivot highs/lows using the same lookback on both sides; track each pivot until swept or older than the pool-age limit
Calculation: Bullish/bearish BOS = close crosses above the latest swing high/below the latest swing low, optionally requiring a same-direction candle body at least the configured multiple of ATR
Calculation: Liquidity sweep = for any tracked, untaken pool, high > pool price AND close < pool price (high sweep), or low < pool price AND close > pool price (low sweep)
Calculation: HTF bias = last completed higher-timeframe close above/below its simple moving average; equal means neutral
Calculation: Bullish/bearish FVG = current low > high two bars ago / current high < low two bars ago
Calculation: Bullish/bearish OB = high-to-low range of the most recent prior bearish/bullish candle found within the search lookback; freeze its boundaries when the confirmed setup forms
Long: low sweep
Long: HTF close > HTF simple moving average
Long: bullish BOS AND a low sweep was armed within the timeout while trend state was nonpositive AND (HTF bias filter disabled OR HTF bias bullish) AND (OB retest disabled OR a later bar overlaps the frozen bullish OB within the touch timeout and, within the confirmation timeout, confirmation mode is None OR a bullish rejection candle OR bullish engulfing candle OR close above the OB top OR close above the retest bar high) AND (FVG requirement disabled OR bullish FVG occurs within the post-BOS window)
Short: high sweep
Short: HTF close < HTF simple moving average
Short: bearish BOS AND a high sweep was armed within the timeout while trend state was nonnegative AND (HTF bias filter disabled OR HTF bias bearish) AND (OB retest disabled OR a later bar overlaps the frozen bearish OB within the touch timeout and, within the confirmation timeout, confirmation mode is None OR a bearish rejection candle OR bearish engulfing candle OR close below the OB bottom OR close below the retest bar low) AND (FVG requirement disabled OR bearish FVG occurs within the post-BOS window)
Exit: long, low <= active stop OR high >= target
Exit: short, high >= active stop OR low <= target