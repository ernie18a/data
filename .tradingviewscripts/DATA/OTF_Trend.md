<!-- tradingview-pine-id: PUB;b1c6be9cd9394ef09f3cb97f086bc8fd -->
<!-- tradingviewscripts-format: 1 -->
# OTF Trend

Source: https://www.tradingview.com/script/m19wr5WE-One-Time-Framing/

## Description

OTF Trend

One Time Framing is a simple idea from auction market theory (the AMD / Market Profile world) that gets overcomplicated more often than it needs to be. 

A market is one time framing up when each bar makes a higher low than the one before it. That's the whole test — the highs aren't part of it. Sellers might still be winning the fight for the high, but as long as they can't push price below the previous bar's low, they're not getting control of the auction. Buyers are setting the floor, one bar at a time, and one timeframe of participant is running the show. One time framing down is the mirror image: each bar makes a lower high, and buyers can't lift price above the previous high.

What the indicator draws

A green triangle below the bar when a new upward run begins, a red triangle above the bar when a new downward run begins. Faded dots mark each bar the run continues. A small × marks the bar where the run ends.

You choose how many consecutive bars are required before it counts. The default is 2 — one higher low is enough to call it. Push it to 3 or 4 and you'll get far fewer signals, but the ones you get will have more behind them. I'd suggest 3 on daily and weekly charts, 2 on intraday.

Inside bars

An inside bar has a higher low and a lower high. On the letter of the definition, it technically qualifies as one time framing in both directions at once. So this indicator treats inside bars as neutral. They don't extend a run and they don't break one — the count simply pauses. Price is coiling, nobody is in control, and the trend picks up where it left off on the next real bar. Inside bars get their own colour so you can see them at a glance.

There's a second job inside bars do here though. Because they represent a genuine pause, a break of an inside bar's range is often the moment the trend actually turns. So when an inside bar prints, the indicator remembers its high and low. If price then breaks out of that range in the opposite direction to the current trend, that counts as a reversal and flips the trend immediately — you don't have to wait for a fresh run to build up from scratch. This tends to get you in a bar or two earlier at turning points.

That pending setup expires if nothing happens within a set number of bars (default 8), so a stale inside bar from thirty bars back can't fire off a signal that has nothing to do with current price action.

What actually triggers a new trend

In priority order, each bar:

No trend running and a fresh run qualifies → new trend, triangle prints
An inside bar range break against the existing trend → reversal, triangle prints
The current run is broken → trend ends, × prints

A trend ending and a new one starting in the other direction are deliberately kept on separate bars. You could argue for collapsing them into one, but I'd rather see the exit clearly than save a bar on the entry.

Settings

Optional bar colouring for up runs, down runs and inside bars, all colours adjustable
Optional moving average with a choice of types (EMA 21 by default) purely for context — it plays no part in the signal logic
Alerts for new bullish and bearish runs, for inside bar reversals specifically, and for a trend ending
The run depth counters are exposed in the Data Window if you want to see how deep the current run is

Things to consider

Set your alerts to Once Per Bar Close. The state of the current bar can change as its high and low extend, so anything read intrabar isn't final.

Also be aware that a large gap can satisfy "higher low" on its own without any real structure behind it. Worth knowing if you're running this over earnings on equities or any asset that gaps over a weekend or overnight.

This isn't a standalone system. One time framing tells you who's in control right now, not whether you should be in the trade. Use it for confirmation and for timing entries within a bias you've already formed elsewhere.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mickaswah

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mickaswah

//@version=6
indicator("OTF Trend", shorttitle="OTF", overlay = true)

// ═══════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════

var string G_OTF = "OTF Detection"
var string G_MSS = "MSS Reversal"
var string G_VIS = "Visuals"
var string G_MA  = "Moving Average"

lookbackBars = input.int(2, "Consecutive Bars", minval = 2, group = G_OTF,
     tooltip = "Bars required in the run. 2 = one higher low / lower high. " +
               "Higher values = fewer, higher-conviction signals.")

mssMaxBars = input.int(8, "MSS Expiry (bars)", minval = 1, group = G_MSS,
     tooltip = "A pending inside-bar setup is discarded if not confirmed within this many bars.")

showExit = input.bool(true, "Show Trend-End Marker", group = G_VIS)
showCont = input.bool(true, "Show Continuation Dots",  group = G_VIS)

enableUpColor     = input.bool(true, "Colour Up Bars",     group = G_VIS)
enableDownColor   = input.bool(true, "Colour Down Bars",   group = G_VIS)
enableInsideColor = input.bool(true, "Colour Inside Bars", group = G_VIS)

barColorUp     = input.color(color.rgb(241, 243, 241), "Up",     group = G_VIS, inline = "bc")
barColorDown   = input.color(color.rgb(94, 93, 93),    "Down",   group = G_VIS, inline = "bc")
insideBarColor = input.color(color.rgb(60, 136, 250),  "Inside", group = G_VIS, inline = "bc")

showMA   = input.bool(true, "Show MA", group = G_MA)
maType   = input.string("EMA", "Type", options = ["SMA","EMA","WMA","VWMA","RMA","DEMA"], group = G_MA)
maLength = input.int(21, "Length", minval = 1, group = G_MA)
maColor  = input.color(color.rgb(243, 243, 240), "Colour", group = G_MA)

// ═══════════════════════════════════════════════════════════════════
//  CALCULATIONS
// ═══════════════════════════════════════════════════════════════════

// --- Moving average -------------------------------------------------
ma = switch maType
    "SMA"  => ta.sma(close, maLength)
    "EMA"  => ta.ema(close, maLength)
    "WMA"  => ta.wma(close, maLength)
    "VWMA" => ta.vwma(close, maLength)
    "RMA"  => ta.rma(close, maLength)
    "DEMA" => 2 * ta.ema(close, maLength) - ta.ema(ta.ema(close, maLength), maLength)

// --- Bar classification ---------------------------------------------
// Inside bars are NEUTRAL: they neither extend nor break an OTF run.
// (An inside bar satisfies "higher low" AND "lower high" simultaneously,
//  so counting it would corrupt both direction counters.)
isInside = high < high[1] and low > low[1]

// --- OTF run counters (O(1), replaces the per-bar loop) --------------
// Dalton's definition is low-based (up) / high-based (down). Raw
// highs and lows are used here deliberately — no body substitution.
var int upRun = 0
var int dnRun = 0

if not isInside
    upRun := low  > low[1]  ? upRun + 1 : 0
    dnRun := high < high[1] ? dnRun + 1 : 0

otfUp   = upRun >= lookbackBars - 1
otfDown = dnRun >= lookbackBars - 1

// --- MSS pending state (inside-bar range break) ----------------------
var float insideHigh = na
var float insideLow  = na
var int   insideIdx  = na

// A new inside bar arms (or re-arms) the pending setup.
if isInside
    insideHigh := high
    insideLow  := low
    insideIdx  := bar_index

// Pending is live only within the expiry window.
mssArmed = not na(insideIdx) and (bar_index - insideIdx) <= mssMaxBars and not isInside

// Confirmation is ALWAYS close-based, by design and not optional.
// A wick through the inside bar range that closes back inside is a
// failed probe, not a change of control. Using high/low here produces
// reversal signals that no reading of the auction would support, and
// the error scales with bar size — worst on Daily and Weekly.
confirmedUp   = mssArmed and close > insideHigh and low  > low[1]
confirmedDown = mssArmed and close < insideLow  and high < high[1]

// Disarm on confirmation so the same setup can't fire twice.
if confirmedUp or confirmedDown
    insideIdx := na

// ═══════════════════════════════════════════════════════════════════
//  TREND STATE MACHINE
//  Single write per bar, evaluated against a snapshot of the prior
//  state. This is what prevents same-bar overwrite bugs.
// ═══════════════════════════════════════════════════════════════════

var int trend = 0                  // 1 = up, -1 = down, 0 = none
int prevTrend = trend              // snapshot BEFORE any mutation

// Signal flags — the single source of truth for shapes AND alerts.
bool sigRevUp   = false            // MSS reversal into up
bool sigRevDn   = false
bool sigStartUp = false            // fresh OTF start from flat
bool sigStartDn = false
bool sigExitUp  = false            // up trend terminated
bool sigExitDn  = false

// Candidate events, all measured against prevTrend.
bool brokeUp = prevTrend ==  1 and not otfUp   and not isInside
bool brokeDn = prevTrend == -1 and not otfDown and not isInside

if confirmedUp and prevTrend != 1
    trend     := 1
    sigRevUp  := true

else if confirmedDown and prevTrend != -1
    trend     := -1
    sigRevDn  := true

else if brokeUp or brokeDn
    trend     := 0
    sigExitUp := brokeUp
    sigExitDn := brokeDn
    // Deliberate: no same-bar flip. Re-entry is evaluated next bar,
    // which preserves a clean, unambiguous exit signal.

else if prevTrend == 0 and not isInside
    if otfUp
        trend      := 1
        sigStartUp := true
    else if otfDown
        trend      := -1
        sigStartDn := true

// Derived display conditions
newUp  = sigRevUp or sigStartUp
newDn  = sigRevDn or sigStartDn
contUp = trend ==  1 and otfUp   and not newUp and not isInside
contDn = trend == -1 and otfDown and not newDn and not isInside

// ═══════════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════════

plotshape(newUp, title = "New Up", location = location.belowbar,
     style = shape.triangleup, color = color.green, size = size.tiny)
plotshape(newDn, title = "New Down", location = location.abovebar,
     style = shape.triangledown, color = color.red, size = size.tiny)

plotshape(showCont and contUp, title = "Cont Up", location = location.belowbar,
     style = shape.circle, color = color.new(color.green, 60), size = size.tiny)
plotshape(showCont and contDn, title = "Cont Down", location = location.abovebar,
     style = shape.circle, color = color.new(color.red, 60), size = size.tiny)

plotchar(showExit and sigExitUp, title = "Up Trend End", char = "×",
     location = location.belowbar, color = color.new(color.green, 30), size = size.tiny)
plotchar(showExit and sigExitDn, title = "Down Trend End", char = "×",
     location = location.abovebar, color = color.new(color.red, 30), size = size.tiny)

// Bar colouring — inside bars take priority so the paint matches the
// fact that no continuation dot is drawn on them.
color barc = na
if isInside and enableInsideColor
    barc := insideBarColor
else if trend == 1 and otfUp and enableUpColor
    barc := barColorUp
else if trend == -1 and otfDown and enableDownColor
    barc := barColorDown
barcolor(barc)

// MA on the pane only — keeps the Data Window clean.
plot(showMA ? ma : na, title = "MA", color = maColor, display = display.pane)

// Run depth in the Data Window for diagnostics / Bar Replay.
plot(upRun, title = "Up Run",   display = display.data_window)
plot(dnRun, title = "Down Run", display = display.data_window)
plot(trend, title = "Trend",    display = display.data_window + display.status_line)

// ═══════════════════════════════════════════════════════════════════
//  ALERTS
//  Fired from the same flags that draw the shapes — visual and alert
//  can no longer diverge.
// ═══════════════════════════════════════════════════════════════════

alertcondition(newUp, title = "Bullish OTF",
     message = "Bullish OTF | {{ticker}} | {{interval}} | Close: {{close}}")
alertcondition(newDn, title = "Bearish OTF",
     message = "Bearish OTF | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(sigRevUp, title = "Bullish MSS Reversal",
     message = "Bullish MSS Reversal | {{ticker}} | {{interval}} | Close: {{close}}")
alertcondition(sigRevDn, title = "Bearish MSS Reversal",
     message = "Bearish MSS Reversal | {{ticker}} | {{interval}} | Close: {{close}}")

alertcondition(sigExitUp or sigExitDn, title = "OTF Trend End",
     message = "OTF Trend Ended | {{ticker}} | {{interval}} | Close: {{close}}")
````
