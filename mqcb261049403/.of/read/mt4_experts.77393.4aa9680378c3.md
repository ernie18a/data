Calculation: Heikin-Ashi open and close = Recompute over a configurable lookback ending with the current bar; initialize the oldest Heikin-Ashi open to (open + close) / 2, then set each subsequent Heikin-Ashi open to the preceding Heikin-Ashi open and close average. Each Heikin-Ashi close is (open + high + low + close) / 4. The lookback is at least the pending-signal expiry parameter plus five bars.
Calculation: Bullish reversal = current Heikin-Ashi close > current Heikin-Ashi open AND previous Heikin-Ashi close < previous Heikin-Ashi open.
Calculation: Bearish reversal = current Heikin-Ashi close < current Heikin-Ashi open AND previous Heikin-Ashi close > previous Heikin-Ashi open.
Calculation: Pending direction = the direction of the latest reversal; replace any existing pending direction on a new reversal. Test the channel on the reversal bar and every subsequent closed bar. Clear the pending direction on the first channel trigger, even if an entry filter fails or a position is open; otherwise clear it after the configured expiry number of subsequent bars, unless expiry is disabled. Test the channel before expiry on the expiry bar.
Calculation: Channel bands = EMA of close plus or minus ATR multiplied by a configurable factor.
Calculation: Entry filters = optional entry-bar hour within the configured start-inclusive, end-exclusive window, including windows crossing midnight AND optional exclusion of Friday at or after the cutoff hour AND optional current closed-bar volume >= a configurable multiple of the average volume over a lookback including that bar, with a zero average passing AND optional ATR <= a configurable threshold. Use separate lookbacks for volume and filter ATR.
Calculation: Initial stop = at entry, either the lowest low over a configurable closed-bar lookback minus a buffer for a long, or the highest high over that lookback plus a buffer for a short; alternatively, entry price minus an ATR multiple for a long or entry price plus an ATR multiple for a short. The stop ATR has its own lookback.
Calculation: Target = entry price plus a configurable multiple of entry price minus initial stop for a long, or entry price minus a configurable multiple of initial stop minus entry price for a short. The initial risk distance must be positive.
Calculation: Active stop = initial stop if enabled; optionally, after price reaches a configurable fraction of the distance from entry to target, move the stop to entry plus a lock for a long or entry minus a lock for a short. This break-even stop can be activated even when the initial stop is disabled.
Long: Bullish reversal.
Short: Bearish reversal.
Long: Pending direction = long AND close >= lower channel band AND entry filters pass AND position side = flat AND entry price > initial stop.
Short: Pending direction = short AND close <= upper channel band AND entry filters pass AND position side = flat AND entry price < initial stop.
Exit: long, bearish reversal AND opposite-signal exit enabled.
Exit: short, bullish reversal AND opposite-signal exit enabled.
Exit: long, price <= active stop OR price >= target.
Exit: short, price >= active stop OR price <= target.