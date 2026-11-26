# TRADERXMOM Indicator

- url: https://www.tradingview.com/script/oU5cENCF-TRADERXMOM-Indicator/
- type: indicator
- pine_id: PUB;c0c4d5a1700647bfa147b9a982190710
- version: 9.0

## Description

TRADERXMOM Indicator (Heikin Ashi/EMA Momentum)

[b]What it does[/b]
Plots directional momentum signals on Heikin Ashi price action, generated from three independently-gated pattern types: an initial breakout, a pullback-and-continuation, and an EMA-cross condition. "Signal Up"/"Signal Down" markers indicate qualifying momentum shifts within active sessions.

[b]How it works[/b]
Heikin Ashi values are calculated manually within the script rather than via a built-in HA ticker override, keeping signal computation independent from the real OHLC series. A fast EMA pair (8/21) drives trend direction and entry timing; a separate, slower EMA pair (13/48) is shown purely as visual reference and isn't part of the signal logic. Each of the three pattern types requires a full-bodied Heikin Ashi candle (no wick on the trend side) as confirmation:

Breakout — a strong-bodied HA candle closing beyond both EMAs in trend direction
Pullback — trend intact, price pulled back toward the fast EMA over the prior several bars, then a strong-bodied HA candle resumes in trend direction
EMA Cross — the fast/slow EMA pair crosses, confirmed by a strong-bodied HA candle

Recognizing three distinct momentum behaviors rather than relying on a single crossover rule is the core differentiator from standard single-trigger EMA/HA scripts, which typically only catch one of these patterns and miss the others.

Signals are further gated by up to four configurable session windows, a cooldown period between signals to prevent clustering, a defined kill zone that blocks signals late in the session, and an optional VWAP directional filter.

[b]How to use it[/b]
Built for micro index futures (MNQ, MES) on lower intraday timeframes. Enable or disable individual sessions and the VWAP filter to match your own trading windows. Signal markers indicate conditions worth evaluating, not automatic entries — always apply your own risk management.

## Source Code

````pine
//@version=6
indicator("TRADERXMOM Indicator", overlay=true)

// ============================================================
// TRADERXMOM — HA EMA Momentum Indicator
// 8/13 EMA + HA Entry Model + VWAP Filter
// 21 EMA = DISPLAY ONLY
// 3 Full-Bar Cooldown
// Signal labels only — no order execution
// ============================================================

// ─────────────────────────────────────────────────────────────
// DISPLAY
// ─────────────────────────────────────────────────────────────

showEMAs    = input.bool(true, "Show EMAs", group="Display")
showSignals = input.bool(true, "Show Signals", group="Display")


// ─────────────────────────────────────────────────────────────
// SESSION FILTER
// ─────────────────────────────────────────────────────────────

useTimeFilter = input.bool(
     true,
     "Use time filter",
     group="Session 1"
     )

sess1Enabled = input.bool(
     true,
     "Session 1 on",
     group="Session 1"
     )

session1 = input.session(
     "0930-1130",
     "Session 1",
     group="Session 1"
     )

sess1BgColor = input.color(
     color.new(color.blue, 92),
     "Session 1 background",
     group="Session 1"
     )

sess2Enabled = input.bool(
     true,
     "Session 2 on",
     group="Session 2"
     )

session2 = input.session(
     "1330-1600",
     "Session 2",
     group="Session 2"
     )

sess2BgColor = input.color(
     color.new(color.purple, 92),
     "Session 2 background",
     group="Session 2"
     )

sess3Enabled = input.bool(
     true,
     "Session 3 on",
     group="Session 3"
     )

session3 = input.session(
     "1800-0000",
     "Session 3",
     group="Session 3"
     )

sess3BgColor = input.color(
     color.new(color.teal, 92),
     "Session 3 background",
     group="Session 3"
     )

sess4Enabled = input.bool(
     true,
     "Session 4 on",
     group="Session 4"
     )

session4 = input.session(
     "0000-0600",
     "Session 4",
     group="Session 4"
     )

sess4BgColor = input.color(
     color.new(color.orange, 92),
     "Session 4 background",
     group="Session 4"
     )


// ─────────────────────────────────────────────────────────────
// KILL ZONE
// ─────────────────────────────────────────────────────────────

TIME_EXIT_HOUR   = 15
TIME_EXIT_MINUTE = 50
GLOBEX_HOUR      = 18


// ─────────────────────────────────────────────────────────────
// SESSIONS
// ─────────────────────────────────────────────────────────────

inSession1 = sess1Enabled and not na(
     time(timeframe.period, session1, "America/New_York")
     )

inSession2 = sess2Enabled and not na(
     time(timeframe.period, session2, "America/New_York")
     )

inSession3 = sess3Enabled and not na(
     time(timeframe.period, session3, "America/New_York")
     )

inSession4 = sess4Enabled and not na(
     time(timeframe.period, session4, "America/New_York")
     )

validSession =
     inSession1 or
     inSession2 or
     inSession3 or
     inSession4


// ─────────────────────────────────────────────────────────────
// EMAs
// ─────────────────────────────────────────────────────────────

// ACTIVE entry EMAs
ema8  = ta.ema(close, 8)
ema13 = ta.ema(close, 13)

// DISPLAY / CONTEXT ONLY
// This EMA does NOT affect BUY or SELL signals.
trendEMA = ta.ema(close, 21)


// ─────────────────────────────────────────────────────────────
// VWAP
// ─────────────────────────────────────────────────────────────

// VWAP IS an active entry filter.
//
// BUY  = price must close ABOVE VWAP
// SELL = price must close BELOW VWAP

vwapLine = ta.vwap(hlc3)


// ─────────────────────────────────────────────────────────────
// HEIKIN ASHI — MANUAL CALCULATION
// ─────────────────────────────────────────────────────────────

var float prevHaOpen  = na
var float prevHaClose = na

haClose = (open + high + low + close) / 4.0

haOpen = na(prevHaOpen) ?
     (open + close) / 2.0 :
     (prevHaOpen + prevHaClose) / 2.0

haHigh = math.max(
     high,
     math.max(haOpen, haClose)
     )

haLow = math.min(
     low,
     math.min(haOpen, haClose)
     )

prevHaOpen  := haOpen
prevHaClose := haClose

haBull = haClose > haOpen
haBear = haClose < haOpen


// Strong HA candle:
//
// Bull = no meaningful LOWER wick
// Bear = no meaningful UPPER wick

strongBull =
     haBull and
     (haOpen - haLow) <= syminfo.mintick

strongBear =
     haBear and
     (haHigh - haOpen) <= syminfo.mintick


// ─────────────────────────────────────────────────────────────
// TREND
// ─────────────────────────────────────────────────────────────

// Used specifically for pullback entry model.

ema8Slope  = ema8 - ema8[3]
ema13Slope = ema13 - ema13[3]

bullTrend =
     ema8 > ema13 and
     ema8Slope > 0 and
     ema13Slope > 0

bearTrend =
     ema8 < ema13 and
     ema8Slope < 0 and
     ema13Slope < 0

// Minimum 5-point separation between 8/13
// for the pullback entry model.

emaFanning = math.abs(ema8 - ema13) >= 5.0


// ============================================================
// ENTRY MODEL 1 — BREAKOUT / MOMENTUM
// ============================================================

breakoutBuy =
     strongBull and
     close > ema8 and
     ema8 > ema13

breakdownSell =
     strongBear and
     close < ema8 and
     ema8 < ema13


// ============================================================
// ENTRY MODEL 2 — PULLBACK
// ============================================================

// Previous HA candle must be opposite color.

bullishPullback = haBear[1]
bearishPullback = haBull[1]

pullbackBuy =
     bullTrend and
     emaFanning and
     bullishPullback and
     strongBull and
     close > ema8

pullbackSell =
     bearTrend and
     emaFanning and
     bearishPullback and
     strongBear and
     close < ema8


// ============================================================
// ENTRY MODEL 3 — 8/13 EMA CROSS
// ============================================================

emaCrossUp =
     ema8 > ema13 and
     ema8[1] <= ema13[1]

emaCrossDown =
     ema8 < ema13 and
     ema8[1] >= ema13[1]

crossBuy =
     emaCrossUp and
     strongBull

crossSell =
     emaCrossDown and
     strongBear


// ─────────────────────────────────────────────────────────────
// KILL ZONE
// ─────────────────────────────────────────────────────────────

nyHour =
     hour(time, "America/New_York")

nyMinute =
     minute(time, "America/New_York")

isWeekday =
     dayofweek >= dayofweek.monday and
     dayofweek <= dayofweek.friday

inKillZone =
     isWeekday and
     (
         nyHour > TIME_EXIT_HOUR or
         (
             nyHour == TIME_EXIT_HOUR and
             nyMinute >= TIME_EXIT_MINUTE
         )
     ) and
     nyHour < GLOBEX_HOUR


// ============================================================
// RAW ENTRY SIGNALS
// ============================================================

rawBuy =
     breakoutBuy or
     pullbackBuy or
     crossBuy

rawSell =
     breakdownSell or
     pullbackSell or
     crossSell


// ============================================================
// ENTRY FILTERS
// ============================================================
//
// IMPORTANT:
//
// 21 EMA IS NOT USED HERE.
//
// LONG:
//     8 > 13
//     price > 8
//     price > VWAP
//
// SHORT:
//     8 < 13
//     price < 8
//     price < VWAP
//
// ============================================================

emaStackBull =
     ema8 > ema13

emaStackBear =
     ema8 < ema13

priceAboveAll =
     close > ema8 and
     emaStackBull and
     close > vwapLine

priceBelowAll =
     close < ema8 and
     emaStackBear and
     close < vwapLine


// ============================================================
// 3 FULL-BAR SIGNAL COOLDOWN
// ============================================================
//
// Example:
//
// Signal = Bar 0
// Wait   = Bar 1
// Wait   = Bar 2
// Wait   = Bar 3
// Next signal allowed = Bar 4
//
// ============================================================

var int lastSignalBar = na

cooldownBars = 3

cooldownOK =
     na(lastSignalBar) or
     (bar_index - lastSignalBar > cooldownBars)


// ============================================================
// FINAL BUY / SELL SIGNALS
// ============================================================

buySignal =
     rawBuy and
     cooldownOK and
     not inKillZone and
     priceAboveAll and
     (not useTimeFilter or validSession)

sellSignal =
     rawSell and
     cooldownOK and
     not inKillZone and
     priceBelowAll and
     (not useTimeFilter or validSession)


// Reset cooldown after EITHER direction signals.

if buySignal or sellSignal
    lastSignalBar := bar_index


// ─────────────────────────────────────────────────────────────
// SESSION BACKGROUNDS
// ─────────────────────────────────────────────────────────────

bgcolor(
     sess1Enabled and inSession1 ?
     sess1BgColor :
     na,
     title="Session 1 Background"
     )

bgcolor(
     sess2Enabled and inSession2 ?
     sess2BgColor :
     na,
     title="Session 2 Background"
     )

bgcolor(
     sess3Enabled and inSession3 ?
     sess3BgColor :
     na,
     title="Session 3 Background"
     )

bgcolor(
     sess4Enabled and inSession4 ?
     sess4BgColor :
     na,
     title="Session 4 Background"
     )


// ─────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────

p_ema8 = plot(
     showEMAs ? ema8 : na,
     "8 EMA",
     color=color.purple,
     linewidth=2
     )

plot(
     showEMAs ? ema13 : na,
     "13 EMA",
     color=color.aqua,
     linewidth=2
     )

p_trendEMA = plot(
     showEMAs ? trendEMA : na,
     "Trend EMA (21) — Display Only",
     color=color.yellow,
     linewidth=2
     )

plot(
     showEMAs ? vwapLine : na,
     "VWAP",
     color=color.new(#ff66c4, 0),
     linewidth=2
     )


// ─────────────────────────────────────────────────────────────
// 8/21 TREND CLOUD — DISPLAY ONLY
// ─────────────────────────────────────────────────────────────
//
// Cloud is visual context.
// Cloud color DOES NOT affect signal generation.

cloudColor =
     ema8 > trendEMA ?
     color.new(color.green, 95) :
     color.new(color.red, 95)

fill(
     p_ema8,
     p_trendEMA,
     color=showEMAs ? cloudColor : na,
     title="Trend Cloud (8/21) — Display Only"
     )


// ─────────────────────────────────────────────────────────────
// SIGNALS
// ─────────────────────────────────────────────────────────────

showBuy =
     showSignals and
     buySignal

showSell =
     showSignals and
     sellSignal

plotshape(
     showBuy,
     title="BUY",
     style=shape.triangleup,
     color=color.rgb(214, 136, 255),
     location=location.belowbar,
     size=size.tiny
     )

plotshape(
     showSell,
     title="SELL",
     style=shape.triangledown,
     color=color.gray,
     location=location.abovebar,
     size=size.tiny
     )


// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────

alertcondition(
     buySignal,
     title="TRADERXMOM Buy Signal",
     message="TRADERXMOM Indicator BUY"
     )

alertcondition(
     sellSignal,
     title="TRADERXMOM Sell Signal",
     message="TRADERXMOM Indicator SELL"
     )

alertcondition(
     buySignal or sellSignal,
     title="TRADERXMOM Any Signal",
     message="TRADERXMOM Indicator SIGNAL"
     )
````
