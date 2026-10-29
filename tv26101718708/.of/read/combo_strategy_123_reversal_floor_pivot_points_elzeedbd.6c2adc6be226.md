Calculation: Fast stochastic = simple moving average of the lookback-period stochastic %K over a shorter smoothing period
Calculation: Slow stochastic = simple moving average of fast stochastic over a longer smoothing period
Calculation: 123 reversal state = +1 when the close two bars ago is below the prior close, the current close is above the prior close, fast stochastic is below slow stochastic, and fast stochastic is above the threshold; -1 when the close two bars ago is above the prior close, the current close is below the prior close, fast stochastic is above slow stochastic, and fast stochastic is below the threshold; otherwise retain the prior state (initially 0)
Calculation: Floor pivot = (prior completed daily high + prior completed daily low + prior completed daily close) / 3, using daily bars higher than the chart timeframe
Calculation: Floor pivot resistance 1 = 2 × floor pivot − prior completed daily low
Calculation: Floor pivot support 1 = 2 × floor pivot − prior completed daily high
Calculation: Floor pivot state = +1 when the chart close is above floor pivot resistance 1; -1 when the chart close is below floor pivot support 1; otherwise retain the prior state (initially 0)
Long: 123 reversal state = +1 AND floor pivot state = +1
Short: 123 reversal state = -1 AND floor pivot state = -1