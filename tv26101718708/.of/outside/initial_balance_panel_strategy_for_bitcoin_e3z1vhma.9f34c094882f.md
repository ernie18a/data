Trade the chart instrument long or short using a breakout-consensus count across a basket of 16 crypto USDT pairs, filtered by a volatility trailing-stop trend on the chart instrument. The basket is BTC, ETH, EOS, LTC, XRP, DASH, IOTA, NEO, QTUM, XMR, ZEC, ETC, ADA, XTZ, LINK and DOT, all quoted against USDT on Binance. The chart instrument is normally BTC, which is also the first basket member. Evaluate everything on every bar of the chart timeframe.

1. Per-pair Initial Balance (IB) levels. Run the same calculation independently for each basket pair on the same timeframe. Define three daily sessions, each with a one-hour IB window measured from the session open: Asia 00:00-01:00, London 08:00-09:00, and New York 14:30-15:30. All three run every day of the week, in the exchange/chart time zone. During each window, track the highest high and lowest low from the window's first bar through its last bar. Reset the tracking at the start of each new window. At the end of the window, latch the final high and low as that session's IB high and IB low. Hold the latched levels until the next day's window for that session replaces them. Before the first capture, the stored high is 0 and the stored low is 0, so the levels start as zeros.

2. Per-pair state, using that pair's own close.
- Bullish: the close is strictly above all three latched IB highs (Asia, London and New York).
- Bearish: the close is strictly below all three latched IB lows.
- Otherwise the pair is neutral.
- Bullish is checked first, though both cannot be true at once.

3. Consensus counts. Count the basket pairs that are bullish and the pairs that are bearish. The code also adds the chart symbol's session-phase color as a 17th entry. That color is never the bullish or bearish color, so it adds nothing to either count.

4. Volatility Stop trend on the chart instrument. Use the chart close as the source. Keep a running maximum and minimum of the source since the last trend flip. Take an ATR over a configurable length and multiply it by a configurable factor. If the ATR is unavailable, fall back to the true range of the bar.
- While in an uptrend, the stop is the larger of the previous stop and (running max minus the scaled ATR).
- While in a downtrend, the stop is the smaller of the previous stop and (running min plus the scaled ATR).
- The trend is up when the source minus the stop is >= 0, otherwise down.
- Initialize the trend as up, with the stop at 0 and the max and min equal to the first source value.
- When the trend flips, reset both the running max and min to the current source. Then recompute the stop fresh as (max minus scaled ATR) if the new trend is up, or (min plus scaled ATR) if it is down.

5. Entries.
- Go long when the bullish count is >= a configurable long threshold (default near-unanimous, i.e. almost all 16 pairs) and the Volatility Stop trend is up.
- Go short when the bearish count is >= a configurable short threshold and the trend is down. The default short threshold exceeds the 16 usable pairs, so shorts are effectively disabled by default.
- Two optional BTC filters apply symmetrically. In 'BTC same' mode, the BTC pair must itself be bullish for longs, or bearish for shorts. In 'BTC not breaking' mode, the BTC pair must be neutral, meaning neither bullish nor bearish. Both are off by default.
- Entry orders are market orders. An entry in the opposite direction reverses an existing position. Repeating an entry in the same direction adds nothing.

6. Exits.
- Close a long position when the Volatility Stop trend flips from up to down on the current bar.
- Close a short position when the trend flips from down to up.
- There is no fixed stop-loss, take-profit or time-based exit.
- Consensus loss alone does not exit a position. Only the trend flip does, or a reversing entry.