# RS Plate Relative Strength

- url: https://www.tradingview.com/script/oQ2FVHVg/
- type: indicator
- pine_id: PUB;41b6eb130e7f4b12843504f567e1dd16
- version: 1.0

## Description

以spx为基准对比12大板块的相对强弱，和指标的斜率排名

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © linestraw

//@version=6
indicator("RS板块相对强度")

lookback = input(20,'斜率计算周期')

// --- 1. 纯计算函数 (不包含任何 request.security) ---
// 计算加权涨幅 WR
f_calculate_wr(series float s) =>
    float r30  = (s - s[30]) / s[30]
    float r90  = (s - s[90]) / s[90]
    float r180 = (s - s[180]) / s[180]
    float r252 = (s - s[252]) / s[252]
    0.6 * r30 + 0.25 * r90 + 0.1 * r180 + 0.05 * r252

// 计算 Beta
f_calculate_beta(series float s, series float m) =>
    float s_ret = (s - s[1]) / s[1]
    float m_ret = (m - m[1]) / m[1]
    float cov = ta.sma(s_ret * m_ret, 252) - ta.sma(s_ret, 252) * ta.sma(m_ret, 252)
    float market_var = ta.variance(m_ret, 252)
    market_var != 0 ? cov / market_var : 1.0

// 计算 RS Score
f_calculate_rs(series float s, series float m, float m_wr) =>
    float s_wr = f_calculate_wr(s)
    float b    = f_calculate_beta(s, m)
    s_wr - (b * m_wr)

// --- 2. 全局取数 (核心优化：每个标的只 request 一次) ---
// 基础数据请求 (耗费 1 次)
float m_c = request.security("AMEX:SPY", "D", close)
float m_wr = f_calculate_wr(m_c)

// 板块数据请求 (耗费 11 次)
float c_xlk = request.security("AMEX:XLK", "D", close)
float c_xli = request.security("AMEX:XLI", "D", close)
float c_xlp = request.security("AMEX:XLP", "D", close)
float c_xlf = request.security("AMEX:XLF", "D", close)
float c_xlb = request.security("AMEX:XLB", "D", close)
float c_xlre= request.security("AMEX:XLRE", "D", close)
float c_xle = request.security("AMEX:XLE", "D", close)
float c_xlu = request.security("AMEX:XLU", "D", close)
float c_xlc = request.security("AMEX:XLC", "D", close)
float c_xly = request.security("AMEX:XLY", "D", close)
float c_xlv = request.security("AMEX:XLV", "D", close)

// --- 3. 执行纯数学计算 ---
float rs_xlk  = f_calculate_rs(c_xlk,  m_c, m_wr)
float rs_xli  = f_calculate_rs(c_xli,  m_c, m_wr)
float rs_xlp  = f_calculate_rs(c_xlp,  m_c, m_wr)
float rs_xlf  = f_calculate_rs(c_xlf,  m_c, m_wr)
float rs_xlb  = f_calculate_rs(c_xlb,  m_c, m_wr)
float rs_xlre = f_calculate_rs(c_xlre, m_c, m_wr)
float rs_xle  = f_calculate_rs(c_xle,  m_c, m_wr)
float rs_xlu  = f_calculate_rs(c_xlu,  m_c, m_wr)
float rs_xlc  = f_calculate_rs(c_xlc,  m_c, m_wr)
float rs_xly  = f_calculate_rs(c_xly,  m_c, m_wr)
float rs_xlv  = f_calculate_rs(c_xlv,  m_c, m_wr)

//---5.斜率计算---
calc_slope(src) =>
    ta.linreg(src, lookback, 0) - ta.linreg(src, lookback, 1)

slope_xlk = calc_slope(rs_xlk)
slope_xli = calc_slope(rs_xli)
slope_xlp = calc_slope(rs_xlp)
slope_xlf = calc_slope(rs_xlf)
slope_xlb = calc_slope(rs_xlb)
slope_xlre = calc_slope(rs_xlre)
slope_xle = calc_slope(rs_xle)
slope_xlu = calc_slope(rs_xlu)
slope_xlc = calc_slope(rs_xlc)
slope_xly = calc_slope(rs_xly)
slope_xlv = calc_slope(rs_xlv)

//---6.斜率排名---
// --- 2. 创建一个副本并进行降序排列 (从大到小) ---
slope_array = array.from(
    slope_xlk 
    ,slope_xli 
    ,slope_xlp 
    ,slope_xlf 
    ,slope_xlb 
    ,slope_xlre
    ,slope_xle 
    ,slope_xlu 
    ,slope_xlc 
    ,slope_xly 
    ,slope_xlv )
sorted_array = array.copy(slope_array)
array.sort(sorted_array, order.descending)

// --- 3. 定义查询排名的函数 ---
// 在排序后的数组里找原数值的位置，+1 得到名次（1为最强）
get_sector_rank(val, s_arr) =>
    array.indexof(s_arr, val) + 1

// --- 4. 输出每个板块的具体排名 (Rank) ---
rank_xlk = get_sector_rank(slope_xlk, sorted_array)
rank_xli = get_sector_rank(slope_xli, sorted_array)
rank_xlp = get_sector_rank(slope_xlp, sorted_array)
rank_xlf = get_sector_rank(slope_xlf, sorted_array)
rank_xlb = get_sector_rank(slope_xlb, sorted_array)
rank_xle = get_sector_rank(slope_xle, sorted_array)
rank_xlu = get_sector_rank(slope_xlu, sorted_array)
rank_xlc = get_sector_rank(slope_xlc, sorted_array)
rank_xly = get_sector_rank(slope_xly, sorted_array)
rank_xlv = get_sector_rank(slope_xlv, sorted_array)
rank_xlre = get_sector_rank(slope_xlre,sorted_array)

// --- 5. 根据排名分配 LineWidth (线宽变量) ---
// 逻辑：第1-2名=4, 第3-5名=3, 第6-8名=2, 其余=1
calc_width(r) =>
    r <= 2 ? 0 : r <= 5 ? 60 : r <= 8 ? 80 : 95

i_xlk = calc_width(rank_xlk)
i_xli = calc_width(rank_xli)
i_xlp = calc_width(rank_xlp)
i_xlf = calc_width(rank_xlf)
i_xlb = calc_width(rank_xlb)
i_xle = calc_width(rank_xle)
i_xlu = calc_width(rank_xlu)
i_xlc = calc_width(rank_xlc)
i_xly = calc_width(rank_xly)
i_xlv = calc_width(rank_xlv)
i_xlre = calc_width(rank_xlre)

// --- 4. 绘图（增加中文板块名称） ---
plot(rs_xlk*100,  title="XLK-信息科技", color=color.rgb(11, 247, 247, i_xlk))
plot(rs_xlc*100,  title="XLC-通信服务", color=color.rgb(115, 255, 0, i_xlc))
plot(rs_xly*100,  title="XLY-非必需消费", color=color.rgb(255, 230, 0, i_xly))
plot(rs_xlf*100,  title="XLF-金融",     color=color.rgb(0, 255, 55, i_xlf))
plot(rs_xle*100,  title="XLE-能源",     color=color.rgb(0, 162, 255, i_xle))
plot(rs_xlv*100,  title="XLV-医疗保健", color=color.rgb(255, 0, 0, i_xlv))
plot(rs_xli*100,  title="XLI-工业",     color=color.rgb(255, 81, 0, i_xli))
plot(rs_xlp*100,  title="XLP-必需消费", color=color.rgb(255, 238, 0, i_xlp))
plot(rs_xlu*100,  title="XLU-公用事业", color=color.rgb(255, 145, 0, i_xlu))
plot(rs_xlre*100, title="XLRE-房地产",  color=color.rgb(0, 255, 13, i_xlre))
plot(rs_xlb*100,  title="XLB-基础材料", color=color.rgb(255, 136, 0, i_xlb))

// 零轴基准线
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)

//表格提示
// ==================== 排名展示表格模块 (修正版) ====================

// --- 1. 数据映射 ---
string[] t_names = array.from("XLK-信息科技", "XLI-工业", "XLP-必需消费", "XLF-金融", "XLB-基础材料", "XLE-能源", "XLU-公用事业", "XLC-通信服务", "XLY-非必需消费", "XLV-医疗保健", "XLRE-房地产")
int[]    t_ranks = array.from(rank_xlk, rank_xli, rank_xlp, rank_xlf, rank_xlb, rank_xle, rank_xlu, rank_xlc, rank_xly, rank_xlv, rank_xlre)

// --- 2. 提取前五名 ---
// 初始为空字符串
var string r1_name = ""
var string r2_name = ""
var string r3_name = ""
var string r4_name = ""
var string r5_name = ""

// 使用标准的 if-else 缩进块，彻底解决 => 报错问题
for i = 0 to array.size(t_ranks) - 1
    int r = array.get(t_ranks, i)
    string n = array.get(t_names, i)
    if r == 1
        r1_name := n
    else if r == 2
        r2_name := n
    else if r == 3
        r3_name := n
    else if r == 4
        r4_name := n
    else if r == 5
        r5_name := n

// --- 3. 创建并绘制表格 ---
// 使用 var 确保表格只创建一次
var table rank_display = table.new(position.bottom_center, 5, 2, border_width = 1, border_color = color.gray)

if barstate.islast
    // 第一行：表头（显示名次）
    table.cell(rank_display, 0, 0, "TOP 1", bgcolor = color.new(color.red, 30),   text_color = color.white, text_size = size.small)
    table.cell(rank_display, 1, 0, "TOP 2", bgcolor = color.new(color.orange, 30), text_color = color.white, text_size = size.small)
    table.cell(rank_display, 2, 0, "TOP 3", bgcolor = color.new(color.green, 30),  text_color = color.white, text_size = size.small)
    table.cell(rank_display, 3, 0, "TOP 4", bgcolor = color.new(color.blue, 30),   text_color = color.white, text_size = size.small)
    table.cell(rank_display, 4, 0, "TOP 5", bgcolor = color.new(color.gray, 30),   text_color = color.white, text_size = size.small)

    // 第二行：板块名称
    table.cell(rank_display, 0, 1, r1_name, text_color = color.yellow, text_size = size.normal)
    table.cell(rank_display, 1, 1, r2_name, text_color = color.yellow, text_size = size.normal)
    table.cell(rank_display, 2, 1, r3_name, text_color = color.white,  text_size = size.normal)
    table.cell(rank_display, 3, 1, r4_name, text_color = color.white,  text_size = size.normal)
    table.cell(rank_display, 4, 1, r5_name, text_color = color.white,  text_size = size.normal)
````
