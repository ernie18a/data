Long: close > HMA(close, shorter lookback) AND close crosses above the highest high of the previous 5 bars AND volume > 1.5 × SMA(volume, 10) AND abs(close − open) > SMA(abs(close − open), 10) over the previous 10 bars AND close > HMA(close, longer lookback) AND most recent signal is not long
Short: close ≤ HMA(close, shorter lookback) AND close crosses below the lowest low of the previous 5 bars AND volume > 1.5 × SMA(volume, 10) AND abs(close − open) > SMA(abs(close − open), 10) over the previous 10 bars AND close < HMA(close, longer lookback) AND most recent signal is not short
Calculation: Long target = entry price + ATR(14) × target multiplier
Calculation: Long stop = entry-bar low − ATR(14) × stop-buffer multiplier
Calculation: Short target = entry price − ATR(14) × target multiplier
Calculation: Short stop = entry-bar high + ATR(14) × stop-buffer multiplier
Exit: long, high ≥ long target OR low ≤ long stop
Exit: short, low ≤ short target OR high ≥ short stop