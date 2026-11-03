Long: close > 20-period exponential moving average
Short: close <= 20-period exponential moving average
Long: close > 50-period exponential moving average
Short: close <= 50-period exponential moving average
Long: close > 100-period exponential moving average
Short: close <= 100-period exponential moving average
Long: close > 200-period exponential moving average
Short: close <= 200-period exponential moving average
Long: RSI <= 30
Short: RSI >= 70
Long: close <= lower Bollinger Band
Short: close >= upper Bollinger Band
Long: close > VWAP
Short: close <= VWAP
Calculation: Supertrend direction = use ATR-based basic bands at hl2 plus/minus the ATR multiplier; carry the upper band forward as max(current lower band, prior upper band) when prior close exceeds prior upper band, otherwise use current lower band; carry the lower band forward as min(current upper band, prior lower band) when prior close is below prior lower band, otherwise use current upper band; flip direction from bearish to bullish when close exceeds the carried lower band, and from bullish to bearish when close falls below the carried upper band; otherwise retain prior direction, initially bullish
Long: Supertrend direction is bullish
Short: Supertrend direction is bearish
Calculation: OBV MACD direction = cumulative signed volume using the sign of close change; form a synthetic price by adding (OBV minus its 14-bar SMA) divided by its 28-bar standard deviation, multiplied by the 28-bar standard deviation of high minus low, to high when this adjustment is positive and to low otherwise (use zero adjustment when the first standard deviation is zero); subtract the 26-period EMA of close from the 9-period DEMA of this synthetic price; filter this difference by updating a carried value to the difference only when it exceeds the prior carried value plus or minus the cumulative average absolute difference from the prior carried value (otherwise retain the prior carried value); direction is the sign of the filtered value's change, retaining the prior nonzero direction when unchanged and initially zero
Long: OBV MACD direction = bullish
Short: OBV MACD direction is not bullish