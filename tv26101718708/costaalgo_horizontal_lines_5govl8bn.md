# CostaAlgo Horizontal Lines

- url: https://www.tradingview.com/script/5GOvl8bn-CostaAlgo-Horizontal-Lines/
- type: indicator
- pine_id: PUB;371de4e9493c4b6a899639e9bd58d114
- version: 1.0

## Description

CostaAlgo Horizontal Lines – The Only Level Tool You'll Ever Need.
Stop wasting time drawing lines manually. This tool snaps clean horizontal levels across your entire chart in seconds. Set your start price, set your step, done. Every level perfectly spaced. Every time.
What it does:
Price levels automatically placed from your chosen starting point, spaced exactly how you want. Trading Gold at 4500 with 25-point steps? Done. BTC at 65000 with 250-point steps? One click. NQ, Forex, Crypto, Futures — any market, any spacing, any timeframe.
What you can customize:

Start price — your anchor
Step size — your spacing
Number of lines — 1 to 100
Color — whatever you want
Thickness — thin to bold
Style — Solid, Dashed or Dotted
Labels on/off — clean or detailed, your choice

Why it's different:
No clutter. No complexity. Just pure, clean levels that actually mean something. Switch from Gold to BTC? Change two numbers and you're set. It adapts to YOU, not the other way around.
This is the tool professional traders wish they had years ago.
Simple enough for beginners. Powerful enough for pros. Free for everyone.
Add it once. Use it forever.
CostaAlgo Horizontal Lines. Built different.

## Source Code

````pine
//@version=6
indicator("CostaAlgo Horizontal Lines", overlay=true, max_lines_count=500)

var string GRP1 = "Lijn Instellingen"
startPrice  = input.float(65000, "Startprijs",          group=GRP1)
step        = input.float(250,   "Stap tussen lijnen",  group=GRP1)
numLines    = input.int(20,      "Aantal lijnen",        group=GRP1, minval=1, maxval=100)
lineColor   = input.color(color.new(color.blue, 0), "Kleur",   group=GRP1)
lineWidth   = input.int(1,       "Dikte (1-4)",          group=GRP1, minval=1, maxval=4)
lineStyle   = input.string("Solid", "Stijl",             group=GRP1, options=["Solid","Dashed","Dotted"])
showLabels  = input.bool(true,   "Labels tonen",         group=GRP1)

lstyle = lineStyle == "Dashed" ? line.style_dashed :
         lineStyle == "Dotted" ? line.style_dotted :
         line.style_solid

var line[] lines = array.new_line()
var label[] lbls = array.new_label()

if barstate.islast
    for l in lines
        line.delete(l)
    for lb in lbls
        label.delete(lb)
    array.clear(lines)
    array.clear(lbls)

    for i = 0 to numLines - 1
        lvl = startPrice + step * i
        ln = line.new(bar_index - 500, lvl, bar_index + 500, lvl,
             color=lineColor, width=lineWidth, style=lstyle, extend=extend.both)
        array.push(lines, ln)

        if showLabels
            lb = label.new(bar_index + 10, lvl, str.tostring(lvl, "#.##"),
                 color=color.new(lineColor, 80), textcolor=lineColor,
                 style=label.style_label_left, size=size.small)
            array.push(lbls, lb)
````
