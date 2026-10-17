# Range BAR Scalper (100R/1000R)

- url: https://www.tradingview.com/script/msb7h9sa-Range-BAR-Scalper-100R-1000R/
- type: indicator
- pine_id: PUB;c06e3a4c7a7f4c34afd76f9ce72b9461
- version: 1.0

## Description

Range Scalper — Adaptive S/R Zones
A visualization tool built specifically for range charts (100R/1000R).
🔹 Adaptive S/R zones with automatic pivot detection
🔹 M / R / RSI signals with neon-style markers
🔹 Dashboard showing active levels and last break
🔹 Status panel: trend, bar run, RSI, and last signal (with bars-ago count)
The visual style of the signal markers is inspired by Dynamic RSI Regression Bands by Zeiierman, and the adaptive S/R zone concept draws from Adaptive S/R Zones by BigBeluga. Both originals are licensed under CC BY-NC-SA 4.0; this tool follows the same license and is for non-commercial use only.
⚠️ This is a visualization/educational tool, not financial advice. Signals are not a guarantee of results — test it yourself before any real use.Disclaimer
This indicator is provided for educational and informational purposes only. It is not financial, investment, or trading advice, and nothing in it constitutes a recommendation to buy, sell, or hold any instrument.
Trading and investing carry substantial risk of loss. Past performance — including any signals, levels, or visuals shown by this tool — does not guarantee future results. The signals are not predictions and may produce false or losing setups.
You are solely responsible for your own trading decisions. The author accepts no liability for any losses, damages, or other consequences arising from the use of this tool. Always do your own research and consider consulting a licensed financial professional before trading.
Licensed under CC BY-NC-SA 4.0 — non-commercial use only. Visual style adapted from work by Zeiierman and BigBeluga.

## Source Code

````pine
//@version=6
indicator("Range Scalper — Adaptive S/R Zones", "RangeScalp S/R", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=200)

// Built for RANGE charts (100R/1000R). Lengths are in BARS (price moves), not time.
// Visual style (zones, price labels, dashboard, age-based width) inspired by the
// adaptive S/R concept; implemented here with original code.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gSwing       = "Swing Detection"
pivotLen     = input.int(5, "Pivot Length", minval=2, maxval=50, group=gSwing)
maxAgeBars   = input.int(300, "Max Level Age (bars)", minval=20, maxval=2000, group=gSwing)
mergeThresh  = input.float(0.5, "Merge Threshold (ATR x)", minval=0.0, maxval=3.0, step=0.05, group=gSwing)

gLvl         = "Levels"
showSupport  = input.bool(true, "Show Support", group=gLvl)
showResist   = input.bool(true, "Show Resistance", group=gLvl)
maxLevels    = input.int(5, "Max Active Levels Each", minval=1, maxval=20, group=gLvl)
showZones    = input.bool(true, "Show Zones", group=gLvl)
zoneWidth    = input.float(0.25, "Zone Width (ATR x)", minval=0.05, maxval=2.0, step=0.05, group=gLvl)
showPriceLbl = input.bool(true, "Show Price Labels", group=gLvl)

gBreak       = "Breakouts"
breakSens    = input.float(0.1, "Break Sensitivity (ATR x)", minval=0.0, maxval=2.0, step=0.05, group=gBreak)
showBreakLbl = input.bool(true, "Show Break Labels", group=gBreak)

gVis         = "Visuals"
supColor     = input.color(color.new(#22bac5, 0), "Support Color", group=gVis)
resColor     = input.color(color.new(#ff6f43, 0), "Resistance Color", group=gVis)
brokenColor  = input.color(color.new(#94a3b8, 0), "Broken Color", group=gVis)
useDynWidth  = input.bool(true, "Age-Based Width (older = thicker)", group=gVis)
maxLineWidth = input.int(7, "Max Width", minval=1, maxval=10, group=gVis)
baseWidth    = input.int(2, "Base Width", minval=1, maxval=5, group=gVis)
showDash     = input.bool(true, "Show Dashboard", group=gVis)
dashPos      = input.string("Bottom Right", "Dashboard Position", options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=gVis)

gSig         = "M/R Signals"
showSignals  = input.bool(true, "Show Momentum/Reversal Arrows", group=gSig)
momBars      = input.int(3, "Bars for Momentum", minval=2, maxval=8, group=gSig)
fastLen      = input.int(8, "Fast EMA (bars)", minval=2, maxval=50, group=gSig)
slowLen      = input.int(21, "Slow EMA (bars)", minval=5, maxval=100, group=gSig)
exhaustBars  = input.int(5, "Bars for Exhaustion", minval=3, maxval=12, group=gSig)
rsiLen       = input.int(7, "RSI Length (bars)", minval=2, maxval=20, group=gSig)
rsiOB        = input.int(75, "RSI Overbought", minval=60, maxval=90, group=gSig)
rsiOS        = input.int(25, "RSI Oversold", minval=10, maxval=40, group=gSig)
useTrendFilter = input.bool(true, "Momentum only WITH EMA trend", group=gSig)
antiSpam     = input.bool(true, "Anti-Spam (1 per run)", group=gSig)
showRsiArrows = input.bool(true, "Show RSI Extreme Arrows", group=gSig, tooltip="Arrow when RSI exits overbought/oversold")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPES & STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type SRLevel
    float price
    int   barStart
    int   levelType   // 1 = resistance, -1 = support
    bool  active
    line  ln
    box   zone
    label priceLbl

var array<SRLevel> levels = array.new<SRLevel>()
var string lastBreakDir = "—"

atrVal  = ta.atr(14)
atrSafe = na(atrVal) or atrVal == 0 ? syminfo.mintick * 10 : atrVal

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tooClose(_price, _type) =>
    bool close_ = false
    sz = array.size(levels)
    if sz > 0
        for i = 0 to sz - 1
            l = array.get(levels, i)
            if l.levelType == _type and l.active and math.abs(l.price - _price) < mergeThresh * atrSafe
                close_ := true
                break
    close_

f_countActive(_type) =>
    int c = 0
    sz = array.size(levels)
    if sz > 0
        for i = 0 to sz - 1
            l = array.get(levels, i)
            if l.levelType == _type and l.active
                c += 1
    c

f_addLevel(_price, _type, _barIdx) =>
    if not f_tooClose(_price, _type) and f_countActive(_type) < maxLevels
        col = _type == 1 ? resColor : supColor
        ln = line.new(_barIdx, _price, _barIdx + 1, _price, extend=extend.right, color=col, width=baseWidth)
        zb = showZones ? box.new(_barIdx, _price + zoneWidth * atrSafe * 0.5, _barIdx + 1, _price - zoneWidth * atrSafe * 0.5, border_color=color.new(col, 90), bgcolor=color.new(col, 88), extend=extend.right) : na
        plb = showPriceLbl ? label.new(bar_index + 20, _price, str.tostring(_price, format.mintick), style=label.style_label_left, textcolor=col, color=color.new(chart.bg_color, 100), size=size.small) : na
        array.push(levels, SRLevel.new(_price, _barIdx, _type, true, ln, zb, plb))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRUNE OLD LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
psz = array.size(levels)
if psz > 0
    for i = psz - 1 to 0
        if i < array.size(levels)
            l = array.get(levels, i)
            if l.active and (bar_index - l.barStart) > maxAgeBars
                line.delete(l.ln)
                if not na(l.zone)
                    box.delete(l.zone)
                if not na(l.priceLbl)
                    label.delete(l.priceLbl)
                array.remove(levels, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADD NEW PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not na(ph) and showResist
    f_addLevel(ph, 1, bar_index - pivotLen)
if not na(pl) and showSupport
    f_addLevel(pl, -1, bar_index - pivotLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
asz = array.size(levels)
if asz > 0
    for i = asz - 1 to 0
        if i < array.size(levels)
            l = array.get(levels, i)
            if l.active
                buf = breakSens * atrSafe
                brokeUp = l.levelType == 1 and close > l.price + buf
                brokeDn = l.levelType == -1 and close < l.price - buf
                if brokeUp or brokeDn
                    lastBreakDir := brokeUp ? "Bullish" : "Bearish"
                    if not na(l.priceLbl)
                        label.delete(l.priceLbl)
                    line.set_color(l.ln, color.new(brokenColor, 0))
                    line.set_style(l.ln, line.style_dotted)
                    line.set_width(l.ln, 1)
                    line.set_extend(l.ln, extend.none)
                    line.set_x2(l.ln, bar_index)
                    if not na(l.zone)
                        box.delete(l.zone)
                    if showBreakLbl
                        label.new(bar_index, l.price, brokeUp ? "Break ↑" : "Break ↓", style=brokeUp ? label.style_label_down : label.style_label_up, textcolor=color.white, color=color.new(brokeUp ? supColor : resColor, 30), size=size.small)
                    array.remove(levels, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTEND ACTIVE LEVELS + AGE WIDTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
esz = array.size(levels)
if esz > 0
    for i = 0 to esz - 1
        l = array.get(levels, i)
        if l.active
            if useDynWidth
                age = bar_index - l.barStart
                w = math.min(maxLineWidth, 1 + math.floor((age / maxAgeBars) * (maxLineWidth - 1)))
                line.set_width(l.ln, int(w))
            else
                line.set_width(l.ln, baseWidth)
            line.set_x2(l.ln, bar_index + 1)
            if not na(l.zone)
                box.set_right(l.zone, bar_index + 1)
            if showPriceLbl and not na(l.priceLbl)
                label.set_x(l.priceLbl, bar_index + 10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEAREST LEVELS FOR DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float nearSup = na
var float nearRes = na
nearSup := na
nearRes := na
dsz = array.size(levels)
if dsz > 0
    for i = 0 to dsz - 1
        l = array.get(levels, i)
        if l.active
            if l.levelType == -1 and l.price < close and (na(nearSup) or l.price > nearSup)
                nearSup := l.price
            if l.levelType == 1 and l.price > close and (na(nearRes) or l.price < nearRes)
                nearRes := l.price

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = na
if showDash
    tpos = switch dashPos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.bottom_right
    if barstate.isfirst
        dash := table.new(tpos, 2, 5, bgcolor=color.new(#0d1117, 5), border_color=color.new(#30363d, 40), border_width=1, frame_color=color.new(#30363d, 20), frame_width=1)
    if barstate.islast and not na(dash)
        table.cell(dash, 0, 0, "S/R Dashboard", text_color=color.new(#f0f6fc, 0), text_size=size.normal, bgcolor=color.new(#161b22, 0), text_halign=text.align_center)
        table.merge_cells(dash, 0, 0, 1, 0)
        table.cell(dash, 0, 1, "Resistance", text_color=color.new(#8b949e, 0), bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dash, 1, 1, na(nearRes) ? "—" : str.tostring(nearRes, format.mintick), text_color=na(nearRes) ? color.new(#484f58, 0) : resColor, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)
        table.cell(dash, 0, 2, "Support", text_color=color.new(#8b949e, 0), bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dash, 1, 2, na(nearSup) ? "—" : str.tostring(nearSup, format.mintick), text_color=na(nearSup) ? color.new(#484f58, 0) : supColor, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)
        table.cell(dash, 0, 3, "Last Break", text_color=color.new(#8b949e, 0), bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        bdc = lastBreakDir == "Bullish" ? supColor : lastBreakDir == "Bearish" ? resColor : color.new(#484f58, 0)
        table.cell(dash, 1, 3, lastBreakDir, text_color=bdc, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)
        table.cell(dash, 0, 4, "Active Levels", text_color=color.new(#8b949e, 0), bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dash, 1, 4, str.tostring(array.size(levels)), text_color=color.new(#f0f6fc, 0), bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// M/R SIGNALS (momentum + reversal, range-bar based)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
trendUp = emaFast > emaSlow
trendDown = emaFast < emaSlow
rsiSig = ta.rsi(close, rsiLen)

bullBar = close > open
bearBar = close < open
var int upRun = 0
var int dnRun = 0
upRun := bullBar ? upRun + 1 : 0
dnRun := bearBar ? dnRun + 1 : 0

momBull = upRun >= momBars and (not useTrendFilter or trendUp)
momBear = dnRun >= momBars and (not useTrendFilter or trendDown)
revBull = dnRun >= exhaustBars and rsiSig < rsiOS
revBear = upRun >= exhaustBars and rsiSig > rsiOB

momBullSig = antiSpam ? (momBull and not momBull[1]) : momBull
momBearSig = antiSpam ? (momBear and not momBear[1]) : momBear
revBullSig = antiSpam ? (revBull and not revBull[1]) : revBull
revBearSig = antiSpam ? (revBear and not revBear[1]) : revBear

// RSI extreme arrows: arrow when RSI exits an extreme zone
rsiExitOS = ta.crossover(rsiSig, rsiOS)   // leaving oversold -> bullish
rsiExitOB = ta.crossunder(rsiSig, rsiOB)  // leaving overbought -> bearish

momUpCol = #39ff14
momDnCol = #ff073a
revUpCol = #00ffa3
revDnCol = #ff2d95
rsiUpCol = #00e5ff
rsiDnCol = #d400ff

plot(showSignals ? emaFast : na, "Fast EMA", color=color.new(color.aqua, 40), linewidth=1)
plot(showSignals ? emaSlow : na, "Slow EMA", color=color.new(color.orange, 40), linewidth=1)

// Zeiierman-style placement: offset from price by ATR (clean spacing, not glued to bar)
// Marker glow technique adapted from "Dynamic RSI Regression Bands" by Zeiierman
// (CC BY-NC-SA 4.0) — solid core plotshape + larger translucent plotshape for the glow.
atrOff = ta.ema(ta.atr(20), 100)
placeBelow = ta.lowest(low, 10) - atrOff
placeAbove = ta.highest(high, 10) + atrOff

momBullUp = showSignals and momBullSig
momBearDn = showSignals and momBearSig
revBullUp = showSignals and revBullSig
revBearDn = showSignals and revBearSig
rsiBullUp = showRsiArrows and rsiExitOS
rsiBearDn = showRsiArrows and rsiExitOB

// ── UP markers: glow (large, transparent) UNDER solid core (tiny) ──
plotshape(momBullUp ? placeBelow : na, "Mom Long glow", shape.triangleup, location.absolute, color.new(momUpCol, 70), size=size.small)
plotshape(momBullUp ? placeBelow : na, "Mom Long core", shape.triangleup, location.absolute, color.new(momUpCol, 0),  size=size.tiny, text="M", textcolor=momUpCol)

plotshape(revBullUp ? placeBelow : na, "Rev Long glow", shape.triangleup, location.absolute, color.new(revUpCol, 70), size=size.small)
plotshape(revBullUp ? placeBelow : na, "Rev Long core", shape.triangleup, location.absolute, color.new(revUpCol, 0),  size=size.tiny, text="R", textcolor=revUpCol)

plotshape(rsiBullUp ? placeBelow : na, "RSI Long glow", shape.triangleup, location.absolute, color.new(rsiUpCol, 70), size=size.small)
plotshape(rsiBullUp ? placeBelow : na, "RSI Long core", shape.triangleup, location.absolute, color.new(rsiUpCol, 0),  size=size.tiny, text="RSI", textcolor=rsiUpCol)

// ── DOWN markers: glow (large, transparent) OVER solid core (tiny) ──
plotshape(momBearDn ? placeAbove : na, "Mom Short glow", shape.triangledown, location.absolute, color.new(momDnCol, 70), size=size.small)
plotshape(momBearDn ? placeAbove : na, "Mom Short core", shape.triangledown, location.absolute, color.new(momDnCol, 0),  size=size.tiny, text="M", textcolor=momDnCol)

plotshape(revBearDn ? placeAbove : na, "Rev Short glow", shape.triangledown, location.absolute, color.new(revDnCol, 70), size=size.small)
plotshape(revBearDn ? placeAbove : na, "Rev Short core", shape.triangledown, location.absolute, color.new(revDnCol, 0),  size=size.tiny, text="R", textcolor=revDnCol)

plotshape(rsiBearDn ? placeAbove : na, "RSI Short glow", shape.triangledown, location.absolute, color.new(rsiDnCol, 70), size=size.small)
plotshape(rsiBearDn ? placeAbove : na, "RSI Short core", shape.triangledown, location.absolute, color.new(rsiDnCol, 0),  size=size.tiny, text="RSI", textcolor=rsiDnCol)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RANGE SCALPER PANEL (signals status, top-right)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Remember the last signal and which bar it fired on
var string lastSig = "—"
var int    lastSigBar = na
var bool   lastSigBull = false

if momBullSig
    lastSig := "MOM LONG"
    lastSigBar := bar_index
    lastSigBull := true
else if momBearSig
    lastSig := "MOM SHORT"
    lastSigBar := bar_index
    lastSigBull := false
else if revBullSig
    lastSig := "REV LONG"
    lastSigBar := bar_index
    lastSigBull := true
else if revBearSig
    lastSig := "REV SHORT"
    lastSigBar := bar_index
    lastSigBull := false
else if rsiExitOS
    lastSig := "RSI LONG"
    lastSigBar := bar_index
    lastSigBull := true
else if rsiExitOB
    lastSig := "RSI SHORT"
    lastSigBar := bar_index
    lastSigBull := false

var table sigPanel = table.new(position.top_right, 2, 5, border_width=2)

if barstate.islast and showSignals
    table.clear(sigPanel, 0, 0, 1, 4)

    table.cell(sigPanel, 0, 0, "RANGE SCALPER", bgcolor=color.new(color.black, 0), text_color=color.yellow, text_size=size.small)
    table.cell(sigPanel, 1, 0, syminfo.ticker, bgcolor=color.new(color.black, 0), text_color=color.white, text_size=size.small)

    trTxt = trendUp ? "UP" : trendDown ? "DOWN" : "FLAT"
    trCol = trendUp ? color.new(color.green, 60) : trendDown ? color.new(color.red, 60) : color.new(color.gray, 70)
    table.cell(sigPanel, 0, 1, "EMA Trend", bgcolor=color.new(color.black, 85), text_color=color.white, text_size=size.small)
    table.cell(sigPanel, 1, 1, trTxt, bgcolor=trCol, text_color=color.white, text_size=size.small)

    runTxt = upRun > 0 ? str.tostring(upRun) + " up" : dnRun > 0 ? str.tostring(dnRun) + " down" : "0"
    table.cell(sigPanel, 0, 2, "Bar Run", bgcolor=color.new(color.black, 85), text_color=color.white, text_size=size.small)
    table.cell(sigPanel, 1, 2, runTxt, bgcolor=color.new(color.black, 85), text_color=color.white, text_size=size.small)

    rTxt = str.tostring(rsiSig, "#")
    rCol = rsiSig > rsiOB ? color.new(color.red, 60) : rsiSig < rsiOS ? color.new(color.green, 60) : color.new(color.gray, 75)
    table.cell(sigPanel, 0, 3, str.format("RSI({0})", rsiLen), bgcolor=color.new(color.black, 85), text_color=color.white, text_size=size.small)
    table.cell(sigPanel, 1, 3, rTxt, bgcolor=rCol, text_color=color.white, text_size=size.small)

    // Last signal + bars ago
    barsAgo = na(lastSigBar) ? na : bar_index - lastSigBar
    sTxt = lastSig == "—" ? "—" : barsAgo == 0 ? lastSig + " (now)" : lastSig + " (" + str.tostring(barsAgo) + " bars)"
    sCol = lastSig == "—" ? color.new(color.gray, 75) : lastSigBull ? color.new(color.lime, 40) : color.new(color.red, 40)
    table.cell(sigPanel, 0, 4, "Last Signal", bgcolor=color.new(color.black, 50), text_color=color.yellow, text_size=size.small)
    table.cell(sigPanel, 1, 4, sTxt, bgcolor=sCol, text_color=color.white, text_size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(momBullSig, "Momentum Long", "Range Scalper: Momentum LONG")
alertcondition(momBearSig, "Momentum Short", "Range Scalper: Momentum SHORT")
alertcondition(revBullSig, "Reversal Long", "Range Scalper: Reversal LONG (exhaustion)")
alertcondition(revBearSig, "Reversal Short", "Range Scalper: Reversal SHORT (exhaustion)")
alertcondition(rsiExitOS, "RSI Exit Oversold", "Range Scalper: RSI left oversold (bullish)")
alertcondition(rsiExitOB, "RSI Exit Overbought", "Range Scalper: RSI left overbought (bearish)")
alertcondition(lastBreakDir == "Bullish" and lastBreakDir[1] != "Bullish", "Resistance Broken", "Range Scalper: Resistance broken (bullish)")
alertcondition(lastBreakDir == "Bearish" and lastBreakDir[1] != "Bearish", "Support Broken", "Range Scalper: Support broken (bearish)")
````
