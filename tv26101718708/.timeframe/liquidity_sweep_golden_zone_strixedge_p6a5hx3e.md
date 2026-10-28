# Liquidity Sweep & Golden Zone [StrixEDGE]

- url: https://www.tradingview.com/script/P6A5hX3E-Liquidity-Sweep-Golden-Zone-StrixEDGE/
- type: indicator
- pine_id: PUB;3d4d2d06b9ad440b90422bdcf2af7a36
- version: 1.0

## Description

Overview

Liquidity Sweep & Golden Zone [MTF Heatmap] is a multi-timeframe structural analysis tool built for traders who use Smart Money Concepts (SMC) and ICT methodology. It identifies liquidity sweeps at confirmed swing levels, maps the Fibonacci Golden Zone (OTE), and presents a real-time confluence dashboard across 15-minute, 1-hour, 4-hour, and daily timeframes.

The indicator answers three questions at a glance: where is the liquidity?, has it been swept?, and do multiple timeframes agree on direction?

How It Works

Liquidity Sweep Detection

The engine tracks confirmed swing highs and swing lows using pivot detection. These pivots represent resting liquidity pools — areas where stop-loss orders accumulate:

- Buy-Side Liquidity (BSL) sits above swing highs, where short sellers place their stops. When price wicks above a swing high and closes back below, a BSL sweep is triggered — signaling that buy-side stops were hunted. This typically precedes bearish continuation.

https://www.tradingview.com/x/LwHCYZTh/

- Sell-Side Liquidity (SSL) sits below swing lows, where long traders place their stops. When price wicks below a swing low and closes back above, an SSL sweep is triggered — signaling that sell-side stops were hunted. This typically precedes bullish reversal.

https://www.tradingview.com/x/nNs0xUHQ/

Each sweep event displays the estimated volume in USDT at the moment of the sweep. This is calculated as `volume × close` on the sweep bar and serves as a proxy for the magnitude of liquidations that occurred. Higher volume sweeps tend to produce stronger reversals.

After a sweep, the level is updated to the new extreme — preventing duplicate signals and establishing a fresh liquidity reference.

Support & Resistance (Pivot-Based)

https://www.tradingview.com/x/IatCEaRO/

Active (un-swept) pivot levels are drawn on the chart as structural Support and Resistance:

- A line extending from the bar where the pivot formed to the current price area
- A zone band (ATR × 0.15) around the level, representing the area of influence
- Origin labels showing "Buy-Side Liquidity SWEEP" or "Sell-Side Liquidity SWEEP" with the USDT volume
- Price labels on the right edge for quick reference

These levels update dynamically: when a new pivot is confirmed, the line starts from the new origin. When a sweep occurs, the level shifts to the sweep bar.

Golden Zone (Fibonacci OTE: 0.618 – 0.786)

https://www.tradingview.com/x/iqRJGw8W/

The Golden Zone represents the Optimal Trade Entry area — the 61.8% to 78.6% Fibonacci retracement of the most recent price range. Unlike pivot-based calculations, this indicator uses a **lookback-based approach**: it finds the highest high and lowest low over a configurable number of bars, then derives the zone from that range.

The zone is visualized with:
- A filled box between the 0.618 and 0.786 levels (transparency adjustable)
- Dashed border lines at 0.618 and 0.786
- A dotted midline at the 0.702 level
- Price labels showing exact values
- A centered "GOLDEN ZONE" tag

This approach produces a stable, always-visible zone that doesn't depend on individual pivot detection, making it reliable across all market conditions.

Multi-Timeframe Heatmap

The core of this indicator is a 7-column heatmap table that evaluates market conditions across four timeframes simultaneously:

| Column | What It Shows | Bullish | Bearish |
|--------|--------------|---------|---------|
| SWEEP | Recent liquidity sweep direction | ● BULL (SSL swept) | ● BEAR (BSL swept) |
| GZ | Price position relative to Golden Zone | ▲ ABOVE | ▼ BELOW |
| S/R | Price position vs. pivot S/R midpoint | ▲ BULLISH | ▼ BEARISH |
| BIAS | EMA 21/50 trend direction | ▲ BULL | ▼ BEAR |
| RSI | RSI(14) value with decimal precision | Color-coded by zone | Color-coded by zone |
| SIGNAL | Composite of all conditions | LONG ▲ | SHORT ▼ |

Signal Logic: The SIGNAL column counts four conditions per timeframe — RSI above/below 50, price in/above the Golden Zone, price above/below the S/R midpoint, and EMA bias direction. When 3 or more conditions align bullish, the signal reads LONG. When 3 or more align bearish, it reads SHORT. Otherwise, NEUTRAL.

A confluence bar at the bottom aggregates all timeframes. When the majority of conditions across all four timeframes agree, it displays STRONG BULLISH or STRONG BEARISH CONFLUENCE.

RSI Color Coding

| RSI Range | Color | Meaning |
|-----------|-------|---------|
| > 70 | Orange | Overbought |
| 50 – 70 | Green | Bullish momentum |
| 30 – 50 | Red | Bearish momentum |
| < 30 | Blue | Oversold |

Settings

Structure Settings
| Setting | Default | Description |
|---------|---------|-------------|
| Pivot Lookback Length | 5 | Bars left and right to confirm a swing pivot. Higher values produce fewer but stronger levels |
| Sweep Active Memory | 10 | How many bars a sweep signal remains active on the heatmap after detection |

Golden Zone
| Setting | Default | Description |
|---------|---------|-------------|
| Lookback Period | 20 | Number of bars to find highest high and lowest low for Fibonacci calculation |
| Show Golden Zone | On | Toggle zone visibility on chart |
| Fill Golden Zone | On | Shade the area between 0.618 and 0.786 |
| Fill Transparency | 88 | Opacity of the filled zone (50–98) |
| Golden Zone Color | Gold | Color for all Golden Zone elements |

Support & Resistance
| Setting | Default | Description |
|---------|---------|-------------|
| Show S/R on Chart | On | Toggle S/R lines, zone bands, and labels |
| Support Color | Teal | Color for support level and SSL elements |
| Resistance Color | Red | Color for resistance level and BSL elements |
| Line Width | 2 | Thickness of S/R lines (1–4) |
| Line Style | Solid | Solid, Dashed, or Dotted |
| Show Price Labels | On | Display price values at the right edge of each level |

Sweep Event Labels
| Setting | Default | Description |
|---------|---------|-------------|
| Show Sweep Labels | On | Toggle sweep event markers on chart |
| Bullish Sweep Color | Green | Color for SSL sweep labels (bullish reversal) |
| Bearish Sweep Color | Red | Color for BSL sweep labels (bearish reversal) |

Heatmap Table
| Setting | Default | Description |
|---------|---------|-------------|
| Show Heatmap Table | On | Toggle the entire dashboard |
| Table Position | Top Right | 9 position options across the chart |
| Table Cell Size | Normal | Tiny, Small, Normal, Large, or Auto |

Alerts

Five alert conditions are built in and ready to use:

1. Bullish Liquidity Sweep — SSL swept, potential bullish reversal
2. Bearish Liquidity Sweep — BSL swept, potential bearish reversal
3. Bull Sweep + Golden Zone — SSL swept while price is inside the OTE zone (high-probability long)
4. Bear Sweep + Golden Zone — BSL swept while price is inside the OTE zone (high-probability short)
5. Price in Golden Zone — Price enters the 0.618–0.786 zone on any bar


Disclaimer

This indicator is a technical analysis tool designed to assist in identifying potential areas of interest based on market structure and liquidity concepts. It does not constitute financial advice. The USDT volume figures are approximations, not verified liquidation data. Always use proper risk management and combine this tool with your own analysis. Past performance of any signal or pattern does not guarantee future results. Trade at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Liquidity Sweep & Golden Zone [StrixEDGE]", 
     overlay          = true, 
     max_boxes_count  = 500, 
     max_labels_count = 500, 
     max_lines_count  = 500)

// ═══════════════════════════════════════════════════════════════════
//                          INPUTS                                   
// ═══════════════════════════════════════════════════════════════════

// ── Structure ───────────────────────────────────────────────────────
string G_STRUCT     = "⚙ Structure Settings"
int    pivotLen     = input.int(5, "Pivot Lookback Length", minval = 2, maxval = 50, group = G_STRUCT, 
                       tooltip = "Bars left & right to confirm a swing pivot. Higher = fewer but stronger levels")
int    sweepMemory  = input.int(10, "Sweep Active Memory (bars)", minval = 1, maxval = 50, group = G_STRUCT,
                       tooltip = "How many bars a sweep signal stays active on the heatmap")

// ── Golden Zone ─────────────────────────────────────────────────────
string G_GZ         = "🟡 Golden Zone (Fib 0.618 – 0.786)"
int    gzLookback   = input.int(20, "Lookback Period (bars)", minval = 5, maxval = 500, group = G_GZ,
                       tooltip = "Number of candles to find highest high & lowest low for Golden Zone calculation")
bool   showGZ       = input.bool(true, "Show Golden Zone on Chart", group = G_GZ)
bool   gzFill       = input.bool(true, "Fill Golden Zone", group = G_GZ)
int    gzFillTransp = input.int(88, "Fill Transparency", minval = 50, maxval = 98, group = G_GZ)
color  gzColor      = input.color(color.rgb(210, 190, 60), "Golden Zone Color", group = G_GZ)

// ── S/R (Pivot Levels) ─────────────────────────────────────────────
string G_SR         = "📐 Support & Resistance"
bool   showSR       = input.bool(true, "Show S/R on Chart", group = G_SR)
color  supColor     = input.color(color.rgb(38, 166, 154), "Support Color", group = G_SR)
color  resColor     = input.color(color.rgb(239, 83, 80), "Resistance Color", group = G_SR)
int    srLineWidth  = input.int(2, "Line Width", minval = 1, maxval = 4, group = G_SR)
string srLineStyle  = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_SR)
bool   showPriceL   = input.bool(true, "Show Price Labels", group = G_SR)

// ── Sweep Labels ────────────────────────────────────────────────────
string G_SWEEP      = "💧 Sweep Event Labels"
bool   showSweepLbl = input.bool(true, "Show Sweep Labels", group = G_SWEEP)
color  bullCol      = input.color(#00C853, "Bullish Sweep Color", group = G_SWEEP)
color  bearCol      = input.color(#FF1744, "Bearish Sweep Color", group = G_SWEEP)

// ── MTF Heatmap Table ───────────────────────────────────────────────
string G_TBL        = "📊 MTF Heatmap Table"
bool   showTbl      = input.bool(true, "Show Heatmap Table", group = G_TBL)
string tblPosIn     = input.string("Top Right", "Table Position", 
                       options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", 
                                  "Top Center", "Bottom Center", "Middle Right", "Middle Left", "Middle Center"], group = G_TBL)
string tblSzIn      = input.string("Normal", "Table Cell Size", 
                       options = ["Tiny", "Small", "Normal", "Large", "Auto"], group = G_TBL)


// ═══════════════════════════════════════════════════════════════════
//                      COLOR PALETTE                                
// ═══════════════════════════════════════════════════════════════════

color C_TITLE_BG   = color.rgb(8, 10, 18)
color C_TITLE_TXT  = color.rgb(220, 225, 235)
color C_HDR_BG     = color.rgb(16, 20, 32)
color C_HDR_TXT    = color.rgb(140, 145, 160)
color C_ROW_BG     = color.rgb(20, 24, 38)
color C_ROW_TXT    = color.rgb(185, 190, 205)
color C_BULL_BG    = color.rgb(20, 50, 38)
color C_BULL_TXT   = color.rgb(38, 166, 154)
color C_BEAR_BG    = color.rgb(55, 22, 22)
color C_BEAR_TXT   = color.rgb(239, 83, 80)
color C_NEUT_BG    = color.rgb(35, 38, 50)
color C_NEUT_TXT   = color.rgb(120, 123, 134)
color C_GZ_BG      = color.rgb(40, 45, 20)
color C_GZ_TXT     = color.rgb(210, 190, 60)
color C_DATA_BG    = color.rgb(24, 28, 42)
color C_SEP        = color.rgb(12, 14, 22)
color C_WHITE      = color.rgb(255, 255, 255)
color C_SIG_LONG   = color.rgb(38, 166, 154)
color C_SIG_SHORT  = color.rgb(239, 83, 80)
color C_SIG_NEUT   = color.rgb(50, 54, 68)


// ═══════════════════════════════════════════════════════════════════
//                    UTILITY FUNCTIONS                              
// ═══════════════════════════════════════════════════════════════════

f_tablePos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        => position.top_right

f_tableSize(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Auto"  => size.auto
        => size.normal

f_lineStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_price(float p) =>
    na(p) ? "—" : p >= 10000 ? str.tostring(p, "#.##") : p >= 100 ? str.tostring(p, "#.###") : p >= 1 ? str.tostring(p, "#.####") : p >= 0.01 ? str.tostring(p, "#.######") : str.tostring(p, "#.########")

f_vol(float v) =>
    na(v) ? "N/A" : v >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : v >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : v >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" : str.tostring(v, "#.##")


// ═══════════════════════════════════════════════════════════════════
//              RESOLVED TABLE SETTINGS (script-level)               
// ═══════════════════════════════════════════════════════════════════

string TBL_POS    = f_tablePos(tblPosIn)
string TBL_SZ     = f_tableSize(tblSzIn)
string SR_LN_STYLE = f_lineStyle(srLineStyle)


// ═══════════════════════════════════════════════════════════════════
//          TABLE ROW FUNCTION (top-level, 7 columns)                
// ═══════════════════════════════════════════════════════════════════

f_fillRow(table t, int row, string tfName, float sw, float gz, float sr, float bi, float rsi, string txtSz) =>
    // Col 0: TF label
    table.cell(t, 0, row, tfName, 
         text_color = C_ROW_TXT, text_size = txtSz, bgcolor = C_ROW_BG, 
         text_halign = text.align_center, text_font_family = font.family_monospace)

    // Col 1: Sweep
    string swTxt  = sw > 0.5 ? "● BULL" : sw < -0.5 ? "● BEAR" : "—"
    color  swBg   = sw > 0.5 ? C_BULL_BG : sw < -0.5 ? C_BEAR_BG : C_NEUT_BG
    color  swTxtC = sw > 0.5 ? C_BULL_TXT : sw < -0.5 ? C_BEAR_TXT : C_NEUT_TXT
    table.cell(t, 1, row, swTxt, 
         text_color = swTxtC, text_size = txtSz, bgcolor = swBg, 
         text_halign = text.align_center, text_font_family = font.family_monospace)

    // Col 2: Golden Zone
    string gzTxt  = gz > 0.75 ? "▲ ABOVE" : gz > 0.25 ? "◆ IN ZONE" : "▼ BELOW"
    color  gzBg2  = gz > 0.75 ? C_BULL_BG : gz > 0.25 ? C_GZ_BG : C_BEAR_BG
    color  gzTxtC = gz > 0.75 ? C_BULL_TXT : gz > 0.25 ? C_GZ_TXT : C_BEAR_TXT
    table.cell(t, 2, row, gzTxt, 
         text_color = gzTxtC, text_size = txtSz, bgcolor = gzBg2, 
         text_halign = text.align_center, text_font_family = font.family_monospace)

    // Col 3: S/R Position
    string srTxt  = sr > 0.5 ? "▲ BULLISH" : sr < -0.5 ? "▼ BEARISH" : "— NEUTRAL"
    color  srBg   = sr > 0.5 ? C_BULL_BG : sr < -0.5 ? C_BEAR_BG : C_NEUT_BG
    color  srTxtC = sr > 0.5 ? C_BULL_TXT : sr < -0.5 ? C_BEAR_TXT : C_NEUT_TXT
    table.cell(t, 3, row, srTxt, 
         text_color = srTxtC, text_size = txtSz, bgcolor = srBg, 
         text_halign = text.align_center, text_font_family = font.family_monospace)

    // Col 4: Bias
    string biTxt  = bi > 0.5 ? "▲ BULL" : bi < -0.5 ? "▼ BEAR" : "◼ FLAT"
    color  biBg   = bi > 0.5 ? C_BULL_BG : bi < -0.5 ? C_BEAR_BG : C_NEUT_BG
    color  biTxtC = bi > 0.5 ? C_BULL_TXT : bi < -0.5 ? C_BEAR_TXT : C_NEUT_TXT
    table.cell(t, 4, row, biTxt, 
         text_color = biTxtC, text_size = txtSz, bgcolor = biBg, 
         text_halign = text.align_center, text_font_family = font.family_monospace)

    // Col 5: RSI
    float  rsiR    = nz(rsi)
    string rsiTxt  = str.tostring(rsiR, "#.##")
    color  rsiBg   = rsiR > 70 ? color.rgb(60, 35, 10) : rsiR < 30 ? color.rgb(15, 30, 55) : rsiR >= 50 ? C_BULL_BG : C_BEAR_BG
    color  rsiTxtC = rsiR > 70 ? color.rgb(255, 152, 0) : rsiR < 30 ? color.rgb(41, 121, 255) : rsiR >= 50 ? C_BULL_TXT : C_BEAR_TXT
    table.cell(t, 5, row, rsiTxt, 
         text_color = rsiTxtC, text_size = txtSz, bgcolor = rsiBg, 
         text_halign = text.align_center, text_font_family = font.family_monospace)

    // Col 6: Signal (composite score: RSI + GZ + S/R + Bias = 4 conditions)
    int bullC = 0
    bullC += rsiR > 50 ? 1 : 0
    bullC += gz > 0.25 ? 1 : 0
    bullC += sr > 0.5  ? 1 : 0
    bullC += bi > 0.5  ? 1 : 0

    int bearC = 0
    bearC += rsiR < 50 ? 1 : 0
    bearC += gz < 0.0  ? 1 : 0
    bearC += sr < -0.5 ? 1 : 0
    bearC += bi < -0.5 ? 1 : 0

    int    sig    = bullC >= 3 ? 1 : bearC >= 3 ? -1 : 0
    string sigTxt = sig == 1 ? "LONG  ▲" : sig == -1 ? "SHORT  ▼" : "NEUTRAL  —"
    color  sigBg  = sig == 1 ? C_SIG_LONG : sig == -1 ? C_SIG_SHORT : C_SIG_NEUT
    color  sigTxC = sig == 1 ? C_WHITE : sig == -1 ? C_WHITE : C_NEUT_TXT
    table.cell(t, 6, row, sigTxt, 
         text_color = sigTxC, text_size = txtSz, bgcolor = sigBg, 
         text_halign = text.align_center, text_font_family = font.family_monospace)


// ═══════════════════════════════════════════════════════════════════
//                   LIQUIDITY SWEEP ENGINE                          
// ═══════════════════════════════════════════════════════════════════

float pivH = ta.pivothigh(high, pivotLen, pivotLen)
float pivL = ta.pivotlow(low, pivotLen, pivotLen)

var float activeSwH     = na
var float activeSwL     = na
var int   activeSwH_bar = 0
var int   activeSwL_bar = 0
var float swH_vol       = na
var float swL_vol       = na

if not na(pivH)
    activeSwH     := pivH
    activeSwH_bar := bar_index - pivotLen
    swH_vol       := volume[pivotLen] * close[pivotLen]

if not na(pivL)
    activeSwL     := pivL
    activeSwL_bar := bar_index - pivotLen
    swL_vol       := volume[pivotLen] * close[pivotLen]

// Sweep Detection
bool rawBullSweep = not na(activeSwL) and low < activeSwL and close > activeSwL
bool rawBearSweep = not na(activeSwH) and high > activeSwH and close < activeSwH

// Invalidate & update origin on sweep
if rawBullSweep
    activeSwL     := low
    activeSwL_bar := bar_index
    swL_vol       := volume * close

if rawBearSweep
    activeSwH     := high
    activeSwH_bar := bar_index
    swH_vol       := volume * close

// Persistent sweep tracking for heatmap
var float sweepDir       = 0.0
var int   barsSinceSweep = 9999

if rawBullSweep
    sweepDir       := 1.0
    barsSinceSweep := 0
else if rawBearSweep
    sweepDir       := -1.0
    barsSinceSweep := 0
else
    barsSinceSweep += 1

float sweepSignal = barsSinceSweep <= sweepMemory ? sweepDir : 0.0


// ═══════════════════════════════════════════════════════════════════
//               GOLDEN ZONE ENGINE (Lookback-Based)                 
// ═══════════════════════════════════════════════════════════════════

float lkb_hi    = ta.highest(high, gzLookback)
float lkb_lo    = ta.lowest(low, gzLookback)
float lkb_rng   = lkb_hi - lkb_lo
float lkb_gz_lo = lkb_lo + lkb_rng * 0.618
float lkb_gz_hi = lkb_lo + lkb_rng * 0.786
float lkb_gz_md = (lkb_gz_lo + lkb_gz_hi) / 2.0

// Encode: 1.0 = above, 0.5 = in zone, -1.0 = below
float gzSignal = close > lkb_gz_hi ? 1.0 : close >= lkb_gz_lo ? 0.5 : -1.0


// ═══════════════════════════════════════════════════════════════════
//                S/R POSITION (Pivot Midpoint)                      
// ═══════════════════════════════════════════════════════════════════

float srMid    = not na(activeSwH) and not na(activeSwL) ? (activeSwH + activeSwL) / 2.0 : na
float srSignal = na(srMid) ? 0.0 : close > srMid ? 1.0 : close < srMid ? -1.0 : 0.0


// ═══════════════════════════════════════════════════════════════════
//                      MARKET BIAS & RSI                            
// ═══════════════════════════════════════════════════════════════════

float ema21  = ta.ema(close, 21)
float ema50  = ta.ema(close, 50)
float bias   = ema21 > ema50 ? 1.0 : ema21 < ema50 ? -1.0 : 0.0
float rsiVal = ta.rsi(close, 14)


// ═══════════════════════════════════════════════════════════════════
//                    MULTI-TIMEFRAME DATA                           
// ═══════════════════════════════════════════════════════════════════

[sw15, gz15, sr15, bi15, rsi15]       = request.security(syminfo.tickerid, "15",  [sweepSignal, gzSignal, srSignal, bias, rsiVal], lookahead = barmerge.lookahead_off)
[sw60, gz60, sr60, bi60, rsi60]       = request.security(syminfo.tickerid, "60",  [sweepSignal, gzSignal, srSignal, bias, rsiVal], lookahead = barmerge.lookahead_off)
[sw240, gz240, sr240, bi240, rsi240]  = request.security(syminfo.tickerid, "240", [sweepSignal, gzSignal, srSignal, bias, rsiVal], lookahead = barmerge.lookahead_off)
[swD, gzD, srD, biD, rsiD]           = request.security(syminfo.tickerid, "1D",  [sweepSignal, gzSignal, srSignal, bias, rsiVal], lookahead = barmerge.lookahead_off)


// ═══════════════════════════════════════════════════════════════════
//                   CHART: SWEEP EVENT LABELS                       
// ═══════════════════════════════════════════════════════════════════

if showSweepLbl and rawBullSweep
    label.new(bar_index, low, "◆ Sell-Side Liquidity SWEEP\n$" + f_vol(volume * close), 
         style = label.style_label_up, color = bullCol, 
         textcolor = color.white, size = size.small)

if showSweepLbl and rawBearSweep
    label.new(bar_index, high, "◆ Buy-Side Liquidity SWEEP\n$" + f_vol(volume * close), 
         style = label.style_label_down, color = bearCol, 
         textcolor = color.white, size = size.small)


// ═══════════════════════════════════════════════════════════════════
//         CHART: S/R FROM PIVOT LEVELS (Reference Style)            
// ═══════════════════════════════════════════════════════════════════

float atr14     = ta.atr(14)
float zoneBand  = atr14 * 0.15

// Persistent drawing objects (script-level)
var line  ln_res     = na
var box   bx_res     = na
var label lbl_res    = na
var label lbl_res_px = na
var line  ln_sup     = na
var box   bx_sup     = na
var label lbl_sup    = na
var label lbl_sup_px = na

if barstate.islast and showSR and not na(activeSwH) and not na(activeSwL)
    srRight = bar_index + 5

    // ── RESISTANCE (active swing high) ──────────────────────────
    line.delete(ln_res)
    box.delete(bx_res)
    label.delete(lbl_res)
    label.delete(lbl_res_px)

    ln_res := line.new(activeSwH_bar, activeSwH, srRight, activeSwH, 
         color = resColor, width = srLineWidth, style = SR_LN_STYLE)
    
    bx_res := box.new(activeSwH_bar, activeSwH + zoneBand, srRight, activeSwH - zoneBand, 
         border_color = color.new(resColor, 85), border_width = 0,
         bgcolor = color.new(resColor, 90))

    lbl_res := label.new(activeSwH_bar, activeSwH + zoneBand, "Buy-Side Liquidity SWEEP\n$" + f_vol(swH_vol), 
         style = label.style_label_down, color = color.new(resColor, 60), 
         textcolor = C_WHITE, size = size.tiny)

    if showPriceL
        lbl_res_px := label.new(srRight + 1, activeSwH, f_price(activeSwH), 
             style = label.style_label_left, color = color.new(resColor, 70), 
             textcolor = resColor, size = size.small)

    // ── SUPPORT (active swing low) ──────────────────────────────
    line.delete(ln_sup)
    box.delete(bx_sup)
    label.delete(lbl_sup)
    label.delete(lbl_sup_px)

    ln_sup := line.new(activeSwL_bar, activeSwL, srRight, activeSwL, 
         color = supColor, width = srLineWidth, style = SR_LN_STYLE)

    bx_sup := box.new(activeSwL_bar, activeSwL + zoneBand, srRight, activeSwL - zoneBand, 
         border_color = color.new(supColor, 85), border_width = 0,
         bgcolor = color.new(supColor, 90))

    lbl_sup := label.new(activeSwL_bar, activeSwL - zoneBand, "Sell-Side Liquidity SWEEP\n$" + f_vol(swL_vol), 
         style = label.style_label_up, color = color.new(supColor, 60), 
         textcolor = C_WHITE, size = size.tiny)

    if showPriceL
        lbl_sup_px := label.new(srRight + 1, activeSwL, f_price(activeSwL), 
             style = label.style_label_left, color = color.new(supColor, 70), 
             textcolor = supColor, size = size.small)


// ═══════════════════════════════════════════════════════════════════
//         CHART: GOLDEN ZONE (Lookback, Reference Style)            
// ═══════════════════════════════════════════════════════════════════

var box   bx_gz      = na
var line  ln_gz_top  = na
var line  ln_gz_bot  = na
var line  ln_gz_mid  = na
var label lbl_gz_top = na
var label lbl_gz_bot = na
var label lbl_gz_tag = na

if barstate.islast and showGZ
    int gzRight = bar_index + 20

    box.delete(bx_gz)
    line.delete(ln_gz_top)
    line.delete(ln_gz_bot)
    line.delete(ln_gz_mid)
    label.delete(lbl_gz_top)
    label.delete(lbl_gz_bot)
    label.delete(lbl_gz_tag)

    // Filled zone box
    if gzFill
        bx_gz := box.new(bar_index, lkb_gz_hi, gzRight, lkb_gz_lo, 
             border_color = color.new(gzColor, 40), border_width = 1, 
             border_style = line.style_dashed,
             bgcolor = color.new(gzColor, gzFillTransp))

    // Top border (0.786)
    ln_gz_top := line.new(bar_index, lkb_gz_hi, gzRight, lkb_gz_hi, 
         color = gzColor, width = 1, style = line.style_dashed)

    // Bottom border (0.618)
    ln_gz_bot := line.new(bar_index, lkb_gz_lo, gzRight, lkb_gz_lo, 
         color = gzColor, width = 1, style = line.style_dashed)

    // Midline (0.702)
    ln_gz_mid := line.new(bar_index, lkb_gz_md, gzRight, lkb_gz_md, 
         color = color.new(gzColor, 50), width = 1, style = line.style_dotted)

    // Price labels on right edge
    if showPriceL
        lbl_gz_top := label.new(gzRight + 1, lkb_gz_hi, "0.786  " + f_price(lkb_gz_hi), 
             style = label.style_label_left, color = color.new(gzColor, 70), 
             textcolor = gzColor, size = size.small)

        lbl_gz_bot := label.new(gzRight + 1, lkb_gz_lo, "0.618  " + f_price(lkb_gz_lo), 
             style = label.style_label_left, color = color.new(gzColor, 70), 
             textcolor = gzColor, size = size.small)

    // Centered tag
    lbl_gz_tag := label.new(bar_index + 10, lkb_gz_md, "GOLDEN ZONE", 
         style = label.style_label_center, color = color.rgb(0, 0, 0, 100), 
         textcolor = color.new(gzColor, 20), size = size.small)


// ═══════════════════════════════════════════════════════════════════
//                    HEATMAP TABLE (7 cols × 7 rows)                
// ═══════════════════════════════════════════════════════════════════

var table tbl = table.new(TBL_POS, 7, 7, 
     bgcolor = C_DATA_BG, border_color = C_SEP, border_width = 1, 
     frame_color = C_SEP, frame_width = 2)

if showTbl and barstate.islast
    // ── Row 0: Title ────────────────────────────────────────────
    table.cell(tbl, 0, 0, "  LIQUIDITY SWEEP  &  GOLDEN ZONE  ", 
         text_color = C_TITLE_TXT, text_size = TBL_SZ, bgcolor = C_TITLE_BG, 
         text_halign = text.align_center, text_font_family = font.family_monospace)
    table.merge_cells(tbl, 0, 0, 6, 0)

    // ── Row 1: Column Headers ───────────────────────────────────
    table.cell(tbl, 0, 1, "  TF  ",    text_color = C_HDR_TXT, text_size = TBL_SZ, bgcolor = C_HDR_BG, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 1, " SWEEP ",   text_color = C_HDR_TXT, text_size = TBL_SZ, bgcolor = C_HDR_BG, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(tbl, 2, 1, "  GZ  ",    text_color = C_HDR_TXT, text_size = TBL_SZ, bgcolor = C_HDR_BG, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(tbl, 3, 1, "  S/R  ",   text_color = C_HDR_TXT, text_size = TBL_SZ, bgcolor = C_HDR_BG, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(tbl, 4, 1, " BIAS ",    text_color = C_HDR_TXT, text_size = TBL_SZ, bgcolor = C_HDR_BG, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(tbl, 5, 1, " RSI ",     text_color = C_HDR_TXT, text_size = TBL_SZ, bgcolor = C_HDR_BG, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(tbl, 6, 1, " SIGNAL ",  text_color = C_HDR_TXT, text_size = TBL_SZ, bgcolor = C_HDR_BG, text_halign = text.align_center, text_font_family = font.family_monospace)

    // ── Rows 2–5: Timeframe data ────────────────────────────────
    f_fillRow(tbl, 2, " 15M ", sw15,  gz15,  sr15,  bi15,  rsi15,  TBL_SZ)
    f_fillRow(tbl, 3, "  1H ", sw60,  gz60,  sr60,  bi60,  rsi60,  TBL_SZ)
    f_fillRow(tbl, 4, "  4H ", sw240, gz240, sr240, bi240, rsi240, TBL_SZ)
    f_fillRow(tbl, 5, "  1D ", swD,   gzD,   srD,   biD,   rsiD,   TBL_SZ)

    // ── Row 6: MTF Confluence ───────────────────────────────────
    float tBull = 0.0
    float tBear = 0.0
    tBull += sw15  > 0.5 ? 1.0 : 0.0
    tBull += sw60  > 0.5 ? 1.0 : 0.0
    tBull += sw240 > 0.5 ? 1.0 : 0.0
    tBull += swD   > 0.5 ? 1.0 : 0.0
    tBull += gz15  > 0.25 ? 1.0 : 0.0
    tBull += gz60  > 0.25 ? 1.0 : 0.0
    tBull += gz240 > 0.25 ? 1.0 : 0.0
    tBull += gzD   > 0.25 ? 1.0 : 0.0
    tBull += sr15  > 0.5 ? 1.0 : 0.0
    tBull += sr60  > 0.5 ? 1.0 : 0.0
    tBull += sr240 > 0.5 ? 1.0 : 0.0
    tBull += srD   > 0.5 ? 1.0 : 0.0
    tBull += bi15  > 0.5 ? 1.0 : 0.0
    tBull += bi60  > 0.5 ? 1.0 : 0.0
    tBull += bi240 > 0.5 ? 1.0 : 0.0
    tBull += biD   > 0.5 ? 1.0 : 0.0

    tBear += sw15  < -0.5 ? 1.0 : 0.0
    tBear += sw60  < -0.5 ? 1.0 : 0.0
    tBear += sw240 < -0.5 ? 1.0 : 0.0
    tBear += swD   < -0.5 ? 1.0 : 0.0
    tBear += gz15  < 0.0  ? 1.0 : 0.0
    tBear += gz60  < 0.0  ? 1.0 : 0.0
    tBear += gz240 < 0.0  ? 1.0 : 0.0
    tBear += gzD   < 0.0  ? 1.0 : 0.0
    tBear += sr15  < -0.5 ? 1.0 : 0.0
    tBear += sr60  < -0.5 ? 1.0 : 0.0
    tBear += sr240 < -0.5 ? 1.0 : 0.0
    tBear += srD   < -0.5 ? 1.0 : 0.0
    tBear += bi15  < -0.5 ? 1.0 : 0.0
    tBear += bi60  < -0.5 ? 1.0 : 0.0
    tBear += bi240 < -0.5 ? 1.0 : 0.0
    tBear += biD   < -0.5 ? 1.0 : 0.0

    float  confScore = tBull - tBear
    string confTxt   = confScore >= 6 ? "⚡ STRONG BULLISH CONFLUENCE" : confScore >= 3 ? "▲ BULLISH CONFLUENCE" : confScore <= -6 ? "⚡ STRONG BEARISH CONFLUENCE" : confScore <= -3 ? "▼ BEARISH CONFLUENCE" : "◼ MIXED / NO CONFLUENCE"
    color  confBg    = confScore >= 6 ? C_SIG_LONG : confScore >= 3 ? C_BULL_BG : confScore <= -6 ? C_SIG_SHORT : confScore <= -3 ? C_BEAR_BG : C_NEUT_BG
    color  confTxtC  = confScore >= 6 ? C_WHITE : confScore >= 3 ? C_BULL_TXT : confScore <= -6 ? C_WHITE : confScore <= -3 ? C_BEAR_TXT : C_NEUT_TXT

    table.cell(tbl, 0, 6, confTxt, 
         text_color = confTxtC, text_size = TBL_SZ, bgcolor = confBg, 
         text_halign = text.align_center, text_font_family = font.family_monospace)
    table.merge_cells(tbl, 0, 6, 6, 6)


// ═══════════════════════════════════════════════════════════════════
//                        EMA PLOTS                                  
// ═══════════════════════════════════════════════════════════════════

plot(ema21, "EMA 21", color = color.new(#42A5F5, 60), linewidth = 1)
plot(ema50, "EMA 50", color = color.new(#AB47BC, 60), linewidth = 1)


// ═══════════════════════════════════════════════════════════════════
//                        ALERTS                                     
// ═══════════════════════════════════════════════════════════════════

bool inGZ = close >= lkb_gz_lo and close <= lkb_gz_hi

alertcondition(rawBullSweep, title = "Bullish Liquidity Sweep", 
     message = "🟢 Bullish Liquidity Sweep on {{ticker}} ({{interval}})")
alertcondition(rawBearSweep, title = "Bearish Liquidity Sweep", 
     message = "🔴 Bearish Liquidity Sweep on {{ticker}} ({{interval}})")
alertcondition(rawBullSweep and inGZ, title = "Bull Sweep + Golden Zone", 
     message = "⚡ Bullish Sweep inside Golden Zone on {{ticker}} ({{interval}})")
alertcondition(rawBearSweep and inGZ, title = "Bear Sweep + Golden Zone", 
     message = "⚡ Bearish Sweep inside Golden Zone on {{ticker}} ({{interval}})")
alertcondition(inGZ, title = "Price in Golden Zone", 
     message = "🟡 Price entered Golden Zone (0.618–0.786) on {{ticker}} ({{interval}})")
````
