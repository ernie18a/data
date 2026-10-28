# Triple Lens by MOU

- url: https://www.tradingview.com/script/bi8sXCgQ-Triple-Lens-by-MOU/
- type: indicator
- pine_id: PUB;335d80c4be6e4527aa5543ef518e0ba2
- version: 2.0

## Description

[b]Triple Lens by MOU[/b]
After spending years burning money on candlestick patterns, MACD crossovers, and Elliott Waves, I came to a simple conclusion: most retail technical analysis has been arbitraged into oblivion by quant funds. What survives — and what still works — sits in three places that machines can't fully eat: trend stage, accumulation pattern, and market breadth.
This indicator is what I built for my own trading. It overlays three independent frameworks from three legendary technicians:

Stan Weinstein — Stage Analysis (where are we in the cycle?)
William O'Neil — CANSLIM accumulation (is smart money building?)
Walter Deemer — Market Breadth (is the broader tape supporting us?)

Each lens looks at a completely different dimension. When all three light up green at the same time, you get a ▲ signal on the chart. That's the moment to pay attention.
Why three? Because any single indicator gets gamed. But three independent signals confirming the same direction is a different statistical animal — it's confluence, not coincidence.
One thing I want to be honest about: this isn't a crystal ball. Technical analysis cannot predict the future, period. What a good system can do is take you from 50/50 coin-flip entries to maybe 60-70% odds. That's it. But over hundreds of trades, that edge compounds — and that's where real wealth is built.
A ▲ signal is your green light to consider entering, not a guarantee that you'll win every time. Sizing, stops, and risk management still matter.
Important: This indicator goes blind during earnings. Earnings re-price the fundamentals — and technical analysis is built on the assumption that fundamentals are stable. If a ▲ fires right before an earnings call, wait it out. Let the dust settle, then re-evaluate.
Free to use. No tweaking needed. Built for swing and position traders on daily/weekly timeframes.
If this helps you, drop a boost. If you have feedback, comments are open.
— MOU

## Source Code

````pine
//@version=6
indicator("Triple Lens by MOU v2", overlay=true)

// ═══════════════════════════════════════════════
// 参数设置
// ═══════════════════════════════════════════════
ma30w_len        = input.int(30,    "Weinstein 30周均线",              minval=10, group="透镜① Weinstein")
slope_len        = input.int(3,     "斜率检测周期（周）",               minval=2,  group="透镜① Weinstein")
breakdown_buffer = input.float(0.03,"Stage 4 跌破缓冲（%）",            minval=0.0, maxval=0.10, step=0.005, group="透镜① Weinstein")
accum_threshold  = input.int(2,     "O'Neil 净吸筹日阈值（25天内）",    minval=1,  group="透镜② O'Neil")
dist_threshold   = input.int(4,     "O'Neil 派发日预警阈值（25天内）",  minval=2,  group="透镜② O'Neil")
dist_confirm     = input.int(5,     "O'Neil 派发日确认阈值（25天内）",  minval=3,  group="透镜② O'Neil")
breadth_recovery = input.float(50,  "Deemer Breadth 回升阈值",          minval=20, maxval=80, group="透镜③ Deemer")
breadth_overheat = input.float(70,  "Deemer Breadth 过热阈值",          minval=50, maxval=90, group="透镜③ Deemer")

// ═══════════════════════════════════════════════
// 透镜① Weinstein 30周均线数据
// ═══════════════════════════════════════════════
ma30w_weekly = request.security(syminfo.tickerid, "W", ta.sma(close, ma30w_len))
ma30w_prev   = request.security(syminfo.tickerid, "W", ta.sma(close, ma30w_len)[slope_len])
ma30w_slope  = ma30w_weekly - ma30w_prev

// ═══════════════════════════════════════════════
// 透镜② O'Neil Accumulation/Distribution
// ═══════════════════════════════════════════════
vol_avg   = ta.sma(volume, 50)
price_chg = (close - close[1]) / close[1]

isAccumDay = price_chg >  0.002 and volume > vol_avg
isDistDay  = price_chg < -0.002 and volume > vol_avg

accumCount     = math.sum(isAccumDay ? 1 : 0, 25)
distCount      = math.sum(isDistDay  ? 1 : 0, 25)
netAccum       = accumCount - distCount
isAccumulating = netAccum >= accum_threshold

// ═══════════════════════════════════════════════
// 综合 Stage 判断（Weinstein × O'Neil 融合）
// ═══════════════════════════════════════════════
isStage2 = close > ma30w_weekly and ma30w_slope > 0

// 新增 Stage 3 顶部派发期（关键补充）
isStage3 = close > ma30w_weekly and 
           ma30w_slope <= 0 and 
           distCount >= dist_threshold

// Stage 4 加严：要么跌破缓冲+均线向下，要么派发严重确认
isStage4 = (close < ma30w_weekly * (1 - breakdown_buffer) and ma30w_slope < 0) or
           (close < ma30w_weekly and distCount >= dist_confirm)

isStage1 = math.abs(close - ma30w_weekly) / ma30w_weekly < 0.05 and
           math.abs(ma30w_slope) / ma30w_weekly < 0.005 and
           not isStage3

// 早期撤退信号：Stage 3 或 价格刚跌破均线（趋势刚翻转）
isEarlyExit = isStage3 or (isStage2[1] and close < ma30w_weekly)

// ═══════════════════════════════════════════════
// 透镜③ Deemer Market Breadth（S5FI）
// ═══════════════════════════════════════════════
s5fi                   = request.security("S5FI", "D", close, ignore_invalid_symbol=true)
breadth_low_recently   = ta.lowest(s5fi, 30) < 30
breadth_now_recovering = s5fi > breadth_recovery
isBreadthBullish       = breadth_low_recently and breadth_now_recovering

// 新增：宽度过热回落（顶部预警）
breadth_high_recently  = ta.highest(s5fi, 30) > breadth_overheat
breadth_now_falling    = s5fi < breadth_recovery
isBreadthBearish       = breadth_high_recently and breadth_now_falling

// ═══════════════════════════════════════════════
// 三透镜共振信号
// ═══════════════════════════════════════════════
tripleLens  = isStage2 and isAccumulating and isBreadthBullish
firstSignal = tripleLens and not tripleLens[1]

exitSignal  = isEarlyExit or isBreadthBearish
firstExit   = exitSignal and not exitSignal[1]

// ═══════════════════════════════════════════════
// 绘图
// ═══════════════════════════════════════════════
ma_color = isStage2 ? color.new(#1A7A4A, 0) :
           isStage3 ? color.new(#FF8C00, 0) :
           isStage4 ? color.new(#C0392B, 0) :
                      color.new(#888888, 40)

plot(ma30w_weekly, color=ma_color, linewidth=2, title="30周均线")

bgcolor(isStage2 ? color.new(color.green,  93) : na, title="上升阶段背景")
bgcolor(isStage3 ? color.new(color.orange, 88) : na, title="顶部派发背景")
bgcolor(isStage4 ? color.new(color.red,    93) : na, title="下跌阶段背景")
bgcolor(isStage1 ? color.new(color.yellow, 93) : na, title="筑底阶段背景")

plotshape(firstSignal,
     title    = "三透镜共振买点",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = #1A7A4A,
     size     = size.large,
     text     = "买入", textcolor = color.white)

plotshape(tripleLens and not firstSignal,
     title    = "共振持续",
     style    = shape.circle,
     location = location.belowbar,
     color    = color.new(#1A7A4A, 50),
     size     = size.tiny)

plotshape(firstExit,
     title    = "早期撤退信号",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = #FF8C00,
     size     = size.large,
     text     = "减仓", textcolor = color.white)

// ═══════════════════════════════════════════════
// 表格文字赋值
// 正面颜色：亮白色 #FFFFFF
// 警告颜色：橙色 #FF8C00
// 负面颜色：亮红色 #FF4444
// 中性颜色：金色 #FFD700
// ═══════════════════════════════════════════════

// ── 趋势阶段（Weinstein）──
var string w_txt = ""
var color  w_col = color.white
if isStage2
    w_txt := "上升阶段 [确认]"
    w_col := #FFFFFF
else if isStage3
    w_txt := "顶部派发 [减仓]"
    w_col := #FF8C00
else if isStage1
    w_txt := "筑底阶段 [等待]"
    w_col := #FFD700
else if isStage4
    w_txt := "下跌阶段 [回避]"
    w_col := #FF4444
else
    w_txt := "中性区 [观望]"
    w_col := color.new(color.white, 30)

// ── 吸筹指数（O'Neil）──
var string o_txt = ""
var color  o_col = color.white
if isAccumulating
    o_txt := "主力吸筹 [确认] (" + str.tostring(netAccum) + ")"
    o_col := #FFFFFF
else if distCount >= dist_threshold
    o_txt := "主力派发 [警告] (" + str.tostring(netAccum) + ")"
    o_col := #FF4444
else
    o_txt := "资金中性 [观察] (" + str.tostring(netAccum) + ")"
    o_col := #FFD700

// ── 市场宽度（Deemer）──
var string d_txt = ""
var color  d_col = color.white
if na(s5fi)
    d_txt := "数据加载中..."
    d_col := #FFD700
else if isBreadthBullish
    d_txt := "宽度回升 [确认] " + str.tostring(math.round(s5fi, 1))
    d_col := #FFFFFF
else if isBreadthBearish
    d_txt := "宽度回落 [警告] " + str.tostring(math.round(s5fi, 1))
    d_col := #FF4444
else
    d_txt := "宽度中性 [等待] " + str.tostring(math.round(s5fi, 1))
    d_col := #FFD700

// ── 综合信号 ──
var string sig_txt = ""
var string sig_sub = ""
var color  sig_col = color.white
var color  sig_bg  = color.new(#1E3A5F, 0)
if tripleLens
    sig_txt := "三透镜共振触发"
    sig_sub := ">>> 进场信号 <<<"
    sig_col := #FFD700
    sig_bg  := color.new(#B8860B, 75)
else if exitSignal
    sig_txt := "撤退信号触发"
    sig_sub := ">>> 减仓 / 离场 <<<"
    sig_col := #FF8C00
    sig_bg  := color.new(#8B3A1A, 50)
else
    sig_txt := "等待信号..."
    sig_sub := "---"
    sig_col := color.new(color.white, 50)
    sig_bg  := color.new(#1E3A5F, 0)

// ═══════════════════════════════════════════════
// 状态面板
// ═══════════════════════════════════════════════
var table panel = table.new(
     position.top_center, 2, 5,
     bgcolor      = color.new(#1E3A5F, 10),
     border_width = 1,
     border_color = color.new(#B8860B, 60),
     frame_width  = 1,
     frame_color  = color.new(#B8860B, 40))

if barstate.islast
    // ── 标题行 ──
    table.cell(panel, 0, 0, "MOU三透镜",
         text_color  = #B8860B, text_size = size.large,
         bgcolor     = color.new(#1E3A5F, 0),
         text_halign = text.align_left)
    table.cell(panel, 1, 0, "判断结果",
         text_color  = #B8860B, text_size = size.large,
         bgcolor     = color.new(#1E3A5F, 0),
         text_halign = text.align_center)

    // ── 透镜① 趋势阶段 ──
    table.cell(panel, 0, 1, "趋势阶段",
         text_color  = color.new(color.white, 20),
         text_size   = size.normal,
         text_halign = text.align_left)
    table.cell(panel, 1, 1, w_txt,
         text_color  = w_col,
         text_size   = size.normal,
         text_halign = text.align_center)

    // ── 透镜② 吸筹指数 ──
    table.cell(panel, 0, 2, "吸筹指数",
         text_color  = color.new(color.white, 20),
         text_size   = size.normal,
         text_halign = text.align_left)
    table.cell(panel, 1, 2, o_txt,
         text_color  = o_col,
         text_size   = size.normal,
         text_halign = text.align_center)

    // ── 透镜③ 市场宽度 ──
    table.cell(panel, 0, 3, "市场宽度",
         text_color  = color.new(color.white, 20),
         text_size   = size.normal,
         text_halign = text.align_left)
    table.cell(panel, 1, 3, d_txt,
         text_color  = d_col,
         text_size   = size.normal,
         text_halign = text.align_center)

    // ── 综合信号行 ──
    table.cell(panel, 0, 4, sig_txt,
         text_color  = sig_col, text_size = size.normal,
         bgcolor     = sig_bg,  text_halign = text.align_center)
    table.cell(panel, 1, 4, sig_sub,
         text_color  = sig_col, text_size = size.normal,
         bgcolor     = sig_bg,  text_halign = text.align_center)

// ═══════════════════════════════════════════════
// 提醒
// ═══════════════════════════════════════════════
alertcondition(firstSignal,
     title   = "三透镜共振买点",
     message = "{{ticker}} 三透镜共振触发：趋势上升 + 主力吸筹 + 市场宽度回升 —— 《投资为乐》第二版")

alertcondition(firstExit,
     title   = "早期撤退信号",
     message = "{{ticker}} 撤退信号触发：顶部派发 或 宽度回落 —— 《投资为乐》第二版")
````
