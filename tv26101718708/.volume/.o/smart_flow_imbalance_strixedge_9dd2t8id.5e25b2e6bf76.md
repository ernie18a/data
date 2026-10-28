Calculation: Relative volume = current volume divided by its moving average over the core lookback.
Calculation: Flow pressure = the smoothed one-bar close return divided by ATR, multiplied by capped relative volume; clamp to [-1, 1].
Calculation: Displacement = candle body divided by ATR, multiplied by capped relative volume, normalized and clamped to [-1, 1].
Calculation: Range balance = close’s position within the rolling high-low range over the core lookback, mapped to [-1, 1].
Calculation: Score = a smoothed 0–100 normalization of a weighted blend of flow pressure, displacement, and range balance, blended with a DNA score from those same components. In the engine blend, flow pressure has the greatest weight, followed by displacement, then range balance; in the DNA score, displacement has the greatest weight and flow pressure and range balance have equal lower weights. Use the same smoothing length for flow pressure and score.
Calculation: Stop loss and TP3 = entry price offset by ATR on the entry bar times separate stop and TP3 distance multipliers; offset against the position for the stop and with it for TP3.
Long: On a confirmed bar close, score crosses up through the upper trigger threshold AND no setup is active.
Short: On a confirmed bar close, score crosses down through the symmetric lower trigger threshold AND no setup is active.
Exit: long, low <= stop loss OR high >= TP3
Exit: short, high >= stop loss OR low <= TP3