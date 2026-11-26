# $SPX / $SPY / $QQQ BullFlow 5/5 Plan

- url: https://www.tradingview.com/script/j2xS7g8y-SPX-SPY-QQQ-BullFlow-5-5-Plan/
- type: indicator
- pine_id: PUB;94598afdb10342b1bfb33e573c779728
- version: 1.0

## Description

5/5 Script for [symbol="SP:SPX"]SP:SPX[/symbol], [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol], $SPY. 

I classified flow this way:

Call Ask / Above Ask = bullish
Put Bid / Below Bid = bullish
Put Ask / Above Ask = bearish
Call Bid / Below Bid = bearish
Mid = neutral / excluded from directional score
Correction prints were separated because they distorted [symbol="SP:SPX"]SP:SPX[/symbol] heavily.

Flow Work
Ticker	Total Premium	Calls	Puts	Bullish Premium	Bearish Premium	Read
[symbol="SP:SPX"]SP:SPX[/symbol] all prints	$417.3M	$205.6M	$211.7M	$304.5M	$100.3M	Looks bullish, but distorted by corrections
[symbol="SP:SPX"]SP:SPX[/symbol] excluding corrections	$72.8M	$22.1M	$50.7M	$22.2M	$50.6M	Actionable flow skewed bearish
$SPXW all prints	$31.9M	$9.7M	$22.2M	$15.9M	$14.1M	Balanced
$SPXW excluding corrections	$12.5M	$2.2M	$10.3M	$4.1M	$6.4M	Slight bearish tilt
[symbol="AMEX:SPY"]AMEX:SPY[/symbol]	$224.9M	$89.7M	$135.2M	$120.7M	$101.5M	Slight bullish, but put-heavy
[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol]	$200.2M	$110.2M	$90.0M	$108.8M	$86.9M	Cleanest bullish setup
[symbol="TVC:VIX"]TVC:VIX[/symbol]	$18.6M	$17.9M	$0.8M	$11.9M	$2.0M	Vol hedge active

The most important part: [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] has the cleanest conditional long profile. [symbol="AMEX:SPY"]AMEX:SPY[/symbol] is more two-way. [symbol="SP:SPX"]SP:SPX[/symbol] is sitting on a dangerous pivot because $SPXW max -GEX is at 7200.

[symbol="SP:SPX"]SP:SPX[/symbol] Analysis

[symbol="SP:SPX"]SP:SPX[/symbol] is at 7200.75. The chart is not cleanly bullish here. It rallied into 7250s, failed, rolled back into 7200, and is now compressing directly on the $SPXW 7200 negative gamma zone.

Gamma structure:

[symbol="SP:SPX"]SP:SPX[/symbol] Total Net GEX: +29.08B
[symbol="SP:SPX"]SP:SPX[/symbol] Max +GEX: 7400
[symbol="SP:SPX"]SP:SPX[/symbol] Max -GEX: 6800
$SPXW Total Net GEX: +7.31B
$SPXW Max +GEX: 7300
$SPXW Max -GEX: 7200

This creates a very specific setup. Above 7220 to 7240, the market can stabilize and squeeze back toward 7250, 7275, 7300. Below 7200, the index can get slippery because spot is sitting directly on the $SPXW max negative gamma level.

Base case: neutral-to-bearish below 7220. Bullish only on reclaim above 7220 and stronger above 7240.

Trade plan:

Bull trigger: 7220 reclaim
A-grade bull trigger: 7240 hold
Bull targets: 7250, 7275, 7300, 7350, 7400
Bear warning: below 7200
A-grade bear trigger: below 7185 / 7175
Bear targets: 7150, 7125, 7100, 7050, 7000
Avoid chop: 7195 to 7220 unless there is strong VIX confirmation.

VIX filter:

Longs are higher quality only if [symbol="TVC:VIX"]TVC:VIX[/symbol] is below 18.25 and preferably losing 18.00.
Shorts become higher quality if [symbol="TVC:VIX"]TVC:VIX[/symbol] holds above 18.25 and starts pushing toward 18.75 to 19.25.

[symbol="AMEX:SPY"]AMEX:SPY[/symbol] Analysis

[symbol="AMEX:SPY"]AMEX:SPY[/symbol] is at 717.76. This is weaker than [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] and less attractive for longs unless it reclaims 720.

Gamma structure:

[symbol="AMEX:SPY"]AMEX:SPY[/symbol] Total Net GEX: -2.38B
[symbol="AMEX:SPY"]AMEX:SPY[/symbol] Max +GEX: 725
[symbol="AMEX:SPY"]AMEX:SPY[/symbol] Max -GEX: 700

Negative net GEX means [symbol="AMEX:SPY"]AMEX:SPY[/symbol] can move more aggressively once a level breaks. It is not as pinned as a strong positive gamma tape. The upside magnet is 725, but price first has to reclaim 720 and 722.50. Without that reclaim, [symbol="AMEX:SPY"]AMEX:SPY[/symbol] remains vulnerable to a 715 to 712 test.

Flow read:

[symbol="AMEX:SPY"]AMEX:SPY[/symbol] had $224.9M total premium. Puts were larger than calls by notional value, but directional scoring still leaned slightly bullish because of put selling and some call buying. The issue is that the tape is mixed, not clean. 5/15 flow was almost balanced at $36.2M bullish versus $33.9M bearish.

Trade plan:

Bull trigger: 720 reclaim
A-grade bull trigger: 722.50
Bull targets: 725, 728, 730, 735
Bear warning: below 717.50
A-grade bear trigger: below 715
Bear targets: 712, 710, 705, 700
Avoid chop: 717.50 to 720.

Best usage: [symbol="AMEX:SPY"]AMEX:SPY[/symbol] is the confirmation vehicle. If [symbol="SP:SPX"]SP:SPX[/symbol] reclaims 7220 but [symbol="AMEX:SPY"]AMEX:SPY[/symbol] cannot reclaim 720, do not chase index calls.

[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] Analysis

[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] is the best long candidate of the three, but still conditional. Price is at 672.02 and holding above the 670 to 672 zone after the rally.

Gamma structure:

[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] Total Net GEX: +2.46B
[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] Max +GEX: 680
[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] Max -GEX: 645

Flow read:

[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] had $200.2M total premium. Calls were $110.2M versus puts at $90.0M. Directionally, bullish premium was $108.8M versus bearish premium at $86.9M. This is cleaner than $SPY. The 5/5 flow also leaned bullish at $7.14M bullish versus $5.39M bearish.

The problem is that price is still sitting below the real breakout area. [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] above 675 to 676.25 can magnetize into 680. Failure below 670 puts 668, 665, 660 into play.

Trade plan:

Bull trigger: 673.50 reclaim
A-grade bull trigger: 676.25
Bull targets: 680, 685, 690, 700
Bear warning: below 670
A-grade bear trigger: below 668
Bear targets: 665, 660, 655, 645
Avoid chop: 670 to 673.50.

Best setup: [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] long above 676.25 with [symbol="TVC:VIX"]TVC:VIX[/symbol] below 18.25 and [symbol="AMEX:SPY"]AMEX:SPY[/symbol] above 720. That is the cleanest continuation setup.

Priority Ranking for 5/5
[symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] long above 676.25
Cleanest flow, positive net GEX, 680 magnet overhead.
[symbol="SP:SPX"]SP:SPX[/symbol] downside below 7200 / 7185
Best volatility expansion setup if [symbol="TVC:VIX"]TVC:VIX[/symbol] holds above 18.25.
[symbol="AMEX:SPY"]AMEX:SPY[/symbol] directional confirmation
Use [symbol="AMEX:SPY"]AMEX:SPY[/symbol] 720 / 722.50 reclaim or 717.50 / 715 breakdown to confirm whether [symbol="SP:SPX"]SP:SPX[/symbol] is real.

No blind bullish open. The market needs to prove reclaim first.

Master Pine Script for [symbol="SP:SPX"]SP:SPX[/symbol] / [symbol="AMEX:SPY"]AMEX:SPY[/symbol] / [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol]

This one script covers all three. Add it to each chart and leave auto-detect on. It will detect [symbol="SP:SPX"]SP:SPX[/symbol], [symbol="AMEX:SPY"]AMEX:SPY[/symbol], or [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] and plot the correct levels, labels, triggers, table, EMAs, and VWAP.

## Source Code

````pine
//@version=6
indicator("$SPX / $SPY / $QQQ BullFlow 5/5 Plan", overlay=true, max_lines_count=200, max_labels_count=200)

//==============================
// Inputs
//==============================
setupMode     = input.string("SPX", "Manual Setup Mode", options=["SPX", "SPY", "QQQ"])
useAutoDetect = input.bool(true, "Auto-Detect Ticker")
labelOffset   = input.int(35, "Label Offset", minval=5, maxval=250)

showEMAs      = input.bool(true, "Show EMAs")
showVWAP      = input.bool(true, "Show VWAP")
showSignals   = input.bool(true, "Show Trigger Markers")
showTable     = input.bool(true, "Show Bias Table")

//==============================
// Auto Detect
//==============================
detectedMode =
     str.contains(syminfo.ticker, "QQQ") ? "QQQ" :
     str.contains(syminfo.ticker, "SPY") ? "SPY" :
     str.contains(syminfo.ticker, "SPX") ? "SPX" :
     setupMode

mode = useAutoDetect ? detectedMode : setupMode

//==============================
// Level Definitions
//==============================
pivot =
     mode == "SPX" ? 7200.00 :
     mode == "SPY" ? 718.00 :
     672.00

bullTrigger =
     mode == "SPX" ? 7220.00 :
     mode == "SPY" ? 720.00 :
     673.50

aGradeBull =
     mode == "SPX" ? 7240.00 :
     mode == "SPY" ? 722.50 :
     676.25

bullT1 =
     mode == "SPX" ? 7250.00 :
     mode == "SPY" ? 725.00 :
     680.00

bullT2 =
     mode == "SPX" ? 7275.00 :
     mode == "SPY" ? 728.00 :
     685.00

bullT3 =
     mode == "SPX" ? 7300.00 :
     mode == "SPY" ? 730.00 :
     690.00

bullT4 =
     mode == "SPX" ? 7350.00 :
     mode == "SPY" ? 735.00 :
     700.00

maxGex =
     mode == "SPX" ? 7400.00 :
     mode == "SPY" ? 725.00 :
     680.00

softInvalid =
     mode == "SPX" ? 7200.00 :
     mode == "SPY" ? 717.50 :
     670.00

bearTrigger =
     mode == "SPX" ? 7185.00 :
     mode == "SPY" ? 715.00 :
     668.00

bearT1 =
     mode == "SPX" ? 7150.00 :
     mode == "SPY" ? 712.00 :
     665.00

bearT2 =
     mode == "SPX" ? 7125.00 :
     mode == "SPY" ? 710.00 :
     660.00

bearT3 =
     mode == "SPX" ? 7100.00 :
     mode == "SPY" ? 705.00 :
     655.00

maxNegGex =
     mode == "SPX" ? 6800.00 :
     mode == "SPY" ? 700.00 :
     645.00

//==============================
// EMAs + VWAP
//==============================
ema8  = ta.ema(close, 8)
ema21 = ta.ema(close, 21)
ema50 = ta.ema(close, 50)
vwap  = ta.vwap(hlc3)

plot(showEMAs ? ema8 : na,  "EMA 8",  color=color.aqua, linewidth=2)
plot(showEMAs ? ema21 : na, "EMA 21", color=color.fuchsia, linewidth=2)
plot(showEMAs ? ema50 : na, "EMA 50", color=color.orange, linewidth=2)
plot(showVWAP ? vwap : na,  "VWAP",   color=color.yellow, linewidth=2)

//==============================
// Level Arrays
//==============================
prices = array.from(
     pivot,
     bullTrigger,
     aGradeBull,
     bullT1,
     bullT2,
     bullT3,
     bullT4,
     maxGex,
     softInvalid,
     bearTrigger,
     bearT1,
     bearT2,
     bearT3,
     maxNegGex
)

texts = array.from(
     "$" + mode + " Pivot / Chop: " + str.tostring(pivot, format.mintick),
     "$" + mode + " Bull Trigger > " + str.tostring(bullTrigger, format.mintick),
     "$" + mode + " A-Grade Bull > " + str.tostring(aGradeBull, format.mintick),
     "$" + mode + " Bull T1: " + str.tostring(bullT1, format.mintick),
     "$" + mode + " Bull T2: " + str.tostring(bullT2, format.mintick),
     "$" + mode + " Bull T3: " + str.tostring(bullT3, format.mintick),
     "$" + mode + " Bull T4: " + str.tostring(bullT4, format.mintick),
     "$" + mode + " Max +GEX / Magnet: " + str.tostring(maxGex, format.mintick),
     "$" + mode + " Bear Warning < " + str.tostring(softInvalid, format.mintick),
     "$" + mode + " A-Grade Bear < " + str.tostring(bearTrigger, format.mintick),
     "$" + mode + " Bear T1: " + str.tostring(bearT1, format.mintick),
     "$" + mode + " Bear T2: " + str.tostring(bearT2, format.mintick),
     "$" + mode + " Bear T3: " + str.tostring(bearT3, format.mintick),
     "$" + mode + " Max -GEX / Downside Magnet: " + str.tostring(maxNegGex, format.mintick)
)

var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()

f_levelColor(_i) =>
    _i == 0 ? color.orange :
     _i >= 1 and _i <= 7 ? color.green :
     _i == 8 ? color.orange :
     color.red

f_levelStyle(_i) =>
    _i == 0 or _i == 1 or _i == 2 or _i == 8 or _i == 9 ? line.style_solid : line.style_dashed

f_levelWidth(_i) =>
    _i == 0 or _i == 1 or _i == 2 or _i == 8 or _i == 9 ? 2 : 1

//==============================
// Create Lines / Labels
//==============================
if barstate.isfirst
    for i = 0 to array.size(prices) - 1
        p = array.get(prices, i)
        txt = array.get(texts, i)
        c = f_levelColor(i)
        sty = f_levelStyle(i)
        w = f_levelWidth(i)

        l = line.new(
             x1=bar_index,
             y1=p,
             x2=bar_index + labelOffset,
             y2=p,
             xloc=xloc.bar_index,
             extend=extend.right,
             color=c,
             style=sty,
             width=w
        )

        lab = label.new(
             x=bar_index + labelOffset,
             y=p,
             text=txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=c,
             textcolor=color.white,
             size=size.small
        )

        array.push(levelLines, l)
        array.push(levelLabels, lab)

//==============================
// Update Lines / Labels
//==============================
if barstate.islast
    for i = 0 to array.size(prices) - 1
        p = array.get(prices, i)
        txt = array.get(texts, i)
        c = f_levelColor(i)
        sty = f_levelStyle(i)
        w = f_levelWidth(i)

        l = array.get(levelLines, i)
        lab = array.get(levelLabels, i)

        line.set_xy1(l, bar_index - 1, p)
        line.set_xy2(l, bar_index + labelOffset, p)
        line.set_color(l, c)
        line.set_style(l, sty)
        line.set_width(l, w)

        label.set_x(lab, bar_index + labelOffset)
        label.set_y(lab, p)
        label.set_text(lab, txt)
        label.set_color(lab, c)
        label.set_textcolor(lab, color.white)

//==============================
// Signal Logic
//==============================
bullSignal       = ta.crossover(close, bullTrigger)
aGradeBullSignal = ta.crossover(close, aGradeBull)
softFailSignal   = ta.crossunder(close, softInvalid)
bearSignal       = ta.crossunder(close, bearTrigger)

plotshape(showSignals and bullSignal, title="Bull Trigger", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="Bull")
plotshape(showSignals and aGradeBullSignal, title="A-Grade Bull", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.normal, text="A+")
plotshape(showSignals and softFailSignal, title="Bear Warning", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.small, text="Warn")
plotshape(showSignals and bearSignal, title="A-Grade Bear", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal, text="Bear")

alertcondition(bullSignal, title="Bull Trigger", message="Bull trigger crossed.")
alertcondition(aGradeBullSignal, title="A-Grade Bull Trigger", message="A-grade bull trigger crossed.")
alertcondition(softFailSignal, title="Bear Warning", message="Bear warning level lost.")
alertcondition(bearSignal, title="A-Grade Bear Trigger", message="A-grade bear trigger crossed.")

//==============================
// Bias Table
//==============================
var table setupTable = table.new(position.top_right, 1, 6, border_width=1)

biasText =
     close >= aGradeBull ? "$" + mode + " A-GRADE LONG" :
     close >= bullTrigger ? "$" + mode + " BULL RECLAIM" :
     close <= bearTrigger ? "$" + mode + " A-GRADE BEAR" :
     close <= softInvalid ? "$" + mode + " BEAR WARNING" :
     "$" + mode + " CHOP / WAIT"

biasColor =
     close >= aGradeBull ? color.green :
     close >= bullTrigger ? color.new(color.green, 25) :
     close <= bearTrigger ? color.red :
     close <= softInvalid ? color.orange :
     color.gray

if showTable and barstate.islast
    table.cell(setupTable, 0, 0, "$" + mode + " 5/5 Setup", text_color=color.white, bgcolor=color.black)
    table.cell(setupTable, 0, 1, biasText, text_color=color.white, bgcolor=biasColor)
    table.cell(setupTable, 0, 2, "Long: > " + str.tostring(bullTrigger, format.mintick) + " / A+ > " + str.tostring(aGradeBull, format.mintick), text_color=color.white, bgcolor=color.new(color.green, 70))
    table.cell(setupTable, 0, 3, "Bear: < " + str.tostring(softInvalid, format.mintick) + " / A+ < " + str.tostring(bearTrigger, format.mintick), text_color=color.white, bgcolor=color.new(color.red, 70))
    table.cell(setupTable, 0, 4, "Bull Targets: " + str.tostring(bullT1, format.mintick) + " / " + str.tostring(bullT2, format.mintick) + " / " + str.tostring(bullT3, format.mintick) + " / " + str.tostring(bullT4, format.mintick), text_color=color.white, bgcolor=color.black)
    table.cell(setupTable, 0, 5, "Gamma Magnets: +" + str.tostring(maxGex, format.mintick) + " / -" + str.tostring(maxNegGex, format.mintick), text_color=color.white, bgcolor=color.black)
````
