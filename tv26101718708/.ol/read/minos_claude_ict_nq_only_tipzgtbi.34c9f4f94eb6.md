Calculation: Bullish FVG = current low > high two bars earlier; its zone spans the two-bars-earlier high to the current low
Calculation: Bearish FVG = current high < low two bars earlier; its zone spans the current high to the two-bars-earlier low
Calculation: Bullish FVG tap = current low <= the top of any previously created bullish FVG zone AND current close >= its bottom
Calculation: Bearish FVG tap = current high >= the bottom of any previously created bearish FVG zone AND current close <= its top
Calculation: Confirmed pivot high/low = a high/low greater/less than the highs/lows of the same number of bars on both sides; use the latest confirmed pivot
Calculation: Bullish BOS = current close > latest confirmed pivot high AND previous close <= that pivot high
Calculation: Bearish BOS = current close < latest confirmed pivot low AND previous close >= that pivot low
Calculation: Bullish order block = the nearest preceding bearish candle at a bullish BOS; its zone is that candle's low to high and remains the stored bullish order block until replaced at a later bullish BOS
Calculation: Bearish order block = the nearest preceding bullish candle at a bearish BOS; its zone is that candle's low to high and remains the stored bearish order block until replaced at a later bearish BOS
Calculation: Bullish order block retest = current low <= stored bullish order block high AND current close >= its low AND current close > previous close
Calculation: Bearish order block retest = current high >= stored bearish order block low AND current close <= its high AND current close < previous close
Calculation: Equal highs = two adjacent completed bars on the configured higher timeframe have highs whose absolute difference divided by the earlier high is less than the configured threshold
Calculation: Equal lows = two adjacent completed bars on the configured higher timeframe have lows whose absolute difference divided by the earlier low is less than the configured threshold
Long: Bullish BOS OR bullish FVG tap OR bullish order block retest OR current high > the higher of an equal-high pair AND current close < that level
Short: Bearish BOS OR bearish FVG tap OR bearish order block retest OR current low < the lower of an equal-low pair AND current close > that level