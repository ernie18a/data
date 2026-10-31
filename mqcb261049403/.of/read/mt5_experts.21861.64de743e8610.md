Calculation: Session range = for each day, find the bars containing two configured intraday times; take the highest high and lowest low from the earlier containing bar through the bar immediately before the later containing bar. Apply these bounds to the final range bar and subsequent bars until the next range begins; bounds are unavailable during the rest of a range. The final range bar's bounds use the completed range.
Calculation: Breakout state = above when a bar's close is greater than its session range high, below when its close is less than its session range low, and neutral otherwise, including when the bounds are unavailable.
Long: Chart-timeframe breakout state = above
Short: Chart-timeframe breakout state = below
Long: Higher-timeframe breakout state on the selected signal bar = above AND breakout state on the preceding higher-timeframe bar != above; use the last completed higher-timeframe bar or the still-forming bar according to the signal-bar setting
Short: Higher-timeframe breakout state on the selected signal bar = below AND breakout state on the preceding higher-timeframe bar != below; use the last completed higher-timeframe bar or the still-forming bar according to the signal-bar setting
Exit: long, higher-timeframe breakout state on the selected signal bar = below; use the last completed higher-timeframe bar or the still-forming bar according to the signal-bar setting
Exit: short, higher-timeframe breakout state on the selected signal bar = above; use the last completed higher-timeframe bar or the still-forming bar according to the signal-bar setting
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance