Long: Shorter-period moving average of close > longer-period simple moving average of close at the selected bar offset
Short: Shorter-period moving average of close < longer-period simple moving average of close at the selected bar offset
Exit: short, shorter-period moving average of close > longer-period simple moving average of close at the selected bar offset
Exit: long, shorter-period moving average of close < longer-period simple moving average of close at the selected bar offset
Long: Stochastic main line > signal line AND signal line < lower threshold, on the last completed bar
Short: Stochastic main line < signal line AND signal line > upper threshold, on the last completed bar
Exit: short, stochastic main line > signal line AND signal line < lower threshold, on the last completed bar
Exit: long, stochastic main line < signal line AND signal line > upper threshold, on the last completed bar
Long: Awesome Oscillator on the current bar + Awesome Oscillator on the previous bar > Awesome Oscillator two bars ago + Awesome Oscillator three bars ago
Short: Awesome Oscillator on the current bar + Awesome Oscillator on the previous bar < Awesome Oscillator two bars ago + Awesome Oscillator three bars ago
Exit: short, Awesome Oscillator on the current bar + Awesome Oscillator on the previous bar > Awesome Oscillator two bars ago + Awesome Oscillator three bars ago
Exit: long, Awesome Oscillator on the current bar + Awesome Oscillator on the previous bar < Awesome Oscillator two bars ago + Awesome Oscillator three bars ago
Calculation: Accelerator Oscillator at offset n = Awesome Oscillator at offset n minus its simple moving average at offset n
Long: Accelerator Oscillator on the current bar > its value on the previous bar AND its value on the previous bar > its value two bars ago AND (its value on the current bar >= 0 OR its value on the current bar <= 0 AND its value two bars ago > its value three bars ago)
Short: Accelerator Oscillator on the current bar < its value on the previous bar AND its value on the previous bar < its value two bars ago AND (its value on the current bar <= 0 OR its value on the current bar >= 0 AND its value two bars ago < its value three bars ago)
Exit: short, Accelerator Oscillator on the current bar > its value on the previous bar AND its value on the previous bar > its value two bars ago AND (its value on the current bar >= 0 OR its value on the current bar <= 0 AND its value two bars ago > its value three bars ago)
Exit: long, Accelerator Oscillator on the current bar < its value on the previous bar AND its value on the previous bar < its value two bars ago AND (its value on the current bar <= 0 OR its value on the current bar >= 0 AND its value two bars ago < its value three bars ago)
Long: DeMarker on the last completed bar < lower threshold
Short: DeMarker on the last completed bar > upper threshold
Exit: short, DeMarker on the last completed bar < lower threshold
Exit: long, DeMarker on the last completed bar > upper threshold
Long: CCI of median price on the current bar > CCI on the previous bar AND CCI on the previous bar < CCI two bars ago
Short: CCI of median price on the current bar < CCI on the previous bar AND CCI on the previous bar > CCI two bars ago
Exit: short, CCI of median price on the last completed bar < negative threshold
Exit: long, CCI of median price on the last completed bar > positive threshold
Long: RSI of open on the current bar > upper threshold
Short: RSI of open on the current bar < lower threshold
Exit: short, RSI of open on the current bar > upper threshold
Exit: long, RSI of open on the current bar < lower threshold
Long: Money Flow Index on the current bar > upper threshold
Short: Money Flow Index on the current bar < lower threshold
Exit: short, Money Flow Index on the current bar > (upper threshold + lower threshold) / 2
Exit: long, Money Flow Index on the current bar < (upper threshold + lower threshold) / 2
Long: Williams Percent Range at the selected bar offset > upper threshold
Short: Williams Percent Range on the current bar < lower threshold
Exit: short, Williams Percent Range on the current bar > upper threshold
Exit: long, Williams Percent Range on the current bar < lower threshold
Long: MACD signal line of open on the current bar > MACD signal line of open on the previous bar with independently selected parameters
Short: MACD signal line of open on the current bar < MACD signal line of open on the previous bar with independently selected parameters
Long: MACD histogram of open on the current bar > MACD signal line of open on the previous bar with independently selected parameters
Short: MACD histogram of open on the current bar < MACD signal line of open on the previous bar with independently selected parameters
Exit: short, MACD signal line of open on the current bar > MACD signal line of open on the previous bar with the same parameters
Exit: long, MACD signal line of open on the current bar < MACD signal line of open on the previous bar with the same parameters
Exit: short, MACD histogram of open on the current bar > MACD signal line of open on the previous bar with the same parameters
Exit: long, MACD histogram of open on the current bar < MACD signal line of open on the previous bar with the same parameters
Long: ADX main line on the current bar > upper threshold
Short: ADX main line on the current bar < lower threshold
Exit: short, ADX main line on the current bar > upper threshold
Exit: long, ADX main line on the current bar < lower threshold
Long: Parabolic SAR on the current bar > current close
Short: Parabolic SAR on the current bar < current close
Exit: short, Parabolic SAR on the current bar > current close
Exit: long, Parabolic SAR on the current bar < current close
Exit: long, low <= entry price - stop distance OR high >= entry price + profit distance
Exit: short, high >= entry price + stop distance OR low <= entry price - profit distance