Calculation: Heikin-Ashi close = close of the Heikin-Ashi transformed bar
Calculation: FastMA = EMA of Heikin-Ashi close with a shorter lookback, computed on bars of a higher timeframe than the chart, using the higher-timeframe bar still forming (it updates with each chart bar)
Calculation: SlowMA = same as FastMA but with a longer lookback than FastMA
Calculation: Dist = absolute value of (FastMA - SlowMA)
Calculation: ATR1 = Average True Range on chart-timeframe bars; ATR2 = Average True Range on chart-timeframe bars (its lookback may differ from ATR1)
Long: FastMA crosses above SlowMA on this bar (previous FastMA <= previous SlowMA AND current FastMA > current SlowMA) AND Dist / ATR1 >= a small fraction threshold (not a squeeze) AND Dist > a multiplier * ATR2 AND the bar is on a weekday and its time of day is inside the regular daytime trading session window
Short: FastMA crosses below SlowMA on this bar (previous FastMA >= previous SlowMA AND current FastMA < current SlowMA) AND Dist / ATR1 >= a small fraction threshold (not a squeeze) AND Dist > a multiplier * ATR2 AND the bar is on a weekday and its time of day is inside the regular daytime trading session window
Exit: long, high >= entry price + take-profit multiplier * ATR1 at entry OR low <= entry price - stop-loss multiplier * ATR1 at entry (take-profit multiplier larger than stop-loss multiplier)
Exit: short, low <= entry price - take-profit multiplier * ATR1 at entry OR high >= entry price + stop-loss multiplier * ATR1 at entry (take-profit multiplier larger than stop-loss multiplier)