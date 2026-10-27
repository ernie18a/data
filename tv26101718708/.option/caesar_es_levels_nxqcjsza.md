# Caesar ES Levels

- url: https://www.tradingview.com/script/NxqcjSzA-Caesar-ES-Levels/
- type: indicator
- pine_id: PUB;ef8d718448c544ab844893f523e23f8b
- version: 2.0

## Description

Input ES levels in this format (number, number, number) and auto populates levels for ES, MES, SPX, SPY for you in your charts

## Source Code

````pine
//@version=6                                                                                                            
indicator("ES Levels", overlay=true, max_lines_count=500, max_labels_count=500)                                         
levels_input = input.string(defval="5500,5450,5400,5350,5300", title="ES Levels")                                       
col = color.new(color.black, 70)                                                                                        
es_price = request.security("CME_MINI:ES1!", timeframe.period, close)                                                   
spx_price = request.security("SP:SPX", timeframe.period, close)                                                         
spy_price = request.security("AMEX:SPY", timeframe.period, close)
factor = str.contains(syminfo.ticker, "SPY") ? spy_price / es_price : str.contains(syminfo.ticker, "SPX") ? spx_price / es_price : 1.0  
                                                                                                                          
var line[] drawnLines = array.new_line()                                                                                
var label[] drawnLabels = array.new_label()
                                                                                                                          
if barstate.islast
    for l in drawnLines
        line.delete(l)
    array.clear(drawnLines)
    for lb in drawnLabels
        label.delete(lb)                                                                                                
    array.clear(drawnLabels)
    levels = str.split(levels_input, ",")                                                                               
    for i = 0 to array.size(levels) - 1
        raw = str.trim(array.get(levels, i))
        if str.length(raw) > 0                                                                                          
            lvl = str.tonumber(raw) * factor
            if not na(lvl)                                                                                              
                array.push(drawnLines, line.new(bar_index, lvl, bar_index + 1, lvl, extend=extend.both, color=col, width=1))                                                                                                               
                array.push(drawnLabels, label.new(bar_index + 5, lvl, text=str.tostring(math.round(lvl, 2)), textcolor=color.black, style=label.style_none, size=size.small))
````
