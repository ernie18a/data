Calculation: Aroon up/down = 100 × (lookback + bars since highest high/lowest low in lookback) ÷ lookback, respectively
Calculation: Awesome Oscillator = 5-bar SMA of (high + low)/2 − 34-bar SMA of (high + low)/2; AO change = current AO − previous AO
Calculation: RSI average = RSI-length SMA of RSI
Calculation: MACD = fast-EMA(close) − slow-EMA(close); signal = signal-length EMA of MACD
Calculation: Stochastic %K = smoothed stochastic of close within the high-low range; %D = its moving average
Calculation: Stochastic RSI %K = smoothed stochastic of RSI; %D = its moving average
Calculation: Moving averages = each selected moving average of close; the first has the shorter length
Calculation: SuperTrend direction = standard SuperTrend direction
Calculation: ATR stop = low − RMA(true range, 14) × selected multiplier
Calculation: Pivot stop = lowest low over selected lookback, including the current bar
Calculation: VWAP stop = low − abs(sum over 14 bars of (session VWAP of true range × volume) ÷ sum of volume over 14 bars) × selected multiplier
Long: In the selected internal mode, every enabled condition is true: selected Aroon condition (Aroon up crosses above down, exceeds threshold, or is below threshold); selected AO-change condition (AO change crosses above zero, exceeds threshold, or is below threshold); selected RSI condition (RSI crosses above RSI average, exceeds threshold, or is below threshold); selected MACD condition (MACD crosses above signal, exceeds threshold, or is below threshold); selected stochastic %K condition (crosses above %D, exceeds threshold, or is below threshold); selected stochastic RSI %K condition (crosses above %D, exceeds threshold, or is below threshold); moving-average condition (shorter moving average crosses above longer moving average); and/or SuperTrend direction crosses below zero; OR, in external mode, external indicator value equals its configured signal value; and, if date-range filtering is enabled, current bar time is within the configured range
Exit: Long, high ≥ entry price + selected reward multiple × risk distance OR low ≤ entry price − risk distance; risk distance = absolute value of entry price − selected stop level calculated on the entry bar (ATR stop, pivot stop, or VWAP stop). If both levels are reached on the same bar, take-profit is checked first.