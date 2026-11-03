Calculation: RSI = Wilder’s RSI of close over a configurable lookback; when calculated on a higher timeframe, use its last completed bar in non-repainting mode, otherwise use the current bar
Calculation: RSI signal line = a configurable moving average of RSI; use the same timeframe and completed/forming-bar rule as RSI
Calculation: Bull regime = the lowest RSI over a configurable lookback is at or above a configurable floor AND the highest RSI is above a configurable ceiling
Calculation: Bear regime = the highest RSI over a configurable lookback is at or below a configurable ceiling AND the lowest RSI is below a configurable floor
Long: RSI crosses above its signal line
Long: RSI forms a confirmed regular bullish divergence: price makes a lower pivot low and RSI makes a higher pivot low, with the pivot gap within configured minimum and maximum bars
Long: RSI forms a confirmed hidden bullish divergence: price makes a higher pivot low and RSI makes a lower pivot low, with the pivot gap within configured minimum and maximum bars
Long: Bull regime
Short: RSI crosses below its signal line
Short: RSI forms a confirmed regular bearish divergence: price makes a higher pivot high and RSI makes a lower pivot high, with the pivot gap within configured minimum and maximum bars
Short: RSI forms a confirmed hidden bearish divergence: price makes a lower pivot high and RSI makes a higher pivot high, with the pivot gap within configured minimum and maximum bars
Short: Bear regime
Exit: long, RSI crosses below the overbought level
Exit: short, RSI crosses above the oversold level