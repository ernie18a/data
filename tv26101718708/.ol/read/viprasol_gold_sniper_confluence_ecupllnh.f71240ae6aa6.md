Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA
Calculation: Bull score = count of these conditions: close > VWAP; RSI(14) > 50; MACD line > signal line; fast EMA > slow EMA; ADX(14) > 25 AND close > fast EMA; volume > 20-bar volume SMA AND close > open; RSI(14) on the configured confirmation timeframe > 50
Calculation: Bear score = count of these conditions: close < VWAP; RSI(14) < 50; MACD line < signal line; fast EMA < slow EMA; ADX(14) > 25 AND close < fast EMA; volume > 20-bar volume SMA AND close < open; RSI(14) on the configured confirmation timeframe < 50
Calculation: Confirmation-timeframe RSI = RSI(14) on a timeframe configured relative to the chart timeframe (higher or lower); use its current bar value, which may still be forming
Calculation: Average daily range = simple moving average of daily high minus daily low over a lookback of completed daily bars; daily timeframe is higher than an intraday chart
Calculation: Today's range = running high minus running low for the current day, accumulated from chart bars
Calculation: Stop distance = ATR multiplied by a configurable factor
Calculation: Long stop = entry price - stop distance
Calculation: Short stop = entry price + stop distance
Calculation: Long target at level n = entry price + n × stop distance; short target at level n = entry price - n × stop distance, for each enabled level from 1 to 3
Long: Fast EMA crosses above slow EMA on a confirmed chart bar AND bull score ≥ minimum score AND (session filter is off OR chart timeframe is daily or higher OR time is within the configured London or New York session) AND (ADR filter is off OR chart timeframe is weekly or monthly OR today's range / average daily range × 100 < configured block threshold) AND (no prior entry OR chart bars since prior entry ≥ configured minimum gap)
Short: Fast EMA crosses below slow EMA on a confirmed chart bar AND bear score ≥ minimum score AND (session filter is off OR chart timeframe is daily or higher OR time is within the configured London or New York session) AND (ADR filter is off OR chart timeframe is weekly or monthly OR today's range / average daily range × 100 < configured block threshold) AND (no prior entry OR chart bars since prior entry ≥ configured minimum gap)
Exit: long, after the entry bar, low ≤ long stop; after target 1 has been touched, use entry price as the stop
Exit: short, after the entry bar, high ≥ short stop; after target 1 has been touched, use entry price as the stop
Exit: long, after the entry bar, high ≥ the highest enabled long target
Exit: short, after the entry bar, low ≤ the lowest enabled short target