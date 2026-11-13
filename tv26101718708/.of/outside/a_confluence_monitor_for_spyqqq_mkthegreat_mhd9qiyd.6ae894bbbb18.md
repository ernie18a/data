Intraday framework on a single index ETF (SPY/QQQ). It evaluates each bar on close, using that instrument's own price and volume plus a higher-timeframe view of the same symbol. It decides when to BUY CALL options (bullish) or BUY PUT options (bearish). There is no exit rule; stops and targets are left to the trader.

Bullish score: seven binary checks, one point each.
1. Close is above the session-anchored VWAP of typical price (hlc3).
2. The fast EMA is above the mid EMA, and close is above the fast EMA.
3. RSI is above its neutral midpoint.
4. The MACD line is above its signal line, and the MACD histogram is higher than on the previous bar.
5. Current volume is at least a set multiple of its recent simple average.
6. Close is above the slow EMA.
7. Breakout trigger: close crosses upward (was at or below the level on the prior bar, now above it) through any one of these levels plus a small ATR-based buffer: (a) the highest high of the previous N bars, excluding the current bar; (b) the current day's premarket high, if it exists; (c) the previous day's high; (d) the current day's opening-range high (first minutes of the regular session), if it exists.

Bearish score: the exact mirror.
1. Close is below VWAP.
2. The fast EMA is below the mid EMA, and close is below the fast EMA.
3. RSI is below its neutral midpoint.
4. The MACD line is below its signal line, and the histogram is lower than on the previous bar.
5. The same volume check as the bullish side.
6. Close is below the slow EMA.
7. Close crosses downward through any of these levels minus the buffer: the lowest low of the previous N bars, the premarket low, the previous day's low, or the opening-range low.

Higher-timeframe confirmation is an optional toggle, on by default. It uses a fixed higher timeframe of the same symbol.
- Bullish: HTF close is above HTF VWAP, HTF fast EMA is above HTF mid EMA, HTF RSI is above neutral, and the HTF MACD line is above its signal.
- Bearish: all four conditions mirrored.
- If the toggle is off, confirmation always passes.

Entry rule:
- A raw bullish setup requires all of the following: the bar is inside the regular trading session, the bullish score is at or above a minimum threshold (6 of 7), and bullish HTF confirmation passes.
- A raw bearish setup is the mirror of this.
- The actual signal fires only on the first bar where the raw setup turns true after being false on the previous bar (a rising edge). It does not repeat while the setup persists.
- A bullish signal means buy a call. A bearish signal means buy a put.
- Premarket and opening-range levels reset at the start of each day and accumulate their highs and lows only during their own sessions.
- Level breakouts require the level to exist.
- Option contract choice (near-the-money, liquid, tight spread) and risk management are manual and outside the logic.

A chop zone is flagged when price is very close to VWAP, RSI is in a narrow band around neutral, and the fast and mid EMAs are nearly equal. It is informational only and does not block signals.