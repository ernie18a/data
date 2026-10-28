Calculation: Relative volume = current bar volume divided by its 20-bar average volume
Calculation: 1-hour baseline = 20-period EMA of close on the current, still-forming 1-hour bar
Calculation: Prior 2-hour high/low = high/low of the last completed 2-hour bar
Calculation: 2-hour trend is bullish when the current, still-forming 2-hour close is above its 20-period EMA and open; bearish when below its EMA and open
Calculation: 4-hour trend is bullish when the current, still-forming 4-hour close is above its 20-period EMA and open; bearish when below its EMA and open
Calculation: Long stop = the lower of entry-bar low and prior 2-hour low, minus an ATR-based buffer
Calculation: Short stop = the higher of entry-bar high and prior 2-hour high, plus an ATR-based buffer
Calculation: Long target = entry price + (entry price − long stop) × risk/reward multiple
Calculation: Short target = entry price − (short stop − entry price) × risk/reward multiple
Long: During the configured NY session AND bullish 2-hour and 4-hour trends AND ((bar low < prior 2-hour low AND bar close > prior 2-hour low AND relative volume > 1) OR (bar close > VWAP AND bar close > 1-hour baseline AND relative volume > configured trend threshold AND bar close > bar open))
Short: During the configured NY session AND bearish 2-hour and 4-hour trends AND ((bar high > prior 2-hour high AND bar close < prior 2-hour high AND relative volume > 1) OR (bar close < VWAP AND bar close < 1-hour baseline AND relative volume > configured trend threshold AND bar close < bar open))
Long: No sweep or trend entry signal AND bar close > prior 2-hour high
Short: No sweep or trend entry signal AND bar close < prior 2-hour low
Exit: Long, (bar high >= long target AND long target > previous bar close) OR (bar low <= long stop AND long stop < previous bar close)
Exit: Short, (bar low <= short target AND short target < previous bar close) OR (bar high >= short stop AND short stop > previous bar close)