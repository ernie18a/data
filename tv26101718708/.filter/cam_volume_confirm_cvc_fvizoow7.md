# Cam Volume Confirm [CVC]

- url: https://www.tradingview.com/script/fViZOOw7-Cam-Volume-Confirm-CVC/
- type: indicator
- pine_id: PUB;93beaf3508374e4ea49cfed944289b2c
- version: 1.0

## Description

Volume + Rsi

3. weakThresh default is positive in tooltip but negative in logic
Your input tooltip says "below negative = SHORT confirmed" but the default is -20.0 which is already negative — the tooltip wording is slightly confusing. Minor, but worth cleaning up for users.

4. No connection to the actual Camarilla signal
Right now CVC runs independently — it doesn't know when the Camarilla Pivot Plays indicator fired a signal. It just shows volume power continuously. So the VALID/FAKE labels appear based on the metric crossing thresholds, not specifically in response to a Cam play triggering.
To truly confirm a Cam signal, you'd want to receive the Camarilla entry event (via input.source or a shared alert) and then evaluate the metric at that moment.

5. isFake label only shows on transition from strong/weak → fake
pineif isFake and not wasFake and (wasStrong or wasWeak)
This is actually good design — it avoids spam. But it means if the metric is in the fake zone from the start of a new day, no FAKE label appears. Might want to add a session-start check if that matters to you.SKJhgdbASHDGuyaSDjBASLJDhgAOUYSDFABJS lNAMBSV

## Source Code

````pine
// © CamVolumeConfirm - Camarilla Volume + RSI Confirmation Indicator
// Compatible with TradingView Pine Script v6
// Designed to confirm or reject signals from the "Camarilla Pivot Plays" indicator
// Confirmation requires BOTH volume strength AND RSI momentum agreement
// Inspired by BSD (Bar Strength Delta) methodology

//@version=6
indicator("Cam Volume Confirm [CVC]", shorttitle = "CVC", overlay = false, max_lines_count = 10, max_labels_count = 50)

// ═══════════════════════════════════════════════════════════
// ---- INPUTS
// ═══════════════════════════════════════════════════════════

// ── Volume Settings ─────────────────────────────────────────
float volBoost     = input.float(0.5,  "Volume Boost",              minval = 0.0, maxval = 1.0, step = 0.1, tooltip = "Non-linearity boost. 0=linear, 0.5=sqrt (recommended), 1=square.", group = "Volume Settings")
float volFactor    = input.float(1.0,  "Volume Factor",             minval = 0.0, maxval = 1.0, step = 0.1, tooltip = "How much weight volume has. 0=no effect, 1=full effect.", group = "Volume Settings")
int   rmaLen       = input.int  (14,   "Rolling RMA Length (bars)", minval = 1, tooltip = "Wilder RMA length for the rolling metric.", group = "Volume Settings")
int   scaleDays    = input.int  (5,    "Scaling RMA Length (days)", minval = 1, tooltip = "Days used to scale metric to -100/+100 range.", group = "Volume Settings")

// ── Smoothing ───────────────────────────────────────────────
string smoothMethod = input.string("HMA", "Smoothing Method", options = ["None", "SMA", "EMA", "RMA", "HMA", "WMA"], tooltip = "Moving average applied visually to the metric.", group = "Smoothing")
int    smoothLen    = input.int(5, "Smoothing Length (bars)", minval = 1, tooltip = "Length for visual smoothing.", group = "Smoothing")

// ── Volume Confirmation Thresholds ──────────────────────────
float powerThresh  = input.float( 20.0, "Power Threshold (above = strong)", minval = 1,   maxval = 99,  step = 1, tooltip = "Volume metric must be above this for LONG volume confirmation.", group = "Volume Confirmation")
float weakThresh   = input.float(-20.0, "Weakness Threshold (below = weak)", minval = -99, maxval = -1,  step = 1, tooltip = "Volume metric must be below this for SHORT volume confirmation.", group = "Volume Confirmation")

// ── RSI Settings ────────────────────────────────────────────
int   rsiLen       = input.int  (14,   "RSI Length",               minval = 1,  tooltip = "Standard RSI period. 14 is the classic default.", group = "RSI Confirmation")
float rsiMidLine   = input.float(50.0, "RSI Mid Line",             minval = 30, maxval = 70, step = 1, tooltip = "RSI must cross above this to confirm LONG, cross below to confirm SHORT. 50 = momentum shift.", group = "RSI Confirmation")
float rsiOBLevel   = input.float(70.0, "RSI Overbought Level",     minval = 60, maxval = 90, step = 1, tooltip = "RSI above this = overbought warning on LONG signals.", group = "RSI Confirmation")
float rsiOSLevel   = input.float(30.0, "RSI Oversold Level",       minval = 10, maxval = 40, step = 1, tooltip = "RSI below this = oversold warning on SHORT signals.", group = "RSI Confirmation")
bool  showRsiLine  = input.bool (true,  "Show RSI Line on Panel",   tooltip = "Plots the RSI value scaled to the oscillator panel for visual reference.", group = "RSI Confirmation")
color rsiColour    = input.color(color.new(color.yellow, 20), "RSI Line Colour", group = "RSI Confirmation")

// ── Display ─────────────────────────────────────────────────
bool  showSignals  = input.bool(true,  "Show VALID / FAKE labels",  group = "Display")
bool  showInfoBox  = input.bool(true,  "Show Info Box",             group = "Display")
string infoPos     = input.string("Top Right", "Info Box Position", options = ["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left"], group = "Display")
bool  showZeroLine = input.bool(true,  "Show Zero Line & Threshold Bands", group = "Display")
color bullColour   = input.color(color.new(color.teal,  15), "Strong (Bull) Colour",  group = "Display")
color bearColour   = input.color(color.new(color.red,   15), "Weak (Bear) Colour",    group = "Display")
color neutColour   = input.color(color.new(color.gray,  40), "Neutral Colour",        group = "Display")
color maColour     = input.color(color.new(color.blue,  10), "Smoothing Line Colour", group = "Display")
color threshColour = input.color(color.new(color.orange,30), "Threshold Band Colour", group = "Display")

// ═══════════════════════════════════════════════════════════
// ---- FUNCTIONS
// ═══════════════════════════════════════════════════════════

hma(series float src, simple int len) =>
    wma1 = ta.wma(src, len)
    wma2 = ta.wma(src, math.floor(len / 2))
    ta.wma(2 * wma2 - wma1, math.floor(math.sqrt(len)))

smooth(series float src, simple int len, simple string method) =>
    switch method
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "RMA" => ta.rma(src, len)
        "HMA" => hma(src, len)
        "WMA" => ta.wma(src, len)
        =>       src

// ═══════════════════════════════════════════════════════════
// ---- VOLUME METRIC CALCULATION
// ═══════════════════════════════════════════════════════════

// Fix: timeframe-aware bars-per-day instead of hardcoded 390
int   barsPerDay    = timeframe.in_seconds() > 0 ? math.max(1, math.round(23400 / timeframe.in_seconds())) : 390

float barDir        = close - open
float barRange      = high - low
float normDir       = barRange != 0.0 ? barDir / barRange : 0.0
float rawVol        = volume > 0 ? math.pow(volume, 1.0 - volBoost) : 0.0
float volComp       = rawVol * volFactor + (1.0 - volFactor)
float rawMetric     = normDir * volComp
float absMetric     = math.abs(rawMetric)
float scaler        = ta.rma(absMetric, scaleDays * barsPerDay)
float scaledRaw     = scaler != 0.0 ? (rawMetric / scaler) * 100.0 : rawMetric * 100.0
float scaledMetric  = math.max(-100.0, math.min(100.0, scaledRaw))
float rollingMetric = ta.rma(scaledMetric, rmaLen)
float displayMetric = smooth(rollingMetric, smoothLen, smoothMethod)

// ═══════════════════════════════════════════════════════════
// ---- RSI CALCULATION
// ═══════════════════════════════════════════════════════════

float rsiValue    = ta.rsi(close, rsiLen)

// RSI confirmation conditions:
// LONG  → RSI crosses above the mid line (momentum turning bullish)
// SHORT → RSI crosses below the mid line (momentum turning bearish)
bool  rsiCrossUp   = ta.crossover (rsiValue, rsiMidLine)   // RSI just crossed above 50
bool  rsiCrossDown = ta.crossunder (rsiValue, rsiMidLine)  // RSI just crossed below 50

// Sustained RSI confirmation: RSI stays above/below mid line
// We use this (not just the crossover) so the confirmation holds across bars
bool  rsiAboveMid  = rsiValue >= rsiMidLine   // RSI is bullish territory
bool  rsiBelowMid  = rsiValue <  rsiMidLine   // RSI is bearish territory

// Overbought / oversold warning flags
bool  rsiOverbought  = rsiValue >= rsiOBLevel  // warning: LONG may be extended
bool  rsiOversold    = rsiValue <= rsiOSLevel  // warning: SHORT may be extended

// Scale RSI (0-100) → oscillator space (-100 to +100) for panel plotting
// Formula: (rsi - 50) * 2  maps 0→-100, 50→0, 100→+100
float rsiScaled   = (rsiValue - 50.0) * 2.0

// ═══════════════════════════════════════════════════════════
// ---- VOLUME CONFIRMATION
// ═══════════════════════════════════════════════════════════

bool isStrongVol  = displayMetric >= powerThresh   // volume confirms bullish
bool isWeakVol    = displayMetric <= weakThresh    // volume confirms bearish
bool isFakeVol    = not isStrongVol and not isWeakVol

// ═══════════════════════════════════════════════════════════
// ---- COMBINED CONFIRMATION (Volume AND RSI)
// ═══════════════════════════════════════════════════════════

// LONG  confirmed: volume is strong AND RSI is above mid line
// SHORT confirmed: volume is weak   AND RSI is below mid line
// Both must agree — strictest mode
bool confirmedLong  = isStrongVol and rsiAboveMid
bool confirmedShort = isWeakVol   and rsiBelowMid
bool isFake         = not confirmedLong and not confirmedShort

// Previous bar states for transition-based label logic
bool wasStrongVol       = isStrongVol[1]
bool wasWeakVol         = isWeakVol[1]
bool wasRsiAboveMid     = rsiAboveMid[1]
bool wasRsiBelowMid     = rsiBelowMid[1]
bool wasConfirmedLong   = confirmedLong[1]
bool wasConfirmedShort  = confirmedShort[1]
bool wasFake            = isFake[1]

// Bar colour reflects the combined state
color barColor = confirmedLong ? bullColour : confirmedShort ? bearColour : neutColour

// ═══════════════════════════════════════════════════════════
// ---- PLOTS
// ═══════════════════════════════════════════════════════════

// Volume metric histogram + smoothed line
plot(displayMetric, "Volume Power",  style = plot.style_histogram, color = barColor, linewidth = 2)
plot(displayMetric, "Smoothed Line", color = maColour, linewidth = 2)

// RSI scaled line on the same panel
plot(showRsiLine ? rsiScaled : na, "RSI (scaled)", color = rsiColour, linewidth = 1)

// Zero line and threshold bands
hline(0, "Zero", color = color.new(color.white, 50), linestyle = hline.style_solid, linewidth = 1)
plot(showZeroLine ?  powerThresh : na, "Power Threshold",    color = threshColour, linewidth = 1)
plot(showZeroLine ?  weakThresh  : na, "Weakness Threshold", color = threshColour, linewidth = 1)

// RSI mid-line reference (at 0 in scaled space = RSI 50)
hline(0, "RSI Mid (50)", color = color.new(color.yellow, 80), linestyle = hline.style_dashed, linewidth = 1)

p1 = plot(showZeroLine ? powerThresh : na, display = display.none)
p2 = plot(showZeroLine ? weakThresh  : na, display = display.none)
fill(p1, p2, color = color.new(color.gray, 90), title = "Fake Zone Fill")

// ═══════════════════════════════════════════════════════════
// ---- VALID / FAKE LABELS
// ═══════════════════════════════════════════════════════════

if showSignals
    // Full confirmation labels
    if confirmedLong and not wasConfirmedLong
        string longTxt = rsiOverbought ? "✔ VALID LONG  ⚠ OB" : "✔ VALID LONG"
        label.new(bar_index, displayMetric, text = longTxt, color = color.new(color.teal, 20), style = label.style_label_up, textcolor = color.white, size = size.small)

    if confirmedShort and not wasConfirmedShort
        string shortTxt = rsiOversold ? "✔ VALID SHORT  ⚠ OS" : "✔ VALID SHORT"
        label.new(bar_index, displayMetric, text = shortTxt, color = color.new(color.red, 20), style = label.style_label_down, textcolor = color.white, size = size.small)

    // Fake label: was confirmed but now lost
    if isFake and not wasFake and (wasConfirmedLong or wasConfirmedShort)
        label.new(bar_index, displayMetric, text = "⚠ FAKE", color = color.new(color.orange, 20), style = label.style_label_up, textcolor = color.white, size = size.small)

    // Partial labels: only one condition met — helps diagnose the missing piece
    if isStrongVol and not rsiAboveMid and not wasStrongVol
        label.new(bar_index, displayMetric, text = "〜 VOL OK / RSI BEARISH", color = color.new(color.teal, 65), style = label.style_label_up, textcolor = color.white, size = size.tiny)
    if rsiAboveMid and not isStrongVol and not wasRsiAboveMid
        label.new(bar_index, displayMetric, text = "〜 RSI OK / LOW VOL", color = color.new(color.teal, 65), style = label.style_label_up, textcolor = color.white, size = size.tiny)
    if isWeakVol and not rsiBelowMid and not wasWeakVol
        label.new(bar_index, displayMetric, text = "〜 VOL OK / RSI BULLISH", color = color.new(color.red, 65), style = label.style_label_down, textcolor = color.white, size = size.tiny)
    if rsiBelowMid and not isWeakVol and not wasRsiBelowMid
        label.new(bar_index, displayMetric, text = "〜 RSI OK / LOW VOL", color = color.new(color.red, 65), style = label.style_label_down, textcolor = color.white, size = size.tiny)

// ═══════════════════════════════════════════════════════════
// ---- INFO BOX
// ═══════════════════════════════════════════════════════════

if showInfoBox and barstate.islast
    tablePos = switch infoPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Top Center"   => position.top_center
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right

    var table infoTable = na
    if na(infoTable)
        infoTable := table.new(tablePos, 2, 7, bgcolor = color.new(color.black, 20), border_color = color.new(color.white, 40), border_width = 1)

    // Combined status text
    string statusText =
         confirmedLong  and rsiOverbought  ? "● LONG  CONFIRMED  ⚠ Overbought"  :
         confirmedLong                     ? "● LONG  CONFIRMED  ✔ Vol + RSI"   :
         confirmedShort and rsiOversold    ? "● SHORT CONFIRMED  ⚠ Oversold"    :
         confirmedShort                    ? "● SHORT CONFIRMED  ✔ Vol + RSI"   :
         isFakeVol                         ? "● FAKE  — Volume inconclusive"    :
                                             "● PARTIAL — RSI disagrees"

    color statusColor =
         confirmedLong  ? color.teal   :
         confirmedShort ? color.red    :
         isFakeVol      ? color.orange :
                          color.yellow

    // Volume status
    string volText  = isStrongVol ? "✔ Strong — Bullish" : isWeakVol ? "✔ Weak — Bearish" : "✖ Neutral / Inconclusive"
    color  volColor = isStrongVol ? color.teal : isWeakVol ? color.red : color.orange

    // RSI status
    string rsiSideText  = rsiAboveMid ? "✔ Above " + str.tostring(rsiMidLine) + " — Bullish" : "✖ Below " + str.tostring(rsiMidLine) + " — Bearish"
    color  rsiSideColor = rsiAboveMid ? color.teal : color.red
    string rsiWarnText  = rsiOverbought ? "⚠ Overbought (" + str.tostring(math.round(rsiValue, 1)) + ")" : rsiOversold ? "⚠ Oversold (" + str.tostring(math.round(rsiValue, 1)) + ")" : str.tostring(math.round(rsiValue, 1)) + " — Normal"
    color  rsiWarnColor = rsiOverbought or rsiOversold ? color.orange : color.white

    table.cell(infoTable, 0, 0, "CVC Status",      text_color = color.gray,    text_size = size.small)
    table.cell(infoTable, 1, 0, statusText,         text_color = statusColor,   text_size = size.small)
    table.cell(infoTable, 0, 1, "Volume",           text_color = color.gray,    text_size = size.small)
    table.cell(infoTable, 1, 1, volText,            text_color = volColor,      text_size = size.small)
    table.cell(infoTable, 0, 2, "Vol Metric",       text_color = color.gray,    text_size = size.small)
    table.cell(infoTable, 1, 2, str.tostring(math.round(displayMetric, 1)), text_color = color.white, text_size = size.small)
    table.cell(infoTable, 0, 3, "RSI Direction",    text_color = color.gray,    text_size = size.small)
    table.cell(infoTable, 1, 3, rsiSideText,        text_color = rsiSideColor,  text_size = size.small)
    table.cell(infoTable, 0, 4, "RSI Value",        text_color = color.gray,    text_size = size.small)
    table.cell(infoTable, 1, 4, rsiWarnText,        text_color = rsiWarnColor,  text_size = size.small)
    table.cell(infoTable, 0, 5, "Vol Threshold",    text_color = color.gray,    text_size = size.small)
    table.cell(infoTable, 1, 5, str.tostring(powerThresh) + " / " + str.tostring(weakThresh), text_color = color.orange, text_size = size.small)
    table.cell(infoTable, 0, 6, "Settings",         text_color = color.gray,    text_size = size.small)
    table.cell(infoTable, 1, 6, "RSI(" + str.tostring(rsiLen) + ")  " + smoothMethod + "(" + str.tostring(smoothLen) + ")", text_color = color.white, text_size = size.small)

// ═══════════════════════════════════════════════════════════
// ---- ALERTS
// ═══════════════════════════════════════════════════════════

// Full confirmation alerts (Volume AND RSI both agree)
alertcondition(confirmedLong  and not wasConfirmedLong,  title = "CVC: LONG Confirmed (Vol + RSI)",  message = "Camarilla LONG confirmed — Volume strong + RSI above midline on {{ticker}} at {{time}}")
alertcondition(confirmedShort and not wasConfirmedShort, title = "CVC: SHORT Confirmed (Vol + RSI)", message = "Camarilla SHORT confirmed — Volume weak + RSI below midline on {{ticker}} at {{time}}")
alertcondition(isFake and not wasFake and (wasConfirmedLong or wasConfirmedShort), title = "CVC: Signal FAKE", message = "Camarilla signal FAKE — Vol+RSI confirmation lost on {{ticker}} at {{time}}")

// Partial alerts — when only one of the two conditions fires
alertcondition(isStrongVol and not rsiAboveMid and not wasStrongVol,  title = "CVC: Vol Strong but RSI Bearish (Long)",  message = "Volume strong but RSI below midline — partial LONG signal on {{ticker}} at {{time}}")
alertcondition(rsiCrossUp  and not isStrongVol,                       title = "CVC: RSI Crossed Up but Low Volume",      message = "RSI crossed above midline but volume not confirmed on {{ticker}} at {{time}}")
alertcondition(isWeakVol   and not rsiBelowMid and not wasWeakVol,    title = "CVC: Vol Weak but RSI Bullish (Short)",   message = "Volume weak but RSI above midline — partial SHORT signal on {{ticker}} at {{time}}")
alertcondition(rsiCrossDown and not isWeakVol,                        title = "CVC: RSI Crossed Down but Low Volume",    message = "RSI crossed below midline but volume not confirmed on {{ticker}} at {{time}}")

// Overbought / Oversold warnings on confirmed signals
alertcondition(confirmedLong  and rsiOverbought and not wasConfirmedLong,  title = "CVC: LONG Confirmed but Overbought",  message = "LONG confirmed but RSI is overbought — proceed with caution on {{ticker}} at {{time}}")
alertcondition(confirmedShort and rsiOversold   and not wasConfirmedShort, title = "CVC: SHORT Confirmed but Oversold",   message = "SHORT confirmed but RSI is oversold — proceed with caution on {{ticker}} at {{time}}")
````
