Calculation: Higher-high reversal = low > low[1] AND high > high[1] AND close > high[1]
Calculation: Lower-low reversal = low < low[1] AND high < high[1] AND close < low[1]
Calculation: Long stop = low[1] on the long-entry bar
Calculation: Long target = upper Bollinger band when high >= Bollinger basis on the long-entry bar, otherwise Bollinger basis on the long-entry bar
Calculation: Short stop = high[1] on the short-entry bar
Calculation: Short target = lower Bollinger band when low <= Bollinger basis on the short-entry bar, otherwise Bollinger basis on the short-entry bar
Long: On a completed chart bar, high[1] < Bollinger lower band[1] AND close > Bollinger lower band AND close < Bollinger upper band AND Higher-high reversal AND RSI(source, lookback) crosses above the oversold threshold AND EMA(close, shorter lookback) < EMA(close, longer lookback)
Short: On a completed chart bar, low[1] > Bollinger upper band[1] AND close < Bollinger upper band AND close > Bollinger lower band AND Lower-low reversal AND RSI(source, lookback) crosses below the overbought threshold AND EMA(close, shorter lookback) > EMA(close, longer lookback)
Exit: long, close >= Long target OR close <= Long stop OR end of day for markets that close
Exit: short, close <= Short target OR close >= Short stop OR end of day for markets that close