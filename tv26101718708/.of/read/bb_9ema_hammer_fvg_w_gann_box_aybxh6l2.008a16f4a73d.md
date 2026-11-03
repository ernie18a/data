Calculation: Hammer = high - fraction * (high - low) < min(open, close)
Calculation: Shooting star = low + fraction * (high - low) > max(open, close)
Calculation: Bullish gap size = low - high two bars ago if low >= high two bars ago, otherwise 0
Calculation: Bearish gap size = low two bars ago - high if low two bars ago >= high, otherwise 0
Calculation: Confirmed pivot high or low = a pivot high or low with equal-length left and right lookbacks, available on the confirming bar; compare each pivot with the preceding pivot of the same kind
Calculation: Unbroken pivot high or low = the latest confirmed pivot of that kind, available for one break until replaced by another confirmed pivot; process a newly confirmed pivot before checking for a break
Calculation: Up fractal = high one bar ago > current high AND, among the bars preceding that high, one of the next one to five older highs is strictly lower while every intervening high is less than or equal to it
Calculation: Down fractal = low one bar ago < current low AND, among the bars preceding that low, one of the next one to five older lows is strictly higher while every intervening low is greater than or equal to it
Long: Hammer on the current bar when next-bar confirmation is disabled
Long: Hammer on the previous bar AND close > open on the current bar when next-bar confirmation is enabled
Short: Shooting star on the current bar when next-bar confirmation is disabled
Short: Shooting star on the previous bar AND close < open on the current bar when next-bar confirmation is enabled
Long: high > previous high AND low >= previous low AND close >= previous close
Short: high > previous high AND low >= previous low AND close < previous close
Short: low < previous low AND high <= previous high AND close <= previous close
Long: low < previous low AND high <= previous high AND close > previous close
Long: bullish gap size > minimum gap size
Short: bullish gap size <= minimum gap size AND bearish gap size > minimum gap size
Long: a new higher-timeframe bar begins AND the last completed higher-timeframe bar's bullish gap size > higher-timeframe minimum gap size
Short: a new higher-timeframe bar begins AND the last completed higher-timeframe bar's bullish gap size <= higher-timeframe minimum gap size AND its bearish gap size > higher-timeframe minimum gap size
Long: confirmed pivot high >= preceding pivot high OR confirmed pivot low >= preceding pivot low
Short: confirmed pivot high < preceding pivot high OR confirmed pivot low < preceding pivot low OR a confirmed pivot high or low has no preceding pivot of the same kind
Long: close > unbroken pivot high, or high > unbroken pivot high when high/low break detection is selected
Short: close < unbroken pivot low, or low < unbroken pivot low when high/low break detection is selected
Long: up fractal
Short: down fractal