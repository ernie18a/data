Calculation: Higher-timeframe raid = within the current higher-timeframe bar, one or more consecutive chart bars close beyond the last completed higher-timeframe bar's high or low; the raid is confirmed on the first subsequent chart bar that closes back at or inside that level, before the current higher-timeframe bar ends.
Calculation: Confirmed pivot high or low = a chart bar's high or low is a pivot with equal numbers of bars on each side; it becomes known after the right-hand bars complete. Each newly confirmed pivot replaces the previous candidate of the same kind; a candidate can be broken only once.
Calculation: Bullish fair value gap = current low > high two chart bars earlier AND the difference is at least an ATR multiple; its top is current low and its bottom is that earlier high. Bearish fair value gap = current high < low two chart bars earlier AND the difference is at least an ATR multiple; its top is that earlier low and its bottom is current high. Optionally remove older overlapping gaps of the same direction when a new gap forms; retain only the most recent configured number of gaps.
Calculation: Gap mitigation = for a bullish gap, min(open, close) < bottom, low < bottom, or low < midpoint; for a bearish gap, max(open, close) > top, high > top, or high > midpoint, according to the selected close, wick, or midpoint method. In standard mode remove a gap when mitigated. In breaker mode a mitigated gap reverses direction and remains until high > top for an originally bullish gap or low < bottom for an originally bearish gap.
Long: A higher-timeframe low raid is confirmed.
Short: A higher-timeframe high raid is confirmed.
Long: A pivot low is confirmed.
Short: A pivot high is confirmed.
Long: Close > the latest unbroken confirmed pivot high OR, when wick confirmation is selected, high > that pivot high.
Short: Close < the latest unbroken confirmed pivot low OR, when wick confirmation is selected, low < that pivot low.
Long: A bullish fair value gap forms and remains unmitigated.
Short: A bearish fair value gap forms and remains unmitigated.
Long: A bearish fair value gap is mitigated in breaker mode.
Short: A bullish fair value gap is mitigated in breaker mode.
Long: An unbroken bullish fair value gap has not previously been raided AND low < its top AND close > its top.
Short: An unbroken bearish fair value gap has not previously been raided AND high > its bottom AND close < its bottom.
Long: Close >= the open of the currently forming higher-timeframe bar, evaluated independently for a shorter and a longer higher timeframe.
Short: Close < the open of the currently forming higher-timeframe bar, evaluated independently for a shorter and a longer higher timeframe.
Long: Close >= session VWAP of typical price.
Short: Close < session VWAP of typical price.
Long: RSI of close >= the midpoint of its range.
Short: RSI of close < the midpoint of its range.
Long: Positive directional indicator > negative directional indicator.
Short: Negative directional indicator > positive directional indicator.