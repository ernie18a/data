Calculation: Upper breakout rail = highest high over the lookback bars ending on the previous completed chart bar
Calculation: Lower breakout rail = lowest low over the lookback bars ending on the previous completed chart bar
Calculation: Long stop = maximum of the initial stop (entry price minus ATR at entry × initial-stop multiplier) and the prior stop and highest high since entry minus current ATR × trail multiplier
Calculation: Short stop = minimum of the initial stop (entry price plus ATR at entry × initial-stop multiplier) and the prior stop and lowest low since entry plus current ATR × trail multiplier
Long: On a completed chart bar, close crosses above the upper breakout rail AND close > EMA AND EMA > its value at the slope lookback AND (higher-timeframe confirmation is disabled OR chart close > EMA from the last completed higher-timeframe bar)
Short: On a completed chart bar, close crosses below the lower breakout rail AND close < EMA AND EMA < its value at the slope lookback AND (higher-timeframe confirmation is disabled OR chart close < EMA from the last completed higher-timeframe bar)
Exit: long, low <= long stop
Exit: short, high >= short stop