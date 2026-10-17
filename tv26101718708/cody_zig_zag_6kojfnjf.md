# Cody Zig Zag

- url: https://www.tradingview.com/script/6KOJFNjF-Cody-Zig-Zag/
- type: indicator
- pine_id: PUB;e5aff2ee6c834a58893509996e99f288
- version: 1.0

## Description

Cody Zig Zag Indicator - Complete Explanation
This is a Zig Zag indicator that replicates the MetaTrader 4 (MT4) version, which works differently than TradingView's built-in Zig Zag. Here's what it does:

🎯 What is a Zig Zag Indicator?
It filters out minor price movements to show only significant swing highs and swing lows, helping you identify trends and chart patterns (head & shoulders, double tops/bottoms, etc.).

⚙️ User Settings (Inputs)
Setting	Default	What It Does
Depth	6	Lookback period to find local highs/lows
Deviation	5	Minimum price change (in ticks) to form a new swing point
Backstep	2	Minimum bars between swing points
Line Thickness	2	Zig Zag line width
Bull Color	Lime	Color for upward moves
Bear Color	Red	Color for downward moves
Repaint Levels	true	If ON, lines/labels adjust real-time; if OFF, they lock on close
🔍 How It Works (The "Bake" Section)
Step 1: Find Potential Pivot Points
p_lw = Most recent low within Depth bars

p_hg = Most recent high within Depth bars

Checks if price moved enough (Deviation * tick size) to qualify

Step 2: Determine Direction
down = Boolean (true = bearish/downward leg, false = bullish/upward leg)

Tracks whether we're connecting a high→low (down) or low→high (up)

Step 3: Draw Zig Zag Lines
Connects alternating swing highs and swing lows

Labels each point as:

HH = Higher High

LH = Lower High

LL = Lower Low

HL = Higher Low

🏷️ Labels Explained
When price makes a new swing point, you'll see:

HH (Higher High) - Bullish continuation signal

LH (Lower High) - Bearish reversal signal

LL (Lower Low) - Bearish continuation signal

HL (Higher Low) - Bullish reversal signal

📊 Visual Features
Colored Zig Zag lines: Green for up-legs, Red for down-legs

Background color: Green during bullish legs, Red during bearish legs (90% transparent)

Labels: Tiny triangles pointing up/down with text

⚠️ Repaint Behavior (Important!)
Repaint = ON (default)	Repaint = OFF
Lines/labels update in real-time	Locks on bar close
Can "repaint" history	More reliable for backtesting
Good for real-time trading	No historical repainting
Warning: Zig Zag indicators naturally repaint because they need future bars to confirm pivot points. The repaint option controls HOW they repaint.

🚨 Alerts
This script triggers alerts when:

Direction Changed - Zig Zag switches from up to down or down to up

Bullish Direction - Switches from down to up

Bearish Direction - Switches from up to down

📈 How to Use
Identify Trend: Upward Zig Zag = Uptrend; Downward = Downtrend

Find Patterns: Look for HH/HL patterns (bullish) or LH/LL patterns (bearish)

Divergence: Compare Zig Zag swings with oscillator indicators

Support/Resistance: Swing points act as natural S/R levels

⚡ Quick Summary
This indicator draws a line connecting significant price swings, ignoring small noise. It's great for:

Visualizing trend structure

Identifying chart patterns

Finding entry/exit levels

Spotting trend reversals

## Source Code

````pine
//@version=5
//@author=lucemanb

//
//       THIS CODE IS BASED FROM THE MT4 ZIGZAG INDICATOR
//       THE ZIGZAG SETTINGS FOR THE MAIN ONE ON TRADINGVIEW DO NOT WORK THE SAME AS MT4
//       I HOPE U LOVE IT
//

// Ping me for donations, Collaborations or Support


////////
// Seek Menu
indicator('Cody Zig Zag', 'Cody Zig Zag', true, format.price, max_labels_count=51, max_lines_count=50)


////////
// Fetch Ingredients 
// [
Depth = input.int(6, 'Depth', minval=1, step=1)
Deviation = input.int(5, 'Deviation', minval=1, step=1)
Backstep = input.int(2, 'Backstep', minval=2, step=1)
line_thick = input.int(2, 'Line Thickness', minval=1, maxval=4)
upcolor = input(color.lime, 'Bull Color')
dncolor = input(color.red, 'Bear Color')
repaint = input(true, 'Repaint Levels')
// ]


//////// 
// Bake
// [
var last_h = 1
last_h += 1
var last_l = 1
last_l += 1
var lw = 1
var hg = 1
lw += 1
hg += 1
p_lw = -ta.lowestbars(Depth)
p_hg = -ta.highestbars(Depth)
lowing = lw == p_lw or low - low[p_lw] > Deviation * syminfo.mintick
highing = hg == p_hg or high[p_hg] - high > Deviation * syminfo.mintick
lh = ta.barssince(not highing[1])
ll = ta.barssince(not lowing[1])
down = ta.barssince(not(lh > ll)) >= Backstep
lower = low[lw] > low[p_lw]
higher = high[hg] < high[p_hg]
if lw != p_lw and (not down[1] or lower)
    lw := p_lw < hg ? p_lw : 0
    lw
if hg != p_hg and (down[1] or higher)
    hg := p_hg < lw ? p_hg : 0
    hg

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
        last_h
    else
        last_l := lw
        last_l
    if not repaint
        nx = down ? last_h : last_l
        zz := line.new(bar_index - nx, down ? high[nx] : low[nx], bar_index - (down ? last_l : last_h), down ? low[last_l] : high[last_h], width=line_thick, color=down ? upcolor : dncolor)
        point := label.new(bar_index - nx, down ? high[nx] : low[nx], down ? high[nx] > high[last_h[1]] ? 'HH' : 'LH' : low[nx] < low[last_l[1]] ? 'LL' : 'HL', style=down ? label.style_label_down : label.style_label_up, size=size.tiny, color=down ? dncolor : upcolor, textcolor=color.black, tooltip=down ? high[nx] > high[last_h[1]] ? 'Higher High' : 'Lower High' : low[nx] < low[last_l[1]] ? 'Lower Low' : 'Higher Low')
        point
    down
if repaint
    zz := line.new(bar_index - (down ? last_h : last_l), down ? high[last_h] : low[last_l], bar_index - x1, y1, width=line_thick, color=down ? dncolor : upcolor)
    point := label.new(bar_index - x1, y1, down ? low[x1] < low[last_l] ? 'LL' : 'HL' : high[x1] > high[last_h] ? 'HH' : 'LH', style=down ? label.style_label_up : label.style_label_down, size=size.tiny, color=down ? upcolor : dncolor, textcolor=color.black, tooltip=down ? low[x1] < low[last_l] ? 'Lower Low' : 'Higher Low' : high[x1] > high[last_h] ? 'Higher High' : 'Lower High')
    point
// ]


////////
// Let it Cool And Serve
bear = down
bgcolor(bear ? color.red : color.lime, title='Scanning Direction', transp=90)


////////
// Declare Meal Was Sweet By Force
alertcondition(bear != bear[1], 'Direction Changed', 'Zigzag on {{ticker}} direction changed at {{time}}')
alertcondition(bear != bear[1] and not bear, 'Bullish Direction', 'Zigzag on {{ticker}} bullish direction at {{time}}')
alertcondition(bear != bear[1] and bear, 'Bearish Direction', 'Zigzag on {{ticker}} bearish direction at {{time}}')
````
