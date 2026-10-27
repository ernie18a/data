#  SEDAT XI Crypto AI BIAS ENGINE

- url: https://www.tradingview.com/script/nv7JGsSS-SEDAT-XI-Crypto-AI-BIAS-ENGINE/
- type: indicator
- pine_id: PUB;f906b9453fb241bc9bb3827b090fd7d4
- version: 1.0

## Description

SΞDAT XI Crypto AI Bias Engine 

This dashboard is built to help crypto traders quickly read market bias across major crypto names.

It scans:
BTC
ETH
SOL
ADA
XRP
SHIB
Current chart ticker

The dashboard shows:
• Bias direction
• Bull breakout pressure
• Bear breakdown pressure
• High volume confirmation
• Momentum score
• RSI reading
• Current chart ticker row

Bias meanings:
BULL B/O = Bullish breakout pressure with high volume
BEAR B/O = Bearish breakdown pressure with high volume
STRONG BULL = Strong bullish trend conditions
STRONG BEAR = Strong bearish trend conditions
BULL = Mild bullish bias
BEAR = Mild bearish bias
CHOP = No clean direction

How to use:
Use the dashboard as a market scanner, not as a standalone buy/sell system.
The strongest bullish setups are when bias is BULL B/O or STRONG BULL with HIGH volume and RSI above 55.
The strongest bearish setups are when bias is BEAR B/O or STRONG BEAR with HIGH volume and RSI below 45.
The current chart ticker row helps confirm whether the crypto you are watching is stronger or weaker than the main crypto list.

Suggested timeframe:
15m for active trading bias
5m for faster entries
1h or 4h for bigger trend confirmation

This tool is for educational and informational use only.
It is not financial advice.
Always confirm with your own risk management, support/resistance, trend structure, and market conditions.

## Source Code

````pine
//@version=6
indicator("⚡ SΞDAT XI Crypto AI BIAS ENGINE ⚡", shorttitle="SΞDAT CRYPTO", overlay=true, max_bars_back=500)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
scanTF   = input.timeframe("15", "Scan Timeframe")
volLen   = input.int(20, "Volume SMA Length")
volMult  = input.float(1.5, "High Volume Multiplier")
breakLen = input.int(20, "Breakout Lookback")

dashPosInput = input.string("Bottom Right", "Dashboard Position",
     options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"])

dashSizeInput = input.string("Small", "Dashboard Size",
     options=["Tiny", "Small", "Normal", "Large"])

btcSym  = input.symbol("BINANCE:BTCUSDT", "BTC")
ethSym  = input.symbol("BINANCE:ETHUSDT", "ETH")
solSym  = input.symbol("BINANCE:SOLUSDT", "SOL")
adaSym  = input.symbol("BINANCE:ADAUSDT", "ADA")
xrpSym  = input.symbol("BINANCE:XRPUSDT", "XRP")
shibSym = input.symbol("BINANCE:SHIBUSDT", "SHIB")

//━━━━━━━━━━━━━━━━━━━
// POSITION / SIZE
//━━━━━━━━━━━━━━━━━━━
dashPos = dashPosInput == "Top Right" ? position.top_right :
     dashPosInput == "Middle Right" ? position.middle_right :
     dashPosInput == "Bottom Right" ? position.bottom_right :
     dashPosInput == "Top Left" ? position.top_left :
     dashPosInput == "Middle Left" ? position.middle_left :
     position.bottom_left

txtSize = dashSizeInput == "Tiny" ? size.tiny :
     dashSizeInput == "Small" ? size.small :
     dashSizeInput == "Normal" ? size.normal :
     size.large

//━━━━━━━━━━━━━━━━━━━
// CALCULATION
//━━━━━━━━━━━━━━━━━━━
f_calc() =>
    ema9  = ta.ema(close, 9)
    ema21 = ta.ema(close, 21)
    ema50 = ta.ema(close, 50)
    rsi14 = ta.rsi(close, 14)
    volAvg = ta.sma(volume, volLen)
    highVol = volume > volAvg * volMult
    hi = ta.highest(high, breakLen)
    lo = ta.lowest(low, breakLen)

    bullTrend = ema9 > ema21 and ema21 > ema50
    bearTrend = ema9 < ema21 and ema21 < ema50
    bullBreak = close > hi[1] and highVol
    bearBreak = close < lo[1] and highVol

    score = 0
    score += bullTrend ? 2 : bearTrend ? -2 : 0
    score += close > ema50 ? 1 : -1
    score += rsi14 > 55 ? 1 : rsi14 < 45 ? -1 : 0
    score += bullBreak ? 2 : bearBreak ? -2 : 0
    score += highVol ? 1 : 0

    biasNum = bullBreak ? 3 :
         bearBreak ? -3 :
         score >= 4 ? 2 :
         score <= -4 ? -2 :
         score > 0 ? 1 :
         score < 0 ? -1 :
         0

    [biasNum, highVol, score, rsi14]

f_data(sym) =>
    request.security(sym, scanTF, f_calc())

//━━━━━━━━━━━━━━━━━━━
// DATA
//━━━━━━━━━━━━━━━━━━━
[btcBias, btcHV, btcScore, btcRsi] = f_data(btcSym)
[ethBias, ethHV, ethScore, ethRsi] = f_data(ethSym)
[solBias, solHV, solScore, solRsi] = f_data(solSym)
[adaBias, adaHV, adaScore, adaRsi] = f_data(adaSym)
[xrpBias, xrpHV, xrpScore, xrpRsi] = f_data(xrpSym)
[shibBias, shibHV, shibScore, shibRsi] = f_data(shibSym)

// Current chart ticker data
[chartBias, chartHV, chartScore, chartRsi] = request.security(syminfo.tickerid, scanTF, f_calc())

chartName = syminfo.ticker

//━━━━━━━━━━━━━━━━━━━
// COLORS / TEXT
//━━━━━━━━━━━━━━━━━━━
f_biasTxt(b) =>
    b == 3 ? "⚡ BULL B/O" :
     b == -3 ? "🔥 BEAR B/O" :
     b == 2 ? "🟢 STRONG BULL" :
     b == -2 ? "🔴 STRONG BEAR" :
     b == 1 ? "BULL" :
     b == -1 ? "BEAR" :
     "CHOP"

f_bg(b) =>
    b == 3 ? color.new(color.yellow, 0) :
     b == -3 ? color.new(color.red, 0) :
     b == 2 ? color.new(color.lime, 0) :
     b == -2 ? color.new(color.red, 5) :
     b == 1 ? color.new(color.green, 20) :
     b == -1 ? color.new(color.maroon, 10) :
     color.new(color.gray, 40)

f_txt(b) =>
    b == 3 ? color.black : color.white

f_scoreBg(score) =>
    score >= 5 ? color.new(color.lime, 10) :
     score <= -5 ? color.new(color.red, 10) :
     score > 0 ? color.new(color.green, 35) :
     score < 0 ? color.new(color.maroon, 25) :
     color.new(color.gray, 40)

//━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━
var table dash = table.new(dashPos, 5, 8, border_width=2)

f_row(row, ticker, b, hv, score, rsiVal, isChartRow) =>
    tickerBg = isChartRow ? color.new(color.aqua, 15) : color.new(color.black, 0)
    tickerTc = isChartRow ? color.black : color.white
    table.cell(dash, 0, row, ticker, text_color=tickerTc, bgcolor=tickerBg, text_size=txtSize)
    table.cell(dash, 1, row, f_biasTxt(b), text_color=f_txt(b), bgcolor=f_bg(b), text_size=txtSize)
    table.cell(dash, 2, row, hv ? "HIGH" : "NORMAL", text_color=color.white, bgcolor=hv ? color.new(color.orange, 0) : color.new(color.gray, 45), text_size=txtSize)
    table.cell(dash, 3, row, str.tostring(score), text_color=color.white, bgcolor=f_scoreBg(score), text_size=txtSize)
    table.cell(dash, 4, row, str.tostring(math.round(rsiVal)), text_color=color.white, bgcolor=rsiVal > 55 ? color.new(color.green, 25) : rsiVal < 45 ? color.new(color.red, 25) : color.new(color.gray, 45), text_size=txtSize)

if barstate.islast
    table.cell(dash, 0, 0, "⚡ SΞDAT XI ⚡", text_color=color.aqua, bgcolor=color.new(color.black, 0), text_size=txtSize)
    table.cell(dash, 1, 0, "BIAS", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
    table.cell(dash, 2, 0, "VOL", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
    table.cell(dash, 3, 0, "SCORE", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
    table.cell(dash, 4, 0, "RSI", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)

    f_row(1, "BTC", btcBias, btcHV, btcScore, btcRsi, false)
    f_row(2, "ETH", ethBias, ethHV, ethScore, ethRsi, false)
    f_row(3, "SOL", solBias, solHV, solScore, solRsi, false)
    f_row(4, "ADA", adaBias, adaHV, adaScore, adaRsi, false)
    f_row(5, "XRP", xrpBias, xrpHV, xrpScore, xrpRsi, false)
    f_row(6, "SHIB", shibBias, shibHV, shibScore, shibRsi, false)

    // Bottom row = actual current chart ticker
    f_row(7, "📍 " + chartName, chartBias, chartHV, chartScore, chartRsi, true)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(chartBias == 3, "Current Chart Bull Breakout", "Current chart crypto has BULL BREAKOUT pressure.")
alertcondition(chartBias == -3, "Current Chart Bear Breakdown", "Current chart crypto has BEAR BREAKDOWN pressure.")
````
