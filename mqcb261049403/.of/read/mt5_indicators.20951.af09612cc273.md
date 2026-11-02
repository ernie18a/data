Calculation: Trend = initially 0; on each bar, find the highest high and lowest low over a configurable lookback including that bar. Let fraction = (33 − risk parameter) / 100, lower threshold = lowest low + (highest high − lowest low) × fraction, and upper threshold = highest high − (highest high − lowest low) × fraction. Set trend to −1 if close < lower threshold, then set it to +1 if close > upper threshold; otherwise retain its previous value.
Long: Chart-timeframe trend = +1.
Short: Chart-timeframe trend = −1.
Long: Chart-timeframe trend = +1 AND previous bar's trend ≤ 0.
Short: Chart-timeframe trend = −1 AND previous bar's trend ≥ 0.
Long: Selected bar's trend = +1 on each configurable timeframe, which may be higher or lower than the chart timeframe; the selected bar may be the still-forming bar, the last completed bar, or an earlier completed bar.
Short: Selected bar's trend = −1 on each configurable timeframe, which may be higher or lower than the chart timeframe; the selected bar may be the still-forming bar, the last completed bar, or an earlier completed bar.