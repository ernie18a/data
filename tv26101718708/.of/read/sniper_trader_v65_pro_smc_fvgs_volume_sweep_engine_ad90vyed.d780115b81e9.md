Calculation: Candle delta = volume on an up candle, negative volume on a down candle, and zero on a doji; cumulative delta resets at each session reset and otherwise adds candle delta
Calculation: Bullish divergence = current low below the latest confirmed pivot low AND current cumulative delta above cumulative delta at that pivot low
Calculation: Bearish divergence = current high above the latest confirmed pivot high AND current cumulative delta below cumulative delta at that pivot high
Long: Bullish divergence is true now AND was false on the prior bar
Short: Bearish divergence is true now AND was false on the prior bar
Calculation: Bullish divergence zone = from the trigger bar's low to the lower of its open and close
Calculation: Bearish divergence zone = from the higher of the trigger bar's open and close to the trigger bar's high
Long: At least the configured minimum number of bars have elapsed since a bullish divergence zone formed AND low <= the zone's upper bound AND close > its lower bound AND close > open AND lower wick / (high - low) >= 0.3 AND upper wick / (high - low) <= 0.6 AND the trade window is open
Short: At least the configured minimum number of bars have elapsed since a bearish divergence zone formed AND high >= the zone's lower bound AND close < the zone's upper bound AND close < open AND upper wick / (high - low) >= 0.3 AND lower wick / (high - low) <= 0.6 AND the trade window is open
Long: Close > the lower bound of an active bearish divergence zone AND close > the simple moving average of close AND the trade window is open
Short: Close < the upper bound of an active bullish divergence zone AND close < the simple moving average of close AND the trade window is open
Calculation: Bullish fair value gap = current low - high two bars ago; bearish fair value gap = low two bars ago - current high
Long: Bullish fair value gap > 0 AND (volume one bar ago > its 20-bar simple moving average one bar ago × volume multiplier) AND (bullish fair value gap > ATR(14) one bar ago × ATR multiplier) AND candle delta one bar ago > 0
Short: Bearish fair value gap > 0 AND (volume one bar ago > its 20-bar simple moving average one bar ago × volume multiplier) AND (bearish fair value gap > ATR(14) one bar ago × ATR multiplier) AND candle delta one bar ago < 0
Calculation: Anchored VWAP = cumulative volume-weighted average of HLC3 since the selected session, day, week, or month anchor
Long: Close > anchored VWAP AND anchored VWAP > its value about 15 minutes earlier AND close >= close about 1 hour earlier × 1.001
Short: Close < anchored VWAP AND anchored VWAP < its value about 15 minutes earlier AND close <= close about 1 hour earlier × 0.999
Calculation: Timeframe candle momentum = 1 when its close > its open, -1 when its close < its open, and 0 otherwise; use the current bar, including the still-forming bar, on each listed timeframe
Long: Weighted sum of positive candle momentum across 1D, 4H, 2H, 1H, 30m, 15m, 10m, 5m, and 1m timeframes > weighted sum of negative candle momentum across those timeframes; weights are respectively 15, 15, 15, 15, 10, 10, 10, 5, and 5
Short: Weighted sum of negative candle momentum across 1D, 4H, 2H, 1H, 30m, 15m, 10m, 5m, and 1m timeframes > weighted sum of positive candle momentum across those timeframes; weights are respectively 15, 15, 15, 15, 10, 10, 10, 5, and 5
Exit: Long, close <= stop price OR high >= any active target price OR bars since breakout entry > maximum trade duration
Exit: Short, close >= stop price OR low <= any active target price OR bars since breakout entry > maximum trade duration