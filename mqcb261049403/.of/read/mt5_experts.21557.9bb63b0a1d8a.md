Calculation: Upper channel = for each of a configurable number of consecutive offsets starting at a configurable shift from the evaluated bar, find the highest high over a window of that same number of bars ending at that offset; average those highs and round to the nearest configurable price increment.
Calculation: Lower channel = for each of a separately configurable number of consecutive offsets starting at a separately configurable shift from the evaluated bar, find the lowest low over a window of that same number of bars ending at that offset; average those lows and round to the nearest separately configurable price increment.
Calculation: Bullish breakout = close > upper channel AND close >= lower channel.
Calculation: Bearish breakout = close < lower channel.
Long: Bullish breakout on the chart bar.
Short: Bearish breakout on the chart bar.
Long: Bullish breakout on the selected bar of a configurable higher or lower timeframe AND bullish breakout is false on its preceding bar; the selected bar is either the last completed bar, an earlier completed bar, or the bar still forming.
Short: Bearish breakout on the selected bar of a configurable higher or lower timeframe AND bearish breakout is false on its preceding bar; the selected bar is either the last completed bar, an earlier completed bar, or the bar still forming.
Exit: long, bearish breakout on the selected bar of a configurable higher or lower timeframe; the selected bar is either the last completed bar, an earlier completed bar, or the bar still forming.
Exit: short, bullish breakout on the selected bar of a configurable higher or lower timeframe; the selected bar is either the last completed bar, an earlier completed bar, or the bar still forming.
Exit: long, low <= entry price minus configurable stop distance OR high >= entry price plus configurable profit distance.
Exit: short, high >= entry price plus configurable stop distance OR low <= entry price minus configurable profit distance.