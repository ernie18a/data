Calculation: Average candle range = moving average of high − low over the configured lookback, including the current bar.
Calculation: Body-to-range ratio = |close − open| / (high − low).
Calculation: Bullish close drive = (close − low) / (high − low).
Calculation: Bearish close drive = (high − close) / (high − low).
Calculation: Volume ratio = volume / moving average of volume over the configured lookback; use 1 if that average is missing or nonpositive.
Calculation: Bullish vacuum score = nearest integer to the sum of 30% × min((current range / average candle range) / minimum displacement ratio, 1) × 100, 28% × min(body-to-range ratio / minimum body-to-range ratio, 1) × 100, 18% × min(volume ratio / volume confirmation ratio, 1) × 100, and 24% × min(bullish close drive / minimum close drive, 1) × 100.
Calculation: Bearish vacuum score = same as bullish vacuum score, using bearish close drive.
Long: close > open AND current range / average candle range ≥ minimum displacement ratio AND body-to-range ratio ≥ minimum body-to-range ratio AND bullish close drive ≥ minimum close drive AND bullish vacuum score ≥ minimum vacuum score AND no prior qualified vacuum exists OR bars since the prior qualified vacuum ≥ cooldown.
Short: close < open AND current range / average candle range ≥ minimum displacement ratio AND body-to-range ratio ≥ minimum body-to-range ratio AND bearish close drive ≥ minimum close drive AND bearish vacuum score ≥ minimum vacuum score AND no prior qualified vacuum exists OR bars since the prior qualified vacuum ≥ cooldown.