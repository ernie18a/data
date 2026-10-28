Calculation: Confirmed swing high/low = a high/low pivot confirmed using the same left- and right-bar lookback; retain the latest two of each.
Calculation: Bullish RSI divergence = latest confirmed price swing low is below the prior swing low and RSI at the latest low is above RSI at the prior low.
Calculation: Bearish RSI divergence = latest confirmed price swing high is above the prior swing high and RSI at the latest high is below RSI at the prior high.
Calculation: Bullish squeeze momentum = 20-bar linear regression of close minus the average of the 20-bar highest high/lowest low midpoint and 20-bar average close; use Bollinger Bands (20, 1.5 standard deviations) inside EMA(20) ± 1.5 ATR(20) to identify squeeze bars.
Calculation: Bullish CHoCH = the latest two confirmed swing highs form a lower high, the latest two confirmed swing lows form a lower low, and close exceeds the latest swing high.
Calculation: Bearish CHoCH = the latest two confirmed swing highs form a higher high, the latest two confirmed swing lows form a higher low, and close is below the latest swing low.
Long: Bullish RSI divergence
Short: Bearish RSI divergence
Long: Bullish CHoCH is true and was false on the prior bar AND relative volume meets its display threshold AND the bar is outside the Asia session
Short: Bearish CHoCH is true and was false on the prior bar AND relative volume meets its display threshold AND the bar is outside the Asia session
Long: The squeeze was on during the prior bar and is off now AND bullish squeeze momentum is above zero
Short: The squeeze was on during the prior bar and is off now AND bullish squeeze momentum is below zero
Long: Bullish squeeze momentum crosses above zero AND its absolute value exceeds the display threshold AND relative volume meets its display threshold AND the bar is outside the Asia session
Short: Bullish squeeze momentum crosses below zero AND its absolute value exceeds the display threshold AND relative volume meets its display threshold AND the bar is outside the Asia session