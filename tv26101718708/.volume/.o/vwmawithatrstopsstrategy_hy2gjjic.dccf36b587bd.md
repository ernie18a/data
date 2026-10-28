Calculation: VWMA = volume-weighted moving average of close
Calculation: RSI of VWMA = RSI calculated on VWMA
Calculation: ATR trailing stop = recursively update using ATR distance: if current and previous close are above the previous stop, use the greater of the previous stop and current close minus ATR distance; if both are below, use the lesser of the previous stop and current close plus ATR distance; otherwise use current close minus ATR distance when current close is above the previous stop, or current close plus ATR distance when it is not. ATR distance is ATR multiplied by a parameter.
Long: RSI of VWMA >= a threshold AND close > open AND close > VWMA AND close > ATR trailing stop
Exit: Long, previous close >= previous ATR trailing stop AND close < ATR trailing stop