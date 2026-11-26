# Medias Moviles retroceso ath

- url: https://www.tradingview.com/script/nz8Dq6bH/
- type: indicator
- pine_id: PUB;88346ff73db54ad1b46d1981a370c9ab
- version: 1.0

## Description

cinco indicadores que te permiten tener una excelente estrategia

## Source Code

````pine
//@CDI-DIEGO
//@version=6
//Este indicador combina el retroceso que hace un ticker desde su Alto Histórico, nos muestra siete medias móviles en cualquier temporalidad,
//las siete medias móviles en temporalidad fija de 1D y una tabla con el performance de la acción que estamos viendo en el momento, así como el ATR en % y USD

indicator('Medias Móviles/ retroceso ATH', 'CDI Medias Móviles & ATH', overlay=true)

var float valorMedia_A = na
var float valorMedia_B = na
var float valorMedia_C = na
var float valorMedia_D = na
var float valorMedia_E = na
var float valorMedia_F = na
var float valorMedia_G = na

inf    = 'Temporalidad para las Medias Móviles'
infAtr = "El estudio de rango verdadero promedio (ATR) calcula el rango de precio real promedio durante un período de tiempo."
toolTip1 = "Posible movimiento del precio diario"
toolTip2 = "% de movimiento que lleva en el día respecto al promedio"

Mostrar_T   = input.bool(false, 'Mostrar Performance', group='El Club de Inversionistas', inline='a')
mostrarATR  = input.bool(false , tooltip = infAtr, title= "Mostrar ATR diario", group='El Club de Inversionistas', inline='b')
lengthAtr   = input(defval=14, title= "  Longitud ATR diario", group='El Club de Inversionistas', inline='b')
showAth = input.bool(false, 'Mostrar ATH', group='El Club de Inversionistas', inline='c')
mostrar_W_M = input.bool(false, 'CDI Cuido mi capital', group='El Club de Inversionistas', inline='d')

/////////////// ATR Diario //////////////

var table T_atr = table.new(position.top_center, columns = 2, rows = 1, border_width = 1)

AtrDiario() =>
    _AtrDiario = ta.atr(lengthAtr) / close * 100
    _AtrDiario
AtrDiarioUsd =  close * ta.atr(lengthAtr) / close

Mov_Dia() =>
    _Mov_Dia = (high - low) *100 / AtrDiarioUsd
    _Mov_Dia

_colorAtr  = color.blue
_transp   = 60
_textColor = color.white

cellAtrDiario(_table, _column, _row, _value,  _value1) =>
    _atrDiario = "ATR diario = " + str.tostring(_value, '0.00') + '% \n' + "ATR diario = " + str.tostring(_value1, '0.00') + " USD"
    table.cell(_table, _column, _row, _atrDiario, bgcolor=_colorAtr, text_color=_textColor, tooltip= toolTip1)
   
cellAtrMov(_table, _column, _row, _value,  _value1) =>
    _atrMov = "Movimiento ATR diario \n" + str.tostring(_value, '0.00') + " %"
    table.cell(_table, _column, _row, _atrMov, bgcolor=_colorAtr, text_color=_textColor, tooltip= toolTip2)
    
if mostrarATR and timeframe.isdaily
    cellAtrDiario(T_atr, 0, 0, AtrDiario(), AtrDiarioUsd)
    cellAtrMov(T_atr, 1, 0, Mov_Dia(), 'en el día')
    
///////// P E R F O R M A N C E //////////

var table T_performance = table.new(position.top_right, 3, 2, border_width=1)

f_return(_v1, _v2) =>
    (_v1 - _v2) * 100 / math.abs(_v2)

f_performance(_barsBack) =>
    _performance = request.security(syminfo.tickerid, '1D', f_return(close, close[_barsBack]))
    _performance

lastYearClose = request.security(syminfo.tickerid, '12M', close[1], lookahead=barmerge.lookahead_on)

C_positivo = #196F3D
C_negativo = color.red

f_fillCell(_table, _column, _row, _value, _timeframe) =>
    _c_color  = color.new(_value >= 0 ? C_positivo : C_negativo, 0)
    _cellText = str.tostring(_value, '0.00') + '%\n' + _timeframe
    table.cell(_table, _column, _row, _cellText, bgcolor=_c_color, text_color=color.white)

if Mostrar_T
    f_fillCell(T_performance, 2, 1, f_performance(251), '1 Year')
    f_fillCell(T_performance, 1, 1, f_return(close, lastYearClose), 'Ytd')
    f_fillCell(T_performance, 0, 1, f_performance(126), '6 Months')
    f_fillCell(T_performance, 2, 0, f_performance(63), '3 Months')
    f_fillCell(T_performance, 1, 0, f_performance(21), '1 Month')
    f_fillCell(T_performance, 0, 0, f_performance(5), '1 Week')

///////// MEDIAS MÓVILES DINÁMICAS //////////
marcoTiempo = input.timeframe(defval='', title='Marco de tiempo', tooltip=inf, group='Medias Móviles ', inline='0')
M_avg = input(true, 'Mostrar medias móviles', group='Medias Móviles ', inline='e')

M_Avg1 = input.bool(defval=true, title='', group='Medias Móviles ', inline='1')
P_Avg1 = input.int(defval=8, minval=1, title='Periodo', group='Medias Móviles ', inline='1')
C_Avg1 = input.color(defval=color.blue, title='Color', group='Medias Móviles ', inline='1')
T_Avg1 = input.string(title='Media A', defval='EMA', options=['EMA', 'SMA'], group='Medias Móviles ', inline='1')

M_Avg2 = input.bool(defval=true, title='', group='Medias Móviles ', inline='2')
P_Avg2 = input.int(defval=21, minval=1, title='Periodo', group='Medias Móviles ', inline='2')
C_Avg2 = input.color(title='Color', defval=color.red, group='Medias Móviles ', inline='2')
T_Avg2 = input.string(title='Media B', defval='EMA', options=['EMA', 'SMA'], group='Medias Móviles ', inline='2')

M_Avg3 = input.bool(title='', defval=true, group='Medias Móviles ', inline='3')
P_Avg3 = input.int(defval=50, minval=1, title='Periodo', group='Medias Móviles ', inline='3')
C_Avg3 = input.color(title='Color', defval=color.green, group='Medias Móviles ', inline='3')
T_Avg3 = input.string(title='Media C', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles ', inline='3')

M_Avg4 = input.bool(title='', defval=false, group='Medias Móviles ', inline='4')
P_Avg4 = input.int(defval=75, minval=1, title='Periodo', group='Medias Móviles ', inline='4')
C_Avg4 = input.color(title='Color', defval=color.aqua, group='Medias Móviles ', inline='4')
T_Avg4 = input.string(title='Media D', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles ', inline='4')

M_Avg5 = input.bool(title='', defval=false, group='Medias Móviles ', inline='5')
P_Avg5 = input.int(defval=100, minval=1, title='Periodo', group='Medias Móviles ', inline='5')
C_Avg5 = input.color(title='Color', defval=color.purple, group='Medias Móviles ', inline='5')
T_Avg5 = input.string(title='Media E', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles ', inline='5')

M_Avg6 = input.bool(title='', defval=false, group='Medias Móviles ', inline='6')
P_Avg6 = input.int(defval=150, minval=1, title='Periodo', group='Medias Móviles ', inline='6')
C_Avg6 = input.color(title='Color', defval=color.orange, group='Medias Móviles ', inline='6')
T_Avg6 = input.string(title='Media F', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles ', inline='6')

M_Avg7 = input.bool(title='', defval=false, group='Medias Móviles ', inline='7')
P_Avg7 = input.int(defval=200, minval=1, title='Periodo', group='Medias Móviles ', inline='7')
C_Avg7 = input.color(title='Color', defval=color.maroon, group='Medias Móviles ', inline='7')
T_Avg7 = input.string(title='Media G', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles ', inline='7')

                                        // Cálculo de medias
valorMedia_A := T_Avg1 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo, ta.ema(close, P_Avg1)) : request.security(syminfo.tickerid, marcoTiempo, ta.sma(close, P_Avg1))
valorMedia_B := T_Avg2 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo, ta.ema(close, P_Avg2)) : request.security(syminfo.tickerid, marcoTiempo, ta.sma(close, P_Avg2))
valorMedia_C := T_Avg3 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo, ta.ema(close, P_Avg3)) : request.security(syminfo.tickerid, marcoTiempo, ta.sma(close, P_Avg3))
valorMedia_D := T_Avg4 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo, ta.ema(close, P_Avg4)) : request.security(syminfo.tickerid, marcoTiempo, ta.sma(close, P_Avg4))
valorMedia_E := T_Avg5 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo, ta.ema(close, P_Avg5)) : request.security(syminfo.tickerid, marcoTiempo, ta.sma(close, P_Avg5))
valorMedia_F := T_Avg6 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo, ta.ema(close, P_Avg6)) : request.security(syminfo.tickerid, marcoTiempo, ta.sma(close, P_Avg6))
valorMedia_G := T_Avg7 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo, ta.ema(close, P_Avg7)) : request.security(syminfo.tickerid, marcoTiempo, ta.sma(close, P_Avg7))

plot(M_avg == true and M_Avg1 == true ? valorMedia_A : na, title= "Media A", color=C_Avg1, editable=false)
plot(M_avg == true and M_Avg2 == true ? valorMedia_B : na, title= "Media B", color=C_Avg2, editable=false)
plot(M_avg == true and M_Avg3 == true ? valorMedia_C : na, title= "Media C", color=C_Avg3, editable=false)
plot(M_avg == true and M_Avg4 == true ? valorMedia_D : na, title= "Media D", color=C_Avg4, editable=false)
plot(M_avg == true and M_Avg5 == true ? valorMedia_E : na, title= "Media E", color=C_Avg5, editable=false)
plot(M_avg == true and M_Avg6 == true ? valorMedia_F : na, title= "Media F", color=C_Avg6, editable=false)
plot(M_avg == true and M_Avg7 == true ? valorMedia_G : na, title= "Media G", color=C_Avg7, editable=false)

///////// A T H ////////// 

C_line1  = input.color(defval=color.purple, title='3% ', group='retroceso desde el ATH', inline='1')
m_tres   = input.bool(defval=true, title='   ', group='retroceso desde el ATH', inline='1')
C_line2  = input.color(defval=color.orange, title='5% ', group='retroceso desde el ATH', inline='1')
m_cinco  = input.bool(defval=true, title='   ', group='retroceso desde el ATH', inline='1')
C_line3  = input.color(defval=color.green, title='10%', group='retroceso desde el ATH', inline='1')
m_diez   = input.bool(defval=true, title='   ',  group='retroceso desde el ATH', inline='1')
C_line4  = input.color(defval=color.gray, title='13%', group='retroceso desde el ATH', inline='2')
m_trece  = input.bool(defval=true, title='   ',  group='retroceso desde el ATH', inline='2')
C_line5  = input.color(defval=color.lime, title=' 15%', group='retroceso desde el ATH', inline='2')
m_quince = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='2')
C_line6  = input.color(defval=color.aqua, title='20%', group='retroceso desde el ATH', inline='2')
m_veinte = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='2')
C_line7  = input.color(defval=color.fuchsia, title='25%', group='retroceso desde el ATH', inline='3')
m_25     = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='3')
C_line8  = input.color(defval=color.blue, title='30%', group='retroceso desde el ATH', inline='3')
m_30     = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='3')
C_line9  = input.color(defval=color.red, title='35%', group='retroceso desde el ATH', inline='3')
m_35     = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='3')
C_line10 = input.color(defval=color.yellow, title='40%', group='retroceso desde el ATH', inline='4')
m_40     = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='4')
C_line11 = input.color(defval=color.maroon, title='45%', group='retroceso desde el ATH', inline='4')
m_45     = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='4')
C_line12 = input.color(defval=color.olive, title='50%', group='retroceso desde el ATH', inline='4')
m_50     = input.bool(defval=false, title='   ', group='retroceso desde el ATH', inline='4')

Style_line = line.style_dashed
high_Label = high

highest_high() =>
    var float h = 0.0
    h := math.max(h, high)
    h

var high_1M = request.security(syminfo.tickerid, '1M', highest_high(), lookahead=barmerge.lookahead_off)
var high_1W = request.security(syminfo.tickerid, '1W', highest_high(), lookahead=barmerge.lookahead_off)
var high_1D = request.security(syminfo.tickerid, '1D', highest_high(), lookahead=barmerge.lookahead_off)
var ATH_label = showAth ? label.new(bar_index, high, text='ATH', color=color.black, textcolor=color.white, style=label.style_label_down, size=size.small) : na
var ATH = nz(high_1M, nz(high_1W, nz(high_1D, high)))
ATH := math.max(high, nz(ATH[1], ATH))

//Altura "y" de las líneas de %
tres = math.abs(ATH - ATH * 3 / 100)
cinco = math.abs(ATH - ATH * 5 / 100)
diez = math.abs(ATH - ATH * 10 / 100)
trece = math.abs(ATH - ATH * 13 / 100)
quince = math.abs(ATH - ATH * 15 / 100)
veinte = math.abs(ATH - ATH * 20 / 100)
y25 = math.abs(ATH - ATH * 25 / 100)
y30 = math.abs(ATH - ATH * 30 / 100)
y35 = math.abs(ATH - ATH * 35 / 100)
y40 = math.abs(ATH - ATH * 40 / 100)
y45 = math.abs(ATH - ATH * 45 / 100)
y50 = math.abs(ATH - ATH * 50 / 100)

if ATH > ATH[1] and showAth
    label.set_xy(ATH_label, bar_index, ATH)

///////Medias móviles en temporalidad 1D
desplazamiento = 5 * (time - time[1])

L_tres  = m_tres   and showAth == true ? line.new(time + desplazamiento, tres  , time , tres  , xloc=xloc.bar_time, color = C_line1 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_cinco = m_cinco  and showAth == true ? line.new(time + desplazamiento, cinco , time , cinco , xloc=xloc.bar_time, color = C_line2 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_diez  = m_diez   and showAth == true ? line.new(time + desplazamiento, diez  , time , diez  , xloc=xloc.bar_time, color = C_line3 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_trece = m_trece  and showAth == true ? line.new(time + desplazamiento, trece , time , trece , xloc=xloc.bar_time, color = C_line4 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_quince= m_quince and showAth == true ? line.new(time + desplazamiento, quince, time , quince, xloc=xloc.bar_time, color = C_line5 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_veinte= m_veinte and showAth == true ? line.new(time + desplazamiento, veinte, time , veinte, xloc=xloc.bar_time, color = C_line6 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_25    = m_25     and showAth == true ? line.new(time + desplazamiento, y25,    time , y25   , xloc=xloc.bar_time, color = C_line7 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_30    = m_30     and showAth == true ? line.new(time + desplazamiento, y30,    time , y30   , xloc=xloc.bar_time, color = C_line8 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_35    = m_35     and showAth == true ? line.new(time + desplazamiento, y35,    time , y35   , xloc=xloc.bar_time, color = C_line9 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_40    = m_40     and showAth == true ? line.new(time + desplazamiento, y40,    time , y40   , xloc=xloc.bar_time, color = C_line10 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_45    = m_45     and showAth == true ? line.new(time + desplazamiento, y45,    time , y45   , xloc=xloc.bar_time, color = C_line11 , style = line.style_dashed, extend=extend.left, width=1 ):na
L_50    = m_50     and showAth == true ? line.new(time + desplazamiento, y50,    time , y50   , xloc=xloc.bar_time, color = C_line12 , style = line.style_dashed, extend=extend.left, width=1 ):na

N_tres  = m_tres and showAth == true ? label.new(time + desplazamiento, tres  , "- 3%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line1, size=size.normal,color=color.new(color.red,100)):na
N_cinco = m_cinco and showAth == true ? label.new(time + desplazamiento, cinco , "- 5%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line2, size=size.normal,color=color.new(color.red,100)):na
N_diez  = m_diez and showAth == true ? label.new(time + desplazamiento, diez  , "-10%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line3, size=size.normal,color=color.new(color.red,100)):na
N_trece = m_trece and showAth == true ? label.new(time + desplazamiento, trece , "-13%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line4, size=size.normal,color=color.new(color.red,100)):na
N_quince= m_quince and showAth == true ? label.new(time + desplazamiento, quince, "-15%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line5, size=size.normal,color=color.new(color.red,100)):na
N_veinte= m_veinte and showAth == true ? label.new(time + desplazamiento, veinte, "-20%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line6, size=size.normal,color=color.new(color.red,100)):na
N_25    = m_25     and showAth == true ? label.new(time + desplazamiento, y25,    "-25%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line7, size=size.normal,color=color.new(color.red,100)):na
N_30    = m_30     and showAth == true ? label.new(time + desplazamiento, y30,    "-30%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line8, size=size.normal,color=color.new(color.red,100)):na
N_35    = m_35     and showAth == true ? label.new(time + desplazamiento, y35,    "-35%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line9, size=size.normal,color=color.new(color.red,100)):na
N_40    = m_40     and showAth == true ? label.new(time + desplazamiento, y40,    "-40%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line10, size=size.normal,color=color.new(color.red,100)):na
N_45    = m_45     and showAth == true ? label.new(time + desplazamiento, y45,    "-45%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line11, size=size.normal,color=color.new(color.red,100)):na
N_50    = m_50     and showAth == true ? label.new(time + desplazamiento, y50,    "-50%", xloc=xloc.bar_time, style=label.style_label_lower_left ,textcolor=C_line12, size=size.normal,color=color.new(color.red,100)):na

label.delete(N_tres[1])
label.delete(N_cinco[1])
label.delete(N_diez[1])
label.delete(N_trece[1])
label.delete(N_quince[1])
label.delete(N_veinte[1])
label.delete(N_25[1])
label.delete(N_30[1])
label.delete(N_35[1])
label.delete(N_40[1])
label.delete(N_45[1])
label.delete(N_50[1])

line.delete(L_tres[1])
line.delete(L_cinco[1])
line.delete(L_diez[1])
line.delete(L_trece[1])
line.delete(L_quince[1])
line.delete(L_veinte[1])
line.delete(L_25[1])
line.delete(L_30[1])
line.delete(L_35[1])
line.delete(L_40[1])
line.delete(L_45[1])
line.delete(L_50[1])

///////// LÍNEAS HORIZONTALES DE MEDIAS MÓVILES FIJAS  //////////
// Declaración de variables
var float valorMedia_A1 = na
var float valorMedia_B2 = na
var float valorMedia_C3 = na
var float valorMedia_D4 = na
var float valorMedia_E5 = na
var float valorMedia_F6 = na
var float valorMedia_G7 = na

//Declaración de Input
marcoTiempo1 = '1D'
inf1 = 'Temporalidad permanente de 1 día'
M_avg1D = input(true, 'Mostrar medias móviles fijas', group='Medias Móviles Temporalidad 1D', inline='e')

M_Avg11 = input.bool(defval=true, title='', group='Medias Móviles Temporalidad 1D', inline='1', tooltip=inf1)
P_Avg11 = input.int(defval=8, minval=1, title='Periodo', group='Medias Móviles Temporalidad 1D', inline='1')
C_Avg11 = input.color(defval=color.blue, title='Color', group='Medias Móviles Temporalidad 1D', inline='1')
T_Avg11 = input.string(title='Media A', defval='EMA', options=['EMA', 'SMA'], group='Medias Móviles Temporalidad 1D', inline='1')

M_Avg22 = input.bool(title='', defval=true, group='Medias Móviles Temporalidad 1D', inline='2', tooltip=inf1)
P_Avg22 = input.int(defval=21, minval=1, title='Periodo', group='Medias Móviles Temporalidad 1D', inline='2')
C_Avg22 = input.color(title='Color', defval=color.red, group='Medias Móviles Temporalidad 1D', inline='2')
T_Avg22 = input.string(title='Media B', defval='EMA', options=['EMA', 'SMA'], group='Medias Móviles Temporalidad 1D', inline='2')

M_Avg33 = input.bool(title='', defval=true, group='Medias Móviles Temporalidad 1D', inline='3', tooltip=inf1)
P_Avg33 = input.int(defval=50, minval=1, title='Periodo', group='Medias Móviles Temporalidad 1D', inline='3')
C_Avg33 = input.color(title='Color', defval=color.green, group='Medias Móviles Temporalidad 1D', inline='3')
T_Avg33 = input.string(title='Media C', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles Temporalidad 1D', inline='3')

M_Avg44 = input.bool(title='', defval=false, group='Medias Móviles Temporalidad 1D', inline='4', tooltip=inf1)
P_Avg44 = input.int(defval=75, minval=1, title='Periodo', group='Medias Móviles Temporalidad 1D', inline='4')
C_Avg44 = input.color(title='Color', defval=color.aqua, group='Medias Móviles Temporalidad 1D', inline='4')
T_Avg44 = input.string(title='Media D', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles Temporalidad 1D', inline='4')

M_Avg55 = input.bool(title='', defval=false, group='Medias Móviles Temporalidad 1D', inline='5', tooltip=inf1)
P_Avg55 = input.int(defval=100, minval=1, title='Periodo', group='Medias Móviles Temporalidad 1D', inline='5')
C_Avg55 = input.color(title='Color', defval=color.purple, group='Medias Móviles Temporalidad 1D', inline='5')
T_Avg55 = input.string(title='Media E', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles Temporalidad 1D', inline='5')

M_Avg66 = input.bool(title='', defval=false, group='Medias Móviles Temporalidad 1D', inline='6', tooltip=inf1)
P_Avg66 = input.int(defval=150, minval=1, title='Periodo', group='Medias Móviles Temporalidad 1D', inline='6')
C_Avg66 = input.color(title='Color', defval=color.orange, group='Medias Móviles Temporalidad 1D', inline='6')
T_Avg66 = input.string(title='Media F', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles Temporalidad 1D', inline='6')

M_Avg77 = input.bool(title='', defval=false, group='Medias Móviles Temporalidad 1D', inline='7', tooltip=inf1)
P_Avg77 = input.int(defval=200, minval=1, title='Periodo', group='Medias Móviles Temporalidad 1D', inline='7')
C_Avg77 = input.color(title='Color', defval=color.maroon, group='Medias Móviles Temporalidad 1D', inline='7')
T_Avg77 = input.string(title='Media G', defval='SMA', options=['EMA', 'SMA'], group='Medias Móviles Temporalidad 1D', inline='7')

// Cálculo de medias
valorMedia_A1 := T_Avg11 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo1, ta.ema(close, P_Avg11)) : request.security(syminfo.tickerid, marcoTiempo1, ta.sma(close, P_Avg11))
valorMedia_B2 := T_Avg22 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo1, ta.ema(close, P_Avg22)) : request.security(syminfo.tickerid, marcoTiempo1, ta.sma(close, P_Avg22))
valorMedia_C3 := T_Avg33 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo1, ta.ema(close, P_Avg33)) : request.security(syminfo.tickerid, marcoTiempo1, ta.sma(close, P_Avg33))
valorMedia_D4 := T_Avg44 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo1, ta.ema(close, P_Avg44)) : request.security(syminfo.tickerid, marcoTiempo1, ta.sma(close, P_Avg44))
valorMedia_E5 := T_Avg55 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo1, ta.ema(close, P_Avg55)) : request.security(syminfo.tickerid, marcoTiempo1, ta.sma(close, P_Avg55))
valorMedia_F6 := T_Avg66 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo1, ta.ema(close, P_Avg66)) : request.security(syminfo.tickerid, marcoTiempo1, ta.sma(close, P_Avg66))
valorMedia_G7 := T_Avg77 == 'EMA' ? request.security(syminfo.tickerid, marcoTiempo1, ta.ema(close, P_Avg77)) : request.security(syminfo.tickerid, marcoTiempo1, ta.sma(close, P_Avg77))

// Visualización de resultados
etiquetaMarcoTiempo = marcoTiempo1
desplazamiento00    = 2 * (time - time[1])
desplazamiento1     = time + 60 + 60 * 24

if M_avg1D and M_Avg11
    linea_A1 = line.new(x1=desplazamiento1, y1=valorMedia_A1, x2=time, xloc=xloc.bar_time, y2=valorMedia_A1, color=C_Avg11, extend=extend.left, width=1)
    Label_A1 = label.new(time + desplazamiento00, valorMedia_A1, xloc=xloc.bar_time, text=T_Avg11 + ' ' + str.tostring(P_Avg11), color=color.new(color.red, 100), style=label.style_label_lower_left, size=size.normal, textcolor=C_Avg11, tooltip=T_Avg11 + ' ' + str.tostring(P_Avg11) + ' ' + marcoTiempo1)
    line.delete(linea_A1[1])
    label.delete(Label_A1[1])

if M_avg1D and M_Avg22
    linea_B2 = line.new(x1=desplazamiento1, y1=valorMedia_B2, x2=time, xloc=xloc.bar_time, y2=valorMedia_B2, color=C_Avg22, extend=extend.left, width=1)
    Label_B2 = label.new(time + desplazamiento00, valorMedia_B2, xloc=xloc.bar_time, text=T_Avg22 + ' ' + str.tostring(P_Avg22), color=color.new(color.red, 100), style=label.style_label_lower_left, size=size.normal, textcolor=C_Avg22, tooltip=T_Avg22 + ' ' + str.tostring(P_Avg22) + ' ' + marcoTiempo1)
    line.delete(linea_B2[1])
    label.delete(Label_B2[1])

if M_avg1D and M_Avg33
    linea_C3 = line.new(x1=desplazamiento1, y1=valorMedia_C3, x2=time, xloc=xloc.bar_time, y2=valorMedia_C3, color=C_Avg33, extend=extend.left, width=1)
    Label_C3 = label.new(time + desplazamiento00, valorMedia_C3, xloc=xloc.bar_time, text=T_Avg33 + ' ' + str.tostring(P_Avg33), color=color.new(color.red, 100), style=label.style_label_lower_left, size=size.normal, textcolor=C_Avg33, tooltip=T_Avg33 + ' ' + str.tostring(P_Avg33) + ' ' + marcoTiempo1)
    line.delete(linea_C3[1])
    label.delete(Label_C3[1])

if M_avg1D and M_Avg44
    linea_D4 = line.new(x1=desplazamiento1, y1=valorMedia_D4, x2=time, xloc=xloc.bar_time, y2=valorMedia_D4, color=C_Avg44, extend=extend.left, width=1)
    Label_D4 = label.new(time + desplazamiento00, valorMedia_D4, xloc=xloc.bar_time, text=T_Avg44 + ' ' + str.tostring(P_Avg44), color=color.new(color.red, 100), style=label.style_label_lower_left, size=size.normal, textcolor=C_Avg44, tooltip=T_Avg44 + ' ' + str.tostring(P_Avg44) + ' ' + marcoTiempo1)
    line.delete(linea_D4[1])
    label.delete(Label_D4[1])

if M_avg1D and M_Avg55
    linea_E5 = line.new(x1=desplazamiento1, y1=valorMedia_E5, x2=time, xloc=xloc.bar_time, y2=valorMedia_E5, color=C_Avg55, extend=extend.left, width=1)
    Label_E5 = label.new(time + desplazamiento00, valorMedia_E5, xloc=xloc.bar_time, text=T_Avg55 + ' ' + str.tostring(P_Avg55), color=color.new(color.red, 100), style=label.style_label_lower_left, size=size.normal, textcolor=C_Avg55, tooltip=T_Avg55 + ' ' + str.tostring(P_Avg55) + ' ' + marcoTiempo1)
    line.delete(linea_E5[1])
    label.delete(Label_E5[1])

if M_avg1D and M_Avg66
    linea_F6 = line.new(x1=desplazamiento1, y1=valorMedia_F6, x2=time, xloc=xloc.bar_time, y2=valorMedia_F6, color=C_Avg66, extend=extend.left, width=1)
    Label_F6 = label.new(time + desplazamiento00, valorMedia_F6, xloc=xloc.bar_time, text=T_Avg66 + ' ' + str.tostring(P_Avg66), color=color.new(color.red, 100), style=label.style_label_lower_left, size=size.normal, textcolor=C_Avg66, tooltip=T_Avg66 + ' ' + str.tostring(P_Avg66) + ' ' + marcoTiempo1)
    line.delete(linea_F6[1])
    label.delete(Label_F6[1])

if M_avg1D and M_Avg77
    linea_G7 = line.new(x1=desplazamiento1, y1=valorMedia_G7, x2=time, xloc=xloc.bar_time, y2=valorMedia_G7, color=C_Avg77, extend=extend.left, width=1)
    Label_G7 = label.new(time + desplazamiento00, valorMedia_G7, xloc=xloc.bar_time, text=T_Avg77 + ' ' + str.tostring(P_Avg77), color=color.new(color.red, 100), style=label.style_label_lower_left, size=size.normal, textcolor=C_Avg77, tooltip=T_Avg77 + ' ' + str.tostring(P_Avg77) + ' ' + marcoTiempo1)
    line.delete(linea_G7[1])
    label.delete(Label_G7[1])

///// Marca de agua /////// Agradecimientos a los programadores de Tradingview

string i_text1     = 'I 💖 the Stops'
string i_text2     = 'Cuido mi 💵 capital'
string i_tableYpos = 'bottom'
string i_tableXpos = 'right'
int    i_height    = 8
int    i_width     = 10
color  i_c_text    = color.new(color.white, 0)
string i_textSize  = 'auto'
color  i_c_bg      = color.new(color.blue, 10)

var table watermark = table.new(i_tableYpos + '_' + i_tableXpos, 1, 1)

if barstate.islast and mostrar_W_M
    varip bool _changeText = true
    _changeText := not _changeText
    string _txt = str.length(i_text2) != 0 and _changeText ? i_text2 : i_text1
    table.cell(watermark, 0, 0, _txt, i_width, i_height, i_c_text, text_size=i_textSize, bgcolor=i_c_bg)
````
