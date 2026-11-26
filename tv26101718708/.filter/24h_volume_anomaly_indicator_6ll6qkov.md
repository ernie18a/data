# 24H Volume Anomaly Indicator

- url: https://www.tradingview.com/script/6LL6QkOV/
- type: indicator
- pine_id: PUB;4afa822a06a64b619281380ec10d0aa7
- version: 1.0

## Description

检测任意K线周期下的24小时累计成交量异动，对放量K线染色并支持自定义均线/颜色/警报。

注意：只适合加密市场

【1】24小时累计成交量
   自动适配当前K线周期，将成交量聚合为24小时累计值，
   适合发现不同时段间的资金活跃度变化。

【2】异动检测与K线染色
   以历史N根K的24H成交量均线为基准，
   当当前24H成交量超过「均线 × 倍数阈值」时，
   对当前K线进行半透明染色：
   - 阳线（收涨）：红色
   - 阴线（收跌）：绿色

【3】可调均线系统
   支持 EMA / SMA / WMA 三种均线类型，
   均线周期（默认90根K）和倍数阈值均可自定义。

【4】 副图可视化
   - 24H成交量柱（异动时变色，非异动时为默认灰色）
   - 均线参考线（叠加于成交量柱上方）

【5】预警功能
   异动触发时可通过 TradingView 警报系统推送通知。

━━━━ 参数说明 ━━━━

均线设置
  · 均线周期：计算均线的K线根数（默认90）
  · 均线类型：EMA / SMA / WMA

异动检测
  · 异动倍数阈值：当前量 > 均线 × 倍数（默认1.0）

颜色设置
  · 放量阳K颜色、阴K颜色、均线颜色、成交量柱颜色均可自定义

副图显示
  · 显示/隐藏成交量柱和均线参考线

━━━━ 注意事项 ━━━━

本指标使用 request.security() 获取多时间周期数据，
创建警报时会提示"计算基于重绘指标"，属正常现象，勾选确认即可。

## Source Code

````pine
// +------------------------------------------------------------------+
// |  24H成交量异动指标                                                |
// |  24H Volume Spike Indicator - Pine Script v6                      |
// |  作者：寇豆码 | QA：严过关                                        |
// +------------------------------------------------------------------+
// |  功能说明：                                                       |
// |  1. 计算任意K线周期下的24小时累计成交量                           |
// |  2. 基于历史90根K的24H成交量计算均线（EMA/SMA/WMA）              |
// |  3. 当前24H成交量超过均线×倍数阈值时，对K线染色                  |
// |     - 阳K（收涨）：红色半透明                                     |
// |     - 阴K（收跌）：绿色半透明                                     |
// |  4. 副图显示24H成交量柱和均线参考线                               |
// +------------------------------------------------------------------+
// |  ⚠️ 警报说明：                                                    |
// |  本指标使用 request.security() 获取多时间周期数据，               |
// |  TradingView 创建警报时会提示"计算基于重绘指标"，                  |
// |  属正常现象，勾选确认即可正常创建警报。                           |
// +------------------------------------------------------------------+
//@version=6
import PineCoders/getSeries/1 as gs
// +------------------------------------------------------------------+
// |  指标基础设置                                                     |
// +------------------------------------------------------------------+
indicator(
     title       = "24H成交量异动指标",
     shorttitle  = "24H量异动",
     overlay     = false,
     format      = format.volume,
     max_lines_count = 500
     )
// +------------------------------------------------------------------+
// |  用户参数定义                                                     |
// +------------------------------------------------------------------+
// --- 均线参数 ---
ma_period = input.int(
     title     = "均线周期（K线根数）",
     defval    = 90,
     minval    = 2,
     group     = "均线设置",
     tooltip   = "用历史N根K的24H成交量计算均线，不包含当前K"
     )
ma_type = input.string(
     title     = "均线类型",
     defval    = "EMA",
     options   = ["EMA", "SMA", "WMA"],
     group     = "均线设置",
     tooltip   = "EMA=指数移动平均，SMA=简单移动平均，WMA=加权移动平均"
     )
// --- 异动检测 ---
n_times = input.float(
     title     = "异动倍数阈值",
     defval    = 1.0,
     minval    = 0.1,
     step      = 0.1,
     group     = "异动检测",
     tooltip   = "当前24H成交量 > 均线 × 倍数 时触发异动标记"
     )
// --- 颜色设置 ---
bull_color = input.color(
     title     = "放量阳K颜色",
     defval    = color.red,
     group     = "颜色设置",
     tooltip   = "异动且收阳的K线颜色（半透明50%）"
     )
bear_color = input.color(
     title     = "放量阴K颜色",
     defval    = color.green,
     group     = "颜色设置",
     tooltip   = "异动且收阴的K线颜色（半透明50%）"
     )
ma_color = input.color(
     title     = "均线颜色",
     defval    = color.orange,
     group     = "颜色设置",
     tooltip   = "均线参考线的颜色（默认橙色）"
     )
vol_bar_color = input.color(
     title     = "成交量柱颜色",
     defval    = color.gray,
     group     = "颜色设置",
     tooltip   = "非异动时成交量柱的默认颜色"
     )
// --- 副图显示 ---
show_vol_bar = input.bool(
     title     = "显示24H成交量柱",
     defval    = true,
     group     = "副图显示",
     tooltip   = "在副图区域绘制24H成交量柱状图"
     )
show_ma_line = input.bool(
     title     = "显示均线参考线",
     defval    = true,
     group     = "副图显示",
     tooltip   = "在副图区域叠加均线参考线"
     )
// +------------------------------------------------------------------+
// |  24H成交量计算                                                   |
// +------------------------------------------------------------------+
// 根据当前时间框架自动选择聚合周期
sumVolTF = switch
    timeframe.isminutes or timeframe.isseconds => "1"
    timeframe.isdaily                        => "5"
    => "60"
// 使用 PineCoders/getSeries 库计算24H滚动累计成交量
sum24hVol(series float src) =>
    int msIn24h      = 24 * 60 * 60 * 1000
    array<float> arr  = gs.rollOnTimeWhen(src, msIn24h)
    array.sum(arr)
// 当前K的24H累计成交量（用于异动判断）
vol24h_cur = request.security(
     syminfo.tickerid,
     sumVolTF,
     sum24hVol(volume)
     )
// 历史K的24H成交量（用于均线计算，排除当前K）
vol24h_his = request.security(
     syminfo.tickerid,
     sumVolTF,
     sum24hVol(volume[1])
     )
// +------------------------------------------------------------------+
// |  均线计算（基于历史数据，不含当前K）                               |
// +------------------------------------------------------------------+
vol_ma = switch ma_type
    "EMA" => ta.ema(vol24h_his, ma_period)
    "SMA" => ta.sma(vol24h_his, ma_period)
    "WMA" => ta.wma(vol24h_his, ma_period)
// +------------------------------------------------------------------+
// |  异动判断                                                         |
// +------------------------------------------------------------------+
is_spike = vol_ma > 0 and (vol24h_cur > vol_ma * n_times)
is_bull  = close > open
// +------------------------------------------------------------------+
// |  主图K线染色（50%半透明）                                         |
// +------------------------------------------------------------------+
bar_color = is_spike and is_bull  ? color.new(bull_color, 50)
          : is_spike and not is_bull ? color.new(bear_color, 50)
          : na
barcolor(bar_color, title = "24H异动K线染色")
// +------------------------------------------------------------------+
// |  副图：24H成交量柱 + 均线参考线                                   |
// +------------------------------------------------------------------+
// 24H成交量柱（异动时用对应颜色，非异动时自定义颜色）
plot(
     show_vol_bar ? vol24h_cur : na,
     title      = "24H成交量柱",
     color      = is_spike and is_bull  ? bull_color
                : is_spike and not is_bull ? bear_color
                : vol_bar_color,
     style      = plot.style_columns,
     histbase   = 0
     )
// 均线参考线
plot(
     show_ma_line ? vol_ma : na,
     title      = "均线",
     color      = color.new(ma_color, 30),
     linewidth  = 2,
     style      = plot.style_line
     )
// +------------------------------------------------------------------+
// |  警报条件                                                         |
// +------------------------------------------------------------------+
alertcondition(
     is_spike,
     title      = "24H成交量异动预警",
     message    = "【{{ticker}}】24H成交量异动预警：当前成交量已超过均线阈值，请关注。"
     )
````
