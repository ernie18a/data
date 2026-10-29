Calculation: Mid = selected HMA, EMA, or SMA of close
Calculation: Bandwidth = weighted sum of standard deviation of close, ATR, and absolute difference between VWMA of close and SMA of close using the same lookback
Calculation: Upper band = Mid + Bandwidth
Calculation: Lower band = Mid − Bandwidth
Long: close > Upper band AND volume > SMA(volume, same lookback as the VWMA) × volume confirmation multiplier AND RSI(close) > 50 AND higher-timeframe close of the still-forming bar > its Mid
Short: close < Lower band AND volume > SMA(volume, same lookback as the VWMA) × volume confirmation multiplier AND RSI(close) < 50 AND higher-timeframe close of the still-forming bar < its Mid