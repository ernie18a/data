Calculation: Anchored VWAP = volume-weighted average of the selected price source, reset each session, week, or month and accumulated through the current anchor period.
Calculation: T3 VWAP basis = T3 smoothing of the anchored VWAP, using six sequential EMAs with the same lookback.
Calculation: ATR ladder unit = current chart-bar ATR × the band-step parameter.
Calculation: Normalized distance = (close − T3 VWAP basis) / ATR ladder unit.
Long: bar is confirmed AND close > T3 VWAP basis + ATR ladder unit × expansion threshold AND T3 VWAP basis > its prior chart-bar value AND normalized distance > its prior chart-bar value
Short: bar is confirmed AND close < T3 VWAP basis − ATR ladder unit × expansion threshold AND T3 VWAP basis < its prior chart-bar value AND normalized distance < its prior chart-bar value
Exit: long, bar is confirmed AND high ≥ T3 VWAP basis + ATR ladder unit × reaction threshold AND close < T3 VWAP basis + ATR ladder unit × reaction threshold
Exit: short, bar is confirmed AND low ≤ T3 VWAP basis − ATR ladder unit × reaction threshold AND close > T3 VWAP basis − ATR ladder unit × reaction threshold