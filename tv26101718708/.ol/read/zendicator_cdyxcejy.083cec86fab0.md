Calculation: Current higher-timeframe close = close of the higher-timeframe bar still forming
Calculation: Prior higher-timeframe close = close of the prior completed higher-timeframe bar
Calculation: Hull moving average = WMA(2 × WMA(close, shorter lookback of about half the longer lookback) − WMA(close, longer lookback), lookback of about the square root of the longer lookback)
Long: Current higher-timeframe close > prior higher-timeframe close AND current Hull moving average > Hull moving average from 2 chart bars earlier
Short: Current higher-timeframe close < prior higher-timeframe close AND current Hull moving average < Hull moving average from 2 chart bars earlier
Exit: long, Current higher-timeframe close < prior higher-timeframe close AND Hull moving average from 2 chart bars earlier > current Hull moving average AND open profit > take-profit threshold
Exit: short, Current higher-timeframe close > prior higher-timeframe close AND current Hull moving average > Hull moving average from 2 chart bars earlier AND open profit > take-profit threshold