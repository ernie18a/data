Calculation: Timeframe data = For each enabled, ordered timeframe, request OHLCV and ADX. Relative to the chart timeframe, a higher timeframe uses the last completed bar on historical bars and the still-forming bar in real time; a lower timeframe uses the last available intrabar. The chart timeframe uses its current bar. Perform all subsequent calculations on the resulting chart-bar series, except ADX, which is calculated in the requested timeframe.
Calculation: Close position = (requested close - requested low) / max(requested high - requested low, minimum tick size).
Calculation: Buyer percentage = clamp(round(close position * 100), 0, 100).
Calculation: CVD = cumulative sum of requested volume * (2 * close position - 1), accumulated on chart bars.
Calculation: CVD direction = up when CVD exceeds every CVD value in a prior lookback; down when CVD is below every CVD value in that lookback; otherwise neutral. The up state takes precedence if both conditions hold.
Calculation: CVD momentum = up when the CVD EMA exceeds every prior EMA value in a shorter lookback; down when it is below every prior EMA value in that lookback. Building includes every up state; slowing requires down and not up.
Calculation: Freshness = elapsed minutes since CVD direction last changed, calculated as chart bars since the change multiplied by the requested timeframe duration; before any change, freshness is a large sentinel value.
Calculation: Bullish divergence = requested close below its lowest prior value over a divergence lookback AND CVD at or above its lowest prior value over that lookback.
Calculation: Bearish divergence = requested close above its highest prior value over the divergence lookback AND CVD at or below its highest prior value over that lookback. Bearish divergence takes precedence over bullish divergence for each timeframe.
Calculation: Direction scores = counts of enabled timeframes with CVD direction up or down. Weighted direction scores sum increasing weights in timeframe order for enabled up or down timeframes. Dominance requires the corresponding weighted score to exceed the opposite weighted score.
Calculation: Aggregate counts = counts of enabled timeframes with fresh CVD direction, building CVD momentum, slowing CVD momentum, and either divergence. Average ADX is the mean requested ADX across enabled timeframes. Alignment is the greater direction score.
Calculation: Strong trend = the corresponding weighted direction score is at or above its threshold AND average ADX is at or above its strong-trend threshold AND the fresh count is at or above its threshold.
Calculation: Active trend = corresponding dominance AND corresponding direction score at or above the lesser of its count threshold and the enabled timeframe count AND average ADX at or above its active-trend threshold AND building count at or above the lesser of its count threshold and the enabled timeframe count.
Calculation: Early expansion = both of the first two ordered timeframes are enabled AND both have the corresponding CVD direction AND corresponding dominance AND average ADX at or above its active-trend threshold AND building count at or above its early-expansion threshold.
Calculation: Late trend = alignment at or above the lesser of its count threshold and the enabled timeframe count AND (fresh count at or below its threshold OR slowing count at or above its threshold).
Calculation: Transition expansion = average ADX at or above its active-trend threshold AND building count at or above the lesser of its count threshold and the enabled timeframe count AND fresh count at or above its threshold AND alignment at or above the lesser of its count threshold and the enabled timeframe count.
Long: Buyer percentage at or above its bullish threshold AND CVD direction up, for an enabled timeframe.
Short: Buyer percentage at or below its bearish threshold AND CVD direction down, for an enabled timeframe.
Long: Bullish divergence for an enabled timeframe.
Short: Bearish divergence for an enabled timeframe.
Long: Bull direction score at or above the summary threshold, which depends on the enabled timeframe count.
Short: Bull direction score below its summary threshold AND bear direction score at or above its summary threshold.
Long: Both direction scores below their summary thresholds AND both of the first two ordered timeframes enabled AND both CVD directions up AND bullish dominance.
Short: Both direction scores below their summary thresholds AND both of the first two ordered timeframes enabled AND both CVD directions down AND bearish dominance.
Long: Bullish dominance.
Short: Bearish dominance.
Long: Divergence count equals zero AND strong bullish trend.
Short: Divergence count equals zero AND strong bearish trend AND no strong bullish trend.
Long: Divergence count equals zero AND neither strong trend is active AND active bullish trend.
Short: Divergence count equals zero AND neither strong trend is active AND no active bullish trend AND active bearish trend.
Long: Divergence count equals zero AND neither strong trend nor active trend is active AND early bullish expansion.
Short: Divergence count equals zero AND neither strong trend nor active trend is active AND no early bullish expansion AND early bearish expansion.
Long: Divergence count equals zero AND neither strong trend, active trend, nor early expansion is active AND late trend AND bullish dominance.
Short: Divergence count equals zero AND neither strong trend, active trend, nor early expansion is active AND late trend AND bearish dominance.
Long: Divergence count equals zero AND neither strong trend, active trend, nor early expansion is active AND no late trend AND transition expansion AND bullish dominance.
Short: Divergence count equals zero AND neither strong trend, active trend, nor early expansion is active AND no late trend AND transition expansion AND bearish dominance.