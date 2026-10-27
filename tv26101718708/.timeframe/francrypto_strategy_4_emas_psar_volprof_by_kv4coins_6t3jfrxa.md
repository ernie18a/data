# [francrypto® strategy] 4 EMAs, P.SAR & Vol.Prof. (by kv4coins)

- url: https://www.tradingview.com/script/6t3JfRXa/
- type: indicator
- pine_id: PUB;F976iFyDoKIAAqmv4UpLjMqWX14C9t34
- version: 6.0

## Description

(ENG)
This script consists of my own strategy for cryptocurrency (but can be adapted very well for stocks, forex, etc.)

Is a combination of:
- Four Exponentials Moving Average (EMA), configurables: by defect are 10, 21, 55 and 200 periods in yellow, aqua, orange and blue each of them
- Parabolic SAR System (PSAR), configurable
- Volume Profile (that has been developed by kv4coins - he has already authorized me to use it under the same OSS Licence Terms: MPL 2.0), configurable: with another default values and bilingual support for Spanish (SPA)

[b]How it works[/b]

1) It is always better to detect specifics candlesticks or patrons: [i]doji[/i], [i]pinbar or inverted pinbar[/i], [i]engulfing bars[/i], [i]morning star or evening star[/i], [i]harami[/i], [i]twizzer bottom or top[/i], etc.
2) The 10 and 21 periods EMA help to identify the short-term behavior
3) The 55 periods EMA can be used like a support or resistance in medium-term, as 200 periods EMA in very long-term
4) It will convenient search for a double cross (10 & 21) or a triple cross (10, 21 & 55) to determine the medium-term change Downtrend to UpTrend (or viceversa)
5) Confirm the change patron with the Parabolic SAR and then identify potencials purchases or sales
6) Use Volume profile to detect potential supports or resistances areas, in order to set stop limit/loss and take profit orders.

Hope this helps!
Cheers,
FRANCRYPTO®

–––––– 0 ––––––

(ESP)
Este script consiste en mi propia estrategia para criptomonedas (pero puede adaptarse muy bien para acciones, forex, etc.)

Es la combinación de:
1) Cuatro Medias Móviles Exponenciales (EMA), configurables: por defecto son de 10, 21, 55 y 200 períodos en amarillo, turquesa, naranja y azul cada una de ellas
2) Sistema Parabolic SAR (PSAR), configurable
3) Perfil de Volumen (que fuera desarrollado por kv4coins - que ya me ha autorizado a su uso bajo las mismas condiciones de la Licencia OSS: MPL 2.0), configurable: con otros valores por defecto y soporte bilingüe para Español (SPA)

[b]Cómo funciona[/b]

1) Siempre va a resultar mejor detectar velas japonesas específicas o patrones: [i]doji[/i], [i]martillos o martillos invertidos[/i], [i]velas envolventes[/i], [i]patrón amanecer o atardecer[/i], [i]harami[/i], [i]velas gemelas[/i], etcétera
2) La EMA de 10 y 21 períodos ayudan a identificar el comportamiento de corto plazo
3) La EMA de 55 períodos puede ser usada como un soporte o resistencia de mediano plazo, como así también, la EMA de 200 períodos en el muy largo plazo
4) Será conveniente buscar un doble cruce (10 & 21) o un triple cruce (10, 21 & 55) para determinar un cambio de la tendencia de mediano plazo de bajista hacia alcista (o viceversa)
5) Confirmá el patrón de cambio con la Parabólica de SAR y entonces identificá potenciales compras o ventas
6) Usá el perfil de volumen para detectar las potenciales zonas de soporte o resistencia, principalmente para establecer ordenes stop limit/loss o take profit.

¡Espero que pueda serles de utilidad!
Saludos,
FRANCRYPTO®

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © francrypto_ / francrypto® (Volume Profile has been developed by kv4coins. He has already authorized me to use it under the same OSS Licence Terms: MPL 2.0)

//@version=5
// INDICATOR
//----------//
indicator(title      = "[francrypto®] 4 EMAs, PSAR, VP, BB, RSI, MACD & INFO BOX", 
     shorttitle      = "[francrypto® strategy+] 9 indicators in 1 and more", 
     overlay         = true, 
     precision       = 4, 
     linktoseries    = true, 
     max_bars_back   = 750, 
     max_lines_count = 500)
//----------//

//----------//
// BB (public domain)
// 1) added Bollinger Bands for those who asked for it
// 2) added i_showBB option
// 3) bilingual titles: added spanish (SPA) ones
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
// PSAR (public domain)
// 1) change PSAR circles into teal (bullish) or maroon color (bearish)
// 2) bilingual titles: added spanish (SPA) ones
// 3) added i_showPSAR option
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
// 1) bilingual titles: added spanish (SPA) ones
// 2) max value of EMA 1, 2, 3 & 4: 250 to avoid 'loop takes too long to execute' issue
// 3) default value of EMA 1 (10 periods), EMA 2 (21 periods), EMA 3 (55 periods) & EMA 4 (200 periods)
// 4) added bullish or bearish small crosses
// 5) added bullish or bearish big crosses 
// 6) added i_showEMAS option
//
// VARIABLES
i_showEMAS = input(true, 'Show 4 EMAs // Mostrar 4 EMAs')
Length_Longitud_EMA_1 = input.int(10, '1° EMA length // 1° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_2 = input.int(21, '2° EMA length // 2° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_3 = input.int(55, '3° EMA length // 3° EMA longitud [1-250]', minval=1, maxval=250)
Length_Longitud_EMA_4 = input.int(200, '4° EMA length // 4° EMA longitud [1-250]', minval=1, maxval=250)
ShowCross_EMA_1_EMA2 = input(defval=true, title="1 & 2 EMAs Small crosses // Cruces pequeños de EMAs 1 y 2")
ShowCross_EMA_3_EMA4 = input(defval=true, title="3 & 4 EMAs Big Crosses // Cruces grandes de EMAs 3 y 4")

EMA1 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_1) : na
EMA2 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_2) : na
EMA3 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_3) : na
EMA4 = i_showEMAS ? ta.ema(close, Length_Longitud_EMA_4) : na

golden_cross_small = ta.cross(EMA2, EMA1) and EMA1[1] <= EMA2[1] and ShowCross_EMA_1_EMA2
death_cross_small = ta.cross(EMA2, EMA1) and EMA2[1] <= EMA1[1] and ShowCross_EMA_1_EMA2
golden_cross = ta.cross(EMA4, EMA3) and EMA3[1] <= EMA4[1] and ShowCross_EMA_3_EMA4
death_cross = ta.cross(EMA4, EMA3) and EMA4[1] <= EMA3[1] and ShowCross_EMA_3_EMA4

// PLOTING
plot(EMA1, color=color.new(#ffff00, 25), linewidth=1, title='1° Exponential Moving Average // 1° Media Móvil Exponencial')
plot(EMA2, color=color.new(#00e6ff, 25), linewidth=1, title='2° Exponential Moving Average // 2° Media Móvil Exponencial')
plot(EMA3, color=color.new(#ffa600, 0), linewidth=1, title='3° Exponential Moving Average // 3° Media Móvil Exponencial')
plot(EMA4, color=color.new(#001eff, 0), linewidth=1, title='4° Exponential Moving Average // 4° Media Móvil Exponencial')

plot(ShowCross_EMA_1_EMA2 ? (ta.cross(EMA1, EMA2) ? EMA1 : na) : na, color=EMA2 - EMA1 > 0 ? color.red : color.lime, style=plot.style_circles, linewidth=4)
plot(ShowCross_EMA_3_EMA4 ? (ta.cross(EMA3, EMA4) ? EMA3 : na) : na, color=EMA4 - EMA3 > 0 ? color.red : color.lime, style=plot.style_cross, linewidth=4)
//----------//

//----------//
// VOLUME PROFILE (VP developed by @kv4coins)
//
// my changes to his code
// 1) bilingual titles: added spanish (SPA) ones
// 2) default value of 'vp_lookback': back 200 to avoid 'loop takes too long to execute' issue
// 3) default value of 'vp_bar_width': 2 so that it looks better
// 4) default value of 'vp_bar_mult': 60 so that it looks better
// 5) default value of 'vp_bar_offset': 62 for a simplified screen
// 6) default value of 'vp_poc_show': false for a simplified screen
// 7) max value of 'vp_lookback': 750 to avoid 'loop takes too long to execute' issue
// 8) max value of 'vp_bar_mult': 200 for a simplified screen
// 9) max value of 'vp_bar_offset': 200 for a simplified screen
// 10) placed 'vp_bar_color' in 75% transparent aqua and 'vp_poc_color' in a solid aqua
// 11) codded bullish and bearish 'bools' to avoid 'loop takes too long to execute' issue
// 12) added i_showVP option
//
// INPUTS
i_showVP = input(true, 'Show VP // Mostrar Perfil de Volumen')

vp_lookback = input.int(defval=200, title='VP Lookback Depth // Retrospectiva Profundidad del Perfil de Volumen [10-750]', minval=10, maxval=750)

vp_max_bars = input.int(defval=250, title='VP Number of Bars // Cantidad de Barras del Perfil de Volumen [10-500]', minval=10, maxval=500)

vp_bar_mult = input.int(defval=60, title='VP Bar Length Multiplier // Longitud de las Barras del Perfil de Volumen [10-200]', minval=10, maxval=200)

vp_bar_offset = input.int(defval=62, title='VP Bar Horizontal Offset // Distancia en Eje Horizontal de las Barras del Perfil de Volumen [0-200]', minval=0, maxval=200)

vp_bar_width = input.int(defval=2, title='VP Bar Width // Ancho de las Barras del Perfil de Volumen [1-20]', minval=1, maxval=20)

// As suggested by @NXT2017 to @kv4coins
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

//----------//
// LABEL
//
// 1) added "FRANCRYPTO® information box" Label
// 2) color NavyBlue for Label with orange text
// 3) added Rounds for all decimals
// 4) value of 'Label Vertical Offset' (or Y) = close price value
// 5) default value of 'Label Horizontal Offset' (or X): 65 (and 'maxval': 205) for a simplified screen
// 6) added U$S CCL (for Argentina)
// 7) added Indices and Commodities Section
// 8) added Crypto Dominance Section
// 9) added MACD Section with current trendline: Bullish or Bearish
// 10) added RSI Section with current value in Label
// 11) RSI Overbuy turns Label into Teal color with White text
// 12) RSI Oversell turns Label into Maroon color with White text
// 13) Changed Gold & Silver tickets to 'GOLD' & 'SILVER' because ticket 'SIL1!' doesn't have data
// 
i_offsetLabel = input.int(defval=65, title='Label Horizontal Offset // Distancia en Eje Horizontal de la Etiqueta [0-205]', minval=0, maxval=205)

offset = i_offsetLabel * (time - time[1])
splitter = '__________________'
nl = '\n'
title = '╔╗ FRANCRYPTO®' + nl + '╠╗    Info. BOX' + nl + '═╝    💡🔗💻'

string dynamicText = title + nl
var label id = na
label.delete(id)
id := label.new(x=time + offset, y=close, xloc=xloc.bar_time, text=dynamicText)

// LABEL VARIABLES
i_showCCL = input(true, 'Show CCL dollar // Mostrar dólar CCL')
i_showINDEX = input(true, 'Show INDICES // Mostrar INDICES')
i_showDOMINANCE = input(true, 'Show DOMINANCE // Mostrar DOMINANCE')
i_showMACD = input(true, 'Show MACD // Mostrar MACD')
i_showRSI = input(true, 'Show RSI // Mostrar RSI')

// ROUNDS
f_round(_val, _decimals) =>
    if _decimals == -1
        _val
    else
        _p = math.pow(10, _decimals)
        math.round(math.abs(_val) * _p) / _p * math.sign(_val)

f_strHelp(_prefix, _var, _round) =>
    _res = str.tostring(f_round(_var, _round))
    _prefix + ' ' + _res + nl

// CCLSection
CCLTitle = splitter + nl
CCLClose = request.security('(BCBA:GGAL/NASDAQ:GGAL*10+BCBA:BMA/NYSE:BMA*10+BCBA:YPFD/NYSE:YPF+BCBA:PAMP/NYSE:PAM*25+BCBA:BBAR/NYSE:BBAR*3)/5', 'M', close)
CCL = f_strHelp('🇦🇷$ CCL💸 💲', CCLClose, 1)
CCLSection = i_showCCL ? CCLTitle + nl + CCL : na

// INDEXSection
INDEXTitle = splitter + nl + nl + 'Forex💰 & Metals🔒️' + nl
DOLLARClose = request.security('DXY', 'M', close)
DOLLAR = f_strHelp('US$ Index 💵 Val:', DOLLARClose, 1)
EUROClose = request.security('EXY', 'M', close)
EURO = f_strHelp('€ Index 💶 Val:', EUROClose, 1)
GOLDClose = request.security('GOLD', 'M', close)
GOLD = f_strHelp('Gold 🟡 💲', GOLDClose, 1)
SILVERClose = request.security('SILVER', 'M', close)
SILVER = f_strHelp('Silver ⚪ 💲', SILVERClose, 1)
INDEXSection = i_showINDEX ? INDEXTitle + nl + DOLLAR + EURO + nl + GOLD + SILVER : na

// DOMINANCESection
DOMINANCETitle = splitter + nl + nl + 'Crypto Dominance🌐' + nl
BTCDClose = request.security('BTC.D', 'M', close)
BTCD = f_strHelp('BTC ₿ % →', BTCDClose, 1)
ETHDClose = request.security('ETH.D', 'M', close)
ETHD = f_strHelp('ETH ⬨ % →', ETHDClose, 1)
DOMINANCESection = i_showDOMINANCE ? DOMINANCETitle + nl + BTCD + ETHD : na

// MACDSection
MACDTitle = splitter + nl
[macd, macdsignal, macdhist] = ta.macd(close, fastlen=12, slowlen=26, siglen=9)
trend3 = macdhist > 0 ? '[ Bullish 📈 Alcista ]' : '[ Bearish 📉 Bajista ]'
MACDSection = i_showMACD ? MACDTitle + nl + 'MACD Trend 📊 Tend:' + nl + trend3 + nl : na

// RSISection
RSITitle = splitter + nl
rsi = ta.rsi(close, 14)
Trend1 = rsi > 70 ? nl + '🚨⚠️ 🚨⚠️ 🚨' + nl + nl + '[ OVERBUY!!!! 📈' + nl + '¡¡SOBRECOMPRA!! ]' : na
Trend2 = rsi < 30 ? nl + '🚨⚠️ 🚨⚠️ 🚨' + nl + nl + '[ OVERSELL!!!! 📉' + nl + '¡¡SOBREVENTA!! ]' : na
RSISection = i_showRSI ? RSITitle + nl + f_strHelp('RSI 🧮 〽️ Val:', rsi, 1) + Trend1 + Trend2 : na

// STYLE
label.set_textalign(id, text.align_left)
label.set_color(id, color=color.rgb(0, 0, 50, 0))
label.set_textcolor(id, textcolor=color.new(color.orange, 0))
label.set_style(id, label.style_label_left)

// DynamicText
dynamicText := dynamicText + CCLSection + INDEXSection + DOMINANCESection + MACDSection + RSISection
label.set_text(id, text=dynamicText)

if Trend1 == nl + '🚨⚠️ 🚨⚠️ 🚨' + nl + nl + '[ OVERBUY!!!! 📈' + nl + '¡¡SOBRECOMPRA!! ]'
    label.set_textcolor(id, textcolor=color.white)
    label.set_color(id, color.teal)

if Trend2 == nl + '🚨⚠️ 🚨⚠️ 🚨' + nl + nl + '[ OVERSELL!!!! 📉' + nl + '¡¡SOBREVENTA!! ]'
    label.set_textcolor(id, textcolor=color.white)
    label.set_color(id, color.maroon)
//----------//
// END
````
