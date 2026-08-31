<!-- tradingview-pine-id: PUB;SO4ASax7aRrMPSXzi4HIp755lNTpAIs0 -->
<!-- tradingviewscripts-format: 1 -->
# Technical Rank

Source: https://www.tradingview.com/script/czknkFNs-Technical-Rank/

## Description

Hello Traders,

Technical Rank (TR) was authored by John Murphy. Technical Rank shows how a security is performing relative to its peers. Multiple moving averages, rate of change and the Relative Strength Index (RSI) indicators are used to calculate the Technical Rank. These values are mathematically manipulated with percentage factors and then summed together. there are 3 parts, long term, middle term and short term. for Long term part Moving Average with length 200 (30%) and Rate of Change with the length 125 (30%) are used, for middle term part, Moving Average with length 50 (15%) and Rate of Change with the length 20 (15%) are used and for short term part, PPO (5%) and RSI (5%) used. 

Technical Rank is created using the following formula and weightings:
Long-Term Indicators (weighting): Percent above/below the 200-day exponential moving average (EMA) (30% weight) and the 125-day rate-of-change (ROC) (30% weight).
Medium-Term Indicators (weighting): Percent above/below 50-day EMA (15%) and the 20-day rate-of-change (15%).
Short-Term Indicators (weighting): Three-day slope of percentage price oscillator histogram divided by three (5%) and the relative strength index (5%).

The scripts calculates Technical Rank for 10 different securities and sorts them by Technical Rank value. A ranking of zero indicates the stock is the weakest in the group technically. A rank of 100 indicates the stock ranks highest in terms of technical performance. An increasing Technical Rank means the stock's price performance is showing strength relative to the group of stock being analyzed. A decreasing Technical Rank shows deteriorating relative price performance. Securities in the top 3-4 will have a technical rank of 70 or higher. You should focus on these relatively strong securities for potential long positions on pullbacks. You can also use the technical rank to avoid weak securities (in the bottom 3-4). I recommend you to check Technical Rank for the securities in multiple time frames.

You can choose the symbols as you want but you should choose the symbols with the same session info. for example only Cryptos, only Stocks, only FX pairs etc. (not mix of them).

Enjoy!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue

//@version=4
study("Technical Rank")
Offset = input(defval = 0, title = "Label Offset", minval = 0)
sym1 = input(defval = "NASDAQ:MSFT", title = "Symbol 1", type = input.string)
sym2 = input(defval = "NASDAQ:AAPL", title = "Symbol 2", type = input.string)
sym3 = input(defval = "NASDAQ:AMZN", title = "Symbol 3", type = input.string)
sym4 = input(defval = "NASDAQ:GOOGL", title = "Symbol 4", type = input.string)
sym5 = input(defval = "NASDAQ:FB", title = "Symbol 5", type = input.string)
sym6 = input(defval = "NASDAQ:INTC", title = "Symbol 6", type = input.string)
sym7 = input(defval = "NASDAQ:CSCO", title = "Symbol 7", type = input.string)
sym8 = input(defval = "NASDAQ:CMCSA", title = "Symbol 8", type = input.string)
sym9 = input(defval = "NASDAQ:PEP", title = "Symbol 9", type = input.string)
sym10= input(defval = "NASDAQ:ADBE", title = "Symbol 10", type = input.string)
sym11 = input(defval = "NASDAQ:SBUX", title = "Symbol 11", type = input.string)
sym12 = input(defval = "NASDAQ:TXN", title = "Symbol 12", type = input.string)
sym13 = input(defval = "NASDAQ:QCOM", title = "Symbol 13", type = input.string)
sym14 = input(defval = "NASDAQ:PYPL", title = "Symbol 14", type = input.string)
sym15 = input(defval = "NASDAQ:COST", title = "Symbol 15", type = input.string)
sym16 = input(defval = "NASDAQ:AMGN", title = "Symbol 16", type = input.string)
sym17 = input(defval = "NASDAQ:AVGO", title = "Symbol 17", type = input.string)
sym18 = input(defval = "", title = "Symbol 18", type = input.string)
sym19 = input(defval = "", title = "Symbol 19", type = input.string)
sym20= input(defval = "", title = "Symbol 20", type = input.string)
labcol = input(defval = color.yellow, title = "Label Color", type = input.color)
txtcol = input(defval = color.black, title = "Text Color", type = input.color)

Technical_Rank(clsval)=>
    ma200 = sma(clsval, 200)
    ma50  = sma(clsval, 50)
    longtermma = 0.30 * 100 * (clsval - ma200) / ma200
    longtermroc = 0.30 * roc(clsval, 125)
    
    midtermma = 0.15 * 100 * (clsval - ma50) / ma50
    midtermroc = 0.15  * roc(clsval, 20)
    
    ma12 = ema(clsval, 12)
    ma26 = ema(clsval, 26)
    ppo = 100 * (ma12 - ma26) / ma26
    sig = ema(ppo, 9)
    ppoHist = ppo - sig
    
    slope = (ppoHist - ppoHist[8]) / 3
    stPpo = .05 * 100 * slope
    
    stRsi = .05 * rsi(clsval, 14)
    trank = longtermma + longtermroc + midtermma + midtermroc + stPpo + stRsi
    trank := trank < 0 ? 0 : trank > 100 ? 100 : trank

get_sym(x)=>
    ret = x == 1 ? sym1 : x == 2 ? sym2 : x == 3 ? sym3 : x == 4 ? sym4 : x == 5 ? sym5 : x == 6 ? sym6 : x == 7 ? sym7 : x == 8 ? sym8 : x == 9 ? sym9 : x == 10 ? sym10 :
          x == 11 ? sym11 : x == 12 ? sym12 : x == 13 ? sym13 : x == 14 ? sym14 : x == 15 ? sym15 : x == 16 ? sym16 : x == 17 ? sym17 : x == 18 ? sym18 : x == 19 ? sym19 : sym20

// assign
var trlist = array.new_float(40, 0) // 10 x 2 matrix
array.set(trlist,  0,  1), array.set(trlist, 1, sym1 != "" ? Technical_Rank(security(sym1, timeframe.period, close)) : 0.)
array.set(trlist,  2,  2), array.set(trlist, 3, sym2 != "" ? Technical_Rank(security(sym2, timeframe.period, close)) : 0.)
array.set(trlist,  4,  3), array.set(trlist, 5, sym3 != "" ? Technical_Rank(security(sym3, timeframe.period, close)) : 0.)
array.set(trlist,  6,  4), array.set(trlist, 7, sym4 != "" ? Technical_Rank(security(sym4, timeframe.period, close)) : 0.)
array.set(trlist,  8,  5), array.set(trlist, 9, sym5 != "" ? Technical_Rank(security(sym5, timeframe.period, close)) : 0.)
array.set(trlist, 10,  6), array.set(trlist,11, sym6 != "" ? Technical_Rank(security(sym6, timeframe.period, close)) : 0.)
array.set(trlist, 12,  7), array.set(trlist,13, sym7 != "" ? Technical_Rank(security(sym7, timeframe.period, close)) : 0.)
array.set(trlist, 14,  8), array.set(trlist,15, sym8 != "" ? Technical_Rank(security(sym8, timeframe.period, close)) : 0.)
array.set(trlist, 16,  9), array.set(trlist,17, sym9 != "" ? Technical_Rank(security(sym9, timeframe.period, close)) : 0.)
array.set(trlist, 18, 10), array.set(trlist,19, sym10 != "" ? Technical_Rank(security(sym10,timeframe.period, close)) : 0.)
array.set(trlist, 20, 11), array.set(trlist,21, sym11 != "" ? Technical_Rank(security(sym11,timeframe.period, close)) : 0.)
array.set(trlist, 22, 12), array.set(trlist,23, sym12 != "" ? Technical_Rank(security(sym12,timeframe.period, close)) : 0.)
array.set(trlist, 24, 13), array.set(trlist,25, sym13 != "" ? Technical_Rank(security(sym13,timeframe.period, close)) : 0.)
array.set(trlist, 26, 14), array.set(trlist,27, sym14 != "" ? Technical_Rank(security(sym14,timeframe.period, close)) : 0.)
array.set(trlist, 28, 15), array.set(trlist,29, sym15 != "" ? Technical_Rank(security(sym15,timeframe.period, close)) : 0.)
array.set(trlist, 30, 16), array.set(trlist,31, sym16 != "" ? Technical_Rank(security(sym16,timeframe.period, close)) : 0.)
array.set(trlist, 32, 17), array.set(trlist,33, sym17 != "" ? Technical_Rank(security(sym17,timeframe.period, close)) : 0.)
array.set(trlist, 34, 18), array.set(trlist,35, sym18 != "" ? Technical_Rank(security(sym18,timeframe.period, close)) : 0.)
array.set(trlist, 36, 19), array.set(trlist,37, sym19 != "" ? Technical_Rank(security(sym19,timeframe.period, close)) : 0.)
array.set(trlist, 38, 20), array.set(trlist,39, sym20 != "" ? Technical_Rank(security(sym20,timeframe.period, close)) : 0.)

// sort
for x = 0 to 18
    for y = x + 1 to 19
        if array.get(trlist, y * 2 + 1) > array.get(trlist, x * 2 + 1)
            float tmp = array.get(trlist, y * 2)
            array.set(trlist, y * 2, array.get(trlist, x * 2))
            array.set(trlist, x * 2, tmp)
            tmp := array.get(trlist, y * 2 + 1)
            array.set(trlist, y * 2 + 1, array.get(trlist, x * 2 + 1))
            array.set(trlist, x * 2 + 1, tmp)

// show
trtext1 = "-------- TECHNICAL RANK / 1 --------\n\n"
trtext2 = "-------- TECHNICAL RANK / 2 --------\n\n"
for x = 0 to 9
    trtext1 := trtext1 + tostring(x + 1) + ". " + get_sym(array.get(trlist, x * 2)) + " : " + tostring(array.get(trlist, x * 2 + 1), '#.###') + "\n"

for x = 10 to 19
    trtext2 := trtext2 + tostring(x + 1) + ". " + get_sym(array.get(trlist, x * 2)) + " : " + tostring(array.get(trlist, x * 2 + 1), '#.###') + "\n"
    
var label lab1 = label.new(bar_index, 0, "", textalign = text.align_left, style = label.style_label_right, color = labcol, textcolor = txtcol)
var label lab2 = label.new(bar_index, 0, "", textalign = text.align_left, style = label.style_label_right, color = labcol, textcolor = txtcol)
label.set_text(lab1, trtext1)
label.set_x(lab1, bar_index - Offset - 35)
label.set_text(lab2, trtext2)
label.set_x(lab2, bar_index - Offset)
````
