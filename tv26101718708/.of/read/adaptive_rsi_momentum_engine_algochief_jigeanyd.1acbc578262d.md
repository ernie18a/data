Calculation: RSI channel = select one: Bollinger bands of RSI; EMA of RSI plus or minus a multiplier times EMA of the absolute RSI change; or the midpoint of the rolling highest and lowest RSI plus or minus a multiplier times half their range.
Calculation: RSI smoothing = a selected SMA, EMA, RMA, WMA, or VWMA of RSI; for VWMA, use SMA on bars whose volume is not positive.
Calculation: Confirmed RSI pivot = an RSI high or low with the same number of bars on each side; evaluate it when the right-side bars have completed. Compare consecutive confirmed pivots of the same type and use the price high or low on each RSI pivot bar.
Calculation: Reversal deviation levels = after the latest bullish or bearish reversal, retain RSI on the signal bar plus or minus, respectively, a multiplier times the RSI standard deviation; retain a second level using twice that multiplier. Cap upper levels at the RSI maximum and lower levels at the RSI minimum. Replace both levels on the next reversal.
Calculation: Divergence deviation levels = calculate and retain levels in the same way as reversal deviation levels, using the latest regular or hidden divergence and a separate multiplier. Replace both levels on the next divergence.
Calculation: Dashboard signals = calculate RSI from close on each selected higher or lower timeframe using its last completed bar; for a lower timeframe, use the last completed lower-timeframe bar within the chart bar. Apply the same reversal, channel breakout, and regular divergence comparisons as on the chart timeframe, with an independently parameterized divergence pivot lookback. For each signal category, retain the number of timeframe bars since the most recent bullish and bearish signals.
Long: RSI is at or below the oversold threshold.
Short: RSI is at or above the overbought threshold.
Long: Previous RSI is below RSI two bars ago AND current RSI is above previous RSI AND (previous RSI is at or below the oversold threshold OR previous RSI is at or below the previous lower RSI channel).
Short: Previous RSI is above RSI two bars ago AND current RSI is below previous RSI AND (previous RSI is at or above the overbought threshold OR previous RSI is at or above the previous upper RSI channel).
Long: A confirmed RSI low pivot has a lower price low AND higher RSI than the preceding confirmed RSI low pivot, OR a higher price low AND lower RSI than that pivot.
Short: A confirmed RSI high pivot has a higher price high AND lower RSI than the preceding confirmed RSI high pivot, OR a lower price high AND higher RSI than that pivot.
Long: RSI crosses above the upper RSI channel OR crosses above RSI smoothing.
Short: RSI crosses below the lower RSI channel OR crosses below RSI smoothing.
Long: The latest reversal or divergence was bullish AND RSI crosses above either corresponding retained deviation level.
Short: The latest reversal or divergence was bearish AND RSI crosses below either corresponding retained deviation level.
Long: Dashboard RSI is at or below the oversold threshold OR is above its smoothing.
Short: Dashboard RSI is at or above the overbought threshold OR is at or below its smoothing.
Long: The dashboard's most recent bullish regular divergence, reversal, or upward channel breakout is within the signal-age limit AND is at least as recent as the corresponding bearish signal, or no corresponding bearish signal exists.
Short: The dashboard's most recent bearish regular divergence, reversal, or downward channel breakout is within the signal-age limit AND is more recent than the corresponding bullish signal, or no corresponding bullish signal exists.