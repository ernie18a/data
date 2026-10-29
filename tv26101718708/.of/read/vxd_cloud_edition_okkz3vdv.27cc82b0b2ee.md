Calculation: Cloud high/low = maximum/minimum of the fast EMA of close, smoothed linear regression of close, and the AlphaTrend value from two bars earlier; AlphaTrend uses either Supertrend or the RSI-based trailing band, according to the selected order condition
Calculation: Cloud trend = direction of the CloudMA, which is the rising/falling two-bar trend of the cloud line; CloudMA trails the cloud low when the Andean bullish component exceeds the bearish component, and trails the cloud high when the bearish component exceeds the bullish component
Calculation: Pivot high/low = latest confirmed pivot high/low, using equal left and right lookbacks
Calculation: Risk-range high/low = highest pivot high / lowest pivot low over the pivot sizing lookback
Calculation: Bullish/bearish Andean component = square root of the smoothed second moment minus the square of the smoothed first moment of the respective price envelope
Calculation: Long target = entry price + risk-reward multiple × (entry price − risk-range low); short target = entry price − risk-reward multiple × (risk-range high − entry price)
Calculation: High-volume bar = volume > volume multiplier × simple moving average of volume
Long: A bullish high-volume bar (close > open AND high-volume bar)
Long: On a false-to-true transition of the selected long condition, with no existing long position and long-entry rearm enabled: (close > pivot high AND close > cloud high) OR (close > cloud high AND smoothed linear regression of close is rising for two bars) OR (cloud trend is rising AND close > cloud high)
Short: A bearish high-volume bar (close < open AND high-volume bar)
Short: On a false-to-true transition of the selected short condition, with no existing short position and short-entry rearm enabled: (close < pivot low AND close < cloud low) OR (close < cloud low AND smoothed linear regression of close is falling for two bars) OR (cloud trend is falling AND close < cloud low)
Exit: Long, (cloud trend changes to falling when the cloud-trend entry condition is selected) OR (close < cloud low AND close < pivot low) OR (low falls below the long stop) OR (high reaches the long target)
Exit: Short, (cloud trend changes to rising when the cloud-trend entry condition is selected) OR (close > cloud high AND close > pivot high) OR (high rises above the short stop) OR (low reaches the short target)