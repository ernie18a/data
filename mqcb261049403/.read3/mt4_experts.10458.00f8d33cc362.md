Calculation: recent AO sum = Awesome Oscillator[0] + Awesome Oscillator[1]
Calculation: older AO sum = Awesome Oscillator[2] + Awesome Oscillator[3]
Calculation: MFI midpoint = (upper MFI threshold + lower MFI threshold) / 2
Long: Moving Average(close, shorter lookback, configurable method)[shift parameter] > SMA(close, longer lookback)[shift parameter]
Short: Moving Average(close, shorter lookback, configurable method)[shift parameter] < SMA(close, longer lookback)[shift parameter]
Long: Stochastic main line(low/high price, %K lookback, %D lookback, slowing, LWMA)[1] > Stochastic signal line(low/high price, %K lookback, %D lookback, slowing, LWMA)[1] AND Stochastic signal line(low/high price, %K lookback, %D lookback, slowing, LWMA)[1] < lower threshold
Short: Stochastic main line(low/high price, %K lookback, %D lookback, slowing, LWMA)[1] < Stochastic signal line(low/high price, %K lookback, %D lookback, slowing, LWMA)[1] AND Stochastic signal line(low/high price, %K lookback, %D lookback, slowing, LWMA)[1] > upper threshold
Long: recent AO sum > older AO sum
Short: recent AO sum < older AO sum
Long: upper Fractals line[0] < close[0]
Short: lower Fractals line[0] > close[0]
Long: (AC[0] >= 0 AND AC[0] > AC[1] AND AC[1] > AC[2]) OR (AC[0] <= 0 AND AC[0] > AC[1] AND AC[1] > AC[2] AND AC[2] > AC[3])
Short: (AC[0] <= 0 AND AC[0] < AC[1] AND AC[1] < AC[2]) OR (AC[0] >= 0 AND AC[0] < AC[1] AND AC[1] < AC[2] AND AC[2] < AC[3])
Long: DeMarker(lookback)[1] < lower threshold
Short: DeMarker(lookback)[1] > upper threshold
Long: CCI((high + low) / 2, lookback)[0] > CCI((high + low) / 2, lookback)[1] AND CCI((high + low) / 2, lookback)[1] < CCI((high + low) / 2, lookback)[2]
Short: CCI((high + low) / 2, lookback)[0] < CCI((high + low) / 2, lookback)[1] AND CCI((high + low) / 2, lookback)[1] > CCI((high + low) / 2, lookback)[2]
Long: RSI(open, lookback)[0] > upper threshold
Short: RSI(open, lookback)[0] < lower threshold
Long: MFI(lookback)[0] > upper threshold
Short: MFI(lookback)[0] < lower threshold
Long: Williams %R(lookback)[shift parameter] > upper threshold
Short: Williams %R(lookback)[0] < lower threshold
Long: MACD signal line(open, configured fast/slow/signal lookbacks)[0] > MACD signal line(open, separate reference fast/slow/signal lookbacks)[1]
Short: MACD signal line(open, configured fast/slow/signal lookbacks)[0] < MACD signal line(open, separate reference fast/slow/signal lookbacks)[1]
Long: OsMA(open, configured fast/slow/signal lookbacks)[0] > MACD signal line(open, separate reference fast/slow/signal lookbacks)[1]
Short: OsMA(open, configured fast/slow/signal lookbacks)[0] < MACD signal line(open, separate reference fast/slow/signal lookbacks)[1]
Long: ADX(lookback)[0] > upper threshold
Short: ADX(lookback)[0] < lower threshold
Long: Parabolic SAR(step, maximum step)[0] > close[0]
Short: Parabolic SAR(step, maximum step)[0] < close[0]
Long: StochasticStack output > close[0]
Short: StochasticStack output(custom parameter 1, custom parameter 2) < close[0]
Long: Parabolic_ZZ output > close[0]
Short: Parabolic_ZZ output < close[0]
Long: ZigZag output > close[0]
Short: ZigZag output < close[0]
Exit: long, CCI((high + low) / 2, lookback)[1] < -level
Exit: short, CCI((high + low) / 2, lookback)[1] > level
Exit: long, MFI(lookback)[0] < MFI midpoint
Exit: short, MFI(lookback)[0] > MFI midpoint
Exit: short, Williams %R(lookback)[0] > upper threshold
Exit: long, MACD signal line(open, configured fast/slow/signal lookbacks)[0] < MACD signal line(open, configured fast/slow/signal lookbacks)[1]
Exit: short, MACD signal line(open, configured fast/slow/signal lookbacks)[0] > MACD signal line(open, configured fast/slow/signal lookbacks)[1]
Exit: long, OsMA(open, configured fast/slow/signal lookbacks)[0] < MACD signal line(open, configured fast/slow/signal lookbacks)[1]
Exit: short, OsMA(open, configured fast/slow/signal lookbacks)[0] > MACD signal line(open, configured fast/slow/signal lookbacks)[1]
Exit: long, StochasticStack output > close[0]
Exit: short, StochasticStack output < close[0]
Exit: long, Parabolic_ZZ output > close[0]
Exit: short, Parabolic_ZZ output < close[0]
Exit: long, ZigZag output > close[0]
Exit: short, ZigZag output < close[0]