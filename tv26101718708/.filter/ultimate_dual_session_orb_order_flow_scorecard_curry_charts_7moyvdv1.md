# Ultimate Dual Session ORB Order Flow Scorecard - Curry Charts

- url: https://www.tradingview.com/script/7MoyVdV1-Ultimate-Dual-Session-ORB-Order-Flow-Scorecard-Curry-Charts/
- type: indicator
- pine_id: PUB;556138491360400bb658d089290bfba9
- version: 1.0

## Description

Core Strategy:



1. New York Opening Range:

- Mark the first 15-minute New York opening range from 9:30 AM to 9:45 AM Eastern Time.

- Draw the New York opening range high and low.



2. Sydney/Asia Opening Range:

- Mark the first 5-minute Sydney/Asia session opening range from 6:00 PM to 6:05 PM Eastern Time.

- Draw the Sydney/Asia opening range high and low.



3. Add volume profile-style levels for both opening ranges:

- Point of Control

- Value Area High

- Value Area Low



4. Detect breakout conditions:

- Bullish breakout when price closes above the active opening range high or value area high.

- Bearish breakout when price closes below the active opening range low or value area low.

- Use 5-minute candle confirmation.

- Option to require 1 close or 2 consecutive closes outside the range.



Top-Right Real-Time Scorecard Box:



Create a table in the top-right corner of the chart that updates in real time and shows green checkmarks or red X marks for each condition.



Scorecard categories:



1. Opening Range Breakout

- Green checkmark if price has closed outside the active session range or value area.

- Red X if price is still inside the range.



2. CVD / Delta Confirmation

- Green checkmark if estimated delta agrees with the breakout direction.

- Red X if delta disagrees.



3. Speed of Tape Confirmation

- Green checkmark if recent volume/tick activity is accelerating above normal.

- Red X if tape speed is slow or neutral.



4. Relative Volume Confirmation

- Green checkmark if current volume is above average volume.

- Red X if current volume is weak.



5. ATR Expansion Confirmation

- Green checkmark if ATR is expanding compared to recent ATR.

- Red X if ATR is flat or contracting.



6. VWAP Confirmation

- Green checkmark if bullish breakout is above VWAP or bearish breakout is below VWAP.

- Red X if price is on the wrong side of VWAP.



7. Volume Profile Confirmation

- Green checkmark if price breaks and holds beyond VAH for bullish setups or below VAL for bearish setups.

- Red X if price rejects back into value area.



8. Delta Momentum Confirmation

- Green checkmark if delta is increasing in the breakout direction over recent candles.

- Red X if delta is flat, weakening, or moving against the breakout.

- For bullish breakouts, delta should be rising.

- For bearish breakouts, delta should be falling/negative.



9. Absorption Detector

- Green checkmark if no major absorption is detected against the trade.

- Red X if absorption is detected.

- Bullish absorption warning: price is trying to break higher with strong buy delta, but price is barely moving or rejecting.

- Bearish absorption warning: price is trying to break lower with strong sell delta, but price is barely moving or rejecting.

- Show warning text: “Absorption Detected — Caution.”



10. Liquidity Sweep Detector

- Green checkmark if no liquidity sweep is detected against the trade.

- Red X if a sweep is detected.

- Buy-side liquidity sweep: price breaks above range high or VAH, then closes back inside the range/value area.

- Sell-side liquidity sweep: price breaks below range low or VAL, then closes back inside the range/value area.

- Show warning text: “Liquidity Sweep — Failed Breakout Risk.”



11. Breakout Acceptance Score

- Green checkmark if price breaks outside the range and holds beyond the breakout level.

- Red X if price breaks out but quickly rejects back into the range.

- Bullish acceptance = price holds above range high or VAH.

- Bearish acceptance = price holds below range low or VAL.



12. Initiative Activity Detector

- Green checkmark if breakout direction has strong volume, strong delta, fast tape, and expanding ATR.

- Red X if the move looks weak, slow, or reactive.

- Label as:

  - Initiative Buyers

  - Initiative Sellers

  - Responsive Buyers

  - Responsive Sellers

  - Neutral



Score System:



- Give each green checkmark 1 point.

- Maximum score: 12 points.

- Show total score in the box.



Ranking:



- 10 to 12 checks = A+ Institutional Breakout

- 8 to 9 checks = Strong Setup

- 6 to 7 checks = Good Setup / Caution

- 5 or fewer checks = Low Quality / Skip



The scorecard should display:



- Active session: New York or Sydney/Asia

- Breakout direction: Bullish, Bearish, or None

- Current score: X/12

- Setup ranking: A+ Institutional Breakout, Strong Setup, Good/Caution, or Skip

- Estimated buy volume

- Estimated sell volume

- Delta

- CVD trend

- Delta momentum

- Speed of tape status

- Relative volume reading

- ATR expansion status

- VWAP status

- Volume profile confirmation

- Absorption status

- Liquidity sweep status

- Breakout acceptance status

- Initiative activity status



Estimated Order Flow Logic:



Since TradingView does not provide true bid/ask order-flow data, estimate buy and sell volume using candle structure:



- Buy volume estimate based on where the candle closes within its high-low range.

- Sell volume estimate based on the opposite side of the candle range.

- Delta = estimated buy volume minus estimated sell volume.

- CVD = cumulative estimated delta.



Speed of Tape Logic:



Estimate speed of tape using recent volume acceleration:

- Compare current volume to the average volume of the last 20 candles.

- Fast tape = current volume significantly above average.

- Normal tape = current volume near average.

- Slow tape = current volume below average.



ATR Expansion Logic:



- Use ATR to detect volatility expansion.

- Green checkmark if current ATR is greater than recent ATR average.

- Red X if ATR is flat or below average.



Suggested Trade Management Levels:



Add suggested take-profit and stop-loss levels to the indicator. These should be visual guidance only, not automatic orders.



When a bullish breakout is detected:

- Suggested entry = breakout candle close or confirmed breakout level.

- Suggested stop loss = below the active opening range low, or below the active value area / POC area if that gives a cleaner risk level.

- TP1 = 40% of the active opening range size projected above the breakout level.

- TP2 = 60% of the active opening range size projected above the breakout level.

- TP3 / runner target = 100% of the active opening range size projected above the breakout level, or next major liquidity/volume level.



When a bearish breakout is detected:

- Suggested entry = breakout candle close or confirmed breakout level.

- Suggested stop loss = above the active opening range high, or above the active value area / POC area if that gives a cleaner risk level.

- TP1 = 40% of the active opening range size projected below the breakout level.

- TP2 = 60% of the active opening range size projected below the breakout level.

- TP3 / runner target = 100% of the active opening range size projected below the breakout level, or next major liquidity/volume level.



Risk Management Rules:



- After TP1 is hit, show a suggested stop move to breakeven.

- If price hits TP1 but delta/CVD weakens, show “Consider partial exit.”

- If price reaches TP2 and ATR is still expanding with strong delta, show “Runner still valid.”

- If price rejects back into the range after breakout, show “Failed breakout / exit warning.”



Display suggested levels on the chart with horizontal lines:

- Entry

- Stop Loss

- TP1

- TP2

- TP3 / Runner Target



Also show them inside the top-right scorecard:

- Entry price

- Stop loss price

- TP1 price

- TP2 price

- TP3 price

- Risk/reward to TP1

- Risk/reward to TP2

- Risk/reward to TP3



Alerts:



Create alerts for:



- New York A+ Institutional Bullish Breakout

- New York A+ Institutional Bearish Breakout

- Sydney/Asia A+ Institutional Bullish Breakout

- Sydney/Asia A+ Institutional Bearish Breakout

- Strong Bullish Setup

- Strong Bearish Setup

- Good Bullish Setup

- Good Bearish Setup

- Absorption detected

- Liquidity sweep detected

- Breakout accepted

- Breakout failed

- Delta momentum increasing

- Delta momentum weakening

- Initiative buyers detected

- Initiative sellers detected

- Price hits TP1

- Price hits TP2

- Price hits TP3 / runner target

- Price hits stop loss

- Price reaches TP1 and stop should move to breakeven



Customization Settings:



Allow the user to adjust:



- New York session start/end time

- Sydney/Asia session start/end time

- Opening range length

- Number of breakout confirmation candles

- Volume average length

- Delta threshold

- Relative volume threshold

- ATR length

- ATR expansion threshold

- VWAP filter on/off

- Scorecard table position

- Minimum score required for alert

- Show/hide each scorecard category

- TP1 percentage of range

- TP2 percentage of range

- TP3 percentage of range

- Use opposite range side stop loss on/off

- Use POC/value area stop loss on/off

- Move stop to breakeven after TP1 on/off

- Show/hide trade management lines



Important:



This indicator should not guarantee trades. It should act as a real-time confirmation dashboard that helps filter opening range breakout setups by showing whether volume, delta, tape speed, volatility, VWAP, value area confirmation, breakout acceptance, absorption, liquidity sweeps, initiative activity, and trade management levels are aligned with the breakout.



These DOM-style tools are not true Level 2 order book data. They are proxy detectors built from volume, candle structure, estimated delta, CVD, price movement, ATR, VWAP, and volume profile. The goal is to help the trader identify whether a breakout is being accepted, rejected, absorbed, or supported by strong participation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
//@version=6
indicator("Ultimate Dual Session ORB Order Flow Scorecard", shorttitle="ORB Scorecard", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// --- Constants ---
const string TZ = "America/New_York"

// --- Inputs ---
group_sessions = "--- Session Settings ---"
nyTime      = input.session("0930-0945", "New York ORB Time", group = group_sessions, tooltip = "Time in NY timezone")
sydTime     = input.session("1800-1805", "Sydney/Asia ORB Time", group = group_sessions)
useNY       = input.bool(true, "Enable New York Session", group = group_sessions)
useSYD      = input.bool(true, "Enable Sydney Session", group = group_sessions)

group_logic = "--- Breakout & Logic ---"
confirmBars = input.int(1, "Breakout Confirmation Bars", minval = 1, maxval = 2, group = group_logic)
volLen      = input.int(20, "Volume Average Length", group = group_logic)
atrLen      = input.int(14, "ATR Length", group = group_logic)
rvolThres   = input.float(1.2, "Relative Volume Threshold", group = group_logic)

group_dash = "--- Scorecard Design ---"
dashPos     = input.string("top_right", "Scorecard Position", options = ["top_right", "bottom_right", "top_left", "bottom_left", "top_center", "bottom_center"], group = group_dash)
orientation = input.string("Horizontal", "Scorecard Orientation", options = ["Horizontal", "Vertical"], group = group_dash)
dashScale   = input.string("small", "Scorecard Size", options = ["tiny", "small", "normal", "large"], group = group_dash)

group_style = "--- Style ---"
bullColor   = input.color(#089981, "Bullish Color", group = group_style)
bearColor   = input.color(#f23645, "Bearish Color", group = group_style)
neutralColor= input.color(#5b9cf6, "Neutral Color", group = group_style)

group_tm = "--- Trade Management ---"
showTM      = input.bool(true, "Show TM Levels", group = group_tm)
tp1Pct      = input.float(40.0, "TP1 % of Range", group = group_tm) / 100
tp2Pct      = input.float(60.0, "TP2 % of Range", group = group_tm) / 100
tp3Pct      = input.float(100.0, "TP3 % of Range", group = group_tm) / 100

// --- Session Logic ---
is_ny_session  = not na(time(timeframe.period, nyTime, TZ)) and useNY
is_syd_session = not na(time(timeframe.period, sydTime, TZ)) and useSYD
is_orb_active  = is_ny_session or is_syd_session

var float orbHigh = na
var float orbLow  = na
var float orbVAH  = na
var float orbVAL  = na
var float orbPOC  = na
var float orbSize = na

// Arrays for Volume Profile
var float[] orbPrices = array.new_float()
var float[] orbVolumes = array.new_float()

// Detect Session Transitions
new_ny  = is_ny_session and not is_ny_session[1]
new_syd = is_syd_session and not is_syd_session[1]
new_session = new_ny or new_syd

if new_session
    orbHigh := high
    orbLow  := low
    array.clear(orbPrices)
    array.clear(orbVolumes)

if is_orb_active
    orbHigh := math.max(orbHigh, high)
    orbLow  := math.min(orbLow, low)
    array.push(orbPrices, close)
    array.push(orbVolumes, volume)

// Calculate Volume Profile Levels at session end
end_ny  = not is_ny_session and is_ny_session[1]
end_syd = not is_syd_session and is_syd_session[1]
end_session = end_ny or end_syd

if end_session
    orbSize := orbHigh - orbLow
    if array.size(orbPrices) > 0
        // POC Estimation
        int maxIdx = 0
        float maxV = 0.0
        for i = 0 to array.size(orbVolumes) - 1
            if array.get(orbVolumes, i) > maxV
                maxV := array.get(orbVolumes, i)
                maxIdx := i
        orbPOC := array.get(orbPrices, maxIdx)
        orbVAH := orbHigh - (orbSize * 0.2)
        orbVAL := orbLow + (orbSize * 0.2)

// --- Order Flow Estimation ---
float buyVol  = volume * (close - low) / (high - low + 0.000001)
float sellVol = volume * (high - close) / (high - low + 0.000001)
float delta   = buyVol - sellVol
var float cvd = 0.0
cvd := is_orb_active ? cvd + delta : cvd

// --- Confirmation Metrics ---
float volAvg  = ta.sma(volume, volLen)
bool fastTape = volume > volAvg * rvolThres
bool highVol  = volume > volAvg
float atr     = ta.atr(atrLen)
bool atrExp   = atr > ta.sma(atr, atrLen)
float myVwap  = ta.vwap
bool aboveVwap = close > myVwap
bool belowVwap = close < myVwap

// Delta Momentum
bool deltaBull = delta > 0 and delta > nz(delta[1])
bool deltaBear = delta < 0 and delta < nz(delta[1])

// Absorption / Sweep Logic
bool bullAbsorption = close > open and delta < 0 and (high - close) > (close - open) 
bool bearAbsorption = close < open and delta > 0 and (close - low) > (open - close)  
bool liquiditySweepBull = high > orbHigh and close < orbHigh
bool liquiditySweepBear = low < orbLow and close > orbLow

// --- Breakout Logic ---
bool bullishBreak = close > orbHigh or close > orbVAH
bool bearishBreak = close < orbLow or close < orbVAL

var int confirmBull = 0
var int confirmBear = 0

if not is_orb_active and not na(orbHigh)
    if bullishBreak
        confirmBull += 1
        confirmBear := 0
    else if bearishBreak
        confirmBear += 1
        confirmBull := 0
    else
        confirmBull := 0
        confirmBear := 0
else
    confirmBull := 0
    confirmBear := 0

bool isBullish = confirmBull >= confirmBars
bool isBearish = confirmBear >= confirmBars
bool breakoutAcceptance = (isBullish and close > orbHigh) or (isBearish and close < orbLow)

// --- Scorecard (The 12 Checks) ---
int score = 0
bool c1 = isBullish or isBearish 
bool c2 = (isBullish and delta > 0) or (isBearish and delta < 0) 
bool c3 = fastTape 
bool c4 = highVol 
bool c5 = atrExp 
bool c6 = (isBullish and aboveVwap) or (isBearish and belowVwap) 
bool c7 = (isBullish and close > orbVAH) or (isBearish and close < orbVAL) 
bool c8 = (isBullish and deltaBull) or (isBearish and deltaBear) 
bool c9 = not (isBullish ? bullAbsorption : (isBearish ? bearAbsorption : false)) 
bool c10 = not (isBullish ? liquiditySweepBull : (isBearish ? liquiditySweepBear : false)) 
bool c11 = breakoutAcceptance 
bool c12 = (c1 and c2 and c3 and c5) 

score += (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) + (c5 ? 1 : 0) + (c6 ? 1 : 0)
score += (c7 ? 1 : 0) + (c8 ? 1 : 0) + (c9 ? 1 : 0) + (c10 ? 1 : 0) + (c11 ? 1 : 0) + (c12 ? 1 : 0)

string ranking = score >= 10 ? "A+ Inst" : score >= 8 ? "Strong" : score >= 6 ? "Caution" : "Skip"
color scoreColor = score >= 10 ? bullColor : score >= 8 ? color.new(bullColor, 30) : score >= 6 ? neutralColor : bearColor

// --- Trade Management Levels ---
var float entryPrice = na
var float slPrice = na
var float tp1 = na
var float tp2 = na
var float tp3 = na

if (isBullish or isBearish) and na(entryPrice)
    entryPrice := close
    if isBullish
        slPrice := orbLow
        tp1 := entryPrice + (orbSize * tp1Pct)
        tp2 := entryPrice + (orbSize * tp2Pct)
        tp3 := entryPrice + (orbSize * tp3Pct)
    else
        slPrice := orbHigh
        tp1 := entryPrice - (orbSize * tp1Pct)
        tp2 := entryPrice - (orbSize * tp2Pct)
        tp3 := entryPrice - (orbSize * tp3Pct)

if end_session 
    entryPrice := na
    slPrice := na
    tp1 := na
    tp2 := na
    tp3 := na

// --- Visuals ---
plot(orbHigh, "ORB High", color = color.new(neutralColor, 20), style = plot.style_linebr, linewidth = 2)
plot(orbLow, "ORB Low", color = color.new(neutralColor, 20), style = plot.style_linebr, linewidth = 2)
plot(orbVAH, "VAH", color = color.new(neutralColor, 50), style = plot.style_linebr, linewidth = 1)
plot(orbVAL, "VAL", color = color.new(neutralColor, 50), style = plot.style_linebr, linewidth = 1)
plot(orbPOC, "POC", color = color.new(neutralColor, 70), style = plot.style_linebr, linewidth = 1)

plot(showTM ? entryPrice : na, "Entry", color = chart.fg_color, style = plot.style_linebr)
plot(showTM ? slPrice : na, "Stop Loss", color = bearColor, style = plot.style_linebr, linewidth = 2)
plot(showTM ? tp1 : na, "TP1", color = bullColor, style = plot.style_linebr)
plot(showTM ? tp2 : na, "TP2", color = bullColor, style = plot.style_linebr)
plot(showTM ? tp3 : na, "TP3", color = bullColor, style = plot.style_linebr)

// --- Scorecard Design Logic ---
string tPos = dashPos == "top_right" ? position.top_right : 
              dashPos == "bottom_right" ? position.bottom_right : 
              dashPos == "top_left" ? position.top_left : 
              dashPos == "bottom_left" ? position.bottom_left : 
              dashPos == "top_center" ? position.top_center : position.bottom_center

string tSize = dashScale == "tiny" ? size.tiny : 
               dashScale == "small" ? size.small : 
               dashScale == "normal" ? size.normal : size.large

bool isH = orientation == "Horizontal"
int tCols = isH ? 17 : 2
int tRows = isH ? 2 : 23

// A+ Flash Logic
bool aPlusActive = score >= 10 and (isBullish or isBearish)
color flashColor = aPlusActive ? color.new(bullColor, 40) : color.new(chart.bg_color, 10)

var table scorecard = table.new(tPos, tCols, tRows, bgcolor = color.new(chart.bg_color, 10), border_width = 1, border_color = color.new(chart.fg_color, 50))

if barstate.islast
    string sessStr = is_ny_session ? "NY" : is_syd_session ? "SYD" : "None"
    string biasStr = isBullish ? "BULL" : isBearish ? "BEAR" : "None"
    color biasCol = isBullish ? bullColor : isBearish ? bearColor : chart.fg_color
    string dCvdStr = str.tostring(delta, "#.#") + "/" + str.tostring(cvd, "#.#")

    // Mapping Values
    string[] labels = array.from("RANK", "SCORE", "SESS", "BIAS", "ORB", "CVD", "TAPE", "RVOL", "ATR", "VWAP", "VAL", "MOM", "ABS", "SWP", "ACC", "INIT", "Δ/CVD")
    string[] values = array.from(ranking, str.tostring(score) + "/12", sessStr, biasStr, c1?"✅":"❌", c2?"✅":"❌", c3?"✅":"❌", c4?"✅":"❌", c5?"✅":"❌", c6?"✅":"❌", c7?"✅":"❌", c8?"✅":"❌", c9?"✅":"❌", c10?"✅":"❌", c11?"✅":"❌", c12?"✅":"❌", dCvdStr)
    color[] vColors = array.from(scoreColor, scoreColor, chart.fg_color, biasCol, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color, chart.fg_color)
    int[] vRows     = array.from(4, 3, 1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)

    for i = 0 to array.size(labels) - 1
        string lbl = array.get(labels, i)
        string val = array.get(values, i)
        color clr  = array.get(vColors, i)
        int rIdx   = array.get(vRows, i)

        if isH
            table.cell(scorecard, i, 0, lbl, text_color = color.new(chart.fg_color, 50), text_size = tSize, bgcolor = flashColor)
            table.cell(scorecard, i, 1, val, text_color = clr, text_size = tSize, bgcolor = flashColor)
        else
            table.cell(scorecard, 0, rIdx, lbl, text_halign = text.align_left, text_size = tSize, bgcolor = flashColor)
            table.cell(scorecard, 1, rIdx, val, text_color = clr, text_size = tSize, bgcolor = flashColor)

    // Vertical specific branding
    if not isH
        table.cell(scorecard, 0, 0, "CATEGORY", text_color = chart.fg_color, text_size = tSize, bgcolor = flashColor)
        table.cell(scorecard, 1, 0, "STATUS", text_color = chart.fg_color, text_size = tSize, bgcolor = flashColor)
        if bullAbsorption or bearAbsorption
            table.cell(scorecard, 0, 21, "Absorption!", bgcolor = bearColor, text_color = color.white, text_size = tSize)
            table.merge_cells(scorecard, 0, 21, 1, 21)
        if liquiditySweepBull or liquiditySweepBear
            table.cell(scorecard, 0, 22, "Sweep!", bgcolor = bearColor, text_color = color.white, text_size = tSize)
            table.merge_cells(scorecard, 0, 22, 1, 22)

// --- Real-time Sound Alerts ---
if aPlusActive and not aPlusActive[1]
    alert("A+ Institutional Setup Detected! Score: " + str.tostring(score) + "/12", alert.freq_once_per_bar)

// --- Alerts ---
alertcondition(score >= 10 and (isBullish or isBearish), "A+ Institutional Breakout")
alertcondition(bullAbsorption or bearAbsorption, "Absorption Detected")
alertcondition(liquiditySweepBull or liquiditySweepBear, "Liquidity Sweep Detected")
````
