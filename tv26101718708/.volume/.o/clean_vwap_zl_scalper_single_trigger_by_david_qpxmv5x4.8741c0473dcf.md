Calculation: Zero-lag EMA = EMA of source + (source − source lagged by floor((length − 1) / 2))
Calculation: Stop distance = ATR × stop multiple
Calculation: Target distance = stop distance × reward-to-risk ratio
Long: close > Zero-lag EMA AND close > VWAP AND (low <= VWAP OR low <= Zero-lag EMA) AND close > open AND close >= previous bar open
Short: close < Zero-lag EMA AND close < VWAP AND (high >= VWAP OR high >= Zero-lag EMA) AND close < open AND close <= previous bar open
Exit: long, low <= entry price − Stop distance OR high >= entry price + Target distance OR short-entry conditions
Exit: short, high >= entry price + Stop distance OR low <= entry price − Target distance OR long-entry conditions