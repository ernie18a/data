# Belforts Tomahawk Chop

- url: https://www.tradingview.com/script/gH7U3SHM-Belforts-Tomahawk-Chop/
- type: indicator
- pine_id: PUB;921fdb4c1b7e416ab7072ab558bc9667
- version: 14.0

## Description

5 min scalping tool ill make a vid on it shortly// Basically when higher time frames align youll get the background color change letting u know its time to man the battle station . when you get a signal you take that trade for a quick SCALP !!!

## Source Code

````pine
//@version=6
indicator("Belforts Tomahawk Chop", overlay=true, max_bars_back=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// Source symbol uses current chart — works correctly now that timeframe is fixed to 360min
string srcSymbol = syminfo.tickerid
bool   use6hHA   = false

grpBG = "=== Background Intensity Levels ==="
bgUseHA = input.bool(true, "MTF Background uses Heikin Ashi candles", group=grpBG, tooltip="Applies to BOTH the 6H streak and the 1H alignment. Previously the 6H read regular candles while the 1H read Heikin Ashi — an inconsistency that made the background disagree with what you see on a plain 6H/1H chart. Turn OFF to read regular candles on both.")
use6hKill = input.bool(true, "6H Live Kill Switch", group=grpBG, tooltip="Blocks all signals the moment the CURRENTLY FORMING 6H candle flips against the streak direction, even though the two closed 6H candles still agree. Signals only resume once the forming candle is back in agreement (i.e. two closed candles plus the live one all lined up). Note: this reintroduces live-bar repainting by design — a signal can appear and vanish while the 6H candle is still forming.")
bgMatchSignals = input.bool(true, "Background matches signal gating (recommended)", group=grpBG, tooltip="ON: the background paints from the same CONFIRMED levels that gate signals, so a signal can never appear on a blank background. OFF: the background also factors in the live, still-forming 6H candle as a real-time kill switch — more responsive, but it can switch off while confirmed signals still fire, leaving signals on an unpainted background.")
col_bull_l1 = input.color(color.new(color.green, 96), "Bull L1 - 6H streak (subtle)",    group=grpBG)
col_bull_l2 = input.color(color.new(color.green, 89), "Bull L2 - + 1H aligned (medium)", group=grpBG)
col_bull_l3 = input.color(color.new(color.green, 76), "Bull L3 - + 1H strong (bright)",  group=grpBG)
col_bear_l1 = input.color(color.new(color.red,   96), "Bear L1 - 6H streak (subtle)",    group=grpBG)
col_bear_l2 = input.color(color.new(color.red,   89), "Bear L2 - + 1H aligned (medium)", group=grpBG)
col_bear_l3 = input.color(color.new(color.red,   76), "Bear L3 - + 1H strong (bright)",  group=grpBG)


grpRSI = "=== RSI Cross Settings ==="
rsiLen     = input.int(14, "RSI Length",           minval=2, group=grpRSI)
rsiFastLen = input.int(14, "RSI Fast Line Smooth",  minval=1, group=grpRSI)
rsiSlowLen = input.int(2,  "RSI Slow Signal Smooth",minval=1, group=grpRSI)
useHaRsi   = input.bool(true, "Use Heikin Ashi candles for RSI source", group=grpRSI)


grpDIV = "=== Divergence Settings ==="
showDivRsi = input.bool(false, "Show RSI Divergences", group=grpDIV)
pivLB      = input.int(3,  "Pivot Lookback (bars each side)", minval=2, maxval=20, group=grpDIV)
divMaxBars = input.int(60, "Max Bars Between Pivots",         minval=5,            group=grpDIV)
col_bull_div = input.color(color.new(#00e676, 0), "Bullish Divergence Color", group=grpDIV)
col_bear_div = input.color(color.new(#ff1744, 0), "Bearish Divergence Color", group=grpDIV)
divSize       = input.string("small",  "Divergence Size",   options=["tiny","small","normal","large"], group=grpDIV)

grpST = "=== Supertrend ==="
showST      = input.bool(false, "Show Supertrend",          group=grpST)
stPeriod    = input.int(10,     "ATR Period",    minval=1,   group=grpST)
stMult      = input.float(3.0,  "ATR Multiplier",minval=0.1, step=0.1, group=grpST)
col_st_bull = input.color(color.new(#00bcd4, 0), "Supertrend Bull Color", group=grpST)
col_st_bear = input.color(color.new(#e91e63, 0), "Supertrend Bear Color", group=grpST)
showSTSignal = input.bool(true, "Show Flip Signals",         group=grpST)
stFlipSize    = input.string("small",  "Flip Signal Size",  options=["tiny","small","normal","large"], group=grpST)

grpVMC = "=== VMC Cipher B ==="
showVMC     = input.bool(true,  "Show VMC Cipher B Signals",  group=grpVMC)
vmcN1       = input.int(9,   "Channel Length (n1)",  minval=1, group=grpVMC)
vmcN2       = input.int(12,  "Average Length (n2)",  minval=1, group=grpVMC)
vmcMALen    = input.int(3,   "WT MA Length (BVMC uses 3, VuManChu uses 4)", minval=1, group=grpVMC)
vmcOB       = input.int(53,  "Overbought Level",     minval=1, group=grpVMC)
vmcOS       = input.int(-53, "Oversold Level",       maxval=-1,group=grpVMC)
vmcDivOBLevel = input.int(45,  "Bearish Divergence min", group=grpVMC)
vmcDivOSLevel = input.int(-65, "Bullish Divergence min", group=grpVMC)
col_vmc_buy  = input.color(color.new(#2e7d32, 0), "Buy Dot Color",  group=grpVMC)
col_vmc_sell = input.color(color.new(#c62828, 0), "Sell Dot Color",   group=grpVMC)
vmcDotSize    = input.string("tiny", "Dot Size",            options=["tiny","small","normal","large"], group=grpVMC)
vmcDivSize    = input.string("small",  "Divergence Size",   options=["tiny","small","normal","large"], group=grpVMC)
vmcDotFilterByD1K2 = input.bool(true, "Only fire VMC Dot when BOTH D1 & K2 are in OS/OB zone", group=grpVMC)
vmcDotD1K2OS       = input.int(19, "D1/K2 Oversold Level (for Buy Dot)",   minval=0, maxval=100, group=grpVMC)
vmcDotD1K2OB       = input.int(81, "D1/K2 Overbought Level (for Sell Dot)", minval=0, maxval=100, group=grpVMC)
vmcUseRsiFilter = input.bool(true, "Only fire from RSI extremes (oversold/overbought)", group=grpVMC)
vmcRsiOSLevel   = input.int(47, "Bull only if RSI below this",  minval=1, maxval=99, group=grpVMC)
vmcRsiOBLevel   = input.int(53, "Bear only if RSI above this",  minval=1, maxval=99, group=grpVMC)
vmcRequireKD    = input.bool(true, "Only fire when both K & D are under RSI (bull) / above RSI (bear)", group=grpVMC)

grpSing = "=== Singularity Signal ==="
showSing      = input.bool(false, "Show Singularity (💎)", group=grpSing)
col_sing_bull = input.color(color.new(#00e5ff, 0), "Singularity Bull Color", group=grpSing)
col_sing_bear = input.color(color.new(#ff6d00, 0), "Singularity Bear Color", group=grpSing)
singSize      = input.string("normal", "Singularity Size",  options=["tiny","small","normal","large"], group=grpSing)

grpShandoogie = "=== Shandoogie Signal ==="
showShandoogie      = input.bool(true,  "Show Shandoogie Signal", group=grpShandoogie)
shandoogieRequireBG = input.bool(false, "Require background alignment (default: fires independently)", group=grpShandoogie)
col_shand_bull      = input.color(color.new(#00e5ff, 0), "Bull Shandoogie Color", group=grpShandoogie)
col_shand_bear      = input.color(color.new(#ff6d00, 0), "Bear Shandoogie Color", group=grpShandoogie)
shandoogieEmojiBull = input.string("🦅", "Bull Emoji", options=["🦅","🚀","⚡","🔥","💥","🐂"], group=grpShandoogie)
shandoogieEmojiBear = input.string("🦈", "Bear Emoji", options=["🦈","💀","⚡","🔥","💥","🐻"], group=grpShandoogie)
shandoogieSize      = input.string("normal", "Signal Size", options=["tiny","small","normal","large"], group=grpShandoogie)

grpTDIPop = "=== TDIGM Pop Signal ==="
showTDIPop      = input.bool(true,  "Show TDIGM Pop Signal", group=grpTDIPop, tooltip="Fires only when the TDI signal line crosses a band AND closes outside it.")
tdiSource       = input.string("Follow Chart", "Candle Source", options=["Follow Chart","Heikin Ashi","Regular"], group=grpTDIPop, tooltip="Which candles the TDI's RSI is built from. 'Follow Chart' matches whatever style the chart is set to, so the signal agrees with a TDIGM indicator sitting on that same chart. Force Heikin Ashi or Regular to pin it regardless of chart style.")
tdiRsiLen       = input.int(11,  "RSI Period",         minval=1, group=grpTDIPop)
tdiBandLen      = input.int(31,  "Band Length",        minval=1, group=grpTDIPop)
tdiSlowLen      = input.int(1,   "Signal MA Length",   minval=1, group=grpTDIPop, tooltip="Matches 'Slow MA on RSI' in TDIGM. At 1 this is the raw RSI line with no smoothing.")
tdiRequireBG    = input.bool(true, "Require background alignment", group=grpTDIPop)
tdiFilterExtremes = input.bool(true, "Don't chase — block pops from the extreme zones", group=grpTDIPop, tooltip="Blocks a bull pop when the TDI signal line is already at or above the extreme overbought line, and a bear pop when it is already at or below the extreme oversold line. Those are breakouts happening after the move is already stretched. The level is read on the same confirmed bar the pop closes on.")
tdiExtremeOB    = input.int(80, "Extreme Overbought (blocks Bull pop at or above)", minval=1, maxval=99, group=grpTDIPop)
tdiExtremeOS    = input.int(20, "Extreme Oversold (blocks Bear pop at or below)",   minval=1, maxval=99, group=grpTDIPop)
col_tdi_bull    = input.color(color.new(#00e676, 0), "Bull Pop Color", group=grpTDIPop)
col_tdi_bear    = input.color(color.new(#ff1744, 0), "Bear Pop Color", group=grpTDIPop)
tdiPopSize      = input.string("small", "Signal Size", options=["tiny","small","normal","large"], group=grpTDIPop)

grpRecolor = "=== RSI Cross Marker Settings ==="
showCross    = input.bool(false, "Show Cross Markers on RSI Line Cross", group=grpRecolor)
col_cross_up = input.color(color.new(#1abc9c, 0), "Cross Marker - Bull cross color", group=grpRecolor)
col_cross_dn = input.color(color.new(#9c27b0, 0), "Cross Marker - Bear cross color", group=grpRecolor)
rsiCrossSize  = input.string("small", "Cross Marker Size", options=["tiny","small","normal","large"], group=grpRecolor)

grpBvmc = "=== Belfort D1 Cross (BVMC) ==="
showBvmcCross  = input.bool(true, "Show Belfort D1 Cross Signal", group=grpBvmc)
bvmcRsiLen     = input.int(14,    "RSI Length",          minval=1, group=grpBvmc)
bvmcRsiSrc     = input.source(close, "RSI Source",       group=grpBvmc)
bvmcStochLen   = input.int(40,    "D1 Stoch Length",     minval=1, group=grpBvmc)
bvmcSmoothK    = input.int(1,     "D1 K Smooth",         minval=1, group=grpBvmc)
bvmcSmoothD    = input.int(1,     "D1 D Smooth",         minval=1, group=grpBvmc)
col_bvmc_up    = input.color(color.new(#00e676, 0), "Bull Cross Color", group=grpBvmc)
col_bvmc_dn    = input.color(color.new(#ff1744, 0), "Bear Cross Color", group=grpBvmc)
bvmcSize       = input.string("tiny", "Signal Size",  options=["tiny","small","normal","large"], group=grpBvmc)
bvmcUseRsiFilter = input.bool(true, "Only fire from RSI extremes (oversold/overbought)", group=grpBvmc)
bvmcRsiOSLevel   = input.int(47, "Bull Cross only if RSI below this",  minval=1, maxval=99, group=grpBvmc)
bvmcRsiOBLevel   = input.int(53, "Bear Cross only if RSI above this",  minval=1, maxval=99, group=grpBvmc)

grpK2 = "=== K2 Cross (BVMC) ==="
showK2Cross  = input.bool(true, "Show K2 Cross Signal", group=grpK2)
bvmcK2Len    = input.int(80,    "K2 Stoch Length", minval=1, group=grpK2)
bvmcK2Smooth = input.int(1,     "K2 Smooth",       minval=1, group=grpK2)
col_k2_up    = input.color(color.new(#00e676, 0), "Bull Cross Color", group=grpK2)
col_k2_dn    = input.color(color.new(#ff1744, 0), "Bear Cross Color", group=grpK2)
k2Size       = input.string("tiny", "Signal Size",  options=["tiny","small","normal","large"], group=grpK2)
k2FilterExtremes = input.bool(true, "Don't chase — filter out crosses in the extreme opposite zone", group=grpK2)
k2ExtremeOBLevel  = input.int(75, "Extreme Overbought (blocks Bull cross above this)", minval=1, maxval=99, group=grpK2)
k2ExtremeOSLevel  = input.int(25, "Extreme Oversold (blocks Bear cross below this)",   minval=1, maxval=99, group=grpK2)

grpPreview = "=== Live Signal Preview ==="
showLivePreview   = input.bool(true, "Show Live Preview on Forming Candle", group=grpPreview)
previewOpacity    = input.int(55, "Preview Fade (0=solid, 90=barely visible)", minval=0, maxval=90, group=grpPreview)


grpRNL = "=== Round Number Levels ==="
showRNL       = input.bool(false, "Show Round Number Levels", group=grpRNL)
roundStep     = input.int(1000,   "Round Number Interval",    group=grpRNL, minval=1)
col_round     = input.color(color.new(#ffffff, 20), "Round Number Line",      group=grpRNL)
col_086       = input.color(color.new(#00bcd4, 0),  "+86 Line (thicker)",     group=grpRNL)
col_113       = input.color(color.new(#ff9800, 30), "+113 Line",              group=grpRNL)
col_226       = input.color(color.new(#ff9800, 30), "+226 Line",              group=grpRNL)
col_rnlzone   = input.color(color.new(#ff1744, 88), "113-226 Zone Fill",      group=grpRNL)
col_888       = input.color(color.new(#ab47bc, 0),  "888 Level Line",         group=grpRNL)
rnlLblSize    = input.string("small", "Label Text Size", options=["tiny","small","normal","large"], group=grpRNL)
col_lbl_round = input.color(color.new(#ffffff, 0), "Round Number Label Color", group=grpRNL)
col_lbl_086   = input.color(color.new(#00bcd4, 0), "+86 Label Color",          group=grpRNL)
col_lbl_zone  = input.color(color.new(#ff9800, 0), "+113/226 Zone Label Color", group=grpRNL)
col_lbl_888   = input.color(color.new(#ab47bc, 0), "888 Label Color",           group=grpRNL)

grpWR = "=== Winrate Table ==="
showWinrateTable = input.bool(true, "Show Winrate Table", group=grpWR)
wrStopPct        = input.float(4.00, "Stop / Loss Move (%)", minval=0.01, step=0.01, group=grpWR)
wrWinPct1        = input.float(0.27, "Win Target 1 (%)",     minval=0.01, step=0.01, group=grpWR)
wrWinPct2        = input.float(0.33, "Win Target 2 (%)",     minval=0.01, step=0.01, group=grpWR)
wrWinPct3        = input.float(0.50, "Win Target 3 (%)",     minval=0.01, step=0.01, group=grpWR)
wrTablePos        = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpWR)
wrTextSize        = input.string("small", "Table Text Size", options=["tiny","small","normal","large"], group=grpWR)
wrOpenBullColor   = input.color(color.new(#a5d6a7, 0), "Open Signal Color (Bull)", group=grpWR)
wrOpenBearColor   = input.color(color.new(#ef9a9a, 0), "Open Signal Color (Bear)", group=grpWR)

grpQuad = "=== QuadCore 4-Way Confluence ==="
quadUseFilter  = input.bool(false, "Use as filter on ALL signals", group=grpQuad, tooltip="When on, every signal type must also have 4-way stoch confluence agreeing in its direction before it can fire.")
quadColorMode  = input.string("Wick + Border", "Candle Coloring", options=["Off","Wick + Border","Whole Bar"], group=grpQuad, tooltip="Colors the candles while all four stochastics agree. 'Wick + Border' leaves the candle body as-is and only tints the outline and wicks. 'Whole Bar' recolors the entire candle.")
quadColorMatchBg = input.bool(true, "Candle coloring must match background tier", group=grpQuad, tooltip="When on, bull confluence candles only paint while the background is bullish (and vice versa), matching how every signal is gated. Turn off to paint confluence candles regardless of background direction.")
col_quad_candle_bull = input.color(color.new(#00e5ff, 0), "Bull Confluence Candle Color", group=grpQuad)
col_quad_candle_bear = input.color(color.new(#ff6d00, 0), "Bear Confluence Candle Color", group=grpQuad)
quadOB         = input.int(80, "Overbought Level", minval=1, maxval=100, group=grpQuad)
quadOS         = input.int(20, "Oversold Level",   minval=0, maxval=99,  group=grpQuad)
quad1K = input.int(9,  "Stoch 1 K Len", minval=1, group=grpQuad, inline="q1")
quad1D = input.int(3,  "D Smooth",      minval=1, group=grpQuad, inline="q1")
quad2K = input.int(14, "Stoch 2 K Len", minval=1, group=grpQuad, inline="q2")
quad2D = input.int(3,  "D Smooth",      minval=1, group=grpQuad, inline="q2")
quad3K = input.int(40, "Stoch 3 K Len", minval=1, group=grpQuad, inline="q3")
quad3D = input.int(4,  "D Smooth",      minval=1, group=grpQuad, inline="q3")
quad4K = input.int(60, "Stoch 4 K Len", minval=1, group=grpQuad, inline="q4")
quad4D = input.int(10, "D Smooth",      minval=1, group=grpQuad, inline="q4")

grpQuadDiv = "=== QuadCore Divergence ==="
showQuadDiv    = input.bool(true, "Show QuadCore Divergence Signal", group=grpQuadDiv, tooltip="Fires when ANY of the four stochastics shows a divergence against price. Uses QuadCore's tie-tolerant pivot detection, so plateaus at the extremes still count as pivots.")
quadDivS1      = input.bool(true, "Use Stoch 1 (fast)", group=grpQuadDiv, inline="qd")
quadDivS2      = input.bool(true, "Use Stoch 2",        group=grpQuadDiv, inline="qd")
quadDivS3      = input.bool(true, "Use Stoch 3",        group=grpQuadDiv, inline="qd")
quadDivS4      = input.bool(true, "Use Stoch 4 (slow)", group=grpQuadDiv, inline="qd")
quadDivLbL     = input.int(5,  "Pivot Lookback Left",  minval=1, group=grpQuadDiv)
quadDivLbR     = input.int(5,  "Pivot Lookback Right", minval=1, group=grpQuadDiv)
quadDivMinBars = input.int(5,  "Min Bars Between Compared Pivots", minval=1, group=grpQuadDiv)
quadDivMaxBars = input.int(60, "Max Bars Between Compared Pivots", minval=5, group=grpQuadDiv)
quadDivMinAgree  = input.int(2, "Min Stochs That Must Agree", minval=1, maxval=4, group=grpQuadDiv, tooltip="How many of the four stochastics must show the same divergence on the same bar before a signal fires. 1 = any single stoch (most signals), 2 = at least two agree (recommended), 3-4 = very selective.")
quadDivCooldown  = input.int(10, "Cooldown Bars Between Signals", minval=0, group=grpQuadDiv, tooltip="After a QuadCore div fires, block any new one for this many bars. Prevents clusters of signals stacking up during the same move. 0 = no cooldown.")
quadDivBullEmoji = input.string("⬆️", "Bull Divergence Marker", options=["⬆️","🔼","⤴️","↗️","🚀"], group=grpQuadDiv)
quadDivBearEmoji = input.string("⬇️", "Bear Divergence Marker", options=["⬇️","🔽","⤵️","↘️","💧"], group=grpQuadDiv)
col_quaddiv_up = input.color(color.new(#00e5ff, 0), "Bull Divergence Color", group=grpQuadDiv)
col_quaddiv_dn = input.color(color.new(#ff4081, 0), "Bear Divergence Color", group=grpQuadDiv)
quadDivSize    = input.string("small", "Signal Size", options=["tiny","small","normal","large"], group=grpQuadDiv)

grpQTri = "=== QuadCore Triangle ==="
showQTri      = input.bool(true, "Show QuadCore Triangle Signal", group=grpQTri, tooltip="Fires when all four QuadCore stochastics are pointing up AND the SLOWEST one (the Stoch 4 slot) crosses up out of the oversold zone. The slowest is the last to turn, so its exit confirms the whole group has rotated. Bear side is the mirror: all four pointing down and the slowest crossing down out of overbought.")
qtriRequireRising = input.bool(true, "Require all four to be rising", group=grpQTri, tooltip="Off = fire on the zone exit alone, without checking slope.")
qtriRequireBG = input.bool(true, "Require background alignment (HTF filter)", group=grpQTri)
col_qtri_up   = input.color(color.new(#76ff03, 0), "Bull Triangle Color", group=grpQTri)
col_qtri_dn   = input.color(color.new(#ff3d00, 0), "Bear Triangle Color", group=grpQTri)
qtriBullEmoji = input.string("🔺", "Bull Marker", options=["🔺","▲","🟢","⏫","🛎️"], group=grpQTri)
qtriBearEmoji = input.string("🔻", "Bear Marker", options=["🔻","▼","🔴","⏬","🛎️"], group=grpQTri)
qtriSize      = input.string("small", "Signal Size", options=["tiny","small","normal","large"], group=grpQTri)

grpWAR = "=== WAR Formation ==="
showWAR       = input.bool(true, "Show WAR Formation Signal", group=grpWAR, tooltip="Consecutive Heikin Ashi candles all in the same direction, each one strictly stronger than the one before it, with no weakness wick on any of them. Bull needs no lower wick; bear needs no upper wick.")
warSource     = input.string("Follow Chart", "Candle Source", options=["Follow Chart","Heikin Ashi","Regular"], group=grpWAR, tooltip="'Follow Chart' reads the chart's own candles, so on a Heikin Ashi chart it reads HA directly. Force a style to pin it regardless of how the chart is drawn.")
warBars       = input.int(3, "Candles in Formation", minval=2, maxval=6, group=grpWAR)
warWickTicks  = input.float(0.0, "Weakness Wick Tolerance (ticks)", minval=0.0, step=0.5, group=grpWAR, tooltip="How much weakness wick is still allowed, in ticks. 0 = a perfectly flat base (bull) or top (bear) is required. Raise slightly if the formation is too rare on your symbol.")
warGrowRange  = input.bool(false, "Also require total range to grow each candle", group=grpWAR, tooltip="On top of the body growing, require each candle's full high-to-low range to exceed the previous one's.")
warGrowWick   = input.bool(true, "Wick must also grow each candle", group=grpWAR, tooltip="The strength wick has to lengthen on every candle, the same way the body does. For a bull that is the upper wick (high to close, since a clean bull candle has no lower wick); for a bear it is the lower wick (close to low). Body and wick both expanding is what gives the formation its parabolic shape.")
warWickLine   = input.bool(true, "Wick tips must hold the projected line", group=grpWAR, tooltip="Draw a straight line through the first two candles' wick tips and extend it one candle forward. The third candle's wick tip must touch or break that line. This is an acceleration test — the wicks have to keep pace with the rate they were already advancing, not merely make a new extreme. Applied to every consecutive group of three when the formation is longer than three candles.")
warRequireBG  = input.bool(true, "Require background alignment (HTF filter)", group=grpWAR)
col_war_up    = input.color(color.new(#00e676, 0), "Bull WAR Color", group=grpWAR)
col_war_dn    = input.color(color.new(#ff1744, 0), "Bear WAR Color", group=grpWAR)
warBullEmoji  = input.string("⚔️", "Bull Marker", options=["⚔️","🗡️","🔥","🚀","🐂"], group=grpWAR)
warBearEmoji  = input.string("⚔️", "Bear Marker", options=["⚔️","🗡️","🔥","💀","🐻"], group=grpWAR)
warSize       = input.string("normal", "Signal Size", options=["tiny","small","normal","large"], group=grpWAR)

grpStack = "=== Signal Stacking ==="
stackSignals  = input.bool(true, "Stack multiple signals on same candle (best win rate closest to bar)", group=grpStack)
stackSpacing  = input.float(0.35, "Stack Spacing (x ATR)", minval=0.05, step=0.05, group=grpStack)

grpFilt = "=== Signal Filtering ==="
filterL1 = input.bool(false, "Filter Out L1 Tier Signals (require L2+ alignment)", group=grpFilt)
blockUntilT1 = input.bool(true, "Block repeat signals until prior hits Target 1", group=grpFilt, tooltip="Stops the same signal type firing again while its previous trade is still open and has not yet reached win target 1. Each signal type is tracked separately, so a Shandoogie never blocks a TDI Pop. Once the prior trade hits target 1 (or stops out and closes), the block lifts.")
int minSigTier = filterL1 ? 2 : 1

// ══════════════════════════════════════════════════════════════════════════════
//  HA SYMBOL
// ══════════════════════════════════════════════════════════════════════════════
haSymbol = ticker.heikinashi(srcSymbol)

realTicker = ticker.new(syminfo.prefix, syminfo.ticker)
float realOpen = request.security(realTicker, timeframe.period, open, lookahead=barmerge.lookahead_off)
float realHigh = request.security(realTicker, timeframe.period, high, lookahead=barmerge.lookahead_off)
float realLow  = request.security(realTicker, timeframe.period, low,  lookahead=barmerge.lookahead_off)



// ══════════════════════════════════════════════════════════════════════════════
//  6H STREAK
// ══════════════════════════════════════════════════════════════════════════════
f_6hClosed() =>
    bool  dir = close >= open
    int   idx = bar_index
    float c_  = close
    float o_  = open
    [dir, idx, c_, o_]

f_6hLive() =>
    bool  dir = close >= open
    float c_  = close
    float o_  = open
    [dir, c_, o_]

string bgSymbol = bgUseHA ? haSymbol : realTicker

[ha6DirOff,  ha6Idx, ha6C_off,  ha6O_off]  = request.security(bgSymbol, "360", f_6hClosed(), lookahead=barmerge.lookahead_off)
[ha6DirLive, ha6C_live, ha6O_live]          = request.security(bgSymbol, "360", f_6hLive(),   lookahead=barmerge.lookahead_on)

bool ha6NewBar = ta.change(ha6Idx) != 0

var bool ha6D1  = false
var bool ha6D2  = false
var int  ha6Cnt = 0

if ha6NewBar
    ha6D2  := ha6D1
    ha6D1  := ha6DirOff
    ha6Cnt += 1

float r6c   = ha6C_off
float r6o   = ha6O_off
float r6c_l = ha6C_live
float r6o_l = ha6O_live
bool ha6StreakBull = ha6Cnt >= 2 and ha6D1 and ha6D2 and ha6DirLive
bool ha6StreakBear = ha6Cnt >= 2 and not ha6D1 and not ha6D2 and not ha6DirLive
int  sixHLevel    = ha6StreakBull ? 1 : ha6StreakBear ? -1 : 0

bool bull6       = sixHLevel ==  1
bool bear6       = sixHLevel == -1
bool streak6Valid = sixHLevel != 0

// ══════════════════════════════════════════════════════════════════════════════
//  1H HA STATE
// ══════════════════════════════════════════════════════════════════════════════
f_1hState() =>
    bool isBull   = close >= open
    float body    = math.abs(close - open)
    float weakTail = isBull ? math.max(open - low, 0.0) : math.max(high - open, 0.0)
    bool noWeak   = body > 0 and weakTail <= syminfo.mintick
    isBull ? (noWeak ? 2 : 1) : (noWeak ? -2 : -1)

int oneHState      = request.security(bgSymbol, "60", f_1hState(), lookahead=barmerge.lookahead_off)
bool bull1         = oneHState > 0
bool cond_1h_noWeak = math.abs(oneHState) == 2

// ══════════════════════════════════════════════════════════════════════════════
//  MTF LEVELS
// ══════════════════════════════════════════════════════════════════════════════
bool cond_L1_bull = bull6 and streak6Valid
bool cond_L1_bear = bear6 and streak6Valid
bool cond_L2_bull = cond_L1_bull and bull1
bool cond_L2_bear = cond_L1_bear and not bull1
bool cond_L3_bull = cond_L2_bull and cond_1h_noWeak
bool cond_L3_bear = cond_L2_bear and cond_1h_noWeak

int bullLevel = cond_L3_bull ? 3 : cond_L2_bull ? 2 : cond_L1_bull ? 1 : 0
int bearLevel = cond_L3_bear ? 3 : cond_L2_bear ? 2 : cond_L1_bear ? 1 : 0

bool ha6StreakBullConfirmed = ha6Cnt >= 2 and ha6D1 and ha6D2
bool ha6StreakBearConfirmed = ha6Cnt >= 2 and not ha6D1 and not ha6D2
int  sixHLevelConfirmed     = ha6StreakBullConfirmed ? 1 : ha6StreakBearConfirmed ? -1 : 0
bool bull6Confirmed         = sixHLevelConfirmed ==  1
bool bear6Confirmed         = sixHLevelConfirmed == -1
bool streak6ValidConfirmed  = sixHLevelConfirmed != 0

bool cond_L1_bull_c = bull6Confirmed and streak6ValidConfirmed
bool cond_L1_bear_c = bear6Confirmed and streak6ValidConfirmed
bool cond_L2_bull_c = cond_L1_bull_c and bull1
bool cond_L2_bear_c = cond_L1_bear_c and not bull1
bool cond_L3_bull_c = cond_L2_bull_c and cond_1h_noWeak
bool cond_L3_bear_c = cond_L2_bear_c and cond_1h_noWeak

int bullLevelConfirmed = cond_L3_bull_c ? 3 : cond_L2_bull_c ? 2 : cond_L1_bull_c ? 1 : 0
int bearLevelConfirmed = cond_L3_bear_c ? 3 : cond_L2_bear_c ? 2 : cond_L1_bear_c ? 1 : 0

bool sixHKillBullOK = not use6hKill or ha6DirLive
bool sixHKillBearOK = not use6hKill or not ha6DirLive

int bullLevelGated = sixHKillBullOK ? bullLevelConfirmed : 0
int bearLevelGated = sixHKillBearOK ? bearLevelConfirmed : 0

// ══════════════════════════════════════════════════════════════════════════════
//  BACKGROUND
// ══════════════════════════════════════════════════════════════════════════════
int bgBull = bgMatchSignals ? bullLevelGated : bullLevel
int bgBear = bgMatchSignals ? bearLevelGated : bearLevel
color bgCol = bgBull == 3 ? col_bull_l3 : bgBull == 2 ? col_bull_l2 : bgBull == 1 ? col_bull_l1 : bgBear == 3 ? col_bear_l3 : bgBear == 2 ? col_bear_l2 : bgBear == 1 ? col_bear_l1 : na
bgcolor(bgCol, title="MTF Momentum Background")

// ══════════════════════════════════════════════════════════════════════════════
//  RSI
// ══════════════════════════════════════════════════════════════════════════════
float haClose = request.security(haSymbol, timeframe.period, close, lookahead=barmerge.lookahead_on)
float rsiSrc  = useHaRsi ? haClose : close
float rsiRaw  = ta.rsi(rsiSrc, rsiLen)

int smallPer  = math.min(rsiFastLen, rsiSlowLen)
int largePer  = math.max(rsiFastLen, rsiSlowLen)
float rsiFast = ta.sma(rsiRaw, smallPer)
float rsiSlow = ta.sma(rsiRaw, largePer)
bool rsiBull  = rsiFast > rsiSlow

bool crossUp = ta.crossover(rsiFast,  rsiSlow)[1]
bool crossDn = ta.crossunder(rsiFast, rsiSlow)[1]

// ══════════════════════════════════════════════════════════════════════════════
//  DIVERGENCES
// ══════════════════════════════════════════════════════════════════════════════
series float plBar = ta.pivotlow( low,  pivLB, pivLB)
series float phBar = ta.pivothigh(high, pivLB, pivLB)

float pl_price0 = ta.valuewhen(not na(plBar), low[pivLB],   0)
float pl_price1 = ta.valuewhen(not na(plBar), low[pivLB],   1)
float ph_price0 = ta.valuewhen(not na(phBar), high[pivLB],  0)
float ph_price1 = ta.valuewhen(not na(phBar), high[pivLB],  1)
float pl_rsi0   = ta.valuewhen(not na(plBar), rsiRaw[pivLB], 0)
float pl_rsi1   = ta.valuewhen(not na(plBar), rsiRaw[pivLB], 1)
float ph_rsi0   = ta.valuewhen(not na(phBar), rsiRaw[pivLB], 0)
float ph_rsi1   = ta.valuewhen(not na(phBar), rsiRaw[pivLB], 1)

bool plFresh = nz(ta.barssince(not na(plBar)), 999) <= divMaxBars
bool phFresh = nz(ta.barssince(not na(phBar)), 999) <= divMaxBars

bool rsiBullDiv = not na(plBar[1]) and plFresh and pl_price0 < pl_price1 and pl_rsi0 > pl_rsi1
bool rsiBearDiv = not na(phBar[1]) and phFresh and ph_price0 > ph_price1 and ph_rsi0 < ph_rsi1

bool bullDiv = showDivRsi and rsiBullDiv
bool bearDiv = showDivRsi and rsiBearDiv

// ══════════════════════════════════════════════════════════════════════════════
//  SINGULARITY  💎
// ══════════════════════════════════════════════════════════════════════════════
float sg6_c0 = request.security(srcSymbol, "360", close, lookahead=barmerge.lookahead_off)
float sg6_o0 = request.security(srcSymbol, "360", open,  lookahead=barmerge.lookahead_off)
float sg6_h0 = request.security(srcSymbol, "360", high,  lookahead=barmerge.lookahead_off)
float sg6_l0 = request.security(srcSymbol, "360", low,   lookahead=barmerge.lookahead_off)
int   sg6_i0 = request.security(srcSymbol, "360", bar_index, lookahead=barmerge.lookahead_off)

float sg1_c0 = request.security(srcSymbol, "60",  close, lookahead=barmerge.lookahead_off)
float sg1_o0 = request.security(srcSymbol, "60",  open,  lookahead=barmerge.lookahead_off)
float sg1_h0 = request.security(srcSymbol, "60",  high,  lookahead=barmerge.lookahead_off)
float sg1_l0 = request.security(srcSymbol, "60",  low,   lookahead=barmerge.lookahead_off)
int   sg1_i0 = request.security(srcSymbol, "60",  bar_index, lookahead=barmerge.lookahead_off)

var float sg6_c1 = sg6_c0
var float sg6_o1 = sg6_o0
var float sg6_h1 = sg6_h0
var float sg6_l1 = sg6_l0
var float sg1_c1 = sg1_c0
var float sg1_o1 = sg1_o0
var float sg1_h1 = sg1_h0
var float sg1_l1 = sg1_l0

if ta.change(sg6_i0) != 0
    sg6_c1 := sg6_c0[1]
    sg6_o1 := sg6_o0[1]
    sg6_h1 := sg6_h0[1]
    sg6_l1 := sg6_l0[1]

if ta.change(sg1_i0) != 0
    sg1_c1 := sg1_c0[1]
    sg1_o1 := sg1_o0[1]
    sg1_h1 := sg1_h0[1]
    sg1_l1 := sg1_l0[1]

bool s6b0 = sg6_c0 >= sg6_o0
bool s6b1 = sg6_c1 >= sg6_o1
float s6bd0 = math.abs(sg6_c0 - sg6_o0)
float s6bd1 = math.abs(sg6_c1 - sg6_o1)
float s6t0  = s6b0 ? math.max(sg6_o0 - sg6_l0, 0.0) : math.max(sg6_h0 - sg6_o0, 0.0)
float s6t1  = s6b1 ? math.max(sg6_o1 - sg6_l1, 0.0) : math.max(sg6_h1 - sg6_o1, 0.0)
int   sing6h = (s6b0 == s6b1 and s6bd0 > 0 and s6t0 <= syminfo.mintick and s6bd1 > 0 and s6t1 <= syminfo.mintick and s6bd0 > s6bd1) ? (s6b0 ? 1 : -1) : 0

bool s1b0 = sg1_c0 >= sg1_o0
bool s1b1 = sg1_c1 >= sg1_o1
float s1bd0 = math.abs(sg1_c0 - sg1_o0)
float s1bd1 = math.abs(sg1_c1 - sg1_o1)
float s1t0  = s1b0 ? math.max(sg1_o0 - sg1_l0, 0.0) : math.max(sg1_h0 - sg1_o0, 0.0)
float s1t1  = s1b1 ? math.max(sg1_o1 - sg1_l1, 0.0) : math.max(sg1_h1 - sg1_o1, 0.0)
int   sing1h = (s1b0 == s1b1 and s1bd0 > 0 and s1t0 <= syminfo.mintick and s1bd1 > 0 and s1t1 <= syminfo.mintick and s1bd0 > s1bd1) ? (s1b0 ? 1 : -1) : 0

bool singBull    = showSing and sing6h ==  1 and sing1h ==  1
bool singBear    = showSing and sing6h == -1 and sing1h == -1
bool singBullNew = singBull[1] and not singBull[2]
bool singBearNew = singBear[1] and not singBear[2]

// ══════════════════════════════════════════════════════════════════════════════
//  VMC CIPHER B
// ══════════════════════════════════════════════════════════════════════════════
float vmcAP  = hlc3
float vmcESA = ta.ema(vmcAP, vmcN1)
float vmcD   = ta.ema(math.abs(vmcAP - vmcESA), vmcN1)
float vmcCI  = (vmcAP - vmcESA) / (0.015 * vmcD)
float vmcWT1 = ta.ema(vmcCI, vmcN2)
float vmcWT2 = ta.sma(vmcWT1, vmcMALen)

bool vmcBuyDot  = ta.crossover(vmcWT1,  vmcWT2)[1] and vmcWT2[1] <= vmcOS
bool vmcSellDot = ta.crossunder(vmcWT1, vmcWT2)[1] and vmcWT2[1] >= vmcOB

f_vmcTopFractal(src) => src[4] < src[2] and src[3] < src[2] and src[2] > src[1] and src[2] > src[0]
f_vmcBotFractal(src) => src[4] > src[2] and src[3] > src[2] and src[2] < src[1] and src[2] < src[0]

bool vmcIsFractalTop = f_vmcTopFractal(vmcWT2) and vmcWT2[2] >= vmcDivOBLevel
bool vmcIsFractalBot = f_vmcBotFractal(vmcWT2) and vmcWT2[2] <= vmcDivOSLevel

float vmcHighPrev  = ta.valuewhen(vmcIsFractalTop, vmcWT2[2], 0)[2]
float vmcHighPrice = ta.valuewhen(vmcIsFractalTop, high[2],   0)[2]
float vmcLowPrev   = ta.valuewhen(vmcIsFractalBot, vmcWT2[2], 0)[2]
float vmcLowPrice  = ta.valuewhen(vmcIsFractalBot, low[2],    0)[2]

bool vmcBearDiv = (vmcIsFractalTop and high[2] > vmcHighPrice and vmcWT2[2] < vmcHighPrev)[1]
bool vmcBullDiv = (vmcIsFractalBot and low[2]  < vmcLowPrice  and vmcWT2[2] > vmcLowPrev)[1]

// ══════════════════════════════════════════════════════════════════════════════
//  SUPERTREND
// ══════════════════════════════════════════════════════════════════════════════
[stLine, stDir] = ta.supertrend(stMult, stPeriod)

bool stBull = stDir < 0
bool stBear = stDir > 0

bool stFlipBull = stBull[1] and not stBull[2]
bool stFlipBear = stBear[1] and not stBear[2]

plot(showST ? stLine : na, "Supertrend",
     color=stBull ? col_st_bull : col_st_bear,
     linewidth=2, style=plot.style_linebr, display=display.pane)

// ══════════════════════════════════════════════════════════════════════════════
//  BELFORT D1 CROSS (from BVMC indicator)
// ══════════════════════════════════════════════════════════════════════════════
float bvmcRsi = ta.rsi(bvmcRsiSrc, bvmcRsiLen)
float bvmcK1  = ta.sma(ta.stoch(close, high, low, bvmcStochLen), bvmcSmoothK)
float bvmcD1  = ta.sma(bvmcK1, bvmcSmoothD)

bool bvmcBullZoneOK = not bvmcUseRsiFilter or bvmcRsi[1] < bvmcRsiOSLevel
bool bvmcBearZoneOK = not bvmcUseRsiFilter or bvmcRsi[1] > bvmcRsiOBLevel

bool bvmcCrossUp = ta.crossover(bvmcD1, bvmcRsi)[1]  and bvmcBullZoneOK
bool bvmcCrossDn = ta.crossunder(bvmcD1, bvmcRsi)[1] and bvmcBearZoneOK

// ══════════════════════════════════════════════════════════════════════════════
//  K2 CROSS (from BVMC indicator)
// ══════════════════════════════════════════════════════════════════════════════
float bvmcK2 = ta.sma(ta.stoch(close, high, low, bvmcK2Len), bvmcK2Smooth)

bool k2BullZoneOK = not k2FilterExtremes or bvmcRsi[1] < k2ExtremeOBLevel
bool k2BearZoneOK = not k2FilterExtremes or bvmcRsi[1] > k2ExtremeOSLevel

bool k2CrossUp = ta.crossover(bvmcK2, bvmcRsi)[1]  and k2BullZoneOK
bool k2CrossDn = ta.crossunder(bvmcK2, bvmcRsi)[1] and k2BearZoneOK

// ══════════════════════════════════════════════════════════════════════════════
//  QUADCORE 4-WAY CONFLUENCE
// ══════════════════════════════════════════════════════════════════════════════
float quadD1 = ta.sma(ta.stoch(close, high, low, quad1K), quad1D)
float quadD2 = ta.sma(ta.stoch(close, high, low, quad2K), quad2D)
float quadD3 = ta.sma(ta.stoch(close, high, low, quad3K), quad3D)
float quadD4 = ta.sma(ta.stoch(close, high, low, quad4K), quad4D)

bool quadAllOversold   = quadD1 < quadOS and quadD2 < quadOS and quadD3 < quadOS and quadD4 < quadOS
bool quadAllOverbought = quadD1 > quadOB and quadD2 > quadOB and quadD3 > quadOB and quadD4 > quadOB

bool quadBullColorOK = not quadColorMatchBg or bullLevelGated >= minSigTier
bool quadBearColorOK = not quadColorMatchBg or bearLevelGated >= minSigTier
color quadCandleCol = (quadAllOversold and quadBullColorOK) ? col_quad_candle_bull : (quadAllOverbought and quadBearColorOK) ? col_quad_candle_bear : na
bool  quadColorOn   = quadColorMode != "Off" and not na(quadCandleCol)

barcolor(quadColorMode == "Whole Bar" and quadColorOn ? quadCandleCol : na, title="QuadCore Confluence Bar")

plotcandle(quadColorMode == "Wick + Border" and quadColorOn ? open  : na,
     quadColorMode == "Wick + Border" and quadColorOn ? high  : na,
     quadColorMode == "Wick + Border" and quadColorOn ? low   : na,
     quadColorMode == "Wick + Border" and quadColorOn ? close : na,
     title="QuadCore Confluence Outline",
     color=color.new(color.black, 100), wickcolor=quadCandleCol, bordercolor=quadCandleCol)

bool quadBullFilterOK = not quadUseFilter or quadAllOversold[1]
bool quadBearFilterOK = not quadUseFilter or quadAllOverbought[1]

// ══════════════════════════════════════════════════════════════════════════════
//  QUADCORE DIVERGENCE
// ══════════════════════════════════════════════════════════════════════════════
f_quadPivotHigh(src, lbL, lbR) =>
    float pv = src[lbR]
    bool isPivot = true
    for i = 0 to lbL + lbR
        if i != lbR and src[i] > pv
            isPivot := false
    isPivot ? pv : na

f_quadPivotLow(src, lbL, lbR) =>
    float pv = src[lbR]
    bool isPivot = true
    for i = 0 to lbL + lbR
        if i != lbR and src[i] < pv
            isPivot := false
    isPivot ? pv : na

f_quadDiv(osc, enabled) =>
    var plOscArr   = array.new_float(0)
    var plPriceArr = array.new_float(0)
    var plBarArr   = array.new_int(0)
    var phOscArr   = array.new_float(0)
    var phPriceArr = array.new_float(0)
    var phBarArr   = array.new_int(0)
    bool bullFound = false
    bool bearFound = false

    float pl = f_quadPivotLow(osc,  quadDivLbL, quadDivLbR)
    float ph = f_quadPivotHigh(osc, quadDivLbL, quadDivLbR)

    if not na(pl)
        int   curBar   = bar_index[quadDivLbR]
        float curOsc   = pl
        float curPrice = low[quadDivLbR]
        int   idx = array.size(plBarArr) - 1
        while idx >= 0 and not bullFound
            int pBar = array.get(plBarArr, idx)
            int barsBack = curBar - pBar
            if barsBack > quadDivMaxBars
                idx := -1
            else
                if barsBack >= quadDivMinBars
                    float pOsc   = array.get(plOscArr, idx)
                    float pPrice = array.get(plPriceArr, idx)
                    if curOsc > pOsc and curPrice < pPrice and curOsc < quadOS and pOsc < quadOS
                        bullFound := true
                idx -= 1
        array.push(plOscArr, curOsc)
        array.push(plPriceArr, curPrice)
        array.push(plBarArr, curBar)
        if array.size(plBarArr) > 40
            array.shift(plOscArr)
            array.shift(plPriceArr)
            array.shift(plBarArr)

    if not na(ph)
        int   curBarH   = bar_index[quadDivLbR]
        float curOscH   = ph
        float curPriceH = high[quadDivLbR]
        int   idxH = array.size(phBarArr) - 1
        while idxH >= 0 and not bearFound
            int pBarH = array.get(phBarArr, idxH)
            int barsBackH = curBarH - pBarH
            if barsBackH > quadDivMaxBars
                idxH := -1
            else
                if barsBackH >= quadDivMinBars
                    float pOscH   = array.get(phOscArr, idxH)
                    float pPriceH = array.get(phPriceArr, idxH)
                    if curOscH < pOscH and curPriceH > pPriceH and curOscH > quadOB and pOscH > quadOB
                        bearFound := true
                idxH -= 1
        array.push(phOscArr, curOscH)
        array.push(phPriceArr, curPriceH)
        array.push(phBarArr, curBarH)
        if array.size(phBarArr) > 40
            array.shift(phOscArr)
            array.shift(phPriceArr)
            array.shift(phBarArr)

    [bullFound and enabled, bearFound and enabled]

[qd1Bull, qd1Bear] = f_quadDiv(quadD1, quadDivS1)
[qd2Bull, qd2Bear] = f_quadDiv(quadD2, quadDivS2)
[qd3Bull, qd3Bear] = f_quadDiv(quadD3, quadDivS3)
[qd4Bull, qd4Bear] = f_quadDiv(quadD4, quadDivS4)

// Count how many stochs agree on the same bar (each bool is already [1]-confirmed inside f_quadDiv)
int qdBullCount = (qd1Bull ? 1 : 0) + (qd2Bull ? 1 : 0) + (qd3Bull ? 1 : 0) + (qd4Bull ? 1 : 0)
int qdBearCount = (qd1Bear ? 1 : 0) + (qd2Bear ? 1 : 0) + (qd3Bear ? 1 : 0) + (qd4Bear ? 1 : 0)

// Cooldown — track bars since last QuadCore div fired (bull and bear tracked separately)
var int qdBullLastBar = -999
var int qdBearLastBar = -999
bool qdBullCooldownOK = (bar_index - qdBullLastBar) > quadDivCooldown
bool qdBearCooldownOK = (bar_index - qdBearLastBar) > quadDivCooldown

bool quadDivBull = showQuadDiv and (qdBullCount >= quadDivMinAgree)[1] and qdBullCooldownOK
bool quadDivBear = showQuadDiv and (qdBearCount >= quadDivMinAgree)[1] and qdBearCooldownOK

// Update cooldown trackers when a signal fires
if quadDivBull
    qdBullLastBar := bar_index
if quadDivBear
    qdBearLastBar := bar_index

// ══════════════════════════════════════════════════════════════════════════════
//  QUADCORE TRIANGLE
//
//  The trigger is the SLOWEST stochastic (the Stoch 4 slot — 60/10 by
//  default) clearing the oversold line, while all four are pointing up.
//
//  The slowest one is the last to turn, so its exit is the confirmation that
//  the whole group has genuinely rotated rather than just the fast ones
//  whipping. This is deliberately NOT "whichever of the four happened to
//  cross last" — that could be any of them on a given rotation and would
//  fire on faster, less meaningful exits.
//
//  All four stochastics are chart-timeframe, so nothing here repaints; [1]
//  and [2] are both fully closed bars.
// ══════════════════════════════════════════════════════════════════════════════
// Slope check on the confirmed bars — "aimed upwards" into the cross, not
// merely sitting above the level.
bool quadAllRising  = quadD1[1] > quadD1[2] and quadD2[1] > quadD2[2] and quadD3[1] > quadD3[2] and quadD4[1] > quadD4[2]
bool quadAllFalling = quadD1[1] < quadD1[2] and quadD2[1] < quadD2[2] and quadD3[1] < quadD3[2] and quadD4[1] < quadD4[2]

bool qtriRisingOK  = not qtriRequireRising or quadAllRising
bool qtriFallingOK = not qtriRequireRising or quadAllFalling

// Slowest stoch (quadD4) exits the zone on the confirmed bar: at or inside
// the level on [2], clearly outside on [1]. Fires once on the exit bar and
// not again while it stays out.
bool qtriExitOS = quadD4[2] <= quadOS and quadD4[1] > quadOS
bool qtriExitOB = quadD4[2] >= quadOB and quadD4[1] < quadOB

bool qtriBgBullOK = not qtriRequireBG or bullLevelConfirmed >= minSigTier
bool qtriBgBearOK = not qtriRequireBG or bearLevelConfirmed >= minSigTier

bool qtriBull = showQTri and qtriExitOS and qtriRisingOK  and qtriBgBullOK
bool qtriBear = showQTri and qtriExitOB and qtriFallingOK and qtriBgBearOK

// ══════════════════════════════════════════════════════════════════════════════
//  WAR FORMATION
//
//  N consecutive Heikin Ashi candles, all the same direction, each STRICTLY
//  stronger than the one before, none showing a weakness wick.
//
//  "Weakness wick" is directional: on a bull candle it is the lower wick
//  (price dipping below the open before pushing up), on a bear candle the
//  upper wick. A clean bull HA candle opens at its low; any lower wick means
//  the move was contested, which is what separates a real formation from the
//  near-misses that otherwise look similar.
//
//  "Stronger" means the body grows every candle, with an optional extra
//  requirement that the full range grows too.
//
//  Everything is read from bar [1] backwards, so the newest candle in the
//  formation is a closed bar and nothing repaints.
// ══════════════════════════════════════════════════════════════════════════════

// Heikin Ashi OHLC computed inline from the chart's own candles. On a chart
// already set to Heikin Ashi the built-ins ARE the HA values, so "Follow
// Chart" reads them straight through — no second HA calculation running
// alongside the one the chart is drawing.
float warHaC_calc = (open + high + low + close) / 4
var float warHaO_calc = na
warHaO_calc := na(warHaO_calc[1]) ? (open + close) / 2 : (warHaO_calc[1] + warHaC_calc[1]) / 2
float warHaH_calc = math.max(high, math.max(warHaO_calc, warHaC_calc))
float warHaL_calc = math.min(low,  math.min(warHaO_calc, warHaC_calc))

bool warForceReg = warSource == "Regular"
bool warUseCalc  = warSource == "Heikin Ashi" and not chart.is_heikinashi

float warO = warForceReg ? open  : warUseCalc ? warHaO_calc : open
float warH = warForceReg ? high  : warUseCalc ? warHaH_calc : high
float warL = warForceReg ? low   : warUseCalc ? warHaL_calc : low
float warC = warForceReg ? close : warUseCalc ? warHaC_calc : close

float warTol = warWickTicks * syminfo.mintick

// ── Bull: every candle up, flat base, body (and optionally range) growing ──
bool warBullOK = true
for k = 1 to warBars
    float b = warC[k] - warO[k]
    if b <= 0
        warBullOK := false
    if (warO[k] - warL[k]) > warTol
        warBullOK := false
if warBullOK
    for k = 1 to warBars - 1
        float bNew = warC[k]     - warO[k]
        float bOld = warC[k + 1] - warO[k + 1]
        if bNew <= bOld
            warBullOK := false
        // Strength wick for a bull is the upper one: high down to close.
        // Must lengthen every candle, same as the body.
        if warGrowWick and (warH[k] - warC[k]) <= (warH[k + 1] - warC[k + 1])
            warBullOK := false
        if warGrowRange and (warH[k] - warL[k]) <= (warH[k + 1] - warL[k + 1])
            warBullOK := false

// Projected wick line. For each consecutive triple (oldest two define the
// line), extend that line one candle forward and require the newest wick tip
// to reach or exceed it. Two points one bar apart advance by
// (warH[k+1] - warH[k+2]) per bar, so the projection is
// warH[k+1] + that step = 2*warH[k+1] - warH[k+2]. Touching counts, so the
// test only fails when the tip falls short of the line.
if warBullOK and warWickLine
    for k = 1 to warBars - 2
        float projH = 2 * warH[k + 1] - warH[k + 2]
        if warH[k] < projH
            warBullOK := false

// ── Bear: mirror — every candle down, flat top, body growing ──────────────
bool warBearOK = true
for k = 1 to warBars
    float b = warO[k] - warC[k]
    if b <= 0
        warBearOK := false
    if (warH[k] - warO[k]) > warTol
        warBearOK := false
if warBearOK
    for k = 1 to warBars - 1
        float bNew = warO[k]     - warC[k]
        float bOld = warO[k + 1] - warC[k + 1]
        if bNew <= bOld
            warBearOK := false
        // Strength wick for a bear is the lower one: close down to low.
        if warGrowWick and (warC[k] - warL[k]) <= (warC[k + 1] - warL[k + 1])
            warBearOK := false
        if warGrowRange and (warH[k] - warL[k]) <= (warH[k + 1] - warL[k + 1])
            warBearOK := false

// Mirror of the bull projection, run on the wick BOTTOMS: the line through
// the two older lows is extended forward and the newest low must reach or
// break below it.
if warBearOK and warWickLine
    for k = 1 to warBars - 2
        float projL = 2 * warL[k + 1] - warL[k + 2]
        if warL[k] > projL
            warBearOK := false

bool warBgBullOK = not warRequireBG or bullLevelConfirmed >= minSigTier
bool warBgBearOK = not warRequireBG or bearLevelConfirmed >= minSigTier

// Edge-detected. Without this the signal repeats on every bar that the
// formation stays valid: when a further, even stronger candle prints, the
// window slides forward and the new set of candles still satisfies every
// rule, so it would fire again mid-run. A formation is a discrete event, so
// it fires only on the bar the pattern first completes.
bool warBull = showWAR and warBullOK and not warBullOK[1] and warBgBullOK
bool warBear = showWAR and warBearOK and not warBearOK[1] and warBgBearOK

// Composite gates used by every signal type.
//
// These deliberately use bullLevelConfirmed / bearLevelConfirmed, NOT the
// ...Gated versions. The Gated levels fold in ha6DirLive — the direction of
// the still-forming 6H candle, fetched with lookahead_on. That value means
// one thing while the candle is forming and a different thing once it closes,
// so on a chart reload Pine resolves it on historical bars to the candle's
// FINAL direction. Any signal gated on it can therefore evaluate true when
// the bar closes and false after a refresh — the marker prints, a bot acts on
// it, and then it vanishes from history.
//
// bullLevelConfirmed / bearLevelConfirmed are built only from already-CLOSED
// 6H and 1H bars, so once a signal fires on a closed bar it stays fired
// permanently and the chart always matches what fired live.
//
// The live kill switch is still applied to the background paint and the live
// preview layer, where a mid-bar flip is expected and nothing is recorded.
bool bullGateOK = bullLevelConfirmed >= minSigTier and quadBullFilterOK
bool bearGateOK = bearLevelConfirmed >= minSigTier and quadBearFilterOK

// ══════════════════════════════════════════════════════════════════════════════
//  VMC DOT & DIV — OPTIONAL D1/K2 ZONE FILTER
// ══════════════════════════════════════════════════════════════════════════════
bool vmcDotBullZoneOK = not vmcDotFilterByD1K2 or (bvmcD1 <= vmcDotD1K2OS and bvmcK2 <= vmcDotD1K2OS)
bool vmcDotBearZoneOK = not vmcDotFilterByD1K2 or (bvmcD1 >= vmcDotD1K2OB and bvmcK2 >= vmcDotD1K2OB)

bool vmcRsiBullZoneOK = not vmcUseRsiFilter or bvmcRsi[1] < vmcRsiOSLevel
bool vmcRsiBearZoneOK = not vmcUseRsiFilter or bvmcRsi[1] > vmcRsiOBLevel

bool vmcKDBullOK = not vmcRequireKD or (bvmcK2[1] < bvmcRsi[1] and bvmcD1[1] < bvmcRsi[1])
bool vmcKDBearOK = not vmcRequireKD or (bvmcK2[1] > bvmcRsi[1] and bvmcD1[1] > bvmcRsi[1])

bool vmcBuyDotFiltered  = vmcBuyDot  and vmcDotBullZoneOK and vmcRsiBullZoneOK and vmcKDBullOK
bool vmcSellDotFiltered = vmcSellDot and vmcDotBearZoneOK and vmcRsiBearZoneOK and vmcKDBearOK
bool vmcBullDivFiltered = vmcBullDiv and vmcDotBullZoneOK and vmcRsiBullZoneOK and vmcKDBullOK
bool vmcBearDivFiltered = vmcBearDiv and vmcDotBearZoneOK and vmcRsiBearZoneOK and vmcKDBearOK

// ══════════════════════════════════════════════════════════════════════════════
//  SHANDOOGIE SIGNAL
//
//  Fires when QuadCore candle coloring JUST ended (was active on the previous
//  confirmed bar, off on this bar) and the next closed HA candle is a strong
//  flip in the direction that matches what the coloring was:
//    Oversold coloring ended   -> strong bullish HA candle  -> Bull Shandoogie
//    Overbought coloring ended -> strong bearish HA candle  -> Bear Shandoogie
//
//  "Strong" means the HA candle has no weak tail on the opposing side:
//    Bull: HA close > open AND HA open == HA low  (opens at the low, full body)
//    Bear: HA close < open AND HA open == HA high (opens at the high, full body)
//
//  Confirmed on [1] like every other signal — never repaints.
//  Background gating is optional and OFF by default (fires independently of
//  the 6H/1H MTF streak, letting it catch momentum exhaustion/flip moments
//  that can precede the background catching up).
// ══════════════════════════════════════════════════════════════════════════════

// HA open/close at chart timeframe — lookahead_on for the live bar but signal
// always reads at [1] (the confirmed closed bar) so no repainting.
// High/low not needed — direction check only requires open and close.
float haOpen_chart  = request.security(haSymbol, timeframe.period, open,  lookahead=barmerge.lookahead_on)
float haClose_chart = request.security(haSymbol, timeframe.period, close, lookahead=barmerge.lookahead_on)

// Confirmed closed bar HA values
float shand_haO = haOpen_chart[1]
float shand_haC = haClose_chart[1]

// HA candle direction check — any bullish or bearish HA candle qualifies.
// No tail requirement: the question is simply whether the candle after the
// QuadCore block ends agrees in direction with what the coloring was.
// Oversold block (colored bull) -> next closed HA candle must be green (close > open).
// Overbought block (colored bear) -> next closed HA candle must be red  (close < open).
bool shand_haBull = shand_haC > shand_haO
bool shand_haBear = shand_haC < shand_haO

// QuadCore coloring ended: was ON two bars ago (confirmed [2]), OFF last bar (confirmed [1]).
// quadAllOversold requires ALL FOUR stochs below the OS level, so the moment
// ANY ONE crosses back above it quadAllOversold turns false — that's the end of the block.
// Same logic applies to quadAllOverbought on the bear side.
bool shand_oversoldJustEnded   = quadAllOversold[2]   and not quadAllOversold[1]
bool shand_overboughtJustEnded = quadAllOverbought[2] and not quadAllOverbought[1]

// Optional background gate (OFF by default — fires independently)
bool shand_bgBullOK = not shandoogieRequireBG or bullLevelConfirmed >= minSigTier
bool shand_bgBearOK = not shandoogieRequireBG or bearLevelConfirmed >= minSigTier

bool shandoogieBull = showShandoogie and shand_oversoldJustEnded   and shand_haBull and shand_bgBullOK
bool shandoogieBear = showShandoogie and shand_overboughtJustEnded and shand_haBear and shand_bgBearOK

// ══════════════════════════════════════════════════════════════════════════════
//  TDIGM POP SIGNAL
//
//  Bull Pop: the TDI signal line crosses ABOVE the upper band and closes there
//  Bear Pop: the TDI signal line crosses BELOW the lower band and closes there
//
//  Fires on the exact bar the line closes outside the band, and not again
//  while it stays outside.
// ══════════════════════════════════════════════════════════════════════════════
// ── Source ────────────────────────────────────────────────────────────────
// Plain `close` is deliberate and is the whole fix.
//
// The TDIGM indicator uses src = close with no ticker or security calls.
// TradingView feeds an HA chart's values into `close` automatically, so on a
// Heikin Ashi chart TDIGM's RSI is built from HA closes and on a regular
// chart from regular closes — without TDIGM doing anything.
//
// Reading plain `close` here means this TDI is built from the exact same
// series the chart hands TDIGM, bar for bar, on whatever style the chart is
// set to. It agrees by construction rather than by reconstruction.
//
// Every request.security(ticker.heikinashi(...)) approach is a SECOND,
// independent HA calculation. On a regular chart it roughly matched, which
// is why signals looked right there. On an HA chart the chart had already
// applied HA, so that second path was computing from a different series than
// the one being drawn — which is exactly why the markers went off only after
// switching to Heikin Ashi. No ticker rebuild fixes that, because the
// problem is having two HA paths at all. There is now one.
//
// Forcing a style is still available: "Heikin Ashi" computes HA inline from
// the chart's own OHLC (used when the chart is regular), and "Regular" pulls
// unmodified exchange data. "Follow Chart" — the default — reads `close`
// straight through and is what matches TDIGM.
float tdiHaC = (open + high + low + close) / 4

float tdiForcedReg = request.security(realTicker, timeframe.period, close, lookahead=barmerge.lookahead_off)
float tdiForcedHA  = chart.is_heikinashi ? close : tdiHaC

float tdiSrc = tdiSource == "Heikin Ashi" ? tdiForcedHA : tdiSource == "Regular" ? tdiForcedReg : close

float tdiR       = ta.rsi(tdiSrc, tdiRsiLen)
float tdiMa      = ta.sma(tdiR, tdiBandLen)
float tdiOffs    = 1.6185 * ta.stdev(tdiR, tdiBandLen)
float tdiUp      = tdiMa + tdiOffs
float tdiDn      = tdiMa - tdiOffs
float tdiSlowMA  = ta.sma(tdiR, tdiSlowLen)

// ── Cross AND close outside ───────────────────────────────────────────────
// Written as an explicit two-bar test rather than ta.crossover so the
// "closes outside" requirement is visible and exact:
//   bar [2] — the line was inside the band (at or within it)
//   bar [1] — the line's CLOSED value is strictly outside the band
// Both bars are fully closed, so nothing is judged on a forming bar. The
// label draws at bar_index[1], which is bar [1] — the bar that closed
// outside. It cannot fire again while the line stays outside, because the
// [2] test requires it to have been inside one bar earlier.
bool tdiPopRawBull = tdiSlowMA[2] <= tdiUp[2] and tdiSlowMA[1] > tdiUp[1]
bool tdiPopRawBear = tdiSlowMA[2] >= tdiDn[2] and tdiSlowMA[1] < tdiDn[1]

// Background gate (ON by default)
bool tdi_bgBullOK = not tdiRequireBG or bullLevelConfirmed >= minSigTier
bool tdi_bgBearOK = not tdiRequireBG or bearLevelConfirmed >= minSigTier

// Don't-chase filter. Read on bar [1] — the same confirmed bar the pop closes
// on — so the level tested is the one the signal actually fired at.
// A bull pop above the extreme overbought line is a breakout into an already
// stretched move; the bear side mirrors it below extreme oversold.
bool tdiExtremeBullOK = not tdiFilterExtremes or tdiSlowMA[1] < tdiExtremeOB
bool tdiExtremeBearOK = not tdiFilterExtremes or tdiSlowMA[1] > tdiExtremeOS

bool tdiPopBull = showTDIPop and tdiPopRawBull and tdi_bgBullOK and tdiExtremeBullOK
bool tdiPopBear = showTDIPop and tdiPopRawBear and tdi_bgBearOK and tdiExtremeBearOK

// ══════════════════════════════════════════════════════════════════════════════
//  ROUND NUMBER LEVELS
// ══════════════════════════════════════════════════════════════════════════════
float rnl_round = float(math.round(close / roundStep) * roundStep)
float rnl_086   = rnl_round + 86
float rnl_113   = rnl_round + 113
float rnl_226   = rnl_round + 226
float rnl_888   = rnl_round - roundStep + 888

var line  rl_round = na
var line  rl_086   = na
var line  rl_113   = na
var line  rl_226   = na
var line  rl_888   = na
var linefill rl_fill = na
var label lb_round = na
var label lb_086   = na
var label lb_zone  = na
var label lb_888   = na
var float rl_last  = na

if showRNL and (rnl_round != rl_last or na(rl_last))
    rl_last := rnl_round
    if not na(rl_round)
        line.delete(rl_round)
    if not na(rl_086)
        line.delete(rl_086)
    if not na(rl_113)
        line.delete(rl_113)
    if not na(rl_226)
        line.delete(rl_226)
    if not na(rl_888)
        line.delete(rl_888)
    if not na(rl_fill)
        linefill.delete(rl_fill)
    rl_round := line.new(bar_index, rnl_round, bar_index + 1, rnl_round, extend=extend.both, color=col_round, width=1, style=line.style_solid)
    rl_086   := line.new(bar_index, rnl_086,   bar_index + 1, rnl_086,   extend=extend.both, color=col_086,   width=2, style=line.style_solid)
    rl_113   := line.new(bar_index, rnl_113,   bar_index + 1, rnl_113,   extend=extend.both, color=col_113,   width=1, style=line.style_dashed)
    rl_226   := line.new(bar_index, rnl_226,   bar_index + 1, rnl_226,   extend=extend.both, color=col_226,   width=1, style=line.style_dashed)
    rl_888   := line.new(bar_index, rnl_888,   bar_index + 1, rnl_888,   extend=extend.both, color=col_888,   width=1, style=line.style_solid)
    rl_fill  := linefill.new(rl_113, rl_226, col_rnlzone)

if showRNL and barstate.islast
    label.delete(lb_round)
    label.delete(lb_086)
    label.delete(lb_zone)
    label.delete(lb_888)
    lsz = rnlLblSize == "tiny" ? size.tiny : rnlLblSize == "normal" ? size.normal : rnlLblSize == "large" ? size.large : size.small
    lb_round := label.new(bar_index + 2, rnl_round,                  "R "     + str.tostring(int(rnl_round)), color=color.new(col_round, 60), textcolor=col_lbl_round, style=label.style_label_left, size=lsz)
    lb_086   := label.new(bar_index + 2, rnl_086,                    "+86  "  + str.tostring(int(rnl_086)),   color=color.new(col_086,   60), textcolor=col_lbl_086,   style=label.style_label_left, size=lsz)
    lb_zone  := label.new(bar_index + 2, (rnl_113 + rnl_226) / 2,   "+113/+226 ZONE",                        color=color.new(#ff1744,   70), textcolor=col_lbl_zone,  style=label.style_label_left, size=lsz)
    lb_888   := label.new(bar_index + 2, rnl_888,                    "888  "  + str.tostring(int(rnl_888)),   color=color.new(col_888,   60), textcolor=col_lbl_888,   style=label.style_label_left, size=lsz)


// ══════════════════════════════════════════════════════════════════════════════
//  LIVE SIGNAL PREVIEW
// ══════════════════════════════════════════════════════════════════════════════
var label pvCrossBull = na
var label pvCrossBear = na
var label pvVmcBull   = na
var label pvVmcBear   = na
var label pvStBull    = na
var label pvStBear    = na
var label pvBvmcBull  = na
var label pvBvmcBear  = na
var label pvK2Bull    = na
var label pvK2Bear    = na

if not na(pvCrossBull)
    label.delete(pvCrossBull)
    pvCrossBull := na
if not na(pvCrossBear)
    label.delete(pvCrossBear)
    pvCrossBear := na
if not na(pvVmcBull)
    label.delete(pvVmcBull)
    pvVmcBull := na
if not na(pvVmcBear)
    label.delete(pvVmcBear)
    pvVmcBear := na
if not na(pvStBull)
    label.delete(pvStBull)
    pvStBull := na
if not na(pvStBear)
    label.delete(pvStBear)
    pvStBear := na
if not na(pvBvmcBull)
    label.delete(pvBvmcBull)
    pvBvmcBull := na
if not na(pvBvmcBear)
    label.delete(pvBvmcBear)
    pvBvmcBear := na
if not na(pvK2Bull)
    label.delete(pvK2Bull)
    pvK2Bull := na
if not na(pvK2Bear)
    label.delete(pvK2Bear)
    pvK2Bear := na

bool rawLiveCrossUp = ta.crossover(rsiFast, rsiSlow)
bool rawLiveCrossDn = ta.crossunder(rsiFast, rsiSlow)
bool rawLiveVmcUp   = ta.crossover(vmcWT1, vmcWT2)
bool rawLiveVmcDn   = ta.crossunder(vmcWT1, vmcWT2)
bool rawLiveBvmcUp  = ta.crossover(bvmcD1, bvmcRsi)
bool rawLiveBvmcDn  = ta.crossunder(bvmcD1, bvmcRsi)
bool rawLiveK2Up    = ta.crossover(bvmcK2, bvmcRsi)
bool rawLiveK2Dn    = ta.crossunder(bvmcK2, bvmcRsi)

bool liveCrossUp = showCross and rawLiveCrossUp and bullGateOK and rsiRaw < 50
bool liveCrossDn = showCross and rawLiveCrossDn and bearGateOK and rsiRaw > 50
bool liveVmcBuy  = showVMC and rawLiveVmcUp and vmcWT2 <= vmcOS and vmcDotBullZoneOK and (not vmcUseRsiFilter or bvmcRsi < vmcRsiOSLevel) and (not vmcRequireKD or (bvmcK2 < bvmcRsi and bvmcD1 < bvmcRsi)) and bullGateOK
bool liveVmcSell = showVMC and rawLiveVmcDn and vmcWT2 >= vmcOB and vmcDotBearZoneOK and (not vmcUseRsiFilter or bvmcRsi > vmcRsiOBLevel) and (not vmcRequireKD or (bvmcK2 > bvmcRsi and bvmcD1 > bvmcRsi)) and bearGateOK
bool liveStBull  = showST and showSTSignal and stBull and not stBull[1] and bullGateOK
bool liveStBear  = showST and showSTSignal and stBear and not stBear[1] and bearGateOK

bool liveBvmcUp  = showBvmcCross and rawLiveBvmcUp and bvmcBullZoneOK and bullGateOK
bool liveBvmcDn  = showBvmcCross and rawLiveBvmcDn and bvmcBearZoneOK and bearGateOK
bool liveK2Up    = showK2Cross and rawLiveK2Up and k2BullZoneOK and bullGateOK
bool liveK2Dn    = showK2Cross and rawLiveK2Dn and k2BearZoneOK and bearGateOK

if showLivePreview and not barstate.isconfirmed
    if liveCrossUp
        pvCrossBull := label.new(bar_index, na, "", style=label.style_circle, color=color.new(col_cross_up, previewOpacity), yloc=yloc.belowbar, size=rsiCrossSize == "tiny" ? size.tiny : rsiCrossSize == "small" ? size.small : rsiCrossSize == "large" ? size.large : size.normal)
    if liveCrossDn
        pvCrossBear := label.new(bar_index, na, "", style=label.style_circle, color=color.new(col_cross_dn, previewOpacity), yloc=yloc.abovebar, size=rsiCrossSize == "tiny" ? size.tiny : rsiCrossSize == "small" ? size.small : rsiCrossSize == "large" ? size.large : size.normal)
    if liveVmcBuy
        pvVmcBull := label.new(bar_index, na, "", style=label.style_circle, color=color.new(col_vmc_buy, previewOpacity), yloc=yloc.belowbar, size=vmcDotSize == "tiny" ? size.tiny : vmcDotSize == "small" ? size.small : vmcDotSize == "large" ? size.large : size.normal)
    if liveVmcSell
        pvVmcBear := label.new(bar_index, na, "", style=label.style_circle, color=color.new(col_vmc_sell, previewOpacity), yloc=yloc.abovebar, size=vmcDotSize == "tiny" ? size.tiny : vmcDotSize == "small" ? size.small : vmcDotSize == "large" ? size.large : size.normal)
    if liveStBull
        pvStBull := label.new(bar_index, na, "", style=label.style_arrowup, color=color.new(col_st_bull, previewOpacity), yloc=yloc.belowbar, size=stFlipSize == "tiny" ? size.tiny : stFlipSize == "small" ? size.small : stFlipSize == "large" ? size.large : size.normal)
    if liveStBear
        pvStBear := label.new(bar_index, na, "", style=label.style_arrowdown, color=color.new(col_st_bear, previewOpacity), yloc=yloc.abovebar, size=stFlipSize == "tiny" ? size.tiny : stFlipSize == "small" ? size.small : stFlipSize == "large" ? size.large : size.normal)
    if liveBvmcUp
        pvBvmcBull := label.new(bar_index, na, "", style=label.style_xcross, color=color.new(col_bvmc_up, previewOpacity), yloc=yloc.belowbar, size=bvmcSize == "tiny" ? size.tiny : bvmcSize == "small" ? size.small : bvmcSize == "large" ? size.large : size.normal)
    if liveBvmcDn
        pvBvmcBear := label.new(bar_index, na, "", style=label.style_xcross, color=color.new(col_bvmc_dn, previewOpacity), yloc=yloc.abovebar, size=bvmcSize == "tiny" ? size.tiny : bvmcSize == "small" ? size.small : bvmcSize == "large" ? size.large : size.normal)
    if liveK2Up
        pvK2Bull := label.new(bar_index, na, "", style=label.style_square, color=color.new(col_k2_up, previewOpacity), yloc=yloc.belowbar, size=k2Size == "tiny" ? size.tiny : k2Size == "small" ? size.small : k2Size == "large" ? size.large : size.normal)
    if liveK2Dn
        pvK2Bear := label.new(bar_index, na, "", style=label.style_square, color=color.new(col_k2_dn, previewOpacity), yloc=yloc.abovebar, size=k2Size == "tiny" ? size.tiny : k2Size == "small" ? size.small : k2Size == "large" ? size.large : size.normal)

// ══════════════════════════════════════════════════════════════════════════════
//  WINRATE TRACKING
// ══════════════════════════════════════════════════════════════════════════════
f_formatSince(firstTime) =>
    if na(firstTime)
        "—"
    else
        float hoursElapsed = (time - firstTime) / (1000.0 * 60 * 60)
        hoursElapsed < 24 ? str.tostring(hoursElapsed, "#.#") + "h" : str.tostring(hoursElapsed / 24, "#.#") + "d"

f_buildTooltip(catName, dir, entryPx, r1, r2, r3, w1, w2, w3, stopped, catWins1, catTotal1, catWins2, catTotal2, catWins3, catTotal3, catFired, catStreak, catFirstTime) =>
    string dirStr = dir == 1 ? "Long" : "Short"
    float  tp1Px  = dir == 1 ? entryPx * (1 + w1 / 100) : entryPx * (1 - w1 / 100)
    float  tp2Px  = dir == 1 ? entryPx * (1 + w2 / 100) : entryPx * (1 - w2 / 100)
    float  tp3Px  = dir == 1 ? entryPx * (1 + w3 / 100) : entryPx * (1 - w3 / 100)
    float  stopPx = dir == 1 ? entryPx * (1 - wrStopPct / 100) : entryPx * (1 + wrStopPct / 100)
    string s1 = r1 ? "WIN" : stopped ? "LOSS" : "Pending"
    string s2 = r2 ? "WIN" : stopped ? "LOSS" : "Pending"
    string s3 = r3 ? "WIN" : stopped ? "LOSS" : "Pending"
    string statusStr = stopped ? "Stopped Out" : (r1 and r2 and r3 ? "All Targets Hit" : "Open")
    string wr1 = catTotal1 > 0 ? str.tostring(100.0 * catWins1 / catTotal1, "#.0") + "%" : "—"
    string wr2 = catTotal2 > 0 ? str.tostring(100.0 * catWins2 / catTotal2, "#.0") + "%" : "—"
    string wr3 = catTotal3 > 0 ? str.tostring(100.0 * catWins3 / catTotal3, "#.0") + "%" : "—"
    int    catLosses = catTotal1 - catWins1
    catName + " " + dirStr + " @ " + str.tostring(entryPx, format.mintick) + "\n" +
     "Stop " + str.tostring(stopPx, format.mintick) + "\n" +
     str.tostring(w1, "#.##") + "% Target " + str.tostring(tp1Px, format.mintick) + ": " + s1 + "\n" +
     str.tostring(w2, "#.##") + "% Target " + str.tostring(tp2Px, format.mintick) + ": " + s2 + "\n" +
     str.tostring(w3, "#.##") + "% Target " + str.tostring(tp3Px, format.mintick) + ": " + s3 + "\n" +
     "Status: " + statusStr + "\n" +
     "───────────────\n" +
     catName + " overall\n" +
     "Win rate: " + wr1 + " / " + wr2 + " / " + wr3 + "\n" +
     "Record: " + str.tostring(catWins1) + "W - " + str.tostring(catLosses) + "L\n" +
     "Signals fired: " + str.tostring(catFired) + "\n" +
     "Current streak: " + str.tostring(catStreak) + "\n" +
     "Tracked for: " + f_formatSince(catFirstTime)

f_pushOpenTrade(entryArr, dirArr, res1Arr, res2Arr, res3Arr, labelArr, dir, lbl, catName, catWins1, catTotal1, catWins2, catTotal2, catWins3, catTotal3, catFired, catStreak, catFirstTime) =>
    float entryPx = realOpen
    array.push(entryArr, entryPx)
    array.push(dirArr, dir)
    array.push(res1Arr, false)
    array.push(res2Arr, false)
    array.push(res3Arr, false)
    array.push(labelArr, lbl)
    if not na(lbl)
        label.set_tooltip(lbl, f_buildTooltip(catName, dir, entryPx, false, false, false, wrWinPct1, wrWinPct2, wrWinPct3, false, catWins1, catTotal1, catWins2, catTotal2, catWins3, catTotal3, catFired, catStreak, catFirstTime))
        label.set_color(lbl, dir == 1 ? wrOpenBullColor : wrOpenBearColor)

f_gradeOpenTrades(entryArr, dirArr, res1Arr, res2Arr, res3Arr, labelArr, w1, w2, w3, stopPct, catName, winColorBull, winColorBear, catWins1, catTotal1, catWins2, catTotal2, catWins3, catTotal3, catFired, catStreak, catFirstTime) =>
    int dw1 = 0
    int dt1 = 0
    int dw2 = 0
    int dt2 = 0
    int dw3 = 0
    int dt3 = 0
    int i = array.size(entryArr) - 1
    while i >= 0
        float e   = array.get(entryArr, i)
        int   d   = array.get(dirArr, i)
        bool  r1  = array.get(res1Arr, i)
        bool  r2  = array.get(res2Arr, i)
        bool  r3  = array.get(res3Arr, i)
        label lbl = array.get(labelArr, i)
        bool stopHit = d == 1 ? realLow <= e * (1 - stopPct / 100) : realHigh >= e * (1 + stopPct / 100)
        if stopHit
            if not r1
                dt1 := dt1 + 1
            if not r2
                dt2 := dt2 + 1
            if not r3
                dt3 := dt3 + 1
            if not na(lbl)
                label.set_tooltip(lbl, f_buildTooltip(catName, d, e, r1, r2, r3, w1, w2, w3, true, catWins1, catTotal1, catWins2, catTotal2, catWins3, catTotal3, catFired, catStreak, catFirstTime))
            if not r1 and not na(lbl)
                label.set_color(lbl, color.white)
            array.remove(entryArr, i)
            array.remove(dirArr, i)
            array.remove(res1Arr, i)
            array.remove(res2Arr, i)
            array.remove(res3Arr, i)
            array.remove(labelArr, i)
        else
            bool hit1 = d == 1 ? realHigh >= e * (1 + w1 / 100) : realLow <= e * (1 - w1 / 100)
            bool hit2 = d == 1 ? realHigh >= e * (1 + w2 / 100) : realLow <= e * (1 - w2 / 100)
            bool hit3 = d == 1 ? realHigh >= e * (1 + w3 / 100) : realLow <= e * (1 - w3 / 100)
            bool newR1 = r1
            bool newR2 = r2
            bool newR3 = r3
            if not r1 and hit1
                dw1 := dw1 + 1
                dt1 := dt1 + 1
                newR1 := true
                if not na(lbl)
                    label.set_color(lbl, d == 1 ? winColorBull : winColorBear)
            if not r2 and hit2
                dw2 := dw2 + 1
                dt2 := dt2 + 1
                newR2 := true
            if not r3 and hit3
                dw3 := dw3 + 1
                dt3 := dt3 + 1
                newR3 := true
            if newR1 != r1
                array.set(res1Arr, i, newR1)
            if newR2 != r2
                array.set(res2Arr, i, newR2)
            if newR3 != r3
                array.set(res3Arr, i, newR3)
            if (newR1 != r1 or newR2 != r2 or newR3 != r3) and not na(lbl)
                label.set_tooltip(lbl, f_buildTooltip(catName, d, e, newR1, newR2, newR3, w1, w2, w3, false, catWins1, catTotal1, catWins2, catTotal2, catWins3, catTotal3, catFired, catStreak, catFirstTime))
            if newR1 and newR2 and newR3
                array.remove(entryArr, i)
                array.remove(dirArr, i)
                array.remove(res1Arr, i)
                array.remove(res2Arr, i)
                array.remove(res3Arr, i)
                array.remove(labelArr, i)
        i := i - 1
    [dw1, dt1, dw2, dt2, dw3, dt3]

// ── Open-trade arrays + counters per signal category ────────────────────────
var array<float> wrCrossEntry = array.new<float>()
var array<int>   wrCrossDir   = array.new<int>()
var array<bool>  wrCrossRes1  = array.new<bool>()
var array<bool>  wrCrossRes2  = array.new<bool>()
var array<bool>  wrCrossRes3  = array.new<bool>()
var array<label> wrCrossLabel = array.new<label>()
var int wrCrossFired = 0
var float wrCrossFirstTime = na
var int wrCrossLongFired = 0
var int wrCrossShortFired = 0
var int wrCrossWins1 = 0
var int wrCrossStreak = 0
var int wrCrossTotal1 = 0
var int wrCrossWins2 = 0
var int wrCrossTotal2 = 0
var int wrCrossWins3 = 0
var int wrCrossTotal3 = 0

var array<float> wrDivEntry = array.new<float>()
var array<int>   wrDivDir   = array.new<int>()
var array<bool>  wrDivRes1  = array.new<bool>()
var array<bool>  wrDivRes2  = array.new<bool>()
var array<bool>  wrDivRes3  = array.new<bool>()
var array<label> wrDivLabel = array.new<label>()
var int wrDivFired = 0
var float wrDivFirstTime = na
var int wrDivLongFired = 0
var int wrDivShortFired = 0
var int wrDivWins1 = 0
var int wrDivStreak = 0
var int wrDivTotal1 = 0
var int wrDivWins2 = 0
var int wrDivTotal2 = 0
var int wrDivWins3 = 0
var int wrDivTotal3 = 0

var array<float> wrVmcDotEntry = array.new<float>()
var array<int>   wrVmcDotDir   = array.new<int>()
var array<bool>  wrVmcDotRes1  = array.new<bool>()
var array<bool>  wrVmcDotRes2  = array.new<bool>()
var array<bool>  wrVmcDotRes3  = array.new<bool>()
var array<label> wrVmcDotLabel = array.new<label>()
var int wrVmcDotFired = 0
var float wrVmcDotFirstTime = na
var int wrVmcDotLongFired = 0
var int wrVmcDotShortFired = 0
var int wrVmcDotWins1 = 0
var int wrVmcDotStreak = 0
var int wrVmcDotTotal1 = 0
var int wrVmcDotWins2 = 0
var int wrVmcDotTotal2 = 0
var int wrVmcDotWins3 = 0
var int wrVmcDotTotal3 = 0

var array<float> wrVmcDivEntry = array.new<float>()
var array<int>   wrVmcDivDir   = array.new<int>()
var array<bool>  wrVmcDivRes1  = array.new<bool>()
var array<bool>  wrVmcDivRes2  = array.new<bool>()
var array<bool>  wrVmcDivRes3  = array.new<bool>()
var array<label> wrVmcDivLabel = array.new<label>()
var int wrVmcDivFired = 0
var float wrVmcDivFirstTime = na
var int wrVmcDivLongFired = 0
var int wrVmcDivShortFired = 0
var int wrVmcDivWins1 = 0
var int wrVmcDivStreak = 0
var int wrVmcDivTotal1 = 0
var int wrVmcDivWins2 = 0
var int wrVmcDivTotal2 = 0
var int wrVmcDivWins3 = 0
var int wrVmcDivTotal3 = 0

var array<float> wrStEntry = array.new<float>()
var array<int>   wrStDir   = array.new<int>()
var array<bool>  wrStRes1  = array.new<bool>()
var array<bool>  wrStRes2  = array.new<bool>()
var array<bool>  wrStRes3  = array.new<bool>()
var array<label> wrStLabel = array.new<label>()
var int wrStFired = 0
var float wrStFirstTime = na
var int wrStLongFired = 0
var int wrStShortFired = 0
var int wrStWins1 = 0
var int wrStStreak = 0
var int wrStTotal1 = 0
var int wrStWins2 = 0
var int wrStTotal2 = 0
var int wrStWins3 = 0
var int wrStTotal3 = 0

var array<float> wrBvmcEntry = array.new<float>()
var array<int>   wrBvmcDir   = array.new<int>()
var array<bool>  wrBvmcRes1  = array.new<bool>()
var array<bool>  wrBvmcRes2  = array.new<bool>()
var array<bool>  wrBvmcRes3  = array.new<bool>()
var array<label> wrBvmcLabel = array.new<label>()
var int wrBvmcFired = 0
var float wrBvmcFirstTime = na
var int wrBvmcLongFired = 0
var int wrBvmcShortFired = 0
var int wrBvmcWins1 = 0
var int wrBvmcStreak = 0
var int wrBvmcTotal1 = 0
var int wrBvmcWins2 = 0
var int wrBvmcTotal2 = 0
var int wrBvmcWins3 = 0
var int wrBvmcTotal3 = 0

var array<float> wrK2Entry = array.new<float>()
var array<int>   wrK2Dir   = array.new<int>()
var array<bool>  wrK2Res1  = array.new<bool>()
var array<bool>  wrK2Res2  = array.new<bool>()
var array<bool>  wrK2Res3  = array.new<bool>()
var array<label> wrK2Label = array.new<label>()
var int wrK2Fired = 0
var float wrK2FirstTime = na
var int wrK2LongFired = 0
var int wrK2ShortFired = 0
var int wrK2Wins1 = 0
var int wrK2Streak = 0
var int wrK2Total1 = 0
var int wrK2Wins2 = 0
var int wrK2Total2 = 0
var int wrK2Wins3 = 0
var int wrK2Total3 = 0

var array<float> wrQDivEntry = array.new<float>()
var array<int>   wrQDivDir   = array.new<int>()
var array<bool>  wrQDivRes1  = array.new<bool>()
var array<bool>  wrQDivRes2  = array.new<bool>()
var array<bool>  wrQDivRes3  = array.new<bool>()
var array<label> wrQDivLabel = array.new<label>()
var int wrQDivFired = 0
var float wrQDivFirstTime = na
var int wrQDivLongFired = 0
var int wrQDivShortFired = 0
var int wrQDivWins1 = 0
var int wrQDivStreak = 0
var int wrQDivTotal1 = 0
var int wrQDivWins2 = 0
var int wrQDivTotal2 = 0
var int wrQDivWins3 = 0
var int wrQDivTotal3 = 0

var array<float> wrSingEntry = array.new<float>()
var array<int>   wrSingDir   = array.new<int>()
var array<bool>  wrSingRes1  = array.new<bool>()
var array<bool>  wrSingRes2  = array.new<bool>()
var array<bool>  wrSingRes3  = array.new<bool>()
var array<label> wrSingLabel = array.new<label>()
var int wrSingFired = 0
var int wrSingStreak = 0
var float wrSingFirstTime = na
var int wrSingLongFired = 0
var int wrSingShortFired = 0
var int wrSingWins1 = 0
var int wrSingTotal1 = 0
var int wrSingWins2 = 0
var int wrSingTotal2 = 0
var int wrSingWins3 = 0
var int wrSingTotal3 = 0

var array<float> wrShandEntry = array.new<float>()
var array<int>   wrShandDir   = array.new<int>()
var array<bool>  wrShandRes1  = array.new<bool>()
var array<bool>  wrShandRes2  = array.new<bool>()
var array<bool>  wrShandRes3  = array.new<bool>()
var array<label> wrShandLabel = array.new<label>()
var int   wrShandFired      = 0
var float wrShandFirstTime  = na
var int   wrShandLongFired  = 0
var int   wrShandShortFired = 0
var int   wrShandWins1      = 0
var int   wrShandStreak     = 0
var int   wrShandTotal1     = 0
var int   wrShandWins2      = 0
var int   wrShandTotal2     = 0
var int   wrShandWins3      = 0
var int   wrShandTotal3     = 0

var array<float> wrTDIEntry = array.new<float>()
var array<int>   wrTDIDir   = array.new<int>()
var array<bool>  wrTDIRes1  = array.new<bool>()
var array<bool>  wrTDIRes2  = array.new<bool>()
var array<bool>  wrTDIRes3  = array.new<bool>()
var array<label> wrTDILabel = array.new<label>()
var int   wrTDIFired      = 0
var float wrTDIFirstTime  = na
var int   wrTDILongFired  = 0
var int   wrTDIShortFired = 0
var int   wrTDIWins1      = 0
var int   wrTDIStreak     = 0
var int   wrTDITotal1     = 0
var int   wrTDIWins2      = 0
var int   wrTDITotal2     = 0
var int   wrTDIWins3      = 0
var int   wrTDITotal3     = 0

var array<float> wrQTriEntry = array.new<float>()
var array<int>   wrQTriDir   = array.new<int>()
var array<bool>  wrQTriRes1  = array.new<bool>()
var array<bool>  wrQTriRes2  = array.new<bool>()
var array<bool>  wrQTriRes3  = array.new<bool>()
var array<label> wrQTriLabel = array.new<label>()
var int   wrQTriFired      = 0
var float wrQTriFirstTime  = na
var int   wrQTriLongFired  = 0
var int   wrQTriShortFired = 0
var int   wrQTriWins1      = 0
var int   wrQTriStreak     = 0
var int   wrQTriTotal1     = 0
var int   wrQTriWins2      = 0
var int   wrQTriTotal2     = 0
var int   wrQTriWins3      = 0
var int   wrQTriTotal3     = 0

var array<float> wrWAREntry = array.new<float>()
var array<int>   wrWARDir   = array.new<int>()
var array<bool>  wrWARRes1  = array.new<bool>()
var array<bool>  wrWARRes2  = array.new<bool>()
var array<bool>  wrWARRes3  = array.new<bool>()
var array<label> wrWARLabel = array.new<label>()
var int   wrWARFired      = 0
var float wrWARFirstTime  = na
var int   wrWARLongFired  = 0
var int   wrWARShortFired = 0
var int   wrWARWins1      = 0
var int   wrWARStreak     = 0
var int   wrWARTotal1     = 0
var int   wrWARWins2      = 0
var int   wrWARTotal2     = 0
var int   wrWARWins3      = 0
var int   wrWARTotal3     = 0

// ── Grade first ──────────────────────────────────────────────────────────────
f_updateStreak(streak, dw, dt) =>
    int newStreak = streak
    if dt > 0
        if dw == dt
            newStreak := streak + dw
        else if dw == 0
            newStreak := 0
        else
            newStreak := dw
    newStreak

[cxw1, cxt1, cxw2, cxt2, cxw3, cxt3] = f_gradeOpenTrades(wrCrossEntry, wrCrossDir, wrCrossRes1, wrCrossRes2, wrCrossRes3, wrCrossLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "RSI Cross", col_cross_up, col_cross_dn, wrCrossWins1, wrCrossTotal1, wrCrossWins2, wrCrossTotal2, wrCrossWins3, wrCrossTotal3, wrCrossFired, wrCrossStreak, wrCrossFirstTime)
wrCrossWins1 += cxw1
wrCrossTotal1 += cxt1
wrCrossWins2 += cxw2
wrCrossTotal2 += cxt2
wrCrossWins3 += cxw3
wrCrossTotal3 += cxt3
wrCrossStreak := f_updateStreak(wrCrossStreak, cxw1, cxt1)

[dvw1, dvt1, dvw2, dvt2, dvw3, dvt3] = f_gradeOpenTrades(wrDivEntry, wrDivDir, wrDivRes1, wrDivRes2, wrDivRes3, wrDivLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "RSI Div", col_bull_div, col_bear_div, wrDivWins1, wrDivTotal1, wrDivWins2, wrDivTotal2, wrDivWins3, wrDivTotal3, wrDivFired, wrDivStreak, wrDivFirstTime)
wrDivWins1 += dvw1
wrDivTotal1 += dvt1
wrDivWins2 += dvw2
wrDivTotal2 += dvt2
wrDivWins3 += dvw3
wrDivTotal3 += dvt3
wrDivStreak := f_updateStreak(wrDivStreak, dvw1, dvt1)

[vdw1, vdt1, vdw2, vdt2, vdw3, vdt3] = f_gradeOpenTrades(wrVmcDotEntry, wrVmcDotDir, wrVmcDotRes1, wrVmcDotRes2, wrVmcDotRes3, wrVmcDotLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "VMC Dot", col_vmc_buy, col_vmc_sell, wrVmcDotWins1, wrVmcDotTotal1, wrVmcDotWins2, wrVmcDotTotal2, wrVmcDotWins3, wrVmcDotTotal3, wrVmcDotFired, wrVmcDotStreak, wrVmcDotFirstTime)
wrVmcDotWins1 += vdw1
wrVmcDotTotal1 += vdt1
wrVmcDotWins2 += vdw2
wrVmcDotTotal2 += vdt2
wrVmcDotWins3 += vdw3
wrVmcDotTotal3 += vdt3
wrVmcDotStreak := f_updateStreak(wrVmcDotStreak, vdw1, vdt1)

[vvw1, vvt1, vvw2, vvt2, vvw3, vvt3] = f_gradeOpenTrades(wrVmcDivEntry, wrVmcDivDir, wrVmcDivRes1, wrVmcDivRes2, wrVmcDivRes3, wrVmcDivLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "VMC Div", col_vmc_buy, col_vmc_sell, wrVmcDivWins1, wrVmcDivTotal1, wrVmcDivWins2, wrVmcDivTotal2, wrVmcDivWins3, wrVmcDivTotal3, wrVmcDivFired, wrVmcDivStreak, wrVmcDivFirstTime)
wrVmcDivWins1 += vvw1
wrVmcDivTotal1 += vvt1
wrVmcDivWins2 += vvw2
wrVmcDivTotal2 += vvt2
wrVmcDivWins3 += vvw3
wrVmcDivTotal3 += vvt3
wrVmcDivStreak := f_updateStreak(wrVmcDivStreak, vvw1, vvt1)

[stw1, stt1, stw2, stt2, stw3, stt3] = f_gradeOpenTrades(wrStEntry, wrStDir, wrStRes1, wrStRes2, wrStRes3, wrStLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "S/T", col_st_bull, col_st_bear, wrStWins1, wrStTotal1, wrStWins2, wrStTotal2, wrStWins3, wrStTotal3, wrStFired, wrStStreak, wrStFirstTime)
wrStWins1 += stw1
wrStTotal1 += stt1
wrStWins2 += stw2
wrStTotal2 += stt2
wrStWins3 += stw3
wrStTotal3 += stt3
wrStStreak := f_updateStreak(wrStStreak, stw1, stt1)

[bvw1, bvt1, bvw2, bvt2, bvw3, bvt3] = f_gradeOpenTrades(wrBvmcEntry, wrBvmcDir, wrBvmcRes1, wrBvmcRes2, wrBvmcRes3, wrBvmcLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "D1 Cross", col_bvmc_up, col_bvmc_dn, wrBvmcWins1, wrBvmcTotal1, wrBvmcWins2, wrBvmcTotal2, wrBvmcWins3, wrBvmcTotal3, wrBvmcFired, wrBvmcStreak, wrBvmcFirstTime)
wrBvmcWins1 += bvw1
wrBvmcTotal1 += bvt1
wrBvmcWins2 += bvw2
wrBvmcTotal2 += bvt2
wrBvmcWins3 += bvw3
wrBvmcTotal3 += bvt3
wrBvmcStreak := f_updateStreak(wrBvmcStreak, bvw1, bvt1)

[k2w1, k2t1, k2w2, k2t2, k2w3, k2t3] = f_gradeOpenTrades(wrK2Entry, wrK2Dir, wrK2Res1, wrK2Res2, wrK2Res3, wrK2Label, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "K2 Cross", col_k2_up, col_k2_dn, wrK2Wins1, wrK2Total1, wrK2Wins2, wrK2Total2, wrK2Wins3, wrK2Total3, wrK2Fired, wrK2Streak, wrK2FirstTime)
wrK2Wins1 += k2w1
wrK2Total1 += k2t1
wrK2Wins2 += k2w2
wrK2Total2 += k2t2
wrK2Wins3 += k2w3
wrK2Total3 += k2t3
wrK2Streak := f_updateStreak(wrK2Streak, k2w1, k2t1)

[sgw1, sgt1, sgw2, sgt2, sgw3, sgt3] = f_gradeOpenTrades(wrSingEntry, wrSingDir, wrSingRes1, wrSingRes2, wrSingRes3, wrSingLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "Singularity", col_sing_bull, col_sing_bear, wrSingWins1, wrSingTotal1, wrSingWins2, wrSingTotal2, wrSingWins3, wrSingTotal3, wrSingFired, wrSingStreak, wrSingFirstTime)
wrSingWins1 += sgw1
wrSingTotal1 += sgt1
wrSingWins2 += sgw2
wrSingTotal2 += sgt2
wrSingWins3 += sgw3
wrSingTotal3 += sgt3

[qvw1, qvt1, qvw2, qvt2, qvw3, qvt3] = f_gradeOpenTrades(wrQDivEntry, wrQDivDir, wrQDivRes1, wrQDivRes2, wrQDivRes3, wrQDivLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "QuadCore Div", col_quaddiv_up, col_quaddiv_dn, wrQDivWins1, wrQDivTotal1, wrQDivWins2, wrQDivTotal2, wrQDivWins3, wrQDivTotal3, wrQDivFired, wrQDivStreak, wrQDivFirstTime)
wrQDivWins1 += qvw1
wrQDivTotal1 += qvt1
wrQDivWins2 += qvw2
wrQDivTotal2 += qvt2
wrQDivWins3 += qvw3
wrQDivTotal3 += qvt3
wrQDivStreak := f_updateStreak(wrQDivStreak, qvw1, qvt1)

[shw1, sht1, shw2, sht2, shw3, sht3] = f_gradeOpenTrades(wrShandEntry, wrShandDir, wrShandRes1, wrShandRes2, wrShandRes3, wrShandLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "Shandoogie", col_shand_bull, col_shand_bear, wrShandWins1, wrShandTotal1, wrShandWins2, wrShandTotal2, wrShandWins3, wrShandTotal3, wrShandFired, wrShandStreak, wrShandFirstTime)
wrShandWins1  += shw1
wrShandTotal1 += sht1
wrShandWins2  += shw2
wrShandTotal2 += sht2
wrShandWins3  += shw3
wrShandTotal3 += sht3
wrShandStreak := f_updateStreak(wrShandStreak, shw1, sht1)

[tdw1, tdt1, tdw2, tdt2, tdw3, tdt3] = f_gradeOpenTrades(wrTDIEntry, wrTDIDir, wrTDIRes1, wrTDIRes2, wrTDIRes3, wrTDILabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "TDI Pop", col_tdi_bull, col_tdi_bear, wrTDIWins1, wrTDITotal1, wrTDIWins2, wrTDITotal2, wrTDIWins3, wrTDITotal3, wrTDIFired, wrTDIStreak, wrTDIFirstTime)
wrTDIWins1  += tdw1
wrTDITotal1 += tdt1
wrTDIWins2  += tdw2
wrTDITotal2 += tdt2
wrTDIWins3  += tdw3
wrTDITotal3 += tdt3
wrTDIStreak := f_updateStreak(wrTDIStreak, tdw1, tdt1)

[qtw1, qtt1, qtw2, qtt2, qtw3, qtt3] = f_gradeOpenTrades(wrQTriEntry, wrQTriDir, wrQTriRes1, wrQTriRes2, wrQTriRes3, wrQTriLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "Quad Tri", col_qtri_up, col_qtri_dn, wrQTriWins1, wrQTriTotal1, wrQTriWins2, wrQTriTotal2, wrQTriWins3, wrQTriTotal3, wrQTriFired, wrQTriStreak, wrQTriFirstTime)
wrQTriWins1  += qtw1
wrQTriTotal1 += qtt1
wrQTriWins2  += qtw2
wrQTriTotal2 += qtt2
wrQTriWins3  += qtw3
wrQTriTotal3 += qtt3
wrQTriStreak := f_updateStreak(wrQTriStreak, qtw1, qtt1)

[waw1, wat1, waw2, wat2, waw3, wat3] = f_gradeOpenTrades(wrWAREntry, wrWARDir, wrWARRes1, wrWARRes2, wrWARRes3, wrWARLabel, wrWinPct1, wrWinPct2, wrWinPct3, wrStopPct, "WAR", col_war_up, col_war_dn, wrWARWins1, wrWARTotal1, wrWARWins2, wrWARTotal2, wrWARWins3, wrWARTotal3, wrWARFired, wrWARStreak, wrWARFirstTime)
wrWARWins1  += waw1
wrWARTotal1 += wat1
wrWARWins2  += waw2
wrWARTotal2 += wat2
wrWARWins3  += waw3
wrWARTotal3 += wat3
wrWARStreak := f_updateStreak(wrWARStreak, waw1, wat1)

// ── Repeat-signal block ────────────────────────────────────────────────────
// True while this category still has an open trade IN THAT DIRECTION that has
// not reached win target 1. Long and short are tracked separately, so a
// pending long never blocks a short of the same signal type.
//
// Placed after the grading pass above so a trade that hit target 1 on THIS
// bar already counts as resolved and stops blocking immediately.
// Trades that stop out are removed from the arrays by the grader, so a losing
// signal releases the block rather than freezing the category forever.
f_pendingT1(res1Arr, dirArr, dir) =>
    bool pending = false
    int n = array.size(res1Arr)
    if n > 0
        for i = 0 to n - 1
            if array.get(dirArr, i) == dir and not array.get(res1Arr, i)
                pending := true
    pending

bool okCrossBull   = not blockUntilT1 or not f_pendingT1(wrCrossRes1,  wrCrossDir,   1)
bool okCrossBear   = not blockUntilT1 or not f_pendingT1(wrCrossRes1,  wrCrossDir,  -1)
bool okDivBull     = not blockUntilT1 or not f_pendingT1(wrDivRes1,    wrDivDir,     1)
bool okDivBear     = not blockUntilT1 or not f_pendingT1(wrDivRes1,    wrDivDir,    -1)
bool okVmcDotBull  = not blockUntilT1 or not f_pendingT1(wrVmcDotRes1, wrVmcDotDir,  1)
bool okVmcDotBear  = not blockUntilT1 or not f_pendingT1(wrVmcDotRes1, wrVmcDotDir, -1)
bool okVmcDivBull  = not blockUntilT1 or not f_pendingT1(wrVmcDivRes1, wrVmcDivDir,  1)
bool okVmcDivBear  = not blockUntilT1 or not f_pendingT1(wrVmcDivRes1, wrVmcDivDir, -1)
bool okStBull      = not blockUntilT1 or not f_pendingT1(wrStRes1,     wrStDir,      1)
bool okStBear      = not blockUntilT1 or not f_pendingT1(wrStRes1,     wrStDir,     -1)
bool okBvmcBull    = not blockUntilT1 or not f_pendingT1(wrBvmcRes1,   wrBvmcDir,    1)
bool okBvmcBear    = not blockUntilT1 or not f_pendingT1(wrBvmcRes1,   wrBvmcDir,   -1)
bool okK2Bull      = not blockUntilT1 or not f_pendingT1(wrK2Res1,     wrK2Dir,      1)
bool okK2Bear      = not blockUntilT1 or not f_pendingT1(wrK2Res1,     wrK2Dir,     -1)
bool okSingBull    = not blockUntilT1 or not f_pendingT1(wrSingRes1,   wrSingDir,    1)
bool okSingBear    = not blockUntilT1 or not f_pendingT1(wrSingRes1,   wrSingDir,   -1)
bool okQDivBull    = not blockUntilT1 or not f_pendingT1(wrQDivRes1,   wrQDivDir,    1)
bool okQDivBear    = not blockUntilT1 or not f_pendingT1(wrQDivRes1,   wrQDivDir,   -1)
bool okShandBull   = not blockUntilT1 or not f_pendingT1(wrShandRes1,  wrShandDir,   1)
bool okShandBear   = not blockUntilT1 or not f_pendingT1(wrShandRes1,  wrShandDir,  -1)
bool okTDIBull     = not blockUntilT1 or not f_pendingT1(wrTDIRes1,    wrTDIDir,     1)
bool okTDIBear     = not blockUntilT1 or not f_pendingT1(wrTDIRes1,    wrTDIDir,    -1)
bool okQTriBull    = not blockUntilT1 or not f_pendingT1(wrQTriRes1,   wrQTriDir,    1)
bool okQTriBear    = not blockUntilT1 or not f_pendingT1(wrQTriRes1,   wrQTriDir,   -1)
bool okWARBull     = not blockUntilT1 or not f_pendingT1(wrWARRes1,    wrWARDir,     1)
bool okWARBear     = not blockUntilT1 or not f_pendingT1(wrWARRes1,    wrWARDir,    -1)

// ══════════════════════════════════════════════════════════════════════════════
//  SIGNAL LABELS — stacked by win rate
// ══════════════════════════════════════════════════════════════════════════════
f_wrOf(w, t) => t > 0 ? 100.0 * w / t : -1.0

float stackGap = ta.atr(14) * stackSpacing

label lblCrossBull  = na
label lblCrossBear  = na
label lblDivBull    = na
label lblDivBear    = na
label lblVmcDotBull = na
label lblVmcDotBear = na
label lblVmcDivBull = na
label lblVmcDivBear = na
label lblStBull     = na
label lblStBear     = na
label lblBvmcBull   = na
label lblBvmcBear   = na
label lblK2Bull     = na
label lblK2Bear     = na
label lblQDivBull   = na
label lblQDivBear   = na

array<int>   sigBullIds = array.new<int>()
array<float> sigBullWR  = array.new<float>()
array<int>   sigBearIds = array.new<int>()
array<float> sigBearWR  = array.new<float>()

if showCross and crossUp and bullGateOK and rsiRaw < 50 and okCrossBull
    array.push(sigBullIds, 0)
    array.push(sigBullWR, f_wrOf(wrCrossWins1, wrCrossTotal1))
if showDivRsi and bullDiv and bullGateOK and okDivBull
    array.push(sigBullIds, 1)
    array.push(sigBullWR, f_wrOf(wrDivWins1, wrDivTotal1))
if showVMC and vmcBuyDotFiltered and bullGateOK and okVmcDotBull
    array.push(sigBullIds, 2)
    array.push(sigBullWR, f_wrOf(wrVmcDotWins1, wrVmcDotTotal1))
if showVMC and vmcBullDivFiltered and bullGateOK and okVmcDivBull
    array.push(sigBullIds, 3)
    array.push(sigBullWR, f_wrOf(wrVmcDivWins1, wrVmcDivTotal1))
if showST and showSTSignal and stFlipBull and bullGateOK and okStBull
    array.push(sigBullIds, 4)
    array.push(sigBullWR, f_wrOf(wrStWins1, wrStTotal1))
if showBvmcCross and bvmcCrossUp and bullGateOK and okBvmcBull
    array.push(sigBullIds, 5)
    array.push(sigBullWR, f_wrOf(wrBvmcWins1, wrBvmcTotal1))
if showK2Cross and k2CrossUp and bullGateOK and okK2Bull
    array.push(sigBullIds, 6)
    array.push(sigBullWR, f_wrOf(wrK2Wins1, wrK2Total1))
if singBullNew and okSingBull
    array.push(sigBullIds, 7)
    array.push(sigBullWR, f_wrOf(wrSingWins1, wrSingTotal1))
if quadDivBull and bullGateOK and okQDivBull
    array.push(sigBullIds, 9)
    array.push(sigBullWR, f_wrOf(wrQDivWins1, wrQDivTotal1))
if shandoogieBull and okShandBull
    array.push(sigBullIds, 10)
    array.push(sigBullWR, f_wrOf(wrShandWins1, wrShandTotal1))
if tdiPopBull and okTDIBull
    array.push(sigBullIds, 11)
    array.push(sigBullWR, f_wrOf(wrTDIWins1, wrTDITotal1))
if qtriBull and okQTriBull
    array.push(sigBullIds, 12)
    array.push(sigBullWR, f_wrOf(wrQTriWins1, wrQTriTotal1))
if warBull and okWARBull
    array.push(sigBullIds, 13)
    array.push(sigBullWR, f_wrOf(wrWARWins1, wrWARTotal1))

if showCross and crossDn and bearGateOK and rsiRaw > 50 and okCrossBear
    array.push(sigBearIds, 0)
    array.push(sigBearWR, f_wrOf(wrCrossWins1, wrCrossTotal1))
if showDivRsi and bearDiv and bearGateOK and okDivBear
    array.push(sigBearIds, 1)
    array.push(sigBearWR, f_wrOf(wrDivWins1, wrDivTotal1))
if showVMC and vmcSellDotFiltered and bearGateOK and okVmcDotBear
    array.push(sigBearIds, 2)
    array.push(sigBearWR, f_wrOf(wrVmcDotWins1, wrVmcDotTotal1))
if showVMC and vmcBearDivFiltered and bearGateOK and okVmcDivBear
    array.push(sigBearIds, 3)
    array.push(sigBearWR, f_wrOf(wrVmcDivWins1, wrVmcDivTotal1))
if showST and showSTSignal and stFlipBear and bearGateOK and okStBear
    array.push(sigBearIds, 4)
    array.push(sigBearWR, f_wrOf(wrStWins1, wrStTotal1))
if showBvmcCross and bvmcCrossDn and bearGateOK and okBvmcBear
    array.push(sigBearIds, 5)
    array.push(sigBearWR, f_wrOf(wrBvmcWins1, wrBvmcTotal1))
if showK2Cross and k2CrossDn and bearGateOK and okK2Bear
    array.push(sigBearIds, 6)
    array.push(sigBearWR, f_wrOf(wrK2Wins1, wrK2Total1))
if singBearNew and okSingBear
    array.push(sigBearIds, 7)
    array.push(sigBearWR, f_wrOf(wrSingWins1, wrSingTotal1))
if quadDivBear and bearGateOK and okQDivBear
    array.push(sigBearIds, 9)
    array.push(sigBearWR, f_wrOf(wrQDivWins1, wrQDivTotal1))
if shandoogieBear and okShandBear
    array.push(sigBearIds, 10)
    array.push(sigBearWR, f_wrOf(wrShandWins1, wrShandTotal1))
if tdiPopBear and okTDIBear
    array.push(sigBearIds, 11)
    array.push(sigBearWR, f_wrOf(wrTDIWins1, wrTDITotal1))
if qtriBear and okQTriBear
    array.push(sigBearIds, 12)
    array.push(sigBearWR, f_wrOf(wrQTriWins1, wrQTriTotal1))
if warBear and okWARBear
    array.push(sigBearIds, 13)
    array.push(sigBearWR, f_wrOf(wrWARWins1, wrWARTotal1))

// ── Draw bull stack ──────────────────────────────────────────────────────────
if array.size(sigBullIds) > 0
    array<int> bullOrder = array.sort_indices(sigBullWR, order.descending)
    for s = 0 to array.size(bullOrder) - 1
        int sid = array.get(sigBullIds, array.get(bullOrder, s))
        float yPos = low[1] - stackGap * (s + 1)
        bool  useStack = stackSignals and array.size(sigBullIds) > 1
        int   xPos = bar_index[1]
        if sid == 0
            lblCrossBull := useStack ? label.new(xPos, yPos, "", style=label.style_circle, color=col_cross_up, yloc=yloc.price, size=rsiCrossSize == "tiny" ? size.tiny : rsiCrossSize == "small" ? size.small : rsiCrossSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_circle, color=col_cross_up, yloc=yloc.belowbar, size=rsiCrossSize == "tiny" ? size.tiny : rsiCrossSize == "small" ? size.small : rsiCrossSize == "large" ? size.large : size.normal)
        else if sid == 1
            lblDivBull := useStack ? label.new(xPos, yPos, "", style=label.style_triangleup, color=col_bull_div, yloc=yloc.price, size=divSize == "tiny" ? size.tiny : divSize == "small" ? size.small : divSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_triangleup, color=col_bull_div, yloc=yloc.belowbar, size=divSize == "tiny" ? size.tiny : divSize == "small" ? size.small : divSize == "large" ? size.large : size.normal)
        else if sid == 2
            lblVmcDotBull := useStack ? label.new(xPos, yPos, "", style=label.style_circle, color=col_vmc_buy, yloc=yloc.price, size=vmcDotSize == "tiny" ? size.tiny : vmcDotSize == "small" ? size.small : vmcDotSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_circle, color=col_vmc_buy, yloc=yloc.belowbar, size=vmcDotSize == "tiny" ? size.tiny : vmcDotSize == "small" ? size.small : vmcDotSize == "large" ? size.large : size.normal)
        else if sid == 3
            lblVmcDivBull := useStack ? label.new(xPos, yPos, "", style=label.style_diamond, color=color.new(col_vmc_buy, 20), yloc=yloc.price, size=vmcDivSize == "tiny" ? size.tiny : vmcDivSize == "small" ? size.small : vmcDivSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_diamond, color=color.new(col_vmc_buy, 20), yloc=yloc.belowbar, size=vmcDivSize == "tiny" ? size.tiny : vmcDivSize == "small" ? size.small : vmcDivSize == "large" ? size.large : size.normal)
        else if sid == 4
            lblStBull := useStack ? label.new(xPos, yPos, "", style=label.style_arrowup, color=col_st_bull, yloc=yloc.price, size=stFlipSize == "tiny" ? size.tiny : stFlipSize == "small" ? size.small : stFlipSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_arrowup, color=col_st_bull, yloc=yloc.belowbar, size=stFlipSize == "tiny" ? size.tiny : stFlipSize == "small" ? size.small : stFlipSize == "large" ? size.large : size.normal)
        else if sid == 5
            lblBvmcBull := useStack ? label.new(xPos, yPos, "", style=label.style_xcross, color=col_bvmc_up, yloc=yloc.price, size=bvmcSize == "tiny" ? size.tiny : bvmcSize == "small" ? size.small : bvmcSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_xcross, color=col_bvmc_up, yloc=yloc.belowbar, size=bvmcSize == "tiny" ? size.tiny : bvmcSize == "small" ? size.small : bvmcSize == "large" ? size.large : size.normal)
        else if sid == 6
            lblK2Bull := useStack ? label.new(xPos, yPos, "", style=label.style_square, color=col_k2_up, yloc=yloc.price, size=k2Size == "tiny" ? size.tiny : k2Size == "small" ? size.small : k2Size == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_square, color=col_k2_up, yloc=yloc.belowbar, size=k2Size == "tiny" ? size.tiny : k2Size == "small" ? size.small : k2Size == "large" ? size.large : size.normal)
        else if sid == 7
            if useStack
                label.new(xPos, yPos, "💎", style=label.style_label_up, color=col_sing_bull, yloc=yloc.price, textcolor=color.white, size=singSize == "tiny" ? size.tiny : singSize == "small" ? size.small : singSize == "large" ? size.large : size.normal)
            else
                label.new(xPos, na, "💎", style=label.style_label_up, color=col_sing_bull, yloc=yloc.belowbar, textcolor=color.white, size=singSize == "tiny" ? size.tiny : singSize == "small" ? size.small : singSize == "large" ? size.large : size.normal)
        else if sid == 9
            // QuadCore div is confirmed quadDivLbR bars after the actual pivot.
            // Back-anchor the label to the real pivot bar by subtracting quadDivLbR from xPos.
            int qDivXBull = bar_index[1] - quadDivLbR
            float qDivYBull = low[1 + quadDivLbR] - stackGap * (s + 1)
            lblQDivBull := useStack ? label.new(qDivXBull, qDivYBull, quadDivBullEmoji, style=label.style_label_up, color=col_quaddiv_up, yloc=yloc.price, textcolor=color.white, size=quadDivSize == "tiny" ? size.tiny : quadDivSize == "small" ? size.small : quadDivSize == "large" ? size.large : size.normal) : label.new(qDivXBull, na, quadDivBullEmoji, style=label.style_label_up, color=col_quaddiv_up, yloc=yloc.belowbar, textcolor=color.white, size=quadDivSize == "tiny" ? size.tiny : quadDivSize == "small" ? size.small : quadDivSize == "large" ? size.large : size.normal)
        else if sid == 10
            label lblShandBull = useStack ? label.new(xPos, yPos, shandoogieEmojiBull, style=label.style_label_up, color=col_shand_bull, yloc=yloc.price, textcolor=color.white, size=shandoogieSize == "tiny" ? size.tiny : shandoogieSize == "small" ? size.small : shandoogieSize == "large" ? size.large : size.normal) : label.new(xPos, na, shandoogieEmojiBull, style=label.style_label_up, color=col_shand_bull, yloc=yloc.belowbar, textcolor=color.white, size=shandoogieSize == "tiny" ? size.tiny : shandoogieSize == "small" ? size.small : shandoogieSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrShandEntry, wrShandDir, wrShandRes1, wrShandRes2, wrShandRes3, wrShandLabel, 1, lblShandBull, "Shandoogie", wrShandWins1, wrShandTotal1, wrShandWins2, wrShandTotal2, wrShandWins3, wrShandTotal3, wrShandFired, wrShandStreak, wrShandFirstTime)
            wrShandFired += 1
            if na(wrShandFirstTime)
                wrShandFirstTime := time
            wrShandLongFired += 1
        else if sid == 11
            label lblTDIBull = useStack ? label.new(xPos, yPos, "🎯", style=label.style_label_up, color=col_tdi_bull, yloc=yloc.price, textcolor=color.white, size=tdiPopSize == "tiny" ? size.tiny : tdiPopSize == "small" ? size.small : tdiPopSize == "large" ? size.large : size.normal) : label.new(xPos, na, "🎯", style=label.style_label_up, color=col_tdi_bull, yloc=yloc.belowbar, textcolor=color.white, size=tdiPopSize == "tiny" ? size.tiny : tdiPopSize == "small" ? size.small : tdiPopSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrTDIEntry, wrTDIDir, wrTDIRes1, wrTDIRes2, wrTDIRes3, wrTDILabel, 1, lblTDIBull, "TDI Pop", wrTDIWins1, wrTDITotal1, wrTDIWins2, wrTDITotal2, wrTDIWins3, wrTDITotal3, wrTDIFired, wrTDIStreak, wrTDIFirstTime)
            wrTDIFired += 1
            if na(wrTDIFirstTime)
                wrTDIFirstTime := time
            wrTDILongFired += 1
        else if sid == 12
            label lblQTriBull = useStack ? label.new(xPos, yPos, qtriBullEmoji, style=label.style_label_up, color=col_qtri_up, yloc=yloc.price, textcolor=color.white, size=qtriSize == "tiny" ? size.tiny : qtriSize == "small" ? size.small : qtriSize == "large" ? size.large : size.normal) : label.new(xPos, na, qtriBullEmoji, style=label.style_label_up, color=col_qtri_up, yloc=yloc.belowbar, textcolor=color.white, size=qtriSize == "tiny" ? size.tiny : qtriSize == "small" ? size.small : qtriSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrQTriEntry, wrQTriDir, wrQTriRes1, wrQTriRes2, wrQTriRes3, wrQTriLabel, 1, lblQTriBull, "Quad Tri", wrQTriWins1, wrQTriTotal1, wrQTriWins2, wrQTriTotal2, wrQTriWins3, wrQTriTotal3, wrQTriFired, wrQTriStreak, wrQTriFirstTime)
            wrQTriFired += 1
            if na(wrQTriFirstTime)
                wrQTriFirstTime := time
            wrQTriLongFired += 1
        else if sid == 13
            label lblWARBull = useStack ? label.new(xPos, yPos, warBullEmoji, style=label.style_label_up, color=col_war_up, yloc=yloc.price, textcolor=color.white, size=warSize == "tiny" ? size.tiny : warSize == "small" ? size.small : warSize == "large" ? size.large : size.normal) : label.new(xPos, na, warBullEmoji, style=label.style_label_up, color=col_war_up, yloc=yloc.belowbar, textcolor=color.white, size=warSize == "tiny" ? size.tiny : warSize == "small" ? size.small : warSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrWAREntry, wrWARDir, wrWARRes1, wrWARRes2, wrWARRes3, wrWARLabel, 1, lblWARBull, "WAR", wrWARWins1, wrWARTotal1, wrWARWins2, wrWARTotal2, wrWARWins3, wrWARTotal3, wrWARFired, wrWARStreak, wrWARFirstTime)
            wrWARFired += 1
            if na(wrWARFirstTime)
                wrWARFirstTime := time
            wrWARLongFired += 1

// ── Draw bear stack ──────────────────────────────────────────────────────────
if array.size(sigBearIds) > 0
    array<int> bearOrder = array.sort_indices(sigBearWR, order.descending)
    for s = 0 to array.size(bearOrder) - 1
        int sid = array.get(sigBearIds, array.get(bearOrder, s))
        float yPos = high[1] + stackGap * (s + 1)
        bool  useStack = stackSignals and array.size(sigBearIds) > 1
        int   xPos = bar_index[1]
        if sid == 0
            lblCrossBear := useStack ? label.new(xPos, yPos, "", style=label.style_circle, color=col_cross_dn, yloc=yloc.price, size=rsiCrossSize == "tiny" ? size.tiny : rsiCrossSize == "small" ? size.small : rsiCrossSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_circle, color=col_cross_dn, yloc=yloc.abovebar, size=rsiCrossSize == "tiny" ? size.tiny : rsiCrossSize == "small" ? size.small : rsiCrossSize == "large" ? size.large : size.normal)
        else if sid == 1
            lblDivBear := useStack ? label.new(xPos, yPos, "", style=label.style_triangledown, color=col_bear_div, yloc=yloc.price, size=divSize == "tiny" ? size.tiny : divSize == "small" ? size.small : divSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_triangledown, color=col_bear_div, yloc=yloc.abovebar, size=divSize == "tiny" ? size.tiny : divSize == "small" ? size.small : divSize == "large" ? size.large : size.normal)
        else if sid == 2
            lblVmcDotBear := useStack ? label.new(xPos, yPos, "", style=label.style_circle, color=col_vmc_sell, yloc=yloc.price, size=vmcDotSize == "tiny" ? size.tiny : vmcDotSize == "small" ? size.small : vmcDotSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_circle, color=col_vmc_sell, yloc=yloc.abovebar, size=vmcDotSize == "tiny" ? size.tiny : vmcDotSize == "small" ? size.small : vmcDotSize == "large" ? size.large : size.normal)
        else if sid == 3
            lblVmcDivBear := useStack ? label.new(xPos, yPos, "", style=label.style_diamond, color=color.new(col_vmc_sell, 20), yloc=yloc.price, size=vmcDivSize == "tiny" ? size.tiny : vmcDivSize == "small" ? size.small : vmcDivSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_diamond, color=color.new(col_vmc_sell, 20), yloc=yloc.abovebar, size=vmcDivSize == "tiny" ? size.tiny : vmcDivSize == "small" ? size.small : vmcDivSize == "large" ? size.large : size.normal)
        else if sid == 4
            lblStBear := useStack ? label.new(xPos, yPos, "", style=label.style_arrowdown, color=col_st_bear, yloc=yloc.price, size=stFlipSize == "tiny" ? size.tiny : stFlipSize == "small" ? size.small : stFlipSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_arrowdown, color=col_st_bear, yloc=yloc.abovebar, size=stFlipSize == "tiny" ? size.tiny : stFlipSize == "small" ? size.small : stFlipSize == "large" ? size.large : size.normal)
        else if sid == 5
            lblBvmcBear := useStack ? label.new(xPos, yPos, "", style=label.style_xcross, color=col_bvmc_dn, yloc=yloc.price, size=bvmcSize == "tiny" ? size.tiny : bvmcSize == "small" ? size.small : bvmcSize == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_xcross, color=col_bvmc_dn, yloc=yloc.abovebar, size=bvmcSize == "tiny" ? size.tiny : bvmcSize == "small" ? size.small : bvmcSize == "large" ? size.large : size.normal)
        else if sid == 6
            lblK2Bear := useStack ? label.new(xPos, yPos, "", style=label.style_square, color=col_k2_dn, yloc=yloc.price, size=k2Size == "tiny" ? size.tiny : k2Size == "small" ? size.small : k2Size == "large" ? size.large : size.normal) : label.new(xPos, na, "", style=label.style_square, color=col_k2_dn, yloc=yloc.abovebar, size=k2Size == "tiny" ? size.tiny : k2Size == "small" ? size.small : k2Size == "large" ? size.large : size.normal)
        else if sid == 7
            if useStack
                label.new(xPos, yPos, "💎", style=label.style_label_down, color=col_sing_bear, yloc=yloc.price, textcolor=color.white, size=singSize == "tiny" ? size.tiny : singSize == "small" ? size.small : singSize == "large" ? size.large : size.normal)
            else
                label.new(xPos, na, "💎", style=label.style_label_down, color=col_sing_bear, yloc=yloc.abovebar, textcolor=color.white, size=singSize == "tiny" ? size.tiny : singSize == "small" ? size.small : singSize == "large" ? size.large : size.normal)
        else if sid == 9
            // Same back-anchor fix for bear side.
            int qDivXBear = bar_index[1] - quadDivLbR
            float qDivYBear = high[1 + quadDivLbR] + stackGap * (s + 1)
            lblQDivBear := useStack ? label.new(qDivXBear, qDivYBear, quadDivBearEmoji, style=label.style_label_down, color=col_quaddiv_dn, yloc=yloc.price, textcolor=color.white, size=quadDivSize == "tiny" ? size.tiny : quadDivSize == "small" ? size.small : quadDivSize == "large" ? size.large : size.normal) : label.new(qDivXBear, na, quadDivBearEmoji, style=label.style_label_down, color=col_quaddiv_dn, yloc=yloc.abovebar, textcolor=color.white, size=quadDivSize == "tiny" ? size.tiny : quadDivSize == "small" ? size.small : quadDivSize == "large" ? size.large : size.normal)
        else if sid == 10
            label lblShandBear = useStack ? label.new(xPos, yPos, shandoogieEmojiBear, style=label.style_label_down, color=col_shand_bear, yloc=yloc.price, textcolor=color.white, size=shandoogieSize == "tiny" ? size.tiny : shandoogieSize == "small" ? size.small : shandoogieSize == "large" ? size.large : size.normal) : label.new(xPos, na, shandoogieEmojiBear, style=label.style_label_down, color=col_shand_bear, yloc=yloc.abovebar, textcolor=color.white, size=shandoogieSize == "tiny" ? size.tiny : shandoogieSize == "small" ? size.small : shandoogieSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrShandEntry, wrShandDir, wrShandRes1, wrShandRes2, wrShandRes3, wrShandLabel, -1, lblShandBear, "Shandoogie", wrShandWins1, wrShandTotal1, wrShandWins2, wrShandTotal2, wrShandWins3, wrShandTotal3, wrShandFired, wrShandStreak, wrShandFirstTime)
            wrShandFired += 1
            if na(wrShandFirstTime)
                wrShandFirstTime := time
            wrShandShortFired += 1
        else if sid == 11
            label lblTDIBear = useStack ? label.new(xPos, yPos, "🎯", style=label.style_label_down, color=col_tdi_bear, yloc=yloc.price, textcolor=color.white, size=tdiPopSize == "tiny" ? size.tiny : tdiPopSize == "small" ? size.small : tdiPopSize == "large" ? size.large : size.normal) : label.new(xPos, na, "🎯", style=label.style_label_down, color=col_tdi_bear, yloc=yloc.abovebar, textcolor=color.white, size=tdiPopSize == "tiny" ? size.tiny : tdiPopSize == "small" ? size.small : tdiPopSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrTDIEntry, wrTDIDir, wrTDIRes1, wrTDIRes2, wrTDIRes3, wrTDILabel, -1, lblTDIBear, "TDI Pop", wrTDIWins1, wrTDITotal1, wrTDIWins2, wrTDITotal2, wrTDIWins3, wrTDITotal3, wrTDIFired, wrTDIStreak, wrTDIFirstTime)
            wrTDIFired += 1
            if na(wrTDIFirstTime)
                wrTDIFirstTime := time
            wrTDIShortFired += 1
        else if sid == 12
            label lblQTriBear = useStack ? label.new(xPos, yPos, qtriBearEmoji, style=label.style_label_down, color=col_qtri_dn, yloc=yloc.price, textcolor=color.white, size=qtriSize == "tiny" ? size.tiny : qtriSize == "small" ? size.small : qtriSize == "large" ? size.large : size.normal) : label.new(xPos, na, qtriBearEmoji, style=label.style_label_down, color=col_qtri_dn, yloc=yloc.abovebar, textcolor=color.white, size=qtriSize == "tiny" ? size.tiny : qtriSize == "small" ? size.small : qtriSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrQTriEntry, wrQTriDir, wrQTriRes1, wrQTriRes2, wrQTriRes3, wrQTriLabel, -1, lblQTriBear, "Quad Tri", wrQTriWins1, wrQTriTotal1, wrQTriWins2, wrQTriTotal2, wrQTriWins3, wrQTriTotal3, wrQTriFired, wrQTriStreak, wrQTriFirstTime)
            wrQTriFired += 1
            if na(wrQTriFirstTime)
                wrQTriFirstTime := time
            wrQTriShortFired += 1
        else if sid == 13
            label lblWARBear = useStack ? label.new(xPos, yPos, warBearEmoji, style=label.style_label_down, color=col_war_dn, yloc=yloc.price, textcolor=color.white, size=warSize == "tiny" ? size.tiny : warSize == "small" ? size.small : warSize == "large" ? size.large : size.normal) : label.new(xPos, na, warBearEmoji, style=label.style_label_down, color=col_war_dn, yloc=yloc.abovebar, textcolor=color.white, size=warSize == "tiny" ? size.tiny : warSize == "small" ? size.small : warSize == "large" ? size.large : size.normal)
            f_pushOpenTrade(wrWAREntry, wrWARDir, wrWARRes1, wrWARRes2, wrWARRes3, wrWARLabel, -1, lblWARBear, "WAR", wrWARWins1, wrWARTotal1, wrWARWins2, wrWARTotal2, wrWARWins3, wrWARTotal3, wrWARFired, wrWARStreak, wrWARFirstTime)
            wrWARFired += 1
            if na(wrWARFirstTime)
                wrWARFirstTime := time
            wrWARShortFired += 1

// ── Push remaining trades not handled inside the draw loops ─────────────────
bool sigRsiCrossBull = showCross and crossUp and bullGateOK and rsiRaw < 50 and okCrossBull
bool sigRsiCrossBear = showCross and crossDn and bearGateOK and rsiRaw > 50 and okCrossBear
if sigRsiCrossBull
    f_pushOpenTrade(wrCrossEntry, wrCrossDir, wrCrossRes1, wrCrossRes2, wrCrossRes3, wrCrossLabel, 1, lblCrossBull, "RSI Cross", wrCrossWins1, wrCrossTotal1, wrCrossWins2, wrCrossTotal2, wrCrossWins3, wrCrossTotal3, wrCrossFired, wrCrossStreak, wrCrossFirstTime)
    wrCrossFired += 1
    if na(wrCrossFirstTime)
        wrCrossFirstTime := time
    wrCrossLongFired += 1
if sigRsiCrossBear
    f_pushOpenTrade(wrCrossEntry, wrCrossDir, wrCrossRes1, wrCrossRes2, wrCrossRes3, wrCrossLabel, -1, lblCrossBear, "RSI Cross", wrCrossWins1, wrCrossTotal1, wrCrossWins2, wrCrossTotal2, wrCrossWins3, wrCrossTotal3, wrCrossFired, wrCrossStreak, wrCrossFirstTime)
    wrCrossFired += 1
    if na(wrCrossFirstTime)
        wrCrossFirstTime := time
    wrCrossShortFired += 1

if bullDiv and bullGateOK and okDivBull
    f_pushOpenTrade(wrDivEntry, wrDivDir, wrDivRes1, wrDivRes2, wrDivRes3, wrDivLabel, 1, lblDivBull, "RSI Div", wrDivWins1, wrDivTotal1, wrDivWins2, wrDivTotal2, wrDivWins3, wrDivTotal3, wrDivFired, wrDivStreak, wrDivFirstTime)
    wrDivFired += 1
    if na(wrDivFirstTime)
        wrDivFirstTime := time
    wrDivLongFired += 1
if bearDiv and bearGateOK and okDivBear
    f_pushOpenTrade(wrDivEntry, wrDivDir, wrDivRes1, wrDivRes2, wrDivRes3, wrDivLabel, -1, lblDivBear, "RSI Div", wrDivWins1, wrDivTotal1, wrDivWins2, wrDivTotal2, wrDivWins3, wrDivTotal3, wrDivFired, wrDivStreak, wrDivFirstTime)
    wrDivFired += 1
    if na(wrDivFirstTime)
        wrDivFirstTime := time
    wrDivShortFired += 1

if showVMC and vmcBuyDotFiltered and bullGateOK and okVmcDotBull
    f_pushOpenTrade(wrVmcDotEntry, wrVmcDotDir, wrVmcDotRes1, wrVmcDotRes2, wrVmcDotRes3, wrVmcDotLabel, 1, lblVmcDotBull, "VMC Dot", wrVmcDotWins1, wrVmcDotTotal1, wrVmcDotWins2, wrVmcDotTotal2, wrVmcDotWins3, wrVmcDotTotal3, wrVmcDotFired, wrVmcDotStreak, wrVmcDotFirstTime)
    wrVmcDotFired += 1
    if na(wrVmcDotFirstTime)
        wrVmcDotFirstTime := time
    wrVmcDotLongFired += 1
if showVMC and vmcSellDotFiltered and bearGateOK and okVmcDotBear
    f_pushOpenTrade(wrVmcDotEntry, wrVmcDotDir, wrVmcDotRes1, wrVmcDotRes2, wrVmcDotRes3, wrVmcDotLabel, -1, lblVmcDotBear, "VMC Dot", wrVmcDotWins1, wrVmcDotTotal1, wrVmcDotWins2, wrVmcDotTotal2, wrVmcDotWins3, wrVmcDotTotal3, wrVmcDotFired, wrVmcDotStreak, wrVmcDotFirstTime)
    wrVmcDotFired += 1
    if na(wrVmcDotFirstTime)
        wrVmcDotFirstTime := time
    wrVmcDotShortFired += 1

if showVMC and vmcBullDivFiltered and bullGateOK and okVmcDivBull
    f_pushOpenTrade(wrVmcDivEntry, wrVmcDivDir, wrVmcDivRes1, wrVmcDivRes2, wrVmcDivRes3, wrVmcDivLabel, 1, lblVmcDivBull, "VMC Div", wrVmcDivWins1, wrVmcDivTotal1, wrVmcDivWins2, wrVmcDivTotal2, wrVmcDivWins3, wrVmcDivTotal3, wrVmcDivFired, wrVmcDivStreak, wrVmcDivFirstTime)
    wrVmcDivFired += 1
    if na(wrVmcDivFirstTime)
        wrVmcDivFirstTime := time
    wrVmcDivLongFired += 1
if showVMC and vmcBearDivFiltered and bearGateOK and okVmcDivBear
    f_pushOpenTrade(wrVmcDivEntry, wrVmcDivDir, wrVmcDivRes1, wrVmcDivRes2, wrVmcDivRes3, wrVmcDivLabel, -1, lblVmcDivBear, "VMC Div", wrVmcDivWins1, wrVmcDivTotal1, wrVmcDivWins2, wrVmcDivTotal2, wrVmcDivWins3, wrVmcDivTotal3, wrVmcDivFired, wrVmcDivStreak, wrVmcDivFirstTime)
    wrVmcDivFired += 1
    if na(wrVmcDivFirstTime)
        wrVmcDivFirstTime := time
    wrVmcDivShortFired += 1

if showST and showSTSignal and stFlipBull and bullGateOK and okStBull
    f_pushOpenTrade(wrStEntry, wrStDir, wrStRes1, wrStRes2, wrStRes3, wrStLabel, 1, lblStBull, "S/T", wrStWins1, wrStTotal1, wrStWins2, wrStTotal2, wrStWins3, wrStTotal3, wrStFired, wrStStreak, wrStFirstTime)
    wrStFired += 1
    if na(wrStFirstTime)
        wrStFirstTime := time
    wrStLongFired += 1
if showST and showSTSignal and stFlipBear and bearGateOK and okStBear
    f_pushOpenTrade(wrStEntry, wrStDir, wrStRes1, wrStRes2, wrStRes3, wrStLabel, -1, lblStBear, "S/T", wrStWins1, wrStTotal1, wrStWins2, wrStTotal2, wrStWins3, wrStTotal3, wrStFired, wrStStreak, wrStFirstTime)
    wrStFired += 1
    if na(wrStFirstTime)
        wrStFirstTime := time
    wrStShortFired += 1

if showBvmcCross and bvmcCrossUp and bullGateOK and okBvmcBull
    f_pushOpenTrade(wrBvmcEntry, wrBvmcDir, wrBvmcRes1, wrBvmcRes2, wrBvmcRes3, wrBvmcLabel, 1, lblBvmcBull, "D1 Cross", wrBvmcWins1, wrBvmcTotal1, wrBvmcWins2, wrBvmcTotal2, wrBvmcWins3, wrBvmcTotal3, wrBvmcFired, wrBvmcStreak, wrBvmcFirstTime)
    wrBvmcFired += 1
    if na(wrBvmcFirstTime)
        wrBvmcFirstTime := time
    wrBvmcLongFired += 1
if showBvmcCross and bvmcCrossDn and bearGateOK and okBvmcBear
    f_pushOpenTrade(wrBvmcEntry, wrBvmcDir, wrBvmcRes1, wrBvmcRes2, wrBvmcRes3, wrBvmcLabel, -1, lblBvmcBear, "D1 Cross", wrBvmcWins1, wrBvmcTotal1, wrBvmcWins2, wrBvmcTotal2, wrBvmcWins3, wrBvmcTotal3, wrBvmcFired, wrBvmcStreak, wrBvmcFirstTime)
    wrBvmcFired += 1
    if na(wrBvmcFirstTime)
        wrBvmcFirstTime := time
    wrBvmcShortFired += 1

if showK2Cross and k2CrossUp and bullGateOK and okK2Bull
    f_pushOpenTrade(wrK2Entry, wrK2Dir, wrK2Res1, wrK2Res2, wrK2Res3, wrK2Label, 1, lblK2Bull, "K2 Cross", wrK2Wins1, wrK2Total1, wrK2Wins2, wrK2Total2, wrK2Wins3, wrK2Total3, wrK2Fired, wrK2Streak, wrK2FirstTime)
    wrK2Fired += 1
    if na(wrK2FirstTime)
        wrK2FirstTime := time
    wrK2LongFired += 1
if showK2Cross and k2CrossDn and bearGateOK and okK2Bear
    f_pushOpenTrade(wrK2Entry, wrK2Dir, wrK2Res1, wrK2Res2, wrK2Res3, wrK2Label, -1, lblK2Bear, "K2 Cross", wrK2Wins1, wrK2Total1, wrK2Wins2, wrK2Total2, wrK2Wins3, wrK2Total3, wrK2Fired, wrK2Streak, wrK2FirstTime)
    wrK2Fired += 1
    if na(wrK2FirstTime)
        wrK2FirstTime := time
    wrK2ShortFired += 1

label naLbl = na

if singBullNew and okSingBull
    f_pushOpenTrade(wrSingEntry, wrSingDir, wrSingRes1, wrSingRes2, wrSingRes3, wrSingLabel, 1, naLbl, "Singularity", wrSingWins1, wrSingTotal1, wrSingWins2, wrSingTotal2, wrSingWins3, wrSingTotal3, wrSingFired, wrSingStreak, wrSingFirstTime)
    wrSingFired += 1
    wrSingLongFired += 1
if singBearNew and okSingBear
    f_pushOpenTrade(wrSingEntry, wrSingDir, wrSingRes1, wrSingRes2, wrSingRes3, wrSingLabel, -1, naLbl, "Singularity", wrSingWins1, wrSingTotal1, wrSingWins2, wrSingTotal2, wrSingWins3, wrSingTotal3, wrSingFired, wrSingStreak, wrSingFirstTime)
    wrSingFired += 1
    wrSingShortFired += 1

if quadDivBull and bullGateOK and okQDivBull
    f_pushOpenTrade(wrQDivEntry, wrQDivDir, wrQDivRes1, wrQDivRes2, wrQDivRes3, wrQDivLabel, 1, lblQDivBull, "QuadCore Div", wrQDivWins1, wrQDivTotal1, wrQDivWins2, wrQDivTotal2, wrQDivWins3, wrQDivTotal3, wrQDivFired, wrQDivStreak, wrQDivFirstTime)
    wrQDivFired += 1
    if na(wrQDivFirstTime)
        wrQDivFirstTime := time
    wrQDivLongFired += 1
if quadDivBear and bearGateOK and okQDivBear
    f_pushOpenTrade(wrQDivEntry, wrQDivDir, wrQDivRes1, wrQDivRes2, wrQDivRes3, wrQDivLabel, -1, lblQDivBear, "QuadCore Div", wrQDivWins1, wrQDivTotal1, wrQDivWins2, wrQDivTotal2, wrQDivWins3, wrQDivTotal3, wrQDivFired, wrQDivStreak, wrQDivFirstTime)
    wrQDivFired += 1
    if na(wrQDivFirstTime)
        wrQDivFirstTime := time
    wrQDivShortFired += 1

// ── Render table ─────────────────────────────────────────────────────────────
wrPos = wrTablePos == "Top Left" ? position.top_left : wrTablePos == "Bottom Right" ? position.bottom_right : wrTablePos == "Bottom Left" ? position.bottom_left : position.top_right
wrSz  = wrTextSize == "tiny" ? size.tiny : wrTextSize == "normal" ? size.normal : wrTextSize == "large" ? size.large : size.small

int wrRowCount = 1 + (showCross ? 1 : 0) + (showDivRsi ? 1 : 0) + (showVMC ? 2 : 0) + ((showST and showSTSignal) ? 1 : 0) + (showBvmcCross ? 1 : 0) + (showK2Cross ? 1 : 0) + (showQuadDiv ? 1 : 0) + (showShandoogie ? 1 : 0) + (showTDIPop ? 1 : 0) + (showQTri ? 1 : 0) + (showWAR ? 1 : 0)
var table wrTable = table.new(wrPos, 4, math.max(wrRowCount, 1), border_width=1)

f_wrRow(t, row, label_, fired, openCount, wins1, total1, wins2, total2, wins3, total3, firstTime, streak) =>
    float pct1 = total1 > 0 ? 100.0 * wins1 / total1 : na
    float pct2 = total2 > 0 ? 100.0 * wins2 / total2 : na
    float pct3 = total3 > 0 ? 100.0 * wins3 / total3 : na
    string pct1Str = na(pct1) ? "—" : str.tostring(pct1, "#.0") + "%"
    string pct2Str = na(pct2) ? "—" : str.tostring(pct2, "#.0") + "%"
    string pct3Str = na(pct3) ? "—" : str.tostring(pct3, "#.0") + "%"
    color rowCol1 = na(pct1) ? color.new(color.gray, 70) : pct1 >= 50 ? color.new(color.green, 75) : color.new(color.red, 75)
    color rowCol2 = na(pct2) ? color.new(color.gray, 70) : pct2 >= 50 ? color.new(color.green, 75) : color.new(color.red, 75)
    color rowCol3 = na(pct3) ? color.new(color.gray, 70) : pct3 >= 50 ? color.new(color.green, 75) : color.new(color.red, 75)
    int    losses1 = total1 - wins1
    string rowTip = label_ + "\n" +
     "Signals fired: " + str.tostring(fired) + "\n" +
     "Record (" + str.tostring(wrWinPct1, "#.##") + "%): " + str.tostring(wins1) + "W - " + str.tostring(losses1) + "L\n" +
     "Current streak: " + str.tostring(streak) + "\n" +
     "Open trades: " + str.tostring(openCount) + "\n" +
     "Tracked for: " + f_formatSince(firstTime)
    table.cell(t, 0, row, label_,   text_color=color.white, text_size=wrSz, text_halign=text.align_left, bgcolor=color.new(color.black, 0), tooltip=rowTip)
    table.cell(t, 1, row, pct1Str,  text_color=color.white, text_size=wrSz, bgcolor=rowCol1, tooltip=rowTip)
    table.cell(t, 2, row, pct2Str,  text_color=color.white, text_size=wrSz, bgcolor=rowCol2, tooltip=rowTip)
    table.cell(t, 3, row, pct3Str,  text_color=color.white, text_size=wrSz, bgcolor=rowCol3, tooltip=rowTip)

if showWinrateTable and barstate.islast
    table.cell(wrTable, 0, 0, "Signal", text_color=color.white, text_size=wrSz, text_halign=text.align_left, bgcolor=color.new(color.navy, 0))
    table.cell(wrTable, 1, 0, str.tostring(wrWinPct1, "#.##") + "%", text_color=color.white, text_size=wrSz, bgcolor=color.new(color.navy, 0))
    table.cell(wrTable, 2, 0, str.tostring(wrWinPct2, "#.##") + "%", text_color=color.white, text_size=wrSz, bgcolor=color.new(color.navy, 0))
    table.cell(wrTable, 3, 0, str.tostring(wrWinPct3, "#.##") + "%", text_color=color.white, text_size=wrSz, bgcolor=color.new(color.navy, 0))

    array<int>   catIds    = array.new<int>()
    array<float> catScores = array.new<float>()
    if showCross
        array.push(catIds, 0)
        array.push(catScores, wrCrossTotal1 > 0 ? 100.0 * wrCrossWins1 / wrCrossTotal1 : -1.0)
    if showDivRsi
        array.push(catIds, 1)
        array.push(catScores, wrDivTotal1 > 0 ? 100.0 * wrDivWins1 / wrDivTotal1 : -1.0)
    if showVMC
        array.push(catIds, 2)
        array.push(catScores, wrVmcDotTotal1 > 0 ? 100.0 * wrVmcDotWins1 / wrVmcDotTotal1 : -1.0)
        array.push(catIds, 3)
        array.push(catScores, wrVmcDivTotal1 > 0 ? 100.0 * wrVmcDivWins1 / wrVmcDivTotal1 : -1.0)
    if showST and showSTSignal
        array.push(catIds, 4)
        array.push(catScores, wrStTotal1 > 0 ? 100.0 * wrStWins1 / wrStTotal1 : -1.0)
    if showBvmcCross
        array.push(catIds, 5)
        array.push(catScores, wrBvmcTotal1 > 0 ? 100.0 * wrBvmcWins1 / wrBvmcTotal1 : -1.0)
    if showK2Cross
        array.push(catIds, 6)
        array.push(catScores, wrK2Total1 > 0 ? 100.0 * wrK2Wins1 / wrK2Total1 : -1.0)
    if showQuadDiv
        array.push(catIds, 8)
        array.push(catScores, wrQDivTotal1 > 0 ? 100.0 * wrQDivWins1 / wrQDivTotal1 : -1.0)
    if showShandoogie
        array.push(catIds, 10)
        array.push(catScores, wrShandTotal1 > 0 ? 100.0 * wrShandWins1 / wrShandTotal1 : -1.0)
    if showTDIPop
        array.push(catIds, 11)
        array.push(catScores, wrTDITotal1 > 0 ? 100.0 * wrTDIWins1 / wrTDITotal1 : -1.0)
    if showQTri
        array.push(catIds, 12)
        array.push(catScores, wrQTriTotal1 > 0 ? 100.0 * wrQTriWins1 / wrQTriTotal1 : -1.0)
    if showWAR
        array.push(catIds, 13)
        array.push(catScores, wrWARTotal1 > 0 ? 100.0 * wrWARWins1 / wrWARTotal1 : -1.0)

    array<int> sortOrder = array.sort_indices(catScores, order.descending)
    int wrRow = 1
    if array.size(sortOrder) > 0
        for sortPos = 0 to array.size(sortOrder) - 1
            int pos = array.get(sortOrder, sortPos)
            int cid = array.get(catIds, pos)
            if cid == 0
                f_wrRow(wrTable, wrRow, "RSI Cross", wrCrossFired, array.size(wrCrossEntry), wrCrossWins1, wrCrossTotal1, wrCrossWins2, wrCrossTotal2, wrCrossWins3, wrCrossTotal3, wrCrossFirstTime, wrCrossStreak)
            else if cid == 1
                f_wrRow(wrTable, wrRow, "RSI Div", wrDivFired, array.size(wrDivEntry), wrDivWins1, wrDivTotal1, wrDivWins2, wrDivTotal2, wrDivWins3, wrDivTotal3, wrDivFirstTime, wrDivStreak)
            else if cid == 2
                f_wrRow(wrTable, wrRow, "VMC Dot", wrVmcDotFired, array.size(wrVmcDotEntry), wrVmcDotWins1, wrVmcDotTotal1, wrVmcDotWins2, wrVmcDotTotal2, wrVmcDotWins3, wrVmcDotTotal3, wrVmcDotFirstTime, wrVmcDotStreak)
            else if cid == 3
                f_wrRow(wrTable, wrRow, "VMC Div", wrVmcDivFired, array.size(wrVmcDivEntry), wrVmcDivWins1, wrVmcDivTotal1, wrVmcDivWins2, wrVmcDivTotal2, wrVmcDivWins3, wrVmcDivTotal3, wrVmcDivFirstTime, wrVmcDivStreak)
            else if cid == 4
                f_wrRow(wrTable, wrRow, "S/T", wrStFired, array.size(wrStEntry), wrStWins1, wrStTotal1, wrStWins2, wrStTotal2, wrStWins3, wrStTotal3, wrStFirstTime, wrStStreak)
            else if cid == 5
                f_wrRow(wrTable, wrRow, "D1 Cross", wrBvmcFired, array.size(wrBvmcEntry), wrBvmcWins1, wrBvmcTotal1, wrBvmcWins2, wrBvmcTotal2, wrBvmcWins3, wrBvmcTotal3, wrBvmcFirstTime, wrBvmcStreak)
            else if cid == 6
                f_wrRow(wrTable, wrRow, "K2 Cross", wrK2Fired, array.size(wrK2Entry), wrK2Wins1, wrK2Total1, wrK2Wins2, wrK2Total2, wrK2Wins3, wrK2Total3, wrK2FirstTime, wrK2Streak)
            else if cid == 8
                f_wrRow(wrTable, wrRow, "Quad Div", wrQDivFired, array.size(wrQDivEntry), wrQDivWins1, wrQDivTotal1, wrQDivWins2, wrQDivTotal2, wrQDivWins3, wrQDivTotal3, wrQDivFirstTime, wrQDivStreak)
            else if cid == 10
                f_wrRow(wrTable, wrRow, "Shandoogie", wrShandFired, array.size(wrShandEntry), wrShandWins1, wrShandTotal1, wrShandWins2, wrShandTotal2, wrShandWins3, wrShandTotal3, wrShandFirstTime, wrShandStreak)
            else if cid == 11
                f_wrRow(wrTable, wrRow, "TDI Pop", wrTDIFired, array.size(wrTDIEntry), wrTDIWins1, wrTDITotal1, wrTDIWins2, wrTDITotal2, wrTDIWins3, wrTDITotal3, wrTDIFirstTime, wrTDIStreak)
            else if cid == 12
                f_wrRow(wrTable, wrRow, "Quad Tri", wrQTriFired, array.size(wrQTriEntry), wrQTriWins1, wrQTriTotal1, wrQTriWins2, wrQTriTotal2, wrQTriWins3, wrQTriTotal3, wrQTriFirstTime, wrQTriStreak)
            else if cid == 13
                f_wrRow(wrTable, wrRow, "WAR", wrWARFired, array.size(wrWAREntry), wrWARWins1, wrWARTotal1, wrWARWins2, wrWARTotal2, wrWARWins3, wrWARTotal3, wrWARFirstTime, wrWARStreak)
            wrRow := wrRow + 1


// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullLevel >= 1 and bullLevel[1] == 0, "🟢 Background ON  — Bull L1", "6H bull streak started")
alertcondition(bearLevel >= 1 and bearLevel[1] == 0, "🔴 Background ON  — Bear L1", "6H bear streak started")
alertcondition(bullLevel >= 3 and bullLevel[1] <  3, "🟢 Background ON  — Bull L3 Full", "Full bull alignment — 1H strong")
alertcondition(bearLevel >= 3 and bearLevel[1] <  3, "🔴 Background ON  — Bear L3 Full", "Full bear alignment — 1H strong")
alertcondition(bullLevel == 0 and bullLevel[1] > 0,  "⚪ Background OFF — Bull Ended", "6H flipped — green background off")
alertcondition(bearLevel == 0 and bearLevel[1] > 0,  "⚪ Background OFF — Bear Ended", "6H flipped — red background off")

alertcondition(crossUp and bullGateOK and okCrossBull,            "〰️ RSI Cross Bull",        "RSI fast crossed above slow")
alertcondition(crossDn and bearGateOK and okCrossBear,            "〰️ RSI Cross Bear",        "RSI fast crossed below slow")
alertcondition(bullDiv and bullGateOK and okDivBull,            "📐 RSI Divergence Bull",    "Price lower low, RSI higher low")
alertcondition(bearDiv and bearGateOK and okDivBear,            "📐 RSI Divergence Bear",    "Price higher high, RSI lower high")
alertcondition(vmcBuyDotFiltered  and bullGateOK and okVmcDotBull,         "🟢 VMC Buy Dot",           "VMC WT crossed up from oversold")
alertcondition(vmcSellDotFiltered and bearGateOK and okVmcDotBear,         "🔴 VMC Sell Dot",          "VMC WT crossed down from overbought")
alertcondition(vmcBullDivFiltered and bullGateOK and okVmcDivBull,         "📐 VMC Divergence Bull",    "VMC WT bullish divergence")
alertcondition(vmcBearDivFiltered and bearGateOK and okVmcDivBear,         "📐 VMC Divergence Bear",    "VMC WT bearish divergence")
alertcondition(stFlipBull and bullGateOK and okStBull,         "📈 Supertrend Bull Flip",   "Supertrend turned bullish")
alertcondition(stFlipBear and bearGateOK and okStBear,         "📉 Supertrend Bear Flip",   "Supertrend turned bearish")
alertcondition(bvmcCrossUp and bullGateOK and okBvmcBull,       "✖️ Belfort D1 Cross Bull",   "RSI crossed above Belfort D1")
alertcondition(bvmcCrossDn and bearGateOK and okBvmcBear,       "✖️ Belfort D1 Cross Bear",   "RSI crossed below Belfort D1")
alertcondition(k2CrossUp and bullGateOK and okK2Bull,         "◻️ K2 Cross Bull",   "K2 crossed above RSI")
alertcondition(k2CrossDn and bearGateOK and okK2Bear,         "◻️ K2 Cross Bear",   "K2 crossed below RSI")
alertcondition(quadDivBull and bullGateOK and okQDivBull,       "⬆️ QuadCore Div Bull", "Bullish divergence on a QuadCore stochastic")
alertcondition(quadDivBear and bearGateOK and okQDivBear,       "⬇️ QuadCore Div Bear", "Bearish divergence on a QuadCore stochastic")
alertcondition(singBullNew and okSingBull,                           "💎 Singularity Bull",       "6H + 1H pure bull alignment")
alertcondition(singBearNew and okSingBear,                           "💎 Singularity Bear",       "6H + 1H pure bear alignment")
alertcondition(shandoogieBull and okShandBull, "🦅 Shandoogie Bull", "QuadCore oversold coloring ended + strong HA bull flip")
alertcondition(shandoogieBear and okShandBear, "🦈 Shandoogie Bear", "QuadCore overbought coloring ended + strong HA bear flip")
alertcondition(tdiPopBull and okTDIBull, "🎯 TDI Pop Bull", "TDI signal line closed above upper band")
alertcondition(tdiPopBear and okTDIBear, "🎯 TDI Pop Bear", "TDI signal line closed below lower band")
alertcondition(qtriBull and okQTriBull, "🔺 QuadCore Triangle Bull", "All four QuadCore stochs rising and the slowest cleared oversold")
alertcondition(qtriBear and okQTriBear, "🔻 QuadCore Triangle Bear", "All four QuadCore stochs falling and the slowest cleared overbought")
alertcondition(warBull and okWARBull, "⚔️ WAR Formation Bull", "Consecutive HA candles each stronger, no lower wicks")
alertcondition(warBear and okWARBear, "⚔️ WAR Formation Bear", "Consecutive HA candles each stronger, no upper wicks")

bool anyBull = bullGateOK and bullLevelConfirmed[1] >= minSigTier and ((showCross and crossUp and bullGateOK) or (showDivRsi and bullDiv and bullGateOK) or (showVMC and vmcBuyDotFiltered and bullGateOK) or (showVMC and vmcBullDivFiltered and bullGateOK) or (showST and stFlipBull and bullGateOK) or (showSing and singBullNew and bullGateOK) or (showBvmcCross and bvmcCrossUp and bullGateOK) or (showK2Cross and k2CrossUp and bullGateOK) or (quadDivBull and bullGateOK) or (shandoogieBull and okShandBull) or (tdiPopBull and okTDIBull) or (qtriBull and okQTriBull) or (warBull and okWARBull))
bool anyBear = bearGateOK and bearLevelConfirmed[1] >= minSigTier and ((showCross and crossDn and bearGateOK) or (showDivRsi and bearDiv and bearGateOK) or (showVMC and vmcSellDotFiltered and bearGateOK) or (showVMC and vmcBearDivFiltered and bearGateOK) or (showST and stFlipBear and bearGateOK) or (showSing and singBearNew and bearGateOK) or (showBvmcCross and bvmcCrossDn and bearGateOK) or (showK2Cross and k2CrossDn and bearGateOK) or (quadDivBear and bearGateOK) or (shandoogieBear and okShandBear) or (tdiPopBear and okTDIBear) or (qtriBear and okQTriBear) or (warBear and okWARBear))

alertcondition(anyBull, "🚀 ANY Bull Signal", "At least one bullish signal fired — check chart")
alertcondition(anyBear, "💀 ANY Bear Signal", "At least one bearish signal fired — check chart")
````
