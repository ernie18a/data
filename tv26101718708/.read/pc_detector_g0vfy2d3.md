# PC detector

- url: https://www.tradingview.com/script/g0VFy2D3-PC-detector/
- type: indicator
- pine_id: PUB;1d4deaeff5e6498bacd40de493d0af5f
- version: 2.0

## Description

detect and mark PC.
based on MNQ1! .
based on the TDO.

## Source Code

````pine
//@version=5
indicator("PC", overlay=true, max_labels_count=500)

// --- Timeframe Filter ---
// Specifically allow only the 15m timeframe.
allowedTimeframe = timeframe.period == "15"

// --- Symbol Inputs ---
s_nq_sym = input.symbol("CME_MINI:MNQ1!", "Index 1 (NQ)")
s_es_sym = input.symbol("CME_MINI:MES1!", "Index 2 (ES)")

// --- Visibility Toggles ---
showNormal = input.bool(true, "Enable Normal PC", group="Visibility")
enableAlerts = input.bool(true, "Enable Alerts", group="Alerts")

// --- Style Inputs ---
color_standard = input.color(color.black, "Standard PC Color")
pc_text_color  = input.color(color.white, "PC Text Color")
tdo_text_color = input.color(color.black, "TDO Text Color")
tdo_color      = input.color(color.gray, "TDO Line Color")

// --- Data Fetching ---
// Using request.security. We use nz() later to handle any 'na' values in Replay mode.
[o_nq, c_nq] = request.security(s_nq_sym, timeframe.period, [open, close], gaps=barmerge.gaps_off)
[o_es, c_es] = request.security(s_es_sym, timeframe.period, [open, close], gaps=barmerge.gaps_off)

// --- TDO Calculation ---
// London session starts at 07:00 UTC+3 (Israel Time)
t_isLondonOpen = time(timeframe.period, "0700-0701", "GMT+3")
var float tdo = na
var line tdo_line = na
var label tdo_price_label = na

if not na(t_isLondonOpen) and allowedTimeframe
    tdo := o_nq
    // Create the line
    tdo_line := line.new(bar_index, tdo, bar_index, tdo, color=tdo_color, width=1, style=line.style_solid)
    // Create the label at the end of the line
    tdo_price_label := label.new(bar_index, tdo, text="TDO: " + str.tostring(tdo), color=color.new(color.white, 100), textcolor=tdo_text_color, style=label.style_label_left, size=size.small)

// Continuously update the line end and the label position to the current bar
if not na(tdo_line) and not na(tdo_price_label) and allowedTimeframe
    line.set_x2(tdo_line, bar_index)
    label.set_x(tdo_price_label, bar_index)

// --- Logic Calculation ---

// 1. Define states (Handling potential 'na' values with nz)
isBullNQ = nz(c_nq) > nz(o_nq)
isBearNQ = nz(c_nq) < nz(o_nq)

isBullES = nz(c_es) > nz(o_es)
isBearES = nz(c_es) < nz(o_es)
isDojiES = nz(c_es) == nz(o_es)

// 2. Core PC Logic with Doji and TDO Filters
// PC occurs if NQ has color and ES is either the opposite color or a Doji
isDivergent = (isBullNQ and (isBearES or isDojiES)) or (isBearNQ and (isBullES or isDojiES))

// Filter: Red candles (isBearNQ) must open ABOVE TDO. Green candles (isBullNQ) must open BELOW TDO.
tdoFilter = (isBearNQ and o_nq > tdo) or (isBullNQ and o_nq < tdo)

isNormalPC = allowedTimeframe and showNormal and isDivergent and not na(tdo) and tdoFilter

// --- Visual Rendering ---

// Determine the active label for the current bar
string activeLabel = isNormalPC ? "PC" : ""
color  activeColor = color_standard

// Render Label
if activeLabel != ""
    label.new(bar_index, high, text=activeLabel, style=label.style_label_down, color=activeColor, textcolor=pc_text_color, yloc=yloc.abovebar, size=size.small)

// --- Alerts ---
// Trigger alert ONLY when alerts are enabled, the bar closes, and the PC condition is met
if enableAlerts and isNormalPC and barstate.isconfirmed
    alert("PC Signal Confirmed: A PC label has appeared on the close of the 15m candle.", alert.freq_once_per_bar)

// Legacy alert condition for the Alert Creation Dialog
alertcondition(enableAlerts and isNormalPC and barstate.isconfirmed, "Confirmed Normal PC", "PC signal detected on candle close")
````
