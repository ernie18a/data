Calculation: Anchored VWAP = cumulative volume-weighted average of typical price (high + low + close) / 3, restarted at the selected session open, week open, manual timestamp, or most recently confirmed pivot high/low.
Calculation: Z-score = (close − anchored VWAP) / rolling standard deviation of (close − anchored VWAP), using the same lookback for both directions.
Long: close > anchored VWAP AND Z-score ≥ threshold AND bars since prior signal ≥ cooldown AND bar is confirmed.
Short: close < anchored VWAP AND Z-score ≤ −threshold AND bars since prior signal ≥ cooldown AND bar is confirmed.
Exit: Long, close 1/3 when high ≥ entry + (entry − anchored VWAP) × first target multiplier.
Exit: Long, close 1/3 when high ≥ entry + (entry − anchored VWAP) × second target multiplier.
Exit: Long, close remaining position when low ≤ anchored VWAP + (entry − anchored VWAP) × stop multiplier − ATR(14) × stop buffer OR high ≥ entry + (entry − anchored VWAP) × third target multiplier.
Exit: Short, close 1/3 when low ≤ entry + (entry − anchored VWAP) × first target multiplier.
Exit: Short, close 1/3 when low ≤ entry + (entry − anchored VWAP) × second target multiplier.
Exit: Short, close remaining position when high ≥ anchored VWAP + (entry − anchored VWAP) × stop multiplier + ATR(14) × stop buffer OR low ≤ entry + (entry − anchored VWAP) × third target multiplier.
Exit: Long after second target, close remaining position when low ≤ highest high since trail activation − ATR(22) × trail multiplier; update the trail to the greater of its prior value and current high − ATR(22) × trail multiplier.
Exit: Short after second target, close remaining position when high ≥ lowest low since trail activation + ATR(22) × trail multiplier; update the trail to the lesser of its prior value and current low + ATR(22) × trail multiplier.