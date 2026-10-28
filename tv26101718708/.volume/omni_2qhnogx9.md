# Omni

- url: https://www.tradingview.com/script/2qHnogX9-Omni/
- type: indicator
- pine_id: PUB;63331c5b6a08443585e313072b3a6182
- version: 1.0

## Description

OMNI — All-in-One Price Action Toolkit
Omni combines six of the most-used intraday tools into a single indicator, so you don't need to stack five separate scripts to build a full picture of the market.
🔹 Hank Dot — Non-Repainting Swing Detection
Marks confirmed swing tops and bottoms with a dot, filtered by minimum swing size (ATR-based) so only meaningful turns get flagged. Fully non-repainting — a dot never moves or disappears once it prints, and it only appears after the turn is confirmed.
🔹 Fair Value Gaps (FVG) + Inverse FVG
Detects 3-candle imbalances on a higher timeframe of your choice and plots them as support/resistance zones directly on your chart. Broken zones can automatically flip color and role (support → resistance, or vice versa) when price closes through them.
🔹 VWAP with Standard Deviation Bands
Session VWAP with two configurable, shaded standard-deviation bands — useful for reading trend-day continuation zones vs. range-day extremes.
🔹 Multi-Timeframe EMAs
Three independently configurable EMAs, each with its own length and timeframe. Optional smoothing turns higher-timeframe EMAs into a gliding line instead of a stepped one.
🔹 Session & Liquidity Levels
Automatically plots Previous Day/Week High-Low, Pre-Market, Asian session, London session, and Opening Range Breakout (ORB) levels — with labels — so key liquidity zones are always visible.
🔹 Bias Table
A 6-factor dashboard (EMA trend, higher-timeframe trend, VWAP position, momentum, market structure, and prior-day position) that tallies into one bullish/bearish score at a glance.
Every input includes an in-depth tooltip explaining what it does and how it's typically used, so it's approachable whether you're new to these concepts or already familiar with them.
⚠️ This is an analysis tool, not financial advice. It is designed to help visualize price structure, liquidity, and confluence — always combine it with your own risk management and trade plan.

## Source Code

````pine
//@version=6
// ============================================================================
// OMNI — all-in-one price-action toolkit
//   • Hank Dot: significant, non-repainting swing tops/bottoms
//   • Multi-timeframe FVG + IFVG (detected on a higher TF, drawn on your chart)
//   • EMA 1/2/3 with per-EMA timeframe + HTF smoothing
//   • VWAP with 1σ/2σ volume-weighted bands
//   • Liquidity levels with sizable labels
//   • Bias Table: 6-factor bullish/bearish consensus
//   NOTE: Analysis tool, not financial advice.
// ============================================================================

indicator("Omni", overlay = true, max_labels_count = 500, max_boxes_count = 500)

// ============================================================================
// 1. SETTINGS & INPUTS
// ============================================================================

// --- SWING REVERSAL HANK DOT ---
grp_sw = "═══ HANK DOT ═══"
showDots = input.bool(true, "Show Hank Dot", group=grp_sw,
  tooltip="Draws a white dot on confirmed swing tops and bottoms — the points where price turned direction. NON-REPAINTING: the dot only appears 'Confirmation (Right Bars)' bars after the turn actually happened, once it's had time to be confirmed as real. It will never disappear or move once drawn.\n\nHOW TO USE: a dot on its own isn't a signal. Look for a dot forming at the same place as another tool on this chart — a support/resistance line, a colored FVG zone, or VWAP — that overlap is what makes it worth paying attention to.")
swLeft = input.int(15, "Swing Strength (Left Bars)", minval=1, group=grp_sw,
  tooltip="Controls how big a price swing has to be before it counts as a real top or bottom. A higher number means the indicator compares the turn to more bars on the left, so only larger, more significant swings get marked. Raise it for fewer/bigger signals, lower it for more/smaller ones.")
swRight = input.int(5, "Confirmation (Right Bars)", minval=1, group=grp_sw,
  tooltip="How many bars the indicator waits before confirming a top or bottom and drawing the dot. This is a trade-off: a lower number confirms faster but is more likely to be wrong; a higher number waits longer but is more reliable. Think of it as the delay between the actual turn and when you're told about it.")
swDev = input.float(2.0, "Min Swing Size (× ATR)", minval=0.0, group=grp_sw,
  tooltip="A filter that ignores small, insignificant wiggles. ATR (Average True Range) measures how much a symbol typically moves — this setting requires a swing to travel at least this many multiples of that typical move before it's allowed to be marked. Higher = fewer, more meaningful signals.")

// --- FAIR VALUE GAPS (multi-timeframe) ---
grp_fvg = "═══ FAIR VALUE GAPS ═══"
showFvg   = input.bool(true, "Show FVG", group=grp_fvg,
  tooltip="A Fair Value Gap (FVG) is a 3-candle pattern that shows an imbalance — a spot where price moved so fast it left a gap with no trading in between. These are plotted as colored zones. Teal zones sit below price and can act as support; maroon zones sit above price and can act as resistance.\n\nHOW TO USE: many traders watch for price to return to one of these zones and react (bounce or reject) at it, especially the first time it's touched — a zone that's already been retested once is considered weaker.")
fvgTf     = input.timeframe("3", "FVG Timeframe", group=grp_fvg,
  tooltip="The timeframe used to FIND the gaps, even though they're drawn on whatever chart you're currently viewing. A lower timeframe (like 3 or 5 minutes) finds more gaps, more often — useful for short-term trades. A higher timeframe (like 15, 30, or 60 minutes) finds fewer gaps that tend to be more significant and longer-lasting. Set it equal to your chart's timeframe to see only the plain, un-combined gaps.")
useIfvg   = input.bool(true, "Flip Broken Gaps (IFVG)", group=grp_fvg,
  tooltip="Normally a gap keeps its role (support or resistance) forever. With this on, if price fully closes through a gap, the indicator treats that as the gap 'failing' and flips its role and color — a broken support zone becomes a new resistance zone, and vice versa.\n\nHOW TO USE: a flip is useful information on its own — it shows a level that used to hold has now failed, which often means the trend has changed.")
fvgMinAtr = input.float(0.25, "Min Gap Size (× ATR)", minval=0.0, group=grp_fvg,
  tooltip="A filter that hides gaps that are too small to matter. It compares the gap's size to the typical (ATR) range of a candle on the FVG Timeframe you selected above, so this stays consistent even if you change your chart's timeframe. Raise this number to see fewer, larger gaps only.")
fvgRemove = input.bool(true, "Hide Filled Gaps", group=grp_fvg,
  tooltip="Once price fully trades back through a gap (filling it in completely), this setting removes it from the chart automatically, since a filled gap has already done what it was going to do and is no longer useful information.")
colBull = input.color(color.new(color.teal,   82), "Bullish",  group=grp_fvg, inline="fc")
colBear = input.color(color.new(color.maroon, 82), "Bearish", group=grp_fvg, inline="fc")

// --- BIAS TABLE ---
grp_bias = "═══ BIAS TABLE ═══"
showBias = input.bool(true, "Show Bias Table", group=grp_bias,
  tooltip="A small table showing 6 independent factors (trend, momentum, structure, and so on), each voting bullish or bearish, plus one combined score at the bottom.\n\nHOW TO USE: this is meant as a quick-glance filter for which direction has the most evidence behind it right now — not a buy/sell signal by itself. Many traders only look for trade setups in the direction most of the rows already agree on.")
biasPos  = input.string("Top Right", "Position",
  options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=grp_bias)
biasSize = input.string("Normal", "Table Size",
  options=["Tiny","Small","Normal","Large"], group=grp_bias)
htfTf    = input.timeframe("60", "HTF Trend Timeframe", group=grp_bias,
  tooltip="A higher timeframe used only for the 'HTF Trend' row, to give a sense of the bigger-picture trend behind your current chart. A common approach is picking something noticeably higher than your chart's own timeframe (for example, 60 minutes if you're trading on a 1 or 5 minute chart).")

// --- LIQUIDITY LEVELS ---
grp_lvl = "═══ LIQUIDITY LEVELS ═══"
showP    = input.bool(true, "Show Prev Day High/Low", group=grp_lvl,
  tooltip="Draws the previous trading day's high and low as horizontal lines. These are commonly watched levels — price often reacts (bounces or breaks through with momentum) when it reaches them.")
showW    = input.bool(true, "Show Prev Week High/Low", group=grp_lvl,
  tooltip="Draws the previous week's high and low. These are larger, longer-term levels that get tested less often than the daily levels, but can matter more when price does reach them.")
showPrem = input.bool(true, "Show Pre-Market High/Low", group=grp_lvl,
  tooltip="Draws the high and low set during the pre-market session (04:00–09:30 ET, before the regular session opens). These levels are frequently tested in the first part of the regular trading day.")
showAsia = input.bool(true, "Show Asian Session High/Low", group=grp_lvl,
  tooltip="Draws the high and low set during the Asian trading session (18:00–02:00 ET). This shows where overnight trading found its edges, which can act as levels later in the day.")
showLon  = input.bool(true, "Show London Session High/Low", group=grp_lvl,
  tooltip="Draws the high and low set during the London trading session (03:00–11:30 ET). This session often sets the range that gets tested once the U.S. session opens.")
showOrb  = input.bool(true, "Show ORB High/Low", group=grp_lvl,
  tooltip="ORB stands for Opening Range Breakout — the high and low of the first few minutes after the market opens (09:30 ET), controlled by the 'ORB Duration' setting below.\n\nHOW TO USE: many traders watch for price to break clearly above or below this range as an early signal for the direction of the day.")
orbMins  = input.int(30, "ORB Duration (Minutes)", group=grp_lvl,
  tooltip="How many minutes after the open are used to build the Opening Range. A shorter window (like 5 or 15 minutes) reacts faster but is noisier; a longer window (like 30 or 60 minutes) is slower but more stable.")
showLabs = input.bool(true, "Show Level Labels", group=grp_lvl, tooltip="Adds small text tags (like 'PDH' or 'ORB L') next to each level line so you can tell them apart at a glance.")
labSize  = input.string("Normal", "Label Size",
  options=["Tiny","Small","Normal","Large","Huge"], group=grp_lvl, tooltip="Controls how large the level labels appear on the chart.")

// --- INDICATORS ---
grp_ind = "═══ INDICATORS ═══"
showVwap  = input.bool(true, "Show VWAP", group=grp_ind,
  tooltip="VWAP (Volume Weighted Average Price) is the average price paid for the symbol so far in the session, weighted by how much volume traded at each price. It resets at the start of each new session.\n\nHOW TO USE: price above VWAP is generally read as buyers being in control for the day so far; price below VWAP is read as sellers being in control. It's one of the most widely watched intraday reference lines.")
vwapSrc   = input.source(hlc3, "VWAP Source", group=grp_ind,
  tooltip="Which price is used to calculate VWAP. The default, hlc3 (the average of the high, low, and close of each candle), is the standard choice and matches what most charting platforms use — only change this if you have a specific reason to.")
showBands = input.bool(true, "Show VWAP σ Bands", group=grp_ind,
  tooltip="Adds bands above and below VWAP based on how much price has typically varied from it (standard deviation, marked with the σ symbol) during the session — similar in spirit to Bollinger Bands, but anchored to VWAP instead of a moving average.\n\nHOW TO USE: the inner band is a smaller, more common move away from VWAP; the outer band represents a larger, less common move. Some traders treat a touch of the outer band as 'stretched' and worth watching for a pullback, while others treat sustained trading beyond it as a sign of unusually strong momentum. Both readings are common — pick whichever fits how you already trade.")
sd1Mult   = input.float(1.0, "Band 1 (σ)", step=0.25, minval=0.25, group=grp_ind,
  tooltip="How many standard deviations away from VWAP the inner band is drawn. 1.0 is the standard, commonly used setting.")
sd2Mult   = input.float(2.0, "Band 2 (σ)", step=0.25, minval=0.25, group=grp_ind,
  tooltip="How many standard deviations away from VWAP the outer band is drawn. 2.0 is the standard, commonly used setting, representing a larger and less frequent move away from the average.")
emaSmooth = input.bool(true, "Smooth Higher-TF EMAs", group=grp_ind,
  tooltip="An EMA (Exponential Moving Average) set to a timeframe higher than your chart normally updates in visible 'steps' rather than a smooth line, because it's only recalculating once per higher-timeframe candle. Turning this on approximates that same EMA using your chart's own timeframe so it draws as a smooth, gliding line instead. Turn it off if you'd rather see the exact, literal higher-timeframe value.")
grp_e1 = "─── EMA 1 ───"
showEma1 = input.bool(true, "Show EMA 1", group=grp_e1, tooltip="A short-length EMA, often used to gauge very recent, short-term momentum. A common default length is 9.")
emaF_len = input.int(9,  "Length",    group=grp_e1)
emaF_tf  = input.timeframe("5", "Timeframe", group=grp_e1, tooltip="The timeframe this EMA is calculated on. Leave blank to use your chart's own timeframe.")
grp_e2 = "─── EMA 2 ───"
showEma2 = input.bool(true, "Show EMA 2", group=grp_e2, tooltip="A medium-length EMA, often used alongside EMA 1 to judge short-term trend direction — for example, EMA 1 above EMA 2 is commonly read as an uptrend. A common default length is 20.")
emaS_len = input.int(20, "Length",    group=grp_e2)
emaS_tf  = input.timeframe("5", "Timeframe", group=grp_e2, tooltip="The timeframe this EMA is calculated on. Leave blank to use your chart's own timeframe.")
grp_e3 = "─── EMA 3 ───"
showEma3 = input.bool(true, "Show EMA 3", group=grp_e3, tooltip="A longer-length EMA, used as a bigger-picture trend reference in the background. Common default lengths are 50 or 200 — the higher the number, the slower and smoother the line, and the longer-term the trend it reflects.")
emaT_len = input.int(200, "Length",   group=grp_e3)
emaT_tf  = input.timeframe("5", "Timeframe", group=grp_e3, tooltip="The timeframe this EMA is calculated on. Leave blank to use your chart's own timeframe.")

// ============================================================================
// 2. DATA ENGINE
// ============================================================================
get_data(src, tf) => request.security(syminfo.tickerid, tf, src[1], lookahead = barmerge.lookahead_on)

pdh = get_data(high, "D"), pdl = get_data(low, "D"), pdc = get_data(close, "D")
pwh = get_data(high, "W"), pwl = get_data(low, "W")

var float asiaH = na, var float asiaL = na
var float lonH  = na, var float lonL  = na
var float pmH   = na, var float pmL   = na
newDay = ta.change(time("D")) != 0
if not na(time("1440", "1800-0200"))
    asiaH := math.max(nz(asiaH, high), high), asiaL := math.min(nz(asiaL, low), low)
if not na(time("1440", "0300-1130"))
    lonH  := math.max(nz(lonH,  high), high), lonL  := math.min(nz(lonL,  low), low)
if not na(time("1440", "0400-0930"))
    pmH   := math.max(nz(pmH,   high), high), pmL   := math.min(nz(pmL,   low), low)
if newDay
    asiaH := na, asiaL := na, lonH := na, lonL := na, pmH := na, pmL := na

var float orbH = na, var float orbL = na
sessMin = (hour(time, "America/New_York") * 60) + minute(time, "America/New_York")
start = 9*60 + 30, end = start + orbMins
if newDay
    orbH := na, orbL := na
if sessMin >= start and sessMin < end
    orbH := math.max(nz(orbH, high), high), orbL := math.min(nz(orbL, low), low)

// Smoothed multi-TF EMA: scaled-length on chart TF when higher TF + smoothing
f_ema(len, tf, smooth) =>
    cs = timeframe.in_seconds()
    ts = tf == "" ? cs : timeframe.in_seconds(tf)
    mult = math.max(1, math.round(ts / cs))
    sec = request.security(syminfo.tickerid, tf, ta.ema(close, len))
    scaled = ta.ema(close, math.min(int(len * mult), 4990))
    (smooth and tf != "") ? scaled : sec

e1 = f_ema(emaF_len, emaF_tf, emaSmooth)
e2 = f_ema(emaS_len, emaS_tf, emaSmooth)
e3 = f_ema(emaT_len, emaT_tf, emaSmooth)

// VWAP + volume-weighted σ bands (built-in tuple form, session anchored)
[vwapV,  vwU1, vwL1] = ta.vwap(vwapSrc, newDay, sd1Mult)
[vwapM2, vwU2, vwL2] = ta.vwap(vwapSrc, newDay, sd2Mult)

atrVal = ta.atr(14)
rsiVal = ta.rsi(close, 14)
htfEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, 50))

// ============================================================================
// 3. SWING REVERSAL ENGINE
// ============================================================================
ph = ta.pivothigh(high, swLeft, swRight)
pl = ta.pivotlow(low,  swLeft, swRight)

var float lastTopP = na, var float prevTopP = na
var float lastBotP = na, var float prevBotP = na
var int   lastSwing = 0
bool confTop = false
bool confBot = false
minMove = swDev * atrVal

if not na(ph)
    p = high[swRight]
    if lastSwing != 1 and (na(lastBotP) or (p - lastBotP) >= minMove)
        prevTopP := lastTopP
        lastTopP := p
        confTop  := true
        lastSwing := 1
    else if lastSwing == 1 and p > nz(lastTopP, p)
        lastTopP := p
if not na(pl)
    p = low[swRight]
    if lastSwing != -1 and (na(lastTopP) or (lastTopP - p) >= minMove)
        prevBotP := lastBotP
        lastBotP := p
        confBot  := true
        lastSwing := -1
    else if lastSwing == -1 and p < nz(lastBotP, p)
        lastBotP := p

// ============================================================================
// 4. FAIR VALUE GAP ENGINE (multi-timeframe)
// ============================================================================
var array<box> fBox   = array.new<box>()
var array<int> fState = array.new<int>()   // 1 bull, -1 bear, 2 ifvg-bull, -2 ifvg-bear
EXT = 5, MAXB = 20

// Confirmed HTF candles: [1] + lookahead_on = last CLOSED higher-TF bar,
// delivered on the first chart bar of the new HTF period. Identical on
// historical and realtime bars (no repaint, no leak). HTF ATR fetched in the
// same call so the gap-size filter scales with the FVG timeframe itself.
[htfH, htfL, htfT, htfAtr] = request.security(syminfo.tickerid, fvgTf, [high[1], low[1], time[1], ta.atr(14)[1]], lookahead = barmerge.lookahead_on)
newHtf = ta.change(htfT) != 0

var float gh1 = na, var float gh2 = na, var float gh3 = na
var float gl1 = na, var float gl2 = na, var float gl3 = na
var int   gx1 = na, var int   gx2 = na, var int   gx3 = na

if showFvg and newHtf and not na(htfH)
    gh1:=gh2, gh2:=gh3, gh3:=htfH
    gl1:=gl2, gl2:=gl3, gl3:=htfL
    gx1:=gx2, gx2:=gx3, gx3:=bar_index
    if not na(gh1)
        if gl3 > gh1                       // bullish FVG: c3 low above c1 high
            topp = gl3, botp = gh1
            if topp - botp >= fvgMinAtr * htfAtr
                array.push(fBox, box.new(nz(gx1, bar_index), topp, bar_index+EXT, botp, border_color=na, bgcolor=colBull))
                array.push(fState, 1)
        else if gh3 < gl1                  // bearish FVG: c3 high below c1 low
            topp = gl1, botp = gh3
            if topp - botp >= fvgMinAtr * htfAtr
                array.push(fBox, box.new(nz(gx1, bar_index), topp, bar_index+EXT, botp, border_color=na, bgcolor=colBear))
                array.push(fState, -1)

if showFvg
    while array.size(fBox) > MAXB
        box.delete(array.shift(fBox))
        array.shift(fState)
    if array.size(fBox) > 0
        for i = array.size(fBox) - 1 to 0
            bx = array.get(fBox, i), st = array.get(fState, i)
            t = box.get_top(bx), bo = box.get_bottom(bx)
            keep = true
            if st == 1
                if useIfvg and close < bo
                    box.set_bgcolor(bx, colBear), array.set(fState, i, -2)
                else if fvgRemove and low <= bo
                    box.delete(bx), keep := false
            else if st == -1
                if useIfvg and close > t
                    box.set_bgcolor(bx, colBull), array.set(fState, i, 2)
                else if fvgRemove and high >= t
                    box.delete(bx), keep := false
            else if st == 2
                if close < bo
                    box.delete(bx), keep := false
            else if st == -2
                if close > t
                    box.delete(bx), keep := false
            if keep
                box.set_right(bx, bar_index + EXT)
            else
                array.remove(fBox, i), array.remove(fState, i)

// ============================================================================
// 5. VISUALIZATION
// ============================================================================
plot_clean(val) => newDay ? na : val

plot(showP    ? plot_clean(pdh)  : na, "Prev Day High",  color.new(color.blue,   50), style=plot.style_linebr)
plot(showP    ? plot_clean(pdl)  : na, "Prev Day Low",   color.new(color.blue,   50), style=plot.style_linebr)
plot(showW    ? plot_clean(pwh)  : na, "Prev Week High", color.new(color.purple, 30), 2, style=plot.style_linebr)
plot(showW    ? plot_clean(pwl)  : na, "Prev Week Low",  color.new(color.purple, 30), 2, style=plot.style_linebr)
plot(showAsia ? plot_clean(asiaH): na, "Asia High",      color.new(color.yellow, 60), style=plot.style_linebr)
plot(showAsia ? plot_clean(asiaL): na, "Asia Low",       color.new(color.yellow, 60), style=plot.style_linebr)
plot(showLon  ? plot_clean(lonH) : na, "London High",    color.new(color.orange, 60), style=plot.style_linebr)
plot(showLon  ? plot_clean(lonL) : na, "London Low",     color.new(color.orange, 60), style=plot.style_linebr)
plot(showPrem ? plot_clean(pmH)  : na, "PM High",        color.new(color.gray,   50), style=plot.style_linebr)
plot(showPrem ? plot_clean(pmL)  : na, "PM Low",         color.new(color.gray,   50), style=plot.style_linebr)
plot(showOrb and sessMin >= end ? orbH : na, "ORB High",  color.green, style=plot.style_linebr)
plot(showOrb and sessMin >= end ? orbL : na, "ORB Low",   color.red,   style=plot.style_linebr)

plot(showEma1 ? e1 : na, "EMA 1", color.new(color.yellow,  0))
plot(showEma2 ? e2 : na, "EMA 2", color.new(color.blue,    0))
plot(showEma3 ? e3 : na, "EMA 3", color.new(color.fuchsia, 0))

plot(showVwap ? vwapV : na, "VWAP", color.new(color.white, 30))

// Bands drawn as shaded fills (like the built-in VWAP indicator): band 1 is
// filled first, then band 2 is filled on top. Band 2's fill spans wider than
// band 1's, so the region INSIDE band 1 gets two overlapping 92%-transparent
// layers (darker), while the region between band 1 and band 2 gets only one
// (lighter) — that's what produces the gradient halo effect.
vwB1U = plot(showVwap and showBands ? vwU1 : na, "VWAP +1σ", color.new(color.teal, 55), display=display.none)
vwB1L = plot(showVwap and showBands ? vwL1 : na, "VWAP -1σ", color.new(color.teal, 55), display=display.none)
fill(vwB1U, vwB1L, title="VWAP 1σ Fill", color=color.new(color.teal, 92))
vwB2U = plot(showVwap and showBands ? vwU2 : na, "VWAP +2σ", color.new(color.teal, 70), display=display.none)
vwB2L = plot(showVwap and showBands ? vwL2 : na, "VWAP -2σ", color.new(color.teal, 70), display=display.none)
fill(vwB2U, vwB2L, title="VWAP 2σ Fill", color=color.new(color.teal, 92))

plotshape(showDots and confTop, "Swing Top",    shape.circle, location.abovebar, color.white, size=size.tiny, offset=-swRight)
plotshape(showDots and confBot, "Swing Bottom", shape.circle, location.belowbar, color.white, size=size.tiny, offset=-swRight)
alertcondition(confTop, "Swing Top",    "Omni: Swing top confirmed")
alertcondition(confBot, "Swing Bottom", "Omni: Swing bottom confirmed")

f_lsize(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

var label lbl_pdh = na, var label lbl_pdl = na
var label lbl_pwh = na, var label lbl_pwl = na
var label lbl_pmh = na, var label lbl_pml = na
var label lbl_ash = na, var label lbl_asl = na
var label lbl_loh = na, var label lbl_lol = na
var label lbl_orh = na, var label lbl_orl = na
mk(val, txt, col) =>
    not na(val) ? label.new(bar_index, val, txt, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, col, size=f_lsize(labSize)) : na
// Labels live ONLY on the last bar: the full set is deleted and recreated
// there each update, so exactly one set ever exists — no trail, no reprint.
if showLabs and barstate.islast
    label.delete(lbl_pdh), label.delete(lbl_pdl), label.delete(lbl_pwh), label.delete(lbl_pwl)
    label.delete(lbl_pmh), label.delete(lbl_pml), label.delete(lbl_ash), label.delete(lbl_asl)
    label.delete(lbl_loh), label.delete(lbl_lol), label.delete(lbl_orh), label.delete(lbl_orl)
    lbl_pdh := showP    ? mk(pdh,   "PDH",    color.blue)   : na
    lbl_pdl := showP    ? mk(pdl,   "PDL",    color.blue)   : na
    lbl_pwh := showW    ? mk(pwh,   "PWH",    color.purple) : na
    lbl_pwl := showW    ? mk(pwl,   "PWL",    color.purple) : na
    lbl_pmh := showPrem ? mk(pmH,   "PMH",    color.gray)   : na
    lbl_pml := showPrem ? mk(pmL,   "PML",    color.gray)   : na
    lbl_ash := showAsia ? mk(asiaH, "Asia H", color.yellow) : na
    lbl_asl := showAsia ? mk(asiaL, "Asia L", color.yellow) : na
    lbl_loh := showLon  ? mk(lonH,  "Lon H",  color.orange) : na
    lbl_lol := showLon  ? mk(lonL,  "Lon L",  color.orange) : na
    lbl_orh := showOrb  ? mk(orbH,  "ORB H",  color.green)  : na
    lbl_orl := showOrb  ? mk(orbL,  "ORB L",  color.red)    : na

// ============================================================================
// 6. BIAS TABLE
// ============================================================================
emaBull = e1 > e2,                          emaBear = e1 < e2
htfBull = close > htfEma,                   htfBear = close < htfEma
vwapBull = not na(vwapV) and close > vwapV, vwapBear = not na(vwapV) and close < vwapV
rsiBull = rsiVal > 50,                      rsiBear = rsiVal < 50
structBull = not na(prevTopP) and not na(prevBotP) and lastTopP > prevTopP and lastBotP > prevBotP
structBear = not na(prevTopP) and not na(prevBotP) and lastTopP < prevTopP and lastBotP < prevBotP
pdBull = close > pdc,                        pdBear = close < pdc

bulls = (emaBull?1:0)+(htfBull?1:0)+(vwapBull?1:0)+(rsiBull?1:0)+(structBull?1:0)+(pdBull?1:0)
bears = (emaBear?1:0)+(htfBear?1:0)+(vwapBear?1:0)+(rsiBear?1:0)+(structBear?1:0)+(pdBear?1:0)
net   = bulls - bears

biasPosV = biasPos == "Top Left" ? position.top_left : biasPos == "Bottom Right" ? position.bottom_right : biasPos == "Bottom Left" ? position.bottom_left : biasPos == "Middle Right" ? position.middle_right : position.top_right
biasSzV  = biasSize == "Tiny" ? size.tiny : biasSize == "Normal" ? size.normal : biasSize == "Large" ? size.large : size.small

var table bt = table.new(biasPosV, 2, 8, bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 60), border_width=1)
f_row(rowIdx, name, isBull, isBear, valTxt) =>
    cB = color.new(color.lime, 0), cR = color.new(color.red, 0), cN = color.new(color.gray, 0)
    table.cell(bt, 0, rowIdx, name, text_color=color.new(color.white,0), text_size=biasSzV)
    table.cell(bt, 1, rowIdx, valTxt, text_color=isBull?cB:isBear?cR:cN, text_size=biasSzV)
if showBias and barstate.islast
    table.cell(bt, 0, 0, "OMNI BIAS", text_color=color.white, text_size=biasSzV, bgcolor=color.new(color.blue, 35))
    table.cell(bt, 1, 0, str.tostring(bulls) + "▲ " + str.tostring(bears) + "▼", text_color=color.white, text_size=biasSzV, bgcolor=color.new(color.blue, 35))
    f_row(1, "EMA Trend", emaBull, emaBear, emaBull?"▲ Bull":emaBear?"▼ Bear":"– Flat")
    f_row(2, "HTF Trend", htfBull, htfBear, htfBull?"▲ Up":htfBear?"▼ Down":"– Flat")
    f_row(3, "VWAP", vwapBull, vwapBear, na(vwapV)?"– n/a":vwapBull?"▲ Above":"▼ Below")
    f_row(4, "Momentum", rsiBull, rsiBear, str.tostring(math.round(rsiVal)) + (rsiBull?" ▲":" ▼"))
    f_row(5, "Structure", structBull, structBear, structBull?"▲ HH/HL":structBear?"▼ LH/LL":"– Mixed")
    f_row(6, "Prev Day", pdBull, pdBear, pdBull?"▲ Above":"▼ Below")
    overallTxt = net > 0 ? "BULLISH " + str.tostring(bulls) + "/6" : net < 0 ? "BEARISH " + str.tostring(bears) + "/6" : "NEUTRAL"
    overallCol = net > 0 ? color.new(color.lime, 0) : net < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)
    table.cell(bt, 0, 7, "OVERALL", text_color=color.white, text_size=biasSzV, bgcolor=color.new(color.gray, 70))
    table.cell(bt, 1, 7, overallTxt, text_color=overallCol, text_size=biasSzV, bgcolor=color.new(color.gray, 70))
````
