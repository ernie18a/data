Calculation: Stochastic %K and %D = standard Stochastic oscillator calculated from high and low.
Calculation: Fast and slow RSI = RSI of typical price, with the fast lookback shorter than the slow lookback.
Calculation: Entry and trend CCI = CCI of typical price, with the entry lookback shorter than the trend lookback.
Calculation: Evaluate each enabled timeframe; aggregate bars from the input data when that timeframe is higher or lower than the chart timeframe. Use the selected candle, which may be the last completed bar or the bar still forming.
Long: Stochastic %K > %D
Short: Stochastic %K < %D
Long: Fast RSI > slow RSI
Short: Fast RSI < slow RSI
Long: CCI > 0 AND CCI > its value on the prior bar, OR CCI < 0 AND CCI >= its value on the prior bar
Short: CCI > 0 AND CCI <= its value on the prior bar, OR CCI < 0 AND CCI < its value on the prior bar
Long: All four indicators signal long on the same timeframe
Short: All four indicators signal short on the same timeframe