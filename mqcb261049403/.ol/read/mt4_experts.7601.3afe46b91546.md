Calculation: CCI = commodity channel index on a higher-timeframe bar that is still forming
Calculation: Longer-lookback EMA = EMA of median price on a higher timeframe, using the last completed bar; its preceding value is from the prior completed bar
Calculation: Shorter-lookback EMA = EMA of median price on a higher timeframe, using the bar still forming; its preceding value is from the last completed bar
Long: Longer-lookback EMA > its preceding value AND shorter-lookback EMA > its preceding value AND CCI < its configured lower threshold
Short: Longer-lookback EMA < its preceding value AND shorter-lookback EMA < its preceding value AND CCI > its configured upper threshold
Exit: long, Longer-lookback EMA <= its preceding value OR current close - entry price > configured stop distance
Exit: short, Longer-lookback EMA >= its preceding value OR entry price - current close > configured stop distance