# Panel S-500

- url: https://www.tradingview.com/script/FCHKdxoh-Panel-S-500/
- type: indicator
- pine_id: PUB;87c7d20f36e54486b3fb88dea553b581
- version: 1.0

## Description

s-500 is a multi-timeframe market dashboard designed to give a fast and clean view of the current market context.

the tool combines trend, rsi, macd, adx, volume, volatility, sessions, killzones, vwap, moving averages, momentum, compression, expansion and general market bias inside one compact panel.

the goal of s-500 is not to replace your strategy. it is built to help you read the market environment before taking a trade. it can be used as a confirmation tool, a market filter, or a quick decision dashboard.

main features

multi-timeframe trend reading
multi-timeframe rsi reading
multi-timeframe macd reading
multi-timeframe adx reading
volume analysis
obv direction
volume moving average status
volume trend
vsa activity
stochastic direction
vwap bias
ema 20, ema 26, ema 50 and ema 200 context
rsi slope
ema 20 slope
range to atr ratio
body ratio
atr slope
volume delta
compression and expansion reading
tokyo, london, new york and sydney session status
london and new york killzone status
market bias
suggested action
market regime
momentum strength
volatility status
trend strength
market phase
risk environment

how to use s-500

enable the panel from the settings.

start by looking at the bias line.

if bias shows bullish, the market context is mostly bullish.
if bias shows bearish, the market context is mostly bearish.
if bias shows neutral, the market does not have a clear directional structure.

then check the action line.

buy means the current conditions are more favorable for long setups.
sell means the current conditions are more favorable for short setups.
wait means the market is not clean enough and it may be better to wait.

after that, check the regime line.

trend up means the market is moving in an upward structure.
trend down means the market is moving in a downward structure.
range means the market is more sideways and less directional.
unclear means the structure is not strong enough to define a clean regime.

beginner tutorial

1. check the bias first

the bias gives the main direction of the market.

bullish bias means buyers are stronger.
bearish bias means sellers are stronger.
neutral bias means the market is mixed.

a beginner should avoid trading against the bias.

2. check the action

the action line gives a simple reading of the current context.

buy means you should mainly look for long opportunities.
sell means you should mainly look for short opportunities.
wait means conditions are not clean enough.

this does not mean you should enter immediately. it means the market context is more favorable in that direction.

3. check the trend mtf section

the trend mtf section shows if multiple timeframes are bullish or bearish.

when most timeframes are bullish, the market has stronger upward alignment.
when most timeframes are bearish, the market has stronger downward alignment.
when timeframes are mixed, the market may be unstable or ranging.

4. check rsi mtf

rsi above 50 usually supports bullish momentum.
rsi below 50 usually supports bearish momentum.

if rsi is growing across several timeframes, momentum is improving.
if rsi is falling across several timeframes, momentum is weakening.

5. check macd mtf

macd above 0 supports bullish pressure.
macd below 0 supports bearish pressure.

a growing macd means momentum is increasing.
a falling macd means momentum is decreasing.

6. check adx mtf

adx helps estimate trend strength.

a stronger adx can confirm that the market has directional force.
a weak adx can indicate a range or a low-quality trend.

7. check vwap

if price is above vwap, buyers have more control.
if price is below vwap, sellers have more control.

vwap is useful for intraday trading and quick market context.

8. check volatility

high volatility means the market is moving aggressively.
low volatility means the market is calmer.

high volatility can create opportunities, but it also increases risk.
low volatility can create slow or choppy price action.

9. check market phase

expansion means the market is moving with more range and energy.
compression means the market is becoming tighter and less volatile.
neutral means there is no strong expansion or compression signal.

10. check risk environment

favorable means the environment is cleaner for trading.
dangerous means conditions may be unstable or risky.
neutral means the market is not clearly favorable or dangerous.

example of bullish use

the panel shows:

bias bullish
action buy
regime trend up
momentum strong
price above vwap
ema 50 above ema 200
rsi above 50 on several timeframes
macd growing on several timeframes

in this case, the trader can focus only on long setups.

a beginner could wait for a pullback, a support retest, a bullish candle confirmation, or a clean continuation signal before entering.

example of bearish use

the panel shows:

bias bearish
action sell
regime trend down
momentum strong
price below vwap
ema 50 below ema 200
rsi below 50 on several timeframes
macd falling on several timeframes

in this case, the trader can focus only on short setups.

a beginner could wait for a rejection from resistance, a bearish retest, a breakdown, or a continuation signal before entering.

example of range use

the panel shows:

bias neutral
action wait
regime range
momentum weak
volatility low
mixed trend mtf
weak adx

in this case, the market does not have a clean direction.

a beginner should be careful, reduce risk, or wait for a clearer breakout with stronger volume and momentum.

example of session use

if london or new york is active, the market may have more movement.
if a killzone is active, volatility can increase.
if all sessions are quiet, the market may be slower.

sessions should not be used alone. they are best used with trend, volume, volatility and structure.

settings

enable panel

turns the dashboard on or off.

position

selects where the panel appears on the chart.

aggressive mode

enables a more aggressive context reading. this can be useful for faster traders, but it may also react earlier and with more sensitivity.

ema fast

sets the fast ema used for trend calculations.

ema slow

sets the slow ema used for trend calculations.

rsi length

sets the rsi period.

adx length

sets the adx period.

best practices

use s-500 as a market filter before entering a trade.

avoid buying when the panel shows a strong bearish context.

avoid selling when the panel shows a strong bullish context.

look for alignment between bias, action, trend, rsi, macd, vwap, volume and volatility.

do not enter only because one line is bullish or bearish. stronger setups usually appear when several elements confirm the same direction.

s-500 can be useful for:

scalping
intraday trading
trend confirmation
multi-timeframe analysis
filtering weak signals
avoiding bad market conditions
reading momentum
reading volatility
session awareness
market preparation before entry

important note

s-500 does not guarantee profit.

it should be used with proper risk management, position sizing, stop loss placement and personal analysis.

no indicator can predict the market with certainty. the best use of this tool is to combine it with structure, support and resistance, volume, trend, volatility and disciplined risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator('S-500', shorttitle='S-500', overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=2000)

grp = "⭐⭐⭐⭐⭐ S-500 PANEL ⭐⭐⭐⭐⭐"

enablePanel = input.bool(true, "Enable Panel", group=grp)
posInp = input.string("Top Right","Position",
     options=["Top Left","Top Right"],
     group=grp)
aggressiveMode = input.bool(false, "Aggressive Mode", group=grp)
emaFastLen = input.int(50,"EMA Fast",group=grp)
emaSlowLen = input.int(200,"EMA Slow",group=grp)
rsiLen     = input.int(14,"RSI Length",group=grp)
adxLen     = input.int(14,"ADX Length",group=grp)

posPanel = position.top_right
if posInp == "Top Left"
    posPanel := position.top_left
else if posInp == "Top Right"
    posPanel := position.top_right

string[] tfsTrend  = array.from("15","30","60","240","D")
string[] tfsTrendN = array.from("15m","30m","1H","4H","1D")

string[] tfsMTF  = array.from("15","30","60","240","D")
string[] tfsMTFN = array.from("15m","30m","1H","4H","1D")

f_col(_state)=>
    color c = color.rgb(255,140,0)
    if _state == "Bull"
        c := color.rgb(18,185,88)
    else if _state == "Bear"
        c := color.rgb(214,64,64)
    c

f_col_dir(_dir)=>
    color c = color.rgb(255,140,0)
    if _dir == "Grow"
        c := color.rgb(18,185,88)
    else if _dir == "Fall"
        c := color.rgb(214,64,64)
    c

f_rowBg(_row) =>
    color bg = color.new(color.rgb(28,28,28), 0)
    if _row % 2 == 0
        bg := color.new(color.rgb(34,34,34), 0)
    bg

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
trendCore = emaFast > emaSlow

rsiCore = ta.rsi(close, rsiLen)
[macdLine, _, _] = ta.macd(close,12,26,9)

volMA = ta.sma(volume,20)
atr   = ta.atr(14)

rangeHL    = high - low
rangeHL_MA = ta.sma(rangeHL, 20)
stochK = ta.stoch(close, high, low, 14)

ema20  = ta.ema(close,20)
ema26  = ta.ema(close,26)
ema50  = ta.ema(close,50)
ema200 = ta.ema(close,200)

rsiSlope = rsiCore - rsiCore[1]

ema20Slope = ema20 - ema20[1]

rangeATR = atr > 0 ? (high - low) / atr : 0.0

bodySize  = math.abs(close - open)
bodyRatioCore = (high - low) > 0 ? bodySize / (high - low) : 0.0

atrSlope = atr - atr[1]

volDelta   = close > open ? volume : close < open ? -volume : 0
volDeltaMA = ta.sma(volDelta, 5)

atr_ma_local = ta.sma(atr, 50)
compressionRatio = atr_ma_local > 0 ? atr / atr_ma_local : 1.0

f_adx(_len)=>
    up = high - high[1]
    dn = low[1] - low
    pDM = (up > dn and up > 0) ? up : 0
    mDM = (dn > up and dn > 0) ? dn : 0
    tr  = ta.rma(ta.tr(true), _len)
    pDI = 100 * ta.rma(pDM, _len) / math.max(tr, 1e-6)
    mDI = 100 * ta.rma(mDM, _len) / math.max(tr, 1e-6)
    dx  = 100 * math.abs(pDI - mDI) / math.max(pDI + mDI, 1e-6)
    ta.rma(dx, _len)

adxCore = f_adx(adxLen)

var float obv = 0.0
if not na(close[1])
    if close > close[1]
        obv += volume
    else if close < close[1]
        obv -= volume

var table panel = na
if enablePanel and na(panel)
    panel := table.new(
        posPanel, 2, 70,
        bgcolor=color.new(color.rgb(28,28,28),0),
        frame_color=color.new(color.gray,40),
        frame_width=1
    )

if enablePanel and not na(panel)
    table.clear(panel,0,0,1,69)

    table.cell(panel,0,0,"TREND MTF",text_color=color.white,text_size=size.tiny,bgcolor=color.new(color.gray,75))
    table.cell(panel,1,0,"",bgcolor=color.new(color.gray,75))

    for i=0 to array.size(tfsTrend)-1
        tf  = array.get(tfsTrend,i)
        tfN = array.get(tfsTrendN,i)

        tVal = request.security(syminfo.tickerid, tf, trendCore)
        row = i + 1
        bg  = row % 2 == 0 ? color.new(color.rgb(34,34,34),0) : color.new(color.rgb(28,28,28),0)

        table.cell(panel,0,row,tfN,bgcolor=bg,text_color=color.white,text_size=size.tiny)
        table.cell(panel,1,row,tVal?"Bullish":"Bearish",bgcolor=bg,text_color=f_col(tVal?"Bull":"Bear"),text_size=size.tiny)

    base = 8
    table.cell(panel,0,base,"RSI MTF",text_color=color.white,text_size=size.tiny,bgcolor=color.new(color.gray,75))
    table.cell(panel,1,base,"",bgcolor=color.new(color.gray,75))

    for i=0 to array.size(tfsMTF)-1
        tf  = array.get(tfsMTF,i)
        tfN = array.get(tfsMTFN,i)

        [rN, rP] = request.security(syminfo.tickerid, tf, [rsiCore, rsiCore[1]])
        dir = rN > rP ? "Grow" : rN < rP ? "Fall" : "Flat"

        row = base + i + 1
        bg  = row % 2 == 0 ? color.new(color.rgb(34,34,34),0) : color.new(color.rgb(28,28,28),0)

        txt = (rN>50?"RSI>50":"RSI<50")+" / "+dir+" ("+str.tostring(rN,"#.0")+")"
        table.cell(panel,0,row,tfN,bgcolor=bg,text_color=color.white,text_size=size.tiny)
        table.cell(panel,1,row,txt,bgcolor=bg,text_color=f_col_dir(dir),text_size=size.tiny)

    base := 14
    table.cell(panel,0,base,"MACD MTF",text_color=color.white,text_size=size.tiny,bgcolor=color.new(color.gray,75))
    table.cell(panel,1,base,"",bgcolor=color.new(color.gray,75))

    for i=0 to array.size(tfsMTF)-1
        tf  = array.get(tfsMTF,i)
        tfN = array.get(tfsMTFN,i)

        [mN, mP] = request.security(syminfo.tickerid, tf, [macdLine, macdLine[1]])
        dir = mN > mP ? "Grow" : mN < mP ? "Fall" : "Flat"

        row = base + i + 1
        bg  = row % 2 == 0 ? color.new(color.rgb(34,34,34),0) : color.new(color.rgb(28,28,28),0)

        txt = (mN>0?"MACD>0":"MACD<0")+" / "+dir
        table.cell(panel,0,row,tfN,bgcolor=bg,text_color=color.white,text_size=size.tiny)
        table.cell(panel,1,row,txt,bgcolor=bg,text_color=f_col_dir(dir),text_size=size.tiny)

    base := 20
    table.cell(panel,0,base,"ADX MTF",text_color=color.white,text_size=size.tiny,bgcolor=color.new(color.gray,75))
    table.cell(panel,1,base,"",bgcolor=color.new(color.gray,75))

    for i=0 to array.size(tfsMTF)-1
        tf  = array.get(tfsMTF,i)
        tfN = array.get(tfsMTFN,i)

        [aN, aP] = request.security(syminfo.tickerid, tf, [adxCore, adxCore[1]])
        state = aN > 25 ? "Bull" : aN < 20 ? "Bear" : "Neutral"

        row = base + i + 1
        bg  = row % 2 == 0 ? color.new(color.rgb(34,34,34),0) : color.new(color.rgb(28,28,28),0)

        txt = (aN>25?"ADX>25":"ADX<25")+" / "+(aN>aP?"Grow":aN<aP?"Fall":"Flat")+" ("+str.tostring(aN,"#.0")+")"
        table.cell(panel,0,row,tfN,bgcolor=bg,text_color=color.white,text_size=size.tiny)
        table.cell(panel,1,row,txt,bgcolor=bg,text_color=f_col(state),text_size=size.tiny)

    base := 28
    table.cell(panel,0,base,"INFO TF",text_color=color.white,text_size=size.tiny,bgcolor=color.new(color.gray,75))
    table.cell(panel,1,base,"",bgcolor=color.new(color.gray,75))

    row = base + 1

    bgInfo = f_rowBg(row)
    table.cell(panel,0,row,"OBV",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,obv>obv[1]?"Grow":"Fall",text_color=f_col(obv>obv[1]?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"Vol MA",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,volume>volMA?"Above":"Below",text_color=f_col(volume>volMA?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"Vol Trd",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,volMA>volMA[1]?"Bull":"Bear",text_color=f_col(volMA>volMA[1]?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    vsa = volume > volMA and rangeHL > rangeHL_MA
    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"VSA",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,vsa?"Active":"Quiet",text_color=f_col(vsa?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    k = stochK
    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"Stochastic",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,k>50?"Bull":"Bear",text_color=f_col(k>50?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    vwapVal = ta.vwap
    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"VWAP",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,close>vwapVal?"Bull":"Bear",text_color=f_col(close>vwapVal?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"EMA 200/50",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,ema50>ema200?"Bull":"Bear",text_color=f_col(ema50>ema200?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"EMA 26/50",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,ema26>ema50?"Bull":"Bear",text_color=f_col(ema26>ema50?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"EMA 20",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,close>ema20?"Bull":"Bear",text_color=f_col(close>ema20?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"RSI Slope",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,rsiSlope>0?"Up":"Down",text_color=f_col(rsiSlope>0?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"EMA20 Slope",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,ema20Slope>0?"Up":"Down",text_color=f_col(ema20Slope>0?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"Range / ATR",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,str.tostring(rangeATR,"#.00"),text_color=f_col(rangeATR>1.1?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"Body Ratio",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,str.tostring(bodyRatioCore,"#.00"),text_color=f_col(bodyRatioCore>0.6?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"ATR Slope",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,atrSlope>0?"Up":"Down",text_color=f_col(atrSlope>0?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"Vol Delta",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,volDeltaMA>0?"Buy":"Sell",text_color=f_col(volDeltaMA>0?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    bgInfo := f_rowBg(row)
    table.cell(panel,0,row,"Compression",text_color=color.white,text_size=size.tiny, bgcolor=bgInfo)
    table.cell(panel,1,row,compressionRatio>1?"Expand":"Compress",text_color=f_col(compressionRatio>1?"Bull":"Bear"),text_size=size.tiny, bgcolor=bgInfo)
    row += 1

    int r = 40

    int hUTC   = hour(time, "UTC")
    int dowUTC = dayofweek(time, "UTC")

    bool isWeekdayUTC = dowUTC >= dayofweek.monday and dowUTC <= dayofweek.friday

    bool inTokyo  = isWeekdayUTC and (hUTC >= 0  and hUTC < 9)
    bool inLondon = isWeekdayUTC and (hUTC >= 7  and hUTC < 16)
    bool inNY     = isWeekdayUTC and (hUTC >= 12 and hUTC < 21)
    bool inSydney = isWeekdayUTC and (hUTC >= 21 or  hUTC < 6)

    bool inLondonKZ = isWeekdayUTC and (hUTC >= 7  and hUTC < 10)
    bool inNYKZ     = isWeekdayUTC and (hUTC >= 12 and hUTC < 15)
    bool kzActive   = inLondonKZ or inNYKZ

    table.cell(panel, 0, r, "SESSION", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 70))
    table.cell(panel, 1, r, "", bgcolor=color.new(color.gray, 70))
    r += 1

    string sess = "CLOSED"
    if isWeekdayUTC
        sess := ""
        if inTokyo
            sess += "Tokyo "
        if inLondon
            sess += "London "
        if inNY
            sess += "NY "
        if inSydney
            sess += "Sydney"

    bgSess = f_rowBg(r)
    table.cell(panel, 0, r, "Session", text_color=color.white, text_size=size.tiny, bgcolor=bgSess)
    table.cell(panel, 1, r, sess, text_color=isWeekdayUTC ? color.rgb(248,95,253) : color.gray, text_size=size.tiny, bgcolor=bgSess)
    r += 1

    bgSess := f_rowBg(r)
    table.cell(panel,0,r,"Tokyo",text_color=color.white,text_size=size.tiny, bgcolor=bgSess)
    table.cell(panel,1,r,inTokyo?"Active":"Inactive",text_color=inTokyo?color.lime:color.gray,text_size=size.tiny, bgcolor=bgSess)
    r += 1

    bgSess := f_rowBg(r)
    table.cell(panel,0,r,"London",text_color=color.white,text_size=size.tiny, bgcolor=bgSess)
    table.cell(panel,1,r,inLondon?"Active":"Inactive",text_color=inLondon?color.lime:color.gray,text_size=size.tiny, bgcolor=bgSess)
    r += 1

    bgSess := f_rowBg(r)
    table.cell(panel,0,r,"NY",text_color=color.white,text_size=size.tiny, bgcolor=bgSess)
    table.cell(panel,1,r,inNY?"Active":"Inactive",text_color=inNY?color.lime:color.gray,text_size=size.tiny, bgcolor=bgSess)
    r += 1

    bgSess := f_rowBg(r)
    table.cell(panel,0,r,"Sydney",text_color=color.white,text_size=size.tiny, bgcolor=bgSess)
    table.cell(panel,1,r,inSydney?"Active":"Inactive",text_color=inSydney?color.lime:color.gray,text_size=size.tiny, bgcolor=bgSess)
    r += 1

    bgSess := f_rowBg(r)
    table.cell(panel,0,r,"Killzone",text_color=color.white,text_size=size.tiny, bgcolor=bgSess)
    table.cell(panel,1,r,kzActive?"Active":"Inactive",text_color=kzActive?color.orange:color.gray,text_size=size.tiny, bgcolor=bgSess)
    r += 1

    bgSess := f_rowBg(r)
    table.cell(panel,0,r,"Tokyo Range",text_color=color.white,text_size=size.tiny, bgcolor=bgSess)
    table.cell(panel,1,r,inTokyo?"Active":"Inactive",text_color=inTokyo?color.lime:color.gray,text_size=size.tiny, bgcolor=bgSess)
    r += 1

    int rc = r

    table.cell(panel, 0, rc, "MARKET CONTEXT", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 70))
    table.cell(panel, 1, rc, "", bgcolor=color.new(color.gray, 70))
    rc += 1

    bool biasBull = close > ema50 and ema50 > ema200 and close > ta.vwap
    bool biasBear = close < ema50 and ema50 < ema200 and close < ta.vwap

    string bias = "Neutral"
    biasCol = color.gray
    if biasBull
        bias := "Bullish"
        biasCol := color.lime
    else if biasBear
        bias := "Bearish"
        biasCol := color.red

    bgCtx = f_rowBg(rc)
    table.cell(panel, 0, rc, "Bias", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, bias, text_color=biasCol, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1

    string action = "Wait"
    color actionCol = color.gray

    if biasBull
        action := "Buy"
        actionCol := color.lime
    else if biasBear
        action := "Sell"
        actionCol := color.red
    else if aggressiveMode
        if (ta.rsi(close,14) > 55 or ta.rsi(close,14) < 45) and biasBull
            action := "Buy (Agg)"
            actionCol := color.orange
        else if (ta.rsi(close,14) > 55 or ta.rsi(close,14) < 45) and biasBear
            action := "Sell (Agg)"
            actionCol := color.orange

    bgCtx := f_rowBg(rc)
    table.cell(panel, 0, rc, "Action", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, action, text_color=actionCol, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1

    bool trendUp   = ema50 > ema200
    bool trendDown = ema50 < ema200
    bool ranging   = math.abs(ema50 - ema200) < atr * 0.2

    string regime = "Unclear"
    color regimeCol = color.gray
    if ranging
        regime := "Range"
        regimeCol := color.orange
    else if trendUp
        regime := "Trend Up"
        regimeCol := color.lime
    else if trendDown
        regime := "Trend Down"
        regimeCol := color.red

    bgCtx := f_rowBg(rc)
    table.cell(panel, 0, rc, "Regime", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, regime, text_color=regimeCol, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1

    bool momentumStrong = ta.rsi(close,14) > 55 or ta.rsi(close,14) < 45
    string momentum = "Weak"
    color momCol = color.gray
    if momentumStrong
        momentum := "Strong"
        momCol := color.lime

    bgCtx := f_rowBg(rc)
    table.cell(panel, 0, rc, "Momentum", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, momentum, text_color=momCol, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1

    bool highVol = atr > ta.sma(atr, 50)
    bgCtx := f_rowBg(rc)
    table.cell(panel, 0, rc, "Volatility", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, highVol ? "High" : "Low", text_color=highVol ? color.orange : color.gray, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1

    float emaDist = math.abs(ema50 - ema200)
    float atrRef  = atr
    string trendStrength = "Weak"
    color trendCol = color.gray
    if emaDist > atrRef * 1.5
        trendStrength := "Strong"
        trendCol := color.lime
    else if emaDist > atrRef * 0.7
        trendStrength := "Moderate"
        trendCol := color.orange

    bgCtx := f_rowBg(rc)
    table.cell(panel, 0, rc, "Trend Strength", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, trendStrength, text_color=trendCol, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1

    float atrMA = ta.sma(atr, 50)
    string marketPhase = "Neutral"
    color phaseCol = color.gray
    if atr > atrMA * 1.15
        marketPhase := "Expansion"
        phaseCol := color.lime
    else if atr < atrMA * 0.85
        marketPhase := "Compression"
        phaseCol := color.orange

    bgCtx := f_rowBg(rc)
    table.cell(panel, 0, rc, "Market Phase", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, marketPhase, text_color=phaseCol, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1

    string riskEnv = "Neutral"
    color riskCol = color.gray
    if atr > atrMA * 1.4 and ranging
        riskEnv := "Dangerous"
        riskCol := color.red
    else if atr < atrMA * 1.1 and not ranging
        riskEnv := "Favorable"
        riskCol := color.lime

    bgCtx := f_rowBg(rc)
    table.cell(panel, 0, rc, "Risk Env", text_color=color.white, text_size=size.tiny, bgcolor=bgCtx)
    table.cell(panel, 1, rc, riskEnv, text_color=riskCol, text_size=size.tiny, bgcolor=bgCtx)
    rc += 1
````
