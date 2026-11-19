Calculation: Chart %K = SMA(Stochastic(close, high, low, stochastic and regression lookback), K smoothing lookback), on chart bars.
Calculation: Chart %D = SMA(Chart %K, D smoothing lookback), on chart bars.
Calculation: T1 %K = linear regression at its current endpoint of SMA(Stochastic(T1 close, T1 high, T1 low, stochastic and regression lookback), K smoothing lookback), over the stochastic and regression lookback; calculated on T1 bars and mapped to chart bars using the current T1 bar in real time and T1 values confirmed at close historically (lookahead off).
Calculation: T1 %D = linear regression at its current endpoint of SMA(SMA(Stochastic(T1 close, T1 high, T1 low, stochastic and regression lookback), K smoothing lookback), D smoothing lookback), over the stochastic and regression lookback; calculated on T1 bars and mapped to chart bars using the current T1 bar in real time and T1 values confirmed at close historically (lookahead off).
Long: long direction permitted AND (trend filter disabled OR EMA(close, shorter trend lookback) > EMA(close, longer trend lookback)) AND T1 %K crosses above the stochastic midline AND Chart %K > the stochastic midline AND Chart %K > its value on the prior chart bar AND Chart %K > Chart %D AND T1 %K > T1 %D.
Short: short direction permitted AND (trend filter disabled OR EMA(close, shorter trend lookback) < EMA(close, longer trend lookback)) AND T1 %D crosses below the stochastic midline AND Chart %K < the stochastic midline AND Chart %K < its value on the prior chart bar AND Chart %K < Chart %D AND T1 %K < T1 %D.
Calculation: Initial risk distance = ATR(ATR lookback) × initial stop multiple, sampled on the entry bar and held for the trade.
Calculation: Open-trade R = (close − entry price) / initial risk distance when long; (entry price − close) / initial risk distance when short.
Calculation: Long stop = entry price − initial risk distance at entry; thereafter, if Open-trade R ≥ trailing-start R, max(previous stop, close − ATR(ATR lookback) × trailing ATR multiple); else if Open-trade R ≥ breakeven trigger R, max(previous stop, entry price); otherwise previous stop.
Calculation: Short stop = entry price + initial risk distance at entry; thereafter, if Open-trade R ≥ trailing-start R, min(previous stop, close + ATR(ATR lookback) × trailing ATR multiple); else if Open-trade R ≥ breakeven trigger R, min(previous stop, entry price); otherwise previous stop.
Exit: long, low ≤ Long stop.
Exit: short, high ≥ Short stop.
Exit: long, T1 %D crosses below the upper stochastic threshold.
Exit: short, T1 %K crosses above the lower stochastic threshold.
Exit: long, trend exit enabled AND EMA(close, shorter trend lookback) < EMA(close, longer trend lookback).
Exit: short, trend exit enabled AND EMA(close, shorter trend lookback) > EMA(close, longer trend lookback).
Exit: long, time-stop lookback enabled AND chart bars elapsed since entry ≥ time-stop lookback.
Exit: short, time-stop lookback enabled AND chart bars elapsed since entry ≥ time-stop lookback.