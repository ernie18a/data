Calculation: Displacement candle = absolute difference between close and open exceeds the simple moving average of that absolute difference times a threshold
Calculation: High volume = volume exceeds its simple moving average times a sensitivity multiplier
Calculation: Bullish FVG = low > high two bars ago AND low - high two bars ago exceeds ATR times a gap threshold
Calculation: Bearish FVG = high < low two bars ago AND low two bars ago - high exceeds ATR times a gap threshold
Calculation: Confirmed swing high/low = a pivot high/low confirmed after the required bars to its right have completed
Calculation: Current bullish trend = close crosses above the latest confirmed pivot high; current bearish trend = close crosses below the latest confirmed pivot low
Long: low < lowest low over the range lookback bars AND close > that range low AND close > open AND absolute close-open exceeds ATR times a body threshold AND high volume AND within the permitted session
Long: close > open AND close > previous bar's high AND displacement candle AND high volume AND close > the higher-timeframe EMA of close on its last completed bar AND within the permitted session AND bullish FVG
Long: previous bar is bearish AND close > previous bar's high AND close > open AND close-open exceeds ATR times an impulse threshold AND close > the higher-timeframe EMA of close on its last completed bar AND high volume AND bullish order block
Long: low < the latest confirmed swing low AND close > that swing low
Long: close crosses above the latest confirmed pivot low AND close on the previous bar was at or below that pivot low
Long: bullish trend AND close crosses above the latest confirmed pivot high AND close on the previous bar was at or below that pivot high AND displacement candle AND close > previous bar's high AND high volume
Long: current confirmed pivot low is higher than the previous confirmed pivot low
Short: high > the range high from the manipulation lookback bars ago AND close < that range high AND close < open AND absolute close-open exceeds ATR times a body threshold AND high volume AND within the permitted session
Short: high > the latest confirmed swing high AND close < that swing high
Short: close < open AND close < previous bar's low AND displacement candle AND high volume AND close < the higher-timeframe EMA of close on its last completed bar AND within the permitted session AND bearish FVG
Short: previous bar is bullish AND close < previous bar's low AND close < open AND open-close exceeds ATR times an impulse threshold AND close < the higher-timeframe EMA of close on its last completed bar AND high volume AND bearish order block
Short: close crosses below the latest confirmed pivot low AND close on the previous bar was at or above that pivot low
Short: bearish trend AND close crosses below the latest confirmed pivot low AND close on the previous bar was at or above that pivot low AND displacement candle AND close < previous bar's low AND high volume
Short: current confirmed pivot high is higher than the previous confirmed pivot high