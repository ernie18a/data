# Raschke 3/10 Oscillator + ADX

- url: https://www.tradingview.com/script/E9UaNuvr-Raschke-3-10-Oscillator-ADX/
- type: indicator
- pine_id: PUB;e917bdf33246434ab3da0ac860a772b5
- version: 1.0

## Description

The histogram uses four shades — bright teal when bull momentum is building, faded teal when it's fading, bright red when bear momentum is building, faded red when it's fading. This alone tells you the story at a glance.
The fast line (3-10 EMA) changes color based on four states: solid teal = above signal AND positive (strongest bull), faded teal = above signal but still negative (recovering), faded red = below signal but still positive (weakening), solid red = below signal AND negative (strongest bear).
The ADX background does the heavy lifting — green tint fills the pane when ADX ≥ 25 (trending, trust the crosses), red tint when ADX ≤ 20 (choppy, fade extremes instead). The info table in the top-right corner shows live ADX value, DI+/DI−, and current state label.

The four signal shapes plotted:
ShapeMeaning▲ solid tealBull cross — fast crossed above signal▼ solid redBear cross — fast crossed below signal● small tealBull hook — continuation without recrossing● small redBear hook — continuation without recrossing✕ orangeBearish divergence warning✕ blueBullish divergence warning

Linda Raschke's rule baked in: The high-conviction alert fires only when a cross happens AND ADX is already in trending territory — that's the confirmation she requires before trusting a directional entry. All 9 alert conditions are pre-wired and ready to activate from the TradingView Alerts menu.



the 3/10 oscillator, four-shade histogram, ADX background zones, the info table, all signal shapes, and all 10 alert condition

## Source Code

````pine
//@version=6
indicator(title="Raschke 3/10 Oscillator + ADX", shorttitle="3/10 + ADX", overlay=false, max_bars_back=500)

// ============================================================
// INPUTS - 3/10 Oscillator
// ============================================================
var GRP1 = "3/10 Oscillator"
i_fast = input.int(3,  "Fast EMA Length",   minval=1, maxval=50,  group=GRP1)
i_slow = input.int(10, "Slow EMA Length",   minval=2, maxval=200, group=GRP1)
i_sig  = input.int(16, "Signal SMA Length", minval=1, maxval=200, group=GRP1)

// ============================================================
// INPUTS - ADX
// ============================================================
var GRP2 = "ADX Settings"
i_adxLen  = input.int(14, "DI Length",             minval=1, maxval=100, group=GRP2)
i_adxSmth = input.int(14, "ADX Smoothing",         minval=1, maxval=100, group=GRP2)
i_adxH    = input.int(25, "Trending Threshold >=", minval=1, maxval=99,  group=GRP2)
i_adxL    = input.int(20, "Choppy Threshold <=",   minval=1, maxval=99,  group=GRP2)
i_showBg  = input.bool(true, "Show ADX Background Zones", group=GRP2)
i_showTbl = input.bool(true, "Show ADX Info Table",       group=GRP2)

// ============================================================
// INPUTS - Signals
// ============================================================
var GRP3 = "Signal Visibility"
i_showCross = input.bool(true, "Show Cross Signals",      group=GRP3)
i_showHook  = input.bool(true, "Show Hook Signals",       group=GRP3)
i_showDiv   = input.bool(true, "Show Divergence Signals", group=GRP3)
i_divBars   = input.int(8, "Divergence Lookback Bars",    minval=3, maxval=30, group=GRP3)

// ============================================================
// INPUTS - Colors
// ============================================================
var GRP4 = "Colors"
i_cBull  = input.color(#26A69A, "Bull Color",          group=GRP4)
i_cBear  = input.color(#EF5350, "Bear Color",          group=GRP4)
i_cSig   = input.color(#FF9800, "Signal Line",         group=GRP4)
i_cTrend = input.color(color.new(#4CAF50, 87), "Trending Background", group=GRP4)
i_cChop  = input.color(color.new(#F44336, 87), "Choppy Background",   group=GRP4)

// ============================================================
// 3/10 OSCILLATOR
// ============================================================
osc  = ta.ema(close, i_fast) - ta.ema(close, i_slow)
sig  = ta.sma(osc, i_sig)
hist = osc - sig

// ============================================================
// ADX
// ============================================================
[diPlus, diMinus, adxVal] = ta.dmi(i_adxLen, i_adxSmth)
isTrend = adxVal >= i_adxH
isChop  = adxVal <= i_adxL

// ============================================================
// BACKGROUNDS
// ============================================================
bgcolor(i_showBg and isTrend ? i_cTrend : na, title="Trending Zone")
bgcolor(i_showBg and isChop  ? i_cChop  : na, title="Choppy Zone")

// ============================================================
// HISTOGRAM
// ============================================================
histCol = hist >= 0
         ? (hist >= hist[1] ? i_cBull : color.new(i_cBull, 55))
         : (hist <= hist[1] ? i_cBear : color.new(i_cBear, 55))
plot(hist, "Histogram", color=histCol, style=plot.style_histogram, linewidth=2)

// ============================================================
// FAST LINE + SIGNAL LINE
// ============================================================
oscCol = osc > sig and osc >= 0 ? i_cBull :
         osc > sig and osc <  0 ? color.new(i_cBull, 45) :
         osc < sig and osc >  0 ? color.new(i_cBear, 45) :
                                  i_cBear

p_osc = plot(osc, "Fast Line", color=oscCol, linewidth=2)
p_sig = plot(sig, "Signal Line", color=i_cSig, linewidth=1)
fill(p_osc, p_sig, color=color.new(osc > sig ? i_cBull : i_cBear, 91), title="Fill")
hline(0, "Zero", color=color.new(color.gray, 35), linestyle=hline.style_dashed, linewidth=1)

// ============================================================
// SIGNALS
// ============================================================
bullCross = ta.crossover(osc, sig)
bearCross = ta.crossunder(osc, sig)
bullHook  = not bullCross and osc > sig and osc > osc[1] and osc[1] < osc[2]
bearHook  = not bearCross and osc < sig and osc < osc[1] and osc[1] > osc[2]

ph = ta.highest(close, i_divBars)
pl = ta.lowest(close,  i_divBars)
oh = ta.highest(osc,   i_divBars)
ol = ta.lowest(osc,    i_divBars)

bearDiv = i_showDiv and close >= ph * 0.999 and osc < oh * 0.92 and osc > 0
bullDiv = i_showDiv and close <= pl * 1.001 and osc > ol * 0.92 and osc < 0

// ============================================================
// SHAPES
// ============================================================
plotshape(i_showCross and bullCross, "Bull Cross",
         style=shape.triangleup, location=location.bottom,
         color=#26A69A, size=size.small)

plotshape(i_showCross and bearCross, "Bear Cross",
         style=shape.triangledown, location=location.top,
         color=#EF5350, size=size.small)

plotshape(i_showHook and bullHook, "Bull Hook",
         style=shape.circle, location=location.bottom,
         color=color.new(#26A69A, 20), size=size.tiny)

plotshape(i_showHook and bearHook, "Bear Hook",
         style=shape.circle, location=location.top,
         color=color.new(#EF5350, 20), size=size.tiny)

plotshape(bearDiv, "Bear Divergence",
         style=shape.xcross, location=location.top,
         color=#FF6B35, size=size.small)

plotshape(bullDiv, "Bull Divergence",
         style=shape.xcross, location=location.bottom,
         color=#64B5F6, size=size.small)

// ============================================================
// INFO TABLE
// ============================================================
var table tbl = table.new(
     position=position.top_right, columns=2, rows=5,
     border_width=1, border_color=color.new(color.gray, 55),
     frame_width=1,  frame_color=color.new(color.gray, 40))

if i_showTbl and barstate.islast
    adxColor  = isTrend ? color.new(#26A69A, 0) : isChop ? color.new(#EF5350, 0) : color.new(#B39DDB, 0)
    stateText = isTrend ? "TREND" : isChop ? "CHOP" : "NEUTRAL"
    bg  = color.new(#0d1117, 5)
    bgH = color.new(#161b22, 5)

    table.cell(tbl, 0, 0, "ADX (14)",
               text_color=color.silver, bgcolor=bgH, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, str.tostring(math.round(adxVal, 1)),
               text_color=adxColor, bgcolor=bgH, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 1, "State",
               text_color=color.silver, bgcolor=bg, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1, stateText,
               text_color=adxColor, bgcolor=bg, text_size=size.small, text_halign=text.align_right)

    table.cell(tbl, 0, 2, "DI+",
               text_color=color.gray, bgcolor=bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(math.round(diPlus, 1)),
               text_color=color.new(#26A69A, 0), bgcolor=bg, text_size=size.tiny, text_halign=text.align_right)

    table.cell(tbl, 0, 3, "DI-",
               text_color=color.gray, bgcolor=bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 3, str.tostring(math.round(diMinus, 1)),
               text_color=color.new(#EF5350, 0), bgcolor=bg, text_size=size.tiny, text_halign=text.align_right)

    table.cell(tbl, 0, 4, ">=" + str.tostring(i_adxH) + " trend / <=" + str.tostring(i_adxL) + " chop",
               text_color=color.new(color.gray, 30), bgcolor=bgH, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 1, 4, "",
               text_color=color.gray, bgcolor=bgH, text_size=size.tiny)

// ============================================================
// ALERTS
// ============================================================
alertcondition(bullCross,                  title="Bull Cross",          message="3/10 - Bull Cross: fast crossed above signal.")
alertcondition(bearCross,                  title="Bear Cross",          message="3/10 - Bear Cross: fast crossed below signal.")
alertcondition(bullCross and isTrend,      title="Bull Cross in Trend", message="3/10 - High Conviction Bull Cross: ADX trending.")
alertcondition(bearCross and isTrend,      title="Bear Cross in Trend", message="3/10 - High Conviction Bear Cross: ADX trending.")
alertcondition(bullHook,                   title="Bull Hook",           message="3/10 - Bull Hook continuation.")
alertcondition(bearHook,                   title="Bear Hook",           message="3/10 - Bear Hook continuation.")
alertcondition(isTrend and not isTrend[1], title="ADX Entered Trend",   message="ADX entered trending zone.")
alertcondition(isChop  and not isChop[1],  title="ADX Entered Chop",    message="ADX entered choppy zone.")
alertcondition(bearDiv,                    title="Bearish Divergence",  message="3/10 - Bearish divergence detected.")
alertcondition(bullDiv,                    title="Bullish Divergence",  message="3/10 - Bullish divergence detected.")
````
