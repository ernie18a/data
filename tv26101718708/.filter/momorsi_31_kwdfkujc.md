# Momo(RSI) 3.1

- url: https://www.tradingview.com/script/kWdfKUjc-Momo-RSI-3-1/
- type: indicator
- pine_id: PUB;1df85906b4974ddf84ffd1726332f27e
- version: 1.0

## Description

Multi-timeframe RSI indicator. Highlights on the background when all timeframes are aligned which can indicate momentum in one direction.
The difference on this indicator is that it switches the table to your selected symbol.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe RSI", shorttitle="MTF RSI", overlay=false)

// ── UDT ──────────────────────────────────────────────────────────────────────
type TFRow
    string label
    float  value

// ── RSI Settings ────────────────────────────────────────────────────────────
rsiLen    = input.int(14,  "RSI Length", minval=1, group="RSI")
rsiSrc    = input.source(close, "Source", group="RSI")
rsiColor  = input.color(color.black, "RSI Line Color", group="RSI")
bullLevel = input.float(60, "Bullish Threshold", minval=0, maxval=100, step=0.5, group="RSI")
bearLevel = input.float(40, "Bearish Threshold", minval=0, maxval=100, step=0.5, group="RSI")

// ── Timeframe Toggles ───────────────────────────────────────────────────────
show1m  = input.bool(true, "1m",  group="Timeframes")
show5m  = input.bool(true, "5m",  group="Timeframes")
show15m = input.bool(true, "15m", group="Timeframes")
show30m = input.bool(true, "30m", group="Timeframes")
show1h  = input.bool(true, "1h",  group="Timeframes")
show4h  = input.bool(true, "4h",  group="Timeframes")
show1d  = input.bool(true, "1D",  group="Timeframes")
show1w  = input.bool(true, "1W",  group="Timeframes")

// ── RSI Calculations ────────────────────────────────────────────────────────
rsiCurrent = ta.rsi(rsiSrc, rsiLen)
rsi1m      = request.security(syminfo.tickerid, "1",   ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)
rsi5m      = request.security(syminfo.tickerid, "5",   ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)
rsi15m     = request.security(syminfo.tickerid, "15",  ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)
rsi30m     = request.security(syminfo.tickerid, "30",  ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)
rsi1h      = request.security(syminfo.tickerid, "60",  ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)
rsi4h      = request.security(syminfo.tickerid, "240", ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)
rsi1d      = request.security(syminfo.tickerid, "D",   ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)
rsi1w      = request.security(syminfo.tickerid, "W",   ta.rsi(rsiSrc, rsiLen), lookahead=barmerge.lookahead_off)

// ── All-TF threshold alignment ────────────────────────────────────────────────
anyEnabled = show1m or show5m or show15m or show30m or show1h or show4h or show1d or show1w

allBullish = anyEnabled and
     (not show1m  or rsi1m  >= bullLevel) and
     (not show5m  or rsi5m  >= bullLevel) and
     (not show15m or rsi15m >= bullLevel) and
     (not show30m or rsi30m >= bullLevel) and
     (not show1h  or rsi1h  >= bullLevel) and
     (not show4h  or rsi4h  >= bullLevel) and
     (not show1d  or rsi1d  >= bullLevel) and
     (not show1w  or rsi1w  >= bullLevel)

allBearish = anyEnabled and
     (not show1m  or rsi1m  <= bearLevel) and
     (not show5m  or rsi5m  <= bearLevel) and
     (not show15m or rsi15m <= bearLevel) and
     (not show30m or rsi30m <= bearLevel) and
     (not show1h  or rsi1h  <= bearLevel) and
     (not show4h  or rsi4h  <= bearLevel) and
     (not show1d  or rsi1d  <= bearLevel) and
     (not show1w  or rsi1w  <= bearLevel)

// ── RSI Line (current TF, single color) ──────────────────────────────────────
plot(rsiCurrent, "RSI", color=rsiColor, linewidth=2, style=plot.style_line)

// ── Thresholds (dotted) ──────────────────────────────────────────────────────
hline(bullLevel, "Bullish Threshold", color=color.lime, linestyle=hline.style_dotted, linewidth=1)
hline(bearLevel, "Bearish Threshold", color=color.red,  linestyle=hline.style_dotted, linewidth=1)
hline(50,        "Midline",           color=color.gray, linestyle=hline.style_dotted)

// ── Background (only when ALL shown TFs agree) ────────────────────────────────
bgCol = allBullish ? color.new(color.lime, 92) : allBearish ? color.new(color.red, 92) : na
bgcolor(bgCol, title="RSI Background")

// ── Helpers ───────────────────────────────────────────────────────────────────
rsiCol(v) =>
    v >= bullLevel ? color.lime : v <= bearLevel ? color.red : color.white

cellBg(v) =>
    v >= bullLevel ? color.new(color.lime, 75) : v <= bearLevel ? color.new(color.red, 75) : color.new(color.black, 75)

// ── Dynamic Table (only enabled rows shown) ───────────────────────────────────
if barstate.islast
    rows = array.new<TFRow>()
    if show1m
        array.push(rows, TFRow.new("1m",  rsi1m))
    if show5m
        array.push(rows, TFRow.new("5m",  rsi5m))
    if show15m
        array.push(rows, TFRow.new("15m", rsi15m))
    if show30m
        array.push(rows, TFRow.new("30m", rsi30m))
    if show1h
        array.push(rows, TFRow.new("1h",  rsi1h))
    if show4h
        array.push(rows, TFRow.new("4h",  rsi4h))
    if show1d
        array.push(rows, TFRow.new("1D",  rsi1d))
    if show1w
        array.push(rows, TFRow.new("1W",  rsi1w))

    n = array.size(rows)
    if n > 0
        tbl = table.new(position.middle_right, 2, n + 1,
             bgcolor=color.new(color.black, 75),
             border_width=1, border_color=color.new(color.gray, 70),
             frame_width=1,  frame_color=color.new(color.gray, 50))

        table.cell(tbl, 0, 0, "TF",  text_color=color.silver, text_size=size.small, bgcolor=color.new(color.gray, 55))
        table.cell(tbl, 1, 0, "RSI", text_color=color.silver, text_size=size.small, bgcolor=color.new(color.gray, 55))

        for i = 0 to n - 1
            r = array.get(rows, i)
            table.cell(tbl, 0, i + 1, r.label,                      text_color=color.gray,      text_size=size.small, bgcolor=color.new(color.black, 75))
            table.cell(tbl, 1, i + 1, str.tostring(r.value, "#.0"), text_color=rsiCol(r.value), text_size=size.small, bgcolor=cellBg(r.value))
````
