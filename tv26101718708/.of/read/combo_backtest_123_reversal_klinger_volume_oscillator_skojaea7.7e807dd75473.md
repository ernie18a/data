Calculation: Fast stochastic = 100 × (close − lowest low over lookback) / (highest high over lookback − lowest low over lookback), smoothed by a short-term simple moving average
Calculation: Slow stochastic = simple moving average of fast stochastic over a longer lookback
Calculation: 123 reversal state = +1 when close two bars ago < close one bar ago AND close > close one bar ago AND fast stochastic < slow stochastic AND fast stochastic > threshold; −1 when close two bars ago > close one bar ago AND close < close one bar ago AND fast stochastic > slow stochastic AND fast stochastic < threshold; otherwise retain the previous state
Calculation: Klinger trend force = volume × 100 when (high + low + close) / 3 > its previous-bar value; otherwise −volume × 100
Calculation: Klinger oscillator = EMA of trend force with a shorter lookback − EMA of trend force with a longer lookback
Calculation: Klinger trigger = EMA of Klinger oscillator
Calculation: Klinger state = +1 when Klinger oscillator > Klinger trigger; −1 when Klinger oscillator < Klinger trigger; otherwise retain the previous state
Calculation: Combined signal = +1 when 123 reversal state = +1 AND Klinger state = +1; −1 when both states = −1; otherwise 0
Long: Combined signal = +1
Short: Combined signal = −1
Exit: long, Combined signal = 0
Exit: short, Combined signal = 0