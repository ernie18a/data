Calculation: Fast stochastic = SMA of the stochastic oscillator over its smoothing lookback
Calculation: Slow stochastic = SMA of the fast stochastic over a longer lookback
Calculation: Reversal state = 1 when the close two bars ago is below the prior close AND the current close is above the prior close AND the fast stochastic is below the slow stochastic AND the fast stochastic is above the threshold; -1 when the close two bars ago is above the prior close AND the current close is below the prior close AND the fast stochastic is above the slow stochastic AND the fast stochastic is below the threshold; otherwise retain the prior state
Calculation: 3-10 oscillator = short-lookback EMA of higher-timeframe daily HL2 minus longer-lookback EMA of the same HL2; signal = SMA of the oscillator. Use the still-forming higher-timeframe bar.
Calculation: 3-10 state = 1 when the oscillator is above its signal; -1 when the signal is above the oscillator; otherwise retain the prior state
Long: Reversal state = 1 AND 3-10 state = 1
Short: Reversal state = -1 AND 3-10 state = -1