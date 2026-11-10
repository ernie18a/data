Calculation: Confirmed swing high/low = a high/low that is respectively the highest/lowest over equal numbers of bars on each side, available after the right-side bars complete; use the latest confirmed value.
Calculation: Liquidity high/low = either the latest confirmed swing high/low or the highest high/lowest low over a lookback ending on the preceding chart bar.
Calculation: EMA travel = absolute difference between the current EMA and its value EMA-length chart bars ago, divided by current ATR; the gap and sweep regime filters may use different EMA lengths and thresholds.
Calculation: Higher-timeframe bias = EMA of higher-timeframe closes; use the last completed higher-timeframe bar historically and the still-forming higher-timeframe bar in real time.
Calculation: Round step = either a configured positive step or 10 raised to floor(log10(current close)); nearest round level to a price = round(price / round step) × round step.
Calculation: Sweep regime permission = either unrestricted, EMA travel below its threshold, chart close on the permitted side of higher-timeframe bias, or EMA travel below its threshold OR chart close on the permitted side of higher-timeframe bias, according to the selected mode; the permitted side is above for long and below for short.
Calculation: Sweep confluence = either unrestricted or the distance between the swept liquidity level and the corresponding extreme of the last completed higher-timeframe bar, or its nearest round level, is at most an ATR multiple.
Calculation: Gap stop and target = signal-bar close minus an ATR multiple for a long or plus an ATR multiple for a short, and the close preceding the signal bar, respectively; retain both values for the position.
Calculation: Sweep stop = signal-bar low minus an ATR multiple for a long or signal-bar high plus an ATR multiple for a short; retain it for the position.
Calculation: Sweep target = signal-bar close plus, for a long, or minus, for a short, a risk-reward multiple of the distance from signal-bar close to sweep stop; alternatively use the opposite liquidity level if it exists and is above signal-bar close for a long or below it for a short, otherwise use the risk-reward target; retain the result for the position.
Long: A swing low is confirmed.
Short: A swing high is confirmed.
Long: Low > high two chart bars ago.
Short: High < low two chart bars ago.
Long: Close > open AND close - open > an ATR multiple AND preceding close < preceding open.
Short: Close < open AND open - close > an ATR multiple AND preceding close > preceding open.
Long: Close > latest confirmed swing high AND preceding close <= that same swing high.
Short: Close < latest confirmed swing low AND preceding close >= that same swing low.
Long: Low < liquidity low AND close > liquidity low.
Short: High > liquidity high AND close < liquidity high.
Long: Position is flat AND gap module and gap longs are enabled AND open < preceding close × (1 - minimum gap fraction) AND (range filter is disabled OR gap EMA travel < its threshold).
Short: Position is flat AND gap module and gap shorts are enabled AND open > preceding close × (1 + minimum gap fraction) AND (range filter is disabled OR gap EMA travel < its threshold).
Long: Position is flat AND no enabled gap entry occurs on this bar AND sweep module and sweep longs are enabled AND low < liquidity low AND close > liquidity low AND long sweep regime permission holds AND sweep confluence holds.
Short: Position is flat AND no enabled gap entry occurs on this bar AND sweep module and sweep shorts are enabled AND high > liquidity high AND close < liquidity high AND short sweep regime permission holds AND sweep confluence holds.
Exit: Long gap position, low <= gap stop OR high >= gap target.
Exit: Short gap position, high >= gap stop OR low <= gap target.
Exit: Long sweep position, low <= sweep stop OR high >= sweep target.
Exit: Short sweep position, high >= sweep stop OR low <= sweep target.
Exit: Long or short, maximum holding period is enabled AND chart bars since entry >= maximum holding period.