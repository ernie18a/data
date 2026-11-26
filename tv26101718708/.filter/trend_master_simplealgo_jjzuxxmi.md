# Trend Master [SimpleAlgo]

- url: https://www.tradingview.com/script/JjZUxXMi-Trend-Master-SimpleAlgo/
- type: indicator
- pine_id: PUB;a69593941e294131a697e4bf2b07acd3
- version: 1.0

## Description

⭐ [b]OVERVIEW[/b]

Trend Master answers three questions at a glance: which way is the market trending, how strong is that trend right now, and is the current dip a pullback inside the trend or the start of something new.

It does this with one adaptive ribbon, candles colored by trend strength, and only two kinds of signals: a confirmed trend start and a finished pullback. A built-in chop filter pauses signals when the market is going nowhere, and a panel describes the current state in plain words.

⚙️ [b]HOW IT WORKS[/b]

[list=1]
[*][b]Adaptive ribbon.[/b] The ribbon is built from a fast and a slow exponential average. Their lengths are not fixed: they are scaled by an efficiency ratio (how far price actually travelled over the slow length, divided by the total path it took). In clean, directional markets the lengths shorten so the ribbon follows price closely. In choppy markets they lengthen, up to 1.6x the base length, so the ribbon flips less on noise. The trend is up when the fast average is above the slow one, and down when it is below.
[*][b]Trend strength.[/b] Each bar gets a strength score from 0 to 1, blended from three parts: how far apart the two averages are (measured in ATR), how efficiently price is moving, and, where volume data exists, whether up-volume versus down-volume over the last 20 bars supports the trend direction. The score is lightly smoothed and described as Strong, Steady or Weakening.
[*][b]Trend start signal.[/b] When the averages cross, the new direction is not signalled right away. It must survive the confirmation period (default 3 bars) with price closed on the correct side of the ribbon. Signals must also alternate direction, so a trend that briefly flips and flips back can never produce two labels pointing the same way. Because of the confirmation period, UPTREND and DOWNTREND labels appear a few bars after the actual cross. This is intentional: it is the cost of filtering out false starts.
[*][b]Chop filter.[/b] The script counts how many times the ribbon has flipped in the recent window (default 50 bars). If it has flipped more than the allowed number (default 2), the market is treated as chop. The ribbon keeps tracking direction, but no trend or pullback signals print until it settles, and the panel shows "Chop, signals paused".
[*][b]Pullback signal.[/b] Once a confirmed trend is at least the minimum age (default 8 bars), the script watches for price to reach into the ribbon by the chosen depth (default 40% of the ribbon's width). When price then closes back outside the ribbon on a candle in the trend direction, and trend strength is at least Steady, a diamond marks the finished pullback.
[*][b]Trend origin line.[/b] A dashed line marks the price where the current trend began. While price stays on the right side of it, the move that started the trend has not been undone.
[/list]

Signals are decided on closed bars only and never move afterwards. The ribbon, candle colors, glow and aura update on the current bar as it forms, like any moving average. The panel reads from the last closed bar so it never gets ahead of the chart.

🎯 [b]HOW TO USE IT[/b]

[list]
[*][b]Read the ribbon first.[/b] Its color is the trend direction. Its brightness and the aura around it show strength: a wide, bright aura is a strong trend, a thin, faded one is a trend running out of steam.
[*][b]Trend labels mark confirmed changes in direction.[/b] They are rare by design.
[*][b]Diamonds mark continuation.[/b] Price dipped into the ribbon and resumed with the trend. These are the moments trend traders typically watch for re-entries.
[*][b]Watch the panel status.[/b] "Trending clean", "Trending", "Pulling back", "Losing steam", "Confirming..." and "Chop, signals paused" describe the current state in plain words.
[*][b]Adjust to your market.[/b] Longer lengths suit slower markets and higher timeframes. If you see too few signals in ranging markets, raise the chop filter's max flips. If pullback diamonds appear too often, raise the pullback depth or the spacing between pullbacks.
[/list]

This shows trend direction, strength and structure. It does not predict where price will go next and is not a buy or sell recommendation. Use it with your own analysis and risk management.

💡 [b]WHAT MAKES IT DIFFERENT[/b]

Most trend ribbons use fixed lengths and signal every crossover. Trend Master adapts its lengths to how efficiently price is moving, requires a new trend to survive a confirmation period before it is signalled, pauses entirely in chop, and adds a strength reading and a pullback signal. The ribbon tells you not just the direction, but the quality of the trend and where it is continuing.

🔔 [b]ALERTS[/b]

[list]
[*]New uptrend and New downtrend (on confirmation, with move quality in the message).
[*]Pullback in uptrend and Pullback in downtrend (with trend strength in the message).
[/list]

🛠️ [b]SETTINGS[/b]

[list]
[*][b]Trend ribbon:[/b] fast and slow length, adapt to volatility on or off.
[*][b]Signals:[/b] trend start and pullback toggles, confirmation bars, chop filter window and max flips, pullback depth, spacing between pullbacks, minimum trend age for pullbacks.
[*][b]Trend strength:[/b] strength-colored candles, panel and position, include volume.
[*][b]Look:[/b] themes (Neon, Aurora, Classic, Ice, Custom), neon glow, strength aura, trend origin line, background flash on trend start (off by default), and label distances.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Trend Master [SimpleAlgo]", "Trend Master", overlay = true, max_labels_count = 500, max_lines_count = 200)

// ═══════════════════════════════ Inputs ═══════════════════════════════
grpR = "Trend ribbon"
showRibbon = input.bool(true, "Show ribbon", group = grpR)
fastLen    = input.int(21, "Fast length", minval = 2, maxval = 200, group = grpR)
slowLen    = input.int(55, "Slow length", minval = 3, maxval = 400, group = grpR)
adaptive   = input.bool(true, "Adapt to volatility", group = grpR, tooltip = "Speeds the averages up when the market is moving cleanly and slows them down when it is choppy, so the ribbon flips less in noise.")

grpS = "Signals"
showStart    = input.bool(true, "Trend start signals", group = grpS, tooltip = "Price and both averages line up in a new direction.")
showPullback = input.bool(true, "Pullback signals", group = grpS, tooltip = "During a trend, price dips into the ribbon and turns back out with the trend.")
confirmBars  = input.int(3, "Confirm trend after (bars)", minval = 1, maxval = 20, group = grpS, tooltip = "A new trend only gets a signal once it has survived this many bars with price still on the right side of the ribbon. Flips that die sooner are ignored, so you never get two signals in a row pointing the same way.")
chopWin      = input.int(50, "Chop filter: window (bars)", minval = 10, maxval = 500, group = grpS, tooltip = "The chop filter counts how many times the ribbon has flipped inside this many bars.")
chopMax      = input.int(2, "Chop filter: max flips in window", minval = 1, maxval = 20, group = grpS, tooltip = "If the ribbon has flipped more than this many times inside the window, the market is treated as chop and no trend or pullback signals print until it settles. Raise it to get more signals in ranges, lower it to get fewer.")
pullDepth    = input.int(40, "Pullback depth (% of ribbon)", minval = 0, maxval = 100, group = grpS, tooltip = "How far into the ribbon price has to reach before it counts as a pullback. 0 = just touching the fast average. Higher values mean fewer, deeper pullbacks.")
pullGap      = input.int(12, "Min bars between pullbacks", minval = 0, maxval = 200, group = grpS)
minAge       = input.int(8, "Min trend age for pullbacks (bars)", minval = 1, maxval = 100, group = grpS)

grpT = "Trend strength"
showCandles = input.bool(true, "Color candles by strength", group = grpT)
showPanel   = input.bool(true, "Show panel", group = grpT)
panelPos    = input.string("Top Right", "Panel position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpT)
useVol      = input.bool(true, "Include volume in strength", group = grpT, tooltip = "When volume data exists, trend strength also considers whether volume is supporting the move. Ignored on symbols without volume.")

grpD = "Look"
theme      = input.string("Neon", "Theme", options = ["Neon", "Aurora", "Classic", "Ice", "Custom"], group = grpD)
cUp        = input.color(#3DDC97, "Up",   inline = "c", group = grpD)
cDn        = input.color(#F2607A, "Down", inline = "c", group = grpD)
cFlat      = input.color(#2B3040, "Flat", inline = "c", group = grpD, tooltip = "Used where the trend is weak. Keep this dark: if it is brighter than the up/down colours it pulls the eye to the weakest part of the chart.")
showGlow   = input.bool(true, "Neon glow on ribbon", group = grpD, tooltip = "Soft halo around the fast average. Brightens as the trend strengthens.")
showAura   = input.bool(true, "Strength aura", group = grpD, tooltip = "A translucent band on the outside of the ribbon that widens as the trend gets stronger and shrinks as it weakens. Read it like a breathing gauge.")
showOrigin = input.bool(true, "Trend origin line", group = grpD, tooltip = "Dashed line at the price where the current trend began. A simple line in the sand: while price stays on the right side of it, the trend has not been undone.")
showFlash  = input.bool(false, "Flash background on trend start", group = grpD)
labelOff   = input.float(4.0, "Trend label distance (ATR)", minval = 0.1, maxval = 15.0, step = 0.5, group = grpD, tooltip = "How far the UPTREND / DOWNTREND labels sit from the bar. Measured in ATR, so it scales with the symbol's volatility. Raise it if labels overlap the candles.")
pullOff    = input.float(1.5, "Pullback marker distance (ATR)", minval = 0.1, maxval = 15.0, step = 0.5, group = grpD)

[colUp, colDn, colFlat] = switch theme
    "Neon"    => [#00FFA3, #FF3D71, #262B38]
    "Aurora"  => [#5EEAD4, #C084FC, #2A2F3E]
    "Classic" => [#00E676, #FF1744, #23262F]
    "Ice"     => [#7DD3FC, #F472B6, #262932]
    => [cUp, cDn, cFlat]

color ink = #0F1117
// Readable grey for panel text. Never use colFlat for text: it is deliberately dark.
color mute = #8B93A7

// ═══════════════════════════════ Adaptive ribbon ═══════════════════════════════
// Exponential average that accepts a length which changes bar to bar.
vEma(float src, float len) =>
    float a = 2.0 / (math.max(len, 1.0) + 1.0)
    var float e = na
    e := na(e) ? src : a * src + (1.0 - a) * e
    e

// Efficiency: how far price got, divided by the path it took. High = clean move, low = chop.
float chg   = math.abs(close - close[slowLen])
float noise = math.sum(math.abs(close - close[1]), slowLen)
float eff   = noise > 0 ? chg / noise : 0.0
float effS  = ta.ema(eff, 5)

// Lengths stretch in chop and tighten in clean trends
float mult   = adaptive ? (1.6 - nz(effS)) : 1.0
float fLen   = math.max(2.0, fastLen * mult)
float sLen   = math.max(3.0, slowLen * mult)
float fastMA = vEma(close, fLen)
float slowMA = vEma(close, sLen)

int   dir      = fastMA > slowMA ? 1 : -1
bool  flipped  = dir != dir[1]
color trendCol = dir == 1 ? colUp : colDn

// Chop filter: too many ribbon flips in the recent window means signals are suppressed
float flips  = math.sum(flipped ? 1.0 : 0.0, chopWin)
bool choppy = flips > chopMax

// ═══════════════════════════════ Trend strength ═══════════════════════════════
// Three inputs, each 0 to 1: how separated the averages are (in ATR), how efficient the move is,
// and whether volume supports it. Blended into one score, then described in plain words.
float atr    = ta.atr(14)
float sep    = atr > 0 ? math.min(math.abs(fastMA - slowMA) / atr, 2.0) / 2.0 : 0.0
float volMA  = ta.sma(volume, 20)
bool  hasVol = not na(volume) and not na(volMA) and volMA > 0
float dirVol = hasVol ? math.sum((close > open ? volume : -volume), 20) / (volMA * 20) : 0.0
float volFit = hasVol ? math.min(math.max(dir == 1 ? dirVol : -dirVol, 0.0), 1.0) : 0.0
float score  = useVol and hasVol ? (0.4 * sep + 0.35 * nz(effS) * 1.5 + 0.25 * volFit) : (0.55 * sep + 0.45 * nz(effS) * 1.5)
score := math.min(math.max(score, 0.0), 1.0)
float scoreS = ta.ema(score, 3)

string strengthTxt = scoreS >= 0.6 ? "Strong" : scoreS >= 0.32 ? "Steady" : "Weakening"
// Weak trends fade the trend colour rather than switching to a neutral colour, so the ribbon never
// grows a bright grey band that outshines the trend itself.
color  strengthCol = scoreS >= 0.6 ? trendCol : scoreS >= 0.32 ? color.new(trendCol, 25) : color.new(trendCol, 50)
// Move quality at a fresh cross (separation is always tiny there, so strength would always read low)
string qualityTxt  = nz(effS) >= 0.4 ? "Clean move" : nz(effS) >= 0.2 ? "Average move" : "Choppy move"

// ═══════════════════════════════ State ═══════════════════════════════
var int    trendStart   = 0
var float  flipClose    = na
var int    lastLabelDir = 0
var bool   inPullback   = false
var int    lastPull     = -100000
var string lastEvent    = "None yet"
var int    lastEventBar = na
var line   originLn     = na
bool startUp = false, bool startDn = false, bool pullUp = false, bool pullDn = false
bool flashBar = false

float ribTop = math.max(fastMA, slowMA)
float ribBtm = math.min(fastMA, slowMA)

// Trend age is tracked at global scope so the live bar and the panel always agree with the ribbon.
if flipped
    trendStart := bar_index
    flipClose  := close
int age = bar_index - trendStart

// ═══════════════════════════════ Drawing: candles, aura, ribbon, glow ═══════════════════════════════
// Candles: trend colour, intensity from strength. Counter-trend candles are only slightly muted so they stay readable.
color barCol  = color.from_gradient(scoreS, 0.0, 0.8, colFlat, trendCol)
color candleC = (dir == 1 ? close >= open : close <= open) ? barCol : color.from_gradient(0.35, 0.0, 1.0, barCol, colFlat)
barcolor(showCandles ? candleC : na, title = "Strength candles")

// Strength aura: a band outside the ribbon. Width has a floor so it reads even on steady trends, then grows with strength.
float auraOff  = (0.3 + 0.7 * scoreS) * atr * 0.8
float auraEdge = dir == 1 ? fastMA + auraOff : fastMA - auraOff
pAura = plot(showRibbon and showAura ? auraEdge : na, "Aura edge", color = na, display = display.none)
pFast = plot(showRibbon ? fastMA : na, "Fast", color = color.new(strengthCol, 0), linewidth = 1)
pSlow = plot(showRibbon ? slowMA : na, "Slow", color = color.new(strengthCol, 40), linewidth = 1)

fill(pAura, pFast,
     top_value    = math.max(auraEdge, fastMA),
     bottom_value = math.min(auraEdge, fastMA),
     top_color    = showRibbon and showAura ? (dir == 1 ? color.new(trendCol, 98) : color.new(trendCol, 68)) : na,
     bottom_color = showRibbon and showAura ? (dir == 1 ? color.new(trendCol, 68) : color.new(trendCol, 98)) : na,
     title = "Strength aura")

// Ribbon body: dense at the fast edge, fading toward the slow edge. Brightens while a pullback is in progress.
int ribA = inPullback ? 30 : 52
fill(pFast, pSlow,
     top_value    = ribTop,
     bottom_value = ribBtm,
     top_color    = showRibbon ? (dir == 1 ? color.new(strengthCol, ribA) : color.new(strengthCol, 86)) : na,
     bottom_color = showRibbon ? (dir == 1 ? color.new(strengthCol, 86) : color.new(strengthCol, ribA)) : na,
     title = "Ribbon")

// Neon glow: stacked wide, translucent copies of the fast line. Transparency tracks strength.
int glowA = int(94 - scoreS * 16)
plot(showRibbon and showGlow ? fastMA : na, "Glow outer", color = color.new(trendCol, glowA),     linewidth = 7)
plot(showRibbon and showGlow ? fastMA : na, "Glow mid",   color = color.new(trendCol, glowA - 8), linewidth = 4)
plot(showRibbon and showGlow ? fastMA : na, "Glow core",  color = color.new(trendCol, 20),        linewidth = 2)

// ═══════════════════════════════ Events ═══════════════════════════════
if barstate.isconfirmed and not na(atr)
    if flipped
        inPullback := false

    // Trend start: fires on the first bar where the flip has survived at least confirmBars bars with price on the
    // right side of the ribbon. Direction must alternate with the previous start signal, so flip-flops never
    // produce two same-way labels.
    // In chop the trend is still registered (so pullback logic knows the direction) but nothing prints.
    if age >= confirmBars and dir != lastLabelDir and (dir == 1 ? close > ribTop : close < ribBtm)
        lastLabelDir := dir
        flashBar     := not choppy
        if showOrigin and not choppy
            if not na(originLn)
                originLn.set_x2(bar_index)
                originLn.set_extend(extend.none)
            originLn := line.new(trendStart, flipClose, bar_index, flipClose, extend = extend.right, color = color.new(trendCol, 15), style = line.style_dashed, width = 1)
        if showStart and not choppy
            label.new(bar_index, dir == 1 ? low - atr * labelOff : high + atr * labelOff, dir == 1 ? "▲ UPTREND" : "▼ DOWNTREND", style = dir == 1 ? label.style_label_up : label.style_label_down, color = trendCol, textcolor = ink, size = size.normal, tooltip = (dir == 1 ? "New uptrend" : "New downtrend") + ": the fast average crossed the slow one and price has held on that side for " + str.tostring(confirmBars) + " bars.\n" + qualityTxt)
            lastEvent := dir == 1 ? "Trend ▲" : "Trend ▼", lastEventBar := bar_index
            if dir == 1
                startUp := true
            else
                startDn := true
            alert((dir == 1 ? "New uptrend" : "New downtrend") + ", " + str.lower(qualityTxt), alert.freq_once_per_bar_close)

    // Pullback: price dips into the ribbon during a trend, then closes back out with the trend
    if not flipped and age >= minAge and lastLabelDir == dir
        float depthPx   = (ribTop - ribBtm) * pullDepth / 100.0
        bool intoRibbon = dir == 1 ? low <= ribTop - depthPx : high >= ribBtm + depthPx
        bool backOut    = dir == 1 ? close > ribTop : close < ribBtm
        bool withTrend  = dir == 1 ? close > open : close < open
        if intoRibbon and not backOut
            inPullback := true
        else if inPullback and backOut
            inPullback := false
            if showPullback and not choppy and withTrend and bar_index - lastPull >= pullGap and scoreS >= 0.32
                label.new(bar_index, dir == 1 ? low - atr * pullOff : high + atr * pullOff, "", style = label.style_diamond, color = color.new(trendCol, 10), size = size.normal, tooltip = "Pullback finished: price dipped into the ribbon and closed back out with the trend.\nTrend strength: " + strengthTxt)
                lastPull := bar_index
                lastEvent := dir == 1 ? "Pullback ▲" : "Pullback ▼", lastEventBar := bar_index
                if dir == 1
                    pullUp := true
                else
                    pullDn := true
                alert("Pullback finished in a " + (dir == 1 ? "up" : "down") + "trend, strength " + strengthTxt, alert.freq_once_per_bar_close)

// Trend start flash (on the confirmation bar, not on every raw flip)
bgcolor(showFlash and flashBar ? color.new(trendCol, 68) : na, title = "Trend start flash")

// ═══════════════════════════════ Panel ═══════════════════════════════
color pBg  = color.new(ink, 8)
color pDim = color.new(mute, 0)
color pTxt = color.new(#E5E7EB, 0)
pPos = switch panelPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table pnl = table.new(pPos, 2, 6, bgcolor = pBg, border_width = 2, border_color = color.new(ink, 0), frame_width = 1, frame_color = color.new(#2A3040, 0))
if barstate.islast and showPanel
    // On the live bar, read last closed bar so the panel never flickers ahead of the ribbon
    bool   live    = not barstate.isconfirmed
    int    pDir    = live ? dir[1] : dir
    int    pAge    = live ? age[1] : age
    float  pScore  = live ? scoreS[1] : scoreS
    color  pTrend  = pDir == 1 ? colUp : colDn
    string pStrTxt = pScore >= 0.6 ? "Strong" : pScore >= 0.32 ? "Steady" : "Weakening"
    color  pStrCol = pScore >= 0.6 ? pTrend : pScore >= 0.32 ? color.new(pTrend, 25) : mute
    string meter = ""
    for i = 1 to 5
        meter := meter + (pScore >= i / 5.0 - 0.1 ? "▰" : "▱")
    bool   unconfirmed = lastLabelDir != pDir
    bool   pChoppy     = live ? choppy[1] : choppy
    string status = pChoppy ? "Chop, signals paused" : unconfirmed ? "Confirming..." : inPullback ? "Pulling back" : pScore >= 0.6 ? "Trending clean" : pScore >= 0.32 ? "Trending" : "Losing steam"

    pnl.cell(0, 0, (pDir == 1 ? "▲  " : "▼  ") + "TREND MASTER", text_color = ink, text_size = size.normal, text_halign = text.align_left, bgcolor = pTrend)
    pnl.merge_cells(0, 0, 1, 0)
    pnl.cell(0, 1, "Trend",       text_color = pDim, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 1, pDir == 1 ? "Up" : "Down", text_color = pTrend, text_size = size.normal, text_halign = text.align_right)
    pnl.cell(0, 2, "Strength",    text_color = pDim, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 2, meter + "  " + pStrTxt, text_color = pStrCol, text_size = size.normal, text_halign = text.align_right, tooltip = "Blend of how far apart the two averages are, how cleanly price is moving, and (where volume data exists) whether volume supports the direction.")
    pnl.cell(0, 3, "Status",      text_color = pDim, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 3, status,        text_color = pChoppy ? mute : unconfirmed or inPullback ? pTxt : pStrCol, text_size = size.normal, text_halign = text.align_right)
    pnl.cell(0, 4, "Running for", text_color = pDim, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 4, str.tostring(pAge) + " bars", text_color = pTxt, text_size = size.normal, text_halign = text.align_right)
    pnl.cell(0, 5, "Last event",  text_color = pDim, text_size = size.small, text_halign = text.align_left)
    pnl.cell(1, 5, na(lastEventBar) ? lastEvent : lastEvent + ", " + str.tostring((live ? bar_index - 1 : bar_index) - lastEventBar) + " bars ago", text_color = pTxt, text_size = size.normal, text_halign = text.align_right)

// ═══════════════════════════════ Alerts ═══════════════════════════════
alertcondition(startUp, "New uptrend",          "Trend Master: new uptrend")
alertcondition(startDn, "New downtrend",        "Trend Master: new downtrend")
alertcondition(pullUp,  "Pullback in uptrend",   "Trend Master: pullback finished in an uptrend")
alertcondition(pullDn,  "Pullback in downtrend", "Trend Master: pullback finished in a downtrend")
````
