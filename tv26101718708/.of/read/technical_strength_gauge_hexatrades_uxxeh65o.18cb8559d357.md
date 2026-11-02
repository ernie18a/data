Calculation: Analysis data = chart-timeframe bars, or bars aggregated to a selected higher or lower timeframe. On historical chart bars, higher-timeframe calculations use the last completed higher-timeframe bar and lower-timeframe calculations use the last available completed lower-timeframe bar. On a forming chart bar, calculations may use the forming analysis bar; if close confirmation is enabled, use the preceding chart bar's readings until the chart bar closes.
Calculation: Oscillator reversal vote = +1 when the oscillator is below its oversold threshold and above its previous value; -1 when it is above its overbought threshold and below its previous value; otherwise 0. Apply separately to RSI, CCI, Williams %R, MFI, Ultimate Oscillator, smoothed Stochastic RSI, and CMO. Use symmetric thresholds around zero for CCI and CMO.
Calculation: Smoothed Stochastic RSI = SMA of the stochastic oscillator calculated with RSI as its high, low, and close inputs.
Calculation: Fisher Transform = recursively smooth the position of midpoint price within its rolling highest-to-lowest range, clamp the result between negative and positive limits, apply the logarithmic Fisher transform, and recursively smooth the transformed value.
Calculation: Ichimoku conversion, base, and second span = midpoints of rolling high and low using respectively short, intermediate, and long lookbacks; first span = average of conversion and base. Use undisplaced spans.
Calculation: Vortex components = rolling sums of abs(high - previous low) and abs(low - previous high); their common denominator is the rolling sum of true range.
Calculation: Individual votes = +1 for each corresponding Long condition and -1 for each corresponding Short condition below, otherwise 0; the moving-average conditions produce one vote per family and length. If both conditions apply, use +1. Exclude MFI and volume-weighted moving-average votes when volume is unavailable.
Calculation: Leading rating = weighted average of enabled RSI, Stochastic, CCI, Williams %R, MFI, ROC, Momentum, Ultimate Oscillator, Awesome Oscillator, Bollinger midpoint, Donchian midpoint, Aroon, Stochastic RSI, TSI, Fisher Transform, and CMO votes. Lagging rating = weighted average of enabled MACD histogram, all moving-average, Supertrend, ADX, Ichimoku, Parabolic SAR, linear regression, Vortex, and DMI votes. Assign configurable weights by oscillator, moving-average, and trend category; Bollinger, Donchian, and Aroon use the trend weight, and MACD uses the oscillator weight. Exclude disabled, unavailable, and zero-weight votes from the denominator; an empty group has rating 0. Summary rating = average of leading and lagging ratings.
Calculation: Trend bias = average of five components: Supertrend direction as +1 or -1; close above both undisplaced Ichimoku spans as +1, below both as -1, otherwise 0; the sign of +DI minus -DI using a configurable deadband; the sign of moving-average alignment using the same deadband; and the sign of the change in linear-regression value using the same deadband. Moving-average alignment = twice the fraction of true comparisons among close > shortest EMA, shortest EMA > next EMA, next EMA > next longer EMA, and that EMA > longest EMA, minus 1.
Long: RSI OR CCI OR Williams %R OR MFI OR Ultimate Oscillator OR smoothed Stochastic RSI OR CMO has an oscillator reversal vote of +1.
Short: RSI OR CCI OR Williams %R OR MFI OR Ultimate Oscillator OR smoothed Stochastic RSI OR CMO has an oscillator reversal vote of -1.
Long: Smoothed Stochastic K and its SMA signal are both below the oversold threshold AND K crosses above its signal.
Short: Smoothed Stochastic K and its SMA signal are both above the overbought threshold AND K crosses below its signal.
Long: MACD histogram > 0 AND MACD histogram > previous histogram.
Short: MACD histogram < 0 AND MACD histogram < previous histogram.
Long: ROC > 0.
Short: ROC < 0.
Long: Momentum > previous Momentum.
Short: Momentum < previous Momentum.
Long: Awesome Oscillator crosses above 0 OR Awesome Oscillator > 0 AND its previous value < both its current value and its value two bars ago.
Short: Awesome Oscillator crosses below 0 OR Awesome Oscillator < 0 AND its previous value > both its current value and its value two bars ago.
Long: Close > EMA, SMA, VWMA, WMA, HMA, RMA, ALMA, DEMA, TEMA, or KAMA, evaluated separately at each of five configurable moving-average lengths.
Short: Close < EMA, SMA, VWMA, WMA, HMA, RMA, ALMA, DEMA, TEMA, or KAMA, evaluated separately at each of five configurable moving-average lengths.
Long: Supertrend indicates an uptrend.
Short: Supertrend indicates a downtrend.
Long: ADX > threshold AND +DI > -DI.
Short: ADX > threshold AND +DI < -DI.
Long: Ichimoku first span > second span AND close > first span AND close > base AND conversion > base AND close > conversion.
Short: Ichimoku first span < second span AND close < second span AND close < base AND conversion < base AND close < conversion.
Long: Close > Parabolic SAR.
Short: Close < Parabolic SAR.
Long: Close > Bollinger Bands middle line.
Short: Close < Bollinger Bands middle line.
Long: Close > Donchian channel midpoint.
Short: Close < Donchian channel midpoint.
Long: Aroon Up > Aroon Down.
Short: Aroon Up < Aroon Down.
Long: Linear-regression value > previous linear-regression value.
Short: Linear-regression value < previous linear-regression value.
Long: Vortex true-range sum != 0 AND positive Vortex component > negative Vortex component.
Short: Vortex true-range sum != 0 AND positive Vortex component < negative Vortex component.
Long: +DI > -DI.
Short: +DI < -DI.
Long: TSI > its EMA signal AND TSI > previous TSI.
Short: TSI < its EMA signal AND TSI < previous TSI.
Long: Fisher Transform > 0 AND Fisher Transform > previous Fisher Transform.
Short: Fisher Transform < 0 AND Fisher Transform < previous Fisher Transform.
Long: Leading rating OR lagging rating OR summary rating >= positive verdict threshold.
Short: Leading rating OR lagging rating OR summary rating <= negative verdict threshold.
Long: Summary rating crosses above a positive normal or stronger trigger threshold AND the optional ADX filter is disabled or ADX >= its minimum threshold.
Short: Summary rating crosses below a negative normal or stronger trigger threshold AND the optional ADX filter is disabled or ADX >= its minimum threshold.
Long: ADX >= sideways threshold AND trend bias > positive regime threshold.
Short: ADX >= sideways threshold AND trend bias < negative regime threshold.