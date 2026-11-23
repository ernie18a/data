Calculation: Body = abs(close - open)
Calculation: InitialStopLong = max(min(low, low[1]) * (1 - Bf), entry price * (1 - X)) evaluated on the entry bar
Calculation: InitialStopShort = min(max(high, high[1]) * (1 + Bf), entry price * (1 + X)) evaluated on the entry bar
Long: close(T1, last completed bar) > EMA(close, L_D, T1, last completed bar) AND RSI(close, L_H, T2, last completed bar) > K AND RSI(close, L_R) > P_RL AND MACD line(close, fast, slow, sig) > MACD signal(close, fast, slow, sig) AND close[1] < open[1] AND close > open AND close >= open[1] AND open <= close[1] AND Body > Body[1] * E AND ATR(high, low, close, A) > SMA(ATR(high, low, close, A), M) AND volume > R_V * SMA(volume, V)
Short: close(T1, last completed bar) < EMA(close, L_D, T1, last completed bar) AND RSI(close, L_H, T2, last completed bar) < K AND RSI(close, L_R) < P_RS AND MACD line(close, fast, slow, sig) < MACD signal(close, fast, slow, sig) AND close[1] > open[1] AND close < open AND open >= close[1] AND close <= open[1] AND Body > Body[1] * E AND ATR(high, low, close, A) > SMA(ATR(high, low, close, A), M) AND volume > R_V * SMA(volume, V)
Exit: long, low <= InitialStopLong
Exit: long, close crosses above entry price + R_TP * (entry price - InitialStopLong)
Exit: short, high >= InitialStopShort
Exit: short, close crosses below entry price - R_TP * (InitialStopShort - entry price)