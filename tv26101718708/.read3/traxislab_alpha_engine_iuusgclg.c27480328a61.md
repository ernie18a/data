Calculation: Volume-weighted momentum oscillator = SuperSmoother of the normalized cumulative momentum over the momentum lookback, smoothed over the smoothing lookback; cumulative momentum is the sum over the momentum lookback of (close - prior close) * (volume / SMA(volume, momentum lookback)), using a unit volume ratio when that SMA is zero; normalize using the highest and lowest cumulative momentum over the normalization lookback, using the oscillator midpoint when their range is zero
Calculation: HMA slope = (HMA(close, HMA lookback) - prior HMA) / ATR(ATR lookback), or close multiplied by an ATR fallback fraction when ATR is unavailable, multiplied by the percentage scaling factor
Calculation: Squeeze = ATR(ATR lookback) / SMA(ATR(ATR lookback), long-term baseline lookback) < squeeze threshold
Calculation: Bullish squeeze breakout = Squeeze on the prior bar AND NOT Squeeze AND HMA slope > minimum slope
Calculation: Bearish squeeze breakout = Squeeze on the prior bar AND NOT Squeeze AND HMA slope < -minimum slope
Calculation: Trend state = initialize neutral; set neutral when neither slope threshold is exceeded; set bullish when HMA slope > minimum slope and (prior state is not bearish OR bullish squeeze breakout); set bearish when HMA slope < -minimum slope and (prior state is not bullish OR bearish squeeze breakout); otherwise set neutral
Calculation: Dynamic upper oscillator band = SMA(volume-weighted momentum oscillator, zone lookback) + standard deviation(volume-weighted momentum oscillator, zone lookback) * dynamic band width
Calculation: Dynamic lower oscillator band = SMA(volume-weighted momentum oscillator, zone lookback) - standard deviation(volume-weighted momentum oscillator, zone lookback) * dynamic band width
Calculation: Overbought zone = fixed zones are enabled AND volume-weighted momentum oscillator > overbought level, OR dynamic zones are enabled AND volume-weighted momentum oscillator > dynamic upper oscillator band
Calculation: Oversold zone = fixed zones are enabled AND volume-weighted momentum oscillator < oversold level, OR dynamic zones are enabled AND volume-weighted momentum oscillator < dynamic lower oscillator band
Long: Trend state is bullish
Short: Trend state is bearish
Long: Volume-weighted momentum oscillator > its midpoint
Short: Volume-weighted momentum oscillator <= its midpoint
Long: Bullish squeeze breakout
Short: Bearish squeeze breakout
Long: Oversold zone AND NOT Oversold zone on the prior bar
Short: Overbought zone AND NOT Overbought zone on the prior bar
Long: Volume-weighted momentum oscillator crosses above the fixed oversold level when fixed zones are enabled OR crosses above the dynamic lower oscillator band when dynamic zones are enabled
Short: Volume-weighted momentum oscillator crosses below the fixed overbought level when fixed zones are enabled OR crosses below the dynamic upper oscillator band when dynamic zones are enabled
Long: Confluence is enabled AND (Trend state is bullish OR bullish squeeze breakout) AND (volume-weighted momentum oscillator crosses above the fixed oversold level when fixed zones are enabled OR crosses above the dynamic lower oscillator band when dynamic zones are enabled OR (volume-weighted momentum oscillator > its midpoint AND > its prior value AND NOT Overbought zone)) AND close > HMA(close, HMA lookback) AND more than the cooldown parameter in chart bars has elapsed since the prior confluence signal in either direction
Short: Confluence is enabled AND (Trend state is bearish OR bearish squeeze breakout) AND (volume-weighted momentum oscillator crosses below the fixed overbought level when fixed zones are enabled OR crosses below the dynamic upper oscillator band when dynamic zones are enabled OR (volume-weighted momentum oscillator < its midpoint AND < its prior value AND NOT Oversold zone)) AND close < HMA(close, HMA lookback) AND more than the cooldown parameter in chart bars has elapsed since the prior confluence signal in either direction