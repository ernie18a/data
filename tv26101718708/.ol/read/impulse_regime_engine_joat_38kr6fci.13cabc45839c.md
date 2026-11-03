Calculation: Volume ratio = short-term SMA(volume) divided by long-term SMA(volume)
Calculation: Elevated-volume regime = volume ratio >= normal-volume threshold
Calculation: Ready = available chart bars >= the greatest of the long-volume lookback, projection-range lookback, strength lookback, and 100
Calculation: Projected RSI price = lowest low over the projection-range lookback + (SMA-smoothed RSI × (highest high − lowest low) over that lookback / 100)
Calculation: Projection basis = EMA of projected RSI price; projection tolerance = long-lookback SMA of absolute(close − open) × tolerance multiplier
Calculation: Trend bias = bullish after a confirmed close > projection basis + tolerance; bearish after a confirmed close < projection basis − tolerance; otherwise retain the prior bias, initially bearish
Calculation: Box = start on a confirmed transition into elevated volume when ready, idle, and cooldown has passed; expand top to the highest high and bottom to the lowest low while elevated volume continues, up to the build limit; arm when elevated volume ends; discard on build or armed timeout; after resolution, require the configured cooldown before starting another box
Calculation: Stop distance = ATR × stop multiplier in ATR mode, otherwise entry price × 0.01 × stop multiplier; third target = entry price + position direction × stop distance × third risk-reward multiple
Long: Ready AND confirmed bar AND ((box is armed AND close > box top AND prior close <= box top) OR (trend bias changes from bearish to bullish))
Short: Ready AND confirmed bar AND ((box is armed AND close < box bottom AND prior close >= box bottom) OR (trend bias changes from bullish to bearish))
Exit: Long, low <= entry price − stop distance OR high >= third target OR bars since entry > configured trade-map life
Exit: Short, high >= entry price + stop distance OR low <= third target OR bars since entry > configured trade-map life