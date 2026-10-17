# Supertrend - EMA Cloud - Divergence - ADX [StrixEDGE]

- url: https://www.tradingview.com/script/vyRcS826-Supertrend-EMA-Cloud-Divergence-ADX-StrixEDGE/
- type: indicator
- pine_id: PUB;4be203f5823b4a9e8f5a1034a08b714e
- version: 1.0

## Description

Overview

Apex Trend Engine is a 5-layer confluence system that combines trend-following, momentum, and reversal detection into a single overlay indicator. Each layer operates independently and feeds into a unified scoring engine that generates high-conviction BUY and SELL signals only when multiple confirmations align.

Layer 1 — Supertrend (Trend Direction)

An ATR-based adaptive trend filter that hugs price during trends and flips cleanly on reversals. The Supertrend line is plotted directly on the chart with a subtle fill between price and the stop level, making the current trend direction visible at a glance.

Bull & Bear SuperTrend : https://www.tradingview.com/x/dSJr8kCY/

Layer 2 — EMA Cloud (Momentum & Entries)

A fast/slow EMA pair (default 9/21) with a filled cloud between them. The cloud color shows momentum direction: green when fast EMA is above slow, red when below. Crossovers serve as entry triggers when confirmed by other layers.

Bull & Bear EMA : https://www.tradingview.com/x/UP5GOtjD/

Layer 3 — RSI Divergence Scanner (Reversals)

Automatic detection of regular bullish and bearish divergences between price and RSI using pivot-confirmed swing points. When price makes a lower low but RSI makes a higher low, a bullish divergence line is drawn on the chart. The reverse for bearish.

Bull Div. https://www.tradingview.com/x/6sltT2Am/
Bear Div. https://www.tradingview.com/x/fhi9s16G/

Layer 4 — ADX Trend Strength (Filter)

The Average Directional Index measures whether the market is trending or ranging. ADX above the threshold (default 25) confirms a trending market. The directional indicators (DI+ vs DI-) determine if the trend is bullish or bearish.

Bull & Bear ADX : https://www.tradingview.com/x/mNQ5ZPGA/

Layer 5 — Combined Signal Engine

Each layer contributes one point to a bull score and one to a bear score (5 points maximum each):

Point 1 — Supertrend direction
Point 2 — EMA fast/slow alignment
Point 3 — Price position relative to 200 EMA
Point 4 — Recent RSI divergence (within 20 bars)
Point 5 — ADX trending with directional confirmation

Signal generation requires both a score threshold AND a trigger event:

STRONG BUY — 4 or more bullish points with an EMA crossover or Supertrend flip
https://www.tradingview.com/x/k45HPlef/
BUY — 3 or more bullish points with a trigger
https://www.tradingview.com/x/cYSWdmC0/
STRONG SELL — 4 or more bearish points with a trigger https://www.tradingview.com/x/bIdQGB9n/
SELL — 3 or more bearish points with a trigger
https://www.tradingview.com/x/CUyG5rXk/

This dual requirement (score plus trigger) prevents signals from firing on every bar during a trend and limits them to actionable moments.

Chart visuals

Supertrend: colored line with transparent fill to price showing the trend zone
EMA Cloud: fast and slow EMA lines with filled cloud between them
EMA 200: gold line for macro trend reference
Divergence lines: green lines connecting bullish divergence pivots, red for bearish
Signal arrows: double arrows for strong signals, single triangles for regular
Background highlight: subtle bar coloring on strong signal bars

Dashboard table

The on-chart dashboard shows each layer's current reading:

Supertrend — stop level and direction
EMA Cross — values and cross status
EMA 200 — value and price position
RSI — value with overbought/oversold warnings
Divergence — type and how many bars ago
ADX — value with trending/ranging status
Score — X/5 BULL and X/5 BEAR
Signal — combined verdict

Settings

Every component is independently configurable with sensible defaults:

Supertrend: ATR length 10, multiplier 3.0
EMA Cloud: fast 9, slow 21, trend 200
RSI Divergence: length 14, pivot lookback 5
ADX: length 14, smoothing 14, trending threshold 25
Signals: buy/sell arrows and background highlights toggleable
Dashboard: position and text size adjustable

Alerts : 10 alert conditions covering every signal type:

Strong Buy, Buy, Strong Sell, Sell
Supertrend flip bullish/bearish
EMA cross up/down
Bullish/Bearish divergence detected

Disclaimer

This indicator is a technical analysis tool for educational and informational purposes. It does not constitute financial advice. Past performance does not guarantee future results. Always use proper risk management and never risk capital you cannot afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Supertrend - EMA Cloud - Divergence - ADX [StrixEDGE]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════
//  ▄▀▄ █▀█ █▀▀ ▀▄▀   ▀█▀ █▀▄ █▀▀ █▄ █ █▀▄   █▀▀ █▄ █ █▀▀ ▀█▀ █▄ █ █▀▀
//  █▀█ █▀▀ ██▄ █ █    █  █▀▄ ██▄ █ ▀█ █▄▀   ██▄ █ ▀█ █▄█  █  █ ▀█ ██▄
// ══════════════════════════════════════════════════════════════════════
//
//  5-layer confluence engine:
//  ① Supertrend — ATR-based adaptive trend filter
//  ② EMA Cloud — 9/21 cross with dynamic cloud fill
//  ③ RSI Divergence Scanner — auto-detects bullish/bearish reversals
//  ④ ADX Trend Strength — filters ranging vs trending markets
//  ⑤ Combined Signal — scores all layers for high-conviction entries
//
// ══════════════════════════════════════════════════════════════════════


// ┌─────────────────────────────────────────────────────────────────┐
// │                         INPUTS                                  │
// └─────────────────────────────────────────────────────────────────┘

// ── Supertrend ──────────────────────────────────────────────────────
var GRP_ST = "① Supertrend"
i_atrLen  = input.int(10, "ATR Length", minval = 1, group = GRP_ST)
i_atrMult = input.float(3.0, "ATR Multiplier", minval = 0.5, step = 0.1, group = GRP_ST,
     tooltip = "Higher = fewer signals but stronger trend filter. 2.0–3.0 is standard")
i_showST  = input.bool(true, "Show Supertrend Line", group = GRP_ST)

// ── EMA Cloud ───────────────────────────────────────────────────────
var GRP_EMA = "② EMA Cloud"
i_emaFast  = input.int(9, "Fast EMA", minval = 2, group = GRP_EMA)
i_emaSlow  = input.int(21, "Slow EMA", minval = 2, group = GRP_EMA)
i_ema200   = input.int(200, "Trend EMA", minval = 50, group = GRP_EMA,
     tooltip = "Long-term trend filter. Price above = bullish bias, below = bearish")
i_showEMA  = input.bool(true, "Show EMA Lines", group = GRP_EMA)
i_showCloud = input.bool(true, "Show Cloud Fill", group = GRP_EMA)

// ── RSI Divergence ──────────────────────────────────────────────────
var GRP_DIV = "③ RSI Divergence"
i_rsiLen   = input.int(14, "RSI Length", minval = 2, group = GRP_DIV)
i_pivotLen = input.int(5, "Pivot Lookback", minval = 2, maxval = 20, group = GRP_DIV,
     tooltip = "Bars left/right to confirm a swing high/low. Higher = fewer but stronger divergences")
i_showDiv  = input.bool(true, "Show Divergence Lines", group = GRP_DIV)
i_showDivLabels = input.bool(true, "Show Divergence Labels", group = GRP_DIV)

// ── ADX ─────────────────────────────────────────────────────────────
var GRP_ADX = "④ ADX Trend Strength"
i_adxLen    = input.int(14, "ADX Length", minval = 2, group = GRP_ADX)
i_adxSmooth = input.int(14, "ADX Smoothing", minval = 2, group = GRP_ADX)
i_adxThresh = input.int(25, "Trending Threshold", minval = 15, maxval = 50, group = GRP_ADX,
     tooltip = "ADX above this = trending market. Below = ranging / choppy")

// ── Signals ─────────────────────────────────────────────────────────
var GRP_SIG = "⑤ Signal Settings"
i_showSignals = input.bool(true, "Show Buy/Sell Arrows", group = GRP_SIG)
i_showBg      = input.bool(true, "Highlight Signal Bars", group = GRP_SIG)

// ── Table ───────────────────────────────────────────────────────────
var GRP_TBL = "📊 Dashboard"
i_showTable = input.bool(true, "Show Dashboard", group = GRP_TBL)
i_tblPos    = input.string("Top Right", "Position",
     options = ["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = GRP_TBL)
i_tblSize   = input.string("Small", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = GRP_TBL)


// ┌─────────────────────────────────────────────────────────────────┐
// │                    COLOR PALETTE                                │
// └─────────────────────────────────────────────────────────────────┘
var color C_BULL      = color.rgb(38, 166, 154)
var color C_BEAR      = color.rgb(239, 83, 80)
var color C_BULL_DIM  = color.rgb(38, 166, 154, 75)
var color C_BEAR_DIM  = color.rgb(239, 83, 80, 75)
var color C_BULL_BG   = color.rgb(38, 166, 154, 90)
var color C_BEAR_BG   = color.rgb(239, 83, 80, 90)
var color C_CLOUD_BUL = color.rgb(38, 166, 154, 85)
var color C_CLOUD_BER = color.rgb(239, 83, 80, 85)
var color C_NEUTRAL   = color.rgb(120, 123, 134)
var color C_EMA200    = color.rgb(255, 183, 77)
var color C_DIV_BULL  = color.rgb(0, 230, 118)
var color C_DIV_BEAR  = color.rgb(255, 82, 82)
var color C_TBL_BG    = color.rgb(8, 10, 18)
var color C_TBL_HDR   = color.rgb(16, 20, 32)
var color C_TBL_CELL  = color.rgb(24, 28, 42)
var color C_TBL_LBL   = color.rgb(20, 24, 38)
var color C_TBL_TXT   = color.rgb(185, 190, 205)
var color C_HDR_TXT   = color.rgb(140, 145, 160)
var color C_WHITE     = color.rgb(255, 255, 255)
var color C_ACCENT    = color.rgb(100, 120, 255)
var color C_BULL_CELL = color.rgb(20, 50, 38)
var color C_BEAR_CELL = color.rgb(55, 22, 22)
var color C_NEUT_CELL = color.rgb(35, 38, 50)
var color C_SIG_BUY   = color.rgb(0, 230, 118)
var color C_SIG_SELL  = color.rgb(255, 82, 82)


// ┌─────────────────────────────────────────────────────────────────┐
// │                    HELPER FUNCTIONS                              │
// └─────────────────────────────────────────────────────────────────┘
f_pos() =>
    switch i_tblPos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

f_size() =>
    switch i_tblSize
        "Tiny"  => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        =>         size.small

f_price(float p) =>
    na(p) ? "—" : p >= 10000 ? str.tostring(p, "#.##") : p >= 100 ? str.tostring(p, "#.###") : p >= 1 ? str.tostring(p, "#.####") : str.tostring(p, "#.######")


// ┌─────────────────────────────────────────────────────────────────┐
// │                  ① SUPERTREND                                   │
// └─────────────────────────────────────────────────────────────────┘
atrVal = ta.atr(i_atrLen)
float srcMid = (high + low) / 2.0

float upperBand = srcMid + i_atrMult * atrVal
float lowerBand = srcMid - i_atrMult * atrVal

var float stUp = na
var float stDn = na
var int   stDir = 1

prevUp = nz(stUp[1], lowerBand)
prevDn = nz(stDn[1], upperBand)

stUp := lowerBand > prevUp or close[1] < prevUp ? lowerBand : prevUp
stDn := upperBand < prevDn or close[1] > prevDn ? upperBand : prevDn

if close > prevDn
    stDir := 1
else if close < prevUp
    stDir := -1
else
    stDir := nz(stDir[1], 1)

float stValue = stDir == 1 ? stUp : stDn
bool  stBull  = stDir == 1
bool  stBear  = stDir == -1

// Supertrend direction change
bool stFlipBull = stBull and not stBull[1]
bool stFlipBear = stBear and not stBear[1]


// ┌─────────────────────────────────────────────────────────────────┐
// │                  ② EMA CLOUD                                    │
// └─────────────────────────────────────────────────────────────────┘
emaF   = ta.ema(close, i_emaFast)
emaS   = ta.ema(close, i_emaSlow)
ema200 = ta.ema(close, i_ema200)

bool emaBull    = emaF > emaS
bool emaBear    = emaF < emaS
bool emaCrossUp = ta.crossover(emaF, emaS)
bool emaCrossDn = ta.crossunder(emaF, emaS)
bool above200   = close > ema200
bool below200   = close < ema200


// ┌─────────────────────────────────────────────────────────────────┐
// │                  ③ RSI DIVERGENCE                               │
// └─────────────────────────────────────────────────────────────────┘
rsiVal = ta.rsi(close, i_rsiLen)

// Pivot detection (confirmed swings)
pivotHi    = ta.pivothigh(high, i_pivotLen, i_pivotLen)
pivotLo    = ta.pivotlow(low, i_pivotLen, i_pivotLen)
rsiPivotHi = ta.pivothigh(rsiVal, i_pivotLen, i_pivotLen)
rsiPivotLo = ta.pivotlow(rsiVal, i_pivotLen, i_pivotLen)

// Track previous and current pivot lows (for bullish divergence)
bool foundLo = not na(pivotLo)
float prevPriceLo = ta.valuewhen(foundLo, pivotLo, 1)
float currPriceLo = ta.valuewhen(foundLo, pivotLo, 0)
int   prevLoBar   = ta.valuewhen(foundLo, bar_index - i_pivotLen, 1)
int   currLoBar   = ta.valuewhen(foundLo, bar_index - i_pivotLen, 0)
float prevRsiLo   = ta.valuewhen(foundLo, rsiPivotLo, 1)
float currRsiLo   = ta.valuewhen(foundLo, rsiPivotLo, 0)

// Track previous and current pivot highs (for bearish divergence)
bool foundHi = not na(pivotHi)
float prevPriceHi = ta.valuewhen(foundHi, pivotHi, 1)
float currPriceHi = ta.valuewhen(foundHi, pivotHi, 0)
int   prevHiBar   = ta.valuewhen(foundHi, bar_index - i_pivotLen, 1)
int   currHiBar   = ta.valuewhen(foundHi, bar_index - i_pivotLen, 0)
float prevRsiHi   = ta.valuewhen(foundHi, rsiPivotHi, 1)
float currRsiHi   = ta.valuewhen(foundHi, rsiPivotHi, 0)

// Bullish divergence: price lower low + RSI higher low
bool bullDiv = foundLo and 
     not na(prevPriceLo) and not na(currRsiLo) and not na(prevRsiLo) and
     currPriceLo < prevPriceLo and 
     currRsiLo > prevRsiLo

// Bearish divergence: price higher high + RSI lower high
bool bearDiv = foundHi and 
     not na(prevPriceHi) and not na(currRsiHi) and not na(prevRsiHi) and
     currPriceHi > prevPriceHi and 
     currRsiHi < prevRsiHi

// Draw divergence lines on chart
if bullDiv and i_showDiv
    line.new(prevLoBar, prevPriceLo, currLoBar, currPriceLo, 
         color = C_DIV_BULL, width = 2, style = line.style_solid)
    if i_showDivLabels
        label.new(currLoBar, currPriceLo, "BULL DIV", 
             yloc = yloc.belowbar, style = label.style_label_up, 
             color = color.new(C_DIV_BULL, 30), textcolor = C_WHITE, size = size.tiny)

if bearDiv and i_showDiv
    line.new(prevHiBar, prevPriceHi, currHiBar, currPriceHi, 
         color = C_DIV_BEAR, width = 2, style = line.style_solid)
    if i_showDivLabels
        label.new(currHiBar, currPriceHi, "BEAR DIV", 
             yloc = yloc.abovebar, style = label.style_label_down, 
             color = color.new(C_DIV_BEAR, 30), textcolor = C_WHITE, size = size.tiny)

// Track most recent divergence type (for table)
var int lastDivType = 0  // 0 = none, 1 = bull, -1 = bear
var int lastDivBar  = 0
if bullDiv
    lastDivType := 1
    lastDivBar  := bar_index
if bearDiv
    lastDivType := -1
    lastDivBar  := bar_index

divAge    = bar_index - lastDivBar
divRecent = divAge <= 20  // consider "active" within 20 bars


// ┌─────────────────────────────────────────────────────────────────┐
// │                  ④ ADX TREND STRENGTH                           │
// └─────────────────────────────────────────────────────────────────┘
[diPlus, diMinus, adxVal] = ta.dmi(i_adxLen, i_adxSmooth)

bool isTrending = adxVal >= i_adxThresh
bool diPlusBull = diPlus > diMinus

// Trend strength score (0–100)
float trendScore = math.min(adxVal / 50.0 * 100, 100)
string trendLabel = trendScore >= 75 ? "VERY STRONG" : trendScore >= 50 ? "STRONG" : trendScore >= 25 ? "MODERATE" : "WEAK"


// ┌─────────────────────────────────────────────────────────────────┐
// │                  ⑤ COMBINED SIGNAL ENGINE                       │
// └─────────────────────────────────────────────────────────────────┘

// Bull score (0–5)
float bullScore = 0
bullScore += stBull                                     ? 1 : 0   // Supertrend bullish
bullScore += emaBull                                    ? 1 : 0   // EMA cross bullish
bullScore += above200                                   ? 1 : 0   // Above 200 EMA
bullScore += (divRecent and lastDivType == 1)           ? 1 : 0   // Recent bull divergence
bullScore += (isTrending and diPlusBull)                ? 1 : 0   // ADX trending + DI+ > DI-

// Bear score (0–5)
float bearScore = 0
bearScore += stBear                                     ? 1 : 0
bearScore += emaBear                                    ? 1 : 0
bearScore += below200                                   ? 1 : 0
bearScore += (divRecent and lastDivType == -1)          ? 1 : 0
bearScore += (isTrending and not diPlusBull)            ? 1 : 0

// Signal levels
bool strongBuy  = bullScore >= 4 and (emaCrossUp or stFlipBull)
bool buy        = bullScore >= 3 and (emaCrossUp or stFlipBull)
bool strongSell = bearScore >= 4 and (emaCrossDn or stFlipBear)
bool sell       = bearScore >= 3 and (emaCrossDn or stFlipBear)

// Overall bias
string bias = bullScore >= 4 ? "STRONG BULL" : bullScore >= 3 ? "BULLISH" : bearScore >= 4 ? "STRONG BEAR" : bearScore >= 3 ? "BEARISH" : "NEUTRAL"
color biasColor = bullScore >= 3 ? C_BULL : bearScore >= 3 ? C_BEAR : C_NEUTRAL


// ┌─────────────────────────────────────────────────────────────────┐
// │                    CHART PLOTS                                  │
// └─────────────────────────────────────────────────────────────────┘

// ── Supertrend ──────────────────────────────────────────────────────
stPlotColor = stBull ? C_BULL : C_BEAR
plot(i_showST ? stValue : na, "Supertrend", color = stPlotColor, linewidth = 2, style = plot.style_linebr)

// Supertrend fill to price
p_st    = plot(i_showST ? stValue : na, "ST Fill Base", display = display.none)
p_close = plot(i_showST ? close : na, "Close Fill Base", display = display.none)
fill(p_close, p_st, color = stBull ? C_BULL_BG : C_BEAR_BG, title = "Supertrend Fill")

// ── EMA Cloud ───────────────────────────────────────────────────────
p_emaF = plot(i_showEMA ? emaF : na, "EMA Fast", color = emaBull ? C_BULL : C_BEAR, linewidth = 1)
p_emaS = plot(i_showEMA ? emaS : na, "EMA Slow", color = emaBull ? C_BULL_DIM : C_BEAR_DIM, linewidth = 1)
plot(i_showEMA ? ema200 : na, "EMA 200", color = C_EMA200, linewidth = 2, style = plot.style_line)
fill(p_emaF, p_emaS, color = i_showCloud ? (emaBull ? C_CLOUD_BUL : C_CLOUD_BER) : na, title = "EMA Cloud")

// ── Signal Arrows ───────────────────────────────────────────────────
plotshape(i_showSignals and strongBuy, "Strong Buy", shape.labelup, location.belowbar, 
     color = C_SIG_BUY, text = "▲▲", textcolor = C_WHITE, size = size.small)
plotshape(i_showSignals and buy and not strongBuy, "Buy", shape.triangleup, location.belowbar, 
     color = color.new(C_SIG_BUY, 30), size = size.tiny)
plotshape(i_showSignals and strongSell, "Strong Sell", shape.labeldown, location.abovebar, 
     color = C_SIG_SELL, text = "▼▼", textcolor = C_WHITE, size = size.small)
plotshape(i_showSignals and sell and not strongSell, "Sell", shape.triangledown, location.abovebar, 
     color = color.new(C_SIG_SELL, 30), size = size.tiny)

// ── Signal bar background ───────────────────────────────────────────
bgcolor(i_showBg and strongBuy  ? color.new(C_SIG_BUY, 88)  : na, title = "Strong Buy BG")
bgcolor(i_showBg and strongSell ? color.new(C_SIG_SELL, 88) : na, title = "Strong Sell BG")


// ┌─────────────────────────────────────────────────────────────────┐
// │                  DASHBOARD TABLE                                │
// └─────────────────────────────────────────────────────────────────┘

if i_showTable and barstate.islast
    sz = f_size()
    
    var tbl = table.new(f_pos(), 3, 11,
         bgcolor = C_TBL_CELL, frame_width = 2, frame_color = C_TBL_BG,
         border_width = 1, border_color = C_TBL_BG)

    // Row 0 — Title
    tbl.cell(0, 0, "⚡  APEX TREND ENGINE StrixEDGE", text_color = C_ACCENT, bgcolor = C_TBL_BG, text_halign = text.align_center, text_size = sz)
    tbl.cell(1, 0, "", bgcolor = C_TBL_BG)
    tbl.cell(2, 0, syminfo.ticker, text_color = C_HDR_TXT, bgcolor = C_TBL_BG, text_halign = text.align_center, text_size = sz)
    tbl.merge_cells(0, 0, 1, 0)

    // Row 1 — Headers
    tbl.cell(0, 1, "LAYER", text_color = C_HDR_TXT, bgcolor = C_TBL_HDR, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 1, "VALUE", text_color = C_HDR_TXT, bgcolor = C_TBL_HDR, text_halign = text.align_center, text_size = sz)
    tbl.cell(2, 1, "STATUS", text_color = C_HDR_TXT, bgcolor = C_TBL_HDR, text_halign = text.align_center, text_size = sz)

    // Row 2 — Supertrend
    string stStatus = stBull ? "▲ BULLISH" : "▼ BEARISH"
    tbl.cell(0, 2, "SUPERTREND", text_color = C_TBL_TXT, bgcolor = C_TBL_LBL, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 2, f_price(stValue), text_color = stBull ? C_BULL : C_BEAR, bgcolor = C_TBL_CELL, text_halign = text.align_center, text_size = sz)
    tbl.cell(2, 2, stStatus, text_color = stBull ? C_BULL : C_BEAR, bgcolor = stBull ? C_BULL_CELL : C_BEAR_CELL, text_halign = text.align_center, text_size = sz)

    // Row 3 — EMA Cross
    string emaCrossStatus = emaCrossUp ? "✦ CROSS UP" : emaCrossDn ? "✦ CROSS DOWN" : emaBull ? "▲ BULL" : "▼ BEAR"
    color emaCrossColor = emaBull ? C_BULL : C_BEAR
    tbl.cell(0, 3, "EMA " + str.tostring(i_emaFast) + "/" + str.tostring(i_emaSlow), text_color = C_TBL_TXT, bgcolor = C_TBL_LBL, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 3, f_price(emaF) + " / " + f_price(emaS), text_color = emaCrossColor, bgcolor = C_TBL_CELL, text_halign = text.align_center, text_size = sz)
    tbl.cell(2, 3, emaCrossStatus, text_color = emaCrossColor, bgcolor = emaBull ? C_BULL_CELL : C_BEAR_CELL, text_halign = text.align_center, text_size = sz)

    // Row 4 — EMA 200
    string ema200Status = above200 ? "▲ ABOVE" : "▼ BELOW"
    tbl.cell(0, 4, "EMA " + str.tostring(i_ema200), text_color = C_TBL_TXT, bgcolor = C_TBL_LBL, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 4, f_price(ema200), text_color = C_EMA200, bgcolor = C_TBL_CELL, text_halign = text.align_center, text_size = sz)
    tbl.cell(2, 4, ema200Status, text_color = above200 ? C_BULL : C_BEAR, bgcolor = above200 ? C_BULL_CELL : C_BEAR_CELL, text_halign = text.align_center, text_size = sz)

    // Row 5 — RSI
    string rsiStatus = rsiVal > 70 ? "⚠ OVERBOUGHT" : rsiVal < 30 ? "⚠ OVERSOLD" : rsiVal > 50 ? "▲ BULL" : "▼ BEAR"
    color rsiColor = rsiVal > 50 ? C_BULL : C_BEAR
    tbl.cell(0, 5, "RSI (" + str.tostring(i_rsiLen) + ")", text_color = C_TBL_TXT, bgcolor = C_TBL_LBL, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 5, str.tostring(rsiVal, "#.#"), text_color = rsiColor, bgcolor = C_TBL_CELL, text_halign = text.align_center, text_size = sz)
    tbl.cell(2, 5, rsiStatus, text_color = rsiColor, bgcolor = rsiVal > 50 ? C_BULL_CELL : C_BEAR_CELL, text_halign = text.align_center, text_size = sz)

    // Row 6 — Divergence
    string divStatus = not divRecent ? "— NONE" : lastDivType == 1 ? "✦ BULL DIV" : "✦ BEAR DIV"
    color divColor = not divRecent ? C_NEUTRAL : lastDivType == 1 ? C_DIV_BULL : C_DIV_BEAR
    string divAgeStr = divRecent ? str.tostring(divAge) + " bars ago" : "—"
    tbl.cell(0, 6, "DIVERGENCE", text_color = C_TBL_TXT, bgcolor = C_TBL_LBL, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 6, divAgeStr, text_color = divColor, bgcolor = C_TBL_CELL, text_halign = text.align_center, text_size = sz)
    tbl.cell(2, 6, divStatus, text_color = divColor, bgcolor = not divRecent ? C_NEUT_CELL : lastDivType == 1 ? C_BULL_CELL : C_BEAR_CELL, text_halign = text.align_center, text_size = sz)

    // Row 7 — ADX
    string adxStatus = not isTrending ? "— RANGING" : diPlusBull ? "▲ TREND UP" : "▼ TREND DN"
    color adxColor = not isTrending ? C_NEUTRAL : diPlusBull ? C_BULL : C_BEAR
    tbl.cell(0, 7, "ADX (" + str.tostring(i_adxLen) + ")", text_color = C_TBL_TXT, bgcolor = C_TBL_LBL, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 7, str.tostring(adxVal, "#.#"), text_color = adxColor, bgcolor = C_TBL_CELL, text_halign = text.align_center, text_size = sz)
    tbl.cell(2, 7, adxStatus, text_color = adxColor, bgcolor = not isTrending ? C_NEUT_CELL : diPlusBull ? C_BULL_CELL : C_BEAR_CELL, text_halign = text.align_center, text_size = sz)

    // Row 8 — Separator
    tbl.cell(0, 8, "", bgcolor = C_TBL_BG, text_size = size.tiny)
    tbl.cell(1, 8, "", bgcolor = C_TBL_BG, text_size = size.tiny)
    tbl.cell(2, 8, "", bgcolor = C_TBL_BG, text_size = size.tiny)

    // Row 9 — Score
    string scoreStr = str.tostring(bullScore, "#") + "/5 BULL  •  " + str.tostring(bearScore, "#") + "/5 BEAR"
    color scoreColor = bullScore > bearScore ? C_BULL : bearScore > bullScore ? C_BEAR : C_NEUTRAL
    tbl.cell(0, 9, "SCORE", text_color = C_TBL_TXT, bgcolor = C_TBL_LBL, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 9, scoreStr, text_color = scoreColor, bgcolor = C_TBL_CELL, text_halign = text.align_center, text_size = sz)
    tbl.merge_cells(1, 9, 2, 9)

    // Row 10 — Signal
    string sigStr = strongBuy ? "STRONG BUY  ▲▲" : buy ? "BUY  ▲" : strongSell ? "STRONG SELL  ▼▼" : sell ? "SELL  ▼" : bias
    color sigBg = strongBuy or buy ? C_SIG_BUY : strongSell or sell ? C_SIG_SELL : C_NEUT_CELL
    color sigTxt = strongBuy or strongSell or buy or sell ? C_WHITE : C_NEUTRAL
    tbl.cell(0, 10, "🎯 SIGNAL", text_color = C_WHITE, bgcolor = C_TBL_BG, text_halign = text.align_left, text_size = sz)
    tbl.cell(1, 10, sigStr, text_color = sigTxt, bgcolor = sigBg, text_halign = text.align_center, text_size = sz)
    tbl.merge_cells(1, 10, 2, 10)


// ┌─────────────────────────────────────────────────────────────────┐
// │                        ALERTS                                   │
// └─────────────────────────────────────────────────────────────────┘
alertcondition(strongBuy,  "Strong Buy",  "Apex Engine: STRONG BUY — 4+ layers bullish with trigger")
alertcondition(buy,        "Buy",         "Apex Engine: BUY — 3+ layers bullish with trigger")
alertcondition(strongSell, "Strong Sell", "Apex Engine: STRONG SELL — 4+ layers bearish with trigger")
alertcondition(sell,       "Sell",        "Apex Engine: SELL — 3+ layers bearish with trigger")
alertcondition(stFlipBull, "ST Flip Bull", "Apex Engine: Supertrend flipped BULLISH")
alertcondition(stFlipBear, "ST Flip Bear", "Apex Engine: Supertrend flipped BEARISH")
alertcondition(emaCrossUp, "EMA Cross Up", "Apex Engine: Fast EMA crossed above Slow EMA")
alertcondition(emaCrossDn, "EMA Cross Dn", "Apex Engine: Fast EMA crossed below Slow EMA")
alertcondition(bullDiv,    "Bull Divergence", "Apex Engine: Bullish RSI divergence detected")
alertcondition(bearDiv,    "Bear Divergence", "Apex Engine: Bearish RSI divergence detected")

// ══════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ══════════════════════════════════════════════════════════════════════
````
