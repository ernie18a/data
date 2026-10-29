Calculation: Momentum Z-score = (current close change − 50-bar simple average of close change) / 50-bar standard deviation of close change
Calculation: Confirmed pivot high/low = a bar high/low greater/less than the highs/lows of the configured number of bars on both sides; becomes available after the right-side bars complete
Calculation: Order block = for a bullish breakout, the first bearish candle among the preceding 10 bars; for a bearish breakout, the first bullish candle among the preceding 10 bars. Its high and low are the block top and bottom.
Calculation: Higher-timeframe alignment = higher-timeframe close above its EMA for bullish alignment or below its EMA for bearish alignment; use the last completed higher-timeframe bar (monthly EMA length longer than weekly, longer than daily)
Calculation: Active stop = for longs, the greater of entry price minus the hard-stop distance and the dynamic stop; for shorts, the lesser of entry price plus the hard-stop distance and the dynamic stop. After price moves favorably by the break-even trigger, the long dynamic stop is the greater of its prior value, entry price, and close minus 2.5 ATR; the short dynamic stop is the lesser of its prior value, entry price, and close plus 2.5 ATR. ATR uses chart-timeframe bars.
Long: Close crosses above the latest confirmed pivot high AND Momentum Z-score > configured positive threshold
Short: Close crosses below the latest confirmed pivot low AND Momentum Z-score < negative configured threshold
Long: Flat position AND an unmitigated, unused bullish order block exists AND low <= its top AND close > its bottom AND each enabled monthly, weekly, and daily alignment is bullish
Short: Flat position AND an unmitigated, unused bearish order block exists AND high >= its bottom AND close < its top AND each enabled monthly, weekly, and daily alignment is bearish
Long: Flat position AND waiting for bullish re-entry after a stagnation exit AND close > tracked order-block top
Short: Flat position AND waiting for bearish re-entry after a stagnation exit AND close < tracked order-block bottom
Exit: Long, bars since entry >= configured linger bars AND close is between the tracked order-block bottom and top, inclusive
Exit: Short, bars since entry >= configured linger bars AND close is between the tracked order-block bottom and top, inclusive
Exit: Long, high >= entry price + configured profit target OR low <= active stop
Exit: Short, low <= entry price − configured profit target OR high >= active stop