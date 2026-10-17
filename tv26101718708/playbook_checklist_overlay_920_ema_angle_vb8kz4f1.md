# PLAYBOOK CHECKLIST OVERLAY (9/20 EMA + Angle)

- url: https://www.tradingview.com/script/Vb8kZ4F1-PLAYBOOK-CHECKLIST-OVERLAY-9-20-EMA-Angle/
- type: indicator
- pine_id: PUB;01196eae589c4002b6d429c533d2f32a
- version: 1.0

## Description

PLAYBOOK CHECKLIST OVERLAY (9/20 EMA + Angle) is a clean rule-based trading assistant designed to help traders stay disciplined and avoid emotional entries.

This indicator combines:
• 9 EMA and 20 EMA trend alignment
• Trend angle strength analysis
• Pullback entry location validation
• Checklist confirmation table

The goal is simple:
Only take trades when your playbook conditions are fully aligned.

The indicator checks:
✔ EMA Trend Alignment
✔ Trend Strength / Angle
✔ Pullback Entry Zone
✔ Bar Close Confirmation

A visual checklist table helps traders quickly determine whether conditions are valid before entering a trade.

Perfect for:
• Scalping
• Intraday trading
• Futures trading
• Trend continuation setups
• Pullback trading
• Rule-based execution

How to use:
• Look for proper EMA alignment
• Wait for strong trend angle confirmation
• Enter near EMA pullback zones
• Avoid forcing trades when checklist conditions are not fully aligned

This tool is designed to reduce:
• FOMO
• Overtrading
• Chasing candles
• Emotional entries
• Random low-quality setups

Features:
✔ EMA trend detection
✔ ATR-normalized trend angle calculation
✔ Pullback zone validation
✔ Real-time checklist overlay
✔ Optional confirmation labels
✔ Cleaner trade discipline framework

Best used with:
• Market structure
• Support & Resistance
• Trendlines
• Volume confirmation
• VWAP
• Higher timeframe direction

Suggested Category:
Primary: Trend Analysis
Secondary: Moving Averages

Suggested Tags:
ema, trend, checklist, scalping, futures, intraday, pullback, price action, momentum, trading, discipline, trend following, strategy, nq, spx

If you find this indicator useful:
👍 Leave a Like
⭐ Add to Favorites
📢 Share with fellow traders and friends

Your support is greatly appreciated and helps inspire future tools and improvements for the trading community.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sunilnahata

//@version=5
indicator("PLAYBOOK CHECKLIST OVERLAY (9/20 EMA + Angle)", overlay=true, max_labels_count=500)

// === INPUTS
emaFastLen = input.int(9,  "EMA Fast", minval=1)
emaSlowLen = input.int(20, "EMA Slow", minval=1)
angleBars  = input.int(3,  "Slope Lookback Bars", minval=1)
atrLen     = input.int(14, "ATR Length", minval=1)
angleMin   = input.float(5.0, "Min Trend Angle (deg)", step=0.1)

showTable  = input.bool(true, "Show Checklist Table")
showLabel  = input.bool(false, "Show 'PLAYBOOK OK' Labels")
onlyOnClose = input.bool(true, "Signal Only On Bar Close")

// === EMAS
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// === SLOPE → ANGLE (ATR-normalized, scale-independent)
atr   = math.max(ta.atr(atrLen), syminfo.mintick)
slope = (emaFast - emaFast[angleBars]) / atr
angle = math.atan(slope) * 180 / math.pi

// === CONDITIONS
trendBull = emaFast > emaSlow
trendBear = emaFast < emaSlow
trendOK   = trendBull or trendBear

angleOK = math.abs(angle) >= angleMin

// "Location" = price is between EMAs (pullback zone) OR touching one of them
hi = math.max(emaFast, emaSlow)
lo = math.min(emaFast, emaSlow)
locationOK = (close <= hi and close >= lo) or (low <= hi and high >= lo)

// Optional: reduce repaint-like behavior by confirming at bar close
confirmed = onlyOnClose ? barstate.isconfirmed : true

tradeAllowed = confirmed and trendOK and angleOK and locationOK

// === PLOTS (optional but helpful)
plot(emaFast, "EMA Fast", linewidth=2)
plot(emaSlow, "EMA Slow", linewidth=2)

// === CHECKLIST TABLE
var table checklist = table.new(position.top_right, 2, 6, border_width=1)

f_cell(_row, _label, _ok) =>
    table.cell(checklist, 0, _row, _label, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(checklist, 1, _row, _ok ? "YES" : "NO",
      text_color=color.white,
      bgcolor=_ok ? color.new(color.green, 0) : color.new(color.red, 0))

if showTable and barstate.islast
    // Header
    table.cell(checklist, 0, 0, "CHECK",  text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(checklist, 1, 0, "STATUS", text_color=color.white, bgcolor=color.new(color.black, 0))

    f_cell(1, "EMA Alignment (9 vs 20)", trendOK)
    f_cell(2, "Trend Angle |deg| ≥ " + str.tostring(angleMin), angleOK)
    f_cell(3, "Entry Location (EMA Zone)", locationOK)

    // Direction row
    dirTxt = trendBull ? "BULL" : trendBear ? "BEAR" : "NONE"
    dirOk  = trendBull or trendBear
    table.cell(checklist, 0, 4, "Direction", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(checklist, 1, 4, dirTxt, text_color=color.white,
      bgcolor=dirOk ? color.new(color.blue, 0) : color.new(color.red, 0))

    // Final decision
    table.cell(checklist, 0, 5, "TRADE?", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(checklist, 1, 5, tradeAllowed ? "YES" : "NO",
      text_color=color.white,
      bgcolor=tradeAllowed ? color.new(color.green, 0) : color.new(color.red, 0))

// === OPTIONAL LABELS
if showLabel and tradeAllowed
    label.new(bar_index, high, "PLAYBOOK OK",
      style=label.style_label_down, color=color.new(color.green, 0), textcolor=color.white)

// === ALERT CONDITION
alertcondition(tradeAllowed, title="Playbook OK", message="PLAYBOOK OK: EMA aligned + angle strong + in EMA zone.")
````
