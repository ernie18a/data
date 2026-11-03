Calculation: Pivot high = a bar whose high is higher than the highs of the preceding and following pivot-strength bars
Calculation: Pivot low = a bar whose low is lower than the lows of the preceding and following pivot-strength bars
Calculation: Bullish FVG = low > high two bars earlier AND gap size >= ATR * minimum-gap multiplier; remains active until close < its lower boundary
Calculation: Bearish FVG = high < low two bars earlier AND gap size >= ATR * minimum-gap multiplier; remains active until close > its upper boundary
Calculation: Bullish order block = the nearest bearish candle within the lookback before a bullish break; its zone is that candle's low-to-high range and remains active until close < its low
Calculation: Bearish order block = the nearest bullish candle within the lookback before a bearish break; its zone is that candle's low-to-high range and remains active until close > its high
Calculation: Demand zone = most recent confirmed pivot-low zone from a higher timeframe, using the last completed higher-timeframe bar; zone spans the pivot bar's low to the higher of its open and close
Calculation: Supply zone = most recent confirmed pivot-high zone from a higher timeframe, using the last completed higher-timeframe bar; zone spans the lower of its open and close to the pivot bar's high
Calculation: Bullish break = close > latest pivot high AND previous close <= latest pivot high
Calculation: Bearish break = close < latest pivot low AND previous close >= latest pivot low
Long: confirmed pivot high > previous pivot high OR confirmed pivot low > previous pivot low OR bullish break OR (bullish FVG active AND low <= its midpoint AND close > its midpoint) OR (bullish order block active AND low <= its high AND close > its low) OR (demand zone exists AND low <= its top AND close > its bottom) OR (bullish break after bearish trend) OR (bearish FVG active AND close > its upper boundary)
Short: confirmed pivot high < previous pivot high OR confirmed pivot low < previous pivot low OR bearish break OR (bearish FVG active AND high >= its midpoint AND close < its midpoint) OR (bearish order block active AND high >= its low AND close < its high) OR (supply zone exists AND high >= its bottom AND close < its top) OR (bearish break after bullish trend) OR (bullish FVG active AND close < its lower boundary)
Exit: long, close <= entry price - ATR * stop multiplier OR close >= entry price + ATR * target multiplier OR short condition
Exit: short, close >= entry price + ATR * stop multiplier OR close <= entry price - ATR * target multiplier OR long condition