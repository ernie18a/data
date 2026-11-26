# VWAP Master [SimpleAlgo]

- url: https://www.tradingview.com/script/GHkirqfX-VWAP-Master-SimpleAlgo/
- type: indicator
- pine_id: PUB;50b8a80c1315415e8338931f5dd388c2
- version: 1.0

## Description

⭐ [b]OVERVIEW[/b]

Most VWAP tools give you the line, a couple of deviation bands, and leave the rest to you. We wanted the chart to do the reading: is price above value or below it, how far has it stretched, and has it started coming back.

So VWAP Master draws the line, puts a wide gradient band on each side for the stretched zone, colours the candles by where price is, and prints two things only. A small "Stretched" tag when price is deep enough into a band to matter, and an arrow when it turns. The panel in the corner says the same thing in words.

⚙️ [b]HOW IT WORKS[/b]

[list=1]
[*][b]VWAP.[/b] By default it's a rolling VWAP: the volume-weighted average of typical price over the last 100 bars. It never resets, which is why the line and bands stay smooth. If you want the classic version, switch the anchor to Session, Week, Month or Year. Those restart at the start of each period, and you'll see a small break in the line where they do.
[*][b]Deviation.[/b] The volume-weighted standard deviation around VWAP over the same window. In rolling mode it's smoothed a little so the bands breathe instead of stepping. It also can't go below a third of an ATR, otherwise the first few bars after a reset would all look stretched.
[*][b]Bands.[/b] Each one runs from 1.5 to 3.25 deviations, built from seven layers a quarter deviation each, faint on the inside and brightest at the outer edge. The top band is in the down colour and the bottom one in the up colour, because that's the way a bounce off each of them goes.
[*][b]Side.[/b] The line turns the up colour once price has closed at least 0.3 deviations above VWAP and stayed there for 3 bars, and the down colour when it does the same below. Nothing prints for this. The line and the panel just change.
[*][b]Stretched.[/b] A visit to a band starts when a bar closes 1.5 deviations or more from VWAP. The first time that visit gets to 2 deviations you get a small Stretched tag, with an arrow for the direction a bounce would go. One per visit.
[*][b]Bounce.[/b] Once a visit has reached 2 deviations, the first bar that closes back inside the 1.5 line on a candle pointing at VWAP gets an arrow. The turn has to happen within 3 bars of the last close inside the band, so a slow drift back doesn't count. If the visit reached the outer edge of the band first, the arrow gets a +.
[*][b]One per visit.[/b] This is the part that keeps the chart clean. A visit isn't over until price is back within half a deviation of VWAP, no matter how many times it pokes in and out of the band on the way. You only get a second arrow on the same visit if price went at least half a deviation deeper than it had at the first one, and there are never fewer than 10 bars between two arrows on the same side.
[*][b]Trend.[/b] The panel tells you if VWAP is rising, falling or flat over the last 20 bars, and there's an option to skip any bounce that goes against that.
[/list]

Tags and arrows are decided on closed bars and never move afterwards. The line, bands and candle colours update on the live bar like any moving average does. The panel reads the last closed bar so it never gets ahead of the chart.

🎯 [b]HOW TO USE IT[/b]

Start with the line and the candles. Up colour, price is holding above value. Down colour, below. Dim candles right on the line mean it's at value and nobody has the edge yet.

The bands are the stretched zone. Price lives between them most of the time, and when it reaches into one it's a long way from value and tends to come back.

The tag is the heads-up, the arrow is the turn. The + means it went all the way to the outer edge before turning, which is the kind we pay the most attention to.

Before you act on an arrow, look at the VWAP row in the panel. A bounce up toward a rising VWAP is a pullback in an uptrend. A bounce up toward a falling one is a fade against the trend, and those need more care. If you only want the first kind, turn on "Skip bounces against the trend".

On the anchor: Rolling gives you the smooth read on any timeframe. Session is the intraday VWAP that institutions actually reference. Week or Month suit swing trading.

None of this predicts where price goes next, and an arrow isn't a buy or sell recommendation. In a strong trend price can sit inside a band for a long time. Use it alongside your own analysis and manage your risk.

💡 [b]WHAT MAKES IT DIFFERENT[/b]

The rolling anchor keeps the picture continuous instead of restarting every session. The bands are drawn so you can see how stretched price is without reading a number. And the signal logic treats a visit to the band as one event instead of firing on every dip in and out, which is usually what makes band tools too noisy to keep on the chart.

🔔 [b]ALERTS[/b]

[list]
[*]Stretched above value, Stretched below value.
[*]Bounce down, Bounce up. The message says if it was a + bounce.
[/list]

🛠️ [b]SETTINGS[/b]

[list]
[*][b]VWAP:[/b] anchor (Rolling, Session, Week, Month, Year), rolling length, show bands, where the band starts, band smoothing.
[*][b]Signals:[/b] bounce signals, stretched tags, skip bounces against the trend.
[*][b]Candles and panel:[/b] candle colouring, panel and position.
[*][b]Look:[/b] themes (Neon, Classic, Aurora, Ice, Custom), glow on the VWAP line, signal label distance.
[/list]

📝 [b]NOTES[/b]

[list]
[*]The rolling anchor is a volume-weighted moving average. It isn't the session VWAP that intraday traders usually mean by the word. Switch to Session if that's what you're after.
[*]Volume is whatever your data feed gives you. On forex and CFDs that's usually tick volume.
[*]On symbols with no volume at all it falls back to a time-weighted version, and the panel header says "no volume".
[*]In the anchored modes the bands are narrow right after a reset and widen as the period builds.
[*]Mean reversion to value works best in ranges. In a strong trend price can hold inside a band for ages. That's why the VWAP direction is in the panel and why the trend filter exists.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("VWAP Master [SimpleAlgo]", "VWAP Master [SimpleAlgo]", overlay = true, max_labels_count = 500)

// ═══════════════════════════════ Inputs ═══════════════════════════════
grpA = "VWAP"
anchorIn  = input.string("Rolling", "Anchor", options = ["Rolling", "Session", "Week", "Month", "Year"], group = grpA, tooltip = "Rolling: a VWAP over the last N bars that never resets, so it stays smooth. Session, Week, Month and Year restart the average at the start of each period, the way a classic VWAP does.")
rollLen   = input.int(100, "Rolling length (bars)", minval = 20, maxval = 1000, group = grpA, tooltip = "Only used with the Rolling anchor.")
showBands = input.bool(true, "Show bands", group = grpA)
bandIn    = input.float(1.5, "Band starts at (deviations)", minval = 0.5, maxval = 4.0, step = 0.25, group = grpA, tooltip = "The inner edge of the band, in standard deviations from VWAP. The band is 1.75 deviations thick, so 1.5 runs from 1.5 to 3.25.")
smoothLen = input.int(10, "Band smoothing", minval = 1, maxval = 50, group = grpA, tooltip = "Smooths the band width so it breathes instead of stepping. Rolling anchor only.")

grpS = "Signals"
showSig     = input.bool(true, "Bounce signals", group = grpS, tooltip = "An arrow when price pushes at least 2 deviations from VWAP, then closes back toward it. One per visit to the band, however many times price dips in and out. The arrow gets a + when price reached the outer edge of the band first.")
showStretch = input.bool(true, "Stretched tags", group = grpS, tooltip = "A small tag once price is deep enough into the band for a bounce to count. The heads-up that a signal may follow.")
withTrend   = input.bool(false, "Skip bounces against the trend", group = grpS, tooltip = "When VWAP is rising, only bounces up from the lower band print. When it is falling, only bounces down from the upper band. A flat VWAP prints both.")

grpT = "Candles and panel"
showCandles = input.bool(true, "Color candles by distance from value", group = grpT, tooltip = "Up colour above VWAP, down colour below. The further price is from VWAP, the brighter the candle.")
showPanel   = input.bool(true, "Show panel", group = grpT)
panelPos    = input.string("Top Right", "Panel position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpT)

grpD = "Look"
theme    = input.string("Neon", "Theme", options = ["Neon", "Classic", "Aurora", "Ice", "Custom"], group = grpD)
cUp      = input.color(#00FFA3, "Up",   inline = "c", group = grpD)
cDn      = input.color(#FF3D71, "Down", inline = "c", group = grpD)
cFlat    = input.color(#2B3040, "Flat", inline = "c", group = grpD, tooltip = "Candles sitting right on VWAP. Keep this dark.")
showGlow = input.bool(true, "Soft glow on VWAP", group = grpD)
labelOff = input.float(1.2, "Signal label distance (ATR)", minval = 0.1, maxval = 15.0, step = 0.1, group = grpD)

[colUp, colDn, colFlat] = switch theme
    "Neon"    => [#00FFA3, #FF3D71, #262B38]
    "Aurora"  => [#5EEAD4, #C084FC, #2A2F3E]
    "Classic" => [#00FF31, #FF0013, #23262F]
    "Ice"     => [#7DD3FC, #F472B6, #262932]
    => [cUp, cDn, cFlat]

color ink  = #0F1117
color mute = #8B93A7

// Signal rules
float sideBuffer   = 0.3   // price has to clear VWAP by this many deviations for the line colour to change
int   sideConfirm  = 3     // and stay there this many bars
float minDepth     = 0.5   // a bounce needs price at least this far into the band (so 2.0 deviations with the default band)
float deeperBy     = 0.5   // a second bounce on the same visit needs a push this much deeper than the first
float visitEnd     = 0.5   // a visit to the band is over once price is back within this many deviations of VWAP
int   bounceWindow = 3     // the turn has to come within this many bars of the last close inside the band
int   minGap       = 10    // minimum bars between two signals on the same side

// ═══════════════════════════════ VWAP ═══════════════════════════════
// Rolling window or anchored to a period. Falls back to time-weighted when the symbol has no volume.
bool   rolling      = anchorIn == "Rolling"
string anchorTF     = anchorIn == "Session" ? "D" : anchorIn == "Week" ? "W" : anchorIn == "Month" ? "M" : "12M"
bool   newPeriod    = not rolling and timeframe.change(anchorTF)
bool   symbolHasVol = ta.cum(nz(volume)) > 0
float  src          = hlc3
float  w            = symbolHasVol ? nz(volume) : 1.0

// Rolling
float rVw  = symbolHasVol ? ta.vwma(src, rollLen) : ta.sma(src, rollLen)
float rVar = symbolHasVol ? ta.vwma(src * src, rollLen) - rVw * rVw : math.pow(ta.stdev(src, rollLen), 2)

// Anchored
var float sPV  = 0.0
var float sV   = 0.0
var float sP2V = 0.0
if newPeriod
    sPV  := 0.0
    sV   := 0.0
    sP2V := 0.0
sPV  += src * w
sV   += w
sP2V += src * src * w
float aVw  = sV > 0 ? sPV / sV : src
float aVar = sV > 0 ? sP2V / sV - aVw * aVw : 0.0

float vw   = rolling ? rVw : aVw
float vari = rolling ? rVar : aVar
float atr  = ta.atr(14)
// Floor at 0.3 ATR so the first bars after a reset don't read as stretched
float sdRaw = math.max(math.sqrt(math.max(nz(vari), 0.0)), nz(atr) * 0.3)
float sdSm  = ta.ema(sdRaw, smoothLen)
float sd    = rolling ? sdSm : sdRaw
float dist  = (close - vw) / sd
// 20-bar VWAP slope in deviations
float slope = (vw - nz(vw[20], vw)) / sd
int   trend = slope > 0.3 ? 1 : slope < -0.3 ? -1 : 0

// Seven layers per side, 0.25 deviations each
float step = 0.25
float u0 = vw + sd * bandIn
float u1 = vw + sd * (bandIn + step * 1)
float u2 = vw + sd * (bandIn + step * 2)
float u3 = vw + sd * (bandIn + step * 3)
float u4 = vw + sd * (bandIn + step * 4)
float u5 = vw + sd * (bandIn + step * 5)
float u6 = vw + sd * (bandIn + step * 6)
float u7 = vw + sd * (bandIn + step * 7)
float d0 = vw - sd * bandIn
float d1 = vw - sd * (bandIn + step * 1)
float d2 = vw - sd * (bandIn + step * 2)
float d3 = vw - sd * (bandIn + step * 3)
float d4 = vw - sd * (bandIn + step * 4)
float d5 = vw - sd * (bandIn + step * 5)
float d6 = vw - sd * (bandIn + step * 6)
float d7 = vw - sd * (bandIn + step * 7)
float bandOuter = bandIn + step * 7

// Side of VWAP, and the side price has cleared by the buffer
int rawSide = close >= vw ? 1 : -1
var int candSide = 0
candSide := close > vw + sd * sideBuffer ? 1 : close < vw - sd * sideBuffer ? -1 : candSide
var int sideRun = 0
sideRun := candSide == candSide[1] ? sideRun + 1 : 1

// ═══════════════════════════════ Events (confirmed bars only) ═══════════════════════════════
var int    state        = 0       // confirmed side: 1 above VWAP, -1 below, 0 not confirmed yet
var bool   visitUp      = false   // a visit to the upper band is in progress
var bool   visitDn      = false
var float  peakUp       = 0.0     // deepest point of the visit, in deviations
var float  peakDn       = 0.0
var float  sigPeakUp    = na      // depth at the last signal of this visit
var float  sigPeakDn    = na
var bool   taggedUp     = false   // the Stretched tag has printed for this visit
var bool   taggedDn     = false
var int    tagBarUp     = -100000 // bar of the last Stretched tag, so a bounce label right after it sits higher
var int    tagBarDn     = -100000
var int    lastInUp     = na      // last bar that closed inside the upper band
var int    lastInDn     = na
var int    lastDnSig    = -100000
var int    lastUpSig    = -100000
var string lastEvent    = "None yet"
var int    lastEventBar = na
bool bounceDn = false
bool bounceUp = false
bool stretchUp  = false
bool stretchDn  = false

if barstate.isconfirmed and not na(atr) and not na(vw)
    if newPeriod
        state   := 0
        visitUp := false
        visitDn := false

    // Confirmed side (line colour only)
    if candSide != 0 and sideRun >= sideConfirm and candSide != state
        state := candSide

    // ── Upper band ──
    if close >= u0
        if not visitUp
            visitUp   := true
            peakUp    := dist
            sigPeakUp := na
            taggedUp  := false
        peakUp   := math.max(peakUp, dist)
        lastInUp := bar_index
        if not taggedUp and dist >= bandIn + minDepth
            taggedUp := true
            tagBarUp := bar_index
            stretchUp  := true
            if showStretch
                label.new(bar_index, high + atr * 0.15, "Stretched ▼", style = label.style_label_down, color = color.new(colDn, 100), textcolor = color.new(colDn, 20), size = size.small, tooltip = "Price is " + str.tostring(dist, "0.0") + " deviations above VWAP. This far from value, price tends to come back toward it. A bounce signal prints once it turns.")
            alert("VWAP Master: stretched above value", alert.freq_once_per_bar_close)
    else if visitUp
        bool turned = close < open and bar_index - lastInUp <= bounceWindow
        bool deep   = peakUp >= bandIn + minDepth
        bool deeper = na(sigPeakUp) or peakUp >= sigPeakUp + deeperBy
        bool okTrend = not withTrend or trend <= 0
        if turned and deep and deeper and okTrend and bar_index - lastDnSig >= minGap
            bool strong = peakUp >= bandOuter
            sigPeakUp := peakUp
            lastDnSig := bar_index
            bounceDn  := true
            if showSig
                label.new(bar_index, high + atr * (labelOff + (bar_index - tagBarUp <= 3 ? 0.7 : 0.0)), strong ? "▼ +" : "▼", style = label.style_label_down, color = colDn, textcolor = ink, size = size.normal, tooltip = (strong ? "Strong bounce. " : "Bounce. ") + "Price reached " + str.tostring(peakUp, "0.0") + " deviations above VWAP, then closed back toward it on a down candle." + (strong ? "\nThe + means it reached the outer edge of the band first." : ""))
                lastEvent    := strong ? "Bounce ▼ +" : "Bounce ▼"
                lastEventBar := bar_index
                alert("VWAP Master: " + (strong ? "strong " : "") + "bounce down from the band", alert.freq_once_per_bar_close)
        if dist <= visitEnd
            visitUp := false

    // ── Lower band: mirror ──
    if close <= d0
        if not visitDn
            visitDn   := true
            peakDn    := -dist
            sigPeakDn := na
            taggedDn  := false
        peakDn   := math.max(peakDn, -dist)
        lastInDn := bar_index
        if not taggedDn and -dist >= bandIn + minDepth
            taggedDn := true
            tagBarDn := bar_index
            stretchDn  := true
            if showStretch
                label.new(bar_index, low - atr * 0.15, "Stretched ▲", style = label.style_label_up, color = color.new(colUp, 100), textcolor = color.new(colUp, 20), size = size.small, tooltip = "Price is " + str.tostring(-dist, "0.0") + " deviations below VWAP. This far from value, price tends to come back toward it. A bounce signal prints once it turns.")
            alert("VWAP Master: stretched below value", alert.freq_once_per_bar_close)
    else if visitDn
        bool turned = close > open and bar_index - lastInDn <= bounceWindow
        bool deep   = peakDn >= bandIn + minDepth
        bool deeper = na(sigPeakDn) or peakDn >= sigPeakDn + deeperBy
        bool okTrend = not withTrend or trend >= 0
        if turned and deep and deeper and okTrend and bar_index - lastUpSig >= minGap
            bool strong = peakDn >= bandOuter
            sigPeakDn := peakDn
            lastUpSig := bar_index
            bounceUp  := true
            if showSig
                label.new(bar_index, low - atr * (labelOff + (bar_index - tagBarDn <= 3 ? 0.7 : 0.0)), strong ? "▲ +" : "▲", style = label.style_label_up, color = colUp, textcolor = ink, size = size.normal, tooltip = (strong ? "Strong bounce. " : "Bounce. ") + "Price reached " + str.tostring(peakDn, "0.0") + " deviations below VWAP, then closed back toward it on an up candle." + (strong ? "\nThe + means it reached the outer edge of the band first." : ""))
                lastEvent    := strong ? "Bounce ▲ +" : "Bounce ▲"
                lastEventBar := bar_index
                alert("VWAP Master: " + (strong ? "strong " : "") + "bounce up from the band", alert.freq_once_per_bar_close)
        if dist >= -visitEnd
            visitDn := false

// ═══════════════════════════════ Drawing ═══════════════════════════════
color stateCol = state == 1 ? colUp : state == -1 ? colDn : mute
bool  gap      = newPeriod
bool  bands    = showBands and not gap

// Band edges are hidden; the fills brighten toward the outer edge
pU0 = plot(bands ? u0 : na, "Upper edge 0", color = na, display = display.none, editable = false)
pU1 = plot(bands ? u1 : na, "Upper edge 1", color = na, display = display.none, editable = false)
pU2 = plot(bands ? u2 : na, "Upper edge 2", color = na, display = display.none, editable = false)
pU3 = plot(bands ? u3 : na, "Upper edge 3", color = na, display = display.none, editable = false)
pU4 = plot(bands ? u4 : na, "Upper edge 4", color = na, display = display.none, editable = false)
pU5 = plot(bands ? u5 : na, "Upper edge 5", color = na, display = display.none, editable = false)
pU6 = plot(bands ? u6 : na, "Upper edge 6", color = na, display = display.none, editable = false)
pU7 = plot(bands ? u7 : na, "Upper edge 7", color = na, display = display.none, editable = false)
pD0 = plot(bands ? d0 : na, "Lower edge 0", color = na, display = display.none, editable = false)
pD1 = plot(bands ? d1 : na, "Lower edge 1", color = na, display = display.none, editable = false)
pD2 = plot(bands ? d2 : na, "Lower edge 2", color = na, display = display.none, editable = false)
pD3 = plot(bands ? d3 : na, "Lower edge 3", color = na, display = display.none, editable = false)
pD4 = plot(bands ? d4 : na, "Lower edge 4", color = na, display = display.none, editable = false)
pD5 = plot(bands ? d5 : na, "Lower edge 5", color = na, display = display.none, editable = false)
pD6 = plot(bands ? d6 : na, "Lower edge 6", color = na, display = display.none, editable = false)
pD7 = plot(bands ? d7 : na, "Lower edge 7", color = na, display = display.none, editable = false)

fill(pU0, pU1, color = color.new(colDn, 94), title = "Upper band 1 (inner, faintest)")
fill(pU1, pU2, color = color.new(colDn, 90), title = "Upper band 2")
fill(pU2, pU3, color = color.new(colDn, 86), title = "Upper band 3")
fill(pU3, pU4, color = color.new(colDn, 82), title = "Upper band 4")
fill(pU4, pU5, color = color.new(colDn, 78), title = "Upper band 5")
fill(pU5, pU6, color = color.new(colDn, 75), title = "Upper band 6")
fill(pU6, pU7, color = color.new(colDn, 72), title = "Upper band 7 (outer, brightest)")
fill(pD0, pD1, color = color.new(colUp, 94), title = "Lower band 1 (inner, faintest)")
fill(pD1, pD2, color = color.new(colUp, 90), title = "Lower band 2")
fill(pD2, pD3, color = color.new(colUp, 86), title = "Lower band 3")
fill(pD3, pD4, color = color.new(colUp, 82), title = "Lower band 4")
fill(pD4, pD5, color = color.new(colUp, 78), title = "Lower band 5")
fill(pD5, pD6, color = color.new(colUp, 75), title = "Lower band 6")
fill(pD6, pD7, color = color.new(colUp, 72), title = "Lower band 7 (outer, brightest)")

// VWAP line with a soft glow
plot(showGlow and not gap ? vw : na, "Glow outer", color = color.new(stateCol, 92), linewidth = 5, style = plot.style_linebr)
plot(showGlow and not gap ? vw : na, "Glow mid",   color = color.new(stateCol, 84), linewidth = 3, style = plot.style_linebr)
plot(gap ? na : vw, "VWAP", color = color.new(stateCol, 0), linewidth = 1, style = plot.style_linebr)

// Candles: brighter the further from VWAP
float distInt = math.min(math.abs(dist) / bandOuter, 1.0)
color sideCol = rawSide == 1 ? colUp : colDn
color barCol  = color.from_gradient(0.3 + 0.7 * distInt, 0.0, 1.0, colFlat, sideCol)
color candleC = (rawSide == 1 ? close >= open : close <= open) ? barCol : color.from_gradient(0.35, 0.0, 1.0, barCol, colFlat)
barcolor(showCandles ? candleC : na, title = "Value candles")

// ═══════════════════════════════ Panel ═══════════════════════════════
color pBg  = color.new(ink, 8)
color pTxt = color.new(#E5E7EB, 0)
pPos = switch panelPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table pnl = table.new(pPos, 2, 5, bgcolor = pBg, border_width = 2, border_color = color.new(ink, 0), frame_width = 1, frame_color = color.new(#2A3040, 0))
if barstate.islast and showPanel
    // Read the last closed bar while the current one is forming
    bool   live    = not barstate.isconfirmed
    int    bi      = live ? bar_index - 1 : bar_index
    float  pDist   = nz(live ? dist[1] : dist)
    int    pCand   = live ? candSide[1] : candSide
    bool   testing = state == 0 or pCand != state
    bool   stUp    = pDist >= bandIn
    bool   stDn    = pDist <= -bandIn
    color  pState  = state == 1 ? colUp : state == -1 ? colDn : mute
    string status  = stUp ? "Stretched above value" : stDn ? "Stretched below value" : testing ? "Testing VWAP" : state == 1 ? "Buyers in control" : "Sellers in control"
    color  stCol   = stUp ? colDn : stDn ? colUp : testing ? pTxt : pState
    string distTxt = str.tostring(math.abs(pDist), "0.0") + (pDist >= 0 ? " deviations above" : " deviations below")
    int    pTrend  = live ? trend[1] : trend
    string trendTxt = pTrend == 1 ? "Rising" : pTrend == -1 ? "Falling" : "Flat"
    color  trendCol = pTrend == 1 ? colUp : pTrend == -1 ? colDn : pTxt
    string anchorTxt = (rolling ? "Rolling VWAP over the last " + str.tostring(rollLen) + " bars." : anchorIn + " VWAP, restarts every " + str.lower(anchorIn) + ".") + (symbolHasVol ? "" : " This symbol has no volume data, so this is a time-weighted average.")
    int    agoN    = na(lastEventBar) ? 0 : bi - lastEventBar
    string lastTxt = na(lastEventBar) ? lastEvent : lastEvent + (agoN == 0 ? ", this bar" : agoN == 1 ? ", 1 bar ago" : ", " + str.tostring(agoN) + " bars ago")
    color  lastCol = na(lastEventBar) ? pTxt : str.contains(lastEvent, "▲") ? colUp : colDn

    pnl.cell(0, 0, (state == 1 ? "▲  " : state == -1 ? "▼  " : "○  ") + "VWAP MASTER" + (symbolHasVol ? "" : " · no volume"), text_color = ink, text_size = size.normal, text_halign = text.align_left, bgcolor = pState, tooltip = anchorTxt)
    pnl.merge_cells(0, 0, 1, 0)
    pnl.cell(0, 1, "Price",      text_color = mute, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 1, distTxt,      text_color = pDist >= 0 ? colUp : colDn, text_size = size.normal, text_halign = text.align_right, tooltip = "Distance from VWAP in standard deviations. The band starts at " + str.tostring(bandIn, "0.0") + " and ends at " + str.tostring(bandOuter, "0.00") + ".")
    pnl.cell(0, 2, "Status",     text_color = mute, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 2, status,       text_color = stCol, text_size = size.normal, text_halign = text.align_right)
    pnl.cell(0, 3, "VWAP",       text_color = mute, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 3, trendTxt,     text_color = trendCol, text_size = size.normal, text_halign = text.align_right, tooltip = "Where VWAP is heading over the last 20 bars. A bounce up toward a rising VWAP is a pullback in an uptrend. A bounce up toward a falling one goes against the trend.")
    pnl.cell(0, 4, "Last event", text_color = mute, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 4, lastTxt,      text_color = lastCol, text_size = size.normal, text_halign = text.align_right)

// ═══════════════════════════════ Alerts ═══════════════════════════════
alertcondition(stretchUp,  "Stretched above value", "VWAP Master: stretched above value")
alertcondition(stretchDn,  "Stretched below value", "VWAP Master: stretched below value")
alertcondition(bounceDn, "Bounce down",           "VWAP Master: bounce down from the band")
alertcondition(bounceUp, "Bounce up",             "VWAP Master: bounce up from the band")
````
