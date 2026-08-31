<!-- tradingview-pine-id: PUB;7d292b4804f14c6589a50fc58f4feb89 -->
<!-- tradingviewscripts-format: 1 -->
# Ang MTF Clouds + BarCount v2

Source: https://www.tradingview.com/script/jNv0nrNR-Ang-MTF-Clouds-BarCount-v2/

## Description

Merges Ripster's EMA Clouds and MTF Clouds into one workspace and adds the execution layer around them: five higher-timeframe clouds (daily + hourly), five clouds on the chart timeframe, opening-range breakout, premarket high/low, a 10:00 ET marker, bar counting from the open, auto-spaced cloud labels, and a Chop/Trend verdict panel.

The panel is the reason this exists. Cloud systems are trend-day tools that get chopped up in ranges, so the first question is whether the day is tradeable at all — price trapped inside the premarket range with no 10:00 breakout is a "size down" day regardless of what color the clouds are.

Entries at cloud rejections/reclaims, stops at the cloud edge, targets at the next cloud (MTF magnet). Designed for SPY on a 10-minute chart.

Note: higher-timeframe clouds repaint intraday (standard request.security behavior), so replay-based backtests will overstate performance. Cloud concept © @ripster47, MPL 2.0.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original Ripster cloud concept © ripster47
//
// v2 (2026-08-06) 相对 v1 的改动：
//   [修] Show EMA Cloud 开关全部接线（v1 里 ema2/ema3 声明后从未使用，勾了没反应）
//   [修] Resolution 输入接线（v1 硬编码 "D"/"60"，res/res1 是死输入）
//   [修] 删除死变量 showlong / showshort / orb_open
//   [保留] 用户调试过的默认值全部不动：D 50/55、D 21/24、1H 34/50、1H 5/12
//   [新] 增加 Daily 34/50 云槽位，**默认关闭**。曾误判为作者改动，核查后不成立：
//        7/04 官方 MTF Scanner = 1H + D20/21 + D50/55；7/09、7/21 回复与实盘计划仍用 50/55；
//        8/04 那条本身开头就是 "Its still same steps"。34/50 是他多给的一组，不是替换。
//   [修] ORB 改为按分钟数计算并回报实际覆盖窗口（v1 在 10m 图上实为 09:30-09:50 而非 15 分钟）
//   [修] ORB 高低轨只在当日常规交易时段绘制（v1 会拖到隔夜和次日开盘）
//   [新] 本地云补齐到官方 Ripster EMA Clouds 的五组：**8/9(默认开，回踩层)**、5/12、34/50、
//        72/89(默认关)、180/200(默认关)。v1 只有 5/12 和 34/50，漏了官方默认开着的 8/9。
//        本地云长度全部改为可配置输入（官方本来就是输入项），默认值不变。
//   [新] Draw EMA Lines 开关（官方 showLine 默认 false = 只显云不画线；此处默认 true 保持原观感）
//   [新] MA Type 开关 EMA/SMA（官方 f_ma 的等价实现），只作用于本地云，默认 EMA
//   [新] Chop/Trend 判定面板：盘前枢轴 + 34/50 云 + 5/12 云 + 10 AM 开盘区间突破
//   [新] 10:00 ET 竖线标记（10 AM Trend Time）
//   [修] 所有 input title 改为全局唯一（原先多个 group 里有同名 title）
//   [修] f_col 改为块状函数体（Pine 续行缩进不能是 4 的倍数，原写法报 CE10156）
//   [修] HTF 云的 fill 复用可见 plot 的 id，不再内联隐藏 plot ——
//        plot 配额从 70 降到 50（上限 64；plot() 每个占 2 配额，plotshape 占 1）
//
//@version=6
indicator("Ang MTF Clouds + BarCount v2", shorttitle="Ang MTF v2", overlay=true, max_labels_count=500, max_lines_count=100)

// ===================== 基础参数 =====================
src              = input.source(hl2, title="Source")
ma_offset        = input.int(0, title="Offset")
emacloudleading  = input.int(0, title="Leading Period For EMA Cloud")

tf_daily  = input.timeframe("D",  title="HTF Resolution A (慢云)",  group="Resolutions")
tf_hourly = input.timeframe("60", title="HTF Resolution B (快云)",  group="Resolutions")

// ===================== HTF 云开关与参数 =====================
// 参数版本对照：
//   海报（Tenet MTF Setup）        = D 50/55 + D 20/21 + 1H 34/50
//   @ripster47 2026-08-04 推文     = 1H 34/50 + D 34/50 + D 20/21   （不是改动，见下）
//   本机 v1（用户自行调试）        = D 50/55 + D 21/24 + 1H 34/50 + 1H 5/12
//
// 已核查（2026-08-06 实拉官方源码）：官方 Ripster MTF Clouds 仍是 //@version=5、52 行、
// 发布于 2024-07-04 后从未更新，默认 D 50/55 + D 20/21。8/4 那条推文不是改参数。
// 本文件取向：**用户调试过的默认值一律保留**（50/55、21/24、34/50、5/12 不动）。
// 想切回官方配置：关掉 Cloud 1，把 Cloud 2 改成 20/21。
grp1 = "Cloud 1 - HTF A 50/55 (v1 调试值; 作者 2026-08 已弃用此组)"
show_c1 = input.bool(true, title="Show Cloud 1", group=grp1)
c1_s    = input.int(50, title="C1 Short Length", group=grp1)
c1_l    = input.int(55, title="C1 Long Length",  group=grp1)

grp2 = "Cloud 2 - HTF A 21/24 (v1 调试值; 官方为 20/21)"
show_c2 = input.bool(true, title="Show Cloud 2", group=grp2)
c2_s    = input.int(21, title="C2 Short Length", group=grp2, tooltip="保留 v1 调试值 21/24。官方海报与推文均为 20/21")
c2_l    = input.int(24, title="C2 Long Length",  group=grp2)

grp3 = "Cloud 3 - HTF A 34/50 (可选, 默认关)"
show_c3 = input.bool(false, title="Show Cloud 3", group=grp3, tooltip="@ripster47 2026-08-04 提过 daily 34/50，但他 7 月的官方 Scanner、教学回复和实盘计划仍在用 daily 50/55，那条推文本身开头也是 'still same steps'。故判定为『他多给的一组』而非替换，默认关闭。他对 34/50 唯一的说法是 2026-07-10 的 'No but 34 50 is bigger pivot'")
c3_s    = input.int(34, title="C3 Short Length", group=grp3)
c3_l    = input.int(50, title="C3 Long Length",  group=grp3)

grp4 = "Cloud 4 - HTF B 34/50"
show_c4 = input.bool(true, title="Show Cloud 4", group=grp4)
c4_s    = input.int(34, title="C4 Short Length", group=grp4)
c4_l    = input.int(50, title="C4 Long Length",  group=grp4)

grp5 = "Cloud 5 - HTF B 5/12"
show_c5 = input.bool(true, title="Show Cloud 5", group=grp5)
c5_s    = input.int(5,  title="C5 Short Length", group=grp5)
c5_l    = input.int(12, title="C5 Long Length",  group=grp5)

// 图表当前周期的本地云（触发层，设计上在 10 分钟图看）
// 与官方 Ripster EMA Clouds（//@version=4）的五组本地云对齐：
//   EMA1 8/9(开)、EMA2 5/12(开)、EMA3 34/50(开)、EMA4 72/89(关)、EMA5 180/200(关)
// v1 只有 5/12 和 34/50，缺了默认开着的 8/9（Ripster: "8-9 EMA Clouds can be used as pullback Levels"）
grpL = "Local Clouds (图表当前周期)"
matype = input.string("EMA", title="MA Type", options=["EMA","SMA"], group=grpL, tooltip="官方 Ripster EMA Clouds 的 MA Type 开关，只作用于本地云。HTF 云保持 EMA —— 官方 MTF Clouds 没有这个选项，是 EMA 写死的。默认 EMA，日常不用动")
show_local_lines = input.bool(true, title="Draw EMA Lines", group=grpL, tooltip="官方默认 false（只显示云不画线，图更干净）。这里默认 true 以保持原有观感")
show_l1 = input.bool(true,  title="Show Local 8/9 (回踩层)", group=grpL, tooltip="官方 EMA Clouds 的 EMA1，默认开。位于 5/12 触发层与 34/50 结构层之间，用作回踩位")
l1_s    = input.int(8,  title="8/9 Short",  group=grpL)
l1_l    = input.int(9,  title="8/9 Long",   group=grpL)
show_l2 = input.bool(true, title="Show Local 5/12",  group=grpL)
l2_s    = input.int(5,  title="5/12 Short", group=grpL)
l2_l    = input.int(12, title="5/12 Long",  group=grpL)
show_l3 = input.bool(true, title="Show Local 34/50", group=grpL, tooltip="在 1H 图上会与 Cloud 4/5 重合，属冗余")
l3_s    = input.int(34, title="34/50 Short", group=grpL)
l3_l    = input.int(50, title="34/50 Long",  group=grpL)
show_l4 = input.bool(false, title="Show Local 72/89",   group=grpL, tooltip="官方 EMA4，默认关")
l4_s    = input.int(72, title="72/89 Short", group=grpL)
l4_l    = input.int(89, title="72/89 Long",  group=grpL)
show_l5 = input.bool(false, title="Show Local 180/200", group=grpL, tooltip="官方 EMA5，默认关")
l5_s    = input.int(180, title="180/200 Short", group=grpL)
l5_l    = input.int(200, title="180/200 Long",  group=grpL)

// ===================== 云标签 =====================
show_labels        = input.bool(true, title="Show Cloud Labels", group="Cloud Labels")
label_offset_bars  = input.int(5, title="Label Offset (bars to the right)", minval=0, maxval=50, group="Cloud Labels")
label_size_opt     = input.string("small", title="Label Size", options=["tiny","small","normal","large"], group="Cloud Labels")
label_min_gap_pct  = input.float(0.25, title="Min Vertical Gap (% of price)", minval=0.0, maxval=10.0, step=0.05, group="Cloud Labels", tooltip="刚好够不重叠即可，默认 0.25%")
leader_line_style_opt = input.string("dotted", title="Leader Line Style", options=["solid","dashed","dotted"], group="Cloud Labels")
leader_line_width  = input.int(1, title="Leader Line Width", minval=1, maxval=4, group="Cloud Labels")

// ===================== BarCount =====================
show_barcount   = input.bool(true, title="Show BarCount", group="BarCount")
barcount_size_opt = input.string("Normal", title="BarCount Label Size", options=["Auto","Huge","Large","Normal","Small","Tiny"], group="BarCount")
barcount_color  = input.color(color.orange, title="BarCount Text Color", group="BarCount")
barcount_every  = input.int(2, title="Display at every X bars", minval=1, group="BarCount")
barcount_reset  = input.string("US Open", title="Reset Period", options=["US Open","Day","Week","Session","None"], group="BarCount")

// ===================== 时区 / 交易时段 =====================
tz_str = input.string("America/New_York", title="Session Timezone", options=["America/New_York", "Asia/Shanghai", "Etc/UTC"], group="Sessions")
rth_session = input.session("0930-1600", title="Regular Session", group="Sessions")
pm_session  = input.session("0400-0930", title="Premarket Session", group="Sessions")

in_rth = not na(time(timeframe.period, rth_session, tz_str))
in_pm  = not na(time(timeframe.period, pm_session,  tz_str))
intraday = timeframe.isintraday

// ===================== ORB（Opening Range Breakout，开盘区间突破） =====================
show_orb        = input.bool(true, title="Show ORB", group="ORB")
orb_minutes     = input.int(15, title="Opening Range (minutes)", minval=1, maxval=120, group="ORB", tooltip="从 09:30 ET 起算。图表周期无法整除时，实际覆盖窗口会显示在标签里")
orb_high_color  = input.color(color.lime, title="ORB High Color", group="ORB")
orb_low_color   = input.color(color.red,  title="ORB Low Color",  group="ORB")
orb_line_width  = input.int(2, title="ORB Line Width", minval=1, maxval=4, group="ORB")
show_orb_breakouts = input.bool(true, title="Show Breakout Signals", group="ORB")

// 用绝对时间戳界定开盘区间，而不是 session 字符串 —— session 字符串在
// 无法整除的周期上会悄悄放大区间（10m 图上 "0930-0945" 实际覆盖 09:30-09:50）
ny_open_ms  = timestamp(tz_str, year(time, tz_str), month(time, tz_str), dayofmonth(time, tz_str), 9, 30)
orb_end_ms  = ny_open_ms + orb_minutes * 60000
in_orb_win  = intraday and time >= ny_open_ms and time < orb_end_ms

var float orb_high = na
var float orb_low  = na
var int   orb_actual_end = na
var bool  orb_ready = false
var bool  orb_broken_up = false
var bool  orb_broken_down = false

orb_win_start = in_orb_win and not in_orb_win[1]
orb_win_end   = intraday and not in_orb_win and in_orb_win[1]

if orb_win_start
    orb_high := high
    orb_low  := low
    orb_actual_end := time_close
    orb_ready := false
    orb_broken_up := false
    orb_broken_down := false
else if in_orb_win
    orb_high := math.max(nz(orb_high, high), high)
    orb_low  := math.min(nz(orb_low,  low),  low)
    orb_actual_end := time_close
else if orb_win_end
    orb_ready := true

orb_breakout_up   = intraday and show_orb and orb_ready and in_rth and not orb_broken_up   and ta.crossover(close, orb_high)
orb_breakout_down = intraday and show_orb and orb_ready and in_rth and not orb_broken_down and ta.crossunder(close, orb_low)

if orb_breakout_up
    orb_broken_up := true
if orb_breakout_down
    orb_broken_down := true

// 只在当日常规时段绘制，避免隔夜拖线
orb_draw = intraday and show_orb and in_rth and not na(orb_high)
plot(orb_draw ? orb_high : na, title="ORB High", color=orb_high_color, linewidth=orb_line_width, style=plot.style_linebr)
plot(orb_draw ? orb_low  : na, title="ORB Low",  color=orb_low_color,  linewidth=orb_line_width, style=plot.style_linebr)
plotshape(show_orb_breakouts and orb_breakout_up,   title="ORB Breakout Up",   style=shape.triangleup,   location=location.belowbar, color=orb_high_color, size=size.tiny, text="ORB↑", textcolor=color.white)
plotshape(show_orb_breakouts and orb_breakout_down, title="ORB Breakout Down", style=shape.triangledown, location=location.abovebar, color=orb_low_color,  size=size.tiny, text="ORB↓", textcolor=color.white)

barcount_label_size = barcount_size_opt == "Huge"  ? size.huge :
                      barcount_size_opt == "Large" ? size.large :
                      barcount_size_opt == "Small" ? size.small :
                      barcount_size_opt == "Tiny"  ? size.tiny  :
                      barcount_size_opt == "Auto"  ? size.auto  : size.normal

// ===================== 颜色 =====================
c1_line_col  = input.color(color.rgb(33, 149, 243, 50), title="C1 Line Color",  group=grp1)
c1_cloud_col = input.color(color.new(color.blue, 90),   title="C1 Cloud Color", group=grp1)
c2_line_col  = input.color(color.teal,                  title="C2 Line Color",  group=grp2)
c2_cloud_col = input.color(color.new(#897e00, 90),      title="C2 Cloud Color", group=grp2)
c3_line_col  = input.color(color.rgb(255, 152, 0, 60),  title="C3 Line Color",  group=grp3)
c3_cloud_col = input.color(color.new(color.orange, 90), title="C3 Cloud Color", group=grp3)
c4_line_col  = input.color(color.rgb(255, 82, 82, 69),  title="C4 Line Color",  group=grp4)
c4_cloud_col = input.color(color.new(color.red, 90),    title="C4 Cloud Color", group=grp4)
c5_line_col  = input.color(color.rgb(155, 39, 176, 68), title="C5 Line Color",  group=grp5)
c5_cloud_col = input.color(color.new(color.purple, 90), title="C5 Cloud Color", group=grp5)

gL2 = "Color Settings - Local 5/12"
lead2_short_up   = input.color(color.rgb(128, 128, 0, 73),  title="L5/12 Short Line Up",   group=gL2)
lead2_short_down = input.color(color.rgb(136, 14, 79, 68),  title="L5/12 Short Line Down", group=gL2)
lead2_long_up    = input.color(color.rgb(76, 175, 79, 62),  title="L5/12 Long Line Up",    group=gL2)
lead2_long_down  = input.color(color.rgb(255, 82, 82, 73),  title="L5/12 Long Line Down",  group=gL2)
lead2_bull       = input.color(#4caf4f21, title="L5/12 Bullish Cloud", group=gL2)
lead2_bear       = input.color(#f4433642, title="L5/12 Bearish Cloud", group=gL2)
lead2_transp     = input.int(65, title="L5/12 Cloud Transparency (0-100)", minval=0, maxval=100, group=gL2)

gL3 = "Color Settings - Local 34/50"
lead3_short_up   = input.color(color.rgb(128, 128, 0, 70),  title="L34/50 Short Line Up",   group=gL3)
lead3_short_down = input.color(color.rgb(136, 14, 79, 70),  title="L34/50 Short Line Down", group=gL3)
lead3_long_up    = input.color(color.rgb(76, 175, 79, 74),  title="L34/50 Long Line Up",    group=gL3)
lead3_long_down  = input.color(color.rgb(255, 82, 82, 82),  title="L34/50 Long Line Down",  group=gL3)
lead3_bull       = input.color(#2195f342, title="L34/50 Bullish Cloud", group=gL3)
lead3_bear       = input.color(#ffb84d34, title="L34/50 Bearish Cloud", group=gL3)
lead3_transp     = input.int(70, title="L34/50 Cloud Transparency (0-100)", minval=0, maxval=100, group=gL3)

// 以下三组用官方 Ripster EMA Clouds 的原始配色与透明度
gL1 = "Color Settings - Local 8/9"
lead1_bull   = input.color(#036103, title="L8/9 Bullish Cloud", group=gL1)
lead1_bear   = input.color(#880e4f, title="L8/9 Bearish Cloud", group=gL1)
lead1_transp = input.int(45, title="L8/9 Cloud Transparency (0-100)", minval=0, maxval=100, group=gL1)

gL4 = "Color Settings - Local 72/89"
lead4_bull   = input.color(#009688, title="L72/89 Bullish Cloud", group=gL4)
lead4_bear   = input.color(#f06292, title="L72/89 Bearish Cloud", group=gL4)
lead4_transp = input.int(65, title="L72/89 Cloud Transparency (0-100)", minval=0, maxval=100, group=gL4)

gL5 = "Color Settings - Local 180/200"
lead5_bull   = input.color(#05bed5, title="L180/200 Bullish Cloud", group=gL5)
lead5_bear   = input.color(#e65100, title="L180/200 Bearish Cloud", group=gL5)
lead5_transp = input.int(65, title="L180/200 Cloud Transparency (0-100)", minval=0, maxval=100, group=gL5)

// ===================== EMA 计算 =====================
htf_c1s = request.security(syminfo.tickerid, tf_daily,  ta.ema(src, c1_s))
htf_c1l = request.security(syminfo.tickerid, tf_daily,  ta.ema(src, c1_l))
htf_c2s = request.security(syminfo.tickerid, tf_daily,  ta.ema(src, c2_s))
htf_c2l = request.security(syminfo.tickerid, tf_daily,  ta.ema(src, c2_l))
htf_c3s = request.security(syminfo.tickerid, tf_daily,  ta.ema(src, c3_s))
htf_c3l = request.security(syminfo.tickerid, tf_daily,  ta.ema(src, c3_l))
htf_c4s = request.security(syminfo.tickerid, tf_hourly, ta.ema(src, c4_s))
htf_c4l = request.security(syminfo.tickerid, tf_hourly, ta.ema(src, c4_l))
htf_c5s = request.security(syminfo.tickerid, tf_hourly, ta.ema(src, c5_s))
htf_c5l = request.security(syminfo.tickerid, tf_hourly, ta.ema(src, c5_l))

// 开关接线：隐藏时置 na，线和填充一并消失
p_c1s = show_c1 ? htf_c1s : na
p_c1l = show_c1 ? htf_c1l : na
p_c2s = show_c2 ? htf_c2s : na
p_c2l = show_c2 ? htf_c2l : na
p_c3s = show_c3 ? htf_c3s : na
p_c3l = show_c3 ? htf_c3l : na
p_c4s = show_c4 ? htf_c4s : na
p_c4l = show_c4 ? htf_c4l : na
p_c5s = show_c5 ? htf_c5s : na
p_c5l = show_c5 ? htf_c5l : na

// 本地云（图表当前周期）
// 官方 f_ma 的等价实现。⚠️ 两条都算完再选，不要写成 matype=="SMA" ? ta.sma(..) : ta.ema(..) ——
// ta.* 放在三元里只有被选中的分支每根 K 线求值，另一条的内部状态会断，结果不可靠。
f_ma(int len) =>
    e = ta.ema(src, len)
    s = ta.sma(src, len)
    matype == "SMA" ? s : e

loc_1s  = f_ma(l1_s)
loc_1l  = f_ma(l1_l)
loc_5   = f_ma(l2_s)
loc_12  = f_ma(l2_l)
loc_34  = f_ma(l3_s)
loc_50  = f_ma(l3_l)
loc_4s  = f_ma(l4_s)
loc_4l  = f_ma(l4_l)
loc_5s  = f_ma(l5_s)
loc_5l  = f_ma(l5_l)

mashort1 = show_l1 ? loc_1s : na
malong1  = show_l1 ? loc_1l : na
mashort2 = show_l2 ? loc_5  : na
malong2  = show_l2 ? loc_12 : na
mashort3 = show_l3 ? loc_34 : na
malong3  = show_l3 ? loc_50 : na
mashort4 = show_l4 ? loc_4s : na
malong4  = show_l4 ? loc_4l : na
mashort5 = show_l5 ? loc_5s : na
malong5  = show_l5 ? loc_5l : na

// 线色沿用官方规则：短线 short>=short[1] ? olive : maroon，长线 long>=long[1] ? green : red
mashortcolor1 = loc_1s >= loc_1s[1] ? color.olive : color.maroon
malongcolor1  = loc_1l >= loc_1l[1] ? color.green : color.red
ecloudcolour1 = loc_1s >= loc_1l    ? lead1_bull  : lead1_bear

mashortcolor2 = loc_5  >= loc_5[1]  ? lead2_short_up : lead2_short_down
malongcolor2  = loc_12 >= loc_12[1] ? lead2_long_up  : lead2_long_down
ecloudcolour2 = loc_5  >= loc_12    ? lead2_bull     : lead2_bear

mashortcolor3 = loc_34 >= loc_34[1] ? lead3_short_up : lead3_short_down
malongcolor3  = loc_50 >= loc_50[1] ? lead3_long_up  : lead3_long_down
ecloudcolour3 = loc_34 >= loc_50    ? lead3_bull     : lead3_bear

mashortcolor4 = loc_4s >= loc_4s[1] ? color.olive : color.maroon
malongcolor4  = loc_4l >= loc_4l[1] ? color.green : color.red
ecloudcolour4 = loc_4s >= loc_4l    ? lead4_bull  : lead4_bear

mashortcolor5 = loc_5s >= loc_5s[1] ? color.olive : color.maroon
malongcolor5  = loc_5l >= loc_5l[1] ? color.green : color.red
ecloudcolour5 = loc_5s >= loc_5l    ? lead5_bull  : lead5_bear

// ===================== 绘图 =====================
// ⚠️ plot 配额：TradingView 上限 64，且 **plot() 每个占 2 个配额**（plotshape 占 1）。
// 官方 MTF Clouds 的写法是 fill(plot(...display=display.none), plot(...display=display.none))，
// 即每片云画 4 个 plot（2 条可见线 + 2 条隐藏线）—— 5 片云就是 20 个 plot = 40 配额。
// 这里改成把可见 plot 的 id 存下来直接喂给 fill，每片云只要 2 个 plot。省下 10 个 plot / 20 配额。
pl_c1s = plot(p_c1s, color=c1_line_col, offset=ma_offset, linewidth=1, title="C1 Short")
pl_c1l = plot(p_c1l, color=c1_line_col, offset=ma_offset, linewidth=1, title="C1 Long")
pl_c2s = plot(p_c2s, color=c2_line_col, offset=ma_offset, linewidth=1, title="C2 Short")
pl_c2l = plot(p_c2l, color=c2_line_col, offset=ma_offset, linewidth=1, title="C2 Long")
pl_c3s = plot(p_c3s, color=c3_line_col, offset=ma_offset, linewidth=1, title="C3 Short")
pl_c3l = plot(p_c3l, color=c3_line_col, offset=ma_offset, linewidth=1, title="C3 Long")
pl_c4s = plot(p_c4s, color=c4_line_col, offset=ma_offset, linewidth=1, title="C4 Short")
pl_c4l = plot(p_c4l, color=c4_line_col, offset=ma_offset, linewidth=1, title="C4 Long")
pl_c5s = plot(p_c5s, color=c5_line_col, offset=ma_offset, linewidth=1, title="C5 Short")
pl_c5l = plot(p_c5l, color=c5_line_col, offset=ma_offset, linewidth=1, title="C5 Long")

fill(pl_c1s, pl_c1l, color=c1_cloud_col, title="Cloud 1")
fill(pl_c2s, pl_c2l, color=c2_cloud_col, title="Cloud 2")
fill(pl_c3s, pl_c3l, color=c3_cloud_col, title="Cloud 3")
fill(pl_c4s, pl_c4l, color=c4_cloud_col, title="Cloud 4")
fill(pl_c5s, pl_c5l, color=c5_cloud_col, title="Cloud 5")

// show_local_lines=false 时线隐藏但云仍在（官方 showLine 的做法：把线色设为 na）
mashortline1 = plot(mashort1, color=show_local_lines ? mashortcolor1 : na, linewidth=1, offset=emacloudleading, title="Local 8")
malongline1  = plot(malong1,  color=show_local_lines ? malongcolor1  : na, linewidth=3, offset=emacloudleading, title="Local 9")
mashortline2 = plot(mashort2, color=show_local_lines ? mashortcolor2 : na, linewidth=1, offset=emacloudleading, title="Local 5")
malongline2  = plot(malong2,  color=show_local_lines ? malongcolor2  : na, linewidth=3, offset=emacloudleading, title="Local 12")
mashortline3 = plot(mashort3, color=show_local_lines ? mashortcolor3 : na, linewidth=1, offset=emacloudleading, title="Local 34")
malongline3  = plot(malong3,  color=show_local_lines ? malongcolor3  : na, linewidth=3, offset=emacloudleading, title="Local 50")
mashortline4 = plot(mashort4, color=show_local_lines ? mashortcolor4 : na, linewidth=1, offset=emacloudleading, title="Local 72")
malongline4  = plot(malong4,  color=show_local_lines ? malongcolor4  : na, linewidth=3, offset=emacloudleading, title="Local 89")
mashortline5 = plot(mashort5, color=show_local_lines ? mashortcolor5 : na, linewidth=1, offset=emacloudleading, title="Local 180")
malongline5  = plot(malong5,  color=show_local_lines ? malongcolor5  : na, linewidth=3, offset=emacloudleading, title="Local 200")

fill(mashortline1, malongline1, color=color.new(ecloudcolour1, lead1_transp), title="Local Cloud 8/9")
fill(mashortline2, malongline2, color=color.new(ecloudcolour2, lead2_transp), title="Local Cloud 5/12")
fill(mashortline3, malongline3, color=color.new(ecloudcolour3, lead3_transp), title="Local Cloud 34/50")
fill(mashortline4, malongline4, color=color.new(ecloudcolour4, lead4_transp), title="Local Cloud 72/89")
fill(mashortline5, malongline5, color=color.new(ecloudcolour5, lead5_transp), title="Local Cloud 180/200")

// ===================== 云标签：防重叠 + 牵引线 =====================
f_lsize(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : size.large

f_lstyle(s) =>
    s == "solid" ? line.style_solid : s == "dashed" ? line.style_dashed : line.style_dotted

var array<label> cloud_lbls = array.new<label>()
var array<line>  cloud_lns  = array.new<line>()

if barstate.islast
    while array.size(cloud_lbls) > 0
        label.delete(array.pop(cloud_lbls))
    while array.size(cloud_lns) > 0
        line.delete(array.pop(cloud_lns))

if show_labels and barstate.islast
    lsize  = f_lsize(label_size_opt)
    lstyle = f_lstyle(leader_line_style_opt)
    lbar   = bar_index + label_offset_bars

    // 只收集可见的云
    prices = array.new<float>()
    texts  = array.new<string>()
    cols   = array.new<color>()

    if show_c1
        array.push(prices, (htf_c1s + htf_c1l) / 2)
        array.push(texts,  str.format("{0} {1}/{2}", tf_daily, c1_s, c1_l))
        array.push(cols,   color.new(color.blue, 30))
    if show_c2
        array.push(prices, (htf_c2s + htf_c2l) / 2)
        array.push(texts,  str.format("{0} {1}/{2}", tf_daily, c2_s, c2_l))
        array.push(cols,   color.new(color.teal, 30))
    if show_c3
        array.push(prices, (htf_c3s + htf_c3l) / 2)
        array.push(texts,  str.format("{0} {1}/{2}", tf_daily, c3_s, c3_l))
        array.push(cols,   color.new(color.orange, 30))
    if show_c4
        array.push(prices, (htf_c4s + htf_c4l) / 2)
        array.push(texts,  str.format("{0}m {1}/{2}", tf_hourly, c4_s, c4_l))
        array.push(cols,   color.new(color.red, 30))
    if show_c5
        array.push(prices, (htf_c5s + htf_c5l) / 2)
        array.push(texts,  str.format("{0}m {1}/{2}", tf_hourly, c5_s, c5_l))
        array.push(cols,   color.new(color.purple, 30))

    n = array.size(prices)
    if n > 0
        // 按价格排序取索引
        idx = array.new<int>()
        for i = 0 to n - 1
            array.push(idx, i)
        // ⚠️ Pine 的 for 在 to < from 时会倒着数，n=1 时必须跳过排序
        if n > 1
            for i = 0 to n - 2
                for j = 0 to n - 2 - i
                    if array.get(prices, array.get(idx, j)) > array.get(prices, array.get(idx, j + 1))
                        tmp = array.get(idx, j)
                        array.set(idx, j, array.get(idx, j + 1))
                        array.set(idx, j + 1, tmp)

        // 自下而上推开，保证最小垂直间距
        min_gap = close * (label_min_gap_pct / 100.0)
        adj = array.new<float>(n, na)
        prev_y = -1e20
        for k = 0 to n - 1
            ii = array.get(idx, k)
            y  = array.get(prices, ii)
            if y < prev_y + min_gap
                y := prev_y + min_gap
            array.set(adj, ii, y)
            prev_y := y

        for i = 0 to n - 1
            py = array.get(prices, i)
            ay = array.get(adj, i)
            cc = array.get(cols, i)
            array.push(cloud_lns,  line.new(bar_index, py, lbar, ay, color=color.new(cc, 40), style=lstyle, width=leader_line_width))
            array.push(cloud_lbls, label.new(lbar, ay, array.get(texts, i), color=cc, textcolor=color.white, style=label.style_label_left, size=lsize))

// ===================== Chop / Trend 判定面板 =====================
// 依据 ripstereducation.com "Chop vs Trend" + Ripster Trend Labels：
//   Price Action 列 = 价格 vs 盘前枢轴；显示 Chop 时应降低仓位（chop 优先级高于云信号）
grpT = "Chop / Trend Panel"
show_panel   = input.bool(true, title="Show Chop/Trend Panel", group=grpT)
panel_pos    = input.string("top_right", title="Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grpT)
show_pm_lines = input.bool(true, title="Draw Premarket High/Low", group=grpT)
show_10am    = input.bool(true, title="Mark 10:00 ET (Trend Time)", group=grpT)

// --- 盘前高低（PM High / PM Low）
var float pm_high = na
var float pm_low  = na
pm_start = intraday and in_pm and not in_pm[1]
if pm_start
    pm_high := high
    pm_low  := low
else if intraday and in_pm
    pm_high := math.max(nz(pm_high, high), high)
    pm_low  := math.min(nz(pm_low,  low),  low)

pm_draw = intraday and show_pm_lines and in_rth and not na(pm_high)
plot(pm_draw ? pm_high : na, title="PM High", color=color.new(color.aqua, 30), style=plot.style_linebr, linewidth=1)
plot(pm_draw ? pm_low  : na, title="PM Low",  color=color.new(color.fuchsia, 30), style=plot.style_linebr, linewidth=1)

// --- 昨日高低（PDH / PDL）
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

// --- 开盘 30 分钟区间 + 10 AM 概念
or30_end_ms = ny_open_ms + 30 * 60000
in_or30 = intraday and time >= ny_open_ms and time < or30_end_ms
after_10am = intraday and in_rth and time >= or30_end_ms

var float or30_high = na
var float or30_low  = na
or30_start = in_or30 and not in_or30[1]
if or30_start
    or30_high := high
    or30_low  := low
else if in_or30
    or30_high := math.max(nz(or30_high, high), high)
    or30_low  := math.min(nz(or30_low,  low),  low)

is_10am_bar = intraday and time >= or30_end_ms and (na(time[1]) or time[1] < or30_end_ms)
if show_10am and is_10am_bar
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(color.gray, 55), style=line.style_dashed, width=1)

// --- 三列状态
pa_state = na(pm_high) or na(pm_low) ? "n/a" :
           close > pm_high ? "Bullish" :
           close < pm_low  ? "Bearish" : "CHOP"

c3450_state = loc_34 >= loc_50 ? "Bullish" : "Bearish"
c512_state  = loc_5  >= loc_12 ? "Bullish" : "Bearish"

pd_state = na(pdh) or na(pdl) ? "n/a" :
           close > pdh ? "Over PDH" :
           close < pdl ? "Under PDL" : "Inside"

tenam_state = not after_10am ? "before 10AM" :
              na(or30_high) ? "n/a" :
              close > or30_high ? "TREND UP" :
              close < or30_low  ? "TREND DN" : "CHOP"

// ⚠️ 写成块状函数体，不要用单行 `=>` 加多行三元 —— Pine 的续行缩进不能是 4 的倍数，
// 那样写会被解析成新的语句块，报 "end of line without line continuation" (CE10156)
f_col(string s) =>
    c = color.new(color.gray, 40)
    if s == "Bullish" or s == "Over PDH" or s == "TREND UP"
        c := color.new(color.green, 20)
    else if s == "Bearish" or s == "Under PDL" or s == "TREND DN"
        c := color.new(color.red, 20)
    else if s == "CHOP" or s == "Inside"
        c := color.new(color.orange, 20)
    c

// table.new 的 position 要求 simple string。input.string 本身满足，
// 但经过自定义函数返回会被降级成 series，所以这里内联三元而不是包成函数。
var table tt = table.new(panel_pos == "top_left" ? position.top_left :
                         panel_pos == "bottom_right" ? position.bottom_right :
                         panel_pos == "bottom_left" ? position.bottom_left :
                         panel_pos == "middle_right" ? position.middle_right : position.top_right,
                         2, 6, border_width=1)

if show_panel and barstate.islast and intraday
    // 三列全同色 = 高胜率单；Price Action 显示 CHOP 时减仓
    bull_all = pa_state == "Bullish" and c3450_state == "Bullish" and c512_state == "Bullish"
    bear_all = pa_state == "Bearish" and c3450_state == "Bearish" and c512_state == "Bearish"
    verdict  = bull_all ? "HIGH PROB LONG" : bear_all ? "HIGH PROB SHORT" : pa_state == "CHOP" ? "CHOP - size down" : "MIXED - wait"
    vcol     = bull_all ? color.new(color.green, 10) : bear_all ? color.new(color.red, 10) : color.new(color.orange, 25)

    table.cell(tt, 0, 0, "Price Action (PM)", bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(tt, 1, 0, pa_state, bgcolor=f_col(pa_state), text_color=color.white, text_size=size.small)
    table.cell(tt, 0, 1, "Cloud 34/50", bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(tt, 1, 1, c3450_state, bgcolor=f_col(c3450_state), text_color=color.white, text_size=size.small)
    table.cell(tt, 0, 2, "Cloud 5/12", bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(tt, 1, 2, c512_state, bgcolor=f_col(c512_state), text_color=color.white, text_size=size.small)
    table.cell(tt, 0, 3, "vs Yesterday", bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(tt, 1, 3, pd_state, bgcolor=f_col(pd_state), text_color=color.white, text_size=size.small)
    table.cell(tt, 0, 4, "10AM Trend Time", bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(tt, 1, 4, tenam_state, bgcolor=f_col(tenam_state), text_color=color.white, text_size=size.small)
    table.cell(tt, 0, 5, "Verdict", bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(tt, 1, 5, verdict, bgcolor=vcol, text_color=color.white, text_size=size.small)

// ORB 实际覆盖窗口提示（图表周期无法整除 orb_minutes 时会与设定值不同）
var label orb_note = na
if show_orb and intraday and barstate.islast and not na(orb_actual_end)
    label.delete(orb_note)
    int actual_min = int((orb_actual_end - ny_open_ms) / 60000)
    orb_note := label.new(bar_index, orb_high, str.format("ORB {0}m 设定 → 实际 {1}m", orb_minutes, actual_min), style=label.style_label_down, color=color.new(color.gray, 30), textcolor=color.white, size=size.tiny)

// ===================== BarCount =====================
is_new_period() =>
    us_open = time >= ny_open_ms and (na(time[1]) or time[1] < ny_open_ms)
    barcount_reset == "US Open" ? us_open :
     barcount_reset == "Day"     ? (na(dayofweek[1])  or dayofweek  != dayofweek[1]) :
     barcount_reset == "Week"    ? (na(weekofyear[1]) or weekofyear != weekofyear[1]) :
     barcount_reset == "Session" ? session.isfirstbar :
     false

var int bcount = 1
if is_new_period()
    bcount := 1
else
    bcount := bcount + 1

if show_barcount and (bcount % barcount_every == 0)
    label.new(bar_index, 0, text=str.tostring(bcount), style=label.style_none, yloc=yloc.belowbar, textcolor=barcount_color, size=barcount_label_size)
````
