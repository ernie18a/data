# Top-Down Candle Panel

- url: https://www.tradingview.com/script/iAhb0wdo-Top-Down-Candle-Panel/
- type: indicator
- pine_id: PUB;513dc0a93a154197b4f8a9942d635ae9
- version: 1.0

## Description

[image]https://www.tradingview.com/x/jyYpcMy2/[/image]

[b]Top-Down Candle Panel[/b]

The Top-Down Candle Panel is a premium multi-timeframe candle visualization system built for traders who rely on top-down analysis, market structure, and higher-timeframe confirmation.

Instead of constantly switching between charts and timeframes, this indicator projects multiple higher-timeframe candles directly onto your active chart, allowing you to instantly read market pressure, candle behavior, and higher-timeframe sentiment in real time.

Designed for precision traders, scalpers, intraday traders, and swing traders alike, the panel helps simplify market context while reducing chart clutter and decision fatigue.

━━━━━━━━━━━━━━━━━━
KEY FEATURES
━━━━━━━━━━━━━━━━━━

[list]
[*]Displays up to 4 fully customizable timeframes simultaneously
[*]Default structure includes 5M, 15M, 1H, and 4H analysis
[*]Hybrid, Price Accurate, and Aligned Dashboard display modes
[*]Smart candle projection system
[*]Built-in candle behavior recognition
[*]Premium minimalist dashboard styling
[*]Adjustable candle scaling and spacing controls
[*]Light and dark mode compatibility
[*]Optional real-price hybrid markers
[*]Multi-timeframe alignment visualization
[*]Clean top-down workflow integration
[/list]

━━━━━━━━━━━━━━━━━━
ADVANCED CANDLE ANALYSIS
━━━━━━━━━━━━━━━━━━

The panel automatically classifies candle behavior to help traders quickly interpret higher-timeframe intent and momentum.

[b]Included candle reads:[/b]
[list]
[*]Bullish Expansion
[*]Bearish Expansion
[*]Upper Rejection
[*]Lower Rejection
[*]Doji
[*]Bullish / Bearish pressure candles
[/list]

[b]This allows traders to instantly identify:[/b]
[list]
[*]Expansion strength
[*]Rejection zones
[*]Momentum continuation
[*]Possible exhaustion
[*]Higher-timeframe buying or selling pressure
[/list]

━━━━━━━━━━━━━━━━━━
WHY THIS TOOL EXISTS
━━━━━━━━━━━━━━━━━━

Most traders perform top-down analysis by manually flipping through multiple charts and timeframes. This process is slow, distracting, and often causes traders to lose focus on current price action.

[b]The Top-Down Candle Panel was built to solve that problem.[/b]

By placing multiple timeframe candles directly beside live price action, traders can maintain situational awareness without leaving the active chart.

[b]This creates a faster and cleaner workflow for:[/b]
[list]
[*]Multi-timeframe confirmation
[*]Trend continuation analysis
[*]Rejection candle recognition
[*]Trade filtering
[*]Directional bias
[*]Context-based execution
[*]Avoiding trades against higher-timeframe pressure
[*]
[/list]
━━━━━━━━━━━━━━━━━━
IMPORTANT
━━━━━━━━━━━━━━━━━━

This indicator is not designed to generate automatic buy or sell signals.

Its purpose is to improve decision quality through clearer market context, cleaner visualization, and stronger higher-timeframe awareness.

[b]The goal is simple:[/b]
Help traders see what the higher timeframes are doing before entering the trade.

## Source Code

````pine
//@version=6
indicator("Top-Down Candle Panel", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tf1 = input.timeframe("5", "TF 1")
tf2 = input.timeframe("15", "TF 2")
tf3 = input.timeframe("60", "TF 3")
tf4 = input.timeframe("240", "TF 4")

showTF1 = input.bool(true, "Show TF1")
showTF2 = input.bool(true, "Show TF2")
showTF3 = input.bool(true, "Show TF3")
showTF4 = input.bool(true, "Show TF4")

displayMode = input.string(
     "Hybrid",
     "Display Mode",
     options = ["Price Accurate", "Aligned Dashboard", "Hybrid"]
)

alignBasis = input.string(
     "Midpoint",
     "Aligned Anchor Basis",
     options = ["Midpoint", "Close"]
)

useChartTFWhenMatching =
     input.bool(true, "Use Chart Candle When TF Matches")

offsetX =
     input.int(14, "Right Offset", minval = 2, maxval = 120)

gapX =
     input.int(9, "Candle Spacing", minval = 4, maxval = 40)

bodyWidth =
     input.int(2, "Body Width", minval = 1, maxval = 6)

wickWidth =
     input.int(1, "Wick Width", minval = 1, maxval = 4)

scale5M =
     input.float(14.5, "5M Scale", minval = 0.25, step = 0.25)

scale15M =
     input.float(12.5, "15M Scale", minval = 0.25, step = 0.25)

scale1H =
     input.float(8.0, "1H Scale", minval = 0.25, step = 0.25)

scale4H =
     input.float(2.5, "4H Scale", minval = 0.25, step = 0.25)

showLabels =
     input.bool(true, "Show TF Labels")

showCandleReads =
     input.bool(true, "Show Candle Read Labels")

showGhostMarkers =
     input.bool(false, "Show Real Price Marker In Hybrid")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THEME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
themeMode = input.string(
     "Auto",
     "Theme Mode",
     options = ["Auto", "Dark", "Light"]
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullCol    = color.new(#00c89b, 0)
bearCol    = color.new(#f23645, 0)

bullBorder = color.new(#00c89b, 0)
bearBorder = color.new(#f23645, 0)

isLight = themeMode == "Light"

wickCol =
     isLight
          ? color.new(color.black, 45)
          : color.new(color.white, 35)

labelBg =
     isLight
          ? color.new(#dfe3eb, 0)
          : color.new(#1e222d, 0)

labelTextCol =
     isLight
          ? color.black
          : color.white

ghostCol =
     isLight
          ? color.new(color.black, 70)
          : color.new(color.white, 65)

amberCol = #ffb100

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tfLabel(_tf) =>
    n = str.tonumber(_tf)

    not na(n)
         ? (
             int(n) >= 60 and int(n) % 60 == 0
                  ? str.tostring(int(n / 60)) + "H"
                  : str.tostring(int(n)) + "M"
           )
         : str.upper(_tf)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
getCandle(_tf) =>
    chartSec = timeframe.in_seconds(timeframe.period)
    reqSec   = timeframe.in_seconds(_tf)

    useChart =
         useChartTFWhenMatching and chartSec == reqSec

    float o = na
    float h = na
    float l = na
    float c = na

    if useChart
        o := open
        h := high
        l := low
        c := close
    else
        [ro, rh, rl, rc] =
             request.security(
                  syminfo.tickerid,
                  _tf,
                  [open, high, low, close],
                  barmerge.gaps_off,
                  barmerge.lookahead_off
             )

        o := ro
        h := rh
        l := rl
        c := rc

    [o, h, l, c]

[o1, h1, l1, c1] = getCandle(tf1)
[o2, h2, l2, c2] = getCandle(tf2)
[o3, h3, l3, c3] = getCandle(tf3)
[o4, h4, l4, c4] = getCandle(tf4)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC SLOT POSITIONING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
slot1 = 0

slot2 =
     showTF1
          ? 1
          : 0

slot3 =
     (showTF1 ? 1 : 0) +
     (showTF2 ? 1 : 0)

slot4 =
     (showTF1 ? 1 : 0) +
     (showTF2 ? 1 : 0) +
     (showTF3 ? 1 : 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ANCHORING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
displayAnchor = close

priceAccurate(_price, _scale) =>
    displayAnchor + (_price - displayAnchor) * _scale

alignedPrice(_price, _o, _h, _l, _c, _scale) =>
    candleAnchor =
         alignBasis == "Midpoint"
              ? (_h + _l) * 0.5
              : _c

    displayAnchor + (_price - candleAnchor) * _scale

finalPrice(_price, _o, _h, _l, _c, _scale) =>
    displayMode == "Price Accurate"
         ? priceAccurate(_price, _scale)
         : alignedPrice(_price, _o, _h, _l, _c, _scale)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE READS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
candleRead(_o, _h, _l, _c) =>
    rng = math.max(_h - _l, syminfo.mintick)

    body      = math.abs(_c - _o)
    upperWick = _h - math.max(_o, _c)
    lowerWick = math.min(_o, _c) - _l

    bodyPct  = body / rng
    upperPct = upperWick / rng
    lowerPct = lowerWick / rng

    isBull = _c >= _o

    isDoji     = bodyPct <= 0.15
    strongBody = bodyPct >= 0.55

    upperReject =
         upperPct >= 0.40 and upperPct > lowerPct

    lowerReject =
         lowerPct >= 0.40 and lowerPct > upperPct

    isDoji
         ? "Doji"
         : upperReject
              ? "Upper\nRejection"
         : lowerReject
              ? "Lower\nRejection"
         : strongBody and isBull
              ? "Bullish\nExpansion"
         : strongBody and not isBull
              ? "Bearish\nExpansion"
         : isBull
              ? "Bullish"
         : "Bearish"

candleReadColor(_txt, _isBull) =>
    str.contains(_txt, "Doji")
         ? amberCol
         : str.contains(_txt, "Rejection")
              ? amberCol
         : _isBull
              ? bullCol
              : bearCol

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box b1 = box.new(0, close, 0, close)
var box b2 = box.new(0, close, 0, close)
var box b3 = box.new(0, close, 0, close)
var box b4 = box.new(0, close, 0, close)

var line w1 = line.new(0, close, 0, close)
var line w2 = line.new(0, close, 0, close)
var line w3 = line.new(0, close, 0, close)
var line w4 = line.new(0, close, 0, close)

var line g1 = line.new(0, close, 0, close)
var line g2 = line.new(0, close, 0, close)
var line g3 = line.new(0, close, 0, close)
var line g4 = line.new(0, close, 0, close)

var label lb1 = label.new(0, close, "")
var label lb2 = label.new(0, close, "")
var label lb3 = label.new(0, close, "")
var label lb4 = label.new(0, close, "")

var label rd1 = label.new(0, close, "")
var label rd2 = label.new(0, close, "")
var label rd3 = label.new(0, close, "")
var label rd4 = label.new(0, close, "")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
drawCandle(
     _enabled,
     _body,
     _wick,
     _ghost,
     _lbl,
     _readLbl,
     _o,
     _h,
     _l,
     _c,
     _slot,
     _tfText,
     _scale
) =>

    if _enabled

        centerX =
             bar_index + offsetX + gapX * _slot

        leftX  = centerX - bodyWidth
        rightX = centerX + bodyWidth

        so = finalPrice(_o, _o, _h, _l, _c, _scale)
        sh = finalPrice(_h, _o, _h, _l, _c, _scale)
        sl = finalPrice(_l, _o, _h, _l, _c, _scale)
        sc = finalPrice(_c, _o, _h, _l, _c, _scale)

        topBody = math.max(so, sc)
        botBody = math.min(so, sc)

        isBull = _c >= _o

        box.set_left(_body, leftX)
        box.set_right(_body, rightX)
        box.set_top(_body, topBody)
        box.set_bottom(_body, botBody)
        box.set_bgcolor(_body, isBull ? bullCol : bearCol)
        box.set_border_color(_body, isBull ? bullBorder : bearBorder)

        line.set_x1(_wick, centerX)
        line.set_x2(_wick, centerX)
        line.set_y1(_wick, sh)
        line.set_y2(_wick, sl)
        line.set_color(_wick, wickCol)
        line.set_width(_wick, wickWidth)

        showGhost =
             displayMode == "Hybrid" and showGhostMarkers

        line.set_x1(_ghost, leftX)
        line.set_x2(_ghost, rightX)
        line.set_y1(_ghost, _c)
        line.set_y2(_ghost, _c)
        line.set_color(_ghost, showGhost ? ghostCol : color.new(color.white, 100))
        line.set_width(_ghost, 1)

        label.set_x(_lbl, centerX)
        label.set_y(_lbl, sh + syminfo.mintick * 16)
        label.set_text(_lbl, showLabels ? tfLabel(_tfText) : "")
        label.set_textcolor(_lbl, labelTextCol)
        label.set_color(_lbl, showLabels ? labelBg : color.new(color.black, 100))
        label.set_style(_lbl, label.style_label_down)

        readTxt = candleRead(_o, _h, _l, _c)
        readCol = candleReadColor(readTxt, isBull)

        label.set_x(_readLbl, centerX)
        label.set_y(_readLbl, sl - syminfo.mintick * 6)
        label.set_text(_readLbl, showCandleReads ? readTxt : "")
        label.set_textcolor(_readLbl, readCol)
        label.set_color(_readLbl, color.new(color.black, 100))
        label.set_style(_readLbl, label.style_label_up)

    else
        box.set_bgcolor(_body, color.new(color.black, 100))
        line.set_color(_wick, color.new(color.black, 100))
        line.set_color(_ghost, color.new(color.black, 100))
        label.set_text(_lbl, "")
        label.set_text(_readLbl, "")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
drawCandle(showTF1, b1, w1, g1, lb1, rd1, o1, h1, l1, c1, slot1, tf1, scale5M)
drawCandle(showTF2, b2, w2, g2, lb2, rd2, o2, h2, l2, c2, slot2, tf2, scale15M)
drawCandle(showTF3, b3, w3, g3, lb3, rd3, o3, h3, l3, c3, slot3, tf3, scale1H)
drawCandle(showTF4, b4, w4, g4, lb4, rd4, o4, h4, l4, c4, slot4, tf4, scale4H)
````
