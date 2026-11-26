# Precision VWAP Chase

- url: https://www.tradingview.com/script/39a054iE-Precision-VWAP-Chase/
- type: indicator
- pine_id: PUB;7708736a746d4c148c2eb246fdab5a83
- version: 2.0

## Description

WHAT VWAPCHASE IS

VWAPChase measures how far price is from session VWAP, in units of recent volatility. The reading is live price minus session VWAP, divided by a fixed 5-minute Wilder ATR(7). A reading of +2.5 means price is 2.5 times the current 5-minute ATR above VWAP. A reading of -1.0 means price is 1.0 times that ATR below it.

VWAP is the volume-weighted average traded price for the session. Distance from VWAP provides a simple reference for how far price has moved from that session average. When I'm looking at a runner, one question I keep asking is how far above VWAP I would be paying to participate. VWAPChase puts a number and color on that distance.

It measures displacement. It does not judge the trade. It does not know whether a stretched move is ending or just starting, and it never tells anyone to enter or exit.

WHAT MAKES IT DIFFERENT

The ruler is fixed. The ATR is always taken from 5-minute bars with a length of 7, whatever the chart timeframe. A 15-second chart, a 1-minute chart and a 15-minute chart give the same reading for the same price and VWAP. Switching timeframes changes the view, not the measurement.

The reading is live. It updates with live price and session VWAP while using 5-minute ATR as its fixed volatility reference. On a fast move, the reading climbs as the move happens instead of waiting for a bar to close.

The scale is symmetric. The same limits apply above and below VWAP, so a stretched move up and a stretched move down are measured the same way.

THE STATES

The label is colored by state using its displayed one-decimal reading. Each limit applies to both sides of VWAP.

Parabolic, +4.0 and above: magenta
Extended, +2.0 to +3.9: yellow
Moderate, +0.6 to +1.9: green
Near VWAP, -0.5 to +0.5: gray
Below VWAP, -0.6 to -1.9: orange
Extended Below, -2.0 to -3.9: red
Parabolic Below, -4.0 and below: magenta

The state is decided from the same one-decimal number the label shows, so a displayed +4.0 is always magenta and a displayed +2.0 is always yellow.

The colors describe distance from VWAP, not trend health. Green is not a buy signal and yellow is not a warning to stay out. A fresh breakout can print yellow because it is happening well above VWAP. A failing move can read green because the distance that remains is moderate. Read the state together with whatever you use for structure.

snapshot

THE LABEL

A text label sits at the right end of the VWAP line and shows VWAP and the current reading, for example VWAP 3.23 +1.7 ATR. Very large values, such as market capitalization charts, are abbreviated to T, B or M so the label stays readable.

Label Position can be set to On, Above or Below. Above and Below lift the text off the VWAP line so it does not collide with other indicators' lines. The label stays anchored to VWAP either way.

The label also explains when no reading is possible: on daily and higher charts, on symbols without volume data, and while the 5-minute ATR is still building at the start of the chart.

THRESHOLD LINES

Optional lines show where the label changes state. Upper Thresholds draws +2 (yellow) and +4 (magenta). Lower Thresholds draws -2 (red) and -4 (magenta). Both are off by default.

The lines use the same fixed 5-minute ATR as the reading and move with session VWAP. When volatility expands, you can watch them widen away from VWAP. When the session quiets down, they pull back in. That makes the normalization visible in a way the number alone cannot.

Thresholds are moving volatility boundaries, not support or resistance. Price can cross them freely; their purpose is to show where the extension state changes.

I prefer the threshold lines off, as illustrated in the image below.

https://www.tradingview.com/x/xWMX8OCG/

Upper and lower threshold lines can be turned on separately. The following image shows the lower threshold lines on and the upper lines off.

https://www.tradingview.com/x/JYPlZI26/

SETTINGS

Tiers: Near VWAP, Extended and Parabolic limits, in ATR units. Each applies to both sides of VWAP. Defaults are 0.5, 2.0 and 4.0.

VWAP: show or hide the line, its color and width.

Thresholds: show the upper and lower threshold lines and their width.

Label: show or hide the label, its offset from the last bar, its position, its size, and the color of each state.

The ATR timeframe and length are not settings. The 5-minute ATR(7) is fixed so the reading means the same thing on every chart.

The reading is also in the Data Window and can be used as a Pine Screener column.

HOW TO READ IT

Watch how the reading changes, not only where it sits. A reading can reach magenta during a forming bar and fall back to yellow before the close. It can also remain magenta into the close. Because the reading is live, both behaviors remain visible instead of being reduced to a close-only value.

Gray means price is near VWAP. Repeated crossings around VWAP show that price is staying close to the session average.

Use it alongside a structure tool. Structure tells you what the move is doing. VWAPChase tells you how far from VWAP you are paying to take part in it.

DATA REQUIREMENTS

VWAP requires volume. Symbols that carry no volume, including many index and blended price symbols, show a no volume data message instead of a reading. Choose an exchange symbol that reports volume.

CFD and broker feeds may report tick volume rather than traded volume. VWAP still works on them but is weighted by activity rather than true volume. For crypto, use an exchange feed that reports volume.

Use extended hours on stocks so premarket trading counts in VWAP. A 24-hour session starts VWAP at the overnight open instead, which can shift the reading slightly.

LIMITATIONS

VWAPChase runs on intraday timeframes only.

Right before a breakout, quiet bars keep the 5-minute ATR small, so early readings on a new move run high. Right after a blow-off, the large bars swell the ATR, so readings for some time afterward run low. The threshold lines show both effects as they happen.

Session VWAP gets heavier as the day goes on. Late in a strong trend, the distance can keep growing partly because VWAP moves slowly, not only because price is stretching.

On lower timeframes, the threshold lines can step as the 5-minute ATR updates.

Readings on the forming bar can change before the bar closes.

VWAPChase has no alerts. It is a gauge, not an event detector. Alerts can be added in a future update if users find them useful.

VWAPChase does not predict future prices, does not manage risk and does not guarantee any outcome.

DISCLAIMER

VWAPChase's readings, colors, lines and label are analytical measurements derived from the rules described above, not recommendations to buy or sell. Trading decisions and risk management remain the user's responsibility.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MohaveTrader
// Precision VWAP Chase [MohaveTrader] (VWAPChase)
// Version History
// v1.1 — October 2026
// • Fixed extreme readings when trading becomes unusually quiet: the 5-minute ATR could shrink so far that a small move away from VWAP read Extended or Parabolic
// • Added a collapse floor: the ruler cannot drop below Collapse Threshold x the symbol's normal 5-minute ATR, measured on regular-session bars only over roughly the most recent five sessions
// • Active trading is unchanged: when live 5-minute ATR is above the collapse floor, the reading is the same as v1.0
// • New inputs: Collapse Threshold (0.35) and Normal ATR Length (390 regular-session 5-minute bars); Collapse Threshold 0 restores the v1.0 ruler
//
// v1.0 — October 2026
// • Initial release
//
// Measures live price displacement from session VWAP in units of fixed 5-minute Wilder ATR(7), with a collapse floor so the ruler cannot shrink far below the symbol's normal 5-minute volatility. Positive readings are above VWAP; negative readings are below. Colors identify near-VWAP, moderate, extended and parabolic displacement on either side.
// Above VWAP: green = moderate, yellow = extended, magenta = parabolic. Below VWAP: orange = below, red = extended below, magenta = parabolic below. Gray = near VWAP.
//
// HOW TO USE
// Use on intraday charts with extended hours on so premarket counts in VWAP.
// The reading updates live with price on any intraday chart. The ATR updates every 5 minutes.
// Uses a fixed 5-minute Wilder ATR(7) as the volatility ruler, so the extension reading remains consistent when switching chart timeframes.
// Collapse floor: normal 5-minute ATR is measured on the symbol's regular-session bars only. If live ATR falls below Collapse Threshold x normal ATR, the ruler is held at that level instead. Premarket and after-hours bars never enter the normal reference. On symbols with less than about five regular sessions of history, the collapse floor stays off until enough data is available.
// VWAPChase measures displacement, not the speed of a move or the quality of a trade. A stock that drifts far from VWAP after a large run can still read strongly.
// Adjust the Near VWAP, Extended and Parabolic limits to taste. Each limit applies to both sides of VWAP.
// Optional upper (+Extended, +Parabolic) and lower (-Extended, -Parabolic) threshold lines show where the label changes state. They use the same ruler as the live reading and move with session VWAP. Thresholds are moving volatility boundaries, not support or resistance.
// Set Label Position to Above or Below to move the text off other indicators' lines. The label stays anchored to VWAP.
// The value is also in the Data Window and can be used as a Pine Screener column.
//@version=6
indicator("Precision VWAP Chase", "VWAPChase", overlay = true, max_labels_count = 5)

nearLim = input.float(0.5, "Near VWAP Limit (ATR)", minval = 0, step = 0.1, group = "Tiers")
extLim = input.float(2.0, "Extended Limit (ATR)", minval = 0, step = 0.1, group = "Tiers")
paraLim = input.float(4.0, "Parabolic Limit (ATR)", minval = 0, step = 0.1, group = "Tiers")

collapseFrac = input.float(0.35, "Collapse Threshold", minval = 0, step = 0.05, group = "Collapse Floor", tooltip = "Collapse floor = this x normal 5m ATR. 0 restores the v1.0 ruler.")
normLen = input.int(390, "Normal ATR Length (bars)", minval = 1, group = "Collapse Floor", tooltip = "Regular-session 5m bars in the normal ATR.")

showVwap = input.bool(true, "Show VWAP", group = "VWAP")
vwapCol = input.color(color.white, "VWAP Color", group = "VWAP")
vwapW = input.int(2, "VWAP Width", minval = 1, maxval = 5, group = "VWAP")

showUpTh = input.bool(false, "Show Upper Thresholds", group = "Thresholds")
showDnTh = input.bool(false, "Show Lower Thresholds", group = "Thresholds")
thW = input.int(1, "Threshold Width", minval = 1, maxval = 5, group = "Thresholds")

showLbl = input.bool(true, "Show Label", group = "Label")
lblOff = input.int(3, "Label Offset (bars)", minval = 0, group = "Label")
lblPos = input.string("On", "Label Position", options = ["On", "Above", "Below"], group = "Label")
lblSize = input.string(size.normal, "Label Size", options = [size.tiny, size.small, size.normal, size.large, size.huge], group = "Label")
colNear = input.color(#B0BEC5, "At VWAP", group = "Label")
colGood = input.color(#39FF14, "Moderate", group = "Label")
colExt = input.color(#FFFF33, "Extended", group = "Label")
colPara = input.color(#FF2EFF, "Parabolic", group = "Label")
colBelow = input.color(#FF9F1C, "Below VWAP", group = "Label")
colExtDn = input.color(#FF3131, "Extended Below", group = "Label")

chartSec = timeframe.in_seconds()
chartAtr = ta.atr(7)
vw = ta.vwap(hlc3)
tkReg = ticker.modify(syminfo.tickerid, session.regular)

var float atr5 = na
var float normAtr = na
if timeframe.isintraday
    if chartSec < 300
        atr5 := request.security(syminfo.tickerid, "5", ta.atr(7))
        normAtr := request.security(tkReg, "5", ta.atr(normLen))
    else if chartSec > 300
        ltfAtr = request.security_lower_tf(syminfo.tickerid, "5", ta.atr(7), ignore_invalid_timeframe = true)
        if array.size(ltfAtr) > 0
            atr5 := array.last(ltfAtr)
        ltfNorm = request.security_lower_tf(tkReg, "5", ta.atr(normLen), ignore_invalid_timeframe = true)
        if array.size(ltfNorm) > 0
            normAtr := array.last(ltfNorm)
    else
        atr5 := chartAtr
        normAtr := request.security(tkReg, "5", ta.atr(normLen))

ok = timeframe.isintraday and atr5 > 0
ruler = ok ? math.max(atr5, collapseFrac * nz(normAtr)) : na
dist = ok ? (close - vw) / ruler : na
r = math.round(dist, 1)
col = na(r) ? color.silver : r >= paraLim ? colPara : r >= extLim ? colExt : r > nearLim ? colGood : r >= -nearLim ? colNear : r > -extLim ? colBelow : r > -paraLim ? colExtDn : colPara

drawOk = timeframe.isintraday and not timeframe.change("D")
plot(showVwap and drawOk ? vw : na, "VWAP", vwapCol, vwapW, plot.style_linebr)
plot(showUpTh and drawOk and ok ? vw + extLim * ruler : na, "Upper Extended Threshold", colExt, thW, plot.style_linebr)
plot(showUpTh and drawOk and ok ? vw + paraLim * ruler : na, "Upper Parabolic Threshold", colPara, thW, plot.style_linebr)
plot(showDnTh and drawOk and ok ? vw - extLim * ruler : na, "Lower Extended Threshold", colExtDn, thW, plot.style_linebr)
plot(showDnTh and drawOk and ok ? vw - paraLim * ruler : na, "Lower Parabolic Threshold", colPara, thW, plot.style_linebr)
plot(dist, "VWAP Chase (ATR)", display = display.data_window)

f_px(v) =>
    a = math.abs(v)
    a >= 1e12 ? str.tostring(v / 1e12, "0.###") + "T" : a >= 1e9 ? str.tostring(v / 1e9, "0.###") + "B" : a >= 1e6 ? str.tostring(v / 1e6, "0.###") + "M" : str.tostring(v, format.mintick)

lblStyle = lblPos == "Above" ? label.style_label_lower_left : lblPos == "Below" ? label.style_label_upper_left : label.style_label_left

var label lb = na
if barstate.islast
    label.delete(lb)
    lb := na
    if showLbl
        if not timeframe.isintraday
            lb := label.new(bar_index + lblOff, close, "VWAPChase: intraday charts only", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.silver, size = lblSize)
        else if na(vw)
            lb := label.new(bar_index + lblOff, close, "VWAPChase: no volume data for VWAP", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.silver, size = lblSize)
        else if not ok
            lb := label.new(bar_index + lblOff, vw, "VWAP " + f_px(vw) + "  waiting for 5m ATR", style = lblStyle, color = color.new(color.black, 100), textcolor = color.silver, size = lblSize)
        else
            txt = "VWAP " + f_px(vw) + "  " + (r >= 0 ? "+" : "") + str.tostring(r, "0.0") + " ATR"
            lb := label.new(bar_index + lblOff, vw, txt, style = lblStyle, color = color.new(color.black, 100), textcolor = col, size = lblSize)
````
