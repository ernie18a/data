# Institutional VWAP Bands [JOAT]

- url: https://www.tradingview.com/script/HBa1RdfD-Institutional-VWAP-Bands-JOAT/
- type: indicator
- pine_id: PUB;25b8a79a26c34356b285d8818776ebb6
- version: 1.0

## Description

[b]Institutional VWAP Bands [JOAT][/b]
[i]An anchored VWAP with standard-deviation bands that classifies price as cheap, fair or expensive and offers two complementary playbooks: mean reversion and trend pullback.[/i]

[image]https://www.tradingview.com/x/Og0oDmjj/[/image]

[b]What it is[/b]
VWAP is the benchmark institutions measure their own fills against — the market's running notion of fair value. Standard-deviation bands around it map where price is stretched relative to that benchmark. This indicator runs an anchored VWAP with three band pairs and turns them into a structured, non-repainting decision tool rather than a plain VWAP line.

[b]How it works[/b]
• [b]Anchored VWAP[/b] — volume-weighted average price accumulated from a chosen anchor (session, week or month) with a controlled reset, so the reference restarts cleanly each period.

• [b]Sigma bands[/b] — three pairs of bands at one, two and three standard deviations of price around VWAP, computed from the same volume-weighted variance. These define the stretch zones.

• [b]Value state[/b] — every bar is classified with a z-score into cheap, fair or expensive relative to VWAP. This drives the colour system and the dashboard.

• [b]Mean-reversion fades[/b] — when price is stretched to the outer bands against the higher-timeframe trend and then reclaims back inside, a fade toward VWAP is signalled. The reclaim requirement is deliberate, so you are not blindly catching a falling knife.

• [b]Trend-pullback entries[/b] — in a trend, a retracement to VWAP or the first band that holds is a discount entry in the trend direction. Both playbooks are labelled by type, and Buy/Sell are mutually exclusive with a minimum-gap control.

[b]Trade levels[/b]
Each signal draws a red risk box to the ATR stop and a green reward box to the third target, with inner dividers and right-edge labels for entry, stop and each take-profit. For reversion signals the first target is clamped toward VWAP so it always sits on the profit side of entry.

[b]The dashboard[/b]
An adjustable value-ladder panel shows the value state, the z-score, the trend bias, the active playbook and signal, a conviction estimate, and a live first-target-before-stop tally from closed bars only.

[b]How to use it[/b]
• Choose the anchor that matches your style: session for intraday, week or month for swing context.
• Fade the outer bands only against the trend and with a reclaim; take pullbacks to VWAP with the trend.
• Works across assets and timeframes, though the anchor should suit the timeframe you trade.

[b]Settings[/b]
Anchor period, VWAP source, three band multipliers, trend filter length, reversion trigger, ATR risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
VWAP and deviation bands are standard building blocks; the contribution here is the explicit two-playbook logic (reclaim-based reversion versus trend pullback), the value-state classification that ties colour, dashboard and signals together, and the reversion target clamp — combined into one coherent, non-repainting framework and fully explained.

[b]Notes and limitations[/b]
• VWAP is most meaningful on instruments with reliable volume; on symbols without real volume the bands lose accuracy, which is stated here honestly.
• Reversion trades against a strong trend carry inherent risk even with the reclaim filter.
• The tally reflects only past bars on the current chart and is not a forecast.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Institutional VWAP Bands [JOAT]", "VWAP Bands [JOAT]", overlay = true, max_labels_count = 300, max_lines_count = 100, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (institutional blue vs red)
// ─────────────────────────────────────────────────────────────────────────
BLUE   = #2962FF
BLUE_HI= #79A6FF
RED    = #EF2D4E
RED_HI = #FF7690
GOLD   = #FFB020
GREEN  = #17B87C
GREEN_HI= #3FE0A6
ROSE   = #E6B08A
ROSE_HI= #F3CBA9
INK    = #0A0E17
INKHI  = #ECF1FA
MUTE   = #56607A

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gV      = "VWAP"
anchor  = input.string("Session","Anchor period", options = ["Session","Week","Month"], group = gV, tooltip = "When the VWAP accumulation resets.")
vwapSrc = input.source(hlc3, "VWAP source", group = gV)
band1   = input.float(1.0, "σ Band 1", minval = 0.1, step = 0.1, group = gV)
band2   = input.float(2.0, "σ Band 2", minval = 0.1, step = 0.1, group = gV)
band3   = input.float(3.0, "σ Band 3", minval = 0.1, step = 0.1, group = gV)

gT      = "Trend Filter"
trendLen= input.int(100, "Trend EMA", minval = 2, group = gT, tooltip = "Defines higher-timeframe bias: reversion trades fade counter-trend stretches; pullback trades go with it.")

gSig    = "Signals"
useRev  = input.bool(true, "Mean-reversion fades", group = gSig, tooltip = "Fade ±2σ+ stretches against trend on a reclaim back inside.")
usePb   = input.bool(true, "Trend-pullback entries", group = gSig, tooltip = "Buy discounts to VWAP/1σ in an uptrend, sell premiums in a downtrend.")
zEntry  = input.float(2.0, "Reversion σ trigger", minval = 0.5, step = 0.1, group = gSig)

gTr     = "Trade Levels"
showLad = input.bool(true, "TP/SL boxes", group = gTr)
atrLenT = input.int(14, "ATR length", minval = 1, group = gTr)
slMult  = input.float(1.2,"SL = ATR ×", minval = 0.1, step = 0.1, group = gTr)
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gTr)

gVis    = "Visuals"
showBands=input.bool(true, "Show σ bands", group = gVis)
fillBands=input.bool(true, "Fill bands", group = gVis)
colorBars=input.bool(true, "Value-tinted candles", group = gVis)
showStretch=input.bool(true,"Mark extreme stretch", group = gVis)

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)
hudBg   = input.color(#0B0F1A, "Background", group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// ─────────────────────────────────────────────────────────────────────────
//  ANCHORED VWAP + σ  (manual accumulation so we control the reset)
// ─────────────────────────────────────────────────────────────────────────
newPeriod = anchor == "Session" ? timeframe.change("D") : anchor == "Week" ? timeframe.change("W") : timeframe.change("M")

var float sumPV = 0.0
var float sumV  = 0.0
var float sumP2V= 0.0

if newPeriod
    sumPV  := 0.0
    sumV   := 0.0
    sumP2V := 0.0

sumPV  += nz(vwapSrc * volume)
sumV   += nz(volume)
sumP2V += nz(vwapSrc * vwapSrc * volume)

vwap   = sumV > 0 ? sumPV / sumV : vwapSrc
variance = sumV > 0 ? math.max(0.0, sumP2V / sumV - vwap * vwap) : 0.0
sigma  = math.sqrt(variance)

u1 = vwap + band1 * sigma
l1 = vwap - band1 * sigma
u2 = vwap + band2 * sigma
l2 = vwap - band2 * sigma
u3 = vwap + band3 * sigma
l3 = vwap - band3 * sigma

// z-score of price vs VWAP
z = sigma > 0 ? (close - vwap) / sigma : 0.0

// ─────────────────────────────────────────────────────────────────────────
//  VALUE STATE + TREND
// ─────────────────────────────────────────────────────────────────────────
trendMa = ta.ema(close, trendLen)
upTrend = close >= trendMa
valState = z > band2 ? 2 : z > band1 ? 1 : z < -band2 ? -2 : z < -band1 ? -1 : 0
// -2 very cheap … +2 very expensive (relative to VWAP)

atr = ta.atr(atrLenT)

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS
//   Reversion: price stretched beyond ±zEntry σ against trend, then reclaims
//              back inside the band → fade toward VWAP.
//   Pullback : in trend, price tags VWAP/1σ discount and closes back with trend.
// ─────────────────────────────────────────────────────────────────────────
stretchedUp = z >= zEntry
stretchedDn = z <= -zEntry

// Reversion: a very-cheap bar reclaims upward (or very-expensive rolls over).
revBuy  = useRev and z[1] <= -zEntry and z > z[1] and close > open
revSell = useRev and z[1] >=  zEntry and z < z[1] and close < open

// Pullback: in trend, price reclaims VWAP in the trend direction (discount/premium entry).
pbBuy  = usePb and upTrend and ta.crossover(close, vwap)
pbSell = usePb and not upTrend and ta.crossunder(close, vwap)

sell = revSell or pbSell
buy  = (revBuy or pbBuy) and not sell   // prevent same-bar conflict
sig  = buy or sell

// ── signal debounce — Buy/Sell can never stack on any timeframe
minGap = input.int(6, "Min bars between signals", minval = 0, group = "Signals", tooltip = "Minimum bar spacing between printed signals so labels never overlap on lower timeframes. 0 = off.")
var int lastSigBar = na
okGap = na(lastSigBar) or (bar_index - lastSigBar) >= minGap
buy  := buy  and okGap
sell := sell and okGap
sig  := buy or sell
if sig
    lastSigBar := bar_index
sigKind = revBuy ? "Reversion" : pbBuy ? "Pullback" : revSell ? "Reversion" : pbSell ? "Pullback" : ""

// ─────────────────────────────────────────────────────────────────────────
//  CONVICTION 0..100
// ─────────────────────────────────────────────────────────────────────────
zComp    = math.min(1.0, math.abs(z) / band3)
trendComp= (buy and upTrend) or (sell and not upTrend) ? 1.0 : 0.5
kindComp = sigKind == "Pullback" ? 0.9 : 0.7
conv = math.round(100 * (0.4 * zComp + 0.35 * trendComp + 0.25 * kindComp))

// ─────────────────────────────────────────────────────────────────────────
//  LIVE STATS + TP/SL BOXES  (red risk / green reward; reversion TP1 = VWAP)
// ─────────────────────────────────────────────────────────────────────────
var float sEntry = na
var float sSL = na
var float sT1 = na
var int   sDir = 0
var bool  sOpen = false
var int   wins = 0
var int   losses = 0

if sOpen
    if sDir == 1
        if high >= sT1
            wins += 1
            sOpen := false
        else if low <= sSL
            losses += 1
            sOpen := false
    else
        if low <= sT1
            wins += 1
            sOpen := false
        else if high >= sSL
            losses += 1
            sOpen := false

var box   riskBox   = na
var box   rewardBox = na
var line  lnE = na
var line  lnS = na
var line  ln1 = na
var line  ln2 = na
var label lbE = na
var label lbS = na
var label lb1 = na
var label lb2 = na
var label lb3 = na

f_lvl(line ln, label lb, float p, string txt, color c) =>
    line.set_xy1(ln, bar_index, p)
    line.set_xy2(ln, bar_index + boxW, p)
    line.set_color(ln, c)
    label.set_xy(lb, bar_index + boxW, p)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

if sig
    if sOpen
        losses += 1
        sOpen := false
    sDir   := buy ? 1 : -1
    sEntry := close
    risk    = atr * slMult
    risk   := risk > 0 ? risk : atr
    sSL    := buy ? close - risk : close + risk
    // primary target: VWAP for reversion, ±2σ band for pullback.
    // clamp the reversion target to the profit side so TP1 never lands past entry.
    t1 = sigKind == "Reversion" ? (buy ? math.max(vwap, close) : math.min(vwap, close)) : (buy ? u2 : l2)
    t2 = buy ? u2 : l2
    t3 = buy ? u3 : l3
    sT1 := t1
    sOpen := true

    if showLad
        box.delete(riskBox)
        box.delete(rewardBox)
        // red RISK box: entry → SL
        riskBox   := box.new(bar_index, sEntry, bar_index + boxW, sSL, bgcolor = color.new(RED, 82), border_color = color.new(RED, 35), border_width = 1)
        // green REWARD box: entry → TP3
        rewardBox := box.new(bar_index, sEntry, bar_index + boxW, t3, bgcolor = color.new(GREEN, 85), border_color = color.new(GREEN, 35), border_width = 1)
        if na(lnE)
            lnE := line.new(bar_index, sEntry, bar_index + boxW, sEntry, color = GOLD, width = 2)
            lnS := line.new(bar_index, sSL, bar_index + boxW, sSL, color = RED, style = line.style_dashed)
            ln1 := line.new(bar_index, t1, bar_index + boxW, t1, color = GREEN, style = line.style_dotted)
            ln2 := line.new(bar_index, t2, bar_index + boxW, t2, color = GREEN, style = line.style_dotted)
            lbE := label.new(bar_index + boxW, sEntry, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lbS := label.new(bar_index + boxW, sSL, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb1 := label.new(bar_index + boxW, t1, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb2 := label.new(bar_index + boxW, t2, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
            lb3 := label.new(bar_index + boxW, t3, "", style = label.style_label_left, color = color.new(INK,100), size = size.small)
        f_lvl(lnE, lbE, sEntry, " ENTRY " + str.tostring(sEntry, format.mintick), GOLD)
        f_lvl(lnS, lbS, sSL, " SL " + str.tostring(sSL, format.mintick), RED_HI)
        f_lvl(ln1, lb1, t1, " TP1 " + (sigKind == "Reversion" ? "· VWAP " : "· 2σ ") + str.tostring(t1, format.mintick), GREEN)
        f_lvl(ln2, lb2, t2, " TP2 · 2σ " + str.tostring(t2, format.mintick), GREEN)
        // TP3 label sits at the reward-box top (no inner divider line)
        label.set_xy(lb3, bar_index + boxW, t3)
        label.set_text(lb3, " TP3 · 3σ " + str.tostring(t3, format.mintick))
        label.set_textcolor(lb3, GREEN_HI)

if showLad and not na(riskBox) and barstate.islast
    box.set_right(riskBox, bar_index + boxW)
    box.set_right(rewardBox, bar_index + boxW)
    line.set_x2(lnE, bar_index + boxW)
    line.set_x2(lnS, bar_index + boxW)
    line.set_x2(ln1, bar_index + boxW)
    line.set_x2(ln2, bar_index + boxW)
    label.set_x(lbE, bar_index + boxW)
    label.set_x(lbS, bar_index + boxW)
    label.set_x(lb1, bar_index + boxW)
    label.set_x(lb2, bar_index + boxW)
    label.set_x(lb3, bar_index + boxW)

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────────────────────────────────
vwapCol = upTrend ? BLUE : RED
plot(vwap, "VWAP", color = color.new(vwapCol, 0), linewidth = 2)

pu1 = plot(showBands ? u1 : na, "U1", color = color.new(RED, 70))
pl1 = plot(showBands ? l1 : na, "L1", color = color.new(BLUE, 70))
pu2 = plot(showBands ? u2 : na, "U2", color = color.new(RED, 55))
pl2 = plot(showBands ? l2 : na, "L2", color = color.new(BLUE, 55))
pu3 = plot(showBands ? u3 : na, "U3", color = color.new(RED, 40), style = plot.style_stepline)
pl3 = plot(showBands ? l3 : na, "L3", color = color.new(BLUE, 40), style = plot.style_stepline)

fill(pu1, pu2, color = fillBands ? color.new(RED, 90) : na, title = "Upper value fill")
fill(pu2, pu3, color = fillBands ? color.new(RED, 84) : na, title = "Upper extreme fill")
fill(pl1, pl2, color = fillBands ? color.new(BLUE, 90) : na, title = "Lower value fill")
fill(pl2, pl3, color = fillBands ? color.new(BLUE, 84) : na, title = "Lower extreme fill")

// value-tinted candles: cheap = blue, fair = mute, expensive = red
valCol = z > band1 ? color.from_gradient(math.min(z, band3), band1, band3, RED_HI, RED) : z < -band1 ? color.from_gradient(math.min(-z, band3), band1, band3, BLUE_HI, BLUE) : MUTE
barcolor(colorBars ? color.new(valCol, 25) : na)

plotshape(showStretch and stretchedUp and not stretchedUp[1], "Expensive", style = shape.triangledown, location = location.abovebar, color = RED, size = size.tiny)
plotshape(showStretch and stretchedDn and not stretchedDn[1], "Cheap", style = shape.triangleup, location = location.belowbar, color = BLUE, size = size.tiny)

plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = BLUE, textcolor = INKHI, text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = RED,  textcolor = INKHI, text = "SELL", size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal

// dot-meter glyph builder for the value ladder (● filled / ○ empty)
f_dots(float pct01) =>
    fill = math.round(math.max(0.0, math.min(1.0, pct01)) * 8)
    out = ""
    for i = 1 to 8
        out := out + (i <= fill ? "●" : "○")
    out

var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 7, bgcolor = color.new(hudBg, 0), frame_color = color.new(#1C2436, 0), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #1A2440), 0)

    // royal-blue (cheap / discount) vs rose-gold (rich / expensive) accent system
    valT = valState >= 2 ? "EXPENSIVE" : valState == 1 ? "RICH" : valState <= -2 ? "CHEAP" : valState == -1 ? "DISCOUNT" : "FAIR"
    valC = valState >= 1 ? ROSE_HI : valState <= -1 ? BLUE_HI : MUTE
    trT  = upTrend ? "UP" : "DOWN"
    trC  = upTrend ? BLUE_HI : ROSE_HI

    // headline z-score (signed), coloured by cheap/expensive side
    zHead = (z >= 0 ? "+" : "") + str.tostring(z, "#.##") + "σ"
    zC    = z > 0 ? ROSE_HI : z < 0 ? BLUE_HI : MUTE
    // ladder meter: how far toward the ±3σ extreme, tinted to the active side
    zMag  = math.min(1.0, math.abs(z) / band3)
    zDots = f_dots(zMag)

    convDots = f_dots(conv / 100.0)
    convC = conv >= 66 ? BLUE_HI : conv >= 33 ? GOLD : MUTE

    trDots = f_dots(upTrend ? math.min(1.0, (close - trendMa) / (atr > 0 ? atr * 3 : 1)) : math.min(1.0, (trendMa - close) / (atr > 0 ? atr * 3 : 1)))

    sigT = buy ? "BUY ▲ " + sigKind : sell ? "SELL ▼ " + sigKind : "WAITING"
    sigC = buy ? BLUE_HI : sell ? ROSE_HI : MUTE
    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? BLUE_HI : winRate <= 45 ? ROSE_HI : GOLD

    // ── header: σ ladder identity + big z-score headline
    table.cell(hud, 0, 0, "  σ VALUE LADDER", text_color = INKHI, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, zHead + "  ", text_color = zC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)
    // ── value state rung
    table.cell(hud, 0, 1, "  Value", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, valT + "  ", text_color = valC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // ── deviation rung: dot ladder toward ±3σ
    table.cell(hud, 0, 2, "  Deviation", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, zDots + "  ", text_color = zC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // ── trend rung
    table.cell(hud, 0, 3, "  Trend " + trT, text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, trDots + "  ", text_color = trC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // ── conviction rung
    table.cell(hud, 0, 4, "  Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, convDots + " " + str.tostring(conv) + "  ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // ── signal rung
    table.cell(hud, 0, 5, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // ── footer: win rate (TP1 first)
    table.cell(hud, 0, 6, "  Win (TP1) · " + anchor, text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 6, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,  "Buy",  "VWAP Bands: long trigger (reversion reclaim or trend pullback)")
alertcondition(sell, "Sell", "VWAP Bands: short trigger (reversion rollover or trend pullback)")
alertcondition(stretchedUp and not stretchedUp[1], "Expensive stretch", "VWAP Bands: price stretched above upper σ band")
alertcondition(stretchedDn and not stretchedDn[1], "Cheap stretch", "VWAP Bands: price stretched below lower σ band")
````
