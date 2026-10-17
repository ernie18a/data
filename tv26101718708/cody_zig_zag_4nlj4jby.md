# Cody Zig Zag

- url: https://www.tradingview.com/script/4NLj4jBy-Cody-Zig-Zag/
- type: indicator
- pine_id: PUB;75a8674bc01d4b808ac66e3731255c12
- version: 1.0

## Description

Cody Zig Zag – MT4-Style Zig Zag for TradingView
The ZigZag indicator that actually works like the classic MT4 version!

🔍 Overview
Cody Zig Zag is a powerful, fully customizable ZigZag indicator that replicates the exact behavior of the popular MetaTrader 4 (MT4) ZigZag. Unlike TradingView's built-in ZigZag, this version behaves identically to what MT4 traders know and love – making it perfect for Elliott Wave traders, support/resistance hunters, and breakout specialists.

⚙️ Input Parameters (Just like MT4!)
Parameter	Default	Description
Depth	12	Minimum number of bars between swing points
Deviation	5	Minimum price movement (in ticks) to form a new swing
Backstep	2	Minimum bars between swing points of the same type
Line Thickness	2	Visual weight of the ZigZag line
Bull Color	Lime	Color for upward swings
Bear Color	Red	Color for downward swings
Repaint Levels	True	Enables real-time repainting (MT4 style)
🎯 Key Features
✅ TRUE MT4 BEHAVIOR – Exact replication of MetaTrader 4's classic ZigZag algorithm

✅ INTELLIGENT LABELS – Automatically identifies HH (Higher High), LH (Lower High), LL (Lower Low), and HL (Higher Low)

✅ REAL-TIME UPDATES – Optional repainting mode for live market analysis

✅ DIRECTION BACKGROUND – Visual market direction indicator (Green = Bullish, Red = Bearish)

✅ ALERT CONDITIONS – Get notified when the ZigZag direction changes

💡 How to Use
For Beginners:
Just add the indicator to your chart – the default settings (12,5,2) work perfectly for most timeframes!

For Advanced Traders:

Lower Depth (5-8) → More swings, more detail (scalping/1min charts)

Higher Depth (12-20) → Cleaner swings, fewer signals (swing trading/4H+ charts)

Adjust Deviation → Control minimum swing size based on volatility

🎨 Visual Guide
Lime Line = Price moving UP

Red Line = Price moving DOWN

HH Label = Higher High (uptrend continuation)

LH Label = Lower High (potential reversal down)

LL Label = Lower Low (downtrend continuation)

HL Label = Higher Low (potential reversal up)

📊 Best For
📌 Elliott Wave Counting – Perfect for identifying wave structure

📌 Support & Resistance – Automatically marks swing highs/lows

📌 Breakout Trading – Visualize clear break levels

📌 Divergence Trading – Spot hidden/regular divergences with RSI/MACD

📌 Harmonic Patterns – Identify XABCD patterns easily

⏰ Alert Conditions
Direction Changed – Triggered whenever the ZigZag changes direction

Bullish Direction – When price starts moving up

Bearish Direction – When price starts moving down

🔧 Troubleshooting
Q: Why does the indicator "repaint"?
A: That's how MT4 ZigZag works! Repainting shows the most accurate real-time swing points. Turn OFF "Repaint Levels" if you prefer traditional non-repainting behavior.

Q: What timeframes work best?
A: Works on ALL timeframes! Lower Depth values (5-8) for lower timeframes, higher Depth (12-20) for higher timeframes.

Q: Can I use this for automated strategies?
A: Yes! The alert conditions can trigger tradingview alerts for manual or webhook-based trading.

🙏 Credits
Original MT4 ZigZag logic ported to Pine Script™ v6 by lucemanb
Renamed and optimized as Cody Zig Zag

📝 Keywords
ZigZag MT4 Elliott Wave Swing High Swing Low Support Resistance Divergence Breakout Harmonic Patterns Price Action Trend Reversal Higher High Lower Low Technical Analysis TradingView Indicator Free Indicator

⭐ Support & Feedback
If you find this indicator useful:

Like & Follow for more tools

Leave a review with your suggestions

Share with your trading community

Happy Trading! 🚀

Disclaimer: This indicator is for educational and analytical purposes. Past performance does not guarantee future results. Always practice proper risk management.

## Source Code

````pine
//@version=6
//@author=lucemanb

//
//       THIS CODE IS BASED FROM THE MT4 ZIGZAG INDICATOR
//       THE ZIGZAG SETTINGS FOR THE MAIN ONE ON TRADINGVIEW DO NOT WORK THE SAME AS MT4
//       I HOPE U LOVE IT
//

// Ping me for donations, Collaborations or Support


////////
// Seek Menu
indicator("Cody Zig Zag", "Cody Zig Zag", true, format.price, max_labels_count=51, max_lines_count=50)


////////
// Fetch Ingredients 
// [
Depth       = input.int(12, "Depth", minval=1, step=1)
Deviation   = input.int(5, "Deviation", minval=1, step=1)
Backstep    = input.int(2, "Backstep", minval=2, step=1)
line_thick  = input.int(2, "Line Thickness", minval=1, maxval=4)
upcolor     = input.color(color.lime, "Bull Color")
dncolor     = input.color(color.red, "Bear Color")
repaint     = input.bool(true, "Repaint Levels")
// ]


//////// 
// Bake
// [
var last_h = 1
var last_l = 1
var lw = 1
var hg = 1

lw := lw + 1
hg := hg + 1

p_lw = -ta.lowestbars(Depth)
p_hg = -ta.highestbars(Depth)

lowing = lw == p_lw or low - low[p_lw] > Deviation * syminfo.mintick
highing = hg == p_hg or high[p_hg] - high > Deviation * syminfo.mintick

lh = ta.barssince(not highing[1])
ll = ta.barssince(not lowing[1])

down = ta.barssince(not (lh > ll)) >= Backstep
lower = low[lw] > low[p_lw]
higher = high[hg] < high[p_hg]

if lw != p_lw and (not down[1] or lower)
    lw := p_lw < hg ? p_lw : 0
if hg != p_hg and (down[1] or higher)
    hg := p_hg < lw ? p_hg : 0

line zz = na
label point = na
x1 = down ? lw : hg
y1 = down ? low[lw] : high[hg]

if down == down[1]
    if repaint
        label.delete(point[1])
        line.delete(zz[1])
    down
if down != down[1]
    if down
        last_h := hg
    else
        last_l := lw
    if not repaint
        nx = down ? last_h : last_l
        zz := line.new(bar_index - nx, down ? high[nx] : low[nx], bar_index - (down ? last_l : last_h), down ? low[last_l] : high[last_h], width=line_thick, color=down ? upcolor : dncolor)
        point := label.new(bar_index - nx, down ? high[nx] : low[nx], down ? (high[nx] > high[last_h[1]] ? "HH" : "LH") : (low[nx] < low[last_l[1]] ? "LL" : "HL"), style=down ? label.style_label_down : label.style_label_up, size=size.tiny, color=down ? dncolor : upcolor, textcolor=color.black, tooltip=down ? (high[nx] > high[last_h[1]] ? "Higher High" : "Lower High") : (low[nx] < low[last_l[1]] ? "Lower Low" : "Higher Low"))
    down
if repaint
    zz := line.new(bar_index - (down ? last_h : last_l), down ? high[last_h] : low[last_l], bar_index - x1, y1, width=line_thick, color=down ? dncolor : upcolor)
    point := label.new(bar_index - x1, y1, down ? (low[x1] < low[last_l] ? "LL" : "HL") : (high[x1] > high[last_h] ? "HH" : "LH"), style=down ? label.style_label_up : label.style_label_down, size=size.tiny, color=down ? upcolor : dncolor, textcolor=color.black, tooltip=down ? (low[x1] < low[last_l] ? "Lower Low" : "Higher Low") : (high[x1] > high[last_h] ? "Higher High" : "Lower High"))
// ]


////////
// Let it Cool And Serve
bear = down
bgcolor(bear ? color.red : color.lime, title="Scanning Direction")


////////
// Declare Meal Was Sweet By Force
alertcondition(bear != bear[1], "Direction Changed", 'Zigzag on {{ticker}} direction changed at {{time}}')
alertcondition(bear != bear[1] and not bear, "Bullish Direction", 'Zigzag on {{ticker}} bullish direction at {{time}}')
alertcondition(bear != bear[1] and bear, "Bearish Direction", 'Zigzag on {{ticker}} bearish direction at {{time}}')
````
