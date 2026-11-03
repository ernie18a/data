Calculation: Fast LWMA = linear weighted moving average of typical price (high + low + close) / 3, using a shorter lookback than the slow LWMA, on a higher timeframe’s still-forming bar
Calculation: Slow LWMA = linear weighted moving average of typical price (high + low + close) / 3, using a longer lookback than the fast LWMA, on a higher timeframe’s still-forming bar
Calculation: Lower Bollinger Band = lower band of Bollinger Bands, on the chart timeframe using the last completed bar
Calculation: Short-period EMA group alignment = the 3-, 5-, 8-, 10-, 12-, and 15-period exponential moving averages of typical price are all equal, on the chart timeframe’s still-forming bar
Calculation: Long-period EMA group alignment = the 30-, 35-, 40-, 45-, 50-, and 60-period exponential moving averages of typical price are all equal, on the chart timeframe’s still-forming bar
Long: Fast LWMA > Slow LWMA AND low two bars ago < high one bar ago AND absolute difference between current price and close two bars ago > the configured retracement distance in points
Short: Fast LWMA < Slow LWMA AND low one bar ago < high two bars ago
Exit: long, price reaches the stop-loss or take-profit level set at entry
Exit: short, price reaches the stop-loss or take-profit level set at entry
Exit: long, short-period EMA group alignment OR long-period EMA group alignment OR close one bar ago <= Lower Bollinger Band
Exit: short, short-period EMA group alignment OR long-period EMA group alignment OR close one bar ago <= Lower Bollinger Band