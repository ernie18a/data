Calculation: Fast stochastic = SMA of the stochastic oscillator over the fast smoothing parameter
Calculation: Slow stochastic = SMA of Fast stochastic over the slow smoothing parameter
Long: close two bars ago < close one bar ago AND close > close one bar ago AND Fast stochastic < Slow stochastic AND Fast stochastic > stochastic level
Short: close two bars ago > close one bar ago AND close < close one bar ago AND Fast stochastic > Slow stochastic AND Fast stochastic < stochastic level
Calculation: OHLC4 = (open + high + low + close) / 4
Calculation: Cumulative price-volume trend = prior cumulative price-volume trend + (volume / volume scaling parameter) × (current OHLC4 − prior OHLC4) / prior OHLC4
Calculation: Adjusted price-volume trend = price-volume level + price-volume scale × Cumulative price-volume trend
Calculation: Smoothed adjusted price-volume trend = SMA of Adjusted price-volume trend over its lookback parameter
Long: Adjusted price-volume trend > Smoothed adjusted price-volume trend
Short: Adjusted price-volume trend < Smoothed adjusted price-volume trend
Long: Reversal signal is long AND price-volume trend signal is long, when direction reversal is disabled; OR Reversal signal is short AND price-volume trend signal is short, when direction reversal is enabled
Short: Reversal signal is short AND price-volume trend signal is short, when direction reversal is disabled; OR Reversal signal is long AND price-volume trend signal is long, when direction reversal is enabled
Exit: long or short, neither the reversal signal and price-volume trend signal both indicate long nor both indicate short