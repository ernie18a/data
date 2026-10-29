Calculation: EMA(fast) = exponential moving average of close; fast lookback is shorter than mid, which is shorter than slow. Compute on each assigned timeframe; use its current bar, including a still-forming bar when that timeframe is higher than the chart timeframe.
Calculation: MACD = difference between the shorter-lookback and longer-lookback EMAs of close; signal line is an EMA of MACD, and histogram is MACD minus signal line. Use each assigned timeframe's current bar, including a still-forming higher-timeframe bar.
Calculation: Ichimoku cloud = area between Span A, the mean of the 9-bar and 26-bar high-low midpoints, and Span B, the 52-bar high-low midpoint; use the unshifted spans. Use each assigned timeframe's current bar, including a still-forming higher-timeframe bar.
Calculation: Cumulative volume delta = cumulative sum of volume × (2 × close − high − low) / (high − low), or zero when high equals low. Use each assigned timeframe's current bar, including a still-forming higher-timeframe bar.
Calculation: Market structure direction = direction of the latest break of a confirmed pivot high or low; confirm pivots with the same configurable number of bars on each side, and confirm breaks using either close or wick. Use each assigned timeframe's current bar, including a still-forming higher-timeframe bar.
Calculation: Directional score = sum of the votes for fast/mid EMA relation, mid/slow EMA relation, close/fast EMA relation, MACD, RSI, SuperTrend, Ichimoku cloud, and (when volume is available) cumulative volume delta. Each vote is +1, −1, or 0.
Long: fast EMA > mid EMA
Short: fast EMA < mid EMA
Long: mid EMA > slow EMA
Short: mid EMA < slow EMA
Long: close > fast EMA
Short: close < fast EMA
Long: MACD line > signal line AND MACD histogram > 0
Short: MACD line < signal line AND MACD histogram < 0
Long: RSI ≥ bullish threshold
Short: RSI ≤ bearish threshold
Long: SuperTrend indicates bullish direction
Short: SuperTrend indicates bearish direction
Long: close > upper Ichimoku cloud boundary
Short: close < lower Ichimoku cloud boundary
Long: cumulative volume delta > its value at the longer lookback AND close > its value at that lookback, when volume is available
Short: cumulative volume delta < its value at the longer lookback AND close < its value at that lookback, when volume is available
Long: +DI > −DI AND ADX ≥ trend threshold
Short: +DI ≤ −DI AND ADX ≥ trend threshold
Long: close ≥ highest close over the divergence lookback AND RSI < highest RSI over that lookback
Short: close ≤ lowest close over the divergence lookback AND RSI > lowest RSI over that lookback
Long: close ≥ highest close over the volume-divergence lookback AND OBV < highest OBV over that lookback
Short: close ≤ lowest close over the volume-divergence lookback AND OBV > lowest OBV over that lookback
Long: latest confirmed pivot high is broken above
Short: latest confirmed pivot low is broken below
Long: directional score ≥ 3
Short: directional score ≤ −3
Long: directional score crosses from ≤ 2.5 to > 2.5
Short: directional score crosses from ≥ −2.5 to < −2.5
Long: every visible assigned timeframe has directional score ≥ 3
Short: every visible assigned timeframe has directional score ≤ −3