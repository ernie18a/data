Calculation: 8AM range = highest high and lowest low of bars in the configured 8AM New York session, available after that session completes
Calculation: Prior higher-timeframe range = high and low of the last completed higher-timeframe bar
Calculation: Prior-day range = high and low of the last completed daily bar
Calculation: Opening range = highest high and lowest low of bars during the configured opening-range window, available after it completes
Calculation: Confirmed swing high = a bar high higher than the highs of the configured number of chart bars before and after it; confirmed after those following bars complete
Calculation: Confirmed swing low = a bar low lower than the lows of the configured number of chart bars before and after it; confirmed after those following bars complete
Calculation: Key levels = active prior-day, 8AM, prior higher-timeframe, preceding higher-timeframe, and opening-range highs, lows, and midpoints
Calculation: Key-level tolerance = configured pip distance, or configured percentage of ATR from the last completed daily bar (higher timeframe)
Calculation: Buy pressure = volume × (close − low) ÷ (high − low), or volume × 0.5 when high = low
Calculation: Sell pressure = volume − buy pressure
Calculation: Pressure delta = buy pressure − sell pressure
Long: During the configured projection session after the 8AM session completes, low < 8AM range low AND close > 8AM range low, once per range
Short: During the configured projection session after the 8AM session completes, high > 8AM range high AND close < 8AM range high, once per range
Long: Low < prior higher-timeframe range low AND close > prior higher-timeframe range low, once per higher-timeframe range
Short: High > prior higher-timeframe range high AND close < prior higher-timeframe range high, once per higher-timeframe range
Long: Low < prior-day range low AND close > prior-day range low, once per day
Short: High > prior-day range high AND close < prior-day range high, once per day
Long: During the configured signal window after the opening range completes, close > opening-range high, once per range
Short: During the configured signal window after the opening range completes, close < opening-range low, once per range
Long: A confirmed swing low is swept for the first time (low < swing low) and reclaimed (close > swing low), during the configured reversal session if session filtering is enabled; if key-level-only filtering is enabled, the swing low is within key-level tolerance of any active key level
Short: A confirmed swing high is swept for the first time (high > swing high) and rejected (close < swing high), during the configured reversal session if session filtering is enabled; if key-level-only filtering is enabled, the swing high is within key-level tolerance of any active key level
Long: After a bullish swing-failure signal, close > the latest confirmed swing high within the configured bar window, before close falls below the signal bar low
Short: After a bearish swing-failure signal, close < the latest confirmed swing low within the configured bar window, before close rises above the signal bar high
Long: A newly confirmed swing high > the preceding confirmed swing high
Long: A newly confirmed swing low > the preceding confirmed swing low
Short: A newly confirmed swing high < the preceding confirmed swing high
Short: A newly confirmed swing low < the preceding confirmed swing low
Long: Volume is available AND pressure delta > moving average of absolute pressure delta × configured strength threshold AND close > open AND volume > its moving average; use the same configured lookback for both moving averages
Short: Volume is available AND pressure delta < −(moving average of absolute pressure delta × configured strength threshold) AND close < open AND volume > its moving average; use the same configured lookback for both moving averages
Long: Price retests an unbroken buying-pressure zone: low <= zone top AND previous bar low > zone top
Short: Price retests an unbroken selling-pressure zone: high >= zone bottom AND previous bar high < zone bottom