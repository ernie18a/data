Calculation: Weight = volume if volume > 0, else 1, when SMA(volume, lookback) > 0; otherwise high - low
Calculation: POC = midpoint of the row with the largest smoothed row volume, where over the last lookback bars the price range from lowest low to highest high is split into row count equal rows, each bar adds Weight x (overlap of its high-low range with the row) / (high - low) to that row, row volumes are smoothed by a 3-row triangular kernel with a missing neighbor replaced by the row itself, and ties go to the lowest row
Calculation: BullBias = sum over the last lookback bars of Weight x BullShare, divided by sum over the same bars of Weight, where BullShare = up-candle base share + up-candle slope x (close - low) / (high - low) if close >= open, otherwise down-candle base share + down-candle slope x (close - low) / (high - low)
Calculation: Pressure = pressure scale x (close - EMA(close, EMA period)) / ATR(high, low, close, ATR period) + candle direction tilt if close >= open, otherwise - candle direction tilt, where high - low replaces ATR when ATR is undefined
Long: close crosses above POC
Short: close crosses below POC
Long: BullBias > upper bias threshold
Short: BullBias < lower bias threshold
Long: Pressure > 0
Short: Pressure < 0