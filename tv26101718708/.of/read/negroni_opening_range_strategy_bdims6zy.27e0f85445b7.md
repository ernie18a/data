Calculation: Range high and low = highest high and lowest low of chart bars whose opening times fall within the selected pre-market or opening-range window; update during the window and retain the latest values until the next window begins.
Calculation: ATR = average true range on the selected timeframe; for a higher timeframe use the last completed bar in historical backtests, and for a lower timeframe use the last completed intrabar within each chart bar.
Calculation: Trend moving average = a selectable EMA, SMA, VWMA, or HMA of a selectable price source; the fast moving average is independently configured and has a shorter period than the trend moving average.
Long: Close crosses above the selected range high AND bar opening time is within the inclusive trading window AND today's submitted entry orders are below the daily limit AND long trading is enabled.
Short: Close crosses below the selected range low AND bar opening time is within the inclusive trading window AND today's submitted entry orders are below the daily limit AND short trading is enabled.
Long: Fast moving average > trend moving average.
Short: Fast moving average <= trend moving average.
Exit: Long, bar opening time >= configured closing time.
Exit: Short, bar opening time >= configured closing time.
Exit: Long, before closing time AND full ATR mode is selected AND (low <= entry price - ATR × stop multiplier OR high >= entry price + ATR × full target multiplier).
Exit: Short, before closing time AND full ATR mode is selected AND (high >= entry price + ATR × stop multiplier OR low <= entry price - ATR × full target multiplier).
Exit: Long, before closing time AND partial ATR mode is selected AND (low <= entry price - ATR × stop multiplier OR high >= entry price + ATR × partial target multiplier for each of two configured partial quantities OR high >= entry price + ATR × full target multiplier for the remaining quantity); both partial targets use the same partial target multiplier.
Exit: Short, before closing time AND partial ATR mode is selected AND (high >= entry price + ATR × stop multiplier OR low <= entry price - ATR × partial target multiplier for each of two configured partial quantities OR low <= entry price - ATR × full target multiplier for the remaining quantity); both partial targets use the same partial target multiplier.
Exit: Long, before closing time AND trailing mode is selected AND price has reached the configured absolute activation price AND low <= highest price since activation - configured trailing offset in minimum price ticks.
Exit: Short, before closing time AND trailing mode is selected AND high >= entry price + configured trailing distance in price units.
Exit: Long, before closing time AND moving-average mode is selected AND low <= trend moving average.
Exit: Short, before closing time AND moving-average mode is selected AND high >= trend moving average.
Exit: Long, before closing time AND scalp mode is selected AND (low <= entry price - configured stop distance OR high >= entry price + configured target distance).
Exit: Short, before closing time AND scalp mode is selected AND (high >= entry price + configured stop distance OR low <= entry price - configured target distance).
Exit: Long, before closing time AND pre-market multiplier mode is selected AND (low <= pre-market high - (pre-market high - pre-market low) × range multiplier OR high >= entry price + ATR × full target multiplier).
Exit: Short, before closing time AND pre-market multiplier mode is selected AND (high >= pre-market low + (pre-market high - pre-market low) × range multiplier OR low <= entry price - ATR × full target multiplier).