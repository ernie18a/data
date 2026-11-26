# Combo Master V7: 9MA + Bollinger + Coral + InsideBar

- url: https://www.tradingview.com/script/8Xi1jnBE/
- type: indicator
- pine_id: PUB;9bad814bb6c94b439fb685b761139b0e
- version: 1.0

## Description

indicador com 9 médias persolanizáveis, bandas de bollinger, duas coral trend e inside bar

## Source Code

````pine
//@version=5
indicator("Combo Master V7: 9MA + Bollinger + Coral + InsideBar", shorttitle="Combo Master V7", overlay=true)

// ==========================================
// 1. CORAL TREND INDICATOR (LazyBear) - COM MENU DE CORES
// ==========================================
coral_grp = "1. Coral Trend Indicator"
src_coral = input(close, title="Coral Source", group=coral_grp)
sm        = input.int(21, title="Smoothing Period", group=coral_grp)
cd        = input.float(0.4, title="Constant D", group=coral_grp)
ebc       = input.bool(false, title="Color Bars (Coral Trend)", group=coral_grp)
ribm      = input.bool(false, title="Ribbon Mode (Background)", group=coral_grp)

// Menu de Cores do Coral
c_up   = input.color(color.rgb(0, 89, 255), "Cor de Alta", inline="Coral Colors", group=coral_grp)
c_down = input.color(color.rgb(255, 0, 0), "Cor de Baixa", inline="Coral Colors", group=coral_grp)
c_neu  = input.color(color.rgb(0, 140, 255), "Cor Neutra", inline="Coral Colors", group=coral_grp)

di = (sm - 1.0) / 2.0 + 1.0
c1_coral = 2 / (di + 1.0)
c2_coral = 1 - c1_coral
c3_coral = 3.0 * (cd * cd + cd * cd * cd)
c4_coral = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
c5_coral = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd

var float i1 = 0.0, var float i2 = 0.0, var float i3 = 0.0
var float i4 = 0.0, var float i5 = 0.0, var float i6 = 0.0

i1 := c1_coral * src_coral + c2_coral * nz(i1[1])
i2 := c1_coral * i1 + c2_coral * nz(i2[1])
i3 := c1_coral * i2 + c2_coral * nz(i3[1])
i4 := c1_coral * i3 + c2_coral * nz(i4[1])
i5 := c1_coral * i4 + c2_coral * nz(i5[1]) 
i6 := c1_coral * i5 + c2_coral * nz(i6[1]) 

bfr = -cd * cd * cd * i6 + c3_coral * i5 + c4_coral * i4 + c5_coral * i3
bfrC = bfr > nz(bfr[1]) ? c_up : bfr < nz(bfr[1]) ? c_down : c_neu

plot(ribm ? na : bfr, title="Coral Trend", linewidth=3, style=plot.style_circles, color=bfrC)
bgcolor(ribm ? color.new(bfrC, 80) : na)

// ==========================================
// 1B. CORAL TREND INDICATOR (CÓPIA)
// ==========================================
coral_grp_copy = "1. Coral Trend Indicator (Cópia)"
src_coral_copy = input(close, title="Coral Source", group=coral_grp_copy)
sm_copy        = input.int(21, title="Smoothing Period", group=coral_grp_copy)
cd_copy        = input.float(0.4, title="Constant D", group=coral_grp_copy)
ribm_copy      = input.bool(false, title="Ribbon Mode (Background)", group=coral_grp_copy)

// Menu de Cores do Coral (Cópia)
c_up_copy   = input.color(color.rgb(0, 89, 255), "Cor de Alta", inline="Coral Colors Copy", group=coral_grp_copy)
c_down_copy = input.color(color.rgb(255, 0, 0), "Cor de Baixa", inline="Coral Colors Copy", group=coral_grp_copy)
c_neu_copy  = input.color(color.rgb(0, 140, 255), "Cor Neutra", inline="Coral Colors Copy", group=coral_grp_copy)

di_copy = (sm_copy - 1.0) / 2.0 + 1.0
c1_coral_copy = 2 / (di_copy + 1.0)
c2_coral_copy = 1 - c1_coral_copy
c3_coral_copy = 3.0 * (cd_copy * cd_copy + cd_copy * cd_copy * cd_copy)
c4_coral_copy = -3.0 * (2.0 * cd_copy * cd_copy + cd_copy + cd_copy * cd_copy * cd_copy)
c5_coral_copy = 3.0 * cd_copy + 1.0 + cd_copy * cd_copy * cd_copy + 3.0 * cd_copy * cd_copy

var float i1_copy = 0.0, var float i2_copy = 0.0, var float i3_copy = 0.0
var float i4_copy = 0.0, var float i5_copy = 0.0, var float i6_copy = 0.0

i1_copy := c1_coral_copy * src_coral_copy + c2_coral_copy * nz(i1_copy[1])
i2_copy := c1_coral_copy * i1_copy + c2_coral_copy * nz(i2_copy[1])
i3_copy := c1_coral_copy * i2_copy + c2_coral_copy * nz(i3_copy[1])
i4_copy := c1_coral_copy * i3_copy + c2_coral_copy * nz(i4_copy[1])
i5_copy := c1_coral_copy * i4_copy + c2_coral_copy * nz(i5_copy[1]) 
i6_copy := c1_coral_copy * i5_copy + c2_coral_copy * nz(i6_copy[1]) 

bfr_copy = -cd_copy * cd_copy * cd_copy * i6_copy + c3_coral_copy * i5_copy + c4_coral_copy * i4_copy + c5_coral_copy * i3_copy
bfrC_copy = bfr_copy > nz(bfr_copy[1]) ? c_up_copy : bfr_copy < nz(bfr_copy[1]) ? c_down_copy : c_neu_copy

plot(ribm_copy ? na : bfr_copy, title="Coral Trend (Cópia)", linewidth=3, style=plot.style_circles, color=bfrC_copy)
bgcolor(ribm_copy ? color.new(bfrC_copy, 80) : na)


// ==========================================
// 2. AS 9 MÉDIAS MÓVEIS (PINE by AAP)
// ==========================================
ma_grp = "2. Médias Móveis (AAP)"

// Função para calcular a média
calc_ma(source, length, type) =>
    switch type
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)
        => na

// Função para buscar o timeframe e calcular
get_ma(s, t, l, src, tf) =>
    m_val = calc_ma(src, l, t)
    request.security(syminfo.tickerid, tf, m_val, gaps=barmerge.gaps_on)

// Inputs das Médias (Incluindo Timeframe)
s1 = input(true, "M1", inline="M1", group=ma_grp), t1 = input.string("SMA", "", inline="M1", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l1 = input.int(8, "", inline="M1", group=ma_grp), src1 = input(close, "", inline="M1", group=ma_grp), tf1 = input.timeframe("", "", inline="M1", group=ma_grp), c1_col = input(#f60c0c, "", inline="M1", group=ma_grp)
s2 = input(true, "M2", inline="M2", group=ma_grp), t2 = input.string("SMA", "", inline="M2", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l2 = input.int(13, "", inline="M2", group=ma_grp), src2 = input(close, "", inline="M2", group=ma_grp), tf2 = input.timeframe("", "", inline="M2", group=ma_grp), c2_col = input(#f60c0c, "", inline="M2", group=ma_grp)
s3 = input(true, "M3", inline="M3", group=ma_grp), t3 = input.string("SMA", "", inline="M3", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l3 = input.int(21, "", inline="M3", group=ma_grp), src3 = input(close, "", inline="M3", group=ma_grp), tf3 = input.timeframe("", "", inline="M3", group=ma_grp), c3_col = input(#f60c0c, "", inline="M3", group=ma_grp)
s4 = input(true, "M4", inline="M4", group=ma_grp), t4 = input.string("SMA", "", inline="M4", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l4 = input.int(25, "", inline="M4", group=ma_grp), src4 = input(close, "", inline="M4", group=ma_grp), tf4 = input.timeframe("", "", inline="M4", group=ma_grp), c4_col = input(#f60c0c, "", inline="M4", group=ma_grp)
s5 = input(true, "M5", inline="M5", group=ma_grp), t5 = input.string("SMA", "", inline="M5", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l5 = input.int(50, "", inline="M5", group=ma_grp), src5 = input(close, "", inline="M5", group=ma_grp), tf5 = input.timeframe("", "", inline="M5", group=ma_grp), c5_col = input(#f60c0c, "", inline="M5", group=ma_grp)
s6 = input(true, "M6", inline="M6", group=ma_grp), t6 = input.string("SMA", "", inline="M6", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l6 = input.int(84, "", inline="M6", group=ma_grp), src6 = input(close, "", inline="M6", group=ma_grp), tf6 = input.timeframe("", "", inline="M6", group=ma_grp), c6_col = input(#f60c0c, "", inline="M6", group=ma_grp)
s7 = input(true, "M7", inline="M7", group=ma_grp), t7 = input.string("SMA", "", inline="M7", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l7 = input.int(100, "", inline="M7", group=ma_grp), src7 = input(close, "", inline="M7", group=ma_grp), tf7 = input.timeframe("", "", inline="M7", group=ma_grp), c7_col = input(#f60c0c, "", inline="M7", group=ma_grp)
s8 = input(true, "M8", inline="M8", group=ma_grp), t8 = input.string("SMA", "", inline="M8", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l8 = input.int(200, "", inline="M8", group=ma_grp), src8 = input(close, "", inline="M8", group=ma_grp), tf8 = input.timeframe("", "", inline="M8", group=ma_grp), c8_col = input(#f60c0c, "", inline="M8", group=ma_grp)
s9 = input(true, "M9", inline="M9", group=ma_grp), t9 = input.string("SMA", "", inline="M9", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=ma_grp), l9 = input.int(300, "", inline="M9", group=ma_grp), src9 = input(close, "", inline="M9", group=ma_grp), tf9 = input.timeframe("", "", inline="M9", group=ma_grp), c9_col = input(#f60c0c, "", inline="M9", group=ma_grp)

// Plotagem das Médias com Security
plot(s1 ? get_ma(s1, t1, l1, src1, tf1) : na, color=c1_col, title="MA 1")
plot(s2 ? get_ma(s2, t2, l2, src2, tf2) : na, color=c2_col, title="MA 2")
plot(s3 ? get_ma(s3, t3, l3, src3, tf3) : na, color=c3_col, title="MA 3")
plot(s4 ? get_ma(s4, t4, l4, src4, tf4) : na, color=c4_col, title="MA 4")
plot(s5 ? get_ma(s5, t5, l5, src5, tf5) : na, color=c5_col, title="MA 5")
plot(s6 ? get_ma(s6, t6, l6, src6, tf6) : na, color=c6_col, title="MA 6")
plot(s7 ? get_ma(s7, t7, l7, src7, tf7) : na, color=c7_col, title="MA 7")
plot(s8 ? get_ma(s8, t8, l8, src8, tf8) : na, color=c8_col, title="MA 8")
plot(s9 ? get_ma(s9, t9, l9, src9, tf9) : na, color=c9_col, title="MA 9")

// ==========================================
// 3. BANDAS DE BOLLINGER
// ==========================================
bb_grp = "3. Bandas de Bollinger"
bb_len   = input.int(20, "Período BB", group=bb_grp)
bb_mult  = input.float(2.0, "Desvio BB", group=bb_grp)
bb_show_bg = input.bool(true, "Mostrar Background", group=bb_grp)
bb_bg_col  = input.color(color.new(color.blue, 95), "Cor do Fundo", group=bb_grp)

[basis, upper, lower] = ta.bb(close, bb_len, bb_mult)

plot(basis, color=color.orange, title="BB Base")
p_up = plot(upper, color=color.blue, title="BB Superior")
p_lo = plot(lower, color=color.blue, title="BB Inferior")
fill(p_up, p_lo, color = bb_show_bg ? bb_bg_col : na, title="Fundo BB")

// ==========================================
// 4. INSIDE BAR
// ==========================================
isInside = high < high[1] and low > low[1]
bar_color = ebc ? bfrC : (isInside ? color.blue : na)
barcolor(bar_color)

alertcondition(isInside, "Inside Bar", "Padrão Inside Bar detectado!")
````
