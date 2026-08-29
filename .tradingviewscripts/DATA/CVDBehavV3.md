<!-- tradingview-pine-id: PUB;fcc5e982cced4395a31108007ff4ad6b -->
<!-- tradingviewscripts-format: 1 -->
# CVD_Behav_V3

Source: https://www.tradingview.com/script/SLbRgrAX/

## Description

Here is a comprehensive English explanation of the **CVD Pro: Institutional Behavior Panorama V3.0** indicator for TradingView.

---

## CVD Pro: Institutional Behavior Panorama V3.0 – User Guide

### 1. Overview & Core Logic

This indicator is designed to **detect institutional (whale) activity** by combining **CVD (Cumulative Volume Delta)** with price position, volume purity, and slope analysis. It visualizes accumulation, distribution, attacks, absorption, churn, and momentum exhaustion in real time.

**Core Calculation:**
- **CVD** = cumulative sum of (buy volume – sell volume) estimated from intra-bar price action.
- **Normalized CVD** = (raw CVD – 50‑period SMA) / 50‑period stdev → z‑score for cross‑asset comparability.
- **Acceleration** = weighted change of CVD, multiplied by volume factor to filter noise.

**Three‑dimensional validation** ensures signals are meaningful:
1. **Price position** – relative to 100‑period high/low (bottom 30% / top 30%).
2. **Volume purity** – volume > 1.5× its 20‑period average (adjustable), but not extreme (>5×) to avoid outliers.
3. **Slope comparison** – 20‑period linear regression slopes of price and CVD.

---

### 2. Chart Signals (Overlay on Price)

| Symbol | Color / Shape | Meaning | Action |
|--------|---------------|---------|--------|
| **吸** (Accumulate) | Green label below bar | Price falling but CVD rising – smart money buying in a downtrend. | Light long, stop below signal low. |
| **发** (Distribute) | Red label above bar | Price rising but CVD falling – smart money selling into strength. | Reduce or exit longs; do not chase. |
| **攻** (Attack) | Purple triangle below bar | Price & CVD both rising, CVD slope > 0.5× price slope – genuine breakout with real volume. | Aggressive entry on breakout, stop below signal low. |
| **托** (Support) | Blue dot below bar | Price near 20‑day low, CVD stabilises – large passive bids absorbing selling. | Short‑term bounce play, but light position. |
| **换** (Absorption) | Orange diamond below bar | Narrow range (width <3%) with CVD surging – accumulation within a consolidation, often a handover between institutions. | Accumulation zone; wait for breakout above range high. |
| **对倒** (Churn) | Maroon triangle above bar | Price spikes (>1% slope) but CVD flat/declining – fake breakout via wash trading. | Avoid chasing; tighten stops on existing positions. |
| **减速** (Slowdown) | Yellow arrow above bar | After an “Attack”, acceleration declines for 3 bars – momentum fading. | Do not add; consider partial exit. |
| **B** (Bullish Divergence) | Green “B” below bar | Price makes new low, CVD does not – potential reversal. | Watch for confirmation with support. |
| **S** (Bearish Divergence) | Fuchsia “S” above bar | Price makes new high, CVD does not – potential top. | Reduce risk; tighten stops. |

---

### 3. Sub‑Chart (Lower Panel) – CVD & Acceleration

- **Purple line** – Normalized CVD (z‑score). Up = net buying, down = net selling.
- **Yellow line (fast)** – 5‑period EMA of normalized CVD.
- **Blue line (slow)** – 20‑period EMA of normalized CVD.
  - **Golden cross (fast > slow)** = institutional thrust increasing (bullish).
  - **Death cross (fast < slow)** = institutional thrust decreasing (bearish).
- **Red / Green histogram** – CVD acceleration (weighted). 
  - **Green & growing** = institutional acceleration (momentum increasing).
  - **Red & growing** = deceleration (momentum decreasing).
  - *Height reflects the strength of the change.*

---

### 4. Multi‑Timeframe Dashboard (Top‑Left Corner)

Displays the **fast vs slow CVD status** for 15m, 1h, 4h, and Daily:
- 🟢 Green dot = CVD fast > slow (bullish trend on that timeframe).
- 🔴 Red dot = CVD fast < slow (bearish trend).

**Position sizing guide:**
- All green → heavy (conviction).
- One red, three green → light.
- All red → stay in cash or short.

---

### 5. Step‑by‑Step Trading Workflow

1. **Set the macro bias** – Check the background colour:
   - **Light green** = price above 200‑EMA → only long signals are valid.
   - **Light red** = price below 200‑EMA → only short signals (or no signals) are valid.
   - *Ignore counter‑trend signals.*

2. **Assess the dashboard** – Confirm the multi‑timeframe trend. All green → high confidence; mixed → reduce position size.

3. **Look for behaviour labels** that align with the macro trend:
   - In a green background: **攻**, **吸**, or **换** are actionable buy signals.
   - In a red background: ignore all buy labels.

4. **Monitor acceleration and divergences** for risk management:
   - **S** or **减速** → tighten stops or take partial profits.
   - **B** → watch for a possible reversal, but wait for confirmation.

---

### 6. Parameter Tuning Recommendations

| Parameter | Default | When to Adjust |
|-----------|---------|----------------|
| **Fast MA Length** | 5 | Lower (3) for more sensitivity (scalping); higher (13) for smoother signals (swing). |
| **Slow MA Length** | 20 | Increase for less frequent crossovers; decrease for earlier signals. |
| **Lookback (Position)** | 100 | Increase to 200 for stricter “bottom/top” definition on weekly charts. |
| **Volume Threshold** | 1.5 | Raise to 2.0 for crypto/futures to reduce noise; lower to 1.2 for stocks. |
| **EMA Period (Trend)** | 200 | Use 50 for short‑term trend; 200 for long‑term. |
| **Show options** | All true | Toggle off CVD, MA, or acceleration for cleaner view. |

---

### 7. Alerts (Notifications)

The indicator provides **one‑time alerts** (on first occurrence) for:
- High‑confidence Attack / Accumulate / Distribute
- Absorption (range accumulation)
- Bullish / Bearish divergence
- Momentum slowdown
- Churn (fake breakout)

**Set up alerts** via the TradingView alarm dialog – select the condition and enable push notifications.

---

### 8. Important Risk Disclaimers

- **Data limitations** – CVD is estimated from OHLC data, not tick‑by‑tick order flow. The indicator is a **tool for analysis, not a guaranteed predictor**.
- **Lag** – Signals appear 1‑2 bars after the actual event. Always combine with price action (support/resistance, candlestick patterns).
- **False signals** – Especially in low timeframes (<15 min). Use higher timeframes for reliability.
- **Backtesting** – Past performance does not guarantee future results. Always paper‑trade first.
- **Stop‑loss** – For any signal, place your stop **below the signal bar’s low** (for longs) or **above its high** (for shorts). Never trade without a stop.

---

### 9. Quick Reference Card

| You see... | Background | Dashboard | Action |
|------------|------------|-----------|--------|
| **攻** + green acceleration | Light green | All green | Aggressive long |
| **吸** | Light green | Mixed green/red | Light long, scale in |
| **换** | Light green | Any | Accumulate, wait for breakout |
| **对倒** or **减速** | Any | Any | Tighten stops, do not add |
| **发** or **S** | Light red | Mostly red | Short or exit longs |
| **B** | Light red | Red | Wait; do not buy yet |

---

### 10. Final Words

This indicator transforms raw volume and price data into **actionable institutional footprints**. It does not replace your own judgment but provides an objective framework to **filter noise, confirm trends, and manage risk**.

Use it with discipline – always combine signals with proper risk management and your own market context.

Happy trading! 📈

---

## Source Code

````pine
//@version=6
indicator('CVD_Behav_V3', shorttitle = 'CVD_Behav_V3', overlay = false, precision = 4, scale = scale.right, dynamic_requests = true)

// ============================================================================
//  1. 参数设置（含详细使用说明）
// ============================================================================

show_cvd = input.bool(true, '显示CVD曲线', tooltip = '═════════════════════\n' + '📊 【CVD 主力行为全景版 V3.0 使用说明】\n' + '═════════════════════\n' + '🎯 核心逻辑：CVD（累积成交量增量）反映主力资金净流向\n' + '   配合价格位置、成交量纯度、斜率三维验证，识别主力行为\n' + '📊 副图指标解读：\n' + '──────────────────────\n' + '📈 紫色曲线 = 归一化CVD（主力资金净流向）\n' + '   → 向上 = 主力净买入，向下 = 主力净卖出\n' + '📈 黄色快线 = CVD的EMA（5周期）\n' + '📈 蓝色慢线 = CVD的EMA（20周期）\n' + '   → 金叉（快线上穿慢线）= 主力加力做多\n' + '   → 死叉（快线下穿慢线）= 主力减速做空\n' + '📊 红/绿柱 = CVD加速度（主力推力变化）\n' + '   → 绿色柱变长 = 主力在加速进攻\n' + '   → 红色柱变长 = 主力在加速撤退\n' + '🎯 多周期仪表盘（左上角）\n' + '──────────────────────\n' + '15m ● 1h ● 4h ● D ●\n' + '   🟢 绿色 = CVD快线在慢线之上（多头趋势）\n' + '   🔴 红色 = CVD快线在慢线之下（空头趋势）\n' + '   → 全绿：重仓做多；全红：空仓观望；\n' + '   → 混合：轻仓操作，顺大周期方向\n' + '🎯 综合操作口诀：\n' + '──────────────────────\n' + '1️⃣ 看背景色（定战略）：\n' + '   淡绿（EMA之上）→ 只做多，不做空\n' + '   淡红（EMA之下）→ 只做空，不做多\n' + '2️⃣ 看仪表盘（定仓位）：\n' + '   全绿 → 重仓；一红三绿 → 轻仓；全红 → 空仓\n' + '3️⃣ 看行为标签（定时机）：\n' + '   顺势信号（背景绿 + 攻/吸/换）→ 跟进\n' + '   逆势信号（背景红 + 任何买入信号）→ 放弃\n' + '4️⃣ 看背离/减速（定风控）：\n' + '   出现 S / 减速 → 收紧止损\n' + '   出现 B → 关注反转可能\n' + '⚠️ 风险提示：\n' + '──────────────────────\n' + '• 本指标基于TradingView估算数据，非真实逐笔成交\n' + '• 信号滞后1-2根K线，请结合K线形态综合判断\n' + '• 任何信号都需设止损，建议止损设在信号K线最低价\n' + '• 建议在15分钟及以上周期使用，小周期噪音大\n' + '• 回测表现不代表实盘结果，请先模拟盘验证\n' + '═════════════════════')







fast_len = input.int(5, '快线周期', minval = 1, tooltip = 'CVD快线（黄色）的EMA周期。\n🔹 数值越小，信号越敏感，适合短线；\n🔹 数值越大，信号越平滑，适合中长线。\n推荐：5（短线）/ 13（中长线）')
slow_len = input.int(20, '慢线周期', minval = 1, tooltip = 'CVD慢线（蓝色）的EMA周期。\n🔹 快线上穿慢线 = 主力加力（金叉做多）；\n🔹 快线下穿慢线 = 主力减速（死叉减仓）。\n推荐：20（默认）')
lookback = input.int(100, '位置参考周期', minval = 50, tooltip = '用于判断价格高/低位的回看K线数。\n🔹 数值越大，对“底部/顶部”的定义越严格；\n🔹 数值越小，信号越敏感但假信号增多。\n推荐：100（日线）/ 200（周线）')
vol_threshold = input.float(1.5, '放量阈值', step = 0.1, tooltip = '成交量需超过20日均量的倍数。\n🔹 值越小，信号越敏感；值越大，信号越稀缺。\n推荐：1.5（股票）/ 2.0（币圈期货）')
ema_period = input.int(200, '宏观趋势EMA周期', minval = 50, tooltip = '用于判断大趋势方向的EMA周期。\n🔹 价格在EMA之上 = 多头保护区（背景淡绿）；\n🔹 价格在EMA之下 = 空头禁区（背景淡红）。\n推荐：200（长线）/ 50（短线）')
show_ma = input.bool(true, '显示均线', tooltip = '显示CVD的EMA快慢线（黄/蓝）')
show_accel = input.bool(true, '显示加速度', tooltip = '显示CVD加速度柱状图（红/绿），反映主力推力变化')
show_dashboard = input.bool(true, '显示多周期仪表盘', tooltip = '═════════════════════\n' + '📌 图表信号解读：\n' + '──────────────────────\n' + '🟢 【吸】绿色标签（底部出现）\n' + '   → 主力在低位暗中吸筹，价格跌但CVD在涨\n' + '   → 操作：轻仓试多，止损设在信号K线最低价下方\n' + '🔴 【发】红色标签（顶部出现）\n' + '   → 主力在高位悄悄派发，价格涨但CVD在跌\n' + '   → 操作：减仓或清仓，绝不追涨\n' + '🟣 【攻】紫色三角（放量突破）\n' + '   → 主力真金白银主动进攻，价格与CVD同步上涨\n' + '   → 操作：突破关键位时果断跟进，止损设在进攻K线最低价\n' + '🔵 【托】蓝色圆点（低位承接）\n' + '   → 主力在低位挂大单托底，短期企稳信号\n' + '   → 操作：可做超跌反弹，但仓位不宜重\n' + '🟠 【换】橙色钻石（横盘吸收）\n' + '   → 主力在横盘区间内持续吸筹，新旧主力换手\n' + '   → 操作：潜伏区，等待放量突破上沿后跟进\n' + '🟤 【对倒】深红三角（顶部出现）\n' + '   → 主力左手倒右手制造假突破，CVD未跟进\n' + '   → 操作：立即停止开仓，持仓收紧止损\n' + '🟡 【减速】黄色箭头（进攻后出现）\n' + '   → 进攻信号后推力衰减，价格面临回调\n' + '   → 操作：不加仓，准备减仓或平仓\n' + '🟢 【B】底背离（价格新低，CVD不跟）\n' + '   → 左侧抄底信号，需配合支撑位验证\n' + '🔴 【S】顶背离（价格新高，CVD不跟）\n' + '   → 顶部反转预警，减仓为主\n')

// ============================================================================
//  2. 核心CVD计算（手动累积）
// ============================================================================
range_hl = high - low
safe_range = math.max(range_hl, syminfo.mintick * 10)
buy_power = volume * (close - low) / safe_range
sell_power = volume * (high - close) / safe_range
delta = buy_power - sell_power

var float raw_cvd = 0.0
raw_cvd := raw_cvd + delta

cvd_mean = ta.sma(raw_cvd, 50)
cvd_std = ta.stdev(raw_cvd, 50)
cvd_std_safe = math.max(cvd_std, syminfo.mintick * 1e-6)
cvd_norm = (raw_cvd - cvd_mean) / cvd_std_safe

fast_ma = ta.ema(cvd_norm, fast_len)
slow_ma = ta.ema(cvd_norm, slow_len)

vol_factor = volume / ta.sma(volume, 20)
raw_accel = ta.change(cvd_norm, 1) - ta.change(cvd_norm, 1)[1]
weighted_accel = raw_accel * math.min(vol_factor, 3)
smooth_accel = ta.sma(weighted_accel, 3)

// ============================================================================
//  3. 三维验证 + 置信度评分（已修正斜率未来函数）
// ============================================================================
price_range = ta.highest(high, lookback) - ta.lowest(low, lookback)
price_range_safe = math.max(price_range, syminfo.mintick * 10)
price_position = (close - ta.lowest(low, lookback)) / price_range_safe

is_low_position = price_position < 0.3
is_high_position = price_position > 0.7

volume_purity = volume / ta.sma(volume, 20)
is_real_volume = volume_purity > vol_threshold and volume_purity < 5

// 修正：使用偏移 -1 避免未来数据
price_slope = ta.linreg(close, 20, 0) - ta.linreg(close, 20, -1)
cvd_slope = ta.linreg(cvd_norm, 20, 0) - ta.linreg(cvd_norm, 20, -1)

// 换手优先计算
range_high_20 = ta.highest(high, 20)
range_low_20 = ta.lowest(low, 20)
range_width = (range_high_20 - range_low_20) / range_low_20 * 100
cvd_20_change = cvd_norm - cvd_norm[20]
absorption = range_width < 3 and cvd_20_change > 1.5 and volume > ta.sma(volume, 20) * 1.8

accumulation = is_low_position and is_real_volume and price_slope < 0 and cvd_slope > 0.3 and not absorption
distribution = is_high_position and is_real_volume and price_slope > 0 and cvd_slope < -0.3
attack = price_slope > 0 and cvd_slope > 0 and cvd_slope > price_slope * 0.5 and is_real_volume
absorb = is_low_position and is_real_volume and ta.change(cvd_norm, 3) > 0 and ta.change(cvd_norm, 3) < 0.8

// 对倒检测
churn = price_slope > 1.0 and cvd_slope < 0.3 and is_real_volume and price_slope > cvd_slope * 2

high_conf_accum = accumulation and volume_purity > 1.5
high_conf_dist = distribution and volume_purity > 1.5
high_conf_attack = attack and volume_purity > 1.5

accum_color = volume_purity > 2.5 ? color.lime : color.green
dist_color = volume_purity > 2.5 ? color.fuchsia : color.red
attack_color = volume_purity > 2.5 and cvd_slope > price_slope * 1.0 ? color.white : color.new(color.purple, 0)

// ============================================================================
//  4. 背离检测
// ============================================================================
price_high = ta.highest(high, 5)
price_low = ta.lowest(low, 5)
cvd_high = ta.highest(cvd_norm, 5)
cvd_low = ta.lowest(cvd_norm, 5)
bearish_div = high == price_high and cvd_norm < cvd_high[1] and cvd_norm < cvd_high
bullish_div = low == price_low and cvd_norm > cvd_low[1] and cvd_norm > cvd_low

// ============================================================================
//  5. 增强功能
// ============================================================================
ema_long = ta.ema(close, ema_period)
trend_up = close > ema_long

accel_decline = ta.falling(smooth_accel, 3)
attack_fading = attack and accel_decline

new_accum = high_conf_accum and not high_conf_accum[1]
new_dist = high_conf_dist and not high_conf_dist[1]
new_attack = high_conf_attack and not high_conf_attack[1]
new_absorb = absorption and not absorption[1]
new_bull_div = bullish_div and not bullish_div[1]
new_bear_div = bearish_div and not bearish_div[1]
new_fading = attack_fading and not attack_fading[1]

// ============================================================================
//  6. 图形绘制
// ============================================================================
bgcolor(trend_up ? color.new(color.green, 92) : color.new(color.red, 92), title = '宏观趋势背景')
bgcolor(high_conf_accum ? color.new(color.green, 88) : na, title = '高确定性吸筹区')
bgcolor(high_conf_dist ? color.new(color.red, 88) : na, title = '高确定性派发区')

plotshape(high_conf_accum, title = '吸筹', style = shape.labelup, location = location.belowbar, color = accum_color, text = '吸', textcolor = color.white, size = size.small, force_overlay = true)
plotshape(high_conf_dist, title = '派发', style = shape.labeldown, location = location.abovebar, color = dist_color, text = '发', textcolor = color.white, size = size.small, force_overlay = true)
plotshape(high_conf_attack, title = '主动进攻', style = shape.triangleup, location = location.belowbar, color = attack_color, size = size.small, text = '攻', textcolor = color.white, force_overlay = true)
plotshape(absorb, title = '被动承接', style = shape.circle, location = location.belowbar, color = color.new(color.blue, 0), size = size.tiny, text = '托', force_overlay = true)
plotshape(absorption, title = '区间吸收（换手）', style = shape.diamond, location = location.belowbar, color = color.new(color.orange, 0), size = size.small, text = '换', textcolor = color.white, force_overlay = true)
plotshape(attack_fading, title = '进攻减速', style = shape.arrowdown, location = location.abovebar, color = color.new(color.yellow, 0), size = size.tiny, text = '减速', force_overlay = true)
plotshape(churn, title = '对倒预警', style = shape.triangledown, location = location.abovebar, color = color.new(color.maroon, 0), size = size.small, text = '对倒', textcolor = color.white, force_overlay = true)
plotshape(bullish_div, title = '底背离', style = shape.labelup, location = location.belowbar, color = color.lime, text = 'B', textcolor = color.black, size = size.tiny, force_overlay = true)
plotshape(bearish_div, title = '顶背离', style = shape.labeldown, location = location.abovebar, color = color.fuchsia, text = 'S', textcolor = color.white, size = size.tiny, force_overlay = true)

plot(show_cvd ? cvd_norm : na, color = color.new(color.purple, 70), linewidth = 1, title = 'CVD归一化')
plot(show_ma ? fast_ma : na, color = color.new(color.yellow, 0), linewidth = 2, title = '快线')
plot(show_ma ? slow_ma : na, color = color.new(color.blue, 0), linewidth = 2, title = '慢线')
plot(show_accel ? smooth_accel : na, color = smooth_accel > 0 ? color.green : color.red, style = plot.style_histogram, linewidth = 2, title = '加速度', histbase = 0)

hline(0, color = color.new(color.gray, 60), linestyle = hline.style_dashed)

// ============================================================================
//  7. 多周期仪表盘（单标签整合，含详细tooltip）
// ============================================================================
getHigherTimeframes(current) =>
    tfList = array.new_string(0)
    array.push(tfList, '1')
    array.push(tfList, '2')
    array.push(tfList, '3')
    array.push(tfList, '5')
    array.push(tfList, '10')
    array.push(tfList, '15')
    array.push(tfList, '30')
    array.push(tfList, '60')
    array.push(tfList, '120')
    array.push(tfList, '180')
    array.push(tfList, '240')
    array.push(tfList, '360')
    array.push(tfList, '720')
    array.push(tfList, 'D')
    array.push(tfList, '2D')
    array.push(tfList, '3D')
    array.push(tfList, 'W')
    array.push(tfList, '2W')
    array.push(tfList, 'M')
    array.push(tfList, '3M')
    array.push(tfList, '6M')
    array.push(tfList, '12M')
    idx = array.indexof(tfList, current)
    if idx == -1
        array.from('D', 'W', 'M')
    else
        higher = array.new_string()
        for i = 1 to 3 by 1
            j = idx + i
            if j < array.size(tfList)
                array.push(higher, array.get(tfList, j))
        while array.size(higher) < 3
            array.push(higher, array.get(tfList, array.size(tfList) - 1))
        higher

if show_dashboard and barstate.islast
    tfs = getHigherTimeframes(timeframe.period)
    statusTexts = array.new_string()
    bullCount = 0
    for i = 0 to 2 by 1
        tf = array.get(tfs, i)
        htf_fast = request.security(syminfo.tickerid, tf, ta.ema(cvd_norm, fast_len))
        htf_slow = request.security(syminfo.tickerid, tf, ta.ema(cvd_norm, slow_len))
        if not na(htf_fast) and not na(htf_slow)
            isBull = htf_fast > htf_slow
            if isBull
                bullCount := bullCount + 1
                array.push(statusTexts, tf + ' 🟢')
            else
                array.push(statusTexts, tf + ' 🔴')
        else
            array.push(statusTexts, tf + ' ⚪')

    // 初始化建议字符串
    advice = ''
    if bullCount == 3
        advice := '全绿：重仓做多，顺势而为'
        advice
    else if bullCount == 2
        advice := '两绿一红：轻仓操作，顺大周期方向（注意红色周期压力）'
        advice
    else if bullCount == 1
        advice := '一绿两红：谨慎轻仓，建议观望或顺唯一多头周期'
        advice
    else
        advice := '全红：空仓观望，等待趋势明朗'
        advice

    // 结合当前背景微调（已声明advice）
    if trend_up and bullCount >= 2
        advice := advice + '，当前背景多头，可积极'
        advice
    if not trend_up and bullCount <= 1
        advice := advice + '，当前背景空头，继续观望'
        advice

    // 构建显示文本
    labelText = '📊 多周期仪表盘\n'
    for i = 0 to 2 by 1
        labelText := labelText + array.get(statusTexts, i) + '  '
        labelText
    labelText := labelText + '\n' + advice

    // 构建tooltip
    tooltipText = '🔍 各周期状态详解：\n'
    for i = 0 to 2 by 1
        tooltipText := tooltipText + array.get(statusTexts, i) + '\n'
        tooltipText
    tooltipText := tooltipText + '\n📌 操作建议：\n' + advice
    tooltipText := tooltipText + '\n\n⚠️ 风险提示：\n• 信号滞后，需结合K线形态\n• 严格止损，避免重仓逆势'

    xPos = bar_index + 15
    yPos = high * 1.02
    label.new(x = xPos, y = yPos, text = 'CVD', color = color.new(color.black, 70), style = label.style_label_left, textcolor = color.white, size = size.normal, tooltip = tooltipText, force_overlay = true)

// ============================================================================
//  8. 预警条件（仅新信号触发）
// ============================================================================
alertcondition(new_attack, title = '高确定性进攻', message = '主动进攻信号')
alertcondition(new_accum, title = '高确定性吸筹', message = '吸筹信号')
alertcondition(new_dist, title = '高确定性派发', message = '派发信号')
alertcondition(new_absorb, title = '区间吸收（换手）', message = '主力在横盘区间内持续吸筹')
alertcondition(new_bull_div, title = '底背离', message = '价格新低但CVD未新低')
alertcondition(new_bear_div, title = '顶背离', message = '价格新高但CVD未新高')
alertcondition(new_fading, title = '进攻减速', message = '进攻信号出现但推力衰减，注意回调风险')
alertcondition(churn, title = '对倒预警', message = '价格急涨但CVD未跟进，疑似对倒诱多')
````
