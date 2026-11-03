Calculation: Recent low = lowest low over the lookback ending on the previous chart bar.
Calculation: Recent high = highest high over the lookback ending on the previous chart bar.
Calculation: Signal cooldown = number of chart bars since the most recent long or short sweep signal; it passes if no such signal exists or if the count is at least the cooldown threshold.
Calculation: Long sweep signal = low < recent low AND close > recent low AND close > open AND (chart trend filter disabled OR previous chart bar close > its close SMA) AND (higher-timeframe trend filter disabled OR last completed higher-timeframe close > its close SMA) AND (volatility filter disabled OR ATR / close >= volatility threshold) AND (volume filter disabled OR volume >= volume SMA × volume multiplier) AND (cooldown disabled OR signal cooldown passes).
Calculation: Short sweep signal = high > recent high AND close < recent high AND close < open AND (chart trend filter disabled OR previous chart bar close < its close SMA) AND (higher-timeframe trend filter disabled OR last completed higher-timeframe close < its close SMA) AND (volatility filter disabled OR ATR / close >= volatility threshold) AND (volume filter disabled OR volume >= volume SMA × volume multiplier) AND (cooldown disabled OR signal cooldown passes).
Calculation: Signal risk distance = signal-bar close − (signal-bar low − signal-bar ATR × stop multiplier) for a long sweep signal, or (signal-bar high + signal-bar ATR × stop multiplier) − signal-bar close for a short sweep signal. Retain the most recent sweep signal's side, close and risk distance until another sweep signal occurs.
Calculation: Target = most recent sweep signal's close plus its risk distance × target multiplier for a long signal, or minus its risk distance × target multiplier for a short signal. Calculate three targets using independently configurable multipliers.
Long: Long sweep signal = true.
Short: Short sweep signal = true.
Long: Last completed higher-timeframe close > its close SMA.
Short: Last completed higher-timeframe close < its close SMA.
Exit: long, short sweep signal = true.
Exit: short, long sweep signal = true.
Exit: long, most recent sweep signal side = long AND high >= any of its three targets.
Exit: short, most recent sweep signal side = short AND low <= any of its three targets.