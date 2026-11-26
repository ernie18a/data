# SMC Premium + VNP Signal System [v3]

- url: https://www.tradingview.com/script/RPF4G6YU/
- type: indicator
- pine_id: PUB;bd35ae2566534c9fa3f8c59e993c7253
- version: 1.0

## Description

phiên bản V1

đây là phiên bản đầu tiên
dành cho chiến lược break out
các nhà giao dịch future

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © SMC Premium + VNP Signal System — v3.1 (Pine Script v6 compliant)
//@version=6
indicator("SMC Premium + VNP Signal System [v3]", overlay=true,
     max_labels_count=100, max_lines_count=150, max_boxes_count=100)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
grpSIG = "➞ Signal Settings"
i_period   = input.int(14,    "Swing Period",     minval=5, maxval=50, group=grpSIG, inline="s1")
i_priceTyp = input.string("Wicks","Price Type",   options=["Wicks","Body"], group=grpSIG, inline="s1")
i_htfTF    = input.timeframe("240","HTF Bias TF", group=grpSIG)

grpRR = "➞ Risk/Reward"
i_RR       = input.float(2.0,  "RR Ratio",       step=0.5, minval=0.5, group=grpRR, inline="r1")
i_atrLen   = input.int(14,     "ATR Length",      minval=5,             group=grpRR, inline="r1")
i_atrMult  = input.float(1.5,  "ATR Multiplier",  step=0.1, minval=0.5, group=grpRR, inline="r1")
i_slType   = input.string("Close","SL Trigger",   options=["Close","High/Low"], group=grpRR)
i_chosenTP = input.string("TP2","Active TP Exit", options=["TP1","TP2","TP3","TP4"], group=grpRR)

grpVIS = "➞ Visuals"
i_showET   = input.bool(true, "ET Line",    group=grpVIS, inline="v1")
i_showSL   = input.bool(true, "SL Line",    group=grpVIS, inline="v1")
i_showTP   = input.bool(true, "TP Lines",   group=grpVIS, inline="v1")
i_showPX   = input.bool(true, "Prices",     group=grpVIS, inline="v1")
i_showLab  = input.bool(true, "Signals",    group=grpVIS, inline="v2")
i_showOB   = input.bool(true, "OB Zones",   group=grpVIS, inline="v2")
i_showFVG  = input.bool(true, "FVG Zones",  group=grpVIS, inline="v2")
i_showStr  = input.bool(true, "Structure",  group=grpVIS, inline="v2")

grpCOL = "➞ Colors"
cBull  = input.color(color.rgb(2,133,69),  "Bull", group=grpCOL, inline="c1")
cBear  = input.color(color.rgb(246,7,7),   "Bear", group=grpCOL, inline="c1")
cEntry = input.color(color.orange,          "Entry",group=grpCOL, inline="c1")

// ═══════════════════════════════════════════════════════════════
// VAR — Trade State
// ═══════════════════════════════════════════════════════════════
var bool  v_TradeON = false
var bool  v_IsLong  = false
var bool  v_IsShort = false
var float v_ET  = na, var float v_SL  = na
var float v_TP1 = na, var float v_TP2 = na
var float v_TP3 = na, var float v_TP4 = na

var line  l_ET  = na, var line  l_SL  = na
var line  l_TP1 = na, var line  l_TP2 = na
var line  l_TP3 = na, var line  l_TP4 = na
var label lb_ET = na, var label lb_SL = na
var label lb_T1 = na, var label lb_T2 = na
var label lb_T3 = na, var label lb_T4 = na

var bool  v_phA = false, var float v_pH = na
var bool  v_plA = false, var float v_pL = na
var bool  v_HBk = false
var int   v_W   = 0
var int   v_L   = 0
var table v_tab = table.new(position.bottom_right, 2, 7,
     bgcolor=color.new(color.gray,80), border_color=color.gray, border_width=1)

// ═══════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════
_atr    = ta.atr(i_atrLen)
_ema21  = ta.ema(close, 21)
_ema55  = ta.ema(close, 55)
_ema200 = ta.ema(close, 200)
_rsi    = ta.rsi(close, 14)
[_diP, _diM, _adx] = ta.dmi(14, 14)
[_macdL, _macdS, _macdH] = ta.macd(close, 12, 26, 9)
_avgVol = ta.sma(volume, 20)

_htfE21 = request.security(syminfo.tickerid, i_htfTF, ta.ema(close,21))
_htfE55 = request.security(syminfo.tickerid, i_htfTF, ta.ema(close,55))
_htfBull = _htfE21 > _htfE55 and close > _htfE55
_htfBear = _htfE21 < _htfE55 and close < _htfE55

_trendBull = _ema21 > _ema55 and close > _ema200 and _htfBull
_trendBear = _ema21 < _ema55 and close < _ema200 and _htfBear

_adxStr  = _adx > 25
_diBull  = _diP > _diM
_diBear  = _diM > _diP
_rsiBuy  = _rsi > 40 and _rsi < 65
_rsiSell = _rsi > 35 and _rsi < 60
_macdBull = _macdL > _macdS and _macdH > 0
_macdBear = _macdL < _macdS and _macdH < 0
_highVol  = volume > _avgVol * 1.2
_atrExp   = _atr > ta.sma(_atr, 20) * 0.85
_bodyBull = close > open and (close - open) > _atr * 0.3
_bodyBear = close < open and (open - close) > _atr * 0.3

_fvgBull = low[0]  > high[2] and close[1] > high[2]
_fvgBear = high[0] < low[2]  and close[1] < low[2]

_hh = ta.highest(high[1], i_period)
_ll = ta.lowest (low[1],  i_period)
_sweepH = high > _hh and close < _hh
_sweepL = low  < _ll and close > _ll

// Confluence scores — each on one line, no continuation
_lC1   = (_trendBull?15:0) + (_adxStr?10:0) + (_diBull?10:0)  + (_rsiBuy?10:0)  + (_macdBull?15:0)
_lC2   = (_highVol?10:0)   + (_atrExp?5:0)  + (_sweepL?10:0)  + (_fvgBull?10:0) + (_bodyBull?5:0)
_lConf = _lC1 + _lC2

_sC1   = (_trendBear?15:0) + (_adxStr?10:0) + (_diBear?10:0)  + (_rsiSell?10:0) + (_macdBear?15:0)
_sC2   = (_highVol?10:0)   + (_atrExp?5:0)  + (_sweepH?10:0)  + (_fvgBear?10:0) + (_bodyBear?5:0)
_sConf = _sC1 + _sC2

// ═══════════════════════════════════════════════════════════════
// SIGNAL DETECTION — SMC HTF Reversal Model
// ═══════════════════════════════════════════════════════════════
_useWicks = i_priceTyp == "Wicks"
_scrH = _useWicks ? high : close
_scrL = _useWicks ? low  : close

_PH = ta.pivothigh(high, i_period, i_period)
_PL = ta.pivotlow (low,  i_period, i_period)

if ta.change(fixnan(_PH)) != 0
    v_pH := _PH
    v_phA := true

if ta.change(fixnan(_PL)) != 0
    v_pL := _PL
    v_plA := true

_confGate  = 60
_buyBase   = _scrH > nz(v_pH) and v_phA and not v_TradeON
_buyConf   = _lConf >= _confGate and _trendBull and _adxStr
_rawBUY    = _buyBase and _buyConf

_sellBase  = _scrL < nz(v_pL) and v_plA and not v_TradeON
_sellConf  = _sConf >= _confGate and _trendBear and _adxStr
_rawSELL   = _sellBase and _sellConf

// Structure lines (BOS / CHoCH)
if _rawBUY and not v_TradeON and i_showStr
    _pIdx = bar_index - i_period
    line.new(_pIdx, v_pH, bar_index, v_pH, color=cBull, style=line.style_dashed, width=1)
    label.new(math.floor((_pIdx+bar_index)/2), v_pH, v_HBk?"BOS":"CHoCH",
         color=color.new(color.black,100), textcolor=cBull, size=size.tiny)
    v_phA := false
    v_HBk := true

if _rawSELL and not v_TradeON and i_showStr
    _pIdx = bar_index - i_period
    line.new(_pIdx, v_pL, bar_index, v_pL, color=cBear, style=line.style_dashed, width=1)
    label.new(math.floor((_pIdx+bar_index)/2), v_pL, v_HBk?"CHoCH":"BOS",
         color=color.new(color.black,100), textcolor=cBear, size=size.tiny,
         style=label.style_label_up)
    v_plA := false
    v_HBk := false

// ═══════════════════════════════════════════════════════════════
// ADAPTIVE SL + TP LEVELS
// ═══════════════════════════════════════════════════════════════
_atrBase   = ta.rma(ta.tr(true), i_atrLen)
_adaptMult = _adx > 35 ? i_atrMult * 1.2 : _adx > 25 ? i_atrMult : i_atrMult * 0.8
_atrRMA    = _atrBase * _adaptMult
_slDL      = math.abs(close - (low  - _atrRMA))
_slDS      = math.abs(close - (high + _atrRMA))

// Price string helper (pure function - returns value, OK in v6)
_px(v) => i_showPX ? str.tostring(math.round_to_mintick(v)) : ""
_fd(c) => color.new(c, 70)

// ═══════════════════════════════════════════════════════════════
// TRADE ENTRY — BUY (all global var modifications inline)
// ═══════════════════════════════════════════════════════════════
if _rawBUY and not v_TradeON
    // Delete previous lines
    line.delete(l_ET)
    line.delete(l_SL)
    line.delete(l_TP1)
    line.delete(l_TP2)
    line.delete(l_TP3)
    line.delete(l_TP4)
    // Set levels
    v_ET  := close
    v_SL  := close - _slDL
    v_TP1 := close + i_RR * _slDL
    v_TP2 := close + i_RR * _slDL * 2
    v_TP3 := close + i_RR * _slDL * 3
    v_TP4 := close + i_RR * _slDL * 4
    v_TradeON := true
    v_IsLong  := true
    v_IsShort := false
    // Draw ET line
    if i_showET
        l_ET  := line.new(bar_index, v_ET, bar_index+1, v_ET, color=cEntry, style=line.style_dashed, width=2)
        lb_ET := label.new(bar_index+1, v_ET, "ET: " + _px(v_ET), color=cEntry, style=label.style_label_left, textcolor=color.white, size=size.small)
    // Draw SL line
    if i_showSL
        l_SL  := line.new(bar_index, v_SL, bar_index+1, v_SL, color=cBear, style=line.style_solid, width=2)
        lb_SL := label.new(bar_index+1, v_SL, "SL: " + _px(v_SL), color=cBear, style=label.style_label_left, textcolor=color.white, size=size.small)
    // Draw TP lines
    if i_showTP
        l_TP1 := line.new(bar_index, v_TP1, bar_index+1, v_TP1, color=cBull, style=line.style_dotted, width=2)
        l_TP2 := line.new(bar_index, v_TP2, bar_index+1, v_TP2, color=cBull, style=line.style_dotted, width=2)
        l_TP3 := line.new(bar_index, v_TP3, bar_index+1, v_TP3, color=cBull, style=line.style_dotted, width=2)
        l_TP4 := line.new(bar_index, v_TP4, bar_index+1, v_TP4, color=cBull, style=line.style_dotted, width=2)
        lb_T1 := label.new(bar_index+1, v_TP1, "TP 1: " + _px(v_TP1), color=cBull, style=label.style_label_left, textcolor=color.white, size=size.small)
        lb_T2 := label.new(bar_index+1, v_TP2, "TP 2: " + _px(v_TP2), color=cBull, style=label.style_label_left, textcolor=color.white, size=size.small)
        lb_T3 := label.new(bar_index+1, v_TP3, "TP 3: " + _px(v_TP3), color=cBull, style=label.style_label_left, textcolor=color.white, size=size.small)
        lb_T4 := label.new(bar_index+1, v_TP4, "TP 4: " + _px(v_TP4), color=cBull, style=label.style_label_left, textcolor=color.white, size=size.small)
    // Signal label
    if i_showLab
        _fl = (_macdBull?" ✦MACD":"") + (_sweepL?" ✦Sweep":"") + (_fvgBull?" ✦FVG":"")
        label.new(bar_index, low, "▲ BUY " + str.tostring(math.round(_lConf)) + "%" + "\nRR 1:" + str.tostring(i_RR) + _fl, style=label.style_label_up, color=cBull, textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// TRADE ENTRY — SELL
// ═══════════════════════════════════════════════════════════════
if _rawSELL and not v_TradeON
    line.delete(l_ET)
    line.delete(l_SL)
    line.delete(l_TP1)
    line.delete(l_TP2)
    line.delete(l_TP3)
    line.delete(l_TP4)
    v_ET  := close
    v_SL  := close + _slDS
    v_TP1 := close - i_RR * _slDS
    v_TP2 := close - i_RR * _slDS * 2
    v_TP3 := close - i_RR * _slDS * 3
    v_TP4 := close - i_RR * _slDS * 4
    v_TradeON := true
    v_IsLong  := false
    v_IsShort := true
    if i_showET
        l_ET  := line.new(bar_index, v_ET, bar_index+1, v_ET, color=cEntry, style=line.style_dashed, width=2)
        lb_ET := label.new(bar_index+1, v_ET, "ET: " + _px(v_ET), color=cEntry, style=label.style_label_left, textcolor=color.white, size=size.small)
    if i_showSL
        l_SL  := line.new(bar_index, v_SL, bar_index+1, v_SL, color=cBear, style=line.style_solid, width=2)
        lb_SL := label.new(bar_index+1, v_SL, "SL: " + _px(v_SL), color=cBear, style=label.style_label_left, textcolor=color.white, size=size.small)
    if i_showTP
        l_TP1 := line.new(bar_index, v_TP1, bar_index+1, v_TP1, color=cBear, style=line.style_dotted, width=2)
        l_TP2 := line.new(bar_index, v_TP2, bar_index+1, v_TP2, color=cBear, style=line.style_dotted, width=2)
        l_TP3 := line.new(bar_index, v_TP3, bar_index+1, v_TP3, color=cBear, style=line.style_dotted, width=2)
        l_TP4 := line.new(bar_index, v_TP4, bar_index+1, v_TP4, color=cBear, style=line.style_dotted, width=2)
        lb_T1 := label.new(bar_index+1, v_TP1, "TP 1: " + _px(v_TP1), color=cBear, style=label.style_label_left, textcolor=color.white, size=size.small)
        lb_T2 := label.new(bar_index+1, v_TP2, "TP 2: " + _px(v_TP2), color=cBear, style=label.style_label_left, textcolor=color.white, size=size.small)
        lb_T3 := label.new(bar_index+1, v_TP3, "TP 3: " + _px(v_TP3), color=cBear, style=label.style_label_left, textcolor=color.white, size=size.small)
        lb_T4 := label.new(bar_index+1, v_TP4, "TP 4: " + _px(v_TP4), color=cBear, style=label.style_label_left, textcolor=color.white, size=size.small)
    if i_showLab
        _fl = (_macdBear?" ✦MACD":"") + (_sweepH?" ✦Sweep":"") + (_fvgBear?" ✦FVG":"")
        label.new(bar_index, high, "▼ SELL " + str.tostring(math.round(_sConf)) + "%" + "\nRR 1:" + str.tostring(i_RR) + _fl, style=label.style_label_down, color=cBear, textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// EXTEND LINES — Each on its own line (no comma syntax)
// ═══════════════════════════════════════════════════════════════
if v_TradeON
    if i_showET and not na(l_ET)
        line.set_x2(l_ET, bar_index)
        label.set_x(lb_ET, bar_index + 1)
    if i_showSL and not na(l_SL)
        line.set_x2(l_SL, bar_index)
        label.set_x(lb_SL, bar_index + 1)
    if i_showTP and not na(l_TP1)
        line.set_x2(l_TP1, bar_index)
        line.set_x2(l_TP2, bar_index)
        line.set_x2(l_TP3, bar_index)
        line.set_x2(l_TP4, bar_index)
        label.set_x(lb_T1, bar_index + 1)
        label.set_x(lb_T2, bar_index + 1)
        label.set_x(lb_T3, bar_index + 1)
        label.set_x(lb_T4, bar_index + 1)

// ═══════════════════════════════════════════════════════════════
// EXIT LOGIC — TP or SL Hit
// ═══════════════════════════════════════════════════════════════
_actTP = switch i_chosenTP
    "TP1" => v_TP1
    "TP2" => v_TP2
    "TP3" => v_TP3
    =>       v_TP4

_slClose = i_slType == "Close"

if v_IsLong and v_TradeON
    if high >= _actTP
        v_W       += 1
        v_TradeON := false
        v_IsLong  := false
        line.delete(l_ET)
        line.delete(l_SL)
        line.delete(l_TP1)
        line.delete(l_TP2)
        line.delete(l_TP3)
        line.delete(l_TP4)
        if not na(lb_ET)
            label.set_color(lb_ET, _fd(cEntry))
            label.set_color(lb_SL, _fd(cBear))
            label.set_color(lb_T1, _fd(cBull))
            label.set_color(lb_T2, _fd(cBull))
            label.set_color(lb_T3, _fd(cBull))
            label.set_color(lb_T4, _fd(cBull))
    else if (_slClose ? close : low) <= v_SL
        v_L       += 1
        v_TradeON := false
        v_IsLong  := false
        line.delete(l_ET)
        line.delete(l_SL)
        line.delete(l_TP1)
        line.delete(l_TP2)
        line.delete(l_TP3)
        line.delete(l_TP4)
        if not na(lb_ET)
            label.set_color(lb_ET, _fd(cEntry))
            label.set_color(lb_SL, _fd(cBear))
            label.set_color(lb_T1, _fd(cBear))
            label.set_color(lb_T2, _fd(cBear))
            label.set_color(lb_T3, _fd(cBear))
            label.set_color(lb_T4, _fd(cBear))

if v_IsShort and v_TradeON
    if low <= _actTP
        v_W       += 1
        v_TradeON := false
        v_IsShort := false
        line.delete(l_ET)
        line.delete(l_SL)
        line.delete(l_TP1)
        line.delete(l_TP2)
        line.delete(l_TP3)
        line.delete(l_TP4)
        if not na(lb_ET)
            label.set_color(lb_ET, _fd(cEntry))
            label.set_color(lb_SL, _fd(cBear))
            label.set_color(lb_T1, _fd(cBull))
            label.set_color(lb_T2, _fd(cBull))
            label.set_color(lb_T3, _fd(cBull))
            label.set_color(lb_T4, _fd(cBull))
    else if (_slClose ? close : high) >= v_SL
        v_L       += 1
        v_TradeON := false
        v_IsShort := false
        line.delete(l_ET)
        line.delete(l_SL)
        line.delete(l_TP1)
        line.delete(l_TP2)
        line.delete(l_TP3)
        line.delete(l_TP4)
        if not na(lb_ET)
            label.set_color(lb_ET, _fd(cEntry))
            label.set_color(lb_SL, _fd(cBear))
            label.set_color(lb_T1, _fd(cBear))
            label.set_color(lb_T2, _fd(cBear))
            label.set_color(lb_T3, _fd(cBear))
            label.set_color(lb_T4, _fd(cBear))

// ═══════════════════════════════════════════════════════════════
// ICT VISUALS — OB + FVG (native, no library)
// ═══════════════════════════════════════════════════════════════
if _fvgBull and i_showFVG
    box.new(bar_index-2, high[2], bar_index, low[0], bgcolor=color.new(cBull,88), border_color=color.new(cBull,60))

if _fvgBear and i_showFVG
    box.new(bar_index-2, low[2], bar_index, high[0], bgcolor=color.new(cBear,88), border_color=color.new(cBear,60))

var box   _obBB = na
var float _obBL = na
var box   _obBrB = na
var float _obBrT = na

if close[1] < open[1] and close > high[1] and (close-open) > _atr*0.5 and i_showOB
    box.delete(_obBB)
    _obBL := close[1]
    _obBB := box.new(bar_index-1, open[1], bar_index, close[1], bgcolor=color.new(cBull,85), border_color=color.new(cBull,50), text="Bull OB", text_size=size.tiny, text_color=cBull)

if close[1] > open[1] and close < low[1] and (open-close) > _atr*0.5 and i_showOB
    box.delete(_obBrB)
    _obBrT := open[1]
    _obBrB := box.new(bar_index-1, close[1], bar_index, open[1], bgcolor=color.new(cBear,85), border_color=color.new(cBear,50), text="Bear OB", text_size=size.tiny, text_color=cBear)

if i_showOB
    if not na(_obBB)
        box.set_right(_obBB, bar_index)
    if not na(_obBrB)
        box.set_right(_obBrB, bar_index)

if not na(_obBL) and close < _obBL
    box.delete(_obBB)
    _obBB := na
    _obBL := na

if not na(_obBrT) and close > _obBrT
    box.delete(_obBrB)
    _obBrB := na
    _obBrT := na

// ═══════════════════════════════════════════════════════════════
// EMA PLOTS
// ═══════════════════════════════════════════════════════════════
plot(_ema21,  "EMA 21",  color=color.new(color.blue,   40), linewidth=1)
plot(_ema55,  "EMA 55",  color=color.new(color.orange, 40), linewidth=1)
plot(_ema200, "EMA 200", color=color.new(color.white,  20), linewidth=2)
plot(_htfBull ? _htfE21 : na, "HTF Bull", color=color.new(cBull,30), linewidth=1, style=plot.style_stepline)
plot(_htfBear ? _htfE21 : na, "HTF Bear", color=color.new(cBear,30), linewidth=1, style=plot.style_stepline)

// ═══════════════════════════════════════════════════════════════
// WIN/LOSS TABLE
// ═══════════════════════════════════════════════════════════════
_total  = v_W + v_L
_winPct = _total > 0 ? math.round(v_W / _total * 100, 1) : 0.0
_pCol   = _winPct >= 55 ? color.rgb(8,192,155) : _winPct >= 45 ? color.yellow : color.rgb(246,7,7)

if barstate.islast
    table.cell(v_tab, 0, 0, "Win Trades",  text_color=color.rgb(163,163,177), text_size=size.small)
    table.cell(v_tab, 1, 0, str.tostring(v_W), text_color=color.rgb(8,192,155), text_size=size.small)
    table.cell(v_tab, 0, 1, "Loss Trades", text_color=color.rgb(163,163,177), text_size=size.small)
    table.cell(v_tab, 1, 1, str.tostring(v_L), text_color=color.rgb(254,127,16), text_size=size.small)
    table.cell(v_tab, 0, 2, "Win Rate",    text_color=color.rgb(163,163,177), text_size=size.small)
    table.cell(v_tab, 1, 2, str.tostring(_winPct) + "%", text_color=_pCol, text_size=size.small)
    table.cell(v_tab, 0, 3, "Active TP",   text_color=color.rgb(163,163,177), text_size=size.small)
    table.cell(v_tab, 1, 3, i_chosenTP,    text_color=color.yellow, text_size=size.small)
    table.cell(v_tab, 0, 4, "Open Trade",  text_color=color.rgb(163,163,177), text_size=size.small)
    table.cell(v_tab, 1, 4, v_TradeON ? (v_IsLong ? "LONG ▲" : "SHORT ▼") : "None", text_color=v_IsLong ? color.rgb(8,192,155) : v_IsShort ? cBear : color.gray, text_size=size.small)
    table.cell(v_tab, 0, 5, "HTF Bias",    text_color=color.rgb(163,163,177), text_size=size.small)
    table.cell(v_tab, 1, 5, _htfBull ? "BULL ▲" : _htfBear ? "BEAR ▼" : "NEUTRAL", text_color=_htfBull ? cBull : _htfBear ? cBear : color.gray, text_size=size.small)
    table.cell(v_tab, 0, 6, "Model",       text_color=color.rgb(163,163,177), text_size=size.small)
    table.cell(v_tab, 1, 6, "SMC HTF Rev", text_color=color.rgb(100,181,246), text_size=size.small)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(_rawBUY,  "SMC BUY Signal",  "SMC BUY | {{ticker}} {{interval}} | {{close}}")
alertcondition(_rawSELL, "SMC SELL Signal", "SMC SELL | {{ticker}} {{interval}} | {{close}}")
````
