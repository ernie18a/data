Calculation: Risk distance = ATR at entry × stop multiplier
Calculation: Take-profit distance = risk distance × risk/reward ratio
Long: close > EMA AND close > upper Bollinger Band AND previous close <= previous upper Bollinger Band AND volume > volume moving average AND ((start hour < end hour AND start hour <= hour < end hour) OR (start hour >= end hour AND (hour >= start hour OR hour < end hour)))
Short: close < EMA AND close < lower Bollinger Band AND previous close >= previous lower Bollinger Band AND volume > volume moving average AND ((start hour < end hour AND start hour <= hour < end hour) OR (start hour >= end hour AND (hour >= start hour OR hour < end hour)))
Exit: long, high >= entry price + take-profit distance OR low <= entry price - risk distance
Exit: short, low <= entry price - take-profit distance OR high >= entry price + risk distance