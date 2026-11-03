Calculation: Confirmed pivot high or low = a high or low that is extreme over an equal number of preceding and subsequent bars, available only after the subsequent bars have completed. Use separate lookbacks for sweeps and changes of character.
Calculation: Bullish gap = current low > high two bars ago AND their difference >= a minimum price distance; its top is current low and its bottom is that earlier high. Bearish gap = current high < low two bars ago AND their difference >= a minimum price distance; its top is that earlier low and its bottom is current high. Retain at most a configured number of the most recent gaps per original direction. A bullish gap becomes inverted when close < its bottom and is removed on a later bar when high > its top. A bearish gap becomes inverted when close > its top and is removed on a later bar when low < its bottom.
Calculation: Change-of-character direction = initially neutral; set to bullish when close > the latest confirmed change-of-character pivot high and direction is not bullish; set to bearish when close < the latest confirmed change-of-character pivot low and direction is not bearish. Update pivots before testing breaks, and test the bullish break before the bearish break.
Long: Low < latest confirmed sweep pivot low AND close > that pivot low AND (min(open, close) - low) / max(high - low, minimum range) > a wick fraction.
Short: High > latest confirmed sweep pivot high AND close < that pivot high AND (high - max(open, close)) / max(high - low, minimum range) > a wick fraction.
Long: Close > previous close AND previous close > close two bars ago AND the last consecutive-close signal was not long AND the number of bars since the last consecutive-close signal >= a minimum, or there was no previous signal.
Short: Close < previous close AND previous close < close two bars ago AND the last consecutive-close signal was not short AND the number of bars since the last consecutive-close signal >= a minimum, or there was no previous signal.
Long: A bullish gap forms.
Short: A bearish gap forms.
Long: Close > the top of a retained, non-inverted bearish gap.
Short: Close < the bottom of a retained, non-inverted bullish gap.
Long: Close > latest confirmed change-of-character pivot high AND the previous change-of-character direction is not bullish.
Short: Close < latest confirmed change-of-character pivot low AND the direction after testing the bullish break is not bearish.
Long: Close > previous high AND close - open > ATR multiplied by a threshold.
Short: Close < previous low AND open - close > ATR multiplied by a threshold.