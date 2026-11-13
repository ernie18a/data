Calculation: CMF = sum over a lookback of (((close-low)-(high-close))/(high-low) * volume) divided by sum of volume over the same lookback; the multiplier is 0 when high equals low
Calculation: CMF_MA = simple moving average of CMF, with a lookback shorter than the CMF lookback
Calculation: POC = session VWAP of close * (1 + small factor * CMF)
Long: pivot low is confirmed on this bar, i.e. the low of the bar R bars ago is lower than the lows of the L bars before it and the R bars after it (L = left span, R = right span, R bars of delay)
Short: pivot high is confirmed on this bar, i.e. the high of the bar R bars ago is higher than the highs of the L bars before it and the R bars after it (L = left span, R = right span, R bars of delay)
Long: CMF > 0 AND CMF > CMF_MA
Short: CMF < -T_small AND CMF < CMF_MA
Long: CMF < -T_extreme (oversold; T_extreme > T_zone > T_small)
Short: CMF > T_extreme (overbought)
Long: CMF > T_zone (strong zone)
Short: CMF < -T_zone (weak zone)
Long: close > POC
Short: close < POC