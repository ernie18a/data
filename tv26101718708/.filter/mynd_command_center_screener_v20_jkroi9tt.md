# MYND Command Center Screener v2.0

- url: https://www.tradingview.com/script/JKRoI9tT-MYND-Command-Center-Screener-v2-0/
- type: indicator
- pine_id: PUB;41a64efc5a814cacb6c38f847daf1ebd
- version: 1.0

## Description

MYND Command Center Screener [v2.0]

Scan up to 30 watchlist symbols and rank them by general setup quality, compression readiness, or both - now with the answer to "which of my tickers is coiled and about to move."

WHAT IT DOES

This screener scans your configured watchlist (up to 30 symbols) and ranks them live in a table by score. v1.0 had one score - a general Alpha Score blending trend efficiency, relative volume, and volatility-regime fit. v2.0 adds a second, independent Squeeze Score - how tight, deep, and recently-fired each symbol's own compression engine reads - plus a Composite Score blending both, and a Rank By dropdown so you choose which question the table answers.

HOW IT WORKS

Each symbol is pulled once per bar (1 request.security() call each, 30 total) and run through two scoring engines. The Alpha Score checks how efficiently price has been moving, whether volume confirms it, and whether volatility sits in a tradeable middle ground. The Squeeze Score runs the same TTM-Squeeze-Pro-style 3-tier compression test used in MYND Ultimate Squeeze Confluence & Exit Dashboard (Bollinger Band inside 3 nested Keltner Channel bands) and blends compression depth, tier, and recent-fire status into a 0-100 read. A new Confluence column checks whether the two engines' directional reads agree, and a Rank Δ column tracks how fast each symbol is climbing or falling in the ranking itself.

KEY FEATURES

Two independent 0-100 scores (Alpha, Squeeze) plus a configurable-weight Composite Score and a Rank By selector. A Confluence column and a compression Tier column. Rank Δ tracking showing rank momentum bar to bar. A Watchlist Override for a fast all-on/all-off bulk switch without losing your individual per-symbol settings. A table that automatically sizes itself to only the symbols currently in use - no blank rows. Score columns display as "NN.N / 100" and Tier as "T# (#/3)" so the scale is always visible. Light/Dark theme presets plus a Colorblind-Safe Okabe-Ito option. Full tooltips throughout.

HOW TO USE IT

Configure your watchlist (20 symbols enabled by default). Set Rank By to Composite for a blended "good setup AND coiled" ranking, or switch to Squeeze Score alone if you specifically want the tightest coils regardless of general trend quality. Watch for symbols with a high Squeeze Score, Tier 3, and Confluence = Yes - the strongest combined read this tool can give. A fast-climbing Rank Δ can flag a symbol worth attention before it reaches the top of the table. Use the Watchlist Override dropdown for a quick "scan everything" or "quiet the table" moment without touching your 30 individual checkboxes - switch back to "Use Individual Toggles" and your prior per-symbol setup returns exactly as you left it.

SETTINGS WORTH TUNING FIRST

Rank By and the two Composite Weight inputs - the core dial for what "best" means in your table. Squeeze Score Threshold for the Newly Squeeze-Ready alert - your sensitivity for the compression-specific alert.

ALERTS

4 alertcondition()s (Watchlist Strength Rising/Falling, Symbol Entered Top N, Symbol Newly Squeeze-Ready) plus a combo bundle, and 1 dynamic alert() for leadership changes (set up via TradingView's "Any alert() function call" condition, not the named dropdown).

This tool can only tell you what trend/volume/volatility/compression behavior has looked like recently across your watchlist - it is not a guarantee of future performance. This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("MYND Command Center Screener v2.0", shorttitle="MYND CCS v2.0", overlay=false)

// =====================================================================================

// v2.0 CHANGES FROM v1.0:
//
//  1. SQUEEZE SCORE (NEW) - reuses #80's verified TTM-Squeeze-Pro-style 3-tier compression
//     engine (Bollinger inside 3 nested Keltner bands; tightest tier now correctly defaults
//     to a 1.0 multiplier per the 2026-08-19 Standing Design Convention #8 fix, not the 1.5
//     the original #80 port carried before that correction), computed per symbol at the
//     same data timeframe the existing Alpha Score already uses. A new 0-100 Squeeze Score
//     blends compression depth, tier, and whether that symbol fired recently - this is
//     what actually answers "which of my tickers is tightest/most coiled right now,"
//     which the v1.0 Alpha Score (trend/volume/volatility-fit only) never captured.
//  2. COMPOSITE SCORE (NEW) - a configurable-weight blend of Alpha Score and Squeeze
//     Score, and a new "Rank By" dropdown (Alpha / Squeeze / Composite) so the table's
//     primary sort can reflect whichever question you're actually asking - "best general
//     setup," "tightest coil," or both blended - instead of one fixed ranking.
//  3. CONFLUENCE COLUMN (NEW) - Yes/No/N/A read on whether the existing EMA-trend
//     Direction agrees with the squeeze engine's own directional lean - a fast visual
//     filter for setups where both reads agree vs. ones where they don't.
//  4. RANK CHANGE TRACKING (NEW) - a new "Rank Δ" column tracks each symbol's rank move
//     since the prior bar (▲/▼/–), so rising momentum in the RANKING itself (not just
//     price) is visible at a glance - matched by symbol name across bars since sort order
//     changes every bar.
//  5. NEW ALERTS - "Any Symbol Entered Top N" (a symbol's rank crossed into your
//     configured top-N this bar) and "Any Symbol Newly Squeeze-Ready" (a symbol's Squeeze
//     Score crossed above your threshold this bar) - both genuine watchlist-wide
//     alertcondition()s, not per-symbol dynamic alerts, so they work in TradingView's
//     standard alert dropdown.
//  6. FULL MYND STANDARDS RETROFIT - Theme Preset (Light/Dark/Custom) and a new
//     Colorblind-Safe Okabe-Ito toggle (neither existed in v1.0), full tooltip coverage
//     on every non-cosmetic input (v1.0 had only 2), and an expanded combo-alert note.
//     Total Control's header-color and 5-tier text size were already present in v1.0 and
//     are preserved unchanged.
//
// POST-RELEASE UPDATE (2026-08-19, same day): 3 additions -
//  7. WATCHLIST OVERRIDE (NEW) - a 3-way "Watchlist Override" dropdown (Watchlist Controls
//     group) for a fast bulk on/off across all 30 symbols at once ("Use Individual
//     Toggles" / "Force ALL ON" / "Force ALL OFF"). Pine cannot programmatically set
//     another input's stored checkbox value, so this works by overriding each symbol's
//     EFFECTIVE enabled-state used in scoring/ranking/the table - the 30 individual
//     checkboxes underneath are never touched, so switching back to "Use Individual
//     Toggles" exactly restores whatever was set per-symbol beforehand.
//  8. DYNAMIC TABLE SIZING (NEW) - the table now renders only as many rows as there are
//     effectively-enabled symbols (1 header + N, via a runtime-sized table.new()) instead
//     of a fixed 31-row table with blank "(Off)" rows for disabled slots. Disabled/
//     override-forced-off symbols are excluded upstream (before ranking) and never occupy
//     a row at all. The now-pointless "Disabled Slot Color" input from v1.0/early v2.0 was
//     removed as part of this change, since a disabled row is never drawn anymore.
//  9. SCORE-VS-SCALE DISPLAY (NEW) - Alpha, Squeeze, and Composite columns now show
//     "NN.N / 100" instead of a bare number, and Tier shows "TN (N/3)" - so the scale is
//     always visible in the table itself, not just in the docs.


// =====================================================================================
// ---------------------------- INPUTS: WATCHLIST CONTROLS (NEW) ----------------------------
// Pine cannot programmatically check/uncheck another input's box in the settings panel, so
// a literal "master checkbox that ticks the other 30" isn't possible. This achieves the
// same practical result a different way: a 3-way override that controls the EFFECTIVE
// enabled-state used everywhere below, without ever touching the 30 individual checkboxes
// underneath - switch back to "Use Individual Toggles" at any time and every symbol's own
// checkbox is exactly as you left it, ready to fine-tune one at a time.
watchlistOverride = input.string("Use Individual Toggles", "Watchlist Override (quick on/off)", options=["Use Individual Toggles", "Force ALL ON", "Force ALL OFF"], group="Watchlist Controls", tooltip="Quick bulk adjustment. 'Force ALL ON'/'Force ALL OFF' treat every symbol as enabled/disabled regardless of its individual checkbox below - the checkboxes themselves are untouched, so switching back to 'Use Individual Toggles' restores exactly whatever you'd set per-symbol before.")
// ---------------------------- INPUTS: WATCHLIST 1-10 ---------------------------- (unchanged from v1.0)
sym1Enable = input.bool(true, "Enable Symbol 1", group="Watchlist 1-10", inline="w1")
sym1Sym = input.symbol("SPY", "Symbol 1", group="Watchlist 1-10", inline="w1")
sym2Enable = input.bool(true, "Enable Symbol 2", group="Watchlist 1-10", inline="w2")
sym2Sym = input.symbol("QQQ", "Symbol 2", group="Watchlist 1-10", inline="w2")
sym3Enable = input.bool(true, "Enable Symbol 3", group="Watchlist 1-10", inline="w3")
sym3Sym = input.symbol("IWM", "Symbol 3", group="Watchlist 1-10", inline="w3")
sym4Enable = input.bool(true, "Enable Symbol 4", group="Watchlist 1-10", inline="w4")
sym4Sym = input.symbol("DIA", "Symbol 4", group="Watchlist 1-10", inline="w4")
sym5Enable = input.bool(true, "Enable Symbol 5", group="Watchlist 1-10", inline="w5")
sym5Sym = input.symbol("AAPL", "Symbol 5", group="Watchlist 1-10", inline="w5")
sym6Enable = input.bool(true, "Enable Symbol 6", group="Watchlist 1-10", inline="w6")
sym6Sym = input.symbol("MSFT", "Symbol 6", group="Watchlist 1-10", inline="w6")
sym7Enable = input.bool(true, "Enable Symbol 7", group="Watchlist 1-10", inline="w7")
sym7Sym = input.symbol("NVDA", "Symbol 7", group="Watchlist 1-10", inline="w7")
sym8Enable = input.bool(true, "Enable Symbol 8", group="Watchlist 1-10", inline="w8")
sym8Sym = input.symbol("AMZN", "Symbol 8", group="Watchlist 1-10", inline="w8")
sym9Enable = input.bool(true, "Enable Symbol 9", group="Watchlist 1-10", inline="w9")
sym9Sym = input.symbol("GOOGL", "Symbol 9", group="Watchlist 1-10", inline="w9")
sym10Enable = input.bool(true, "Enable Symbol 10", group="Watchlist 1-10", inline="w10")
sym10Sym = input.symbol("META", "Symbol 10", group="Watchlist 1-10", inline="w10")
// ---------------------------- INPUTS: WATCHLIST 11-20 ----------------------------
sym11Enable = input.bool(true, "Enable Symbol 11", group="Watchlist 11-20", inline="w11")
sym11Sym = input.symbol("TSLA", "Symbol 11", group="Watchlist 11-20", inline="w11")
sym12Enable = input.bool(true, "Enable Symbol 12", group="Watchlist 11-20", inline="w12")
sym12Sym = input.symbol("AMD", "Symbol 12", group="Watchlist 11-20", inline="w12")
sym13Enable = input.bool(true, "Enable Symbol 13", group="Watchlist 11-20", inline="w13")
sym13Sym = input.symbol("XLF", "Symbol 13", group="Watchlist 11-20", inline="w13")
sym14Enable = input.bool(true, "Enable Symbol 14", group="Watchlist 11-20", inline="w14")
sym14Sym = input.symbol("XLE", "Symbol 14", group="Watchlist 11-20", inline="w14")
sym15Enable = input.bool(true, "Enable Symbol 15", group="Watchlist 11-20", inline="w15")
sym15Sym = input.symbol("XLK", "Symbol 15", group="Watchlist 11-20", inline="w15")
sym16Enable = input.bool(false, "Enable Symbol 16", group="Watchlist 11-20", inline="w16")
sym16Sym = input.symbol("JPM", "Symbol 16", group="Watchlist 11-20", inline="w16")
sym17Enable = input.bool(false, "Enable Symbol 17", group="Watchlist 11-20", inline="w17")
sym17Sym = input.symbol("BAC", "Symbol 17", group="Watchlist 11-20", inline="w17")
sym18Enable = input.bool(false, "Enable Symbol 18", group="Watchlist 11-20", inline="w18")
sym18Sym = input.symbol("XOM", "Symbol 18", group="Watchlist 11-20", inline="w18")
sym19Enable = input.bool(false, "Enable Symbol 19", group="Watchlist 11-20", inline="w19")
sym19Sym = input.symbol("CVX", "Symbol 19", group="Watchlist 11-20", inline="w19")
sym20Enable = input.bool(false, "Enable Symbol 20", group="Watchlist 11-20", inline="w20")
sym20Sym = input.symbol("UNH", "Symbol 20", group="Watchlist 11-20", inline="w20")
// ---------------------------- INPUTS: WATCHLIST 21-30 ----------------------------
sym21Enable = input.bool(false, "Enable Symbol 21", group="Watchlist 21-30", inline="w21")
sym21Sym = input.symbol("JNJ", "Symbol 21", group="Watchlist 21-30", inline="w21")
sym22Enable = input.bool(false, "Enable Symbol 22", group="Watchlist 21-30", inline="w22")
sym22Sym = input.symbol("V", "Symbol 22", group="Watchlist 21-30", inline="w22")
sym23Enable = input.bool(false, "Enable Symbol 23", group="Watchlist 21-30", inline="w23")
sym23Sym = input.symbol("MA", "Symbol 23", group="Watchlist 21-30", inline="w23")
sym24Enable = input.bool(false, "Enable Symbol 24", group="Watchlist 21-30", inline="w24")
sym24Sym = input.symbol("HD", "Symbol 24", group="Watchlist 21-30", inline="w24")
sym25Enable = input.bool(false, "Enable Symbol 25", group="Watchlist 21-30", inline="w25")
sym25Sym = input.symbol("WMT", "Symbol 25", group="Watchlist 21-30", inline="w25")
sym26Enable = input.bool(false, "Enable Symbol 26", group="Watchlist 21-30", inline="w26")
sym26Sym = input.symbol("DIS", "Symbol 26", group="Watchlist 21-30", inline="w26")
sym27Enable = input.bool(false, "Enable Symbol 27", group="Watchlist 21-30", inline="w27")
sym27Sym = input.symbol("NFLX", "Symbol 27", group="Watchlist 21-30", inline="w27")
sym28Enable = input.bool(false, "Enable Symbol 28", group="Watchlist 21-30", inline="w28")
sym28Sym = input.symbol("CRM", "Symbol 28", group="Watchlist 21-30", inline="w28")
sym29Enable = input.bool(false, "Enable Symbol 29", group="Watchlist 21-30", inline="w29")
sym29Sym = input.symbol("ADBE", "Symbol 29", group="Watchlist 21-30", inline="w29")
sym30Enable = input.bool(false, "Enable Symbol 30", group="Watchlist 21-30", inline="w30")
sym30Sym = input.symbol("COST", "Symbol 30", group="Watchlist 21-30", inline="w30")
// ---------------------------- INPUTS: DATA SETTINGS ----------------------------
dataTF = input.timeframe("", "Data Timeframe (blank = chart timeframe)", group="Data Settings", tooltip="All 30 symbols, both the Alpha Score and the new Squeeze Score, are read at this single timeframe. Blank = use whatever timeframe the chart itself is on.")
// ---------------------------- INPUTS: ALPHA SCORE SETTINGS (unchanged from v1.0) ----------------------------
fastLen = input.int(20, "Trend Fast EMA Length", minval=1, group="Alpha Score Settings", tooltip="Fast/Slow EMA stack determines the Direction label (Bullish/Bearish/Mixed).")
slowLen = input.int(50, "Trend Slow EMA Length", minval=1, group="Alpha Score Settings")
erLen = input.int(14, "Efficiency Ratio Length", minval=2, group="Alpha Score Settings", tooltip="How clean/directional the recent price path has been - net move divided by total path traveled.")
volLen = input.int(20, "Relative Volume Average Length", minval=1, group="Alpha Score Settings", tooltip="Rolling average volume length current volume is compared against.")
atrLen = input.int(14, "ATR Length", minval=1, group="Alpha Score Settings")
atrPctLen = input.int(252, "ATR Percentile Lookback", minval=10, group="Alpha Score Settings", tooltip="Scores highest when ATR sits near the middle of its own recent range - too quiet or too wild both score lower.")
effWeight = input.float(40, "Efficiency Weight", minval=0, group="Alpha Score Settings", tooltip="Sub-factor weights for the 0-100 Alpha Score (trend/volume/volatility-fit quality, unrelated to compression).")
volWeight = input.float(30, "Relative Volume Weight", minval=0, group="Alpha Score Settings")
atrFitWeight = input.float(30, "Volatility Fit Weight", minval=0, group="Alpha Score Settings")
// ---------------------------- INPUTS: SQUEEZE SCORE SETTINGS (NEW in v2.0) ----------------------------
sqzLen        = input.int(13, "BB / KC / Momentum Length", minval=1, group="Squeeze Score Settings", tooltip="Shared length for the Bollinger Band, all 3 Keltner Channel tiers, and the directional-lean linreg - same TTM-Squeeze-Pro-style engine as #80.")
sqzBbMult     = input.float(1.8, "Bollinger Band Multiplier", minval=0.1, step=0.1, group="Squeeze Score Settings")
sqzKcHighMult = input.float(1.0, "Keltner Multiplier - High (tightest tier)", minval=0.1, step=0.1, group="Squeeze Score Settings", tooltip="Tightest Keltner band - BB inside this = Tier 3 (deepest compression). Verified TTM Squeeze Pro standard (2 independent sources, 2026-08-19) - see MYND_Project_Notes.md Standing Design Convention #8.")
sqzKcMidMult  = input.float(1.5, "Keltner Multiplier - Mid tier", minval=0.1, step=0.1, group="Squeeze Score Settings")
sqzKcLowMult  = input.float(2.0, "Keltner Multiplier - Low (loosest, = squeeze on/off)", minval=0.1, step=0.1, group="Squeeze Score Settings")
sqzFireWindowBars = input.int(3, "Recent-Fire Window (bars)", minval=1, group="Squeeze Score Settings", tooltip="A symbol that fired within this many bars still gets Squeeze Score credit for a confirmed fire, not just raw compression.")
wSqzComp = input.float(1.0, "Squeeze Weight: Compression Depth", minval=0, group="Squeeze Score Settings", tooltip="Sub-factor weights for the new 0-100 Squeeze Score (how coiled/recently-fired each symbol is, independent of the Alpha Score).")
wSqzTier = input.float(1.0, "Squeeze Weight: Tier", minval=0, group="Squeeze Score Settings")
wSqzFire = input.float(1.0, "Squeeze Weight: Recent Fire", minval=0, group="Squeeze Score Settings")
// ---------------------------- INPUTS: RANKING (NEW in v2.0) ----------------------------
rankByMode = input.string("Composite Score", "Rank By", options=["Alpha Score", "Squeeze Score", "Composite Score"], group="Ranking", tooltip="Which score sorts the table. Alpha = best general trend/volume/volatility setup. Squeeze = tightest/most-recently-fired coil, regardless of trend quality. Composite = the blended score below.")
alphaWeightInComposite = input.float(1.0, "Composite Weight: Alpha Score", minval=0, group="Ranking", tooltip="How much the Alpha Score counts toward the Composite Score, relative to the Squeeze Score weight below.")
squeezeWeightInComposite = input.float(1.0, "Composite Weight: Squeeze Score", minval=0, group="Ranking")
showRankChange = input.bool(true, "Show Rank Δ Column", group="Ranking", tooltip="Tracks each symbol's rank move since the prior bar (matched by symbol name, since sort order changes every bar) - rising fast in rank is itself a momentum signal.")
// ---------------------------- INPUTS: ALERT THRESHOLDS ----------------------------
avgScoreHighThreshold = input.float(60, "Watchlist Avg Alpha Score 'High' Threshold", group="Alert Thresholds")
avgScoreLowThreshold = input.float(30, "Watchlist Avg Alpha Score 'Low' Threshold", group="Alert Thresholds")
topNForAlert = input.int(3, "Top-N for 'Symbol Entered Top N' Alert", minval=1, group="Alert Thresholds", tooltip="Fires when any enabled symbol's rank (by your Rank By setting) crosses into this top-N zone this bar.")
squeezeReadyAlertThreshold = input.float(70, "Squeeze Score Threshold for 'Newly Squeeze-Ready' Alert", minval=0, maxval=100, group="Alert Thresholds", tooltip="Fires when any enabled symbol's own Squeeze Score crosses above this level this bar.")
// ---------------------------- INPUTS: DISPLAY ----------------------------
showTable = input.bool(true, "Show Screener Table", group="Display")
tablePosIn = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Display")
tableSizeIn = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display")
scoreHighThreshold = input.float(70, "Score 'High' Threshold (row tint)", group="Display")
scoreMedThreshold = input.float(40, "Score 'Medium' Threshold (row tint)", group="Display")
// ---------------------------- INPUTS: COLORS & THEME (NEW Theme Preset + Colorblind in v2.0) ----------------------------
colorTheme = input.string("Light", "Theme Preset", options=["Light", "Dark", "Custom"], group="Colors & Theme", tooltip="Light/Dark apply a curated palette matched to that chart background. Custom uses the individual color pickers below instead.")
colorblindMode = input.bool(false, "Colorblind-Safe Bull/Bear/Score Colors (Okabe-Ito)", group="Colors & Theme", tooltip="When on, collapses Bullish/Bearish/high-score/low-score colors to the colorblind-safe Okabe-Ito palette - overrides Theme Preset or Custom colors. Direction/quality is still distinguished by text (Bullish/Bearish, the score number itself), not color alone.")
headerBgColorCustom = input.color(color.new(color.navy, 0), "Custom Theme: Table Header Background", group="Colors & Theme (Custom theme only)")
headerTextColorCustom = input.color(color.new(color.white, 0), "Custom Theme: Table Header Text", group="Colors & Theme (Custom theme only)")
colScoreHighCustom = input.color(color.new(color.green, 0), "Custom Theme: Score High Color", group="Colors & Theme (Custom theme only)")
colScoreMedCustom = input.color(color.new(color.yellow, 0), "Custom Theme: Score Medium Color", group="Colors & Theme (Custom theme only)")
colScoreLowCustom = input.color(color.new(color.gray, 0), "Custom Theme: Score Low Color", group="Colors & Theme (Custom theme only)")
colBullishCustom = input.color(color.new(color.green, 0), "Custom Theme: Bullish Direction Color", group="Colors & Theme (Custom theme only)")
colBearishCustom = input.color(color.new(color.red, 0), "Custom Theme: Bearish Direction Color", group="Colors & Theme (Custom theme only)")
colMixedCustom = input.color(color.new(color.gray, 0), "Custom Theme: Mixed Direction Color", group="Colors & Theme (Custom theme only)")
// NOTE: the v1.0 "Disabled Slot Color" input was removed in this revision - disabled/
// override-forced-off symbols no longer render a row at all (see dynamic table sizing
// below), so a row color for them would never be visible and was dead weight.
// =====================================================================================
// THEME RESOLUTION (NEW in v2.0) - Light/Dark/Custom base palette, then Colorblind-Safe
// Okabe-Ito override on top - same layered pattern as MYND Ignition/Exhaustion Curvature
// v2.0 and #80.
// =====================================================================================
f_themeColor(theme, lightVal, darkVal, customVal) =>
    theme == "Light" ? lightVal : theme == "Dark" ? darkVal : customVal
headerBgColor = f_themeColor(colorTheme, color.new(color.navy, 0), color.new(#1A1F2E, 0), headerBgColorCustom)
headerTextColor = f_themeColor(colorTheme, color.new(color.white, 0), color.new(#E0E0E0, 0), headerTextColorCustom)
cbHigh = color.new(#0072B2, 0)
cbLow  = color.new(#E69F00, 0)
colScoreHigh = colorblindMode ? cbHigh : f_themeColor(colorTheme, colScoreHighCustom, colScoreHighCustom, colScoreHighCustom)
colScoreMed  = f_themeColor(colorTheme, colScoreMedCustom, colScoreMedCustom, colScoreMedCustom)
colScoreLow  = colorblindMode ? cbLow : f_themeColor(colorTheme, colScoreLowCustom, colScoreLowCustom, colScoreLowCustom)
colBullish = colorblindMode ? cbHigh : colBullishCustom
colBearish = colorblindMode ? cbLow : colBearishCustom
colMixed   = colMixedCustom
tableSizeConst = tableSizeIn == "Tiny" ? size.tiny : tableSizeIn == "Small" ? size.small : tableSizeIn == "Large" ? size.large : tableSizeIn == "Huge" ? size.huge : size.normal
tablePosConst = tablePosIn == "Top Left" ? position.top_left : tablePosIn == "Top Right" ? position.top_right : tablePosIn == "Bottom Left" ? position.bottom_left : position.bottom_right
// =====================================================================================
// STATELESS/PER-SYMBOL HELPER FUNCTIONS
// =====================================================================================
// f_screenBundle - Alpha Score inputs (unchanged math from v1.0) PLUS the new Squeeze
// Score inputs (reused from #80, verified-corrected 1.0/1.5/2.0 tier multipliers), all in
// ONE function so each symbol still needs only 1 request.security() call. No [1] offset
// applied - this uses request.security()'s default lookahead=barmerge.lookahead_off
// (unchanged from v1.0), which is already repaint-safe on its own; the [1]-offset trick is
// only needed when lookahead_on is explicitly used for speed (as #80's per-timeframe
// fetches do), which this screener does not do.
f_screenBundle(_fastLen, _slowLen, _erLen, _volLen, _atrLen, _atrPctLen, _sqzLen, _bbMult, _kcHighMult, _kcMidMult, _kcLowMult) =>
    emaFast = ta.ema(close, _fastLen)
    emaSlow = ta.ema(close, _slowLen)
    trendState = close > emaFast and emaFast > emaSlow ? 1 : close < emaFast and emaFast < emaSlow ? -1 : 0
    netMove = math.abs(close - close[_erLen])
    pathSum = math.sum(math.abs(ta.change(close)), _erLen)
    effRatio = pathSum > 0 ? netMove / pathSum : 0.0
    avgVol = ta.sma(volume, _volLen)
    relVol = avgVol > 0 ? volume / avgVol : 1.0
    atrVal = ta.atr(_atrLen)
    atrPct = ta.percentrank(atrVal, _atrPctLen)
    // ---- Squeeze fields (NEW, reused from #80's verified-correct 3-tier engine) ----
    bbBasis = ta.sma(close, _sqzLen)
    bbDev = _bbMult * ta.stdev(close, _sqzLen)
    bbUpper = bbBasis + bbDev
    bbLower = bbBasis - bbDev
    kcRangeMa = ta.sma(ta.tr, _sqzLen)
    kcHighUpper = bbBasis + _kcHighMult * kcRangeMa
    kcHighLower = bbBasis - _kcHighMult * kcRangeMa
    kcMidUpper = bbBasis + _kcMidMult * kcRangeMa
    kcMidLower = bbBasis - _kcMidMult * kcRangeMa
    kcLowUpper = bbBasis + _kcLowMult * kcRangeMa
    kcLowLower = bbBasis - _kcLowMult * kcRangeMa
    sqzOnHigh = bbLower > kcHighLower and bbUpper < kcHighUpper
    sqzOnMid = bbLower > kcMidLower and bbUpper < kcMidUpper
    sqzOnLow = bbLower > kcLowLower and bbUpper < kcLowUpper
    sqzOn = sqzOnLow
    sqzTier = sqzOnHigh ? 3 : sqzOnMid ? 2 : sqzOnLow ? 1 : 0
    bbWidth = bbUpper - bbLower
    kcLowWidth = kcLowUpper - kcLowLower
    compressionRaw = kcLowWidth == 0.0 ? 0.0 : 1.0 - (bbWidth / kcLowWidth)
    compressionScore = math.max(0.0, math.min(1.0, compressionRaw))
    hh = ta.highest(high, _sqzLen)
    ll = ta.lowest(low, _sqzLen)
    avgHL = (hh + ll) / 2.0
    avgHLC = (avgHL + ta.sma(close, _sqzLen)) / 2.0
    mom = ta.linreg(close - avgHLC, _sqzLen, 0)
    sqzLeanDir = mom > 0.0 ? 1 : mom < 0.0 ? -1 : 0
    var int barsSinceFiredS = -1
    firedNowS = sqzOn[1] and not sqzOn
    var int lastFiredDirS = 0
    lastFiredDirS := firedNowS ? sqzLeanDir : lastFiredDirS
    barsSinceFiredS := firedNowS ? 0 : (barsSinceFiredS < 0 ? -1 : barsSinceFiredS + 1)
    [trendState, effRatio, relVol, atrPct, close, sqzOn, compressionScore, sqzTier, sqzLeanDir, firedNowS, lastFiredDirS, barsSinceFiredS]

f_alphaScore(_effRatio, _relVol, _atrPct, _effW, _volW, _atrW) =>
    effScore = _effRatio * 100
    volScore = math.max(0.0, math.min(100.0, (_relVol - 1) * 100))
    atrFitScore = 100 - 2 * math.abs(_atrPct - 50)
    wSum = _effW + _volW + _atrW
    score = wSum > 0 ? (_effW * effScore + _volW * volScore + _atrW * atrFitScore) / wSum : 0.0
    score

// f_squeezeScore (NEW) - mirrors #80's Squeeze Ready Score architecture, single-symbol/
// single-timeframe version for the screener context.
f_squeezeScore(_sqzOn, _compressionScore, _sqzTier, _lastFiredDirS, _barsSinceFiredS, _fireWindowBars, _wComp, _wTier, _wFire) =>
    compTerm = _sqzOn ? _compressionScore : 0.0
    tierTerm = _sqzTier / 3.0
    fireTerm = (_lastFiredDirS != 0 and _barsSinceFiredS >= 0 and _barsSinceFiredS <= _fireWindowBars) ? 1.0 : 0.0
    wSum = _wComp + _wTier + _wFire
    score = wSum > 0 ? (_wComp * compTerm + _wTier * tierTerm + _wFire * fireTerm) / wSum * 100.0 : 0.0
    score

f_direction(_trendState) =>
    _trendState == 1 ? "Bullish" : _trendState == -1 ? "Bearish" : "Mixed"

// f_confluence (NEW) - does the general trend Direction agree with the squeeze engine's
// own directional lean.
f_confluence(_trendState, _sqzLeanDir) =>
    _trendState == 0 or _sqzLeanDir == 0 ? "N/A" : _trendState == _sqzLeanDir ? "Yes" : "No"
// =====================================================================================
// PER-SYMBOL DATA PULLS + SCORING (30 explicit call sites - request.security requires
// a distinct call per symbol; f_screenBundle is stateless-per-call-site so this is safe,
// same pattern as v1.0, just with the Squeeze fields added to the same tuple/call.)
// =====================================================================================
symNames = array.new_string(0)
prices = array.new_float(0)
alphaScores = array.new_float(0)
squeezeScores = array.new_float(0)
compositeScores = array.new_float(0)
directions = array.new_string(0)
confluences = array.new_string(0)
tiersArr = array.new_int(0)
sinceFiredArr = array.new_int(0)
// effArr (bug fix, 2026-08-19) - tracks each slot's STATIC effective-enabled flag (from
// its checkbox + Watchlist Override), independent of whether that symbol's score has
// finished warming up yet. This is what enabledIdxArr filters on below - see the RANKING
// section comment for why this specific distinction is the fix for RE10040.
effArr = array.new_bool(0)

[t1, e1, v1, a1, c1, sq1, cp1, ti1, ln1, fr1, fd1, sf1] = request.security(sym1Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff1 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym1Enable
alphaScore1 = eff1 ? f_alphaScore(e1, v1, a1, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore1 = eff1 ? f_squeezeScore(sq1, cp1, ti1, fd1, sf1, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum1 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore1 = eff1 and compWSum1 > 0 ? (alphaWeightInComposite * alphaScore1 + squeezeWeightInComposite * squeezeScore1) / compWSum1 : -999999.0
array.push(symNames, sym1Sym)
array.push(prices, c1)
array.push(alphaScores, alphaScore1)
array.push(squeezeScores, squeezeScore1)
array.push(compositeScores, compositeScore1)
array.push(directions, f_direction(t1))
array.push(confluences, f_confluence(t1, ln1))
array.push(tiersArr, ti1)
array.push(sinceFiredArr, sf1)
array.push(effArr, eff1)

[t2, e2, v2, a2, c2, sq2, cp2, ti2, ln2, fr2, fd2, sf2] = request.security(sym2Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff2 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym2Enable
alphaScore2 = eff2 ? f_alphaScore(e2, v2, a2, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore2 = eff2 ? f_squeezeScore(sq2, cp2, ti2, fd2, sf2, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum2 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore2 = eff2 and compWSum2 > 0 ? (alphaWeightInComposite * alphaScore2 + squeezeWeightInComposite * squeezeScore2) / compWSum2 : -999999.0
array.push(symNames, sym2Sym)
array.push(prices, c2)
array.push(alphaScores, alphaScore2)
array.push(squeezeScores, squeezeScore2)
array.push(compositeScores, compositeScore2)
array.push(directions, f_direction(t2))
array.push(confluences, f_confluence(t2, ln2))
array.push(tiersArr, ti2)
array.push(sinceFiredArr, sf2)
array.push(effArr, eff2)

[t3, e3, v3, a3, c3, sq3, cp3, ti3, ln3, fr3, fd3, sf3] = request.security(sym3Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff3 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym3Enable
alphaScore3 = eff3 ? f_alphaScore(e3, v3, a3, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore3 = eff3 ? f_squeezeScore(sq3, cp3, ti3, fd3, sf3, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum3 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore3 = eff3 and compWSum3 > 0 ? (alphaWeightInComposite * alphaScore3 + squeezeWeightInComposite * squeezeScore3) / compWSum3 : -999999.0
array.push(symNames, sym3Sym)
array.push(prices, c3)
array.push(alphaScores, alphaScore3)
array.push(squeezeScores, squeezeScore3)
array.push(compositeScores, compositeScore3)
array.push(directions, f_direction(t3))
array.push(confluences, f_confluence(t3, ln3))
array.push(tiersArr, ti3)
array.push(sinceFiredArr, sf3)
array.push(effArr, eff3)

[t4, e4, v4, a4, c4, sq4, cp4, ti4, ln4, fr4, fd4, sf4] = request.security(sym4Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff4 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym4Enable
alphaScore4 = eff4 ? f_alphaScore(e4, v4, a4, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore4 = eff4 ? f_squeezeScore(sq4, cp4, ti4, fd4, sf4, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum4 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore4 = eff4 and compWSum4 > 0 ? (alphaWeightInComposite * alphaScore4 + squeezeWeightInComposite * squeezeScore4) / compWSum4 : -999999.0
array.push(symNames, sym4Sym)
array.push(prices, c4)
array.push(alphaScores, alphaScore4)
array.push(squeezeScores, squeezeScore4)
array.push(compositeScores, compositeScore4)
array.push(directions, f_direction(t4))
array.push(confluences, f_confluence(t4, ln4))
array.push(tiersArr, ti4)
array.push(sinceFiredArr, sf4)
array.push(effArr, eff4)

[t5, e5, v5, a5, c5, sq5, cp5, ti5, ln5, fr5, fd5, sf5] = request.security(sym5Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff5 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym5Enable
alphaScore5 = eff5 ? f_alphaScore(e5, v5, a5, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore5 = eff5 ? f_squeezeScore(sq5, cp5, ti5, fd5, sf5, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum5 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore5 = eff5 and compWSum5 > 0 ? (alphaWeightInComposite * alphaScore5 + squeezeWeightInComposite * squeezeScore5) / compWSum5 : -999999.0
array.push(symNames, sym5Sym)
array.push(prices, c5)
array.push(alphaScores, alphaScore5)
array.push(squeezeScores, squeezeScore5)
array.push(compositeScores, compositeScore5)
array.push(directions, f_direction(t5))
array.push(confluences, f_confluence(t5, ln5))
array.push(tiersArr, ti5)
array.push(sinceFiredArr, sf5)
array.push(effArr, eff5)

[t6, e6, v6, a6, c6, sq6, cp6, ti6, ln6, fr6, fd6, sf6] = request.security(sym6Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff6 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym6Enable
alphaScore6 = eff6 ? f_alphaScore(e6, v6, a6, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore6 = eff6 ? f_squeezeScore(sq6, cp6, ti6, fd6, sf6, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum6 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore6 = eff6 and compWSum6 > 0 ? (alphaWeightInComposite * alphaScore6 + squeezeWeightInComposite * squeezeScore6) / compWSum6 : -999999.0
array.push(symNames, sym6Sym)
array.push(prices, c6)
array.push(alphaScores, alphaScore6)
array.push(squeezeScores, squeezeScore6)
array.push(compositeScores, compositeScore6)
array.push(directions, f_direction(t6))
array.push(confluences, f_confluence(t6, ln6))
array.push(tiersArr, ti6)
array.push(sinceFiredArr, sf6)
array.push(effArr, eff6)

[t7, e7, v7, a7, c7, sq7, cp7, ti7, ln7, fr7, fd7, sf7] = request.security(sym7Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff7 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym7Enable
alphaScore7 = eff7 ? f_alphaScore(e7, v7, a7, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore7 = eff7 ? f_squeezeScore(sq7, cp7, ti7, fd7, sf7, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum7 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore7 = eff7 and compWSum7 > 0 ? (alphaWeightInComposite * alphaScore7 + squeezeWeightInComposite * squeezeScore7) / compWSum7 : -999999.0
array.push(symNames, sym7Sym)
array.push(prices, c7)
array.push(alphaScores, alphaScore7)
array.push(squeezeScores, squeezeScore7)
array.push(compositeScores, compositeScore7)
array.push(directions, f_direction(t7))
array.push(confluences, f_confluence(t7, ln7))
array.push(tiersArr, ti7)
array.push(sinceFiredArr, sf7)
array.push(effArr, eff7)

[t8, e8, v8, a8, c8, sq8, cp8, ti8, ln8, fr8, fd8, sf8] = request.security(sym8Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff8 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym8Enable
alphaScore8 = eff8 ? f_alphaScore(e8, v8, a8, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore8 = eff8 ? f_squeezeScore(sq8, cp8, ti8, fd8, sf8, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum8 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore8 = eff8 and compWSum8 > 0 ? (alphaWeightInComposite * alphaScore8 + squeezeWeightInComposite * squeezeScore8) / compWSum8 : -999999.0
array.push(symNames, sym8Sym)
array.push(prices, c8)
array.push(alphaScores, alphaScore8)
array.push(squeezeScores, squeezeScore8)
array.push(compositeScores, compositeScore8)
array.push(directions, f_direction(t8))
array.push(confluences, f_confluence(t8, ln8))
array.push(tiersArr, ti8)
array.push(sinceFiredArr, sf8)
array.push(effArr, eff8)

[t9, e9, v9, a9, c9, sq9, cp9, ti9, ln9, fr9, fd9, sf9] = request.security(sym9Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff9 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym9Enable
alphaScore9 = eff9 ? f_alphaScore(e9, v9, a9, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore9 = eff9 ? f_squeezeScore(sq9, cp9, ti9, fd9, sf9, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum9 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore9 = eff9 and compWSum9 > 0 ? (alphaWeightInComposite * alphaScore9 + squeezeWeightInComposite * squeezeScore9) / compWSum9 : -999999.0
array.push(symNames, sym9Sym)
array.push(prices, c9)
array.push(alphaScores, alphaScore9)
array.push(squeezeScores, squeezeScore9)
array.push(compositeScores, compositeScore9)
array.push(directions, f_direction(t9))
array.push(confluences, f_confluence(t9, ln9))
array.push(tiersArr, ti9)
array.push(sinceFiredArr, sf9)
array.push(effArr, eff9)

[t10, e10, v10, a10, c10, sq10, cp10, ti10, ln10, fr10, fd10, sf10] = request.security(sym10Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff10 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym10Enable
alphaScore10 = eff10 ? f_alphaScore(e10, v10, a10, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore10 = eff10 ? f_squeezeScore(sq10, cp10, ti10, fd10, sf10, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum10 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore10 = eff10 and compWSum10 > 0 ? (alphaWeightInComposite * alphaScore10 + squeezeWeightInComposite * squeezeScore10) / compWSum10 : -999999.0
array.push(symNames, sym10Sym)
array.push(prices, c10)
array.push(alphaScores, alphaScore10)
array.push(squeezeScores, squeezeScore10)
array.push(compositeScores, compositeScore10)
array.push(directions, f_direction(t10))
array.push(confluences, f_confluence(t10, ln10))
array.push(tiersArr, ti10)
array.push(sinceFiredArr, sf10)
array.push(effArr, eff10)

[t11, e11, v11, a11, c11, sq11, cp11, ti11, ln11, fr11, fd11, sf11] = request.security(sym11Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff11 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym11Enable
alphaScore11 = eff11 ? f_alphaScore(e11, v11, a11, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore11 = eff11 ? f_squeezeScore(sq11, cp11, ti11, fd11, sf11, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum11 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore11 = eff11 and compWSum11 > 0 ? (alphaWeightInComposite * alphaScore11 + squeezeWeightInComposite * squeezeScore11) / compWSum11 : -999999.0
array.push(symNames, sym11Sym)
array.push(prices, c11)
array.push(alphaScores, alphaScore11)
array.push(squeezeScores, squeezeScore11)
array.push(compositeScores, compositeScore11)
array.push(directions, f_direction(t11))
array.push(confluences, f_confluence(t11, ln11))
array.push(tiersArr, ti11)
array.push(sinceFiredArr, sf11)
array.push(effArr, eff11)

[t12, e12, v12, a12, c12, sq12, cp12, ti12, ln12, fr12, fd12, sf12] = request.security(sym12Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff12 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym12Enable
alphaScore12 = eff12 ? f_alphaScore(e12, v12, a12, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore12 = eff12 ? f_squeezeScore(sq12, cp12, ti12, fd12, sf12, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum12 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore12 = eff12 and compWSum12 > 0 ? (alphaWeightInComposite * alphaScore12 + squeezeWeightInComposite * squeezeScore12) / compWSum12 : -999999.0
array.push(symNames, sym12Sym)
array.push(prices, c12)
array.push(alphaScores, alphaScore12)
array.push(squeezeScores, squeezeScore12)
array.push(compositeScores, compositeScore12)
array.push(directions, f_direction(t12))
array.push(confluences, f_confluence(t12, ln12))
array.push(tiersArr, ti12)
array.push(sinceFiredArr, sf12)
array.push(effArr, eff12)

[t13, e13, v13, a13, c13, sq13, cp13, ti13, ln13, fr13, fd13, sf13] = request.security(sym13Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff13 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym13Enable
alphaScore13 = eff13 ? f_alphaScore(e13, v13, a13, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore13 = eff13 ? f_squeezeScore(sq13, cp13, ti13, fd13, sf13, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum13 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore13 = eff13 and compWSum13 > 0 ? (alphaWeightInComposite * alphaScore13 + squeezeWeightInComposite * squeezeScore13) / compWSum13 : -999999.0
array.push(symNames, sym13Sym)
array.push(prices, c13)
array.push(alphaScores, alphaScore13)
array.push(squeezeScores, squeezeScore13)
array.push(compositeScores, compositeScore13)
array.push(directions, f_direction(t13))
array.push(confluences, f_confluence(t13, ln13))
array.push(tiersArr, ti13)
array.push(sinceFiredArr, sf13)
array.push(effArr, eff13)

[t14, e14, v14, a14, c14, sq14, cp14, ti14, ln14, fr14, fd14, sf14] = request.security(sym14Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff14 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym14Enable
alphaScore14 = eff14 ? f_alphaScore(e14, v14, a14, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore14 = eff14 ? f_squeezeScore(sq14, cp14, ti14, fd14, sf14, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum14 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore14 = eff14 and compWSum14 > 0 ? (alphaWeightInComposite * alphaScore14 + squeezeWeightInComposite * squeezeScore14) / compWSum14 : -999999.0
array.push(symNames, sym14Sym)
array.push(prices, c14)
array.push(alphaScores, alphaScore14)
array.push(squeezeScores, squeezeScore14)
array.push(compositeScores, compositeScore14)
array.push(directions, f_direction(t14))
array.push(confluences, f_confluence(t14, ln14))
array.push(tiersArr, ti14)
array.push(sinceFiredArr, sf14)
array.push(effArr, eff14)

[t15, e15, v15, a15, c15, sq15, cp15, ti15, ln15, fr15, fd15, sf15] = request.security(sym15Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff15 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym15Enable
alphaScore15 = eff15 ? f_alphaScore(e15, v15, a15, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore15 = eff15 ? f_squeezeScore(sq15, cp15, ti15, fd15, sf15, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum15 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore15 = eff15 and compWSum15 > 0 ? (alphaWeightInComposite * alphaScore15 + squeezeWeightInComposite * squeezeScore15) / compWSum15 : -999999.0
array.push(symNames, sym15Sym)
array.push(prices, c15)
array.push(alphaScores, alphaScore15)
array.push(squeezeScores, squeezeScore15)
array.push(compositeScores, compositeScore15)
array.push(directions, f_direction(t15))
array.push(confluences, f_confluence(t15, ln15))
array.push(tiersArr, ti15)
array.push(sinceFiredArr, sf15)
array.push(effArr, eff15)

[t16, e16, v16, a16, c16, sq16, cp16, ti16, ln16, fr16, fd16, sf16] = request.security(sym16Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff16 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym16Enable
alphaScore16 = eff16 ? f_alphaScore(e16, v16, a16, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore16 = eff16 ? f_squeezeScore(sq16, cp16, ti16, fd16, sf16, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum16 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore16 = eff16 and compWSum16 > 0 ? (alphaWeightInComposite * alphaScore16 + squeezeWeightInComposite * squeezeScore16) / compWSum16 : -999999.0
array.push(symNames, sym16Sym)
array.push(prices, c16)
array.push(alphaScores, alphaScore16)
array.push(squeezeScores, squeezeScore16)
array.push(compositeScores, compositeScore16)
array.push(directions, f_direction(t16))
array.push(confluences, f_confluence(t16, ln16))
array.push(tiersArr, ti16)
array.push(sinceFiredArr, sf16)
array.push(effArr, eff16)

[t17, e17, v17, a17, c17, sq17, cp17, ti17, ln17, fr17, fd17, sf17] = request.security(sym17Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff17 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym17Enable
alphaScore17 = eff17 ? f_alphaScore(e17, v17, a17, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore17 = eff17 ? f_squeezeScore(sq17, cp17, ti17, fd17, sf17, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum17 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore17 = eff17 and compWSum17 > 0 ? (alphaWeightInComposite * alphaScore17 + squeezeWeightInComposite * squeezeScore17) / compWSum17 : -999999.0
array.push(symNames, sym17Sym)
array.push(prices, c17)
array.push(alphaScores, alphaScore17)
array.push(squeezeScores, squeezeScore17)
array.push(compositeScores, compositeScore17)
array.push(directions, f_direction(t17))
array.push(confluences, f_confluence(t17, ln17))
array.push(tiersArr, ti17)
array.push(sinceFiredArr, sf17)
array.push(effArr, eff17)

[t18, e18, v18, a18, c18, sq18, cp18, ti18, ln18, fr18, fd18, sf18] = request.security(sym18Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff18 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym18Enable
alphaScore18 = eff18 ? f_alphaScore(e18, v18, a18, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore18 = eff18 ? f_squeezeScore(sq18, cp18, ti18, fd18, sf18, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum18 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore18 = eff18 and compWSum18 > 0 ? (alphaWeightInComposite * alphaScore18 + squeezeWeightInComposite * squeezeScore18) / compWSum18 : -999999.0
array.push(symNames, sym18Sym)
array.push(prices, c18)
array.push(alphaScores, alphaScore18)
array.push(squeezeScores, squeezeScore18)
array.push(compositeScores, compositeScore18)
array.push(directions, f_direction(t18))
array.push(confluences, f_confluence(t18, ln18))
array.push(tiersArr, ti18)
array.push(sinceFiredArr, sf18)
array.push(effArr, eff18)

[t19, e19, v19, a19, c19, sq19, cp19, ti19, ln19, fr19, fd19, sf19] = request.security(sym19Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff19 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym19Enable
alphaScore19 = eff19 ? f_alphaScore(e19, v19, a19, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore19 = eff19 ? f_squeezeScore(sq19, cp19, ti19, fd19, sf19, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum19 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore19 = eff19 and compWSum19 > 0 ? (alphaWeightInComposite * alphaScore19 + squeezeWeightInComposite * squeezeScore19) / compWSum19 : -999999.0
array.push(symNames, sym19Sym)
array.push(prices, c19)
array.push(alphaScores, alphaScore19)
array.push(squeezeScores, squeezeScore19)
array.push(compositeScores, compositeScore19)
array.push(directions, f_direction(t19))
array.push(confluences, f_confluence(t19, ln19))
array.push(tiersArr, ti19)
array.push(sinceFiredArr, sf19)
array.push(effArr, eff19)

[t20, e20, v20, a20, c20, sq20, cp20, ti20, ln20, fr20, fd20, sf20] = request.security(sym20Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff20 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym20Enable
alphaScore20 = eff20 ? f_alphaScore(e20, v20, a20, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore20 = eff20 ? f_squeezeScore(sq20, cp20, ti20, fd20, sf20, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum20 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore20 = eff20 and compWSum20 > 0 ? (alphaWeightInComposite * alphaScore20 + squeezeWeightInComposite * squeezeScore20) / compWSum20 : -999999.0
array.push(symNames, sym20Sym)
array.push(prices, c20)
array.push(alphaScores, alphaScore20)
array.push(squeezeScores, squeezeScore20)
array.push(compositeScores, compositeScore20)
array.push(directions, f_direction(t20))
array.push(confluences, f_confluence(t20, ln20))
array.push(tiersArr, ti20)
array.push(sinceFiredArr, sf20)
array.push(effArr, eff20)

[t21, e21, v21, a21, c21, sq21, cp21, ti21, ln21, fr21, fd21, sf21] = request.security(sym21Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff21 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym21Enable
alphaScore21 = eff21 ? f_alphaScore(e21, v21, a21, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore21 = eff21 ? f_squeezeScore(sq21, cp21, ti21, fd21, sf21, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum21 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore21 = eff21 and compWSum21 > 0 ? (alphaWeightInComposite * alphaScore21 + squeezeWeightInComposite * squeezeScore21) / compWSum21 : -999999.0
array.push(symNames, sym21Sym)
array.push(prices, c21)
array.push(alphaScores, alphaScore21)
array.push(squeezeScores, squeezeScore21)
array.push(compositeScores, compositeScore21)
array.push(directions, f_direction(t21))
array.push(confluences, f_confluence(t21, ln21))
array.push(tiersArr, ti21)
array.push(sinceFiredArr, sf21)
array.push(effArr, eff21)

[t22, e22, v22, a22, c22, sq22, cp22, ti22, ln22, fr22, fd22, sf22] = request.security(sym22Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff22 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym22Enable
alphaScore22 = eff22 ? f_alphaScore(e22, v22, a22, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore22 = eff22 ? f_squeezeScore(sq22, cp22, ti22, fd22, sf22, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum22 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore22 = eff22 and compWSum22 > 0 ? (alphaWeightInComposite * alphaScore22 + squeezeWeightInComposite * squeezeScore22) / compWSum22 : -999999.0
array.push(symNames, sym22Sym)
array.push(prices, c22)
array.push(alphaScores, alphaScore22)
array.push(squeezeScores, squeezeScore22)
array.push(compositeScores, compositeScore22)
array.push(directions, f_direction(t22))
array.push(confluences, f_confluence(t22, ln22))
array.push(tiersArr, ti22)
array.push(sinceFiredArr, sf22)
array.push(effArr, eff22)

[t23, e23, v23, a23, c23, sq23, cp23, ti23, ln23, fr23, fd23, sf23] = request.security(sym23Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff23 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym23Enable
alphaScore23 = eff23 ? f_alphaScore(e23, v23, a23, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore23 = eff23 ? f_squeezeScore(sq23, cp23, ti23, fd23, sf23, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum23 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore23 = eff23 and compWSum23 > 0 ? (alphaWeightInComposite * alphaScore23 + squeezeWeightInComposite * squeezeScore23) / compWSum23 : -999999.0
array.push(symNames, sym23Sym)
array.push(prices, c23)
array.push(alphaScores, alphaScore23)
array.push(squeezeScores, squeezeScore23)
array.push(compositeScores, compositeScore23)
array.push(directions, f_direction(t23))
array.push(confluences, f_confluence(t23, ln23))
array.push(tiersArr, ti23)
array.push(sinceFiredArr, sf23)
array.push(effArr, eff23)

[t24, e24, v24, a24, c24, sq24, cp24, ti24, ln24, fr24, fd24, sf24] = request.security(sym24Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff24 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym24Enable
alphaScore24 = eff24 ? f_alphaScore(e24, v24, a24, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore24 = eff24 ? f_squeezeScore(sq24, cp24, ti24, fd24, sf24, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum24 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore24 = eff24 and compWSum24 > 0 ? (alphaWeightInComposite * alphaScore24 + squeezeWeightInComposite * squeezeScore24) / compWSum24 : -999999.0
array.push(symNames, sym24Sym)
array.push(prices, c24)
array.push(alphaScores, alphaScore24)
array.push(squeezeScores, squeezeScore24)
array.push(compositeScores, compositeScore24)
array.push(directions, f_direction(t24))
array.push(confluences, f_confluence(t24, ln24))
array.push(tiersArr, ti24)
array.push(sinceFiredArr, sf24)
array.push(effArr, eff24)

[t25, e25, v25, a25, c25, sq25, cp25, ti25, ln25, fr25, fd25, sf25] = request.security(sym25Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff25 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym25Enable
alphaScore25 = eff25 ? f_alphaScore(e25, v25, a25, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore25 = eff25 ? f_squeezeScore(sq25, cp25, ti25, fd25, sf25, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum25 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore25 = eff25 and compWSum25 > 0 ? (alphaWeightInComposite * alphaScore25 + squeezeWeightInComposite * squeezeScore25) / compWSum25 : -999999.0
array.push(symNames, sym25Sym)
array.push(prices, c25)
array.push(alphaScores, alphaScore25)
array.push(squeezeScores, squeezeScore25)
array.push(compositeScores, compositeScore25)
array.push(directions, f_direction(t25))
array.push(confluences, f_confluence(t25, ln25))
array.push(tiersArr, ti25)
array.push(sinceFiredArr, sf25)
array.push(effArr, eff25)

[t26, e26, v26, a26, c26, sq26, cp26, ti26, ln26, fr26, fd26, sf26] = request.security(sym26Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff26 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym26Enable
alphaScore26 = eff26 ? f_alphaScore(e26, v26, a26, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore26 = eff26 ? f_squeezeScore(sq26, cp26, ti26, fd26, sf26, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum26 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore26 = eff26 and compWSum26 > 0 ? (alphaWeightInComposite * alphaScore26 + squeezeWeightInComposite * squeezeScore26) / compWSum26 : -999999.0
array.push(symNames, sym26Sym)
array.push(prices, c26)
array.push(alphaScores, alphaScore26)
array.push(squeezeScores, squeezeScore26)
array.push(compositeScores, compositeScore26)
array.push(directions, f_direction(t26))
array.push(confluences, f_confluence(t26, ln26))
array.push(tiersArr, ti26)
array.push(sinceFiredArr, sf26)
array.push(effArr, eff26)

[t27, e27, v27, a27, c27, sq27, cp27, ti27, ln27, fr27, fd27, sf27] = request.security(sym27Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff27 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym27Enable
alphaScore27 = eff27 ? f_alphaScore(e27, v27, a27, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore27 = eff27 ? f_squeezeScore(sq27, cp27, ti27, fd27, sf27, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum27 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore27 = eff27 and compWSum27 > 0 ? (alphaWeightInComposite * alphaScore27 + squeezeWeightInComposite * squeezeScore27) / compWSum27 : -999999.0
array.push(symNames, sym27Sym)
array.push(prices, c27)
array.push(alphaScores, alphaScore27)
array.push(squeezeScores, squeezeScore27)
array.push(compositeScores, compositeScore27)
array.push(directions, f_direction(t27))
array.push(confluences, f_confluence(t27, ln27))
array.push(tiersArr, ti27)
array.push(sinceFiredArr, sf27)
array.push(effArr, eff27)

[t28, e28, v28, a28, c28, sq28, cp28, ti28, ln28, fr28, fd28, sf28] = request.security(sym28Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff28 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym28Enable
alphaScore28 = eff28 ? f_alphaScore(e28, v28, a28, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore28 = eff28 ? f_squeezeScore(sq28, cp28, ti28, fd28, sf28, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum28 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore28 = eff28 and compWSum28 > 0 ? (alphaWeightInComposite * alphaScore28 + squeezeWeightInComposite * squeezeScore28) / compWSum28 : -999999.0
array.push(symNames, sym28Sym)
array.push(prices, c28)
array.push(alphaScores, alphaScore28)
array.push(squeezeScores, squeezeScore28)
array.push(compositeScores, compositeScore28)
array.push(directions, f_direction(t28))
array.push(confluences, f_confluence(t28, ln28))
array.push(tiersArr, ti28)
array.push(sinceFiredArr, sf28)
array.push(effArr, eff28)

[t29, e29, v29, a29, c29, sq29, cp29, ti29, ln29, fr29, fd29, sf29] = request.security(sym29Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff29 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym29Enable
alphaScore29 = eff29 ? f_alphaScore(e29, v29, a29, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore29 = eff29 ? f_squeezeScore(sq29, cp29, ti29, fd29, sf29, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum29 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore29 = eff29 and compWSum29 > 0 ? (alphaWeightInComposite * alphaScore29 + squeezeWeightInComposite * squeezeScore29) / compWSum29 : -999999.0
array.push(symNames, sym29Sym)
array.push(prices, c29)
array.push(alphaScores, alphaScore29)
array.push(squeezeScores, squeezeScore29)
array.push(compositeScores, compositeScore29)
array.push(directions, f_direction(t29))
array.push(confluences, f_confluence(t29, ln29))
array.push(tiersArr, ti29)
array.push(sinceFiredArr, sf29)
array.push(effArr, eff29)

[t30, e30, v30, a30, c30, sq30, cp30, ti30, ln30, fr30, fd30, sf30] = request.security(sym30Sym, dataTF, f_screenBundle(fastLen, slowLen, erLen, volLen, atrLen, atrPctLen, sqzLen, sqzBbMult, sqzKcHighMult, sqzKcMidMult, sqzKcLowMult))
eff30 = watchlistOverride == "Force ALL ON" ? true : watchlistOverride == "Force ALL OFF" ? false : sym30Enable
alphaScore30 = eff30 ? f_alphaScore(e30, v30, a30, effWeight, volWeight, atrFitWeight) : -999999.0
squeezeScore30 = eff30 ? f_squeezeScore(sq30, cp30, ti30, fd30, sf30, sqzFireWindowBars, wSqzComp, wSqzTier, wSqzFire) : -999999.0
compWSum30 = alphaWeightInComposite + squeezeWeightInComposite
compositeScore30 = eff30 and compWSum30 > 0 ? (alphaWeightInComposite * alphaScore30 + squeezeWeightInComposite * squeezeScore30) / compWSum30 : -999999.0
array.push(symNames, sym30Sym)
array.push(prices, c30)
array.push(alphaScores, alphaScore30)
array.push(squeezeScores, squeezeScore30)
array.push(compositeScores, compositeScore30)
array.push(directions, f_direction(t30))
array.push(confluences, f_confluence(t30, ln30))
array.push(tiersArr, ti30)
array.push(sinceFiredArr, sf30)
array.push(effArr, eff30)

// =====================================================================================
// RANKING (unconditional every bar - shared by the table and the alerts below). NEW in
// v2.0: rankSourceArr is chosen by the Rank By dropdown instead of always being the Alpha
// Score array. ALSO NEW - the sort now runs over only the EFFECTIVELY ENABLED slots
// (enabledIdxArr), not all 30, so a disabled symbol is skipped entirely rather than
// sorting to the bottom and still occupying a table row - this is what makes the table
// shrink to only the symbols actually in use (same "pack enabled slots into consecutive
// rows" technique already proven in #80's dynamic Heatmap Strip/Detail Table).
//
// BUG FIX (2026-08-19, post-delivery, real runtime error RE10040 "Row N is out of table
// bounds"): enabledIdxArr must be filtered on effArr (each slot's STATIC enabled flag -
// checkbox + Watchlist Override), NOT on whether alphaScores currently holds a valid
// number. A symbol's Alpha/Squeeze Score can legitimately read na for its first several
// hundred bars while length-252 ATR-percentile/efficiency-ratio lookbacks are still
// warming up, even though that symbol is enabled the whole time - filtering on the score
// meant enabledIdxArr (and therefore tableRows) started small and grew as history
// accumulated. Since `dash` below is declared with `var table` (sized once, on its first
// execution) but tableRows is recomputed every bar, a later bar needing more rows than
// the table was originally sized for threw "Row N out of table bounds." Filtering on the
// STATIC effArr instead keeps the enabled count - and therefore tableRows - fixed from
// bar 1 onward, matching the same stable-count pattern #80 already uses successfully for
// its own dynamically-sized tables. Sort-key na is coerced to a low value so a still-
// warming-up symbol sorts to the bottom instead of breaking array.sort_indices().
// =====================================================================================
rankSourceArr = rankByMode == "Alpha Score" ? alphaScores : rankByMode == "Squeeze Score" ? squeezeScores : compositeScores
enabledIdxArr = array.new_int(0)
enabledSortKeyArr = array.new_float(0)
for i = 0 to 29
    if array.get(effArr, i)
        array.push(enabledIdxArr, i)
        sortKeyRaw = array.get(rankSourceArr, i)
        array.push(enabledSortKeyArr, na(sortKeyRaw) ? -999999.0 : sortKeyRaw)
sortedSubIdx = array.size(enabledSortKeyArr) > 0 ? array.sort_indices(enabledSortKeyArr, order.descending) : array.new_int(0)

top1Idx = array.size(sortedSubIdx) > 0 ? array.get(enabledIdxArr, array.get(sortedSubIdx, 0)) : -1
top1ScoreVal = top1Idx >= 0 ? array.get(rankSourceArr, top1Idx) : -999999.0
top1Name = top1Idx >= 0 ? array.get(symNames, top1Idx) : "None"

// Average Alpha Score across ENABLED symbols only, for the watchlist-wide strength alerts
// (unchanged from v1.0 - deliberately still Alpha-based, since these 2 alerts are about
// general watchlist setup quality, not compression - the new Squeeze-specific alert below
// covers the compression side).
avgScoreSum = 0.0
avgScoreCount = 0
if array.size(alphaScores) > 0
    for i = 0 to array.size(alphaScores) - 1
        s = array.get(alphaScores, i)
        if s > -999998.0
            avgScoreSum := avgScoreSum + s
            avgScoreCount := avgScoreCount + 1
avgEnabledScore = avgScoreCount > 0 ? avgScoreSum / avgScoreCount : 0.0

// =====================================================================================
// RANK CHANGE TRACKING (NEW in v2.0) - per-SLOT (not per-name) tracking, since each of the
// 30 slots is a stable input across bars even though the SORTED display order changes
// every bar. currentRankOfSlot inverts sortedSubIdx/enabledIdxArr (slot -> rank among
// currently-enabled symbols, 1..enabledCount); prevRankOfSlot is the same thing carried
// over from the prior bar via `var`, read BEFORE being overwritten so the delta reflects
// prior-bar-vs-this-bar, not a same-bar comparison. A symbol newly enabled (or re-enabled
// via the Watchlist Override) correctly shows "New" rather than a stale old rank, since
// disabled slots are left at -1 here rather than carrying a leftover rank forward.
// =====================================================================================
var array<int> prevRankOfSlot = array.new_int(30, -1)
currentRankOfSlot = array.new_int(30, -1)
if array.size(sortedSubIdx) > 0
    for j = 0 to array.size(sortedSubIdx) - 1
        slotIdx = array.get(enabledIdxArr, array.get(sortedSubIdx, j))
        array.set(currentRankOfSlot, slotIdx, j + 1)

// "Any Symbol Entered Top N" (NEW alert) - computed here, while prevRankOfSlot still holds
// the PRIOR bar's ranks.
anySymbolEnteredTopN = false
for i = 0 to 29
    prevR = array.get(prevRankOfSlot, i)
    curR = array.get(currentRankOfSlot, i)
    aScore = array.get(alphaScores, i)
    if aScore > -999998.0 and curR >= 1 and curR <= topNForAlert and (prevR < 1 or prevR > topNForAlert)
        anySymbolEnteredTopN := true

// Now safe to roll currentRankOfSlot into prevRankOfSlot for the next bar.
for i = 0 to 29
    array.set(prevRankOfSlot, i, array.get(currentRankOfSlot, i))

// "Any Symbol Newly Squeeze-Ready" (NEW alert) - same prior-bar-vs-this-bar pattern,
// tracking each slot's own Squeeze Score.
var array<float> prevSqueezeScoreOfSlot = array.new_float(30, -999999.0)
anySymbolNewlySqueezeReady = false
for i = 0 to 29
    sqNow = array.get(squeezeScores, i)
    sqPrev = array.get(prevSqueezeScoreOfSlot, i)
    if sqNow > -999998.0 and sqPrev > -999998.0 and sqPrev <= squeezeReadyAlertThreshold and sqNow > squeezeReadyAlertThreshold
        anySymbolNewlySqueezeReady := true
for i = 0 to 29
    array.set(prevSqueezeScoreOfSlot, i, array.get(squeezeScores, i))

// =====================================================================================
// SIGNAL LOGIC
// =====================================================================================
avgScoreRisingThroughHigh = ta.crossover(avgEnabledScore, avgScoreHighThreshold)
avgScoreFallingThroughLow = ta.crossunder(avgEnabledScore, avgScoreLowThreshold)

var string prevTop1 = ""
leadershipChanged = top1Name != "None" and top1Name != prevTop1
if leadershipChanged and barstate.islast
    alert("MYND Command Center: New #1 ranked symbol (by " + rankByMode + ") - " + top1Name + " (Score " + str.tostring(top1ScoreVal, "#.#") + ")", alert.freq_once_per_bar_close)
prevTop1 := top1Name

// =====================================================================================
// SCREENER TABLE - 10 columns (v1.0's 5 + Rank Δ, Squeeze Score, Tier, Confluence,
// Composite - NEW) x DYNAMIC rows (NEW in this revision: 1 header + only however many
// symbols are effectively enabled right now, instead of a fixed 31 - a disabled symbol no
// longer occupies a blank/'(Off)' row at all, so the table shrinks automatically when only
// a few of your 30 slots are in use. Same runtime-computed table.new() sizing technique
// already proven in #80.
// =====================================================================================
tableRows = math.max(1, 1 + array.size(enabledIdxArr))
var table dash = table.new(tablePosConst, 10, tableRows, border_width=1)

f_cell(_col, _row, _txt, _bg, _txtcol) =>
    table.cell(dash, _col, _row, _txt, bgcolor=_bg, text_color=_txtcol, text_size=tableSizeConst)

if showTable and barstate.islast
    f_cell(0, 0, "Rank", headerBgColor, headerTextColor)
    f_cell(1, 0, "Rank Δ", headerBgColor, headerTextColor)
    f_cell(2, 0, "Symbol", headerBgColor, headerTextColor)
    f_cell(3, 0, "Price", headerBgColor, headerTextColor)
    f_cell(4, 0, "Alpha", headerBgColor, headerTextColor)
    f_cell(5, 0, "Squeeze", headerBgColor, headerTextColor)
    f_cell(6, 0, "Tier", headerBgColor, headerTextColor)
    f_cell(7, 0, "Confl.", headerBgColor, headerTextColor)
    f_cell(8, 0, "Direction", headerBgColor, headerTextColor)
    f_cell(9, 0, "Composite", headerBgColor, headerTextColor)

    if array.size(sortedSubIdx) > 0
        for i = 0 to array.size(sortedSubIdx) - 1
            idx = array.get(enabledIdxArr, array.get(sortedSubIdx, i))
            aSc = array.get(alphaScores, idx)
            sSc = array.get(squeezeScores, idx)
            cSc = array.get(compositeScores, idx)
            nm = array.get(symNames, idx)
            pr = array.get(prices, idx)
            dr = array.get(directions, idx)
            cf = array.get(confluences, idx)
            tier = array.get(tiersArr, idx)
            rowNum = i + 1

            rankTxt = str.tostring(rowNum)
            prevR = array.get(prevRankOfSlot, idx)
            rankDeltaVal = prevR < 1 ? 0 : prevR - rowNum
            rankDeltaTxt = prevR < 1 ? "New" : rankDeltaVal > 0 ? "▲" + str.tostring(rankDeltaVal) : rankDeltaVal < 0 ? "▼" + str.tostring(math.abs(rankDeltaVal)) : "–"
            rankDeltaColor = rankDeltaVal > 0 ? colBullish : rankDeltaVal < 0 ? colBearish : color.new(color.gray, 60)
            nameTxt = nm
            priceTxt = str.tostring(pr, "#.##")
            // "X / 100" / "X / 3" formatting (NEW) - shows each score against its actual
            // total available, not just a bare number, per Travis's request.
            // na-guard (bug fix, 2026-08-19): an enabled symbol can still legitimately read
            // na for its first several hundred bars while length-252-style lookbacks warm
            // up - show "Warming up" instead of a garbled "NaN / 100".
            alphaTxt = na(aSc) ? "Warming up" : str.tostring(aSc, "#.#") + " / 100"
            sqzTxt = na(sSc) ? "Warming up" : str.tostring(sSc, "#.#") + " / 100"
            tierTxt = "T" + str.tostring(tier) + " (" + str.tostring(tier) + "/3)"
            compTxt = na(cSc) ? "Warming up" : str.tostring(cSc, "#.#") + " / 100"
            dirTxt = dr
            cfTxt = cf

            baseColor = color.new(color.gray, 90)
            alphaColor = na(aSc) ? baseColor : aSc >= scoreHighThreshold ? color.new(colScoreHigh, 75) : aSc >= scoreMedThreshold ? color.new(colScoreMed, 80) : color.new(colScoreLow, 85)
            sqzColor = na(sSc) ? baseColor : sSc >= scoreHighThreshold ? color.new(colScoreHigh, 75) : sSc >= scoreMedThreshold ? color.new(colScoreMed, 80) : color.new(colScoreLow, 85)
            compColor = na(cSc) ? baseColor : cSc >= scoreHighThreshold ? color.new(colScoreHigh, 75) : cSc >= scoreMedThreshold ? color.new(colScoreMed, 80) : color.new(colScoreLow, 85)
            tierColor = tier == 3 ? color.new(colScoreHigh, 75) : tier == 2 ? color.new(colScoreMed, 80) : color.new(colScoreLow, 88)
            dirColor = dr == "Bullish" ? color.new(colBullish, 80) : dr == "Bearish" ? color.new(colBearish, 80) : color.new(colMixed, 85)
            cfColor = cf == "Yes" ? color.new(colBullish, 85) : cf == "No" ? color.new(colBearish, 88) : color.new(color.gray, 92)

            f_cell(0, rowNum, rankTxt, baseColor, color.black)
            f_cell(1, rowNum, rankDeltaTxt, showRankChange ? rankDeltaColor : baseColor, color.black)
            f_cell(2, rowNum, nameTxt, baseColor, color.black)
            f_cell(3, rowNum, priceTxt, baseColor, color.black)
            f_cell(4, rowNum, alphaTxt, alphaColor, color.black)
            f_cell(5, rowNum, sqzTxt, sqzColor, color.black)
            f_cell(6, rowNum, tierTxt, tierColor, color.black)
            f_cell(7, rowNum, cfTxt, cfColor, color.black)
            f_cell(8, rowNum, dirTxt, dirColor, color.black)
            f_cell(9, rowNum, compTxt, compColor, color.black)

// =====================================================================================
// ALERTS - v1.0 shipped with 2 alertconditions plus a dynamic alert() for leadership
// changes (that taxonomy note still applies - see the Signals & Alerts tab). v2.0 adds 2
// more genuine alertcondition()s (both watchlist-wide, not per-symbol) and a combo bundle.
// =====================================================================================
alertcondition(avgScoreRisingThroughHigh, title="Watchlist Strength Rising", message="MYND CCS: Average Alpha Score across your active watchlist crossed above the high threshold - broad strength building")
alertcondition(avgScoreFallingThroughLow, title="Watchlist Strength Falling", message="MYND CCS: Average Alpha Score across your active watchlist crossed below the low threshold - broad weakness building")
alertcondition(anySymbolEnteredTopN, title="Symbol Entered Top N (NEW)", message="MYND CCS: A symbol in your watchlist just entered the top-N ranking - check the table for which one")
alertcondition(anySymbolNewlySqueezeReady, title="Symbol Newly Squeeze-Ready (NEW)", message="MYND CCS: A symbol in your watchlist just crossed above your Squeeze Score threshold - a new coiled setup - check the table for which one")
allWatchlistAlerts = avgScoreRisingThroughHigh or avgScoreFallingThroughLow or anySymbolEnteredTopN or anySymbolNewlySqueezeReady
alertcondition(allWatchlistAlerts, title="ALL Watchlist Alerts (combo)", message="MYND CCS: A watchlist-wide alert condition fired - check the table for detail")
````
