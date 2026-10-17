# McGinley Dynamic + LWPI Confluence

- url: https://www.tradingview.com/script/4OQ8151o-McGinley-Dynamic-LWPI-Confluence/
- type: indicator
- pine_id: PUB;12036cbf260d48f689b6cda793cece50
- version: 1.0

## Description

WHAT IT DOES

This overlay combines two complementary reads of the market into a single confluence framework: the McGinley Dynamic, an adaptive trend line that speeds up when price runs and slows down in quiet conditions, and the Larry Williams Proxy Index (LWPI), a volatility-scaled balance-of-power oscillator. A signal prints only when both engines agree: trend direction from the McGinley Dynamic, momentum confirmation from the LWPI.

WHY COMBINE THEM

Every fixed-length moving average lags by a constant amount, which makes it too slow in fast markets and too jumpy in slow ones. The McGinley Dynamic addresses that by scaling its own smoothing factor with the ratio of price to its previous value — but, like any trend line, it says nothing about who is actually in control of the move. The LWPI measures exactly that: the average open-to-close pressure normalized by ATR. On its own, however, the LWPI whipsaws inside strong trends. Each component covers the other's blind spot, which is the reason for the mashup: the McGinley Dynamic decides direction, the LWPI decides timing.

HOW IT WORKS

1. Trend engine — McGinley Dynamic:
MD = MD[1] + (price - MD[1]) / max(k * N * (price / MD[1])^4, 1)
The fourth-power ratio term automatically widens the divisor when price stretches away from the line, reducing overshoot and whipsaw versus EMAs of comparable length. Price above the line = bullish regime (line plots green), below = bearish (red).

2. Momentum engine — LWPI:
LWPI = 50 * SMA(open - close, N) / ATR(N) + 50
Readings below 50 mean closes are dominating opens relative to volatility (buyers in control); above 50, sellers are in control. Optional smoothing (SMA/EMA/WMA/RMA) is available for noisy symbols.

3. Confluence logic:
- Long state: price above McGinley Dynamic AND LWPI below 50
- Short state: price below McGinley Dynamic AND LWPI above 50
A triangle prints on the first bar a state becomes active. The optional candle coloring shows the full extent of each state; the dashboard in the top-right corner summarizes trend, momentum and confluence at a glance.

4. ATR reference bands:
Dotted bands at +/- ATR * multiplier around price provide volatility context, e.g. for evaluating whether a stop distance is realistic for the symbol and timeframe. They are informational and not part of the signal logic.

HOW TO USE IT

Works on any market and timeframe; it was designed with trending instruments in mind (crypto, FX majors, index futures). A simple workflow: read the regime from the line color, wait for the LWPI to hand momentum back to the trend side, and use the confluence triangle as your alert to start analyzing — not as an automatic entry. The three built-in alerts (long confluence, short confluence, trend flip) let you monitor multiple symbols without watching charts.

SETTINGS

All defaults are textbook values, not curve-fitted: McGinley length 14 with the standard 0.6 constant from the original formula, LWPI period 8, ATR 14 with a 2.0 multiplier. Every input is documented with tooltips.

CREDITS

The McGinley Dynamic concept belongs to John R. McGinley, CMT. The Larry Williams Proxy Index concept was popularized on TradingView by loxx, whose open-source work this script's momentum component builds on, with thanks.

DISCLAIMER

This is an educational tool for market analysis. It is not financial advice and no performance is implied or promised. Always do your own research.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © SfericaTrading
//
// McGinley Dynamic + LWPI Confluence
// ----------------------------------
// Trend engine  : McGinley Dynamic (concept by John R. McGinley, CMT)
// Momentum      : Larry Williams Proxy Index (LWPI), concept popularized on
//                 TradingView by loxx — reimplemented and credited per House Rules
// Extras        : ATR reference bands, confluence signals, alerts, status dashboard

//@version=6
indicator("McGinley Dynamic + LWPI Confluence", shorttitle = "MD-LWPI", overlay = true)

// ———————————————————————————— Inputs ————————————————————————————

string GRP1 = "McGinley Dynamic (Trend)"
float srcMdInput  = input.source(close, "Source",     group = GRP1)
int   lenMdInput  = input.int(14,  "Length",          group = GRP1, minval = 1)
float kMdInput    = input.float(0.6, "K Constant",    group = GRP1, minval = 0.1, step = 0.1,
     tooltip = "Standard constant from John R. McGinley's original formula. Lower values make the line react faster.")

string GRP2 = "LWPI (Momentum)"
int    lenLwpiInput    = input.int(8, "Period",            group = GRP2, minval = 1)
bool   smoothLwpiInput = input.bool(false, "Smooth LWPI",  group = GRP2)
string typeLwpiInput   = input.string("SMA", "Smoothing Type", group = GRP2, options = ["SMA", "EMA", "WMA", "RMA"])
int    lenSmoothInput  = input.int(5, "Smoothing Period",  group = GRP2, minval = 1)

string GRP3 = "ATR Reference Bands"
bool  showBandsInput = input.bool(true, "Show ATR Bands",  group = GRP3)
int   lenAtrInput    = input.int(14, "ATR Period",         group = GRP3, minval = 1)
float multAtrInput   = input.float(2.0, "ATR Multiplier",  group = GRP3, minval = 0.1, step = 0.1)

string GRP4 = "Display"
bool showSignalsInput = input.bool(true,  "Show Confluence Signals",           group = GRP4)
bool colorBarsInput   = input.bool(false, "Color Candles by Confluence State", group = GRP4)
bool showTableInput   = input.bool(true,  "Show Status Dashboard",             group = GRP4)

// ———————————————————————————— Calculations ————————————————————————————

// McGinley Dynamic — adaptive moving average. The denominator scales with the
// ratio of price to the previous MD value, so the line speeds up when price
// pulls away and slows down in quiet markets. The math.max(…, 1.0) guard
// prevents division blow-ups on extreme moves.
var float md = na
md := na(md[1]) or md[1] == 0 ?
     srcMdInput :
     md[1] + (srcMdInput - md[1]) / math.max(kMdInput * lenMdInput * math.pow(srcMdInput / md[1], 4), 1.0)

// LWPI — volatility-scaled balance of power. Values BELOW 50 mean buyers are
// in control (closes above opens relative to ATR); values ABOVE 50 mean
// sellers are in control.
float atrLwpi = ta.atr(lenLwpiInput)
float bopLwpi = ta.sma(open - close, lenLwpiInput)
float lwpiRaw = atrLwpi == 0 ? 50.0 : 50.0 * bopLwpi / atrLwpi + 50.0

// Optional smoothing. All variants are computed unconditionally so series
// calculations stay consistent on every bar.
float lwpiSma = ta.sma(lwpiRaw, lenSmoothInput)
float lwpiEma = ta.ema(lwpiRaw, lenSmoothInput)
float lwpiWma = ta.wma(lwpiRaw, lenSmoothInput)
float lwpiRma = ta.rma(lwpiRaw, lenSmoothInput)
float lwpiSmoothed = switch typeLwpiInput
    "EMA" => lwpiEma
    "WMA" => lwpiWma
    "RMA" => lwpiRma
    => lwpiSma
float lwpi = smoothLwpiInput ? lwpiSmoothed : lwpiRaw

// ATR reference bands around price — volatility context for discretionary
// stop placement. Informational only.
float atrValue  = ta.atr(lenAtrInput)
float bandUpper = close + atrValue * multAtrInput
float bandLower = close - atrValue * multAtrInput

// Confluence logic — a state requires BOTH engines to agree; a signal prints
// only on the first bar a state becomes active.
bool bullTrend    = srcMdInput > md
bool bearTrend    = srcMdInput < md
bool bullMomentum = lwpi < 50
bool bearMomentum = lwpi > 50

bool longState   = bullTrend and bullMomentum
bool shortState  = bearTrend and bearMomentum
bool longSignal  = longState  and not longState[1]
bool shortSignal = shortState and not shortState[1]

// ———————————————————————————— Visuals ————————————————————————————

color colorBull = color.new(#089981, 0)
color colorBear = color.new(#F23645, 0)

plot(md, "McGinley Dynamic", color = bullTrend ? colorBull : colorBear, linewidth = 2)

plot(showBandsInput ? bandUpper : na, "ATR Upper Band", color = color.new(#F23645, 75), style = plot.style_circles)
plot(showBandsInput ? bandLower : na, "ATR Lower Band", color = color.new(#089981, 75), style = plot.style_circles)

plotshape(showSignalsInput and longSignal,  "Long Confluence",  shape.triangleup,   location.belowbar,
     colorBull, text = "Long",  textcolor = colorBull, size = size.small)
plotshape(showSignalsInput and shortSignal, "Short Confluence", shape.triangledown, location.abovebar,
     colorBear, text = "Short", textcolor = colorBear, size = size.small)

barcolor(colorBarsInput ? (longState ? colorBull : shortState ? colorBear : na) : na, title = "Confluence State")

// Status dashboard
var table dash = table.new(position.top_right, 2, 4, bgcolor = color.new(color.black, 75),
     border_width = 1, border_color = color.new(color.gray, 70))
if barstate.islast and showTableInput
    table.cell(dash, 0, 0, "MD-LWPI",          text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 0, "",                 text_size = size.small)
    table.cell(dash, 0, 1, "Trend (MD)",       text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 1, bullTrend ? "Bullish" : "Bearish",
         text_color = bullTrend ? colorBull : colorBear, text_size = size.small)
    table.cell(dash, 0, 2, "Momentum (LWPI)",  text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 2, bullMomentum ? "Bullish" : bearMomentum ? "Bearish" : "Neutral",
         text_color = bullMomentum ? colorBull : bearMomentum ? colorBear : color.gray, text_size = size.small)
    table.cell(dash, 0, 3, "Confluence",       text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 3, longState ? "LONG" : shortState ? "SHORT" : "None",
         text_color = longState ? colorBull : shortState ? colorBear : color.gray, text_size = size.small)

// ———————————————————————————— Alerts ————————————————————————————

alertcondition(longSignal,  "Long Confluence",  "MD-LWPI: Long confluence on {{ticker}} ({{interval}})")
alertcondition(shortSignal, "Short Confluence", "MD-LWPI: Short confluence on {{ticker}} ({{interval}})")
alertcondition(ta.cross(srcMdInput, md), "Trend Flip", "MD-LWPI: McGinley trend flip on {{ticker}} ({{interval}})")
````
