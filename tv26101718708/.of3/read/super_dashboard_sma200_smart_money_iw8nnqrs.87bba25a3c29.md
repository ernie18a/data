Calculation: candle body-to-range ratio = if high > low then abs(close - open) / (high - low) else 0
Calculation: buyer volume percentage = if volume > 0 then ((if high != low then volume * (close - low) / (high - low) else 0) / volume) * 100 else 0
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND close > SMA(close, lookback longer than the longer EMA lookback)
Short: EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND close < SMA(close, lookback longer than the longer EMA lookback)
Long: close > SMA(close, lookback longer than the longer EMA lookback)
Short: close < SMA(close, lookback longer than the longer EMA lookback)
Long: buyer volume percentage > upper buyer-share threshold
Short: buyer volume percentage < lower seller-share threshold
Long: volume > SMA(volume, volume lookback) * volume multiplier AND candle body-to-range ratio > candle-strength threshold AND close > EMA(close, shorter EMA lookback) AND close > open
Short: volume > SMA(volume, volume lookback) * volume multiplier AND candle body-to-range ratio > candle-strength threshold AND close < EMA(close, shorter EMA lookback) AND close < open
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND close > SMA(close, lookback longer than the longer EMA lookback) AND volume > SMA(volume, volume lookback) * volume multiplier AND candle body-to-range ratio > candle-strength threshold AND close > EMA(close, shorter EMA lookback) AND close > open
Short: EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND close < SMA(close, lookback longer than the longer EMA lookback) AND volume > SMA(volume, volume lookback) * volume multiplier AND candle body-to-range ratio > candle-strength threshold AND close < EMA(close, shorter EMA lookback) AND close < open