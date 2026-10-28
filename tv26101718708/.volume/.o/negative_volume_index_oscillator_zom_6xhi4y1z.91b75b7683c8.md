Calculation: Negative Volume Index = prior index × close / prior close when volume is lower than previous-bar volume; otherwise prior index
Calculation: NVI oscillator = (shorter-lookback EMA of NVI − longer-lookback EMA of the smoothed NVI) / longer-lookback EMA of the smoothed NVI × 100; use 0 when the longer-lookback EMA is 0
Calculation: Signal line = configurable moving average of the NVI oscillator
Calculation: Bullish divergence = confirmed oscillator pivot low > previous oscillator pivot low AND low at the current pivot < low at the previous pivot AND the current pivot low equals the lowest oscillator value over a longer lookback
Calculation: Bearish divergence = confirmed oscillator pivot high < previous oscillator pivot high AND high at the current pivot > high at the previous pivot AND the current pivot high equals the highest oscillator value over a longer lookback
Long: NVI oscillator > signal line AND prior NVI oscillator ≤ prior signal line OR bullish divergence = true
Short: NVI oscillator < signal line AND prior NVI oscillator ≥ prior signal line OR bearish divergence = true