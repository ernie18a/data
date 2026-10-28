# Buyer and seller Waiting zones

- url: https://www.tradingview.com/script/naCfSlmy-Buyer-and-seller-Waiting-zones/
- type: indicator
- pine_id: PUB;5b99ac8d2a0743d085ab88886af5b991
- version: 1.0

## Description

This scripts helps to identify the liquidity zones

## Source Code

````pine
//@version=6
indicator("MTF Market Structure Table", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────
swingLen = input.int(5, "Swing Lookback Length", minval=2, maxval=20, 
     tooltip="Number of bars left/right to confirm a swing high or swing low.")

tablePos = input.string("top_right", "Table Position", 
     options=["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"])

tableSize = input.string("normal", "Table Size", 
     options=["tiny", "small", "normal", "large"])

show1m  = input.bool(true, "Show 1m",  group="Timeframes")
show5m  = input.bool(true, "Show 5m",  group="Timeframes")
show15m = input.bool(true, "Show 15m", group="Timeframes")
show1h  = input.bool(true, "Show 1H",  group="Timeframes")
show4h  = input.bool(true, "Show 4H",  group="Timeframes")
show1d  = input.bool(true, "Show 1D",  group="Timeframes")

colBullish = input.color(color.new(#26a69a, 0), "Bullish Color", group="Colors")
colBearish = input.color(color.new(#ef5350, 0), "Bearish Color", group="Colors")
colNeutral = input.color(color.new(#787b86, 0), "Neutral Color", group="Colors")
colHeader  = input.color(color.new(#1e222d, 0), "Header Background", group="Colors")

// ─── MARKET STRUCTURE FUNCTION ────────────────────────────────────
f_marketStructure(_len) =>
    _swingHigh = ta.pivothigh(high, _len, _len)
    _swingLow  = ta.pivotlow(low, _len, _len)

    var float _prevHigh = na
    var float _lastHigh = na
    if not na(_swingHigh)
        _prevHigh := _lastHigh
        _lastHigh := _swingHigh

    var float _prevLow = na
    var float _lastLow = na
    if not na(_swingLow)
        _prevLow := _lastLow
        _lastLow := _swingLow

    bool _isHH = not na(_lastHigh) and not na(_prevHigh) and _lastHigh > _prevHigh
    bool _isHL = not na(_lastLow) and not na(_prevLow) and _lastLow > _prevLow
    bool _isLH = not na(_lastHigh) and not na(_prevHigh) and _lastHigh < _prevHigh
    bool _isLL = not na(_lastLow) and not na(_prevLow) and _lastLow < _prevLow

    float _result = _isHH and _isHL ? 1.0 : _isLH and _isLL ? -1.0 : 0.0
    _result

// ─── REQUEST FROM EACH TIMEFRAME ─────────────────────────────────
struct1m  = request.security(syminfo.tickerid, "1",   f_marketStructure(swingLen)[1], lookahead=barmerge.lookahead_on)
struct5m  = request.security(syminfo.tickerid, "5",   f_marketStructure(swingLen)[1], lookahead=barmerge.lookahead_on)
struct15m = request.security(syminfo.tickerid, "15",  f_marketStructure(swingLen)[1], lookahead=barmerge.lookahead_on)
struct1h  = request.security(syminfo.tickerid, "60",  f_marketStructure(swingLen)[1], lookahead=barmerge.lookahead_on)
struct4h  = request.security(syminfo.tickerid, "240", f_marketStructure(swingLen)[1], lookahead=barmerge.lookahead_on)
struct1d  = request.security(syminfo.tickerid, "D",   f_marketStructure(swingLen)[1], lookahead=barmerge.lookahead_on)

// ─── PRE-COMPUTE LABELS AND COLORS ──────────────────────────────
trend1m  = struct1m  > 0 ? "▲ BULLISH" : struct1m  < 0 ? "▼ BEARISH" : "◆ NEUTRAL"
trend5m  = struct5m  > 0 ? "▲ BULLISH" : struct5m  < 0 ? "▼ BEARISH" : "◆ NEUTRAL"
trend15m = struct15m > 0 ? "▲ BULLISH" : struct15m < 0 ? "▼ BEARISH" : "◆ NEUTRAL"
trend1h  = struct1h  > 0 ? "▲ BULLISH" : struct1h  < 0 ? "▼ BEARISH" : "◆ NEUTRAL"
trend4h  = struct4h  > 0 ? "▲ BULLISH" : struct4h  < 0 ? "▼ BEARISH" : "◆ NEUTRAL"
trend1d  = struct1d  > 0 ? "▲ BULLISH" : struct1d  < 0 ? "▼ BEARISH" : "◆ NEUTRAL"

sig1m  = struct1m  > 0 ? "HH + HL" : struct1m  < 0 ? "LH + LL" : "MIXED"
sig5m  = struct5m  > 0 ? "HH + HL" : struct5m  < 0 ? "LH + LL" : "MIXED"
sig15m = struct15m > 0 ? "HH + HL" : struct15m < 0 ? "LH + LL" : "MIXED"
sig1h  = struct1h  > 0 ? "HH + HL" : struct1h  < 0 ? "LH + LL" : "MIXED"
sig4h  = struct4h  > 0 ? "HH + HL" : struct4h  < 0 ? "LH + LL" : "MIXED"
sig1d  = struct1d  > 0 ? "HH + HL" : struct1d  < 0 ? "LH + LL" : "MIXED"

col1m  = struct1m  > 0 ? colBullish : struct1m  < 0 ? colBearish : colNeutral
col5m  = struct5m  > 0 ? colBullish : struct5m  < 0 ? colBearish : colNeutral
col15m = struct15m > 0 ? colBullish : struct15m < 0 ? colBearish : colNeutral
col1h  = struct1h  > 0 ? colBullish : struct1h  < 0 ? colBearish : colNeutral
col4h  = struct4h  > 0 ? colBullish : struct4h  < 0 ? colBearish : colNeutral
col1d  = struct1d  > 0 ? colBullish : struct1d  < 0 ? colBearish : colNeutral

// ─── TABLE SETUP ─────────────────────────────────────────────────
tPos = tablePos == "top_left" ? position.top_left : tablePos == "bottom_right" ? position.bottom_right : tablePos == "bottom_left" ? position.bottom_left : tablePos == "middle_right" ? position.middle_right : tablePos == "middle_left" ? position.middle_left : position.top_right
txtSize = tableSize == "tiny" ? size.tiny : tableSize == "small" ? size.small : tableSize == "large" ? size.large : size.normal
cellBg = color.new(#1e222d, 80)
tfBg   = color.new(#1e222d, 50)

var table t = table.new(tPos, 3, 8, border_width=1, border_color=color.new(#363a45, 0), bgcolor=color.new(#131722, 0))

if barstate.islast
    table.cell(t, 0, 0, "TF",     text_color=color.white, text_size=txtSize, bgcolor=colHeader, text_halign=text.align_center)
    table.cell(t, 1, 0, "Trend",   text_color=color.white, text_size=txtSize, bgcolor=colHeader, text_halign=text.align_center)
    table.cell(t, 2, 0, "Signal",  text_color=color.white, text_size=txtSize, bgcolor=colHeader, text_halign=text.align_center)

    if show1m
        table.cell(t, 0, 1, "1m",    text_color=color.white, text_size=txtSize, bgcolor=tfBg,   text_halign=text.align_center)
        table.cell(t, 1, 1, trend1m,  text_color=col1m,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)
        table.cell(t, 2, 1, sig1m,    text_color=col1m,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)

    if show5m
        table.cell(t, 0, 2, "5m",    text_color=color.white, text_size=txtSize, bgcolor=tfBg,   text_halign=text.align_center)
        table.cell(t, 1, 2, trend5m,  text_color=col5m,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)
        table.cell(t, 2, 2, sig5m,    text_color=col5m,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)

    if show15m
        table.cell(t, 0, 3, "15m",   text_color=color.white, text_size=txtSize, bgcolor=tfBg,   text_halign=text.align_center)
        table.cell(t, 1, 3, trend15m, text_color=col15m,      text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)
        table.cell(t, 2, 3, sig15m,   text_color=col15m,      text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)

    if show1h
        table.cell(t, 0, 4, "1H",    text_color=color.white, text_size=txtSize, bgcolor=tfBg,   text_halign=text.align_center)
        table.cell(t, 1, 4, trend1h,  text_color=col1h,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)
        table.cell(t, 2, 4, sig1h,    text_color=col1h,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)

    if show4h
        table.cell(t, 0, 5, "4H",    text_color=color.white, text_size=txtSize, bgcolor=tfBg,   text_halign=text.align_center)
        table.cell(t, 1, 5, trend4h,  text_color=col4h,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)
        table.cell(t, 2, 5, sig4h,    text_color=col4h,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)

    if show1d
        table.cell(t, 0, 6, "1D",    text_color=color.white, text_size=txtSize, bgcolor=tfBg,   text_halign=text.align_center)
        table.cell(t, 1, 6, trend1d,  text_color=col1d,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)
        table.cell(t, 2, 6, sig1d,    text_color=col1d,       text_size=txtSize, bgcolor=cellBg, text_halign=text.align_center)
````
