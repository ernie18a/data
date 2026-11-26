# SRC Calendar Scenes [includeno]

- url: https://www.tradingview.com/script/q9uA5xFg/
- type: indicator
- pine_id: PUB;5022f4cd26a14dc296fcc2a354d83f49
- version: 2.0

## Description

指标基于 Stochastic、ATR 波动带、回归通道、趋势热度，以及 Volume Sentiment Breakout 风格的趋势状态过滤，把价格所处环境归纳成更适合交易决策的场景标签，而不是单纯给出买卖点。

核心用途：
- 识别 Call Calendar 偏多回踩场景
- 识别 Put Calendar 偏空反弹场景
- 标记 ATM Calendar 中性钉住环境
- 标记强趋势下更适合 Vertical / Diagonal 的环境
- 提醒不要追高、不要抄底、不要过早反向做 calendar
- 给出基于 ATR 偏移的参考 strike 与短腿预期波动范围

主要场景：
C+：高质量偏多回踩 Call Calendar 场景
c+：弱确认偏多 Call Calendar 场景
P-：高质量偏空反弹 Put Calendar 场景
p-：弱确认偏空 Put Calendar 场景
ATM：中性钉住 ATM Calendar 场景
VC+：Bull Call Vertical 候选场景
VP-：Bear Put Vertical 候选场景
↗!：快速上涨，普通 Call Calendar 可能被价格冲过
↘!：快速下跌，普通 Put Calendar 可能被价格冲过
F↑：多头反转陷阱，不宜过早做反向 Put Calendar
F↓：空头反转陷阱，不宜过早做反向 Call Calendar
X↑：不要追高
X↓：不要抄底

使用建议：
- 1H 可作为 5-7 DTE calendar 的主要观察周期
- 4H / Daily 更适合判断大环境和趋势质量
- 2m / 5m 更适合观察执行温度，不建议把每一个短周期信号都当作独立入场
- Manual IV % 用于估算短腿 expected move，需要根据实际期权链 IV 手动调整
- 指标给出的 strike 是基于 ATR 与价格步长的参考值，不等同于真实期权链最优合约

注意：
本指标用于期权策略场景分析和交易计划辅助，不构成投资建议。实际交易前请结合 IV、流动性、财报/宏观事件、bid-ask spread、风险收益比和账户风险控制独立判断。

Attribution:
Derived from “Stochastic Overlay - Regression Channel (Zeiierman)”.
Volume Sentiment Breakout style trend-state idea inspired by AlgoAlpha’s VSB channel logic.
Calendar spread scene extension by includeno.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © includeno
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// Derived from "Stochastic Overlay - Regression Channel (Zeiierman)".
// Original concept and attribution: © Zeiierman.
// Calendar spread scene extension: adds option-calendar context, target strikes, and risk scenes.
//
// Scene legend / 场景图例:
// - C+  : Prime bullish pullback call-calendar scene.
//         高质量偏多回踩 Call Calendar 场景。
//         The base C+ setup is present, the suggested call strike is inside the
//         short-leg expected move, price is not stretched into/above the upper
//         band or upper regression channel, stochastic is not over-hot, and the
//         recent stochastic path shows a real pullback before turning up. This
//         is the highest-reference bullish calendar marker in this script.
//         基础 C+ 条件成立，建议 call strike 位于短腿预期波动范围内；
//         价格没有贴近/突破上方带或回归上轨，随机指标没有过热，并且最近
//         随机指标路径显示先有效回调、再重新转强。这是本脚本里参考价值
//         最高的偏多日历价差信号。
// - c+  : Weak/unconfirmed bullish pullback call-calendar scene.
//         弱确认/未确认的偏多回踩 Call Calendar 场景。
//         The base bullish pullback logic is present, but at least one prime
//         quality filter is missing. It is useful as a trend-state hint, but it
//         should usually be confirmed by a higher timeframe or a cleaner pullback
//         before opening a plain call calendar.
//         基础偏多回踩逻辑成立，但至少缺少一个高质量过滤条件。它更适合作为
//         趋势状态提示；开普通 call calendar 前，通常应等待更高周期确认或
//         更干净的回踩。
// - VC+ : Bull call vertical candidate.
//         看涨垂直价差候选点。
//         VSB confirms an active bullish trend, regression slope is positive,
//         bull heat is dominant, and price either breaks out, retests/reclaims
//         the upper band, or pulls back toward the basis/VSB trend guide and
//         turns up again. This is for strong-trend vertical spreads, not a
//         calendar entry.
//         VSB 确认多头 active，回归斜率向上，多头热度占优，并且价格出现突破、
//         回测后重新站上上方带，或回踩 basis/VSB 趋势线后重新转强。它用于强趋势
//         下的看涨垂直价差，不是日历价差入场。
// - VP- : Bear put vertical candidate.
//         看跌垂直价差候选点。
//         VSB confirms an active bearish trend, regression slope is negative,
//         bear heat is dominant, and price either breaks down, rejects the lower
//         band from below, or rebounds toward the basis/VSB trend guide and turns
//         down again. This is for strong-trend vertical spreads, not a calendar
//         entry.
//         VSB 确认空头 active，回归斜率向下，空头热度占优，并且价格出现跌破、
//         反弹到下方带后失败，或反弹到 basis/VSB 趋势线后重新转弱。它用于强趋势
//         下的看跌垂直价差，不是日历价差入场。
// - P-  : Prime bearish rebound put-calendar scene.
//         高质量偏空反弹 Put Calendar 场景。
//         The base P- setup is present, the suggested put strike is inside the
//         short-leg expected move, price is not stretched into/below the lower
//         band or lower regression channel, stochastic is not washed out, and the
//         recent stochastic path shows a real rebound before turning down.
//         基础 P- 条件成立，建议 put strike 位于短腿预期波动范围内；
//         价格没有贴近/跌破下方带或回归下轨，随机指标没有过度超卖，并且最近
//         随机指标路径显示先有效反弹、再重新转弱。
// - p-  : Weak/unconfirmed bearish rebound put-calendar scene.
//         弱确认/未确认的偏空反弹 Put Calendar 场景。
//         The base bearish rebound logic is present, but prime quality filters
//         are incomplete. Treat it as a warning/state marker, not a standalone
//         entry trigger.
//         基础偏空反弹逻辑成立，但高质量过滤条件不完整。把它当作状态/警告标记，
//         不要单独作为入场触发。
// - ATM : Neutral pin calendar scene.
//         中性钉住 ATM Calendar 场景。
//         Regression slope is flat, price is near the band basis, bull/bear heat
//         is balanced, and ATR is not expanding. This favors an ATM calendar only
//         when implied volatility and event risk are acceptable.
//         回归斜率走平，价格接近 basis，多空热度均衡，ATR 没有扩张。
//         只有在隐含波动率和事件风险也合适时，才偏向 ATM calendar。
// - ↗!  : Fast bullish trend.
//         快速上涨趋势。
//         Price is stretched upward with bullish heat and/or ATR expansion. A
//         plain call calendar can be overrun; consider waiting for a pullback or
//         using diagonal logic that gives the move more room.
//         价格向上拉伸，同时多头热度强和/或 ATR 扩张。普通 call calendar
//         可能很快被价格冲过；更适合等待回踩，或使用给趋势更多空间的 diagonal。
// - ↘!  : Fast bearish trend.
//         快速下跌趋势。
//         Price is stretched downward with bearish heat and/or ATR expansion. A
//         plain put calendar can be overrun; consider waiting for a rebound or
//         using diagonal logic.
//         价格向下拉伸，同时空头热度强和/或 ATR 扩张。普通 put calendar
//         可能很快被价格冲过；更适合等待反弹，或使用 diagonal 逻辑。
// - F↑  : Bull fade trap.
//         多头反转陷阱。
//         Price is near/above the upper band while bullish heat remains strong.
//         Do not rush into a contrarian put calendar until the breakout fails or
//         price retests the basis.
//         价格接近/突破上方带，但多头热度仍强。不要急着反向做 put calendar；
//         等突破失败或价格回测 basis 后再判断。
// - F↓  : Bear fade trap.
//         空头反转陷阱。
//         Price is near/below the lower band while bearish heat remains strong.
//         Do not rush into a contrarian call calendar until the breakdown fails
//         or price retests the basis.
//         价格接近/跌破下方带，但空头热度仍强。不要急着反向做 call calendar；
//         等跌破失败或价格回测 basis 后再判断。
// - X↑  : Do not chase high.
//         不要追高。
//         Price is extended near/above the upper band or upper regression channel,
//         stochastic is hot, bullish heat is dominant, and momentum has started
//         to cool or price shows upper rejection. Avoid opening a fresh plain
//         call calendar here unless price retests the basis.
//         价格接近/突破上方带或回归上轨，随机指标偏热，多头热度占优，并且动能已经
//         开始降温或价格出现上方拒绝。除非价格回测 basis，否则不适合新开普通
//         call calendar。
// - X↓  : Do not bottom fish.
//         不要抄底。
//         Price is extended near/below the lower band or lower regression channel,
//         stochastic is washed out, bearish heat is dominant, and downside
//         momentum has started to cool unevenly or price shows lower rejection.
//         Avoid opening a fresh contrarian call calendar until selling pressure
//         stabilizes near the basis.
//         价格接近/跌破下方带或回归下轨，随机指标过冷，空头热度占优，并且下行动能
//         出现不稳定降温或价格出现下方拒绝。卖压在 basis 附近稳定前，不适合逆势
//         新开 call calendar。
//
// Table shorthand / 表格缩写:
// - ◎   : Current scene code.
//         当前场景代码。
// - S/B : Short/long leg sketch. Example: S6/B30 @7422C means sell 6-DTE and
//         buy 30-DTE at the same call strike.
//         短腿/长腿草图。例如 S6/B30 @7422C 表示卖 6DTE、买 30DTE，
//         同一 call strike。
// - K   : Strike offset model, e.g. +0.55ATR, -0.55ATR, or 0ATR.
//         strike 偏移模型，例如 +0.55ATR、-0.55ATR 或 0ATR。
// - !   : Signal quality/risk. ★ = prime signal, ok = acceptable but not prime,
//         EM! = target is outside the short-leg expected move, IV? = check IV.
//         信号质量/风险。★ = 高质量信号；ok = 可接受但不是高质量；
//         EM! = 目标超出短腿预期波动范围；IV? = 需要检查隐含波动率。
// - β   : Regression slope in ATR units over the slope lookback.
//         回归斜率，用 ATR 单位表示。
// - B/R : Bull/bear heat ratio based on time above/below the band basis.
//         多/空热度比例，基于价格在 basis 上方/下方的时间占比。
// - %K/D: Stochastic K and D values.
//         随机指标 K/D 数值。
// - EM/X: Short-leg expected move and invalidation shorthand.
//         短腿预期波动范围和失效条件缩写。
//
// Practical timeframe use / 实用周期用法:
// - 1H is the main practical entry timeframe for 5-7 DTE calendars.
//   1H 是 5-7DTE 日历价差比较实用的主入场周期。
// - 4H/Daily should filter environment and trend quality.
//   4H/Daily 用来过滤大环境和趋势质量。
// - 2m/5m are execution-temperature views. Dense c+/C+ sequences usually mean
//   momentum is strong; the best plain-calendar entry is often the first prime
//   C+ after acceleration cools, not every repeated C+ during a push.
//   2m/5m 更像执行温度计。密集 c+/C+ 通常说明动量很强；普通 calendar
//   更好的入场往往是加速降温后的第一个高质量 C+，而不是上涨推进中的每一个 C+。
//
// Analysis Mode / 分析模式:
// - Both      : Shows call, put, neutral ATM, and both directional risk scenes.
//               显示 call、put、中性 ATM，以及两个方向的风险场景。
// - Call Only : Shows C+/c+, fast bullish trend ↗!, and bear fade trap F↓.
//               只显示 call 相关信号：C+/c+、VC+、快速上涨 ↗!、空头反转陷阱 F↓。
// - Put Only  : Shows P-/p-, VP-, fast bearish trend ↘!, and bull fade trap F↑.
//               只显示 put 相关信号：P-/p-、VP-、快速下跌 ↘!、多头反转陷阱 F↑。
// - X↑/X↓ warnings are price-location risk warnings and can appear in any mode.
//   X↑/X↓ 是价格位置风险提示，可在任意模式出现。
//
// Volume Sentiment Breakout integration / 成交量情绪突破整合:
// - This script reuses the core state idea from "Volume Sentiment Breakout
//   Channels [AlgoAlpha]": a volatility-normalized channel forms first; a break
//   above it creates an active bullish state, and a break below it creates an
//   active bearish state. The state remains active until price loses the dynamic
//   trend guide.
//   本脚本复用了 Volume Sentiment Breakout Channels [AlgoAlpha] 的核心状态思想：
//   先形成波动归一化通道；向上突破后进入 active bullish 状态，向下突破后进入
//   active bearish 状态；直到价格跌破/站回动态趋势线，该状态才失效。
// - When this filter is enabled, prime C+ prefers VSB bullish state, prime P-
//   prefers VSB bearish state, and X↑ is suppressed while VSB still confirms a
//   healthy bullish trend. This avoids marking every strong bullish breakout as
//   "do not chase" too early.
//   开启后，高质量 C+ 更偏向 VSB 多头状态，高质量 P- 更偏向 VSB 空头状态；
//   只要 VSB 仍确认健康多头，X↑ 会被抑制，避免把强势突破过早标成“不要追高”。

//@version=6
indicator("SRC Calendar Scenes [Z]", overlay=false, max_bars_back=500, max_lines_count=50, max_labels_count=200)

const string stochasticGroup = "Stochastic Settings"
const string bandGroup = "Stochastic Price Band"
const string regressionGroup = "Regression Channel"
const string calendarGroup = "Calendar Spread Scenes"
const string verticalGroup = "Vertical Spread Scenes"
const string vsbGroup = "Volume Sentiment Filter"
const string visualGroup = "Visuals"

stochLength = input.int(14, "Stochastic Length", minval=1, maxval=50, group=stochasticGroup)
smoothK = input.int(5, "%K Smoothing", minval=1, group=stochasticGroup)
periodD = input.int(3, "%D Smoothing", minval=1, group=stochasticGroup)

bandLength = input.int(21, "Band Length", minval=5, maxval=100, group=bandGroup)
atrMult = input.float(1.8, "Volatility Multiplier", minval=0.1, maxval=5.0, step=0.1, group=bandGroup)
bandType = input.string("EMA", "Band Type", options=["EMA", "SMA", "WMA", "HMA", "RMA"], group=bandGroup)

regressionType = input.string("Logarithmic", "Regression Type", options=["Logarithmic", "Linear", "Adaptive", "Leading"], group=regressionGroup)
regLength = input.int(100, "Regression Length", minval=25, maxval=500, group=regressionGroup)
regSlopeBars = input.int(10, "Slope Lookback Bars", minval=3, maxval=50, group=regressionGroup)
heatLength = input.int(50, "Heatmap Length", minval=10, maxval=500, group=regressionGroup)

shortDte = input.int(6, "Short Leg DTE", minval=1, maxval=45, group=calendarGroup)
longDte = input.int(30, "Long Leg DTE", minval=7, maxval=120, group=calendarGroup)
analysisMode = input.string("Both", "Analysis Mode", options=["Both", "Call Only", "Put Only"], group=calendarGroup)
targetAtr = input.float(0.55, "Directional Strike ATR Offset", minval=0.1, maxval=2.0, step=0.05, group=calendarGroup)
strikeStep = input.float(1.0, "Strike Rounding Step", minval=0.01, step=0.01, group=calendarGroup)
manualIvPct = input.float(30.0, "Manual IV % for Expected Move", minval=1.0, maxval=300.0, step=0.5, group=calendarGroup)
flatSlopeAtr = input.float(0.18, "Flat Trend Threshold, ATR", minval=0.02, maxval=1.0, step=0.02, group=calendarGroup)
nearBandAtr = input.float(0.35, "Near Band Threshold, ATR", minval=0.05, maxval=1.5, step=0.05, group=calendarGroup)
heatDominance = input.float(0.58, "Trend Dominance Ratio", minval=0.50, maxval=0.90, step=0.01, group=calendarGroup)
extremeHeat = input.float(0.72, "Fast Trend Ratio", minval=0.55, maxval=0.95, step=0.01, group=calendarGroup)
calendarConfirmBars = input.int(3, "Calendar Confirm Bars", minval=1, maxval=50, group=calendarGroup)
calendarConfirmAtr = input.float(0.25, "Calendar Confirm Move, ATR", minval=0.05, maxval=2.0, step=0.05, group=calendarGroup)
calendarConfirmNeedsBasis = input.bool(true, "Calendar Confirm Needs Basis", group=calendarGroup)

showBullVerticalSignals = input.bool(true, "Show Bull Call Vertical Signals", group=verticalGroup)
showBearVerticalSignals = input.bool(true, "Show Bear Put Vertical Signals", group=verticalGroup)
verticalDte = input.int(14, "Vertical DTE", minval=1, maxval=90, group=verticalGroup)
verticalLongAtr = input.float(0.10, "Long Strike ATR Offset", minval=-1.0, maxval=1.0, step=0.05, group=verticalGroup)
verticalWidthAtr = input.float(0.65, "Spread Width ATR", minval=0.1, maxval=3.0, step=0.05, group=verticalGroup)
verticalMaxStoch = input.float(92.0, "Max %K For VC+", minval=60.0, maxval=100.0, step=1.0, group=verticalGroup)
verticalMinTrendAtr = input.float(0.35, "Min Trend Slope, ATR", minval=0.05, maxval=2.0, step=0.05, group=verticalGroup)
verticalMinBars = input.int(8, "Min Bars Between VC+/VP-", minval=1, maxval=100, group=verticalGroup)

useVsbFilter = input.bool(true, "Use VSB Trend Filter", group=vsbGroup)
vsbNormLength = input.int(100, "Normalization Length", minval=10, maxval=500, group=vsbGroup)
vsbDetectLength = input.int(14, "Box Detection Length", minval=2, maxval=100, group=vsbGroup)
vsbStrongClose = input.bool(true, "Strong Closes Only", group=vsbGroup)
vsbFreshBars = input.int(48, "Fresh Breakout Bars", minval=1, maxval=300, group=vsbGroup)

showTable = input.bool(true, "Show Analysis Table", group=visualGroup)
showSignals = input.bool(true, "Show Scene Labels", group=visualGroup)
labelGap = input.int(12, "Min Bars Between Labels", minval=1, maxval=100, group=visualGroup)
showWeakSignals = input.bool(true, "Show Weak C+/P- As Gray", group=visualGroup)
showRiskWarnings = input.bool(true, "Show X↑/X↓ Risk Warnings", group=visualGroup)
showTargets = input.bool(true, "Show Target Strikes", group=visualGroup)
showBands = input.bool(true, "Show Price Bands", group=visualGroup)
showRegression = input.bool(true, "Show Regression Channel", group=visualGroup)
barColoring = input.bool(true, "Color Overlay Candles", group=visualGroup)

upCol = input.color(color.rgb(0, 213, 255), "Call Calendar Color", group=visualGroup)
dnCol = input.color(color.rgb(255, 0, 136), "Put Calendar Color", group=visualGroup)
vcCol = input.color(color.rgb(0, 255, 187), "Bull Vertical Color", group=visualGroup)
vpCol = input.color(color.rgb(255, 55, 55), "Bear Vertical Color", group=visualGroup)
neutralCol = input.color(color.rgb(170, 170, 170), "Neutral Color", group=visualGroup)
warningCol = input.color(color.rgb(255, 180, 0), "Warning Color", group=visualGroup)
weakCol = input.color(color.rgb(140, 140, 140), "Weak Signal Color", group=visualGroup)

callEnabled = analysisMode != "Put Only"
putEnabled = analysisMode != "Call Only"
bothEnabled = analysisMode == "Both"

ma(src, len, maType) =>
    switch maType
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        "HMA" => ta.hma(src, len)
        "RMA" => ta.rma(src, len)
        => ta.ema(src, len)

round_to_step(value, step) =>
    step <= 0 ? value : math.round(value / step) * step

fmt_price(value) =>
    str.tostring(value, format.mintick)

fmt_pct(value) =>
    str.tostring(value * 100.0, "#.0") + "%"

lowestLow = ta.lowest(low, stochLength)
highestHigh = ta.highest(high, stochLength)
stochRange = highestHigh - lowestLow
rawStoch = stochRange == 0 ? 50.0 : 100.0 * ((close - lowestLow) / stochRange)
stochK = ta.sma(rawStoch, smoothK)
stochD = ta.sma(stochK, periodD)

atrRaw = ta.atr(14)
atrBand = atrRaw * atrMult
basis = ma(close, bandLength, bandType)
dev = atrBand * (1 + (50 - math.abs(stochK - 50)) / 100)
upperBand = basis + dev
lowerBand = basis - dev
upperMa = ma(upperBand, 3, "EMA")
lowerMa = ma(lowerBand, 3, "EMA")

isUptrend = close > basis and close[1] > basis[1]
isDowntrend = close < basis and close[1] < basis[1]

regression(src, length) =>
    float sumX = 0.0
    float sumY = 0.0
    float sumXSqr = 0.0
    float sumXY = 0.0

    for i = 0 to length - 1
        val = src[i]
        per = i + 1.0
        sumX += per
        sumY += val
        sumXSqr += per * per
        sumXY += val * per

    slopeValue = (length * sumXY - sumX * sumY) / (length * sumXSqr - sumX * sumX)
    interceptValue = (sumY - slopeValue * sumX) / length
    [slopeValue, interceptValue]

safeBasis = math.max(basis, syminfo.mintick)
leadingLength = math.max(5, regLength - 20)

[slope, intercept] = switch regressionType
    "Logarithmic" => regression(math.log(safeBasis), regLength)
    "Linear" => regression(ta.ema(basis, 20), regLength)
    "Adaptive" =>
        [s, i] = regression(math.log(math.max(ta.hma(basis, 5), syminfo.mintick)), regLength)
        [ta.hma(s, 5), i]
    "Leading" =>
        [s, i] = regression(basis, leadingLength)
        [s * 1.5, i]

calcReg(x) =>
    useLog = regressionType == "Logarithmic" or regressionType == "Adaptive"
    useLog ? math.exp(intercept + slope * x) : intercept + slope * x

rStart = calcReg(regLength)
rEnd = calcReg(0)
rLookback = calcReg(regSlopeBars)
rDev = ta.stdev(basis, regLength)
upperStart = rStart + rDev
upperEnd = rEnd + rDev
lowerStart = rStart - rDev
lowerEnd = rEnd - rDev
regSlopeAtr = atrRaw == 0 ? 0.0 : (rEnd - rLookback) / atrRaw

regUp = regSlopeAtr > flatSlopeAtr
regDown = regSlopeAtr < -flatSlopeAtr
regFlat = math.abs(regSlopeAtr) <= flatSlopeAtr

vsbLowestLow = ta.lowest(low, vsbNormLength)
vsbHighestHigh = ta.highest(high, vsbNormLength)
vsbRange = vsbHighestHigh - vsbLowestLow
vsbNormalizedPrice = vsbRange == 0 ? 0.5 : (close - vsbLowestLow) / vsbRange
vsbVol = ta.stdev(vsbNormalizedPrice, 14)
vsbUpper = vsbVol
vsbLower = ta.wma(vsbVol, vsbDetectLength)
vsbDuration = math.max(nz(ta.barssince(ta.crossover(vsbLower, vsbUpper))), 1)
vsbChannelTopCandidate = ta.highest(high, vsbDuration)
vsbChannelBottomCandidate = ta.lowest(low, vsbDuration)
vsbNewChannel = ta.crossover(vsbUpper, vsbLower) and vsbDuration > 10
vsbPriceToCompare = vsbStrongClose ? math.avg(close, open) : close

var float vsbChannelTop = na
var float vsbChannelBottom = na
var bool vsbChannelActive = false

if vsbNewChannel
    vsbChannelTop := vsbChannelTopCandidate
    vsbChannelBottom := vsbChannelBottomCandidate
    vsbChannelActive := true

vsbBullBreak = vsbChannelActive and not na(vsbChannelTop) and vsbPriceToCompare > vsbChannelTop
vsbBearBreak = vsbChannelActive and not na(vsbChannelBottom) and vsbPriceToCompare < vsbChannelBottom

if vsbBullBreak or vsbBearBreak
    vsbChannelActive := false

vsbBullBars = math.max(nz(ta.barssince(vsbBullBreak)), 1)
vsbBearBars = math.max(nz(ta.barssince(vsbBearBreak)), 1)
vsbTrendUp = ta.sma(low, vsbBullBars)
vsbTrendDown = ta.sma(high, vsbBearBars)

var bool vsbActiveUp = false
var bool vsbActiveDown = false

if vsbBullBreak
    vsbActiveUp := true
    vsbActiveDown := false

if vsbBearBreak
    vsbActiveDown := true
    vsbActiveUp := false

if vsbActiveUp and ta.crossunder(close, vsbTrendUp)
    vsbActiveUp := false

if vsbActiveDown and ta.crossover(close, vsbTrendDown)
    vsbActiveDown := false

vsbBarsSinceBullBreak = ta.barssince(vsbBullBreak)
vsbBarsSinceBearBreak = ta.barssince(vsbBearBreak)
vsbRecentBullBreak = not na(vsbBarsSinceBullBreak) and vsbBarsSinceBullBreak <= vsbFreshBars
vsbRecentBearBreak = not na(vsbBarsSinceBearBreak) and vsbBarsSinceBearBreak <= vsbFreshBars
vsbBullContext = not useVsbFilter or vsbActiveUp or vsbRecentBullBreak
vsbBearContext = not useVsbFilter or vsbActiveDown or vsbRecentBearBreak
vsbBullHealthy = useVsbFilter and vsbActiveUp and close >= vsbTrendUp
vsbBearHealthy = useVsbFilter and vsbActiveDown and close <= vsbTrendDown

bullSum = ta.ema(math.sum(close > basis ? 1 : 0, heatLength), 5)
bearSum = ta.ema(math.sum(close < basis ? 1 : 0, heatLength), 5)
totalSum = bullSum + bearSum
totalSum := na(totalSum) or totalSum == 0 ? 1 : totalSum
bullRatio = na(bullSum) ? 0 : bullSum / totalSum
bearRatio = na(bearSum) ? 0 : bearSum / totalSum

nearLower = close <= lowerMa + atrRaw * nearBandAtr or low <= lowerMa
nearUpper = close >= upperMa - atrRaw * nearBandAtr or high >= upperMa
nearBasis = math.abs(close - basis) <= atrRaw * nearBandAtr
aboveReg = close > upperEnd
belowReg = close < lowerEnd
insideReg = close <= upperEnd and close >= lowerEnd

crossUp = ta.crossover(stochK, stochD)
crossDown = ta.crossunder(stochK, stochD)
stochRising = stochK > stochK[1]
stochFalling = stochK < stochK[1]

atrMean = ta.sma(atrRaw, 20)
atrExpanding = atrRaw > atrMean * 1.15
balancedHeat = math.abs(bullRatio - bearRatio) <= 0.12
extremeBull = bullRatio >= extremeHeat
extremeBear = bearRatio >= extremeHeat

fastBullTrend = (aboveReg or close > upperMa) and regUp and extremeBull and (atrExpanding or stochK > 80)
fastBearTrend = (belowReg or close < lowerMa) and regDown and extremeBear and (atrExpanding or stochK < 20)

bullPullbackCalendar = vsbBullContext and regUp and insideReg and (close >= lowerEnd) and (nearLower or close <= basis + atrRaw * nearBandAtr or stochK < 45) and (crossUp or (stochK > stochD and stochRising)) and bullRatio >= 0.50 and not fastBullTrend
bearReboundCalendar = vsbBearContext and regDown and insideReg and (close <= upperEnd) and (nearUpper or close >= basis - atrRaw * nearBandAtr or stochK > 55) and (crossDown or (stochK < stochD and stochFalling)) and bearRatio >= 0.50 and not fastBearTrend
neutralPinCalendar = regFlat and nearBasis and balancedHeat and not atrExpanding

bullFadeTrap = (nearUpper or aboveReg) and regUp and extremeBull and stochK > 70
bearFadeTrap = (nearLower or belowReg) and regDown and extremeBear and stochK < 30
upperReject = high > upperMa and close < upperMa
lowerReject = low < lowerMa and close > lowerMa
stochHotCooling = stochK > 78 and (stochFalling or crossDown)
stochColdCooling = stochK < 22 and (stochRising or crossUp)
upperStretch = aboveReg or close > upperMa + atrRaw * 0.25
lowerStretch = belowReg or close < lowerMa - atrRaw * 0.25
noChaseHighRaw = not vsbBullHealthy and upperStretch and bullRatio >= heatDominance and (stochHotCooling or upperReject) and not (stochRising and close > close[1] and close >= high - (high - low) * 0.25)
noBottomFishRaw = lowerStretch and bearRatio >= heatDominance and (stochColdCooling or lowerReject) and not (stochFalling and close < close[1] and close <= low + (high - low) * 0.25)
strongBullClose = close > open and close >= high - (high - low) * 0.35
strongBearClose = close < open and close <= low + (high - low) * 0.35
verticalTrendUp = regSlopeAtr >= verticalMinTrendAtr and vsbBullContext
verticalTrendDown = regSlopeAtr <= -verticalMinTrendAtr and vsbBearContext
vsbTrendRetest = vsbActiveUp and low <= vsbTrendUp + atrRaw * nearBandAtr and close > vsbTrendUp and strongBullClose
upperBandReclaim = ta.crossover(close, upperMa) and stochK > stochD and strongBullClose
basisReclaim = low <= basis + atrRaw * nearBandAtr and close > basis + atrRaw * nearBandAtr and stochK > stochD and stochRising and strongBullClose
momentumBreakout = vsbBullBreak and strongBullClose and stochK > stochD
vsbBearTrendRetest = vsbActiveDown and high >= vsbTrendDown - atrRaw * nearBandAtr and close < vsbTrendDown and strongBearClose
lowerBandReject = ta.crossunder(close, lowerMa) and stochK < stochD and strongBearClose
basisReject = high >= basis - atrRaw * nearBandAtr and close < basis - atrRaw * nearBandAtr and stochK < stochD and stochFalling and strongBearClose
momentumBreakdown = vsbBearBreak and strongBearClose and stochK < stochD
rawBullVerticalCandidate = showBullVerticalSignals and callEnabled and verticalTrendUp and bullRatio >= heatDominance and close > basis and stochK < verticalMaxStoch and not noChaseHighRaw and (momentumBreakout or upperBandReclaim or basisReclaim or vsbTrendRetest)
rawBearVerticalCandidate = showBearVerticalSignals and putEnabled and verticalTrendDown and bearRatio >= heatDominance and close < basis and stochK > 100.0 - verticalMaxStoch and not noBottomFishRaw and (momentumBreakdown or lowerBandReject or basisReject or vsbBearTrendRetest)

var int lastBullVerticalBar = na
var int lastBearVerticalBar = na
bullVerticalCandidate = rawBullVerticalCandidate and (na(lastBullVerticalBar) or bar_index - lastBullVerticalBar >= verticalMinBars)
bearVerticalCandidate = rawBearVerticalCandidate and (na(lastBearVerticalBar) or bar_index - lastBearVerticalBar >= verticalMinBars)

callTarget = round_to_step(close + targetAtr * atrRaw, strikeStep)
putTarget = round_to_step(close - targetAtr * atrRaw, strikeStep)
atmTarget = round_to_step(close, strikeStep)
verticalLongStrike = round_to_step(close + verticalLongAtr * atrRaw, strikeStep)
verticalShortStrike = math.max(round_to_step(verticalLongStrike + verticalWidthAtr * atrRaw, strikeStep), verticalLongStrike + strikeStep)
verticalPutLongStrike = round_to_step(close - verticalLongAtr * atrRaw, strikeStep)
verticalPutShortStrike = math.min(round_to_step(verticalPutLongStrike - verticalWidthAtr * atrRaw, strikeStep), verticalPutLongStrike - strikeStep)
manualIv = manualIvPct / 100.0
shortExpectedMove = close * manualIv * math.sqrt(shortDte / 365.0)
callDistance = math.abs(callTarget - close)
putDistance = math.abs(close - putTarget)
callWithinEm = callDistance <= shortExpectedMove
putWithinEm = putDistance <= shortExpectedMove

primeC = bullPullbackCalendar and vsbBullContext and callWithinEm and not nearUpper and not aboveReg and stochK < 65 and ta.lowest(stochK, 8) < 35
primeP = bearReboundCalendar and vsbBearContext and putWithinEm and not nearLower and not belowReg and stochK > 35 and ta.highest(stochK, 8) > 65
weakC = bullPullbackCalendar and not primeC
weakP = bearReboundCalendar and not primeP
showCallScene = callEnabled and bullPullbackCalendar
showPutScene = putEnabled and bearReboundCalendar
showAtmScene = bothEnabled and neutralPinCalendar
showFastBullScene = callEnabled and fastBullTrend
showFastBearScene = putEnabled and fastBearTrend
showBullFadeScene = putEnabled and bullFadeTrap
showBearFadeScene = callEnabled and bearFadeTrap
showNoChaseHighScene = showRiskWarnings and noChaseHighRaw
showNoBottomFishScene = showRiskWarnings and noBottomFishRaw
showBullVerticalScene = bullVerticalCandidate and not showCallScene
showBearVerticalScene = bearVerticalCandidate and not showPutScene

if showBullVerticalScene and barstate.isconfirmed
    lastBullVerticalBar := bar_index

if showBearVerticalScene and barstate.isconfirmed
    lastBearVerticalBar := bar_index

string scene = "WAIT"
string signalCode = "·"
string structure = "—"
string targetText = "—"
string riskText = "..."
string invalidationText = "wait"
string vsbStateText = useVsbFilter ? vsbActiveUp ? " V↑" : vsbActiveDown ? " V↓" : vsbChannelActive ? " V□" : " V·" : ""
int signalId = 0
color sceneColor = neutralCol

if showNoChaseHighScene
    scene := "X↑"
    signalCode := "X↑"
    structure := "no chase"
    targetText := "wait PB"
    riskText := "hot"
    invalidationText := "cool/basis"
    signalId := 8
    sceneColor := warningCol
else if showNoBottomFishScene
    scene := "X↓"
    signalCode := "X↓"
    structure := "no bottom"
    targetText := "wait cool"
    riskText := "fall"
    invalidationText := "base/basis"
    signalId := 9
    sceneColor := warningCol
else if showBullVerticalScene
    scene := "VC+"
    signalCode := "VC+"
    structure := "B/S" + str.tostring(verticalDte) + " @" + fmt_price(verticalLongStrike) + "/" + fmt_price(verticalShortStrike) + "C"
    targetText := "+" + str.tostring(verticalWidthAtr, "#.00") + "ATR"
    riskText := vsbActiveUp ? "V↑" : "V?"
    invalidationText := "< VSB"
    signalId := 10
    sceneColor := vcCol
else if showBearVerticalScene
    scene := "VP-"
    signalCode := "VP-"
    structure := "B/S" + str.tostring(verticalDte) + " @" + fmt_price(verticalPutLongStrike) + "/" + fmt_price(verticalPutShortStrike) + "P"
    targetText := "-" + str.tostring(verticalWidthAtr, "#.00") + "ATR"
    riskText := vsbActiveDown ? "V↓" : "V?"
    invalidationText := "> VSB"
    signalId := 11
    sceneColor := vpCol
else if showCallScene
    scene := "C+"
    signalCode := primeC ? "C+" : "c+"
    structure := "S" + str.tostring(shortDte) + "/B" + str.tostring(longDte) + " @" + fmt_price(callTarget) + "C"
    targetText := "+" + str.tostring(targetAtr, "#.00") + "ATR"
    riskText := primeC ? "★" : callWithinEm ? "ok" : "EM!"
    invalidationText := "< L-Reg"
    signalId := 1
    sceneColor := primeC ? upCol : weakCol
else if showPutScene
    scene := "P-"
    signalCode := primeP ? "P-" : "p-"
    structure := "S" + str.tostring(shortDte) + "/B" + str.tostring(longDte) + " @" + fmt_price(putTarget) + "P"
    targetText := "-" + str.tostring(targetAtr, "#.00") + "ATR"
    riskText := primeP ? "★" : putWithinEm ? "ok" : "EM!"
    invalidationText := "> U-Reg"
    signalId := 2
    sceneColor := primeP ? dnCol : weakCol
else if showAtmScene
    scene := "ATM"
    signalCode := "ATM"
    structure := "S" + str.tostring(shortDte) + "/B" + str.tostring(longDte) + " @" + fmt_price(atmTarget)
    targetText := "0ATR"
    riskText := "IV?"
    invalidationText := "β out"
    signalId := 3
    sceneColor := neutralCol
else if showFastBullScene
    scene := "↗!"
    signalCode := "↗!"
    structure := "diag/wait"
    targetText := "C overrun"
    riskText := "ATR↑"
    invalidationText := "wait PB"
    signalId := 4
    sceneColor := warningCol
else if showFastBearScene
    scene := "↘!"
    signalCode := "↘!"
    structure := "diag/wait"
    targetText := "P overrun"
    riskText := "ATR↑"
    invalidationText := "wait RB"
    signalId := 5
    sceneColor := warningCol
else if showBullFadeScene
    scene := "F↑"
    signalCode := "F↑"
    structure := "no P yet"
    targetText := "wait fail"
    riskText := "B↑"
    invalidationText := "basis"
    signalId := 6
    sceneColor := warningCol
else if showBearFadeScene
    scene := "F↓"
    signalCode := "F↓"
    structure := "no C yet"
    targetText := "wait fail"
    riskText := "B↓"
    invalidationText := "basis"
    signalId := 7
    sceneColor := warningCol

plot(stochK, "K", color=color.rgb(146, 175, 253), linewidth=2)
plot(stochD, "D", color=color.rgb(255, 157, 82), linewidth=2)
h0 = hline(80, "OB", color=color.new(dnCol, 20))
h50 = hline(50, "50", color=color.new(neutralCol, 50))
h1 = hline(20, "OS", color=color.new(upCol, 20))
fill(h0, h1, color=color.rgb(33, 150, 243, 92), title="BG")

baseline = plot(showBands ? basis : na, "B", color=color.new(neutralCol, 0), linewidth=1, force_overlay=true)
ub = plot(showBands ? upperMa : na, "U", color=color.new(dnCol, 0), linewidth=1, force_overlay=true)
lb = plot(showBands ? lowerMa : na, "L", color=color.new(upCol, 0), linewidth=1, force_overlay=true)
fill(ub, baseline, color=color.new(dnCol, 88))
fill(lb, baseline, color=color.new(upCol, 88))

plot(showTargets and callEnabled and bullPullbackCalendar ? callTarget : na, "C-K", color=color.new(upCol, 0), style=plot.style_circles, linewidth=2, force_overlay=true)
plot(showTargets and showBullVerticalScene ? verticalLongStrike : na, "VC-L", color=color.new(vcCol, 0), style=plot.style_cross, linewidth=2, force_overlay=true)
plot(showTargets and showBullVerticalScene ? verticalShortStrike : na, "VC-S", color=color.new(vcCol, 35), style=plot.style_cross, linewidth=2, force_overlay=true)
plot(showTargets and putEnabled and bearReboundCalendar ? putTarget : na, "P-K", color=color.new(dnCol, 0), style=plot.style_circles, linewidth=2, force_overlay=true)
plot(showTargets and showBearVerticalScene ? verticalPutLongStrike : na, "VP-L", color=color.new(vpCol, 0), style=plot.style_cross, linewidth=2, force_overlay=true)
plot(showTargets and showBearVerticalScene ? verticalPutShortStrike : na, "VP-S", color=color.new(vpCol, 35), style=plot.style_cross, linewidth=2, force_overlay=true)
plot(showTargets and bothEnabled and neutralPinCalendar ? atmTarget : na, "A-K", color=color.new(neutralCol, 0), style=plot.style_circles, linewidth=2, force_overlay=true)

plotcandle(barColoring ? open : na, barColoring ? high : na, barColoring ? low : na, barColoring ? close : na,
     color=barColoring ? (isUptrend ? upCol : isDowntrend ? dnCol : neutralCol) : na,
     wickcolor=barColoring ? (isUptrend ? upCol : isDowntrend ? dnCol : neutralCol) : na,
     bordercolor=barColoring ? (isUptrend ? upCol : isDowntrend ? dnCol : neutralCol) : na,
     title="TC", force_overlay=true)

b = bar_index
var line ml = na
var line ul = na
var line ll = na
var linefill regFill = na

if showRegression
    ml := na(ml) ? line.new(b - regLength, rStart, b, rEnd, color=color.new(neutralCol, 0), style=line.style_dashed, width=2, force_overlay=true) : ml
    ul := na(ul) ? line.new(b - regLength, upperStart, b, upperEnd, color=color.new(dnCol, 0), width=2, force_overlay=true) : ul
    ll := na(ll) ? line.new(b - regLength, lowerStart, b, lowerEnd, color=color.new(upCol, 0), width=2, force_overlay=true) : ll

    line.set_xy1(ml, b - regLength, rStart)
    line.set_xy2(ml, b, rEnd)
    line.set_xy1(ul, b - regLength, upperStart)
    line.set_xy2(ul, b, upperEnd)
    line.set_xy1(ll, b - regLength, lowerStart)
    line.set_xy2(ll, b, lowerEnd)

    if na(regFill)
        regFill := linefill.new(ul, ll, color.new(sceneColor, 92))
    else
        linefill.set_color(regFill, color.new(sceneColor, 92))

signalNow = showNoChaseHighScene or showNoBottomFishScene or showBullVerticalScene or showBearVerticalScene or (callEnabled and (primeC or (showWeakSignals and weakC) or fastBullTrend or bearFadeTrap)) or (putEnabled and (primeP or (showWeakSignals and weakP) or fastBearTrend or bullFadeTrap)) or (bothEnabled and neutralPinCalendar)
var int lastSignalBar = na
var array<label> pendingCallLabels = array.new<label>()
var array<int> pendingCallBars = array.new<int>()
var array<float> pendingCallPrices = array.new<float>()
var array<float> pendingCallAtr = array.new<float>()
var array<label> pendingPutLabels = array.new<label>()
var array<int> pendingPutBars = array.new<int>()
var array<float> pendingPutPrices = array.new<float>()
var array<float> pendingPutAtr = array.new<float>()
canPrintSignal = na(lastSignalBar) or bar_index - lastSignalBar >= labelGap or signalId != nz(signalId[1])
if showSignals and signalNow and canPrintSignal and barstate.isconfirmed
    labelStyle = showCallScene or showBullVerticalScene or showAtmScene or showBearFadeScene or showNoBottomFishScene ? label.style_label_up : label.style_label_down
    labelPrice = showCallScene or showBullVerticalScene or showAtmScene or showBearFadeScene or showNoBottomFishScene ? low : high
    newSignalLabel = label.new(bar_index, labelPrice, signalCode, color=color.new(sceneColor, 0), textcolor=color.white, style=labelStyle, size=size.normal, force_overlay=true)
    if signalCode == "C+"
        array.push(pendingCallLabels, newSignalLabel)
        array.push(pendingCallBars, bar_index)
        array.push(pendingCallPrices, close)
        array.push(pendingCallAtr, atrRaw)
    if signalCode == "P-"
        array.push(pendingPutLabels, newSignalLabel)
        array.push(pendingPutBars, bar_index)
        array.push(pendingPutPrices, close)
        array.push(pendingPutAtr, atrRaw)
    lastSignalBar := bar_index

if barstate.isconfirmed and array.size(pendingCallLabels) > 0
    idx = array.size(pendingCallLabels) - 1
    while idx >= 0
        signalBar = array.get(pendingCallBars, idx)
        signalPrice = array.get(pendingCallPrices, idx)
        signalAtr = array.get(pendingCallAtr, idx)
        callConfirmClose = close >= signalPrice + signalAtr * calendarConfirmAtr
        callBasisConfirmed = not calendarConfirmNeedsBasis or close >= basis
        confirmedCall = bar_index > signalBar and callConfirmClose and callBasisConfirmed
        expiredCall = bar_index - signalBar >= calendarConfirmBars
        if confirmedCall or expiredCall
            if not confirmedCall
                failedCallLabel = array.get(pendingCallLabels, idx)
                label.set_color(failedCallLabel, color.new(weakCol, 0))
                label.set_text(failedCallLabel, "c+")
            array.remove(pendingCallLabels, idx)
            array.remove(pendingCallBars, idx)
            array.remove(pendingCallPrices, idx)
            array.remove(pendingCallAtr, idx)
        idx -= 1

if barstate.isconfirmed and array.size(pendingPutLabels) > 0
    idx = array.size(pendingPutLabels) - 1
    while idx >= 0
        signalBar = array.get(pendingPutBars, idx)
        signalPrice = array.get(pendingPutPrices, idx)
        signalAtr = array.get(pendingPutAtr, idx)
        putConfirmClose = close <= signalPrice - signalAtr * calendarConfirmAtr
        putBasisConfirmed = not calendarConfirmNeedsBasis or close <= basis
        confirmedPut = bar_index > signalBar and putConfirmClose and putBasisConfirmed
        expiredPut = bar_index - signalBar >= calendarConfirmBars
        if confirmedPut or expiredPut
            if not confirmedPut
                failedPutLabel = array.get(pendingPutLabels, idx)
                label.set_color(failedPutLabel, color.new(weakCol, 0))
                label.set_text(failedPutLabel, "p-")
            array.remove(pendingPutLabels, idx)
            array.remove(pendingPutBars, idx)
            array.remove(pendingPutPrices, idx)
            array.remove(pendingPutAtr, idx)
        idx -= 1

var table analysisTable = table.new(position.top_right, 2, 8, border_width=1, force_overlay=true)

if showTable and barstate.islast
    headerBg = color.new(sceneColor, 0)
    bodyBg = color.new(color.black, 15)
    table.cell(analysisTable, 0, 0, "◎", bgcolor=headerBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 0, scene, bgcolor=headerBg, text_color=color.white, text_halign=text.align_left)
    table.cell(analysisTable, 0, 1, "S/B", bgcolor=bodyBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 1, structure, bgcolor=bodyBg, text_color=color.white, text_halign=text.align_left)
    table.cell(analysisTable, 0, 2, "K", bgcolor=bodyBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 2, targetText, bgcolor=bodyBg, text_color=color.white, text_halign=text.align_left)
    table.cell(analysisTable, 0, 3, "!", bgcolor=bodyBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 3, riskText, bgcolor=bodyBg, text_color=color.white, text_halign=text.align_left)
    table.cell(analysisTable, 0, 4, "β", bgcolor=bodyBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 4, str.tostring(regSlopeAtr, "#.00") + "A/" + str.tostring(regSlopeBars) + vsbStateText, bgcolor=bodyBg, text_color=color.white, text_halign=text.align_left)
    table.cell(analysisTable, 0, 5, "B/R", bgcolor=bodyBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 5, fmt_pct(bullRatio) + " / " + fmt_pct(bearRatio), bgcolor=bodyBg, text_color=color.white, text_halign=text.align_left)
    table.cell(analysisTable, 0, 6, "%K/D", bgcolor=bodyBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 6, str.tostring(stochK, "#.0") + " / " + str.tostring(stochD, "#.0"), bgcolor=bodyBg, text_color=color.white, text_halign=text.align_left)
    table.cell(analysisTable, 0, 7, "EM/X", bgcolor=bodyBg, text_color=color.white, text_halign=text.align_center)
    table.cell(analysisTable, 1, 7, "±" + fmt_price(shortExpectedMove) + " / " + invalidationText, bgcolor=bodyBg, text_color=color.white, text_halign=text.align_left)

alertcondition(callEnabled and bullPullbackCalendar, title="Bullish Pullback Call Calendar", message="Bullish pullback calendar scene: consider same-strike call calendar near Spot + ATR offset.")
alertcondition(showBullVerticalScene, title="Bull Call Vertical Candidate", message="VC+ scene: strong bullish VSB trend supports a bull call vertical spread candidate.")
alertcondition(putEnabled and bearReboundCalendar, title="Bearish Rebound Put Calendar", message="Bearish rebound calendar scene: consider same-strike put calendar near Spot - ATR offset.")
alertcondition(showBearVerticalScene, title="Bear Put Vertical Candidate", message="VP- scene: strong bearish VSB trend supports a bear put vertical spread candidate.")
alertcondition(bothEnabled and neutralPinCalendar, title="Neutral Pin ATM Calendar", message="Neutral pin calendar scene: consider ATM calendar if IV and event risk are acceptable.")
alertcondition((callEnabled and (fastBullTrend or bearFadeTrap)) or (putEnabled and (fastBearTrend or bullFadeTrap)), title="Avoid Plain Calendar", message="Trend/fade-trap scene: plain calendar can be overrun; consider waiting or using diagonal logic.")
alertcondition(showNoChaseHighScene, title="Do Not Chase High", message="X↑ risk: price is extended near/above the upper band/channel. Avoid chasing a fresh plain call calendar.")
alertcondition(showNoBottomFishScene, title="Do Not Bottom Fish", message="X↓ risk: price is extended near/below the lower band/channel. Avoid bottom-fishing a fresh contrarian call calendar.")
````
