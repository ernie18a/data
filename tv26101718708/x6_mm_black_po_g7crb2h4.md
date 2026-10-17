# x6 mm black po

- url: https://www.tradingview.com/script/G7cRb2h4/
- type: indicator
- pine_id: PUB;2c9fc01fd45540c6aa02e27ac8d28955
- version: 1.0

## Description

x6 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// FXM Currency Symbol - TradingView port
// Original: "!FXM_Currency_Symbol.ex4"
// Mostra il simbolo dello strumento corrente come label grande sul grafico.
// Parametri originali estratti dal binario: Corner, Vertical_offset,
// Horizontal_offset, FontSize_symbol, Color_symbol.
// =============================================================================
indicator("x6 mm black po", overlay=true, max_labels_count=1)

cornerIn  = input.string("top_right", "Corner",
              options=["top_left","top_right","bottom_left","bottom_right","center"])
fontSize  = input.string("huge", "Font size",
              options=["tiny","small","normal","large","huge"])
txtColor  = input.color(color.new(color.gray, 50), "Color")
customTxt = input.string("", "Custom text (vuoto = ticker)")

// Pine non supporta offset in pixel — usiamo posizionamento via table per simulare il "corner"
sizeMap = fontSize == "tiny" ? size.tiny :
          fontSize == "small" ? size.small :
          fontSize == "normal" ? size.normal :
          fontSize == "large" ? size.large : size.huge

pos = cornerIn == "top_left" ? position.top_left :
      cornerIn == "top_right" ? position.top_right :
      cornerIn == "bottom_left" ? position.bottom_left :
      cornerIn == "bottom_right" ? position.bottom_right : position.middle_center

// Ricrea la table su barstate.islast cancellando la precedente (no memory leak).
// Necessario perché Pine non permette di cambiare 'position' di una table esistente.
var table t = na
if barstate.islast
    if not na(t)
        table.delete(t)
    t := table.new(position=pos, columns=1, rows=1)
    txt = customTxt == "" ? syminfo.ticker : customTxt
    table.cell(t, 0, 0, txt, text_color=txtColor, text_size=sizeMap, bgcolor=color.new(color.black, 100))
````
