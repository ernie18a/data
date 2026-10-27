# AetherEdge - Volatility Squeeze Breaker

- url: https://www.tradingview.com/script/3tR3C2jE/
- type: indicator
- pine_id: PUB;4e1bfdd42a8d4f1682109356e21b9b03
- version: 1.0

## Description

🖊️ Overview
AetherEdge Volatility Squeeze Breaker is a next-generation squeeze detection engine that visualizes the "compressed energy" building up just before explosive market moves, anticipating breakouts before they occur. Fusing 3-tier hierarchical squeeze detection (Bollinger Bands × Keltner Channel) with a proprietary accumulated energy bar system, it quantifies both compression depth and duration. The trinity confirmation of volume, momentum, and squeeze tier extracts only the highest-conviction breakouts.

🔶 Key Features

3-Tier Hierarchical Squeeze Detection: Visualizes Wide / Medium / Tight compression depths
Accumulated Energy Bar: Quantifies compression length × depth on a 0–100 scale
BB × KC Integrated Logic: Classic yet powerful method—BB contained within KC
LazyBear-Style Momentum: Linreg-based 4-color gradient force assessment
Volume Surge Filter: Extracts only breakouts with 1.5× average volume
High-Conviction Signals: Special visualization for Tier 2+ post-squeeze breaks
Squeeze Dot Display: Tier-colored dots for intuitive compression awareness
Breakout Arrows: Instant marking of confirmed directional breaks
Dashboard: Integrated energy %, squeeze tier, and momentum status display
Premium Dark Mode UI: AetherEdge brand color palette

🧠 Technical Architecture

This indicator is a sophisticated engine that multi-dimensionally analyzes the "volatility contraction → expansion cycle."

3-Tier Squeeze Formula: Simultaneously evaluates whether BB(20, 2.0) is fully contained within KC(20, tier mult) at tierWide(2.0) / tierMid(1.5) / tierTight(1.0). sqTier = sqTight ? 3 : sqMid ? 2 : sqWide ? 1 : 0 quantifies depth.
Energy Accumulation Algorithm: During squeeze, energy += (sqTier * 0.6) + compress * 2.0 accumulates. compress = max(0, 1 - bw/kw) extracts compression ratio from BB-to-KC width. Capped at 100.
Decay Logic: Post-release, energy *= 0.88 - 1 produces exponential decay, expressing energy expenditure over time.
Momentum Engine: LazyBear-style linreg of close - avg(avg(highest, lowest), sma), histogram-rendered with 4 colors for rising/falling/accelerating/decelerating force.
Breakout Confirmation Logic: ①Squeeze release (recentRelease: within last 3 bars), ②momentum direction match, ③volume surge, ④BB boundary break—all four conditions required.
High-Conviction Separation: lastTier records maximum compression depth during squeeze; only Tier 2+ post-squeeze breaks become special signals.
True Hold Duration (sqBars): Counts squeeze persistence—longer compression foreshadows larger explosions.
Selectable TR for KC: useTR toggle switches between True Range and High-Low basis for instrument-specific tuning.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (1H–4H): bbLen=20, bbMult=2.0, kcLen=20, kcMult=1.5, volMult=1.5 (standard is optimal)
ETH (15M–1H): bbMult=1.8, tierTight=0.9 for earlier detection
SOL (High-Vol): bbMult=2.2, volMult=2.0 for aggressive false-break filtering
XRP (Range-Heavy): tierWide=2.5, energyLen=80 to capture long-term accumulation
Tuning Guide:

Day Trading: Maintain defaults, operate on 15M–1H
Swing Trading: bbLen=30, kcLen=30 for daily/weekly large-scale squeezes
Scalping: bbLen=10, kcLen=10 for short-term compression capture
Low-Vol Markets: tierTight=0.8 to extract only the strictest squeezes
Trending Markets: volMult=2.0+ for genuine breakouts only
Energy Thresholds: 80+ signals major explosion, 60–80 standard breakout readiness

💡 How to Use in Practice

Energy 80+ with High-Conviction Arrow: Highest-conviction breakout entry
Sustained Tier 3 (Red Dot): Energy maxing out → precursor to large trend birth
Momentum Color Flip + Squeeze Release: Moment of directional confirmation—immediate entry candidate
Avoid Counter-Trend: Never enter early during squeeze; always wait for release confirmation
Double-Break Caution: Upward break followed by reversal break-down is a classic false breakout
Multi-Timeframe Synergy: Higher-TF Tier 3 squeeze + lower-TF breakout firing = ultimate setup
AetherEdge Synergy: Self-Evolving S/R Grid strong-line break + Squeeze Breaker high-conviction signal = ultimate dual confirmation
Energy Depletion Watch: Rapid post-break energy drop indicates explosive energy spent—evidence of trend continuation

⚠️ Important Notes

No Entry During Squeeze: Direction unknown pre-release; always confirm sqReleased
False-Break-Heavy Markets: In sticky ranges, use volMult=2.0+ for strict filtering
Energy Decay Timing: Breakouts within a few bars of release are most effective; reliability drops beyond 3 bars
lastTier Reset: Resets after 2 consecutive non-squeeze bars for proper state management
Behavior in Abnormal Volatility: Risk of misjudgment during sudden expansion—higher-TF confirmation recommended

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Squeeze detection and breakout judgment are probabilistic evaluations based on historical price and volatility data and do not guarantee future market behavior. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - Volatility Squeeze Breaker", "AE-Squeeze Breaker", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpBB  = "① Bollinger Bands"
bbLen  = input.int(20,  "BB Length",  minval=2, group=grpBB)
bbMult = input.float(2.0, "BB StdDev", minval=0.5, step=0.1, group=grpBB)

grpKC  = "② Keltner Channel"
kcLen  = input.int(20,  "KC Length",  minval=2, group=grpKC)
kcMult = input.float(1.5, "KC Mult",   minval=0.5, step=0.1, group=grpKC)
useTR  = input.bool(true, "Use True Range for KC", group=grpKC)

grpSQ  = "③ Squeeze Tiers"
tierWide = input.float(2.0, "Wide Squeeze (KC mult)",   step=0.1, group=grpSQ)
tierMid  = input.float(1.5, "Medium Squeeze (KC mult)", step=0.1, group=grpSQ)
tierTight= input.float(1.0, "Tight Squeeze (KC mult)",  step=0.1, group=grpSQ)

grpMOM = "④ Momentum"
momLen = input.int(20,  "Momentum Length", minval=2, group=grpMOM)

grpVOL = "⑤ Volume Filter"
useVol    = input.bool(true, "Enable Volume Filter", group=grpVOL)
volLen    = input.int(20,  "Volume SMA Length", minval=2, group=grpVOL)
volMult   = input.float(1.5, "Volume Surge Mult", minval=1.0, step=0.1, group=grpVOL)

grpENG = "⑥ Energy Bar"
energyLen = input.int(50, "Energy Lookback (bars in squeeze)", minval=5, group=grpENG)
showEnergy= input.bool(true, "Show Energy Panel", group=grpENG)

grpUI  = "🎨 Display"
darkMode = input.bool(true, "Dark Mode", group=grpUI)
showBands= input.bool(true, "Show BB + KC Bands", group=grpUI)
showDots = input.bool(true, "Show Squeeze Dots",  group=grpUI)
showArrow= input.bool(true, "Show Breakout Arrows", group=grpUI)
showDash = input.bool(true, "Show Dashboard", group=grpUI)
dashPos  = input.string("Top Right", "Dashboard Position",options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpUI)

// ═══════════════════════════════════════════════════════════════
//  COLORS — AetherEdge palette
// ═══════════════════════════════════════════════════════════════
cBg        = darkMode ? color.new(#0b1221, 10) : color.new(#f7f9fc, 10)
cBgAlt     = darkMode ? color.new(#111a2e, 15) : color.new(#ffffff, 0)
cBorder    = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText      = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute      = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent    = color.new(#00d4ff, 0)

cBull      = color.new(#00e5a0, 0)
cBullSoft  = color.new(#26a69a, 0)
cBear      = color.new(#ff3d71, 0)
cBearSoft  = color.new(#ef5350, 0)
cNeutral   = color.new(#5c6b7d, 0)

cSqTight   = color.new(#ff3d71, 0)   // red = maximum compression
cSqMid     = color.new(#ffb547, 0)   // amber
cSqWide    = color.new(#00d4ff, 0)   // cyan
cSqOff     = color.new(#5c6b7d, 50)

// ═══════════════════════════════════════════════════════════════
//  BB / KC CALCULATION
// ═══════════════════════════════════════════════════════════════
src = close
basis = ta.sma(src, bbLen)
dev   = bbMult * ta.stdev(src, bbLen)
bbU   = basis + dev
bbL   = basis - dev

kcBasis = ta.sma(src, kcLen)
rng     = useTR ? ta.tr : (high - low)
rngMA   = ta.sma(rng, kcLen)

kcU_tight = kcBasis + rngMA * tierTight
kcL_tight = kcBasis - rngMA * tierTight
kcU_mid   = kcBasis + rngMA * tierMid
kcL_mid   = kcBasis - rngMA * tierMid
kcU_wide  = kcBasis + rngMA * tierWide
kcL_wide  = kcBasis - rngMA * tierWide

// Standard KC for display (kcMult)
kcU = kcBasis + rngMA * kcMult
kcL = kcBasis - rngMA * kcMult

// ═══════════════════════════════════════════════════════════════
//  SQUEEZE DETECTION — tiered
// ═══════════════════════════════════════════════════════════════
sqWide  = bbL > kcL_wide  and bbU < kcU_wide
sqMid   = bbL > kcL_mid   and bbU < kcU_mid
sqTight = bbL > kcL_tight and bbU < kcU_tight

sqOn    = sqWide or sqMid or sqTight
sqTier  = sqTight ? 3 : sqMid ? 2 : sqWide ? 1 : 0
sqColor = sqTight ? cSqTight : sqMid ? cSqMid : sqWide ? cSqWide : cSqOff

// ═══════════════════════════════════════════════════════════════
//  MOMENTUM — LazyBear style linreg
// ═══════════════════════════════════════════════════════════════
mom = ta.linreg(src - math.avg(math.avg(ta.highest(high, momLen), ta.lowest(low, momLen)), ta.sma(close, momLen)), momLen, 0)

momUp    = mom > 0
momRise  = mom > nz(mom[1])
momColor = momUp ? (momRise ? cBull : cBullSoft) : (momRise ? cBearSoft : cBear)

// ═══════════════════════════════════════════════════════════════
//  VOLUME FILTER
// ═══════════════════════════════════════════════════════════════
volAvg  = ta.sma(volume, volLen)
volSurge = volume > volAvg * volMult
volOK   = not useVol or volSurge

// ═══════════════════════════════════════════════════════════════
//  ENERGY BAR — accumulated volatility-compression "potential"
//  Concept: the longer & tighter a squeeze persists,
//           the higher the stored energy. Released on breakout.
// ═══════════════════════════════════════════════════════════════
var float energy = 0.0
var int   sqBars = 0

if sqOn
    sqBars += 1
    // each bar adds tier-weighted increment, normalized by BB width compression
    bw = (bbU - bbL) / basis
    kw = (kcU_wide - kcL_wide) / kcBasis
    compress = kw == 0 ? 0 : math.max(0, 1 - bw / kw)
    energy := math.min(100, energy + (sqTier * 0.6) + compress * 2.0)
else
    // decay when squeeze released
    energy := math.max(0, energy * 0.88 - 1)
    if not sqOn and sqOn[1]
        sqBars := 0

// normalize
energyPct = math.min(100, math.max(0, energy))

// ═══════════════════════════════════════════════════════════════
//  BREAKOUT DETECTION — squeeze release + momentum + volume
// ═══════════════════════════════════════════════════════════════
sqReleased = not sqOn and sqOn[1]

// consider "recent release": within last 3 bars
recentRelease = sqReleased or (not sqOn and (sqOn[1] or sqOn[2] or sqOn[3]))

breakUp   = recentRelease and momUp      and volOK and close > bbU[1]
breakDown = recentRelease and not momUp  and volOK and close < bbL[1]

// high-conviction signal requires tier >= 2 during squeeze
var int lastTier = 0
if sqOn
    lastTier := math.max(lastTier, sqTier)
if not sqOn and not sqOn[1]
    lastTier := 0

highConvUp   = breakUp   and lastTier >= 2
highConvDown = breakDown and lastTier >= 2

// ═══════════════════════════════════════════════════════════════
//  PLOTS — Bands
// ═══════════════════════════════════════════════════════════════
bbUpperP = plot(showBands ? bbU : na, "BB Upper", color=color.new(cAccent, 60))
bbLowerP = plot(showBands ? bbL : na, "BB Lower", color=color.new(cAccent, 60))
fill(bbUpperP, bbLowerP, color=color.new(cAccent, 94), title="BB Fill")

kcUpperP = plot(showBands ? kcU : na, "KC Upper", color=color.new(cMute, 40), style=plot.style_linebr)
kcLowerP = plot(showBands ? kcL : na, "KC Lower", color=color.new(cMute, 40), style=plot.style_linebr)

plot(showBands ? basis : na, "Basis", color=color.new(cAccent, 30), linewidth=1)

// ═══════════════════════════════════════════════════════════════
//  PLOTS — Squeeze dots on basis line
// ═══════════════════════════════════════════════════════════════
plotshape(showDots and sqOn ? basis : na, title="Squeeze Dot",
     style=shape.circle, location=location.absolute,
     color=sqColor, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
//  PLOTS — Breakout arrows
// ═══════════════════════════════════════════════════════════════
plotshape(showArrow and breakUp and not highConvUp ? low : na,  title="Breakout Up",
     style=shape.triangleup, location=location.belowbar, color=cBull, size=size.small, text="▲")

plotshape(showArrow and breakDown and not highConvDown ? high : na, title="Breakout Down",
     style=shape.triangledown, location=location.abovebar, color=cBear, size=size.small, text="▼")

plotshape(showArrow and highConvUp ? low : na, title="HIGH-CONV Up",
     style=shape.labelup, location=location.belowbar, color=cBull, textcolor=color.white, size=size.normal, text="◆ LONG")

plotshape(showArrow and highConvDown ? high : na, title="HIGH-CONV Down",
     style=shape.labeldown, location=location.abovebar, color=cBear, textcolor=color.white, size=size.normal, text="◆ SHORT")

// subtle background tint on release candle
bgcolor(breakUp   ? color.new(cBull, 88) : na)
bgcolor(breakDown ? color.new(cBear, 88) : na)

// ═══════════════════════════════════════════════════════════════
//  ENERGY BAR — rendered as progress bar in floating table
// ═══════════════════════════════════════════════════════════════
f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

f_energyColor(e) =>
    e >= 80 ? cSqTight :
     e >= 60 ? color.new(#ff8c42, 0) :
     e >= 40 ? cSqMid :
     e >= 20 ? cSqWide :
               cMute

f_tierLabel(t) =>
    t == 3 ? "◆◆◆ TIGHT" :
     t == 2 ? "◆◆ MEDIUM" :
     t == 1 ? "◆ WIDE"   :
              "— OFF"

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = na
var table ebar = na

if barstate.islast and showDash
    dash := table.new(f_pos(dashPos), 2, 8, bgcolor=cBg, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    // Title
    table.cell(dash, 0, 0, "◆ AETHEREDGE  SQUEEZE BREAKER ◆", text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    // Squeeze status
    table.cell(dash, 0, 1, "SQUEEZE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 1, f_tierLabel(sqTier), text_color=color.white, bgcolor=sqColor, text_halign=text.align_center)

    // Squeeze duration
    table.cell(dash, 0, 2, "DURATION", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 2, sqOn ? str.tostring(sqBars) + " bars" : "released", text_color=cText, bgcolor=cBg, text_halign=text.align_center)

    // Momentum
    momTxt = momUp ? (momRise ? "▲▲ RISING" : "▲ BULL") : (momRise ? "▼ BEAR" : "▼▼ FALLING")
    table.cell(dash, 0, 3, "MOMENTUM", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 3, momTxt, text_color=color.white, bgcolor=momColor, text_halign=text.align_center)

    // Volume
    volRatio = volume / volAvg
    volTxt = volSurge ? "⚡ SURGE  x" + str.tostring(volRatio, "#.00") : "normal  x" + str.tostring(volRatio, "#.00")
    table.cell(dash, 0, 4, "VOLUME", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 4, volTxt, text_color=color.white, bgcolor=volSurge ? cBull : cNeutral, text_halign=text.align_center)

    // Energy
    table.cell(dash, 0, 5, "ENERGY", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(energyPct, "#.0") + " %", text_color=color.white, bgcolor=f_energyColor(energyPct), text_halign=text.align_center)

    // Signal
    sigTxt = highConvUp   ? "◆ HIGH-CONV LONG"  :highConvDown ? "◆ HIGH-CONV SHORT" :breakUp      ? "▲ BREAKOUT UP"     :breakDown    ? "▼ BREAKOUT DOWN"   :sqOn         ? "… COILING"         :"— no signal"
    sigCol = (highConvUp or breakUp)     ? cBull :
             (highConvDown or breakDown) ? cBear :
             sqOn                        ? sqColor :
                                           cNeutral
    table.cell(dash, 0, 6, "SIGNAL", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 6, sigTxt, text_color=color.white, bgcolor=sigCol, text_halign=text.align_center)

    // BB width (compression metric)
    bbw = (bbU - bbL) / basis * 100
    table.cell(dash, 0, 7, "BB WIDTH", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bbw, "#.00") + " %", text_color=cText, bgcolor=cBg, text_halign=text.align_center)

// Energy segmented bar (floating at bottom)
if barstate.islast and showEnergy
    segs = 20
    ebar := table.new(position.bottom_center, segs + 2, 2, bgcolor=cBg, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    table.cell(ebar, 0, 0, "⚡ ENERGY", text_color=cAccent, bgcolor=cBgAlt, text_size=size.small)
    table.cell(ebar, segs + 1, 0, str.tostring(energyPct, "#.0") + "%", text_color=color.white, bgcolor=f_energyColor(energyPct), text_size=size.small, text_halign=text.align_center)

    filled = math.round(energyPct / 100 * segs)
    for i = 1 to segs
        segCol = i <= filled ? f_energyColor(energyPct) : cBgAlt
        table.cell(ebar, i, 0, "", bgcolor=segCol, text_size=size.small)

    // tier markers row
    table.cell(ebar, 0, 1, "", bgcolor=cBgAlt, text_size=size.tiny)
    table.cell(ebar, segs + 1, 1, "", bgcolor=cBgAlt, text_size=size.tiny)
    for i = 1 to segs
        marker = i == 5 ? "·" : i == 10 ? "|" : i == 15 ? "·" : ""
        table.cell(ebar, i, 1, marker, text_color=cMute, bgcolor=cBg, text_size=size.tiny, text_halign=text.align_center)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(sqOn and not sqOn[1],        "Squeeze Started",  "AetherEdge: Volatility squeeze has STARTED")
alertcondition(sqTight and not sqTight[1],  "Tight Squeeze",    "AetherEdge: TIGHT squeeze — maximum compression")
alertcondition(sqReleased,                   "Squeeze Released", "AetherEdge: Squeeze RELEASED — watch for breakout")
alertcondition(breakUp,                      "Breakout Up",      "AetherEdge: BULLISH breakout (volume-confirmed)")
alertcondition(breakDown,                    "Breakout Down",    "AetherEdge: BEARISH breakout (volume-confirmed)")
alertcondition(highConvUp,                   "High-Conv Long",   "AetherEdge: ◆ HIGH-CONVICTION LONG signal")
alertcondition(highConvDown,                 "High-Conv Short",  "AetherEdge: ◆ HIGH-CONVICTION SHORT signal")
alertcondition(energyPct >= 80,              "Energy Full",      "AetherEdge: Energy ≥ 80% — breakout imminent")
````
