# FCPO KDJ Tower HA EMA Strategy

- url: https://www.tradingview.com/script/aIssaYjv-FCPO-KDJ-Tower-HA-EMA-Strategy/
- type: strategy
- pine_id: PUB;45caeee610f64603bf57c57f0de5ae30
- version: 1.0

## Description

[b]FCPO 5-Min Strategy Backtest v1[/b] — A day-trading strategy for FCPO (Malaysia Crude Palm Oil Futures, BMD:FCPO1!) built on a 5-layer confluence system: KDJ + Tower (Baota) + Heikin Ashi + EMA20 + MACD. It uses the exact same entry logic as the companion "FCPO 5min Signal System v2" indicator, converted to the Strategy Tester to validate signal quality.

[b]Entry Conditions (all 5 layers must align)[/b]:
- Layer 1 — Trend filter: price above EMA20 = long only; below EMA20 = short only
- Layer 2 — Momentum: MACD histogram direction (5,20,5)
- Layer 3 — Extreme signal: KDJ J value < 20 (oversold) or > 80 (overbought)
- Layer 4 — Candle confirmation: Heikin Ashi direction matches raw candle close direction
- Layer 5 — Final filter: Tower (Baota) line flips red (bullish) / green (bearish)
- Entries only when flat; each signal fires once, on the first bar all conditions align

[b]Exit Rules (intraday discipline)[/b]:
- Fixed stop-loss / take-profit: 8 points each by default (1 lot = RM25 per point, i.e. RM200 / RM200)
- Max holding time: 60 bars by default (can be disabled)
- End-of-day liquidation at 17:45 — no overnight positions
- No new entries after 17:15 (MYT)

[b]Backtest Settings[/b]: commission RM12.5/lot and 1-tick slippage included; initial capital 10,000, fixed 1 lot.

[b]How to Use[/b]: Open FCPO1! (or BMD:FCPO1!) on a 5-minute chart — keep regular candlesticks (do NOT enable Heikin Ashi candles, as fill prices would be distorted) — add the strategy, then open the Strategy Tester. All parameters (EMA / KDJ / MACD / stop-take points / time windows) are adjustable in the settings panel.

Disclaimer: This script is a technical-analysis tool for validation only. Backtest results do not guarantee future performance, and this is not financial advice. Futures trading involves high risk; always use proper risk management and stop-loss discipline.

[b]FCPO 5分钟 策略回测 v1[/b] —— 基于 KDJ + 宝塔线 + Heikin Ashi + EMA20 + MACD 五层共振入场系统的 FCPO（马来西亚棕榈油期货，BMD:FCPO1!）日内交易策略，与「FCPO 系统警报 v2」指标使用同一套入场逻辑，用于在策略回测器中验证信号质量。

[b]入场条件（五层全部满足才开仓）[/b]：
- 第1层 大方向：价格在 EMA20 上方只做多，下方只做空
- 第2层 动量背景：MACD 柱状线方向（5,20,5）
- 第3层 极端信号：KDJ J 值 < 20（KDJL）或 > 80（KDJH）
- 第4层 K线确认：Heikin Ashi 同向 + 普通K线收盘同向
- 第5层 最终过滤：宝塔线翻红 / 翻绿
- 只在空仓时进场，信号首次满足时只触发一次

[b]出场规则（按日内交易纪律）[/b]：
- 固定止损 / 止盈：默认各 8 点（1手合约每点 = RM25，即 RM200 / RM200）
- 最长持仓超时：默认 60 根K线（可关闭）
- 日内强平：17:45 触发清仓，不留隔夜仓
- 17:15 后不开新仓

[b]回测设置[/b]：已含手续费（RM12.5/手）与滑点（1 tick）；初始资金 10,000，固定 1 手。

[b]使用方法[/b]：FCPO1!（或 BMD:FCPO1!）5 分钟图 → 保持普通K线蜡烛模式（不要开 Heikin Ashi 蜡烛，否则成交价失真）→ 添加策略 → 打开策略回测器查看结果。EMA / KDJ / MACD / 止损止盈点数 / 时间窗口等参数均可在设置面板调整。

提醒：本策略仅为技术分析验证工具，回测结果不代表未来表现，不构成任何投资建议。期货交易风险高，请务必配合资金管理与止损纪律。

## Source Code

````pine
//@version=6
strategy("FCPO 策略回测 (KDJ+宝塔+HA+EMA)", shorttitle="FCPO Strategy v1", overlay=true, precision=1,
     initial_capital=10000,
     default_qty_type=strategy.fixed,
     default_qty_value=1,
     commission_type=strategy.commission.cash_per_contract,
     commission_value=12.5,
     slippage=1,
     max_bars_back=200)

// ============================================================
//  FCPO 5分钟 策略回测 v1 —— 由「FCPO 系统警报 v2」指标改造
//  入场（五层框架全部满足，同指标）：
//     L1 大方向: 价格在 EMA20 上方只做多 / 下方只做空
//     L2 动量   : MACD 柱状线方向 (5,20,5)
//     L3 极端   : KDJ J<20 (KDJL) / J>80 (KDJH)
//     L4 确认   : Heikin Ashi 同向 + 普通K线收盘同向
//     L5 过滤   : 宝塔线翻红/翻绿
//  出场（按他的交易纪律）：
//     固定止损 / 固定止盈 / 最长持仓超时 / 日内强平（不留隔夜）
//     17:15 后不开新仓
//  注意：回测请用普通K线图（不要开 Heikin Ashi 蜡烛）！
//        成交价按图表K线计算，HA 蜡烛会让盈亏失真。
//        1手 FCPO 每点 = RM25，RM200 止损/止盈 ≈ 8 点（默认值）。
//        若他实际做多手数，把止损/止盈点数按手数折算。
// ============================================================

// ========== 输入参数 ==========
emaLen         = input.int(20,   "EMA 长度",        minval=1)
kdjPeriod      = input.int(9,    "KDJ 周期",        minval=2)
kdjK           = input.int(5,    "KDJ K 平滑",      minval=1)
kdjD           = input.int(5,    "KDJ D 平滑",      minval=1)
jOversold      = input.float(20, "超卖线 (KDJL)",    minval=1,  maxval=49)
jOverbought    = input.float(80, "超买线 (KDJH)",    minval=51, maxval=99)
macdFast       = input.int(5,    "MACD 快线",        minval=1)
macdSlow       = input.int(20,   "MACD 慢线",        minval=2)
macdSignal     = input.int(5,    "MACD 信号线",      minval=1)
useStrictTower = input.bool(false, "宝塔线只认严格翻色", tooltip="开启=只在绿翻红/红翻绿瞬间出信号；关闭=翻色或连续2根同色都算（原版用法）")
requireRawK    = input.bool(true, "要求普通K线同向确认", tooltip="第4层确认：HA阳线 + 普通K线收盘阳 才做多")
daySessionOnly = input.bool(true, "只在日盘出信号",   tooltip="日盘 10:30-18:00 (MYT)；夜盘 21:00-23:30 不开单")

stopPts        = input.float(8,  "止损点数 (RM/吨)",  minval=0.5, tooltip="1手合约每点=RM25。RM200止损≈8点")
targetPts      = input.float(8,  "止盈点数 (RM/吨)",  minval=0.5, tooltip="RM200止盈≈8点")
maxHoldBars    = input.int(60,   "最长持仓K线数",     minval=0,  tooltip="0=不限制（日内强平兜底）")
noNewAfter     = input.int(1715, "新仓截止时间 (HHMM)", tooltip="如 1715 = 17:15 后不开新仓")
eodClose       = input.int(1745, "日内强平时间 (HHMM)", tooltip="到点平掉所有仓位，次日不留仓")

// ========== 数据源（不依赖图表蜡烛类型） ==========
// 原始 OHLC：EMA / KDJ / 宝塔 / MACD 全部基于真实成交价
[rO, rH, rL, rC] = request.security(syminfo.tickerid, timeframe.period, [open, high, low, close])
// Heikin Ashi：与图表 HA 模式同源的标准算法
haTicker = ticker.heikinashi(syminfo.tickerid)
[haO, haH, haL, haC] = request.security(haTicker, timeframe.period, [open, high, low, close])

// ========== 第1层：EMA 趋势过滤 ==========
emaLine = ta.ema(rC, emaLen)

// ========== 第3层：KDJ (9,5,5) 中国式加权（与文华/通达信一致） ==========
hh  = ta.highest(rH, kdjPeriod)
ll  = ta.lowest(rL, kdjPeriod)
rsv = hh == ll ? 50.0 : (rC - ll) / (hh - ll) * 100

var float k = na
var float d = na
k := na(k[1]) ? rsv : (rsv + (kdjK - 1) * nz(k[1])) / kdjK
d := na(d[1]) ? k   : (k   + (kdjD - 1) * nz(d[1])) / kdjD
jVal = 3 * k - 2 * d
kdjL = jVal < jOversold     // 超卖区，配合多头方向做顺势低吸
kdjH = jVal > jOverbought   // 超买区，配合空头方向做顺势高抛

// ========== 第2层：MACD (5,20,5) 柱状线方向 ==========
macdLine = ta.ema(rC, macdFast) - ta.ema(rC, macdSlow)
sigLine  = ta.ema(macdLine, macdSignal)
macdBull = macdLine > sigLine
macdBear = macdLine < sigLine

// ========== 第4层：Heikin Ashi + 普通K线 同向 ==========
haBull   = haC > haO
haBear   = haC < haO
rawBull  = rC > rO
rawBear  = rC < rO

// ========== 第5层：宝塔线 ==========
towerUp     = rC > rC[1]   // 红宝塔（上涨）
towerDn     = rC < rC[1]   // 绿宝塔（下跌）
towerFlipUp = towerUp and towerDn[1]  // 由绿翻红
towerFlipDn = towerDn and towerUp[1]  // 由红翻绿
towerOKUp   = useStrictTower ? towerFlipUp : towerUp
towerOKDn   = useStrictTower ? towerFlipDn : towerDn

// ========== 综合信号（L1-L5 全部满足，一次性触发） ==========
longBase  = rC > emaLine and kdjL and haBull and towerOKUp and macdBull
shortBase = rC < emaLine and kdjH and haBear and towerOKDn and macdBear
longCond  = requireRawK ? (longBase and rawBull) : longBase
shortCond = requireRawK ? (shortBase and rawBear) : shortBase

longSig  = longCond and not longCond[1]
shortSig = shortCond and not shortCond[1]

// ========== 时段（MYT） ==========
klHour   = hour(time, "Asia/Kuala_Lumpur")
klMinute = minute(time, "Asia/Kuala_Lumpur")
barKL    = klHour * 100 + klMinute
inDaySession = (klHour > 10 or (klHour == 10 and klMinute >= 30)) and klHour < 18
sessionOK    = not daySessionOnly or inDaySession

inNoNewWindow = barKL >= noNewAfter   // 17:15 后不开新仓
inEodWindow   = barKL >= eodClose     // 日内强平窗口

// ========== 入场（只在空仓时） ==========
longEntry  = longSig and sessionOK and strategy.position_size == 0 and not inNoNewWindow
shortEntry = shortSig and sessionOK and strategy.position_size == 0 and not inNoNewWindow

if longEntry
    strategy.entry("Long", strategy.long, comment="Long")
if shortEntry
    strategy.entry("Short", strategy.short, comment="Short")

// ========== 持仓状态快照（入场后取一次） ==========
var int   entryBar = -1
var float stopPx   = na
var float targetPx = na

if strategy.position_size != 0 and entryBar == -1
    entryBar := bar_index
    avgPx = strategy.position_avg_price
    if strategy.position_size > 0
        stopPx   := avgPx - stopPts
        targetPx := avgPx + targetPts
    else
        stopPx   := avgPx + stopPts
        targetPx := avgPx - targetPts

// ========== 出场（止损/止盈/超时；入场K线之后才开始检查） ==========
if strategy.position_size > 0 and entryBar != -1 and bar_index > entryBar
    if low <= stopPx
        strategy.close("Long", comment="StopLoss")
    else if high >= targetPx
        strategy.close("Long", comment="TakeProfit")
    else if maxHoldBars > 0 and bar_index - entryBar >= maxHoldBars
        strategy.close("Long", comment="TimeOut")

if strategy.position_size < 0 and entryBar != -1 and bar_index > entryBar
    if high >= stopPx
        strategy.close("Short", comment="StopLoss")
    else if low <= targetPx
        strategy.close("Short", comment="TakeProfit")
    else if maxHoldBars > 0 and bar_index - entryBar >= maxHoldBars
        strategy.close("Short", comment="TimeOut")

// ========== 日内强平（不留隔夜） ==========
if strategy.position_size != 0 and inEodWindow
    strategy.close_all(comment="EOD")

// ========== 状态重置（平仓后的下一根K线） ==========
if strategy.position_size[1] != 0 and strategy.position_size == 0
    entryBar := -1
    stopPx   := na
    targetPx := na

// ========== 绘图 ==========
plot(emaLine, "EMA", color=#1e88e5, linewidth=2)
plotshape(longEntry,  style=shape.triangleup,   location=location.belowbar, color=#4caf50, size=size.small, text="BUY")
plotshape(shortEntry, style=shape.triangledown, location=location.abovebar, color=#ef5350, size=size.small, text="SELL")
plotshape(strategy.position_size[1] != 0 and strategy.position_size == 0,
     style=shape.xcross, location=location.abovebar, color=#78909c, size=size.large)
````
