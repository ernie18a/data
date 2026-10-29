Calculation: Donchian midpoint = (highest high + lowest low) / 2 over a lookback.
Calculation: Composite baseline = EMA of the weighted average of the enabled conversion, base, span A, span B, and optional close components; conversion and base are Donchian midpoints with shorter and longer lookbacks, span A is their average, and span B is a Donchian midpoint with a longer lookback than base.
Calculation: Outer channel width = max(EMA(ATR × multiplier + EMA(abs(close − open), body lookback) × multiplier, width smoothing lookback), minimum width in ticks).
Calculation: Inner channel = composite baseline ± outer channel width × inner-channel ratio.
Calculation: Regime state = on each completed chart bar, compression if body size ≤ its EMA × compression factor AND bar range ≤ its EMA × compression factor AND ATR ≤ its EMA × compression factor; else expansion if body size ≥ its EMA × expansion factor AND bar range ≥ its EMA × expansion factor AND abs(close − baseline) / outer channel width ≥ expansion threshold AND volume ≥ its SMA × expansion factor; else balanced. Retain the resulting state until the next completed bar.
Calculation: Trend state = on each completed chart bar, set bullish if close > upper outer channel AND baseline is rising over its slope lookback; else set bearish if close < lower outer channel AND baseline is falling over that lookback; else set neutral if regime is compression AND close is between the inner channel boundaries; otherwise retain the prior state.
Long: Completed chart bar AND trend state changes to bullish.
Short: Completed chart bar AND trend state changes to bearish.
Exit: Long, completed chart bar AND trend state changes to neutral.
Exit: Short, completed chart bar AND trend state changes to neutral.