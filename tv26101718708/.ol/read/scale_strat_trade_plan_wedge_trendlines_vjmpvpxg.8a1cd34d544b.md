Calculation: Strat bar type 2 up = high > prior high AND low >= prior low; 2 down = low < prior low AND high <= prior high; inside = high <= prior high AND low >= prior low; outside = high > prior high AND low < prior low
Calculation: Bullish Strat reversal = 2 up after 2 down OR 2 up after inside preceded by 2 down OR 2 up after inside preceded by outside
Calculation: Bearish Strat reversal = 2 down after 2 up OR 2 down after inside preceded by 2 up OR 2 down after inside preceded by outside
Calculation: Bullish reversal candle = doji (body <= 10% of range) OR hammer (lower wick >= 2x body AND upper wick <= body) OR bullish engulfing (current up candle, prior down candle, current close >= prior open, current open <= prior close)
Calculation: Bearish reversal candle = doji OR shooter (upper wick >= 2x body AND lower wick <= body) OR bearish engulfing (current down candle, prior up candle, current close <= prior open, current open >= prior close)
Calculation: Swing high/low = pivot high/low confirmed with the configured number of bars on both sides
Calculation: Bullish liquidity event = price sweeps below the latest confirmed swing low and closes above it OR close crosses above the latest confirmed swing high from at/below it OR close is within the latest bullish fair-value gap; bullish fair-value gap = current low > high two bars earlier
Calculation: Bearish liquidity event = price sweeps above the latest confirmed swing high and closes below it OR close crosses below the latest confirmed swing low from at/above it OR close is within the latest bearish fair-value gap; bearish fair-value gap = current high < low two bars earlier
Calculation: Support/resistance levels = pivot, first and second support/resistance levels calculated from the prior completed higher-timeframe bar's high, low, and close; add latest confirmed swing low/high and prior completed higher-timeframe period low/high
Calculation: Near support/resistance = close is within the configured percentage of any respective support/resistance level
Calculation: Higher-timeframe alignment = bullish when current higher-timeframe bars are up on all three alignment timeframes; bearish when none of those bars are up. Use bars still forming.
Calculation: Daily EMA confirmation = bullish when the faster EMA crosses above the slower EMA within the configured recent-bar window OR close is above the slower EMA and low is within the configured percentage above it; bearish when the faster EMA crosses below the slower EMA within that window OR close is below the slower EMA and high is within that percentage below it. Use the daily bar still forming; the faster EMA has the shorter lookback.
Calculation: Long score = 1 each for near any support/resistance, bullish reversal candle, bullish higher-timeframe alignment OR bullish Strat reversal OR hammer, bullish liquidity event, and bullish daily EMA confirmation
Calculation: Short score = 1 each for near any support/resistance, bearish reversal candle, bearish higher-timeframe alignment OR bearish Strat reversal OR shooter, bearish liquidity event, and bearish daily EMA confirmation
Calculation: Trend bias = bullish when chart-timeframe faster EMA > slower EMA AND close > slower EMA; bearish when faster EMA < slower EMA AND close < slower EMA. The faster EMA has the shorter lookback.
Calculation: Higher-timeframe trend = bullish when higher-timeframe faster EMA > slower EMA OR close > slower EMA; otherwise bearish. Use bars still forming; the faster EMA has the shorter lookback.
Long: Bullish Strat reversal OR (bullish score >= minimum score AND prior bullish score < minimum score)
Long: Bullish Strat reversal AND bullish score >= minimum score AND (noise filter disabled OR ATR / close <= maximum ATR percentage AND (volume filter disabled OR volume > 20-bar average volume) AND close > open AND high - close <= 40% of range AND close - open >= 30% of range) AND (level filter disabled OR near support OR bullish liquidity event is a break above swing high AND not near resistance) AND (higher-timeframe confirmation disabled OR higher-timeframe trend is bullish) AND (late-entry filter disabled OR time is before the configured cutoff) AND range >= configured minimum ATR multiple
Short: Bearish Strat reversal OR (bearish score >= minimum score AND prior bearish score < minimum score)
Short: Bearish Strat reversal AND bearish score >= minimum score AND (noise filter disabled OR ATR / close <= maximum ATR percentage AND (volume filter disabled OR volume > 20-bar average volume) AND close < open AND high - close <= 40% of range AND open - close >= 30% of range) AND (level filter disabled OR near resistance OR bearish liquidity event is a break below swing low AND not near support) AND (higher-timeframe confirmation disabled OR higher-timeframe trend is bearish) AND (late-entry filter disabled OR time is before the configured cutoff) AND range >= configured minimum ATR multiple
Long: Bullish Strat reversal AND bullish score >= watch threshold AND bullish score < minimum score AND noise filter passes AND level filter passes
Short: Bearish Strat reversal AND bearish score >= watch threshold AND bearish score < minimum score AND noise filter passes AND level filter passes
Long: Bullish trend bias
Short: Bearish trend bias
Long: Higher-timeframe trend is bullish
Short: Higher-timeframe trend is bearish
Calculation: Long stop = max(trigger-bar low - stop-buffer ATR multiple, trigger-bar high - stop-cap ATR multiple); first target = trigger-bar high + target ATR multiple
Calculation: Short stop = min(trigger-bar high + stop-buffer ATR multiple, trigger-bar low + stop-cap ATR multiple); first target = trigger-bar low - target ATR multiple
Exit: long, high >= stored first target AND prior high < stored first target
Exit: long, low <= stored stop AND prior low > stored stop
Exit: short, low <= stored first target AND prior low > stored first target
Exit: short, high >= stored stop AND prior high < stored stop