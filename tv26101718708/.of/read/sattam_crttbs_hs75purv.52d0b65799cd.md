Calculation: CRT range = high and low of one completed higher-timeframe bar; replace it with a new range after completion, invalidation, or manipulation timeout
Calculation: CRT manipulation = on a later completed higher-timeframe bar, wick beyond one range boundary and close back inside; if both boundaries are swept, use the side with the larger wick excursion
Calculation: Active key level = an unmitigated higher-timeframe old high/low pivot zone, last opposite candle before a displacement whose body exceeds the recent average body by a configurable multiple, or three-bar fair-value gap; deactivate when fully crossed
Calculation: Key-level confluence = active key-level zone overlaps the CRT manipulation sweep, allowing a tolerance based on higher-timeframe average range
Calculation: TBS swing high/low = most recent confirmed chart-timeframe pivot high/low
Calculation: Opposing-candle extreme = low of the most recent bullish chart-timeframe candle for bearish setups; high of the most recent bearish chart-timeframe candle for bullish setups
Calculation: CISD level = open of the oldest candle in the latest consecutive run of bullish candles for bearish setups; open of the oldest candle in the latest consecutive run of bearish candles for bullish setups
Calculation: MSS reference = most recent confirmed chart-timeframe pivot low for bearish setups; pivot high for bullish setups, captured when TBS confirms
Calculation: Bearish FVG = gap where current high is below the high two bars earlier; zone spans current high to the earlier bar's low
Calculation: Bullish FVG = gap where current low is above the low two bars earlier; zone spans the earlier bar's high to current low
Calculation: Accumulation/distribution compression = highest high minus lowest low over a lookback is below ATR(200) times a configurable factor scaled by the square root of the lookback
Calculation: Internal pivot = chart-timeframe pivot high/low confirmed by equal-length bars on either side
Calculation: Stop = beyond the more extreme of the TBS sweep and CRT manipulation extreme, with an ATR buffer; move stop to entry after TP1
Calculation: TP1 = CRT range midpoint; TP2 = opposite CRT range boundary; TP3 = extension beyond that boundary by a configurable range multiple
Long: Bullish CRT manipulation is active AND (key-level confluence is present or key-level requirement is disabled) AND a chart-timeframe close is below the most recent pivot low AND a subsequent qualifying close is above the most recent bearish candle high AND outside configured blocked hours AND (close > previous bar high [Model #1] OR close > CISD level [CISD] OR close > MSS reference followed by bullish FVG formation and a retrace to its upper boundary [MSS+FVG]); each selected entry model fires once per setup
Short: Bearish CRT manipulation is active AND (key-level confluence is present or key-level requirement is disabled) AND a chart-timeframe close is above the most recent pivot high AND a subsequent qualifying close is below the most recent bullish candle low AND outside configured blocked hours AND (close < previous bar low [Model #1] OR close < CISD level [CISD] OR close < MSS reference followed by bearish FVG formation and a retrace to its lower boundary [MSS+FVG]); each selected entry model fires once per setup
Long: Compressed range closes above its top
Short: Compressed range closes below its bottom
Long: An un-crossed internal pivot low is swept by a wick and the bar closes above it
Short: An un-crossed internal pivot high is swept by a wick and the bar closes below it
Long: Current high > previous completed daily high AND close < previous completed daily high [daily bias toward previous daily low]
Short: Current low < previous completed daily low AND close > previous completed daily low [daily bias toward previous daily high]
Long: Close > previous completed daily high
Short: Close < previous completed daily low
Exit: Long, low <= current stop OR high >= TP3; check stop before targets
Exit: Short, high >= current stop OR low <= TP3; check stop before targets