Calculation: Rolling high/low = highest high and lowest low over the same lookback on the chart timeframe or selected higher signal timeframe, using the last completed bar.
Calculation: Long reversal levels = rolling high − (rolling high − rolling low) × 0.618 or 0.786.
Calculation: Short reversal levels = rolling low + (rolling high − rolling low) × 0.618 or 0.786.
Calculation: Long confirmation levels = signal-bar low + (captured rolling high − signal-bar low) × 0.236 or 0.382.
Calculation: Short confirmation levels = signal-bar high − (signal-bar high − captured rolling low) × 0.236 or 0.382.
Calculation: Long stop = selected 0.91 or 1.10 Fibonacci extension below the rolling range, if below entry; otherwise entry × (1 − fixed stop percentage).
Calculation: Short stop = selected 0.91 or 1.10 Fibonacci extension above the rolling range, if above entry; otherwise entry × (1 + fixed stop percentage).
Calculation: Long target = entry + risk/reward multiple × (entry − long stop).
Calculation: Short target = entry − risk/reward multiple × (short stop − entry).
Long: low <= either long reversal level AND previous signal-timeframe low > that level AND chart close > last completed daily EMA when the daily trend filter is enabled AND, when validation timeframe is enabled, its most recent rolling low is more recent than its most recent rolling high; OR, after a long reversal signal, chart close >= an undelivered long confirmation level AND previous chart close < that level; AND position is flat AND minimum bars since last entry have elapsed.
Short: high >= either short reversal level AND previous signal-timeframe high < that level AND chart close < last completed daily EMA when the daily trend filter is enabled AND, when validation timeframe is enabled, its most recent rolling high is more recent than its most recent rolling low; OR, after a short reversal signal, chart close <= an undelivered short confirmation level AND previous chart close > that level; AND position is flat AND minimum bars since last entry have elapsed.
Exit: long, low <= long stop OR high >= long target.
Exit: short, high >= short stop OR low <= short target.