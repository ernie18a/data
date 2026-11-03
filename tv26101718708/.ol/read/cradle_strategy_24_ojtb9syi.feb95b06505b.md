Calculation: Short- and medium-term EMAs = exponential moving averages of close, with the short-term EMA using a shorter lookback; higher-timeframe EMAs use the same respective lookbacks on the last completed bar of a timeframe higher than the chart timeframe
Calculation: Small candle = absolute(close − open) ≤ (high − low) × configurable maximum body fraction OR high = low
Calculation: Long stop = lower of setup-bar low and medium-term EMA
Calculation: Long target = entry price + (entry price − long stop) × reward/risk ratio
Calculation: Short stop = higher of setup-bar high and medium-term EMA
Calculation: Short target = entry price − (short stop − entry price) × reward/risk ratio
Long: short-term EMA > medium-term EMA AND higher-timeframe short-term EMA > higher-timeframe medium-term EMA AND low ≤ short-term EMA AND close > medium-term EMA AND small candle AND MACD line > signal line; set entry price to setup-bar high and enter when high ≥ entry price while close ≥ medium-term EMA
Short: short-term EMA < medium-term EMA AND higher-timeframe short-term EMA < higher-timeframe medium-term EMA AND high ≥ short-term EMA AND close < medium-term EMA AND small candle AND MACD line < signal line; set entry price to setup-bar low and enter when low ≤ entry price while close ≤ medium-term EMA
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target