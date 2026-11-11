Calculation: Confirmed swing high/low = a pivot high/low with an equal number of bars on each side; it becomes available after the right-side bars complete. The latest confirmed value remains in use until replaced.
Calculation: Previous period high/low = high/low of the last completed higher-timeframe bar.
Calculation: Bullish gap = current low > high two bars ago AND current low - high two bars ago > ATR times a threshold; its range is from that earlier high to current low. Bearish gap = current high < low two bars ago AND low two bars ago - current high > ATR times a threshold; its range is from current high to that earlier low. Retain the latest range of each side until replaced.
Calculation: Bullish zone = range from the preceding bar's low to max(its open, its close), created when that bar closes below its open AND current close > preceding high AND current close - current open > ATR times a threshold. Bearish zone = range from min(the preceding bar's open, its close) to its high, created when that bar closes above its open AND current close < preceding low AND current open - current close > ATR times a threshold. Retain the latest range of each side until replaced.
Calculation: Bullish sweep = low < latest confirmed swing low AND close > that swing low, OR low < previous period low AND close > previous period low. Bearish sweep = high > latest confirmed swing high AND close < that swing high, OR high > previous period high AND close < previous period high.
Calculation: Entry reference = signal-bar close. Initial long stop = signal-bar low or signal-bar close - signal-bar ATR times a multiplier; initial short stop = signal-bar high or signal-bar close + signal-bar ATR times a multiplier. Risk = absolute difference between entry reference and initial stop. Long target = entry reference + risk times a reward multiplier; short target = entry reference - risk times a reward multiplier.
Calculation: Current long stop = initial long stop, raised to entry reference if the current bar high >= entry reference + risk when breakeven is enabled, and raised to current close - ATR times a multiplier if trailing is enabled. Current short stop = initial short stop, lowered to entry reference if the current bar low <= entry reference - risk when breakeven is enabled, and lowered to current close + ATR times a multiplier if trailing is enabled. Recalculate from the initial stop on each bar.
Long: A swing low is confirmed.
Short: A swing high is confirmed.
Long: Close > latest confirmed swing high.
Short: Close < latest confirmed swing low.
Long: Bullish sweep.
Short: Bearish sweep.
Long: Bullish gap.
Short: Bearish gap.
Long: Bullish zone is created.
Short: Bearish zone is created.
Long: A bullish sweep occurred within the inclusive lookback ending on the current bar AND current high-low range overlaps the latest bullish zone OR bullish gap AND close > open AND optionally close > preceding high AND optionally close < midpoint of the lookback's highest high and lowest low AND optionally shorter-period EMA > longer-period EMA AND optionally position is flat.
Short: A bearish sweep occurred within the inclusive lookback ending on the current bar AND current high-low range overlaps the latest bearish zone OR bearish gap AND close < open AND optionally close < preceding low AND optionally close > midpoint of the lookback's highest high and lowest low AND optionally shorter-period EMA < longer-period EMA AND optionally position is flat.
Exit: Long, price <= current long stop OR price >= long target.
Exit: Short, price >= current short stop OR price <= short target.