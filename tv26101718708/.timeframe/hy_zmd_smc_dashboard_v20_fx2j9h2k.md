# Hy ZMD - SMC Dashboard v2.0

- url: https://www.tradingview.com/script/fX2J9H2k-Hy-ZMD-SMC-Dashboard-v2-0/
- type: indicator
- pine_id: PUB;f5a4fdf2868e4242b6ee50c9beb35a08
- version: 1.0

## Description

Wait and wait until you have enough elements. You will keep a lot of money that is not worth losing because of haste.

## Source Code

````pine
//@version=6
indicator("Hy ZMD - SMC Dashboard v2.0", overlay = true, max_labels_count = 500)

//====================================================
// INPUTS
//====================================================

swingLen = input.int(5, "Swing Length", minval = 2)

showDashboard = input.bool(true, "Show Dashboard")

//====================================================
// SESSION ENGINE
//====================================================

vnHour = hour(time, "Asia/Ho_Chi_Minh")

asiaSession =
     vnHour >= 7 and vnHour < 14

londonSession =
     vnHour >= 14 and vnHour < 17

newYorkSession =
     vnHour >= 19 and vnHour < 23

silverBullet =
     vnHour >= 22 and vnHour < 23

currentSession =
     silverBullet ? "SILVER BULLET" :
     newYorkSession ? "NEW YORK" :
     londonSession ? "LONDON" :
     asiaSession ? "ASIA" :
     "OFF SESSION"

//====================================================
// HTF EMA ENGINE
//====================================================

f_bias(tf)=>

    ema34 =
         request.security(
         syminfo.tickerid,
         tf,
         ta.ema(close,34))

    ema89 =
         request.security(
         syminfo.tickerid,
         tf,
         ta.ema(close,89))

    ema200 =
         request.security(
         syminfo.tickerid,
         tf,
         ta.ema(close,200))

    ema610 =
         request.security(
         syminfo.tickerid,
         tf,
         ta.ema(close,610))

    bull =
         ema34 > ema89 and
         ema89 > ema200 and
         ema200 > ema610

    bear =
         ema34 < ema89 and
         ema89 < ema200 and
         ema200 < ema610

    bull ? "BULL" :
     bear ? "BEAR" :
     "NEUTRAL"

//====================================================
// BIAS
//====================================================

dailyBias = f_bias("D")
h4Bias    = f_bias("240")
h1Bias    = f_bias("60")
m15Bias   = f_bias("15")

//====================================================
// HTF STRUCTURE
//====================================================

dailyHigh = request.security(syminfo.tickerid, "D", ta.highest(high[1], swingLen))

dailyLow = request.security(syminfo.tickerid, "D", ta.lowest(low[1], swingLen))

dailyClose = request.security(syminfo.tickerid, "D", close)

dailyBosBull = dailyClose > dailyHigh

dailyBosBear = dailyClose < dailyLow

//----------------------

h4High = request.security(syminfo.tickerid, "240", ta.highest(high[1], swingLen))

h4Low = request.security(syminfo.tickerid, "240", ta.lowest(low[1], swingLen))

h4Close = request.security(syminfo.tickerid, "240", close)

h4BosBull = h4Close > h4High

h4BosBear = h4Close < h4Low

//----------------------

h1High = request.security(syminfo.tickerid, "60", ta.highest(high[1], swingLen))

h1Low = request.security(syminfo.tickerid, "60", ta.lowest(low[1], swingLen))

h1Close = request.security(syminfo.tickerid, "60", close)

h1BosBull = h1Close > h1High

h1BosBear = h1Close < h1Low

//====================================================
// STRUCTURE ENGINE
//====================================================

bosBull =
     close >
     ta.highest(high[1], swingLen)

bosBear =
     close <
     ta.lowest(low[1], swingLen)

bullChoch =
     low < low[1] and
     close > high[1]

bearChoch =
     high > high[1] and
     close < low[1]

//====================================================
// H1 LIQUIDITY ENGINE
//====================================================

h1PrevHigh = request.security(syminfo.tickerid, "60", ta.highest(high[1], swingLen))
h1PrevLow = request.security(syminfo.tickerid, "60", ta.lowest(low[1], swingLen))

h1LiquidityHigh = request.security(syminfo.tickerid, "60", high)
h1LiquidityLow = request.security(syminfo.tickerid, "60", low)
h1LiquidityClose = request.security(syminfo.tickerid, "60", close)

sslSweep = h1LiquidityLow < h1PrevLow and h1LiquidityClose > h1PrevLow

bslSweep = h1LiquidityHigh > h1PrevHigh and h1LiquidityClose < h1PrevHigh

//====================================================
// DRAW ON LIQUIDITY
//====================================================

bslLevel = ta.highest(high, 20)

sslLevel = ta.lowest(low, 20)

drawOnLiquidity =
     math.abs(close - bslLevel) <
     math.abs(close - sslLevel)
     ? "BSL"
     : "SSL"

//====================================================
// SCORE ENGINE
//====================================================

score = 0

score += dailyBias == "BULL" or dailyBias == "BEAR" ? 2 : 0
score += h4Bias == "BULL" or h4Bias == "BEAR" ? 2 : 0
score += h1Bias == "BULL" or h1Bias == "BEAR" ? 2 : 0
score += m15Bias == "BULL" or m15Bias == "BEAR" ? 2 : 0

score += (bosBull or bosBear) ? 2 : 0
score += (bullChoch or bearChoch) ? 2 : 0
score += (sslSweep or bslSweep) ? 3 : 0

//====================================================
// SIGNAL ENGINE
//====================================================

buySignal =
     dailyBias == "BULL" and
     h4Bias == "BULL" and
     h1Bias == "BULL" and
     bosBull and
     sslSweep and
     score >= 10

sellSignal =
     dailyBias == "BEAR" and
     h4Bias == "BEAR" and
     h1Bias == "BEAR" and
     bosBear and
     bslSweep and
     score >= 10

signal =
     buySignal ? "BUY" :
     sellSignal ? "SELL" :
     "WAIT"

//====================================================
// QUALITY
//====================================================

quality =
     score >= 15 ? "A+" :
     score >= 10 ? "GOOD" :
     score >= 7 ? "WATCH" :
     "NO TRADE"

//====================================================
// DASHBOARD
//====================================================

var table dashboard =
     table.new(
     position.top_right,
     2,
     17,
     border_width = 1)

if barstate.islast and showDashboard

    table.cell(dashboard,0,0,"Hy ZMD")
    table.cell(dashboard,1,0,"SMC v2.0")

    table.cell(dashboard,0,1,"Daily")
    table.cell(dashboard,1,1,dailyBias)

    table.cell(dashboard,0,2,"H4")
    table.cell(dashboard,1,2,h4Bias)

    table.cell(dashboard,0,3,"H1")
    table.cell(dashboard,1,3,h1Bias)

    table.cell(dashboard,0,4,"M15")
    table.cell(dashboard,1,4,m15Bias)

    table.cell(dashboard,0,5,"BOS")
    table.cell(dashboard,1,5,(bosBull or bosBear) ? "YES" : "NO")

    table.cell(dashboard,0,6,"CHOCH")
    table.cell(dashboard,1,6,(bullChoch or bearChoch) ? "YES" : "NO")

    table.cell(dashboard,0,7,"SSL")
    table.cell(dashboard,1,7,sslSweep ? "YES" : "NO")

    table.cell(dashboard,0,8,"BSL")
    table.cell(dashboard,1,8,bslSweep ? "YES" : "NO")

    table.cell(dashboard,0,9,"Session")
    table.cell(dashboard,1,9,currentSession)

    table.cell(dashboard,0,10,"Draw On")
    table.cell(dashboard,1,10,drawOnLiquidity)

    table.cell(dashboard,0,11,"Score")
    table.cell(dashboard,1,11,str.tostring(score)+"/15")

    table.cell(dashboard,0,12,"Signal")
    table.cell(dashboard,1,12,signal)

//====================================================
// ALERTS
//====================================================

alertcondition(
     buySignal,
     "BUY SIGNAL",
     "Hy ZMD BUY SIGNAL")

alertcondition(
     sellSignal,
     "SELL SIGNAL",
     "Hy ZMD SELL SIGNAL")
````
