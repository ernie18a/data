Calculation: Fast/slow EMA direction = +1 when the shorter-lookback EMA of close is above the longer-lookback EMA, -1 when below, otherwise 0; use the last completed higher-timeframe bar, with the same lookbacks on all three higher timeframes.
Calculation: Full bias = the common nonzero EMA direction when all three higher-timeframe directions agree; otherwise 0.
Calculation: Swing structure = up when the latest confirmed pivot high and low are both higher than their respective preceding pivots; down when both are lower; otherwise retain the prior direction. Use the same pivot lookback on highs and lows.
Calculation: OTE zone = the interval between the latest confirmed swing high minus 0.618 and 0.786 of the swing range; a bar is in the zone when its high-low range overlaps the interval.
Calculation: Range filter = ADX is below its threshold on the chart timeframe.
Calculation: M15 bullish order block = the preceding down bar's high-low range when a subsequent up bar has body/range at least the displacement threshold and closes above the preceding bar's high; bearish order block is the reverse. Use completed lower-timeframe bars.
Calculation: Bullish order-block rejection = after a chart bar closes above the bullish block's top, a bar overlaps the block, closes up, touches or passes the top with its low, and its lower wick is at least the rejection fraction of its range. Bearish rejection is the reverse.
Calculation: Sniper score = count of present setup-direction confirmations among displacement, fair-value gap, order-block retest, and shift, minus one if an opposite-direction displacement occurs, floored at zero. Evaluate the lower-timeframe bars within the chart bar; a displacement has body/range above its threshold, a fair-value gap is a three-bar gap, a shift breaks the running prior high/low, and a retest is an order-block touch.
Long: full bias is up AND the chart bar overlaps the OTE zone AND swing structure is not down AND ADX is not below its threshold AND macro block is off AND bullish order-block rejection AND lower-timeframe direction agrees with full bias AND sniper score is at least its threshold.
Short: full bias is down AND the chart bar overlaps the OTE zone AND swing structure is not up AND ADX is not below its threshold AND macro block is off AND bearish order-block rejection AND lower-timeframe direction agrees with full bias AND sniper score is at least its threshold.
Calculation: Market-structure event = bullish BOS when structure trend is up and close crosses above the latest pivot high; bearish BOS when trend is down and close crosses below the latest pivot low. CHoCH is the opposite-direction close crossing the protected pivot low/high, respectively; it changes the trend to the crossing direction. Use confirmed pivots and chart-timeframe closes.
Long: bullish BOS OR bullish CHoCH.
Short: bearish BOS OR bearish CHoCH.
Calculation: Equal-high/low sweep = at least two of the preceding lookback bars have highs (or lows) within the sweep tolerance of the preceding lookback's highest high (or lowest low); a high sweep has current high above that level and close below it, and a low sweep has current low below that level and close above it.
Long: equal-low sweep.
Short: equal-high sweep.
Long: bullish CHoCH AND a low sweep occurred within the sweep lookback.
Short: bearish CHoCH AND a high sweep occurred within the sweep lookback.
Long: latest two confirmed pivot lows are within the double-bottom tolerance.
Short: latest two confirmed pivot highs are within the double-top tolerance.
Long: full bias is up.
Short: full bias is down.
Calculation: Effective stop = initial stop until price reaches entry plus (or minus for short) 70% of the absolute distance from entry to target 1; after that, effective stop is entry. Initial long stop is OTE bottom minus the stop buffer; initial short stop is OTE top plus the stop buffer.
Exit: long, low <= effective stop OR high >= target 3.
Exit: short, high >= effective stop OR low <= target 3.