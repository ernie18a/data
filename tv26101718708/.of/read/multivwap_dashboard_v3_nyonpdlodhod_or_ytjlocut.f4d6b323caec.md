Calculation: Selected price = one selected bar price or average of bar prices: open, high, low, close, (high + low) / 2, (high + low + close) / 3, (open + high + low + close) / 4, or (high + low + 2 × close) / 4.
Calculation: Anchored VWAP = sum(selected price × volume) / sum(volume) over the specified bars; unavailable when summed volume is zero.
Calculation: Regular-session VWAP = anchored VWAP from the first bar of the current regular session through the current bar; unavailable outside that session.
Calculation: Overnight VWAP = anchored VWAP from the first bar in the overnight anchor hour through the current bar; available from that anchor until the end of the next regular session.
Calculation: Previous-session-anchored VWAP = at each regular-session start, initialize the price-volume and volume sums with all bars from the preceding regular-session start through the preceding bar; add each subsequent bar except the current regular-session start bar. It is available during the current regular session.
Calculation: Session-low VWAP = anchored VWAP from the latest bar that set a strictly new regular-session low through the current bar; unavailable outside the regular session.
Calculation: Session-high VWAP = anchored VWAP from the latest bar that set a strictly new regular-session high through the current bar; unavailable outside the regular session.
Calculation: Opening range = highest high and lowest low of chart bars beginning at the regular-session start whose opening times are before the session start plus the selected range duration. Update the range while it forms and retain it afterward until the next session start. Use both a shorter and a longer range.
Calculation: Above count = number of enabled VWAPs among the regular-session, overnight, previous-session-anchored, session-low, and session-high VWAPs for which the VWAP is available and close > VWAP. Enabled count = number of those VWAPs selected for display; unavailable VWAPs count as not above.
Long: For any enabled VWAP, that VWAP is available AND close > that VWAP.
Short: For any enabled VWAP, that VWAP is unavailable OR close <= that VWAP.
Long: For either opening range, close > (range high + range low) / 2.
Short: For either opening range, close <= (range high + range low) / 2.
Long: During the regular session after the shorter opening range has finished forming, previous close <= range high AND close > range high.
Short: During the regular session after the shorter opening range has finished forming, previous close >= range low AND close < range low.
Long: Enabled count > 0 AND above count = enabled count.
Long: Enabled count >= 4 AND above count = 1.
Short: Enabled count > 0 AND above count = 0.
Short: Enabled count >= 4 AND above count = enabled count - 1.