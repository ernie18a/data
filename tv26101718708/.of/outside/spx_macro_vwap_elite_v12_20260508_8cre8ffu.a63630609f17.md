Signal-only logic evaluated on confirmed (closed) bars of the traded index, intraday. There is no exit logic: only long and short entry signals, each in normal or strong grade. Oil is fetched but never used in a decision. The default configuration is described, with optional gates listed at the end.

Inputs:
- Traded-instrument OHLCV.
- A running VWAP of the typical price (hlc3).
- A Hull moving average of close.
- ATR.
- The 10-year Treasury yield (outside data), sampled on the chart's timeframe and compared with its own short simple moving average. 'Yield rising' means yield is above that average.

Definitions:
- Body = absolute value of close minus open.
- Strong candle = body larger than a set fraction of ATR.
- Top fractal = a bar whose high is greater than the highs of the two bars before and the two bars after it. It is only known two bars later. Remember the most recent top fractal high as the resistance level.
- Bottom fractal = the mirror image using lows. Remember the most recent bottom fractal low as the support level.
- Bullish fractal break = close crosses above the remembered resistance level.
- Bearish fractal break = close crosses below the remembered support level.

Long base condition: close is above VWAP, and at least one of these setups holds:
- Bounce: the bar's low is at or below VWAP, close is above VWAP, the candle is bullish (close above open), and it is a strong candle.
- Reclaim: close crosses above VWAP, the candle is bullish, and it is a strong candle.
- Bullish fractal break.

Short base condition: close is below VWAP, and at least one of these setups holds:
- Rejection: the bar's high is at or above VWAP, close is below VWAP, the candle is bearish, and it is a strong candle.
- Breakdown: close is below VWAP while the previous close was at or above the previous VWAP, the candle is bearish, and it is a strong candle.
- Bearish fractal break.

Filter score. Count how many of four filters pass, separately for long and short:
1. Trend: for long the Hull MA is rising versus the prior bar, for short it is falling.
2. Volume: always passes in the default configuration. If enabled, volume must exceed its moving average.
3. Candle strength: the candle body exceeds a (larger) fraction of ATR, the same test for both directions.
4. Macro (10Y yield): for long the yield is NOT rising (at or below its average), for short the yield IS rising.

Final signals:
- Long signal = long base condition, AND long filter score of at least 3 of 4, AND momentum (close above the previous bar's high).
- Short signal = short base condition, AND short filter score of at least 3 of 4, AND momentum (close below the previous bar's low).
- Strong long = a long signal where the reclaim setup is true and all 4 filters pass.
- Strong short = a short signal where the breakdown setup is true and all 4 filters pass.
- A strong signal replaces the normal signal of the same direction.

Optional gates, all off by default and each passing trivially when off:
- A restriction to the morning and afternoon New York sessions.
- A requirement for a bullish or bearish candlestick pattern (pin bar, engulfing, piercing/dark cloud, harami) or a fractal break.
- A MACD histogram check: rising for long, falling for short.