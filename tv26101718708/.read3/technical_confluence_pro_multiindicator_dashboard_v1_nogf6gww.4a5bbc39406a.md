Calculation: Stochastic RSI K = SMA(Stochastic RSI(close, RSI lookback), smoothing lookback)
Calculation: Stochastic RSI D = SMA(Stochastic RSI K, smoothing lookback)
Calculation: Kalman-filtered close = close on the first bar; otherwise, prior Kalman-filtered close + Kalman gain × (close − prior Kalman-filtered close)
Calculation: Kalman oscillator = EMA(Kalman-filtered close, faster lookback) − EMA(Kalman-filtered close, slower lookback)
Calculation: Kalman normalized oscillator = percent-scale min-max normalization of Kalman oscillator over the normalization lookback; use the scale midpoint when the range is zero
Calculation: composite score = enhanced weight for EMA(close, fastest lookback) > EMA(close, middle lookback) > EMA(close, slower lookback) > EMA(close, longest lookback); negative enhanced weight for the reverse stack; otherwise zero, plus enhanced weight for bullish Supertrend and negative enhanced weight for bearish Supertrend, plus standard weight if RSI(close, RSI lookback) > bullish RSI threshold, negative standard weight if it is < bearish RSI threshold, otherwise zero, plus standard weight if Stochastic RSI K > Stochastic RSI D and negative standard weight otherwise, plus standard weight if MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback).line > .signal and negative standard weight otherwise, plus standard weight if ADX(DMI lookback, DMI smoothing lookback) > ADX threshold and DI+ > DI−, negative standard weight if ADX > ADX threshold and DI− > DI+, otherwise zero, plus standard weight if close > session VWAP(hlc3) and negative standard weight otherwise, plus standard weight if OBV > EMA(OBV, OBV EMA lookback) and negative standard weight otherwise, plus standard weight if volume > SMA(volume, volume lookback) × volume multiplier and negative standard weight otherwise, plus standard weight if MACD(T1, MACD fast lookback, MACD slow lookback, MACD signal lookback).line − .signal > .signal and negative standard weight otherwise, plus standard weight if Squeeze Momentum(close, high, low, squeeze lookback, momentum lookback) > zero and > its prior-bar value, negative standard weight if it is < zero and < its prior-bar value, otherwise zero, plus standard weight if QQE smoothed RSI > QQE trailing line and negative standard weight otherwise, plus standard weight if Kalman normalized oscillator > bullish Kalman threshold and Kalman oscillator > its prior-bar value, negative standard weight if normalized oscillator < bearish Kalman threshold and oscillator < its prior-bar value, otherwise zero, plus standard weight if WaveTrend main > WaveTrend signal and main < WaveTrend overbought threshold, negative standard weight if main < signal and main > WaveTrend oversold threshold, otherwise zero; add enhanced weight for each bullish EMA stack and negative enhanced weight for each bearish EMA stack on T1, T2, and T3; add higher weight for a bullish EMA stack and negative higher weight for a bearish EMA stack on each of T4 and T5. For T1–T5, use EMA(close, middle lookback), EMA(close, slower lookback), and EMA(close, longest lookback) from the bar still forming on that timeframe, sampled on chart bars.
Calculation: normalized score = round(clamp((composite score + normalization offset) / normalization span × normalization scale, normalization minimum, normalization maximum))
Long: EMA(close, fastest lookback) > EMA(close, middle lookback) > EMA(close, slower lookback) > EMA(close, longest lookback)
Short: EMA(close, fastest lookback) < EMA(close, middle lookback) < EMA(close, slower lookback) < EMA(close, longest lookback)
Long: Supertrend(close, high, low, multiplier, lookback).direction < zero
Short: Supertrend(close, high, low, multiplier, lookback).direction ≥ zero
Long: RSI(close, RSI lookback) > bullish RSI threshold
Short: RSI(close, RSI lookback) < bearish RSI threshold
Long: Stochastic RSI K > Stochastic RSI D
Short: Stochastic RSI K ≤ Stochastic RSI D
Long: MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback).line > .signal
Short: MACD(close, MACD fast lookback, MACD slow lookback, MACD signal lookback).line ≤ .signal
Long: ADX(DMI lookback, DMI smoothing lookback) ≥ ADX threshold AND DI+ > DI−
Short: ADX(DMI lookback, DMI smoothing lookback) ≥ ADX threshold AND DI− ≥ DI+
Long: close > session VWAP(hlc3)
Short: close ≤ session VWAP(hlc3)
Long: OBV > EMA(OBV, OBV EMA lookback)
Short: OBV ≤ EMA(OBV, OBV EMA lookback)
Long: volume > SMA(volume, volume lookback) × volume multiplier
Short: volume ≤ SMA(volume, volume lookback) × volume multiplier
Long: MACD(T1, MACD fast lookback, MACD slow lookback, MACD signal lookback).line − .signal > .signal; use the bar still forming on T1, sampled on chart bars
Short: MACD(T1, MACD fast lookback, MACD slow lookback, MACD signal lookback).line − .signal ≤ .signal; use the bar still forming on T1, sampled on chart bars
Long: Squeeze Momentum(close, high, low, squeeze lookback, momentum lookback) > zero AND Squeeze Momentum > its prior-bar value
Short: Squeeze Momentum(close, high, low, squeeze lookback, momentum lookback) < zero AND Squeeze Momentum < its prior-bar value
Long: QQE(close, QQE RSI lookback, QQE smoothing lookback, QQE factor).smoothed RSI > .trailing line
Short: QQE(close, QQE RSI lookback, QQE smoothing lookback, QQE factor).smoothed RSI ≤ .trailing line
Long: Kalman normalized oscillator > bullish Kalman threshold AND Kalman oscillator > its prior-bar value
Short: Kalman normalized oscillator < bearish Kalman threshold AND Kalman oscillator < its prior-bar value
Long: WaveTrend main(hlc3, channel lookback, average lookback, deviation factor) > WaveTrend signal AND WaveTrend main < WaveTrend overbought threshold
Short: WaveTrend main < WaveTrend signal AND WaveTrend main > WaveTrend oversold threshold
Long: EMA(close, middle lookback, T1) > EMA(close, slower lookback, T1) > EMA(close, longest lookback, T1) OR EMA(close, middle lookback, T2) > EMA(close, slower lookback, T2) > EMA(close, longest lookback, T2) OR EMA(close, middle lookback, T3) > EMA(close, slower lookback, T3) > EMA(close, longest lookback, T3) OR EMA(close, middle lookback, T4) > EMA(close, slower lookback, T4) > EMA(close, longest lookback, T4) OR EMA(close, middle lookback, T5) > EMA(close, slower lookback, T5) > EMA(close, longest lookback, T5); each uses the bar still forming on its timeframe, sampled on chart bars
Short: EMA(close, middle lookback, T1) < EMA(close, slower lookback, T1) < EMA(close, longest lookback, T1) OR EMA(close, middle lookback, T2) < EMA(close, slower lookback, T2) < EMA(close, longest lookback, T2) OR EMA(close, middle lookback, T3) < EMA(close, slower lookback, T3) < EMA(close, longest lookback, T3) OR EMA(close, middle lookback, T4) < EMA(close, slower lookback, T4) < EMA(close, longest lookback, T4) OR EMA(close, middle lookback, T5) < EMA(close, slower lookback, T5) < EMA(close, longest lookback, T5); each uses the bar still forming on its timeframe, sampled on chart bars
Long: normalized score ≥ buy alert threshold
Long: normalized score ≥ strong-buy alert threshold
Short: normalized score ≤ sell alert threshold
Short: normalized score ≤ strong-sell alert threshold
Long: normalized score ≥ weak-uptrend boundary AND normalized score < uptrend boundary
Long: normalized score ≥ uptrend boundary AND normalized score < strong-uptrend boundary
Long: normalized score ≥ strong-uptrend boundary
Short: normalized score ≥ weak-downtrend boundary AND normalized score < neutral boundary
Short: normalized score ≥ downtrend boundary AND normalized score < weak-downtrend boundary
Short: normalized score < downtrend boundary