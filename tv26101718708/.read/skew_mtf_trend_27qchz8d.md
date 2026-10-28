# Skew MTF Trend

- url: https://www.tradingview.com/script/27QCHz8d-Skew-MTF-Trend/
- type: indicator
- pine_id: PUB;b1e896dce3244137bbd4aee679a4f7f4
- version: 6.0

## Description

Multi-timeframe trend structure at a glance. 
Three fully configurable timeframes on one chart every average colored by its native timeframe's trend state: green above, red below, gray neutral.

[b]Main Timeframe[/b] (default 4H)
EMAs 21, 50, 100, 200. A ribbon fills between the 21/50/100 — green when bull-stacked, red when bear-stacked, gray when mixed.

[b]HTF 1[/b] (default Daily)
EMAs 50 and 200 with trend coloring.

[b]HTF 2[/b] (default Weekly)
EMAs 21, 50, 200 and SMA 200 with trend coloring.

All three timeframes can be changed to any combination. Linewidth scales by layer (Main: 2, HTF 1: 3, HTF 2: 4) for instant visual separation. Master toggles show/hide each timeframe with one click. Every period and line is independently configurable.

[b]Trend Table[/b]
A compact table in the bottom right reads trend state per timeframe using the 50 EMA and 200 EMA:

▲ [b]Green [/b]— price above both the 50 EMA and 200 EMA (uptrend)
▼ [b]Red [/b]— price below both the 50 EMA and 200 EMA (downtrend)
●  [b]Gray [/b]— price between the 50 and 200, or mixed (pending)

The table dynamically displays each selected timeframe, updating automatically when settings change.

[b]Trading with it[/b]
The 50 EMA is the key level that defines the trend. The 200 EMA is the level you trade into.

[b]Uptrend [/b]— Price holds the 50 EMA as support, table showing ▲. Dips into the 50 EMA and the ribbon are buying opportunities. If price dips deeper, the 200 EMA is the next level to bid — the last line of trend defense.

[b]Downtrend [/b]— Price rejects the 50 EMA as resistance, table showing ▼. Rips into the 50 EMA and the ribbon are selling opportunities. The 200 EMA above is the level to sell into on deeper retracements.

[b]Chop [/b]— Price is caught between the 50 and 200, table showing ● on one or more timeframes. Neither side has control. Reduce size or sit flat until the 50 EMA cleanly holds or rejects.

When all three timeframes agree, the trend is strong. When they disagree, conditions are transitional.

## Source Code

````pine
//@version=6
indicator("Skew MTF Trend", overlay=true)

// ─── Groups ───
GRP_MAIN  = "Main Timeframe"
GRP_HTF1  = "HTF 1"
GRP_HTF2  = "HTF 2"
GRP_MOM   = "Momentum"
GRP_DISP  = "Display"

// ─── Main Timeframe ───
showMain  = input.bool(true, "Show Main Averages",  group=GRP_MAIN)
htf       = input.timeframe("240", "Timeframe",     group=GRP_MAIN)
mainLen1  = input.int(21,  "EMA 21",                group=GRP_MAIN)
mainLen2  = input.int(50,  "EMA 50",                group=GRP_MAIN)
mainLen3  = input.int(100, "EMA 100",               group=GRP_MAIN)
mainLen4  = input.int(200, "EMA 200",               group=GRP_MAIN)

// ─── HTF 1 ───
showHTF1    = input.bool(true, "Show HTF 1 Averages", group=GRP_HTF1)
htf1        = input.timeframe("1D", "Timeframe",      group=GRP_HTF1)
htf1Len1    = input.int(50,  "EMA 50",                group=GRP_HTF1)
htf1Len2    = input.int(200, "EMA 200",               group=GRP_HTF1)

// ─── HTF 2 ───
showHTF2       = input.bool(true, "Show HTF 2 Averages", group=GRP_HTF2)
htf2           = input.timeframe("1W", "Timeframe",      group=GRP_HTF2)
htf2Len21      = input.int(21,  "EMA 21",                group=GRP_HTF2)
htf2Len50      = input.int(50,  "EMA 50",                group=GRP_HTF2)
htf2EmaLen     = input.int(200, "EMA 200",               group=GRP_HTF2)
htf2SmaLen     = input.int(200, "SMA 200",               group=GRP_HTF2)

// ─── Momentum ───
showMom    = input.bool(true,  "Show Momentum (Table)",    group=GRP_MOM)
showBarCol = input.bool(false, "Color Candles (Main TF)",  group=GRP_MOM)
rsiLen     = input.int(14,    "RSI Length",                group=GRP_MOM)
stochLen   = input.int(14,    "Stoch Length",              group=GRP_MOM)
smoothK    = input.int(3,     "K Smoothing",               group=GRP_MOM)

// ─── Display ───
showMain21_100 = input.bool(false, "Main: EMA 21 & 100",  group=GRP_DISP)
showMain50     = input.bool(true,  "Main: EMA 50",         group=GRP_DISP)
showMain200    = input.bool(true,  "Main: EMA 200",        group=GRP_DISP)
showHTF1_50    = input.bool(true,  "HTF 1: EMA 50",        group=GRP_DISP)
showHTF1_200   = input.bool(true,  "HTF 1: EMA 200",       group=GRP_DISP)
showHTF2_21    = input.bool(true,  "HTF 2: EMA 21",        group=GRP_DISP)
showHTF2_50    = input.bool(true,  "HTF 2: EMA 50",        group=GRP_DISP)
showHTF2_Ema   = input.bool(true,  "HTF 2: EMA 200",       group=GRP_DISP)
showHTF2_Sma   = input.bool(true,  "HTF 2: SMA 200",       group=GRP_DISP)
showTable      = input.bool(true,  "Show Trend Table",     group=GRP_DISP)
src            = input.source(close, "Source",              group=GRP_DISP)

// ─── Timeframe label helper ───
tfLabel(string tf) =>
    switch tf
        ""    => "Chart"
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "360" => "6H"
        "480" => "8H"
        "720" => "12H"
        "D"   => "1D"
        "1D"  => "1D"
        "W"   => "1W"
        "1W"  => "1W"
        "M"   => "1M"
        "1M"  => "1M"
        => tf

// ─── Visibility flags ───
_visM21  = showMain and showMain21_100
_visM50  = showMain and showMain50
_visM200 = showMain and showMain200
_vis1_50 = showHTF1 and showHTF1_50
_vis1200 = showHTF1 and showHTF1_200
_vis2_21 = showHTF2 and showHTF2_21
_vis2_50 = showHTF2 and showHTF2_50
_vis2E   = showHTF2 and showHTF2_Ema
_vis2S   = showHTF2 and showHTF2_Sma

// ─── Expressions ───
rsiExpr = ta.rsi(src, rsiLen)
skExpr  = ta.sma(ta.stoch(rsiExpr, rsiExpr, rsiExpr, stochLen), smoothK)

// ─── Main TF (2 calls) ───
[e1, e2, e2_1, e2_2, e3, e4, e4_1] = request.security(syminfo.tickerid, htf, [ta.ema(src, mainLen1), ta.ema(src, mainLen2), ta.ema(src, mainLen2)[1], ta.ema(src, mainLen2)[2], ta.ema(src, mainLen3), ta.ema(src, mainLen4), ta.ema(src, mainLen4)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[rsi_m, rsi_m_1, sk_m_1, rsi_m_2, c_main, c_main_1] = request.security(syminfo.tickerid, htf, [rsiExpr, rsiExpr[1], skExpr[1], rsiExpr[2], close, close[1]], barmerge.gaps_off, barmerge.lookahead_off)

// ─── HTF 1 (2 calls) ───
[e1_h1, e1_h1_1, e1_h1_2, e2_h1, e2_h1_1] = request.security(syminfo.tickerid, htf1, [ta.ema(src, htf1Len1), ta.ema(src, htf1Len1)[1], ta.ema(src, htf1Len1)[2], ta.ema(src, htf1Len2), ta.ema(src, htf1Len2)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[rsi_h1_1, sk_h1_1, rsi_h1_2, c_h1, c_h1_1] = request.security(syminfo.tickerid, htf1, [rsiExpr[1], skExpr[1], rsiExpr[2], close, close[1]], barmerge.gaps_off, barmerge.lookahead_off)

// ─── HTF 2 (2 calls) ───
[ema21_h2, ema50_h2, ema50_h2_1, ema50_h2_2, ema200_h2, ema200_h2_1, sma200_h2] = request.security(syminfo.tickerid, htf2, [ta.ema(src, htf2Len21), ta.ema(src, htf2Len50), ta.ema(src, htf2Len50)[1], ta.ema(src, htf2Len50)[2], ta.ema(src, htf2EmaLen), ta.ema(src, htf2EmaLen)[1], ta.sma(src, htf2SmaLen)], barmerge.gaps_off, barmerge.lookahead_off)
[rsi_h2_1, sk_h2_1, rsi_h2_2, c_h2, c_h2_1] = request.security(syminfo.tickerid, htf2, [rsiExpr[1], skExpr[1], rsiExpr[2], close, close[1]], barmerge.gaps_off, barmerge.lookahead_off)

// ─── Bias ───
bull = e1 > e2 and e2 > e3
bear = e1 < e2 and e2 < e3

// ─── Trend colors (close-based, no open needed) ───
trendCol50  = c_main > e2     ? color.lime : c_main < e2     ? color.red : color.new(color.gray, 40)
trendCol200 = c_main > e4     ? color.lime : c_main < e4     ? color.red : color.new(color.gray, 40)

trendCol50_h1  = c_h1 > e1_h1 ? color.lime : c_h1 < e1_h1 ? color.red : color.new(color.gray, 40)
trendCol200_h1 = c_h1 > e2_h1 ? color.lime : c_h1 < e2_h1 ? color.red : color.new(color.gray, 40)

trendCol21_h2  = c_h2 > ema21_h2  ? color.lime : c_h2 < ema21_h2  ? color.red : color.new(color.gray, 40)
trendCol50_h2  = c_h2 > ema50_h2  ? color.lime : c_h2 < ema50_h2  ? color.red : color.new(color.gray, 40)
trendColEma_h2 = c_h2 > ema200_h2 ? color.lime : c_h2 < ema200_h2 ? color.red : color.new(color.gray, 40)
trendColSma_h2 = c_h2 > sma200_h2 ? color.lime : c_h2 < sma200_h2 ? color.red : color.new(color.gray, 40)

// ─── Plots (Main TF — linewidth 1) ───
p1 = plot(e1, color=color.new(#000000,  0), linewidth=1, title="Main EMA 21",  display=_visM21 ? display.all : display.none)
p2 = plot(e2, color=trendCol50,              linewidth=1, title="Main EMA 50",  display=_visM50 ? display.all : display.none)
p3 = plot(e3, color=color.new(#000000, 40),  linewidth=1, title="Main EMA 100", display=_visM21 ? display.all : display.none)
p4 = plot(e4, color=trendCol200,             linewidth=1, title="Main EMA 200", display=_visM200 ? display.all : display.none)

// ─── Plots (HTF 1 — linewidth 2) ───
plot(e1_h1, color=trendCol50_h1,  linewidth=2, title="HTF 1 EMA 50",  display=_vis1_50 ? display.all : display.none)
plot(e2_h1, color=trendCol200_h1, linewidth=2, title="HTF 1 EMA 200", display=_vis1200 ? display.all : display.none)

// ─── Plots (HTF 2 — linewidth 3) ───
plot(ema21_h2,  color=trendCol21_h2,  linewidth=3, title="HTF 2 EMA 21",  display=_vis2_21 ? display.all : display.none)
plot(ema50_h2,  color=trendCol50_h2,  linewidth=3, title="HTF 2 EMA 50",  display=_vis2_50 ? display.all : display.none)
plot(ema200_h2, color=trendColEma_h2, linewidth=3, title="HTF 2 EMA 200", display=_vis2E   ? display.all : display.none)
plot(sma200_h2, color=trendColSma_h2, linewidth=3, title="HTF 2 SMA 200", display=_vis2S   ? display.all : display.none)

// ─── Ribbon ───
colBull = color.new(color.lime, 80)
colBear = color.new(color.red,  80)
colNeu  = color.new(color.gray, 85)
ribbonCol = showMain ? (bull ? colBull : bear ? colBear : colNeu) : na
fill(p1, p2, color=ribbonCol, title="Ribbon 21-50")
fill(p2, p3, color=ribbonCol, title="Ribbon 50-100")

// ─── 3-Tier Candle Coloring + 50 EMA Retest (main TF) ───
neonBull = c_main > e1 and c_main > e2 and c_main > e3 and c_main > e4 and rsi_m > 50
neonBear = c_main < e1 and c_main < e2 and c_main < e3 and c_main < e4 and rsi_m < 50
midBull  = c_main > e1 and c_main > e2 and c_main > e3 and rsi_m > 50
midBear  = c_main < e1 and c_main < e2 and c_main < e3 and rsi_m < 50
softBull = c_main > e1 and c_main > e2 and rsi_m > 50
softBear = c_main < e1 and c_main < e2 and rsi_m < 50

retestZone = e2 * 0.005
retestBull = c_main > e2 and c_main < (e2 + retestZone) and not softBull
retestBear = c_main < e2 and c_main > (e2 - retestZone) and not softBear

barCol = neonBull ? #00E676 : neonBear ? #FF1744 : midBull ? #43A047 : midBear ? #E53935 : softBull ? #81C784 : softBear ? #E57373 : retestBull ? #26C6DA : retestBear ? #FFA726 : c_main > e2 ? #81C784 : #E57373
barcolor(showBarCol ? barCol : na, title="Trend Strength Candles")

// ─── CONFIRMED TABLE DATA ───
conf_mainUp   = c_main_1 > e2_1 and c_main_1 > e4_1
conf_mainDown = c_main_1 < e2_1 and c_main_1 < e4_1
conf_htf1Up   = c_h1_1 > e1_h1_1 and c_h1_1 > e2_h1_1
conf_htf1Down = c_h1_1 < e1_h1_1 and c_h1_1 < e2_h1_1
conf_htf2Up   = c_h2_1 > ema50_h2_1 and c_h2_1 > ema200_h2_1
conf_htf2Down = c_h2_1 < ema50_h2_1 and c_h2_1 < ema200_h2_1

tCol_m  = conf_mainUp ? color.lime : conf_mainDown ? color.red : #555555
tCol_h1 = conf_htf1Up ? color.lime : conf_htf1Down ? color.red : #555555
tCol_h2 = conf_htf2Up ? color.lime : conf_htf2Down ? color.red : #555555

conf_tDir_m  = e2_1 > e2_2
conf_tDir_h1 = e1_h1_1 > e1_h1_2
conf_tDir_h2 = ema50_h2_1 > ema50_h2_2

conf_momBull_m  = rsi_m_1  > 50 and sk_m_1  > 50
conf_momBear_m  = rsi_m_1  < 50 and sk_m_1  < 50
conf_momBull_h1 = rsi_h1_1 > 50 and sk_h1_1 > 50
conf_momBear_h1 = rsi_h1_1 < 50 and sk_h1_1 < 50
conf_momBull_h2 = rsi_h2_1 > 50 and sk_h2_1 > 50
conf_momBear_h2 = rsi_h2_1 < 50 and sk_h2_1 < 50

mCol_m  = conf_momBull_m  ? color.lime : conf_momBear_m  ? color.red : #555555
mCol_h1 = conf_momBull_h1 ? color.lime : conf_momBear_h1 ? color.red : #555555
mCol_h2 = conf_momBull_h2 ? color.lime : conf_momBear_h2 ? color.red : #555555

conf_mDir_m  = rsi_m_1  > rsi_m_2
conf_mDir_h1 = rsi_h1_1 > rsi_h1_2
conf_mDir_h2 = rsi_h2_1 > rsi_h2_2

// ─── Table ───
var table tbl = table.new(position.bottom_right, 5, 4, bgcolor=color.new(#000000, 80), border_width=0)

if barstate.islast and showTable
    table.cell(tbl, 0, 0, "",  text_color=color.black, text_size=size.small)
    table.cell(tbl, 1, 0, "T", text_color=color.black, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 0, "",  text_color=color.black, text_size=size.small)
    if showMom
        table.cell(tbl, 3, 0, "M", text_color=color.black, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 4, 0, "",  text_color=color.black, text_size=size.small)
    table.cell(tbl, 0, 1, tfLabel(htf), text_color=color.black, text_size=size.normal, text_halign=text.align_left)
    table.cell(tbl, 1, 1, conf_mainUp ? "▲" : conf_mainDown ? "▼" : "●", text_color=tCol_m, text_size=size.large, text_halign=text.align_center)
    table.cell(tbl, 2, 1, conf_tDir_m ? "↑" : "↓", text_color=conf_tDir_m ? color.lime : color.red, text_size=size.normal, text_halign=text.align_center)
    if showMom
        table.cell(tbl, 3, 1, conf_momBull_m ? "▲" : conf_momBear_m ? "▼" : "●", text_color=mCol_m, text_size=size.large, text_halign=text.align_center)
        table.cell(tbl, 4, 1, conf_mDir_m ? "↑" : "↓", text_color=conf_mDir_m ? color.lime : color.red, text_size=size.normal, text_halign=text.align_center)
    table.cell(tbl, 0, 2, tfLabel(htf1), text_color=color.black, text_size=size.normal, text_halign=text.align_left)
    table.cell(tbl, 1, 2, conf_htf1Up ? "▲" : conf_htf1Down ? "▼" : "●", text_color=tCol_h1, text_size=size.large, text_halign=text.align_center)
    table.cell(tbl, 2, 2, conf_tDir_h1 ? "↑" : "↓", text_color=conf_tDir_h1 ? color.lime : color.red, text_size=size.normal, text_halign=text.align_center)
    if showMom
        table.cell(tbl, 3, 2, conf_momBull_h1 ? "▲" : conf_momBear_h1 ? "▼" : "●", text_color=mCol_h1, text_size=size.large, text_halign=text.align_center)
        table.cell(tbl, 4, 2, conf_mDir_h1 ? "↑" : "↓", text_color=conf_mDir_h1 ? color.lime : color.red, text_size=size.normal, text_halign=text.align_center)
    table.cell(tbl, 0, 3, tfLabel(htf2), text_color=color.black, text_size=size.normal, text_halign=text.align_left)
    table.cell(tbl, 1, 3, conf_htf2Up ? "▲" : conf_htf2Down ? "▼" : "●", text_color=tCol_h2, text_size=size.large, text_halign=text.align_center)
    table.cell(tbl, 2, 3, conf_tDir_h2 ? "↑" : "↓", text_color=conf_tDir_h2 ? color.lime : color.red, text_size=size.normal, text_halign=text.align_center)
    if showMom
        table.cell(tbl, 3, 3, conf_momBull_h2 ? "▲" : conf_momBear_h2 ? "▼" : "●", text_color=mCol_h2, text_size=size.large, text_halign=text.align_center)
        table.cell(tbl, 4, 3, conf_mDir_h2 ? "↑" : "↓", text_color=conf_mDir_h2 ? color.lime : color.red, text_size=size.normal, text_halign=text.align_center)
````
