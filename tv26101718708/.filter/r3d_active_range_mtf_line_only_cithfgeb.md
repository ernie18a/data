# R3D Active Range MTF LINE ONLY

- url: https://www.tradingview.com/script/cITHFgeb/
- type: indicator
- pine_id: PUB;b76b536e922143a48461b7b5ccd0b8e1
- version: 2.0

## Description

marca rangos en muchas temporalidades, ideal para tener una vision mas clara de para donde podria ir el precio.

## Source Code

````pine
//@version=6
indicator("R3D Active Range MTF LINE ONLY", overlay=true, max_lines_count=300, max_labels_count=300)

// ARRAYS

var line[] lines = array.new_line()
var label[] labels = array.new_label()

var float[] levels = array.new_float()
var float[] invalids = array.new_float()

var int[] dirs = array.new_int()


// FUNCION

f_range(tf, name)=>

    [ph,pl,ch,cl,cc] = request.security(
     syminfo.tickerid,
     tf,
     [
      high[1],
      low[1],
      high,
      low,
      close
     ],
     lookahead=barmerge.lookahead_off)


    // toma LOW
    // marca HIGH de vela tomada

    if cl < pl and cc > pl

        lvl = ph
        inv = pl

        if ch < lvl

            ln = line.new(
             bar_index,
             lvl,
             bar_index+50,
             lvl,
             color=color.green,
             width=2)

            lb = label.new(
             bar_index+50,
             lvl,
             name,
             style=label.style_none,
             textcolor=color.green,
             size=size.small)

            array.push(lines,ln)
            array.push(labels,lb)
            array.push(levels,lvl)
            array.push(invalids,inv)
            array.push(dirs,1)


    // toma HIGH
    // marca LOW de vela tomada

    if ch > ph and cc < ph

        lvl = pl
        inv = ph

        if cl > lvl

            ln = line.new(
             bar_index,
             lvl,
             bar_index+50,
             lvl,
             color=color.red,
             width=2)

            lb = label.new(
             bar_index+50,
             lvl,
             name,
             style=label.style_none,
             textcolor=color.red,
             size=size.small)

            array.push(lines,ln)
            array.push(labels,lb)
            array.push(levels,lvl)
            array.push(invalids,inv)
            array.push(dirs,-1)


//=====================
// MINUTOS
//=====================

f_range("5","5m")
f_range("10","10m")
f_range("15","15m")
f_range("30","30m")

//=====================
// HORAS
//=====================

f_range("60","1H")
f_range("120","2H")
f_range("180","3H")
f_range("240","4H")
f_range("300","5H")
f_range("360","6H")
f_range("480","8H")
f_range("720","12H")

//=====================
// DIAS
//=====================

f_range("1D","1D")
f_range("2D","2D")
f_range("3D","3D")
f_range("4D","4D")
f_range("5D","5D")
f_range("6D","6D")
f_range("7D","7D")

//=====================
// SEMANAL
//=====================

f_range("1W","1S")


// BORRAR RANGOS MUERTOS

if array.size(levels)>0

    for i=array.size(levels)-1 to 0

        lvl=array.get(levels,i)
        inv=array.get(invalids,i)
        dir=array.get(dirs,i)

        remove=false

        if dir==1

            if high>=lvl or close<inv
                remove:=true

        if dir==-1

            if low<=lvl or close>inv
                remove:=true

        if remove

            line.delete(array.get(lines,i))
            label.delete(array.get(labels,i))

            array.remove(lines,i)
            array.remove(labels,i)
            array.remove(levels,i)
            array.remove(invalids,i)
            array.remove(dirs,i)
````
