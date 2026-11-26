# SMC PRO MTF FVG + OB

- url: https://www.tradingview.com/script/M185WA5o/
- type: indicator
- pine_id: PUB;db0bc3fdc4e443039a056f1cfb8fa3f3
- version: 1.0

## Description

marcações com alinhamento de fluxo fvg e obs nos times superiores para facilitar aonde o preço pode parar

## Source Code

````pine
//@version=6
indicator("SMC PRO MTF FVG + OB", overlay = true, max_lines_count = 500, max_labels_count = 500)

//====================================================
// TIMEFRAME SUPERIOR
//====================================================

string HTF = "240"

if timeframe.period == "1"
    HTF := "5"

if timeframe.period == "5"
    HTF := "15"

if timeframe.period == "15"
    HTF := "60"

if timeframe.period == "60"
    HTF := "240"

//====================================================
// CONFIGURAÇÕES
//====================================================

leftBars  = input.int(1, "Linha Esquerda", minval = 1, maxval = 10)
rightBars = input.int(12, "Linha Direita", minval = 2, maxval = 50)

txtSizeInput = input.string(
     "normal",
     "Texto",
     options = ["small", "normal", "large"]
)

txtSize =
     txtSizeInput == "small" ? size.small :
     txtSizeInput == "large" ? size.large :
     size.normal

//====================================================
// CORES
//====================================================

fvgColor = color.rgb(0, 150, 130)
obColor  = color.rgb(70, 100, 190)

//====================================================
// FVG HTF
//====================================================

bullFVG = request.security(
     syminfo.tickerid,
     HTF,
     low > high[2]
)

bullFVGPrice = request.security(
     syminfo.tickerid,
     HTF,
     low
)

//====================================================
// OB HTF
//====================================================

bullOB = request.security(
     syminfo.tickerid,
     HTF,
     close[1] < open[1] and close > high[1]
)

bullOBPrice = request.security(
     syminfo.tickerid,
     HTF,
     low[1]
)

//====================================================
// CONTROLE REPETIÇÃO
//====================================================

var float lastFVG = na
var float lastOB  = na

//====================================================
// FVG
//====================================================

if bullFVG and (na(lastFVG) or bullFVGPrice != lastFVG)

    // LINHA FIXA NO PREÇO
    line.new(
         x1 = bar_index - leftBars,
         y1 = bullFVGPrice,
         x2 = bar_index + rightBars,
         y2 = bullFVGPrice,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(fvgColor, 10),
         width = 2
    )

    // TEXTO FIXO NO PREÇO
    label.new(
         x = bar_index + rightBars + 1,
         y = bullFVGPrice,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         text = "FVG " + HTF,
         style = label.style_none,
         textcolor = color.black,
         size = txtSize
    )

    lastFVG := bullFVGPrice

//====================================================
// OB
//====================================================

if bullOB and (na(lastOB) or bullOBPrice != lastOB)

    // LINHA FIXA NO PREÇO
    line.new(
         x1 = bar_index - leftBars,
         y1 = bullOBPrice,
         x2 = bar_index + rightBars,
         y2 = bullOBPrice,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(obColor, 10),
         width = 2,
         style = line.style_dashed
    )

    // TEXTO FIXO NO PREÇO
    label.new(
         x = bar_index + rightBars + 1,
         y = bullOBPrice,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         text = "OB " + HTF,
         style = label.style_none,
         textcolor = color.black,
         size = txtSize
    )

    lastOB := bullOBPrice

//====================================================
// PAINEL FIXO
//====================================================

var table painel = table.new(position.top_right, 1, 1)

if barstate.islast

    table.cell(
         painel,
         0,
         0,
         "Fluxo HTF: " + HTF,
         text_color = color.black,
         bgcolor = color.new(color.white, 0)
    )
````
