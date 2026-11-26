Calculation: Activation = if the selected activation mode is volatility, ATR(shorter lookback) > ATR(longer lookback); otherwise HMA(RSI(volume, volume RSI lookback), shorter smoothing lookback) > volume threshold
Calculation: Main adaptive lookback = initialize to average(main minimum lookback, main maximum lookback); on each chart bar, if Activation then max(main minimum lookback, previous lookback × (1 − shared adaptation rate)), else min(main maximum lookback, previous lookback × (1 + shared adaptation rate))
Calculation: Minor adaptive lookback = initialize to average(minor minimum lookback, minor maximum lookback); on each chart bar, if Activation then max(minor minimum lookback, previous lookback × (1 − shared adaptation rate)), else min(minor maximum lookback, previous lookback × (1 + shared adaptation rate))
Calculation: Main adaptive HMA = HMA(selected price field, integer part of main adaptive lookback)
Calculation: Minor adaptive HMA = HMA(selected price field, integer part of minor adaptive lookback)
Calculation: Adaptive HMA slope(HMA) = if dt > 0 then −round(acos(1 / sqrt(1 + dt²)) × 180 / π) else round(acos(1 / sqrt(1 + dt²)) × 180 / π), where dt = (HMA[lag] − HMA) / selected price field × slope range parameter / (highest(high, slope lookback) − lowest(low, slope lookback)) × lowest(low, slope lookback)
Long: Adaptive HMA slope(Main adaptive HMA) ≥ slope threshold
Short: Adaptive HMA slope(Main adaptive HMA) ≤ −slope threshold
Long: Adaptive HMA slope(Minor adaptive HMA) ≥ slope threshold
Short: Adaptive HMA slope(Minor adaptive HMA) ≤ −slope threshold
Long: close > Main adaptive HMA AND Adaptive HMA slope(Main adaptive HMA) ≥ slope threshold AND Activation AND RSI(close, RSI lookback) > RSI threshold
Short: close < Main adaptive HMA AND Adaptive HMA slope(Main adaptive HMA) ≤ −slope threshold AND Activation AND RSI(close, RSI lookback) < RSI threshold
Long: Adaptive HMA slope(Main adaptive HMA) ≥ slope threshold AND Activation AND NOT (the same condition held on the previous chart bar)
Short: Adaptive HMA slope(Main adaptive HMA) ≤ −slope threshold AND Activation AND NOT (the same condition held on the previous chart bar)
Exit: Long, Adaptive HMA slope(Main adaptive HMA) ≥ slope threshold AND NOT Activation AND close < Minor adaptive HMA AND NOT (the same condition held on the previous chart bar)
Exit: Short, Adaptive HMA slope(Main adaptive HMA) ≤ −slope threshold AND NOT Activation AND close > Minor adaptive HMA AND NOT (the same condition held on the previous chart bar)