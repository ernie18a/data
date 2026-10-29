Calculation: Asia range high/low = highest high/lowest low during the Asia session, reset at each Asia session start
Calculation: Bullish displacement = close > open AND absolute(close - open) > ATR
Calculation: Bearish displacement = close < open AND absolute(close - open) > ATR
Calculation: Bullish FVG = current low > high two bars earlier
Calculation: Bearish FVG = current high < low two bars earlier
Long: During the London session AND the first sweep since that session began was low < Asia range low (if both range edges are swept on the same bar, this sweep takes precedence) AND no trade has yet been taken this session AND close > low of the preceding bar AND bullish displacement AND bullish FVG AND higher-timeframe close > its 20-period SMA, using the last completed higher-timeframe bar
Short: During the London session AND the first sweep since that session began was high > Asia range high AND no trade has yet been taken this session AND high of the preceding bar > close AND bearish displacement AND bearish FVG AND higher-timeframe close < its 20-period SMA, using the last completed higher-timeframe bar
Exit: Long, low <= the low of the bar preceding entry OR high >= entry price + (entry price - the low of the bar preceding entry) × reward/risk multiple
Exit: Short, high >= the high of the bar preceding entry OR low <= entry price - (the high of the bar preceding entry - entry price) × reward/risk multiple