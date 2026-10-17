# BBW + Squeeze

- url: https://www.tradingview.com/script/lGWYZA7y-BBW-Squeeze/
- type: indicator
- pine_id: PUB;4fc8382f0d69440cba4633e7b695b433
- version: 1.0

## Description

The BBW Squeeze indicator, explained

The idea in one sentence: Markets switch between quiet phases and loud phases. This indicator flags when a market is unusually quiet compared to its own last six months, because a big move often follows a quiet stretch.

How it measures “quiet”

It uses Bollinger Bands. Those are two lines drawn around the price, two standard deviations above and below the 20-bar average. When price swings wildly, the bands spread apart. When price drifts sideways, they pull together.

The indicator doesn’t draw the bands themselves. It plots their width as a percentage of price. That’s the BandWidth (BBW), the light grey line. It’s the same formula as TradingView’s built-in BBW.

What counts as a “squeeze”

John Bollinger’s classic rule: a squeeze happens when BandWidth hits its lowest level in about six months. So the indicator:

Tracks the lowest BandWidth of the last 182 calendar days (the red step line).
Shades the background pink when the current BandWidth is at that low or within 5% above it. The 5% is relative: if the low is 4.0, anything up to 4.2 counts.

Set the tolerance to 0 and you get Bollinger’s rule exactly, with only brand-new lows counting.

Why “calendar days” matters

Most versions count bars, for example “the last 125 bars”. That breaks quickly. 125 daily bars is six months for stocks (5 trading days a week) but only four months for crypto (7 days a week). On a 4-hour chart it’s just three weeks. This version measures real time instead, so the “six-month low” means six months on any chart, whatever the market or timeframe.

Safety rails built in

No fake lows at the start of the chart: the red line and the shading only appear once there are a full six months of data. Otherwise the “lowest in six months” would really be “lowest in the few weeks we have”.
Disabled on weekly and monthly charts: six months is only about 26 weekly bars, or 6 monthly ones. The lowest of six values isn’t meaningful.
Step line on purpose: when an old low drops out of the window, the red line jumps up. That’s bookkeeping, not something the market did.

How to read it

Pink background = volatility is compressed, a “coiled spring”.
It does not tell you the direction. A squeeze can end with a breakout up or a breakdown down. You need price action or another tool to tell which.
The current, unfinished bar can change until it closes, so a squeeze can flicker in and out during that bar.
It’s a visual tool only. There are no alerts and no buy or sell signals.

Settings

BB length (20)
Standard deviations (2): only changes the height of the lines, not when a squeeze is detected
Lookback (182 days)
Tolerance (5%)
The three colours

## Source Code

````pine
//@version=6
// BBW + Squeeze v2
// Changes vs. v1 (details and sources: REVIEW.md):
//  1. Lookback is now a calendar-time window (days), not a bar count. A monotonic
//     deque over `time` keeps the window minimum, so 4h crypto, 1D crypto and 1D
//     stocks all compare against the same ~6 calendar months without switching
//     inputs. Pine exposes no session hours (syminfo.session = regular/extended
//     only), so any days->bars conversion would be a market-type heuristic.
//  2. Warm-up gate is time-based (>= window of valid BBW history) instead of
//     bar_index; the low line is hidden until the window is full, so a
//     partial-history low is never shown as a "6-month low".
//  3. Timeframes with fewer than MIN_BARS bars per window (weekly, monthly) show
//     no squeeze: a minimum over ~26 or ~6 bars is not an extreme.
//  4. Colors from the user's chart (screenshot) as input.color(); transparency
//     lives in the default value so the input stays editable (Style/Inputs tab).
//  5. alertcondition() removed: the script is for visual reading only.
//  6. Low line drawn as step line (jumps when an old low leaves the window are
//     window bookkeeping, not a market event). Numeric inputs hidden from the
//     status line to keep it short on mobile.
// Unchanged on purpose: BBW formula (identical to TradingView's BBW, x100),
// close as source, tolerance logic. The current (open) bar still repaints.
indicator("BBW + Squeeze", precision = 2)

len  = input.int(20, "BB-Länge", minval = 2, display = display.none)
mult = input.float(2.0, "StdAbw", minval = 0.1, display = display.none,
     tooltip = "Ändert nur die Höhe der Linien, nicht die Squeeze-Erkennung.")
days = input.int(182, "Vergleichszeitraum (Kalendertage)", minval = 30, display = display.none,
     tooltip = "Bollinger: Tief der letzten ~6 Monate. Gerechnet in Kalendertagen, unabhängig von Zeiteinheit und Handelszeiten. 182 Tage ~ 125 Handelstage bei Aktien.")
tol  = input.float(5.0, "Toleranz über Tief (%)", minval = 0, maxval = 20, display = display.none,
     tooltip = "Relativ zum Tief, nicht in Prozentpunkten. 0 = nur exakt neues Tief (Bollinger pur).")
colBbw = input.color(#DBDBDB,   "Farbe BandWidth")
colLow = input.color(#F23645,   "Farbe Tief")
colBg  = input.color(#E91E6347, "Farbe Squeeze-Hintergrund")  // #E91E63 at ~72 % transparency

MS_DAY   = 86400000
MIN_BARS = 50  // weekly (~26) and monthly (~6) windows are too coarse for an extreme

windowMs  = days * MS_DAY
tooCoarse = days * 86400.0 / timeframe.in_seconds() < MIN_BARS

basis = ta.sma(close, len)
dev   = mult * ta.stdev(close, len)
bbw   = (2 * dev) / basis * 100

// Monotonic deque: values ascend from front to back, front = minimum of the window.
var array<float> dqVal  = array.new<float>()
var array<int>   dqTime = array.new<int>()
var int tStart = na  // open time of the first valid BBW value (warm-up anchor)

if not na(bbw)
    if na(tStart)
        tStart := time
    // Values >= the new one can never become the window minimum again.
    while dqVal.size() > 0 and dqVal.last() >= bbw
        dqVal.pop()
        dqTime.pop()
    dqVal.push(bbw)
    dqTime.push(time)

// Expire entries older than the calendar window.
cutoff = time - windowMs
while dqTime.size() > 0 and dqTime.first() < cutoff
    dqVal.shift()
    dqTime.shift()

float lowLine = dqVal.size() > 0 ? dqVal.first() : na

ready   = not tooCoarse and not na(tStart) and time - tStart >= windowMs
squeeze = ready and bbw <= lowLine * (1 + tol / 100)

plot(bbw, "BandWidth", color = colBbw)
plot(ready ? lowLine : na, "Tief", color = colLow, style = plot.style_stepline)
bgcolor(squeeze ? colBg : na)
````
