# Opening Range Breakout 

- url: https://www.tradingview.com/script/OUkUGhJn-Opening-Range-Breakout/
- type: indicator
- pine_id: PUB;ec680a9786e34848be3b2948921f8b36
- version: 4.0

## Description

## Opening Range Breakout (ORB) — 8:30–8:45 CT

**What it does**
Marks the first 15-minute candle after the CME open (8:30–8:45 America/Chicago), locks that high and low as the opening range, then fires a single, no-repaint signal the moment price breaks the range for the first time. One trade idea per session — no spam, no flicker.

**How it works**
- Builds the range live from 8:30, locks it permanently at 8:45.
- **BUY** on the first break above the range high. **SELL** on the first break below the range low.
- If both sides break on the same bar, direction is resolved by where price closed relative to the range midpoint.
- Signal latches after firing — it will not repeat or repaint for the rest of the session.

**The one knob**
`Signal on wick break` — OFF (default) waits for a confirmed bar close before signaling (cleaner, fewer fakeouts). ON triggers the instant a wick pierces the range (faster, more noise).

**Built for**
NQ / MNQ index futures on the 8:30 CT open. Run it on a **1m–15m chart** — it warns you if the timeframe is too large for the range to build correctly.

**Alerts**
Two ready conditions: *OR Breakout — BUY* and *OR Breakout — SELL*, wired to the same latched logic as the on-chart labels.

---

Want a shorter punchline version for a TradingView title card, or a longer one with the trading logic spelled out for your Discord?

## Source Code

````pine
//@version=6
indicator("Opening Range Breakout", overlay=true)

// ── SETTINGS ──────────────────────────────────────────────
tz      = "America/Chicago"     // Lee's Summit / CME time
orSess  = "0830-0845"           // first 15-min candle after the open

// run on a small chart or the range is wrong
if barstate.islast and timeframe.in_seconds() > 900
    label.new(bar_index, high, "Run on a 1m–15m chart", style=label.style_label_down, color=color.orange, textcolor=color.white)

// ── OPENING RANGE: build 8:30–8:45, lock at 8:45 ──────────
in_or       = not na(time(timeframe.period, orSess, tz))
is_or_start = in_or and not in_or[1]
is_or_end   = not in_or and in_or[1]

var float orH      = na
var float orL      = na
var bool  locked   = false
var bool  signaled = false
var int   pendDir  = 0          // 0 none, +1 buy armed, -1 sell armed

if is_or_start
    orH := high
    orL := low
    locked := false
    signaled := false
    pendDir := 0
else if in_or
    orH := math.max(orH, high)
    orL := math.min(orL, low)

if is_or_end
    locked := true

// ── SIGNAL: first CLOSE-and-hold beyond the range → fire the NEXT candle ──
bool buy_signal  = false
bool sell_signal = false

// STEP 1 — a break closed & held last bar → fire immediately on THIS (next) candle
if pendDir == 1 and not signaled
    buy_signal := true
    signaled   := true
    pendDir    := 0
else if pendDir == -1 and not signaled
    sell_signal := true
    signaled    := true
    pendDir     := 0

// STEP 2 — arm on the FIRST candle that truly CLOSES beyond the range (confirmed close only)
if barstate.isconfirmed and locked and not signaled and pendDir == 0 and not na(orH)
    if close > orH
        pendDir := 1
    else if close < orL
        pendDir := -1

// ── VISUALS ───────────────────────────────────────────────
plot(locked ? orH : na, "OR High", color=color.new(#00ffbb, 0), style=plot.style_linebr, linewidth=2)
plot(locked ? orL : na, "OR Low",  color=color.new(#ff0055, 0), style=plot.style_linebr, linewidth=2)

plotshape(buy_signal,  title="Buy",  style=shape.labelup,   location=location.belowbar, color=color.green, text="BUY",  textcolor=color.white, size=size.small)
plotshape(sell_signal, title="Sell", style=shape.labeldown, location=location.abovebar, color=color.red,   text="SELL", textcolor=color.white, size=size.small)

// ── ALERTS: straight-up selectable Buy / Sell in the alert dropdown ──
alertcondition(buy_signal,  title="Buy",  message="BUY")
alertcondition(sell_signal, title="Sell", message="SELL")
````
