Calculation: Base Ichimoku = Ichimoku(Tenkan lookback, Kijun lookback, Span B lookback), calculated on T1 bars and mapped to chart bars using the current, still-forming T1 bar; use chart-timeframe bars when auto-switch replaces T1.
Calculation: Higher Ichimoku = Ichimoku(the same Tenkan, Kijun, and Span B lookbacks), calculated on T2 bars and mapped to chart bars using the current, still-forming T2 bar; use chart-timeframe bars when T2 is disabled or unavailable.
Calculation: T1 cloud top/bottom = max/min(Base Ichimoku Senkou A, Base Ichimoku Senkou B) from the Senkou offset mapped to chart bars ago.
Calculation: T2 cloud top/bottom = max/min(Higher Ichimoku Senkou A, Higher Ichimoku Senkou B) from the Senkou offset mapped to chart bars ago.
Calculation: T1 Chikou cloud top/bottom = max/min(Base Ichimoku Senkou A, Base Ichimoku Senkou B) from the Senkou offset plus Chikou offset mapped to chart bars ago.
Calculation: Bullish alignment = Base Ichimoku Senkou A > Senkou B AND close > close[Chikou offset mapped from T1] AND Base Ichimoku Tenkan > Kijun AND close > T1 Chikou cloud top AND close > T1 cloud top AND close > T2 cloud top.
Calculation: Bearish alignment = Base Ichimoku Senkou A <= Senkou B AND close < close[Chikou offset mapped from T1] AND Base Ichimoku Tenkan < Kijun AND close < T1 Chikou cloud bottom AND close < T1 cloud bottom AND close < T2 cloud bottom.
Calculation: Continuous bullish alignment = bullish alignment on every chart bar in the bullish detection lookback.
Calculation: Continuous bearish alignment = bearish alignment on every chart bar in the bullish detection lookback.
Calculation: Trend phase = bullish when close is above both current clouds, bearish when close is below both; in a range retain the prior phase if either directional condition occurred within the range-retention lookback, otherwise neutral.
Calculation: Range upper edge = maximum of max(open, close) over chart bars from the range-edge start offset through the range lookback minus one.
Calculation: Range lower edge = minimum of min(open, close) over chart bars from the range-edge start offset through the range lookback minus one.
Calculation: ATR stop distance = ATR(stop ATR lookback) * stop ATR multiple.
Calculation: Entry padding = ATR(entry-padding ATR lookback) * entry-padding multiple.
Calculation: Recent body low/high = minimum/maximum of min/max(open, close) over chart bars from the trailing-stop start offset through the trailing-stop lookback minus one.
Calculation: Long mixed stop = min(low - ATR stop distance, (T1 cloud top + low - ATR stop distance) / 2, recent body low).
Calculation: Short mixed stop = max(high + ATR stop distance, (T1 cloud bottom + high + ATR stop distance) / 2, recent body high).
Calculation: Long trailing stop = long mixed stop when a flat long signal occurs, then max(prior long trailing stop, current long mixed stop) while long.
Calculation: Short trailing stop = short mixed stop when a flat short signal occurs, then min(prior short trailing stop, current short mixed stop) while short.
Calculation: Long extra-entry level = minimum of min(open, close) over chart bars from the extra-entry start offset through the extra-entry lookback minus one, plus entry padding.
Calculation: Short extra-entry level = maximum of max(open, close) over chart bars from the extra-entry start offset through the extra-entry lookback minus one, minus entry padding.
Calculation: Up doji = abs(close - open) < (high - low) * doji-body fraction AND max(open, close) > low + (high - low) * doji-position fraction.
Calculation: Down doji = abs(close - open) < (high - low) * doji-body fraction AND min(open, close) < high - (high - low) * doji-position fraction.
Calculation: MACD = MACD(close, shorter lookback, longer lookback, signal lookback), with the shorter lookback less than the longer lookback, on chart bars.
Long: Base Ichimoku Senkou A > Senkou B.
Short: Base Ichimoku Senkou A <= Senkou B.
Long: Higher Ichimoku Senkou A > Senkou B.
Short: Higher Ichimoku Senkou A <= Senkou B.
Long: Continuous bullish alignment.
Short: Continuous bearish alignment.
Long: Flat AND datetime within the configured trading window AND continuous bullish alignment AND first-entry phase since the latest trend-phase change AND MACD line > signal line after MACD line <= signal line in that phase.
Short: Flat AND datetime within the configured trading window AND continuous bearish alignment AND first-entry phase since the latest trend-phase change AND MACD line <= signal line after MACD line > signal line in that phase.
Long: Flat AND datetime within the configured trading window AND later-entry phase AND continuous bullish alignment AND a close above the range upper edge since the latest trend-phase change or position close AND, after that break, a bar closed above the T1 cloud top with MACD line <= signal line AND close > range upper edge.
Short: Flat AND datetime within the configured trading window AND later-entry phase AND continuous bearish alignment AND a close below the range lower edge since the latest trend-phase change or position close AND, after that break, a bar closed below the T1 cloud bottom with MACD line > signal line AND close < range lower edge.
Long: Flat AND later-entry phase AND continuous bullish alignment AND the first close above the range upper edge since the latest trend-phase change or position close.
Short: Flat AND later-entry phase AND continuous bearish alignment AND the first close below the range lower edge since the latest trend-phase change or position close.
Long: Flat AND first-entry phase AND bullish alignment AND, on the first confirmation bar, MACD line > signal line after MACD line <= signal line since the latest trend-phase change.
Short: Flat AND first-entry phase AND bearish alignment AND, on the first confirmation bar, MACD line <= signal line after MACD line > signal line since the latest trend-phase change.
Long: Long position AND after a partial profit exit while a long position remains AND bullish alignment AND long extra-entry level > prior long entry reference AND (close > open OR up doji) AND datetime within the configured trading window.
Short: Short position AND after a partial profit exit while a short position remains AND bearish alignment AND short extra-entry level < prior short entry reference AND (close < open OR down doji) AND datetime within the configured trading window.
Calculation: Initial long target = range upper edge + (hl2 - long extra-entry level).
Calculation: Initial short target = range lower edge - (short extra-entry level - hl2).
Calculation: Extra-entry long target = range upper edge + entry padding.
Calculation: Extra-entry short target = range lower edge - entry padding.
Exit: long, low <= long trailing stop OR high >= initial long target OR high >= extra-entry long target.
Exit: short, high >= short trailing stop OR low <= initial short target OR low <= extra-entry short target.