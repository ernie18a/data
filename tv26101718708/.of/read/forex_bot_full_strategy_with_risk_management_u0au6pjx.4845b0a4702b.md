Calculation: Volume oscillator = 100 × (short-term EMA(volume) − long-term EMA(volume)) / long-term EMA(volume)
Long: MACD histogram on the previous bar < 0 AND MACD histogram on the current bar > 0 AND close > EMA(close) AND Volume oscillator < 0 AND PSAR trend is up
Short: MACD histogram on the previous bar > 0 AND MACD histogram on the current bar < 0 AND close < EMA(close) AND Volume oscillator > 0 AND PSAR trend is down
Calculation: Long take-profit = signal-bar close + (signal-bar close − PSAR)
Calculation: Long stop-loss = signal-bar close − (signal-bar close − PSAR)
Calculation: Short take-profit = signal-bar close − (PSAR − signal-bar close)
Calculation: Short stop-loss = signal-bar close + (PSAR − signal-bar close)
Exit: long, close or high crosses above Long take-profit OR close or low crosses below Long stop-loss OR Short condition
Exit: short, close or low crosses below Short take-profit OR close or high crosses above Short stop-loss OR Long condition