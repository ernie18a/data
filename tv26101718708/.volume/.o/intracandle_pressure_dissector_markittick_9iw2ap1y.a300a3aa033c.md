Calculation: Selected candle = current chart-timeframe bar, or last completed higher-timeframe bar when higher-timeframe analysis is enabled
Calculation: ATR = average true range on the selected timeframe; use its last completed value
Calculation: Volume rank = min-max normalization of selected-candle volume over a rolling lookback, scaled 0–1; use the selected candle and its preceding bars
Calculation: Body efficiency = (close − open) / (high − low)
Calculation: Wick asymmetry = ((min(open, close) − low) − (high − max(open, close))) / (high − low)
Calculation: Volume conviction = body efficiency × volume rank
Calculation: Inertia = current body × previous selected-timeframe body / ATR²
Calculation: Spread pressure = ((close − low) − (high − close)) / (high − low)
Calculation: Ghost volume = volume rank × (1 − min(1, abs(close − open) / ATR))
Calculation: FLOW = EMA of the weighted sum of body efficiency, wick asymmetry, volume conviction, inertia, spread pressure, and negative ghost volume, normalized over a rolling window to −100…100; normalize each dimension to the script’s scale before weighting and normalize weights by their sum. The FLOW normalization window is twice the volume-rank lookback.
Calculation: Normalized FLOW acceleration = min-max normalization of the second difference of FLOW over the volume-rank lookback, minus 50
Long: FLOW > 0 AND NOT (selected close > selected close two bars ago AND FLOW > −fake-move threshold AND FLOW < fake-move threshold AND selected close >= selected open) OR normalized FLOW acceleration > 10
Short: FLOW < 0 AND NOT (selected close < selected close two bars ago AND FLOW > −fake-move threshold AND FLOW < fake-move threshold AND selected close < selected open) OR normalized FLOW acceleration < −10