Calculation: Bullish/bearish ribbon = count of adjacent moving-average pairs in the eight-line ribbon where the shorter-lookback average is above/below the next longer-lookback average; count meets the configured alignment threshold (bearish reverses the comparison).
Calculation: Higher-timeframe bullish/bearish = higher-timeframe close above/below its shorter-lookback EMA, with that EMA above/below its longer-lookback EMA; use the requested higher-timeframe bar as returned with lookahead off (last completed historically, forming in real time).
Calculation: Bullish/bearish order flow = (cumulative candle volume delta above/below its moving average while price falls/rises and delta rises/falls, OR buying volume divided by max(selling volume, 1) above 1 + threshold / below 1 − threshold) AND (close crosses above/below session VWAP or is above/below session VWAP). Candle volume delta is volume on up-close candles minus volume on down-close candles.
Calculation: Bullish/bearish order-flow filter = order-flow analysis disabled OR (matching bullish/bearish order flow OR close above/below session VWAP).
Calculation: Bullish/bearish smart-money filter = smart-money analysis disabled OR (matching bullish/bearish smart-money event OR matching bullish/bearish order block OR matching bullish/bearish fair-value gap).
Calculation: Bullish/bearish order block = current candle closes up/down, previous candle closes down/up, and current close is within the top/bottom 30% of its range.
Calculation: Bullish/bearish fair-value gap = current low/high is above/below the high/low two bars earlier by more than the configured ATR multiple.
Calculation: High/low liquidity grab = current high/low exceeds the highest/lowest high/low of the prior lookback bars, and current candle closes down/up back below/above that prior extreme.
Calculation: Bullish/bearish break of structure = close crosses above the latest confirmed pivot high / below the latest confirmed pivot low; pivot lookback is equal on both sides.
Calculation: Bullish/bearish smart-money event = smart-money analysis enabled AND (bullish/bearish order block OR bullish/bearish fair-value gap OR low/high liquidity grab OR bullish/bearish break of structure).
Calculation: Trend regime = ADX above its threshold. Range regime = ADX at or below its threshold.
Calculation: Bullish/bearish trend = fast EMA above/below slow EMA AND close above/below the trend-filter EMA.
Calculation: Volume spike = volume exceeds its moving average times the configured multiplier.
Calculation: Bullish/bearish trend entry setup = trend regime AND matching bullish/bearish trend AND fast EMA crosses above/below slow EMA AND volume spike.
Calculation: Bullish/bearish breakout setup = close above the prior bar's highest high / below the prior bar's lowest low over the breakout lookback AND volume spike AND close above/below the trend-filter EMA.
Calculation: Bullish/bearish mean-reversion setup = range regime AND close below/above the lower/upper Bollinger Band AND RSI below/above its oversold/overbought threshold AND RSI crosses up through the oversold threshold / down through the overbought threshold.
Long: (bullish trend entry setup OR bullish breakout setup OR bullish mean-reversion setup) AND higher-timeframe bullish filter enabled or bullish AND ribbon filter enabled or bullish AND bullish order-flow filter AND bullish smart-money filter AND within configured trading session AND flat position
Long: bullish break of structure
Long: low liquidity grab
Long: bullish order block
Long: bullish fair-value gap
Short: (bearish trend entry setup OR bearish breakout setup OR bearish mean-reversion setup) AND higher-timeframe bearish filter enabled or bearish AND ribbon filter enabled or bearish AND bearish order-flow filter AND bearish smart-money filter AND within configured trading session AND flat position
Short: bearish break of structure
Short: high liquidity grab
Short: bearish order block
Short: bearish fair-value gap
Exit: long, price reaches entry price minus ATR at entry times stop multiplier OR trailing stop is hit after price advances by the configured activation distance OR (trailing stop disabled AND price reaches entry price plus ATR at entry times target multiplier)
Exit: short, price reaches entry price plus ATR at entry times stop multiplier OR trailing stop is hit after price declines by the configured activation distance OR (trailing stop disabled AND price reaches entry price minus ATR at entry times target multiplier)