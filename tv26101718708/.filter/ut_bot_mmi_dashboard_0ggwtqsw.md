# UT Bot MMI Dashboard

- url: https://www.tradingview.com/script/0GGWtQSW/
- type: indicator
- pine_id: PUB;035b8c6f4bdd4f61a6a8beeb74485625
- version: 1.0

## Description

UT Bot MMI Dashboard — 多周期多指标看板

在图表左下角以表格形式，直观展示当前品种在5个不同时间周期上的综合技术状态。

包含指标：

UT Bot 方向 — ATR跟踪止损线判断多空方向
EMA 趋势 — 短/中/长EMA排列及距离扩张收缩判断趋势强度
MACD 信号 — DEA方向判断多空动能
RSI 信号 — 超买超卖及转强转弱提示

UT Bot MMI Dashboard — Multi-Timeframe Multi-Indicator Dashboard

A clean table displayed at the bottom-left of your chart, summarizing technical conditions across 5 customizable timeframes for any trading pair.

Included Indicators：

UT Bot Direction — ATR Trailing Stop for trend confirmation
EMA Trend — Short/Medium/Long EMA alignment + expansion/contraction analysis
MACD Signal — DEA direction to gauge momentum
RSI Signal — Overbought/oversold and 50-level crossovers

## Source Code

````pine
//@version=6
indicator(title="UT Bot MMI Dashboard", overlay=true)

// ------------------------------------------------------------
// 一、参数设置
// ------------------------------------------------------------
// -------- 五个周期下拉菜单（显示名|timeframe，解析后使用） --------
i_tf1 = input.string(title="▶ 周期1", defval="15分钟", options=["5分钟","15分钟","30分钟","1小时","2小时","4小时","一日","一周"])
i_tf2 = input.string(title="▶ 周期2", defval="30分钟", options=["5分钟","15分钟","30分钟","1小时","2小时","4小时","一日","一周"])
i_tf3 = input.string(title="▶ 周期3", defval="1小时",  options=["5分钟","15分钟","30分钟","1小时","2小时","4小时","一日","一周"])
i_tf4 = input.string(title="▶ 周期4", defval="4小时",  options=["5分钟","15分钟","30分钟","1小时","2小时","4小时","一日","一周"])
i_tf5 = input.string(title="▶ 周期5", defval="一日",   options=["5分钟","15分钟","30分钟","1小时","2小时","4小时","一日","一周"])

// -------- 表格显示 --------
i_tableSize = input.string(title="▶ 表格字体大小", defval="小型",
     options=["微型", "小型", "中型", "大型"])

getTextSize() => i_tableSize == "微型" ? size.tiny : i_tableSize == "小型" ? size.small : i_tableSize == "中型" ? size.normal : size.large

// -------- Heikin Ashi --------
i_useHeikinAshi = input.bool(false, title="▶ 使用Heikin Ashi蜡烛图信号")

// -------- UT Bot 参数 --------
i_keyValue  = input.int(40, title="▶ ATR止损系数（灵敏度）")
i_atrPeriod = input.int(20, title="▶ ATR周期")

// -------- EMA 参数 --------
i_emaShort = input.int(21, title="▶ EMA 短周期")
i_emaMid   = input.int(55, title="▶ EMA 中周期")
i_emaLong  = input.int(89, title="▶ EMA 长周期")

// -------- MACD 参数 --------
i_macdFast   = input.int(12, title="▶ MACD 快速EMA周期")
i_macdSlow   = input.int(26, title="▶ MACD 慢速EMA周期")
i_macdSignal = input.int(9,  title="▶ MACD 信号线周期")

// -------- RSI 参数 --------
i_rsiPeriod = input.int(13, title="▶ RSI 周期")

// ------------------------------------------------------------
// 二、从下拉选项解析 timeframe 值（switch 版本）
// ------------------------------------------------------------
getTfVal(label) =>
    switch label
        "5分钟"  => "5"
        "15分钟" => "15"
        "30分钟" => "30"
        "1小时"  => "60"
        "2小时"  => "120"
        "4小时"  => "240"
        "一日"   => "D"
        "一周"   => "W"
        => "60"

// ------------------------------------------------------------
// 三、Heikin Ashi 收盘价计算（供跨周期调用）
// ------------------------------------------------------------
getHeikinAshiClose(tf) =>
    [reqOpen, reqHigh, reqLow, reqClose] = request.security(syminfo.tickerid, tf, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off)
    float haClose = na
    float haOpen  = na
    haClose := (reqOpen + reqHigh + reqLow + reqClose) / 4
    haOpen  := na(haOpen[1]) ? (reqOpen + reqClose) / 2 : (haOpen[1] + haClose[1]) / 2
    haClose

getHeikinAshiClosePrev(tf) =>
    [reqOpen, reqHigh, reqLow, reqClose] = request.security(syminfo.tickerid, tf, [open[1], high[1], low[1], close[1]], barmerge.gaps_off, barmerge.lookahead_off)
    float haClose = na
    float haOpen  = na
    haClose := (reqOpen + reqHigh + reqLow + reqClose) / 4
    haOpen  := na(haOpen[1]) ? (reqOpen + reqClose) / 2 : (haOpen[1] + haClose[1]) / 2
    haClose

// ------------------------------------------------------------
// 四、UT Bot 核心算法
// 返回值：[止损线数值, 方向(1多头/-1空头/0观望)]
// ------------------------------------------------------------
utBotCalc(src, keyValue, atrPeriod) =>
    atrValue    = ta.atr(atrPeriod)
    atrLossStep = keyValue * atrValue / 10
    var float trailStop = 0.0
    if src > nz(trailStop[1], 0) and src[1] > nz(trailStop[1], 0)
        trailStop := math.max(nz(trailStop[1]), src - atrLossStep)
    else if src < nz(trailStop[1], 0) and src[1] < nz(trailStop[1], 0)
        trailStop := math.min(nz(trailStop[1]), src + atrLossStep)
    else if src > nz(trailStop[1], 0)
        trailStop := src - atrLossStep
    else
        trailStop := src + atrLossStep
    dir = src > trailStop ? 1 : src < trailStop ? -1 : 0
    [trailStop, dir]

// ------------------------------------------------------------
// 五、MACD 信号解读函数
// 返回值：[信号文字, 信号颜色]
// ------------------------------------------------------------
getMacdSignalInfo(dea, deaPrev) =>
    float d = nz(dea, 0)
    float dPrev = nz(deaPrev, 0)
    bool isRising = d > dPrev
    if d > 0 and isRising
        ["多头上涨", color.green]
    else if d > 0 and not isRising
        ["多头回调", color.blue]
    else if d < 0 and not isRising
        ["空头下跌", color.red]
    else if d < 0 and isRising
        ["空头反弹", color.orange]
    else
        ["—", color.gray]

// ------------------------------------------------------------
// 六、EMA 趋势解读函数
// 多头趋势：短>中>长；空头趋势：短<中<长；其余→震荡盘整
// 扩张/收缩：看短EMA与长EMA的距离绝对值变化
// 返回值：[信号文字, 信号颜色]
// ------------------------------------------------------------
getEmaTrendInfo(emaS, emaM, emaL, emaSPrev, emaLPrev) =>
    float s = nz(emaS, 0)
    float m = nz(emaM, 0)
    float l = nz(emaL, 0)
    float sPrev = nz(emaSPrev, 0)
    float lPrev = nz(emaLPrev, 0)
    float dist = math.abs(s - l)
    float distPrev = math.abs(sPrev - lPrev)
    bool expanding = dist > distPrev
    if s > m and m > l
        if expanding
            ["多头扩张", color.green]
        else
            ["多头收缩", color.green]
    else if s < m and m < l
        if expanding
            ["空头扩张", color.red]
        else
            ["空头收缩", color.red]
    else
        ["震荡盘整", color.gray]

// ------------------------------------------------------------
// 七、RSI 信号解读函数
// 优先级：穿越50 > 超买超卖 > 强势弱势
// RSI>80超买 / RSI<20超卖 / 50~80强势 / 20~50弱势
// 返回值：[信号文字, 信号颜色]
// ------------------------------------------------------------
getRsiSignalInfo(rsi, rsiPrev) =>
    float r = nz(rsi, 50)
    float rPrev = nz(rsiPrev, 50)
    bool crossedAbove50 = r > 50 and rPrev <= 50
    bool crossedBelow50 = r < 50 and rPrev >= 50
    if crossedAbove50
        ["转强", #00E676]
    else if crossedBelow50
        ["转弱", #FF1744]
    else if r > 80
        ["超买", #FF5252]
    else if r < 20
        ["超卖", #69F0AE]
    else if r > 50
        ["强势", #00C853]
    else
        ["弱势", #FF6D00]

// ------------------------------------------------------------
// 八、跨周期数据请求
// ------------------------------------------------------------
getPrice(tf) =>
    i_useHeikinAshi ? getHeikinAshiClose(tf)
                     : request.security(syminfo.tickerid, tf, close, barmerge.gaps_off, barmerge.lookahead_off)

getPricePrev(tf) =>
    i_useHeikinAshi ? getHeikinAshiClosePrev(tf)
                     : request.security(syminfo.tickerid, tf, close[1], barmerge.gaps_off, barmerge.lookahead_off)

// ---------- 周期1 ----------
tf1 = getTfVal(i_tf1)
utBot1() => utBotCalc(getPrice(tf1), i_keyValue, i_atrPeriod)
macd1() =>
    [dif, dea, hist] = ta.macd(getPrice(tf1), i_macdFast, i_macdSlow, i_macdSignal)
    pricePrev = getPricePrev(tf1)
    [_difPrev, deaPrev, _histPrev] = ta.macd(pricePrev, i_macdFast, i_macdSlow, i_macdSignal)
    [dea, deaPrev]
ema1() =>
    price = getPrice(tf1)
    [ta.ema(price, i_emaShort), ta.ema(price, i_emaMid), ta.ema(price, i_emaLong)]
ema1Prev() =>
    pricePrev = getPricePrev(tf1)
    [ta.ema(pricePrev, i_emaShort), ta.ema(pricePrev, i_emaLong)]
rsi1() =>
    [ta.rsi(getPrice(tf1), i_rsiPeriod), ta.rsi(getPricePrev(tf1), i_rsiPeriod)]

[stopTf1, dirTf1] = request.security(syminfo.tickerid, tf1, utBot1())
[macdTf1Dea, macdTf1DeaPrev] = request.security(syminfo.tickerid, tf1, macd1())
[emaTf1S, emaTf1M, emaTf1L] = request.security(syminfo.tickerid, tf1, ema1())
[emaTf1SPrev, emaTf1LPrev] = request.security(syminfo.tickerid, tf1, ema1Prev())
[rsiTf1, rsiTf1Prev] = request.security(syminfo.tickerid, tf1, rsi1())

// ---------- 周期2 ----------
tf2 = getTfVal(i_tf2)
utBot2() => utBotCalc(getPrice(tf2), i_keyValue, i_atrPeriod)
macd2() =>
    [dif, dea, hist] = ta.macd(getPrice(tf2), i_macdFast, i_macdSlow, i_macdSignal)
    pricePrev = getPricePrev(tf2)
    [_difPrev, deaPrev, _histPrev] = ta.macd(pricePrev, i_macdFast, i_macdSlow, i_macdSignal)
    [dea, deaPrev]
ema2() =>
    price = getPrice(tf2)
    [ta.ema(price, i_emaShort), ta.ema(price, i_emaMid), ta.ema(price, i_emaLong)]
ema2Prev() =>
    pricePrev = getPricePrev(tf2)
    [ta.ema(pricePrev, i_emaShort), ta.ema(pricePrev, i_emaLong)]
rsi2() =>
    [ta.rsi(getPrice(tf2), i_rsiPeriod), ta.rsi(getPricePrev(tf2), i_rsiPeriod)]

[stopTf2, dirTf2] = request.security(syminfo.tickerid, tf2, utBot2())
[macdTf2Dea, macdTf2DeaPrev] = request.security(syminfo.tickerid, tf2, macd2())
[emaTf2S, emaTf2M, emaTf2L] = request.security(syminfo.tickerid, tf2, ema2())
[emaTf2SPrev, emaTf2LPrev] = request.security(syminfo.tickerid, tf2, ema2Prev())
[rsiTf2, rsiTf2Prev] = request.security(syminfo.tickerid, tf2, rsi2())

// ---------- 周期3 ----------
tf3 = getTfVal(i_tf3)
utBot3() => utBotCalc(getPrice(tf3), i_keyValue, i_atrPeriod)
macd3() =>
    [dif, dea, hist] = ta.macd(getPrice(tf3), i_macdFast, i_macdSlow, i_macdSignal)
    pricePrev = getPricePrev(tf3)
    [_difPrev, deaPrev, _histPrev] = ta.macd(pricePrev, i_macdFast, i_macdSlow, i_macdSignal)
    [dea, deaPrev]
ema3() =>
    price = getPrice(tf3)
    [ta.ema(price, i_emaShort), ta.ema(price, i_emaMid), ta.ema(price, i_emaLong)]
ema3Prev() =>
    pricePrev = getPricePrev(tf3)
    [ta.ema(pricePrev, i_emaShort), ta.ema(pricePrev, i_emaLong)]
rsi3() =>
    [ta.rsi(getPrice(tf3), i_rsiPeriod), ta.rsi(getPricePrev(tf3), i_rsiPeriod)]

[stopTf3, dirTf3] = request.security(syminfo.tickerid, tf3, utBot3())
[macdTf3Dea, macdTf3DeaPrev] = request.security(syminfo.tickerid, tf3, macd3())
[emaTf3S, emaTf3M, emaTf3L] = request.security(syminfo.tickerid, tf3, ema3())
[emaTf3SPrev, emaTf3LPrev] = request.security(syminfo.tickerid, tf3, ema3Prev())
[rsiTf3, rsiTf3Prev] = request.security(syminfo.tickerid, tf3, rsi3())

// ---------- 周期4 ----------
tf4 = getTfVal(i_tf4)
utBot4() => utBotCalc(getPrice(tf4), i_keyValue, i_atrPeriod)
macd4() =>
    [dif, dea, hist] = ta.macd(getPrice(tf4), i_macdFast, i_macdSlow, i_macdSignal)
    pricePrev = getPricePrev(tf4)
    [_difPrev, deaPrev, _histPrev] = ta.macd(pricePrev, i_macdFast, i_macdSlow, i_macdSignal)
    [dea, deaPrev]
ema4() =>
    price = getPrice(tf4)
    [ta.ema(price, i_emaShort), ta.ema(price, i_emaMid), ta.ema(price, i_emaLong)]
ema4Prev() =>
    pricePrev = getPricePrev(tf4)
    [ta.ema(pricePrev, i_emaShort), ta.ema(pricePrev, i_emaLong)]
rsi4() =>
    [ta.rsi(getPrice(tf4), i_rsiPeriod), ta.rsi(getPricePrev(tf4), i_rsiPeriod)]

[stopTf4, dirTf4] = request.security(syminfo.tickerid, tf4, utBot4())
[macdTf4Dea, macdTf4DeaPrev] = request.security(syminfo.tickerid, tf4, macd4())
[emaTf4S, emaTf4M, emaTf4L] = request.security(syminfo.tickerid, tf4, ema4())
[emaTf4SPrev, emaTf4LPrev] = request.security(syminfo.tickerid, tf4, ema4Prev())
[rsiTf4, rsiTf4Prev] = request.security(syminfo.tickerid, tf4, rsi4())

// ---------- 周期5 ----------
tf5 = getTfVal(i_tf5)
utBot5() => utBotCalc(getPrice(tf5), i_keyValue, i_atrPeriod)
macd5() =>
    [dif, dea, hist] = ta.macd(getPrice(tf5), i_macdFast, i_macdSlow, i_macdSignal)
    pricePrev = getPricePrev(tf5)
    [_difPrev, deaPrev, _histPrev] = ta.macd(pricePrev, i_macdFast, i_macdSlow, i_macdSignal)
    [dea, deaPrev]
ema5() =>
    price = getPrice(tf5)
    [ta.ema(price, i_emaShort), ta.ema(price, i_emaMid), ta.ema(price, i_emaLong)]
ema5Prev() =>
    pricePrev = getPricePrev(tf5)
    [ta.ema(pricePrev, i_emaShort), ta.ema(pricePrev, i_emaLong)]
rsi5() =>
    [ta.rsi(getPrice(tf5), i_rsiPeriod), ta.rsi(getPricePrev(tf5), i_rsiPeriod)]

[stopTf5, dirTf5] = request.security(syminfo.tickerid, tf5, utBot5())
[macdTf5Dea, macdTf5DeaPrev] = request.security(syminfo.tickerid, tf5, macd5())
[emaTf5S, emaTf5M, emaTf5L] = request.security(syminfo.tickerid, tf5, ema5())
[emaTf5SPrev, emaTf5LPrev] = request.security(syminfo.tickerid, tf5, ema5Prev())
[rsiTf5, rsiTf5Prev] = request.security(syminfo.tickerid, tf5, rsi5())

// ------------------------------------------------------------
// 九、表格绘制（固定在左下角，5列6行）
// ------------------------------------------------------------
var table dashTable = na

if barstate.islast
    dashTable := table.new(
         position=position.bottom_left,
         columns=5,
         rows=6,
         bgcolor=color.new(#1e1e1e, 0),
         border_color=color.new(#444444, 0),
         border_width=1)

    ts = getTextSize()

    // ---- 表头 ----
    table.cell(dashTable, 0, 0, "周期",   text_color=color.white, text_size=ts, bgcolor=color.new(#333333, 0))
    table.cell(dashTable, 1, 0, "UT区间", text_color=color.white, text_size=ts, bgcolor=color.new(#333333, 0))
    table.cell(dashTable, 2, 0, "EMA",    text_color=color.white, text_size=ts, bgcolor=color.new(#333333, 0))
    table.cell(dashTable, 3, 0, "MACD",   text_color=color.white, text_size=ts, bgcolor=color.new(#333333, 0))
    table.cell(dashTable, 4, 0, "RSI",    text_color=color.white, text_size=ts, bgcolor=color.new(#333333, 0))

    // ---- row=1: 周期1 ----
    table.cell(dashTable, 0, 1, i_tf1, text_color=color.white, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    if dirTf1 == 1
        table.cell(dashTable, 1, 1, "🟢 多头", text_color=color.green, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else if dirTf1 == -1
        table.cell(dashTable, 1, 1, "🔴 空头", text_color=color.red,   text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else
        table.cell(dashTable, 1, 1, "— 中立", text_color=color.gray,  text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [emaText1, emaColor1] = getEmaTrendInfo(emaTf1S, emaTf1M, emaTf1L, emaTf1SPrev, emaTf1LPrev)
    table.cell(dashTable, 2, 1, emaText1, text_color=emaColor1, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [macdText1, macdColor1] = getMacdSignalInfo(macdTf1Dea, macdTf1DeaPrev)
    table.cell(dashTable, 3, 1, macdText1, text_color=macdColor1, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [rsiText1, rsiColor1] = getRsiSignalInfo(rsiTf1, rsiTf1Prev)
    table.cell(dashTable, 4, 1, rsiText1, text_color=rsiColor1, text_size=ts, bgcolor=color.new(#1e1e1e, 0))

    // ---- row=2: 周期2 ----
    table.cell(dashTable, 0, 2, i_tf2, text_color=color.white, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    if dirTf2 == 1
        table.cell(dashTable, 1, 2, "🟢 多头", text_color=color.green, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else if dirTf2 == -1
        table.cell(dashTable, 1, 2, "🔴 空头", text_color=color.red,   text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else
        table.cell(dashTable, 1, 2, "— 中立", text_color=color.gray,  text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [emaText2, emaColor2] = getEmaTrendInfo(emaTf2S, emaTf2M, emaTf2L, emaTf2SPrev, emaTf2LPrev)
    table.cell(dashTable, 2, 2, emaText2, text_color=emaColor2, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [macdText2, macdColor2] = getMacdSignalInfo(macdTf2Dea, macdTf2DeaPrev)
    table.cell(dashTable, 3, 2, macdText2, text_color=macdColor2, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [rsiText2, rsiColor2] = getRsiSignalInfo(rsiTf2, rsiTf2Prev)
    table.cell(dashTable, 4, 2, rsiText2, text_color=rsiColor2, text_size=ts, bgcolor=color.new(#1e1e1e, 0))

    // ---- row=3: 周期3 ----
    table.cell(dashTable, 0, 3, i_tf3, text_color=color.white, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    if dirTf3 == 1
        table.cell(dashTable, 1, 3, "🟢 多头", text_color=color.green, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else if dirTf3 == -1
        table.cell(dashTable, 1, 3, "🔴 空头", text_color=color.red,   text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else
        table.cell(dashTable, 1, 3, "— 中立", text_color=color.gray,  text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [emaText3, emaColor3] = getEmaTrendInfo(emaTf3S, emaTf3M, emaTf3L, emaTf3SPrev, emaTf3LPrev)
    table.cell(dashTable, 2, 3, emaText3, text_color=emaColor3, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [macdText3, macdColor3] = getMacdSignalInfo(macdTf3Dea, macdTf3DeaPrev)
    table.cell(dashTable, 3, 3, macdText3, text_color=macdColor3, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [rsiText3, rsiColor3] = getRsiSignalInfo(rsiTf3, rsiTf3Prev)
    table.cell(dashTable, 4, 3, rsiText3, text_color=rsiColor3, text_size=ts, bgcolor=color.new(#1e1e1e, 0))

    // ---- row=4: 周期4 ----
    table.cell(dashTable, 0, 4, i_tf4, text_color=color.white, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    if dirTf4 == 1
        table.cell(dashTable, 1, 4, "🟢 多头", text_color=color.green, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else if dirTf4 == -1
        table.cell(dashTable, 1, 4, "🔴 空头", text_color=color.red,   text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else
        table.cell(dashTable, 1, 4, "— 中立", text_color=color.gray,  text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [emaText4, emaColor4] = getEmaTrendInfo(emaTf4S, emaTf4M, emaTf4L, emaTf4SPrev, emaTf4LPrev)
    table.cell(dashTable, 2, 4, emaText4, text_color=emaColor4, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [macdText4, macdColor4] = getMacdSignalInfo(macdTf4Dea, macdTf4DeaPrev)
    table.cell(dashTable, 3, 4, macdText4, text_color=macdColor4, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [rsiText4, rsiColor4] = getRsiSignalInfo(rsiTf4, rsiTf4Prev)
    table.cell(dashTable, 4, 4, rsiText4, text_color=rsiColor4, text_size=ts, bgcolor=color.new(#1e1e1e, 0))

    // ---- row=5: 周期5 ----
    table.cell(dashTable, 0, 5, i_tf5, text_color=color.white, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    if dirTf5 == 1
        table.cell(dashTable, 1, 5, "🟢 多头", text_color=color.green, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else if dirTf5 == -1
        table.cell(dashTable, 1, 5, "🔴 空头", text_color=color.red,   text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    else
        table.cell(dashTable, 1, 5, "— 中立", text_color=color.gray,  text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [emaText5, emaColor5] = getEmaTrendInfo(emaTf5S, emaTf5M, emaTf5L, emaTf5SPrev, emaTf5LPrev)
    table.cell(dashTable, 2, 5, emaText5, text_color=emaColor5, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [macdText5, macdColor5] = getMacdSignalInfo(macdTf5Dea, macdTf5DeaPrev)
    table.cell(dashTable, 3, 5, macdText5, text_color=macdColor5, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
    [rsiText5, rsiColor5] = getRsiSignalInfo(rsiTf5, rsiTf5Prev)
    table.cell(dashTable, 4, 5, rsiText5, text_color=rsiColor5, text_size=ts, bgcolor=color.new(#1e1e1e, 0))
````
