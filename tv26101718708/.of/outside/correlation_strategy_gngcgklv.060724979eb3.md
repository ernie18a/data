Trade one instrument (the chart instrument) using a second, user-chosen reference instrument. On every bar, compute the rolling Pearson correlation between the reference instrument's closing prices and the traded instrument's closing prices over a lookback window, and scale it to percent (-100 to 100). A 'low-correlation regime' exists when this value is below a threshold.

Direction filter, which is only evaluated inside the low-correlation regime. It has two modes, selected by a switch:
- Moving-average mode: the bullish condition is the traded instrument's close below its simple moving average. The bearish condition is the close above that average.
- RSI mode: the bullish condition is the traded instrument's RSI below an oversold level. The bearish condition is RSI above an overbought level.
The moving-average and RSI lengths either equal the correlation lookback or are separate settings.

Signals:
- BUY = low-correlation regime AND bullish condition.
- SELL = low-correlation regime AND bearish condition.

Entries: BUY opens or holds a long position. SELL opens or holds a short position. An optional 'reverse' switch swaps the mapping, so BUY goes short and SELL goes long. Optionally restrict trading to long-only, short-only, or both.

Position handling: if stop-and-reverse is allowed, a fresh opposite signal flips the position immediately. Otherwise a new entry is allowed only when flat.

Exits come from protective stops, take-profit, an optional trailing stop, or an optional fixed number of bars after entry. These use only the traded instrument's own price data, not the reference instrument, and the exit is otherwise the opposite-signal flip. Trading may also be limited to a chosen sample window of bars.