<!-- tradingview-pine-id: PUB;84c9c3eaa45c4133a68368233496de08 -->
<!-- tradingviewscripts-format: 1 -->
# Market Internals Status — TICK / ADD / VOLD

Source: https://www.tradingview.com/script/TjxEzlYA/

## Description

This indicator displays a real-time status table for three classic NYSE/Nasdaq
market-breadth internals: [symbol="USI:TICK"]USI:TICK[/symbol], [symbol="USI:ADD"]USI:ADD[/symbol] (advance/decline issues, Nasdaq variant
by default) and [symbol="USI:VOLD"]USI:VOLD[/symbol] (up/down volume difference). It is designed for index
futures and index CFD traders (ES, MES, SPX, NQ, etc.) who use market
internals to confirm directional bias before entering a trade.

METHODOLOGY
Each internal is classified using a fixed absolute-level threshold you control
from the settings: a reading above the "bullish" threshold is tagged BULLISH,
below the "bearish" threshold is tagged BEARISH, and anything in between is
NEUTRAL. This is a simple level-based read, not a moving average, oscillator,
or percentile rank — the goal is to mirror how discretionary traders read raw
internals on a dedicated internals chart, but with an objective, repeatable
rule instead of a visual guess.

A CONSENSUS row aggregates the three readings: it shows "aligned bullish" or
"aligned bearish" only when at least two of the three internals agree in the
same direction past their threshold; otherwise it shows "mixed/flat",
flagging a session where internals do not confirm a clean directional bias.

DATA VALIDATION
Market-internal data feeds occasionally emit corrupted or placeholder values
when the underlying index has no valid tick (e.g., outside NYSE/Nasdaq
cash-session hours). The script validates every reading against a
configurable sanity ceiling per internal. A reading outside that realistic
range is treated as invalid and shown as N/A instead of being misclassified
as bullish or bearish, and it is excluded from the consensus calculation.

SESSION AWARENESS
[symbol="USI:TICK"]USI:TICK[/symbol], [symbol="USI:ADD"]USI:ADD[/symbol] and [symbol="USI:VOLD"]USI:VOLD[/symbol] are breadth measures of the NYSE/Nasdaq cash equity
market and therefore only update during the 09:30–16:00 America/New_York
session. A SESSION row tells you at a glance whether the reading is live or
frozen from the prior session close — important context if you trade an
instrument (like index futures) that keeps trading outside cash-market hours.

HOW TO USE IT
Add the indicator to any chart — it does not need to be an internals chart
itself, it fetches its own data via request.security(). Open the settings to:
(1) pick the exact ticker for each internal your data plan provides, since
exchange-composite symbol naming can vary; (2) set your own bullish/bearish
thresholds; (3) adjust the sanity ceilings if you trade an internal with an
unusually wide typical range. Use the resulting table as a breadth
confirmation filter alongside your own price/volume-based setup — it is not
a standalone entry signal.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradercolombiia

//@version=6
indicator("Market Internals Status — TICK / ADD / VOLD", overlay=true)

// ============================================================
// Public release version — English UI text and comments, per
// TradingView House Rules on Script Publishing (English must be
// predominant). Functionally identical to internals_status.pine,
// the private/Spanish working copy used for personal trading
// routine (kept unchanged in this repo).
//
// Status table for three classic NYSE/Nasdaq market-breadth
// internals: $TICK, $ADD (advance/decline issues) and $VOLD
// (up/down volume difference). Classifies each by a configurable
// absolute-level threshold: BULLISH / BEARISH / NEUTRAL. A
// CONSENSUS row aggregates the three, and a SESSION row shows
// whether the underlying cash-equity data is currently live or
// frozen outside NYSE/Nasdaq trading hours.
// ============================================================

// === Symbols (editable from the indicator settings) ===
// Note: the Nasdaq advance/decline symbol on TradingView is
// "USI:ADDQ" (not "USI:ADDN"). Use "USI:ADD" for the NYSE version.
tickSymbol = input.symbol("USI:TICK", "TICK Symbol")
addSymbol  = input.symbol("USI:ADDQ", "ADD Symbol (Nasdaq A/D)")
voldSymbol = input.symbol("USI:VOLD", "VOLD Symbol")

// === Absolute-level thresholds ===
tickUp   = input.float(400,        "TICK bullish >",   group="Thresholds")
tickDown = input.float(-400,       "TICK bearish <",   group="Thresholds")
addUp    = input.float(800,        "ADD bullish >",    group="Thresholds")
addDown  = input.float(-800,       "ADD bearish <",    group="Thresholds")
voldUp   = input.float(300000000,  "VOLD bullish >",   group="Thresholds")
voldDown = input.float(-300000000, "VOLD bearish <",   group="Thresholds")

// === Data sanity check: values outside this range are treated as
// invalid (corrupted feed / no-data sentinel), not a real reading —
// prevents a bad tick from being counted as a signal. ===
tickSanityMax = input.float(3000,        "TICK · max valid value", group="Data Sanity Check")
addSanityMax  = input.float(5000,        "ADD · max valid value",  group="Data Sanity Check")
voldSanityMax = input.float(5000000000,  "VOLD · max valid value", group="Data Sanity Check")

// === NYSE session: $TICK/$ADD/$VOLD are equity-market breadth
// measures and only update during cash-equity trading hours.
// Outside that window (pre-market/after-hours/weekend on a futures
// chart) the value freezes at the last session close — that is
// expected data behavior, not a script error. ===
nyseSession = input.session("0930-1600", "NYSE Session Hours (equities)", group="Session")
inNyseSession = not na(time(timeframe.period, nyseSession, "America/New_York"))

// === Data ===
tickVal = request.security(tickSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off)
addVal  = request.security(addSymbol,  timeframe.period, close, lookahead=barmerge.lookahead_off)
voldVal = request.security(voldSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off)

// === Validity: not na AND within a realistic range ===
f_valid(val, maxAbs) =>
    not na(val) and math.abs(val) <= maxAbs

tickValid = f_valid(tickVal, tickSanityMax)
addValid  = f_valid(addVal, addSanityMax)
voldValid = f_valid(voldVal, voldSanityMax)

// === Classification: 1 bullish, -1 bearish, 0 neutral/invalid ===
f_status(val, up, down, valid) =>
    valid ? (val > up ? 1 : val < down ? -1 : 0) : 0

tickStatus = f_status(tickVal, tickUp, tickDown, tickValid)
addStatus  = f_status(addVal, addUp, addDown, addValid)
voldStatus = f_status(voldVal, voldUp, voldDown, voldValid)

f_label(status, valid) =>
    not valid ? "N/A" : status == 1 ? "BULLISH" : status == -1 ? "BEARISH" : "NEUTRAL"

f_color(status, valid) =>
    not valid ? color.new(color.gray, 0) : status == 1 ? color.new(color.green, 0) : status == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)

// === Compact K/M/B formatting so large values don't overflow the table ===
f_compact(val) =>
    absVal = math.abs(val)
    sign = val < 0 ? "-" : ""
    result = absVal >= 1e9 ? sign + str.tostring(absVal / 1e9, "#.##") + "B" :
      absVal >= 1e6 ? sign + str.tostring(absVal / 1e6, "#.##") + "M" :
      absVal >= 1e3 ? sign + str.tostring(absVal / 1e3, "#.##") + "K" :
      str.tostring(val, "#.##")
    result

f_display(val, valid) =>
    valid ? f_compact(val) : "N/A"

// === Consensus ===
sumStatus = tickStatus + addStatus + voldStatus
consensusLabel = sumStatus >= 2 ? "ALIGNED BULLISH" : sumStatus <= -2 ? "ALIGNED BEARISH" : "MIXED / FLAT"
consensusColor = sumStatus >= 2 ? color.new(color.green, 0) : sumStatus <= -2 ? color.new(color.red, 0) : color.new(color.gray, 0)

// === Table ===
var table t = table.new(position.top_right, 3, 6, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "INTERNAL", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(t, 1, 0, "VALUE",    bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(t, 2, 0, "STATUS",   bgcolor=color.new(color.black, 0), text_color=color.white)

    table.cell(t, 0, 1, "$TICK", text_color=color.white)
    table.cell(t, 1, 1, f_display(tickVal, tickValid), text_color=color.white)
    table.cell(t, 2, 1, f_label(tickStatus, tickValid), bgcolor=f_color(tickStatus, tickValid), text_color=color.white)

    table.cell(t, 0, 2, "$ADD", text_color=color.white)
    table.cell(t, 1, 2, f_display(addVal, addValid), text_color=color.white)
    table.cell(t, 2, 2, f_label(addStatus, addValid), bgcolor=f_color(addStatus, addValid), text_color=color.white)

    table.cell(t, 0, 3, "$VOLD", text_color=color.white)
    table.cell(t, 1, 3, f_display(voldVal, voldValid), text_color=color.white)
    table.cell(t, 2, 3, f_label(voldStatus, voldValid), bgcolor=f_color(voldStatus, voldValid), text_color=color.white)

    table.cell(t, 0, 4, "CONSENSUS", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(t, 1, 4, "", bgcolor=color.new(color.black, 0))
    table.cell(t, 2, 4, consensusLabel, bgcolor=consensusColor, text_color=color.white)

    table.cell(t, 0, 5, "SESSION", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(t, 1, 5, "", bgcolor=color.new(color.black, 0))
    table.cell(t, 2, 5, inNyseSession ? "OPEN" : "CLOSED (frozen)", bgcolor=inNyseSession ? color.new(color.green, 0) : color.new(color.gray, 0), text_color=color.white)
````
