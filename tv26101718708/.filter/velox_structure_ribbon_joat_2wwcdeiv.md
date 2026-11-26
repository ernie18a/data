# Velox Structure Ribbon [JOAT]

- url: https://www.tradingview.com/script/2WwCDeIv-Velox-Structure-Ribbon-JOAT/
- type: indicator
- pine_id: PUB;87080f5aa7c54053bd6bf5a130165607
- version: 1.0

## Description

[b]Velox Structure Ribbon [JOAT][/b]

[b]Introduction[/b]

Velox Structure Ribbon (VSR) is an open-source multi-band trend structure ribbon that uses a volatility-normalized, dynamically-spaced band system to visualize how far price has extended from its trend baseline and in which direction. The ribbon is anchored by a dual SMEMA core — a fast and slow double-smoothed moving average — and radiates six equidistant bands above and below the baseline, with spacing determined by the smoothed average candle range. Each band that price has penetrated adds one point to a 0-3 bull or bear structure score. A 0-100 composite trend strength score combines band penetration with RSI momentum. Volume confirmation and RSI filters are available to sharpen signal quality.

The problem VSR solves is that standard envelopes and Bollinger Bands use fixed or volatility-scaled offsets that can cluster bands too tightly in low-volatility environments and spread them too far in high-volatility ones. VSR normalizes band spacing using the market's own smoothed candle range, meaning band width automatically contracts in quiet markets and expands in active ones. This keeps the structure score meaningful across all conditions: three bands penetrated in a quiet market represents the same degree of extension relative to current volatility as three bands penetrated in a volatile market.

[image]https://www.tradingview.com/x/mqrXBlW7/[/image]

[b]Core Concepts[/b]

[b]1. SMEMA Ribbon Core[/b]

The ribbon center uses two SMEMA lines — slow (full period, default 20) and fast (half period). The slow SMEMA defines trend direction: sloping upward means the trend is bullish, downward means bearish. The fill between fast and slow creates a visual ribbon that contracts during consolidation and expands during trends:

[pine]
float smemaSlow = smema(close, smemaLen)
float smemaFast = smema(close, math.max(int(smemaLen / 2), 3))
bool  trendUp   = smemaSlow > smemaSlow[1]
bool  trendDn   = smemaSlow < smemaSlow[1]
[/pine]

[b]2. Volatility-Normalized Band Spacing[/b]

The step unit for band placement is SMEMA applied to the high-low range over a long smoothing period (default 100 bars). This produces an adaptive measure of the average candle body size. Each of the six bands is placed at integer multiples of this step above and below the slow SMEMA:

[pine]
float step = smema(high - low, stepSmooth)
float up1  = smemaSlow + step * 1
float up2  = smemaSlow + step * 2
float up3  = smemaSlow + step * 3
[/pine]

Because the step automatically adjusts to market volatility, the bands always represent meaningful structural extensions rather than arbitrary percentage offsets.

[b]3. Bull and Bear Structure Scoring[/b]

Each bar, the indicator counts how many upper bands price has broken through (bullish penetration) and how many lower bands (bearish penetration). Each penetrated band adds one point to the respective score:

[pine]
int bullStr = (above1 ? 1 : 0) + (above2 ? 1 : 0) + (above3 ? 1 : 0)
int bearStr = (below1 ? 1 : 0) + (below2 ? 1 : 0) + (below3 ? 1 : 0)
[/pine]

A score of 0 means price is between the baseline and first band — neutral zone. Score of 1 means first structural extension. Score of 3 means full breakout beyond all three bands in that direction.

[b]4. Composite Trend Strength Score (0-100)[/b]

The strength score combines two inputs: the band penetration score converted to a 0-50 scale (each band = 16.7 points) and the RSI deviation from 50 on a 0-50 scale. The combination rewards moves that have both structural extension (price has pushed through multiple bands) and momentum confirmation (RSI is moving away from neutral):

[pine]
float bandScore = math.min(float(math.max(bullStr, bearStr)) * 16.7, 50.0)
float rsiScore  = math.min(math.abs(rsiVal - 50.0), 50.0)
int   strScore  = int(math.min(bandScore + rsiScore, 100.0))
[/pine]

[b]5. Distance-Based Band Coloring[/b]

Each band receives a gradient color whose intensity scales with how far price is from that band relative to its historical range. Bands that price has recently broken through or is pressing against are rendered more vividly. Bands far from price are nearly transparent. This creates a visual heat-map effect showing where structural tension exists:

[pine]
bandColor(float src, color col) =>
    float dist    = math.abs(close - src)
    float pctNorm = ta.percentile_linear_interpolation(dist, 400, 100)
    float colSize = pctNorm > 0 ? dist / pctNorm : 0.0
    showBands ? color.from_gradient(colSize, 0, 0.5, color(na), col) : color(na)
[/pine]

[b]Features[/b]

[list]
[*][b]Six-Band Structure Grid:[/b] Three bands above and three below the slow SMEMA baseline, dynamically spaced by the smoothed candle range
[*][b]Dual SMEMA Core Ribbon:[/b] Fast and slow baseline with gradient fill, colored by trend direction
[*][b]Trend Direction Diamond:[/b] A small diamond marker on the baseline at every trend flip (when the slow SMEMA changes slope direction)
[*][b]Bull / Bear Structure Score (0-3):[/b] Real-time count of penetrated upper or lower bands displayed in signal labels and the dashboard
[*][b]Composite Strength Score (0-100):[/b] Combined band penetration and RSI momentum score with Strong/Moderate/Weak label
[*][b]RSI Momentum Filter:[/b] Optional filter requiring RSI alignment before a signal is confirmed (configurable threshold, default 52)
[*][b]Volume Filter:[/b] Optional filter requiring above-average volume (configurable multiplier, default 1.1x the 20-bar SMA). Auto-disables on volume-free instruments
[*][b]Signal Labels:[/b] Small numeric labels at bull and bear signal bars showing the structure score (1, 2, or 3)
[*][b]Strength Bar (Bottom Right):[/b] A visual bar table showing filled cells proportional to the current bull or bear structure score
[*][b]Candle Coloring:[/b] Bar colors reflect trend direction at reduced opacity
[*][b]9-Row Dashboard (Top Right):[/b] Trend direction, last signal and bars-since count, strength score with label, bull and bear band counts, RSI value, timeframe, and version
[*][b]Watermark:[/b] JackOfAllTrades signature at chart center-bottom
[*][b]Alerts:[/b] Bull signal, bear signal, and trend-flip alertconditions with optional JSON webhook format
[/list]

[b]Input Parameters[/b]

[b]Ribbon Engine:[/b]
[list]
[*]SMEMA Length: Core period for the slow baseline (default: 20). Fast = L/2
[*]Step Smoothing: SMA period for the candle-range volatility step (default: 100)
[/list]

[b]Filters:[/b]
[list]
[*]RSI Length: Momentum confirmation period (default: 14)
[*]RSI Threshold: Minimum RSI for bull signal confirmation (default: 52). Bear mirror = 100 - threshold
[*]Volume Filter: Enable/disable volume confirmation (default: off)
[*]Volume Multiplier: Required volume multiple of the 20-bar SMA (default: 1.1)
[/list]

[b]Visuals / Dashboard:[/b]
[list]
[*]Theme: Auto, Dark, or Light
[*]Show Distance Bands: Toggle the six structural bands
[*]Show Core Ribbon: Toggle the fast/slow SMEMA ribbon and fill
[*]Show Signals: Toggle the numeric signal labels
[*]Show Strength Bar: Toggle the bottom-right score visualization
[*]Show Dashboard: Toggle the 9-row information panel
[*]Color Palette: Bull, Bear, and Neutral colors are individually customizable
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read Trend Direction from the Ribbon[/b]
When the ribbon is green and sloping upward, the baseline trend is bullish. When red and sloping downward, bearish. A flat ribbon in neutral color indicates a non-trending market.

[b]Step 2: Use Structure Score for Entry Timing[/b]
A bull signal fires when price is above the first upper band (score 1+) and the trend slope is upward with RSI and volume confirmation. A score of 2 or 3 indicates deeper structural extension — potentially overextended for entry, better for trailing a position.

[b]Step 3: Watch for Pullbacks to the Ribbon[/b]
After a bull signal, price often pulls back toward the ribbon (slow SMEMA) before continuing. Entries from the ribbon during an active bull structure are higher-probability than chasing at the outer bands.

[b]Step 4: Scale Position with Strength Score[/b]
A strength score above 70 (labeled Strong) indicates both structural extension and momentum alignment — use for higher conviction. Below 40 (Weak) may indicate a fading move or early-stage structure not worth full position sizing.

[image]https://www.tradingview.com/x/4cE1vLPM/[/image]

[b]Indicator Limitations[/b]

[list]
[*]The warmup period (SMEMA length x3 or step smoothing + 50, whichever is larger) means the indicator is inactive for the first several dozen bars on any chart
[*]The band spacing adapts to the smoothed candle range with a 100-bar lookback. On instruments with sharp volatility regime changes, the bands may lag behind the new volatility environment for many bars
[*]The volume filter is automatically disabled when volume data is unavailable (e.g., indices, some forex pairs). In those cases, volume confirmation is effectively always true regardless of the toggle setting
[*]Signal labels fire on every bull or bear structure bar — this can be frequent in strongly trending markets. The labels are informational, not entry triggers, and users should apply their own discretion for entry timing
[/list]

[b]Originality Statement[/b]

VSR is original in its use of the SMEMA-smoothed candle range as the band spacing unit. This indicator is published because:

[list]
[*]The volatility-normalized step unit (SMEMA of high-low range) is a unique approach to band spacing that differs from standard ATR envelopes, Bollinger Bands (which use standard deviation), and Keltner Channels (which use raw ATR). The SMEMA smoothing produces a more stable, noise-resistant step unit than raw ATR
[*]The 0-3 integer band-penetration scoring is a discrete structural measure that complements continuous oscillators. It quantifies how far price has extended structurally rather than how fast it has moved
[*]The distance-based gradient coloring using percentile normalization creates an adaptive visual heat-map — the same visual logic is computationally novel within the band-coloring approach
[*]The composite strength score combining band penetration with RSI deviation creates a measure that rewards both structural extension and momentum alignment simultaneously
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Band structure scores are based on historical price position relative to smoothed averages and do not predict future price movement. A score of 3 (maximum bullish extension) can increase further or reverse immediately. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(
    title            = "Velox Structure Ribbon [JOAT]",
    shorttitle       = "VSR [JOAT]",
    overlay          = true,
    max_lines_count  = 500,
    max_labels_count = 500)

// ─── Groups ───────────────────────────────────────────────────────────────────
G_CORE  = "Ribbon Engine"
G_FILT  = "Filters"
G_VIS   = "Visual Settings"
G_DASH  = "Dashboard"
G_ALERT = "Alerts"
G_COL   = "Color Palette"

INDICATOR_VERSION = "v1.0.0"

// ─── Inputs ───────────────────────────────────────────────────────────────────
smemaLen    = input.int(20,    "SMEMA Length",          minval=3,   maxval=100, group=G_CORE,
    tooltip="Core period for sma(ema(close,L),L) — the ribbon baseline.\nFast = L/2, Slow = L")
stepSmooth  = input.int(100,   "Step Smoothing",        minval=20,  maxval=300, group=G_CORE,
    tooltip="SMA period for smema(high-low) — defines the volatility step unit for bands")
rsiLen      = input.int(14,    "RSI Length",            minval=2,   maxval=50,  group=G_FILT)
rsiThresh   = input.float(52.0,"RSI Threshold",         minval=45.0,maxval=60.0,step=1.0, group=G_FILT,
    tooltip="RSI above this = bullish momentum confirmation. Bearish = 100 - threshold")
useVol      = input.bool(false, "Volume Filter",        group=G_FILT,
    tooltip="Require above-average volume for signal confirmation. Auto-disabled on no-volume assets")
volMult     = input.float(1.1, "Volume Multiplier",     minval=0.5, maxval=3.0, step=0.1, group=G_FILT)
themeStr    = input.string("Auto","Theme", options=["Auto","Dark","Light"], group=G_VIS)
showBands   = input.bool(true,  "Show Distance Bands",  group=G_VIS)
showRibbon  = input.bool(true,  "Show Core Ribbon",     group=G_VIS)
showSigs    = input.bool(true,  "Show Signals",         group=G_VIS)
showStrBar  = input.bool(true,  "Show Strength Bar",    group=G_DASH)
showDash    = input.bool(true,  "Show Dashboard",       group=G_DASH)
dashPosStr  = input.string("Top Right","Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
showWM      = input.bool(true,  "Show Watermark",       group=G_VIS)
webhookFmt  = input.bool(false, "Webhook JSON",         group=G_ALERT)
cBull       = input.color(#00C853, "Bull",  inline="c1", group=G_COL)
cBear       = input.color(#D50000, "Bear",  inline="c1", group=G_COL)
cNeutral    = input.color(#546E7A, "Neutral/Mid", inline="c2", group=G_COL)

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

// ─── Utility ──────────────────────────────────────────────────────────────────
safeDiv(float n, float d, float fb = 0.0) =>
    d != 0.0 and not na(n) and not na(d) ? n / d : fb

smema(float src, int len) => ta.sma(ta.ema(src, len), len)

getDashPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.top_right

// ─── Warmup ───────────────────────────────────────────────────────────────────
int  WARMUP = math.max(smemaLen * 3, stepSmooth + 50)
bool warmed = bar_index >= WARMUP

// ─── Core Calculations ────────────────────────────────────────────────────────

// Slow and fast SMEMA — the ribbon anchor lines
float smemaSlow = smema(close, smemaLen)
float smemaFast = smema(close, math.max(int(smemaLen / 2), 3))

// Baseline trend direction
bool trendUp  = smemaSlow > smemaSlow[1]
bool trendDn  = smemaSlow < smemaSlow[1]

// Volatility step unit: smoothed average candle range
// This normalizes the band spacing to market volatility — bands adapt automatically
float step = smema(high - low, stepSmooth)

// Six equidistant bands above and below the slow baseline
float up1 = smemaSlow + step * 1
float up2 = smemaSlow + step * 2
float up3 = smemaSlow + step * 3
float dn1 = smemaSlow - step * 1
float dn2 = smemaSlow - step * 2
float dn3 = smemaSlow - step * 3

// Bull/Bear band penetration scoring (0–3 each)
// Each band above/below that price has breached adds one point
bool above1 = close > up1
bool above2 = close > up2
bool above3 = close > up3
bool below1 = close < dn1
bool below2 = close < dn2
bool below3 = close < dn3

int bullStr = (above1 ? 1 : 0) + (above2 ? 1 : 0) + (above3 ? 1 : 0)
int bearStr = (below1 ? 1 : 0) + (below2 ? 1 : 0) + (below3 ? 1 : 0)

// Signal classification
// +1 = bullish context (above baseline, in upper bands)
// -1 = bearish context (below baseline, in lower bands)
//  0 = neutral (between baseline and first band)
int sigCode = trendUp and bullStr >= 1 ? 1 : not trendUp and bearStr >= 1 ? -1 : 0

// RSI momentum confirmation
float rsiVal  = ta.rsi(close, rsiLen)
bool  rsiBull = rsiVal >= rsiThresh
bool  rsiBear = rsiVal <= (100.0 - rsiThresh)

// Volume filter
bool hasVol   = nz(volume, 0) > 0
float volSma  = useVol and hasVol ? nz(ta.sma(volume, 20), 0.0) : 0.0
bool  volOk   = not useVol or not hasVol or volume > volSma * volMult

// Trend filter: momentum must align with structure signal
bool momentumOk = sigCode == 1 ? rsiBull : sigCode == -1 ? rsiBear : true

// Confirmed signal: structure + momentum + volume + warmup + bar close
bool bullSig = barstate.isconfirmed and warmed and sigCode == 1 and momentumOk and volOk
bool bearSig = barstate.isconfirmed and warmed and sigCode == -1 and momentumOk and volOk

// Track for dashboard (signal persistence across bars)
var string lastSig   = "—"
var int    barsSince = 0
barsSince := barsSince + 1
if bullSig
    lastSig   := "Bull"
    barsSince := 0
if bearSig
    lastSig   := "Bear"
    barsSince := 0

// ─── Composite Trend Strength (0–100) ─────────────────────────────────────────
// Band penetration score: each of the 3 bands = ~16.7 points = max 50
float bandScore = math.min(float(math.max(bullStr, bearStr)) * 16.7, 50.0)
// RSI momentum score: deviation from 50, max 50
float rsiDev    = sigCode >= 1 ? math.max(rsiVal - 50.0, 0.0) : math.max(50.0 - rsiVal, 0.0)
float rsiScore  = math.min(rsiDev, 50.0)
int   strScore  = int(math.min(bandScore + rsiScore, 100.0))
string strLbl   = strScore >= 70 ? "Strong" : strScore >= 40 ? "Moderate" : "Weak"

// ─── Distance-Based Band Coloring ─────────────────────────────────────────────
// The further price is from the band, the more vivid the color
// Uses percentile normalization over 400 bars — avoids saturation in trending markets
bandColor(float src, color col) =>
    float dist    = math.abs(close - src)
    float pctNorm = ta.percentile_linear_interpolation(dist, 400, 100)
    float colSize = pctNorm > 0 ? dist / pctNorm : 0.0
    showBands ? color.from_gradient(colSize, 0, 0.5, color(na), col) : color(na)

// Band colors based on position and trend context
color cu1 = bandColor(up1, close > up1 and trendUp ? cBull : close < up1 and not trendUp ? cBear : color(na))
color cu2 = bandColor(up2, close > up2 and trendUp ? cBull : close < up2 and not trendUp ? cBear : color(na))
color cu3 = bandColor(up3, close > up3 and trendUp ? cBull : close < up3 and not trendUp ? cBear : color(na))
color cd1 = bandColor(dn1, close < dn1 and not trendUp ? cBear : close > dn1 and trendUp ? cBull : color(na))
color cd2 = bandColor(dn2, close < dn2 and not trendUp ? cBear : close > dn2 and trendUp ? cBull : color(na))
color cd3 = bandColor(dn3, close < dn3 and not trendUp ? cBear : close > dn3 and trendUp ? cBull : color(na))

// Ribbon center color
color midClr = trendUp ? cBull : trendDn ? cBear : cNeutral

// ─── Plot Bands ───────────────────────────────────────────────────────────────
plot(up3, "Upper Band 3", color=cu3, editable=false)
plot(up2, "Upper Band 2", color=cu2, editable=false)
plot(up1, "Upper Band 1", color=cu1, editable=false)

// Core ribbon plots — fast and slow SMEMA
pSlow = plot(showRibbon ? smemaSlow : na, "SMEMA Slow",
    color=color.new(midClr, 20), linewidth=2)
pFast = plot(showRibbon ? smemaFast : na, "SMEMA Fast",
    color=color.new(midClr, 60), linewidth=1)
fill(pSlow, pFast, color.new(midClr, 82), title="Ribbon Fill")

plot(dn1, "Lower Band 1", color=cd1, editable=false)
plot(dn2, "Lower Band 2", color=cd2, editable=false)
plot(dn3, "Lower Band 3", color=cd3, editable=false)

// Trend change diamond marker on baseline
plotshape(warmed and trendUp != trendUp[1] ? smemaSlow[1] : na,
    "Trend Flip", shape.diamond, location.absolute, chart.fg_color, offset=-1, size=size.tiny)

// Candle coloring
barcolor(warmed ? color.new(midClr, 40) : na)

// Signal labels
if showSigs
    if bullSig
        label.new(bar_index, low, str.tostring(bullStr),
            style=label.style_label_up, color=color(na), size=size.tiny, textcolor=cBull)
    if bearSig
        label.new(bar_index, high, str.tostring(bearStr),
            style=label.style_label_down, color=color(na), size=size.tiny, textcolor=cBear)

// ─── Strength Bar Table (ChartPrime style) ────────────────────────────────────
// Horizontal bar of cells filling from left based on bull or bear strength score
if showStrBar and barstate.islast
    var sTbl = table.new(position.bottom_right, 6, 3, color.new(color.black, 100))
    table.cell(sTbl, 0, 0, "Bull Str", text_color=TXT_M, text_size=size.tiny)
    table.cell(sTbl, 0, 1, "Bear Str", text_color=TXT_M, text_size=size.tiny)
    for i = 0 to 3
        table.cell(sTbl, 1 + i, 0, "")
        table.cell(sTbl, 1 + i, 1, "")
    if bullStr >= 0
        for i = 0 to bullStr
            table.cell(sTbl, 1 + i, 0, i == bullStr ? str.tostring(bullStr) : "",
                bgcolor=color.new(cBull, 80 - i * 25), text_color=TXT)
    if bearStr >= 0
        for i = 0 to bearStr
            table.cell(sTbl, 1 + i, 1, i == bearStr ? str.tostring(bearStr) : "",
                bgcolor=color.new(cBear, 80 - i * 25), text_color=TXT)

// ─── Dashboard ────────────────────────────────────────────────────────────────
if showDash and barstate.islast
    var tbl = table.new(getDashPos(dashPosStr), 2, 9, TBL_BG, TBL_BD, 1, TBL_BD, 1)

    table.cell(tbl, 0, 0, "JOAT  |  Velox Ribbon",
        text_color=#FFFFFF, bgcolor=HDR_BG, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "Trend",      text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 1, trendUp ? "Bullish" : trendDn ? "Bearish" : "Flat",
        text_color=trendUp ? cBull : trendDn ? cBear : cNeutral, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 2, "Signal",     text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 2, lastSig + (barsSince > 0 ? "  (" + str.tostring(barsSince) + " bars)" : ""),
        text_color=lastSig == "Bull" ? cBull : lastSig == "Bear" ? cBear : TXT_M,
        text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 3, "Strength",   text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 3, str.tostring(strScore) + "  " + strLbl,
        text_color=strScore >= 70 ? cBull : strScore >= 40 ? #FFAB00 : cBear,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 4, "Bull Bands", text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 4, str.tostring(bullStr) + " / 3",
        text_color=bullStr >= 2 ? cBull : bullStr >= 1 ? #FFAB00 : TXT_M,
        text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 5, "Bear Bands", text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 5, str.tostring(bearStr) + " / 3",
        text_color=bearStr >= 2 ? cBear : bearStr >= 1 ? #FFAB00 : TXT_M,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 6, "RSI",        text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 6, str.tostring(rsiVal, "#.1"),
        text_color=rsiVal >= 60 ? cBull : rsiVal <= 40 ? cBear : TXT,
        text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 7, "Timeframe",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 7, timeframe.period, text_color=TXT, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 8, "Version",    text_color=TXT_M, text_size=size.tiny,  bgcolor=TBL_ALT)
    table.cell(tbl, 1, 8, INDICATOR_VERSION, text_color=TXT_M, text_size=size.tiny, bgcolor=TBL_ALT)

// ─── Watermark ────────────────────────────────────────────────────────────────
if showWM and barstate.islast
    var wmT = table.new(position.bottom_center, 1, 1,
        bgcolor=color.new(color.black, 100), border_color=color.new(color.black, 100), border_width=0)
    table.cell(wmT, 0, 0, "JackOfAllTrades",
        text_color=WM_C, text_size=size.normal, text_halign=text.align_center,
        bgcolor=color.new(color.black, 100))

// ─── Alerts ───────────────────────────────────────────────────────────────────
string tkr  = syminfo.tickerid
string tf   = timeframe.period
string pxS  = str.tostring(close, format.mintick)
string bTxt = "VSR Bull Signal | Strength: " + str.tostring(bullStr) + "/3 | " + tkr + " | TF: " + tf + " | " + pxS
string sTxt = "VSR Bear Signal | Strength: " + str.tostring(bearStr) + "/3 | " + tkr + " | TF: " + tf + " | " + pxS
string bJsn = '{"event":"bull","strength":' + str.tostring(bullStr) + ',"ticker":"' + tkr + '","tf":"' + tf + '","price":' + pxS + '}'
string sJsn = '{"event":"bear","strength":' + str.tostring(bearStr) + ',"ticker":"' + tkr + '","tf":"' + tf + '","price":' + pxS + '}'

if bullSig
    alert(webhookFmt ? bJsn : bTxt, alert.freq_once_per_bar_close)
if bearSig
    alert(webhookFmt ? sJsn : sTxt, alert.freq_once_per_bar_close)

alertcondition(bullSig, "VSR Bull Signal", "Velox Structure Ribbon: Bullish structure signal")
alertcondition(bearSig, "VSR Bear Signal", "Velox Structure Ribbon: Bearish structure signal")
alertcondition(trendUp != trendUp[1] and warmed, "VSR Trend Flip", "Velox Structure Ribbon: Trend direction changed")
````
