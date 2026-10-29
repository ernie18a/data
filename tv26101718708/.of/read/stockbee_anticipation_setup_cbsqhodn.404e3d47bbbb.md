Calculation: Base high/low = highest high / lowest low over the preceding base lookback bars, excluding the current bar
Calculation: Prior low = lowest low over the prior-advance lookback window ending at the bar immediately before the base window
Calculation: Base width = (base high − base low) / base low
Calculation: Average range = mean of (high − low) / close over the base lookback, including the current bar
Calculation: Base volume ratio = mean volume over the base lookback / mean volume over the longer volume-baseline lookback
Calculation: Close location = (close − base low) / (base high − base low)
Calculation: Prior advance = (base high − prior low) / prior low
Calculation: Day gain = close / previous close − 1
Calculation: Stop = selected stop reference: lowest low over a recent-low lookback, base low, close minus an ATR multiple, or close reduced by a fixed percentage
Calculation: Risk = (close − stop) / close
Calculation: Range contraction = mean (high − low) / close over a short recent lookback divided by average range over the base lookback
Calculation: Setup score = weighted sum of normalized base tightness, volume dry-up, prior advance, close location, range contraction, trend alignment, and stop risk; narrower base, deeper volume dry-up, larger advance, higher close location, greater range contraction, trend alignment, and tighter risk score higher
Long: base width ≤ its maximum AND average range ≤ its maximum AND base volume ratio ≤ its maximum AND prior advance ≥ its minimum AND close location ≥ its minimum AND close > the shorter-term moving average AND close > the longer-term moving average (when the trend filter is enabled) AND day gain < its maximum AND close ≤ base high AND risk ≤ its maximum AND close ≥ its minimum price AND average volume ≥ its minimum AND setup score ≥ its minimum