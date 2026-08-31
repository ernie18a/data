<!-- tradingview-pine-id: PUB;20dcd097c6ac432598b9d08be3d410c6 -->
<!-- tradingviewscripts-format: 1 -->
# EV HTF Bias Dashboard

Source: https://www.tradingview.com/script/7eRrTcXZ-HTF-Bias-Dashboard-EV-LABS/

## Description

EV HTF Bias Dashboard — Multi-timeframe bias in one view

A clean, configurable dashboard that shows trend, momentum, structure, volume and alignment status across 6 timeframes at once, plus a consolidated overall bias. Drop it on any chart and you have the full multi-timeframe picture without opening 6 separate indicators.

==================================================

WHAT IT DOES

EV HTF Bias Dashboard pulls 6 configurable timeframes, computes 5 metrics per timeframe in real time, and lays them out in a single table you can position anywhere on the chart. At the bottom of the table, an OVERALL row shows you the consensus: how many timeframes are bullish, how many are bearish, and whether everything is aligned or there is conflict.

Designed for traders who want the multi-timeframe context at a glance instead of flipping through 6 charts.

==================================================

THE 5 METRICS PER TIMEFRAME

1. TREND
   Based on close vs the fast EMA.
   - BULL  : close above the fast EMA
   - BEAR  : close below the fast EMA
   - FLAT  : equal (rare)

2. MOMENTUM (RSI)
   RSI value with color coding.
   - White  : neutral zone
   - Green  : oversold (potential bounce)
   - Red    : overbought (potential pullback)

3. STRUCTURE
   Based on the alignment of price against 3 EMAs (fast / mid / slow).
   - UP   : close > fast EMA > mid EMA > slow EMA (full bullish stack)
   - DN   : close < fast EMA < mid EMA < slow EMA (full bearish stack)
   - MX   : mixed alignment (transition or chop)

4. VOLUME
   Current volume relative to its moving average.
   - SPIKE : above your spike threshold (default 2x MA)
   - HIGH  : above 1.5x MA
   - AVG   : between 0.7x and 1.5x MA
   - LOW   : below 0.7x MA

5. STATUS
   Combined verdict for that timeframe.
   - ALIGN  : trend and structure agree, RSI not extreme
   - CONFL  : trend and structure disagree
   - RANGE  : one of them is flat, no clear direction
   - REVERS : trend up but RSI overbought, or trend down but RSI oversold (potential reversal warning)

==================================================

THE OVERALL ROW

A summary cell that aggregates all 6 timeframes:
- Bull vs Bear count (e.g. 4B/2B)
- Overall bias label: BULLISH, BEARISH, or MIXED
- Aligned count: how many of the 6 TFs have all 5 metrics in agreement (ALIGN status)

When the OVERALL row is BULLISH AND aligned count is 5/6 or 6/6, you have maximum confluence. That is when your other EV Labs tools (Order Blocks, FVGs, Liquidity Sweeps) become highest-probability setups.

==================================================

KEY INPUTS

Timeframes (6 rows, smallest to largest):
   - Default: 15m, 1H, 4H, 1D, 1W, 1M
   - Editable to anything Pine supports

Metric Settings:
   - EMA Fast  : default 20 (drives Trend)
   - EMA Mid   : default 50 (part of Structure)
   - EMA Slow  : default 200 (part of Structure)
   - RSI Length: default 14
   - Volume MA : default 20
   - Volume Spike threshold: default 2.0x MA

Visuals:
   - Show Dashboard: on/off
   - Position: 6 options (corners + top/bottom center)
   - Cell Size: Tiny / Small / Normal / Large
   - Show Overall Bias Row: on/off

==================================================

ALERTS

Five built-in alert conditions, ready to use as soon as you add the indicator:

- All TFs Bullish (6/6 bullish): maximum long confluence
- All TFs Bearish (6/6 bearish): maximum short confluence
- Majority Bullish (5+/6 bullish): strong long bias
- Majority Bearish (5+/6 bearish): strong short bias
- Overall Bias Shifted: fires when the OVERALL row changes state

==================================================

RECOMMENDED SETUPS

Scalper on 1m chart
   - TF1: 1,  TF2: 5,  TF3: 15,  TF4: 60,  TF5: 240,  TF6: 1D
   - All thresholds at default

Day trader on 15m chart
   - TF1: 15,  TF2: 60,  TF3: 240,  TF4: 1D,  TF5: 1W,  TF6: 1M
   - All thresholds at default

Swing trader on 4H chart
   - TF1: 240,  TF2: 1D,  TF3: 1W,  TF4: 1M,  TF5: 3M,  TF6: 6M
   - EMA Slow to 100 if you want more sensitivity on higher TFs

Position trader on D1
   - TF1: 1D,  TF2: 1W,  TF3: 1M,  TF4: 3M,  TF5: 6M,  TF6: 12M
   - Raise Min Samples style logic via slower EMAs (50/100/200)

==================================================

HOW IT CONNECTS TO THE EV SUITE

This dashboard is the context layer. Pair it with the rest of EV Labs:

- EV Probability Engine  : only take signals when the OVERALL row agrees with the trade direction
- EV Fair Value Gaps      : high-probability entries when an FVG appears inside a TF marked ALIGN in your bias
- EV Order Blocks         : OB taps are strongest in TFs where structure matches trend
- EV Liquidity Sweeps     : sweep signals are highest quality in TFs where STATUS is ALIGN
- EV Smart Volume         : cross-check the spike markers with the VOLUME column in the dashboard

==================================================

LIMITATIONS

- The "structure" column uses EMA alignment as a proxy for HH/HL market structure, not the full ICT HH/HL pivot logic. It is a robust shortcut, not a literal replacement for proper swing detection.
- request.security() calls are limited by Pine's platform limits. Six timeframes with 2 calls each is well within budget, but adding more would push the boundary.
- The OVERALL bias is a simple majority vote (4 of 6). It does not weight higher timeframes more than lower ones, even though in practice a 1W signal usually matters more than a 15m signal.
- Not a signal service. It is a context and confirmation tool.

==================================================

Built by EV Labs · Pine Script v6 · Open source

---

## Source Code

````pine
//@version=6
// ============================================================================
//  EV HTF BIAS DASHBOARD
//  --------------------------------------------------------------------------
//  Multi-timeframe bias dashboard showing trend, momentum, structure,
//  volume and alignment status across 6 timeframes at once, plus a
//  consolidated overall bias.  No plots on the chart - clean dashboard only.
//
//  Author:  EV Labs
//  Version: 1.0 (Pine v6)
//  License: Open source
// ============================================================================

indicator("EV HTF Bias Dashboard",
     shorttitle     = "EV HTF Bias",
     overlay        = true,
     max_bars_back  = 5000)

// ============================================================================
//  INPUTS
// ============================================================================

grpTF = "Timeframes (6 rows, smallest to largest)"
i_tf1 = input.timeframe("15",  "Timeframe 1", group=grpTF, tooltip="Smallest TF - fastest signal")
i_tf2 = input.timeframe("60",  "Timeframe 2", group=grpTF)
i_tf3 = input.timeframe("240", "Timeframe 3", group=grpTF)
i_tf4 = input.timeframe("1D",  "Timeframe 4", group=grpTF)
i_tf5 = input.timeframe("1W",  "Timeframe 5", group=grpTF)
i_tf6 = input.timeframe("1M",  "Timeframe 6", group=grpTF, tooltip="Largest TF - macro bias")

grpMet = "Metric Settings"
i_emaFast  = input.int(20,  "EMA Fast (trend)",        minval=5,   maxval=100, group=grpMet)
i_emaMid   = input.int(50,  "EMA Mid (structure)",     minval=10,  maxval=200, group=grpMet)
i_emaSlow  = input.int(200, "EMA Slow (structure)",    minval=50,  maxval=500, group=grpMet)
i_rsiLen   = input.int(14,  "RSI Length",              minval=5,   maxval=50,  group=grpMet)
i_volLen   = input.int(20,  "Volume MA Length",        minval=5,   maxval=100, group=grpMet)
i_spikeTh  = input.float(2.0, "Volume Spike Threshold", minval=1.0, step=0.1,  group=grpMet)

grpVis = "Visuals"
i_showTable = input.bool(true, "Show Dashboard", group=grpVis)
i_tablePos  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Top Center","Bottom Center"], group=grpVis)
i_sizeStr   = input.string("Small", "Cell Size", options=["Tiny","Small","Normal","Large"], group=grpVis)
i_showOverall = input.bool(true, "Show Overall Bias Row", group=grpVis)

// ============================================================================
//  HELPERS
// ============================================================================

f_getSize(_s) =>
    switch _s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_getPos(_s) =>
    switch _s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_right

cellSize = f_getSize(i_sizeStr)

// ============================================================================
//  PER-TF DATA FETCHING
// ============================================================================

[tf1_c, tf1_ef, tf1_em, tf1_es] = request.security(syminfo.tickerid, i_tf1, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaMid), ta.ema(close, i_emaSlow)], barmerge.gaps_off, barmerge.lookahead_off)
[tf1_rsi, tf1_vol, tf1_volAvg]  = request.security(syminfo.tickerid, i_tf1, [ta.rsi(close, i_rsiLen), volume, ta.sma(volume, i_volLen)], barmerge.gaps_off, barmerge.lookahead_off)

[tf2_c, tf2_ef, tf2_em, tf2_es] = request.security(syminfo.tickerid, i_tf2, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaMid), ta.ema(close, i_emaSlow)], barmerge.gaps_off, barmerge.lookahead_off)
[tf2_rsi, tf2_vol, tf2_volAvg]  = request.security(syminfo.tickerid, i_tf2, [ta.rsi(close, i_rsiLen), volume, ta.sma(volume, i_volLen)], barmerge.gaps_off, barmerge.lookahead_off)

[tf3_c, tf3_ef, tf3_em, tf3_es] = request.security(syminfo.tickerid, i_tf3, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaMid), ta.ema(close, i_emaSlow)], barmerge.gaps_off, barmerge.lookahead_off)
[tf3_rsi, tf3_vol, tf3_volAvg]  = request.security(syminfo.tickerid, i_tf3, [ta.rsi(close, i_rsiLen), volume, ta.sma(volume, i_volLen)], barmerge.gaps_off, barmerge.lookahead_off)

[tf4_c, tf4_ef, tf4_em, tf4_es] = request.security(syminfo.tickerid, i_tf4, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaMid), ta.ema(close, i_emaSlow)], barmerge.gaps_off, barmerge.lookahead_off)
[tf4_rsi, tf4_vol, tf4_volAvg]  = request.security(syminfo.tickerid, i_tf4, [ta.rsi(close, i_rsiLen), volume, ta.sma(volume, i_volLen)], barmerge.gaps_off, barmerge.lookahead_off)

[tf5_c, tf5_ef, tf5_em, tf5_es] = request.security(syminfo.tickerid, i_tf5, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaMid), ta.ema(close, i_emaSlow)], barmerge.gaps_off, barmerge.lookahead_off)
[tf5_rsi, tf5_vol, tf5_volAvg]  = request.security(syminfo.tickerid, i_tf5, [ta.rsi(close, i_rsiLen), volume, ta.sma(volume, i_volLen)], barmerge.gaps_off, barmerge.lookahead_off)

[tf6_c, tf6_ef, tf6_em, tf6_es] = request.security(syminfo.tickerid, i_tf6, [close, ta.ema(close, i_emaFast), ta.ema(close, i_emaMid), ta.ema(close, i_emaSlow)], barmerge.gaps_off, barmerge.lookahead_off)
[tf6_rsi, tf6_vol, tf6_volAvg]  = request.security(syminfo.tickerid, i_tf6, [ta.rsi(close, i_rsiLen), volume, ta.sma(volume, i_volLen)], barmerge.gaps_off, barmerge.lookahead_off)

// ============================================================================
//  PER-TF METRIC CALCULATIONS
// ============================================================================

f_calcTrend(_c, _ef) =>
    _c > _ef ? 1 : _c < _ef ? -1 : 0

f_calcStruct(_c, _ef, _em, _es) =>
    _c > _ef and _ef > _em and _em > _es ? 1 : _c < _ef and _ef < _em and _em < _es ? -1 : 0

f_calcVolState(_vol, _avg, _spike) =>
    _avg > 0 ? (_vol > _avg * _spike ? 3 : _vol > _avg * 1.5 ? 2 : _vol > _avg * 0.7 ? 1 : 0) : 1

f_calcStatus(_trend, _struct, _rsi) =>
    _trend == 0 or _struct == 0 ? "RANGE" : _trend != _struct ? "CONFL" : (_trend == 1 and _rsi > 75) or (_trend == -1 and _rsi < 25) ? "REVERS" : "ALIGN"

tf1_trend    = f_calcTrend(tf1_c, tf1_ef)
tf1_struct   = f_calcStruct(tf1_c, tf1_ef, tf1_em, tf1_es)
tf1_volState = f_calcVolState(tf1_vol, tf1_volAvg, i_spikeTh)
tf1_status   = f_calcStatus(tf1_trend, tf1_struct, tf1_rsi)

tf2_trend    = f_calcTrend(tf2_c, tf2_ef)
tf2_struct   = f_calcStruct(tf2_c, tf2_ef, tf2_em, tf2_es)
tf2_volState = f_calcVolState(tf2_vol, tf2_volAvg, i_spikeTh)
tf2_status   = f_calcStatus(tf2_trend, tf2_struct, tf2_rsi)

tf3_trend    = f_calcTrend(tf3_c, tf3_ef)
tf3_struct   = f_calcStruct(tf3_c, tf3_ef, tf3_em, tf3_es)
tf3_volState = f_calcVolState(tf3_vol, tf3_volAvg, i_spikeTh)
tf3_status   = f_calcStatus(tf3_trend, tf3_struct, tf3_rsi)

tf4_trend    = f_calcTrend(tf4_c, tf4_ef)
tf4_struct   = f_calcStruct(tf4_c, tf4_ef, tf4_em, tf4_es)
tf4_volState = f_calcVolState(tf4_vol, tf4_volAvg, i_spikeTh)
tf4_status   = f_calcStatus(tf4_trend, tf4_struct, tf4_rsi)

tf5_trend    = f_calcTrend(tf5_c, tf5_ef)
tf5_struct   = f_calcStruct(tf5_c, tf5_ef, tf5_em, tf5_es)
tf5_volState = f_calcVolState(tf5_vol, tf5_volAvg, i_spikeTh)
tf5_status   = f_calcStatus(tf5_trend, tf5_struct, tf5_rsi)

tf6_trend    = f_calcTrend(tf6_c, tf6_ef)
tf6_struct   = f_calcStruct(tf6_c, tf6_ef, tf6_em, tf6_es)
tf6_volState = f_calcVolState(tf6_vol, tf6_volAvg, i_spikeTh)
tf6_status   = f_calcStatus(tf6_trend, tf6_struct, tf6_rsi)

// ============================================================================
//  OVERALL BIAS
// ============================================================================

bullCount = (tf1_trend == 1 ? 1 : 0) + (tf2_trend == 1 ? 1 : 0) + (tf3_trend == 1 ? 1 : 0) + (tf4_trend == 1 ? 1 : 0) + (tf5_trend == 1 ? 1 : 0) + (tf6_trend == 1 ? 1 : 0)
bearCount = (tf1_trend == -1 ? 1 : 0) + (tf2_trend == -1 ? 1 : 0) + (tf3_trend == -1 ? 1 : 0) + (tf4_trend == -1 ? 1 : 0) + (tf5_trend == -1 ? 1 : 0) + (tf6_trend == -1 ? 1 : 0)

overallBias = bullCount >= 4 ? 1 : bearCount >= 4 ? -1 : 0
overallLabel = overallBias == 1 ? "BULLISH" : overallBias == -1 ? "BEARISH" : "MIXED"

var int prevBias = 0
biasShift = overallBias != prevBias
prevBias  := overallBias

alignedCount = (tf1_status == "ALIGN" ? 1 : 0) + (tf2_status == "ALIGN" ? 1 : 0) + (tf3_status == "ALIGN" ? 1 : 0) + (tf4_status == "ALIGN" ? 1 : 0) + (tf5_status == "ALIGN" ? 1 : 0) + (tf6_status == "ALIGN" ? 1 : 0)

// ============================================================================
//  DASHBOARD
// ============================================================================

f_trendLabel(_t) =>
    _t == 1 ? "BULL" : _t == -1 ? "BEAR" : "FLAT"

f_structLabel(_s) =>
    _s == 1 ? "UP" : _s == -1 ? "DN" : "MX"

f_volLabel(_v) =>
    switch _v
        3 => "SPIKE"
        2 => "HIGH"
        1 => "AVG"
        => "LOW"

f_statusClr(_s) =>
    _s == "ALIGN" ? color.new(color.green, 60) : _s == "CONFL" ? color.new(color.orange, 60) : _s == "REVERS" ? color.new(color.yellow, 50) : color.new(color.gray, 70)

f_trendClr(_t) =>
    _t == 1 ? color.new(color.green, 40) : _t == -1 ? color.new(color.red, 40) : color.new(color.gray, 60)

f_structClr(_s) =>
    _s == 1 ? color.new(color.green, 50) : _s == -1 ? color.new(color.red, 50) : color.new(color.gray, 70)

f_rsiClr(_r) =>
    _r > 70 ? color.new(color.red, 30) : _r < 30 ? color.new(color.green, 30) : color.white

f_volClr(_v) =>
    _v == 3 ? color.new(color.yellow, 30) : _v == 2 ? color.new(color.orange, 50) : _v == 1 ? color.white : color.new(color.gray, 50)

var table dash = na
var int dashRows = 8

if barstate.isfirst
    dashRows := i_showOverall ? 9 : 8

if i_showTable and barstate.islast
    if na(dash)
        dash := table.new(f_getPos(i_tablePos), 6, dashRows, bgcolor=color.new(color.black, 75), border_width=1, border_color=color.new(color.gray, 50))

    table.cell(dash, 0, 0, "EV HTF BIAS", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.blue, 20), text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 5, 0)

    table.cell(dash, 0, 1, "TF",        text_color=color.gray, text_size=size.small, bgcolor=color.new(color.gray, 70), text_halign=text.align_center)
    table.cell(dash, 1, 1, "Trend",     text_color=color.gray, text_size=size.small, bgcolor=color.new(color.gray, 70), text_halign=text.align_center)
    table.cell(dash, 2, 1, "Mom (RSI)", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.gray, 70), text_halign=text.align_center)
    table.cell(dash, 3, 1, "Struct",    text_color=color.gray, text_size=size.small, bgcolor=color.new(color.gray, 70), text_halign=text.align_center)
    table.cell(dash, 4, 1, "Volume",    text_color=color.gray, text_size=size.small, bgcolor=color.new(color.gray, 70), text_halign=text.align_center)
    table.cell(dash, 5, 1, "Status",    text_color=color.gray, text_size=size.small, bgcolor=color.new(color.gray, 70), text_halign=text.align_center)

    table.cell(dash, 0, 2, i_tf1,  text_color=color.white, text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 1, 2, f_trendLabel(tf1_trend),  text_color=color.white, text_size=cellSize, bgcolor=f_trendClr(tf1_trend),  text_halign=text.align_center)
    table.cell(dash, 2, 2, str.tostring(tf1_rsi, "#.#"),  text_color=f_rsiClr(tf1_rsi),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 3, 2, f_structLabel(tf1_struct), text_color=color.white, text_size=cellSize, bgcolor=f_structClr(tf1_struct), text_halign=text.align_center)
    table.cell(dash, 4, 2, f_volLabel(tf1_volState),  text_color=f_volClr(tf1_volState),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 5, 2, tf1_status, text_color=color.white, text_size=cellSize, bgcolor=f_statusClr(tf1_status), text_halign=text.align_center)

    table.cell(dash, 0, 3, i_tf2,  text_color=color.white, text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 1, 3, f_trendLabel(tf2_trend),  text_color=color.white, text_size=cellSize, bgcolor=f_trendClr(tf2_trend),  text_halign=text.align_center)
    table.cell(dash, 2, 3, str.tostring(tf2_rsi, "#.#"),  text_color=f_rsiClr(tf2_rsi),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 3, 3, f_structLabel(tf2_struct), text_color=color.white, text_size=cellSize, bgcolor=f_structClr(tf2_struct), text_halign=text.align_center)
    table.cell(dash, 4, 3, f_volLabel(tf2_volState),  text_color=f_volClr(tf2_volState),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 5, 3, tf2_status, text_color=color.white, text_size=cellSize, bgcolor=f_statusClr(tf2_status), text_halign=text.align_center)

    table.cell(dash, 0, 4, i_tf3,  text_color=color.white, text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 1, 4, f_trendLabel(tf3_trend),  text_color=color.white, text_size=cellSize, bgcolor=f_trendClr(tf3_trend),  text_halign=text.align_center)
    table.cell(dash, 2, 4, str.tostring(tf3_rsi, "#.#"),  text_color=f_rsiClr(tf3_rsi),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 3, 4, f_structLabel(tf3_struct), text_color=color.white, text_size=cellSize, bgcolor=f_structClr(tf3_struct), text_halign=text.align_center)
    table.cell(dash, 4, 4, f_volLabel(tf3_volState),  text_color=f_volClr(tf3_volState),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 5, 4, tf3_status, text_color=color.white, text_size=cellSize, bgcolor=f_statusClr(tf3_status), text_halign=text.align_center)

    table.cell(dash, 0, 5, i_tf4,  text_color=color.white, text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 1, 5, f_trendLabel(tf4_trend),  text_color=color.white, text_size=cellSize, bgcolor=f_trendClr(tf4_trend),  text_halign=text.align_center)
    table.cell(dash, 2, 5, str.tostring(tf4_rsi, "#.#"),  text_color=f_rsiClr(tf4_rsi),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 3, 5, f_structLabel(tf4_struct), text_color=color.white, text_size=cellSize, bgcolor=f_structClr(tf4_struct), text_halign=text.align_center)
    table.cell(dash, 4, 5, f_volLabel(tf4_volState),  text_color=f_volClr(tf4_volState),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 5, 5, tf4_status, text_color=color.white, text_size=cellSize, bgcolor=f_statusClr(tf4_status), text_halign=text.align_center)

    table.cell(dash, 0, 6, i_tf5,  text_color=color.white, text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 1, 6, f_trendLabel(tf5_trend),  text_color=color.white, text_size=cellSize, bgcolor=f_trendClr(tf5_trend),  text_halign=text.align_center)
    table.cell(dash, 2, 6, str.tostring(tf5_rsi, "#.#"),  text_color=f_rsiClr(tf5_rsi),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 3, 6, f_structLabel(tf5_struct), text_color=color.white, text_size=cellSize, bgcolor=f_structClr(tf5_struct), text_halign=text.align_center)
    table.cell(dash, 4, 6, f_volLabel(tf5_volState),  text_color=f_volClr(tf5_volState),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 5, 6, tf5_status, text_color=color.white, text_size=cellSize, bgcolor=f_statusClr(tf5_status), text_halign=text.align_center)

    table.cell(dash, 0, 7, i_tf6,  text_color=color.white, text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 1, 7, f_trendLabel(tf6_trend),  text_color=color.white, text_size=cellSize, bgcolor=f_trendClr(tf6_trend),  text_halign=text.align_center)
    table.cell(dash, 2, 7, str.tostring(tf6_rsi, "#.#"),  text_color=f_rsiClr(tf6_rsi),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 3, 7, f_structLabel(tf6_struct), text_color=color.white, text_size=cellSize, bgcolor=f_structClr(tf6_struct), text_halign=text.align_center)
    table.cell(dash, 4, 7, f_volLabel(tf6_volState),  text_color=f_volClr(tf6_volState),  text_size=cellSize, text_halign=text.align_center)
    table.cell(dash, 5, 7, tf6_status, text_color=color.white, text_size=cellSize, bgcolor=f_statusClr(tf6_status), text_halign=text.align_center)

    if i_showOverall
        overallBg = overallBias == 1 ? color.new(color.green, 30) : overallBias == -1 ? color.new(color.red, 30) : color.new(color.gray, 50)
        table.cell(dash, 0, 8, "OVERALL",  text_color=color.white, text_size=size.small, bgcolor=overallBg, text_halign=text.align_center)
        table.cell(dash, 1, 8, str.tostring(bullCount) + "B/" + str.tostring(bearCount) + "B",  text_color=color.white, text_size=size.small, bgcolor=overallBg, text_halign=text.align_center)
        table.merge_cells(dash, 1, 8, 2, 8)
        table.cell(dash, 3, 8, overallLabel,  text_color=color.white, text_size=size.normal, bgcolor=overallBg, text_halign=text.align_center)
        table.merge_cells(dash, 3, 8, 4, 8)
        table.cell(dash, 5, 8, str.tostring(alignedCount) + "/6 align",  text_color=color.white, text_size=size.small, bgcolor=overallBg, text_halign=text.align_center)

// ============================================================================
//  ALERTS
// ============================================================================

allBull = bullCount == 6
allBear = bearCount == 6
majorityBull = bullCount >= 5
majorityBear = bearCount >= 5

alertcondition(allBull,         title="EV HTF Bias: All TFs Bullish",     message="EV HTF Bias: ALL 6 timeframes are BULLISH. Maximum confluence - only trade long.")
alertcondition(allBear,         title="EV HTF Bias: All TFs Bearish",     message="EV HTF Bias: ALL 6 timeframes are BEARISH. Maximum confluence - only trade short.")
alertcondition(majorityBull,    title="EV HTF Bias: Majority Bullish (5+)", message="EV HTF Bias: 5 or more timeframes BULLISH. Strong long bias.")
alertcondition(majorityBear,    title="EV HTF Bias: Majority Bearish (5+)", message="EV HTF Bias: 5 or more timeframes BEARISH. Strong short bias.")
alertcondition(biasShift,       title="EV HTF Bias: Overall Bias Shifted", message="EV HTF Bias: Overall bias changed. Check the dashboard for the new state.")

// ============================================================================
//  END
// ============================================================================
````
