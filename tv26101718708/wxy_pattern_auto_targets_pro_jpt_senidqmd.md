# W-X-Y Pattern Auto Targets Pro [JPT]

- url: https://www.tradingview.com/script/SEnIdQMd-W-X-Y-Pattern-Auto-Targets-Pro-JPT/
- type: indicator
- pine_id: PUB;ffde06d429d64271a1f668edebf01526
- version: 2.0

## Description

🔷 [b]OVERVIEW[/b]

[b]W-X-Y Pattern Auto Targets Pro [JPT][/b] is an educational price action indicator that automatically detects potential [b]W-X-Y reversal structures[/b] using confirmed swing points. When a valid setup is identified, the indicator displays a complete trade framework including an Entry level, Stop Loss, and multiple Take Profit targets.

The indicator is designed to help traders visualize market structure and practice trade planning. It does not predict future price movement or guarantee profitable trades.
🔷 [b]FEATURES[/b]
[list][*]Automatic W-X-Y pattern detection
[*]Bullish and bearish setups
[*]Entry, Stop Loss, TP1, TP2, and TP3 levels
[*]Risk/Reward visualization
[*]EMA 50 & EMA 200 trend filter
[*]Confirmed swing-based structure
[*]Optional alerts for new setups
[*]Clean chart layout with minimal clutter[/list]
🔷 [b]HOW IT WORKS[/b]
[list][*]Detects confirmed swing highs and swing lows.
[*]Identifies potential W-X-Y reversal formations.
[*]Applies the optional EMA trend filter for additional market context.
[*]Calculates Entry, Stop Loss, and Take Profit levels based on the detected structure.
[*]Draws the setup directly on the chart for easy analysis[/list]
🔷 [b]HOW TO USE[/b]
[list][*]Look for newly detected W-X-Y patterns.
[*]Review the market structure and overall trend before making any trading decisions.
[*]Use the displayed Entry, Stop Loss, and Take Profit levels as a reference for planning trades.
[*]Consider combining this indicator with your own confirmation methods and risk management rules.[/list]
🔷 [b]NOTES[/b]
[list][*]Signals are generated from historical and confirmed price structure.
[*]The indicator is intended as an educational and analytical tool.
[*]No indicator can guarantee successful trades, and this script should not be used as the sole
[/list] basis for investment or trading decisions.

[i]If you find this project useful your feedback and suggestions are always appreciated Happy trading![/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("W-X-Y Pattern Auto Targets Pro [JPT]", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=100)


// ───── INPUTS ─────
pivotLen = input.int(5, "Swing Length", minval=2)

useTrend = input.bool(true, "Use EMA Trend Filter")
emaFastLen = input.int(50, "EMA Fast")
emaSlowLen = input.int(200, "EMA Slow")

rr1 = input.float(1.0, "TP1 Risk Reward")
rr2 = input.float(2.0, "TP2 Risk Reward")
rr3 = input.float(3.0, "TP3 Risk Reward")

showTargets = input.bool(true, "Show Targets")


// ───── TREND ─────
ema50 = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaSlowLen)

plot(useTrend ? ema50 : na, "EMA 50", color=color.orange)
plot(useTrend ? ema200 : na, "EMA 200", color=color.blue)

bullTrend = ema50 > ema200
bearTrend = ema50 < ema200



// ───── PIVOTS ─────
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)


var float W = na
var float X = na
var float Y = na

var int Wbar = na
var int Xbar = na
var int Ybar = na


// Store swings
if not na(pivotLow)
    W := pivotLow
    Wbar := bar_index - pivotLen

if not na(pivotHigh)
    X := pivotHigh
    Xbar := bar_index - pivotLen


// ───── PATTERN LOGIC ─────

// Bullish W-X-Y
bullXY = not na(W) and not na(X) and low < W and close > X

// Bearish W-X-Y
bearXY = not na(W) and not na(X) and high > X and close < W



// ───── DRAW PATTERN ─────

if bullXY and (not useTrend or bullTrend)

    Y := low
    Ybar := bar_index


    line.new(Wbar,W,Xbar,X,
      color=color.black,width=2)

    line.new(Xbar,X,Ybar,Y,
      color=color.black,width=2)


    label.new(Wbar,W,"W",
      style=label.style_label_down,
      color=color.gray,
      textcolor=color.white)

    label.new(Xbar,X,"X",
      style=label.style_label_up,
      color=color.gray,
      textcolor=color.white)

    label.new(Ybar,Y,"Y",
      style=label.style_label_down,
      color=color.green,
      textcolor=color.white)



    entry = close
    sl = Y
    risk = entry-sl

    tp1 = entry + risk*rr1
    tp2 = entry + risk*rr2
    tp3 = entry + risk*rr3


    if showTargets

        line.new(bar_index,entry,bar_index+30,entry,
          color=color.white,width=2)

        line.new(bar_index,sl,bar_index+30,sl,
          color=color.red,width=2)

        line.new(bar_index,tp1,bar_index+30,tp1,
          color=color.green)

        line.new(bar_index,tp2,bar_index+30,tp2,
          color=color.green)

        line.new(bar_index,tp3,bar_index+30,tp3,
          color=color.green)


    label.new(bar_index,low,
      "BUY\nW-X-Y",
      style=label.style_label_up,
      color=color.green,
      textcolor=color.white)



if bearXY and (not useTrend or bearTrend)

    Y := high
    Ybar := bar_index


    line.new(Wbar,W,Xbar,X,
      color=color.black,width=2)

    line.new(Xbar,X,Ybar,Y,
      color=color.black,width=2)


    label.new(Wbar,W,"W",
      style=label.style_label_up,
      color=color.gray,
      textcolor=color.white)

    label.new(Xbar,X,"X",
      style=label.style_label_down,
      color=color.gray,
      textcolor=color.white)

    label.new(Ybar,Y,"Y",
      style=label.style_label_up,
      color=color.red,
      textcolor=color.white)



    entry = close
    sl = Y
    risk = sl-entry

    tp1 = entry-risk*rr1
    tp2 = entry-risk*rr2
    tp3 = entry-risk*rr3


    if showTargets

        line.new(bar_index,entry,bar_index+30,entry,
          color=color.white,width=2)

        line.new(bar_index,sl,bar_index+30,sl,
          color=color.red,width=2)

        line.new(bar_index,tp1,bar_index+30,tp1,
          color=color.green)

        line.new(bar_index,tp2,bar_index+30,tp2,
          color=color.green)

        line.new(bar_index,tp3,bar_index+30,tp3,
          color=color.green)


    label.new(bar_index,high,
      "SELL\nW-X-Y",
      style=label.style_label_down,
      color=color.red,
      textcolor=color.white)



// Alerts

alertcondition(bullXY,"Bullish W-X-Y","Bullish W-X-Y Pattern Detected")

alertcondition(bearXY,"Bearish W-X-Y","Bearish W-X-Y Pattern Detected")
````
