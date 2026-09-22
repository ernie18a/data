<!-- tradingview-pine-id: PUB;c5d40905fdf74ef9bcc8e91d9922a30f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP Delta

Source: https://www.tradingview.com/script/94mLUhIV-VWAP-Delta/

## Description

VWAP Delta is an oscillator that plots each bar's open, high, low and close as their distance from the volume-weighted average price, instead of showing price and VWAP side by side. It's built for anyone who wants to see how far, and how consistently, price is trading away from its volume-weighted average — for example to judge how stretched an intraday move already is, or how a recent push compares to the pace of previous ones — rather than only whether price sits above or below VWAP.

The delta of each bar is measured against an EMA baseline built from the delta close, and both can optionally be smoothed with a Hull moving average before that comparison. Because VWAP accumulates from the start of each session and depends on volume, it is an intraday tool and returns na on symbols or timeframes where volume data isn't available. The indicator can display this relationship as a filled area or as its own set of candles, with colors that adapt automatically to the current bias and, in candle style, to whether momentum is currently building or fading.

Calculation

VWAP Smoothing:   applies a Hull moving average to the delta series before plotting, with an adjustable length.
Baseline Length:  EMA length of the baseline that the delta is compared against.

Appearance

Graphic Style:          visual style for the delta series: Area or Candle.
Bull / Bear Area Color: (Area style) fill color for when the delta line is above its baseline, and for when it's below.
Bull Candle Color:      (Candle style) two colors for a bullish candle body — the left one while the body is expanding versus the previous bar, the right one while it's contracting.
Bear Candle Color:      (Candle style) the same pair of colors for a bearish candle body.

https://www.tradingview.com/x/T1t365ha/

In Area style, the delta close is plotted as a single line against its EMA baseline, and the space between them is filled — in Bull Area Color while the delta line is above the baseline, in Bear Area Color while it's below. Only the fill is visible; the delta and baseline lines themselves stay hidden. In Candle style, the fill disappears and the delta is drawn instead as its own set of candles, built from the delta's open, high, low and close relative to VWAP; when smoothing is enabled, the high and low are clamped to the smoothed open and close, so the smoothing itself can never invert a candle's body. Each candle is colored by comparing its own delta open and close: a candle whose delta close sits above its delta open takes a bull color, any other candle — including one where open and close are exactly equal — takes a bear color; within each of those two colors, the shade further distinguishes whether the current body is larger than the previous one (expanding) or smaller (contracting). A zero line marks where price and VWAP coincide.

https://www.tradingview.com/x/l3dPSdGD/
https://www.tradingview.com/x/SSBgR6I5/

This indicator is intended solely for market analysis and does not constitute investment advice or a guarantee of success. Use it at your own discretion and risk; past results are not indicative of future performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © graefe
//@version=6
indicator(title = "VWAP Delta", overlay = false)

const string con_grpCalculation = "Calculation"
const string con_grpAppearance  = "Appearance"

const string con_smoothingTooltip = "Applies a Hull moving average to the delta series before plotting."
const string con_baselineTooltip  = "EMA length of the baseline that the area is filled against."
const string con_styleTooltip     = "Visual style for the delta series\n(Area or Candle)"
const string con_candleTooltip    = "Left: body expanding versus the previous bar.\nRight: body contracting."

bool   inp_showSmoothing   = input.bool(defval = false, title = "VWAP Smoothing", inline = "smoothing", group = con_grpCalculation, tooltip = con_smoothingTooltip)
int    inp_smoothingLength = input.int(defval = 21, title = "", minval = 1, maxval = 400, inline = "smoothing", group = con_grpCalculation, active = inp_showSmoothing)
int    inp_baselineLength  = input.int(defval = 50, title = "Baseline Length", minval = 1, maxval = 500, group = con_grpCalculation, tooltip = con_baselineTooltip)

string inp_style         = input.string(defval = "Area", title = "Graphic Style", options = ["Area", "Candle"], tooltip = con_styleTooltip, group = con_grpAppearance)
bool   cal_isAreaStyle   = inp_style == "Area"
bool   cal_isCandleStyle = inp_style == "Candle"

color inp_bullAreaColor         = input.color(defval = color.new(#006989, 70), title = "Bull Area Color", group = con_grpAppearance, active = cal_isAreaStyle)
color inp_bearAreaColor         = input.color(defval = color.new(#ff7b00, 70), title = "Bear Area Color", group = con_grpAppearance, active = cal_isAreaStyle)
color inp_bullExpandingColor    = input.color(defval = color.rgb(25, 123, 214),  title = "Bull Candle Color", inline = "bullCandle", group = con_grpAppearance, active = cal_isCandleStyle)
color inp_bullContractingColor  = input.color(defval = color.rgb(131, 168, 197), title = "", inline = "bullCandle", group = con_grpAppearance, active = cal_isCandleStyle, tooltip = con_candleTooltip)
color inp_bearExpandingColor    = input.color(defval = color.rgb(255, 102, 1),   title = "Bear Candle Color", inline = "bearCandle", group = con_grpAppearance, active = cal_isCandleStyle)
color inp_bearContractingColor  = input.color(defval = color.rgb(204, 164, 132), title = "", inline = "bearCandle", group = con_grpAppearance, active = cal_isCandleStyle, tooltip = con_candleTooltip)

// OHLC values are expressed as their delta relative to VWAP
float cal_vwap     = ta.vwap
float cal_rawClose = close - cal_vwap
float cal_rawOpen  = open  - cal_vwap
float cal_rawHigh  = high  - cal_vwap
float cal_rawLow   = low   - cal_vwap

// When smoothing is enabled, each delta series is independently smoothed with a Hull average
float cal_deltaClose   = inp_showSmoothing ? ta.hma(source = cal_rawClose, length = inp_smoothingLength) : cal_rawClose
float cal_deltaOpen    = inp_showSmoothing ? ta.hma(source = cal_rawOpen,  length = inp_smoothingLength) : cal_rawOpen
float cal_smoothedHigh = inp_showSmoothing ? ta.hma(source = cal_rawHigh,  length = inp_smoothingLength) : cal_rawHigh
float cal_smoothedLow  = inp_showSmoothing ? ta.hma(source = cal_rawLow,   length = inp_smoothingLength) : cal_rawLow

// High/low are clamped against open/close so the smoothing cannot produce broken candles
float cal_deltaHigh = math.max(cal_smoothedHigh, cal_deltaOpen, cal_deltaClose)
float cal_deltaLow  = math.min(cal_smoothedLow,  cal_deltaOpen, cal_deltaClose)

// Baseline is an EMA of the delta close line; the area is colored depending on the delta line's position relative to the baseline
float cal_baseline    = ta.ema(source = cal_deltaClose, length = inp_baselineLength)
color cal_fillColor   = cal_deltaClose > cal_baseline ? inp_bullAreaColor : inp_bearAreaColor

// Candle color additionally distinguishes a body that is expanding versus contracting compared to the previous bar
float cal_bodySize    = math.abs(cal_deltaClose - cal_deltaOpen)
bool  cal_isExpanding = cal_bodySize > cal_bodySize[1]
bool  cal_isBull      = cal_deltaClose > cal_deltaOpen

color cal_candleColor = cal_isBull ? (cal_isExpanding ? inp_bullExpandingColor : inp_bullContractingColor) : (cal_isExpanding ? inp_bearExpandingColor : inp_bearContractingColor)

outp_deltaLine = plot(series = cal_deltaClose, title = "Delta",    color = na, linewidth = 1, editable = false)
outp_baseline  = plot(series = cal_baseline,   title = "Baseline", color = na, linewidth = 1, editable = false)

fill(plot1 = outp_baseline, plot2 = outp_deltaLine, title = "Delta Fill", color = cal_isAreaStyle ? cal_fillColor : na, editable = false)

plotcandle(open = cal_deltaOpen, high = cal_deltaHigh, low = cal_deltaLow, close = cal_deltaClose, title = "Delta Candles", color = cal_isCandleStyle ? cal_candleColor : na, wickcolor = cal_isCandleStyle ? cal_candleColor : na, bordercolor = cal_isCandleStyle ? cal_candleColor : na, editable = false)

hline(price = 0, title = "Zero Line", color = color.new(chart.fg_color, 50), editable = false)
````
