Calculation: Stochastic RSI K = simple moving average of the stochastic of RSI of close; the stochastic uses the highest and lowest RSI over its lookback.
Calculation: Extreme state = initially neutral; on each closed chart bar set it to upper when K >= upper threshold and to lower when K <= lower threshold; otherwise retain its previous state. The lower threshold is below the middle threshold, which is below the upper threshold.
Calculation: Confluence state = initially unarmed; a K cross above the upper threshold arms short and disarms long, and a K cross below the lower threshold arms long and disarms short. After the corresponding confluence decision, disarm that side. Apply crossings before evaluating confluence on the same bar.
Calculation: Previous-day high and low = high and low of the last completed daily bar, which may be higher, equal to, or lower than the chart timeframe.
Long: K crosses below the lower threshold.
Short: K crosses above the upper threshold.
Long: K crosses above the middle threshold AND extreme state = lower.
Short: K crosses below the middle threshold AND extreme state = upper.
Long: Previous chart-bar close < current previous-day low AND current close >= current previous-day low.
Short: Previous chart-bar close > current previous-day high AND current close <= current previous-day high.
Long: Confluence state = armed long AND ATR > 0 AND absolute difference between close and previous-day low <= ATR multiplied by the zone-tolerance parameter.
Short: Confluence state = armed short AND ATR > 0 AND absolute difference between close and previous-day high <= ATR multiplied by the zone-tolerance parameter.
Long: On the first closed chart bar of a new equal or higher timeframe bar, the last completed bar's low > the high two bars before it on that timeframe.
Short: On the first closed chart bar of a new equal or higher timeframe bar, the last completed bar's high < the low two bars before it on that timeframe.