# Crypto Spaghetti 40 Pro

- url: https://www.tradingview.com/script/M1f7TX6B-Crypto-Spaghetti-40-Pro/
- type: indicator
- pine_id: PUB;7c89dc25f1534dfeb5d3c7c9ee311f41
- version: 1.0

## Description

crypto spaghetti 40 pro future is a multi-symbol relative strength dashboard designed to compare up to 40 crypto pairs in one clean oscillator panel.

the tool does not display normal price. instead, it rebases every selected token from the same lookback point and shows its relative performance as a percentage. this makes it easier to see which tokens are leading, which tokens are lagging, and where rotation is happening inside a crypto basket.

main idea

most traders look at one chart at a time. this tool helps compare many markets at once.

each line represents one token.

when a line is above zero, that token is performing better than its starting point over the selected lookback.

when a line is below zero, that token is performing weaker than its starting point over the selected lookback.

when one line rises faster than the others, that token is showing relative strength.

when one line falls faster than the others, that token is showing relative weakness.

what the indicator shows

performance lines

the script plots up to 40 crypto pairs as percentage performance lines. all pairs are rebased using the same lookback value, so they can be compared on the same scale.

zero line

the zero line is the base level. values above zero show positive performance from the rebase point. values below zero show negative performance from the rebase point.

background zones

the green area shows stronger positive performance.

the yellow area shows the neutral zone.

the red area shows weaker negative performance.

these zones are visual guides only. they help separate strong, neutral, and weak conditions.

rsi dots

small dots can appear on the lines when the selected token reaches rsi overbought, extreme overbought, oversold, or extreme oversold conditions.

these dots are not automatic buy or sell signals. they are momentum warnings.

panel

the panel shows each token with several useful readings:

pair: the selected crypto pair.

percent: the current relative performance.

rank: the current position of the token inside the 40-symbol basket.

zone: top, high, mid, low, or bottom.

rsi: the current rsi value.

sig: rsi status such as ob, xob, os, or xos.

rank and zone

rank shows where a token stands compared to the rest of the basket.

rank #1 means the strongest token in the current basket.

rank #40 means the weakest token in the current basket.

top means the current leader.

high means the token is inside the top group.

mid means the token is in the middle of the basket.

low means the token is inside the weak group.

bottom means the current weakest token.

this ranking system makes it easier to identify leaders and laggards without relying only on line colors.

alerts

the script includes dynamic alert logic using alert calls.

available alert logic includes:

new top token

new bottom token

token enters top 5

token enters bottom 5

top 5 token with rsi overbought or extreme overbought

bottom 5 token with rsi oversold or extreme oversold

performance crosses above the neutral top zone

performance crosses below the neutral bottom zone

to use these alerts, create a tradingview alert and select the condition:

any alert() function call

how to use the tool

step 1: choose the symbols

select the crypto pairs you want to compare. the default list includes major crypto assets and popular altcoins. you can replace any symbol with another pair.

step 2: choose the lookback

the rebase lookback controls how far back the comparison starts.

a shorter lookback gives a more reactive view.

a longer lookback gives a broader market rotation view.

for beginners, a lookback around 200 bars gives a balanced view.

step 3: read the zero line

tokens above zero are outperforming their own starting point.

tokens below zero are underperforming their own starting point.

tokens near zero are close to neutral.

step 4: check rank

rank is one of the most important readings.

a token ranked #1 is the current strongest performer in the selected basket.

a token ranked in the top 5 is part of the strongest group.

a token ranked in the bottom 5 is part of the weakest group.

step 5: check rsi status

if a token is top ranked and also shows ob or xob, it is strong but may be stretched.

if a token is bottom ranked and also shows os or xos, it is weak but may be stretched to the downside.

rsi does not replace price action. it only adds momentum context.

beginner examples

example 1: finding the strongest token

if sol is ranked #1 and its performance line is rising above the others, sol is currently leading the selected basket.

a beginner can use this information to focus analysis on sol instead of searching across many charts manually.

this does not mean immediate entry. the trader should still check structure, trend, support, resistance, and risk.

example 2: identifying weakness

if a token is ranked #40 and its line is deep in the red zone, it is the weakest token in the selected group.

this can help traders avoid weak assets during bullish conditions or watch for possible continuation weakness.

example 3: rotation

if btc was rank #1 and then eth becomes rank #1, the alert can show a top rotation.

this means leadership inside the basket has changed.

rotation can help traders understand where market attention is moving.

example 4: top 5 with rsi overbought

if a token enters the top 5 and rsi is overbought, the token is strong but potentially extended.

a beginner should not chase blindly. it is usually better to wait for a pullback, a clean continuation setup, or confirmation on the price chart.

example 5: bottom 5 with rsi oversold

if a token enters the bottom 5 and rsi is oversold, the token is weak and may be stretched.

this can be useful for studying possible capitulation, but it is not a buy signal by itself.

best use cases

market rotation analysis

crypto basket comparison

finding relative strength

finding relative weakness

spotting leaders and laggards

monitoring top 5 and bottom 5 changes

watching rsi extremes across many symbols

building a watchlist for further analysis

suggested beginner workflow

first, check the top 5.

then, check if those tokens are above zero.

then, check if they are still rising or already flat.

after that, open the normal price chart of the strongest token.

look for structure, trend, support, resistance, volume, and risk level.

do the same with the bottom 5 if you want to study weak markets.

do not trade only because a token is top ranked or bottom ranked.

the indicator is a scanner and comparison tool. it is not a full trading system.

settings explained

rebase lookback bars

sets how many bars are used as the starting point for the performance comparison.

smoothing

smooths the performance lines. higher values make the lines cleaner but slower.

use log-return style

uses log-style performance calculation instead of simple percentage calculation.

request timeframe

allows the comparison to be calculated from another timeframe. empty means the chart timeframe is used.

line width

controls the thickness of the spaghetti lines.

show futuristic panel

shows or hides the ranking panel.

show token labels

shows or hides labels at the right side of the visible chart.

background zones

controls the green, yellow, and red performance zones.

rsi settings

controls the rsi length and the overbought, oversold, extreme overbought, and extreme oversold thresholds.

alert settings

allows each alert type to be enabled or disabled.

min bars between same alert type can reduce repeated alerts.

important notes

this indicator is designed for comparison, not prediction.

a high rank means relative strength inside the selected basket.

a low rank means relative weakness inside the selected basket.

rank can change quickly in volatile markets.

rsi extremes can stay extreme during strong trends.

always confirm signals with price action.

always use risk management.

always test settings before using them in live conditions.

risk notice

this tool is for technical analysis and educational use. it does not provide financial advice and does not guarantee any result. all readings, ranks, zones, and alerts are visual references only. every trader is responsible for their own analysis, risk management, and trading decisions.

## Source Code

````pine

//@version=6
indicator("CRYPTO SPAGHETTI 40 PRO", shorttitle="SP40", overlay=false, max_bars_back=5000, max_labels_count=500)

grpMain = "Main"
lookbackBars    = input.int(200, "Rebase lookback bars", minval=5, maxval=5000, group=grpMain)
smoothLen       = input.int(1, "Smoothing", minval=1, maxval=50, group=grpMain)
useLogScale     = input.bool(false, "Use log-return style", group=grpMain)
tfInput         = input.timeframe("", "Request timeframe (empty = chart)", group=grpMain)
lineWidth       = input.int(1, "Line width", minval=1, maxval=4, group=grpMain)
showPanel       = input.bool(true, "Show futuristic panel", group=grpMain)
panelPos        = input.string("Bottom Right", "Panel position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpMain)
showLineLabels  = input.bool(true, "Show token labels", group=grpMain)
labelOffsetBars = input.int(1, "Label horizontal offset bars", minval=0, maxval=20, group=grpMain)

grpBg = "Background"
showBg     = input.bool(true, "Show gradient background", group=grpBg)
neutralTop = input.float(5.0, "Neutral zone top", group=grpBg)
neutralBot = input.float(-5.0, "Neutral zone bottom", group=grpBg)
upperMax   = input.float(100.0, "Upper gradient max", group=grpBg)
lowerMin   = input.float(-100.0, "Lower gradient min", group=grpBg)

grpRsi = "RSI"
rsiLen      = input.int(14, "RSI length", minval=2, maxval=100, group=grpRsi)
rsiOB       = input.float(70.0, "RSI overbought", minval=50, maxval=100, step=0.1, group=grpRsi)
rsiOS       = input.float(30.0, "RSI oversold", minval=0, maxval=50, step=0.1, group=grpRsi)
rsiXOB      = input.float(80.0, "RSI extreme overbought", minval=50, maxval=100, step=0.1, group=grpRsi)
rsiXOS      = input.float(20.0, "RSI extreme oversold", minval=0, maxval=50, step=0.1, group=grpRsi)
showRsiDots = input.bool(true, "Show RSI dots on lines", group=grpRsi)

grp1 = "Symbols 01-10"
s01 = input.symbol("BINANCE:BTCUSDT",    "01", group=grp1)
s02 = input.symbol("BINANCE:ETHUSDT",    "02", group=grp1)
s03 = input.symbol("BINANCE:BNBUSDT",    "03", group=grp1)
s04 = input.symbol("BINANCE:SOLUSDT",    "04", group=grp1)
s05 = input.symbol("BINANCE:XRPUSDT",    "05", group=grp1)
s06 = input.symbol("BINANCE:ADAUSDT",    "06", group=grp1)
s07 = input.symbol("BINANCE:DOGEUSDT",   "07", group=grp1)
s08 = input.symbol("BINANCE:TRXUSDT",    "08", group=grp1)
s09 = input.symbol("BINANCE:AVAXUSDT",   "09", group=grp1)
s10 = input.symbol("BINANCE:LINKUSDT",   "10", group=grp1)

grp2 = "Symbols 11-20"
s11 = input.symbol("BINANCE:DOTUSDT",    "11", group=grp2)
s12 = input.symbol("BINANCE:POLUSDT",    "12", group=grp2)
s13 = input.symbol("BINANCE:LTCUSDT",    "13", group=grp2)
s14 = input.symbol("BINANCE:BCHUSDT",    "14", group=grp2)
s15 = input.symbol("BINANCE:UNIUSDT",    "15", group=grp2)
s16 = input.symbol("BINANCE:ATOMUSDT",   "16", group=grp2)
s17 = input.symbol("BINANCE:XLMUSDT",    "17", group=grp2)
s18 = input.symbol("BINANCE:ETCUSDT",    "18", group=grp2)
s19 = input.symbol("BINANCE:FILUSDT",    "19", group=grp2)
s20 = input.symbol("BINANCE:APTUSDT",    "20", group=grp2)

grp3 = "Symbols 21-30"
s21 = input.symbol("BINANCE:ARBUSDT",    "21", group=grp3)
s22 = input.symbol("BINANCE:OPUSDT",     "22", group=grp3)
s23 = input.symbol("BINANCE:INJUSDT",    "23", group=grp3)
s24 = input.symbol("BINANCE:NEARUSDT",   "24", group=grp3)
s25 = input.symbol("BINANCE:RENDERUSDT", "25", group=grp3)
s26 = input.symbol("BINANCE:SEIUSDT",    "26", group=grp3)
s27 = input.symbol("BINANCE:SUIUSDT",    "27", group=grp3)
s28 = input.symbol("BINANCE:PEPEUSDT",   "28", group=grp3)
s29 = input.symbol("BINANCE:WIFUSDT",    "29", group=grp3)
s30 = input.symbol("BINANCE:TONUSDT",    "30", group=grp3)

grp4 = "Symbols 31-40"
s31 = input.symbol("BINANCE:SHIBUSDT",   "31", group=grp4)
s32 = input.symbol("BINANCE:AAVEUSDT",   "32", group=grp4)
s33 = input.symbol("BINANCE:ALGOUSDT",   "33", group=grp4)
s34 = input.symbol("BINANCE:VETUSDT",    "34", group=grp4)
s35 = input.symbol("BINANCE:SANDUSDT",   "35", group=grp4)
s36 = input.symbol("BINANCE:MANAUSDT",   "36", group=grp4)
s37 = input.symbol("BINANCE:GALAUSDT",   "37", group=grp4)
s38 = input.symbol("BINANCE:FLOWUSDT",   "38", group=grp4)
s39 = input.symbol("BINANCE:EGLDUSDT",   "39", group=grp4)
s40 = input.symbol("BINANCE:HBARUSDT",   "40", group=grp4)

c01Col = #F7931A
c02Col = #627EEA
c03Col = #F3BA2F
c04Col = #14F195
c05Col = #23292F
c06Col = #2A5ADA
c07Col = #C2A633
c08Col = #EF0027
c09Col = #E84142
c10Col = #0A66C2

c11Col = #E6007A
c12Col = #8247E5
c13Col = #345D9D
c14Col = #8DC351
c15Col = #FF007A
c16Col = #4661EE
c17Col = #14B5D1
c18Col = #328332
c19Col = #00BFFF
c20Col = #00E5FF

c21Col = #28A0F0
c22Col = #FF0420
c23Col = #00D18C
c24Col = #A0A0A0
c25Col = #FF6B00
c26Col = #61D9F9
c27Col = #FFFFFF
c28Col = #4CAF50
c29Col = #FFB300
c30Col = #0098EA

c31Col = #FF6B81
c32Col = #B6509E
c33Col = #111111
c34Col = #15BDFF
c35Col = #00ADEF
c36Col = #FF2D55
c37Col = #F34336
c38Col = #00EF8B
c39Col = #23F7DD
c40Col = #000000

C_PANEL_BG1 = color.new(#050816, 0)
C_PANEL_BG2 = color.new(#0B1022, 0)
C_PANEL_HDR = color.new(#091224, 0)
C_PANEL_BRD = color.new(#1EDBFF, 45)
C_HDR_TXT   = #8FDFFF
C_TXT       = color.white

reqTf = tfInput == "" ? timeframe.period : tfInput

f_pairShort(sym) =>
    string out = sym
    int colonPos = str.pos(sym, ":")
    if colonPos >= 0
        out := str.substring(sym, colonPos + 1, str.length(sym))
    out

f_panelPos(pos) =>
    pos == "Top Right" ? position.top_right :
     pos == "Top Left" ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

f_data(sym) =>
    request.security(sym, reqTf, [close, ta.rsi(close, rsiLen)], ignore_invalid_symbol=true)

f_perf(src) =>
    float out = na
    if not na(src) and not na(src[lookbackBars]) and src[lookbackBars] != 0
        out := useLogScale ? math.log(src / src[lookbackBars]) * 100.0 : (src / src[lookbackBars] - 1.0) * 100.0
    smoothLen > 1 ? ta.ema(out, smoothLen) : out

f_atRightVisibleBar() =>
    time == chart.right_visible_bar_time

f_perfTrend(v) =>
    na(v) ? "·" : v > neutralTop ? "▲" : v < neutralBot ? "▼" : "•"

f_perfTrendBg(v) =>
    na(v) ? color.new(color.gray, 85) : v > neutralTop ? color.new(color.lime, 68) : v < neutralBot ? color.new(color.red, 68) : color.new(color.yellow, 58)

f_perfHeatBg(v) =>
    if na(v)
        color.new(color.gray, 88)
    else
        float mag = math.min(math.abs(v), 200.0) / 200.0
        int tr = 88 - int(mag * 70.0)
        v >= 0 ? color.new(color.lime, tr) : color.new(color.red, tr)

f_rsiStateTxt(r) =>
    na(r) ? "" : r >= rsiXOB ? "XOB" : r >= rsiOB ? "OB" : r <= rsiXOS ? "XOS" : r <= rsiOS ? "OS" : ""

f_rsiStateBg(r) =>
    na(r) ? color.new(color.gray, 86) :
     r >= rsiXOB ? color.new(color.red, 55) :
     r >= rsiOB  ? color.new(color.orange, 52) :
     r <= rsiXOS ? color.new(color.lime, 50) :
     r <= rsiOS  ? color.new(color.aqua, 52) :
     color.new(#3B4668, 65)

f_rsiDotCol(r) =>
    na(r) ? na :
     r >= rsiXOB ? color.red :
     r >= rsiOB  ? color.orange :
     r <= rsiXOS ? color.lime :
     r <= rsiOS  ? color.aqua :
     na

f_compactPct(v) =>
    na(v) ? "n/a" : str.tostring(v, "#.##") + "%"

f_compactRsi(r) =>
    na(r) ? "n/a" : str.tostring(r, "#.#")

f_updLabel(label lb, string sym, float y, color col) =>
    label out = lb
    if showLineLabels and f_atRightVisibleBar() and not na(y)
        string txt = f_pairShort(sym)
        int x = bar_index + labelOffsetBars
        if na(out)
            out := label.new(x, y, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, size=size.tiny, textcolor=color.white, color=col)
        else
            label.set_xy(out, x, y)
            label.set_text(out, txt)
            label.set_textcolor(out, color.white)
            label.set_color(out, col)
            label.set_style(out, label.style_label_left)
            label.set_size(out, size.tiny)
    out

f_updDotLabel(label lb, float y, float r) =>
    label out = lb
    color dc = f_rsiDotCol(r)
    bool active = showRsiDots and f_atRightVisibleBar() and not na(y) and not na(dc)
    if active
        int x = bar_index + labelOffsetBars
        if na(out)
            out := label.new(x, y, "●", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, size=size.tiny, textcolor=dc, color=color.new(color.black, 100))
        else
            label.set_xy(out, x, y)
            label.set_text(out, "●")
            label.set_textcolor(out, dc)
            label.set_color(out, color.new(color.black, 100))
            label.set_style(out, label.style_none)
            label.set_size(out, size.tiny)
    else
        if not na(out)
            label.delete(out)
            out := na
    out

f_rank(float v, array<float> vals) =>
    int r = na(v) ? na : 1
    if not na(v)
        for i = 0 to array.size(vals) - 1
            float x = array.get(vals, i)
            r += not na(x) and x > v ? 1 : 0
    r

f_rankTxt(int r) =>
    na(r) ? "n/a" : "#" + str.tostring(r)

f_zoneTxt(int r) =>
    na(r) ? "n/a" : r == 1 ? "top" : r <= 5 ? "high" : r >= 40 ? "bottom" : r >= 36 ? "low" : "mid"

f_zoneBg(int r) =>
    na(r) ? color.new(color.gray, 85) : r == 1 ? color.new(color.lime, 8) : r <= 5 ? color.new(color.lime, 38) : r >= 40 ? color.new(color.red, 8) : r >= 36 ? color.new(color.red, 38) : color.new(color.gray, 78)

f_rankTxtCol(int r) =>
    na(r) ? C_TXT : r <= 5 or r >= 36 ? color.black : C_TXT

f_rowCompact(tbl, row, pair, lcol, perf, rsi, rank) =>
    color rowBg = row % 2 == 0 ? C_PANEL_BG1 : C_PANEL_BG2
    string sig = f_rsiStateTxt(rsi)
    color zbg = f_zoneBg(rank)
    color ztc = f_rankTxtCol(rank)
    table.cell(tbl, 0, row, "━━", text_color=lcol, bgcolor=rowBg, text_size=size.tiny)
    table.cell(tbl, 1, row, f_pairShort(pair), text_color=C_TXT, bgcolor=rowBg, text_size=size.tiny)
    table.cell(tbl, 2, row, f_compactPct(perf), text_color=C_TXT, bgcolor=f_perfHeatBg(perf), text_size=size.tiny)
    table.cell(tbl, 3, row, f_rankTxt(rank), text_color=ztc, bgcolor=zbg, text_size=size.tiny)
    table.cell(tbl, 4, row, f_zoneTxt(rank), text_color=ztc, bgcolor=zbg, text_size=size.tiny)
    table.cell(tbl, 5, row, f_compactRsi(rsi), text_color=C_TXT, bgcolor=rowBg, text_size=size.tiny)
    table.cell(tbl, 6, row, sig == "" ? "—" : sig, text_color=color.black, bgcolor=sig == "" ? rowBg : f_rsiStateBg(rsi), text_size=size.tiny)

[c01, r01] = f_data(s01)
[c02, r02] = f_data(s02)
[c03, r03] = f_data(s03)
[c04, r04] = f_data(s04)
[c05, r05] = f_data(s05)
[c06, r06] = f_data(s06)
[c07, r07] = f_data(s07)
[c08, r08] = f_data(s08)
[c09, r09] = f_data(s09)
[c10, r10] = f_data(s10)

[c11, r11] = f_data(s11)
[c12, r12] = f_data(s12)
[c13, r13] = f_data(s13)
[c14, r14] = f_data(s14)
[c15, r15] = f_data(s15)
[c16, r16] = f_data(s16)
[c17, r17] = f_data(s17)
[c18, r18] = f_data(s18)
[c19, r19] = f_data(s19)
[c20, r20] = f_data(s20)

[c21, r21] = f_data(s21)
[c22, r22] = f_data(s22)
[c23, r23] = f_data(s23)
[c24, r24] = f_data(s24)
[c25, r25] = f_data(s25)
[c26, r26] = f_data(s26)
[c27, r27] = f_data(s27)
[c28, r28] = f_data(s28)
[c29, r29] = f_data(s29)
[c30, r30] = f_data(s30)

[c31, r31] = f_data(s31)
[c32, r32] = f_data(s32)
[c33, r33] = f_data(s33)
[c34, r34] = f_data(s34)
[c35, r35] = f_data(s35)
[c36, r36] = f_data(s36)
[c37, r37] = f_data(s37)
[c38, r38] = f_data(s38)
[c39, r39] = f_data(s39)
[c40, r40] = f_data(s40)

p01 = f_perf(c01)
p02 = f_perf(c02)
p03 = f_perf(c03)
p04 = f_perf(c04)
p05 = f_perf(c05)
p06 = f_perf(c06)
p07 = f_perf(c07)
p08 = f_perf(c08)
p09 = f_perf(c09)
p10 = f_perf(c10)

p11 = f_perf(c11)
p12 = f_perf(c12)
p13 = f_perf(c13)
p14 = f_perf(c14)
p15 = f_perf(c15)
p16 = f_perf(c16)
p17 = f_perf(c17)
p18 = f_perf(c18)
p19 = f_perf(c19)
p20 = f_perf(c20)

p21 = f_perf(c21)
p22 = f_perf(c22)
p23 = f_perf(c23)
p24 = f_perf(c24)
p25 = f_perf(c25)
p26 = f_perf(c26)
p27 = f_perf(c27)
p28 = f_perf(c28)
p29 = f_perf(c29)
p30 = f_perf(c30)

p31 = f_perf(c31)
p32 = f_perf(c32)
p33 = f_perf(c33)
p34 = f_perf(c34)
p35 = f_perf(c35)
p36 = f_perf(c36)
p37 = f_perf(c37)
p38 = f_perf(c38)
p39 = f_perf(c39)
p40 = f_perf(c40)

rankVals = array.from(p01,p02,p03,p04,p05,p06,p07,p08,p09,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40)
rk01 = f_rank(p01, rankVals)
rk02 = f_rank(p02, rankVals)
rk03 = f_rank(p03, rankVals)
rk04 = f_rank(p04, rankVals)
rk05 = f_rank(p05, rankVals)
rk06 = f_rank(p06, rankVals)
rk07 = f_rank(p07, rankVals)
rk08 = f_rank(p08, rankVals)
rk09 = f_rank(p09, rankVals)
rk10 = f_rank(p10, rankVals)
rk11 = f_rank(p11, rankVals)
rk12 = f_rank(p12, rankVals)
rk13 = f_rank(p13, rankVals)
rk14 = f_rank(p14, rankVals)
rk15 = f_rank(p15, rankVals)
rk16 = f_rank(p16, rankVals)
rk17 = f_rank(p17, rankVals)
rk18 = f_rank(p18, rankVals)
rk19 = f_rank(p19, rankVals)
rk20 = f_rank(p20, rankVals)
rk21 = f_rank(p21, rankVals)
rk22 = f_rank(p22, rankVals)
rk23 = f_rank(p23, rankVals)
rk24 = f_rank(p24, rankVals)
rk25 = f_rank(p25, rankVals)
rk26 = f_rank(p26, rankVals)
rk27 = f_rank(p27, rankVals)
rk28 = f_rank(p28, rankVals)
rk29 = f_rank(p29, rankVals)
rk30 = f_rank(p30, rankVals)
rk31 = f_rank(p31, rankVals)
rk32 = f_rank(p32, rankVals)
rk33 = f_rank(p33, rankVals)
rk34 = f_rank(p34, rankVals)
rk35 = f_rank(p35, rankVals)
rk36 = f_rank(p36, rankVals)
rk37 = f_rank(p37, rankVals)
rk38 = f_rank(p38, rankVals)
rk39 = f_rank(p39, rankVals)
rk40 = f_rank(p40, rankVals)

bgU0 = plot(showBg ? neutralTop : na, title="BG U0", display=display.none)
bgU1 = plot(showBg ? neutralTop + (upperMax - neutralTop) * 0.14 : na, title="BG U1", display=display.none)
bgU2 = plot(showBg ? neutralTop + (upperMax - neutralTop) * 0.28 : na, title="BG U2", display=display.none)
bgU3 = plot(showBg ? neutralTop + (upperMax - neutralTop) * 0.42 : na, title="BG U3", display=display.none)
bgU4 = plot(showBg ? neutralTop + (upperMax - neutralTop) * 0.57 : na, title="BG U4", display=display.none)
bgU5 = plot(showBg ? neutralTop + (upperMax - neutralTop) * 0.71 : na, title="BG U5", display=display.none)
bgU6 = plot(showBg ? neutralTop + (upperMax - neutralTop) * 0.85 : na, title="BG U6", display=display.none)
bgU7 = plot(showBg ? upperMax : na, title="BG U7", display=display.none)

bgN1 = plot(showBg ? neutralBot : na, title="BG N1", display=display.none)
bgN2 = plot(showBg ? neutralTop : na, title="BG N2", display=display.none)

bgL0 = plot(showBg ? lowerMin : na, title="BG L0", display=display.none)
bgL1 = plot(showBg ? lowerMin + (neutralBot - lowerMin) * 0.15 : na, title="BG L1", display=display.none)
bgL2 = plot(showBg ? lowerMin + (neutralBot - lowerMin) * 0.30 : na, title="BG L2", display=display.none)
bgL3 = plot(showBg ? lowerMin + (neutralBot - lowerMin) * 0.45 : na, title="BG L3", display=display.none)
bgL4 = plot(showBg ? lowerMin + (neutralBot - lowerMin) * 0.60 : na, title="BG L4", display=display.none)
bgL5 = plot(showBg ? lowerMin + (neutralBot - lowerMin) * 0.75 : na, title="BG L5", display=display.none)
bgL6 = plot(showBg ? lowerMin + (neutralBot - lowerMin) * 0.90 : na, title="BG L6", display=display.none)
bgL7 = plot(showBg ? neutralBot : na, title="BG L7", display=display.none)

fill(bgU0, bgU1, color=color.new(color.lime, 92))
fill(bgU1, bgU2, color=color.new(color.lime, 88))
fill(bgU2, bgU3, color=color.new(color.lime, 84))
fill(bgU3, bgU4, color=color.new(color.lime, 80))
fill(bgU4, bgU5, color=color.new(color.lime, 76))
fill(bgU5, bgU6, color=color.new(color.lime, 72))
fill(bgU6, bgU7, color=color.new(color.lime, 68))

fill(bgN1, bgN2, color=color.new(color.yellow, 82))

fill(bgL0, bgL1, color=color.new(color.red, 68))
fill(bgL1, bgL2, color=color.new(color.red, 72))
fill(bgL2, bgL3, color=color.new(color.red, 76))
fill(bgL3, bgL4, color=color.new(color.red, 80))
fill(bgL4, bgL5, color=color.new(color.red, 84))
fill(bgL5, bgL6, color=color.new(color.red, 88))
fill(bgL6, bgL7, color=color.new(color.red, 92))

hline(0, "Base 0%", color=color.new(color.gray, 70))

plot(p01, title="01", linewidth=lineWidth, color=c01Col)
plot(p02, title="02", linewidth=lineWidth, color=c02Col)
plot(p03, title="03", linewidth=lineWidth, color=c03Col)
plot(p04, title="04", linewidth=lineWidth, color=c04Col)
plot(p05, title="05", linewidth=lineWidth, color=c05Col)
plot(p06, title="06", linewidth=lineWidth, color=c06Col)
plot(p07, title="07", linewidth=lineWidth, color=c07Col)
plot(p08, title="08", linewidth=lineWidth, color=c08Col)
plot(p09, title="09", linewidth=lineWidth, color=c09Col)
plot(p10, title="10", linewidth=lineWidth, color=c10Col)

plot(p11, title="11", linewidth=lineWidth, color=c11Col)
plot(p12, title="12", linewidth=lineWidth, color=c12Col)
plot(p13, title="13", linewidth=lineWidth, color=c13Col)
plot(p14, title="14", linewidth=lineWidth, color=c14Col)
plot(p15, title="15", linewidth=lineWidth, color=c15Col)
plot(p16, title="16", linewidth=lineWidth, color=c16Col)
plot(p17, title="17", linewidth=lineWidth, color=c17Col)
plot(p18, title="18", linewidth=lineWidth, color=c18Col)
plot(p19, title="19", linewidth=lineWidth, color=c19Col)
plot(p20, title="20", linewidth=lineWidth, color=c20Col)

plot(p21, title="21", linewidth=lineWidth, color=c21Col)
plot(p22, title="22", linewidth=lineWidth, color=c22Col)
plot(p23, title="23", linewidth=lineWidth, color=c23Col)
plot(p24, title="24", linewidth=lineWidth, color=c24Col)
plot(p25, title="25", linewidth=lineWidth, color=c25Col)
plot(p26, title="26", linewidth=lineWidth, color=c26Col)
plot(p27, title="27", linewidth=lineWidth, color=c27Col)
plot(p28, title="28", linewidth=lineWidth, color=c28Col)
plot(p29, title="29", linewidth=lineWidth, color=c29Col)
plot(p30, title="30", linewidth=lineWidth, color=c30Col)

plot(p31, title="31", linewidth=lineWidth, color=c31Col)
plot(p32, title="32", linewidth=lineWidth, color=c32Col)
plot(p33, title="33", linewidth=lineWidth, color=c33Col)
plot(p34, title="34", linewidth=lineWidth, color=c34Col)
plot(p35, title="35", linewidth=lineWidth, color=c35Col)
plot(p36, title="36", linewidth=lineWidth, color=c36Col)
plot(p37, title="37", linewidth=lineWidth, color=c37Col)
plot(p38, title="38", linewidth=lineWidth, color=c38Col)
plot(p39, title="39", linewidth=lineWidth, color=c39Col)
plot(p40, title="40", linewidth=lineWidth, color=c40Col)

var label lb01 = na
var label lb02 = na
var label lb03 = na
var label lb04 = na
var label lb05 = na
var label lb06 = na
var label lb07 = na
var label lb08 = na
var label lb09 = na
var label lb10 = na
var label lb11 = na
var label lb12 = na
var label lb13 = na
var label lb14 = na
var label lb15 = na
var label lb16 = na
var label lb17 = na
var label lb18 = na
var label lb19 = na
var label lb20 = na
var label lb21 = na
var label lb22 = na
var label lb23 = na
var label lb24 = na
var label lb25 = na
var label lb26 = na
var label lb27 = na
var label lb28 = na
var label lb29 = na
var label lb30 = na
var label lb31 = na
var label lb32 = na
var label lb33 = na
var label lb34 = na
var label lb35 = na
var label lb36 = na
var label lb37 = na
var label lb38 = na
var label lb39 = na
var label lb40 = na

var label db01 = na
var label db02 = na
var label db03 = na
var label db04 = na
var label db05 = na
var label db06 = na
var label db07 = na
var label db08 = na
var label db09 = na
var label db10 = na
var label db11 = na
var label db12 = na
var label db13 = na
var label db14 = na
var label db15 = na
var label db16 = na
var label db17 = na
var label db18 = na
var label db19 = na
var label db20 = na
var label db21 = na
var label db22 = na
var label db23 = na
var label db24 = na
var label db25 = na
var label db26 = na
var label db27 = na
var label db28 = na
var label db29 = na
var label db30 = na
var label db31 = na
var label db32 = na
var label db33 = na
var label db34 = na
var label db35 = na
var label db36 = na
var label db37 = na
var label db38 = na
var label db39 = na
var label db40 = na

if showLineLabels and f_atRightVisibleBar()
    lb01 := f_updLabel(lb01, s01, p01, c01Col)
    lb02 := f_updLabel(lb02, s02, p02, c02Col)
    lb03 := f_updLabel(lb03, s03, p03, c03Col)
    lb04 := f_updLabel(lb04, s04, p04, c04Col)
    lb05 := f_updLabel(lb05, s05, p05, c05Col)
    lb06 := f_updLabel(lb06, s06, p06, c06Col)
    lb07 := f_updLabel(lb07, s07, p07, c07Col)
    lb08 := f_updLabel(lb08, s08, p08, c08Col)
    lb09 := f_updLabel(lb09, s09, p09, c09Col)
    lb10 := f_updLabel(lb10, s10, p10, c10Col)

    lb11 := f_updLabel(lb11, s11, p11, c11Col)
    lb12 := f_updLabel(lb12, s12, p12, c12Col)
    lb13 := f_updLabel(lb13, s13, p13, c13Col)
    lb14 := f_updLabel(lb14, s14, p14, c14Col)
    lb15 := f_updLabel(lb15, s15, p15, c15Col)
    lb16 := f_updLabel(lb16, s16, p16, c16Col)
    lb17 := f_updLabel(lb17, s17, p17, c17Col)
    lb18 := f_updLabel(lb18, s18, p18, c18Col)
    lb19 := f_updLabel(lb19, s19, p19, c19Col)
    lb20 := f_updLabel(lb20, s20, p20, c20Col)

    lb21 := f_updLabel(lb21, s21, p21, c21Col)
    lb22 := f_updLabel(lb22, s22, p22, c22Col)
    lb23 := f_updLabel(lb23, s23, p23, c23Col)
    lb24 := f_updLabel(lb24, s24, p24, c24Col)
    lb25 := f_updLabel(lb25, s25, p25, c25Col)
    lb26 := f_updLabel(lb26, s26, p26, c26Col)
    lb27 := f_updLabel(lb27, s27, p27, c27Col)
    lb28 := f_updLabel(lb28, s28, p28, c28Col)
    lb29 := f_updLabel(lb29, s29, p29, c29Col)
    lb30 := f_updLabel(lb30, s30, p30, c30Col)

    lb31 := f_updLabel(lb31, s31, p31, c31Col)
    lb32 := f_updLabel(lb32, s32, p32, c32Col)
    lb33 := f_updLabel(lb33, s33, p33, c33Col)
    lb34 := f_updLabel(lb34, s34, p34, c34Col)
    lb35 := f_updLabel(lb35, s35, p35, c35Col)
    lb36 := f_updLabel(lb36, s36, p36, c36Col)
    lb37 := f_updLabel(lb37, s37, p37, c37Col)
    lb38 := f_updLabel(lb38, s38, p38, c38Col)
    lb39 := f_updLabel(lb39, s39, p39, c39Col)
    lb40 := f_updLabel(lb40, s40, p40, c40Col)

    db01 := f_updDotLabel(db01, p01, r01)
    db02 := f_updDotLabel(db02, p02, r02)
    db03 := f_updDotLabel(db03, p03, r03)
    db04 := f_updDotLabel(db04, p04, r04)
    db05 := f_updDotLabel(db05, p05, r05)
    db06 := f_updDotLabel(db06, p06, r06)
    db07 := f_updDotLabel(db07, p07, r07)
    db08 := f_updDotLabel(db08, p08, r08)
    db09 := f_updDotLabel(db09, p09, r09)
    db10 := f_updDotLabel(db10, p10, r10)

    db11 := f_updDotLabel(db11, p11, r11)
    db12 := f_updDotLabel(db12, p12, r12)
    db13 := f_updDotLabel(db13, p13, r13)
    db14 := f_updDotLabel(db14, p14, r14)
    db15 := f_updDotLabel(db15, p15, r15)
    db16 := f_updDotLabel(db16, p16, r16)
    db17 := f_updDotLabel(db17, p17, r17)
    db18 := f_updDotLabel(db18, p18, r18)
    db19 := f_updDotLabel(db19, p19, r19)
    db20 := f_updDotLabel(db20, p20, r20)

    db21 := f_updDotLabel(db21, p21, r21)
    db22 := f_updDotLabel(db22, p22, r22)
    db23 := f_updDotLabel(db23, p23, r23)
    db24 := f_updDotLabel(db24, p24, r24)
    db25 := f_updDotLabel(db25, p25, r25)
    db26 := f_updDotLabel(db26, p26, r26)
    db27 := f_updDotLabel(db27, p27, r27)
    db28 := f_updDotLabel(db28, p28, r28)
    db29 := f_updDotLabel(db29, p29, r29)
    db30 := f_updDotLabel(db30, p30, r30)

    db31 := f_updDotLabel(db31, p31, r31)
    db32 := f_updDotLabel(db32, p32, r32)
    db33 := f_updDotLabel(db33, p33, r33)
    db34 := f_updDotLabel(db34, p34, r34)
    db35 := f_updDotLabel(db35, p35, r35)
    db36 := f_updDotLabel(db36, p36, r36)
    db37 := f_updDotLabel(db37, p37, r37)
    db38 := f_updDotLabel(db38, p38, r38)
    db39 := f_updDotLabel(db39, p39, r39)
    db40 := f_updDotLabel(db40, p40, r40)

var table pnl = table.new(f_panelPos(panelPos), 7, 43, bgcolor=C_PANEL_BG1, frame_color=C_PANEL_BRD, frame_width=2, border_color=color.new(#1EDBFF, 70), border_width=1)

if barstate.islast and showPanel
    table.cell(pnl, 0, 0, "L",      text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 1, 0, "PAIR",   text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 2, 0, "%",      text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 3, 0, "RANK",   text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 4, 0, "ZONE",   text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 5, 0, "RSI",    text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 6, 0, "SIG",    text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)

    table.cell(pnl, 0, 1, "TF", text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 1, 1, reqTf, text_color=C_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 2, 1, "LB", text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 3, 1, str.tostring(lookbackBars), text_color=C_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 4, 1, "R" + str.tostring(rsiLen), text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 5, 1, "LIVE", text_color=#00FFB7, bgcolor=C_PANEL_HDR, text_size=size.tiny)
    table.cell(pnl, 6, 1, "40", text_color=C_HDR_TXT, bgcolor=C_PANEL_HDR, text_size=size.tiny)

    f_rowCompact(pnl,  2, s01, c01Col, p01, r01, rk01)
    f_rowCompact(pnl,  3, s02, c02Col, p02, r02, rk02)
    f_rowCompact(pnl,  4, s03, c03Col, p03, r03, rk03)
    f_rowCompact(pnl,  5, s04, c04Col, p04, r04, rk04)
    f_rowCompact(pnl,  6, s05, c05Col, p05, r05, rk05)
    f_rowCompact(pnl,  7, s06, c06Col, p06, r06, rk06)
    f_rowCompact(pnl,  8, s07, c07Col, p07, r07, rk07)
    f_rowCompact(pnl,  9, s08, c08Col, p08, r08, rk08)
    f_rowCompact(pnl, 10, s09, c09Col, p09, r09, rk09)
    f_rowCompact(pnl, 11, s10, c10Col, p10, r10, rk10)

    f_rowCompact(pnl, 12, s11, c11Col, p11, r11, rk11)
    f_rowCompact(pnl, 13, s12, c12Col, p12, r12, rk12)
    f_rowCompact(pnl, 14, s13, c13Col, p13, r13, rk13)
    f_rowCompact(pnl, 15, s14, c14Col, p14, r14, rk14)
    f_rowCompact(pnl, 16, s15, c15Col, p15, r15, rk15)
    f_rowCompact(pnl, 17, s16, c16Col, p16, r16, rk16)
    f_rowCompact(pnl, 18, s17, c17Col, p17, r17, rk17)
    f_rowCompact(pnl, 19, s18, c18Col, p18, r18, rk18)
    f_rowCompact(pnl, 20, s19, c19Col, p19, r19, rk19)
    f_rowCompact(pnl, 21, s20, c20Col, p20, r20, rk20)

    f_rowCompact(pnl, 22, s21, c21Col, p21, r21, rk21)
    f_rowCompact(pnl, 23, s22, c22Col, p22, r22, rk22)
    f_rowCompact(pnl, 24, s23, c23Col, p23, r23, rk23)
    f_rowCompact(pnl, 25, s24, c24Col, p24, r24, rk24)
    f_rowCompact(pnl, 26, s25, c25Col, p25, r25, rk25)
    f_rowCompact(pnl, 27, s26, c26Col, p26, r26, rk26)
    f_rowCompact(pnl, 28, s27, c27Col, p27, r27, rk27)
    f_rowCompact(pnl, 29, s28, c28Col, p28, r28, rk28)
    f_rowCompact(pnl, 30, s29, c29Col, p29, r29, rk29)
    f_rowCompact(pnl, 31, s30, c30Col, p30, r30, rk30)

    f_rowCompact(pnl, 32, s31, c31Col, p31, r31, rk31)
    f_rowCompact(pnl, 33, s32, c32Col, p32, r32, rk32)
    f_rowCompact(pnl, 34, s33, c33Col, p33, r33, rk33)
    f_rowCompact(pnl, 35, s34, c34Col, p34, r34, rk34)
    f_rowCompact(pnl, 36, s35, c35Col, p35, r35, rk35)
    f_rowCompact(pnl, 37, s36, c36Col, p36, r36, rk36)
    f_rowCompact(pnl, 38, s37, c37Col, p37, r37, rk37)
    f_rowCompact(pnl, 39, s38, c38Col, p38, r38, rk38)
    f_rowCompact(pnl, 40, s39, c39Col, p39, r39, rk39)
    f_rowCompact(pnl, 41, s40, c40Col, p40, r40, rk40)

    table.cell(pnl, 0, 42, "top", text_color=color.black, bgcolor=color.new(color.lime, 8), text_size=size.tiny)
    table.cell(pnl, 1, 42, "high", text_color=color.black, bgcolor=color.new(color.lime, 38), text_size=size.tiny)
    table.cell(pnl, 2, 42, "mid", text_color=C_TXT, bgcolor=color.new(color.gray, 78), text_size=size.tiny)
    table.cell(pnl, 3, 42, "low", text_color=color.black, bgcolor=color.new(color.red, 38), text_size=size.tiny)
    table.cell(pnl, 4, 42, "bottom", text_color=color.black, bgcolor=color.new(color.red, 8), text_size=size.tiny)
    table.cell(pnl, 5, 42, "ob/os", text_color=color.black, bgcolor=color.new(color.yellow, 40), text_size=size.tiny)
    table.cell(pnl, 6, 42, "xob/xos", text_color=color.black, bgcolor=color.new(color.orange, 40), text_size=size.tiny)
````
