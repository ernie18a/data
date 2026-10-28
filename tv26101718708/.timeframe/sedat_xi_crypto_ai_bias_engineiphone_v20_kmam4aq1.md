# SEDAT XI Crypto AI BIAS ENGINE-iphone v2.0 

- url: https://www.tradingview.com/script/kMAm4aq1-SEDAT-XI-Crypto-AI-BIAS-ENGINE-iphone-v2-0/
- type: indicator
- pine_id: PUB;a1ea2fc5a22e454a97fe854ff2fe7e61
- version: 1.0

## Description

** ⚡SEDAT XI Crypto AI BIAS ENGINE⚡

The **SEDAT XI Crypto AI BIAS ENGINE** is a multi-asset cryptocurrency dashboard designed to help traders quickly identify where momentum, trend, and participation are aligning across the market.

Rather than focusing on a single chart, the dashboard continuously scans major cryptocurrencies and summarizes the information into an easy-to-read institutional-style interface. It combines trend analysis, breakout detection, momentum, volume activity, and RSI into one compact view, making it easier to prioritize the strongest opportunities.

### Features

• Multi-asset crypto scanner (BTC, ETH, SOL, ADA, XRP, SHIB)
• AI-style bias engine with Bullish, Bearish, Strong Trend, and Breakout detection
• Institutional volume activity meter
• Momentum score with color-coded strength
• RSI momentum confirmation
• Live current price display
• Final trade bias summary
• Mobile-friendly dashboard mode
• Adjustable dashboard size and screen placement

The goal is simple: reduce chart clutter and provide a fast market overview so traders can spend less time searching and more time focusing on high-quality setups.

This indicator is designed for educational and informational purposes. It does not predict future price movements or guarantee profitable trades. Always combine its signals with sound risk management and your own market analysis.

Thank you for checking out **SΞDAT XI Crypto AI BIAS ENGINE**. I hope it becomes a valuable part of your trading workflow. Feedback and constructive suggestions are always welcome as the project continues to evolve.

## Source Code

````pine
//@version=6
indicator("⚡ SΞDAT XI Crypto AI BIAS ENGINE-iphone v2.0 ⚡", shorttitle="SΞDAT CRYPTO", overlay=true, max_bars_back=500)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
scanTF   = input.timeframe("15", "Scan Timeframe")
volLen   = input.int(20, "Volume SMA Length", minval=1)
volMult  = input.float(1.5, "High Volume Multiplier", step=0.1)
breakLen = input.int(20, "Breakout Lookback", minval=5)

screenMode = input.string("iPhone 17 / Mobile", "Screen Mode",
     options=["iPhone 17 / Mobile", "Compact", "Desktop", "Large Desktop"])

dashPosInput = input.string("Bottom Right", "Dashboard Position",
     options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"])

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

isMobile = screenMode == "iPhone 17 / Mobile"

txtSize = screenMode == "iPhone 17 / Mobile" ? size.tiny :
     screenMode == "Compact" ? size.tiny :
     screenMode == "Desktop" ? size.small :
     size.normal

//━━━━━━━━━━━━━━━━━━━
// BLOOMBERG / NEON COLORS
//━━━━━━━━━━━━━━━━━━━
bbBlack    = color.rgb(6, 8, 12)
bbPanel    = color.rgb(15, 20, 28)
bbPanel2   = color.rgb(24, 31, 42)
bbSlate    = color.rgb(38, 48, 62)
bbHeader   = color.rgb(0, 82, 165)

bbWhite    = color.rgb(240, 240, 240)
bbGreen    = color.rgb(0, 195, 105)
bbRed      = color.rgb(215, 45, 55)
bbMaroon   = color.rgb(120, 25, 35)
bbOrange   = color.rgb(255, 145, 0)
bbAqua     = color.rgb(0, 215, 255)
bbPurple   = color.rgb(130, 55, 220)
bbFuchsia  = color.rgb(220, 55, 220)

//━━━━━━━━━━━━━━━━━━━
// CALCULATION
//━━━━━━━━━━━━━━━━━━━
f_calc() =>
    ema9  = ta.ema(close, 9)
    ema21 = ta.ema(close, 21)
    ema50 = ta.ema(close, 50)
    rsi14 = ta.rsi(close, 14)

    volAvg = ta.sma(volume, volLen)
    volRatio = volAvg > 0 ? volume / volAvg : 0.0

    activeVol = volRatio >= 1.25
    extremeVol = volRatio >= 1.75

    hi = ta.highest(high, breakLen)
    lo = ta.lowest(low, breakLen)

    bullTrend = ema9 > ema21 and ema21 > ema50
    bearTrend = ema9 < ema21 and ema21 < ema50

    bullBreak = close > hi[1] and activeVol
    bearBreak = close < lo[1] and activeVol

    score = 0
    score += bullTrend ? 2 : bearTrend ? -2 : 0
    score += close > ema50 ? 1 : -1
    score += rsi14 > 55 ? 1 : rsi14 < 45 ? -1 : 0
    score += bullBreak ? 2 : bearBreak ? -2 : 0
    score += activeVol ? 1 : 0
    score += extremeVol and bullTrend ? 1 : extremeVol and bearTrend ? -1 : 0

    biasNum = bullBreak ? 3 :
         bearBreak ? -3 :
         score >= 4 ? 2 :
         score <= -4 ? -2 :
         score > 0 ? 1 :
         score < 0 ? -1 :
         0

    [biasNum, score, rsi14, close, volRatio]

f_data(sym) =>
    request.security(sym, scanTF, f_calc(), ignore_invalid_symbol=true)

//━━━━━━━━━━━━━━━━━━━
// DATA
//━━━━━━━━━━━━━━━━━━━
[btcBias, btcScore, btcRsi, btcPrice, btcVolRatio] = f_data(btcSym)
[ethBias, ethScore, ethRsi, ethPrice, ethVolRatio] = f_data(ethSym)
[solBias, solScore, solRsi, solPrice, solVolRatio] = f_data(solSym)
[adaBias, adaScore, adaRsi, adaPrice, adaVolRatio] = f_data(adaSym)
[xrpBias, xrpScore, xrpRsi, xrpPrice, xrpVolRatio] = f_data(xrpSym)
[shibBias, shibScore, shibRsi, shibPrice, shibVolRatio] = f_data(shibSym)

[chartBias, chartScore, chartRsi, chartPrice, chartVolRatio] =
     request.security(syminfo.tickerid, scanTF, f_calc(), ignore_invalid_symbol=true)

chartName = syminfo.ticker

//━━━━━━━━━━━━━━━━━━━
// TEXT / COLORS
//━━━━━━━━━━━━━━━━━━━
f_biasTxt(b) =>
    isMobile ?
         b == 3 ? "B↑" :
         b == -3 ? "B↓" :
         b == 2 ? "S↑" :
         b == -2 ? "S↓" :
         b == 1 ? "↑" :
         b == -1 ? "↓" :
         "C" :
         b == 3 ? "⚡ BULL B/O" :
         b == -3 ? "🔥 BEAR B/O" :
         b == 2 ? "🟢 STRONG BULL" :
         b == -2 ? "🔴 STRONG BEAR" :
         b == 1 ? "BULL" :
         b == -1 ? "BEAR" :
         "CHOP"

// Stronger neon BIAS colors
f_bg(b) =>
    b == 3  ? color.rgb(255, 255, 0) :
     b == -3 ? color.rgb(255, 0, 60) :
     b == 2  ? color.rgb(0, 255, 120) :
     b == -2 ? color.rgb(255, 40, 120) :
     b == 1  ? color.rgb(90, 255, 90) :
     b == -1 ? color.rgb(255, 120, 120) :
     color.rgb(95, 105, 120)

// Black letters on BIAS column for visibility
f_txt(b) =>
    color.black

f_scoreBg(score) =>
    score >= 5 ? color.new(bbGreen, 5) :
     score <= -5 ? color.new(bbRed, 5) :
     score > 0 ? color.new(bbGreen, 35) :
     score < 0 ? color.new(bbMaroon, 10) :
     bbPanel2

f_priceTxt(p) =>
    isMobile ?
         p >= 1000 ? str.tostring(p, "#") :
         p >= 1 ? str.tostring(p, "#.##") :
         str.tostring(p, "#.######") :
         p >= 1000 ? str.tostring(p, "#,###.00") :
         p >= 1 ? str.tostring(p, "#.00") :
         str.tostring(p, "#.########")

f_volTxt(vr) =>
    isMobile ?
         str.tostring(vr, "#.0") + "x" :
         vr >= 2.0 ? "INST " + str.tostring(vr, "#.00") + "x" :
         vr >= 1.75 ? "EXT " + str.tostring(vr, "#.00") + "x" :
         vr >= 1.25 ? "BUILD " + str.tostring(vr, "#.00") + "x" :
         vr >= 0.80 ? "NORMAL " + str.tostring(vr, "#.00") + "x" :
         "LOW " + str.tostring(vr, "#.00") + "x"

f_volBg(vr) =>
    vr >= 2.0 ? bbPurple :
     vr >= 1.75 ? bbFuchsia :
     vr >= 1.25 ? bbOrange :
     vr >= 0.80 ? bbSlate :
     bbPanel

f_finalTxt(b, score, rsiVal, vr) =>
    isMobile ?
         b == 3 and score >= 4 and rsiVal > 55 and vr >= 1.25 ? "A+↑" :
         b == -3 and score <= -4 and rsiVal < 45 and vr >= 1.25 ? "A+↓" :
         score >= 4 and rsiVal > 55 ? "L" :
         score <= -4 and rsiVal < 45 ? "S" :
         "W" :
         b == 3 and score >= 4 and rsiVal > 55 and vr >= 1.25 ? "A+ LONG" :
         b == -3 and score <= -4 and rsiVal < 45 and vr >= 1.25 ? "A+ SHORT" :
         score >= 4 and rsiVal > 55 ? "LONG WATCH" :
         score <= -4 and rsiVal < 45 ? "SHORT WATCH" :
         "WAIT"

f_finalBg(txt) =>
    str.contains(txt, "A+↑") or str.contains(txt, "A+ LONG") ? bbGreen :
     str.contains(txt, "A+↓") or str.contains(txt, "A+ SHORT") ? bbRed :
     txt == "L" or str.contains(txt, "LONG") ? color.new(bbGreen, 25) :
     txt == "S" or str.contains(txt, "SHORT") ? bbMaroon :
     bbPanel2

f_rsiBg(rsiVal) =>
    rsiVal > 55 ? color.new(bbGreen, 30) :
     rsiVal < 45 ? color.new(bbRed, 25) :
     bbSlate

f_rowBg(row) =>
    row % 2 == 0 ? bbPanel : bbBlack

//━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━
var table dash = table.new(dashPos, 7, 8, bgcolor=bbBlack, border_width=1, border_color=bbSlate)

f_row(row, ticker, b, score, rsiVal, priceVal, volRatio, isChartRow) =>
    baseBg   = f_rowBg(row)
    tickerBg = isChartRow ? color.new(bbAqua, 15) : bbHeader
    tickerTc = isChartRow ? color.black : bbWhite
    finalTxt = f_finalTxt(b, score, rsiVal, volRatio)

    table.cell(dash, 0, row, ticker, text_color=tickerTc, bgcolor=tickerBg, text_size=txtSize)
    table.cell(dash, 1, row, f_priceTxt(priceVal), text_color=bbAqua, bgcolor=baseBg, text_size=txtSize)
    table.cell(dash, 2, row, f_biasTxt(b), text_color=f_txt(b), bgcolor=f_bg(b), text_size=txtSize)
    table.cell(dash, 3, row, f_volTxt(volRatio), text_color=bbWhite, bgcolor=f_volBg(volRatio), text_size=txtSize)
    table.cell(dash, 4, row, str.tostring(score), text_color=bbWhite, bgcolor=f_scoreBg(score), text_size=txtSize)
    table.cell(dash, 5, row, str.tostring(math.round(rsiVal)), text_color=bbWhite, bgcolor=f_rsiBg(rsiVal), text_size=txtSize)
    table.cell(dash, 6, row, finalTxt, text_color=bbWhite, bgcolor=f_finalBg(finalTxt), text_size=txtSize)

if barstate.islast
    table.set_position(dash, dashPos)

    titleTxt = isMobile ? "SΞDAT" : "⚡ SΞDAT XI ⚡"

    table.cell(dash, 0, 0, titleTxt, text_color=bbAqua, bgcolor=bbBlack, text_size=txtSize)
    table.cell(dash, 1, 0, isMobile ? "$" : "PRICE", text_color=bbAqua, bgcolor=bbBlack, text_size=txtSize)
    table.cell(dash, 2, 0, isMobile ? "B" : "BIAS", text_color=bbWhite, bgcolor=bbBlack, text_size=txtSize)
    table.cell(dash, 3, 0, isMobile ? "V" : "VOL", text_color=bbWhite, bgcolor=bbBlack, text_size=txtSize)
    table.cell(dash, 4, 0, isMobile ? "SC" : "SCORE", text_color=bbWhite, bgcolor=bbBlack, text_size=txtSize)
    table.cell(dash, 5, 0, "RSI", text_color=bbWhite, bgcolor=bbBlack, text_size=txtSize)
    table.cell(dash, 6, 0, isMobile ? "F" : "FINAL", text_color=bbAqua, bgcolor=bbBlack, text_size=txtSize)

    f_row(1, "BTC", btcBias, btcScore, btcRsi, btcPrice, btcVolRatio, false)
    f_row(2, "ETH", ethBias, ethScore, ethRsi, ethPrice, ethVolRatio, false)
    f_row(3, "SOL", solBias, solScore, solRsi, solPrice, solVolRatio, false)
    f_row(4, "ADA", adaBias, adaScore, adaRsi, adaPrice, adaVolRatio, false)
    f_row(5, "XRP", xrpBias, xrpScore, xrpRsi, xrpPrice, xrpVolRatio, false)
    f_row(6, "SHIB", shibBias, shibScore, shibRsi, shibPrice, shibVolRatio, false)
    f_row(7, isMobile ? "📍" + chartName : "📍 " + chartName, chartBias, chartScore, chartRsi, chartPrice, chartVolRatio, true)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(chartBias == 3, "Current Chart Bull Breakout", "Current chart crypto has BULL BREAKOUT pressure.")
alertcondition(chartBias == -3, "Current Chart Bear Breakdown", "Current chart crypto has BEAR BREAKDOWN pressure.")
alertcondition(f_finalTxt(chartBias, chartScore, chartRsi, chartVolRatio) == "A+↑" or f_finalTxt(chartBias, chartScore, chartRsi, chartVolRatio) == "A+ LONG", "A+ Long Setup", "Current chart crypto has A+ LONG setup.")
alertcondition(f_finalTxt(chartBias, chartScore, chartRsi, chartVolRatio) == "A+↓" or f_finalTxt(chartBias, chartScore, chartRsi, chartVolRatio) == "A+ SHORT", "A+ Short Setup", "Current chart crypto has A+ SHORT setup.")
````
