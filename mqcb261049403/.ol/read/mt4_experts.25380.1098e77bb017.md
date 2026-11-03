Calculation: Fast and slow LWMA = linear weighted moving averages of typical price on the chart timeframe's forming bar; fast lookback is shorter than slow lookback
Calculation: MACD = MACD line and signal line on the chart timeframe's last completed bar and a higher timeframe's last completed bar, using the same parameters on both timeframes
Calculation: Long trailing stop = highest of the existing stop and the lowest low among the preceding X completed chart bars minus a padding distance
Calculation: Short trailing stop = lowest of the existing stop and the highest high among chart bars from 2 through X+1 bars ago plus a padding distance
Long: fast LWMA < slow LWMA AND MACD line > signal line on both timeframes AND low[2] < high[1] AND abs(current bar open - close[2]) > retrace distance
Short: fast LWMA < slow LWMA AND MACD line < signal line on both timeframes AND low[1] < high[2] AND abs(current bar open - close[1]) > retrace distance
Exit: long, close <= active stop-loss OR close >= entry price + take-profit distance
Exit: short, close >= active stop-loss OR close <= entry price - take-profit distance