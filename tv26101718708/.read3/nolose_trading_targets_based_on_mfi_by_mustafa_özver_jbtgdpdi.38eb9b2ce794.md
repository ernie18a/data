Calculation: Weighted price movement = delta(WMA(reference source, smoothing lookback)) * (WMA(volume, smoothing lookback) > 0 ? WMA(volume, smoothing lookback) : 1)
Calculation: Volume-weighted RSI = 100 - 100 / (1 + RMA(max(weighted price movement, 0), RSI lookback) / RMA(max(-weighted price movement, 0), RSI lookback))
Calculation: Range position = (WMA(reference source, smoothing lookback) - lowest(low, range lookback)) / (highest(high, range lookback) - lowest(low, range lookback)), where the range lookback is longer than the RSI lookback
Calculation: Green setup = volume-weighted RSI < lower RSI threshold AND volume-weighted RSI > volume-weighted RSI[1] AND range position < lower range threshold
Calculation: Red setup = volume-weighted RSI > 100 - lower RSI threshold AND volume-weighted RSI > volume-weighted RSI[1] AND range position > upper range threshold
Calculation: Green candidate = green setup[1] OR green area active[1]
Calculation: Red candidate = red setup[1] OR red area active[1]
Calculation: Green boundary = if green candidate then green boundary[1] else max(ohlc4, hlc3, hl2)
Calculation: Green low = if green candidate then min(green low[1], low) else low
Calculation: Red boundary = if red candidate then red boundary[1] else min(ohlc4, hlc3, hl2)
Calculation: Red high = if red candidate then max(red high[1], high) else high
Calculation: Green target = green retracement parameter * (green boundary - green low) + green low
Calculation: Red target = red retracement parameter * (red high - red boundary) + red boundary
Calculation: Green area active = green candidate AND NOT (red setup OR green target[1] < high)
Calculation: Red area active = red candidate AND NOT (green setup OR red target[1] > low)
Calculation: Setup upper endpoint = if green area active then green boundary else red high
Calculation: Setup lower endpoint = if red area active then red boundary else green low
Calculation: Verified setup = (green area active OR red area active) AND setup upper endpoint / setup lower endpoint > 1 + tolerance parameter AND setup upper endpoint + setup lower endpoint = (setup upper endpoint + setup lower endpoint)[1]
Long: green setup AND green area inactive
Long: green area active AND verified setup
Short: red setup AND red area inactive
Short: red area active AND verified setup