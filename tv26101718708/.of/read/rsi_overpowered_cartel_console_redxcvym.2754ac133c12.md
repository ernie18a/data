Calculation: PVI = cumulative index starting at a constant; each bar, if volume > previous volume, multiply the previous value by close/previous close, else carry it forward
Calculation: NVI = same as PVI but the update applies when volume < previous volume
Calculation: OBV = cumulative sum of +volume if close > previous close, -volume if close < previous close, else 0
Calculation: Composite = average of RSI(PVI), RSI(NVI), RSI(OBV), all with the same RSI length
Calculation: Smooth = EMA(Composite)
Calculation: Osc = EMA(RSI(Composite, same RSI length)), with an EMA length shorter than the Smooth EMA length
Calculation: Supertrend = standard Supertrend (ATR-multiplier based) on the chart timeframe; bullish trend = price above the Supertrend line (uptrend direction), bearish trend = price below it (downtrend direction)
Calculation: Smooth pivot high/low = Smooth is the highest/lowest over a symmetric window of L bars to the left and R bars to the right of the pivot bar; it is confirmed and acted on at the bar R bars after the pivot bar
Long: Osc crosses above the lower level (previous bar Osc <= lower level, current Osc > lower level) AND Supertrend trend is bullish
Long: Smooth crosses to at or below the lower level (Smooth <= lower level AND previous Smooth > lower level)
Long: bullish divergence, evaluated on the bar where a Smooth pivot low is confirmed: Smooth at the pivot bar <= lower level AND a previous Smooth pivot low that also had Smooth <= lower level exists AND the distance between the two pivot bars <= a maximum bar count AND the pivot bar's low < the previous pivot bar's low AND Smooth at the pivot bar > Smooth at the previous pivot bar
Short: Osc crosses below the upper level (previous bar Osc >= upper level, current Osc < upper level) AND Supertrend trend is bearish
Short: Smooth crosses to at or above the upper level (Smooth >= upper level AND previous Smooth < upper level)
Short: bearish divergence, evaluated on the bar where a Smooth pivot high is confirmed: Smooth at the pivot bar >= upper level AND a previous Smooth pivot high that also had Smooth >= upper level exists AND the distance between the two pivot bars <= a maximum bar count AND the pivot bar's high > the previous pivot bar's high AND Smooth at the pivot bar < Smooth at the previous pivot bar