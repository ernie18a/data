Calculation: Close-containment percentage(N) = 100 × count of close[i] between lowest(low[1], N) and highest(high[1], N), for i from 1 through N, divided by N
Calculation: Upper-half close percentage(N) = 100 × count of close[i] at or above (highest(high[1], N) + lowest(low[1], N)) / 2, for i from 1 through N, divided by N
Calculation: Range-width percentage(N) = 100 × (highest(high[1], N) - lowest(low[1], N)) / ((highest(high[1], N) + lowest(low[1], N)) / 2)
Calculation: Prior-advance percentage(N) = 100 × (highest(high[1], N) - lowest(low[N + 1], prior-move lookback)) / lowest(low[N + 1], prior-move lookback)
Calculation: Average bar-range percentage = SMA(100 × (high - low) / close, average-range lookback)
Calculation: Trend filter = (price-above-SMA requirement disabled OR close[1] > SMA(close, price-SMA lookback)[1]) AND (EMA(close, shorter EMA lookback)[1] >= EMA(close, longer EMA lookback)[1] OR close[1] >= EMA(close, longer EMA lookback)[1])
Calculation: Prior-move filter(N) = prior-move requirement disabled OR prior-advance percentage(N) >= minimum prior-advance percentage
Calculation: Range-volume filter(N) = volume-control requirement disabled OR SMA(volume[1], N) <= SMA(volume, volume-average lookback)[1] × maximum range-volume multiple
Calculation: RSI filter = RSI-control requirement disabled OR (RSI(close, RSI lookback)[1] >= minimum RSI AND RSI(close, RSI lookback)[1] <= maximum RSI)
Calculation: Standard-box valid = close-containment percentage(standard-box lookback) >= minimum containment percentage AND range-width percentage(standard-box lookback) <= average bar-range percentage[1] × maximum standard-box width multiple AND trend filter AND prior-move filter(standard-box lookback) AND range-volume filter(standard-box lookback) AND RSI filter
Calculation: Tight-shelf valid = close-containment percentage(tight-shelf lookback) >= minimum containment percentage AND upper-half close percentage(tight-shelf lookback) >= minimum upper-half percentage AND range-width percentage(tight-shelf lookback) <= average bar-range percentage[1] × maximum tight-shelf width multiple AND trend filter AND prior-move filter(tight-shelf lookback) AND range-volume filter(tight-shelf lookback) AND RSI filter
Calculation: Active range valid = tight-shelf valid OR standard-box valid
Calculation: Active range high = if tight-shelf valid, highest(high[1], tight-shelf lookback), otherwise highest(high[1], standard-box lookback); tight-shelf lookback is shorter than standard-box lookback
Calculation: Active range low = if tight-shelf valid, lowest(low[1], tight-shelf lookback), otherwise lowest(low[1], standard-box lookback); tight-shelf lookback is shorter than standard-box lookback
Long: active range valid AND close > active range high AND volume > SMA(volume, volume-average lookback)
Long: active range valid AND close > active range high AND volume <= SMA(volume, volume-average lookback)
Short: active range valid AND close < active range low