Calculation: CCI = (hlc3 − its simple moving average) / (0.015 × mean absolute deviation of hlc3 from that average), over the same lookback.
Calculation: CCI slope = the one-bar change in CCI, optionally EMA-smoothed.
Calculation: Momentum histogram = CCI − its smoothing average; FADE means the histogram is shrinking, and SURGE means it is growing.
Calculation: CCI volatility ratio = current CCI range over a shorter lookback divided by the average of that range over a longer lookback; expanded means the ratio meets or exceeds its expansion threshold.
Calculation: Bullish regular divergence = price makes a lower pivot low while CCI makes a higher pivot low; bearish regular divergence = price makes a higher pivot high while CCI makes a lower pivot high. Both CCI pivots must exceed the applicable absolute CCI threshold, and the pivots must be within the applicable maximum bar span. Hidden bullish divergence = price makes a lower pivot high while CCI makes a higher pivot high; hidden bearish divergence = price makes a higher pivot low while CCI makes a lower pivot low. Fast divergence uses shorter pivot lookback and maximum span than slow divergence; slow divergence uses a higher absolute CCI threshold.
Calculation: CCI absorption = CCI is above the positive extreme threshold or below the negative extreme threshold, and absolute CCI slope divided by its highest value over the lookback crosses below the decay threshold.
Long: CCI forms a confirmed pivot valley below the negative minimum level AND CCI slope crosses above zero
Long: Bullish regular fast divergence AND CCI slope crosses above zero
Long: Bullish regular slow divergence AND CCI slope crosses above zero AND momentum histogram is FADE
Long: Bullish hidden fast divergence OR bullish hidden slow divergence
Long: Bullish fast and slow regular divergences occur within the confluence window
Long: CCI absorption below the negative extreme threshold AND momentum histogram is FADE
Long: Momentum histogram is SURGE AND CCI slope is positive and stronger than its threshold AND CCI volatility ratio is expanded
Short: CCI forms a confirmed pivot peak above the positive minimum level AND CCI slope crosses below zero
Short: Bearish regular fast divergence AND CCI slope crosses below zero
Short: Bearish regular slow divergence AND CCI slope crosses below zero AND momentum histogram is FADE
Short: Bearish hidden fast divergence OR bearish hidden slow divergence
Short: Bearish fast and slow regular divergences occur within the confluence window
Short: CCI absorption above the positive extreme threshold AND momentum histogram is FADE
Short: Momentum histogram is SURGE AND CCI slope is negative and stronger than its threshold AND CCI volatility ratio is expanded
Exit: long, bearish regular slow divergence
Exit: short, bullish regular slow divergence
Exit: long, momentum histogram is FADE AND CCI absorption is above the positive extreme threshold
Exit: short, momentum histogram is FADE AND CCI absorption is below the negative extreme threshold
Exit: long, momentum histogram is FADE AND CCI slope is not stronger than its threshold AND absolute CCI exceeds the extreme regime threshold
Exit: short, momentum histogram is FADE AND CCI slope is not stronger than its threshold AND absolute CCI exceeds the extreme regime threshold
Exit: long, CCI is above the positive deep-extreme threshold AND CCI slope is negative and stronger than twice its threshold
Exit: short, CCI is below the negative deep-extreme threshold AND CCI slope is positive and stronger than twice its threshold