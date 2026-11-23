Calculation: candle = OHLCV of the chart bar, or, when candle source is T1, OHLCV of the last completed T1 bar held on chart bars
Calculation: candle ATR = ATR(ATR length) of the chart bars, or, when candle source is T1, ATR(ATR length) of T1 bars taken as the last completed value held on chart bars
Calculation: RangePos(x, n) = 100 * (x - lowest(x, n)) / (highest(x, n) - lowest(x, n)), or 50 when highest(x, n) equals lowest(x, n)
Calculation: volume score = RangePos(candle volume, shorter lookback) / 100
Calculation: body efficiency = (candle close - candle open) / (candle high - candle low), or 0 when candle high equals candle low
Calculation: ghost volume = 100 * volume score * (1 - min(1, abs(candle close - candle open) / candle ATR))
Calculation: inertia = clamp((candle close - candle open) * (candle close[1] - candle open[1]) / candle ATR^2, -inertia clip, inertia clip), or 0 when candle ATR is zero
Calculation: raw pressure = weight 1 * body efficiency + weight 2 * (candle open + candle close - candle high - candle low) / (candle high - candle low) + weight 3 * body efficiency * volume score + weight 4 * inertia + weight 5 * (2 * candle close - candle high - candle low) / (candle high - candle low) - weight 6 * ghost volume, with each division taken as 0 when candle high equals candle low
Calculation: pressure = EMA(2 * RangePos(raw pressure, longer lookback) - 100, smoothing length)
Calculation: acceleration = (pressure - pressure[1]) - (pressure[1] - pressure[2])
Calculation: acceleration score = RangePos(acceleration, shorter lookback) - 50
Calculation: fake bullish move = candle close > candle close[2] AND pressure > -fake threshold AND pressure < fake threshold AND candle close >= candle open
Calculation: fake bearish move = candle close < candle close[2] AND pressure > -fake threshold AND pressure < fake threshold AND candle close < candle open
Calculation: absorption state = ghost volume >= absorption threshold
Calculation: spacing ok = bars since the last bar on which a fake or absorption label was placed > spacing length
Long: pressure crosses above strong bull threshold AND NOT fake bullish move
Long: pressure >= strong bull threshold AND NOT fake bullish move AND NOT fake bearish move AND NOT absorption state
Long: pressure > strong bull threshold
Long: pressure > 0 AND pressure < strong bull threshold AND NOT fake bullish move AND NOT fake bearish move AND NOT absorption state
Long: pressure > 0
Long: pressure >= 0
Long: fake bearish move
Long: fake bearish move[1] AND spacing ok
Long: absorption state[1] AND candle close[1] < candle open[1] AND NOT fake bullish move[1] AND NOT fake bearish move[1] AND spacing ok
Long: pressure[1] >= strong bull threshold AND NOT fake bullish move[1] AND NOT fake bearish move[1] AND NOT absorption state[1]
Long: acceleration score > upper accel threshold
Long: acceleration > 0
Long: body efficiency > upper dimension threshold
Long: inertia > upper dimension threshold
Short: pressure crosses below strong bear threshold AND NOT fake bearish move
Short: pressure <= strong bear threshold AND NOT fake bullish move AND NOT fake bearish move AND NOT absorption state
Short: pressure < strong bear threshold
Short: pressure < 0 AND pressure > strong bear threshold AND NOT fake bullish move AND NOT fake bearish move AND NOT absorption state
Short: pressure < 0
Short: fake bullish move
Short: fake bullish move[1] AND spacing ok
Short: absorption state[1] AND candle close[1] >= candle open[1] AND NOT fake bullish move[1] AND NOT fake bearish move[1] AND spacing ok
Short: pressure[1] <= strong bear threshold AND NOT fake bullish move[1] AND NOT fake bearish move[1] AND NOT absorption state[1]
Short: acceleration score < lower accel threshold
Short: acceleration <= 0
Short: body efficiency < lower dimension threshold
Short: inertia < lower dimension threshold