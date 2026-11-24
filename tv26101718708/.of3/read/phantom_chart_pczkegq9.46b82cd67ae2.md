Calculation: Heikin Ashi candle = Heikin Ashi transform of open, high, low, close
Calculation: HA up = Heikin Ashi close >= Heikin Ashi open
Calculation: strong bull = HA up AND abs(Heikin Ashi low - min(Heikin Ashi open, Heikin Ashi close)) < wick tolerance
Calculation: strong bear = NOT HA up AND abs(Heikin Ashi high - max(Heikin Ashi open, Heikin Ashi close)) < wick tolerance
Calculation: strong candle = strong bull OR strong bear
Calculation: source = source choice applied to open, high, low, close, optionally smoothed by moving average of smoothing length
Calculation: baseline = baseline level, or (high + low) / 2 of the first chart bar when baseline is automatic
Calculation: body = abs(close - open)
Calculation: candle range = high - low
Calculation: upper shadow = high - max(open, close)
Calculation: lower shadow = min(open, close) - low
Calculation: context EMA = EMA(close, context length)
Calculation: trend EMA = EMA(close, trend length)
Calculation: osc = oscillator(close, high, low, osc length)
Calculation: pivot low = PivotLow(osc, pivot left, pivot right) exists on this bar
Calculation: pivot high = PivotHigh(osc, pivot left, pivot right) exists on this bar
Calculation: LowOsc(n) = osc at the pivot bar of the nth most recent pivot low, n = 0 is the latest
Calculation: LowPrice(n) = low at the pivot bar of the nth most recent pivot low
Calculation: HighOsc(n) = osc at the pivot bar of the nth most recent pivot high
Calculation: HighPrice(n) = high at the pivot bar of the nth most recent pivot high
Long: HA up AND NOT HA up[1]
Short: NOT HA up AND HA up[1]
Long: strong bull
Short: strong bear
Long: strong bull AND NOT strong candle[1]
Short: strong bear AND NOT strong candle[1]
Long: source crosses above baseline
Short: source crosses below baseline
Long: source >= baseline
Short: source < baseline
Long: HA up
Short: NOT HA up
Long: Heikin Ashi close >= Heikin Ashi close[1]
Short: Heikin Ashi close < Heikin Ashi close[1]
Long: close > trend EMA
Short: close <= trend EMA
Long: body > 0 AND lower shadow >= wick ratio * body AND upper shadow <= body AND close < context EMA
Long: body > 0 AND upper shadow >= wick ratio * body AND lower shadow <= body AND close < context EMA
Long: candle range > 0 AND body <= doji threshold * candle range AND lower shadow >= long shadow fraction * candle range AND upper shadow <= short shadow fraction * candle range
Long: close[1] < open[1] AND close > open AND abs(low - low[1]) <= max(tick size, tweezer fraction * candle range)
Long: candle range > 0 AND close > open AND body >= marubozu fraction * candle range
Long: close[1] < open[1] AND close > open AND close >= open[1] AND open <= close[1]
Long: close[1] < open[1] AND close > open AND open >= close[1] AND close <= open[1] AND body < body[1]
Long: close[2] < open[2] AND body[1] < star body fraction * body[2] AND close > open AND close > (open[2] + close[2]) / 2
Long: close > open AND close[1] > open[1] AND close[2] > open[2] AND close > close[1] AND close[1] > close[2] AND open < close[1] AND open > open[1] AND open[1] < close[2] AND open[1] > open[2]
Long: close[1] < open[1] AND close > open AND open < close[1] AND close > (open[1] + close[1]) / 2 AND close < open[1]
Short: body > 0 AND lower shadow >= wick ratio * body AND upper shadow <= body AND close > context EMA
Short: body > 0 AND upper shadow >= wick ratio * body AND lower shadow <= body AND close > context EMA
Short: candle range > 0 AND body <= doji threshold * candle range AND upper shadow >= long shadow fraction * candle range AND lower shadow <= short shadow fraction * candle range
Short: close[1] > open[1] AND close < open AND abs(high - high[1]) <= max(tick size, tweezer fraction * candle range)
Short: candle range > 0 AND close < open AND body >= marubozu fraction * candle range
Short: close[1] > open[1] AND close < open AND open >= close[1] AND close <= open[1]
Short: close[1] > open[1] AND close < open AND open <= close[1] AND close >= open[1] AND body < body[1]
Short: close[2] > open[2] AND body[1] < star body fraction * body[2] AND close < open AND close < (open[2] + close[2]) / 2
Short: close < open AND close[1] < open[1] AND close[2] < open[2] AND close < close[1] AND close[1] < close[2] AND open > close[1] AND open < open[1] AND open[1] > close[2] AND open[1] < open[2]
Short: close[1] > open[1] AND close < open AND open > close[1] AND close < (open[1] + close[1]) / 2 AND close > open[1]
Long: pivot low AND LowOsc(0) > LowOsc(1) AND LowPrice(0) < LowPrice(1)
Long: pivot low AND LowOsc(0) < LowOsc(1) AND LowPrice(0) > LowPrice(1)
Short: pivot high AND HighOsc(0) < HighOsc(1) AND HighPrice(0) > HighPrice(1)
Short: pivot high AND HighOsc(0) > HighOsc(1) AND HighPrice(0) < HighPrice(1)