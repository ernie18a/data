# Caelum Bias Ribbon [JOAT]

- url: https://www.tradingview.com/script/nEe236WO-Caelum-Bias-Ribbon-JOAT/
- type: indicator
- pine_id: PUB;9e4e4542753440ccb04cb9fa2b700d74
- version: 1.0

## Description

[b]Caelum Bias Ribbon [JOAT][/b]

[b]Introduction[/b]

Caelum Bias Ribbon is a multi-timeframe ALMA consensus ribbon. It evaluates whether 15m, 1H, 4H, 1D, and 1W horizons are aligned, mixed, or overheated.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/F6ZH9W4o/[/image]

[b]Core Concepts[/b]

[b]1. ALMA Deviation States[/b]

Each timeframe creates an ALMA center and deviation threshold to classify bullish, bearish, or neutral state.

[b]2. Consensus Voting[/b]

The script counts aligned timeframes to identify broad directional agreement.

[b]3. Overheat Tracking[/b]

Directional runs are counted so stretched multi-timeframe conditions can be marked without predicting reversal.

[b]4. Ribbon Visualization[/b]

Colored ALMA ribbons and fills show agreement without heavy labels.

[pine]
consensus = bullCount >= gate ? 1 : bearCount >= gate ? -1 : 0
[/pine]

[b]Features[/b]

[list]
[*]Five-timeframe ALMA ribbon
[*]Consensus and mixed-state detection
[*]Overheat markers
[*]Consensus candle coloring
[*]Compact dashboard
[/list]

[b]Input Parameters[/b]

[list]
[*]Deviation factor
[*]ALMA length, offset, and sigma
[*]Deviation length
[*]Overheat run threshold
[*]Display toggles
[/list]


[b]How to Use This Script[/b]

Use Caelum as a directional filter. Strong agreement supports trend-following context; mixed readings warn that timeframes are not aligned.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

Caelum is original in combining ALMA deviation states, multi-horizon voting, run-length overheat logic, and a clean ribbon display.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Caelum Bias Ribbon [JOAT]", shorttitle="CBR [JOAT]", overlay=true, scale=scale.right, max_lines_count=120, max_labels_count=160)

// Caelum Bias Ribbon [JOAT]
// Original MTF ALMA SuperTrend consensus ribbon with run quality, overheat states, and consensus candle coloring.

string gCore = "Core"
string gViz = "Visual System"
string gPanel = "Panel"
float factor = input.float(1.0, "Deviation factor", minval=0.1, maxval=5, step=0.05, group=gCore)
int almaLen = input.int(6, "ALMA length", minval=2, maxval=50, group=gCore)
int sdLen = input.int(4, "Deviation length", minval=2, maxval=50, group=gCore)
float almaOffset = input.float(0.85, "ALMA offset", minval=0, maxval=1, step=0.05, group=gCore)
float almaSigma = input.float(4.0, "ALMA sigma", minval=1, maxval=10, step=0.25, group=gCore)
int overheatRun = input.int(8, "Overheat run threshold", minval=2, maxval=100, group=gCore)
bool useFilledBands = input.bool(true, "Use consensus fills", group=gViz)
bool paintBars = input.bool(true, "Paint candles", group=gViz)
bool showPanel = input.bool(true, "Show panel", group=gPanel)

color C_BULL = color.rgb(31, 211, 37)
color C_BEAR = color.rgb(188, 8, 219)
color C_15 = color.rgb(234, 179, 8)
color C_60 = color.rgb(249, 115, 22)
color C_240 = color.rgb(34, 197, 94)
color C_D = color.rgb(59, 130, 246)
color C_W = color.rgb(6, 182, 212)
color C_GOLD = color.rgb(255, 179, 0)
color C_BG = #080a12
color C_TEXT = #ffffff
color C_MUTED = #607d8b

f_st(float src, float alma, float mult, int len) =>
    float dev = ta.stdev(src, len)
    float upper = alma + mult * dev
    float lower = alma - mult * dev
    float prevUpper = nz(upper[1], upper)
    float prevLower = nz(lower[1], lower)
    upper := upper < prevUpper or src[1] > prevUpper ? upper : prevUpper
    lower := lower > prevLower or src[1] < prevLower ? lower : prevLower
    int dir = 1
    float st = na
    float prevSt = nz(st[1], upper)
    if prevSt == prevUpper
        dir := src > upper ? -1 : 1
    else
        dir := src < lower ? 1 : -1
    st := dir == -1 ? lower : upper
    [st, dir]

f_signal(float src) =>
    float alma = ta.alma(src, almaLen, almaOffset, almaSigma)
    [st, dir] = f_st(src, alma, factor, sdLen)
    int sig = dir < 0 ? 1 : -1
    [sig, alma, st]

f_signal_only(float src) =>
    [sig, alma, st] = f_signal(src)
    sig

f_run(int sig) =>
    var int run = 0
    run := sig == nz(sig[1]) ? run + 1 : 1
    run

[sig15, alma15, st15] = request.security(syminfo.tickerid, "15", f_signal(close[1]), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[sig60, alma60, st60] = request.security(syminfo.tickerid, "60", f_signal(close[1]), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[sig240, alma240, st240] = request.security(syminfo.tickerid, "240", f_signal(close[1]), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[sigD, almaD, stD] = request.security(syminfo.tickerid, "D", f_signal(close[1]), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[sigW, almaW, stW] = request.security(syminfo.tickerid, "W", f_signal(close[1]), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[sigCur, almaCur, stCur] = f_signal(close)

int vote = sig15 + sig60 + sig240 + sigD + sigW
int consensus = vote >= 3 ? 1 : vote <= -3 ? -1 : 0
float power = math.abs(vote) / 5.0
int run15 = request.security(syminfo.tickerid, "15", f_run(f_signal_only(close[1])), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
int run60 = request.security(syminfo.tickerid, "60", f_run(f_signal_only(close[1])), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
int run240 = request.security(syminfo.tickerid, "240", f_run(f_signal_only(close[1])), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
int runD = request.security(syminfo.tickerid, "D", f_run(f_signal_only(close[1])), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
int runW = request.security(syminfo.tickerid, "W", f_run(f_signal_only(close[1])), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
int hotCount = (run15 >= overheatRun ? 1 : 0) + (run60 >= overheatRun ? 1 : 0) + (run240 >= overheatRun ? 1 : 0) + (runD >= overheatRun ? 1 : 0) + (runW >= overheatRun ? 1 : 0)

p15 = plot(alma15, "CBR 15m ALMA", color=C_15, linewidth=1)
p60 = plot(alma60, "CBR 1H ALMA", color=C_60, linewidth=1)
p240 = plot(alma240, "CBR 4H ALMA", color=C_240, linewidth=1)
pD = plot(almaD, "CBR 1D ALMA", color=C_D, linewidth=1)
pW = plot(almaW, "CBR 1W ALMA", color=C_W, linewidth=1)
color fillBull = color.new(C_BULL, 82)
color fillBear = color.new(C_BEAR, 82)
fill(p15, p60, color=useFilledBands ? sig15 == sig60 and sig15 == 1 ? fillBull : sig15 == sig60 and sig15 == -1 ? fillBear : color.new(C_MUTED, 94) : na)
fill(p60, p240, color=useFilledBands ? sig60 == sig240 and sig60 == 1 ? fillBull : sig60 == sig240 and sig60 == -1 ? fillBear : color.new(C_MUTED, 94) : na)
fill(p240, pD, color=useFilledBands ? sig240 == sigD and sig240 == 1 ? fillBull : sig240 == sigD and sig240 == -1 ? fillBear : color.new(C_MUTED, 94) : na)
fill(pD, pW, color=useFilledBands ? sigD == sigW and sigD == 1 ? fillBull : sigD == sigW and sigD == -1 ? fillBear : color.new(C_MUTED, 94) : na)
plot(stCur, "CBR current spine", color=sigCur == 1 ? color.new(C_BULL, 12) : color.new(C_BEAR, 12), linewidth=2)

color barState = consensus == 1 ? color.new(C_BULL, int(70 - power * 60)) : consensus == -1 ? color.new(C_BEAR, int(70 - power * 60)) : na
barcolor(paintBars ? barState : na)
plotshape(barstate.isconfirmed and hotCount >= 3 and consensus == 1, "CBR long overheat", shape.labeldown, location.abovebar, color=color.new(C_BULL, 10), text="OH", textcolor=C_BG, size=size.tiny)
plotshape(barstate.isconfirmed and hotCount >= 3 and consensus == -1, "CBR short overheat", shape.labelup, location.belowbar, color=color.new(C_BEAR, 10), text="OH", textcolor=C_TEXT, size=size.tiny)

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 6, 6, bgcolor=color.new(C_BG, 5), border_color=color.new(C_TEXT, 82), border_width=1)
    table.cell(panel, 0, 0, "CAELUM", text_color=C_TEXT, bgcolor=color.new(C_D, 72), text_size=size.small)
    table.cell(panel, 1, 0, "15", text_color=C_TEXT, bgcolor=color.new(C_D, 72), text_size=size.small)
    table.cell(panel, 2, 0, "1H", text_color=C_TEXT, bgcolor=color.new(C_D, 72), text_size=size.small)
    table.cell(panel, 3, 0, "4H", text_color=C_TEXT, bgcolor=color.new(C_D, 72), text_size=size.small)
    table.cell(panel, 4, 0, "1D", text_color=C_TEXT, bgcolor=color.new(C_D, 72), text_size=size.small)
    table.cell(panel, 5, 0, "1W", text_color=C_TEXT, bgcolor=color.new(C_D, 72), text_size=size.small)
    table.cell(panel, 0, 1, "State", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 1, sig15 == 1 ? "B" : "S", text_color=sig15 == 1 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 2, 1, sig60 == 1 ? "B" : "S", text_color=sig60 == 1 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 3, 1, sig240 == 1 ? "B" : "S", text_color=sig240 == 1 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 4, 1, sigD == 1 ? "B" : "S", text_color=sigD == 1 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 5, 1, sigW == 1 ? "B" : "S", text_color=sigW == 1 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 0, 2, "Run", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 2, str.tostring(run15), text_color=run15 >= overheatRun ? C_GOLD : C_TEXT, text_size=size.small)
    table.cell(panel, 2, 2, str.tostring(run60), text_color=run60 >= overheatRun ? C_GOLD : C_TEXT, text_size=size.small)
    table.cell(panel, 3, 2, str.tostring(run240), text_color=run240 >= overheatRun ? C_GOLD : C_TEXT, text_size=size.small)
    table.cell(panel, 4, 2, str.tostring(runD), text_color=runD >= overheatRun ? C_GOLD : C_TEXT, text_size=size.small)
    table.cell(panel, 5, 2, str.tostring(runW), text_color=runW >= overheatRun ? C_GOLD : C_TEXT, text_size=size.small)
    table.cell(panel, 0, 3, "Vote", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 3, str.tostring(vote), text_color=consensus == 1 ? C_BULL : consensus == -1 ? C_BEAR : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 4, "Power", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 4, str.tostring(power * 100, "#") + "%", text_color=consensus == 1 ? C_BULL : consensus == -1 ? C_BEAR : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 5, "Heat", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 5, str.tostring(hotCount), text_color=hotCount >= 3 ? C_GOLD : C_MUTED, text_size=size.small)

alertcondition(barstate.isconfirmed and consensus == 1 and consensus[1] != 1, "CBR Bull Consensus [JOAT]", "Caelum bull consensus")
alertcondition(barstate.isconfirmed and consensus == -1 and consensus[1] != -1, "CBR Bear Consensus [JOAT]", "Caelum bear consensus")
````
