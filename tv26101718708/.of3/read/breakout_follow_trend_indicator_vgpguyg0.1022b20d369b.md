Calculation: Trading hour window = hour >= start hour AND hour < end hour when start hour < end hour; otherwise hour >= start hour OR hour < end hour
Calculation: Stop distance = ATR(lookback) at entry * stop multiplier
Calculation: Target distance = Stop distance * risk-reward ratio
Long: (EMA trend filter disabled OR close > EMA(close, lookback)) AND close crosses above upper Bollinger Band(close, lookback, deviation) AND (volume filter disabled OR volume > SMA(volume, lookback)) AND Trading hour window
Short: (EMA trend filter disabled OR close < EMA(close, lookback)) AND close crosses below lower Bollinger Band(close, lookback, deviation) AND (volume filter disabled OR volume > SMA(volume, lookback)) AND Trading hour window
Exit: long, high >= entry price + Target distance OR low <= entry price - Stop distance
Exit: short, low <= entry price - Target distance OR high >= entry price + Stop distance