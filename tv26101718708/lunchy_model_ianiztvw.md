# Lunchy Model

- url: https://www.tradingview.com/script/IaNiZtVw-Lunchy-Model/
- type: indicator
- pine_id: PUB;a37b06603a0c4e879fe5c4cb4d53d0ab
- version: 1.0

## Description

**The 23 Lunchy Model — 12:35 Indicator for MNQ/NQ Futures**

The 23 Lunchy Model is a precision intraday indicator built around the 12:35 PM ET candle — the most algorithmically significant moment of the lunch session. The lunch hour is designed by the market to stop out chasers and run against whoever is in profit from the morning session. This indicator puts that information into execution form.

**How It Works**

The opening price of the 12:35 candle becomes your premium and discount anchor for the entire lunch session. Price above the 12:35 level signals a bearish bias — the algorithm is hunting longs. Price below signals a bullish bias — the algorithm is targeting shorts. From there, you wait for a false move (Judas) in the opposing direction of the morning session liquidity, watch for a Fair Value Gap to form on that move, and enter when the FVG becomes inverted.

**What The Indicator Plots**

🟡 12:35 open line — your premium/discount dividing line for the session

🕯 12:35 root candle highlight — customizable color to mark your anchor candle

▲▽ Bias icons — directional bias signal printed directly on the 12:35 candle close

🟥🟦 Background tint — red for premium zone, teal for discount zone throughout the lunch hour

📦 FVG detection — automatically detects Fair Value Gaps forming after 12:35 in the Judas move window

⚡ IFVG inversion signal — highlights when an FVG has been inverted with your custom entry icon

🟣 Q3 window box — shaded zone from 12:45 to 13:08, the highest probability inversion window

**Key Features**

- Fully customizable colors, icon sizes, and emoji characters for all signals
- Separate settings for bullish and bearish FVG colors
- Adjustable FVG lookback window
- Premium and discount labels with toggle
- Built-in alerts for the 12:35 open and every IFVG inversion signal
- Designed specifically for 1-minute MNQ and NQ Futures charts

**How To Use It**

1. Set your chart to MNQ1! or NQ1! on the 1-minute timeframe
2. At 12:35 PM ET, note the opening price — this becomes your anchor
3. Identify where the morning session generated liquidity (equal highs/lows, session extremes)
4. Wait for a Judas move into premium or discount — look for extra confluences (liquidity sweeps, imbalances, key time levels)
5. When an FVG forms on the Judas and the ⚡ IFVG signal fires, that is your entry
6. Anchor your stop to the previous 15-minute high or low
7. Prioritize setups where the inversion occurs inside the purple Q3 box (12:45–13:08)

**Risk Management Rules**

- Treat Lunchy as a pullback trade, not a full reversal
- Stop out 3 losses in one day and walk away — you are in time distortion
- Always anchor risk to the previous 15-minute structure
- Never over-leverage — this is a precision setup, not a home run trade

**Recommended Settings**

- Timeframe: 1 minute
- Instrument: MNQ1! / NQ1! (also works on ES, MES, SPY, QQQ)
- Session: New York — 12:00 PM to 1:15 PM ET only

*This indicator is a visual tool to assist with trade identification. It does not constitute financial advice. Always manage your own risk.*

## Source Code

````pine
//@version=5
indicator("Lunchy — 12:35 Model", overlay=true, max_boxes_count=50, max_lines_count=100, max_labels_count=100)

var g_main   = "12:35 Settings"
var g_fvg    = "FVG Settings"
var g_q3     = "Q3 Window"
var g_candle = "12:35 Candle Color"
var g_icons  = "Confirmation Icons"
var g_alerts = "Alerts"

show1235Line   = input.bool(true,  "Show 12:35 Open Line",           group=g_main)
lineExtend     = input.int(120,    "Extend Line (bars)",              group=g_main, minval=10, maxval=500)
showPDLabel    = input.bool(true,  "Show Premium/Discount Labels",    group=g_main)
show1235Candle = input.bool(true,  "Highlight 12:35 Root Candle",     group=g_main)
lineColor      = input.color(color.new(color.yellow, 0), "12:35 Line Color", group=g_main)

color1235Bull   = input.color(color.new(color.yellow, 0),  "12:35 Bullish Candle Body",  group=g_candle)
color1235Bear   = input.color(color.new(color.orange, 0),  "12:35 Bearish Candle Body",  group=g_candle)
color1235Wick   = input.color(color.new(color.yellow, 30), "12:35 Wick Color",           group=g_candle)
color1235Border = input.color(color.new(color.yellow, 0),  "12:35 Candle Border",        group=g_candle)

showQ3Box  = input.bool(true, "Show Q3 Window Box",   group=g_q3)
q3Color    = input.color(color.new(color.purple, 80), "Q3 Box Color", group=g_q3)
showQ3Tag  = input.bool(true, "Show Q3 Tag Label",    group=g_q3)
q3TagColor = input.color(color.new(color.purple, 0),  "Q3 Tag Color", group=g_q3)

showFVG       = input.bool(true,  "Show FVGs (Judas Zone)",           group=g_fvg)
fvgLookback   = input.int(30,     "FVG Lookback (bars after 12:35)",  group=g_fvg, minval=5, maxval=200)
bullFVGColor  = input.color(color.new(color.teal, 75),   "Bullish FVG Color",  group=g_fvg)
bearFVGColor  = input.color(color.new(color.red,  75),   "Bearish FVG Color",  group=g_fvg)
showInverted  = input.bool(true,  "Highlight Inverted FVGs",          group=g_fvg)
invertedColor = input.color(color.new(color.orange, 60), "Inverted FVG Color", group=g_fvg)
ifvgTextColor = input.color(color.new(color.orange, 0),  "⚡ IFVG Text Color", group=g_fvg)

useCharIcons      = input.bool(true,  "Use character based confirmation icons on the chart", group=g_icons)
confirmLongIcon   = input.string("🚀", "Confirmation long icon",        group=g_icons)
earlyConfirmLong  = input.string("▲",  "Early confirmation long icon",  group=g_icons)
confirmShortIcon  = input.string("🚨", "Confirmation short icon",        group=g_icons)
earlyConfirmShort = input.string("▽",  "Early confirmation short icon", group=g_icons)
iconBullBg        = input.color(color.new(color.teal, 10), "Long Icon Background",  group=g_icons)
iconBearBg        = input.color(color.new(color.red,  10), "Short Icon Background", group=g_icons)
iconBiasBullBg    = input.color(color.new(color.teal, 20), "Bias Long Background",  group=g_icons)
iconBiasBearBg    = input.color(color.new(color.red,  20), "Bias Short Background", group=g_icons)
iconSize          = input.string("Normal", "Icon Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_icons)

alertOnInvert = input.bool(true, "Alert on FVG Inversion", group=g_alerts)
alertOn1235   = input.bool(true, "Alert on 12:35 Open",    group=g_alerts)

// ─── SIZE HELPER ───────────────────────────────────────────
f_iconSize() =>
    iconSize == "Tiny"   ? size.tiny   :
     iconSize == "Small"  ? size.small  :
     iconSize == "Large"  ? size.large  :
     iconSize == "Huge"   ? size.huge   : size.normal

f_is1235() => hour(time, "America/New_York") == 12 and minute(time, "America/New_York") == 35

f_isLunch() => hour(time, "America/New_York") == 12

f_isQ3() => (hour(time, "America/New_York") == 12 and minute(time, "America/New_York") >= 45) or (hour(time, "America/New_York") == 13 and minute(time, "America/New_York") <= 8)

var float lunchy_open  = na
var int   lunchy_bar   = na
var line  lunchy_line  = na
var label premium_lbl  = na
var label discount_lbl = na
var box   q3_box       = na
var int   q3_start_bar = na
var float q3_high      = na
var float q3_low       = na
var label q3_tag_lbl   = na

var box[]   fvg_boxes = array.new_box()
var bool[]  fvg_bull  = array.new_bool()
var bool[]  fvg_inv   = array.new_bool()
var float[] fvg_top   = array.new_float()
var float[] fvg_bot   = array.new_float()

if f_is1235() and barstate.isconfirmed
    lunchy_open := open
    lunchy_bar  := bar_index
    if not na(lunchy_line)
        line.delete(lunchy_line)
    lunchy_line := line.new(x1=bar_index, y1=lunchy_open, x2=bar_index + lineExtend, y2=lunchy_open, color=lineColor, width=2, style=line.style_dashed, extend=extend.none)
    if not na(premium_lbl)
        label.delete(premium_lbl)
    if showPDLabel
        premium_lbl := label.new(x=bar_index + 2, y=lunchy_open, text="▲ PREMIUM  Short Bias", color=color.new(color.red, 85), textcolor=color.red, style=label.style_label_right, size=size.small)
    if not na(discount_lbl)
        label.delete(discount_lbl)
    if showPDLabel
        discount_lbl := label.new(x=bar_index + 2, y=lunchy_open, text="▼ DISCOUNT  Long Bias", color=color.new(color.teal, 85), textcolor=color.teal, style=label.style_label_right, size=size.small, yloc=yloc.belowbar)
    if alertOn1235
        alert("Lunchy: 12:35 candle opened at " + str.tostring(lunchy_open), alert.freq_once_per_bar)

is1235Bar    = f_is1235()
candleColor  = is1235Bar and show1235Candle ? (close >= open ? color1235Bull : color1235Bear) : na
wickColor    = is1235Bar and show1235Candle ? color1235Wick   : na
borderColor  = is1235Bar and show1235Candle ? color1235Border : na

plotcandle(open, high, low, close, color=candleColor, wickcolor=wickColor, bordercolor=borderColor, title="12:35 Root Candle")

if showQ3Box
    if f_isQ3()
        if na(q3_start_bar)
            q3_start_bar := bar_index
            q3_high      := high
            q3_low       := low
            if showQ3Tag
                if not na(q3_tag_lbl)
                    label.delete(q3_tag_lbl)
                q3_tag_lbl := label.new(x=bar_index, y=high, text="Q3", color=q3TagColor, textcolor=color.white, style=label.style_label_down, size=size.normal)
        else
            q3_high := math.max(q3_high, high)
            q3_low  := math.min(q3_low, low)
        if not na(q3_box)
            box.delete(q3_box)
        q3_box := box.new(left=q3_start_bar, top=q3_high, right=bar_index + 1, bottom=q3_low, border_color=color.new(color.purple, 40), border_width=1, bgcolor=q3Color)
    else
        if not na(q3_start_bar) and hour(time, "America/New_York") == 13 and minute(time, "America/New_York") == 9
            q3_start_bar := na
            q3_high      := na
            q3_low       := na

isAfter = not na(lunchy_bar) and bar_index > lunchy_bar and bar_index <= lunchy_bar + fvgLookback

bullFVG = isAfter and high[2] < low[0]
bearFVG = isAfter and low[2]  > high[0]

if showFVG and bullFVG and barstate.isconfirmed
    b = box.new(left=bar_index - 1, top=low[0], right=bar_index + fvgLookback, bottom=high[2], border_color=bullFVGColor, border_width=1, bgcolor=bullFVGColor)
    array.push(fvg_boxes, b)
    array.push(fvg_bull,  true)
    array.push(fvg_inv,   false)
    array.push(fvg_top,   low[0])
    array.push(fvg_bot,   high[2])

if showFVG and bearFVG and barstate.isconfirmed
    b = box.new(left=bar_index - 1, top=low[2], right=bar_index + fvgLookback, bottom=high[0], border_color=bearFVGColor, border_width=1, bgcolor=bearFVGColor)
    array.push(fvg_boxes, b)
    array.push(fvg_bull,  false)
    array.push(fvg_inv,   false)
    array.push(fvg_top,   low[2])
    array.push(fvg_bot,   high[0])

if showFVG and showInverted and array.size(fvg_boxes) > 0
    for i = 0 to array.size(fvg_boxes) - 1
        if not array.get(fvg_inv, i)
            isBull   = array.get(fvg_bull, i)
            fTop     = array.get(fvg_top, i)
            fBot     = array.get(fvg_bot, i)
            midpoint = (fTop + fBot) / 2.0
            inverted = isBull ? close < midpoint : close > midpoint
            if inverted
                array.set(fvg_inv, i, true)
                b = array.get(fvg_boxes, i)
                box.set_bgcolor(b, invertedColor)
                box.set_border_color(b, color.new(color.orange, 20))
                box.set_right(b, bar_index + 10)
                icon      = useCharIcons ? (isBull ? confirmShortIcon : confirmLongIcon) : (isBull ? "SHORT" : "LONG")
                iconBg    = isBull ? iconBearBg : iconBullBg
                lStyle    = isBull ? label.style_label_down : label.style_label_up
                yPos      = isBull ? fTop : fBot
                label.new(x=bar_index, y=yPos, text=icon,      color=iconBg,                      textcolor=color.white,  style=lStyle,                                                             size=f_iconSize())
                label.new(x=bar_index, y=yPos, text="⚡ IFVG", color=color.new(color.black, 100), textcolor=ifvgTextColor, style=isBull ? label.style_label_upper_left : label.style_label_lower_left, size=size.small)
                if alertOnInvert
                    alert("Lunchy IFVG → " + icon + (isBull ? " SHORT" : " LONG") + " entry at " + str.tostring(close), alert.freq_once_per_bar)

if f_is1235() and barstate.isconfirmed and useCharIcons
    closeAbove = close > open
    biasIcon   = closeAbove ? earlyConfirmLong : earlyConfirmShort
    biasBg     = closeAbove ? iconBiasBullBg : iconBiasBearBg
    biasStyle  = closeAbove ? label.style_label_up : label.style_label_down
    label.new(x=bar_index, y=closeAbove ? low : high, text=biasIcon + "  12:35 Bias", color=biasBg, textcolor=color.white, style=biasStyle, size=f_iconSize())

aboveLine = not na(lunchy_open) and close > lunchy_open and f_isLunch()
belowLine = not na(lunchy_open) and close < lunchy_open and f_isLunch()
bgcolor(aboveLine ? color.new(color.red,  95) : na, title="Premium Zone Tint")
bgcolor(belowLine ? color.new(color.teal, 95) : na, title="Discount Zone Tint")

plot(lunchy_open, "12:35 Open Level", color=color.new(color.yellow, 60), linewidth=1, style=plot.style_circles)
````
