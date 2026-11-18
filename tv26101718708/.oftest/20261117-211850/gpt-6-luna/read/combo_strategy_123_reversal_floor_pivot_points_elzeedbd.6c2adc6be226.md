Calculation: Fast stochastic average = simple moving average of the stochastic oscillator over a smoothing parameter; the oscillator uses a separate lookback parameter.
Calculation: Slow stochastic average = simple moving average of the fast stochastic average over a separate smoothing parameter.
Calculation: Reversal state = 1 when the close two bars ago is below the prior close, the current close is above the prior close, the fast stochastic average is below the slow stochastic average, and the fast stochastic average is above a threshold; -1 when the close two bars ago is above the prior close, the current close is below the prior close, the fast stochastic average is above the slow stochastic average, and the fast stochastic average is below the threshold; otherwise retain the prior state, initialized to 0.
Calculation: Pivot point = (high + low + close) / 3 of the last completed daily bar.
Calculation: First resistance = 2 × pivot point − low of the last completed daily bar; first support = 2 × pivot point − high of the last completed daily bar.
Calculation: Pivot state = 1 when the current close is above first resistance; -1 when the current close is below first support; otherwise retain the prior state, initialized to 0.
Long: Reversal state = 1 AND pivot state = 1
Short: Reversal state = -1 AND pivot state = -1