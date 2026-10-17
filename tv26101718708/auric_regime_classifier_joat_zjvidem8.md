# Auric Regime Classifier [JOAT]

- url: https://www.tradingview.com/script/ZjvidEM8-Auric-Regime-Classifier-JOAT/
- type: indicator
- pine_id: PUB;9087def93b85480898e0144799e116d6
- version: 1.0

## Description

[b]Auric Regime Classifier [JOAT][/b]

[b]Introduction[/b]

Auric Regime Classifier (ARC) is an open-source, multi-factor market regime detection engine that classifies every confirmed bar into one of five distinct market states: Strong Bull, Weak Bull, Ranging, Weak Bear, or Strong Bear — with a special Compression override that fires when volatility is contracting. The engine uses five independent data sources — adaptive ATR volatility ratio, Bollinger Band squeeze detection, SMEMA trend slope, ADX directional index, and RSI momentum bias — fused through a weighted scoring system into a single net score that drives the regime classification.

The problem ARC solves is that most traders apply a fixed strategy regardless of whether the market is trending strongly, drifting weakly, compressing before a breakout, or chopping without direction. Each of those conditions demands a completely different approach. Applying a trend-following system in a ranging market produces losses. Trading with tight stops in a compression phase produces whipsaws. ARC gives you a clear, real-time label for the current market phase so you can match your approach to the conditions rather than fighting them.

[image]https://www.tradingview.com/x/299NsyO6/[/image]

[b]Core Concepts[/b]

[b]1. SMEMA Adaptive Baseline[/b]

The indicator uses SMEMA (Simple Moving Average of Exponential Moving Average) as its core trend baseline — a proprietary double-smoothing construct used throughout the JackOfAllTrades indicator suite. SMEMA applies a standard EMA first to capture responsiveness, then a SMA over the same period to suppress noise. The result is a baseline that reacts faster than a raw SMA but is smoother than a raw EMA:

[pine]
smema(float src, int len) =>
    ta.sma(ta.ema(src, len), len)
[/pine]

Two SMEMA lines run in parallel: a slow line over the full period (default 20) and a fast line at half the period. Their slope comparison over three bars determines the trend direction score. When the slow SMEMA slopes upward for three consecutive bars, two bull points are awarded. When it slopes downward, two bear points are awarded.

[b]2. Adaptive ATR Volatility Ratio[/b]

ATR over the input period (default 14) is compared against a long-run SMA of ATR (default 50 bars) to produce a volatility expansion/contraction ratio:

[pine]
float volRatio = safeDiv(atrRaw, atrBase, 1.0)
[/pine]

A ratio above 1.1 in the direction of the existing trend awards a bonus point — recognizing that trend moves are more reliable when accompanied by above-average volatility. This prevents the engine from scoring weak, low-volume drifts as strongly as genuine impulsive moves.

[b]3. Bollinger Band Squeeze Detection[/b]

The indicator measures Bollinger Band bandwidth (upper minus lower) and compares it against its own 100-bar SMA. When bandwidth falls below the configurable threshold fraction (default 0.75) of its smoothed average, the market is classified as Compressing. Compression overrides all other regime classifications — a compressing market has no valid directional edge regardless of what the other signals say:

[pine]
bool isSqz = bbBW < bbBWAvg * sqzPct
[/pine]

A Squeeze Release signal fires when compression ends (isSqz transitions from true to false), marking the potential start of an expansion move.

[b]4. ADX Directional Index[/b]

ADX (Average Directional Index) and the +DI/-DI directional lines are calculated using Pine Script v6's built-in ta.dmi() function. ADX above the threshold (default 25) confirms that the market is in a genuine trending regime rather than a sideways range. The directional bias of +DI vs -DI adds two bull or bear points to the regime score:

[pine]
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
bool isBullDir = diPlus  > diMinus
bool isBearDir = diMinus > diPlus
[/pine]

[b]5. Regime Scoring Engine[/b]

All five components feed a dual-sided scoring system. Bull and bear points are accumulated independently, and the net score (bull minus bear, range -6 to +6) determines the regime code:

[pine]
int bullPts = (trendUp   ? 2 : 0) + (isBullDir ? 2 : 0) +
              (rsiBull   ? 1 : 0) + ((volRatio > 1.1 and trendUp) ? 1 : 0)
int netScore = bullPts - bearPts
int regCode  = isSqz ? 0 : netScore >= 4 ? 2 : netScore >= 1 ? 1 :
               netScore <= -4 ? -2 : netScore <= -1 ? -1 : 0
[/pine]

Strong Bull requires a net score of +4 or higher (all four components aligned). Weak Bull requires +1 to +3. Ranging sits at 0. The mirror applies for bearish regimes.

[b]6. Trend Strength Score (0-100)[/b]

Beyond the categorical regime label, ARC produces a continuous trend strength score that measures conviction within the current regime. It combines a distance score (how far price is from the SMEMA baseline in ATR units, capped at 50 points) with a momentum score (RSI deviation from 50 in the trend direction, capped at 50 points). A score of 70+ indicates a strong, high-conviction regime. Below 40 indicates a weak or transitional state.

[b]Features[/b]

[list]
[*][b]Five-State Regime Classification:[/b] Every bar labeled Strong Bull, Weak Bull, Ranging, Weak Bear, or Strong Bear with a Compression override — no ambiguity
[*][b]SMEMA Ribbon:[/b] Fast and slow SMEMA lines with a gradient fill between them, colored by the current regime state for instant visual context
[*][b]Regime Background Tint:[/b] Subtle, semi-transparent background coloring that shifts with the regime — green family for bull states, red family for bear, yellow for compression
[*][b]Candle Coloring:[/b] Bar colors inherit the regime color at reduced opacity, giving every candle immediate regime context without obscuring price action
[*][b]Squeeze Markers:[/b] Circle markers on the SMEMA baseline during compression, with a diamond signal at the moment of squeeze release
[*][b]Trend Strength Score:[/b] A 0-100 numeric score with a Strong/Moderate/Weak label updated each bar, shown in the dashboard
[*][b]Regime Change Alerts:[/b] Alert fires on every confirmed regime state transition with either plain text or structured JSON for webhook delivery
[*][b]12-Row Dashboard (Top Right):[/b] Displays current regime, trend strength score, ADX value and trending/ranging status, +DI/-DI directional reading, volatility ratio, Bollinger Band state, RSI, timeframe, and version
[*][b]Watermark:[/b] JackOfAllTrades signature rendered at chart center-bottom
[/list]

[b]Input Parameters[/b]

[b]Core Engine:[/b]
[list]
[*]ATR Length: Period for raw ATR calculation (default: 14)
[*]ATR Smoothing Period: Baseline ATR lookback for volatility ratio (default: 50)
[/list]

[b]Directional Index:[/b]
[list]
[*]ADX / DI Length: Period for +DI, -DI, and ADX (default: 14)
[*]Trend Threshold: ADX level above which the market is considered trending (default: 25)
[/list]

[b]Volatility Band:[/b]
[list]
[*]BB Length: Bollinger Band period (default: 20)
[*]BB Multiplier: Standard deviation multiplier (default: 2.0)
[*]Squeeze Threshold: Bandwidth fraction of its 100-bar SMA below which compression is declared (default: 0.75)
[/list]

[b]Trend Engine:[/b]
[list]
[*]SMEMA Length: Period for the double-smoothed baseline (default: 20)
[*]RSI Length: Momentum confirmation period (default: 14)
[/list]

[b]Visuals / Dashboard / Alerts:[/b]
[list]
[*]Theme: Auto, Dark, or Light — auto-detects chart background
[*]Regime Background Tint: Toggle the subtle background color
[*]Show SMEMA Baseline: Toggle the ribbon plots
[*]Show Squeeze Markers: Toggle the circle and diamond markers
[*]Show Dashboard: Toggle the 12-row information panel
[*]Show Watermark: Toggle the JackOfAllTrades signature
[*]Webhook JSON Format: Switch alert messages between plain text and JSON
[*]Color Palette: All six regime colors are individually customizable
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Regime[/b]
The dashboard regime field and the background tint tell you exactly where the market stands. This single label is the most actionable piece of information — it drives which strategy is appropriate.

[b]Step 2: Match Your Approach to the Regime[/b]
[list]
[*][b]Strong Bull / Strong Bear:[/b] All four scoring components are aligned. High-conviction directional trades, trend-following entries on pullbacks to the SMEMA ribbon
[*][b]Weak Bull / Weak Bear:[/b] Only one or two components agree. Lighter position sizing, wider stops, prepare for a possible regime shift
[*][b]Ranging:[/b] Net score near zero — avoid directional trades, consider mean-reversion or wait for breakout
[*][b]Compression:[/b] All directional analysis is suspended. Reduce exposure, prepare for a breakout in either direction, and watch the squeeze release signal for timing
[/list]

[b]Step 3: Use Trend Strength for Conviction[/b]
Within any directional regime, the strength score tells you how far into that regime the market has moved. A Strong Bull reading with a strength score of 85 is a very different trade environment from one with a strength score of 42. Use the score to scale position size or filter lower-conviction entries.

[b]Step 4: Set Alerts on Regime Transitions[/b]
The regime-change alert fires the moment a new regime is confirmed on bar close. Enable the Strong Bull and Strong Bear alertconditions specifically to catch the high-conviction regime entrances.

[b]Indicator Limitations[/b]

[list]
[*]All five components are backward-looking. The regime label describes what has happened over the lookback windows — not what will happen. A Strong Bull classification can reverse on the very next bar
[*]The warmup period (equal to the longest lookback, at least 50 bars) means the indicator produces no signals on the first several bars of any chart, including after switching timeframes
[*]Compression detection uses a 100-bar SMA of bandwidth, which is a long-run reference. On very short or illiquid charts with few bars, the bandwidth average may not be reliable
[*]The five-state classification uses fixed score thresholds (+4 for Strong, +1 for Weak). These thresholds are not auto-calibrated to the instrument. In range-bound markets where ADX rarely exceeds 20, the Strong Bull/Bear states may rarely appear
[*]RSI and ADX both work with default periods. No single set of periods is optimal across all assets and timeframes. Users may need to adjust periods when applying to highly volatile assets or longer timeframes
[/list]

[b]Originality Statement[/b]

ARC is original in its synthesis approach and the use of SMEMA as the core trend baseline. This indicator is published because:

[list]
[*]The SMEMA construct (SMA of EMA) is a proprietary double-smoothing formula used consistently across the JackOfAllTrades suite — it provides a smoother baseline than raw EMA while retaining more responsiveness than raw SMA, and it is not a standard available in typical indicator libraries
[*]The dual-sided bull/bear point system scores each directional component independently before computing a net score. This is distinct from composite oscillators that blend components into a single signed value — the dual-side approach preserves information about how many bear components are active even when the net score is positive
[*]The Compression override takes precedence over all directional scores, explicitly suspending regime analysis during volatility contractions. Most regime indicators simply produce lower directional readings in compression without explicitly declaring the compression state
[*]The trend strength score combines an ATR-normalized price distance with an RSI momentum deviation to produce a conviction metric that is distinct from the categorical regime label
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Market regime classifications are based entirely on historical data and past behavior. A market classified as Strong Bull can and will reverse at any time. The Compression state does not guarantee a subsequent breakout, and the direction of any eventual breakout cannot be predicted from compression alone. Always apply proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(
    title            = "Auric Regime Classifier [JOAT]",
    shorttitle       = "ARC [JOAT]",
    overlay          = true,
    max_lines_count  = 500,
    max_labels_count = 500)

// ─── Groups ───────────────────────────────────────────────────────────────────
G_CORE  = "Core Engine"
G_ADX   = "Directional Index"
G_BB    = "Volatility Band"
G_TREND = "Trend Engine"
G_VIS   = "Visual Settings"
G_DASH  = "Dashboard"
G_ALERT = "Alerts"
G_COL   = "Color Palette"

INDICATOR_VERSION = "v1.0.0"

// ─── Inputs ───────────────────────────────────────────────────────────────────
atrLen     = input.int(14,    "ATR Length",            minval=1,   maxval=50,  group=G_CORE)
atrSmooth  = input.int(50,    "ATR Smoothing Period",  minval=10,  maxval=200, group=G_CORE,
    tooltip="Baseline period for ATR average. Vol Ratio = currentATR / baseline.\n>1.0 = expanding volatility, <1.0 = contracting")
adxLen     = input.int(14,    "ADX / DI Length",       minval=2,   maxval=50,  group=G_ADX,
    tooltip="Period for +DI / -DI / ADX calculation (ta.dmi)")
adxThresh  = input.int(25,    "Trend Threshold",       minval=10,  maxval=50,  group=G_ADX,
    tooltip="ADX above this value = trending market. Below = ranging.")
bbLen      = input.int(20,    "BB Length",             minval=5,   maxval=100, group=G_BB)
bbMult     = input.float(2.0, "BB Multiplier",         minval=0.5, maxval=5.0, step=0.1, group=G_BB)
sqzPct     = input.float(0.75,"Squeeze Threshold",     minval=0.3, maxval=1.0, step=0.05, group=G_BB,
    tooltip="BB bandwidth below this fraction of its 100-bar SMA = compression state")
smemaLen   = input.int(20,    "SMEMA Length",          minval=3,   maxval=100, group=G_TREND,
    tooltip="Period for sma(ema(close,L),L) — the JOAT adaptive trend baseline")
rsiLen     = input.int(14,    "RSI Length",            minval=2,   maxval=50,  group=G_TREND)
themeStr   = input.string("Auto",      "Theme",      options=["Auto","Dark","Light"], group=G_VIS)
showBg     = input.bool(true,          "Regime Background Tint",  group=G_VIS)
showSmema  = input.bool(true,          "Show SMEMA Baseline",     group=G_VIS)
showSqz    = input.bool(true,          "Show Squeeze Markers",    group=G_VIS)
showDash   = input.bool(true,          "Show Dashboard",          group=G_DASH)
dashPosStr = input.string("Top Right", "Dashboard Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
showWM     = input.bool(true,          "Show Watermark",          group=G_VIS)
webhookFmt = input.bool(false,         "Webhook JSON Format",     group=G_ALERT)
cSBull     = input.color(#00C853, "Strong Bull", inline="c1", group=G_COL)
cWBull     = input.color(#69F0AE, "Weak Bull",   inline="c1", group=G_COL)
cRange     = input.color(#546E7A, "Ranging",      inline="c2", group=G_COL)
cWBear     = input.color(#FF7043, "Weak Bear",    inline="c2", group=G_COL)
cSBear     = input.color(#D50000, "Strong Bear",  inline="c3", group=G_COL)
cSqz       = input.color(#FFD600, "Squeeze",      inline="c3", group=G_COL)

// ─── Theme ────────────────────────────────────────────────────────────────────
isDark  = switch themeStr
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

TXT     = isDark ? #E0E0E0 : #1A1A1A
TXT_M   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
TBL_BG  = isDark ? color.new(#0D1117, 5) : color.new(#FFFFFF, 5)
TBL_BD  = isDark ? color.new(#21262D, 0) : color.new(#D0D0D0, 0)
TBL_ALT = isDark ? color.new(#161B22, 0) : color.new(#F6F8FA, 0)
HDR_BG  = color.new(#1565C0, 0)
WM_C    = isDark ? color.new(#FFFFFF, 85) : color.new(#000000, 85)

// ─── Utility Functions ────────────────────────────────────────────────────────
safeDiv(float n, float d, float fb = 0.0) =>
    d != 0.0 and not na(n) and not na(d) ? n / d : fb

// SMEMA: sma(ema(src, L), L) — smoother than EMA alone, more responsive than SMA
smema(float src, int len) =>
    ta.sma(ta.ema(src, len), len)

getDashPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.top_right

// ─── Warmup Gate ──────────────────────────────────────────────────────────────
// Prevent signals until all indicators have sufficient history
int  WARMUP = math.max(math.max(atrSmooth, bbLen * 3), math.max(adxLen * 3, 50))
bool warmed = bar_index >= WARMUP

// ─── Core Calculations ────────────────────────────────────────────────────────

// 1. Adaptive ATR Volatility Ratio
//    Ratio > 1.2 = volatility expansion (trending)
//    Ratio < 0.8 = volatility contraction (compression)
float atrRaw  = ta.atr(atrLen)
float atrBase = nz(ta.sma(atrRaw, atrSmooth), nz(atrRaw, 1.0))
float volRatio = safeDiv(atrRaw, atrBase, 1.0)

// 2. Bollinger Bandwidth Squeeze
//    Bandwidth below threshold fraction of its 100-bar average = compression
[bbBasis, bbUpper, bbLower] = ta.bb(close, bbLen, bbMult)
float bbBW      = bbUpper - bbLower
float bbBWAvg   = nz(ta.sma(bbBW, 100), nz(bbBW, 1.0))
bool  isSqz     = bbBW < bbBWAvg * sqzPct
bool  sqzRelease = not isSqz and isSqz[1]

// 3. SMEMA Trend Baseline
//    Compare current vs 3-bars-ago slope to determine trend direction
float smemaSlow = smema(close, smemaLen)
float smemaFast = smema(close, math.max(int(smemaLen / 2), 3))
bool  trendUp   = smemaSlow > smemaSlow[3]
bool  trendDn   = smemaSlow < smemaSlow[3]

// 4. Directional Index + ADX (Pine Script v6 built-in)
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
bool isTrending = adxVal >= adxThresh
bool isBullDir  = diPlus  > diMinus
bool isBearDir  = diMinus > diPlus

// 5. RSI Momentum Bias
//    Above 52 = bullish bias, below 48 = bearish bias (small dead zone avoids noise)
float rsiVal = ta.rsi(close, rsiLen)
bool  rsiBull = rsiVal > 52.0
bool  rsiBear = rsiVal < 48.0

// ─── Regime Scoring Engine ────────────────────────────────────────────────────
// Bull and bear points scored independently, then net score determines regime
// Max per side: 2 (trend) + 2 (DI) + 1 (RSI) + 1 (vol expansion) = 6
int bullPts = (trendUp    ? 2 : 0) +
              (isBullDir  ? 2 : 0) +
              (rsiBull    ? 1 : 0) +
              ((volRatio > 1.1 and trendUp) ? 1 : 0)

int bearPts = (trendDn    ? 2 : 0) +
              (isBearDir  ? 2 : 0) +
              (rsiBear    ? 1 : 0) +
              ((volRatio > 1.1 and trendDn) ? 1 : 0)

int netScore = bullPts - bearPts

// Regime code: -2 Strong Bear → +2 Strong Bull (0 = neutral/ranging/squeeze)
// FIX: Pine Script v6 does not allow multi-line ternary with trailing ':' — collapsed to single line
int regCode = isSqz ? 0 : netScore >= 4 ? 2 : netScore >= 1 ? 1 : netScore <= -4 ? -2 : netScore <= -1 ? -1 : 0

string regStr = regCode == 2 ? "Strong Bull" : regCode == 1 ? "Weak Bull" : regCode == -1 ? "Weak Bear" : regCode == -2 ? "Strong Bear" : isSqz ? "Compression" : "Ranging"
color  regClr = regCode == 2 ? cSBull : regCode == 1 ? cWBull : regCode == -1 ? cWBear : regCode == -2 ? cSBear : isSqz ? cSqz : cRange

// Detect regime state change (confirmed bar, post-warmup)
bool regChanged = warmed and barstate.isconfirmed and (regCode != nz(regCode[1], 99))

// ─── Trend Strength Score (0–100) ─────────────────────────────────────────────
// distScore: how far price is from SMEMA baseline in ATR units (max 50)
// momScore:  RSI deviation from neutral 50 in trend direction (max 50)
float distSc = math.min(safeDiv(math.abs(close - smemaSlow),
    math.max(nz(atrRaw, 1.0), 1e-9)) * 20.0, 50.0)
float momRaw = regCode >= 1 ? math.max(rsiVal - 50.0, 0.0) :
               regCode <= -1 ? math.max(50.0 - rsiVal, 0.0) : 0.0
float momSc  = math.min(momRaw, 50.0)
int   strVal = int(math.min(distSc + momSc, 100.0))

string strLbl = strVal >= 70 ? "Strong" : strVal >= 40 ? "Moderate" : "Weak"
color  strClr = strVal >= 70 ? cSBull : strVal >= 40 ? #FFAB00 : cSBear

// ─── Visual Plots ─────────────────────────────────────────────────────────────
// Background tint — very subtle, just enough to convey regime state
bgcolor(showBg and warmed ? color.new(regClr, 94) : na, title="Regime Background")

// SMEMA ribbon — fast and slow baseline with gradient fill between them
pSmemaSlow = plot(showSmema ? smemaSlow : na, "SMEMA Slow",
    color=color.new(regClr, 20), linewidth=2)
pSmemaFast = plot(showSmema ? smemaFast : na, "SMEMA Fast",
    color=color.new(regClr, 60), linewidth=1)
fill(pSmemaSlow, pSmemaFast, color.new(regClr, 86), title="SMEMA Ribbon Fill")

// Candle coloring — regime-tinted, partially transparent
barcolor(warmed ? color.new(regClr, 40) : na)

// Squeeze markers on the SMEMA baseline
plotshape(showSqz and isSqz      and warmed ? smemaSlow : na,
    "Squeeze Active",  shape.circle,  location.absolute, color.new(cSqz, 30), size=size.tiny)
plotshape(showSqz and sqzRelease and warmed ? smemaSlow : na,
    "Squeeze Release", shape.diamond, location.absolute, cSqz, size=size.small)

// ─── Dashboard ────────────────────────────────────────────────────────────────
if showDash and barstate.islast
    var tbl = table.new(getDashPos(dashPosStr), 2, 10, TBL_BG, TBL_BD, 1, TBL_BD, 1)

    table.cell(tbl, 0, 0, "JOAT  |  Auric Regime",
        text_color=#FFFFFF, bgcolor=HDR_BG, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "Regime",    text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 1, regStr,      text_color=regClr, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 2, "Strength",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 2, str.tostring(strVal) + "  " + strLbl,
        text_color=strClr, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 3, "ADX",       text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 3, str.tostring(adxVal, "#.1") + (isTrending ? "  Trend" : "  Range"),
        text_color=isTrending ? cSBull : cRange, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 4, "+DI / -DI", text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 4, str.tostring(diPlus, "#.1") + " / " + str.tostring(diMinus, "#.1"),
        text_color=isBullDir ? cSBull : cSBear, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 5, "Vol Ratio", text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 5, str.tostring(volRatio, "#.##") + "x",
        text_color=volRatio > 1.2 ? cSBull : volRatio < 0.8 ? cSBear : TXT,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 6, "BB State",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 6, isSqz ? "Compressing" : "Expanded",
        text_color=isSqz ? cSqz : cSBull, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 7, "RSI",       text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 7, str.tostring(rsiVal, "#.1"),
        text_color=rsiVal >= 60 ? cSBull : rsiVal <= 40 ? cSBear : TXT,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 8, "Timeframe", text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 8, timeframe.period,
        text_color=TXT, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 9, "Version",   text_color=TXT_M, text_size=size.tiny,  bgcolor=TBL_BG)
    table.cell(tbl, 1, 9, INDICATOR_VERSION,
        text_color=TXT_M, text_size=size.tiny, bgcolor=TBL_BG)

// ─── Watermark ────────────────────────────────────────────────────────────────
if showWM and barstate.islast
    var wmT = table.new(position.bottom_center, 1, 1,
        bgcolor=color.new(color.black, 100), border_color=color.new(color.black, 100), border_width=0)
    table.cell(wmT, 0, 0, "JackOfAllTrades",
        text_color=WM_C, text_size=size.normal, text_halign=text.align_center,
        bgcolor=color.new(color.black, 100))

// ─── Alerts ───────────────────────────────────────────────────────────────────
string tkr   = syminfo.tickerid
string tf    = timeframe.period
string rTxt  = "ARC Regime: " + regStr + " | " + tkr + " | TF: " + tf + " | Strength: " + str.tostring(strVal)
string rJson = '{"event":"regime","regime":"' + regStr + '","ticker":"' + tkr + '","tf":"' + tf + '","strength":' + str.tostring(strVal) + '}'

if regChanged
    alert(webhookFmt ? rJson : rTxt, alert.freq_once_per_bar_close)

alertcondition(regCode ==  2 and warmed, "Strong Bull Regime",  "ARC: Strong Bull regime confirmed")
alertcondition(regCode == -2 and warmed, "Strong Bear Regime",  "ARC: Strong Bear regime confirmed")
alertcondition(isSqz        and warmed, "Volatility Squeeze",  "ARC: Bollinger compression active")
alertcondition(sqzRelease   and warmed, "Squeeze Release",     "ARC: Squeeze releasing — expansion imminent")
````
