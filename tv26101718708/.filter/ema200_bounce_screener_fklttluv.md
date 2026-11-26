# EMA200 Bounce Screener

- url: https://www.tradingview.com/script/fkLTTluv/
- type: indicator
- pine_id: PUB;e52230917cd74954869fe279c4fb0c65
- version: 1.0

## Description

EMA200 Bounce Screener

WHAT IT DOES
This indicator is built for TradingView's Pine Screener. It flags stocks in an established uptrend whose daily low pulls back to a rising 200-period EMA and then closes back above it — a classic "buy the pullback in a long-term uptrend" pattern. Every condition is exposed as a separate column, so watchlists can be filtered directly in the screener.

SIGNAL CONDITIONS (daily close)
1. The EMA200 is rising (higher than 20 bars ago).
2. Price closed at least X % above the EMA200 within the last N bars (default 5 % / 30 bars). This separates pullbacks from strength from stocks that are merely drifting sideways around the average.
3. The daily low touches the EMA200, at most 1 × ATR(14) below it.
4. The bar closes back above the EMA200.
5. Optional market filter: SPY trades above its own 200-period EMA.

SCREENER COLUMNS
• Signal (1 = bounce today) – all conditions met on the latest bar
• Watch (near EMA200) – uptrend intact, close at most X % above the EMA200, no touch yet (early-warning list)
• Distance to EMA200 % – close relative to the EMA200
• EMA200 slope 20 bars % – strength of the long-term trend
• Buy stop – signal-bar high plus a small offset (reference level)
• Stop – 1.5 × ATR(14) below the EMA200 (reference level)
• EMA200 – current value

HOW TO USE
1. Add the script to your favorites.
2. Open the Pine Screener, choose a watchlist, select this indicator and the 1D timeframe.
3. Filter "Signal = 1" for today's bounces, or "Watch = 1" for candidates approaching the EMA200.
4. Run it after the US close so the daily bar is complete.

NOTES AND LIMITATIONS
• This is a screening tool, not a complete trading system. It does not manage exits; the buy-stop and stop values are reference levels only.
• The Pine Screener evaluates the last 500 bars, so the EMA200 can differ slightly from the value on a chart with full history. Confirm all levels on the chart before placing an order.
• Bounces off the EMA200 often fail on the first attempt; a close back below the average is a common exit condition.
• The script uses a single request.security() call for the SPY filter and returns a scalar, which keeps it compatible with the Pine Screener.
• For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
// EMA200 Bounce Screener
// Flags stocks in an established uptrend whose daily low pulls back to a
// RISING 200-period EMA and closes back above it. Built for the Pine Screener:
// every condition is exposed as a column, so lists can be filtered directly.
//
// Signal conditions (all on the daily close):
//   1. EMA200 is rising (higher than 20 bars ago)
//   2. Price closed at least X % above the EMA200 within the last N bars
//      (the pullback comes from strength, not from a sideways range)
//   3. The bar's low touches the EMA200 (at most 1 ATR below it)
//   4. The bar closes back above the EMA200
//   5. Optional market filter: SPY above its own 200-period EMA
//
// Reference levels (information only, not a complete strategy):
//   • Buy stop: signal bar high + a small offset
//   • Stop:     1.5 × ATR(14) below the EMA200
//
// Pine Screener notes:
//   • only one request.security() call, returning a scalar (tuple returns can
//     break screener runs)
//   • the screener evaluates the last 500 bars, so the EMA200 can differ
//     slightly from the chart value — confirm levels on the chart
// ═══════════════════════════════════════════════════════════════════
indicator("EMA200 Bounce Screener", overlay=false)

lenEma  = input.int(200,    "EMA length")
vorProz = input.float(5.0,  "Prior strength: min. % above EMA", step=0.5)
vorTage = input.int(30,     "… within the last N bars")
nahProz = input.float(3.0,  "Watch: close at most % above EMA", step=0.5)
tick    = input.float(0.02, "Buy-stop offset", step=0.01)
mitSpy  = input.bool(true,  "Market filter: SPY above its EMA200")

ema200 = ta.ema(close, lenEma)
atr14  = ta.atr(14)
steigt = ema200 > ema200[20]
vorher = ta.highest(close / ema200, vorTage)[1] >= 1 + vorProz / 100

// Single scalar call — screener-safe
spyUeber = request.security("SPY", "D", close > ta.ema(close, 200) ? 1 : 0, lookahead = barmerge.lookahead_off)
spyOk    = mitSpy ? spyUeber == 1 : true

beruehrt = low <= ema200 and low >= ema200 - atr14
signal   = steigt and vorher and beruehrt and close > ema200 and spyOk
// Early stage: price approaching the EMA200 but not touching it yet
nahe     = steigt and vorher and close > ema200 and close <= ema200 * (1 + nahProz / 100) and spyOk and not signal

// ── Screener columns ─────────────────────────────────────────────────
plot(signal ? 1 : 0,                  title="Signal (1 = bounce today)")
plot(nahe ? 1 : 0,                    title="Watch (near EMA200)")
plot((close / ema200 - 1) * 100,      title="Distance to EMA200 %")
plot((ema200 / ema200[20] - 1) * 100, title="EMA200 slope 20 bars %")
plot(high + tick,                     title="Buy stop")
plot(ema200 - 1.5 * atr14,            title="Stop")
plot(ema200,                          title="EMA200")
````
