# RCI Strategy [PineIndicators]

- url: https://www.tradingview.com/script/BsqKKqyq-RCI-Strategy-PineIndicators/
- type: strategy
- pine_id: PUB;9c6e4ca8f74d407c8cfae57b37c60f08
- version: 1.0

## Description

[b]RCI Strategy [PineIndicators][/b]
This strategy leverages the Rank Correlation Index (RCI) — a statistical oscillator that measures the relationship between time and price rank — combined with a configurable moving average filter. It offers clean, rule-based entries and exits, and visually enhanced trade tracking via labeled markers and boxes on the chart.

The RCI Strategy is well-suited for momentum traders looking to capture directional shifts with confirmation through RCI smoothing.

[b]Core Logic[/b]
[b]1. Rank Correlation Index (RCI)[/b]
[list]
[*] Measures how closely price changes correlate with time rankings.
[*] Values range between -100 and +100.
[*] Thresholds at ±80 help identify potential reversals or extremes.
[/list]

[b]2. RCI Smoothing via Moving Average[/b]
[list]
[*] A moving average (MA) is applied to the RCI to smooth out fluctuations.
[*] Supported MA types:
[list]
[*] SMA
[*] EMA
[*] SMMA (RMA)
[*] WMA
[*] VWMA
[/list]
[*] Users can disable the smoothing by selecting "None".
[/list]

[b]Trade Entry Logic[/b]
[list]
[*] [b]Long Entry:[/b] RCI crosses above the selected moving average.
[*] [b]Short Entry:[/b] RCI crosses below the moving average.
[*] Entries are restricted by trade direction settings:
[list]
[*] Long Only
[*] Short Only
[*] Long & Short
[/list]
[/list]

[b]Visual Features[/b]
[b]RCI Panel Display[/b]
[list]
[*] Plots RCI line and its moving average in a separate pane.
[*] Horizontal guide lines at 0, +80, and -80 help visualize signal zones.
[/list]

[b]Trade Labels on Chart[/b]
[list]
[*] [b]Buy Label:[/b] Plotted when a long entry is executed.
[*] [b]Close Label:[/b] Plotted when any position is closed.
[*] Triangle markers for visual emphasis on direction change.
[/list]

[b]Trade Visualization Boxes[/b]
[list]
[*] A colored box is drawn between entry and exit prices.
[*] Green = profitable trade; Red = losing trade.
[*] Two horizontal lines connect entry and exit prices for reference.
[/list]

[b]Customization Parameters[/b]
[list]
[*] [b]RCI Source:[/b] Select input price for the RCI (default: close).
[*] [b]RCI Length:[/b] Set sensitivity of the oscillator.
[*] [b]MA Type and Length:[/b] Choose and configure the smoothing filter.
[*] [b]Trade Direction Mode:[/b] Define whether to allow Long, Short, or both.
[/list]

[b]Use Cases[/b]
[list]
[*] Swing traders who want to trade directional reversals with statistical backing.
[*] Traders seeking a clean and visual strategy based on rank momentum.
[*] Environments where both trend and range dynamics occur.
[/list]

[b]Conclusion[/b]
The RCI Strategy [PineIndicators] is a [b]non-repainting, rule-based trading model[/b] that combines rank correlation momentum with smoothed trend logic. Its clean visual markers, labeled trades, and flexible MA filters make it a valuable tool for discretionary and systematic traders alike.

## Source Code

````pine
//@version=6
// © PineIndicators

strategy("RCI Strategy [PineIndicators]",
     overlay = false,
     commission_value = 0.01,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 100,
     slippage = 2,
     max_labels_count = 500,
     max_lines_count  = 500,
     max_boxes_count  = 500)

// ───── Inputs ────────────────────────────────────
src     = input.source(close, "RCI Source")
rciLen  = input.int(10, "RCI Length")
maType  = input.string("SMA", "MA Type",
           options = ["None","SMA","EMA","SMMA (RMA)","WMA","VWMA"])
maLen   = input.int(14, "MA Length")
dirOpt  = input.string("Long & Short","Trade Direction",
           options = ["Long & Short","Long Only","Short Only"])

// ───── RCI + MA (Pane) ─────────────────────────────
rci = ta.rci(src, rciLen)

ma(series,l,t)=>
    switch t
        "SMA"=>ta.sma(series,l)
        "EMA"=>ta.ema(series,l)
        "SMMA (RMA)"=>ta.rma(series,l)
        "WMA"=>ta.wma(series,l)
        "VWMA"=>ta.vwma(series,l)

rciMA = maType!="None" ? ma(rci,maLen,maType):na

plot(rci,"RCI",color.blue,display=display.pane)
plot(rciMA,"RCI-MA",color.yellow,display=display.pane)
plot(0,"Zero",color.gray,display=display.pane)
plot(80,"+80",color.green,display=display.pane)
plot(-80,"-80",color.red,display=display.pane)

// ───── Logic ────────────────────────────────
longCond  = ta.crossover(rci,rciMA)
shortCond = ta.crossunder(rci,rciMA)
canLong   = dirOpt!="Short Only"
canShort  = dirOpt!="Long Only"

if longCond
    if canLong
        strategy.entry("L",strategy.long)
    strategy.close("S")

if shortCond
    if canShort
        strategy.entry("S",strategy.short)
    strategy.close("L")

// ───── Colors ───────────────────────
green   = color.new(#0097a7,  0)
green90 = color.new(#0097a7, 90)
red     = color.new(#ff195f,  0)
red90   = color.new(#ff195f, 90)

// Labels
if strategy.position_size>strategy.position_size[1]     
    label.new(bar_index,low*0.99,"▲",
              xloc=xloc.bar_index,yloc=yloc.price,
              textcolor=green,color=green90,
              style=label.style_text_outline,size=size.normal,
              force_overlay=true)
    label.new(bar_index,low*0.99,"Buy",
              xloc=xloc.bar_index,yloc=yloc.price,
              textcolor=green,color=green90,
              style=label.style_label_up,size=size.tiny,
              force_overlay=true)

if strategy.position_size<strategy.position_size[1]      
    label.new(bar_index,high*1.01,"▼",
              xloc=xloc.bar_index,yloc=yloc.price,
              textcolor=red,color=red90,
              style=label.style_text_outline,size=size.normal,
              force_overlay=true)
    label.new(bar_index,high*1.01,"Close",
              xloc=xloc.bar_index,yloc=yloc.price,
              textcolor=red,color=red90,
              style=label.style_label_down,size=size.tiny,
              force_overlay=true)

// ───── Trade-Boxes ─────────────────────────────────
var float entryPrice = na
var int   entryBar   = na
var bool  entryLong  = false

// Entries
if strategy.position_size!=0 and strategy.position_size[1]==0
    entryPrice := strategy.position_avg_price
    entryBar   := bar_index
    entryLong  := strategy.position_size>0

// Exits
if strategy.position_size==0 and strategy.position_size[1]!=0
    exitBar   = bar_index
    rightIdx  = exitBar-1                       // Balken davor
    exitClose = close[1]                        // Close der Vor-Bar

    // Fallback
    if rightIdx < entryBar
        rightIdx  := exitBar
        exitClose := close

    bool win = entryLong ? exitClose>entryPrice
                         : exitClose<entryPrice
    col  = win ? green : red

    top    = math.max(entryPrice,exitClose)
    bottom = math.min(entryPrice,exitClose)

    pTL = chart.point.from_index(entryBar ,top)
    pBR = chart.point.from_index(rightIdx,bottom)

    box.new(pTL,pBR,border_color=color.new(color.black,100), border_width=1,bgcolor=color.new(col,80),force_overlay=true)

    line.new(entryBar,top,   rightIdx,top,xloc=xloc.bar_index,color=col,width=1,extend=extend.none,force_overlay=true)
    line.new(entryBar,bottom,rightIdx,bottom,xloc=xloc.bar_index,color=col,width=1,extend=extend.none,force_overlay=true)
````
