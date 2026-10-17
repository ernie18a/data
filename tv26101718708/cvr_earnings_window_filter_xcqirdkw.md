# CVR Earnings Window Filter

- url: https://www.tradingview.com/script/xcqIrdkW-CVR-Earnings-Window-Filter/
- type: indicator
- pine_id: PUB;0c5033279eda48ba9174f8485aadefe7
- version: 2.0

## Description

What It Does
The indicator answers a single practical question on every chart: how close is the next earnings event, and does that proximity matter for my trading decision?
It calculates the number of calendar days between right now and the next scheduled earnings release using TradingView's built-in earnings.future_time variable, which holds the Unix timestamp of the next announced earnings date for the current symbol.

Inputs
ParameterDefaultRangeDescriptionN — days until earnings51–60Width of the earnings window in calendar daysFilter modeAvoid window—Controls which condition is a pass

Core Calculation
days_until = floor( (earnings.future_time − timenow) / 86,400,000 )
Floored to full calendar days. Earnings day itself is always day 0 and is always excluded from the window. The active window is the interval [1, N].
days_untilMeaningnaNo earnings date on file for this symbol0Earnings today — excluded from window1Earnings tomorrow — first day inside window> NOutside window — far enough from earnings

Filter Modes
Avoid Window — passes = true when the symbol is outside the window. Enforces a pre-earnings blackout zone (e.g. no new entries within 5 days of a report). Symbols with no date on file (na) pass as safe.
Target Window — passes = true when the symbol is inside the window. Surfaces stocks approaching an earnings catalyst for pre-earnings setup hunting.

Visual Output

Blue step-line — raw days_until value per bar
Dashed line at N — outer boundary; when the line crosses below, the window is active
Dotted lines at 1 and 0 — inner boundaries marking the earnings day itself
Orange background — active whenever the window is open (1 ≤ days_until ≤ N)
Label on last bar — green if the symbol passes the active mode, red if blocked


Edge Cases

No date (na): Avoid mode passes, Target mode blocks
Earnings today (0): outside the window in both modes — the earnings day is never included
Calendar vs. trading days: the calculation uses raw calendar days; a Monday report shows 2 on Friday, not 1
Data accuracy: depends on whether TradingView has a confirmed date; unconfirmed estimates may differ from the actual report

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cristian.vrinceanu

//@version=6
indicator("Earnings Window Filter", overlay = true)

// ── INPUT ────────────────────────────────────────────────────────────────────
N  = input.int(5, "N — days to earnings threshold", minval = 1, maxval = 60)
MS = 86400000  // milliseconds per calendar day

// ── CALCULATION ──────────────────────────────────────────────────────────────
// earnings.future_time = next scheduled earnings (ms). timenow = current time (ms).
float days_last = not na(earnings.future_time) ? math.floor((earnings.future_time - timenow) / float(MS)) : na

// 0 = inside window [0, N], 1 = outside window
bool in_window  = not na(days_last) and days_last >= 0 and days_last <= N
int above_last = in_window ? 0 : 1

// ── VISUAL ───────────────────────────────────────────────────────────────────
// Red background on the last bar only, full chart height, when in window
bgcolor(barstate.islast and in_window ? color.new(color.red, 75) : na)

// ── SCREENER OUTPUTS ─────────────────────────────────────────────────────────
plot(days_last,  "Days to Earnings", display = display.none)
plot(above_last, "Above Threshold",  display = display.none)
````
