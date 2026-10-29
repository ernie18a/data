Calculation: WaveTrend WT1 = EMA of (hlc3 − EMA(hlc3, channel lookback)) / (0.015 × EMA(abs(hlc3 − EMA(hlc3, channel lookback)), channel lookback)); WT2 = SMA(WT1, shorter lookback). Use requested-timeframe bars for each timeframe above or below the chart timeframe; use the current requested-timeframe value, which may still be forming.
Calculation: DI delta = DI+ − DI−. ADX is rising when its current value is greater than its value several bars earlier, and falling when it is lower. Use requested-timeframe bars for each timeframe above or below the chart timeframe; use the current requested-timeframe value, which may still be forming.
Calculation: Extended move = close − lowest low over a lookback exceeds a multiple of ATR; otherwise the move is Normal.
Long: 1H close > 1H EMA AND 1H DI delta > 0 AND 1H ADX rising AND at least 2 of the 1H, 30m, and 5m WaveTrend pairs have WT1 > WT2 AND move is Normal
Short: 1H close < 1H EMA AND 1H DI delta < 0 AND 1H ADX falling AND at least 2 of the 1H, 30m, and 5m WaveTrend pairs have WT1 < WT2 AND move is Normal
Long: RSI status is Oversold or Bullish
Short: RSI status is Overbought or Bearish
Exit: ,