# Price Action Index (ZWYZJNWHJ)[Imitation v6 Pro-TCP]

- url: https://www.tradingview.com/script/m4Q6VRg9/
- type: indicator
- pine_id: PUB;2c9946b5bcfd4e46a69a85fa555d106d
- version: 1.0

## Description

[b]Added option to change time period[/b]
This is a custom oscillator indicator written in TradingView Pine Script v6, named "Price Action Index" (PAI). It integrates a multi-timeframe (MTF) framework, dispersion calculation, and stochastic oscillator, and comes with an automatic detection and alert system for bullish/bearish divergences.
[b]增加了更改时间周期的选项[/b]
这是一个基于 TradingView Pine Script v6 编写的自定义振荡器指标，名为 "Price Action Index" (PAI，价格行为指数)。它融合了多时间周期 (MTF) 框架、离散度计算 (Dispersion) 以及随机指标 (Stochastic)，并自带了底背离/顶背离自动检测和警报系统。

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chrism665

//@version=6
indicator("Price Action Index - MTF Customized v6", overlay=false)

// Tooltips {
string tt_stoch = "The first value is the lookback length for your traditional Stochastic Oscillator. The second is the smoothing length."
string tt_disp = "The dropdown is a selection of methods of calculating dispersion. The box that follows is the lookback length to measure."
string tt_straddle = "This value defines the size of the 'straddle box' where price is within consolidation and the limits where it breaks out."
string tt_barcolor = "Check this box if you want to color candles/bars similar to the color of the Price Action Index."
// }

// HTF Framework {
TF0 = "None"
TF1 = "Auto-Steps (15min, 60min, 4H, 1D, 3D, 1W, 1M, 12M)"
TF2 = "Multiple Of Current TF"
TF3 = "Fixed TF"

i_htfRepaints       = input.bool(false,     "Repaint HTF",                 group="⌚ Time Frame ⌚")
i_htfType           = input.string(TF3,     "Higher Timeframe Selection",  options = [TF0, TF1, TF2, TF3], group="⌚ Time Frame ⌚")
i_htfType2          = input.float(3.,       "Multiple of Current TF",      minval  = 1, group="⌚ Time Frame ⌚")
// v6 升级：使用内置的 input.timeframe 并自带快捷选项（包含 12, 60 等常见周期）
i_htfType3          = input.timeframe("60", "Fixed TF (选择或手动输入周期)", options = ["1", "3", "5", "12", "15", "30", "60", "240", "D", "W", "M"], group="⌚ Time Frame ⌚")

// HTF is being used.
var htfOn       = i_htfType != TF0

// —————————— PineCoders MTF Selection Framework functions
f_resInMinutes() => 
    timeframe.isseconds   ? 1. / 60.  :
      timeframe.isminutes ? 1.        :
      timeframe.isdaily   ? 1440.     :
      timeframe.isweekly  ? 10080.    :
      timeframe.ismonthly ? 43800.    : na

f_resNextStep(float _res) =>
    _res    <= 1        ? "15"  :
      _res  <= 5        ? "60"  :
      _res  <= 30       ? "240" :
      _res  <= 60       ? "1D"  :
      _res  <= 360      ? "3D"  :
      _res  <= 1440     ? "1W"  :
      _res  <= 10080    ? "1M"  : "12M"

f_multipleOfRes(float _res, float _mult) => 
    _targetResInMin = _res * math.max(_mult, 1)
    _targetResInMin     <= 0.083        ? "5S"  :
      _targetResInMin   <= 0.251        ? "15S" :
      _targetResInMin   <= 0.501        ? "30S" :
      _targetResInMin   <= 1440         ? str.tostring(math.round(_targetResInMin)) :
      _targetResInMin   <= 43800        ? str.tostring(math.round(math.min(_targetResInMin / 1440, 365))) + "D" :
      str.tostring(math.round(math.min(_targetResInMin / 43800, 12))) + "M"

var resInMinutes = f_resInMinutes()
var htf = i_htfType == TF0 ? timeframe.period : i_htfType == TF1 ? f_resNextStep(resInMinutes) : i_htfType == TF2 ? f_multipleOfRes(resInMinutes, i_htfType2) : i_htfType3
// }

// Methods of Dispersion {
string dis0 = "Standard Deviation"
f_dis0(src,len)=> ta.stdev(src,len)
string dis1 = "Variance"
f_dis1(src,len)=> ta.variance(src,len)
string dis2 = "Coefficient of Variation"
f_dis2(src,len)=> ta.stdev(src,len) / ta.sma(src,len)
string dis3 = "Signal-to-Noise"
f_dis3(src,len)=> ta.sma(src,len) / ta.stdev(src,len)
string dis4 = "Signal-to-Noise²"
f_dis4(src,len)=> math.pow(ta.sma(src,len),2) / math.pow(ta.stdev(src,len),2)
string dis5 = "Index of Dispersion"
f_dis5(src,len)=> math.pow(ta.variance(src,len),2) / ta.sma(src,len)
string dis6 = "Efficiency"
f_dis6(src,len)=> math.pow(ta.stdev(src,len),2) / math.pow(ta.sma(src,len),2)
string dis7 = "High-Low Range"
f_dis7(src,len)=> ta.highest(len) - ta.lowest(len)
// }

// Price Action Index Inputs {
src = input.source(defval=close, title="Source", group="⌨️ Inputs 🖱")
len = input.int(defval=20, title="Stochastic", group="⌨️ Inputs 🖱", inline="Stoch")
smooth = input.int(defval=3, title="", group="⌨️ Inputs 🖱", inline="Stoch", tooltip=tt_stoch)
dis_method = input.string(dis0, options=[dis0,dis1,dis2,dis3,dis4,dis5,dis6,dis7], title="Dispersion", group="⌨️ Inputs 🖱", inline="Dispersion")
dis_len = input.int(defval=20, title="", group="⌨️ Inputs 🖱", inline="Dispersion", tooltip=tt_disp)

straddle_area = input.float(defval=5.0, title="🧲 Straddle Area ⛔", group="Outputs & Alerts", tooltip=tt_straddle)
use_bar_colors = input.bool(defval=false, title="🎨 Use Bar Colors 🎨", group="Outputs & Alerts", tooltip=tt_barcolor)
use_alerts = input.bool(defval=false, title="🔇 Use Alerts 🔊", group="Outputs & Alerts")
alerts_breakouts = input.bool(defval=false, title="📈 Breakouts 📉", group="Outputs & Alerts", inline="Alerts")
alerts_extremes = input.bool(defval=false, title="⚠️ Tops/Bottoms ⚠️", group="Outputs & Alerts", inline="Alerts")
// }

// Divergence Indicator Inputs {
lbR = input.int(title="Pivot Lookback Right", defval=2, group="Divergence Indicator")
lbL = input.int(title="Pivot Lookback Left", defval=2, group="Divergence Indicator")
rangeUpper = input.int(title="Max of Lookback Range", defval=10, group="Divergence Indicator")
rangeLower = input.int(title="Min of Lookback Range", defval=2, group="Divergence Indicator")
plotBull = input.bool(title="Plot Bullish", defval=true, group="Divergence Indicator")
plotHiddenBull = input.bool(title="Plot Hidden Bullish", defval=false, group="Divergence Indicator")
plotBear = input.bool(title="Plot Bearish", defval=true, group="Divergence Indicator")
plotHiddenBear = input.bool(title="Plot Hidden Bearish", defval=false, group="Divergence Indicator")
bearColor = color.red
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)
// }

// PAI Calcs {
pai(src, dis_len, len)=>
    _disp = f_dis0(src,dis_len)
    if dis_method == dis1
        _disp := f_dis1(src,dis_len)
    else
        if dis_method == dis2
            _disp := f_dis2(src,dis_len)
        else
            if dis_method == dis3
                _disp := -f_dis3(src,dis_len)
            else
                if dis_method == dis4
                    _disp := -f_dis4(src,dis_len)
                else
                    if dis_method == dis5
                        _disp := f_dis5(src,dis_len)
                    else
                        if dis_method == dis6
                            _disp := f_dis6(src,dis_len)
                        else
                            if dis_method == dis7
                                _disp := f_dis7(src,dis_len)

    P = src==close ? ((ta.sma(ta.stoch(close,high,low,len),smooth) - 50)/50) : ((ta.sma(ta.stoch(src,src,src,len),smooth) - 50)/50)
    V = ta.stoch(_disp,_disp,_disp,len)
    P*V

f_security(_sym, _res, _src, _rep) => 
    request.security(_sym, _res, _src[not _rep and barstate.isrealtime ? 1 : 0])[_rep or barstate.isrealtime ? 0 : 1]

Z = not htfOn ? pai(src,dis_len,len) : f_security(syminfo.tickerid, htf, pai(src,dis_len,len), i_htfRepaints)
// }

// Output Conditionals {
straddle = Z<straddle_area and Z>-straddle_area
rally = Z>40
draw = Z<-40

color col = color.black
if straddle
    col := color.fuchsia
if Z>straddle_area
    col := color.lime
if Z<-straddle_area
    col := color.red
// }

// Plots {
plot(Z, color=col, title="Price Action Index")

st_ = hline(straddle_area, color=color.new(color.fuchsia,50), title="Straddle Area")
sb_ = hline(-straddle_area, color=color.new(color.fuchsia,50), title="Straddle Area")
fill(st_, sb_, color=straddle ? color.new(color.fuchsia,75) : na, title="Straddle Area")

p_ob1 = hline(80, color=color.new(color.gray,20), title="Overbought Area")
p_ob2 = hline(100, color=color.new(color.gray,10), title="Overbought Area")
fill(p_ob1, p_ob2, color=rally ? color.new(color.red,75) : na, title="Overbought Area")

p_os1 = hline(-80, color=color.new(color.gray,20), title="Oversold Area")
p_os2 = hline(-100, color=color.new(color.gray,10), title="Oversold Area")
fill(p_os1, p_os2, color=draw ? color.new(color.lime,75) : na, title="Oversold Area")

barcolor(use_bar_colors ? col : na, title="Bar Colors")
// }

// HFT Labels {
var label lbl_dyn_len = na
if barstate.islast
    dt = math.round(time-time[1])
    lbl_dyn_len := label.new(time + (5*dt), 80, xloc=xloc.bar_time, textcolor=color.new(color.red,20), style=label.style_none, textalign=text.align_left, text="HTF: " + htf)
    label.delete(lbl_dyn_len[1])
// }

// Divergence Plots {
osc = Z
plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true
_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

// Regular Bullish
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCond = plotBull and priceLL and oscHL and plFound

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Regular Bullish", linewidth=2, color=(bullCond ? bullColor : noneColor))
plotshape(bullCond ? osc[lbR] : na, offset=-lbR, title="Regular Bullish Label", text=" Bull ", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)

// Hidden Bullish
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish", linewidth=2, color=(hiddenBullCond ? hiddenBullColor : noneColor))
plotshape(hiddenBullCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish Label", text=" H Bull ", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)

// Regular Bearish
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCond = plotBear and priceHH and oscLH and phFound

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Regular Bearish", linewidth=2, color=(bearCond ? bearColor : noneColor))
plotshape(bearCond ? osc[lbR] : na, offset=-lbR, title="Regular Bearish Label", text=" Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)

// Hidden Bearish
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish", linewidth=2, color=(hiddenBearCond ? hiddenBearColor : noneColor))
plotshape(hiddenBearCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish Label", text=" H Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)
// }

// Conditions {
cond_bull_breakout = ta.crossover(Z,straddle_area)
cond_bull_top = ta.crossunder(Z,80)
cond_bear_breakout = ta.crossunder(Z,-straddle_area)
cond_bear_bottom = ta.crossover(Z,-80)
// }

// Alerts {
alertcondition(straddle, title="Straddle Area", message="Inside Straddle Area")
alertcondition(cond_bull_breakout, title="Bullish Breakout", message="Bullish Breakout")
alertcondition(cond_bull_top, title="Bull Top", message="Bull Top")
alertcondition(cond_bear_breakout, title="Bearish Breakout", message="Bearish Breakout")
alertcondition(cond_bear_bottom, title="Bear Bottom", message="Bear Bottom")

if use_alerts
    if cond_bull_breakout
        alert(syminfo.tickerid + "Bullish Breakout")
    if cond_bull_top
        alert(syminfo.tickerid + "Bull Top")
    if cond_bear_breakout
        alert(syminfo.tickerid + "Bearish Breakout")
    if cond_bear_bottom
        alert(syminfo.tickerid + "Bear Bottom")
// }
````
