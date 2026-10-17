# TREND RIBBON

- url: https://www.tradingview.com/script/bqr8sODm-TREND-RIBBON/
- type: indicator
- pine_id: PUB;9e2ec177249f427aad3d064a908372c9
- version: 1.0

## Description

trend filter ribbon

trend filter ribbon is a market structure and trend filtering tool designed to help traders read the active direction of price with a clean ema ribbon, external structure logic, internal entry markers, htf bias filtering, and a compact live dashboard.

the tool is built to answer one simple question:

is the market bullish, bearish, or neutral?

it does not try to predict every candle. it filters the chart so the trader can avoid low-quality counter-trend decisions and focus on cleaner directional setups.

what the indicator does

the indicator combines several elements:

ema ribbon:
a multi-layer ema ribbon shows the current trend body. when the ribbon expands, the trend is stronger. when it compresses, the market is weaker or flatter.

external structure:
major swing highs and swing lows define the main market structure. when price breaks a major level, the script detects bos or choch depending on the current structure state.

internal structure:
smaller swing breaks are used as early entry markers, but only when they agree with the active master trend.

htf veto:
a higher timeframe ema filter can block counter-trend conditions. when the lower timeframe disagrees with the selected htf direction, the master trend can be held as neutral.

live structure levels:
the most important active high and low levels are drawn on the chart so the trader can see where the next structural decision may happen.

dashboard:
a compact institutional-style panel displays external trend, htf bias, master state, ribbon spread, active levels, and early long or short validity.

how to read the ribbon

bullish ribbon:
when the ribbon is bullish, the tool is showing that the active structure and trend conditions favor long setups.

bearish ribbon:
when the ribbon is bearish, the tool is showing that the active structure and trend conditions favor short setups.

neutral ribbon:
when the ribbon is neutral, the market is not clean enough or the htf filter is blocking the active direction. beginners should usually avoid trading during neutral conditions.

ribbon spread:
the ribbon spread measures the distance between the fastest and slowest ribbon ema, normalized by atr.

flat:
the ribbon is compressed. the market may be ranging or weak.

building:
the ribbon is expanding. trend strength is improving.

strong:
the ribbon is clearly expanded. the current direction has stronger momentum.

bos and choch

bos means break of structure.

a bullish bos appears when price continues higher by breaking a valid structural high during a bullish structure.

a bearish bos appears when price continues lower by breaking a valid structural low during a bearish structure.

choch means change of character.

a bullish choch appears when price breaks structure upward after a bearish phase.

a bearish choch appears when price breaks structure downward after a bullish phase.

for beginners:
bos usually means continuation.
choch usually means possible reversal.

how to use the indicator

step 1: check the master trend

start with the dashboard.

if master is bullish, focus only on long ideas.
if master is bearish, focus only on short ideas.
if master is neutral, wait.

step 2: check the htf bias

the htf line shows whether the selected higher timeframe is bullish or bearish.

when the htf agrees with the master trend, the condition is cleaner.
when the htf disagrees, the tool can hold the master trend in neutral mode.

step 3: check the ribbon spread

flat ribbon:
avoid aggressive entries.

building ribbon:
look for confirmation.

strong ribbon:
trend conditions are more active.

step 4: wait for structure

a bos can confirm continuation.
a choch can show that the previous direction may be changing.

beginners should not enter only because a label appears. the label should be combined with context, trend direction, support and resistance, and risk management.

step 5: use internal entry markers

internal entry markers are early signals that appear only in the direction of the active filtered trend.

a long marker is only valid when the master trend is bullish.
a short marker is only valid when the master trend is bearish.

beginner example

example long setup:

1. master trend is bullish
2. htf bias is bullish
3. ribbon spread is building or strong
4. price breaks structure upward
5. a long entry marker appears
6. trader looks for a logical stop below the recent swing low
7. trader targets the next resistance, previous high, or a fixed risk/reward level

example short setup:

1. master trend is bearish
2. htf bias is bearish
3. ribbon spread is building or strong
4. price breaks structure downward
5. a short entry marker appears
6. trader looks for a logical stop above the recent swing high
7. trader targets the next support, previous low, or a fixed risk/reward level

main inputs

external swing strength:
controls the strength of the major swing structure. higher values create fewer but stronger structure signals. lower values create more responsive signals.

internal swing strength:
controls the smaller internal structure used for early entry markers. lower values are faster. higher values are cleaner but slower.

break confirmation:
choose whether structure breaks are confirmed by close or wick.

close:
more conservative.

wick:
more reactive.

bos pivot strength:
controls the pivot sensitivity used for bos continuation levels.

choch pivot strength:
controls the pivot sensitivity used for choch reversal levels.

htf timeframe:
selects the higher timeframe used for directional filtering.

htf ema length:
controls the ema used for the higher timeframe bias.

base ema length:
sets the first ema in the ribbon.

ema step:
controls the spacing between each ema in the ribbon.

ribbon lines:
turns the ribbon lines on or off.

ribbon fill:
turns the fill between ribbon layers on or off.

core glow:
adds a stronger visual emphasis to the main ribbon line.

external structure labels:
shows or hides bos and choch labels.

internal entry markers:
shows or hides early long and short markers.

live structure levels:
shows or hides the active major structure levels.

background tint:
adds a light background color based on the current master trend.

dashboard:
shows or hides the live panel.

dashboard position:
lets the trader place the panel in any chart position.

alerts

the script includes alerts for:

bullish choch
bearish choch
bullish bos
bearish bos
long entry
short entry

for best results, create alerts after the indicator is added to the chart and select the alert condition that matches your trading plan.

beginner tips

do not trade every signal.

use the indicator as a filter, not as a complete trading system.

avoid trading when the dashboard shows neutral.

avoid trading when the ribbon spread is flat.

look for agreement between master trend and htf bias.

always define stop loss, target, and invalidation before entering.

combine the tool with support and resistance, liquidity levels, volume, session context, or higher timeframe analysis.

important notes

this indicator is designed for market analysis and trend filtering.

it does not guarantee profitable trades.

signals can fail during news, low liquidity, sideways markets, or high volatility conditions.

risk management remains the responsibility of the trader.

the best use of this tool is to filter direction, read structure, and avoid trading against the dominant trend.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("TREND RIBBON", shorttitle="T-Ribbon", overlay=true, max_lines_count=300, max_labels_count=500)

gS = "Structure"
intLen = input.int(5, "Internal swing strength", minval=2, maxval=50, group=gS, tooltip="Minor swings inside the trend, used only to time entries.")
brkSrc = input.string("Close", "Break Confirmation", options=["Close", "Wick"], group=gS)

gBC = "BOS / CHoCH Pivots"
bosLen = input.int(25, "BOS pivot strength", minval=5, maxval=200, group=gBC, tooltip="Pivot strength used for continuation BOS levels.")
chochLen = input.int(25, "CHoCH pivot strength", minval=5, maxval=200, group=gBC, tooltip="Pivot strength used for reversal CHoCH levels.")
showBosLabels = input.bool(true, "Show BOS labels", group=gBC)
showChochLabels = input.bool(true, "Show CHoCH labels", group=gBC)
showBosAlerts = input.bool(true, "Enable BOS alerts", group=gBC)
showChochAlerts = input.bool(true, "Enable CHoCH alerts", group=gBC)
bosText = input.string("BOS", "BOS label text", group=gBC)
chochText = input.string("CHoCH", "CHoCH label text", group=gBC)
bosTransparency = input.int(75, "BOS label background transparency", minval=0, maxval=100, group=gBC)
chochTransparency = input.int(70, "CHoCH label background transparency", minval=0, maxval=100, group=gBC)

gH = "HTF Veto"
useHTF = input.bool(true, "Block counter-trend vs HTF", group=gH)
htfTF = input.timeframe("240", "HTF Timeframe", group=gH)
htfLen = input.int(50, "HTF EMA length", minval=2, group=gH)

gB = "EMA Ribbon"
emaBase = input.int(8, "Base EMA length", minval=2, group=gB)
emaStep = input.int(6, "EMA step", minval=1, group=gB)

gX = "Visual"
showLines = input.bool(true, "Ribbon Lines", group=gX)
showFill = input.bool(true, "Ribbon Fill", group=gX)
glow = input.bool(false, "Core Glow", group=gX)
showExt = input.bool(true, "External Structure Labels", group=gX)
showEntries = input.bool(true, "Internal Entry Markers", group=gX)
showLevels = input.bool(true, "Live Structure Levels", group=gX)
showBg = input.bool(true, "Background Tint", group=gX)
showDash = input.bool(true, "Show Dashboard", group=gX)
dashPos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=gX)

gC = "Colors"
colBull = input.color(#00FFD1, "Bull", group=gC)
colBear = input.color(#FF3B5C, "Bear", group=gC)
colAccent = input.color(#B8C0CC, "Panel Accent", group=gC)
colNeu = input.color(#9AB0C7, "Neutral", group=gC)

e1 = ta.ema(close, emaBase + 0 * emaStep)
e2 = ta.ema(close, emaBase + 1 * emaStep)
e3 = ta.ema(close, emaBase + 2 * emaStep)
e4 = ta.ema(close, emaBase + 3 * emaStep)
e5 = ta.ema(close, emaBase + 4 * emaStep)
e6 = ta.ema(close, emaBase + 5 * emaStep)
e7 = ta.ema(close, emaBase + 6 * emaStep)
e8 = ta.ema(close, emaBase + 7 * emaStep)

ribSpread = math.abs(e1 - e8) / ta.atr(14)

upSrc = brkSrc == "Close" ? close : high
dnSrc = brkSrc == "Close" ? close : low

phBos = ta.pivothigh(bosLen, bosLen)
plBos = ta.pivotlow(bosLen, bosLen)
phChoch = ta.pivothigh(chochLen, chochLen)
plChoch = ta.pivotlow(chochLen, chochLen)

var float bosH = na
var int bosHb = na
var bool bosHbrk = false
var float bosL = na
var int bosLb = na
var bool bosLbrk = false

var float chochH = na
var int chochHb = na
var bool chochHbrk = false
var float chochL = na
var int chochLb = na
var bool chochLbrk = false

var int trendE = 0

if not na(phBos)
    bosH := phBos
    bosHb := bar_index - bosLen
    bosHbrk := false

if not na(plBos)
    bosL := plBos
    bosLb := bar_index - bosLen
    bosLbrk := false

if not na(phChoch)
    chochH := phChoch
    chochHb := bar_index - chochLen
    chochHbrk := false

if not na(plChoch)
    chochL := plChoch
    chochLb := bar_index - chochLen
    chochLbrk := false

initH = not na(chochH) ? chochH : bosH
initL = not na(chochL) ? chochL : bosL

if trendE == 0 and not na(initH) and not na(initL)
    trendE := close >= (initH + initL) / 2 ? 1 : -1

eChochUp = false
eChochDn = false
eBosUp = false
eBosDn = false

if trendE <= 0 and not na(chochH) and not chochHbrk and upSrc > chochH
    chochHbrk := true
    eChochUp := true
    trendE := 1

if trendE >= 0 and not na(chochL) and not chochLbrk and dnSrc < chochL
    chochLbrk := true
    eChochDn := true
    trendE := -1

if trendE == 1 and not na(bosH) and not bosHbrk and upSrc > bosH and not eChochUp
    bosHbrk := true
    eBosUp := true
    trendE := 1

if trendE == -1 and not na(bosL) and not bosLbrk and dnSrc < bosL and not eChochDn
    bosLbrk := true
    eBosDn := true
    trendE := -1

phI = ta.pivothigh(intLen, intLen)
plI = ta.pivotlow(intLen, intLen)

var float iH = na
var bool iHbrk = false
var float iL = na
var bool iLbrk = false

if not na(phI)
    iH := phI
    iHbrk := false

if not na(plI)
    iL := plI
    iLbrk := false

iBreakUp = false
iBreakDn = false

if not na(iH) and not iHbrk and upSrc > iH
    iHbrk := true
    iBreakUp := true

if not na(iL) and not iLbrk and dnSrc < iL
    iLbrk := true
    iBreakDn := true

htfEma = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfLen), lookahead=barmerge.lookahead_off)
htfBull = not na(htfEma) and close > htfEma
htfBear = not na(htfEma) and close < htfEma

master = trendE

if useHTF and not na(htfEma)
    if (trendE == 1 and htfBear) or (trendE == -1 and htfBull)
        master := 0

masterBull = master == 1
masterBear = master == -1
mcol = master == 1 ? colBull : master == -1 ? colBear : colNeu

activeH = trendE <= 0 ? chochH : bosH
activeHb = trendE <= 0 ? chochHb : bosHb
activeHbrk = trendE <= 0 ? chochHbrk : bosHbrk
activeL = trendE >= 0 ? chochL : bosL
activeLb = trendE >= 0 ? chochLb : bosLb
activeLbrk = trendE >= 0 ? chochLbrk : bosLbrk

lt = showLines ? 55 : 100

p1 = plot(e1, "EMA 1", color=color.new(mcol, lt), linewidth=1)
p2 = plot(e2, "EMA 2", color=color.new(mcol, lt), linewidth=1)
p3 = plot(e3, "EMA 3", color=color.new(mcol, lt), linewidth=1)
p4 = plot(e4, "EMA 4", color=color.new(mcol, lt), linewidth=1)
p5 = plot(e5, "EMA 5", color=color.new(mcol, lt), linewidth=1)
p6 = plot(e6, "EMA 6", color=color.new(mcol, lt), linewidth=1)
p7 = plot(e7, "EMA 7", color=color.new(mcol, lt), linewidth=1)
p8 = plot(e8, "EMA 8", color=color.new(mcol, lt), linewidth=1)

ft = showFill ? 0 : 100

fill(p1, p2, color=color.new(mcol, 70 + ft))
fill(p2, p3, color=color.new(mcol, 74 + ft))
fill(p3, p4, color=color.new(mcol, 78 + ft))
fill(p4, p5, color=color.new(mcol, 81 + ft))
fill(p5, p6, color=color.new(mcol, 84 + ft))
fill(p6, p7, color=color.new(mcol, 87 + ft))
fill(p7, p8, color=color.new(mcol, 90 + ft))

plot(glow ? e1 : na, "Core Glow", color=color.new(mcol, 70), linewidth=7)
plot(glow ? e1 : na, "Core Halo", color=color.new(mcol, 45), linewidth=4)
plot(e1, "Core", color=color.new(mcol, 0), linewidth=2)

bgcolor(showBg and master != 0 ? color.new(mcol, 95) : na)

if showExt and showChochLabels and eChochUp
    label.new(bar_index, low, chochText + " ▲", style=label.style_label_up, color=color.new(colBull, chochTransparency), textcolor=colBull, size=size.tiny)

if showExt and showChochLabels and eChochDn
    label.new(bar_index, high, chochText + " ▼", style=label.style_label_down, color=color.new(colBear, chochTransparency), textcolor=colBear, size=size.tiny)

if showExt and showBosLabels and eBosUp
    label.new(bar_index, low, bosText + " ▲", style=label.style_label_up, color=color.new(colBull, bosTransparency), textcolor=colBull, size=size.tiny)

if showExt and showBosLabels and eBosDn
    label.new(bar_index, high, bosText + " ▼", style=label.style_label_down, color=color.new(colBear, bosTransparency), textcolor=colBear, size=size.tiny)

longEntry = showEntries and iBreakUp and master == 1
shortEntry = showEntries and iBreakDn and master == -1

plotshape(longEntry, "Long Entry", shape.triangleup, location.belowbar, color.new(colBull, 0), size=size.tiny)
plotshape(shortEntry, "Short Entry", shape.triangledown, location.abovebar, color.new(colBear, 0), size=size.tiny)

var line resLine = na
var line supLine = na
var label resLbl = na
var label supLbl = na

if barstate.islast
    line.delete(resLine)
    line.delete(supLine)
    label.delete(resLbl)
    label.delete(supLbl)

    if showLevels and not na(activeH) and not na(activeHb)
        resLine := line.new(activeHb, activeH, bar_index + 5, activeH, xloc=xloc.bar_index, color=color.new(colBear, activeHbrk ? 65 : 10), width=1, style=activeHbrk ? line.style_dotted : line.style_dashed)
        resLbl := label.new(bar_index + 6, activeH, "Major ▲ " + str.tostring(activeH, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(colBear, 80), textcolor=colBear, size=size.tiny)

    if showLevels and not na(activeL) and not na(activeLb)
        supLine := line.new(activeLb, activeL, bar_index + 5, activeL, xloc=xloc.bar_index, color=color.new(colBull, activeLbrk ? 65 : 10), width=1, style=activeLbrk ? line.style_dotted : line.style_dashed)
        supLbl := label.new(bar_index + 6, activeL, "Major ▼ " + str.tostring(activeL, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(colBull, 80), textcolor=colBull, size=size.tiny)

plot(masterBull ? 1 : 0, "BullValid", display=display.none)
plot(masterBear ? 1 : 0, "BearValid", display=display.none)
plot(master, "Master", display=display.none)
plot(longEntry ? 1 : 0, "LongEntry", display=display.none)
plot(shortEntry ? 1 : 0, "ShortEntry", display=display.none)

alertcondition(showChochAlerts and eChochUp, "Trend Filter • CHoCH Bull", "TREND FILTER — bullish CHoCH")
alertcondition(showChochAlerts and eChochDn, "Trend Filter • CHoCH Bear", "TREND FILTER — bearish CHoCH")
alertcondition(showBosAlerts and eBosUp, "Trend Filter • BOS Bull", "TREND FILTER — bullish BOS")
alertcondition(showBosAlerts and eBosDn, "Trend Filter • BOS Bear", "TREND FILTER — bearish BOS")
alertcondition(longEntry, "Trend Filter • Long Entry", "TREND FILTER — internal long entry in bull trend")
alertcondition(shortEntry, "Trend Filter • Short Entry", "TREND FILTER — internal short entry in bear trend")

posSel = dashPos == "Top Right" ? position.top_right :
     dashPos == "Top Center" ? position.top_center :
     dashPos == "Top Left" ? position.top_left :
     dashPos == "Middle Right" ? position.middle_right :
     dashPos == "Middle Center" ? position.middle_center :
     dashPos == "Middle Left" ? position.middle_left :
     dashPos == "Bottom Right" ? position.bottom_right :
     dashPos == "Bottom Center" ? position.bottom_center :
     position.bottom_left

panelBg = color.new(#101216, 4)
panelHead = color.new(#252A32, 0)
panelRowA = color.new(#181C23, 8)
panelRowB = color.new(#11151B, 8)
panelFrame = color.new(#7C8796, 45)
panelBorder = color.new(#3B414C, 35)

var table dash = table.new(posSel, 2, 9, bgcolor=panelBg, frame_color=panelFrame, frame_width=1, border_color=panelBorder, border_width=1)

cell(int c, int r, string t, color tc, color bg) =>
    table.cell(dash, c, r, t, text_color=tc, bgcolor=bg, text_size=size.tiny, text_halign=text.align_left)

f_ribbonBar(_v) =>
    float v = math.min(math.max(_v, 0.0), 3.0)
    int n = int(math.round((v / 3.0) * 5.0))
    n := math.min(math.max(n, 0), 5)
    n == 5 ? "▰▰▰▰▰" : n == 4 ? "▰▰▰▰▱" : n == 3 ? "▰▰▰▱▱" : n == 2 ? "▰▰▱▱▱" : n == 1 ? "▰▱▱▱▱" : "▱▱▱▱▱"

if showDash
    extTxt = trendE == 0 ? "—" : trendE == 1 ? "🟢 ▲ BULL" : "🔴 ▼ BEAR"
    extCol = trendE == 1 ? colBull : trendE == -1 ? colBear : colNeu

    htfTxt = not useHTF ? "off" : na(htfEma) ? "—" : htfBull ? "🟢 ▲ BULL" : "🔴 ▼ BEAR"
    htfCol = not useHTF ? colNeu : htfBull ? colBull : colBear

    mTxt = master == 0 ? "⚪ NEUTRAL" : master == 1 ? "🟢 ▲ BULL" : "🔴 ▼ BEAR"

    longV = master == 1 ? "✓ VALID" : "✗ AVOID"
    shortV = master == -1 ? "✓ VALID" : "✗ AVOID"
    longC = master == 1 ? colBull : colBear
    shortC = master == -1 ? colBull : colBear

    strTxt = ribSpread >= 2 ? "STRONG" : ribSpread >= 1 ? "BUILDING" : "FLAT"
    ribbonTxt = f_ribbonBar(ribSpread) + " " + str.tostring(ribSpread, "#.##") + " ATR"

    cell(0, 0, "🧭 TREND FILTER", colAccent, panelHead)
    cell(1, 0, "WIZARD", colAccent, panelHead)

    cell(0, 1, "External", colNeu, panelRowA)
    cell(1, 1, extTxt, extCol, panelRowA)

    cell(0, 2, "HTF " + htfTF, colNeu, panelRowB)
    cell(1, 2, htfTxt, htfCol, panelRowB)

    cell(0, 3, "MASTER", colNeu, panelRowA)
    cell(1, 3, mTxt + " (" + strTxt + ")", mcol, panelRowA)

    cell(0, 4, "Ribbon Spread", colNeu, panelRowB)
    cell(1, 4, ribbonTxt, mcol, panelRowB)

    cell(0, 5, "Major ▲", colNeu, panelRowA)
    cell(1, 5, na(activeH) ? "—" : str.tostring(activeH, format.mintick) + (activeHbrk ? " broken" : ""), colBear, panelRowA)

    cell(0, 6, "Major ▼", colNeu, panelRowB)
    cell(1, 6, na(activeL) ? "—" : str.tostring(activeL, format.mintick) + (activeLbrk ? " broken" : ""), colBull, panelRowB)

    cell(0, 7, "Early LONG", colNeu, panelRowA)
    cell(1, 7, longV, #0A0E14, color.new(longC, 10))

    cell(0, 8, "Early SHORT", colNeu, panelRowB)
    cell(1, 8, shortV, #0A0E14, color.new(shortC, 10))
else
    table.clear(dash, 0, 0, 1, 8)
````
