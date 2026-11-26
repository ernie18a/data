# ADR% + ATR/Price %

- url: https://www.tradingview.com/script/ENNYh8Lk-ADR-ATR-Price/
- type: indicator
- pine_id: PUB;6647fc1ec7024f038e8a791ac109d9cc
- version: 1.0

## Description

ADR% + ATR/Price % — Dual Volatility Reading
Two complementary volatility measures in one pane, with a live legend showing current readings.
ADR% (Average Daily Range %) — The classic equity trader's volatility filter. Calculates the average ratio of daily high to daily low over N days (default 20), expressed as a percentage. Always uses daily data regardless of your chart timeframe. A stock with ADR% of 5 typically moves ~5% intraday. Popularized by traders like Qullamaggie and Pradeep Bonde as a screening tool — if ADR% is too low, the stock isn't moving enough to be worth trading.
ATR / Price % — Standard ATR (default 14) divided by current close, expressed as a percentage. Unlike ADR%, this adapts to your chart timeframe — on a 4H chart you get 4H ATR%, on daily you get daily ATR%. Also captures gaps via true range, which ADR% misses. Useful for cross-instrument position sizing and risk normalization.
Why both?

ADR% gives you the daily "is this thing moving" read, frozen to daily regardless of chart.
ATR/Price% gives you the timeframe-aware volatility you're actually trading on.
On a daily chart they'll track closely. Drop to lower timeframes and the divergence shows how much of the daily range your timeframe is capturing.

Features

Independent length settings for each indicator
Toggle either line on/off
Customizable colors
On-pane legend with live values and parameters (position configurable: top/bottom × left/right)
Daily security calls use lookahead_off to prevent repainting

Use cases

Stock screening: filter for ADR% above some threshold (e.g. > 4) to ensure tradeable range
Position sizing: use ATR/Price% to normalize risk across instruments at different prices
Timeframe selection: compare the two to gauge whether your execution timeframe captures enough of the daily move
Volatility regime detection: watch for expansion/contraction in both measures

Works on any market — equities, crypto, futures, FX. Built in Pine v5.

## Source Code

````pine
//@version=5
indicator("ADR% + ATR/Price %", overlay=false, precision=3)

// ─── Inputs ──────────────────────────────────────────────
adrLength   = input.int(20, "ADR Length (days)", minval=1, group="ADR%")
showADR     = input.bool(true, "Show ADR%", group="ADR%")
adrColor    = input.color(color.orange, "ADR% Color", group="ADR%")

atrLength   = input.int(14, "ATR Length", minval=1, group="ATR / Price %")
showATR     = input.bool(true, "Show ATR/Price %", group="ATR / Price %")
atrColor    = input.color(color.blue, "ATR/Price Color", group="ATR / Price %")

showLegend  = input.bool(true, "Show Legend", group="Display")
legendPos   = input.string("top_right", "Legend Position", 
     options=["top_left", "top_right", "bottom_left", "bottom_right"], group="Display")

// ─── ADR% (Average Daily Range, always daily) ────────────
dhigh = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_off)
dlow  = request.security(syminfo.tickerid, "D", low,  lookahead=barmerge.lookahead_off)
adr   = 100 * (ta.sma(dhigh / dlow, adrLength) - 1)

// ─── ATR / Price % (uses chart timeframe) ────────────────
atrPct = (ta.atr(atrLength) / close) * 100

// ─── Plots ───────────────────────────────────────────────
plot(showADR ? adr    : na, title="ADR%",          color=adrColor, linewidth=2)
plot(showATR ? atrPct : na, title="ATR / Price %", color=atrColor, linewidth=1)
hline(0, "Zero", color=color.new(color.gray, 50))

// ─── Legend ──────────────────────────────────────────────
posMap(p) =>
    p == "top_left"     ? position.top_left :
     p == "top_right"    ? position.top_right :
     p == "bottom_left"  ? position.bottom_left : position.bottom_right

var table legend = table.new(posMap(legendPos), 2, 3, 
     bgcolor=color.new(color.black, 80), border_width=1, border_color=color.new(color.gray, 50))

if showLegend and barstate.islast
    table.clear(legend, 0, 0, 1, 2)
    // Header
    table.cell(legend, 0, 0, "Indicator", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    table.cell(legend, 1, 0, "Value",     text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 70))
    // ADR row
    if showADR
        table.cell(legend, 0, 1, "■ ADR% (" + str.tostring(adrLength) + "d, Daily)", 
             text_color=adrColor, text_size=size.small)
        table.cell(legend, 1, 1, str.tostring(adr, "#.###") + "%", 
             text_color=adrColor, text_size=size.small)
    // ATR row
    if showATR
        table.cell(legend, 0, 2, "■ ATR/Price (" + str.tostring(atrLength) + ", " + timeframe.period + ")", 
             text_color=atrColor, text_size=size.small)
        table.cell(legend, 1, 2, str.tostring(atrPct, "#.###") + "%", 
             text_color=atrColor, text_size=size.small)
````
