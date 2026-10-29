Calculation: Fast stochastic = simple moving average of the stochastic oscillator over a shorter smoothing lookback: 100 × (close − lowest low) / (highest high − lowest low), with the high and low extrema calculated over the oscillator lookback.
Calculation: Slow stochastic = simple moving average of Fast stochastic over a longer smoothing lookback than Fast stochastic.
Calculation: Reversal state = +1 when close two bars ago < close one bar ago AND current close > close one bar ago AND Fast stochastic < Slow stochastic AND Fast stochastic > the level; otherwise −1 when close two bars ago > close one bar ago AND current close < close one bar ago AND Fast stochastic > Slow stochastic AND Fast stochastic < the level; otherwise retain the prior state, initially 0.
Calculation: Facilitation state = +1 when (high − low) / volume × 10000 > the positive threshold; otherwise −1 when (high − low) / volume × 10000 < the negative threshold; otherwise retain the prior state, initially 0.
Long: Reversal state = +1 AND Facilitation state = +1
Short: Reversal state = −1 AND Facilitation state = −1
Exit: any, Reversal state ≠ Facilitation state