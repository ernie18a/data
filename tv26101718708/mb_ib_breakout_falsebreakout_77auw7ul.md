# MB & IB Breakout + falseBreakOut

- url: https://www.tradingview.com/script/77AuW7Ul-MB-IB-Breakout-falseBreakOut/
- type: indicator
- pine_id: PUB;8bf529f2c2334d88813f30fa488505d7
- version: 1.0

## Description

מעולה! הנה תיאור מקצועי ומקיף באנגלית, שתוכל להעתיק ולהדביק ישירות בחלון התיאור של האינדיקטור ב-TradingView (כשאתה שומר או מפרסם אותו), או פשוט לשלוח לתלמידים שלך:

Mother Bar & Inside Bar (MB & IB) Pro Breakout
Overview
This advanced indicator is designed for Price Action traders to automatically identify, track, and trade Mother Bar (MB) and Inside Bar (IB) formations. It visually highlights periods of market consolidation and accurately alerts you to potential expansions (Breakouts) or market traps (False Breakouts).

How It Works
When a valid MB and IB pattern is detected, the indicator draws a dynamic box around the Mother Bar's range. If multiple consecutive Inside Bars form (a tightening consolidation), the script smartly adapts and tracks the high and low of the most recent (tightest) Inside Bar to measure breakouts, while keeping the main Mother Bar box intact until the entire pattern is invalidated.

Key Features:

Smart Pattern Detection: Accurately identifies strict Inside Bars (High is strictly lower than the previous high, Low is strictly higher than the previous low).

Visual Range Box: Draws a dashed, customizable box representing the Mother Bar's territory. The box continues to project to the right until the original MB high or low is breached.

True Breakout (BO) Alerts: Detects when a candle securely closes outside the most recent IB range. Visualized on the chart with Green (Up) or Red (Down) triangles.

False Breakout (FBO) Alerts: Identifies "liquidity sweeps" or traps where the price spikes outside the IB range but closes back inside. Visualized on the chart with an Orange 'X'.

Backtesting Lookback Filter: Includes a customizable Lookback period (default: 500 bars) to keep your historical charts clean and optimize performance.

Fully Customizable UI: Easily toggle alerts, adjust box colors, and enable/disable visual chart markers directly from the settings panel.

How to Use:

Trend Continuation: Look for True Breakouts (Triangles) in the direction of the prevailing trend for momentum entries.

Reversal / Trap Trading: Look for False Breakouts ('X' marks) at key support/resistance levels to fade the breakout and trade the reversal back into the range.

Note: This indicator works seamlessly across all timeframes and assets.

## Source Code

````pine
//@version=5
indicator("MB & IB Breakout + falseBreakOut", overlay=true, max_boxes_count=500)

// ==========================================
// הגדרות משתמש (Inputs)
// ==========================================
grp_bt = "הגדרות בקטסט וטווח"
lookback_bars = input.int(500, title="כמות נרות לאחור (Lookback)", group=grp_bt, minval=10)

grp_alerts = "הגדרות התראות"
enable_bo = input.bool(true, title="התראת פריצה (Breakout)", group=grp_alerts)
enable_fbo = input.bool(true, title="התראת פריצת שווא (False Breakout)", group=grp_alerts)

grp_style = "הגדרות עיצוב וסימונים"
box_bg_color = input.color(color.new(color.blue, 90), title="צבע רקע לקופסא", group=grp_style)
box_border_color = input.color(color.blue, title="צבע מסגרת מקווקות", group=grp_style)
show_bo_marks = input.bool(true, title="הצג חצי פריצה על הגרף", group=grp_style)
show_fbo_marks = input.bool(true, title="הצג סימון פריצת שווא (X) על הגרף", group=grp_style)

// ==========================================
// משתני מערכת וסינון Lookback
// ==========================================
var float mb_high = na
var float mb_low = na
var float last_ib_high = na
var float last_ib_low = na
var bool in_pattern = false
var box mb_box = na

in_lookback = (last_bar_index - bar_index) <= lookback_bars
is_new_ib = high < high[1] and low > low[1]

bool bo_up = false
bool bo_dn = false
bool fbo_up = false
bool fbo_dn = false

// ==========================================
// לוגיקת המעקב והפריצות (פועלת רק בתוך ה-Lookback)
// ==========================================
if in_pattern and in_lookback
    // 1. בדיקת פריצות ביחס ל-IB האחרון שנרשם במערכת
    if close > last_ib_high
        bo_up := true
    if close < last_ib_low
        bo_dn := true
        
    // פריצת שווא
    if high > last_ib_high and close <= last_ib_high and close >= last_ib_low
        fbo_up := true
    if low < last_ib_low and close >= last_ib_low and close <= last_ib_high
        fbo_dn := true

    // 2. קטיעת הקופסא - האם נר האם (MB) נפרץ לחלוטין?
    if high > mb_high or low < mb_low
        in_pattern := false
        box.set_right(mb_box, bar_index)
    else
        box.set_right(mb_box, bar_index)
        
        if high < last_ib_high and low > last_ib_low
            last_ib_high := high
            last_ib_low := low

// ==========================================
// זיהוי תחילת תבנית חדשה
// ==========================================
if not in_pattern and is_new_ib and in_lookback
    in_pattern := true
    mb_high := high[1]
    mb_low := low[1]
    last_ib_high := high
    last_ib_low := low
    
    mb_box := box.new(left=bar_index[1], top=mb_high, right=bar_index, bottom=mb_low, border_color=box_border_color, border_style=line.style_dashed, border_width=2, bgcolor=box_bg_color, text="MB Range", text_halign=text.align_right, text_valign=text.align_bottom, text_size=size.small)

if not in_lookback
    in_pattern := false

// ==========================================
// תצוגה ויזואלית על הגרף (Shapes)
// ==========================================
plotshape(bo_up and show_bo_marks, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Breakout Up")
plotshape(bo_dn and show_bo_marks, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Breakout Down")
plotshape(fbo_up and show_fbo_marks, style=shape.xcross, location=location.abovebar, color=color.orange, size=size.small, title="False Breakout Up")
plotshape(fbo_dn and show_fbo_marks, style=shape.xcross, location=location.belowbar, color=color.orange, size=size.small, title="False Breakout Down")

// ==========================================
// ניהול התראות (Alerts System)
// ==========================================
is_breakout = bo_up or bo_dn
is_false_breakout = fbo_up or fbo_dn

if is_breakout and enable_bo
    alert("Breakout! Close outside the last IB range.", alert.freq_once_per_bar_close)

if is_false_breakout and enable_fbo
    alert("False Breakout! Price spiked outside the last IB but closed inside.", alert.freq_once_per_bar_close)

alertcondition(is_breakout and enable_bo, title="התראת פריצת IB", message="זוהתה פריצה (סגירה) של ה-Inside Bar האחרון!")
alertcondition(is_false_breakout and enable_fbo, title="התראת פריצת שווא ב-IB", message="זוהתה פריצת שווא - המחיר סגר בחזרה בתוך טווח ה-Inside Bar!")
````
