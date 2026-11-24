Calculation: Opening-range high = high of the first source bar after each T2 boundary; on chart bars, take values from T1's last completed bar when T1 is selected, or use the first chart bar when the chart timeframe is selected.
Calculation: Opening-range low = low of the first source bar after each T2 boundary; on chart bars, take values from T1's last completed bar when T1 is selected, or use the first chart bar when the chart timeframe is selected.
Calculation: Radar fast = SMA(EMA((open + close) / 2 when close > open, fast EMA lookback), radar smoothing lookback).
Calculation: Radar slow = SMA(EMA((open + close) / 2 when close > open, slow EMA lookback), radar smoothing lookback).
Calculation: Upper radar = max(Radar fast, Radar slow).
Calculation: Lower radar = min(Radar fast, Radar slow).
Calculation: Radar midpoint = (Radar fast + Radar slow) / 2.
Calculation: Body exceeds wicks = abs(close - open) > high - max(close, open) + min(close, open) - low.
Calculation: Momentum score = clamp(impulse weight * (close - nz(close[impulse lookback], close)) / ATR(ATR lookback) + acceleration weight * ((close - nz(close[recent lag], close)) - (nz(close[recent lag], close) - nz(close[earlier lag], nz(close[recent lag], close)))) / ATR(ATR lookback), -score cap, score cap); use zero for each normalized term when ATR is unavailable or zero.
Calculation: Signal side = neutral at each T2 boundary; on confirmed chart bars, set to short when close < Opening-range low AND close < Lower radar AND close < open AND Body exceeds wicks AND Radar fast < Radar slow; set to long under the symmetric Opening-range high conditions; then change short to long when close > Upper radar AND Radar fast > Radar slow, and long to short when close < Lower radar AND Radar fast < Radar slow; otherwise retain its value.
Calculation: Long stop candidate = Upper radar + abs(Upper radar - Radar midpoint) / stop offset divisor.
Calculation: Short stop candidate = Lower radar - abs(Radar midpoint - Lower radar) / stop offset divisor.
Calculation: Profit protection = off at each trade entry; when enabled, activate on a confirmed active-trade bar if the favorable move since entry as a percentage of entry price reaches the trigger and Momentum score >= the momentum threshold for a long trade or <= its negative for a short trade; remain active until trade exit or a new entry. Favorable move is highest high since entry minus entry price for long trades, or entry price minus lowest low since entry for short trades.
Calculation: Long protective stop = initialize to Long stop candidate only if it is below entry-bar close; on later confirmed bars, exit if close < the prior stop, otherwise ratchet upward to the maximum of the prior stop, available Long stop candidate, and, while Profit protection is active, entry price plus the locked share of maximum favorable excursion and any latest confirmed post-entry PivotLow(low, swing-left lookback, swing-right lookback) minus ATR(ATR lookback) times swing ATR buffer; update only when the result is above the prior stop and below close.
Calculation: Short protective stop = initialize to Short stop candidate only if it is above entry-bar close; on later confirmed bars, exit if close > the prior stop, otherwise ratchet downward to the minimum of the prior stop, available Short stop candidate, and, while Profit protection is active, entry price minus the locked share of maximum favorable excursion and any latest confirmed post-entry PivotHigh(high, swing-left lookback, swing-right lookback) plus ATR(ATR lookback) times swing ATR buffer; update only when the result is below the prior stop and above close.
Long: Radar fast > Radar slow.
Short: Radar fast <= Radar slow.
Long: close > Upper radar.
Short: close < Lower radar.
Long: Momentum score >= momentum direction threshold.
Short: Momentum score <= -momentum direction threshold.
Long: confirmed chart bar AND Signal side is long AND the previous chart bar's signal side was not long.
Short: confirmed chart bar AND Signal side is short AND the previous chart bar's signal side was not short.
Long: Signal side is long AND no confirmed stop exit remains latched.
Short: Signal side is short AND no confirmed stop exit remains latched.
Long: confirmed chart bar AND continuation is enabled AND Signal side is long AND a confirmed long stop exit occurred on an earlier bar AND no trade is active AND close > Upper radar AND Long stop candidate < close.
Short: confirmed chart bar AND continuation is enabled AND Signal side is short AND a confirmed short stop exit occurred on an earlier bar AND no trade is active AND close < Lower radar AND Short stop candidate > close.
Exit: long, on a confirmed chart bar after the stop-setting bar, close < Long protective stop.
Exit: short, on a confirmed chart bar after the stop-setting bar, close > Short protective stop.