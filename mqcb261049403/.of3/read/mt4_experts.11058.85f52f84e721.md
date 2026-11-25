Calculation: ZigZag channel boundaries = select the seven latest distinct ZigZag pivots A through G, newest first, using separate depth, deviation, and backstep parameters on chart bars; let L(X,Y) be the straight line through pivot times and prices X and Y evaluated at the current chart bar; if D > E, upper = L(F,B) when F > D else L(D,B), and lower = L(G,C) when G < E else L(E,C); otherwise upper = L(G,C) when G > E else L(E,C), and lower = L(F,B) when F < D else L(D,B).
Long: Awesome Oscillator(current forming chart bar) > 0 AND Awesome Oscillator(previous completed chart bar) < 0 AND Awesome Oscillator(two chart bars ago) < Awesome Oscillator(previous completed chart bar)
Short: Awesome Oscillator(current forming chart bar) < 0 AND Awesome Oscillator(previous completed chart bar) > 0 AND Awesome Oscillator(two chart bars ago) > Awesome Oscillator(previous completed chart bar)
Long: Elliott Wave Oscillator(median price, shorter lookback, longer lookback, current forming chart bar) > 0 AND Elliott Wave Oscillator(median price, shorter lookback, longer lookback, previous completed chart bar) < 0
Short: Elliott Wave Oscillator(median price, shorter lookback, longer lookback, current forming chart bar) < 0 AND Elliott Wave Oscillator(median price, shorter lookback, longer lookback, previous completed chart bar) > 0
Long: close > ZigZag channel upper boundary
Short: close < ZigZag channel lower boundary
Exit: long, Awesome Oscillator(current forming chart bar) < 0 AND close > entry price
Exit: short, Awesome Oscillator(current forming chart bar) > 0 AND close < entry price
Exit: long, Elliott Wave Oscillator(median price, shorter lookback, longer lookback, current forming chart bar) < 0 AND close > entry price
Exit: short, Elliott Wave Oscillator(median price, shorter lookback, longer lookback, current forming chart bar) > 0 AND close < entry price