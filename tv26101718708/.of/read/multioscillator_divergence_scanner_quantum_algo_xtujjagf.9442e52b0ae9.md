Calculation: Oscillators = RSI of close; MACD histogram of close with shorter and longer EMA lengths and a signal EMA length; SMA-smoothed stochastic of close, high, and low; CCI of typical price; OBV; MFI of typical price and volume; and momentum of close.
Calculation: Confirmed pivot low or high = a low or high that is a pivot over independently specified left and right lookbacks; evaluate it at the close of its confirmation bar. Compare each pivot with the immediately preceding confirmed pivot of the same type, using oscillator values on the pivot bars.
Calculation: Divergence pressure = previous divergence pressure multiplied by a decay factor, plus the number of enabled oscillators contributing to each enabled, minimum-confluence bullish divergence confirmed on the current bar, minus the corresponding number for bearish divergences; initialize to zero.
Long: A pivot low is confirmed AND its low < the previous pivot low AND at least one enabled oscillator at the new pivot > its value at the previous pivot.
Long: A pivot low is confirmed AND its low > the previous pivot low AND at least one enabled oscillator at the new pivot < its value at the previous pivot.
Short: A pivot high is confirmed AND its high > the previous pivot high AND at least one enabled oscillator at the new pivot < its value at the previous pivot.
Short: A pivot high is confirmed AND its high < the previous pivot high AND at least one enabled oscillator at the new pivot > its value at the previous pivot.
Long: Enabled RSI <= its oversold threshold OR enabled smoothed stochastic <= its oversold threshold OR enabled CCI <= its oversold threshold OR enabled MFI <= its oversold threshold.
Short: Enabled RSI >= its overbought threshold OR enabled smoothed stochastic >= its overbought threshold OR enabled CCI >= its overbought threshold OR enabled MFI >= its overbought threshold.
Long: Enabled MACD histogram > zero OR enabled momentum > zero OR enabled OBV > its SMA.
Short: Enabled MACD histogram < zero OR enabled momentum < zero OR enabled OBV <= its SMA.
Long: Divergence pressure > zero AND rounded absolute divergence pressure divided by a scaling parameter > zero.
Short: Divergence pressure < zero AND rounded absolute divergence pressure divided by a scaling parameter > zero.