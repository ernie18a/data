# THE GENIUS PRO V6.1

- url: https://www.tradingview.com/script/pkjyAsyN-THE-GENIUS-PRO-V6-1/
- type: indicator
- pine_id: PUB;24fd60be131c4c59af8056158084424b
- version: 3.0

## Description

THE GENIUS PRO V6.1

THE GENIUS PRO CLEAN is a multi-timeframe trend and confirmation indicator designed to help traders identify high-probability trading opportunities while keeping charts clean and easy to read.

The indicator combines trend analysis, market structure, live support and resistance, session tracking, and a simple scoring system to provide an overall market assessment without cluttering the chart with unnecessary signals.

Features
Multi-Timeframe Trend Analysis

The indicator automatically analyses:

• 5 Minute
• 15 Minute
• 1 Hour
• 4 Hour
• Weekly

Each timeframe is evaluated against its EMA50 and displayed as:

🟢 Bullish
🔴 Bearish
🟠 Neutral

This allows traders to quickly identify alignment across multiple timeframes before entering a trade.

EMA50 Trend Filter

The 50-period Exponential Moving Average (EMA50) is used as the primary trend filter.

• Price above EMA50 = Bullish bias
• Price below EMA50 = Bearish bias

This helps traders stay aligned with the prevailing market direction.

Live Support & Resistance

Unlike traditional pivot-based support and resistance that can lag significantly, THE GENIUS PRO CLEAN uses dynamic live support and resistance levels based on recent market structure.

These levels update continuously and provide:

• Current support zones
• Current resistance zones
• Breakout confirmation levels

Market Structure Detection

The indicator monitors price interaction with support and resistance levels to identify:

🟢 Bullish Breaks
🔴 Bearish Breaks

This provides traders with confirmation that market structure has shifted before entering a position.

Session Tracker

The dashboard displays the currently active trading session along with a live countdown timer.

Sessions included:

🔴 Sydney
🟡 Asia
🟢 London
🟣 New York

This helps traders understand when liquidity and volatility are likely to increase throughout the trading day.

Trade Scoring System

THE GENIUS PRO CLEAN evaluates market conditions and assigns a score out of 10.

Grades:

🟢 A+ (9-10/10)
🟢 A (7-8/10)
🟠 B (5-6/10)
🔴 C (3-4/10)
⚫ No Trade (0-2/10)

The scoring system is designed to encourage patience and help traders focus on the highest-quality opportunities.

Trade Confirmation

The indicator generates one of three outputs:

🟢 BUY CONFIRMED
🔴 SELL CONFIRMED
⚪ WAIT

Signals are generated only when trend, structure, and scoring requirements are met.

Designed For

• Forex Traders
• Index Traders
• Cryptocurrency Traders
• Swing Traders
• Day Traders

Philosophy

THE GENIUS PRO CLEAN was built around a simple principle:

"Keep the chart clean. Follow the trend. Wait for confirmation. Take only high-quality setups."

This indicator is designed to assist decision-making and should always be used alongside sound risk management and a well-defined trading plan.

Not financial advice.

## Source Code

````pine
//@version=6
indicator("THE GENIUS PRO V6.3 DAILY BIAS + TRUE S/R", overlay=true, max_lines_count=30, max_labels_count=30)

// Inputs
emaLength = input.int(50, "EMA Length")

dailyLookback = input.int(100, "Daily S/R Lookback", minval=20, maxval=200)
dailyMinTouches = input.int(2, "Daily Minimum Touches", minval=2, maxval=10)
dailyTouchATR = input.float(0.25, "Daily Touch Tolerance ATR", minval=0.05, step=0.05)
srLineLength = input.int(200, "S/R Line Length", minval=50)

showEMA = input.bool(true, "Show EMA")
showSR = input.bool(true, "Show Daily True Support / Resistance")
waitForClose = input.bool(true, "Wait For Candle Close")
showSessions = input.bool(true, "Show Sessions")
sessionTZ = input.string("Europe/London", "Session Timezone")

confirmed = waitForClose ? barstate.isconfirmed : true

// EMA
float ema50 = ta.ema(close, emaLength)
plot(showEMA ? ema50 : na, "EMA 50", color=color.blue, linewidth=2)

// MTF Bias
biasCalc() =>
    float e = ta.ema(close, emaLength)
    close > e ? 1 : close < e ? -1 : 0

int bias5m = request.security(syminfo.tickerid, "5", biasCalc())
int bias15m = request.security(syminfo.tickerid, "15", biasCalc())
int bias1h = request.security(syminfo.tickerid, "60", biasCalc())
int bias4h = request.security(syminfo.tickerid, "240", biasCalc())
int biasD = request.security(syminfo.tickerid, "D", biasCalc())
int biasW = request.security(syminfo.tickerid, "W", biasCalc())

biasText(int b) =>
    b == 1 ? "Bullish" : b == -1 ? "Bearish" : "Neutral"

biasColor(int b) =>
    b == 1 ? color.green : b == -1 ? color.red : color.orange

// Sessions
bool sydneySession = not na(time(timeframe.period, "2100-0000", sessionTZ))
bool asiaSession = not na(time(timeframe.period, "0000-0800", sessionTZ))
bool londonSession = not na(time(timeframe.period, "0800-1300", sessionTZ))
bool newyorkSession = not na(time(timeframe.period, "1300-2100", sessionTZ))

int y = year(timenow, sessionTZ)
int mo = month(timenow, sessionTZ)
int d = dayofmonth(timenow, sessionTZ)

int asiaStart = timestamp(sessionTZ, y, mo, d, 0, 0)
int asiaEnd = timestamp(sessionTZ, y, mo, d, 8, 0)
int londonStart = timestamp(sessionTZ, y, mo, d, 8, 0)
int londonEnd = timestamp(sessionTZ, y, mo, d, 13, 0)
int nyStart = timestamp(sessionTZ, y, mo, d, 13, 0)
int nyEnd = timestamp(sessionTZ, y, mo, d, 21, 0)
int sydneyStart = timestamp(sessionTZ, y, mo, d, 21, 0)
int sydneyEnd = timestamp(sessionTZ, y, mo, d + 1, 0, 0)
int tomorrowAsiaStart = timestamp(sessionTZ, y, mo, d + 1, 0, 0)

timerText(int ms) =>
    int totalSec = int(math.max(ms, 0) / 1000)
    int h = int(math.floor(totalSec / 3600))
    int m = int(math.floor((totalSec % 3600) / 60))
    str.tostring(h) + "h " + str.tostring(m) + "m"

string activeSession =
     not showSessions ? "Hidden" :
     sydneySession ? "Sydney" :
     asiaSession ? "Asia" :
     londonSession ? "London" :
     newyorkSession ? "New York" :
     "Closed"

color sessionColor =
     not showSessions ? color.gray :
     sydneySession ? color.red :
     asiaSession ? color.yellow :
     londonSession ? color.green :
     newyorkSession ? color.purple :
     color.gray

color sessionTextColor = asiaSession ? color.black : color.white

string nextSession =
     not showSessions ? "Hidden" :
     sydneySession ? "Sydney closes" :
     asiaSession ? "Asia closes" :
     londonSession ? "London closes" :
     newyorkSession ? "New York closes" :
     timenow < asiaStart ? "Asia opens" :
     timenow < londonStart ? "London opens" :
     timenow < nyStart ? "New York opens" :
     timenow < sydneyStart ? "Sydney opens" :
     "Asia opens"

int targetTime =
     sydneySession ? sydneyEnd :
     asiaSession ? asiaEnd :
     londonSession ? londonEnd :
     newyorkSession ? nyEnd :
     timenow < asiaStart ? asiaStart :
     timenow < londonStart ? londonStart :
     timenow < nyStart ? nyStart :
     timenow < sydneyStart ? sydneyStart :
     tomorrowAsiaStart

string sessionTimer = timerText(targetTime - timenow)

// Daily True Support / Resistance
dailySRCalc() =>
    float dAtr = ta.atr(14)
    float tolerance = dAtr * dailyTouchATR

    float bestResistance = na
    int bestResTouches = 0
    float bestResDistance = 100000000.0

    float bestSupport = na
    int bestSupTouches = 0
    float bestSupDistance = 100000000.0

    for i = 1 to dailyLookback
        float resCandidate = high[i]

        if resCandidate > close
            int resTouches = 0

            for j = 1 to dailyLookback
                bool touchedResistance = math.abs(high[j] - resCandidate) <= tolerance and close[j] < resCandidate
                resTouches += touchedResistance ? 1 : 0

            float resDistance = resCandidate - close

            if resTouches >= dailyMinTouches and resDistance < bestResDistance
                bestResDistance := resDistance
                bestResTouches := resTouches
                bestResistance := resCandidate

        float supCandidate = low[i]

        if supCandidate < close
            int supTouches = 0

            for j = 1 to dailyLookback
                bool touchedSupport = math.abs(low[j] - supCandidate) <= tolerance and close[j] > supCandidate
                supTouches += touchedSupport ? 1 : 0

            float supDistance = close - supCandidate

            if supTouches >= dailyMinTouches and supDistance < bestSupDistance
                bestSupDistance := supDistance
                bestSupTouches := supTouches
                bestSupport := supCandidate

    [bestResistance, bestResTouches, bestSupport, bestSupTouches]

[resistance, resTouches, support, supTouches] = request.security(syminfo.tickerid, "D", dailySRCalc())

bool validResistance = not na(resistance) and resTouches >= dailyMinTouches
bool validSupport = not na(support) and supTouches >= dailyMinTouches

bool bullishBreak = confirmed and validResistance and close > resistance
bool bearishBreak = confirmed and validSupport and close < support

// Daily S/R Lines
var line resLine = na
var line supLine = na

if showSR and barstate.islast
    if not na(resLine)
        line.delete(resLine)
    if not na(supLine)
        line.delete(supLine)

    if validResistance
        resLine := line.new(bar_index - srLineLength, resistance, bar_index, resistance, extend=extend.right, color=color.red, width=2)

    if validSupport
        supLine := line.new(bar_index - srLineLength, support, bar_index, support, extend=extend.right, color=color.green, width=2)

// Bias
bool bullishBias = close > ema50
bool bearishBias = close < ema50

// Score
int buyScore = 0
buyScore += bullishBias ? 2 : 0
buyScore += bullishBreak ? 3 : 0
buyScore += close > open ? 2 : 0
buyScore += bias15m == 1 ? 1 : 0
buyScore += bias1h == 1 ? 1 : 0
buyScore += biasD == 1 ? 1 : 0

int sellScore = 0
sellScore += bearishBias ? 2 : 0
sellScore += bearishBreak ? 3 : 0
sellScore += close < open ? 2 : 0
sellScore += bias15m == -1 ? 1 : 0
sellScore += bias1h == -1 ? 1 : 0
sellScore += biasD == -1 ? 1 : 0

int finalScore = math.max(buyScore, sellScore)

string grade = finalScore >= 9 ? "A+" : finalScore >= 7 ? "A" : finalScore >= 5 ? "B" : finalScore >= 3 ? "C" : "No Trade"
color gradeColor = finalScore >= 9 ? color.lime : finalScore >= 7 ? color.green : finalScore >= 5 ? color.orange : finalScore >= 3 ? color.red : color.gray

string signal = buyScore > sellScore and finalScore >= 7 ? "BUY CONFIRMED" : sellScore > buyScore and finalScore >= 7 ? "SELL CONFIRMED" : "WAIT"
color signalColor = signal == "BUY CONFIRMED" ? color.green : signal == "SELL CONFIRMED" ? color.red : color.gray

string structureText = bullishBreak ? "Bullish Break" : bearishBreak ? "Bearish Break" : "Waiting"
color structureColor = bullishBreak ? color.green : bearishBreak ? color.red : color.gray

// Dashboard
var table dash = table.new(position.top_right, 2, 16, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "THE GENIUS", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "PRO V6.3", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Candle", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 1, confirmed ? "Closed" : "Waiting", bgcolor=confirmed ? color.green : color.orange, text_color=color.white)

    table.cell(dash, 0, 2, "5M", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 2, biasText(bias5m), bgcolor=biasColor(bias5m), text_color=color.white)

    table.cell(dash, 0, 3, "15M", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 3, biasText(bias15m), bgcolor=biasColor(bias15m), text_color=color.white)

    table.cell(dash, 0, 4, "1H", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 4, biasText(bias1h), bgcolor=biasColor(bias1h), text_color=color.white)

    table.cell(dash, 0, 5, "4H", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 5, biasText(bias4h), bgcolor=biasColor(bias4h), text_color=color.white)

    table.cell(dash, 0, 6, "D", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 6, biasText(biasD), bgcolor=biasColor(biasD), text_color=color.white)

    table.cell(dash, 0, 7, "W", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 7, biasText(biasW), bgcolor=biasColor(biasW), text_color=color.white)

    table.cell(dash, 0, 8, "EMA50", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 8, bullishBias ? "Above" : "Below", bgcolor=bullishBias ? color.green : color.red, text_color=color.white)

    table.cell(dash, 0, 9, "Session", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 9, activeSession, bgcolor=sessionColor, text_color=sessionTextColor)

    table.cell(dash, 0, 10, nextSession, bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 10, sessionTimer, bgcolor=sessionColor, text_color=sessionTextColor)

    table.cell(dash, 0, 11, "Daily S/R Touches", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 11, str.tostring(supTouches) + " / " + str.tostring(resTouches), bgcolor=color.black, text_color=color.white)

    table.cell(dash, 0, 12, "Structure", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 12, structureText, bgcolor=structureColor, text_color=color.white)

    table.cell(dash, 0, 13, "Score", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 13, str.tostring(finalScore) + "/10", bgcolor=gradeColor, text_color=color.white)

    table.cell(dash, 0, 14, "Grade", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 14, grade, bgcolor=gradeColor, text_color=color.white)

    table.cell(dash, 0, 15, "Signal", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 15, signal, bgcolor=signalColor, text_color=color.white)

// Alerts
bool buyConfirmed = confirmed and bullishBias and bullishBreak and finalScore >= 7
bool sellConfirmed = confirmed and bearishBias and bearishBreak and finalScore >= 7

alertcondition(buyConfirmed, title="Buy Confirmed", message="THE GENIUS PRO V6.3: Buy confirmed after candle close")
alertcondition(sellConfirmed, title="Sell Confirmed", message="THE GENIUS PRO V6.3: Sell confirmed after candle close")
````
