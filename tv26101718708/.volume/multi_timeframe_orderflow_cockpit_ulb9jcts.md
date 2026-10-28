# Multi Timeframe Order-Flow Cockpit

- url: https://www.tradingview.com/script/uLb9jcts-Multi-Timeframe-Order-Flow-Cockpit/
- type: indicator
- pine_id: PUB;4dd8cecdf02344fe856e4ac018be4180
- version: 3.0

## Description

Multi-Timeframe Order-Flow Cockpit

A single overlay that turns raw volume into a multi-timeframe order-flow read. It draws a compact row of higher-timeframe (HTF) candles beside price — each split into buy vs sell volume — and condenses several timeframes' order flow into one plain-language verdict. Unusually, it ships with a built-in calibration layer that forward-tests its own verdict and tells you, in plain words, whether that verdict actually beats a base rate — instead of asserting an edge it cannot show.

WHAT IT DOES

For each timeframe you enable, the script reconstructs the buy/sell volume that built every bar, scores how one-sided that flow is, reads market structure, and fuses everything into a single bias with a stated conviction. It then projects key price levels and marks where current price sits inside each timeframe's range — so you can see, at one glance, what order flow is doing across the whole timeframe stack.

WHY THESE COMPONENTS ARE COMBINED

This is not a pile of unrelated overlays. It is a pipeline where each stage feeds the next, and a final stage audits the whole:


Higher-timeframe candles are the canvas — see several timeframes' auctions at once without flipping charts.
Intrabar delta classifies sub-bar volume into buy vs sell (close-vs-open, or range-weighted). Where your plan and symbol allow, the chart-timeframe strip uses native footprint (real aggressor bid/ask volume), tagged REAL; otherwise it reconstructs the delta and is tagged EST — so data fidelity is never hidden.
Order-flow toxicity (VPIN-family) measures how aggressive/one-sided each timeframe's flow is. It is a conviction input, not a direction.
Market structure (swing breaks, BOS/CHoCH) supplies directional context that can override delta when price structure genuinely shifts.
Probabilistic synthesis fuses the above in log-odds space, averaging correlated inputs so that redundant agreement cannot inflate confidence, plus an optional exogenous volatility-index vote (rising volatility pressures the asset).
Forward calibration resolves every committed verdict N bars later against an ATR-sized move and reports Hit% versus an unconditional Base%, gated by a Wilson score interval so a result is only flagged (star) when it is statistically distinguishable from chance — split by trending versus ranging regime.


The components belong together because the deliverable is the synthesis and its honest scoring, which no single overlay can provide: toxicity needs the delta, structure contextualizes the delta, the verdict needs all of them, and the calibration is meaningless without a verdict to test.

HOW TO USE IT


Read the Compact table (default). Bias = which way flow leans; Conviction = how strongly; Flow = calm vs one-sided; Setup = exhaustion flags; Edge = whether the verdict has measured, significant edge; Use = the bottom line — "Context only" until edge is proven, "Tradeable — still verify" only when the calibration confirms it.
Switch the table to Pro for per-timeframe metrics (delta %, toxicity, structure, calibrated bias) plus the combined verdict and calibration rows. Turn on the Key Info table while learning — it is a plain-language legend.
On-chart aids: each panel tags its true High/Low and shows a position triangle at its edge — green when price is above that timeframe's range, red when below, yellow when inside, with brightness scaling to how far price has stretched. Key levels (POC, value-area high/low, recent swing high/low) are projected at true price as reference zones.
Any market: set your symbol, price source and intrabar resolution in Data Source, and your market's volatility index in Volatility Vote. Defaults are set for NSE NIFTY — change them for other assets.
Alerts are attention cues (verdict shift, toxicity spike, divergence, structure shift) — they tell you where to look, never what to do. Create one alert with the condition "Any alert() function call."


WHAT IS ORIGINAL HERE

Most order-flow and "smart-money" tools assert an edge by drawing confident signals. This one is built around the opposite discipline: a transparent calibration layer that measures and reports its own edge against a base rate, refuses to certify a signal that has not earned statistical significance, and reports it separately by market regime. The multi-timeframe order-flow synthesis with decorrelated log-odds fusion, and the REAL/EST fidelity tagging of delta, are also original to this implementation. The honesty layer is the headline feature — it is designed to tell you when there is no proven edge.

CONCEPT CREDITS (methods, not code)

Bulk Volume Classification / VPIN — Easley, Lopez de Prado and O'Hara. Market/Volume Profile (value area, POC) — J. Peter Steidlmayer. Wilson score interval — E. B. Wilson (1927). Efficiency-ratio regime — Perry Kaufman. Market-structure concepts — classical price action. All original code, architecture, fusion and calibration by the author.

DISCLAIMER

This is an awareness/context tool — not a signal generator and not financial advice. No indicator predicts the future. Past behavior and any displayed statistics do not guarantee future results; the calibration is explicitly designed to report when the tool has no measurable edge — heed it. Trade your own plan and manage your risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India                                                                    MPL-2.0
//
// =============================================================================
//  Multi-Timeframe Order-Flow Cockpit  (MTF Order-Flow Cockpit)                       v1.1
// -----------------------------------------------------------------------------
//  v1.1 — Integration + finishing pass (no engine change):
//    • Added an EXP_ Data-Window export bus (confluence probability & direction, chart-TF delta and
//      bias, flow toxicity, volatility vote, reversion cumulative-delta z) so the cockpit's state can
//      feed other scripts via input.source().
//    • Standardized the MPL-2.0 licence line (credit was corrected earlier).
//    • Verified: no conditional ta.*; the seconds→1m delta fallback and the 5 higher-timeframe
//      panels degrade gracefully on Daily/Weekly; the theme is already background-adaptive. Unchanged.
// -----------------------------------------------------------------------------
//  An overlay whose HEADLINE is multi-timeframe level confluence: it harvests the
//  POC and value-area (VAH/VAL) levels from every active timeframe panel — plus
//  prior day/week levels and VWAP — and shades the zones where several ALIGN, which
//  are the highest-quality support/resistance (the hallmark of a professional
//  volume-profile read). It then reports the live order flow AT the nearest zone
//  (buyers/sellers pressing, or absorbing), classifies the session (balance vs trend
//  from the open relative to value), and keeps a built-in calibration layer that
//  reports whether reactions have measurable edge over a base rate instead of
//  asserting one. The HTF buy/sell candle canvas and the fused order-flow bias
//  remain, but as SUPPORTING context — the value is the confluence map and its
//  honest scoring, not any single verdict.
//
//  WHAT IT COMBINES AND WHY (mashup justification, see publication description):
//   0. MTF LEVEL CONFLUENCE (headline) — POC/VAH/VAL from every panel + prior
//      day/week levels + VWAP, clustered so aligned levels form one strong zone.
//      Only the multi-panel data makes this possible; no single-TF profile can.
//   1. HTF candles with buy/sell delta  — the spatial canvas: see several
//      timeframes' auctions at once without flipping charts.
//   2. Intrabar delta reconstruction (BVC) + native footprint where available —
//      turns raw volume into directional buy/sell pressure, honestly tagged
//      REAL (footprint aggressor data) vs EST (reconstruction).
//   3. Order-flow toxicity (VPIN family)  — how one-sided/aggressive flow is.
//   4. Market structure (swing breaks, BOS/CHoCH)  — directional context.
//   5. Probabilistic synthesis (log-odds fusion)  — blends the above into one
//      bias, averaging correlated inputs so agreement can't inflate confidence.
//   6. Forward calibration (base-rate + Wilson interval)  — measures whether the
//      synthesized verdict actually beats chance, and says so plainly.
//   These are not bolted together for show: each later stage consumes the prior
//   stages' output, and the calibration audits the whole. The components belong
//   in one tool because the value is the *synthesis and its honest scoring*, not
//   any single overlay.
//
//  CONCEPT CREDITS (methods, not code):
//   - Bulk Volume Classification / VPIN: Easley, López de Prado & O'Hara.
//   - Volume profile / value area: Steidlmayer (Market Profile).
//   - Market structure (swings / breaks): classical price-action / SMC concepts.
//   - Wilson score interval: E. B. Wilson (1927).
//   - Efficiency ratio (regime): Perry Kaufman.
//  Original implementation, architecture, fusion & calibration by the author.
//
//  HONEST USE: This is a context/awareness tool, not a signal generator. The
//  calibration is built to tell you when there is NO proven edge. Read the
//  "Use" line. Not financial advice.
// =============================================================================

//@version=6
indicator("Multi-Timeframe Order-Flow Cockpit", "MTF OrderFlow Cockpit", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ============================================================================
//  INPUTS  (organized: Data Source → Timeframes → Display → Engine → Calibration → Alerts)
// ============================================================================

// ---- 1. Data Source (change these to use any symbol / market) --------------
gSrc = "① Data Source"
srcSymbol   = input.symbol("", "Symbol (blank = chart)", group = gSrc,
     tooltip = "Leave blank to use the current chart symbol. Set a symbol to analyze any instrument/market from any chart.")
priceSource = input.source(close, "Price source", group = gSrc,
     tooltip = "Series used for structure/regime/divergence logic. Default close.")
finestTf    = input.timeframe("1S", "Finest intrabar TF (chart strip)", group = gSrc,
     tooltip = "Resolution used to reconstruct buy/sell delta for the chart-timeframe strip when native footprint isn't available. 1-second by default for the finest read; if your plan/symbol has no seconds data it automatically falls back to 1-minute. Use on intraday charts.")
autoFallbackMin = input.bool(true, "Auto fall back to 1m if seconds unavailable", group = gSrc,
     tooltip = "If the finest (seconds) resolution returns no data, reconstruct from 1-minute sub-bars instead. The strip's tag shows which resolution is active (e.g. EST·1S or EST·1m).")
htfLtf      = input.timeframe("1", "HTF panel intrabar TF", group = gSrc,
     tooltip = "Resolution used to reconstruct delta inside the higher-timeframe panels. Minutes recommended: seconds cannot span a higher-TF bar and would return no data. 1-minute default.")
deltaMode   = input.string("Weighted", "Delta method", options = ["Binary", "Weighted"], group = gSrc,
     tooltip = "Binary: each sub-bar is 100% buy or sell by close vs open. Weighted: split by where close sits in the sub-bar's range (smoother).")
useFootprint = input.bool(true, "Use native footprint (Premium) when available", group = gSrc,
     tooltip = "If your plan + symbol support it, the chart-timeframe strip uses REAL aggressor bid/ask volume. Otherwise it falls back to reconstruction and is tagged EST.")

// ---- 2. Higher-Timeframe Panels --------------------------------------------
gTf = "② Timeframe Panels"
showBaseStrip = input.bool(true, "Show chart-timeframe strip", group = gTf)
fpBaseN       = input.int(6, "Chart strip — candles", minval = 1, maxval = 50, group = gTf)

g1On = input.bool(true,  "Panel 1", inline = "g1", group = gTf)
g1Tf = input.timeframe("15", "", inline = "g1", group = gTf)
g1N  = input.int(5, "candles", inline = "g1", minval = 1, maxval = 50, group = gTf)

g2On = input.bool(true,  "Panel 2", inline = "g2", group = gTf)
g2Tf = input.timeframe("30", "", inline = "g2", group = gTf)
g2N  = input.int(5, "candles", inline = "g2", minval = 1, maxval = 50, group = gTf)

g3On = input.bool(true,  "Panel 3", inline = "g3", group = gTf)
g3Tf = input.timeframe("60", "", inline = "g3", group = gTf)
g3N  = input.int(5, "candles", inline = "g3", minval = 1, maxval = 50, group = gTf)

g4On = input.bool(true,  "Panel 4", inline = "g4", group = gTf)
g4Tf = input.timeframe("120", "", inline = "g4", group = gTf)
g4N  = input.int(5, "candles", inline = "g4", minval = 1, maxval = 50, group = gTf)

g5On = input.bool(true,  "Panel 5", inline = "g5", group = gTf)
g5Tf = input.timeframe("240", "", inline = "g5", group = gTf)
g5N  = input.int(5, "candles", inline = "g5", minval = 1, maxval = 50, group = gTf)

// ---- 3. Display -------------------------------------------------------------
gDisp = "③ Display"
showDelta = input.bool(true, "Split candles into buy/sell", group = gDisp)
scaleMode = input.string("Fit to Chart", "Scaling", options = ["Fit to Chart", "Original Prices"], group = gDisp,
     tooltip = "Fit to Chart squeezes panels into the visible range (level labels still show true price). Original Prices draws at true price.")
bodyW    = input.int(3, "Candle width", minval = 1, maxval = 5, group = gDisp)
spacing  = input.int(2, "Candle spacing", minval = 0, maxval = 20, group = gDisp)
gapBars  = input.int(10, "Gap from last bar", minval = 0, maxval = 50, group = gDisp)
panelGap = input.int(10, "Gap between panels", minval = 4, maxval = 40, group = gDisp,
     tooltip = "Horizontal spacing between timeframe panels. Larger = more room for high/low tags so nothing overlaps.")
wickW    = input.int(2, "Wick width", minval = 1, maxval = 6, group = gDisp)
lookback = input.int(300, "Scale lookback (bars)", minval = 50, maxval = 500, group = gDisp)
showSep  = input.bool(true, "Panel separators", group = gDisp)
showTint = input.bool(true, "Toxicity background tint", group = gDisp,
     tooltip = "Faint full-height tint behind each panel; opacity rises with order-flow toxicity.")
showHiLo = input.bool(true, "High / Low price tags on panels", group = gDisp,
     tooltip = "Tags the true high and low price of each timeframe's range, so you can read levels without switching charts.")
showNowMarker = input.bool(true, "Current-price marker on panels", group = gDisp,
     tooltip = "Marks where live price sits inside each timeframe's range (a dotted 'now' line), and notes if price is above/below that range.")

// ---- 3b. Volume Profile -----------------------------------------------------
gVP = "③ Display · Volume Profile"
showVP  = input.bool(true, "Show POC / VAH / VAL", group = gVP)
vaPct   = input.float(70, "Value area %", minval = 50, maxval = 95, group = gVP) / 100.0
vpBins  = input.int(24, "Profile bins", minval = 10, maxval = 100, group = gVP)
minCandlesStat = input.int(12, "Min candles for profile", minval = 5, maxval = 50, group = gVP,
     tooltip = "Profile stays hidden until a panel holds this many candles (a 5-candle profile is not meaningful).")

// ---- 3c. Key Levels (projected onto the chart at true price) ---------------
gLvl = "③ Display · Key Levels"
showLevels = input.bool(true, "Project key levels on chart", group = gLvl,
     tooltip = "Draws the main volume-profile levels (POC and value-area high/low) from the recent range as horizontal lines at TRUE price. These are estimated reference levels (where volume concentrated), not predictions.")
lvlLookback = input.int(150, "Levels lookback (bars)", minval = 20, maxval = 500, group = gLvl,
     tooltip = "How many recent bars build the profile that the projected levels come from.")
lvlExtend  = input.bool(true, "Extend levels to the right", group = gLvl)
showSwingLevels = input.bool(true, "Show recent structure levels", group = gLvl,
     tooltip = "The most recent confirmed swing high/low the structure logic is tracking — dotted reference lines.")

// ---- 4. Theme ---------------------------------------------------------------
gTheme = "④ Theme & Colors"
autoTheme = input.bool(true, "Adaptive theme (match chart background)", group = gTheme,
     tooltip = "Automatically choose light/dark text and panel backgrounds to stay readable on any chart theme.")
themeOverride = input.string("Auto", "Force theme", options = ["Auto", "Dark", "Light"], group = gTheme)
bullCol = input.color(#089981, "Buy / Bull", inline = "col", group = gTheme)
bearCol = input.color(#f23645, "Sell / Bear", inline = "col", group = gTheme)
baseBull = input.color(#22c1d6, "Chart-strip buy", inline = "bcol", group = gTheme)
baseBear = input.color(#d653c1, "Chart-strip sell", inline = "bcol", group = gTheme)
pocCol  = input.color(color.orange, "POC", inline = "vpc", group = gTheme)
vaCol   = input.color(#3b82f6, "VAH / VAL", inline = "vpc", group = gTheme)
lblSize = input.string("Normal", "On-chart label size", options = ["Small", "Normal", "Large"], group = gTheme,
     tooltip = "Uniform size for all on-chart text (timeframe tags, high/low, levels). Larger = bolder / more visible.")
markerIntensity = input.bool(true, "Position marker intensity scaling", group = gTheme,
     tooltip = "Brightens the current-price triangle as price stretches further beyond a timeframe's range; faint near the range edge, vivid on a strong break.")

// ---- 5. Readout Table -------------------------------------------------------
gTbl = "⑤ Readout Table"
showTable = input.bool(true, "Show table", group = gTbl)
tableMode = input.string("Compact", "Mode", options = ["Compact", "Pro"], group = gTbl,
     tooltip = "Compact: plain-language summary at a glance. Pro: full per-timeframe metrics.")
tablePos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gTbl)
tableSize = input.string("Small", "Text size", options = ["Small", "Normal", "Large"], group = gTbl,
     tooltip = "Smaller = more compact, less screen space. Increase if you want bigger text.")
showKeyInfo = input.bool(false, "Show Key Info table", group = gTbl,
     tooltip = "A separate one-glance legend explaining what each reading means. Off by default; turn on while learning the tool.")
keyInfoPos  = input.string("Bottom Left", "Key Info position", options = ["Bottom Left", "Bottom Right", "Top Left", "Middle Left"], group = gTbl)

// ---- 6. Synthesis Engine ----------------------------------------------------
gEng = "⑥ Synthesis Engine"
toxWindow = input.int(50, "Toxicity window (bars)", minval = 10, maxval = 200, group = gEng,
     tooltip = "Rolling window, in each panel's own bars, for the VPIN-style toxicity read.")
structPivLen = input.int(5, "Structure pivot length", minval = 2, maxval = 50, group = gEng,
     tooltip = "Swing-pivot lookback for break (BOS/CHoCH) detection, in each panel's own context.")
structWeight = input.float(0.4, "Structure weight in bias", minval = 0.0, maxval = 1.0, step = 0.05, group = gEng,
     tooltip = "How much structure vs delta drives a panel's direction. 0 = delta only.")
toxConv   = input.bool(true, "Toxicity scales conviction", group = gEng,
     tooltip = "One-sided/toxic flow pushes a panel's probability further from 50%; balanced flow pulls it back.")
weightByTF = input.bool(true, "Weight verdict by timeframe", group = gEng,
     tooltip = "Higher timeframes carry more weight in the combined verdict (context).")
corrDiscount = input.float(0.7, "Correlation discount", minval = 0.3, maxval = 1.0, step = 0.05, group = gEng,
     tooltip = "Deflates combined conviction to account for correlated inputs. 1.0 = trust agreement fully; lower = more skeptical.")
fusionGain = input.float(2.5, "Fusion gain", minval = 1.0, maxval = 5.0, step = 0.5, group = gEng,
     tooltip = "Maps a directional score to a probability. Higher = more decisive probabilities.")
divDamp = input.float(0.55, "Divergence damping", minval = 0.1, maxval = 1.0, step = 0.05, group = gEng,
     tooltip = "When price direction disagrees with delta, conviction is multiplied by this (toward 50%).")

// ---- 6b. Cross-asset volatility vote ---------------------------------------
gXa = "⑥ Synthesis · Volatility Vote"
useVol    = input.bool(true, "Add volatility (VIX-type) vote", group = gXa,
     tooltip = "Exogenous signal: a rising volatility index typically pressures the asset (bearish vote); falling = bullish. Set the symbol for your market.")
volSym    = input.symbol("NSE:INDIAVIX", "Volatility symbol", group = gXa,
     tooltip = "Volatility index for your market. Examples: NSE:INDIAVIX (India), TVC:VIX (US S&P), TVC:VXN (Nasdaq). Leave the vote off if none applies.")
volLen    = input.int(20, "Volatility ROC length", minval = 2, maxval = 200, group = gXa)
volScale  = input.float(20.0, "Volatility sensitivity", minval = 1.0, maxval = 100.0, step = 1.0, group = gXa)
volWeight = input.float(1.5, "Volatility weight", minval = 0.0, maxval = 5.0, step = 0.1, group = gXa)

// ---- 7. Calibration ---------------------------------------------------------
gCal = "⑦ Calibration (edge test)"
calibEnabled = input.bool(true, "Calibrate the verdict", group = gCal,
     tooltip = "Forward-tests every committed verdict against realized moves and reports Hit% vs Base% with a significance-gated edge.")
calTarget = input.string("Continuation", "Signal to test", options = ["Continuation", "Reversion"], group = gCal,
     tooltip = "Continuation = the main fused verdict. Reversion = a purpose-built fade signal (price at an extreme that delta fails to confirm).")
calHorizon = input.int(20, "Horizon (bars)", minval = 2, maxval = 200, group = gCal)
calMoveATR = input.float(1.0, "Target move (ATR)", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal)
calAtrLen  = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
calOutcome = input.string("Net move", "Outcome test", options = ["Net move", "Favorable touch"], group = gCal,
     tooltip = "Net move (endpoint): did price END the horizon at least the target in the predicted direction (discriminating). Favorable touch: did it merely TOUCH (lenient).")
regimeSplit = input.bool(true, "Split by trend/range regime", group = gCal,
     tooltip = "Reports the edge separately for Trending vs Ranging conditions (measured at entry).")
erLen    = input.int(20, "Regime length", minval = 5, maxval = 100, group = gCal)
erThresh = input.float(0.3, "Trend threshold", minval = 0.1, maxval = 0.9, step = 0.05, group = gCal)

// ---- 7b. Reversion signal tuning -------------------------------------------
gRev = "⑦ Calibration · Reversion signal"
revLen    = input.int(20, "Reversion lookback", minval = 5, maxval = 200, group = gRev)
revExtremePct = input.float(0.8, "Extreme threshold (range %)", minval = 0.55, maxval = 0.98, step = 0.01, group = gRev)
revConfirmZ   = input.float(0.5, "Delta-confirm z", minval = 0.0, maxval = 2.0, step = 0.1, group = gRev)
revRequireTox = input.bool(false, "Require toxicity spike", group = gRev)
revToxMult    = input.float(1.3, "Toxicity spike x", minval = 1.0, maxval = 3.0, step = 0.1, group = gRev)

// ---- 8. Alerts --------------------------------------------------------------
gAlert = "⑧ Alerts (attention cues)"
alertsOn     = input.bool(true,  "Enable alerts", group = gAlert,
     tooltip = "Attention cues: they flag where to look, never what to do. In TradingView create one alert with condition 'Any alert() function call'.")
alertVerdict = input.bool(true,  "Verdict shift", group = gAlert)
alertTox     = input.bool(true,  "Toxicity spike", group = gAlert)
alertDiv     = input.bool(true,  "Delta / price divergence", group = gAlert)
alertStruct  = input.bool(false, "Structure shift", group = gAlert)

// ---- 3d. MTF Confluence (the headline value) -------------------------------
gConf = "③ Display · MTF Confluence"
showConf   = input.bool(true, "Show MTF confluence zones", group = gConf, tooltip = "Cluster POC/VAH/VAL from every active timeframe panel, plus prior day/week levels and VWAP. Where several align within a band, that is a high-quality support/resistance zone — the hallmark of a professional volume-profile read, and this tool's core value.")
confTolATR = input.float(0.35, "Cluster width (x ATR)", minval = 0.1, maxval = 2.0, step = 0.05, group = gConf, tooltip = "Levels within this many ATRs of each other are treated as one zone.")
confMinN   = input.int(2, "Min aligned levels to qualify", minval = 2, maxval = 6, group = gConf)
usePDW     = input.bool(true, "Include prior day / week levels", group = gConf)
useVWAPc   = input.bool(true, "Include VWAP", group = gConf)
confUp     = input.color(color.new(#2ebd85, 78), "Support zone", inline = "cz", group = gConf)
confDn     = input.color(color.new(#f6465d, 78), "Resistance zone", inline = "cz", group = gConf)

// ============================================================================
//  THEME RESOLUTION (adaptive: readable on any chart background)
// ============================================================================
bool isDark = themeOverride == "Dark" ? true : themeOverride == "Light" ? false : na(chart.bg_color) ? true : (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3.0 < 128
color txtCol   = (autoTheme or themeOverride != "Auto") ? (isDark ? color.new(#e8e8e8, 0) : color.new(#1a1a1a, 0)) : color.new(#e8e8e8, 0)
color txtDim   = isDark ? color.new(#9aa0a6, 0) : color.new(#5f6368, 0)
color panelBg  = isDark ? color.new(#000000, 100) : color.new(#ffffff, 92)
color headBg   = isDark ? color.new(#787b86, 80) : color.new(#787b86, 75)
color hairline = isDark ? color.new(#787b86, 60) : color.new(#787b86, 55)
color cautionC = color.new(#f5a623, 0)
color goodC    = color.new(#089981, 0)
string lblSz = lblSize == "Small" ? size.small : lblSize == "Large" ? size.large : size.normal
// Theme-aware: faint markers stay visible on light charts; line ink contrasts bg.
int   faintFloor = isDark ? 72 : 50
color chartInk   = isDark ? color.new(#b2b5be, 35) : color.new(#363a45, 35)
// Bias inks for tags/markers — brighten on dark backgrounds, deepen on light.
color bullInk    = isDark ? color.new(#26e0a4, 0) : color.new(#0a7d5a, 0)
color bearInk    = isDark ? color.new(#ff5b6e, 0) : color.new(#c0142b, 0)
color neutralC   = isDark ? color.new(#ffd23f, 0) : color.new(#b8860b, 0)

// ============================================================================
//  TYPES
// ============================================================================
type Grp
    bool   on
    int    n
    string tfStr
    color  bull
    color  bear
    bool   real
    int    tfSec
    float  devO
    float  devH
    float  devL
    float  devC
    float  devV
    float  devBuy
    float  devSell
    float  devTox
    int    devStruct
    string srcNote
    array<float> o
    array<float> h
    array<float> l
    array<float> c
    array<float> v
    array<float> buy
    array<float> sell

type Payload
    float o
    float h
    float l
    float c
    float v
    float buy
    float sell
    int   t
    float tox
    int   structState

// ============================================================================
//  PURE FUNCTIONS  (timeframe-agnostic math; reusable)
// ============================================================================
classifyBinary(array<float> o, array<float> c, array<float> v) =>
    float buy = 0.0, float sell = 0.0
    int n = array.size(c)
    if n > 0
        for i = 0 to n - 1
            float vol = array.get(v, i)
            if not na(vol)
                if array.get(c, i) >= array.get(o, i)
                    buy += vol
                else
                    sell += vol
    [buy, sell]

classifyWeighted(array<float> o, array<float> h, array<float> l, array<float> c, array<float> v) =>
    float buy = 0.0, float sell = 0.0
    int n = array.size(c)
    if n > 0
        for i = 0 to n - 1
            float vol = array.get(v, i)
            if not na(vol)
                float hh = array.get(h, i), float ll = array.get(l, i)
                float cc = array.get(c, i), float oo = array.get(o, i)
                float frac = hh > ll ? (cc - ll) / (hh - ll) : (cc >= oo ? 1.0 : 0.0)
                frac := math.max(0.0, math.min(1.0, frac))
                buy  += vol * frac
                sell += vol * (1.0 - frac)
    [buy, sell]

buildProfile(array<float> hi, array<float> lo, array<float> vol, int bins, float vaP) =>
    int n = array.size(hi)
    float pMax = array.max(hi), float pMin = array.min(lo)
    float binSz = math.max((pMax - pMin) / bins, syminfo.mintick)
    array<float> bv = array.new<float>(bins, 0.0)
    for i = 0 to n - 1
        float ch = array.get(hi, i), float cl = array.get(lo, i), float cv = nz(array.get(vol, i))
        float crng = math.max(ch - cl, syminfo.mintick)
        int b0 = math.max(0, int(math.floor((cl - pMin) / binSz)))
        int b1 = math.min(bins - 1, int(math.floor((ch - pMin) / binSz)))
        for b = b0 to b1
            float binLo = pMin + b * binSz
            float ov = math.min(ch, binLo + binSz) - math.max(cl, binLo)
            if ov > 0
                array.set(bv, b, array.get(bv, b) + cv * (ov / crng))
    int pocIdx = 0
    float pocVol = 0.0, float totVol = 0.0
    for b = 0 to bins - 1
        float x = array.get(bv, b)
        totVol += x
        if x > pocVol
            pocVol := x
            pocIdx := b
    float acc = pocVol
    int up = pocIdx, int dn = pocIdx
    float target = totVol * vaP
    while acc < target and (up < bins - 1 or dn > 0)
        float upV = up < bins - 1 ? array.get(bv, up + 1) : -1.0
        float dnV = dn > 0 ? array.get(bv, dn - 1) : -1.0
        if upV >= dnV
            up += 1
            acc += math.max(upV, 0.0)
        else
            dn -= 1
            acc += math.max(dnV, 0.0)
    [pMin + (pocIdx + 0.5) * binSz, pMin + (up + 1) * binSz, pMin + dn * binSz]

fmtVol(float v) =>
    v >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : v >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : v >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" : str.tostring(v, "#")

logitToP(float L) => 1.0 / (1.0 + math.exp(-L))

wilsonLow(float p, int n) =>
    float r = na
    if not na(p) and n > 0
        float z = 1.96
        float denom = 1.0 + z * z / n
        float centre = p + z * z / (2.0 * n)
        float margin = z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))
        r := (centre - margin) / denom
    r

txtSizeOf(string s) => s == "Small" ? size.small : s == "Large" ? size.large : size.normal

posOf(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : s == "Middle Left" ? position.middle_left : position.top_right

// per-panel readouts
panelMetrics(Grp g) =>
    int nC = array.size(g.c)
    float buyTot = 0.0, float sellTot = 0.0, float volTot = 0.0
    int bullCnt = 0, int total = 0
    for s = 0 to nC
        bool isDev = s == nC
        float oo = isDev ? g.devO : array.get(g.o, s)
        float cc = isDev ? g.devC : array.get(g.c, s)
        float vv = isDev ? g.devV : array.get(g.v, s)
        float bb = isDev ? g.devBuy : array.get(g.buy, s)
        float ss = isDev ? g.devSell : array.get(g.sell, s)
        if not na(oo)
            buyTot += nz(bb)
            sellTot += nz(ss)
            volTot += nz(vv)
            if cc >= oo
                bullCnt += 1
            total += 1
    float deltaPct = (buyTot + sellTot) > 0 ? buyTot / (buyTot + sellTot) * 100.0 : na
    float dirBias = total > 0 ? (bullCnt / float(total) * 2.0 - 1.0) : 0.0
    float deltaBias = na(deltaPct) ? 0.0 : (deltaPct / 100.0 * 2.0 - 1.0)
    [deltaPct, g.devTox, deltaBias, dirBias, volTot]

// per-panel probability (delta-led; structure can flip sign; toxicity scales conviction)
// Per-panel POC/VAH/VAL (reuses buildProfile on the panel's own candles)
f_panelPVL(Grp g) =>
    int nC = array.size(g.c)
    float poc = na
    float vah = na
    float val = na
    if g.on and nC + 1 >= minCandlesStat and not na(g.devH)
        array<float> aH = array.new<float>()
        array<float> aL = array.new<float>()
        array<float> aV = array.new<float>()
        if nC > 0
            for i = 0 to nC - 1
                aH.push(array.get(g.h, i))
                aL.push(array.get(g.l, i))
                aV.push(array.get(g.v, i))
        aH.push(g.devH)
        aL.push(g.devL)
        aV.push(g.devV)
        [p, h, l] = buildProfile(aH, aL, aV, vpBins, vaPct)
        poc := p
        vah := h
        val := l
    [poc, vah, val]

// Push a level into the confluence pool with a weight + name (skips na)
f_addLvl(array<float> ap, array<float> aw, array<string> an, float px, float w, string nm) =>
    if not na(px)
        ap.push(px)
        aw.push(w)
        an.push(nm)

panelProb(Grp g) =>
    [dPct, tox, dB, dirB, vTot] = panelMetrics(g)
    bool isNa = na(dPct)
    float structSign = nz(g.devStruct, 0)
    float dirScore = (1.0 - structWeight) * dB + structWeight * structSign
    bool agree = structSign == 0 ? true : (dB * structSign) >= 0
    float convMul = agree ? 1.0 : divDamp
    float toxFactor = toxConv ? (0.5 + math.min(nz(tox, 0.0), 1.0)) : 1.0
    float L = isNa ? 0.0 : fusionGain * dirScore * convMul * toxFactor
    [logitToP(L), L, nz(tox, na), isNa]

// ============================================================================
//  DRAWING POOLS
// ============================================================================
var array<box>   boxes  = array.new<box>()
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()

clearAll() =>
    for b in boxes
        box.delete(b)
    boxes.clear()
    for ln in lines
        line.delete(ln)
    lines.clear()
    for lb in labels
        label.delete(lb)
    labels.clear()

mkBox(int l, float top, int r, float bot, color col) =>
    if boxes.size() < 498
        boxes.push(box.new(l, top, r, bot, border_color = na, bgcolor = col, xloc = xloc.bar_index))

mkLine(int x1, float y1, int x2, float y2, color col, string st, int w) =>
    if lines.size() < 498
        lines.push(line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = col, style = st, width = w))

mkLabel(int x, float y, string txt, color c, string yl, string st) =>
    if labels.size() < 498
        labels.push(label.new(x, y, txt, xloc = xloc.bar_index, yloc = yl, style = st, color = color.new(color.gray, 100), textcolor = c, size = lblSz))

mkTag(int x, float y, string txt, color c, string st) =>
    if labels.size() < 498
        labels.push(label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = st, color = color.new(color.gray, 100), textcolor = c, size = lblSz))

mkMarker(int x, float y, color c) =>
    if labels.size() < 498
        labels.push(label.new(x, y, "◀", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, color = color.new(color.gray, 100), textcolor = c, size = lblSz))

mapY(float price, float gMin, float gMax, float vLo, float vHi) =>
    scaleMode == "Original Prices" ? price : vLo + (price - gMin) / math.max(gMax - gMin, syminfo.mintick) * (vHi - vLo)

drawLevel(int x1, int x2, float price, color col, string name, float gMin, float gMax, float vLo, float vHi) =>
    float y = mapY(price, gMin, gMax, vLo, vHi)
    mkLine(x1, y, x2, y, col, name == "POC" ? line.style_solid : line.style_dashed, 1)
    mkLabel(x2 + 1, y, name + " " + str.tostring(price, format.mintick), col, yloc.price, label.style_label_left)

// ============================================================================
//  DATA FETCH  (every bar)
// ============================================================================
symId = srcSymbol == "" ? syminfo.tickerid : srcSymbol

// HTF payload (UDT): nested intrabar delta + in-context toxicity + structure
payload(simple string sym, simple string ltf) =>
    [lo, lh, ll, lc, lv] = request.security_lower_tf(sym, ltf, [open, high, low, close, volume])
    float bv = 0.0, float sv = 0.0
    if deltaMode == "Weighted"
        [b, s] = classifyWeighted(lo, lh, ll, lc, lv)
        bv := b
        sv := s
    else
        [b, s] = classifyBinary(lo, lc, lv)
        bv := b
        sv := s
    float vp = ta.sma(math.abs(bv - sv), toxWindow) / math.max(ta.sma(bv + sv, toxWindow), 1e-9)
    float ph = ta.pivothigh(structPivLen, structPivLen)
    float pl = ta.pivotlow(structPivLen, structPivLen)
    var float sH = na, var float sL = na, var int sBias = 0
    sH := na(ph) ? sH : ph
    sL := na(pl) ? sL : pl
    if not na(sH) and close > sH
        sBias := 1
        sH := na
    if not na(sL) and close < sL
        sBias := -1
        sL := na
    Payload.new(open, high, low, close, volume, bv, sv, time, vp, sBias)

// Native footprint (single call, chart context). na on unsupported plan/symbol.
footprint fpRaw = useFootprint ? request.footprint(50, int(vaPct * 100), 300) : na
bool fpLive = useFootprint and not na(fpRaw)
float fpBuy = na, float fpSell = na
if fpLive
    fpBuy  := footprint.buy_volume(fpRaw)
    fpSell := footprint.sell_volume(fpRaw)

// Chart-context reconstruction for the base strip: finest (e.g. 1S) with
// automatic fallback to 1-minute when seconds data is unavailable. Both
// requests are issued; the one that returns data is selected at runtime.
[fo, fh, fl, fc, fv] = request.security_lower_tf(symId, finestTf, [open, high, low, close, volume], calc_bars_count = 5000)
[mo, mh, ml, mc, mv] = request.security_lower_tf(symId, "1", [open, high, low, close, volume], calc_bars_count = 5000)
bool finestOk = array.size(fc) > 0
bool useFallbackTf = autoFallbackMin and not finestOk
array<float> clo = useFallbackTf ? mo : fo
array<float> clh = useFallbackTf ? mh : fh
array<float> cll = useFallbackTf ? ml : fl
array<float> clc = useFallbackTf ? mc : fc
array<float> clv = useFallbackTf ? mv : fv
string baseLtfActive = useFallbackTf ? "1m" : (str.contains(finestTf, "S") ? finestTf : finestTf + "m")
float rbBuy = 0.0, float rbSell = 0.0
if deltaMode == "Weighted"
    [b, s] = classifyWeighted(clo, clh, cll, clc, clv)
    rbBuy := b
    rbSell := s
else
    [b, s] = classifyBinary(clo, clc, clv)
    rbBuy := b
    rbSell := s
float baseBuy  = fpLive ? fpBuy  : rbBuy
float baseSell = fpLive ? fpSell : rbSell
float baseTox  = ta.sma(math.abs(baseBuy - baseSell), toxWindow) / math.max(ta.sma(baseBuy + baseSell, toxWindow), 1e-9)

// Base strip structure (chart context)
float bPh = ta.pivothigh(structPivLen, structPivLen)
float bPl = ta.pivotlow(structPivLen, structPivLen)
var float bH = na, var float bL = na, var int baseStruct = 0
bH := na(bPh) ? bH : bPh
bL := na(bPl) ? bL : bPl
if not na(bH) and close > bH
    baseStruct := 1
    bH := na
if not na(bL) and close < bL
    baseStruct := -1
    bL := na
// Persistent last-swing trackers for projected structure levels (not consumed)
var float lastSwingH = na
var float lastSwingL = na
lastSwingH := na(bPh) ? lastSwingH : bPh
lastSwingL := na(bPl) ? lastSwingL : bPl

// Volatility (exogenous) vote
float volx = useVol ? request.security(volSym, timeframe.period, close, ignore_invalid_symbol = true) : na
float volRoc = (not na(volx) and not na(volx[volLen]) and volx[volLen] != 0) ? (volx - volx[volLen]) / volx[volLen] : na
float volBias = na(volRoc) ? na : -math.max(-1.0, math.min(1.0, volRoc * volScale))

// Prior-period levels, VWAP and session open → confluence pool + day-type read
[pdH, pdL, pdC] = request.security(symId, "D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_off)
[pwH, pwL] = request.security(symId, "W", [high[1], low[1]], lookahead = barmerge.lookahead_off)
float dOpen = request.security(symId, "D", open, lookahead = barmerge.lookahead_off)
float vwapV = ta.vwap(hlc3)
float atr14 = ta.atr(14)   // global scope so it has history; used by the confluence tolerance
bool  havePD = not na(pdH) and not na(pdL)
string dayType = not havePD ? "-" : (dOpen > pdH ? "Trend day (opened above value)" : dOpen < pdL ? "Trend day (opened below value)" : "Balance day (opened inside value)")
plot(showConf and useVWAPc ? vwapV : na, "VWAP", color.new(#ff9800, 0), 1)

// Reversion / exhaustion signal (chart context)
float revCumDelta = math.sum(nz(baseBuy) - nz(baseSell), revLen)
float revHi = ta.highest(high, revLen), float revLo = ta.lowest(low, revLen)
float revPos = revHi > revLo ? (close - revLo) / (revHi - revLo) : 0.5
float revDMean = ta.sma(revCumDelta, revLen * 3)
float revDStd  = ta.stdev(revCumDelta, revLen * 3)
float revDz = revDStd > 0 ? (revCumDelta - revDMean) / revDStd : 0.0
bool  bearDiv = revPos >= revExtremePct and revDz < revConfirmZ
bool  bullDiv = revPos <= (1.0 - revExtremePct) and revDz > -revConfirmZ
float revToxSma = ta.sma(baseTox, revLen * 2)
bool  revToxOk = (not revRequireTox) or (baseTox > revToxSma * revToxMult)
int   revDir = (bearDiv and revToxOk) ? -1 : (bullDiv and revToxOk) ? 1 : 0

// ============================================================================
//  ACCUMULATION
// ============================================================================
pushC(Grp g, float o, float h, float l, float c, float v, float bv, float sv) =>
    g.o.push(o), g.h.push(h), g.l.push(l), g.c.push(c), g.v.push(v), g.buy.push(bv), g.sell.push(sv)
    if g.o.size() > g.n
        g.o.shift(), g.h.shift(), g.l.shift(), g.c.shift(), g.v.shift(), g.buy.shift(), g.sell.shift()

newGrp() =>
    Grp.new(false, 1, "", bullCol, bearCol, false, 0, na, na, na, na, na, na, na, na, 0, "",
         array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(),
         array.new<float>(), array.new<float>(), array.new<float>())

updateGrp(Grp g, Payload cur, Payload prev) =>
    g.devO := cur.o, g.devH := cur.h, g.devL := cur.l, g.devC := cur.c, g.devV := cur.v
    g.devBuy := cur.buy, g.devSell := cur.sell, g.devTox := cur.tox, g.devStruct := cur.structState
    bool isNew = na(prev) ? false : cur.t != prev.t
    if isNew and not na(prev) and not na(prev.o)
        pushC(g, prev.o, prev.h, prev.l, prev.c, prev.v, prev.buy, prev.sell)

var grp1 = newGrp(), var grp2 = newGrp(), var grp3 = newGrp(), var grp4 = newGrp(), var grp5 = newGrp()
var grps = array.from(grp1, grp2, grp3, grp4, grp5)
var baseGrp = newGrp()

grp1.on := g1On, grp1.n := g1N, grp1.tfStr := g1Tf, grp1.bull := bullCol, grp1.bear := bearCol, grp1.tfSec := timeframe.in_seconds(g1Tf)
grp2.on := g2On, grp2.n := g2N, grp2.tfStr := g2Tf, grp2.bull := bullCol, grp2.bear := bearCol, grp2.tfSec := timeframe.in_seconds(g2Tf)
grp3.on := g3On, grp3.n := g3N, grp3.tfStr := g3Tf, grp3.bull := bullCol, grp3.bear := bearCol, grp3.tfSec := timeframe.in_seconds(g3Tf)
grp4.on := g4On, grp4.n := g4N, grp4.tfStr := g4Tf, grp4.bull := bullCol, grp4.bear := bearCol, grp4.tfSec := timeframe.in_seconds(g4Tf)
grp5.on := g5On, grp5.n := g5N, grp5.tfStr := g5Tf, grp5.bull := bullCol, grp5.bear := bearCol, grp5.tfSec := timeframe.in_seconds(g5Tf)
baseGrp.on := showBaseStrip, baseGrp.n := fpBaseN, baseGrp.tfStr := timeframe.period
baseGrp.bull := baseBull, baseGrp.bear := baseBear, baseGrp.real := fpLive, baseGrp.tfSec := timeframe.in_seconds(timeframe.period)
baseGrp.srcNote := fpLive ? "" : baseLtfActive

Payload d1 = request.security(symId, g1Tf, payload(symId, htfLtf))
updateGrp(grp1, d1, d1[1])
Payload d2 = request.security(symId, g2Tf, payload(symId, htfLtf))
updateGrp(grp2, d2, d2[1])
Payload d3 = request.security(symId, g3Tf, payload(symId, htfLtf))
updateGrp(grp3, d3, d3[1])
Payload d4 = request.security(symId, g4Tf, payload(symId, htfLtf))
updateGrp(grp4, d4, d4[1])
Payload d5 = request.security(symId, g5Tf, payload(symId, htfLtf))
updateGrp(grp5, d5, d5[1])

Payload baseCur  = Payload.new(open, high, low, close, volume, baseBuy, baseSell, time, baseTox, baseStruct)
Payload basePrev = Payload.new(open[1], high[1], low[1], close[1], volume[1], baseBuy[1], baseSell[1], time[1], baseTox[1], baseStruct[1])
updateGrp(baseGrp, baseCur, basePrev)

// ============================================================================
//  SYNTHESIS  (combined verdict)
// ============================================================================
computeNet(float volB) =>
    float wSum = 0.0, float wlSum = 0.0
    if showBaseStrip
        [pb, lb, ib, nb] = panelProb(baseGrp)
        if not nb
            float w = weightByTF ? math.sqrt(baseGrp.tfSec) : 1.0
            wSum += w
            wlSum += w * lb
    for grp in grps
        if grp.on
            [pg, lg, ig, ng] = panelProb(grp)
            if not ng
                float w = weightByTF ? math.sqrt(grp.tfSec) : 1.0
                wSum += w
                wlSum += w * lg
    if useVol and not na(volB)
        wSum += volWeight
        wlSum += volWeight * (fusionGain * volB)
    float Lnet = wSum > 0 ? (wlSum / wSum) * corrDiscount : 0.0
    [logitToP(Lnet), wSum]

[netP, netW] = computeNet(volBias)
int netDir = netP > 0.55 ? 1 : netP < 0.45 ? -1 : 0
int sigDir = calTarget == "Reversion" ? revDir : netDir

// ============================================================================
//  EXP_ EXPORT BUS  (generic names for cross-script access via input.source)
// ============================================================================
float expChartDelta = nz(baseBuy) - nz(baseSell)
float expDeltaBias  = (nz(baseBuy) + nz(baseSell)) > 0 ? (nz(baseBuy) - nz(baseSell)) / (nz(baseBuy) + nz(baseSell)) : 0.0
plot(netP,                        "EXP_NetProb",    color = color.new(color.gray, 100), display = display.data_window)
plot(netDir,                      "EXP_NetDir",     color = color.new(color.gray, 100), display = display.data_window)
plot(sigDir,                      "EXP_SignalDir",  color = color.new(color.gray, 100), display = display.data_window)
plot(expChartDelta,               "EXP_ChartDelta", color = color.new(color.gray, 100), display = display.data_window)
plot(expDeltaBias,                "EXP_DeltaBias",  color = color.new(color.gray, 100), display = display.data_window)
plot(baseTox,                     "EXP_Toxicity",   color = color.new(color.gray, 100), display = display.data_window)
plot(na(volBias) ? na : volBias,  "EXP_VolBias",    color = color.new(color.gray, 100), display = display.data_window)
plot(revCumDelta,                 "EXP_CumDelta",   color = color.new(color.gray, 100), display = display.data_window)
plot(revDz,                       "EXP_RevDeltaZ",  color = color.new(color.gray, 100), display = display.data_window)

// ============================================================================
//  CALIBRATION  (forward-test the verdict)
// ============================================================================
float calAtr = ta.atr(calAtrLen)
float calHi = ta.highest(high, calHorizon)
float calLo = ta.lowest(low, calHorizon)
float erChange = math.abs(priceSource - priceSource[erLen])
float erVol    = math.sum(math.abs(priceSource - priceSource[1]), erLen)
float er = erVol > 0 ? erChange / erVol : 0.0
bool  trending = er > erThresh

var int bN_T = 0, var int bH_T = 0, var int sN_T = 0, var int sH_T = 0, var int res_T = 0, var int bu_T = 0, var int bd_T = 0
var int bN_R = 0, var int bH_R = 0, var int sN_R = 0, var int sH_R = 0, var int res_R = 0, var int bu_R = 0, var int bd_R = 0

if calibEnabled and barstate.isconfirmed and bar_index > calHorizon + calAtrLen + 5
    int   dirPast = sigDir[calHorizon]
    float entryC  = close[calHorizon]
    float thr     = calMoveATR * calAtr[calHorizon]
    bool upHit = false, bool dnHit = false
    if calOutcome == "Net move"
        float nm = close - entryC
        upHit := nm >= thr
        dnHit := nm <= -thr
    else
        upHit := (calHi - entryC) >= thr
        dnHit := (entryC - calLo) >= thr
    bool trendPast = trending[calHorizon]
    if not na(thr) and thr > 0
        if trendPast
            res_T += 1
            bu_T += upHit ? 1 : 0
            bd_T += dnHit ? 1 : 0
            if dirPast == 1
                bN_T += 1
                bH_T += upHit ? 1 : 0
            else if dirPast == -1
                sN_T += 1
                sH_T += dnHit ? 1 : 0
        else
            res_R += 1
            bu_R += upHit ? 1 : 0
            bd_R += dnHit ? 1 : 0
            if dirPast == 1
                bN_R += 1
                bH_R += upHit ? 1 : 0
            else if dirPast == -1
                sN_R += 1
                sH_R += dnHit ? 1 : 0

// ============================================================================
//  ALERTS  (attention cues — never trade instructions)
// ============================================================================
bool aToxSpike = baseTox > revToxSma * revToxMult
if alertsOn and barstate.isconfirmed
    if alertVerdict and netDir != netDir[1] and netDir != 0
        alert("Order-Flow Cockpit: verdict shifted " + (netDir == 1 ? "BULLISH" : "BEARISH") + " (P " + str.tostring(netP * 100, "#") + "%). Attention cue — look here, not a trade signal.", alert.freq_once_per_bar_close)
    if alertTox and aToxSpike and not aToxSpike[1]
        alert("Order-Flow Cockpit: toxicity spike on chart TF (" + str.tostring(baseTox, "#.00") + "). One-sided aggressive flow — worth a look.", alert.freq_once_per_bar_close)
    if alertDiv and ((bearDiv and not bearDiv[1]) or (bullDiv and not bullDiv[1]))
        alert("Order-Flow Cockpit: " + (bearDiv ? "bearish" : "bullish") + " delta/price divergence at extreme. Possible exhaustion — look here.", alert.freq_once_per_bar_close)
    if alertStruct and baseStruct != baseStruct[1] and baseStruct != 0
        alert("Order-Flow Cockpit: structure shifted " + (baseStruct == 1 ? "bullish" : "bearish") + " on chart TF.", alert.freq_once_per_bar_close)

float visHigh = ta.highest(high, lookback)
float visLow  = ta.lowest(low, lookback)

// ============================================================================
//  RENDER ONE PANEL
// ============================================================================
drawGroup(Grp g, int startX, float vLo, float vHi) =>
    int nC = array.size(g.c)
    float gMin = g.devL, float gMax = g.devH
    for i = 0 to nC - 1
        gMin := math.min(gMin, array.get(g.l, i))
        gMax := math.max(gMax, array.get(g.h, i))
    if na(gMin) or na(gMax)
        gMin := vLo
        gMax := vHi
    int slotW = bodyW + spacing
    int totalC = nC + 1
    if showTint and not na(g.devTox)
        float tr = math.max(0.0, math.min(1.0, g.devTox))
        mkBox(startX - 1, vHi, startX + (nC + 1) * slotW, vLo, color.new(cautionC, int(94 - tr * 24)))
    for s = 0 to nC
        bool isDev = s == nC
        float oo = isDev ? g.devO : array.get(g.o, s)
        float hh = isDev ? g.devH : array.get(g.h, s)
        float ll = isDev ? g.devL : array.get(g.l, s)
        float cc = isDev ? g.devC : array.get(g.c, s)
        float bb = isDev ? g.devBuy : array.get(g.buy, s)
        float ss = isDev ? g.devSell : array.get(g.sell, s)
        if not na(oo)
            int x = startX + s * slotW
            float topP = math.max(oo, cc), float botP = math.min(oo, cc)
            mkLine(x + bodyW / 2, mapY(hh, gMin, gMax, vLo, vHi), x + bodyW / 2, mapY(ll, gMin, gMax, vLo, vHi), cc >= oo ? g.bull : g.bear, line.style_solid, wickW)
            if showDelta and (nz(bb) + nz(ss)) > 0 and topP > botP
                float frac = nz(bb) / (nz(bb) + nz(ss))
                float splitP = botP + (topP - botP) * frac
                mkBox(x, mapY(splitP, gMin, gMax, vLo, vHi), x + bodyW, mapY(botP, gMin, gMax, vLo, vHi), g.bull)
                mkBox(x, mapY(topP, gMin, gMax, vLo, vHi), x + bodyW, mapY(splitP, gMin, gMax, vLo, vHi), g.bear)
            else
                float tP = topP == botP ? topP + syminfo.mintick : topP
                mkBox(x, mapY(tP, gMin, gMax, vLo, vHi), x + bodyW, mapY(botP, gMin, gMax, vLo, vHi), cc >= oo ? g.bull : g.bear)
    int lastX = startX + nC * slotW + bodyW
    int midX = startX + (nC * slotW) / 2
    [pTag, lTag, toxTag, naTag] = panelProb(g)
    color tagCol = naTag ? txtDim : pTag > 0.53 ? bullInk : pTag < 0.47 ? bearInk : neutralC
    string srcTag = (g.real ? "REAL" : "EST") + (g.srcNote != "" ? "·" + g.srcNote : "")
    mkLabel(midX, mapY(gMax, gMin, gMax, vLo, vHi), g.tfStr + "  " + srcTag, tagCol, yloc.price, label.style_label_down)
    // High / Low price tags aligned to the panel's candle structure (compact, no overlap)
    if showHiLo and not na(gMax) and not na(gMin)
        mkTag(midX, mapY(gMax, gMin, gMax, vLo, vHi), str.tostring(gMax, format.mintick), txtDim, label.style_label_up)
        mkTag(midX, mapY(gMin, gMin, gMax, vLo, vHi), str.tostring(gMin, format.mintick), txtDim, label.style_label_down)
    // Current-price marker: a single triangle pointing at the panel, colored by position
    if showNowMarker and not na(gMax) and not na(gMin)
        float pnow = close
        bool above = pnow > gMax, bool below = pnow < gMin
        float yNow = mapY(math.min(gMax, math.max(gMin, pnow)), gMin, gMax, vLo, vHi)
        float rng = math.max(gMax - gMin, syminfo.mintick)
        color baseC = above ? bullInk : below ? bearInk : neutralC
        float intensity = 0.0
        if above
            intensity := math.min((pnow - gMax) / rng, 1.0)        // 0..1, how far above
        else if below
            intensity := math.min((gMin - pnow) / rng, 1.0)        // 0..1, how far below
        else
            intensity := math.abs((pnow - (gMin + gMax) / 2.0) / (rng / 2.0)) * 0.5   // inside: 0 mid .. ~0.5 at edge
        // map intensity -> transparency: faint (75) when weak, vivid (0) when strong
        int transp = markerIntensity ? int(faintFloor - faintFloor * math.max(0.0, math.min(1.0, intensity))) : 0
        color nowC = color.new(baseC, transp)
        mkMarker(lastX + 1, yNow, nowC)
    if showVP and totalC >= minCandlesStat
        array<float> aH = array.new<float>(), array<float> aL = array.new<float>(), array<float> aV = array.new<float>()
        for i = 0 to nC - 1
            aH.push(array.get(g.h, i)), aL.push(array.get(g.l, i)), aV.push(array.get(g.v, i))
        aH.push(g.devH), aL.push(g.devL), aV.push(g.devV)
        [poc, vah, val] = buildProfile(aH, aL, aV, vpBins, vaPct)
        drawLevel(startX, lastX, poc, pocCol, "POC", gMin, gMax, vLo, vHi)
        drawLevel(startX, lastX, vah, vaCol, "VAH", gMin, gMax, vLo, vHi)
        drawLevel(startX, lastX, val, vaCol, "VAL", gMin, gMax, vLo, vHi)
    lastX

// ============================================================================
//  TABLES
// ============================================================================
var table tbl  = table.new(posOf(tablePos), 7, 13, border_width = 1, border_color = hairline, frame_width = 1, frame_color = hairline)
var table tkey = table.new(posOf(keyInfoPos), 2, 9, border_width = 1, border_color = hairline, frame_width = 1, frame_color = hairline)

proRow(table t, int r, Grp g, string ts) =>
    [dPct, tox, dB, dirB, vTot] = panelMetrics(g)
    [P, L, toxv, isNa] = panelProb(g)
    int st = int(nz(g.devStruct, 0))
    table.cell(t, 0, r, g.tfStr, text_color = txtCol, text_size = ts, bgcolor = panelBg)
    table.cell(t, 1, r, g.real ? "REAL" : "EST", text_color = g.real ? goodC : txtDim, text_size = ts, bgcolor = panelBg)
    table.cell(t, 2, r, fmtVol(vTot), text_color = txtDim, text_size = ts, bgcolor = panelBg)
    table.cell(t, 3, r, na(dPct) ? "–" : str.tostring(dPct, "#") + "%", text_color = txtCol, text_size = ts, bgcolor = panelBg)
    table.cell(t, 4, r, na(toxv) ? "–" : str.tostring(toxv, "#.00"), text_color = cautionC, text_size = ts, bgcolor = panelBg)
    table.cell(t, 5, r, st == 1 ? "▲" : st == -1 ? "▼" : "·", text_color = st == 1 ? bullCol : st == -1 ? bearCol : txtDim, text_size = ts, bgcolor = panelBg)
    table.cell(t, 6, r, isNa ? "–" : str.tostring(P * 100, "#") + (P > 0.5 ? "▲" : P < 0.5 ? "▼" : "·"), text_color = isNa ? txtDim : color.from_gradient(P, 0.0, 1.0, bearCol, bullCol), text_size = ts, bgcolor = panelBg)

calRow(table t, int r, string lbl, int bN, int bH, int sN, int sH, int res, int bu, int bd, string ts) =>
    int aggN = bN + sN, int aggH = bH + sH
    float hitR = aggN > 0 ? aggH / float(aggN) : na
    float buR = res > 0 ? bu / float(res) : na, float bdR = res > 0 ? bd / float(res) : na
    float mBase = (aggN > 0 and not na(buR) and not na(bdR)) ? (bN * buR + sN * bdR) / float(aggN) : na
    float edge = (na(hitR) or na(mBase)) ? na : hitR - mBase
    float wlow = wilsonLow(hitR, aggN)
    bool sig = not na(wlow) and not na(mBase) and wlow > mBase
    color cbg = isDark ? color.new(#787b86, 90) : color.new(#787b86, 85)
    table.cell(t, 0, r, lbl, text_color = txtCol, text_size = ts, bgcolor = cbg)
    table.cell(t, 1, r, "n" + str.tostring(aggN), text_color = txtDim, text_size = ts, bgcolor = cbg)
    table.cell(t, 2, r, na(hitR) ? "–" : "H" + str.tostring(hitR * 100, "#"), text_color = goodC, text_size = ts, bgcolor = cbg)
    table.cell(t, 3, r, na(mBase) ? "–" : "B" + str.tostring(mBase * 100, "#"), text_color = txtDim, text_size = ts, bgcolor = cbg)
    table.cell(t, 4, r, na(edge) ? "–" : (edge >= 0 ? "+" : "") + str.tostring(edge * 100, "#"), text_color = na(edge) ? txtDim : edge >= 0 ? bullCol : bearCol, text_size = ts, bgcolor = cbg)
    table.cell(t, 5, r, "", bgcolor = cbg)
    table.cell(t, 6, r, sig ? "★" : "·", text_color = sig ? cautionC : txtDim, text_size = ts, bgcolor = cbg)

// ============================================================================
//  MAIN  (draw once, on the last bar)
// ============================================================================
if barstate.islast
    clearAll()
    string ts = txtSizeOf(tableSize)
    int cursorX = bar_index + gapBars
    bool first = true
    if showBaseStrip
        cursorX := drawGroup(baseGrp, cursorX, visLow, visHigh) + panelGap
        first := false
    for grp in grps
        if grp.on
            if not first and showSep
                mkLine(cursorX - 1, visHigh, cursorX - 1, visLow, chartInk, line.style_dotted, 1)
            cursorX := drawGroup(grp, cursorX, visLow, visHigh) + panelGap
            first := false

    // ---- KEY LEVELS projected at true price across the chart ----------------
    if showLevels
        int lb = math.min(lvlLookback, bar_index)
        if lb > 5
            array<float> lh = array.new<float>(), array<float> ll = array.new<float>(), array<float> lvv = array.new<float>()
            for i = 0 to lb - 1
                lh.push(high[i]), ll.push(low[i]), lvv.push(volume[i])
            [poc, vah, val] = buildProfile(lh, ll, lvv, vpBins, vaPct)
            int lx1 = bar_index - lb + 1
            int lx2 = lvlExtend ? bar_index + gapBars : bar_index
            mkLine(lx1, poc, lx2, poc, pocCol, line.style_solid, 2)
            mkLabel(lx1 - 1, poc, "POC " + str.tostring(poc, format.mintick), pocCol, yloc.price, label.style_label_right)
            mkLine(lx1, vah, lx2, vah, vaCol, line.style_dashed, 1)
            mkLabel(lx1 - 1, vah, "VAH " + str.tostring(vah, format.mintick), vaCol, yloc.price, label.style_label_right)
            mkLine(lx1, val, lx2, val, vaCol, line.style_dashed, 1)
            mkLabel(lx1 - 1, val, "VAL " + str.tostring(val, format.mintick), vaCol, yloc.price, label.style_label_right)
    if showSwingLevels
        int sx2 = lvlExtend ? bar_index + gapBars : bar_index
        if not na(lastSwingH)
            mkLine(bar_index - 60, lastSwingH, sx2, lastSwingH, chartInk, line.style_dotted, 1)
            mkLabel(bar_index - 61, lastSwingH, "Swing H " + str.tostring(lastSwingH, format.mintick), txtDim, yloc.price, label.style_label_right)
        if not na(lastSwingL)
            mkLine(bar_index - 60, lastSwingL, sx2, lastSwingL, chartInk, line.style_dotted, 1)
            mkLabel(bar_index - 61, lastSwingL, "Swing L " + str.tostring(lastSwingL, format.mintick), txtDim, yloc.price, label.style_label_right)

    // ---- MTF CONFLUENCE ENGINE (headline: where multi-timeframe levels cluster) --
    float  nearZone = na
    int    nearCnt  = 0
    bool   nearSup  = true
    string nearName = ""
    if showConf
        array<float>  lp = array.new<float>()
        array<float>  lw = array.new<float>()
        array<string> ln = array.new<string>()
        [bp, bh, bl] = f_panelPVL(baseGrp)
        float bw = math.sqrt(math.max(baseGrp.tfSec, 1))
        f_addLvl(lp, lw, ln, bp, bw, "POC")
        f_addLvl(lp, lw, ln, bh, bw, "VAH")
        f_addLvl(lp, lw, ln, bl, bw, "VAL")
        for g in grps
            if g.on
                [gp, gh, gl] = f_panelPVL(g)
                float gw = math.sqrt(math.max(g.tfSec, 1))
                f_addLvl(lp, lw, ln, gp, gw, g.tfStr + "POC")
                f_addLvl(lp, lw, ln, gh, gw, g.tfStr + "VAH")
                f_addLvl(lp, lw, ln, gl, gw, g.tfStr + "VAL")
        // chart visible-range value area (intraday horizon) + recent swings — robust, near-price
        int _clb = math.min(lvlLookback, bar_index)
        if _clb > 5
            array<float> rh = array.new<float>()
            array<float> rl = array.new<float>()
            array<float> rv = array.new<float>()
            for i = 0 to _clb - 1
                rh.push(high[i])
                rl.push(low[i])
                rv.push(volume[i])
            [rpoc, rvah, rval] = buildProfile(rh, rl, rv, vpBins, vaPct)
            f_addLvl(lp, lw, ln, rpoc, math.sqrt(3600.0), "POC")
            f_addLvl(lp, lw, ln, rvah, math.sqrt(1800.0), "VAH")
            f_addLvl(lp, lw, ln, rval, math.sqrt(1800.0), "VAL")
        f_addLvl(lp, lw, ln, lastSwingH, math.sqrt(900.0), "SwH")
        f_addLvl(lp, lw, ln, lastSwingL, math.sqrt(900.0), "SwL")
        if usePDW
            float pdw = math.sqrt(86400.0)
            f_addLvl(lp, lw, ln, pdH, pdw, "pdH")
            f_addLvl(lp, lw, ln, pdL, pdw, "pdL")
            f_addLvl(lp, lw, ln, pdC, pdw, "pdC")
            float pww = math.sqrt(604800.0)
            f_addLvl(lp, lw, ln, pwH, pww, "pwH")
            f_addLvl(lp, lw, ln, pwL, pww, "pwL")
        if useVWAPc
            f_addLvl(lp, lw, ln, vwapV, math.sqrt(3600.0), "VWAP")
        int nL = array.size(lp)
        float atrNow = math.max(nz(atr14, syminfo.mintick), syminfo.mintick)
        float tol = confTolATR * atrNow
        int cx1 = bar_index - math.min(lvlLookback, bar_index) + 1
        int cx2 = bar_index + gapBars
        if nL > 0
            array<bool> used = array.new<bool>(nL, false)
            for i = 0 to nL - 1
                if not array.get(used, i)
                    float ci = array.get(lp, i)
                    float sP = 0.0
                    float sW = 0.0
                    int   cN = 0
                    string comp = ""
                    for j = 0 to nL - 1
                        if not array.get(used, j) and math.abs(array.get(lp, j) - ci) <= tol
                            sP += array.get(lp, j) * array.get(lw, j)
                            sW += array.get(lw, j)
                            cN += 1
                            comp := comp == "" ? array.get(ln, j) : comp + "+" + array.get(ln, j)
                            array.set(used, j, true)
                    if cN >= confMinN
                        float center = sW > 0 ? sP / sW : ci
                        bool sup = center <= close
                        int transp = math.max(45, 82 - (cN - 2) * 12)
                        color zc = color.new(sup ? color.rgb(46, 189, 133) : color.rgb(246, 70, 93), transp)
                        mkBox(cx1, center + tol / 2.0, cx2, center - tol / 2.0, zc)
                        if na(nearZone) or math.abs(center - close) < math.abs(nearZone - close)
                            nearZone := center
                            nearCnt  := cN
                            nearSup  := sup
                            nearName := comp

    // ---- COMPACT TABLE (default) — plain language, honest about edge --------
    if showTable and tableMode == "Compact"
        table.clear(tbl, 0, 0, 6, 12)
        int cN = bN_T + sN_T + bN_R + sN_R, int cH = bH_T + sH_T + bH_R + sH_R, int cRes = res_T + res_R
        int cBull = bN_T + bN_R, int cBear = sN_T + sN_R
        float cHitR = cN > 0 ? cH / float(cN) : na
        float cBuR = cRes > 0 ? (bu_T + bu_R) / float(cRes) : na, float cBdR = cRes > 0 ? (bd_T + bd_R) / float(cRes) : na
        float cMBase = (cN > 0 and not na(cBuR) and not na(cBdR)) ? (cBull * cBuR + cBear * cBdR) / float(cN) : na
        float cEdge = (na(cHitR) or na(cMBase)) ? na : cHitR - cMBase
        float cWlow = wilsonLow(cHitR, cN)
        bool cSig = not na(cWlow) and not na(cMBase) and cWlow > cMBase
        string biasW = netP > 0.60 ? "Bullish" : netP > 0.53 ? "Mildly Bullish" : netP >= 0.47 ? "Neutral" : netP >= 0.40 ? "Mildly Bearish" : "Bearish"
        string biasArrow = netP > 0.53 ? "  ▲" : netP < 0.47 ? "  ▼" : ""
        color biasWcol = color.from_gradient(netP, 0.35, 0.65, bearCol, bullCol)
        string edgeW = (cSig and not na(cEdge)) ? ("Confirmed +" + str.tostring(cEdge * 100, "#") + "%  ★") : (cN < 30 ? "Gathering data…" : "Not proven")
        color edgeWcol = cSig ? goodC : cautionC
        string useW = cSig ? "Tradeable — still verify" : "Context only — no proven edge"
        color useWcol = cSig ? goodC : cautionC
        float _atr = math.max(nz(atr14, syminfo.mintick), syminfo.mintick)
        bool  atLvl = not na(nearZone) and math.abs(close - nearZone) <= confTolATR * _atr * 1.5
        float lvlDelta = (nz(baseBuy) + nz(baseSell)) > 0 ? (nz(baseBuy) - nz(baseSell)) / (nz(baseBuy) + nz(baseSell)) : na
        string flowAtTxt = not atLvl ? "not at a zone" : na(lvlDelta) ? "-" : (lvlDelta > 0.15 ? "buyers pressing" : lvlDelta < -0.15 ? "sellers pressing" : "balanced") + (baseTox > 0.22 ? " · absorbing" : "")
        color  flowAtCol = not atLvl ? txtDim : lvlDelta > 0.15 ? bullInk : lvlDelta < -0.15 ? bearInk : neutralC
        string zoneTxt = na(nearZone) ? "none in range" : str.tostring(nearZone, format.mintick) + "  x" + str.tostring(nearCnt)
        color  zoneCol = na(nearZone) ? txtDim : nearSup ? goodC : bearInk
        string zoneType = na(nearZone) ? "-" : (nearSup ? "Support x" : "Resistance x") + str.tostring(nearCnt) + ": " + nearName
        table.cell(tbl, 0, 0, "MTF CONFLUENCE COCKPIT", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tbl, 1, 0, "", bgcolor = headBg)
        table.cell(tbl, 0, 1, "Nearest zone", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 1, 1, zoneTxt, text_color = zoneCol, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 0, 2, "Zone type", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 1, 2, zoneType, text_color = zoneCol, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 0, 3, "Flow here", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 1, 3, flowAtTxt, text_color = flowAtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 0, 4, "Day type", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 1, 4, dayType, text_color = txtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 0, 5, "Bias (context)", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 1, 5, biasW + biasArrow, text_color = biasWcol, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 0, 6, "Edge", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 1, 6, edgeW, text_color = edgeWcol, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 0, 7, "Use", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tbl, 1, 7, useW, text_color = useWcol, text_size = ts, bgcolor = panelBg)

    // ---- PRO TABLE ----------------------------------------------------------
    if showTable and tableMode == "Pro"
        table.clear(tbl, 0, 0, 6, 12)
        table.cell(tbl, 0, 0, "TF", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tbl, 1, 0, "Src", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tbl, 2, 0, "Vol", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tbl, 3, 0, "Δ%", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tbl, 4, 0, "Tox", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tbl, 5, 0, "Str", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tbl, 6, 0, "Bias", text_color = txtCol, text_size = ts, bgcolor = headBg)
        int r = 1
        if showBaseStrip
            proRow(tbl, r, baseGrp, ts)
            r += 1
        for grp in grps
            if grp.on
                proRow(tbl, r, grp, ts)
                r += 1
        if useVol and not na(volBias)
            color xbg = isDark ? color.new(#5b3fb5, 70) : color.new(#5b3fb5, 80)
            float vP = logitToP(fusionGain * volBias)
            table.cell(tbl, 0, r, "VOL", text_color = txtCol, text_size = ts, bgcolor = xbg)
            table.cell(tbl, 1, r, "X", text_color = txtDim, text_size = ts, bgcolor = xbg)
            table.cell(tbl, 2, r, na(volx) ? "–" : str.tostring(volx, "#.##"), text_color = txtDim, text_size = ts, bgcolor = xbg)
            table.cell(tbl, 3, r, na(volRoc) ? "–" : (volRoc >= 0 ? "+" : "") + str.tostring(volRoc * 100, "#.0") + "%", text_color = volRoc >= 0 ? bearCol : bullCol, text_size = ts, bgcolor = xbg)
            table.cell(tbl, 4, r, "", bgcolor = xbg)
            table.cell(tbl, 5, r, "", bgcolor = xbg)
            table.cell(tbl, 6, r, str.tostring(vP * 100, "#") + (vP > 0.5 ? "▲" : "▼"), text_color = color.from_gradient(vP, 0.0, 1.0, bearCol, bullCol), text_size = ts, bgcolor = xbg)
            r += 1
        if calTarget == "Reversion"
            color rbg = isDark ? color.new(#5f6d1a, 72) : color.new(#5f6d1a, 82)
            table.cell(tbl, 0, r, "REV", text_color = txtCol, text_size = ts, bgcolor = rbg)
            table.cell(tbl, 1, r, "◀cal", text_color = cautionC, text_size = ts, bgcolor = rbg)
            table.cell(tbl, 2, r, "", bgcolor = rbg)
            table.cell(tbl, 3, r, bearDiv ? "div-" : bullDiv ? "div+" : "–", text_color = bearDiv ? bearCol : bullDiv ? bullCol : txtDim, text_size = ts, bgcolor = rbg)
            table.cell(tbl, 4, r, "", bgcolor = rbg)
            table.cell(tbl, 5, r, "", bgcolor = rbg)
            table.cell(tbl, 6, r, revDir == 1 ? "↑fade" : revDir == -1 ? "↓fade" : "·", text_color = revDir == 1 ? bullCol : revDir == -1 ? bearCol : txtDim, text_size = ts, bgcolor = rbg)
            r += 1
        if netW > 0
            float conv = math.abs(netP - 0.5) * 2.0 * 100.0
            color nbg = isDark ? color.new(#1e4fd6, 78) : color.new(#1e4fd6, 84)
            color netCol = color.from_gradient(netP, 0.0, 1.0, bearCol, bullCol)
            table.cell(tbl, 0, r, "NET", text_color = txtCol, text_size = ts, bgcolor = nbg)
            table.cell(tbl, 1, r, calTarget == "Continuation" ? "◀cal" : "", text_color = cautionC, text_size = ts, bgcolor = nbg)
            table.cell(tbl, 2, r, "", bgcolor = nbg)
            table.cell(tbl, 3, r, netDir == 1 ? "BULL" : netDir == -1 ? "BEAR" : "FLAT", text_color = netCol, text_size = ts, bgcolor = nbg)
            table.cell(tbl, 4, r, str.tostring(conv, "#") + "%", text_color = txtDim, text_size = ts, bgcolor = nbg)
            table.cell(tbl, 5, r, "", bgcolor = nbg)
            table.cell(tbl, 6, r, str.tostring(netP * 100, "#") + (netP > 0.5 ? "▲" : netP < 0.5 ? "▼" : "·"), text_color = netCol, text_size = ts, bgcolor = nbg)
            r += 1
            if calibEnabled
                string ct = calTarget == "Reversion" ? "r" : "n"
                if regimeSplit
                    calRow(tbl, r, "CAL" + ct + "·T", bN_T, bH_T, sN_T, sH_T, res_T, bu_T, bd_T, ts)
                    r += 1
                    calRow(tbl, r, "CAL" + ct + "·R", bN_R, bH_R, sN_R, sH_R, res_R, bu_R, bd_R, ts)
                else
                    calRow(tbl, r, "CAL" + ct, bN_T + bN_R, bH_T + bH_R, sN_T + sN_R, sH_T + sH_R, res_T + res_R, bu_T + bu_R, bd_T + bd_R, ts)

    // ---- KEY INFO TABLE (off by default) — plain-language legend ------------
    if showKeyInfo
        table.clear(tkey, 0, 0, 1, 8)
        table.cell(tkey, 0, 0, "HOW TO READ", text_color = txtCol, text_size = ts, bgcolor = headBg)
        table.cell(tkey, 1, 0, "", bgcolor = headBg)
        table.cell(tkey, 0, 1, "Candles", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 1, "Each = one higher-TF bar, split buy/sell", text_color = txtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 0, 2, "REAL / EST", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 2, "Real footprint vs estimated delta", text_color = txtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 0, 3, "Bias", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 3, "Which way order flow leans", text_color = txtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 0, 4, "Flow", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 4, "Calm = balanced · One-sided = aggressive", text_color = txtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 0, 5, "Setup", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 5, "Exhaustion: price extreme vs weak flow", text_color = txtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 0, 6, "Edge", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 6, "Measured Hit% vs Base%. ★ = significant", text_color = txtCol, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 0, 7, "Use", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 7, "Context-only unless Edge is confirmed", text_color = cautionC, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 0, 8, "Note", text_color = txtDim, text_size = ts, bgcolor = panelBg)
        table.cell(tkey, 1, 8, "Awareness tool — not financial advice", text_color = txtDim, text_size = ts, bgcolor = panelBg)
````
