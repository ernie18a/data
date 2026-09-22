<!-- tradingview-pine-id: PUB;19cbd28b7ba14cabb2747168f9dddf56 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# D.vis Swing Engine - RP + RVOL + Trend

Source: https://www.tradingview.com/script/k71CR80n-D-vis-Swing-Engine-RP-RVOL-Trend/

## Description

## English

**D.vis Swing Engine – Relative Performance + Relative Volume + Trend**

D.vis Swing Engine is a swing trading indicator designed to identify stocks that combine positive trend structure, relative strength versus the S&P 500, and above-average trading volume.

The indicator combines several technical components into a single visual framework:

**Relative Performance (RP)** compares the stock's performance with the S&P 500, using SPY as the default benchmark. A positive RP value means the stock has outperformed the benchmark during the selected lookback period. The indicator also measures whether Relative Performance is improving or deteriorating.

**Relative Volume (RVOL)** compares the current trading volume with the stock's average volume over a selected period. An RVOL above 1.0 indicates above-average volume, while values such as 1.5x or 2.0x indicate significantly increased market participation.

The indicator classifies high relative volume on bullish candles as **Money In** and high relative volume on bearish candles as **Money Out**. These readings should be interpreted as proxies for buying and selling pressure rather than literal capital inflows or outflows.

The trend component uses:

- EMA 9
- EMA 21
- SMA 50
- SMA 200

The primary bullish trend condition requires price to trade above EMA 9 while EMA 9 is above EMA 21. SMA 50, SMA 200, and EMA 21 slope filters can optionally be enabled for more restrictive setups.

The indicator also calculates a **Setup Score from 0 to 5** based on five conditions:

1. Price is above EMA 21.
2. EMA 9 is above EMA 21.
3. Relative Performance is positive.
4. Relative Performance is rising.
5. Relative Volume exceeds the selected threshold on a bullish candle.

The dashboard classifies the setup as:

**WAIT** – insufficient conditions are aligned.

**WATCH** – most conditions are aligned and the stock may be approaching a valid setup.

**BUY 5/5** – trend, Relative Performance, and Relative Volume conditions are fully aligned.

A BUY label is displayed only when the complete bullish setup becomes valid for the first time, helping reduce repeated signals during an already established trend.

The indicator also includes a **RISK** condition designed to highlight potential distribution. This occurs when price falls below EMA 21, Relative Performance becomes negative, and strong relative volume appears on a bearish candle.

### Suggested settings for swing trading

- Benchmark: SPY
- Relative Performance Timeframe: Daily
- RP Lookback: 63 trading days
- RP Momentum Period: 5 trading days
- RVOL Average Length: 20
- RVOL Threshold: 1.5x
- SMA 50 Filter: Optional
- SMA 200 Filter: Optional

This indicator is intended as a decision-support tool and should not be used as a standalone trading system. Market structure, support and resistance, earnings, fundamental factors, risk management, and broader market conditions should also be considered.

---

## Română

**D.vis Swing Engine – Performanță Relativă + Volum Relativ + Trend**

D.vis Swing Engine este un indicator pentru swing trading conceput pentru a identifica acțiunile care combină o structură tehnică pozitivă, performanță relativă superioară față de S&P 500 și volum de tranzacționare peste medie.

Indicatorul combină mai multe componente tehnice într-un singur sistem vizual:

**Relative Performance (RP)** compară performanța acțiunii cu S&P 500, folosind implicit SPY drept benchmark. O valoare RP pozitivă înseamnă că acțiunea a performat mai bine decât benchmark-ul în perioada selectată. Indicatorul măsoară și dacă performanța relativă se îmbunătățește sau se deteriorează.

**Relative Volume (RVOL)** compară volumul curent de tranzacționare cu volumul mediu al acțiunii din perioada selectată. Un RVOL peste 1,0 indică un volum peste medie, iar valori precum 1,5x sau 2,0x indică o creștere semnificativă a participării în piață.

Indicatorul clasifică volumul relativ ridicat pe lumânări bullish drept **Money In**, iar volumul relativ ridicat pe lumânări bearish drept **Money Out**. Aceste valori trebuie interpretate ca aproximări ale presiunii de cumpărare sau vânzare, nu ca intrări sau ieșiri literale de capital.

Componenta de trend utilizează:

- EMA 9
- EMA 21
- SMA 50
- SMA 200

Condiția bullish principală cere ca prețul să fie peste EMA 9, iar EMA 9 să fie peste EMA 21. Filtrele SMA 50, SMA 200 și panta EMA 21 pot fi activate opțional pentru setup-uri mai restrictive.

Indicatorul calculează și un **Setup Score de la 0 la 5**, bazat pe cinci condiții:

1. Prețul este peste EMA 21.
2. EMA 9 este peste EMA 21.
3. Relative Performance este pozitiv.
4. Relative Performance este în creștere.
5. Relative Volume depășește pragul selectat pe o lumânare bullish.

Dashboard-ul clasifică setup-ul astfel:

**WAIT** – nu sunt îndeplinite suficiente condiții.

**WATCH** – majoritatea condițiilor sunt îndeplinite, iar acțiunea se poate apropia de un setup valid.

**BUY 5/5** – condițiile de trend, Relative Performance și Relative Volume sunt complet aliniate.

Eticheta BUY este afișată doar în momentul în care setup-ul bullish complet devine valid pentru prima dată, reducând astfel semnalele repetate în timpul unui trend deja confirmat.

Indicatorul include și o condiție **RISK**, concepută pentru a evidenția posibile perioade de distribuție. Aceasta apare atunci când prețul scade sub EMA 21, Relative Performance devine negativ, iar pe o lumânare bearish apare un volum relativ ridicat.

### Setări recomandate pentru swing trading

- Benchmark: SPY
- Timeframe Relative Performance: Daily
- RP Lookback: 63 zile de tranzacționare
- RP Momentum Period: 5 zile
- Media pentru RVOL: 20 perioade
- Prag RVOL: 1,5x
- Filtru SMA 50: Opțional
- Filtru SMA 200: Opțional

Indicatorul este conceput ca instrument de suport pentru luarea deciziilor și nu trebuie utilizat ca sistem de tranzacționare independent. Structura pieței, suporturile și rezistențele, raportările financiare, factorii fundamentali, managementul riscului și condițiile generale ale pieței trebuie analizate separat.

---

## Source Code

````pine
//@version=6
indicator("D.vis Swing Engine - RP + RVOL + Trend", shorttitle="Swing Engine", overlay=true)

// =====================================================
// 1. INPUTS
// =====================================================

// ----- MOVING AVERAGES -----
groupMA = "1. Trend / Moving Averages"

showMAs = input.bool(true, "Show Moving Averages", group=groupMA)
useSMA50Gate = input.bool(false, "Require Price > SMA50", group=groupMA)
useSMA200Gate = input.bool(false, "Require Price > SMA200", group=groupMA)
requireEMA21Up = input.bool(false, "Require EMA21 Rising", group=groupMA)


// ----- RELATIVE PERFORMANCE -----
groupRP = "2. Relative Performance"

benchmark = input.symbol("AMEX:SPY", "Benchmark", group=groupRP)
rpTF = input.timeframe("1D", "RP Timeframe", group=groupRP)
rpLookback = input.int(63, "RP Lookback", minval=5, group=groupRP)
rpSlopeBars = input.int(5, "RP Momentum Period", minval=1, group=groupRP)
minRP = input.float(0.0, "Minimum RP %", step=0.1, group=groupRP)


// ----- RELATIVE VOLUME -----
groupRVOL = "3. Relative Volume"

volLength = input.int(20, "Average Volume Length", minval=2, group=groupRVOL)
rvolThreshold = input.float(1.5, "RVOL Threshold", minval=0.1, step=0.1, group=groupRVOL)

directionMethod = input.string(
     "Close > Open",
     "Positive Volume Definition",
     options=["Close > Open", "Close > Previous Close"],
     group=groupRVOL)


// ----- SIGNALS -----
groupSIG = "4. Signals"

showBuySignal = input.bool(true, "Show BUY Signal", group=groupSIG)
showRiskSignal = input.bool(true, "Show RISK Signal", group=groupSIG)
showBackground = input.bool(false, "Highlight Full Setup", group=groupSIG)
colorBars = input.bool(false, "Color Bars", group=groupSIG)


// ----- DASHBOARD -----
groupDASH = "5. Dashboard"

showDashboard = input.bool(true, "Show Dashboard", group=groupDASH)


// =====================================================
// 2. MOVING AVERAGES
// =====================================================

ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)


// =====================================================
// 3. PLOT MOVING AVERAGES
// =====================================================

plot(showMAs ? ema9 : na, title="EMA 9", color=color.yellow, linewidth=2)
plot(showMAs ? ema21 : na, title="EMA 21", color=color.orange, linewidth=2)
plot(showMAs ? sma50 : na, title="SMA 50", color=color.aqua, linewidth=2)
plot(showMAs ? sma200 : na, title="SMA 200", color=color.blue, linewidth=2)


// =====================================================
// 4. RELATIVE PERFORMANCE vs S&P 500
// =====================================================

// Randamentul actiunii pe perioada selectata
stockReturn = request.security(
     syminfo.tickerid,
     rpTF,
     close / close[rpLookback])

// Randamentul anterior al actiunii
stockReturnPrev = request.security(
     syminfo.tickerid,
     rpTF,
     close[rpSlopeBars] / close[rpLookback + rpSlopeBars])

// Randamentul benchmark-ului
benchReturn = request.security(
     benchmark,
     rpTF,
     close / close[rpLookback])

// Randamentul anterior al benchmark-ului
benchReturnPrev = request.security(
     benchmark,
     rpTF,
     close[rpSlopeBars] / close[rpLookback + rpSlopeBars])


// Relative Performance actual
rp = 100 * (stockReturn / benchReturn - 1)

// Relative Performance anterior
rpPrev = 100 * (stockReturnPrev / benchReturnPrev - 1)


// Conditii RP
rpPositive = rp > minRP
rpRising = rp > rpPrev

rpOK = rpPositive and rpRising


// =====================================================
// 5. RELATIVE VOLUME
// =====================================================

avgVolume = ta.sma(volume, volLength)

rvol = volume / avgVolume


// Directia pretului
bool bullBar = false
bool bearBar = false

if directionMethod == "Close > Open"
    bullBar := close > open
    bearBar := close < open
else
    bullBar := close > close[1]
    bearBar := close < close[1]


// Money In / Money Out
strongMoneyIn = rvol >= rvolThreshold and bullBar
strongMoneyOut = rvol >= rvolThreshold and bearBar


// =====================================================
// 6. TREND ENGINE
// =====================================================

// Trend principal
emaAlignment = close > ema9 and ema9 > ema21

// EMA21 Rising
ema21Rising = ema21 > ema21[1]


// Filtru SMA50
bool sma50OK = true

if useSMA50Gate
    sma50OK := close > sma50


// Filtru SMA200
bool sma200OK = true

if useSMA200Gate
    sma200OK := close > sma200


// Filtru EMA21 rising
bool ema21SlopeOK = true

if requireEMA21Up
    ema21SlopeOK := ema21Rising


// Trend final
trendOK = emaAlignment and sma50OK and sma200OK and ema21SlopeOK


// =====================================================
// 7. SETUP SCORE
// =====================================================

int score = 0

if close > ema21
    score += 1

if ema9 > ema21
    score += 1

if rpPositive
    score += 1

if rpRising
    score += 1

if strongMoneyIn
    score += 1


// =====================================================
// 8. BUY ENGINE
// =====================================================

// Toate conditiile trebuie sa fie indeplinite
fullSetup = trendOK and rpOK and strongMoneyIn


// Semnal numai pe prima bara
buySignal = fullSetup and not fullSetup[1]


// =====================================================
// 9. RISK ENGINE
// =====================================================

riskCondition = close < ema21 and rp < 0 and strongMoneyOut

riskSignal = riskCondition and not riskCondition[1]


// =====================================================
// 10. BUY / RISK SIGNALS
// =====================================================

plotshape(
     showBuySignal and buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.small)

plotshape(
     showRiskSignal and riskSignal,
     title="RISK",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="RISK",
     textcolor=color.white,
     size=size.small)


// =====================================================
// 11. BACKGROUND COLOR
// =====================================================

color backgroundColor = na

if showBackground and fullSetup
    backgroundColor := color.new(color.lime, 90)

bgcolor(backgroundColor)


// =====================================================
// 12. BAR COLORS
// =====================================================

color customBarColor = na

if colorBars
    if fullSetup
        customBarColor := color.lime
    else if riskCondition
        customBarColor := color.red

barcolor(customBarColor)


// =====================================================
// 13. DATA WINDOW
// =====================================================

plot(
     rp,
     title="Relative Performance %",
     display=display.data_window)

plot(
     rvol,
     title="Relative Volume",
     display=display.data_window)

plot(
     score,
     title="Setup Score",
     display=display.data_window)


// =====================================================
// 14. DASHBOARD COLORS
// =====================================================

// Background colors
tableBg       = color.rgb(70, 70, 70)
tableHeaderBg = color.rgb(45, 65, 85)

// Status colors
bullBg    = color.rgb(40, 120, 70)
bearBg    = color.rgb(150, 55, 55)
neutralBg = color.rgb(90, 90, 90)
watchBg   = color.rgb(200, 130, 35)
buyBg     = color.rgb(70, 200, 90)

// Text colors
tableText = color.white
darkText  = color.black


// =====================================================
// 15. CREATE DASHBOARD
// =====================================================

var table dashboard = table.new(
     position.top_right,
     2,
     9,
     frame_color=color.rgb(90, 90, 90),
     frame_width=1,
     border_color=color.rgb(110, 110, 110),
     border_width=1)


// =====================================================
// 16. DASHBOARD CONTENT
// =====================================================

if barstate.islast and showDashboard

    // -------------------------------------------------
    // HEADER
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         0,
         "D.VIS",
         bgcolor=tableHeaderBg,
         text_color=tableText,
         text_size=size.small)

    table.cell(
         dashboard,
         1,
         0,
         "SWING ENGINE",
         bgcolor=tableHeaderBg,
         text_color=tableText,
         text_size=size.small)


    // -------------------------------------------------
    // TREND
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         1,
         "TREND",
         bgcolor=tableBg,
         text_color=tableText,
         text_size=size.small)

    if trendOK
        table.cell(
             dashboard,
             1,
             1,
             "BULL",
             bgcolor=bullBg,
             text_color=tableText,
             text_size=size.small)
    else
        table.cell(
             dashboard,
             1,
             1,
             "NOT READY",
             bgcolor=bearBg,
             text_color=tableText,
             text_size=size.small)


    // -------------------------------------------------
    // RELATIVE PERFORMANCE
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         2,
         "RP vs SPY",
         bgcolor=tableBg,
         text_color=tableText,
         text_size=size.small)

    if rpPositive
        table.cell(
             dashboard,
             1,
             2,
             str.tostring(rp, "#.##") + "%",
             bgcolor=bullBg,
             text_color=tableText,
             text_size=size.small)
    else
        table.cell(
             dashboard,
             1,
             2,
             str.tostring(rp, "#.##") + "%",
             bgcolor=bearBg,
             text_color=tableText,
             text_size=size.small)


    // -------------------------------------------------
    // RP MOMENTUM
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         3,
         "RP MOMENTUM",
         bgcolor=tableBg,
         text_color=tableText,
         text_size=size.small)

    if rpRising
        table.cell(
             dashboard,
             1,
             3,
             "RISING",
             bgcolor=bullBg,
             text_color=tableText,
             text_size=size.small)
    else
        table.cell(
             dashboard,
             1,
             3,
             "FALLING",
             bgcolor=bearBg,
             text_color=tableText,
             text_size=size.small)


    // -------------------------------------------------
// RVOL
// -------------------------------------------------

table.cell(
     dashboard,
     0,
     4,
     "RVOL",
     bgcolor=tableBg,
     text_color=tableText,
     text_size=size.small)

if strongMoneyIn
    table.cell(
         dashboard,
         1,
         4,
         str.tostring(rvol, "#.##") + "x",
         bgcolor=bullBg,
         text_color=tableText,
         text_size=size.small)

else if strongMoneyOut
    table.cell(
         dashboard,
         1,
         4,
         str.tostring(rvol, "#.##") + "x",
         bgcolor=bearBg,
         text_color=tableText,
         text_size=size.small)

else
    table.cell(
         dashboard,
         1,
         4,
         str.tostring(rvol, "#.##") + "x",
         bgcolor=neutralBg,
         text_color=tableText,
         text_size=size.small)


    // -------------------------------------------------
    // VOLUME FLOW
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         5,
         "VOLUME FLOW",
         bgcolor=tableBg,
         text_color=tableText,
         text_size=size.small)

    if strongMoneyIn
        table.cell(
             dashboard,
             1,
             5,
             "MONEY IN",
             bgcolor=bullBg,
             text_color=tableText,
             text_size=size.small)

    else if strongMoneyOut
        table.cell(
             dashboard,
             1,
             5,
             "MONEY OUT",
             bgcolor=bearBg,
             text_color=tableText,
             text_size=size.small)

    else
        table.cell(
             dashboard,
             1,
             5,
             "NORMAL",
             bgcolor=neutralBg,
             text_color=tableText,
             text_size=size.small)


    // -------------------------------------------------
    // SMA 50
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         6,
         "SMA50",
         bgcolor=tableBg,
         text_color=tableText,
         text_size=size.small)

    if close > sma50
        table.cell(
             dashboard,
             1,
             6,
             "ABOVE",
             bgcolor=bullBg,
             text_color=tableText,
             text_size=size.small)
    else
        table.cell(
             dashboard,
             1,
             6,
             "BELOW",
             bgcolor=bearBg,
             text_color=tableText,
             text_size=size.small)


    // -------------------------------------------------
    // SMA 200
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         7,
         "SMA200",
         bgcolor=tableBg,
         text_color=tableText,
         text_size=size.small)

    if close > sma200
        table.cell(
             dashboard,
             1,
             7,
             "ABOVE",
             bgcolor=bullBg,
             text_color=tableText,
             text_size=size.small)
    else
        table.cell(
             dashboard,
             1,
             7,
             "BELOW",
             bgcolor=bearBg,
             text_color=tableText,
             text_size=size.small)


    // -------------------------------------------------
    // FINAL SETUP
    // -------------------------------------------------

    table.cell(
         dashboard,
         0,
         8,
         "SETUP",
         bgcolor=tableBg,
         text_color=tableText,
         text_size=size.small)

    if fullSetup
        table.cell(
             dashboard,
             1,
             8,
             "BUY 5/5",
             bgcolor=buyBg,
             text_color=darkText,
             text_size=size.small)

    else if score >= 4
        table.cell(
             dashboard,
             1,
             8,
             "WATCH " + str.tostring(score) + "/5",
             bgcolor=watchBg,
             text_color=darkText,
             text_size=size.small)

    else
        table.cell(
             dashboard,
             1,
             8,
             "WAIT " + str.tostring(score) + "/5",
             bgcolor=neutralBg,
             text_color=tableText,
             text_size=size.small)


// Hide dashboard when disabled
if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 8)


// =====================================================
// 16. ALERTS
// =====================================================

alertcondition(
     buySignal,
     title="BUY - Full Alignment",
     message="BUY: Trend + Relative Performance + Relative Volume aligned.")

alertcondition(
     riskSignal,
     title="RISK - Distribution",
     message="RISK: Weak trend + underperformance + high selling volume.")
````
