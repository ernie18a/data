# 5 sma Configurables

- url: https://www.tradingview.com/script/61WbhVtc-5-sma-Configurables/
- type: indicator
- pine_id: PUB;fd62b00a758c4cb2964429cd3246e8b4
- version: 1.0

## Description

este tiene 5 indicadores sma 9 20 40 100 200 muy bueno compatible con tc 2000

## Source Code

````pine
//@version=6
indicator("TC2000 Style - 5 MAs Configurables", overlay=true)

// =====================
// FUNCIÓN DE MEDIA MÓVIL
// =====================
f_ma(src, length, type) =>
    switch type
        "SMA" => ta.sma(src, length)
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        "RMA" => ta.rma(src, length)
        "VWMA" => ta.vwma(src, length)

// =====================
// INPUTS GENERALES
// =====================

// ---- MA1
show1   = input.bool(true, "Mostrar MA 1")
len1    = input.int(9, "MA 1 Periodo")
type1   = input.string("SMA", "MA 1 Tipo", options=["SMA","EMA","WMA","RMA","VWMA"])
src1    = input.source(close, "MA 1 Fuente")
off1    = input.int(0, "MA 1 Offset")
col1    = input.color(color.black, "MA 1 Color")
wid1    = input.int(2, "MA 1 Grosor")

// ---- MA2
show2   = input.bool(true, "Mostrar MA 2")
len2    = input.int(20, "MA 2 Periodo")
type2   = input.string("SMA", "MA 2 Tipo", options=["SMA","EMA","WMA","RMA","VWMA"])
src2    = input.source(close, "MA 2 Fuente")
off2    = input.int(0, "MA 2 Offset")
col2    = input.color(color.yellow, "MA 2 Color")
wid2    = input.int(2, "MA 2 Grosor")

// ---- MA3
show3   = input.bool(true, "Mostrar MA 3")
len3    = input.int(40, "MA 3 Periodo")
type3   = input.string("SMA", "MA 3 Tipo", options=["SMA","EMA","WMA","RMA","VWMA"])
src3    = input.source(close, "MA 3 Fuente")
off3    = input.int(0, "MA 3 Offset")
col3    = input.color(color.red, "MA 3 Color")
wid3    = input.int(2, "MA 3 Grosor")

// ---- MA4
show4   = input.bool(true, "Mostrar MA 4")
len4    = input.int(100, "MA 4 Periodo")
type4   = input.string("SMA", "MA 4 Tipo", options=["SMA","EMA","WMA","RMA","VWMA"])
src4    = input.source(close, "MA 4 Fuente")
off4    = input.int(0, "MA 4 Offset")
col4    = input.color(color.green, "MA 4 Color")
wid4    = input.int(2, "MA 4 Grosor")

// ---- MA5
show5   = input.bool(true, "Mostrar MA 5")
len5    = input.int(200, "MA 5 Periodo")
type5   = input.string("SMA", "MA 5 Tipo", options=["SMA","EMA","WMA","RMA","VWMA"])
src5    = input.source(close, "MA 5 Fuente")
off5    = input.int(0, "MA 5 Offset")
col5    = input.color(color.purple, "MA 5 Color")
wid5    = input.int(2, "MA 5 Grosor")

// =====================
// CÁLCULO DE MEDIAS
// =====================
ma1 = f_ma(src1, len1, type1)
ma2 = f_ma(src2, len2, type2)
ma3 = f_ma(src3, len3, type3)
ma4 = f_ma(src4, len4, type4)
ma5 = f_ma(src5, len5, type5)

// =====================
// PLOTS
// =====================
plot(show1 ? ma1 : na, title="MA 1", color=col1, linewidth=wid1, offset=off1)
plot(show2 ? ma2 : na, title="MA 2", color=col2, linewidth=wid2, offset=off2)
plot(show3 ? ma3 : na, title="MA 3", color=col3, linewidth=wid3, offset=off3)
plot(show4 ? ma4 : na, title="MA 4", color=col4, linewidth=wid4, offset=off4)
plot(show5 ? ma5 : na, title="MA 5", color=col5, linewidth=wid5, offset=off5)
````
