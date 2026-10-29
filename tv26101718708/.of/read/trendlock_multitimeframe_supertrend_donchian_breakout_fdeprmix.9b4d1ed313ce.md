Calculation: Donchian upper = highest high over a lookback, excluding the current bar
Calculation: Donchian lower = lowest low over a lookback, excluding the current bar
Calculation: Supertrend direction = Supertrend using an ATR lookback and factor
Calculation: Higher-timeframe Supertrend direction = Supertrend using the same ATR lookback and factor on a higher timeframe, using the bar still forming
Calculation: Volume average = simple moving average of volume
Calculation: Risk ATR = ATR
Long: long trades enabled AND Supertrend direction is bullish AND (higher-timeframe filter disabled OR higher-timeframe Supertrend direction is bullish) AND close > Donchian lower AND (volume filter disabled OR volume > volume average × volume multiplier) AND position side is flat or short
Short: short trades enabled AND Supertrend direction is bearish AND (higher-timeframe filter disabled OR higher-timeframe Supertrend direction is bearish) AND close < Donchian lower AND (volume filter disabled OR volume > volume average × volume multiplier) AND position side is flat or long
Exit: long, low <= entry price − Risk ATR at entry × stop multiplier OR high >= entry price + Risk ATR at entry × target multiplier OR trend-flip exit enabled AND Supertrend direction is bearish
Exit: short, high >= entry price + Risk ATR at entry × stop multiplier OR low <= entry price − Risk ATR at entry × target multiplier OR trend-flip exit enabled AND Supertrend direction is bullish