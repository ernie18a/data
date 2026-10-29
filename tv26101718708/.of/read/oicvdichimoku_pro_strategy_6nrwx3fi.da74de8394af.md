Calculation: CVD = EMA(volume × (1 if close > open else −1), configured smoothing period)
Calculation: Ichimoku cloud top = max of the displaced Tenkan/Kijun midpoint and displaced Senkou Span B; cloud bottom = min of those values. Tenkan = (highest high over its lookback + lowest low over its lookback) / 2; Kijun and Senkou Span B use the same formula with their respective lookbacks; Senkou Span A = (Tenkan + Kijun) / 2
Long: fast EMA crosses above slow EMA AND CVD > 0 AND close > Ichimoku cloud top
Short: fast EMA crosses below slow EMA AND CVD < 0 AND close < Ichimoku cloud bottom
Calculation: Long stop = signal-bar close − (ATR × configured stop multiple, or signal-bar close × configured stop percentage); long targets = signal-bar close + (ATR × each configured target multiple)
Calculation: Short stop = signal-bar close + (ATR × configured stop multiple, or signal-bar close × configured stop percentage); short targets = signal-bar close − (ATR × each configured target multiple)
Exit: long, low ≤ long stop OR high ≥ either long target
Exit: short, high ≥ short stop OR low ≤ either short target