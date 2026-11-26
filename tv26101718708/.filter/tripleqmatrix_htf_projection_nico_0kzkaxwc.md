# TripleQMatrix: HTF Projection Nico

- url: https://www.tradingview.com/script/0KzKaXwC-TripleQMatrix-HTF-Projection-Nico/
- type: indicator
- pine_id: PUB;0284a55ed8c246e494039c3be935a80a
- version: 1.0

## Description

The Higher Timeframe (HTF) Projection is a professional trading tool designed to solve the "tunnel vision" that often occurs when scalping on lower timeframes like the 30-second or 15-minute charts.

 What is it?
It takes a higher timeframe candle (like a 15-minute bar) and projects its data—Open, High, Low, and Close—directly onto your lower-timeframe chart. It essentially gives you a "ghost" of the larger market context while you are focused on micro-scalping.

How to use it effectively
Using this tool correctly is all about **Contextual Alignment**:
 1. Regime Filtering: Use the projected candle's color (or the "Chop/Runner" status) to determine your market bias.
   If the HTF box is Gray (Chop): Avoid directional scalping. The market is in equilibrium, and institutional participation is too low for a sustained run.
   If the HTF box is Green/Red (Runner): This confirms the current 15-minute trend. Look to only take scalp trades that align with this direction (e.g., if the box is Red/Bearish, prioritize short-selling opportunities).

 2. Projection as a "Magnet": Large institutions often trade based on the levels of these HTF candles. Use the projected **High** and **Low** lines as potential "magnets." If price is trending toward the HTF High, anticipate institutional selling (rejection) at that level.

 3. The "Close" Countdown: The timer label tells you exactly when the 15-minute candle will finalize. Scalpers often experience increased volatility in the final 60 seconds of a 15-minute bar as institutions "mark the close." Use this countdown to protect your open positions.

The Institutional Workflow
 Entry: Wait for a short-term reversal signal (like your **Institutional Rejection** indicator) that happens within the range of the projected HTF candle.
 
Exit: Set your profit targets based on the HTF High/Low levels, as these are the zones where the "Big Money" is likely to take profits or re-enter.
By keeping the HTF projection on your chart, you are no longer just scalping "price action"; you are scalping in harmony with the timeframe that institutional algorithms use to structure their daily entries.

## Source Code

````pine
//@version=6
indicator("TripleQMatrix: HTF Projection + Regime Color", overlay=true, max_boxes_count=100)

// --- HTF Inputs ---
string htf_tf = input.timeframe("15", title="Higher Timeframe")

// --- Regime Logic (Running on 15m) ---
[h_open, h_high, h_low, h_close] = request.security(syminfo.tickerid, htf_tf, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_on)
atr = request.security(syminfo.tickerid, htf_tf, ta.atr(14), barmerge.gaps_off, barmerge.lookahead_on)
atrMA = request.security(syminfo.tickerid, htf_tf, ta.sma(ta.atr(14), 50), barmerge.gaps_off, barmerge.lookahead_on)

bool isChop = atr < (atrMA * 0.7)
bool isBull = h_close > h_open

// --- Color Coding Logic ---
color regimeColor = isChop ? color.new(color.gray, 70) : (isBull ? color.new(color.green, 70) : color.new(color.red, 70))
string regimeText = isChop ? "CHOP" : (isBull ? "BULL RUNNER" : "BEAR RUNNER")

// --- Persistent Drawing Objects ---
// Using 'var' ensures these are created only ONCE globally, not every tick
var box htfBox = na
var label htfLabel = na

// --- Draw / Update the Objects ---
if barstate.islast
    // If they don't exist yet, create them once
    if na(htfBox)
        htfBox := box.new(left=bar_index + 2, top=math.max(h_open, h_close), right=bar_index + 6, bottom=math.min(h_open, h_close), bgcolor=regimeColor, border_color=regimeColor)
    else
        // If they already exist, just move them to the latest coordinates and update colors
        box.set_left(htfBox, bar_index + 2)
        box.set_right(htfBox, bar_index + 6)
        box.set_top(htfBox, math.max(h_open, h_close))
        box.set_bottom(htfBox, math.min(h_open, h_close))
        box.set_bgcolor(htfBox, regimeColor)
        box.set_border_color(htfBox, regimeColor)

    if na(htfLabel)
        htfLabel := label.new(x=bar_index + 4, y=h_high, text=regimeText, style=label.style_label_down, color=color.new(color.black, 100), textcolor=color.black)
    else
        // Move the label dynamically to hover over the latest candle
        label.set_x(htfLabel, bar_index + 4)
        label.set_y(htfLabel, h_high)
        label.set_text(htfLabel, regimeText)
````
