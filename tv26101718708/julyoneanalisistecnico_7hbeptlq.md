# July_One_Analisis_Tecnico

- url: https://www.tradingview.com/script/7HbePtLQ/
- type: indicator
- pine_id: PUB;4322f0977a6b4cfd9f5094f0b661c495
- version: 1.0

## Description

Conjunto de indicadores Técnicos de mi preferencia.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © francrypto_ / francrypto® (Volume Profile has been developed by kv4coins. He has already authorized me to use it under the same OSS Licence Terms: MPL 2.0)

//@version=5
// INDICATOR
//----------//
indicator(title      = "July_One_Analisis_Tecnico", 
     shorttitle      = "July_One_Analisis_Tecnico", 
     overlay         = true, 
     precision       = 4, 
     linktoseries    = true, 
     max_bars_back   = 750, 
     max_lines_count = 500)
//----------//

//----------//
// BB (public domain)
//
i_showBB = input(true, 'Show BB // Mostrar Bandas de Bollinger')
length = input.int(20, minval=1, title="BB Length // Bandas Bollinger Longitud")
src = input(close, title="BB Source // Bandas Bollinger Fuente")
mult = input.float(2.0, minval=0.001, maxval=50, title="BB Standard Deviation // Bandas Bollinger Desviación Típica")
basis = i_showBB ? ta.sma(src, length) : na
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev
BBoffset = input.int(0, "BB Offset // Bandas Bollinger Compensar", minval = -500, maxval = 500)
plot(basis, "BB Basis // Bandas Bollinger Base", color=color.rgb(33, 150, 243, 75), linewidth=1, style=plot.style_cross, offset = BBoffset)
p1 = plot(upper, "BB Upper // Bandas Bollinger Superior", color=color.rgb(33, 150, 243, 75), offset = BBoffset)
p2 = plot(lower, "BB Lower // Bandas Bollinger Inferior", color=color.rgb(33, 150, 243, 75), offset = BBoffset)
fill(p1, p2, title = "Background", color=color.rgb(33, 150, 243, 95))
//----------//

//----------//
// PSAR (public domain)
//
i_showPSAR = input(true, 'Show PSAR // Mostrar Parabólica de SAR')
start = input(0.02, 'PSAR Start // Parabólica de SAR Comienzo')
increment = input(0.02, 'PSAR Increment // Parabólica de SAR Incremento')
maximum = input(0.2, 'PSAR Max Value // Parabólica de SAR Valor Máximo')
out = i_showPSAR ? ta.sar(start, increment, maximum) : na
PSARClose = out < close ? 1 : -1
PSARColor = PSARClose == 1 ? color.teal : color.maroon
plot(out, 'PSAR // Parabólica de SAR', style=plot.style_circles, color=PSARColor)
//----------//

//----------//
// EMA's (public domain)
//
// VARIABLES
i_showEMAS = input(true, 'Show 6 EMAs // Mostrar 6 EMAs')
Length_Longitud_EMA_1 = input.int(10,  '1° EMA length // 1° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_2 = input.int(21,  '2° EMA length // 2° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_3 = input.int(55,  '3° EMA length // 3° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_4 = input.int(100, '4° EMA length // 4° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_5 = input.int(150, '5° EMA length // 5° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_6 = input.int(200, '6° EMA length // 6° EMA longitud [1-250]', minval=1, maxval=250)
ShowCross_EMA_1_EMA2 = input(defval=true, title="1 & 2 EMAs Small crosses // Cruces pequeños de EMAs 1 y 2")
ShowCross_EMA_3_EMA4 = input(defval=true, title="3 & 4 EMAs Big Crosses // Cruces grandes de EMAs 3 y 4")

EMA1 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_1) : na
EMA2 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_2) : na
EMA3 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_3) : na
EMA4 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_4) : na
EMA5 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_5) : na
EMA6 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_6) : na

golden_cross_small = ta.cross(EMA2, EMA1) and EMA1[1] <= EMA2[1] and ShowCross_EMA_1_EMA2
death_cross_small  = ta.cross(EMA2, EMA1) and EMA2[1] <= EMA1[1] and ShowCross_EMA_1_EMA2
golden_cross       = ta.cross(EMA4, EMA3) and EMA3[1] <= EMA4[1] and ShowCross_EMA_3_EMA4
death_cross        = ta.cross(EMA4, EMA3) and EMA4[1] <= EMA3[1] and ShowCross_EMA_3_EMA4

// PLOTING EMAs
plot(EMA1, color=color.new(#ffff00, 25), linewidth=1, title='1° Exponential Moving Average // 1° Media Móvil Exponencial')
plot(EMA2, color=color.new(#00e6ff, 25), linewidth=1, title='2° Exponential Moving Average // 2° Media Móvil Exponencial')
plot(EMA3, color=color.new(#ffa600,  0), linewidth=1, title='3° Exponential Moving Average // 3° Media Móvil Exponencial')
plot(EMA4, color=color.new(#ff00ff,  0), linewidth=1, title='4° Exponential Moving Average // 4° Media Móvil Exponencial')
plot(EMA5, color=color.new(#00ff88,  0), linewidth=1, title='5° Exponential Moving Average // 5° Media Móvil Exponencial')
plot(EMA6, color=color.new(#001eff,  0), linewidth=1, title='6° Exponential Moving Average // 6° Media Móvil Exponencial')

plot(ShowCross_EMA_1_EMA2 ? (ta.cross(EMA1, EMA2) ? EMA1 : na) : na, color=EMA2 - EMA1 > 0 ? color.red : color.lime, style=plot.style_circles, linewidth=4)
plot(ShowCross_EMA_3_EMA4 ? (ta.cross(EMA3, EMA4) ? EMA3 : na) : na, color=EMA4 - EMA3 > 0 ? color.red : color.lime, style=plot.style_cross,   linewidth=4)
//----------//

//----------//
// SMA & WMA 200 (public domain)
//
i_showSMA200 = input(true, 'Show SMA 200 // Mostrar SMA 200 (Media Simple)')
i_showWMA200 = input(true, 'Show WMA 200 // Mostrar WMA 200 (Media Ponderada)')

SMA200 = i_showSMA200 ? ta.sma(close, 200) : na
WMA200 = i_showWMA200 ? ta.wma(close, 200) : na

// PLOTING SMA & WMA
plot(SMA200, color=color.new(#ff4444, 0), linewidth=2, title='SMA 200 // Media Móvil Simple 200')
plot(WMA200, color=color.new(#ffffff, 0), linewidth=2, title='WMA 200 // Media Móvil Ponderada 200')
//----------//

//----------//
// VOLUME PROFILE (VP developed by @kv4coins)
//
// INPUTS
i_showVP = input(true, 'Show VP // Mostrar Perfil de Volumen')

vp_lookback = input.int(defval=200, title='VP Lookback Depth // Retrospectiva Profundidad del Perfil de Volumen [10-750]', minval=10, maxval=750)

vp_max_bars = input.int(defval=250, title='VP Number of Bars // Cantidad de Barras del Perfil de Volumen [10-500]', minval=10, maxval=500)

vp_bar_mult = input.int(defval=60, title='VP Bar Length Multiplier // Longitud de las Barras del Perfil de Volumen [10-200]', minval=10, maxval=200)

vp_bar_offset = input.int(defval=62, title='VP Bar Horizontal Offset // Distancia en Eje Horizontal de las Barras del Perfil de Volumen [0-200]', minval=0, maxval=200)

vp_bar_width = input.int(defval=2, title='VP Bar Width // Ancho de las Barras del Perfil de Volumen [1-20]', minval=1, maxval=20)

vp_delta_type = input.string(defval='Both // Ambos', title='VP Delta Type // Variable Delta del Perfil de Volumen', options=['Both // Ambos', 'Bullish // Toros', 'Bearish // Osos'])

vp_poc_show = input(defval=false, title='VP Extend POC Line // Extender Línea del Punto de Control del Perfil de Volumen')

vp_bar_color = input(defval=color.new(color.aqua, 75), title='VP Bar Color // Color de la Barra del Perfil de Volumen')

vp_poc_color = input(defval=color.new(color.aqua, 0), title='VP POC Color // Color del Punto de control del Perfil de Volumen')

// VARIABLES
float vp_Vmax = 0.0
int vp_VmaxId = 0
int vp_N_BARS = vp_max_bars

var int vp_first = time

vp_a_P = array.new_float(vp_N_BARS + 1, 0.0)
vp_a_V = array.new_float(vp_N_BARS, 0.0)
vp_a_D = array.new_float(vp_N_BARS, 0.0)
vp_a_W = array.new_int(vp_N_BARS, 0)

// CALCULATIONS
float vp_HH = i_showVP ? ta.highest(high, vp_lookback) : na
float vp_LL = i_showVP ? ta.lowest(low, vp_lookback) : na

bool Bullish = vp_delta_type == 'Bullish // Toros'
bool Bearish = vp_delta_type == 'Bearish // Osos'

if barstate.islast
    float vp_HL = (vp_HH - vp_LL) / vp_N_BARS
    for j = 1 to vp_N_BARS + 1 by 1
        array.set(vp_a_P, j - 1, vp_LL + vp_HL * j)
    for i = 0 to vp_lookback - 1 by 1
        int Dc = 0
        array.fill(vp_a_D, 0.0)
        for j = 0 to vp_N_BARS - 1 by 1
            float Pj = array.get(vp_a_P, j)
            if low[i] < Pj and high[i] > Pj and (Bullish ? close[i] >= open[i] : Bearish ? close[i] <= open[i] : true)
                float Dj = array.get(vp_a_D, j)
                float dDj = Dj + nz(volume[i])
                array.set(vp_a_D, j, dDj)
                Dc := Dc + 1
                Dc
        for j = 0 to vp_N_BARS - 1 by 1
            float Vj = array.get(vp_a_V, j)
            float Dj = array.get(vp_a_D, j)
            float dVj = Vj + (Dc > 0 ? Dj / Dc : 0.0)
            array.set(vp_a_V, j, dVj)
    vp_Vmax := array.max(vp_a_V)
    vp_VmaxId := array.indexof(vp_a_V, vp_Vmax)
    for j = 0 to vp_N_BARS - 1 by 1
        float Vj = array.get(vp_a_V, j)
        int Aj = math.round(vp_bar_mult * Vj / vp_Vmax)
        array.set(vp_a_W, j, Aj)

// PLOTING
if barstate.isfirst
    vp_first := time
    vp_first
vp_change = ta.change(time)
vp_x_loc = timenow + math.round(vp_change * vp_bar_offset)

f_setup_bar(n) =>
    x1 = vp_VmaxId == n and vp_poc_show ? math.max(time[vp_lookback], vp_first) : timenow + math.round(vp_change * (vp_bar_offset - array.get(vp_a_W, n)))
    ys = array.get(vp_a_P, n)
    line.new(x1=x1, y1=ys, x2=vp_x_loc, y2=ys, xloc=xloc.bar_time, extend=extend.none, color=vp_VmaxId == n ? vp_poc_color : vp_bar_color, style=line.style_solid, width=vp_bar_width)

if barstate.islast
    for i = 0 to vp_N_BARS - 1 by 1
        f_setup_bar(i)
//----------//

// END
````
