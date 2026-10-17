# Pattern Trade Levels

- url: https://www.tradingview.com/script/UGaWc4pk-Pattern-Trade-Levels/
- type: indicator
- pine_id: PUB;59a526c98ee54079a9b57797a800ca81
- version: 1.0

## Description

Pattern Trade Levels

Plots the key levels for a chart-pattern breakout from two inputs: the breakout boundary and the pattern low. Enter them and the script draws the confirmation level, the measured-move target and your stop, plus a small R:R table in the corner. Use it to check whether a setup is worth taking before the breakout triggers.

What it draws
- Boundary: the resistance line you drew.
- Confirm: the boundary plus a buffer (3% by default, the Edwards & Magee rule). A daily close above it confirms the breakout.
- Target: the measured move, either log (B × B / L) or linear (B + (B − L)).
- Stops. Three options, and the one in use is drawn thicker and marked "USED":
  - ATR (the default): boundary − k × ATR20. ATR20 is a simple 20-bar average of true range. It's frozen on the date you set, so the stop doesn't drift each day.
  - Percent: boundary − 3%.
  - Structural: any level you type in, such as the low of the last full day inside the pattern.

The table
Entry, target (% away), stop (% away), R:R (green at 2R or better), the ATR20 used, the stop's distance from the boundary in ATRs and %, and how far price is from the confirmation level.

Alerts
- Confirm breakout: a close crosses above the confirmation level.
- Boundary touch: price crosses above the boundary.
- Stop touched: price trades below the selected stop.

How to use it
1. Draw your pattern and read off the boundary (B) and the pattern low (L).
2. Set the ATR as-of date to your breakout or entry day.
3. Pick an entry basis for the R:R (the confirmation level, the boundary, or the current price) and check that the trade clears your minimum R:R.
4. Size from the stop, e.g. shares = dollar risk ÷ (entry − stop).

Notes
- The stop is a starting point, not a recommendation. Stops about 0.75 to 1.25 ATR below the boundary performed about the same in my own testing. Choose one that suits the instrument.
- Levels assume a horizontal boundary. For sloped patterns, enter the level where the breakout actually happens.
- This is an indicator, not a strategy. It doesn't take trades or backtest anything.
- For education only. Not financial advice.

## Source Code

````pine
//@version=6
// Pattern Trade Levels — companion to scripts/pattern_scan.py (july-backtester issue #348).
// Type in the boundary and pattern low from any chart pattern; draws the confirm (+3%) level,
// the measured-move target, the stop conventions, and an R:R table.
//
// 2026-09-25 (morning-macro issue #28):
//   - Added an ATR stop option, B − k × ATR20, and made it the default. It matches
//     playbooks/breakout-swing.md and scripts/breakout_stop.py.
//       * ATR20 = SIMPLE mean of true range over 20 bars (ta.sma(ta.tr(true), 20)), not
//         Wilder's ta.atr(). This matches the backtests and breakout_stop.py.
//       * ATR is FROZEN at the entry bar ("ATR as-of date"). The stop is set once at entry
//         and held; it is not recomputed daily.
//   - The old orange "negation stop" (B × (1 − 3%)) is relabelled "3% stop". It is NOT Aksel's
//     pattern-negation level (his sheet col J), which usually sits much lower.
//   - The confirm alert now uses the confPct input instead of a hard-coded 3.0.
//   Backtest context (issue #28, 100 Aksel day-one trades, held 60 sessions): line − 1 ATR20
//   +0.50R, line − 3% +0.49 to +0.51R, LFD +0.56R — a statistically tied group. line − 1 ATR20
//   is the playbook default because it's mechanical, not because it's significantly better.
indicator("Pattern Trade Levels", overlay = true)

// ── Inputs ─────────────────────────────────────────────────────────────────────
B        = input.float(40.39, "Boundary / breakout level (B)",            step = 0.01)
L        = input.float(34.40, "Pattern low (L)",                          step = 0.01)
confPct  = input.float(3.0,   "Confirm / 3% stop buffer %",               step = 0.1)
useLog   = input.bool(true,   "Log measured move (BxB/L) — off = B+(B-L)")
entryOpt = input.string("Confirm", "Entry for R:R", options = ["Confirm", "Boundary", "Current price"])

stopMode = input.string("ATR", "Stop mode", options = ["ATR", "Percent", "Structural"],
     tooltip = "ATR = B − k×ATR20 frozen at the entry date (playbook default). Percent = B × (1 − buffer%). Structural = the value typed below (falls back to ATR if 0).")
atrK     = input.float(1.0, "ATR multiple (k)", minval = 0.1, step = 0.25)
atrDate  = input.time(timestamp("24 Sep 2026 00:00 +0000"), "ATR as-of (entry) date",
     tooltip = "ATR20 is taken from the last bar on or before this date, then held. Set it to your entry/breakout date.")
S        = input.float(0.0,   "Structural stop (e.g. LFD low; 0 = off)",  step = 0.01)

// ── Levels ─────────────────────────────────────────────────────────────────────
confirm  = B * (1 + confPct / 100)          // daily close above = validated breakout
pctStop  = B * (1 - confPct / 100)          // 3% buffer stop (NOT Aksel's pattern negation)
target   = useLog ? B * B / L : B + (B - L)

atr20    = ta.sma(ta.tr(true), 20)          // simple-mean ATR20 (matches backtests / breakout_stop.py)
var float atrAtEntry = na
if time <= atrDate
    atrAtEntry := atr20                     // keeps updating until the as-of date, then frozen
atrStop  = B - atrK * atrAtEntry

entry    = entryOpt == "Confirm" ? confirm : entryOpt == "Boundary" ? B : close
stopUsed = stopMode == "Percent" ? pctStop : stopMode == "Structural" and S > 0 ? S : atrStop
stopName = stopMode == "Percent" ? "3% stop" : stopMode == "Structural" and S > 0 ? "structural" : "B − " + str.tostring(atrK, "#.##") + "×ATR20"
rr       = entry - stopUsed > 0 ? (target - entry) / (entry - stopUsed) : na

// ── Drawing ────────────────────────────────────────────────────────────────────
var line  lnB = na
var line  lnC = na
var line  lnT = na
var line  lnP = na
var line  lnA = na
var line  lnS = na
var label lbB = na
var label lbC = na
var label lbT = na
var label lbP = na
var label lbA = na
var label lbS = na

f_lvl(line ln, label lb, float y, color col, string txt, int w) =>
    line.delete(ln)
    label.delete(lb)
    l = line.new(bar_index - 1, y, bar_index, y, color = col, width = w,
                 style = line.style_dotted, extend = extend.both)
    b = label.new(bar_index - 30, y, txt + "  " + str.tostring(y, format.mintick),
                  color = color.new(color.black, 100), textcolor = col,
                  style = label.style_none, size = size.normal)
    [l, b]

if barstate.islast
    [l1, b1] = f_lvl(lnB, lbB, B,       color.fuchsia, "boundary", 1)
    [l2, b2] = f_lvl(lnC, lbC, confirm, color.aqua,    "confirm +" + str.tostring(confPct, "#.#") + "%", 1)
    [l3, b3] = f_lvl(lnT, lbT, target,  color.lime,    "target", 1)
    [l4, b4] = f_lvl(lnP, lbP, pctStop, color.orange,  "3% stop" + (stopMode == "Percent" ? "  ◄ USED" : ""), stopMode == "Percent" ? 2 : 1)
    lnB := l1, lbB := b1, lnC := l2, lbC := b2, lnT := l3, lbT := b3, lnP := l4, lbP := b4
    if not na(atrStop)
        usedA = stopMode == "ATR" or (stopMode == "Structural" and S <= 0)
        [l5, b5] = f_lvl(lnA, lbA, atrStop, color.red, "ATR stop (B − " + str.tostring(atrK, "#.##") + "×ATR20)" + (usedA ? "  ◄ USED" : ""), usedA ? 2 : 1)
        lnA := l5, lbA := b5
    if S > 0
        usedS = stopMode == "Structural"
        [l6, b6] = f_lvl(lnS, lbS, S, color.purple, "structural stop" + (usedS ? "  ◄ USED" : ""), usedS ? 2 : 1)
        lnS := l6, lbS := b6

    var table t = table.new(position.top_right, 2, 7, bgcolor = color.new(color.black, 20))
    table.cell(t, 0, 0, "Entry (" + entryOpt + ")", text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 0, str.tostring(entry, format.mintick),  text_color = color.white, text_size = size.small)
    table.cell(t, 0, 1, "Target",                  text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 1, str.tostring(target, format.mintick) + "  (+" + str.tostring((target / entry - 1) * 100, "#.#") + "%)",
               text_color = color.lime,  text_size = size.small)
    table.cell(t, 0, 2, "Stop (" + stopName + ")", text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 2, na(stopUsed) ? "n/a" : str.tostring(stopUsed, format.mintick) + "  (-" + str.tostring((1 - stopUsed / entry) * 100, "#.#") + "%)",
               text_color = color.red, text_size = size.small)
    table.cell(t, 0, 3, "R : R",                   text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 3, na(rr) ? "n/a" : str.tostring(rr, "#.##") + "R",
               text_color = rr >= 2 ? color.lime : color.red, text_size = size.small)
    table.cell(t, 0, 4, "ATR20 @ as-of date",      text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 4, na(atrAtEntry) ? "n/a" : str.tostring(atrAtEntry, format.mintick),
               text_color = color.white, text_size = size.small)
    table.cell(t, 0, 5, "Stop distance from B",    text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 5, na(stopUsed) or na(atrAtEntry) ? "n/a" : str.tostring((B - stopUsed) / atrAtEntry, "#.##") + "×ATR  /  " + str.tostring((1 - stopUsed / B) * 100, "#.#") + "%",
               text_color = color.white, text_size = size.small)
    table.cell(t, 0, 6, "Dist to confirm",         text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 6, str.tostring((confirm / close - 1) * 100, "#.##") + "%",
               text_color = color.white, text_size = size.small)

// ── Alerts ─────────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(close, confirm), "Confirm breakout",
               "Price crossed above the confirm level — breakout validated")
alertcondition(ta.crossover(close, B), "Boundary touch",
               "Price crossed above the pattern boundary")
alertcondition(ta.crossunder(low, stopUsed), "Stop touched",
               "Price traded below the selected stop level")
````
