Calculation: Daily VWMA = volume-weighted moving average of the daily close of the percentage of SPX stocks above their 200-day moving average, using a longer lookback; use the current higher-timeframe bar, which may still be forming
Calculation: Direction state = +1 when the Daily VWMA is rising over a shorter lookback, -1 when it is falling over that lookback, otherwise carry forward the previous state
Long: Direction state > 0 AND previous Direction state < 0
Short: Direction state < 0 AND previous Direction state > 0
Exit: long, Direction state < 0 AND previous Direction state > 0