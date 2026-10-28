# OSR Market Regime Radar

- url: https://www.tradingview.com/script/RCSEVcFl/
- type: indicator
- pine_id: PUB;1229b47ae41c475c90543747240ca5aa
- version: 2.0

## Description

OSR 开盘结构雷达用于可视化盘前至开盘初段的价格接受区迁移。
它把伦敦盘 LV2、美股盘前 LV1、BOM 和 OR10 叠加在图上，通过重叠度和分散度判断开盘结构是压缩、震荡、扩张，还是方向迁移。
高重叠代表价格接受区集中，开盘更容易震荡、假突破、扫荡回归；低重叠且区间逐步上移/下移，代表价格接受区迁移，开盘更容易出现趋势扩张或 Judas swing 后反转。
面板不直接给买卖点，只提示当前结构状态、关键位行为、VWAP/TWAP形态，以及趋势、反转、扫荡信号的主观加权方向。

## Source Code

````pine
//@version=6
indicator(
     "Opening Structure Radar",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count = 100,
     max_bars_back = 5000,
     dynamic_requests = true
     )

// ============================================================================
// 0. 常量
// ============================================================================
string TZ = "America/New_York"

// ============================================================================
// 1. 数据源设置
// ============================================================================
grp_src = "1. 数据源设置"

sym_range = input.symbol("SPREADEX:SPX", "LV1/LV2/BOM/OR10 区间数据源", group = grp_src)
range_tf  = input.timeframe("1", "区间计算周期：建议 1 分钟", group = grp_src)

hist_lookback = input.int(100, "视觉历史保留天数", minval = 1, maxval = 100, group = grp_src)

use_chart_symbol_for_pdh = input.bool(false, "PDH/PDL 使用当前图表品种", group = grp_src)
sym_pdh_manual = input.symbol("SPREADEX:SPX", "PDH/PDL 手动 RTH 数据源", group = grp_src)
pdh_rth_tf = input.timeframe("5", "PDH/PDL RTH 计算周期", group = grp_src)
rth_session = input.session("0930-1600", "RTH 时段：美东时间", group = grp_src)

sym_pdh_src = use_chart_symbol_for_pdh ? syminfo.tickerid : sym_pdh_manual

// ============================================================================
// 2. 区间视觉设置
// ============================================================================
grp_visual = "2. 区间视觉设置"

show_lvl2_fill = input.bool(true, "显示 LV2 4:00-8:00 填充", group = grp_visual)
show_lvl1_fill = input.bool(true, "显示 LV1 8:00-9:29 填充", group = grp_visual)
show_bom_fill  = input.bool(true, "显示 BOM 9:30-9:35 填充", group = grp_visual)
show_or10_line = input.bool(true, "显示 OR10 9:30-9:40 高低条带", group = grp_visual)
show_pdh_lines = input.bool(true, "显示 PDH / PDL / PDC", group = grp_visual)

color_lvl2 = input.color(color.new(#ffffff, 70), "LV2 填充颜色", group = grp_visual)
color_lvl1 = input.color(color.new(#ffffff, 50), "LV1 填充颜色", group = grp_visual)
color_bom  = input.color(color.new(#d1adad, 70), "BOM 填充颜色", group = grp_visual)

or10_col = input.color(color.new(#d1adad, 0), "OR10 条带颜色", group = grp_visual)
or10_band_atr_mult = input.float(0.02, "OR10 条带厚度：ATR倍数", minval = 0.001, maxval = 0.20, step = 0.001, group = grp_visual)

pdh_col = input.color(color.new(#5cb25c, 0), "PDH 颜色", group = grp_visual)
pdl_col = input.color(color.new(#d66d55, 0), "PDL 颜色", group = grp_visual)
pdc_col = input.color(color.new(#000000, 0), "PDC 颜色", group = grp_visual)

pdh_style_s = input.string("实线", "PDH 线型", options = ["实线", "虚线", "点虚线"], group = grp_visual)
pdl_style_s = input.string("实线", "PDL 线型", options = ["实线", "虚线", "点虚线"], group = grp_visual)
pdc_style_s = input.string("点虚线", "PDC 线型", options = ["实线", "虚线", "点虚线"], group = grp_visual)

draw_start_hour = input.int(4, "PDH/PDL/PDC 绘制开始小时：美东", minval = 0, maxval = 23, group = grp_visual)
draw_start_min  = input.int(0, "PDH/PDL/PDC 绘制开始分钟：美东", minval = 0, maxval = 59, group = grp_visual)
draw_end_hour   = input.int(16, "所有区间延伸结束小时：美东", minval = 0, maxval = 23, group = grp_visual)
draw_end_min    = input.int(0, "所有区间延伸结束分钟：美东", minval = 0, maxval = 59, group = grp_visual)

// ============================================================================
// 3. OSR 结构评分设置
// ============================================================================
grp_osr = "3. OSR 结构评分设置"

env_weight = input.float(0.65, "两两重叠：包络重叠权重", minval = 0.0, maxval = 1.0, step = 0.05, group = grp_osr)
contain_weight = input.float(0.35, "两两重叠：包含接受权重", minval = 0.0, maxval = 1.0, step = 0.05, group = grp_osr)

w_l2_l1    = input.float(0.20, "压缩分权重：LV2 ∩ LV1", minval = 0.0, maxval = 1.0, step = 0.05, group = grp_osr)
w_l1_bom   = input.float(0.25, "压缩分权重：LV1 ∩ BOM", minval = 0.0, maxval = 1.0, step = 0.05, group = grp_osr)
w_l1_or10  = input.float(0.35, "压缩分权重：LV1 ∩ OR10", minval = 0.0, maxval = 1.0, step = 0.05, group = grp_osr)
w_bom_or10 = input.float(0.20, "压缩分权重：BOM ∩ OR10", minval = 0.0, maxval = 1.0, step = 0.05, group = grp_osr)

norm_mode = input.string("混合", "压缩分输出模式", options = ["原始重叠", "历史分位", "混合"], group = grp_osr)
norm_lookback_days = input.int(120, "历史分位回看交易日", minval = 20, maxval = 250, group = grp_osr)
min_hist_days = input.int(20, "启用历史分位所需最少样本", minval = 5, maxval = 120, group = grp_osr)

clear_compression_th = input.float(75.0, "A+ 明确震荡阈值：压缩分 >=", minval = 60.0, maxval = 95.0, step = 1.0, group = grp_osr)
bias_compression_th  = input.float(60.0, "偏震荡阈值：压缩分 >=", minval = 45.0, maxval = 80.0, step = 1.0, group = grp_osr)

clear_expansion_th = input.float(75.0, "A+ 明确扩张阈值：扩张分 >=", minval = 60.0, maxval = 95.0, step = 1.0, group = grp_osr)
bias_expansion_th  = input.float(60.0, "偏扩张阈值：扩张分 >=", minval = 45.0, maxval = 80.0, step = 1.0, group = grp_osr)

clear_direction_th = input.float(35.0, "A+ 扩张方向阈值：方向分绝对值 >=", minval = 15.0, maxval = 80.0, step = 1.0, group = grp_osr)
bias_direction_th  = input.float(20.0, "偏扩张方向阈值：方向分绝对值 >=", minval = 5.0, maxval = 60.0, step = 1.0, group = grp_osr)

narrow_span_prev_pct = input.float(25.0, "窄幅震荡阈值：总包络 / 昨日RTH区间 %", minval = 5.0, maxval = 100.0, step = 1.0, group = grp_osr)
wide_span_prev_pct   = input.float(55.0, "宽幅震荡参考阈值：总包络 / 昨日RTH区间 %", minval = 10.0, maxval = 150.0, step = 1.0, group = grp_osr)

expansion_delta_th = input.float(6.0, "扩张加速/减速阈值", minval = 1.0, maxval = 30.0, step = 1.0, group = grp_osr)

// ============================================================================
// 4. 关键位观察设置：LV1 / BOM / OR10 / PDH / PDL / RTH EMA20 / 整数位
// ============================================================================
grp_key = "4. 关键位观察：不含 LV2"

use_key_factor = input.bool(true, "启用关键位观察，仅作为加权，不作为硬结论", group = grp_key)

boundary_near_atr_mult = input.float(0.20, "靠近 PDH/PDL 阈值：ATR 倍数", minval = 0.01, maxval = 2.0, step = 0.01, group = grp_key)
boundary_near_prev_range_pct = input.float(5.0, "靠近 PDH/PDL 阈值：昨日区间百分比", minval = 0.5, maxval = 30.0, step = 0.5, group = grp_key)

use_lvl1_key = input.bool(true, "关键位：LV1 上下沿", group = grp_key)
use_bom_key  = input.bool(true, "关键位：BOM 上下沿", group = grp_key)
use_or10_key = input.bool(true, "关键位：OR10 上下沿", group = grp_key)
use_pdh_key  = input.bool(true, "关键位：PDH / PDL", group = grp_key)
use_ema_key  = input.bool(true, "关键位：RTH 5m EMA20", group = grp_key)
use_round_key = input.bool(true, "关键位：百点整数位", group = grp_key)

key_ema_tf   = input.timeframe("5", "RTH EMA 计算周期", group = grp_key)
key_ema_len  = input.int(20, "RTH EMA 长度", minval = 1, group = grp_key)

round_level_step = input.float(100.0, "整数位间距：最低 100", minval = 100.0, step = 25.0, group = grp_key)
key_near_atr_mult = input.float(0.25, "普通关键位靠近阈值：ATR 倍数", minval = 0.01, maxval = 2.0, step = 0.01, group = grp_key)

// ============================================================================
// 5. 外部 VWAP/TWAP 形态检测
// ============================================================================
grp_mkt = "5. 外部 VWAP/TWAP 形态检测：ADD / TICK / VIX1D / SPY量"

use_mkt_factor = input.bool(true, "启用外部 VWAP/TWAP 形态检测", group = grp_mkt)

sym_main = input.symbol("SPREADEX:SPX", "主计算源：SPX / Spreadex", group = grp_mkt)
mkt_tf   = input.timeframe("5", "外部情绪计算周期", group = grp_mkt)

sym_spy   = input.symbol("AMEX:SPY", "SPY 成交量参考", group = grp_mkt)
sym_tick  = input.symbol("USI:TICK", "NYSE TICK", group = grp_mkt)
sym_add   = input.symbol("USI:ADD", "NYSE ADD", group = grp_mkt)
sym_vix1d = input.symbol("CBOE:VIX1D", "VIX1D", group = grp_mkt)

use_rth_tick_add_gate = input.bool(true, "ADD/TICK 仅在 RTH 参与评分", group = grp_mkt)

ema_fast_len = input.int(20, "SPX 快 EMA", minval = 1, group = grp_mkt)
ema_slow_len = input.int(50, "SPX 慢 EMA", minval = 1, group = grp_mkt)
ema_slope_len = input.int(5, "EMA 斜率回看 K 数", minval = 1, group = grp_mkt)
ema_slope_atr_mult = input.float(0.06, "EMA 斜率阈值：ATR 倍数", minval = 0.0, step = 0.01, group = grp_mkt)

atr_len = input.int(14, "ATR 长度", minval = 1, group = grp_mkt)
dmi_len = input.int(14, "DMI 长度", minval = 1, group = grp_mkt)
dmi_smooth = input.int(14, "ADX 平滑", minval = 1, group = grp_mkt)
adx_trend_th = input.float(18.0, "ADX 趋势确认阈值", step = 0.5, group = grp_mkt)
adx_strong_th = input.float(25.0, "ADX 强趋势阈值", step = 0.5, group = grp_mkt)

tick_len = input.int(5, "TICK 平滑长度", minval = 1, group = grp_mkt)
tick_avg_th = input.int(250, "TICK 均值确认阈值", minval = 50, step = 50, group = grp_mkt)
tick_pulse_th = input.int(800, "TICK 脉冲阈值", minval = 100, step = 50, group = grp_mkt)

add_lookback = input.int(5, "ADD 扩张/恶化回看 K 数", minval = 1, group = grp_mkt)
add_extreme_th = input.float(1000.0, "ADD 极端单边阈值", minval = 100.0, step = 100.0, group = grp_mkt)
add_soft_th = input.float(700.0, "ADD TWAP 软确认阈值", minval = 100.0, step = 50.0, group = grp_mkt)

vix1d_risk_pct = input.float(3.0, "VIX1D 日内上升风险阈值 %", step = 0.5, group = grp_mkt)
vix1d_calm_pct = input.float(-3.0, "VIX1D 日内下降压波阈值 %", step = 0.5, group = grp_mkt)
vix_slope_len = input.int(3, "VIX1D 短线回看 K 数", minval = 1, group = grp_mkt)
vix_slope_th = input.float(0.30, "VIX1D 短线涨跌阈值 %", step = 0.05, group = grp_mkt)

twap_lookback = input.int(8, "TWAP 确认回看 K 数", minval = 3, maxval = 36, group = grp_mkt)
twap_min_tick_hits = input.int(3, "TWAP 回看内 TICK 同向最少次数", minval = 1, maxval = 36, group = grp_mkt)

spy_vol_len = input.int(20, "SPY 成交量均线长度", minval = 1, group = grp_mkt)
spy_vol_ratio_th = input.float(1.20, "SPY 放量阈值：当前量 / 均量", minval = 0.5, step = 0.05, group = grp_mkt)

vwap_conf_yes_th = input.float(58.0, "VWAP 形态基础阈值", minval = 30.0, maxval = 95.0, step = 1.0, group = grp_mkt)
twap_conf_yes_th = input.float(62.0, "TWAP 形态基础阈值", minval = 30.0, maxval = 95.0, step = 1.0, group = grp_mkt)

flow_strict_vwap_th = input.float(72.0, "面板显示阈值：VWAP形态", minval = 50.0, maxval = 95.0, step = 1.0, group = grp_mkt)
flow_strict_twap_th = input.float(76.0, "面板显示阈值：TWAP形态", minval = 50.0, maxval = 98.0, step = 1.0, group = grp_mkt)
flow_dir_gap_th = input.float(12.0, "面板显示阈值：多空置信度差", minval = 0.0, maxval = 50.0, step = 1.0, group = grp_mkt)
flow_confirm_bars = input.int(2, "面板显示：连续确认K数", minval = 1, maxval = 5, group = grp_mkt)

// ============================================================================
// 6. 执行面板设置
// ============================================================================
grp_panel = "6. 执行面板显示"

show_panel = input.bool(true, "显示 OSR 执行面板", group = grp_panel)
panel_pos = input.string("右上", "面板位置", options = ["右上", "右中", "右下", "左上", "左中", "左下"], group = grp_panel)
panel_size = input.string("小", "面板文字大小", options = ["极小", "小", "正常", "大"], group = grp_panel)

header_text_color = input.color(color.white, "表头文字颜色", group = grp_panel)
body_text_color   = input.color(color.white, "表身文字颜色", group = grp_panel)
lock_text_color_use_state = input.bool(true, "早盘状态分数文字使用锁定状态配色", group = grp_panel)

show_debug = input.bool(false, "数据窗口显示调试项", group = grp_panel)

// ============================================================================
// 7. 工具函数
// ============================================================================
f_clamp(_x, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _x))

f_sign(_x) =>
    _x > 0 ? 1 : _x < 0 ? -1 : 0

f_line_style(_s) =>
    _s == "实线" ? line.style_solid : _s == "虚线" ? line.style_dashed : line.style_dotted

f_day_key(_t) =>
    year(_t, TZ) * 10000 + month(_t, TZ) * 100 + dayofmonth(_t, TZ)

f_fmt0(_v) =>
    na(_v) ? "na" : str.tostring(int(math.round(_v)))

f_fmt_level(_v) =>
    na(_v) ? "na" : str.tostring(math.round(_v * 4.0) / 4.0)

f_range_ok(_h, _l) =>
    not na(_h) and not na(_l) and _h > _l

f_mid(_h, _l) =>
    (_h + _l) * 0.5

f_max2_na(_a, _b) =>
    na(_a) ? _b : na(_b) ? _a : math.max(_a, _b)

f_min2_na(_a, _b) =>
    na(_a) ? _b : na(_b) ? _a : math.min(_a, _b)

f_max4_na(_a, _b, _c, _d) =>
    f_max2_na(f_max2_na(_a, _b), f_max2_na(_c, _d))

f_min4_na(_a, _b, _c, _d) =>
    f_min2_na(f_min2_na(_a, _b), f_min2_na(_c, _d))

f_table_pos(_s) =>
    pos = position.top_right
    if _s == "右上"
        pos := position.top_right
    else if _s == "右中"
        pos := position.middle_right
    else if _s == "右下"
        pos := position.bottom_right
    else if _s == "左上"
        pos := position.top_left
    else if _s == "左中"
        pos := position.middle_left
    else
        pos := position.bottom_left
    pos

f_text_size(_s) =>
    sz = size.small
    if _s == "极小"
        sz := size.tiny
    else if _s == "小"
        sz := size.small
    else if _s == "正常"
        sz := size.normal
    else
        sz := size.large
    sz

f_rank_pct(_v, _arr) =>
    int n = array.size(_arr)
    float rank = na

    if n > 0 and not na(_v)
        int le = 0

        for i = 0 to n - 1
            float item = array.get(_arr, i)
            if not na(item) and item <= _v
                le += 1

        rank := le * 100.0 / n

    rank

f_overlap_score(_h1, _l1, _h2, _l2) =>
    float res = na
    if f_range_ok(_h1, _l1) and f_range_ok(_h2, _l2)
        float inter = math.max(0.0, math.min(_h1, _h2) - math.max(_l1, _l2))
        float envelope = math.max(_h1, _h2) - math.min(_l1, _l2)
        float small_range = math.min(_h1 - _l1, _h2 - _l2)

        float envelope_ratio = envelope > 0.0 ? inter / envelope * 100.0 : 0.0
        float contain_ratio = small_range > 0.0 ? inter / small_range * 100.0 : 0.0

        float total_w = math.max(env_weight + contain_weight, 0.0001)
        res := f_clamp((envelope_ratio * env_weight + contain_ratio * contain_weight) / total_w, 0.0, 100.0)

    res

f_dir_pair(_h1, _l1, _h2, _l2) =>
    float res = na
    if f_range_ok(_h1, _l1) and f_range_ok(_h2, _l2)
        float mid1 = f_mid(_h1, _l1)
        float mid2 = f_mid(_h2, _l2)
        float avg_range = ((_h1 - _l1) + (_h2 - _l2)) * 0.5
        float scale = math.max(avg_range * 0.5, syminfo.mintick)
        res := f_clamp((mid2 - mid1) / scale * 50.0, -100.0, 100.0)
    res

f_weighted_avg4(_v1, _w1, _v2, _w2, _v3, _w3, _v4, _w4) =>
    float num = 0.0
    float den = 0.0

    if not na(_v1) and _w1 > 0
        num += _v1 * _w1
        den += _w1

    if not na(_v2) and _w2 > 0
        num += _v2 * _w2
        den += _w2

    if not na(_v3) and _w3 > 0
        num += _v3 * _w3
        den += _w3

    if not na(_v4) and _w4 > 0
        num += _v4 * _w4
        den += _w4

    den > 0.0 ? num / den : na

f_in_range(_x, _h, _l) =>
    not na(_x) and f_range_ok(_h, _l) and _x <= _h and _x >= _l

f_state_base_color(_state) =>
    color col = color.rgb(92, 96, 100)

    if _state == 5
        col := color.rgb(150, 132, 98)
    else if _state == 4
        col := color.rgb(232, 132, 0)
    else if _state == 1
        col := color.rgb(180, 145, 92)
    else if _state == 3
        col := color.rgb(0, 155, 70)
    else if _state == 2
        col := color.rgb(90, 150, 110)
    else if _state == -2
        col := color.rgb(180, 105, 150)
    else if _state == -3
        col := color.rgb(230, 35, 145)
    else
        col := color.rgb(92, 96, 100)

    col

f_state_title(_state) =>
    string txt = "不明确"
    if _state == 5
        txt := "窄幅震荡"
    else if _state == 4
        txt := "宽幅震荡"
    else if _state == 1
        txt := "偏震荡"
    else if _state == 3
        txt := "趋势向上"
    else if _state == 2
        txt := "偏趋势向上"
    else if _state == -2
        txt := "偏趋势向下"
    else if _state == -3
        txt := "趋势向下"
    else
        txt := "不明确"
    txt

f_state_score_label(_state, _compression, _expansion) =>
    string out = ""
    if _state == 3 or _state == 2 or _state == -2 or _state == -3
        out := "扩张" + f_fmt0(_expansion)
    else
        out := "压缩" + f_fmt0(_compression)
    out

f_alpha_from_strength(_score, _state) =>
    int a = 78

    if _state == 0
        a := 48
    else if _state == 1 or _state == 2 or _state == -2
        a := 46 - int(math.round(f_clamp(_score, 0.0, 100.0) * 0.22))
    else
        a := 58 - int(math.round(f_clamp(_score, 0.0, 100.0) * 0.42))

    a < 8 ? 8 : a > 78 ? 78 : a

f_flow_style_name(_style, _conf) =>
    string txt = "无明确VWAP/TWAP形态"

    if _style == 2
        txt := "当前TWAP上涨形态 " + f_fmt0(_conf)
    else if _style == 1
        txt := "当前VWAP上涨形态 " + f_fmt0(_conf)
    else if _style == -1
        txt := "当前VWAP下跌形态 " + f_fmt0(_conf)
    else if _style == -2
        txt := "当前TWAP下跌形态 " + f_fmt0(_conf)

    txt

// ============================================================================
// 8. 区间数据函数：LV2 / LV1 / BOM / OR10
// ============================================================================
f_get_session_hlc(_sess, _tf) =>
    bool in_sess = not na(time(_tf, _sess, TZ))
    bool prev_in_sess = in_sess[1] == true

    var float s_h = na
    var float s_l = na
    var float s_c = na

    if in_sess and not prev_in_sess
        s_h := high
        s_l := low
        s_c := close
    else if in_sess
        s_h := na(s_h) ? high : math.max(s_h, high)
        s_l := na(s_l) ? low : math.min(s_l, low)
        s_c := close

    [s_h, s_l, s_c]

// ============================================================================
// 9. PDH / PDL / PDC 数据函数
// ============================================================================
f_prev_rth_levels(_sess, _tf) =>
    bool in_rth = not na(time(_tf, _sess, TZ))
    bool prev_in_rth = in_rth[1] == true

    bool rth_start_f = in_rth and not prev_in_rth
    bool rth_end_f = not in_rth and prev_in_rth

    int bar_day_key = f_day_key(time)

    var float run_h = na
    var float run_l = na
    var float run_c = na
    var int run_key = na

    var float prev_h = na
    var float prev_l = na
    var float prev_c = na
    var int prev_key = na

    if rth_start_f
        if not na(run_h) and not na(run_l) and not na(run_c) and not na(run_key) and (na(prev_key) or prev_key != run_key)
            prev_h := run_h
            prev_l := run_l
            prev_c := run_c
            prev_key := run_key

        run_h := high
        run_l := low
        run_c := close
        run_key := bar_day_key

    else if in_rth
        run_h := na(run_h) ? high : math.max(run_h, high)
        run_l := na(run_l) ? low : math.min(run_l, low)
        run_c := close
        run_key := bar_day_key

    if rth_end_f
        if not na(run_h) and not na(run_l) and not na(run_c) and not na(run_key)
            prev_h := run_h
            prev_l := run_l
            prev_c := run_c
            prev_key := run_key

    [prev_h, prev_l, prev_c, prev_key]

// ============================================================================
// 10. 外部 VWAP/TWAP 数据函数
// ============================================================================
f_pct_from_day_ref() =>
    float prev_close = ta.valuewhen(ta.change(time("D")) != 0, close[1], 0)
    float ref_close = nz(prev_close, close)
    ref_close == 0.0 ? 0.0 : (close / ref_close - 1.0) * 100.0

f_bar_pct(_len) =>
    na(close[_len]) or close[_len] == 0.0 ? 0.0 : (close / close[_len] - 1.0) * 100.0

f_main_data() =>
    [pdi, mdi, adx_val] = ta.dmi(dmi_len, dmi_smooth)

    float ema_fast_val = ta.ema(close, ema_fast_len)
    float ema_slow_val = ta.ema(close, ema_slow_len)
    float vwap_val = ta.vwap(hlc3)
    float atr_val = ta.atr(atr_len)

    float ema_fast_slope_val = ema_fast_val - nz(ema_fast_val[ema_slope_len], ema_fast_val)
    float ema_slow_slope_val = ema_slow_val - nz(ema_slow_val[ema_slope_len], ema_slow_val)

    [close, high, low, ema_fast_val, ema_slow_val, vwap_val, atr_val, ema_fast_slope_val, ema_slow_slope_val, pdi, mdi, adx_val]

f_spy_vol_data() =>
    [close, ta.vwap(hlc3), volume, ta.sma(volume, spy_vol_len)]

f_rth_ema_data(_sess, _tf, _len) =>
    bool in_rth = not na(time(_tf, _sess, TZ))
    bool prev_in_rth = in_rth[1] == true
    bool rth_start_f = in_rth and not prev_in_rth

    float alpha = 2.0 / (_len + 1.0)

    var float rth_ema = na

    if rth_start_f
        rth_ema := close
    else if in_rth
        rth_ema := na(rth_ema) ? close : rth_ema + alpha * (close - rth_ema)

    [close, high, low, rth_ema, in_rth ? 1.0 : 0.0]

// ============================================================================
// 11. 请求 LV2 / LV1 / BOM / OR10
// ============================================================================
ext_sym = ticker.modify(sym_range, session.extended)

[lvl2_h_raw, lvl2_l_raw, lvl2_c_raw] = request.security(
     ext_sym,
     range_tf,
     f_get_session_hlc("0400-0800:23456", range_tf),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

[lvl1_h_raw, lvl1_l_raw, lvl1_c_raw] = request.security(
     ext_sym,
     range_tf,
     f_get_session_hlc("0800-0929:23456", range_tf),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

[bom_h_raw, bom_l_raw, bom_c_raw] = request.security(
     ext_sym,
     range_tf,
     f_get_session_hlc("0930-0935:23456", range_tf),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

[or10_h_raw, or10_l_raw, or10_c_raw] = request.security(
     ext_sym,
     range_tf,
     f_get_session_hlc("0930-0940:23456", range_tf),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

// ============================================================================
// 12. 请求 PDH / PDL / PDC
// ============================================================================
[prev_h_raw, prev_l_raw, prev_c_raw, prev_key_raw] = request.security(
     sym_pdh_src,
     pdh_rth_tf,
     f_prev_rth_levels(rth_session, pdh_rth_tf),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

float prev_h = prev_h_raw
float prev_l = prev_l_raw
float prev_c = prev_c_raw
int prev_key = prev_key_raw

bool has_prev_levels = not na(prev_h) and not na(prev_l) and not na(prev_c)

// ============================================================================
// 13. 请求外部 VWAP/TWAP 数据
// ============================================================================
[
 main_close_raw,
 main_high_raw,
 main_low_raw,
 main_ema_fast_raw,
 main_ema_slow_raw,
 main_vwap_raw,
 main_atr_raw,
 main_ema_fast_slope_raw,
 main_ema_slow_slope_raw,
 main_pdi_raw,
 main_mdi_raw,
 main_adx_raw
 ] = request.security(
     sym_main,
     mkt_tf,
     f_main_data(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

main_close = nz(main_close_raw, close)
main_high = nz(main_high_raw, high)
main_low = nz(main_low_raw, low)
main_ema_fast = nz(main_ema_fast_raw, ta.ema(close, ema_fast_len))
main_ema_slow = nz(main_ema_slow_raw, ta.ema(close, ema_slow_len))
main_vwap = nz(main_vwap_raw, ta.vwap(hlc3))
main_atr = nz(main_atr_raw, ta.atr(atr_len))
main_ema_fast_slope = nz(main_ema_fast_slope_raw, 0.0)
main_ema_slow_slope = nz(main_ema_slow_slope_raw, 0.0)
main_pdi = nz(main_pdi_raw, 0.0)
main_mdi = nz(main_mdi_raw, 0.0)
main_adx = nz(main_adx_raw, 0.0)

[spy_close_raw, spy_vwap_raw, spy_vol_raw, spy_vol_ma_raw] = request.security(
     sym_spy,
     mkt_tf,
     f_spy_vol_data(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

spy_close = nz(spy_close_raw, 0.0)
spy_vwap = nz(spy_vwap_raw, spy_close)
spy_vol = nz(spy_vol_raw, 0.0)
spy_vol_ma = nz(spy_vol_ma_raw, 0.0)

tick_raw = request.security(
     sym_tick,
     mkt_tf,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

add_raw = request.security(
     sym_add,
     mkt_tf,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

vix1d_day_pct_raw = request.security(
     sym_vix1d,
     mkt_tf,
     f_pct_from_day_ref(),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

vix1d_bar_pct_raw = request.security(
     sym_vix1d,
     mkt_tf,
     f_bar_pct(vix_slope_len),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

tick_val = nz(tick_raw, nz(tick_raw[1], 0.0))
add_val = nz(add_raw, nz(add_raw[1], 0.0))
vix1d_day_pct = nz(vix1d_day_pct_raw, 0.0)
vix1d_bar_pct = nz(vix1d_bar_pct_raw, 0.0)

tick_ma = ta.sma(tick_val, tick_len)
add_prev = nz(add_val[add_lookback], add_val)

[key_ema_close_raw, key_ema_high_raw, key_ema_low_raw, key_ema_val_raw, key_ema_in_rth_raw] = request.security(
     sym_main,
     key_ema_tf,
     f_rth_ema_data(rth_session, key_ema_tf, key_ema_len),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
     )

key_ema_close = nz(key_ema_close_raw, main_close)
key_ema_high = nz(key_ema_high_raw, main_high)
key_ema_low = nz(key_ema_low_raw, main_low)
key_ema_val = key_ema_val_raw
key_ema_in_rth = nz(key_ema_in_rth_raw, 0.0) > 0.5

// ============================================================================
// 14. 当前日与时段状态
// ============================================================================
int curr_y = year(time, TZ)
int curr_m = month(time, TZ)
int curr_d = dayofmonth(time, TZ)
int curr_key = f_day_key(time)

bool new_ny_day = na(curr_key[1]) or curr_key != curr_key[1]

int ny_h = hour(time, TZ)
int ny_m = minute(time, TZ)
int current_mins = ny_h * 60 + ny_m

int draw_start_mins = draw_start_hour * 60 + draw_start_min
int draw_end_mins = draw_end_hour * 60 + draw_end_min
bool in_draw_window = current_mins >= draw_start_mins and current_mins < draw_end_mins

int t_draw_start = timestamp(TZ, curr_y, curr_m, curr_d, draw_start_hour, draw_start_min)
int t_0400 = timestamp(TZ, curr_y, curr_m, curr_d, 4, 0)
int t_0800 = timestamp(TZ, curr_y, curr_m, curr_d, 8, 0)
int t_0930 = timestamp(TZ, curr_y, curr_m, curr_d, 9, 30)
int t_1600 = timestamp(TZ, curr_y, curr_m, curr_d, draw_end_hour, draw_end_min)

bool in_lvl2 = not na(time(timeframe.period, "0400-0800:23456", TZ))
bool lvl2_start = in_lvl2 and not (in_lvl2[1] == true)

bool in_lvl1 = not na(time(timeframe.period, "0800-0929:23456", TZ))
bool lvl1_start = in_lvl1 and not (in_lvl1[1] == true)

bool in_bom = not na(time(timeframe.period, "0930-0935:23456", TZ))
bool bom_start = in_bom and not (in_bom[1] == true)
bool bom_end = not in_bom and (in_bom[1] == true)

bool in_or10 = not na(time(timeframe.period, "0930-0940:23456", TZ))
bool or10_start = in_or10 and not (in_or10[1] == true)
bool or10_end = not in_or10 and (in_or10[1] == true)

bool in_us_rth = not na(time(timeframe.period, rth_session, TZ))
bool breadth_data_ok = not use_rth_tick_add_gate or in_us_rth

// 更稳的 RTH 起点判断，替代原来的 "0930-0931" 窄窗口判断。
bool rth_start = in_us_rth and not (in_us_rth[1] == true)

// 5分钟RTH序号：给下游信号做“9:40后、30根K内”约束。
int osr_rth_bar_seq = current_mins >= 9 * 60 + 30 and current_mins < 16 * 60 ? int(math.floor((current_mins - (9 * 60 + 30)) / 5)) + 1 : 0

// ============================================================================
// 15. 当日区间缓存
// ============================================================================
var float d_lvl2_h = na
var float d_lvl2_l = na
var float d_lvl2_c = na

var float d_lvl1_h = na
var float d_lvl1_l = na
var float d_lvl1_c = na

var float d_bom_h = na
var float d_bom_l = na
var float d_bom_c = na

var float d_or10_h = na
var float d_or10_l = na
var float d_or10_c = na

var bool bom_completed_today = false
var bool or10_completed_today = false

var bool has_lvl2_today = false
var bool has_lvl1_today = false
var bool has_bom_today = false

if new_ny_day
    d_lvl2_h := na
    d_lvl2_l := na
    d_lvl2_c := na

    d_lvl1_h := na
    d_lvl1_l := na
    d_lvl1_c := na

    d_bom_h := na
    d_bom_l := na
    d_bom_c := na

    d_or10_h := na
    d_or10_l := na
    d_or10_c := na

    bom_completed_today := false
    or10_completed_today := false

    has_lvl2_today := false
    has_lvl1_today := false
    has_bom_today := false

if in_lvl2 and not na(lvl2_h_raw) and not na(lvl2_l_raw)
    d_lvl2_h := lvl2_h_raw
    d_lvl2_l := lvl2_l_raw
    d_lvl2_c := lvl2_c_raw

if in_lvl1 and not na(lvl1_h_raw) and not na(lvl1_l_raw)
    d_lvl1_h := lvl1_h_raw
    d_lvl1_l := lvl1_l_raw
    d_lvl1_c := lvl1_c_raw

if in_bom and not na(bom_h_raw) and not na(bom_l_raw)
    d_bom_h := bom_h_raw
    d_bom_l := bom_l_raw
    d_bom_c := bom_c_raw

if in_or10 and not na(or10_h_raw) and not na(or10_l_raw)
    d_or10_h := or10_h_raw
    d_or10_l := or10_l_raw
    d_or10_c := or10_c_raw

if bom_end
    bom_completed_today := true

if or10_end
    or10_completed_today := true

// ============================================================================
// 16. 绘图对象存储
// ============================================================================
var box[] hist_boxes = array.new_box()
var line[] hist_lines = array.new_line()

var box lvl2_box = na
var box lvl1_box = na
var box bom_box = na
var box or10_box_h = na
var box or10_box_l = na

var bool or10_lines_drawn_today = false
var bool pdh_lines_drawn_today = false

if new_ny_day
    lvl2_box := na
    lvl1_box := na
    bom_box := na
    or10_box_h := na
    or10_box_l := na

    or10_lines_drawn_today := false
    pdh_lines_drawn_today := false

f_push_box(box _bx) =>
    if not na(_bx)
        array.push(hist_boxes, _bx)

f_push_line(line _ln) =>
    if not na(_ln)
        array.push(hist_lines, _ln)

f_clean_history() =>
    int max_boxes = hist_lookback * 5
    while array.size(hist_boxes) > max_boxes
        box.delete(array.shift(hist_boxes))

    int max_lines = hist_lookback * 3
    while array.size(hist_lines) > max_lines
        line.delete(array.shift(hist_lines))

f_reserve_box_slot() =>
    int max_boxes = hist_lookback * 5
    while array.size(hist_boxes) >= max_boxes
        box.delete(array.shift(hist_boxes))

// ============================================================================
// 17. LV2 填充：4:00-8:00，创建后直接延伸到 16:00
// ============================================================================
if in_lvl2 and show_lvl2_fill and f_range_ok(d_lvl2_h, d_lvl2_l)
    has_lvl2_today := true

    if na(lvl2_box)
        f_reserve_box_slot()
        lvl2_box := box.new(
             left = t_0400,
             top = d_lvl2_h,
             right = t_1600,
             bottom = d_lvl2_l,
             xloc = xloc.bar_time,
             border_color = na,
             bgcolor = color_lvl2
             )

        f_push_box(lvl2_box)
        f_clean_history()
    else
        box.set_left(lvl2_box, t_0400)
        box.set_top(lvl2_box, d_lvl2_h)
        box.set_right(lvl2_box, t_1600)
        box.set_bottom(lvl2_box, d_lvl2_l)

// ============================================================================
// 18. LV1 填充：8:00-9:29，创建后直接延伸到 16:00
// ============================================================================
if in_lvl1 and show_lvl1_fill and f_range_ok(d_lvl1_h, d_lvl1_l)
    has_lvl1_today := true

    if na(lvl1_box)
        f_reserve_box_slot()
        lvl1_box := box.new(
             left = t_0800,
             top = d_lvl1_h,
             right = t_1600,
             bottom = d_lvl1_l,
             xloc = xloc.bar_time,
             border_color = na,
             bgcolor = color_lvl1
             )

        f_push_box(lvl1_box)
        f_clean_history()
    else
        box.set_left(lvl1_box, t_0800)
        box.set_top(lvl1_box, d_lvl1_h)
        box.set_right(lvl1_box, t_1600)
        box.set_bottom(lvl1_box, d_lvl1_l)

// ============================================================================
// 19. BOM 填充：9:30-9:35，创建后直接延伸到 16:00
// ============================================================================
if in_bom and show_bom_fill and f_range_ok(d_bom_h, d_bom_l)
    has_bom_today := true

    if na(bom_box)
        f_reserve_box_slot()
        bom_box := box.new(
             left = t_0930,
             top = d_bom_h,
             right = t_1600,
             bottom = d_bom_l,
             xloc = xloc.bar_time,
             border_color = na,
             bgcolor = color_bom
             )

        f_push_box(bom_box)
        f_clean_history()
    else
        box.set_left(bom_box, t_0930)
        box.set_top(bom_box, d_bom_h)
        box.set_right(bom_box, t_1600)
        box.set_bottom(bom_box, d_bom_l)

if bom_end
    if show_bom_fill and has_bom_today and not na(bom_box)
        box.set_right(bom_box, t_1600)

// ============================================================================
// 20. OR10 高低：使用薄 box 条带，保证在填充区上层可见
// ============================================================================
if or10_end and show_or10_line and not or10_lines_drawn_today and f_range_ok(d_or10_h, d_or10_l)
    float or10_band = math.max(math.max(main_atr, syminfo.mintick) * or10_band_atr_mult, syminfo.mintick * 2.0)

    f_reserve_box_slot()
    or10_box_h := box.new(
         left = t_0930,
         top = d_or10_h + or10_band,
         right = t_1600,
         bottom = d_or10_h - or10_band,
         xloc = xloc.bar_time,
         border_color = na,
         bgcolor = or10_col
         )

    f_reserve_box_slot()
    or10_box_l := box.new(
         left = t_0930,
         top = d_or10_l + or10_band,
         right = t_1600,
         bottom = d_or10_l - or10_band,
         xloc = xloc.bar_time,
         border_color = na,
         bgcolor = or10_col
         )

    f_push_box(or10_box_h)
    f_push_box(or10_box_l)
    f_clean_history()

    or10_lines_drawn_today := true

// ============================================================================
// 21. RTH 开盘后，LV1 / LV2 延伸到 16:00
// 说明：LV1/LV2/BOM 现在创建时已经直接延伸到 16:00。
// 这里保留轻量兜底，不参与任何 OSR 数据计算。
// ============================================================================
if rth_start
    if show_lvl2_fill and has_lvl2_today and not na(lvl2_box)
        box.set_right(lvl2_box, t_1600)

    if show_lvl1_fill and has_lvl1_today and not na(lvl1_box)
        box.set_right(lvl1_box, t_1600)

    has_lvl1_today := false
    has_lvl2_today := false

// ============================================================================
// 22. PDH / PDL / PDC 横线
// ============================================================================
pdh_style = f_line_style(pdh_style_s)
pdl_style = f_line_style(pdl_style_s)
pdc_style = f_line_style(pdc_style_s)

bool is_time_to_draw_pdh = show_pdh_lines and in_draw_window and not pdh_lines_drawn_today and has_prev_levels

if is_time_to_draw_pdh
    pdh_lines_drawn_today := true

    line l_pdh = line.new(
         x1 = t_draw_start,
         y1 = prev_h,
         x2 = t_1600,
         y2 = prev_h,
         xloc = xloc.bar_time,
         color = pdh_col,
         width = 2,
         style = pdh_style
         )

    line l_pdl = line.new(
         x1 = t_draw_start,
         y1 = prev_l,
         x2 = t_1600,
         y2 = prev_l,
         xloc = xloc.bar_time,
         color = pdl_col,
         width = 2,
         style = pdl_style
         )

    line l_pdc = line.new(
         x1 = t_draw_start,
         y1 = prev_c,
         x2 = t_1600,
         y2 = prev_c,
         xloc = xloc.bar_time,
         color = pdc_col,
         width = 1,
         style = pdc_style
         )

    f_push_line(l_pdh)
    f_push_line(l_pdl)
    f_push_line(l_pdc)
    f_clean_history()

last_key = f_day_key(last_bar_time)
bool is_today_chart = curr_key == last_key

plot(
     show_pdh_lines and in_draw_window and is_today_chart and has_prev_levels ? prev_h : na,
     title = "PDH Label",
     color = color.new(pdh_col, 0),
     display = display.price_scale,
     editable = false
     )

plot(
     show_pdh_lines and in_draw_window and is_today_chart and has_prev_levels ? prev_l : na,
     title = "PDL Label",
     color = color.new(pdl_col, 0),
     display = display.price_scale,
     editable = false
     )

plot(
     show_pdh_lines and in_draw_window and is_today_chart and has_prev_levels ? prev_c : na,
     title = "PDC Label",
     color = color.new(pdc_col, 0),
     display = display.price_scale,
     editable = false
     )

// ============================================================================
// 23. 四组两两重叠 + 整体分散度
// ============================================================================
pair_l2_l1 = f_overlap_score(d_lvl2_h, d_lvl2_l, d_lvl1_h, d_lvl1_l)
pair_l1_bom = f_overlap_score(d_lvl1_h, d_lvl1_l, d_bom_h, d_bom_l)
pair_l1_or10 = f_overlap_score(d_lvl1_h, d_lvl1_l, d_or10_h, d_or10_l)
pair_bom_or10 = f_overlap_score(d_bom_h, d_bom_l, d_or10_h, d_or10_l)

dir_l2_l1 = f_dir_pair(d_lvl2_h, d_lvl2_l, d_lvl1_h, d_lvl1_l)
dir_l1_bom = f_dir_pair(d_lvl1_h, d_lvl1_l, d_bom_h, d_bom_l)
dir_l1_or10 = f_dir_pair(d_lvl1_h, d_lvl1_l, d_or10_h, d_or10_l)
dir_bom_or10 = f_dir_pair(d_bom_h, d_bom_l, d_or10_h, d_or10_l)

pair_compression = f_weighted_avg4(
     pair_l2_l1, w_l2_l1,
     pair_l1_bom, w_l1_bom,
     pair_l1_or10, w_l1_or10,
     pair_bom_or10, w_bom_or10
     )

float lvl2_mid = f_range_ok(d_lvl2_h, d_lvl2_l) ? f_mid(d_lvl2_h, d_lvl2_l) : na
float lvl1_mid = f_range_ok(d_lvl1_h, d_lvl1_l) ? f_mid(d_lvl1_h, d_lvl1_l) : na
float bom_mid = f_range_ok(d_bom_h, d_bom_l) ? f_mid(d_bom_h, d_bom_l) : na
float or10_mid = f_range_ok(d_or10_h, d_or10_l) ? f_mid(d_or10_h, d_or10_l) : na

int up_steps = 0
int down_steps = 0

if not na(lvl2_mid) and not na(lvl1_mid)
    up_steps += lvl1_mid > lvl2_mid ? 1 : 0
    down_steps += lvl1_mid < lvl2_mid ? 1 : 0

if not na(lvl1_mid) and not na(bom_mid)
    up_steps += bom_mid > lvl1_mid ? 1 : 0
    down_steps += bom_mid < lvl1_mid ? 1 : 0

if not na(bom_mid) and not na(or10_mid)
    up_steps += or10_mid > bom_mid ? 1 : 0
    down_steps += or10_mid < bom_mid ? 1 : 0

float sequence_bias = (up_steps - down_steps) / 3.0 * 100.0

dir_bias_raw = f_weighted_avg4(
     dir_l2_l1, 0.20,
     dir_l1_bom, 0.30,
     dir_l1_or10, 0.35,
     dir_bom_or10, 0.15
     )

dir_bias_combined = na(dir_bias_raw) ? sequence_bias : dir_bias_raw * 0.70 + sequence_bias * 0.30
dir_bias_safe = f_clamp(nz(dir_bias_combined, 0.0), -100.0, 100.0)

float overall_h = f_max4_na(d_lvl2_h, d_lvl1_h, d_bom_h, d_or10_h)
float overall_l = f_min4_na(d_lvl2_l, d_lvl1_l, d_bom_l, d_or10_l)
float overall_span = f_range_ok(overall_h, overall_l) ? overall_h - overall_l : na

float range_sum = 0.0
int range_count = 0

if f_range_ok(d_lvl2_h, d_lvl2_l)
    range_sum += d_lvl2_h - d_lvl2_l
    range_count += 1

if f_range_ok(d_lvl1_h, d_lvl1_l)
    range_sum += d_lvl1_h - d_lvl1_l
    range_count += 1

if f_range_ok(d_bom_h, d_bom_l)
    range_sum += d_bom_h - d_bom_l
    range_count += 1

if f_range_ok(d_or10_h, d_or10_l)
    range_sum += d_or10_h - d_or10_l
    range_count += 1

float avg_stage_range = range_count > 0 ? range_sum / range_count : na

float dispersion_score = na
if not na(overall_span) and not na(avg_stage_range) and avg_stage_range > 0
    dispersion_score := f_clamp((overall_span / avg_stage_range - 1.0) / 1.35 * 100.0, 0.0, 100.0)

float compression_integrated_raw = na
if not na(pair_compression) and not na(dispersion_score)
    compression_integrated_raw := pair_compression * 0.72 + (100.0 - dispersion_score) * 0.28
else if not na(pair_compression)
    compression_integrated_raw := pair_compression
else if not na(dispersion_score)
    compression_integrated_raw := 100.0 - dispersion_score

compression_raw_safe = f_clamp(nz(compression_integrated_raw, 50.0), 0.0, 100.0)

// ============================================================================
// 24. 历史分位归一化：隐藏参与，不进面板
// ============================================================================
var float[] compression_hist = array.new_float()
var bool compression_recorded_today = false
var float compression_rank_today = na
var int compression_hist_count_today = 0

if new_ny_day
    compression_recorded_today := false
    compression_rank_today := na
    compression_hist_count_today := array.size(compression_hist)

bool final_structure_ready = or10_completed_today and not na(compression_integrated_raw)

if final_structure_ready and not compression_recorded_today
    compression_hist_count_today := array.size(compression_hist)
    compression_rank_today := f_rank_pct(compression_integrated_raw, compression_hist)

    array.push(compression_hist, compression_integrated_raw)

    while array.size(compression_hist) > norm_lookback_days
        array.shift(compression_hist)

    compression_recorded_today := true

bool hist_norm_ready = compression_hist_count_today >= min_hist_days and not na(compression_rank_today)

float compression_final = compression_raw_safe

if norm_mode == "历史分位" and hist_norm_ready
    compression_final := compression_rank_today
else if norm_mode == "混合" and hist_norm_ready
    compression_final := compression_raw_safe * 0.50 + compression_rank_today * 0.50
else
    compression_final := compression_raw_safe

compression_final := f_clamp(compression_final, 0.0, 100.0)
expansion_final = 100.0 - compression_final

// ============================================================================
// 25. VWAP / TWAP 形态检测
// ============================================================================
main_atr_safe = math.max(main_atr, syminfo.mintick)
ema_slope_th = main_atr_safe * ema_slope_atr_mult

price_above_vwap = main_close > main_vwap
price_below_vwap = main_close < main_vwap

ema_stack_up = main_ema_fast > main_ema_slow
ema_stack_down = main_ema_fast < main_ema_slow

ema_slope_up = main_ema_fast_slope > ema_slope_th
ema_slope_down = main_ema_fast_slope < -ema_slope_th

dmi_up = main_pdi > main_mdi and main_adx >= adx_trend_th
dmi_down = main_mdi > main_pdi and main_adx >= adx_trend_th

trend_quality_up = price_above_vwap and ema_stack_up and ema_slope_up and (dmi_up or main_adx >= adx_strong_th)
trend_quality_down = price_below_vwap and ema_stack_down and ema_slope_down and (dmi_down or main_adx >= adx_strong_th)

vwap_trend_up = price_above_vwap and ema_stack_up and ema_slope_up
vwap_trend_down = price_below_vwap and ema_stack_down and ema_slope_down

tick_bull = breadth_data_ok and (tick_val >= tick_pulse_th or tick_ma >= tick_avg_th)
tick_bear = breadth_data_ok and (tick_val <= -tick_pulse_th or tick_ma <= -tick_avg_th)

add_bull = breadth_data_ok and add_val > 0 and add_val > add_prev
add_bear = breadth_data_ok and add_val < 0 and add_val < add_prev

add_high_recent = ta.highest(add_val, twap_lookback)
add_low_recent = ta.lowest(add_val, twap_lookback)
tick_ma_high_recent = ta.highest(tick_ma, twap_lookback)
tick_ma_low_recent = ta.lowest(tick_ma, twap_lookback)

add_soft_bull = breadth_data_ok and add_high_recent >= add_soft_th and add_val > 0
add_soft_bear = breadth_data_ok and add_low_recent <= -add_soft_th and add_val < 0

add_extreme_bull = breadth_data_ok and add_high_recent >= add_extreme_th and add_val > 0
add_extreme_bear = breadth_data_ok and add_low_recent <= -add_extreme_th and add_val < 0

tick_hit_bull = breadth_data_ok and tick_ma >= 0
tick_hit_bear = breadth_data_ok and tick_ma <= 0

tick_bull_hit_count = ta.sma(tick_hit_bull ? 1.0 : 0.0, twap_lookback) * twap_lookback
tick_bear_hit_count = ta.sma(tick_hit_bear ? 1.0 : 0.0, twap_lookback) * twap_lookback

tick_recent_bull = breadth_data_ok and (tick_bull_hit_count >= twap_min_tick_hits or tick_ma_high_recent >= tick_avg_th)
tick_recent_bear = breadth_data_ok and (tick_bear_hit_count >= twap_min_tick_hits or tick_ma_low_recent <= -tick_avg_th)

vix1d_rising_now = vix1d_bar_pct >= vix_slope_th
vix1d_falling_now = vix1d_bar_pct <= -vix_slope_th

vix1d_day_risk = vix1d_day_pct >= vix1d_risk_pct
vix1d_day_calm = vix1d_day_pct <= vix1d_calm_pct

vix1d_risk = (vix1d_day_risk and not vix1d_falling_now) or vix1d_rising_now
vix1d_calm = (vix1d_day_calm and not vix1d_rising_now) or vix1d_falling_now

spy_vol_ratio = spy_vol_ma > 0.0 ? spy_vol / spy_vol_ma : 1.0
spy_vol_expand = spy_vol_ratio >= spy_vol_ratio_th

float vwap_bull_raw = 0.0
vwap_bull_raw += price_above_vwap ? 25.0 : 0.0
vwap_bull_raw += main_close > main_ema_fast ? 10.0 : 0.0
vwap_bull_raw += ema_stack_up ? 15.0 : 0.0
vwap_bull_raw += ema_slope_up ? 20.0 : 0.0
vwap_bull_raw += main_adx >= adx_trend_th ? 10.0 : 0.0
vwap_bull_raw += main_pdi > main_mdi ? 10.0 : 0.0
vwap_bull_raw += add_bull ? 5.0 : 0.0
vwap_bull_raw += tick_bull ? 5.0 : 0.0

float vwap_bear_raw = 0.0
vwap_bear_raw += price_below_vwap ? 25.0 : 0.0
vwap_bear_raw += main_close < main_ema_fast ? 10.0 : 0.0
vwap_bear_raw += ema_stack_down ? 15.0 : 0.0
vwap_bear_raw += ema_slope_down ? 20.0 : 0.0
vwap_bear_raw += main_adx >= adx_trend_th ? 10.0 : 0.0
vwap_bear_raw += main_mdi > main_pdi ? 10.0 : 0.0
vwap_bear_raw += add_bear ? 5.0 : 0.0
vwap_bear_raw += tick_bear ? 5.0 : 0.0

vwap_bull_conf = f_clamp(vwap_bull_raw, 0.0, 100.0)
vwap_bear_conf = f_clamp(vwap_bear_raw, 0.0, 100.0)

int vwap_dir = 0
float vwap_conf = math.max(vwap_bull_conf, vwap_bear_conf)

if vwap_bull_conf >= vwap_bear_conf and vwap_bull_conf >= vwap_conf_yes_th
    vwap_dir := 1
else if vwap_bear_conf > vwap_bull_conf and vwap_bear_conf >= vwap_conf_yes_th
    vwap_dir := -1
else
    vwap_dir := 0

float twap_bull_raw = 0.0
twap_bull_raw += trend_quality_up ? 25.0 : vwap_trend_up ? 15.0 : 0.0
twap_bull_raw += add_extreme_bull ? 25.0 : add_soft_bull ? 15.0 : 0.0
twap_bull_raw += tick_recent_bull ? 20.0 : 0.0
twap_bull_raw += main_adx >= adx_strong_th ? 10.0 : main_adx >= adx_trend_th ? 5.0 : 0.0
twap_bull_raw += not vix1d_risk ? 10.0 : -15.0
twap_bull_raw += spy_vol_expand and spy_close > spy_vwap ? 5.0 : 0.0

float twap_bear_raw = 0.0
twap_bear_raw += trend_quality_down ? 25.0 : vwap_trend_down ? 15.0 : 0.0
twap_bear_raw += add_extreme_bear ? 25.0 : add_soft_bear ? 15.0 : 0.0
twap_bear_raw += tick_recent_bear ? 20.0 : 0.0
twap_bear_raw += main_adx >= adx_strong_th ? 10.0 : main_adx >= adx_trend_th ? 5.0 : 0.0
twap_bear_raw += not vix1d_calm ? 10.0 : -5.0
twap_bear_raw += spy_vol_expand and spy_close < spy_vwap ? 5.0 : 0.0

twap_bull_conf = f_clamp(twap_bull_raw, 0.0, 100.0)
twap_bear_conf = f_clamp(twap_bear_raw, 0.0, 100.0)

int twap_dir = 0
float twap_conf = math.max(twap_bull_conf, twap_bear_conf)

if twap_bull_conf >= twap_bear_conf and twap_bull_conf >= twap_conf_yes_th
    twap_dir := 1
else if twap_bear_conf > twap_bull_conf and twap_bear_conf >= twap_conf_yes_th
    twap_dir := -1
else
    twap_dir := 0

// ============================================================================
// 严格版 VWAP/TWAP 形态筛选
// ============================================================================
float flow_vwap_up_score = vwap_bull_conf
float flow_vwap_down_score = vwap_bear_conf
float flow_twap_up_score = twap_bull_conf
float flow_twap_down_score = twap_bear_conf

float flow_up_best_score = math.max(flow_twap_up_score, flow_vwap_up_score)
float flow_down_best_score = math.max(flow_twap_down_score, flow_vwap_down_score)

int flow_up_best_style = flow_twap_up_score >= flow_vwap_up_score ? 2 : 1
int flow_down_best_style = flow_twap_down_score >= flow_vwap_down_score ? -2 : -1

bool flow_up_dominant = flow_up_best_score >= flow_down_best_score + flow_dir_gap_th
bool flow_down_dominant = flow_down_best_score >= flow_up_best_score + flow_dir_gap_th

int raw_flow_style = 0
float raw_flow_conf = 0.0

if flow_up_dominant
    raw_flow_style := flow_up_best_style
    raw_flow_conf := flow_up_best_score
else if flow_down_dominant
    raw_flow_style := flow_down_best_style
    raw_flow_conf := flow_down_best_score
else
    raw_flow_style := 0
    raw_flow_conf := 0.0

float raw_flow_show_th = math.abs(raw_flow_style) == 2 ? flow_strict_twap_th : flow_strict_vwap_th

bool raw_flow_pass =
     raw_flow_style != 0 and
     raw_flow_conf >= raw_flow_show_th

var int flow_last_raw_style = 0
var int flow_streak = 0

if raw_flow_pass
    if raw_flow_style == flow_last_raw_style
        flow_streak += 1
    else
        flow_streak := 1

    flow_last_raw_style := raw_flow_style
else
    flow_streak := 0
    flow_last_raw_style := 0

int flow_style = flow_streak >= flow_confirm_bars ? raw_flow_style : 0
float flow_conf_final = flow_style != 0 ? raw_flow_conf : 0.0

add_score = breadth_data_ok ? f_clamp(add_val / add_extreme_th * 35.0, -35.0, 35.0) : 0.0
tick_score = breadth_data_ok ? f_clamp(tick_ma / tick_avg_th * 25.0, -25.0, 25.0) : 0.0

float vix_score = 0.0
if vix1d_risk
    vix_score := -15.0
else if vix1d_calm
    vix_score := 12.0

float flow_score_scale = f_clamp(flow_conf_final / 100.0, 0.0, 1.0)

flow_score =
     flow_style == 2  ? 28.0 * flow_score_scale :
     flow_style == 1  ? 15.0 * flow_score_scale :
     flow_style == -2 ? -28.0 * flow_score_scale :
     flow_style == -1 ? -15.0 * flow_score_scale :
     0.0

spy_vol_score = 0.0
if spy_vol_expand
    if spy_close > spy_vwap
        spy_vol_score := 5.0
    else if spy_close < spy_vwap
        spy_vol_score := -5.0

emotion_score_raw = add_score + tick_score + vix_score + flow_score + spy_vol_score
emotion_score = use_mkt_factor ? f_clamp(emotion_score_raw, -100.0, 100.0) : 0.0
emotion_strength = math.abs(emotion_score)

// ============================================================================
// 26. BOM 否定分：正数=下冲失败反转多，负数=上冲失败反转空
// ============================================================================
float p_l1_bom = na(pair_l1_bom) ? 50.0 : pair_l1_bom
float p_l1_or10 = na(pair_l1_or10) ? 50.0 : pair_l1_or10
float p_bom_or10 = na(pair_bom_or10) ? 50.0 : pair_bom_or10

bool bom_up_leave_lv1 =
     f_range_ok(d_lvl1_h, d_lvl1_l) and
     f_range_ok(d_bom_h, d_bom_l) and
     (
      d_bom_l > d_lvl1_h or
      (not na(lvl1_mid) and not na(bom_mid) and bom_mid > lvl1_mid and p_l1_bom <= 45.0)
      )

bool bom_down_leave_lv1 =
     f_range_ok(d_lvl1_h, d_lvl1_l) and
     f_range_ok(d_bom_h, d_bom_l) and
     (
      d_bom_h < d_lvl1_l or
      (not na(lvl1_mid) and not na(bom_mid) and bom_mid < lvl1_mid and p_l1_bom <= 45.0)
      )

bool or10_back_to_lv1 =
     f_range_ok(d_lvl1_h, d_lvl1_l) and
     f_range_ok(d_or10_h, d_or10_l) and
     (
      p_l1_or10 >= 50.0 or
      f_in_range(d_or10_c, d_lvl1_h, d_lvl1_l) or
      f_in_range(or10_mid, d_lvl1_h, d_lvl1_l)
      )

bool or10_rejects_bom_up =
     bom_up_leave_lv1 and
     or10_back_to_lv1 and
     not na(or10_mid) and
     not na(bom_mid) and
     or10_mid < bom_mid

bool or10_rejects_bom_down =
     bom_down_leave_lv1 and
     or10_back_to_lv1 and
     not na(or10_mid) and
     not na(bom_mid) and
     or10_mid > bom_mid

float reject_base = f_clamp(
     (100.0 - p_l1_bom) * 0.45 +
     p_l1_or10 * 0.35 +
     (100.0 - p_bom_or10) * 0.20,
     0.0,
     100.0
     )

float bom_reject_score = 0.0

if or10_rejects_bom_up
    float emotion_confirm_short = emotion_score < 0 ? math.abs(emotion_score) * 0.20 : emotion_score > 0 ? -math.abs(emotion_score) * 0.10 : 0.0
    bom_reject_score := -f_clamp(reject_base + emotion_confirm_short, 0.0, 100.0)
else if or10_rejects_bom_down
    float emotion_confirm_long = emotion_score > 0 ? math.abs(emotion_score) * 0.20 : emotion_score < 0 ? -math.abs(emotion_score) * 0.10 : 0.0
    bom_reject_score := f_clamp(reject_base + emotion_confirm_long, 0.0, 100.0)
else
    bom_reject_score := 0.0

// ============================================================================
// 27. OSR 核心输出分层：保守 A+ 分类
// ============================================================================
osr_compression = f_clamp(compression_final, 0.0, 100.0)
osr_expansion = f_clamp(expansion_final, 0.0, 100.0)
osr_dir_bias = f_clamp(dir_bias_safe, -100.0, 100.0)
osr_bom_reject = f_clamp(bom_reject_score, -100.0, 100.0)

float prev_range_safe = has_prev_levels ? math.max(prev_h - prev_l, syminfo.mintick) : na
float span_prev_pct = not na(overall_span) and not na(prev_range_safe) and prev_range_safe > 0 ? overall_span / prev_range_safe * 100.0 : na

float structure_direction_score = f_clamp(osr_dir_bias * 0.78 + osr_bom_reject * 0.22, -100.0, 100.0)

bool algo_struct_conflict =
     flow_style != 0 and
     math.abs(structure_direction_score) >= bias_direction_th and
     f_sign(flow_style) != f_sign(structure_direction_score)

bool emotion_struct_conflict =
     math.abs(emotion_score) >= 25.0 and
     math.abs(structure_direction_score) >= bias_direction_th and
     f_sign(emotion_score) != f_sign(structure_direction_score)

bool major_conflict = algo_struct_conflict or emotion_struct_conflict

bool clear_up =
     osr_expansion >= clear_expansion_th and
     structure_direction_score >= clear_direction_th and
     not major_conflict

bool clear_down =
     osr_expansion >= clear_expansion_th and
     structure_direction_score <= -clear_direction_th and
     not major_conflict

bool bias_up =
     osr_expansion >= bias_expansion_th and
     structure_direction_score >= bias_direction_th and
     not clear_up and
     not major_conflict

bool bias_down =
     osr_expansion >= bias_expansion_th and
     structure_direction_score <= -bias_direction_th and
     not clear_down and
     not major_conflict

bool clear_compression =
     osr_compression >= clear_compression_th

bool bias_compression =
     osr_compression >= bias_compression_th and
     osr_compression < clear_compression_th

bool is_narrow_context =
     (not na(span_prev_pct) and span_prev_pct <= narrow_span_prev_pct) or
     (na(span_prev_pct) and not na(overall_span) and overall_span <= main_atr_safe * 1.50)

int osr_state_code = 0

if clear_compression
    osr_state_code := is_narrow_context ? 5 : 4
else if clear_up
    osr_state_code := 3
else if clear_down
    osr_state_code := -3
else if bias_compression
    osr_state_code := 1
else if bias_up
    osr_state_code := 2
else if bias_down
    osr_state_code := -2
else
    osr_state_code := 0

float osr_state_strength = 45.0

if osr_state_code == 5
    osr_state_strength := osr_compression * 0.75 + (100.0 - nz(dispersion_score, 50.0)) * 0.25
else if osr_state_code == 4
    osr_state_strength := osr_compression * 0.65 + nz(dispersion_score, 50.0) * 0.20 + nz(span_prev_pct, 40.0) * 0.15
else if osr_state_code == 1
    osr_state_strength := osr_compression
else if osr_state_code == 3 or osr_state_code == -3
    osr_state_strength := osr_expansion * 0.62 + math.abs(structure_direction_score) * 0.28 + emotion_strength * 0.10
else if osr_state_code == 2 or osr_state_code == -2
    osr_state_strength := osr_expansion * 0.70 + math.abs(structure_direction_score) * 0.30
else
    osr_state_strength := 35.0 + math.abs(osr_compression - 50.0) * 0.20

osr_state_strength := f_clamp(osr_state_strength, 0.0, 100.0)

// ============================================================================
// 27.5 9:40 锁定值：给趋势 / 反转 / 扫荡指标调用
// ============================================================================
var float osr_compression_lock_0940 = na
var float osr_expansion_lock_0940 = na
var float osr_ready_0940 = 0.0
var int osr_state_code_lock_0940 = 0
var float osr_dir_bias_lock_0940 = na
var float osr_bom_reject_lock_0940 = na
var float structure_direction_score_lock_0940 = na
var bool osr_locked_today = false

if new_ny_day
    osr_compression_lock_0940 := na
    osr_expansion_lock_0940 := na
    osr_ready_0940 := 0.0
    osr_state_code_lock_0940 := 0
    osr_dir_bias_lock_0940 := na
    osr_bom_reject_lock_0940 := na
    structure_direction_score_lock_0940 := na
    osr_locked_today := false

bool osr_lock_trigger =
     not osr_locked_today and
     final_structure_ready and
     current_mins >= 9 * 60 + 40

if osr_lock_trigger
    osr_compression_lock_0940 := osr_compression
    osr_expansion_lock_0940 := osr_expansion
    osr_state_code_lock_0940 := osr_state_code
    osr_dir_bias_lock_0940 := osr_dir_bias
    osr_bom_reject_lock_0940 := osr_bom_reject
    structure_direction_score_lock_0940 := structure_direction_score
    osr_ready_0940 := 1.0
    osr_locked_today := true

// ============================================================================
// 28. 关键位观察：LV1 / BOM / OR10 / PDH / PDL / EMA20 / 百点整数位
// ============================================================================
float key_near_th = main_atr_safe * key_near_atr_mult

float boundary_near_by_atr = main_atr_safe * boundary_near_atr_mult
float boundary_near_by_range = has_prev_levels ? prev_range_safe * boundary_near_prev_range_pct * 0.01 : na
float boundary_near_th = has_prev_levels ? math.max(boundary_near_by_atr, boundary_near_by_range) : key_near_th

float curr_c = main_close
float curr_h = main_high
float curr_l = main_low
float prev_c_main = nz(main_close[1], main_close)

int trend_side = osr_state_code == 3 or osr_state_code == 2 ? 1 : osr_state_code == -2 or osr_state_code == -3 ? -1 : 0

bool lv1_key_ready =
     use_key_factor and
     use_lvl1_key and
     current_mins >= 9 * 60 + 30 and
     f_range_ok(d_lvl1_h, d_lvl1_l)

bool bom_key_ready =
     use_key_factor and
     use_bom_key and
     (bom_completed_today or current_mins >= 9 * 60 + 35) and
     f_range_ok(d_bom_h, d_bom_l)

bool or10_key_ready =
     use_key_factor and
     use_or10_key and
     (or10_completed_today or current_mins >= 9 * 60 + 40) and
     f_range_ok(d_or10_h, d_or10_l)

bool pd_key_ready =
     use_key_factor and
     use_pdh_key and
     has_prev_levels

bool ema_key_ready =
     use_key_factor and
     use_ema_key and
     key_ema_in_rth and
     not na(key_ema_val)

float round_key = use_round_key and curr_c > 0.0 ? math.round(curr_c / round_level_step) * round_level_step : na

bool round_key_ready =
     use_key_factor and
     use_round_key and
     not na(round_key)

bool key_bar_ok = barstate.isconfirmed

bool lv1h_break_up = key_bar_ok and lv1_key_ready and curr_c > d_lvl1_h and prev_c_main <= d_lvl1_h
bool lv1h_upper_reject = key_bar_ok and lv1_key_ready and curr_h > d_lvl1_h and curr_c < d_lvl1_h
bool lv1h_near = lv1_key_ready and math.abs(curr_c - d_lvl1_h) <= key_near_th

bool lv1l_break_down = key_bar_ok and lv1_key_ready and curr_c < d_lvl1_l and prev_c_main >= d_lvl1_l
bool lv1l_lower_reclaim = key_bar_ok and lv1_key_ready and curr_l < d_lvl1_l and curr_c > d_lvl1_l
bool lv1l_near = lv1_key_ready and math.abs(curr_c - d_lvl1_l) <= key_near_th

bool bomh_break_up = key_bar_ok and bom_key_ready and curr_c > d_bom_h and prev_c_main <= d_bom_h
bool bomh_upper_reject = key_bar_ok and bom_key_ready and curr_h > d_bom_h and curr_c < d_bom_h
bool bomh_near = bom_key_ready and math.abs(curr_c - d_bom_h) <= key_near_th

bool boml_break_down = key_bar_ok and bom_key_ready and curr_c < d_bom_l and prev_c_main >= d_bom_l
bool boml_lower_reclaim = key_bar_ok and bom_key_ready and curr_l < d_bom_l and curr_c > d_bom_l
bool boml_near = bom_key_ready and math.abs(curr_c - d_bom_l) <= key_near_th

bool or10h_break_up = key_bar_ok and or10_key_ready and curr_c > d_or10_h and prev_c_main <= d_or10_h
bool or10h_upper_reject = key_bar_ok and or10_key_ready and curr_h > d_or10_h and curr_c < d_or10_h
bool or10h_near = or10_key_ready and math.abs(curr_c - d_or10_h) <= key_near_th

bool or10l_break_down = key_bar_ok and or10_key_ready and curr_c < d_or10_l and prev_c_main >= d_or10_l
bool or10l_lower_reclaim = key_bar_ok and or10_key_ready and curr_l < d_or10_l and curr_c > d_or10_l
bool or10l_near = or10_key_ready and math.abs(curr_c - d_or10_l) <= key_near_th

bool pdh_break_up = key_bar_ok and pd_key_ready and curr_c > prev_h and prev_c_main <= prev_h
bool pdh_upper_reject = key_bar_ok and pd_key_ready and curr_h > prev_h and curr_c < prev_h
bool pdh_near = pd_key_ready and math.abs(curr_c - prev_h) <= boundary_near_th

bool pdl_break_down = key_bar_ok and pd_key_ready and curr_c < prev_l and prev_c_main >= prev_l
bool pdl_lower_reclaim = key_bar_ok and pd_key_ready and curr_l < prev_l and curr_c > prev_l
bool pdl_near = pd_key_ready and math.abs(curr_c - prev_l) <= boundary_near_th

bool ema_break_up =
     key_bar_ok and
     ema_key_ready and
     key_ema_close > key_ema_val and
     nz(key_ema_close[1], key_ema_close) <= nz(key_ema_val[1], key_ema_val)

bool ema_break_down =
     key_bar_ok and
     ema_key_ready and
     key_ema_close < key_ema_val and
     nz(key_ema_close[1], key_ema_close) >= nz(key_ema_val[1], key_ema_val)

bool ema_support =
     key_bar_ok and
     ema_key_ready and
     key_ema_low <= key_ema_val and
     key_ema_close > key_ema_val

bool ema_resist =
     key_bar_ok and
     ema_key_ready and
     key_ema_high >= key_ema_val and
     key_ema_close < key_ema_val

bool ema_near =
     ema_key_ready and
     math.abs(key_ema_close - key_ema_val) <= key_near_th

bool round_break_up = key_bar_ok and round_key_ready and curr_c > round_key and prev_c_main <= round_key
bool round_break_down = key_bar_ok and round_key_ready and curr_c < round_key and prev_c_main >= round_key
bool round_upper_reject = key_bar_ok and round_key_ready and curr_h > round_key and curr_c < round_key
bool round_lower_reclaim = key_bar_ok and round_key_ready and curr_l < round_key and curr_c > round_key
bool round_near = round_key_ready and math.abs(curr_c - round_key) <= key_near_th

string key_observe_text = ""

if not use_key_factor
    key_observe_text := "等待关键位行为"
else
    if lv1h_upper_reject
        key_observe_text := "盘前上边界拒绝｜假突破扫荡｜关注反转K质量"
    else if lv1l_lower_reclaim
        key_observe_text := "盘前下边界回收｜假跌破扫荡｜关注反转K质量"
    else if bomh_upper_reject
        key_observe_text := "BOM上沿拒绝｜关注反转K质量"
    else if boml_lower_reclaim
        key_observe_text := "BOM下沿回收｜关注反转K质量"
    else if or10h_upper_reject
        key_observe_text := "OR10上沿拒绝｜关注反转K质量"
    else if or10l_lower_reclaim
        key_observe_text := "OR10下沿回收｜关注反转K质量"
    else if pdh_upper_reject
        key_observe_text := "PDH上方失守｜反转风险上升"
    else if pdl_lower_reclaim
        key_observe_text := "PDL下方回收｜反转风险上升"
    else if round_upper_reject
        key_observe_text := "整数位" + f_fmt_level(round_key) + "拒绝｜关注反转K质量"
    else if round_lower_reclaim
        key_observe_text := "整数位" + f_fmt_level(round_key) + "回收｜关注反转K质量"
    else if ema_resist
        key_observe_text := "RTH 5m EMA20压制｜关注反抽K质量"
    else if ema_support
        key_observe_text := "RTH 5m EMA20支撑｜关注回踩K质量"

    if key_observe_text == ""
        if lv1h_break_up
            key_observe_text := "盘前上边界突破｜关注回踩K质量"
        else if lv1l_break_down
            key_observe_text := "盘前下边界跌破｜关注反抽K质量"
        else if bomh_break_up
            key_observe_text := "BOM上沿突破｜关注回踩K质量"
        else if boml_break_down
            key_observe_text := "BOM下沿跌破｜关注反抽K质量"
        else if or10h_break_up
            key_observe_text := "OR10上沿突破｜关注回踩K质量"
        else if or10l_break_down
            key_observe_text := "OR10下沿跌破｜关注反抽K质量"
        else if pdh_break_up
            key_observe_text := "PDH突破｜关注回踩K质量"
        else if pdl_break_down
            key_observe_text := "PDL跌破｜关注反抽K质量"
        else if round_break_up
            key_observe_text := "整数位" + f_fmt_level(round_key) + "突破｜关注回踩K质量"
        else if round_break_down
            key_observe_text := "整数位" + f_fmt_level(round_key) + "跌破｜关注反抽K质量"
        else if ema_break_up
            key_observe_text := "站上RTH 5m EMA20｜关注回踩承接"
        else if ema_break_down
            key_observe_text := "跌破RTH 5m EMA20｜关注反抽压制"

    if key_observe_text == ""
        if trend_side > 0
            if lv1h_near
                key_observe_text := "靠近盘前上边界｜看突破/回踩K质量"
            else if or10h_near
                key_observe_text := "靠近OR10上沿｜看突破/回踩K质量"
            else if bomh_near
                key_observe_text := "靠近BOM上沿｜看突破/回踩K质量"
            else if pdh_near
                key_observe_text := "靠近PDH｜看突破/回踩K质量"
            else if ema_near
                key_observe_text := "靠近RTH 5m EMA20｜看回踩/反抽K质量"
            else if round_near
                key_observe_text := "靠近整数位" + f_fmt_level(round_key) + "｜看突破/回踩K质量"
        else if trend_side < 0
            if lv1l_near
                key_observe_text := "靠近盘前下边界｜看跌破/反抽K质量"
            else if or10l_near
                key_observe_text := "靠近OR10下沿｜看跌破/反抽K质量"
            else if boml_near
                key_observe_text := "靠近BOM下沿｜看跌破/反抽K质量"
            else if pdl_near
                key_observe_text := "靠近PDL｜看跌破/反抽K质量"
            else if ema_near
                key_observe_text := "靠近RTH 5m EMA20｜看回踩/反抽K质量"
            else if round_near
                key_observe_text := "靠近整数位" + f_fmt_level(round_key) + "｜看跌破/反抽K质量"
        else
            if lv1h_near
                key_observe_text := "围绕盘前上边界震荡缠绕"
            else if lv1l_near
                key_observe_text := "围绕盘前下边界震荡缠绕"
            else if bomh_near or boml_near
                key_observe_text := "围绕BOM边界震荡缠绕"
            else if or10h_near or or10l_near
                key_observe_text := "围绕OR10边界震荡缠绕"
            else if pdh_near
                key_observe_text := "围绕PDH震荡缠绕"
            else if pdl_near
                key_observe_text := "围绕PDL震荡缠绕"
            else if ema_near
                key_observe_text := "围绕RTH 5m EMA20震荡缠绕"
            else if round_near
                key_observe_text := "围绕整数位" + f_fmt_level(round_key) + "震荡缠绕"

    if key_observe_text == ""
        key_observe_text := "等待"

float key_reversal_risk_raw = 0.0
key_reversal_risk_raw += lv1h_upper_reject ? -35.0 : 0.0
key_reversal_risk_raw += lv1l_lower_reclaim ? 35.0 : 0.0
key_reversal_risk_raw += bomh_upper_reject ? -25.0 : 0.0
key_reversal_risk_raw += boml_lower_reclaim ? 25.0 : 0.0
key_reversal_risk_raw += or10h_upper_reject ? -30.0 : 0.0
key_reversal_risk_raw += or10l_lower_reclaim ? 30.0 : 0.0
key_reversal_risk_raw += pdh_upper_reject ? -35.0 : 0.0
key_reversal_risk_raw += pdl_lower_reclaim ? 35.0 : 0.0
key_reversal_risk_raw += ema_resist ? -20.0 : 0.0
key_reversal_risk_raw += ema_support ? 20.0 : 0.0
key_reversal_risk_raw += round_upper_reject ? -18.0 : 0.0
key_reversal_risk_raw += round_lower_reclaim ? 18.0 : 0.0

float key_trend_confirm_raw = 0.0
key_trend_confirm_raw += lv1h_break_up ? 35.0 : 0.0
key_trend_confirm_raw += lv1l_break_down ? -35.0 : 0.0
key_trend_confirm_raw += bomh_break_up ? 25.0 : 0.0
key_trend_confirm_raw += boml_break_down ? -25.0 : 0.0
key_trend_confirm_raw += or10h_break_up ? 30.0 : 0.0
key_trend_confirm_raw += or10l_break_down ? -30.0 : 0.0
key_trend_confirm_raw += pdh_break_up ? 35.0 : 0.0
key_trend_confirm_raw += pdl_break_down ? -35.0 : 0.0
key_trend_confirm_raw += ema_break_up ? 20.0 : 0.0
key_trend_confirm_raw += ema_break_down ? -20.0 : 0.0
key_trend_confirm_raw += round_break_up ? 18.0 : 0.0
key_trend_confirm_raw += round_break_down ? -18.0 : 0.0

key_reversal_risk = use_key_factor ? f_clamp(key_reversal_risk_raw, -100.0, 100.0) : 0.0
key_trend_confirm = use_key_factor ? f_clamp(key_trend_confirm_raw, -100.0, 100.0) : 0.0

// ============================================================================
// 29. 信号加权 / 降权分层
// ============================================================================
bool same_struct_emotion =
     math.abs(osr_dir_bias) >= 15.0 and
     math.abs(emotion_score) >= 15.0 and
     f_sign(osr_dir_bias) == f_sign(emotion_score)

bool opp_struct_emotion =
     math.abs(osr_dir_bias) >= 15.0 and
     math.abs(emotion_score) >= 15.0 and
     f_sign(osr_dir_bias) != f_sign(emotion_score)

bool emotion_choppy = math.abs(emotion_score) < 20.0 or flow_style == 0

bool key_trend_align =
     math.abs(key_trend_confirm) >= 25.0 and
     math.abs(osr_dir_bias) >= 15.0 and
     f_sign(key_trend_confirm) == f_sign(osr_dir_bias)

bool key_trend_conflict =
     math.abs(key_trend_confirm) >= 25.0 and
     math.abs(osr_dir_bias) >= 15.0 and
     f_sign(key_trend_confirm) != f_sign(osr_dir_bias)

bool key_reversal_against_trend =
     math.abs(key_reversal_risk) >= 25.0 and
     math.abs(osr_dir_bias) >= 15.0 and
     f_sign(key_reversal_risk) != f_sign(osr_dir_bias)

float trend_w_raw = 100.0
trend_w_raw += (osr_expansion - 50.0) * 0.75
trend_w_raw += math.max(math.abs(osr_dir_bias) - 20.0, 0.0) * 0.25

if same_struct_emotion
    trend_w_raw += emotion_strength * 0.35
else if opp_struct_emotion
    trend_w_raw -= emotion_strength * 0.25

if osr_compression >= 60.0 and emotion_choppy
    trend_w_raw -= (osr_compression - 60.0) * 0.50

if key_trend_align
    trend_w_raw += math.min(math.abs(key_trend_confirm), 45.0) * 0.20

if key_reversal_against_trend
    trend_w_raw -= math.min(math.abs(key_reversal_risk), 45.0) * 0.25

if key_trend_conflict
    trend_w_raw -= 8.0

float reversal_w_raw = 100.0
reversal_w_raw += (osr_compression - 50.0) * 0.70
reversal_w_raw += math.abs(osr_bom_reject) * 0.25
reversal_w_raw += math.min(math.abs(key_reversal_risk), 60.0) * 0.25

if same_struct_emotion and osr_expansion >= 60.0
    reversal_w_raw -= emotion_strength * 0.30

if opp_struct_emotion
    reversal_w_raw += math.min(emotion_strength, 40.0) * 0.20

osr_trend_weight = f_clamp(trend_w_raw, 0.0, 200.0)
osr_reversal_weight = f_clamp(reversal_w_raw, 0.0, 200.0)

// ============================================================================
// 30. 执行面板文字：2列4行
// ============================================================================
string row0_left = "当前状态"
string row0_right = f_state_title(osr_state_code) + "｜" + f_state_score_label(osr_state_code, osr_compression, osr_expansion)

string row1_left = "早盘状态"
string row1_right = osr_ready_0940 > 0.5 ? f_state_title(osr_state_code_lock_0940) + "｜" + f_state_score_label(osr_state_code_lock_0940, osr_compression_lock_0940, osr_expansion_lock_0940) : "等待9:40锁定"

string row2_left = "关键位"
string row2_right = key_observe_text

string row3_left = "算法检测"
string row3_right = f_flow_style_name(flow_style, flow_conf_final)

color panel_base_col = f_state_base_color(osr_state_code)
int panel_alpha = f_alpha_from_strength(osr_state_strength, osr_state_code)

color panel_header_col = color.new(panel_base_col, panel_alpha)
color panel_body_bg = color.new(color.black, 30)
color panel_body_bg_2 = color.new(color.black, 24)
color panel_lock_col = osr_ready_0940 > 0.5 ? f_state_base_color(osr_state_code_lock_0940) : color.rgb(92, 96, 100)
color panel_lock_bg = color.new(panel_lock_col, osr_ready_0940 > 0.5 ? 62 : 78)
color lock_text_col = lock_text_color_use_state and osr_ready_0940 > 0.5 ? color.new(panel_lock_col, 0) : body_text_color

// ============================================================================
// 31. 执行面板绘制：2列4行
// ============================================================================
var table osr_panel = table.new(
     f_table_pos(panel_pos),
     2,
     4,
     border_width = 1,
     frame_width = 1,
     border_color = color.new(color.black, 100),
     frame_color = color.new(color.black, 100)
     )

if show_panel and barstate.islast
    table.cell(
         osr_panel,
         0,
         0,
         row0_left,
         text_color = header_text_color,
         bgcolor = panel_header_col,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

    table.cell(
         osr_panel,
         1,
         0,
         row0_right,
         text_color = header_text_color,
         bgcolor = panel_header_col,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

    table.cell(
         osr_panel,
         0,
         1,
         row1_left,
         text_color = body_text_color,
         bgcolor = panel_body_bg_2,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

    table.cell(
         osr_panel,
         1,
         1,
         row1_right,
         text_color = lock_text_col,
         bgcolor = panel_lock_bg,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

    table.cell(
         osr_panel,
         0,
         2,
         row2_left,
         text_color = body_text_color,
         bgcolor = panel_body_bg,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

    table.cell(
         osr_panel,
         1,
         2,
         row2_right,
         text_color = body_text_color,
         bgcolor = panel_body_bg,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

    table.cell(
         osr_panel,
         0,
         3,
         row3_left,
         text_color = body_text_color,
         bgcolor = panel_body_bg_2,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

    table.cell(
         osr_panel,
         1,
         3,
         row3_right,
         text_color = body_text_color,
         bgcolor = panel_body_bg_2,
         text_size = f_text_size(panel_size),
         text_halign = text.align_left
         )

if not show_panel and barstate.islast
    for r = 0 to 3
        for c = 0 to 1
            table.cell(
                 osr_panel,
                 c,
                 r,
                 "",
                 text_color = color.new(color.white, 100),
                 bgcolor = color.new(color.black, 100),
                 text_size = size.tiny
                 )

// ============================================================================
// 32. 隐藏输出：给趋势 / 反转 / 流动性扫荡指标 input.source() 调用
// ============================================================================
plot(osr_compression, title = "OSR_压缩分_0_100", display = display.none)
plot(osr_expansion, title = "OSR_扩张分_0_100", display = display.none)
plot(osr_dir_bias, title = "OSR_方向偏置_-100_100", display = display.none)
plot(osr_bom_reject, title = "OSR_BOM否定分_-100_100", display = display.none)
plot(osr_trend_weight, title = "OSR_趋势加权_0_200", display = display.none)
plot(osr_reversal_weight, title = "OSR_反手扫荡加权_0_200", display = display.none)

plot(osr_state_code, title = "OSR_状态码_5窄震_4宽震_1偏震_3上扩_2偏上扩_-2偏下扩_-3下扩_0不明", display = display.none)
plot(structure_direction_score, title = "OSR_结构方向分_-100_100", display = display.none)
plot(flow_style, title = "OSR_VWAP_TWAP形态_-2TWAP跌_-1VWAP跌_1VWAP涨_2TWAP涨", display = display.none)
plot(flow_conf_final, title = "OSR_VWAP_TWAP形态置信度_0_100", display = display.none)
plot(key_reversal_risk, title = "OSR_关键位反转风险_-100_100", display = display.none)
plot(key_trend_confirm, title = "OSR_关键位趋势旁证_-100_100", display = display.none)

// 9:40锁定输出：下游三个交易信号指标应优先调用这组，而不是实时分数。
plot(osr_compression_lock_0940, title = "OSR_压缩分_LOCK_0940_0_100", display = display.none)
plot(osr_expansion_lock_0940, title = "OSR_扩张分_LOCK_0940_0_100", display = display.none)
plot(osr_ready_0940, title = "OSR_0940_READY_0_1", display = display.none)
plot(osr_rth_bar_seq, title = "OSR_RTH_K序号", display = display.none)
plot(osr_state_code_lock_0940, title = "OSR_状态码_LOCK_0940", display = display.none)
plot(osr_dir_bias_lock_0940, title = "OSR_方向偏置_LOCK_0940_-100_100", display = display.none)
plot(osr_bom_reject_lock_0940, title = "OSR_BOM否定分_LOCK_0940_-100_100", display = display.none)
plot(structure_direction_score_lock_0940, title = "OSR_结构方向分_LOCK_0940_-100_100", display = display.none)

// ============================================================================
// 33. 调试输出：只进数据窗口，不进执行面板
// ============================================================================
plot(show_debug ? compression_raw_safe : na, title = "OSR调试_原始压缩分", display = display.data_window)
plot(show_debug ? compression_rank_today : na, title = "OSR调试_历史压缩分位", display = display.data_window)
plot(show_debug ? pair_l2_l1 : na, title = "OSR调试_LV2_LV1重叠", display = display.data_window)
plot(show_debug ? pair_l1_bom : na, title = "OSR调试_LV1_BOM重叠", display = display.data_window)
plot(show_debug ? pair_l1_or10 : na, title = "OSR调试_LV1_OR10重叠", display = display.data_window)
plot(show_debug ? pair_bom_or10 : na, title = "OSR调试_BOM_OR10重叠", display = display.data_window)
plot(show_debug ? dispersion_score : na, title = "OSR调试_整体分散度", display = display.data_window)
plot(show_debug ? span_prev_pct : na, title = "OSR调试_总包络占昨日RTH区间百分比", display = display.data_window)
plot(show_debug ? emotion_score : na, title = "OSR调试_VWAP_TWAP情绪分_-100_100", display = display.data_window)
plot(show_debug ? flow_conf_final : na, title = "OSR调试_VWAP_TWAP形态置信度", display = display.data_window)
plot(show_debug ? raw_flow_conf : na, title = "OSR调试_VWAP_TWAP原始最高置信度", display = display.data_window)
plot(show_debug ? flow_streak : na, title = "OSR调试_VWAP_TWAP连续确认K数", display = display.data_window)
plot(show_debug ? key_reversal_risk : na, title = "OSR调试_关键位反转风险", display = display.data_window)
plot(show_debug ? key_trend_confirm : na, title = "OSR调试_关键位趋势旁证", display = display.data_window)
plot(show_debug ? add_val : na, title = "OSR调试_ADD当前值", display = display.data_window)
plot(show_debug ? tick_ma : na, title = "OSR调试_TICK均值", display = display.data_window)
plot(show_debug ? vix1d_bar_pct : na, title = "OSR调试_VIX1D短线涨跌幅", display = display.data_window)
plot(show_debug ? spy_vol_ratio : na, title = "OSR调试_SPY成交量比", display = display.data_window)
plot(show_debug ? round_key : na, title = "OSR调试_当前百点整数位", display = display.data_window)
plot(show_debug ? osr_ready_0940 : na, title = "OSR调试_0940_READY", display = display.data_window)
plot(show_debug ? osr_rth_bar_seq : na, title = "OSR调试_RTH_K序号", display = display.data_window)
plot(show_debug ? osr_compression_lock_0940 : na, title = "OSR调试_锁定压缩分", display = display.data_window)
plot(show_debug ? osr_expansion_lock_0940 : na, title = "OSR调试_锁定扩张分", display = display.data_window)
````
