# Miggoy's regime overlay

- url: https://www.tradingview.com/script/oQQabyQR-Miggoy-s-regime-overlay/
- type: indicator
- pine_id: PUB;8da87c5cad894e64a44a67912bda7df9
- version: 2.0

## Description

A market-regime dashboard that scores the overall environment for swing trading and colors your chart background green, yellow, or red so you can tell at a glance whether conditions favor putting on risk.
The script grades three independent conditions, each worth one point:
1 · Price Structure — SPY stacked above its 10 EMA, with the 10 EMA above the 20 EMA. Confirms a clean short-term uptrend with price leading.
2 · Net 52-Week Highs minus Lows — More new highs than new lows across the market. A positive read means broad participation rather than a narrow rally.
3 · Volatility — Fear draining out of the tape, defined as VIX below its 20 EMA, and the 20 EMA below the 50 EMA (50 > 20 EMA > VIX). Signals a calm, trending environment rather than a spiking, defensive one.
Regime scoring

3 / 3 → GREEN — Full risk per trade, full aggression.
2 / 3 → YELLOW — Half risk, best setups only.
0–1 / 3 → RED — List building, no trades.

The chart background tints to match the regime, and a table summarizes each condition with a pass/fail check, the underlying values, and the suggested action. A "days in regime" counter tracks how long the current state has held.
Notes

All conditions are calculated on the daily timeframe regardless of your chart's timeframe, so the regime read stays consistent whether you're looking at a daily or an intraday chart.
Calculations use confirmed daily data with no lookahead, so the indicator does not repaint.
The high/low inputs default to YRHI.US and YRLO.US (52-week new highs and new lows). Adjust the symbols in settings if your data provider uses different tickers.
Alerts are included for each regime transition (green, yellow, red).

This is a decision-support tool for gauging market conditions, not a buy/sell signal generator. It tells you whether the environment supports trading, not what to trade.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0

//@version=6
indicator("GHP Regime Overlay", overlay=true)

// ─── INPUTS ───
ema10Len  = input.int(10,  "EMA 10 Length")
ema20Len  = input.int(20,  "EMA 20 Length")
spySymbol  = input.symbol("AMEX:SPY", "SPY Symbol")
vixSymbol  = input.symbol("TVC:VIX", "VIX Symbol")
yrhiSymbol = input.symbol("YRHI.US", "YRHI Symbol (52w Highs)")
yrloSymbol = input.symbol("YRLO.US", "YRLO Symbol (52w Lows)")
tablePos = input.string("bottom_left", "Table Position", options=["top_left","top_right","bottom_left","bottom_right"])

// ─── SPY-anchored calc function ───
spyData() =>
    e10 = ta.ema(close, ema10Len)
    e20 = ta.ema(close, ema20Len)
    [close, e10, e20]

// ─── DAILY DATA (anti-repaint: current bar, no lookahead) — ALL anchored to SPY ───
[d_spyClose, d_spy10, d_spy20] = request.security(spySymbol, "D", spyData(), lookahead=barmerge.lookahead_off)

[d_vixClose, d_vix20, d_vix50] = request.security(vixSymbol, "D", [close, ta.ema(close, 20), ta.ema(close, 50)], lookahead=barmerge.lookahead_off)

d_yrhi  = request.security(yrhiSymbol, "D", close, lookahead=barmerge.lookahead_off)
d_yrlo  = request.security(yrloSymbol, "D", close, lookahead=barmerge.lookahead_off)
netHL = nz(d_yrhi) - nz(d_yrlo)

// ─── SCORED CRITERIA (3 points) ───
// Point 1: Price structure — SPY stacked above 10 EMA > 20 EMA
ps1 = d_spyClose > d_spy10 ? 1 : 0
ps2 = d_spy10 > d_spy20    ? 1 : 0
p1 = (ps1 + ps2) == 2 ? 1 : 0

// Point 2: Net 52w highs - lows > 0
p2 = netHL > 0 ? 1 : 0

// Point 3: Volatility — fear draining: 50 EMA > 20 EMA > VIX
vo1 = d_vix20 < d_vix50    ? 1 : 0
vo2 = d_vixClose < d_vix20 ? 1 : 0
p3 = (vo1 + vo2) == 2 ? 1 : 0

totalScore = p1 + p2 + p3

// ─── REGIME ───
// Score: 3 -> green, 2 -> yellow, 0-1 -> red
regime = totalScore >= 3 ? 2 : totalScore == 2 ? 1 : 0

regimeColor = regime == 2 ? color.new(color.green, 85) : regime == 1 ? color.new(color.yellow, 85) : color.new(color.red, 75)
bgcolor(regimeColor)

// ─── DAYS IN REGIME ───
var int daysInRegime = 1
if regime == regime[1]
    daysInRegime += 1
else
    daysInRegime := 1

regimeName = regime == 2 ? "GREEN" : regime == 1 ? "YELLOW" : "RED"

// ─── TABLE ───
posMap = tablePos == "top_left" ? position.top_left : tablePos == "top_right" ? position.top_right : tablePos == "bottom_left" ? position.bottom_left : position.bottom_right

var table t = table.new(posMap, 3, 10, border_width=1, border_color=color.new(color.white, 85), frame_width=2, frame_color=color.new(color.white, 60))

tick(int v) =>
    v == 1 ? "✓" : "✗"

tickCol(int v) =>
    v == 1 ? #4CAF50 : #F44336

if barstate.islast
    headerBg  = regime == 2 ? #1B5E20 : regime == 1 ? #E65100 : #B71C1C
    rowBg1    = #16213E
    rowBg2    = #0F3460
    catBg     = #2C2C54
    white     = color.white
    dim       = color.new(color.white, 30)
    sz        = size.normal
    szL       = size.large

    // Row 0: Regime header
    table.cell(t, 0, 0, "  " + regimeName + "  ", text_color=white, bgcolor=headerBg, text_size=szL)
    table.cell(t, 1, 0, str.tostring(totalScore) + " / 3", text_color=white, bgcolor=headerBg, text_size=szL)
    table.cell(t, 2, 0, str.tostring(daysInRegime) + " days", text_color=white, bgcolor=headerBg, text_size=sz)

    // Row 1: Point 1 header
    table.cell(t, 0, 1, "1 · Price Structure", text_color=white, bgcolor=catBg, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 1, tick(p1), text_color=tickCol(p1), bgcolor=catBg, text_size=sz)
    table.cell(t, 2, 1, "SPY > 10 > 20 EMA", text_color=dim, bgcolor=catBg, text_size=sz)

    table.cell(t, 0, 2, "SPY close > 10 EMA", text_color=white, bgcolor=rowBg1, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 2, tick(ps1), text_color=tickCol(ps1), bgcolor=rowBg1, text_size=sz)
    table.cell(t, 2, 2, "", bgcolor=rowBg1, text_size=sz)

    table.cell(t, 0, 3, "10 EMA > 20 EMA", text_color=white, bgcolor=rowBg2, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 3, tick(ps2), text_color=tickCol(ps2), bgcolor=rowBg2, text_size=sz)
    table.cell(t, 2, 3, "", bgcolor=rowBg2, text_size=sz)

    // Row 4: Point 2 header
    table.cell(t, 0, 4, "2 · Net 52w Highs - Lows", text_color=white, bgcolor=catBg, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 4, tick(p2), text_color=tickCol(p2), bgcolor=catBg, text_size=sz)
    table.cell(t, 2, 4, str.tostring(netHL, "#"), text_color=dim, bgcolor=catBg, text_size=sz)

    // Row 5: Point 3 header
    table.cell(t, 0, 5, "3 · Volatility", text_color=white, bgcolor=catBg, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 5, tick(p3), text_color=tickCol(p3), bgcolor=catBg, text_size=sz)
    table.cell(t, 2, 5, "50 > 20 EMA > VIX", text_color=dim, bgcolor=catBg, text_size=sz)

    table.cell(t, 0, 6, "VIX 20 EMA < 50 EMA", text_color=white, bgcolor=rowBg1, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 6, tick(vo1), text_color=tickCol(vo1), bgcolor=rowBg1, text_size=sz)
    table.cell(t, 2, 6, str.tostring(d_vix20, "#.##") + " / " + str.tostring(d_vix50, "#.##"), text_color=dim, bgcolor=rowBg1, text_size=sz)

    table.cell(t, 0, 7, "VIX < 20 EMA", text_color=white, bgcolor=rowBg2, text_size=sz, text_halign=text.align_left)
    table.cell(t, 1, 7, tick(vo2), text_color=tickCol(vo2), bgcolor=rowBg2, text_size=sz)
    table.cell(t, 2, 7, str.tostring(d_vixClose, "#.##"), text_color=dim, bgcolor=rowBg2, text_size=sz)

    // Row 8: Action
    string action = regime == 2 ? "GREEN · Full risk per trade · Full aggression" : regime == 1 ? "YELLOW · Half risk per trade · Best setups only" : "RED · List building · No trade"
    table.cell(t, 0, 8, action, text_color=white, bgcolor=color.new(headerBg, 20), text_size=sz, text_halign=text.align_left)
    table.merge_cells(t, 0, 8, 2, 8)

// ─── ALERTS ───
alertcondition(regime == 2 and regime[1] != 2, title="Regime → GREEN", message="GHP Regime upgraded to GREEN")
alertcondition(regime == 1 and regime[1] != 1, title="Regime → YELLOW", message="GHP Regime changed to YELLOW")
alertcondition(regime == 0 and regime[1] != 0, title="Regime → RED", message="GHP Regime downgraded to RED")

plot(totalScore, "Score", display=display.status_line)
````
