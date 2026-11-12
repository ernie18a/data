Trade the chart instrument (gold) long or short using mean-reversion at support/resistance zones, gated by the trend bias of an external instrument (the US Dollar Index, DXY). There is no exit rule; the output is only a buy or sell entry signal.

1. Build S/R zones from the traded instrument's own price history. Detect confirmed swing highs and lows (a pivot needs N bars on each side). Keep only pivots within a limited lookback window. Cluster nearby pivots into zones: a zone is a band whose total height cannot exceed a volatility-scaled width (ATR times a multiplier). Score each zone by pivot count (heavily weighted) plus the number of bars in the lookback whose high-low range touched the band. Discard zones below a minimum strength. Pick the strongest zones greedily, skipping any pivot already absorbed by a chosen zone, and cap the number of active zones.

2. Invalidate broken zones permanently. If the previous close was entirely below a zone (it was resistance) and the current close is above its top, or the previous close was entirely above a zone (it was support) and the current close is below its bottom, remove the zone. Remember it so it is not revived when zones are recomputed.

3. Detect touches on each bar. A support touch occurs when the close is above a zone's top and the bar's low wicked into the zone (low at or below the top and at or above the bottom). A resistance touch occurs when the close is below a zone's bottom and the bar's high wicked into the zone (high at or above the bottom and at or below the top). Store the touched level for the next bar.

4. Confirm the rejection on the following bar. A raw BUY occurs if the prior bar registered a support touch at some level, the close before the current bar was at or below that level, and the current close is above it. A raw SELL occurs if the prior bar registered a resistance touch at some level, the close before the current bar was at or above that level, and the current close is below it. Update the stored touch levels after evaluating this.

5. Apply the DXY bias filter, which is on by default. For DXY, on each of the daily and 4-hour timeframes, compute bias as the timeframe's close minus its simple moving average of close (a fixed length, the same on both timeframes). Fetch these without lookahead. Positive means bullish, negative means bearish, and missing data means no confirmation.
- DXY is bearish-confirmed only if both daily and 4-hour bias are available and negative.
- DXY is bullish-confirmed only if both are available and positive.
- Final BUY (go long gold) = raw BUY and DXY bearish-confirmed.
- Final SELL (go short gold) = raw SELL and DXY bullish-confirmed.
If the filter is disabled, the final signals equal the raw signals.

The rationale is that gold and DXY move inversely, so counter-trend setups are filtered out.