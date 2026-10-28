Calculation: Volume EMA oscillator = 100 × (shorter-lookback EMA of volume − longer-lookback EMA of volume) / longer-lookback EMA of volume
Calculation: Long take-profit = signal-bar close + (signal-bar close − signal-bar PSAR); long stop-loss = signal-bar close − (signal-bar close − signal-bar PSAR)
Calculation: Short take-profit = signal-bar close − (signal-bar PSAR − signal-bar close); short stop-loss = signal-bar close + (signal-bar PSAR − signal-bar close)
Long: previous bar MACD histogram < 0 AND current MACD histogram > 0 AND close > 200-period EMA AND PSAR is in an uptrend AND volume EMA oscillator < 0
Short: previous bar MACD histogram > 0 AND current MACD histogram < 0 AND close < 200-period EMA AND PSAR is in a downtrend AND volume EMA oscillator > 0
Exit: long, close crosses above long take-profit OR high crosses above long take-profit OR close crosses below long stop-loss OR low crosses below long stop-loss OR Short condition
Exit: short, close crosses below short take-profit OR low crosses below short take-profit OR close crosses above short stop-loss OR high crosses above short stop-loss OR Long condition