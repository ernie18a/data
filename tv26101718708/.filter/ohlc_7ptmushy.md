# OHLC

- url: https://www.tradingview.com/script/7PTMUShy/
- type: indicator
- pine_id: PUB;bc5906efe8354fd69f3af5780ae707f7
- version: 1.0

## Description

高开低收价水平线

## Source Code

````pine
//@version=5
indicator("OHLC", overlay=true)

// ==== 输入参数 ====
// 昨日
bool showYesterday = input.bool(true, "显示昨日线条", group="昨日 OHLC")
bool yH_show = input.bool(true, "昨日高点", group="昨日 OHLC", inline="y2")
color yH_col = input.color(color.red, "", group="昨日 OHLC", inline="y2")
int yH_width = input.int(2, "", minval=1, maxval=5, group="昨日 OHLC", inline="y2")
string yH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="昨日 OHLC", inline="y2")
bool yL_show = input.bool(true, "昨日低点", group="昨日 OHLC", inline="y3")
color yL_col = input.color(color.green, "", group="昨日 OHLC", inline="y3")
int yL_width = input.int(2, "", minval=1, maxval=5, group="昨日 OHLC", inline="y3")
string yL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="昨日 OHLC", inline="y3")
bool yO_show = input.bool(true, "昨日开盘", group="昨日 OHLC", inline="y1")
color yO_col = input.color(color.yellow, "", group="昨日 OHLC", inline="y1")
int yO_width = input.int(2, "", minval=1, maxval=5, group="昨日 OHLC", inline="y1")
string yO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="昨日 OHLC", inline="y1")
bool yC_show = input.bool(true, "昨日收盘", group="昨日 OHLC", inline="y4")
color yC_col = input.color(color.orange, "", group="昨日 OHLC", inline="y4")
int yC_width = input.int(2, "", minval=1, maxval=5, group="昨日 OHLC", inline="y4")
string yC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="昨日 OHLC", inline="y4")
bool yM_show = input.bool(true, "昨日开收盘中点", group="昨日 OHLC", inline="y5")
color yM_col = input.color(color.blue, "", group="昨日 OHLC", inline="y5")
int yM_width = input.int(2, "", minval=1, maxval=5, group="昨日 OHLC", inline="y5")
string yM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="昨日 OHLC", inline="y5")
bool yHL_M_show = input.bool(true, "昨日高低点中点", group="昨日 OHLC", inline="y6")
color yHL_M_col = input.color(color.blue, "", group="昨日 OHLC", inline="y6")
int yHL_M_width = input.int(2, "", minval=1, maxval=5, group="昨日 OHLC", inline="y6")
string yHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="昨日 OHLC", inline="y6")

// 今日
bool showToday = input.bool(true, "显示今日线条", group="今日 OHLC")
bool tH_show = input.bool(true, "今日高点", group="今日 OHLC", inline="t2")
color tH_col = input.color(color.red, "", group="今日 OHLC", inline="t2")
int tH_width = input.int(2, "", minval=1, maxval=5, group="今日 OHLC", inline="t2")
string tH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="今日 OHLC", inline="t2")
bool tL_show = input.bool(true, "今日低点", group="今日 OHLC", inline="t3")
color tL_col = input.color(color.green, "", group="今日 OHLC", inline="t3")
int tL_width = input.int(2, "", minval=1, maxval=5, group="今日 OHLC", inline="t3")
string tL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="今日 OHLC", inline="t3")
bool tO_show = input.bool(true, "今日开盘", group="今日 OHLC", inline="t1")
color tO_col = input.color(color.yellow, "", group="今日 OHLC", inline="t1")
int tO_width = input.int(2, "", minval=1, maxval=5, group="今日 OHLC", inline="t1")
string tO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="今日 OHLC", inline="t1")
bool tC_show = input.bool(true, "今日收盘", group="今日 OHLC", inline="t4")
color tC_col = input.color(color.orange, "", group="今日 OHLC", inline="t4")
int tC_width = input.int(2, "", minval=1, maxval=5, group="今日 OHLC", inline="t4")
string tC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="今日 OHLC", inline="t4")
bool tM_show = input.bool(true, "今日开收盘中点", group="今日 OHLC", inline="t5")
color tM_col = input.color(color.blue, "", group="今日 OHLC", inline="t5")
int tM_width = input.int(2, "", minval=1, maxval=5, group="今日 OHLC", inline="t5")
string tM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="今日 OHLC", inline="t5")
bool tHL_M_show = input.bool(true, "今日高低点中点", group="今日 OHLC", inline="t6")
color tHL_M_col = input.color(color.blue, "", group="今日 OHLC", inline="t6")
int tHL_M_width = input.int(2, "", minval=1, maxval=5, group="今日 OHLC", inline="t6")
string tHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="今日 OHLC", inline="t6")

// 本周
bool showThisWeek = input.bool(true, "显示本周线条", group="本周 OHLC")
bool wH_show = input.bool(true, "本周高点", group="本周 OHLC", inline="w2")
color wH_col = input.color(color.red, "", group="本周 OHLC", inline="w2")
int wH_width = input.int(2, "", minval=1, maxval=5, group="本周 OHLC", inline="w2")
string wH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本周 OHLC", inline="w2")
bool wL_show = input.bool(true, "本周低点", group="本周 OHLC", inline="w3")
color wL_col = input.color(color.green, "", group="本周 OHLC", inline="w3")
int wL_width = input.int(2, "", minval=1, maxval=5, group="本周 OHLC", inline="w3")
string wL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本周 OHLC", inline="w3")
bool wO_show = input.bool(true, "本周开盘", group="本周 OHLC", inline="w1")
color wO_col = input.color(color.yellow, "", group="本周 OHLC", inline="w1")
int wO_width = input.int(2, "", minval=1, maxval=5, group="本周 OHLC", inline="w1")
string wO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本周 OHLC", inline="w1")
bool wC_show = input.bool(true, "本周收盘", group="本周 OHLC", inline="w4")
color wC_col = input.color(color.orange, "", group="本周 OHLC", inline="w4")
int wC_width = input.int(2, "", minval=1, maxval=5, group="本周 OHLC", inline="w4")
string wC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本周 OHLC", inline="w4")
bool wM_show = input.bool(true, "本周开收盘中点", group="本周 OHLC", inline="w5")
color wM_col = input.color(color.blue, "", group="本周 OHLC", inline="w5")
int wM_width = input.int(2, "", minval=1, maxval=5, group="本周 OHLC", inline="w5")
string wM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本周 OHLC", inline="w5")
bool wHL_M_show = input.bool(true, "本周高低点中点", group="本周 OHLC", inline="w6")
color wHL_M_col = input.color(color.blue, "", group="本周 OHLC", inline="w6")
int wHL_M_width = input.int(2, "", minval=1, maxval=5, group="本周 OHLC", inline="w6")
string wHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本周 OHLC", inline="w6")

// 上周
bool showLastWeek = input.bool(true, "显示上周线条", group="上周 OHLC")
bool lwH_show = input.bool(true, "上周高点", group="上周 OHLC", inline="lw2")
color lwH_col = input.color(color.red, "", group="上周 OHLC", inline="lw2")
int lwH_width = input.int(2, "", minval=1, maxval=5, group="上周 OHLC", inline="lw2")
string lwH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上周 OHLC", inline="lw2")
bool lwL_show = input.bool(true, "上周低点", group="上周 OHLC", inline="lw3")
color lwL_col = input.color(color.green, "", group="上周 OHLC", inline="lw3")
int lwL_width = input.int(2, "", minval=1, maxval=5, group="上周 OHLC", inline="lw3")
string lwL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上周 OHLC", inline="lw3")
bool lwO_show = input.bool(true, "上周开盘", group="上周 OHLC", inline="lw1")
color lwO_col = input.color(color.yellow, "", group="上周 OHLC", inline="lw1")
int lwO_width = input.int(2, "", minval=1, maxval=5, group="上周 OHLC", inline="lw1")
string lwO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上周 OHLC", inline="lw1")
bool lwC_show = input.bool(true, "上周收盘", group="上周 OHLC", inline="lw4")
color lwC_col = input.color(color.orange, "", group="上周 OHLC", inline="lw4")
int lwC_width = input.int(2, "", minval=1, maxval=5, group="上周 OHLC", inline="lw4")
string lwC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上周 OHLC", inline="lw4")
bool lwM_show = input.bool(true, "上周开收盘中点", group="上周 OHLC", inline="lw5")
color lwM_col = input.color(color.blue, "", group="上周 OHLC", inline="lw5")
int lwM_width = input.int(2, "", minval=1, maxval=5, group="上周 OHLC", inline="lw5")
string lwM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上周 OHLC", inline="lw5")
bool lwHL_M_show = input.bool(true, "上周高低点中点", group="上周 OHLC", inline="lw6")
color lwHL_M_col = input.color(color.blue, "", group="上周 OHLC", inline="lw6")
int lwHL_M_width = input.int(2, "", minval=1, maxval=5, group="上周 OHLC", inline="lw6")
string lwHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上周 OHLC", inline="lw6")

// 本月
bool showThisMonth = input.bool(true, "显示本月线条", group="本月 OHLC")
bool mH_show = input.bool(true, "本月高点", group="本月 OHLC", inline="m2")
color mH_col = input.color(color.red, "", group="本月 OHLC", inline="m2")
int mH_width = input.int(2, "", minval=1, maxval=5, group="本月 OHLC", inline="m2")
string mH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本月 OHLC", inline="m2")
bool mL_show = input.bool(true, "本月低点", group="本月 OHLC", inline="m3")
color mL_col = input.color(color.green, "", group="本月 OHLC", inline="m3")
int mL_width = input.int(2, "", minval=1, maxval=5, group="本月 OHLC", inline="m3")
string mL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本月 OHLC", inline="m3")
bool mO_show = input.bool(true, "本月开盘", group="本月 OHLC", inline="m1")
color mO_col = input.color(color.yellow, "", group="本月 OHLC", inline="m1")
int mO_width = input.int(2, "", minval=1, maxval=5, group="本月 OHLC", inline="m1")
string mO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本月 OHLC", inline="m1")
bool mC_show = input.bool(true, "本月收盘", group="本月 OHLC", inline="m4")
color mC_col = input.color(color.orange, "", group="本月 OHLC", inline="m4")
int mC_width = input.int(2, "", minval=1, maxval=5, group="本月 OHLC", inline="m4")
string mC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本月 OHLC", inline="m4")
bool mM_show = input.bool(true, "本月开收盘中点", group="本月 OHLC", inline="m5")
color mM_col = input.color(color.blue, "", group="本月 OHLC", inline="m5")
int mM_width = input.int(2, "", minval=1, maxval=5, group="本月 OHLC", inline="m5")
string mM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本月 OHLC", inline="m5")
bool mHL_M_show = input.bool(true, "本月高低点中点", group="本月 OHLC", inline="m6")
color mHL_M_col = input.color(color.blue, "", group="本月 OHLC", inline="m6")
int mHL_M_width = input.int(2, "", minval=1, maxval=5, group="本月 OHLC", inline="m6")
string mHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本月 OHLC", inline="m6")

// 上月
bool showLastMonth = input.bool(true, "显示上月线条", group="上月 OHLC")
bool lmH_show = input.bool(true, "上月高点", group="上月 OHLC", inline="lm2")
color lmH_col = input.color(color.red, "", group="上月 OHLC", inline="lm2")
int lmH_width = input.int(2, "", minval=1, maxval=5, group="上月 OHLC", inline="lm2")
string lmH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上月 OHLC", inline="lm2")
bool lmL_show = input.bool(true, "上月低点", group="上月 OHLC", inline="lm3")
color lmL_col = input.color(color.green, "", group="上月 OHLC", inline="lm3")
int lmL_width = input.int(2, "", minval=1, maxval=5, group="上月 OHLC", inline="lm3")
string lmL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上月 OHLC", inline="lm3")
bool lmO_show = input.bool(true, "上月开盘", group="上月 OHLC", inline="lm1")
color lmO_col = input.color(color.yellow, "", group="上月 OHLC", inline="lm1")
int lmO_width = input.int(2, "", minval=1, maxval=5, group="上月 OHLC", inline="lm1")
string lmO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上月 OHLC", inline="lm1")
bool lmC_show = input.bool(true, "上月收盘", group="上月 OHLC", inline="lm4")
color lmC_col = input.color(color.orange, "", group="上月 OHLC", inline="lm4")
int lmC_width = input.int(2, "", minval=1, maxval=5, group="上月 OHLC", inline="lm4")
string lmC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上月 OHLC", inline="lm4")
bool lmM_show = input.bool(true, "上月开收盘中点", group="上月 OHLC", inline="lm5")
color lmM_col = input.color(color.blue, "", group="上月 OHLC", inline="lm5")
int lmM_width = input.int(2, "", minval=1, maxval=5, group="上月 OHLC", inline="lm5")
string lmM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上月 OHLC", inline="lm5")
bool lmHL_M_show = input.bool(true, "上月高低点中点", group="上月 OHLC", inline="lm6")
color lmHL_M_col = input.color(color.blue, "", group="上月 OHLC", inline="lm6")
int lmHL_M_width = input.int(2, "", minval=1, maxval=5, group="上月 OHLC", inline="lm6")
string lmHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上月 OHLC", inline="lm6")

// 本季
bool showThisQuarter = input.bool(true, "显示本季线条", group="本季 OHLC")
bool qH_show = input.bool(true, "本季高点", group="本季 OHLC", inline="q2")
color qH_col = input.color(color.red, "", group="本季 OHLC", inline="q2")
int qH_width = input.int(2, "", minval=1, maxval=5, group="本季 OHLC", inline="q2")
string qH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本季 OHLC", inline="q2")
bool qL_show = input.bool(true, "本季低点", group="本季 OHLC", inline="q3")
color qL_col = input.color(color.green, "", group="本季 OHLC", inline="q3")
int qL_width = input.int(2, "", minval=1, maxval=5, group="本季 OHLC", inline="q3")
string qL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本季 OHLC", inline="q3")
bool qO_show = input.bool(true, "本季开盘", group="本季 OHLC", inline="q1")
color qO_col = input.color(color.yellow, "", group="本季 OHLC", inline="q1")
int qO_width = input.int(2, "", minval=1, maxval=5, group="本季 OHLC", inline="q1")
string qO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本季 OHLC", inline="q1")
bool qC_show = input.bool(true, "本季收盘", group="本季 OHLC", inline="q4")
color qC_col = input.color(color.orange, "", group="本季 OHLC", inline="q4")
int qC_width = input.int(2, "", minval=1, maxval=5, group="本季 OHLC", inline="q4")
string qC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本季 OHLC", inline="q4")
bool qM_show = input.bool(true, "本季开收盘中点", group="本季 OHLC", inline="q5")
color qM_col = input.color(color.blue, "", group="本季 OHLC", inline="q5")
int qM_width = input.int(2, "", minval=1, maxval=5, group="本季 OHLC", inline="q5")
string qM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本季 OHLC", inline="q5")
bool qHL_M_show = input.bool(true, "本季高低点中点", group="本季 OHLC", inline="q6")
color qHL_M_col = input.color(color.blue, "", group="本季 OHLC", inline="q6")
int qHL_M_width = input.int(2, "", minval=1, maxval=5, group="本季 OHLC", inline="q6")
string qHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本季 OHLC", inline="q6")

// 上季
bool showLastQuarter = input.bool(true, "显示上季线条", group="上季 OHLC")
bool lqH_show = input.bool(true, "上季高点", group="上季 OHLC", inline="lq2")
color lqH_col = input.color(color.red, "", group="上季 OHLC", inline="lq2")
int lqH_width = input.int(2, "", minval=1, maxval=5, group="上季 OHLC", inline="lq2")
string lqH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上季 OHLC", inline="lq2")
bool lqL_show = input.bool(true, "上季低点", group="上季 OHLC", inline="lq3")
color lqL_col = input.color(color.green, "", group="上季 OHLC", inline="lq3")
int lqL_width = input.int(2, "", minval=1, maxval=5, group="上季 OHLC", inline="lq3")
string lqL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上季 OHLC", inline="lq3")
bool lqO_show = input.bool(true, "上季开盘", group="上季 OHLC", inline="lq1")
color lqO_col = input.color(color.yellow, "", group="上季 OHLC", inline="lq1")
int lqO_width = input.int(2, "", minval=1, maxval=5, group="上季 OHLC", inline="lq1")
string lqO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上季 OHLC", inline="lq1")
bool lqC_show = input.bool(true, "上季收盘", group="上季 OHLC", inline="lq4")
color lqC_col = input.color(color.orange, "", group="上季 OHLC", inline="lq4")
int lqC_width = input.int(2, "", minval=1, maxval=5, group="上季 OHLC", inline="lq4")
string lqC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上季 OHLC", inline="lq4")
bool lqM_show = input.bool(true, "上季开收盘中点", group="上季 OHLC", inline="lq5")
color lqM_col = input.color(color.blue, "", group="上季 OHLC", inline="lq5")
int lqM_width = input.int(2, "", minval=1, maxval=5, group="上季 OHLC", inline="lq5")
string lqM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上季 OHLC", inline="lq5")
bool lqHL_M_show = input.bool(true, "上季高低点中点", group="上季 OHLC", inline="lq6")
color lqHL_M_col = input.color(color.blue, "", group="上季 OHLC", inline="lq6")
int lqHL_M_width = input.int(2, "", minval=1, maxval=5, group="上季 OHLC", inline="lq6")
string lqHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="上季 OHLC", inline="lq6")

// 本年
bool showThisYear = input.bool(true, "显示本年线条", group="本年 OHLC")
bool yrH_show = input.bool(true, "本年高点", group="本年 OHLC", inline="yr2")
color yrH_col = input.color(color.red, "", group="本年 OHLC", inline="yr2")
int yrH_width = input.int(2, "", minval=1, maxval=5, group="本年 OHLC", inline="yr2")
string yrH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本年 OHLC", inline="yr2")
bool yrL_show = input.bool(true, "本年低点", group="本年 OHLC", inline="yr3")
color yrL_col = input.color(color.green, "", group="本年 OHLC", inline="yr3")
int yrL_width = input.int(2, "", minval=1, maxval=5, group="本年 OHLC", inline="yr3")
string yrL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本年 OHLC", inline="yr3")
bool yrO_show = input.bool(true, "本年开盘", group="本年 OHLC", inline="yr1")
color yrO_col = input.color(color.yellow, "", group="本年 OHLC", inline="yr1")
int yrO_width = input.int(2, "", minval=1, maxval=5, group="本年 OHLC", inline="yr1")
string yrO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本年 OHLC", inline="yr1")
bool yrC_show = input.bool(true, "本年收盘", group="本年 OHLC", inline="yr4")
color yrC_col = input.color(color.orange, "", group="本年 OHLC", inline="yr4")
int yrC_width = input.int(2, "", minval=1, maxval=5, group="本年 OHLC", inline="yr4")
string yrC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本年 OHLC", inline="yr4")
bool yrM_show = input.bool(true, "本年开收盘中点", group="本年 OHLC", inline="yr5")
color yrM_col = input.color(color.blue, "", group="本年 OHLC", inline="yr5")
int yrM_width = input.int(2, "", minval=1, maxval=5, group="本年 OHLC", inline="yr5")
string yrM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本年 OHLC", inline="yr5")
bool yrHL_M_show = input.bool(true, "本年高低点中点", group="本年 OHLC", inline="yr6")
color yrHL_M_col = input.color(color.blue, "", group="本年 OHLC", inline="yr6")
int yrHL_M_width = input.int(2, "", minval=1, maxval=5, group="本年 OHLC", inline="yr6")
string yrHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="本年 OHLC", inline="yr6")

// 去年
bool showLastYear = input.bool(true, "显示去年线条", group="去年 OHLC")
bool lyrH_show = input.bool(true, "去年高点", group="去年 OHLC", inline="lyr2")
color lyrH_col = input.color(color.red, "", group="去年 OHLC", inline="lyr2")
int lyrH_width = input.int(2, "", minval=1, maxval=5, group="去年 OHLC", inline="lyr2")
string lyrH_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="去年 OHLC", inline="lyr2")
bool lyrL_show = input.bool(true, "去年低点", group="去年 OHLC", inline="lyr3")
color lyrL_col = input.color(color.green, "", group="去年 OHLC", inline="lyr3")
int lyrL_width = input.int(2, "", minval=1, maxval=5, group="去年 OHLC", inline="lyr3")
string lyrL_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="去年 OHLC", inline="lyr3")
bool lyrO_show = input.bool(true, "去年开盘", group="去年 OHLC", inline="lyr1")
color lyrO_col = input.color(color.yellow, "", group="去年 OHLC", inline="lyr1")
int lyrO_width = input.int(2, "", minval=1, maxval=5, group="去年 OHLC", inline="lyr1")
string lyrO_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="去年 OHLC", inline="lyr1")
bool lyrC_show = input.bool(true, "去年收盘", group="去年 OHLC", inline="lyr4")
color lyrC_col = input.color(color.orange, "", group="去年 OHLC", inline="lyr4")
int lyrC_width = input.int(2, "", minval=1, maxval=5, group="去年 OHLC", inline="lyr4")
string lyrC_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="去年 OHLC", inline="lyr4")
bool lyrM_show = input.bool(true, "去年开收盘中点", group="去年 OHLC", inline="lyr5")
color lyrM_col = input.color(color.blue, "", group="去年 OHLC", inline="lyr5")
int lyrM_width = input.int(2, "", minval=1, maxval=5, group="去年 OHLC", inline="lyr5")
string lyrM_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="去年 OHLC", inline="lyr5")
bool lyrHL_M_show = input.bool(true, "去年高低点中点", group="去年 OHLC", inline="lyr6")
color lyrHL_M_col = input.color(color.blue, "", group="去年 OHLC", inline="lyr6")
int lyrHL_M_width = input.int(2, "", minval=1, maxval=5, group="去年 OHLC", inline="lyr6")
string lyrHL_M_style_input = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group="去年 OHLC", inline="lyr6")

// 附加功能
bool showLabels = input.bool(true, "显示价格标签", group="附加功能")
string labelSize = input.string("Small", "标签大小", options=["Small", "Normal", "Large"], group="附加功能")

// ==== 辅助函数 ====
f_line_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : na

f_set_or_new(_x1, _y1, _x2, _y2, _col, _w, _style, _ln) =>
    _tmp = na(_ln) ? line.new(_x1, _y1, _x2, _y2, xloc.bar_time, extend.none, _col, _style, _w) : _ln
    if not na(_ln)
        line.set_xy1(_tmp, _x1, _y1)
        line.set_xy2(_tmp, _x2, _y2)
        line.set_color(_tmp, _col)
        line.set_width(_tmp, _w)
        line.set_style(_tmp, _style)
    _tmp

f_delete_line(_ln) =>
    if not na(_ln)
        line.delete(_ln)
    line(na)

f_manage_label(_lbl, _x, _y, _text, _col, _show_cond) =>
    if _show_cond
        _style = label.style_label_left
        _tcolor = _col
        _size = labelSize == "Small" ? size.small : labelSize == "Normal" ? size.normal : size.large
        if na(_lbl) or ta.change(time("D"))
            label.delete(_lbl)
            label.new(_x, _y, _text, xloc.bar_time, yloc.price, color=color.new(color.white, 100), textcolor=_tcolor, size=_size, style=_style, tooltip=_text)
        else
            label.set_xy(_lbl, _x, _y)
            label.set_text(_lbl, _text)
            label.set_textcolor(_lbl, _tcolor)
            label.set_size(_lbl, _size)
            _lbl
    else
        if not na(_lbl)
            label.delete(_lbl)
        label(na)

// 转换线条样式
var yH_style = f_line_style(yH_style_input)
var yL_style = f_line_style(yL_style_input)
var yO_style = f_line_style(yO_style_input)
var yC_style = f_line_style(yC_style_input)
var yM_style = f_line_style(yM_style_input)
var yHL_M_style = f_line_style(yHL_M_style_input)
var tH_style = f_line_style(tH_style_input)
var tL_style = f_line_style(tL_style_input)
var tO_style = f_line_style(tO_style_input)
var tC_style = f_line_style(tC_style_input)
var tM_style = f_line_style(tM_style_input)
var tHL_M_style = f_line_style(tHL_M_style_input)
var wH_style = f_line_style(wH_style_input)
var wL_style = f_line_style(wL_style_input)
var wO_style = f_line_style(wO_style_input)
var wC_style = f_line_style(wC_style_input)
var wM_style = f_line_style(wM_style_input)
var wHL_M_style = f_line_style(wHL_M_style_input)
var lwH_style = f_line_style(lwH_style_input)
var lwL_style = f_line_style(lwL_style_input)
var lwO_style = f_line_style(lwO_style_input)
var lwC_style = f_line_style(lwC_style_input)
var lwM_style = f_line_style(lwM_style_input)
var lwHL_M_style = f_line_style(lwHL_M_style_input)
var mH_style = f_line_style(mH_style_input)
var mL_style = f_line_style(mL_style_input)
var mO_style = f_line_style(mO_style_input)
var mC_style = f_line_style(mC_style_input)
var mM_style = f_line_style(mM_style_input)
var mHL_M_style = f_line_style(mHL_M_style_input)
var lmH_style = f_line_style(lmH_style_input)
var lmL_style = f_line_style(lmL_style_input)
var lmO_style = f_line_style(lmO_style_input)
var lmC_style = f_line_style(lmC_style_input)
var lmM_style = f_line_style(lmM_style_input)
var lmHL_M_style = f_line_style(lmHL_M_style_input)
var qH_style = f_line_style(qH_style_input)
var qL_style = f_line_style(qL_style_input)
var qO_style = f_line_style(qO_style_input)
var qC_style = f_line_style(qC_style_input)
var qM_style = f_line_style(qM_style_input)
var qHL_M_style = f_line_style(qHL_M_style_input)
var lqH_style = f_line_style(lqH_style_input)
var lqL_style = f_line_style(lqL_style_input)
var lqO_style = f_line_style(lqO_style_input)
var lqC_style = f_line_style(lqC_style_input)
var lqM_style = f_line_style(lqM_style_input)
var lqHL_M_style = f_line_style(lqHL_M_style_input)
var yrH_style = f_line_style(yrH_style_input)
var yrL_style = f_line_style(yrL_style_input)
var yrO_style = f_line_style(yrO_style_input)
var yrC_style = f_line_style(yrC_style_input)
var yrM_style = f_line_style(yrM_style_input)
var yrHL_M_style = f_line_style(yrHL_M_style_input)
var lyrH_style = f_line_style(lyrH_style_input)
var lyrL_style = f_line_style(lyrL_style_input)
var lyrO_style = f_line_style(lyrO_style_input)
var lyrC_style = f_line_style(lyrC_style_input)
var lyrM_style = f_line_style(lyrM_style_input)
var lyrHL_M_style = f_line_style(lyrHL_M_style_input)

// ==== 获取所有时间框架的 OHLC 数据及发生时间 ====
f_get_hl_time(tf, is_previous) =>
    [o, h, l, c, t, t_close] = request.security(syminfo.tickerid, tf, [open[is_previous ? 1 : 0], high[is_previous ? 1 : 0], low[is_previous ? 1 : 0], close[is_previous ? 1 : 0], time[is_previous ? 1 : 0], time_close[is_previous ? 1 : 0]], lookahead=barmerge.lookahead_on)
    period_bars = timeframe.in_seconds(tf) / timeframe.in_seconds(timeframe.period)
    h_offset = ta.highestbars(high, int(period_bars))[is_previous ? 1 : 0]
    l_offset = ta.lowestbars(low, int(period_bars))[is_previous ? 1 : 0]
    h_time = request.security(syminfo.tickerid, tf, time[h_offset])[is_previous ? 1 : 0]
    l_time = request.security(syminfo.tickerid, tf, time[l_offset])[is_previous ? 1 : 0]
    [o, h, l, c, t, h_time, l_time, t_close]

// 昨日
[yO, yH, yL, yC, yO_time, yH_time, yL_time, yC_time] = f_get_hl_time("D", true)
// 今日
[tO, tH, tL, tC, tO_time, tH_time, tL_time, tC_time] = f_get_hl_time("D", false)
// 本周
[wO, wH, wL, wC, wO_time, wH_time, wL_time, wC_time] = f_get_hl_time("W", false)
// 上周
[lwO, lwH, lwL, lwC, lwO_time, lwH_time, lwL_time, lwC_time] = f_get_hl_time("W", true)
// 本月
[mO, mH, mL, mC, mO_time, mH_time, mL_time, mC_time] = f_get_hl_time("M", false)
// 上月
[lmO, lmH, lmL, lmC, lmO_time, lmH_time, lmL_time, lmC_time] = f_get_hl_time("M", true)
// 本季
[qO, qH, qL, qC, qO_time, qH_time, qL_time, qC_time] = f_get_hl_time("3M", false)
// 上季
[lqO, lqH, lqL, lqC, lqO_time, lqH_time, lqL_time, lqC_time] = f_get_hl_time("3M", true)
// 本年
[yrO, yrH, yrL, yrC, yrO_time, yrH_time, yrL_time, yrC_time] = f_get_hl_time("12M", false)
// 去年
[lyrO, lyrH, lyrL, lyrC, lyrO_time, lyrH_time, lyrL_time, lyrC_time] = f_get_hl_time("12M", true)

// 计算中点
yM = (yO + yC) / 2
tM = (tO + tC) / 2
wM = (wO + wC) / 2
lwM = (lwO + lwC) / 2
mM = (mO + mC) / 2
lmM = (lmO + lmC) / 2
qM = (qO + qC) / 2
lqM = (lqO + lqC) / 2
yrM = (yrO + yrC) / 2
lyrM = (lyrO + lyrC) / 2

yHL_M = (yH + yL) / 2
tHL_M = (tH + tL) / 2
wHL_M = (wH + wL) / 2
lwHL_M = (lwH + lwL) / 2
mHL_M = (mH + mL) / 2
lmHL_M = (lmH + lmL) / 2
qHL_M = (qH + qL) / 2
lqHL_M = (lqH + lqL) / 2
yrHL_M = (yrH + yrL) / 2
lyrHL_M = (lyrH + lyrL) / 2

// 中点线起点时间（开收盘中点使用开盘时间，高低点中点使用高点时间）
yM_time = yO_time
tM_time = tO_time
wM_time = wO_time
lwM_time = lwO_time
mM_time = mO_time
lmM_time = lmO_time
qM_time = qO_time
lqM_time = lqO_time
yrM_time = yrO_time
lyrM_time = lyrO_time

yHL_M_time = yH_time
tHL_M_time = tH_time
wHL_M_time = wH_time
lwHL_M_time = lwH_time
mHL_M_time = mH_time
lmHL_M_time = lmH_time
qHL_M_time = qH_time
lqHL_M_time = lqH_time
yrHL_M_time = yrH_time
lyrHL_M_time = lyrH_time

// ==== 线条和标签句柄 ====
var line yOL=na, var line yHL=na, var line yLL=na, var line yCL=na, var line yML=na, var line yHL_ML=na
var line tOL=na, var line tHL=na, var line tLL=na, var line tCL=na, var line tML=na, var line tHL_ML=na
var line wOL=na, var line wHL=na, var line wLL=na, var line wCL=na, var line wML=na, var line wHL_ML=na
var line lwOL=na, var line lwHL=na, var line lwLL=na, var line lwCL=na, var line lwML=na, var line lwHL_ML=na
var line mOL=na, var line mHL=na, var line mLL=na, var line mCL=na, var line mML=na, var line mHL_ML=na
var line lmOL=na, var line lmHL=na, var line lmLL=na, var line lmCL=na, var line lmML=na, var line lmHL_ML=na
var line qOL=na, var line qHL=na, var line qLL=na, var line qCL=na, var line qML=na, var line qHL_ML=na
var line lqOL=na, var line lqHL=na, var line lqLL=na, var line lqCL=na, var line lqML=na, var line lqHL_ML=na
var line yrOL=na, var line yrHL=na, var line yrLL=na, var line yrCL=na, var line yrML=na, var line yrHL_ML=na
var line lyrOL=na, var line lyrHL=na, var line lyrLL=na, var line lyrCL=na, var line lyrML=na, var line lyrHL_ML=na

var label yOL_l=na, var label yHL_l=na, var label yLL_l=na, var label yCL_l=na, var label yML_l=na, var label yHL_ML_l=na
var label tOL_l=na, var label tHL_l=na, var label tLL_l=na, var label tCL_l=na, var label tML_l=na, var label tHL_ML_l=na
var label wOL_l=na, var label wHL_l=na, var label wLL_l=na, var label wCL_l=na, var label wML_l=na, var label wHL_ML_l=na
var label lwOL_l=na, var label lwHL_l=na, var label lwLL_l=na, var label lwCL_l=na, var label lwML_l=na, var label lwHL_ML_l=na
var label mOL_l=na, var label mHL_l=na, var label mLL_l=na, var label mCL_l=na, var label mML_l=na, var label mHL_ML_l=na
var label lmOL_l=na, var label lmHL_l=na, var label lmLL_l=na, var label lmCL_l=na, var label lmML_l=na, var label lmHL_ML_l=na
var label qOL_l=na, var label qHL_l=na, var label qLL_l=na, var label qCL_l=na, var label qML_l=na, var label qHL_ML_l=na
var label lqOL_l=na, var label lqHL_l=na, var label lqLL_l=na, var label lqCL_l=na, var label lqML_l=na, var label lqHL_ML_l=na
var label yrOL_l=na, var label yrHL_l=na, var label yrLL_l=na, var label yrCL_l=na, var label yrML_l=na, var label yrHL_ML_l=na
var label lyrOL_l=na, var label lyrHL_l=na, var label lyrLL_l=na, var label lyrCL_l=na, var label lyrML_l=na, var label lyrHL_ML_l=na

// ==== 绘制线条和标签 ====
if barstate.islastconfirmedhistory or barstate.isrealtime
    line_end = time + 20 * (time - time[1])

    // 昨日线条
    yOL := showYesterday and yO_show ? f_set_or_new(yO_time, yO, line_end, yO, yO_col, yO_width, yO_style, yOL) : f_delete_line(yOL)
    yHL := showYesterday and yH_show ? f_set_or_new(yH_time, yH, line_end, yH, yH_col, yH_width, yH_style, yHL) : f_delete_line(yHL)
    yLL := showYesterday and yL_show ? f_set_or_new(yL_time, yL, line_end, yL, yL_col, yL_width, yL_style, yLL) : f_delete_line(yLL)
    yCL := showYesterday and yC_show ? f_set_or_new(yC_time, yC, line_end, yC, yC_col, yC_width, yC_style, yCL) : f_delete_line(yCL)
    yML := showYesterday and yM_show ? f_set_or_new(yM_time, yM, line_end, yM, yM_col, yM_width, yM_style, yML) : f_delete_line(yML)
    yHL_ML := showYesterday and yHL_M_show ? f_set_or_new(yHL_M_time, yHL_M, line_end, yHL_M, yHL_M_col, yHL_M_width, yHL_M_style, yHL_ML) : f_delete_line(yHL_ML)

    // 今日线条
    tOL := showToday and tO_show ? f_set_or_new(tO_time, tO, line_end, tO, tO_col, tO_width, tO_style, tOL) : f_delete_line(tOL)
    tHL := showToday and tH_show ? f_set_or_new(tH_time, tH, line_end, tH, tH_col, tH_width, tH_style, tHL) : f_delete_line(tHL)
    tLL := showToday and tL_show ? f_set_or_new(tL_time, tL, line_end, tL, tL_col, tL_width, tL_style, tLL) : f_delete_line(tLL)
    tCL := showToday and tC_show ? f_set_or_new(tC_time, tC, line_end, tC, tC_col, tC_width, tC_style, tCL) : f_delete_line(tCL)
    tML := showToday and tM_show ? f_set_or_new(tM_time, tM, line_end, tM, tM_col, tM_width, tM_style, tML) : f_delete_line(tML)
    tHL_ML := showToday and tHL_M_show ? f_set_or_new(tHL_M_time, tHL_M, line_end, tHL_M, tHL_M_col, tHL_M_width, tHL_M_style, tHL_ML) : f_delete_line(tHL_ML)

    // 本周线条
    wOL := showThisWeek and wO_show ? f_set_or_new(wO_time, wO, line_end, wO, wO_col, wO_width, wO_style, wOL) : f_delete_line(wOL)
    wHL := showThisWeek and wH_show ? f_set_or_new(wH_time, wH, line_end, wH, wH_col, wH_width, wH_style, wHL) : f_delete_line(wHL)
    wLL := showThisWeek and wL_show ? f_set_or_new(wL_time, wL, line_end, wL, wL_col, wL_width, wL_style, wLL) : f_delete_line(wLL)
    wCL := showThisWeek and wC_show ? f_set_or_new(wC_time, wC, line_end, wC, wC_col, wC_width, wC_style, wCL) : f_delete_line(wCL)
    wML := showThisWeek and wM_show ? f_set_or_new(wM_time, wM, line_end, wM, wM_col, wM_width, wM_style, wML) : f_delete_line(wML)
    wHL_ML := showThisWeek and wHL_M_show ? f_set_or_new(wHL_M_time, wHL_M, line_end, wHL_M, wHL_M_col, wHL_M_width, wHL_M_style, wHL_ML) : f_delete_line(wHL_ML)

    // 上周线条
    lwOL := showLastWeek and lwO_show ? f_set_or_new(lwO_time, lwO, line_end, lwO, lwO_col, lwO_width, lwO_style, lwOL) : f_delete_line(lwOL)
    lwHL := showLastWeek and lwH_show ? f_set_or_new(lwH_time, lwH, line_end, lwH, lwH_col, lwH_width, lwH_style, lwHL) : f_delete_line(lwHL)
    lwLL := showLastWeek and lwL_show ? f_set_or_new(lwL_time, lwL, line_end, lwL, lwL_col, lwL_width, lwL_style, lwLL) : f_delete_line(lwLL)
    lwCL := showLastWeek and lwC_show ? f_set_or_new(lwC_time, lwC, line_end, lwC, lwC_col, lwC_width, lwC_style, lwCL) : f_delete_line(lwCL)
    lwML := showLastWeek and lwM_show ? f_set_or_new(lwM_time, lwM, line_end, lwM, lwM_col, lwM_width, lwM_style, lwML) : f_delete_line(lwML)
    lwHL_ML := showLastWeek and lwHL_M_show ? f_set_or_new(lwHL_M_time, lwHL_M, line_end, lwHL_M, lwHL_M_col, lwHL_M_width, lwHL_M_style, lwHL_ML) : f_delete_line(lwHL_ML)

    // 本月线条
    mOL := showThisMonth and mO_show ? f_set_or_new(mO_time, mO, line_end, mO, mO_col, mO_width, mO_style, mOL) : f_delete_line(mOL)
    mHL := showThisMonth and mH_show ? f_set_or_new(mH_time, mH, line_end, mH, mH_col, mH_width, mH_style, mHL) : f_delete_line(mHL)
    mLL := showThisMonth and mL_show ? f_set_or_new(mL_time, mL, line_end, mL, mL_col, mL_width, mL_style, mLL) : f_delete_line(mLL)
    mCL := showThisMonth and mC_show ? f_set_or_new(mC_time, mC, line_end, mC, mC_col, mC_width, mC_style, mCL) : f_delete_line(mCL)
    mML := showThisMonth and mM_show ? f_set_or_new(mM_time, mM, line_end, mM, mM_col, mM_width, mM_style, mML) : f_delete_line(mML)
    mHL_ML := showThisMonth and mHL_M_show ? f_set_or_new(mHL_M_time, mHL_M, line_end, mHL_M, mHL_M_col, mHL_M_width, mHL_M_style, mHL_ML) : f_delete_line(mHL_ML)

    // 上月线条
    lmOL := showLastMonth and lmO_show ? f_set_or_new(lmO_time, lmO, line_end, lmO, lmO_col, lmO_width, lmO_style, lmOL) : f_delete_line(lmOL)
    lmHL := showLastMonth and lmH_show ? f_set_or_new(lmH_time, lmH, line_end, lmH, lmH_col, lmH_width, lmH_style, lmHL) : f_delete_line(lmHL)
    lmLL := showLastMonth and lmL_show ? f_set_or_new(lmL_time, lmL, line_end, lmL, lmL_col, lmL_width, lmL_style, lmLL) : f_delete_line(lmLL)
    lmCL := showLastMonth and lmC_show ? f_set_or_new(lmC_time, lmC, line_end, lmC, lmC_col, lmC_width, lmC_style, lmCL) : f_delete_line(lmCL)
    lmML := showLastMonth and lmM_show ? f_set_or_new(lmM_time, lmM, line_end, lmM, lmM_col, lmM_width, lmM_style, lmML) : f_delete_line(lmML)
    lmHL_ML := showLastMonth and lmHL_M_show ? f_set_or_new(lmHL_M_time, lmHL_M, line_end, lmHL_M, lmHL_M_col, lmHL_M_width, lmHL_M_style, lmHL_ML) : f_delete_line(lmHL_ML)

    // 本季线条
    qOL := showThisQuarter and qO_show ? f_set_or_new(qO_time, qO, line_end, qO, qO_col, qO_width, qO_style, qOL) : f_delete_line(qOL)
    qHL := showThisQuarter and qH_show ? f_set_or_new(qH_time, qH, line_end, qH, qH_col, qH_width, qH_style, qHL) : f_delete_line(qHL)
    qLL := showThisQuarter and qL_show ? f_set_or_new(qL_time, qL, line_end, qL, qL_col, qL_width, qL_style, qLL) : f_delete_line(qLL)
    qCL := showThisQuarter and qC_show ? f_set_or_new(qC_time, qC, line_end, qC, qC_col, qC_width, qC_style, qCL) : f_delete_line(qCL)
    qML := showThisQuarter and qM_show ? f_set_or_new(qM_time, qM, line_end, qM, qM_col, qM_width, qM_style, qML) : f_delete_line(qML)
    qHL_ML := showThisQuarter and qHL_M_show ? f_set_or_new(qHL_M_time, qHL_M, line_end, qHL_M, qHL_M_col, qHL_M_width, qHL_M_style, qHL_ML) : f_delete_line(qHL_ML)

    // 上季线条
    lqOL := showLastQuarter and lqO_show ? f_set_or_new(lqO_time, lqO, line_end, lqO, lqO_col, lqO_width, lqO_style, lqOL) : f_delete_line(lqOL)
    lqHL := showLastQuarter and lqH_show ? f_set_or_new(lqH_time, lqH, line_end, lqH, lqH_col, lqH_width, lqH_style, lqHL) : f_delete_line(lqHL)
    lqLL := showLastQuarter and lqL_show ? f_set_or_new(lqL_time, lqL, line_end, lqL, lqL_col, lqL_width, lqL_style, lqLL) : f_delete_line(lqLL)
    lqCL := showLastQuarter and lqC_show ? f_set_or_new(lqC_time, lqC, line_end, lqC, lqC_col, lqC_width, lqC_style, lqCL) : f_delete_line(lqCL)
    lqML := showLastQuarter and lqM_show ? f_set_or_new(lqM_time, lqM, line_end, lqM, lqM_col, lqM_width, lqM_style, lqML) : f_delete_line(lqML)
    lqHL_ML := showLastQuarter and lqHL_M_show ? f_set_or_new(lqHL_M_time, lqHL_M, line_end, lqHL_M, lqHL_M_col, lqHL_M_width, lqHL_M_style, lqHL_ML) : f_delete_line(lqHL_ML)

    // 本年线条
    yrOL := showThisYear and yrO_show ? f_set_or_new(yrO_time, yrO, line_end, yrO, yrO_col, yrO_width, yrO_style, yrOL) : f_delete_line(yrOL)
    yrHL := showThisYear and yrH_show ? f_set_or_new(yrH_time, yrH, line_end, yrH, yrH_col, yrH_width, yrH_style, yrHL) : f_delete_line(yrHL)
    yrLL := showThisYear and yrL_show ? f_set_or_new(yrL_time, yrL, line_end, yrL, yrL_col, yrL_width, yrL_style, yrLL) : f_delete_line(yrLL)
    yrCL := showThisYear and yrC_show ? f_set_or_new(yrC_time, yrC, line_end, yrC, yrC_col, yrC_width, yrC_style, yrCL) : f_delete_line(yrCL)
    yrML := showThisYear and yrM_show ? f_set_or_new(yrM_time, yrM, line_end, yrM, yrM_col, yrM_width, yrM_style, yrML) : f_delete_line(yrML)
    yrHL_ML := showThisYear and yrHL_M_show ? f_set_or_new(yrHL_M_time, yrHL_M, line_end, yrHL_M, yrHL_M_col, yrHL_M_width, yrHL_M_style, yrHL_ML) : f_delete_line(yrHL_ML)

    // 去年线条
    lyrOL := showLastYear and lyrO_show ? f_set_or_new(lyrO_time, lyrO, line_end, lyrO, lyrO_col, lyrO_width, lyrO_style, lyrOL) : f_delete_line(lyrOL)
    lyrHL := showLastYear and lyrH_show ? f_set_or_new(lyrH_time, lyrH, line_end, lyrH, lyrH_col, lyrH_width, lyrH_style, lyrHL) : f_delete_line(lyrHL)
    lyrLL := showLastYear and lyrL_show ? f_set_or_new(lyrL_time, lyrL, line_end, lyrL, lyrL_col, lyrL_width, lyrL_style, lyrLL) : f_delete_line(lyrLL)
    lyrCL := showLastYear and lyrC_show ? f_set_or_new(lyrC_time, lyrC, line_end, lyrC, lyrC_col, lyrC_width, lyrC_style, lyrCL) : f_delete_line(lyrCL)
    lyrML := showLastYear and lyrM_show ? f_set_or_new(lyrM_time, lyrM, line_end, lyrM, lyrM_col, lyrM_width, lyrM_style, lyrML) : f_delete_line(lyrML)
    lyrHL_ML := showLastYear and lyrHL_M_show ? f_set_or_new(lyrHL_M_time, lyrHL_M, line_end, lyrHL_M, lyrHL_M_col, lyrHL_M_width, lyrHL_M_style, lyrHL_ML) : f_delete_line(lyrHL_ML)

    // 标签
    yOL_l := f_manage_label(yOL_l, line_end, yO, "LDK(" + str.tostring(yO) + ")", yO_col, showLabels and showYesterday and yO_show)
    yHL_l := f_manage_label(yHL_l, line_end, yH, "LDH(" + str.tostring(yH) + ")", yH_col, showLabels and showYesterday and yH_show)
    yLL_l := f_manage_label(yLL_l, line_end, yL, "LDL(" + str.tostring(yL) + ")", yL_col, showLabels and showYesterday and yL_show)
    yCL_l := f_manage_label(yCL_l, line_end, yC, "LDS(" + str.tostring(yC) + ")", yC_col, showLabels and showYesterday and yC_show)
    yML_l := f_manage_label(yML_l, line_end, yM, "LDKS_M(" + str.tostring(yM) + ")", yM_col, showLabels and showYesterday and yM_show)
    yHL_ML_l := f_manage_label(yHL_ML_l, line_end, yHL_M, "LDHL_M(" + str.tostring(yHL_M) + ")", yHL_M_col, showLabels and showYesterday and yHL_M_show)

    tOL_l := f_manage_label(tOL_l, line_end, tO, "TDK(" + str.tostring(tO) + ")", tO_col, showLabels and showToday and tO_show)
    tHL_l := f_manage_label(tHL_l, line_end, tH, "TDH(" + str.tostring(tH) + ")", tH_col, showLabels and showToday and tH_show)
    tLL_l := f_manage_label(tLL_l, line_end, tL, "TDL(" + str.tostring(tL) + ")", tL_col, showLabels and showToday and tL_show)
    tCL_l := f_manage_label(tCL_l, line_end, tC, "TDS(" + str.tostring(tC) + ")", tC_col, showLabels and showToday and tC_show)
    tML_l := f_manage_label(tML_l, line_end, tM, "TDKS_M(" + str.tostring(tM) + ")", tM_col, showLabels and showToday and tM_show)
    tHL_ML_l := f_manage_label(tHL_ML_l, line_end, tHL_M, "TDHL_M(" + str.tostring(tHL_M) + ")", tHL_M_col, showLabels and showToday and tHL_M_show)

    wOL_l := f_manage_label(wOL_l, line_end, wO, "TWK(" + str.tostring(wO) + ")", wO_col, showLabels and showThisWeek and wO_show)
    wHL_l := f_manage_label(wHL_l, line_end, wH, "TWH(" + str.tostring(wH) + ")", wH_col, showLabels and showThisWeek and wH_show)
    wLL_l := f_manage_label(wLL_l, line_end, wL, "TWL(" + str.tostring(wL) + ")", wL_col, showLabels and showThisWeek and wL_show)
    wCL_l := f_manage_label(wCL_l, line_end, wC, "TWS(" + str.tostring(wC) + ")", wC_col, showLabels and showThisWeek and wC_show)
    wML_l := f_manage_label(wML_l, line_end, wM, "TWKS_M(" + str.tostring(wM) + ")", wM_col, showLabels and showThisWeek and wM_show)
    wHL_ML_l := f_manage_label(wHL_ML_l, line_end, wHL_M, "TWHL_M(" + str.tostring(wHL_M) + ")", wHL_M_col, showLabels and showThisWeek and wHL_M_show)

    lwOL_l := f_manage_label(lwOL_l, line_end, lwO, "LWK(" + str.tostring(lwO) + ")", lwO_col, showLabels and showLastWeek and lwO_show)
    lwHL_l := f_manage_label(lwHL_l, line_end, lwH, "LWH(" + str.tostring(lwH) + ")", lwH_col, showLabels and showLastWeek and lwH_show)
    lwLL_l := f_manage_label(lwLL_l, line_end, lwL, "LWL(" + str.tostring(lwL) + ")", lwL_col, showLabels and showLastWeek and lwL_show)
    lwCL_l := f_manage_label(lwCL_l, line_end, lwC, "LWS(" + str.tostring(lwC) + ")", lwC_col, showLabels and showLastWeek and lwC_show)
    lwML_l := f_manage_label(lwML_l, line_end, lwM, "LWKS_M(" + str.tostring(lwM) + ")", lwM_col, showLabels and showLastWeek and lwM_show)
    lwHL_ML_l := f_manage_label(lwHL_ML_l, line_end, lwHL_M, "LWHL_M(" + str.tostring(lwHL_M) + ")", lwHL_M_col, showLabels and showLastWeek and lwHL_M_show)

    mOL_l := f_manage_label(mOL_l, line_end, mO, "TMK(" + str.tostring(mO) + ")", mO_col, showLabels and showThisMonth and mO_show)
    mHL_l := f_manage_label(mHL_l, line_end, mH, "TMH(" + str.tostring(mH) + ")", mH_col, showLabels and showThisMonth and mH_show)
    mLL_l := f_manage_label(mLL_l, line_end, mL, "TML(" + str.tostring(mL) + ")", mL_col, showLabels and showThisMonth and mL_show)
    mCL_l := f_manage_label(mCL_l, line_end, mC, "TMS(" + str.tostring(mC) + ")", mC_col, showLabels and showThisMonth and mC_show)
    mML_l := f_manage_label(mML_l, line_end, mM, "TMKS_M(" + str.tostring(mM) + ")", mM_col, showLabels and showThisMonth and mM_show)
    mHL_ML_l := f_manage_label(mHL_ML_l, line_end, mHL_M, "TMHL_M(" + str.tostring(mHL_M) + ")", mHL_M_col, showLabels and showThisMonth and mHL_M_show)

    lmOL_l := f_manage_label(lmOL_l, line_end, lmO, "LMK(" + str.tostring(lmO) + ")", lmO_col, showLabels and showLastMonth and lmO_show)
    lmHL_l := f_manage_label(lmHL_l, line_end, lmH, "LMH(" + str.tostring(lmH) + ")", lmH_col, showLabels and showLastMonth and lmH_show)
    lmLL_l := f_manage_label(lmLL_l, line_end, lmL, "LML(" + str.tostring(lmL) + ")", lmL_col, showLabels and showLastMonth and lmL_show)
    lmCL_l := f_manage_label(lmCL_l, line_end, lmC, "LMS(" + str.tostring(lmC) + ")", lmC_col, showLabels and showLastMonth and lmC_show)
    lmML_l := f_manage_label(lmML_l, line_end, lmM, "LMKS_M(" + str.tostring(lmM) + ")", lmM_col, showLabels and showLastMonth and lmM_show)
    lmHL_ML_l := f_manage_label(lmHL_ML_l, line_end, lmHL_M, "LMHL_M(" + str.tostring(lmHL_M) + ")", lmHL_M_col, showLabels and showLastMonth and lmHL_M_show)

    qOL_l := f_manage_label(qOL_l, line_end, qO, "TQK(" + str.tostring(qO) + ")", qO_col, showLabels and showThisQuarter and qO_show)
    qHL_l := f_manage_label(qHL_l, line_end, qH, "TQH(" + str.tostring(qH) + ")", qH_col, showLabels and showThisQuarter and qH_show)
    qLL_l := f_manage_label(qLL_l, line_end, qL, "TQL(" + str.tostring(qL) + ")", qL_col, showLabels and showThisQuarter and qL_show)
    qCL_l := f_manage_label(qCL_l, line_end, qC, "TQS(" + str.tostring(qC) + ")", qC_col, showLabels and showThisQuarter and qC_show)
    qML_l := f_manage_label(qML_l, line_end, qM, "TQKS_M(" + str.tostring(qM) + ")", qM_col, showLabels and showThisQuarter and qM_show)
    qHL_ML_l := f_manage_label(qHL_ML_l, line_end, qHL_M, "TQHL_M(" + str.tostring(qHL_M) + ")", qHL_M_col, showLabels and showThisQuarter and qHL_M_show)

    lqOL_l := f_manage_label(lqOL_l, line_end, lqO, "LQK(" + str.tostring(lqO) + ")", lqO_col, showLabels and showLastQuarter and lqO_show)
    lqHL_l := f_manage_label(lqHL_l, line_end, lqH, "LQH(" + str.tostring(lqH) + ")", lqH_col, showLabels and showLastQuarter and lqH_show)
    lqLL_l := f_manage_label(lqLL_l, line_end, lqL, "LQL(" + str.tostring(lqL) + ")", lqL_col, showLabels and showLastQuarter and lqL_show)
    lqCL_l := f_manage_label(lqCL_l, line_end, lqC, "LQS(" + str.tostring(lqC) + ")", lqC_col, showLabels and showLastQuarter and lqC_show)
    lqML_l := f_manage_label(lqML_l, line_end, lqM, "LQKS_M(" + str.tostring(lqM) + ")", lqM_col, showLabels and showLastQuarter and lqM_show)
    lqHL_ML_l := f_manage_label(lqHL_ML_l, line_end, lqHL_M, "LQHL_M(" + str.tostring(lqHL_M) + ")", lqHL_M_col, showLabels and showLastQuarter and lqHL_M_show)

    yrOL_l := f_manage_label(yrOL_l, line_end, yrO, "TYK(" + str.tostring(yrO) + ")", yrO_col, showLabels and showThisYear and yrO_show)
    yrHL_l := f_manage_label(yrHL_l, line_end, yrH, "TYH(" + str.tostring(yrH) + ")", yrH_col, showLabels and showThisYear and yrH_show)
    yrLL_l := f_manage_label(yrLL_l, line_end, yrL, "TYL(" + str.tostring(yrL) + ")", yrL_col, showLabels and showThisYear and yrL_show)
    yrCL_l := f_manage_label(yrCL_l, line_end, yrC, "TYS(" + str.tostring(yrC) + ")", yrC_col, showLabels and showThisYear and yrC_show)
    yrML_l := f_manage_label(yrML_l, line_end, yrM, "TYKS_M(" + str.tostring(yrM) + ")", yrM_col, showLabels and showThisYear and yrM_show)
    yrHL_ML_l := f_manage_label(yrHL_ML_l, line_end, yrHL_M, "TYHL_M(" + str.tostring(yrHL_M) + ")", yrHL_M_col, showLabels and showThisYear and yrHL_M_show)

    lyrOL_l := f_manage_label(lyrOL_l, line_end, lyrO, "LYK(" + str.tostring(lyrO) + ")", lyrO_col, showLabels and showLastYear and lyrO_show)
    lyrHL_l := f_manage_label(lyrHL_l, line_end, lyrH, "LYH(" + str.tostring(lyrH) + ")", lyrH_col, showLabels and showLastYear and lyrH_show)
    lyrLL_l := f_manage_label(lyrLL_l, line_end, lyrL, "LYL(" + str.tostring(lyrL) + ")", lyrL_col, showLabels and showLastYear and lyrL_show)
    lyrCL_l := f_manage_label(lyrCL_l, line_end, lyrC, "LYS(" + str.tostring(lyrC) + ")", lyrC_col, showLabels and showLastYear and lyrC_show)
    lyrML_l := f_manage_label(lyrML_l, line_end, lyrM, "LYKS_M(" + str.tostring(lyrM) + ")", lyrM_col, showLabels and showLastYear and lyrM_show)
    lyrHL_ML_l := f_manage_label(lyrHL_ML_l, line_end, lyrHL_M, "LYHL_M(" + str.tostring(lyrHL_M) + ")", lyrHL_M_col, showLabels and showLastYear and lyrHL_M_show)
````
