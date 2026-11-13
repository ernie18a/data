Calculation: HTF = every indicator below is computed on bars aggregated to a timeframe higher than or equal to the chart timeframe, using the still-forming bar that contains the current chart bar. Close in the MA votes is the chart bar close. prev(X) = the value of X (as an HTF value) at the previous chart bar.
Calculation: MA_score = mean of 15 slots. Each slot is +1 if SMA(close, n) <= chart close, else -1. Slots: six lookbacks n1<n2<n3<n4<n5<n6 each used twice; one lookback shorter than n1; one lookback equal to n2; one slot fixed at 0.
Calculation: V_rsi = -1 if RSI(Wilder, close) > overbought level AND RSI < prev(RSI); +1 if RSI < oversold level AND RSI > prev(RSI); else 0.
Calculation: V_stoch = with K = SMA(raw Stochastic %K of close/high/low, smoothing) and D = SMA(K, d-length): -1 if K > overbought level AND K < D; +1 if K < oversold level AND K > D; else 0.
Calculation: V_adx = +1 if ADX(Wilder) >= trend-strength level AND DI+ > DI-; -1 if ADX >= trend-strength level AND DI+ < DI-; else 0.
Calculation: V_cci = with CCI = (close - SMA(close)) / (0.015 * mean absolute deviation): -1 if CCI > +level AND CCI > prev(CCI); +1 if CCI < -level AND CCI < prev(CCI); else 0.
Calculation: V_stochrsi = same rule as V_stoch, but K and D are built from Stochastic of RSI(close) in place of price (K = SMA(Stochastic of RSI, smoothK), D = SMA(K, smoothD)).
Calculation: V_ao = with AO = SMA(hl2, shorter lookback) - SMA(hl2, longer lookback): +1 if AO > 0 AND AO > prev(AO); -1 if AO < 0 AND AO < prev(AO); else 0.
Calculation: V_mom = +1 if (close - close[n]) > 0, else -1.
Calculation: V_macd = +1 if EMA(close, fast) - EMA(close, slow) > 0, else -1 (fast lookback < slow lookback).
Calculation: V_wpr = with WPR = 100*(close - highest high(n)) / (highest high(n) - lowest low(n)): +1 if WPR < lower level AND WPR > prev(WPR); -1 if WPR > upper level AND WPR < prev(WPR); else 0.
Calculation: V_uo = Ultimate Oscillator with three lookbacks (short<medium<long) and weights 4,2,1 on short, medium, long: +1 if UO >= upper level; -1 if UO <= lower level; else 0.
Calculation: V_bbp = with bulls = high - EMA(close), bears = low - EMA(close): -1 if bulls > 0 AND bulls < prev(bulls); else +1 if bears < 0 AND bears > prev(bears); else 0 (the -1 test has priority).
Calculation: Osc_score = mean of V_rsi, V_stoch, V_adx, V_cci, V_stochrsi, V_ao, V_mom, V_macd, V_wpr, V_uo, V_bbp.
Calculation: Rating = (MA_score + Osc_score) / 2
Long: Rating > 0
Short: Rating < 0