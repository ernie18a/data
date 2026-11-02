Calculation: Bar delta = sum the volume of each completed lower-timeframe bar within the current chart bar as positive when its close >= open and negative otherwise; if no lower-timeframe bars are available, use chart-bar volume as positive when close >= open and negative otherwise.
Calculation: Cumulative volume delta = cumulative sum of bar delta.
Long: Bar delta >= 0.
Short: Bar delta < 0.
Long: Sum of bar delta over the lookback >= 0.
Short: Sum of bar delta over the lookback < 0.
Long: Close <= close at the divergence lookback AND cumulative volume delta > cumulative volume delta at the same lookback.
Short: Close > close at the divergence lookback AND cumulative volume delta <= cumulative volume delta at the same lookback.
Long: Volume >= its linearly interpolated percentile over the bubble lookback including the current bar AND bar delta >= 0.
Short: Volume >= its linearly interpolated percentile over the bubble lookback including the current bar AND bar delta < 0.
Long: Volume >= its linearly interpolated percentile over the absorption lookback including the current bar AND high - low < ATR multiplied by the absorption range factor AND bar delta >= 0.
Short: Volume >= its linearly interpolated percentile over the absorption lookback including the current bar AND high - low < ATR multiplied by the absorption range factor AND bar delta < 0.