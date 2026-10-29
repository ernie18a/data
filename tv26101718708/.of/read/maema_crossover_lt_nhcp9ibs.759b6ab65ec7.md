Calculation: Higher-timeframe SMA = simple moving average of HLC3 over a longer lookback, using the still-forming higher-timeframe bar with lookahead enabled
Calculation: Higher-timeframe EMA = exponential moving average of HLC3 over a shorter lookback than the SMA, using the still-forming higher-timeframe bar with lookahead enabled
Calculation: Upper dynamic zone = nearest-rank percentile of chart-timeframe close over a lookback
Calculation: Lower dynamic zone = nearest-rank percentile of chart-timeframe close over the same lookback as the upper dynamic zone
Calculation: Entry price = average of open, high, low, and close on the entry bar
Calculation: Long stop level = upper dynamic zone or higher-timeframe SMA, whichever is higher, when dynamic-zone stops are enabled; otherwise EMA minus a configurable ATR-based offset
Calculation: Short stop level = lower dynamic zone or higher-timeframe SMA, whichever is lower, when dynamic-zone stops are enabled; otherwise EMA plus a configurable ATR-based offset
Calculation: Long profit level = the higher of entry price increased by a configurable percentage and higher-timeframe SMA plus a configurable ATR multiple
Calculation: Short profit level = the lower of entry price decreased by a configurable percentage and higher-timeframe SMA minus a configurable ATR multiple
Long: Previous chart bar's higher-timeframe SMA > higher-timeframe EMA AND higher-timeframe EMA crosses above higher-timeframe SMA; OR previous chart bar's higher-timeframe SMA is not greater than higher-timeframe EMA AND the absolute difference between higher-timeframe SMA and EMA divided by higher-timeframe SMA exceeds a configurable threshold AND chart close crosses above higher-timeframe EMA
Short: Previous chart bar's higher-timeframe SMA < higher-timeframe EMA AND higher-timeframe EMA crosses below higher-timeframe SMA; OR previous chart bar's higher-timeframe SMA is not less than higher-timeframe EMA AND the absolute difference between higher-timeframe SMA and EMA divided by higher-timeframe SMA exceeds a configurable threshold AND chart close crosses below higher-timeframe EMA
Exit: Long, OHLC4 < long stop level OR chart high > long profit level OR short-entry condition
Exit: Short, OHLC4 > short stop level OR chart low < short profit level OR long-entry condition