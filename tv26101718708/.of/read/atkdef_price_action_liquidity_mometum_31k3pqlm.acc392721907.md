Calculation: Body strength = (close - open) / (high - low), or 0 when high equals low.
Calculation: Body proportion = abs(close - open) / (high - low), or 0 when high equals low.
Calculation: Momentum index = a weighted average of RSI of close and RSI of volume, using the same lookback and a greater weight for price RSI.
Long: Body strength > 0.
Short: Body strength <= 0.
Long: Body proportion of either of the two preceding bars >= the doji threshold AND body strength of that bar > 0.
Short: Body proportion of either of the two preceding bars >= the doji threshold AND body strength of that bar <= 0.
Long: Chaikin Money Flow > the positive inflow threshold.
Short: Chaikin Money Flow < the negative outflow threshold.
Long: Momentum index < the oversold threshold OR (momentum index > the midpoint AND momentum index <= the overbought threshold).
Short: Momentum index > the overbought threshold OR (momentum index >= the oversold threshold AND momentum index <= the midpoint).
Long: Momentum index < the oversold threshold AND Chaikin Money Flow < 0.
Short: Momentum index > the overbought threshold AND Chaikin Money Flow > 0.
Long: Chaikin Money Flow > 0 AND body strength > 0 AND momentum index <= the overbought threshold.
Short: Chaikin Money Flow < 0 AND body strength < 0 AND momentum index >= the oversold threshold.