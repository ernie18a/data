Calculation: Cumulative delta volume = cumulative sum of volume * ((close - low) - (high - close)) / (high - low), using zero when high = low
Calculation: Trend bullish votes = count of: EMA(close, short-term trend lookback) > EMA(close, long-term trend lookback); close > EMA(close, short-term trend lookback); close > AlphaTrend(ATR lookback, multiplier, MFI lookback, T1); ROC(close, CRS lookback) - ROC(benchmark close, CRS lookback) > 0; and, when multi-timeframe confirmation is enabled, close(T2) > EMA(close, short-term trend lookback, T2), otherwise EMA(close, short-term trend lookback) > EMA(close, long-term trend lookback). T1 and T2 values are sampled on chart bars from the requested timeframe bar, which is still forming in realtime and last completed on historical bars.
Calculation: Trend long evidence = 100 * trend bullish votes / total trend tests
Calculation: Trend short evidence = 100 * (total trend tests - trend bullish votes) / total trend tests
Calculation: Flow bullish score = weighted sum of: EMA(cumulative delta volume, short CDV lookback) > SMA(cumulative delta volume, long CDV lookback); change(cumulative delta volume, CDV slope lookback) > 0; percentrank(change(cumulative delta volume, CDV slope lookback), CDV normalization lookback) > acceleration threshold; and (change(close, CDV slope lookback) > 0) equals (change(cumulative delta volume, CDV slope lookback) > 0). The primary criterion has its own weight; the three confirmatory criteria share a separate weight.
Calculation: Flow long evidence = flow bullish score
Calculation: Flow short evidence = 100 - flow bullish score
Calculation: Relative ATR = ATR(ATR lookback) / SMA(ATR(ATR lookback), relative ATR lookback)
Calculation: Relative volume = volume / SMA(volume, volume average lookback)
Calculation: Opportunity votes = count of: relative ATR >= compression threshold and relative ATR <= expansion threshold * expansion multiplier; percentrank(ATR(ATR lookback), relative ATR lookback) is above its lower threshold and below its upper threshold; standard deviation(relative ATR, opportunity stability lookback) < standard deviation(relative ATR, longer opportunity comparison lookback); and relative ATR > relative ATR[opportunity stability lookback] or relative ATR <= compression threshold
Calculation: Opportunity quality = 100 * opportunity votes / total opportunity tests
Calculation: Opportunity confidence = normalized absolute distance of opportunity votes from the midpoint of its possible range
Calculation: Participation quality = 100 * count of: relative volume > average-volume threshold; SMA(relative volume, volume persistence lookback) > average-volume threshold; standard deviation(relative volume, volume persistence lookback) < standard deviation(relative volume, longer participation comparison lookback); relative volume > exceptional-volume threshold, divided by total participation tests
Calculation: Participation confidence = normalized absolute distance of participation votes from the midpoint of its possible range
Calculation: Momentum bullish votes = count of: MFI(hlc3, MFI lookback) > MFI(hlc3, MFI lookback)[MFI slope lookback]; SMA(MFI(hlc3, MFI lookback), MFI slope lookback) > its value MFI slope lookback bars ago; MFI(hlc3, MFI lookback) > MFI midpoint
Calculation: Momentum long evidence = 100 * momentum bullish votes / total momentum tests
Calculation: Momentum short evidence = 100 * (total momentum tests - momentum bullish votes) / total momentum tests
Calculation: Directional regime bias = trend bias weight * (trend long evidence - trend short evidence) + flow bias weight * (flow long evidence - flow short evidence) + momentum bias weight * (momentum long evidence - momentum short evidence)
Calculation: Regime stability score = clamp(regime stable bars / regime stability lookback * 100, 0, 100), where regime stable bars counts consecutive chart bars since the regime changed
Calculation: Total penalty = clamp(sum of separate penalties for EMA structure conflicting with AlphaTrend; price change conflicting with CDV change; relative volume below its weakness threshold; opportunity confidence below its deterioration threshold; momentum votes opposing the trend evidence; regime stable bars below the penalty stability threshold; and enabled higher-timeframe confirmation conflicting with EMA structure), 0, penalty cap
Calculation: Long composite score = weighted mean of trend long evidence, flow long evidence, opportunity quality, participation quality, and momentum long evidence, using separate weights selected for the current regime
Calculation: Short composite score = weighted mean of trend short evidence, flow short evidence, opportunity quality, participation quality, and momentum short evidence, using separate weights selected for the current regime
Calculation: Final long score = clamp(long composite score - total penalty, 0, 100)
Calculation: Final short score = clamp(short composite score - total penalty, 0, 100)
Calculation: Final confidence = clamp(the current-regime weighted mean of trend, flow, opportunity, participation, and momentum confidence, plus the enabled multi-timeframe alignment adjustment, plus the regime stability adjustment, minus the scaled total penalty, 0, 100)
Calculation: Long grade score = clamp(the weighted sum of final long score, final confidence, opportunity quality, participation quality, momentum long evidence, regime stability score, MFI, clamped relative volume score, clamped relative ATR score, and clamped comparative relative strength score, plus one bonus for each of bullish regime, strong trend evidence, strong flow evidence, aligned multi-timeframe confirmation, and close above AlphaTrend, 0, 100). Each component has its own grade weight; each qualifying bonus uses the same bonus parameter.
Calculation: Short grade score = clamp(the weighted sum of final short score, final confidence, opportunity quality, participation quality, momentum short evidence, regime stability score, 100 - MFI, clamped relative volume score, clamped relative ATR score, and clamped inverse comparative relative strength score, plus one bonus for each of bearish regime, strong bearish trend evidence, strong falling flow evidence, aligned multi-timeframe confirmation, and close at or below AlphaTrend, 0, 100). Each component has its own grade weight; each qualifying bonus uses the same bonus parameter.
Long: trend long evidence > trend short evidence
Short: trend short evidence > trend long evidence
Long: change(cumulative delta volume, CDV slope lookback) > 0
Short: change(cumulative delta volume, CDV slope lookback) <= 0
Long: EMA(cumulative delta volume, short CDV lookback) > SMA(cumulative delta volume, long CDV lookback)
Short: EMA(cumulative delta volume, short CDV lookback) <= SMA(cumulative delta volume, long CDV lookback)
Long: close > AlphaTrend(ATR lookback, multiplier, MFI lookback, T1)
Short: close <= AlphaTrend(ATR lookback, multiplier, MFI lookback, T1)
Long: directional regime bias > bull/bear threshold and opportunity quality >= minimum opportunity threshold and prior regime was not Bull Trend
Short: directional regime bias < -bull/bear threshold and opportunity quality >= minimum opportunity threshold and prior regime was not Bear Trend
Long: final long score crosses above the long alert threshold
Short: final short score crosses above the short alert threshold
Long: long grade score >= short grade score
Short: long grade score < short grade score