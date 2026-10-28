# Delta Tether [AlgoNorth]

- url: https://www.tradingview.com/script/CO2VeNHJ-Delta-Tether-AlgoNorth/
- type: indicator
- pine_id: PUB;28cbc889921b4600a1c1ce1b3ca10d73
- version: 1.0

## Description

Delta Tether

Two rallies can look identical on a chart. One has heavy buying behind it. The other is running on almost nothing. Delta Tether shows how far price has pulled away from the buying and selling behind it, right on the candles.

It draws one line from cumulative delta and ties every candle to it with a tether: green when price is above, red when it is below. Rungs on each tether count the distance in ATR. To the right of the latest bar, a stack of ten cells per side lights up to show where the current gap ranks among the last 500 bars.

The result is two readings in one view: how far price has moved from the line, and how common a gap that size is on this chart. Delta is estimated from lower-timeframe candles, so it works on any plan.

🔶 USAGE

🔸 Follow the line. The line (white on dark charts, dark on light ones) is the price level that recent estimated delta lines up with. Candles above it are tethered in green, candles below it in red.

🔸 Read the tethers. Each tether runs from the line to the candle body, with a glow that is strongest at the candle. A longer tether is a bigger gap. Scroll back and the whole history of gaps is there.

🔸 Count the rungs. The small marks on a tether sit at 1, 2 and 3 ATR from the line, and only appear where the tether reaches that far.

🔸 Read the rank stack. Ten cells on each side of the line, each worth 10 percentile points. Cells light up to the current gap's rank on the side price is on. The p50 and p90 labels mark the middle and the top tenth.

🔸 Check the tag. The tag beside the stack shows the current gap in ATR and its percentile. For example, "−0.85 ATR · p49" means price is 0.85 ATR below the line, a gap larger than 49% of recent ones.

🔸 Read the panel. It shows the settings in use, which delta estimate is running and how much of the chart it covers, and how often price and the line met again within 20 bars, for extreme gaps and for ordinary bars that started the same distance away, with the sample counts.

🔸 Alerts: extreme gap above the line, extreme gap below the line, side change.

🔶 DETAILS

🔸 Estimated delta. Each lower-timeframe candle that closes up adds its volume, each that closes down subtracts it, and a flat one takes the direction of the candle before it. This is an estimate from candle direction and volume. It is not bid/ask or aggressor volume.

🔸 Intrabar timeframe. Auto divides the chart timeframe by 5, 4, 3 or 2, whichever divides it exactly, and otherwise uses 1 minute. On 1-minute and seconds charts it cannot go lower, so each bar counts as one up or down bar. Daily charts use 4 hours, weekly 1 day, monthly 1 week.

🔸 The line. Over the last 50 bars the script fits price against estimated cumulative delta and reads the fitted price at the current bar, then smooths it twice. If price and estimated delta moved in opposite directions over the window, the line is the plain average of those closes, and the panel says "line = window average".

🔸 The gap. The distance from the close to the line, in ATR(14). The rungs are measured to the candle body, so the tag can read slightly larger than the rungs suggest.

🔸 Rank. The current gap is ranked against the gaps of the last 500 bars. The stack, the pointer and the tag are placed by rank, not by price distance.

🔸 Extreme gap. Starts when the gap ranks at or above the 90th percentile for 2 bars in a row. It holds until the gap ranks below the 80th percentile or price changes side.

🔸 Met the line. For each measured bar the script checks whether price and the line touched again within 20 bars. The line keeps moving during that window, so they can meet because the line came to price. The windows overlap, so the samples are not independent. A bar is measured only when the whole window after it is drawn.

🔸 Other bars, same distance. Ordinary bars are weighted to start as far from the line as the extreme gaps did, so the two columns compare like with like. Extreme gaps with no ordinary bars at the same distance are left out of both columns, and the Samples row then reads "N of M". A rate is shown only from 20 samples.

🔸 Colours. The line, labels and panel text follow your chart background, and on light charts the green, red and highlight are deepened to stay readable.

🔸 What is original here. The tethers with ATR rungs and the percentile rank stack are a new way to read the distance between price and delta, directly on the candles. The panel adds a like-for-like check: extreme gaps measured against ordinary bars that started the same distance away.

🔶 SETTINGS

🔸 Delta line: Fit window, Smoothing, Line width. How many bars the fit learns from, and how much the line is smoothed.

🔸 Delta (estimate): Intrabar timeframe, Manual timeframe. Auto, or a lower timeframe you pick.

🔸 Extreme gap: Starts at percentile, Holds above percentile, Ranking window, Bars before it counts, Show dots, Highlight colour, Dot size, Dot distance. The dots are optional and off by default.

🔸 Rungs and rank stack: ATR rungs, Rank stack, Stack size, Stack distance, Stack width, Cell height, Unlit cell transparency, Gap tag distance. Raise Stack size when the chart is zoomed out.

🔸 Style: Colour candles by side, Above the line, Below the line, Adjust colours to the chart background, Wicks and outlines, Rungs, Gap tag background, Gap tag text, Glow behind threads, Glow transparency. Colour candles by side paints each candle green or red by which side of the line it closed on. The preview shows it on. It is off by default so your own candle colours are kept.

🔸 Panel: Show panel, Corner, Text size, Return window. Four corners for when more than one copy is loaded.

🔶 NOTES

🔸 This is a context tool. It measures and displays; it doesn't give buy or sell signals. What you do with the reading is up to you.

🔸 The delta is an estimate from lower-timeframe candle direction and volume, not bid/ask data, and the line is built from that estimate.

🔸 The script draws only on bars that have lower-timeframe data, so older history is left blank. How far back it reaches depends on the timeframe; the panel shows the share of bars drawn and the start date. On the charts tested, 5, 10 and 15-minute and 1-hour charts gave the fullest history; 30 and 45-minute charts reached back much less.

🔸 The script needs some history before it shows anything: about 70 bars for the line, and 500 bars before the rank is fully formed.

🔸 It needs volume. On a symbol that reports none, the script stops and says so, and stretches of a chart with no volume are left blank.

🔸 Dots, alerts and panel counts are set at bar close and nothing is redrawn on past bars. The line, the tether, the stack and the tag on the current bar follow price until that bar closes.

🔸 The line is smoothed, so after a fast move part of the gap is the line catching up. Lower the Smoothing setting for a faster line, or set it to 1 to turn smoothing off.

🔸 An extreme gap describes distance, not what comes next. Read the panel's rates together with the sample counts; they come from the bars loaded on your chart, so each symbol and timeframe shows its own numbers.

🔸 The rank stack is drawn in the empty space to the right of the last bar and needs about 15 bars of room at the default size.

🔸 Candle colouring in the preview is an optional setting, off by default.

🔸 Made for candle and bar charts. On Renko, Kagi and similar chart types the panel says the readings are not valid.

🔸 The panel's last-bar time is shown in exchange time, which can differ from your chart's display timezone.

🔶 SUMMARY

A line built from delta, a tether from every candle to it, and a rank stack beside the last bar. Delta Tether puts the distance between price and the buying and selling behind it right on your chart, so it's easy to see at a glance.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoNorth
//@version=6
// Delta Tether [AlgoNorth]: a line fitted from estimated cumulative delta, tethers from each candle to it,
// and a rank stack for the current gap.
// Delta here is an ESTIMATE built from lower-timeframe bar direction and volume.
// It is not bid/ask aggressor volume.
indicator("Delta Tether [AlgoNorth]", shorttitle = "Delta Tether", overlay = true, max_bars_back = 500)

const string VERSION = "v33"
const int BINS       = 24   // starting-gap bins of 0.5 ATR for the like-for-like comparison; the last bin is 11.5 ATR and beyond
const int MIN_N      = 20   // a rate is printed only from this many samples

// ───────────────────────── Inputs
const string GRP_LINE = "Delta line"
int fitLen     = input.int(50, "Fit window (bars)", minval = 10, maxval = 250, group = GRP_LINE, tooltip = "Bars used to learn how much price has moved per unit of estimated cumulative delta. If price and estimated delta moved in opposite directions over the window, the line is the plain average of those closes instead, and the panel says so.")
int lineSmooth = input.int(5, "Smoothing", minval = 1, maxval = 50, group = GRP_LINE, tooltip = "Applied twice. Higher is smoother and slower. Smoothing adds lag, so part of a gap after a fast move is the line catching up.")
int lineWidth  = input.int(3, "Line width", minval = 1, maxval = 6, group = GRP_LINE)

const string GRP_DELTA = "Delta (estimate)"
string ltfMode   = input.string("Auto", "Intrabar timeframe", options = ["Auto", "Manual"], group = GRP_DELTA, tooltip = "Delta is ESTIMATED from the direction and volume of lower-timeframe bars. It is not bid/ask volume. Auto divides the chart timeframe by 5, 4, 3 or 2, whichever divides it exactly, and otherwise uses 1 minute. On 1-minute and seconds charts it cannot go lower, so each bar counts as one up or down bar. Daily charts use 4 hours, weekly 1 day, monthly 1 week. Lower-timeframe history is limited and the script draws only on bars that have it, so how far back it reaches varies a lot by timeframe. The panel shows the share of bars drawn and the start date.")
string ltfManual = input.timeframe("1", "Manual timeframe", group = GRP_DELTA, tooltip = "Used when 'Intrabar timeframe' is Manual. If it is not lower than the chart timeframe, each bar counts as one up or down bar.")

const string GRP_EXT = "Extreme gap"
int pctThresh   = input.int(90, "Starts at percentile", minval = 50, maxval = 99, group = GRP_EXT, tooltip = "An extreme gap starts when the gap between price and the line ranks at or above this percentile of recent gaps. The panel and alerts use this state whether or not the dots are shown.")
int pctHold     = input.int(80, "Holds above percentile", minval = 30, maxval = 99, group = GRP_EXT, tooltip = "Once an extreme gap has started it continues until the gap ranks below this percentile or price changes side. Values above the start percentile are treated as equal to it.")
int pctLen      = input.int(500, "Ranking window (bars)", minval = 50, maxval = 2000, group = GRP_EXT, tooltip = "How many past bars the current gap is ranked against. Also used for the rank stack. Ranks move in steps of 100 divided by this number, so short windows give coarse percentiles.")
int minRun      = input.int(2, "Bars before it counts", minval = 1, maxval = 10, group = GRP_EXT, tooltip = "The gap must rank at or above the start percentile for this many bars in a row. Dots and alerts wait for the bar to close and are never back-filled. The panel's Now row includes the forming bar.")
bool showDots   = input.bool(false, "Show dots", group = GRP_EXT, tooltip = "Dots along the line while an extreme gap is active. Off by default; the rank stack shows the current reading.")
color hiCol     = input.color(#FFD23F, "Highlight colour", group = GRP_EXT, tooltip = "Used for the optional dots and for the pointer beside the rank stack.")
int dotSize     = input.int(4, "Dot size", minval = 1, maxval = 10, group = GRP_EXT)
float dotOffset = input.float(0.4, "Dot distance from the line (ATR)", minval = 0.05, maxval = 3.0, step = 0.05, group = GRP_EXT, tooltip = "Dots sit this far from the line, in ATR(14), on the side away from price.")

const string GRP_STACK = "Rungs and rank stack"
bool showRungs   = input.bool(true, "ATR rungs on the tethers", group = GRP_STACK, tooltip = "A small mark on each tether at 1, 2 and 3 ATR(14) from the line. The marks are measured to the candle body. The ATR figure in the tag and panel is measured to the close, so it can be slightly larger.")
bool showStack   = input.bool(true, "Rank stack", group = GRP_STACK, tooltip = "Ten cells on each side of the line, to the right of the latest bar. Each cell is 10 percentile points of the gap ranking. Cells light up to the current gap's rank on the side price is on. The cells, the pointer and the tag are placed by rank, not by price distance. The stack is drawn into empty space on the right: at the default settings it needs roughly 15 bars of room times 'Stack size'. In Bar Replay there is usually less room than that.")
float stackScale = input.float(1.0, "Stack size", minval = 0.5, maxval = 8.0, step = 0.25, group = GRP_STACK, tooltip = "Scales the whole stack: cell height, width, its distance from the latest bar and the tag distance. Raise it when the chart is zoomed out. From 2 upward the text also steps up a size. At very large settings the sideways spacing is capped so nothing is drawn past the platform's limit.")
int stackOffset  = input.int(6, "Stack distance (bars)", minval = 3, maxval = 40, group = GRP_STACK, tooltip = "Bars to the right of the latest bar, before 'Stack size' is applied.")
int stackWidth   = input.int(2, "Stack width (bars)", minval = 1, maxval = 6, group = GRP_STACK, tooltip = "Width of the cells in bars, before 'Stack size' is applied.")
float cellHeight = input.float(0.3, "Cell height (ATR)", minval = 0.1, maxval = 1.0, step = 0.05, group = GRP_STACK, tooltip = "Height of each cell in ATR(14), before 'Stack size' is applied.")
int dimTransp    = input.int(82, "Unlit cell transparency", minval = 50, maxval = 95, group = GRP_STACK)
int tagOffset    = input.int(5, "Gap tag distance (bars)", minval = 3, maxval = 40, group = GRP_STACK, tooltip = "Bars from the stack to the centre of the gap tag, before 'Stack size' is applied. Raise it if the tag overlaps the p50 or p90 labels.")

const string GRP_STYLE = "Style"
bool colorCandles = input.bool(false, "Colour candles by side", group = GRP_STYLE, tooltip = "Off by default, so the chart's own candles are shown. On: candles are coloured by which side of the line they closed on.")
color upCol       = input.color(#00E676, "Above the line", group = GRP_STYLE, tooltip = "Colour for bars closing above the delta line. It shows which side of the line price is on, not a market direction call.")
color dnCol       = input.color(#FF1744, "Below the line", group = GRP_STYLE, tooltip = "Colour for bars closing below the delta line. It shows which side of the line price is on, not a market direction call.")
bool autoCol      = input.bool(true, "Adjust colours to the chart background", group = GRP_STYLE, tooltip = "On: the wicks, outlines, rungs and gap tag switch between light and dark, and on a light background the green, red and highlight colours are deepened so they stay readable. Off: the colours are used exactly as set, with the four colours below for the wicks, rungs and tag. The line, the stack labels and the panel text always follow the chart background.")
color wickCol     = input.color(color.white, "Wicks and outlines", group = GRP_STYLE, tooltip = "Used when the option above is off and 'Colour candles by side' is on.")
color rungCol     = input.color(color.white, "Rungs", group = GRP_STYLE, tooltip = "Used when the option above is off.")
color tagBg       = input.color(color.white, "Gap tag background", group = GRP_STYLE, tooltip = "Used when the option above is off.")
color tagTxt      = input.color(color.black, "Gap tag text", group = GRP_STYLE, tooltip = "Used when the option above is off.")
bool showGlow     = input.bool(true, "Glow behind threads", group = GRP_STYLE)
int glowTransp    = input.int(45, "Glow transparency at the candle", minval = 5, maxval = 95, group = GRP_STYLE, tooltip = "Lower is brighter. The glow is strongest at the candle and faint at the line.")

const string GRP_PANEL = "Panel"
bool showPanel  = input.bool(true, "Show panel", group = GRP_PANEL)
string panelPos = input.string("Top right", "Corner", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = GRP_PANEL)
string panelTxt = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GRP_PANEL)
int horizon     = input.int(20, "Return window (bars)", minval = 2, maxval = 200, group = GRP_PANEL, tooltip = "How many bars price and the line are given to meet again. The line keeps moving during the window, so they can meet because the line came to price. Windows overlap, so the samples are not independent. 'Other bars, same distance' is ordinary bars weighted to start as far from the line as the extreme gaps did, so the two columns compare like with like. Extreme gaps with no ordinary bars at the same distance are left out of both columns, and the Samples row then reads as 'N of M'. A sample counts only when the whole window after it is drawn. A rate is shown only from 20 samples. These figures change a great deal with the settings above.")

// ───────────────────────── Colours that follow the chart background
lum(color c) => 0.2126 * color.r(c) + 0.7152 * color.g(c) + 0.0722 * color.b(c)
shade(color c, float f) => color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f)

bool lightBg   = lum(chart.bg_color) > 120
bool deepen    = autoCol and lightBg
color fgAuto   = lightBg ? #0F0F0F : color.white
color wickUse  = autoCol ? fgAuto : wickCol
color rungUse  = autoCol ? fgAuto : rungCol
color tagBgUse = autoCol ? fgAuto : tagBg
color tagTxUse = autoCol ? (lightBg ? color.white : color.black) : tagTxt
// Bright colours wash out on a light background, so they are deepened there.
color upUse    = deepen ? shade(upCol, 0.72) : upCol
color dnUse    = deepen ? shade(dnCol, 0.72) : dnCol
color hiUse    = deepen ? shade(hiCol, 0.80) : hiCol
color hdrTxt   = lum(upUse) > 120 ? color.black : color.white

// ───────────────────────── Estimated delta
// Auto: the chart timeframe divided by 5, 4, 3 or 2 where that divides exactly, otherwise one minute.
int chartSec  = timeframe.in_seconds()
int tfMult    = timeframe.multiplier
int autoMin   = tfMult % 5 == 0 ? int(tfMult / 5) : tfMult % 4 == 0 ? int(tfMult / 4) : tfMult % 3 == 0 ? int(tfMult / 3) : tfMult % 2 == 0 ? int(tfMult / 2) : 1
string autoTf = timeframe.isseconds ? timeframe.period : timeframe.isminutes ? timeframe.from_seconds(autoMin * 60) : timeframe.isdaily and tfMult == 1 ? "240" : timeframe.isdaily or timeframe.isweekly ? "1D" : "1W"
string manTf  = timeframe.in_seconds(ltfManual) <= chartSec ? ltfManual : timeframe.period
string ltf    = ltfMode == "Auto" ? autoTf : manTf
bool sameTf   = timeframe.in_seconds(ltf) >= chartSec

[ltfOpen, ltfClose, ltfVol] = request.security_lower_tf(syminfo.tickerid, ltf, [open, close, volume], ignore_invalid_timeframe = true)

// A symbol with no volume cannot produce a delta estimate, so the script stops and says why.
var float volSeen = 0.0
volSeen += nz(volume)
if barstate.islast and volSeen == 0.0
    runtime.error("Delta Tether needs volume. This symbol reports none, so no delta can be estimated.")

// Up intrabars add their volume, down intrabars subtract it. A flat intrabar takes the direction of the one before it.
// Bars with no lower-timeframe data contribute nothing and are not drawn.
var int lastDir = 0
float delta = 0.0
int ltfBars = array.size(ltfClose)
bool hasLtf = ltfBars > 0
if hasLtf
    for i = 0 to ltfBars - 1
        float o = array.get(ltfOpen, i)
        float c = array.get(ltfClose, i)
        float v = nz(array.get(ltfVol, i))
        int d   = c > o ? 1 : c < o ? -1 : lastDir
        delta   += d * v
        lastDir := d
else
    lastDir := 0
float cvd = ta.cum(delta)

// Bars in a row with lower-timeframe data, counting this one.
int ltfRun = 0
ltfRun := hasLtf ? nz(ltfRun[1]) + 1 : 0

// ───────────────────────── Delta-implied line
// Fit price against cumulative delta over the window, then read the fitted price at the current bar.
// Cumulative delta is measured relative to the current bar, so the current x is 0.
float sx  = 0.0
float sy  = 0.0
float sxx = 0.0
float sxy = 0.0
int n     = 0
for i = 0 to fitLen - 1
    float xi = cvd[i] - cvd
    if not na(xi)
        float yi = close[i]
        sx  += xi
        sy  += yi
        sxx += xi * xi
        sxy += xi * yi
        n   += 1

float cxx = sxx - sx * sx / n
float cxy = sxy - sx * sy / n
// When price and delta move opposite ways (or delta is flat) the slope is zero and the line is the window average.
bool lineIsAvg = not (cxx > 0 and cxy > 0)
float slope    = lineIsAvg ? 0.0 : cxy / cxx
float rawLine  = n >= 3 ? sy / n - slope * sx / n : close
float fitLine  = ta.ema(ta.ema(rawLine, lineSmooth), lineSmooth)

// The script draws only where the whole fit window, plus room for the smoothing to settle, has lower-timeframe
// data and some volume. Older bars are left blank, so nothing drawn is ever recalculated from a different estimate.
// The volume sum is on its own line so it runs on every bar.
int needRun  = fitLen + 4 * lineSmooth
float volSum = math.sum(nz(volume), fitLen)
bool show    = ltfRun >= needRun and volSum > 0 and not na(fitLine)
float anchor = show ? fitLine : na

// ───────────────────────── Side, gap, gap percentile, extreme-gap state
float atr     = ta.atr(14)
int side      = close > anchor ? 1 : close < anchor ? -1 : 0
float stretch = show and atr > 0 ? math.abs(close - anchor) / atr : na
float gapPct  = ta.percentrank(stretch, pctLen)
int holdPct   = math.min(pctHold, pctThresh)

bool sameSide = side == side[1]
bool enterOK  = side != 0 and gapPct >= pctThresh
bool holdOK   = side != 0 and gapPct >= holdPct

var int run = 0
run := enterOK ? (sameSide ? run + 1 : 1) : 0

// Starts after minRun bars at the start percentile. Ends when the gap ranks below the hold percentile or price changes side.
bool extOn = false
extOn := (extOn[1] and holdOK and sameSide) or run >= minRun

int extBars = 0
extBars := extOn ? nz(extBars[1]) + 1 : 0

bool extNow   = extOn and barstate.isconfirmed
bool extStart = extNow and not extOn[1]

// A side change is a close on the opposite side from the last bar that had a side.
var int lastSide = 0
bool sideFlip = barstate.isconfirmed and side != 0 and lastSide != 0 and side != lastSide
if barstate.isconfirmed and side != 0
    lastSide := side

// Coverage: how many closed bars are drawn, and since when.
var int barsSeen  = 0
var int barsShown = 0
var int shownFrom = na
if barstate.isconfirmed
    barsSeen += 1
    if show
        barsShown += 1
        if na(shownFrom)
            shownFrom := time

// ───────────────────────── Threads and glow (to the candle body, not the wick)
float bodyLo   = math.min(open, close)
float bodyHi   = math.max(open, close)
bool hasThread = bodyLo > anchor or bodyHi < anchor
float nearEdge = side > 0 ? bodyLo : bodyHi
color sideCol  = side > 0 ? upUse : dnUse
float span     = nearEdge - anchor

// Five layers, each running from a step along the thread to the candle. They stack, so the
// glow is brightest at the candle and there are no gaps between slices.
bool glowOn  = showGlow and hasThread
float layerT = 100.0 * math.pow(glowTransp / 100.0, 1.0 / 5.0)
color layerC = color.new(sideCol, layerT)
float gTop   = glowOn ? nearEdge : na
float g0 = glowOn ? anchor : na
float g1 = glowOn ? anchor + span * 0.2 : na
float g2 = glowOn ? anchor + span * 0.4 : na
float g3 = glowOn ? anchor + span * 0.6 : na
float g4 = glowOn ? anchor + span * 0.8 : na

plotcandle(g0, math.max(g0, gTop), math.min(g0, gTop), gTop, title = "Glow 1", color = layerC, bordercolor = color(na), display = display.pane)
plotcandle(g1, math.max(g1, gTop), math.min(g1, gTop), gTop, title = "Glow 2", color = layerC, bordercolor = color(na), display = display.pane)
plotcandle(g2, math.max(g2, gTop), math.min(g2, gTop), gTop, title = "Glow 3", color = layerC, bordercolor = color(na), display = display.pane)
plotcandle(g3, math.max(g3, gTop), math.min(g3, gTop), gTop, title = "Glow 4", color = layerC, bordercolor = color(na), display = display.pane)
plotcandle(g4, math.max(g4, gTop), math.min(g4, gTop), gTop, title = "Glow 5", color = layerC, bordercolor = color(na), display = display.pane)

// The thread itself: a plotted wick from the line to the candle body, so the line can be drawn above it.
// The body has no height and sits on the line. Its border must be switched off, or the default black outline
// shows as a dash on the line on light backgrounds.
plotcandle(hasThread ? anchor : na, hasThread ? math.max(anchor, nearEdge) : na, hasThread ? math.min(anchor, nearEdge) : na, hasThread ? anchor : na, title = "Threads", color = color(na), wickcolor = sideCol, bordercolor = color(na), display = display.pane)

// ATR rungs: a flat mark across the column at 1, 2 and 3 ATR from the line, only where the tether reaches that far.
float reach = math.abs(span)
float r1 = showRungs and hasThread and reach >= atr       ? anchor + side * atr       : na
float r2 = showRungs and hasThread and reach >= 2.0 * atr ? anchor + side * 2.0 * atr : na
float r3 = showRungs and hasThread and reach >= 3.0 * atr ? anchor + side * 3.0 * atr : na
plotcandle(r1, r1, r1, r1, title = "Rung 1 ATR", bordercolor = rungUse, display = display.pane)
plotcandle(r2, r2, r2, r2, title = "Rung 2 ATR", bordercolor = rungUse, display = display.pane)
plotcandle(r3, r3, r3, r3, title = "Rung 3 ATR", bordercolor = rungUse, display = display.pane)

// ───────────────────────── Line (above the threads), candles, dots
plot(anchor, "Delta line", color = fgAuto, linewidth = lineWidth)

// When candle colouring is on, candles are redrawn on top so the wicks and outlines can take their own colour.
bool paintCandle = colorCandles and side != 0
barcolor(paintCandle ? sideCol : na)
plotcandle(paintCandle ? open : na, paintCandle ? high : na, paintCandle ? low : na, paintCandle ? close : na, title = "Candles", color = sideCol, wickcolor = wickUse, bordercolor = wickUse, display = display.pane)

// Optional dots follow the line on the side away from price: under it when price is above, over it when price is below.
float dotY = side > 0 ? anchor - dotOffset * atr : anchor + dotOffset * atr
plot(showDots and extNow ? dotY : na, "Extreme gap", color = hiUse, style = plot.style_circles, linewidth = dotSize)

// ───────────────────────── Rank stack (latest bar only, redrawn each update)
// Ten cells per side, each worth 10 percentile points of the gap ranking. Cells light up to the
// current rank on the side price is on. Position shows rank, not price distance.
rankText() => na(gapPct) ? "p—" : "p" + str.tostring(math.floor(gapPct), "0")

var array<box> stBoxes    = array.new<box>()
var array<label> stLabels = array.new<label>()
var line stLead           = na

if barstate.islast
    for bx in stBoxes
        box.delete(bx)
    array.clear(stBoxes)
    for lb in stLabels
        label.delete(lb)
    array.clear(stLabels)
    line.delete(stLead)

    if showStack and show and atr > 0
        // 'Stack size' scales every dimension. Only the sideways spacing is capped, to stay inside the platform's 500-bar limit.
        float sclH   = math.min(stackScale, 470.0 / (stackOffset + stackWidth + tagOffset))
        int offBars  = int(math.round(stackOffset * sclH))
        int wBars    = int(math.round(stackWidth * sclH))
        int tagBars  = int(math.round(tagOffset * sclH))
        int ptrBars  = int(math.round(sclH))
        string txtSz = stackScale >= 2.0 ? size.large : size.normal
        string ptrSz = stackScale >= 2.0 ? size.small : size.tiny
        int xL       = bar_index + offBars
        int xR       = xL + wBars
        float cellH  = cellHeight * atr * stackScale
        float stepH  = cellH * 1.35
        float startH = cellH * 0.8
        int lit      = na(gapPct) ? 0 : int(math.ceil(gapPct / 10.0))

        // Lead from the latest bar to the stack, along the line
        stLead := line.new(bar_index, anchor, xL, anchor, color = color.new(fgAuto, 45), style = line.style_dotted)

        for s = 0 to 1
            float sg    = s == 0 ? 1.0 : -1.0
            color col   = s == 0 ? upUse : dnUse
            bool active = (s == 0 and side > 0) or (s == 1 and side < 0)
            for k = 0 to 9
                float yNear = anchor + sg * (startH + k * stepH)
                float yFar  = yNear + sg * cellH
                color cellC = active and k < lit ? col : color.new(col, dimTransp)
                array.push(stBoxes, box.new(xL, math.max(yNear, yFar), xR, math.min(yNear, yFar), border_color = cellC, bgcolor = cellC))
                // The fifth cell ends at p50 and the ninth at p90, so the tags sit on those outer edges.
                if k == 4 or k == 8
                    array.push(stLabels, label.new(xR, yFar, k == 4 ? "p50" : "p90", style = label.style_label_left, color = color(na), textcolor = fgAuto, size = txtSz))

        // Current gap, on a tag level with the top lit cell. A centred label has no pointer, so the text sits in the middle.
        float yNow     = lit > 0 and side != 0 ? anchor + side * (startH + (lit - 1) * stepH + cellH / 2.0) : anchor
        string signTxt = side > 0 ? "+" : side < 0 ? "−" : ""
        array.push(stLabels, label.new(xL - ptrBars, yNow, "", style = label.style_circle, color = hiUse, size = ptrSz))
        array.push(stLabels, label.new(xR + tagBars, yNow, signTxt + str.tostring(stretch, "0.00") + " ATR · " + rankText(), style = label.style_label_center, color = tagBgUse, textcolor = tagTxUse, size = txtSz))

// ───────────────────────── Measured meeting with the line
// Only drawn bars are measured, and only when every bar of the window after them is drawn too, so a gap in the
// data is never scored as "did not meet". The line keeps moving during the window, so price and the line can meet
// because the line came to price. Both groups are binned by starting gap so they can be compared like for like.
float touchLow    = math.sum(low <= anchor ? 1.0 : 0.0, horizon)
float touchHigh   = math.sum(high >= anchor ? 1.0 : 0.0, horizon)
float drawnWin    = math.sum(show ? 1.0 : 0.0, horizon)
int pastSide      = side[horizon]
bool pastStart    = extStart[horizon]
bool pastExt      = extOn[horizon]
float pastStretch = stretch[horizon]

var array<int> extN      = array.new<int>(BINS, 0)
var array<int> extBack   = array.new<int>(BINS, 0)
var array<float> extGap  = array.new<float>(BINS, 0.0)
var array<int> othN      = array.new<int>(BINS, 0)
var array<int> othBack   = array.new<int>(BINS, 0)
var array<float> othGap  = array.new<float>(BINS, 0.0)

if barstate.isconfirmed and not na(pastStretch) and pastSide != 0 and drawnWin == horizon
    bool back = pastSide > 0 ? touchLow > 0 : touchHigh > 0
    int bin   = math.min(BINS - 1, int(pastStretch / 0.5))
    if pastStart
        array.set(extN, bin, array.get(extN, bin) + 1)
        array.set(extBack, bin, array.get(extBack, bin) + (back ? 1 : 0))
        array.set(extGap, bin, array.get(extGap, bin) + pastStretch)
    else if not pastExt
        array.set(othN, bin, array.get(othN, bin) + 1)
        array.set(othBack, bin, array.get(othBack, bin) + (back ? 1 : 0))
        array.set(othGap, bin, array.get(othGap, bin) + pastStretch)

// ───────────────────────── Panel
panelCorner = switch panelPos
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right

panelSize = switch panelTxt
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table panel = table.new(panelCorner, 3, 9, bgcolor = color.new(chart.bg_color, 10), border_color = color.new(fgAuto, 80), border_width = 1, frame_color = color.new(fgAuto, 60), frame_width = 1)

if showPanel and barstate.islast
    bool valid = chart.is_standard

    // Both columns use the same bins: only distances where extreme gaps AND ordinary bars both exist.
    // The ordinary bars are weighted to the extreme gaps' own spread of starting distances.
    int extAll    = 0
    int mExt      = 0
    int mExtBack  = 0
    float mExtGap = 0.0
    float mRate   = 0.0
    float mGap    = 0.0
    int mSamples  = 0
    for b = 0 to BINS - 1
        int e = array.get(extN, b)
        int o = array.get(othN, b)
        extAll += e
        if e > 0 and o > 0
            mExt     += e
            mExtBack += array.get(extBack, b)
            mExtGap  += array.get(extGap, b)
            mRate    += e * 1.0 * array.get(othBack, b) / o
            mGap     += e * array.get(othGap, b) / o
            mSamples += o

    // A rate needs MIN_N samples on both sides of the comparison.
    string extRateTxt = valid and mExt >= MIN_N ? str.tostring(100.0 * mExtBack / mExt, "0.0") + "%" : "—"
    string othRateTxt = valid and mExt >= MIN_N and mSamples >= MIN_N ? str.tostring(100.0 * mRate / mExt, "0.0") + "%" : "—"
    string extGapTxt  = valid and mExt > 0 ? str.tostring(mExtGap / mExt, "0.00") : "—"
    string othGapTxt  = valid and mExt > 0 ? str.tostring(mGap / mExt, "0.00") : "—"
    // "N of M" when some extreme gaps had no ordinary bars at the same distance and were left out.
    string extCntTxt  = str.tostring(mExt) + (mExt < extAll ? " of " + str.tostring(extAll) : "")

    table.cell(panel, 0, 0, "Delta Tether [AlgoNorth] " + VERSION + " · delta line", text_color = hdrTxt, text_size = panelSize, bgcolor = upUse, text_halign = text.align_left)
    table.merge_cells(panel, 0, 0, 2, 0)
    table.cell(panel, 0, 1, "Fit " + str.tostring(fitLen) + " · smooth " + str.tostring(lineSmooth) + "×2 · extreme p" + str.tostring(pctThresh) + " × " + str.tostring(minRun) + ", hold p" + str.tostring(holdPct) + " · rank " + str.tostring(pctLen), text_color = fgAuto, text_size = panelSize, text_halign = text.align_left)
    table.merge_cells(panel, 0, 1, 2, 1)
    // Which estimate is in use, and how much of the chart is drawn
    string estTxt = not hasLtf ? "no lower-timeframe data on this bar" : sameTf ? "bar direction (" + ltf + " is the chart timeframe)" : "intrabar " + ltf
    string covTxt = barsSeen > 0 ? " · drawn on " + str.tostring(100.0 * barsShown / barsSeen, "0.0") + "% of bars" + (na(shownFrom) ? "" : " since " + str.format_time(shownFrom, "yyyy-MM-dd", syminfo.timezone)) : ""
    table.cell(panel, 0, 2, valid ? "Delta estimate: " + estTxt + covTxt : "Non-standard chart: this script's readings are not valid here", text_color = fgAuto, text_size = panelSize, text_halign = text.align_left)
    table.merge_cells(panel, 0, 2, 2, 2)
    table.cell(panel, 1, 3, "Extreme gaps", text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 2, 3, "Other bars, same distance", text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 0, 4, "Met the line ≤ " + str.tostring(horizon) + " bars", text_color = fgAuto, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, extRateTxt, text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 2, 4, othRateTxt, text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 0, 5, "Gap when measured (ATR)", text_color = fgAuto, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, extGapTxt, text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 2, 5, othGapTxt, text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 0, 6, "Samples", text_color = fgAuto, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, valid ? extCntTxt : "—", text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 2, 6, valid ? str.tostring(mSamples) : "—", text_color = fgAuto, text_size = panelSize)
    string sideTxt = side > 0 ? "Above" : side < 0 ? "Below" : "On line"
    bool nowOk     = valid and show and not na(stretch)
    string nowTxt  = nowOk ? sideTxt + " · " + str.tostring(stretch, "0.00") + " ATR · " + rankText() : valid ? "not drawn on this bar" : "—"
    string runTxt  = extOn ? "extreme · " + str.tostring(extBars) + " bars" : "not extreme"
    string fitTxt  = lineIsAvg ? "line = window average" : "line = delta fit"
    table.cell(panel, 0, 7, "Now", text_color = fgAuto, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, nowTxt, text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 2, 7, nowOk ? fitTxt + " · " + runTxt : "—", text_color = fgAuto, text_size = panelSize)
    table.cell(panel, 0, 8, "Last bar " + str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone) + " exchange time · " + str.tostring(bar_index + 1) + " bars", text_color = color.new(fgAuto, 30), text_size = panelSize, text_halign = text.align_left)
    table.merge_cells(panel, 0, 8, 2, 8)

// ───────────────────────── Alerts
alertcondition(extStart and side > 0, "Extreme gap above the line", "Delta Tether, {{ticker}} {{interval}}: price is unusually far above the Delta Tether line.")
alertcondition(extStart and side < 0, "Extreme gap below the line", "Delta Tether, {{ticker}} {{interval}}: price is unusually far below the Delta Tether line.")
alertcondition(sideFlip, "Side change", "Delta Tether, {{ticker}} {{interval}}: price closed on the other side of the Delta Tether line.")
````
