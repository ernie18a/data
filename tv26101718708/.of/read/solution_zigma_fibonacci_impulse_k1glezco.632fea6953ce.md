Calculation: Fibonacci level = the selected retracement level returned by the imported AutoFiboRetrace library for the lookback high and low. The library implementation is absent from READ, so the level cannot be reproduced from READ alone. Its selectable timeframe may be higher, lower, or equal to the chart timeframe; with lookahead off, historical higher-timeframe values use the last completed bar, while realtime values can use the bar still forming; lower-timeframe requests return the last available intrabar.
Calculation: Impulse open = longer-period EMA of the Fibonacci level on chart bars; impulse close = shorter-period EMA of the same level.
Calculation: Chandelier direction = initially long. Compute a long stop as the highest high over its lookback minus an ATR multiple; if the previous close is above the previous long stop, raise it to at least the previous long stop. Compute a short stop as the lowest low over the same lookback plus the same ATR multiple; if the previous close is below the previous short stop, lower it to at most the previous short stop. Set direction to long if close is above the previous short stop; otherwise set it to short if close is below the previous long stop; otherwise retain the previous direction.
Calculation: Smoothed regression = EMA on chart bars of a linear regression of the selected price source. The regression timeframe is selectable as higher, lower, or equal to the chart timeframe; with lookahead off, historical higher-timeframe values use the last completed bar, while realtime values can use the bar still forming; lower-timeframe requests return the last available intrabar.
Calculation: Risk fraction = for an automatic stop, at the first bar with a position calculate (entry price minus the lowest swing low) / entry price for a long or (highest swing high minus entry price) / entry price for a short, and retain it while the position remains open; reset it when flat. The swing is selectable between chart-bar highs and lows and the rolling highest and lowest impulse close, with a separate swing lookback. For a fixed stop, use the configured fraction when the previous risk fraction is zero and a position is open; otherwise use zero.
Long: Impulse close > impulse open
Short: Impulse close < impulse open
Long: Close > impulse open
Short: Close < impulse open
Long: Smoothed regression > previous smoothed regression
Short: Smoothed regression <= previous smoothed regression
Long: Chandelier direction = long AND previous Chandelier direction = short
Short: Chandelier direction = short AND previous Chandelier direction = long
Long: Position is flat AND close crosses above impulse open AND Chandelier direction = long
Short: Position is flat AND close crosses below impulse open AND Chandelier direction = short
Long: Position is flat AND close crosses above impulse open AND Chandelier direction = long AND close > smoothed regression AND close > smoothed regression at a prior chart-bar offset
Short: Position is flat AND close crosses below impulse open AND Chandelier direction = short AND close < smoothed regression AND close < smoothed regression at the same prior chart-bar offset
Long: Position is flat AND close crosses above impulse open AND Chandelier direction = long AND positive directional indicator >= threshold AND positive directional indicator > ADX
Short: Position is flat AND close crosses below impulse open AND Chandelier direction = short AND negative directional indicator >= threshold AND negative directional indicator > ADX
Long: Position is flat AND close crosses above impulse open AND Chandelier direction = long AND close > smoothed regression AND close > smoothed regression at the prior chart-bar offset AND positive directional indicator >= threshold AND positive directional indicator > ADX
Short: Position is flat AND close crosses below impulse open AND Chandelier direction = short AND close < smoothed regression AND close < smoothed regression at the prior chart-bar offset AND negative directional indicator >= threshold AND negative directional indicator > ADX
Calculation: Directional indicators and ADX are calculated on a selectable timeframe that may be higher, lower, or equal to the chart timeframe; with lookahead off, historical higher-timeframe values use the last completed bar, while realtime values can use the bar still forming; lower-timeframe requests return the last available intrabar.
Exit: long, close < impulse open AND Chandelier direction = short
Exit: short, close > impulse open AND Chandelier direction = long
Exit: long, low <= entry price * (1 - risk fraction) OR high >= entry price * (1 + risk fraction * reward-to-risk ratio)
Exit: short, high >= entry price * (1 + risk fraction) OR low <= entry price * (1 - risk fraction * reward-to-risk ratio)