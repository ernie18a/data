# CWOP Legacy Model

- url: https://www.tradingview.com/script/OrUQYoX2-CWOP-Legacy-Model/
- type: indicator
- pine_id: PUB;81387b16b2e344b3bf3245f990368a23
- version: 7.0

## Description

It dont get much better than this lehhhhh do it. It dont get much better than this lehhhhh do it.

## Source Code

````pine
//@version=5
indicator("CWOP Legacy Pro []", overlay=true)

// === HIDDEN FIXED LENGTHS ===
_lenE = 40
_lenS = 25

// === SOURCE ===
_src = (high + low + close) / 3

// === EMA (CUSTOM) ===
_alpha = 2.0 / (_lenE + 1)
var float _ema = na
_ema := na(_ema[1]) ? _src : _alpha * _src + (1 - _alpha) * _ema[1]

// === SMA ===
_sma = ta.sma(_src, _lenS)

// === VWAP + ATR ===
_vwap = ta.vwap(close)
_atr  = ta.atr(14)

// === CANDLE STRUCTURE ===
_rng  = high - low
_body = math.abs(close - open)

_ratio = _rng > 0 ? _body / _rng : 0.0
_pct   = _rng / low * 100.0

_valid = _pct >= 1.0 and _ratio >= 0.25

// === CROSS LOGIC (SCRAMBLED STYLE) ===
_crossE = (low - _ema) * (high - _ema) <= 0
_crossV = (low - _vwap) * (high - _vwap) <= 0
_crossS = (low - _sma) * (high - _sma) <= 0

_crossES = ta.crossover(_ema, _sma)

// === SIGNAL BUILD ===
_sig3 = _valid and _crossE and _crossV and _crossS
_sig2 = _valid and _crossE and _crossV and not _sig3
_sig1 = _valid and _crossES

// === DELAY ENGINE ===
var int _b = na
var int _t = 0
var float _l = na

if _sig3
    _b := bar_index
    _t := 3
    _l := low
else if _sig2
    _b := bar_index
    _t := 2
    _l := low
else if _sig1
    _b := bar_index
    _t := 1
    _l := low

_ready = not na(_b) and (bar_index - _b >= 4)

// === FINAL SIGNAL ===
_fire = _ready and _t > 0

if _fire
    _txt = _t == 3 ? "A++" : _t == 2 ? "A+" : "A"
    label.new(_b, _l, _txt, style=label.style_label_up, color=color.new(#FF5F1F, 0), textcolor=color.white)
````
