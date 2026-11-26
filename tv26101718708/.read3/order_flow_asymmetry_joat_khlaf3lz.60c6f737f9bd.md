Calculation: Bull trend regime = ADX(DI lookback, ADX smoothing) > trend threshold AND close > EMA(close, regime EMA lookback)
Calculation: Bear trend regime = ADX(DI lookback, ADX smoothing) > trend threshold AND close < EMA(close, regime EMA lookback)
Calculation: Normalized VWM = 0 when highest(C, VWM lookback) = lowest(C, VWM lookback); otherwise VWM scale * (C - lowest(C, VWM lookback)) / (highest(C, VWM lookback) - lowest(C, VWM lookback)) - VWM offset, where C = cumulative sum(change(close) * volume)
Calculation: Imbalance score = 0 when ATR(ATR lookback) = 0; otherwise clamp(imbalance scale * I / ATR(ATR lookback), -imbalance cap, imbalance cap), where I = I[1] * decay factor + bar imbalance, I starts at 0, and bar imbalance = 0 when high = low, otherwise (close - (high + low) / 2) / (high - low)
Calculation: Liquidity vacuum = volume < EMA(volume, vacuum volume lookback) - vacuum sigma * StDev(volume, vacuum volume lookback) AND high - low > ATR(ATR lookback)
Long: Bull trend regime
Short: Bear trend regime
Long: Normalized VWM > 0
Short: Normalized VWM < 0
Long: Normalized VWM > VWM cross threshold
Short: Normalized VWM < -VWM cross threshold
Long: Imbalance score > imbalance gate
Short: Imbalance score < -imbalance gate
Long: Imbalance score crosses above extreme imbalance threshold
Short: Imbalance score crosses below -extreme imbalance threshold
Long: Bull trend regime AND Normalized VWM crosses above VWM cross threshold AND Imbalance score > imbalance gate AND NOT Liquidity vacuum AND bars since prior confirmed smart signal >= cooldown AND bar is confirmed
Short: Bear trend regime AND Normalized VWM crosses below -VWM cross threshold AND Imbalance score < -imbalance gate AND NOT Liquidity vacuum AND bars since prior confirmed smart signal >= cooldown AND bar is confirmed
Exit: long, high >= entry price + ATR(ATR lookback) at entry * take-profit ATR multiple OR low <= entry price - ATR(ATR lookback) at entry * stop-loss ATR multiple
Exit: short, low <= entry price - ATR(ATR lookback) at entry * take-profit ATR multiple OR high >= entry price + ATR(ATR lookback) at entry * stop-loss ATR multiple