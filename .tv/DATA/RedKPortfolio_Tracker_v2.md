<!-- tradingview-pine-id: PUB;SQI62bQhFI1j7VAnwQ5xjUkkE52WQ9xC -->
<!-- tradingviewscripts-format: 1 -->
# RedK_Portfolio Tracker v2

Source: https://www.tradingview.com/script/U8imfw8n-RedK-Portfolio-Tracker-v2-few-enhancements-and-display-options/

## Description

This is an update for the PTracker v1 that I published couple of days ago. wanted to publish this as a separate script to get a chance to show how the new Portfolio Summary Infobox can be displayed on the price chart as an option. In my opinion, that info box is the most important element in this tool and that's the piece i was most looking for.

quick note here:  you can track your portfolio (if not so many positions) by entering something like  [MSFT * 1000 + AAPL * 1000 + INTC * 2000 ]  (without the brackets) in TradingView's chart symbol area - TradingView will resolve these symbols and chart the total -- there's a nice post by our friend @boji1 about this in a lot more details - however, that wouldn't show the stats that i need to look at to track my portfolio on daily basis.

i also made couple of other enhancements, like adding the ability to include "free cash" in the portfolio - While this free cash value will impact the Total P/L and P/L %, as part of the overall portfolio (and the denominator), it will not impact the "cost of positions" or the (current) "value of positions" -- also "Cash" will not count towards the total 10 positions that we can track with this tool.

Using Portfolio Tracker as a floating panel on the price chart
====================================================

[*]By default, when the Portfolio Tracker is added to the chart, it will occupy its own lower panel like the picture above. 
[*]if your charts are already busy (like mine :)) - you most probably already have a couple of lower studies and it's crowded there. 
[*]in this case, you can use the Object Tree tool after adding the PTracker, to drag it onto the price panel, or you can also do that by right-clicking on the infobox and choose to move up to the price panel. 
[*]when you do that, remember to also use the Style settings of PTracker to hide both Portfolio and PnL plots, and choose Scale = no scale - this way you get the infobox to work like a floating panel on the price chart

here's a screenshot that shows this scenario - also shows how the infobox color can be easily changed from the PTracker settings to suit your chart background and for best visibility
https://www.tradingview.com/x/vBAKNVyS/

i hope this is useful in  your trading - i look forward to @TradingView team surprising us with a real portfolio tracking capability soon :)

good luck.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader

//@version=4
study(title="RedK_Portfolio Tracker v2", shorttitle="Redk_PTracker_v2", overlay=false, format=format.volume)

cbox     = input(title = "InfoBox Color",  type = input.color,   defval = #1111ff)

p_1      = input(title = "Pos #1",  type = input.bool,   defval = true,   inline = "#1")
sym_1    = input(title = "",        type = input.symbol, defval = "MSFT", inline = "#1")
qty_1    = input(title = "Qty",     type = input.float,  defval = 1000,   inline = "#1")
cost_1   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#1")

val_1    = p_1 ? security(sym_1, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_1 = p_1 ? val_1 * qty_1 : 0
tcost_1  = p_1 ? cost_1 * qty_1 : 0
PnL_1    = p_1 ? tvalue_1 - tcost_1 : 0
//=======================================================================================

p_2      = input(title = "Pos #2",  type = input.bool,   defval = true,   inline = "#2")
sym_2    = input(title = "",        type = input.symbol, defval = "AAPL", inline = "#2")
qty_2    = input(title = "Qty",     type = input.float,  defval = 1000,   inline = "#2")
cost_2   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#2")

val_2    = p_2 ? security(sym_2, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_2 = p_2 ? val_2 * qty_2 : 0
tcost_2  = p_2 ? cost_2 * qty_2 : 0
PnL_2    = p_2 ? tvalue_2 - tcost_2 : 0
//=======================================================================================

p_3      = input(title = "Pos #3",  type = input.bool,   defval = true,   inline = "#3")
sym_3    = input(title = "",        type = input.symbol, defval = "INTC", inline = "#3")
qty_3    = input(title = "Qty",     type = input.float,  defval = 1000,   inline = "#3")
cost_3   = input(title = "Cost",    type = input.float,  defval = 40,     inline = "#3")

val_3    = p_3 ? security(sym_3, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_3 = p_3 ? val_3 * qty_3 : 0
tcost_3  = p_3 ? cost_3 * qty_3 : 0
PnL_3    = p_3 ? tvalue_3 - tcost_3 : 0
//=======================================================================================

p_4      = input(title = "Pos #4",  type = input.bool,   defval = false,  inline = "#4")
sym_4    = input(title = "",        type = input.symbol, defval = "TWTR", inline = "#4")
qty_4    = input(title = "Qty",     type = input.float,  defval = 100,    inline = "#4")
cost_4   = input(title = "Cost",    type = input.float,  defval = 50,     inline = "#4")

val_4    = p_4 ? security(sym_4, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_4 = p_4 ? val_4 * qty_4 : 0
tcost_4  = p_4 ? cost_4 * qty_4 : 0
PnL_4    = p_4 ? tvalue_4 - tcost_4 : 0
//=======================================================================================

p_5      = input(title = "Pos #5",  type = input.bool,   defval = false,  inline = "#5")
sym_5    = input(title = "",        type = input.symbol, defval = "FB",   inline = "#5")
qty_5    = input(title = "Qty",     type = input.float,  defval = 100,    inline = "#5")
cost_5   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#5")

val_5    = p_5 ? security(sym_5, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_5 = p_5 ? val_5 * qty_5 : 0
tcost_5  = p_5 ? cost_5 * qty_5 : 0
PnL_5    = p_5 ? tvalue_5 - tcost_5 : 0
//=======================================================================================
p_6      = input(title = "Pos #6",  type = input.bool,   defval = false,  inline = "#6")
sym_6    = input(title = "",        type = input.symbol, defval = "MSFT", inline = "#6")
qty_6    = input(title = "Qty",     type = input.float,  defval = 100,    inline = "#6")
cost_6   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#6")

val_6    = p_6 ? security(sym_6, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_6 = p_6 ? val_6 * qty_6 : 0
tcost_6  = p_6 ? cost_6 * qty_6 : 0
PnL_6    = p_6 ? tvalue_6 - tcost_6 : 0
//=======================================================================================
p_7      = input(title = "Pos #7",  type = input.bool,   defval = false,  inline = "#7")
sym_7    = input(title = "",        type = input.symbol, defval = "MSFT", inline = "#7")
qty_7    = input(title = "Qty",     type = input.float,  defval = 100,    inline = "#7")
cost_7   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#7")

val_7    = p_7 ? security(sym_7, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_7 = p_7 ? val_7 * qty_7 : 0
tcost_7  = p_7 ? cost_7 * qty_7 : 0
PnL_7    = p_7 ? tvalue_7 - tcost_7 : 0
//=======================================================================================
p_8      = input(title = "Pos #8",  type = input.bool,   defval = false,  inline = "#8")
sym_8    = input(title = "",        type = input.symbol, defval = "MSFT", inline = "#8")
qty_8    = input(title = "Qty",     type = input.float,  defval = 100,    inline = "#8")
cost_8   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#8")

val_8    = p_8 ? security(sym_8, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_8 = p_8 ? val_8 * qty_8 : 0
tcost_8  = p_8 ? cost_8 * qty_8 : 0
PnL_8    = p_8 ? tvalue_8 - tcost_8 : 0
//=======================================================================================
p_9      = input(title = "Pos #9",  type = input.bool,   defval = false,  inline = "#9")
sym_9    = input(title = "",        type = input.symbol, defval = "MSFT", inline = "#9")
qty_9    = input(title = "Qty",     type = input.float,  defval = 100,    inline = "#9")
cost_9   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#9")

val_9    = p_9 ? security(sym_9, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_9 = p_9 ? val_9 * qty_9 : 0
tcost_9  = p_9 ? cost_9 * qty_9 : 0
PnL_9    = p_9 ? tvalue_9 - tcost_9 : 0
//=======================================================================================
p_10      = input(title = "Pos #10", type = input.bool,   defval = false,  inline = "#10")
sym_10    = input(title = "",        type = input.symbol, defval = "MSFT", inline = "#10")
qty_10    = input(title = "Qty",     type = input.float,  defval = 100,    inline = "#10")
cost_10   = input(title = "Cost",    type = input.float,  defval = 100,    inline = "#10")

val_10    = p_10 ? security(sym_10, timeframe.period, close, barmerge.gaps_off) : 0
tvalue_10 = p_10 ? val_10 * qty_10 : 0
tcost_10  = p_10 ? cost_10 * qty_10 : 0
PnL_10    = p_10 ? tvalue_10 - tcost_10 : 0
//=======================================================================================

c_0       = input(title = "Cash",   type = input.bool,    defval = true,    inline = "Cash")
cash_0    = input(title = "",       type = input.float,   defval = 10000,   inline = "Cash")

Cash      = c_0 ? cash_0 : 0
//========================================================================================

TotalValue      = tvalue_1 + tvalue_2 + tvalue_3 + tvalue_4 + tvalue_5 + tvalue_6 + tvalue_7 + tvalue_8 + tvalue_9 + tvalue_10
TotalPortfolio  = TotalValue + Cash
TotalCost       = tcost_1 + tcost_2 + tcost_3 + tcost_4 + tcost_5 + tcost_6 + tcost_7 + tcost_8 + tcost_9 + tcost_10
TotalPnL        = TotalValue - TotalCost

numpos          = (p_1? 1 : 0) + (p_2? 1 : 0) + (p_3? 1 : 0) + (p_4? 1 : 0) + (p_5? 1 : 0) + (p_6? 1 : 0 ) + (p_7? 1 : 0) + (p_8? 1 : 0) + (p_9? 1 : 0) + (p_10? 1 : 0)

PortfolioChange = change(TotalPortfolio)
PortfolioUp     = PortfolioChange > 0
PnLChange       = change(TotalPnL)
PnLUp           = PnLChange > 0

plot(TotalPortfolio, "TotalPortfolio", color = PortfolioUp ? color.blue : color.yellow, linewidth=3, style = plot.style_stepline)
plot(TotalPnL, "Total P&L", color = PnLUp ? color.green : color.red, linewidth=3, style = plot.style_columns)

// Info Box
numformat   = "#,###" //"#.##"
n           = bar_index
NL          = "\n"
arrowup     = "   ↗ ↗" , arrowdn = "   ↘ ↘"
HeaderLine  = "============================"
header      = "******   Portfolio Summary   ******"

InfoBox = header + NL + HeaderLine + NL + NL
  + " # Active Positions = " + tostring(numpos) + NL
  + " Cost of Positions  = $" + tostring(TotalCost,numformat) + NL + NL
  + " Value of Positions  = $" + tostring(TotalValue,numformat) + NL
  + "    Cash in Account  = $" + tostring(Cash,numformat) + NL
  + "      Total Portfolio  = $" + tostring(TotalPortfolio,numformat) + NL + NL
  + "       Total P/L      = $" + tostring(TotalPnL,numformat) + NL
  + "            PnL %      = " + tostring(TotalPnL / (TotalCost + Cash) * 100, "#.##") + "%" + NL
  + NL + HeaderLine + NL
  + " ******* Current Bar Change ****** " + NL + HeaderLine + NL + NL
  + "       $ Gain  = $" + tostring(PnLChange,numformat) + NL
  + "       % Gain  = " + tostring(PnLChange/TotalPortfolio[1]*100,"#.##") + "%" + (PnLChange > 0 ? arrowup : arrowdn)

label l_infobox = label.new(n,TotalPortfolio,text = InfoBox,color=cbox, style=label.style_label_upper_left,textcolor=color.white, textalign=text.align_left)
label.delete(l_infobox[1])
````
