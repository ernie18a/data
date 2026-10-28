Calculation: Candle body-to-range ratio = abs(close - open) / (high - low), when high > low
Calculation: Estimated buy-volume share = (close - low) / (high - low), when high > low
Calculation: Estimated sell-volume share = (high - close) / (high - low), when high > low
Long: high > low AND candle body-to-range ratio < absorption body threshold AND volume > its moving average × absorption volume multiplier AND estimated buy-volume share > dominant share threshold AND close > trend EMA
Long: previous bar met the long absorption condition AND close > open AND open < previous close AND close > previous open AND candle body > previous candle body AND close > trend EMA
Short: high > low AND candle body-to-range ratio < absorption body threshold AND volume > its moving average × absorption volume multiplier AND estimated sell-volume share > dominant share threshold AND close < trend EMA
Short: previous bar met the short absorption condition AND close < open AND open > previous close AND close < previous open AND candle body > previous candle body AND close < trend EMA