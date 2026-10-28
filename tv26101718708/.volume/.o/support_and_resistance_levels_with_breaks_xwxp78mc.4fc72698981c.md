Calculation: Resistance pivot = latest confirmed pivot high of max(open, close), using left- and right-side bars; update one bar after confirmation and hold until replaced.
Calculation: Support pivot = latest confirmed pivot low of min(open, close), using left- and right-side bars; update one bar after confirmation and hold until replaced.
Calculation: Active resistance = resistance pivot when updated; deactivate after close crosses above it.
Calculation: Active support = support pivot when updated; deactivate after close crosses below it.
Calculation: Volume oscillator = 100 × (short-lookback EMA(volume) − long-lookback EMA(volume)) / long-lookback EMA(volume), with the short lookback shorter than the long lookback.
Long: close crosses above resistance pivot AND close > open AND volume oscillator > threshold OR close crosses above resistance pivot AND close <= open OR active resistance AND close > active resistance
Short: close crosses below support pivot AND close < open AND volume oscillator > threshold OR close crosses below support pivot AND close >= open OR active support AND close < active support