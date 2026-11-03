Calculation: Opening range high = highest high during the configured opening-range window
Calculation: Opening range low = lowest low during the configured opening-range window
Calculation: Opening range size = opening range high - opening range low
Calculation: Volume average = simple moving average of volume over a configurable lookback
Long: Opening range is locked AND opening range size is within configured minimum and maximum multiples of ATR AND after the opening-range window and before end-of-day cutoff AND close > opening range high AND volume > volume average × configured multiplier AND no long entry has fired this session AND daily loss limit is not exceeded AND position is flat
Long: A long breakout has initiated a retest opportunity AND within the configured bar limit after that breakout AND close > opening range high AND low <= opening range high × configured touch tolerance
Short: Opening range is locked AND opening range size is within configured minimum and maximum multiples of ATR AND after the opening-range window and before end-of-day cutoff AND close < opening range low AND volume > volume average × configured multiplier AND no short entry has fired this session AND daily loss limit is not exceeded AND position is flat
Short: A short breakout has initiated a retest opportunity AND within the configured bar limit after that breakout AND close < opening range low AND high >= opening range low × configured touch tolerance
Exit: long, high >= first profit target OR low <= stop price OR end-of-day cutoff reached OR daily loss limit exceeded
Exit: long, after first profit target is reached, high >= second profit target OR low <= stop price
Exit: short, low <= first profit target OR high >= stop price OR end-of-day cutoff reached OR daily loss limit exceeded
Exit: short, after first profit target is reached, low <= second profit target OR high >= stop price