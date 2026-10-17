# Trend Pullback Re-Entry Strategy [Jayadev Rana]

- url: https://www.tradingview.com/script/G6KZH6HX-Trend-Pullback-Re-Entry-Strategy-Jayadev-Rana/
- type: strategy
- pine_id: PUB;483afd9089f04718b800265b55bb5018
- version: 1.0

## Description

OVERVIEW

Trend Pullback Re-Entry Strategy is a trend-following strategy that does not buy strength. It waits for an established trend, waits for a counter-trend dip inside it, and enters only when price shows that the dip is over. The aim is to join a trend at a better price than a breakout entry would give, with a stop that sits just beyond the pullback itself.

HOW IT WORKS

The logic has three stages that must occur in order.

1. Trend regime. An uptrend requires the fast EMA above the slow EMA and the slow EMA higher than it was a set number of bars ago. A downtrend is the mirror image. When neither is true the strategy does nothing.

2. Pullback. A short-length RSI measures the depth of the counter-trend move. In an uptrend the RSI must fall to the Pullback Depth level or lower; in a downtrend it must rise to 100 minus that level or higher. This registers a pullback and starts a short countdown.

3. Trigger. Within the Trigger Window, a bar must close above the previous bar's high (uptrend) or below the previous bar's low (downtrend). This is the evidence that the pullback has ended. If the trigger does not arrive within the window, the setup expires.

Orders are placed on the close of the trigger bar and fill on the next bar open.

EXITS

- Initial stop: beyond the lowest low (for longs) or highest high (for shorts) of the pullback window, plus an ATR buffer.
- Trailing stop: once in a trade, the stop trails each new close by an ATR multiple and never moves against the trade. There is no fixed profit target; the trade stays open until the stop is reached.

POSITION SIZING

Quantity is set so that a stop-out at the initial stop loses the chosen percentage of current equity. Because the initial stop is tied to the pullback extreme, shallow pullbacks produce larger positions and deep pullbacks smaller ones, with the same amount at risk. Position notional is capped by the Maximum Leverage input.

STRATEGY PROPERTIES USED

Initial capital 10,000. Commission 0.05 percent per order. Slippage 2 ticks. No pyramiding. Margin 100 percent on both sides, maximum leverage 1. Risk per trade 0.5 percent of equity. Signals are evaluated on closed bars; calculations do not use intrabar data or higher-timeframe requests.

DEFAULT SETTINGS

The default values were chosen with a parameter search on BTCUSDT on the 1-hour timeframe using the properties above. The history was split into an earlier and a later segment and only settings that were acceptable in both segments were considered. Other symbols and timeframes will usually need different values. A parameter search always carries a risk of fitting to the tested history, so results on the tested market are likely to look better than results on new data.

DASHBOARD

Current regime, whether a pullback is armed and waiting for its trigger, and the pullback RSI value.

LIMITATIONS

- The strategy depends on the trend continuing after the pullback. When a pullback is the start of a reversal, the trade is stopped out; this is the normal losing trade for this approach.
- The EMA regime filter reacts slowly. After a trend ends, the filter can stay in the old regime for some time and allow entries in the wrong direction.
- Very strong trends may never pull back deep enough to register, so the strategy can miss the cleanest moves entirely.
- Backtests assume fills at the next bar open with fixed slippage. Real fills, funding costs on leveraged instruments, and gaps are not modeled.
- Settings tuned on past data can stop working when market behavior changes.

This script is for analysis and education. It does not provide financial advice, and past performance does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) Jayadev Rana
//@version=6
strategy("Trend Pullback Re-Entry Strategy [Jayadev Rana]", shorttitle = "TPRE", overlay = true, initial_capital = 10000, default_qty_type = strategy.fixed, default_qty_value = 1, commission_type = strategy.commission.percent, commission_value = 0.05, slippage = 2, pyramiding = 0, margin_long = 100, margin_short = 100)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
string GRP_TREND = "Trend Regime"
string GRP_PB    = "Pullback and Trigger"
string GRP_RISK  = "Risk"
string GRP_DASH  = "Dashboard"
string GRP_STYLE = "Style"

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
int fastLen  = input.int(55, "Fast EMA", minval = 2, maxval = 200, group = GRP_TREND)
int slowLen  = input.int(233, "Slow EMA", minval = 5, maxval = 600, group = GRP_TREND)
int slopeLen = input.int(10, "Slope Lookback", minval = 1, maxval = 100, group = GRP_TREND, tooltip = "An uptrend needs the fast EMA above the slow EMA and the slow EMA higher than it was this many bars ago (mirrored for a downtrend).")

int   pbLen      = input.int(5, "Pullback RSI Length", minval = 2, maxval = 20, group = GRP_PB, tooltip = "A short RSI measures the depth of the counter-trend dip.")
float pbLevel    = input.float(25.0, "Pullback Depth", minval = 1.0, maxval = 49.0, step = 1.0, group = GRP_PB, tooltip = "In an uptrend the short RSI must fall to this level or lower to register a pullback. Downtrends use 100 minus this level.")
int   pbWindow   = input.int(3, "Trigger Window (Bars)", minval = 1, maxval = 30, group = GRP_PB, tooltip = "After a pullback registers, the trigger must arrive within this many bars: a close beyond the previous bar's high in an uptrend, or below its low in a downtrend.")
bool  allowLong  = input.bool(true, "Allow Longs", group = GRP_PB)
bool  allowShort = input.bool(true, "Allow Shorts", group = GRP_PB)

float riskPct   = input.float(0.5, "Risk per Trade (% Equity)", minval = 0.05, maxval = 5.0, step = 0.05, group = GRP_RISK, tooltip = "Position size is set so that a stop-out at the initial stop loses this share of current equity, before commission and slippage.")
float maxLev    = input.float(1.0, "Maximum Leverage", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_RISK, tooltip = "Position notional is capped at equity times this value, whatever the risk calculation asks for.")
float stopBuf   = input.float(0.5, "Stop Buffer (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_RISK, tooltip = "The initial stop sits this far beyond the extreme of the pullback.")
float trailMult = input.float(5.0, "Trailing Stop (ATR)", minval = 0.5, maxval = 10.0, step = 0.25, group = GRP_RISK, tooltip = "Once in a trade the stop trails each new close by this distance and never moves against the trade.")

bool   showDash = input.bool(true, "Show Dashboard", group = GRP_DASH)
string dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = GRP_DASH)

color upCol   = input.color(#26a69a, "Long", group = GRP_STYLE)
color dnCol   = input.color(#ef5350, "Short", group = GRP_STYLE)
color neutCol = input.color(#787b86, "Neutral", group = GRP_STYLE)

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------
float emaF = ta.ema(close, fastLen)
float emaS = ta.ema(close, slowLen)
float rsiP = ta.rsi(close, pbLen)
float atr  = ta.atr(14)
float unit = math.max(nz(atr, high - low), syminfo.mintick)

bool upTrend = emaF > emaS and emaS > emaS[slopeLen]
bool dnTrend = emaF < emaS and emaS < emaS[slopeLen]

int   sinceDip  = nz(ta.barssince(rsiP <= pbLevel), 100000)
int   sincePop  = nz(ta.barssince(rsiP >= 100 - pbLevel), 100000)
float dipLow    = ta.lowest(low, pbWindow + 1)
float popHigh   = ta.highest(high, pbWindow + 1)

//------------------------------------------------------------------------------
// Signals (closed bars only)
//------------------------------------------------------------------------------
bool warm     = bar_index > slowLen + slopeLen
bool flat     = strategy.position_size == 0
bool longSig  = warm and barstate.isconfirmed and flat and allowLong and upTrend and sinceDip <= pbWindow and close > high[1]
bool shortSig = warm and barstate.isconfirmed and flat and allowShort and dnTrend and sincePop <= pbWindow and close < low[1]

//------------------------------------------------------------------------------
// Sizing
//------------------------------------------------------------------------------
f_qty(float stopDist) =>
    float riskCash = strategy.equity * riskPct / 100
    float q   = stopDist > 0 ? riskCash / (stopDist * syminfo.pointvalue) : 0.0
    float cap = strategy.equity * maxLev / (close * syminfo.pointvalue)
    math.max(math.min(q, cap), 0.0)

//------------------------------------------------------------------------------
// Orders and trailing stop
//------------------------------------------------------------------------------
var float trail = na

if longSig
    float stop = dipLow - stopBuf * unit
    float q    = f_qty(close - stop)
    if q > 0
        trail := stop
        strategy.entry("Long", strategy.long, qty = q)
        strategy.exit("Long Stop", "Long", stop = trail)
        alert("Trend Pullback: long entry signal on " + syminfo.ticker, alert.freq_once_per_bar_close)
else if shortSig
    float stop = popHigh + stopBuf * unit
    float q    = f_qty(stop - close)
    if q > 0
        trail := stop
        strategy.entry("Short", strategy.short, qty = q)
        strategy.exit("Short Stop", "Short", stop = trail)
        alert("Trend Pullback: short entry signal on " + syminfo.ticker, alert.freq_once_per_bar_close)
else if strategy.position_size > 0
    trail := math.max(nz(trail, close - trailMult * unit), close - trailMult * unit)
    strategy.exit("Long Stop", "Long", stop = trail)
else if strategy.position_size < 0
    trail := math.min(nz(trail, close + trailMult * unit), close + trailMult * unit)
    strategy.exit("Short Stop", "Short", stop = trail)
else
    trail := na

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
color regCol = upTrend ? upCol : dnTrend ? dnCol : neutCol
plot(emaF, "Fast EMA", color = color.new(regCol, 30))
plot(emaS, "Slow EMA", color = color.new(regCol, 0), linewidth = 2)
plot(strategy.position_size != 0 ? trail : na, "Stop", color = strategy.position_size > 0 ? upCol : dnCol, style = plot.style_linebr)
plot(rsiP, "Pullback RSI", display = display.data_window)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
f_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        => position.bottom_left

var table dash = table.new(f_pos(dashPos), 2, 3, bgcolor = color.new(#131722, 15), border_color = color.new(neutCol, 70), border_width = 1)

f_row(int r, string k, string v, color c) =>
    table.cell(dash, 0, r, k, text_color = color.new(color.white, 30), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right)

if showDash and (barstate.islastconfirmedhistory or barstate.isrealtime)
    bool armedL = upTrend and sinceDip <= pbWindow
    bool armedS = dnTrend and sincePop <= pbWindow
    f_row(0, "Regime", upTrend ? "Uptrend" : dnTrend ? "Downtrend" : "No trend", regCol)
    f_row(1, "Pullback", armedL ? "Dip armed" : armedS ? "Pop armed" : "None", armedL or armedS ? color.orange : color.white)
    f_row(2, "Pullback RSI", str.tostring(rsiP, "#"), color.white)
````
