Calculation: Pivot leg = for swing or internal lookback separately, BEARISH when high[lookback] > Highest(high, lookback), else BULLISH when low[lookback] < Lowest(low, lookback), else the prior leg; initially BEARISH, with the high test taking priority
Calculation: Swing pivot high/low = high[swing lookback] on a swing-leg transition to BEARISH, or low[swing lookback] on a transition to BULLISH; each new pivot is unbroken
Calculation: Internal pivot high/low = high[internal lookback] on an internal-leg transition to BEARISH, or low[internal lookback] on a transition to BULLISH; each new pivot is unbroken
Calculation: Swing pivot tag = HH when a new pivot high exceeds the prior pivot high, otherwise LH; LL when a new pivot low is below the prior pivot low, otherwise HL
Calculation: Swing pivot counts = HH and HL counts since the latest switch to bullish pivot mode, and LL and LH counts since the latest switch to bearish pivot mode; on a switch, the new tag count is one and the other count is zero
Calculation: Long Fibonacci levels = at setup creation, entry = latest HH − (latest HH − current HL) × entry retracement parameter; target = latest HH − (latest HH − current HL) × target retracement parameter; stop = latest HH − (latest HH − current HL) × stop retracement parameter
Calculation: Short Fibonacci levels = at setup creation, entry = latest LL + (current LH − latest LL) × entry retracement parameter; target = latest LL + (current LH − latest LL) × target retracement parameter; stop = latest LL + (current LH − latest LL) × stop retracement parameter
Calculation: Fibonacci setup state = each qualifying new setup activates or replaces the setup and clears entered; its entry touch sets entered; either target or stop touch clears the setup and entered
Calculation: Internal trend state = bullish after a bullish internal pivot break and bearish after a bearish internal pivot break; initially bearish
Calculation: T1 candle percent change = (last completed T1 close − last completed T1 open) / (last completed T1 open × 100)
Calculation: T1 gap threshold = when auto threshold is enabled, cumulative sum on chart bars of the absolute T1 candle percent change only at T1 boundaries, divided by chart bar index and multiplied by a threshold multiplier parameter; otherwise zero
Long: close crosses above the current unbroken swing pivot high
Short: close crosses below the current unbroken swing pivot low
Long: close crosses above the current unbroken internal pivot high AND current internal pivot high differs from current swing pivot high AND (confluence filter is disabled OR high − max(close, open) > min(close, open − low))
Short: close crosses below the current unbroken internal pivot low AND current internal pivot low differs from current swing pivot low AND (confluence filter is disabled OR high − max(close, open) < min(close, open − low))
Long: internal trend state is bullish
Short: internal trend state is bearish
Long: a new swing HL pivot AND HH count ≥ minimum pivot count AND HL count ≥ minimum pivot count AND latest HH > current HL
Short: a new swing LH pivot AND LL count ≥ minimum pivot count AND current LH > latest LL
Long: long setup active AND not entered AND low ≤ stored long entry level
Short: short setup active AND not entered AND high ≥ stored short entry level
Exit: long, long setup active AND entered AND (high ≥ stored long target level OR low ≤ stored long stop level)
Exit: short, short setup active AND entered AND (low ≤ stored short target level OR high ≥ stored short stop level)
Long: on chart bars at a T1 boundary, T1 forming low > T1 high from gap-lookback T1 bars ago AND last completed T1 close > that high AND T1 candle percent change > T1 gap threshold
Short: on chart bars at a T1 boundary, T1 forming high < T1 low from gap-lookback T1 bars ago AND last completed T1 close < that low AND negative T1 candle percent change > T1 gap threshold