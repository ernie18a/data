<!-- tradingview-pine-id: PUB;15b04ed86fad426480db3b07b1746805 -->
<!-- tradingviewscripts-format: 1 -->
# SMC Entry Setups

Source: https://www.tradingview.com/script/ut6JUiVR-SMC-Entry-Setups/

## Description

https://www.tradingview.com/u/Expert_Markets_Insights/
SMC Entry Setups is a Smart Money Concepts (SMC) tool that automatically detects Fair Value Gaps (FVGs) on any chart, any market, and any timeframe, and turns them into complete, ready-to-read trade setups. Instead of manually spotting a 3-candle imbalance, waiting for price to return into it, and then drawing your own Entry / Stop-Loss / Take-Profit levels, this indicator does all of it for you in real time — plotting the exact same style of Entry, Risk (red) and Reward (green) zones that traders draw by hand when marking up their charts.

Why This Indicator Was Built

Fair Value Gaps are one of the core building blocks of Smart Money Concepts / ICT-style trading — they mark the exact footprint of an aggressive, one-sided move where price left an imbalance behind. Price frequently returns to "fill" or "mitigate" that imbalance before continuing in the direction of the original move, which is why FVGs are commonly used as entry zones.

In practice, manually tracking every FVG across multiple symbols and timeframes is slow and error-prone, and charts get cluttered fast once several gaps are marked at once. SMC Entry Setups was built to solve exactly that: it automates the detection, filtering, and mitigation-tracking of FVGs, and only surfaces a clean, complete trade setup when price actually comes back to test one — so you always know at a glance where the entry, stop, and target are, without having to draw anything yourself.

How It Works

1. Fair Value Gap Detection The script scans every bar for the classic 3-candle imbalance:

A bullish FVG forms when the current candle's low is higher than the high from two candles back, leaving an untraded gap below price.
A bearish FVG forms when the current candle's high is lower than the low from two candles back, leaving an untraded gap above price.

2. Noise Filtering (ATR + Displacement) Not every small gap is worth trading. The indicator uses the Average True Range (ATR) to automatically scale its filters to whatever symbol and timeframe you're on:

A minimum gap size (as a multiple of ATR) removes tiny, insignificant gaps.
An optional "displacement" filter requires the candle that created the gap to be a strong, directional, high-momentum candle — the same kind of impulsive move that produces genuine institutional imbalances — filtering out gaps formed by ordinary choppy price action.

3. FVG Visualization Every qualifying FVG is drawn as a labeled box on the chart, colored by direction, so you can see exactly where the imbalance sits and how far it stretches.

4. Mitigation & Entry Detection The indicator continuously tracks every active (unmitigated) FVG. When price later trades back into that zone:

If price closes straight through the gap without reacting, the FVG is treated as invalidated and quietly removed — no false setup is drawn.
If price taps into the zone and holds (a genuine reaction), the indicator fires a trade setup: a bullish FVG that gets tapped from above triggers a BUY setup, and a bearish FVG that gets tapped from below triggers a SELL setup.

5. Entry, Stop-Loss & Take-Profit Calculation Once a setup triggers:

Entry is taken at the price where the reaction was confirmed.
Stop-Loss is placed just beyond the far edge of the FVG, with an extra ATR-based buffer so the stop isn't sitting exactly on the raw structure.
Take-Profit is calculated automatically from your chosen Risk : Reward ratio (default 1:2, fully adjustable).

6. Visual Trade Zones Instead of plain lines, the setup is displayed as two growing colored zones — exactly like a manual Long/Short Position drawing:

A green Reward Zone stretching from Entry to Take-Profit.
A red Risk Zone stretching from Entry to Stop-Loss. Both zones expand to the right in real time for as long as the trade stays open, then stop once price reaches the target or the stop.

7. One Clean Setup At A Time To keep the chart readable, the indicator (by default) will not draw a new setup until the previous one has finished — either by hitting its Take-Profit or its Stop-Loss. This mirrors how a discretionary trader would actually manage the chart: one live idea at a time, not a wall of overlapping signals.

8. Alerts Built-in alert conditions let you get notified the instant a new BUY or SELL setup is triggered, so you don't need to watch the chart constantly.

How To Use It
Add the indicator to any chart, any symbol, any timeframe.
Adjust the FVG Detection settings if you want tighter or looser gap filtering (ATR multiplier, displacement requirement).
Set your preferred Risk : Reward ratio and SL buffer in the Entry / Risk Management section.
Watch for the BUY ENTRY / SELL ENTRY label — the green and red zones show your Reward and Risk at a glance.
Optionally set an alert so you're notified the moment a new setup appears.

This tool is a decision-support aid, not a signal-and-forget system. Always confirm setups against your own market context (higher-timeframe trend, key levels, news events) before acting on them.

Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial advice. Trading involves substantial risk of loss. Past behavior of any pattern, including Fair Value Gaps, does not guarantee future results. Always backtest thoroughly and use proper risk management before using this or any tool in live trading.

Author Verification & Declaration

This script, "SMC Entry Setups," is published and maintained by Expert_Markets_Insights. The underlying market concept used in this tool — the three-candle price "imbalance" known in the trading community as a Fair Value Gap (FVG) — is a generic, publicly documented Smart Money Concepts / ICT market-structure concept. It is not proprietary to any single author, vendor, or publication, and is referenced here purely as a well-known technical definition, in the same way an indicator might reference RSI, MACD, or ATR as generic technical concepts.

Original Implementation Declaration

Every line of Pine Script code in this publication — the Fair Value Gap detection engine, the ATR-based gap filtering, the displacement/impulsive-candle filter, the FVG box drawing, extension, invalidation and expiry logic, the price re-entry ("mitigation") detection engine, the Entry / Stop-Loss / Take-Profit calculation engine, the growing Reward/Risk zone visualization, the "one setup at a time" trade-state management, the labeling system, and the alert framework — has been independently designed and written from scratch by Expert_Markets_Insights specifically for this publication.

No source code has been copied, ported, or adapted from any other author's published TradingView script, open-source repository, or third-party indicator. Any resemblance to other publicly available FVG-based scripts is limited strictly to the shared, generic underlying market concept (the 3-candle FVG definition) — not to the code implementation itself, which is original work.
https://www.tradingview.com/u/Expert_Markets_Insights/

---

## Source Code

````pine
//@version=6

// =============================================================================================
//  SMC Entry Setups
// =============================================================================================
//  Author            : Expert_Markets_Insights
//  Category          : Smart Money Concepts (SMC) / Fair Value Gap (FVG) Trade Setup Tool
//
//  AUTHOR VERIFICATION & DECLARATION
//  ---------------------------------------------------------------------------------------------
//  This script, "SMC Entry Setups", is published and maintained by Expert_Markets_Insights.
//  The underlying market concept used in this tool - the three-candle price "imbalance" known
//  in the trading community as a Fair Value Gap (FVG) - is a generic, publicly documented
//  Smart Money Concepts / ICT market-structure concept. It is not proprietary to any single
//  author, vendor, or publication, and is used here purely as a well-known technical definition,
//  the same way indicators reference RSI, MACD, or ATR as generic technical concepts.
//
//  ORIGINAL IMPLEMENTATION DECLARATION
//  ---------------------------------------------------------------------------------------------
//  Every line of Pine Script code in this file - the FVG detection engine, the ATR-based gap
//  filtering, the FVG box drawing / extension / invalidation / expiry logic, the price
//  re-entry ("mitigation") detection engine, the Entry / Stop-Loss / Take-Profit calculation
//  and plotting engine, the labeling system, and the alert framework - has been independently
//  designed and written from scratch by Expert_Markets_Insights specifically for this
//  publication. No source code has been copied, ported, or adapted from any other author's
//  published TradingView script, open-source repository, or third-party indicator. Any
//  resemblance to other publicly available FVG scripts is limited strictly to the shared,
//  generic underlying market concept (the 3-candle FVG definition), not to the code
//  implementation itself.
//
//  DESCRIPTION
//  ---------------------------------------------------------------------------------------------
//  SMC Entry Setups automatically detects bullish and bearish Fair Value Gaps (FVGs) on any
//  chart, any market, and any timeframe. When price later returns into an unmitigated FVG and
//  reacts from it, the indicator automatically plots a complete trade setup: an Entry line, a
//  Stop-Loss line, and a Take-Profit line (based on a user-defined Risk:Reward ratio), together
//  with BUY / SELL labels - similar to the manual FVG trade markups traders draw by hand.
//
//  DISCLAIMER
//  ---------------------------------------------------------------------------------------------
//  This tool is provided for educational and informational purposes only. It does not
//  constitute financial advice. Trading involves risk. Always backtest and use proper risk
//  management before using any automated setup in live trading.
// =============================================================================================

indicator("SMC Entry Setups", shorttitle = "SMC-ES", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ------------------------------------------------------------------------------------------
// INPUTS
// ------------------------------------------------------------------------------------------
grpFVG   = "FVG Detection"
grpRisk  = "Entry / Risk Management"
grpDisp  = "Display"
grpAlert = "Alerts"

useATRFilter  = input.bool(true, "Filter tiny gaps using ATR", group = grpFVG,
     tooltip = "Ignores Fair Value Gaps smaller than (ATR x Multiplier). Keeps the tool clean on any market/timeframe.")
atrLen        = input.int(14, "ATR Length", group = grpFVG, minval = 1)
atrMult       = input.float(0.25, "Minimum Gap Size = ATR x", group = grpFVG, step = 0.05, minval = 0.0)
requireDisplacement = input.bool(true, "Require Strong Displacement Candle", group = grpFVG,
     tooltip = "Only marks an FVG when the middle candle is a strong/impulsive move (like the sharp candles in the reference chart), filtering out small choppy gaps.")
displacementMult    = input.float(0.5, "Displacement Candle Body >= ATR x", group = grpFVG, step = 0.1, minval = 0.0)
maxFVGAgeBars = input.int(300, "Max FVG Age (bars)", group = grpFVG, minval = 5,
     tooltip = "An FVG that is never touched within this many bars is automatically removed.")
maxActiveFVGs = input.int(12, "Max Active FVG Boxes", group = grpFVG, minval = 1, maxval = 100)

riskReward      = input.float(2.0, "Risk : Reward Ratio", group = grpRisk, minval = 0.1, step = 0.1)
slBufferATRMult = input.float(0.15, "Extra SL Buffer = ATR x", group = grpRisk, step = 0.05, minval = 0.0)
maxTradeBars    = input.int(150, "Max Setup Duration (bars) Before Auto-Close", group = grpRisk, minval = 5,
     tooltip = "Safety limit - if a setup never reaches TP or SL within this many bars, it is force-closed so the reward/risk boxes stop growing forever.")
oneTradeAtATime = input.bool(true, "Only One Active Setup At A Time", group = grpRisk,
     tooltip = "Keeps the chart clean like the reference image: a new Entry/SL/TP setup is only drawn after the previous one has hit its TP or SL.")

showFVGBoxes    = input.bool(true, "Show FVG Boxes", group = grpDisp)
showFVGText     = input.bool(true, "Show 'FVG' Text On Boxes", group = grpDisp)
bullFillColor   = input.color(color.new(color.teal, 80), "Bullish FVG Fill", group = grpDisp)
bearFillColor   = input.color(color.new(color.red, 80), "Bearish FVG Fill", group = grpDisp)
bullBorderColor = input.color(color.new(color.teal, 0), "Bullish FVG Border", group = grpDisp)
bearBorderColor = input.color(color.new(color.red, 0), "Bearish FVG Border", group = grpDisp)
usedFillColor   = input.color(color.new(color.gray, 85), "Mitigated FVG Fill", group = grpDisp)
entryColor      = input.color(color.blue, "Entry Line Color", group = grpDisp)
slColor         = input.color(color.red, "Stop Loss Line Color", group = grpDisp)
tpColor         = input.color(color.green, "Take Profit Line Color", group = grpDisp)
rewardZoneColor = input.color(color.new(color.teal, 75), "Reward Zone Fill (Entry -> TP)", group = grpDisp)
riskZoneColor   = input.color(color.new(color.red, 80), "Risk Zone Fill (Entry -> SL)", group = grpDisp)

enableAlerts = input.bool(true, "Enable Alerts", group = grpAlert)

// ------------------------------------------------------------------------------------------
// DATA TYPE : one Fair Value Gap zone
// ------------------------------------------------------------------------------------------
type FVGZone
    box   zbox
    float top
    float bottom
    bool  isBull
    int   leftBar

var array<FVGZone> fvgZones = array.new<FVGZone>()

// ------------------------------------------------------------------------------------------
// SERIES
// ------------------------------------------------------------------------------------------
atrVal = ta.atr(atrLen)

bool buySignal  = false
bool sellSignal = false

// ------------------------------------------------------------------------------------------
// TRADE STATE  (used when "Only One Active Setup At A Time" is enabled)
// ------------------------------------------------------------------------------------------
var bool  tradeActive  = false
var bool  tradeIsBuy   = false
var float tradeSL      = na
var float tradeTP      = na
var box   rewardBox    = na
var box   riskBox      = na
var int   tradeStartBar = na

// close out the active trade once price reaches its TP or SL, freeing the chart for the next setup
if tradeActive
    // keep growing the reward/risk zone boxes to the right, like a Long/Short Position drawing
    if not na(rewardBox)
        box.set_right(rewardBox, bar_index)
    if not na(riskBox)
        box.set_right(riskBox, bar_index)
    if tradeIsBuy
        if high >= tradeTP or low <= tradeSL
            tradeActive := false
    else
        if low <= tradeTP or high >= tradeSL
            tradeActive := false
    if tradeActive and not na(tradeStartBar) and (bar_index - tradeStartBar) > maxTradeBars
        tradeActive := false

allowNewSetup = not oneTradeAtATime or not tradeActive

// ------------------------------------------------------------------------------------------
// STEP 1 : DETECT NEW FAIR VALUE GAPS  (classic 3-candle imbalance)
// ------------------------------------------------------------------------------------------
bullGapRaw = low > high[2]
bearGapRaw = high < low[2]

bullGapSize = bullGapRaw ? (low - high[2]) : na
bearGapSize = bearGapRaw ? (low[2] - high) : na

bullSizeOK = not useATRFilter or (bullGapSize >= atrVal * atrMult)
bearSizeOK = not useATRFilter or (bearGapSize >= atrVal * atrMult)

// displacement filter : the middle candle must be a strong, directional, impulsive candle
bullDispOK = not requireDisplacement or (close[1] > open[1] and (close[1] - open[1]) >= atrVal * displacementMult)
bearDispOK = not requireDisplacement or (close[1] < open[1] and (open[1] - close[1]) >= atrVal * displacementMult)

bullSizeOK := bullSizeOK and bullDispOK
bearSizeOK := bearSizeOK and bearDispOK

if bullGapRaw and bullSizeOK and not na(atrVal)
    float gTop = low
    float gBot = high[2]
    box b = na
    if showFVGBoxes
        b := box.new(bar_index - 2, gTop, bar_index, gBot,
             border_color = bullBorderColor, border_width = 1,
             bgcolor = bullFillColor,
             text = showFVGText ? "FVG" : "",
             text_color = color.black, text_size = size.tiny,
             text_halign = text.align_center, text_valign = text.align_center)
    array.push(fvgZones, FVGZone.new(b, gTop, gBot, true, bar_index - 2))

if bearGapRaw and bearSizeOK and not na(atrVal)
    float gTop = low[2]
    float gBot = high
    box b = na
    if showFVGBoxes
        b := box.new(bar_index - 2, gTop, bar_index, gBot,
             border_color = bearBorderColor, border_width = 1,
             bgcolor = bearFillColor,
             text = showFVGText ? "FVG" : "",
             text_color = color.black, text_size = size.tiny,
             text_halign = text.align_center, text_valign = text.align_center)
    array.push(fvgZones, FVGZone.new(b, gTop, gBot, false, bar_index - 2))

// keep the active list from growing forever - drop the oldest zone once the limit is hit
while array.size(fvgZones) > maxActiveFVGs
    FVGZone oldZone = array.shift(fvgZones)
    if not na(oldZone.zbox)
        box.delete(oldZone.zbox)

// ------------------------------------------------------------------------------------------
// STEP 2 : MANAGE EXISTING FVGs -> extend box, expire old ones, detect price re-entry
//          ("market goes back into the FVG") and build the Entry / SL / TP setup
// ------------------------------------------------------------------------------------------
int zCount = array.size(fvgZones)
for i = zCount - 1 to 0
    if i < 0 or i >= array.size(fvgZones)
        continue
    FVGZone zone = array.get(fvgZones, i)

    if not na(zone.zbox)
        box.set_right(zone.zbox, bar_index)

    bool tooOld = (bar_index - zone.leftBar) > maxFVGAgeBars
    bool remove = false

    if tooOld
        remove := true
    else
        if zone.isBull
            // bullish FVG acts as support - watch for price dipping back into it
            bool touched = low <= zone.top
            if touched
                remove := true
                if close < zone.bottom
                    // price closed straight through the zone -> invalidated, no setup
                    if not na(zone.zbox)
                        box.delete(zone.zbox)
                else
                    // ---- BUY SETUP ----
                    float entryPrice = close
                    float slPrice    = zone.bottom - atrVal * slBufferATRMult
                    float riskPts    = entryPrice - slPrice
                    if riskPts > 0 and allowNewSetup
                        float tpPrice = entryPrice + riskPts * riskReward
                        // reward zone (green) : entry -> TP, and risk zone (red) : entry -> SL
                        // drawn exactly like a "Long Position" tool - the boxes keep growing
                        // to the right every bar while this trade is active
                        rewardBox := box.new(bar_index, tpPrice, bar_index, entryPrice, border_width = 0, bgcolor = rewardZoneColor)
                        riskBox   := box.new(bar_index, entryPrice, bar_index, slPrice, border_width = 0, bgcolor = riskZoneColor)
                        label.new(bar_index, entryPrice, "BUY ENTRY\n" + str.tostring(entryPrice, format.mintick), style = label.style_label_up, color = entryColor, textcolor = color.white, size = size.small)
                        label.new(bar_index, tpPrice, "TP " + str.tostring(tpPrice, format.mintick), style = label.style_label_down, color = tpColor, textcolor = color.white, size = size.tiny)
                        label.new(bar_index, slPrice, "SL " + str.tostring(slPrice, format.mintick), style = label.style_label_up, color = slColor, textcolor = color.white, size = size.tiny)
                        buySignal := true
                        tradeActive := true
                        tradeIsBuy  := true
                        tradeSL     := slPrice
                        tradeTP     := tpPrice
                        tradeStartBar := bar_index
                        if not na(zone.zbox)
                            box.set_bgcolor(zone.zbox, usedFillColor)
                    if not na(zone.zbox)
                        box.set_extend(zone.zbox, extend.none)
        else
            // bearish FVG acts as resistance - watch for price rallying back into it
            bool touched = high >= zone.bottom
            if touched
                remove := true
                if close > zone.top
                    // price closed straight through the zone -> invalidated, no setup
                    if not na(zone.zbox)
                        box.delete(zone.zbox)
                else
                    // ---- SELL SETUP ----
                    float entryPrice = close
                    float slPrice    = zone.top + atrVal * slBufferATRMult
                    float riskPts    = slPrice - entryPrice
                    if riskPts > 0 and allowNewSetup
                        float tpPrice = entryPrice - riskPts * riskReward
                        // reward zone (green) : TP -> entry, and risk zone (red) : entry -> SL
                        rewardBox := box.new(bar_index, entryPrice, bar_index, tpPrice, border_width = 0, bgcolor = rewardZoneColor)
                        riskBox   := box.new(bar_index, slPrice, bar_index, entryPrice, border_width = 0, bgcolor = riskZoneColor)
                        label.new(bar_index, entryPrice, "SELL ENTRY\n" + str.tostring(entryPrice, format.mintick), style = label.style_label_down, color = entryColor, textcolor = color.white, size = size.small)
                        label.new(bar_index, tpPrice, "TP " + str.tostring(tpPrice, format.mintick), style = label.style_label_up, color = tpColor, textcolor = color.white, size = size.tiny)
                        label.new(bar_index, slPrice, "SL " + str.tostring(slPrice, format.mintick), style = label.style_label_down, color = slColor, textcolor = color.white, size = size.tiny)
                        sellSignal := true
                        tradeActive := true
                        tradeIsBuy  := false
                        tradeSL     := slPrice
                        tradeTP     := tpPrice
                        tradeStartBar := bar_index
                        if not na(zone.zbox)
                            box.set_bgcolor(zone.zbox, usedFillColor)
                    if not na(zone.zbox)
                        box.set_extend(zone.zbox, extend.none)

    if remove
        array.remove(fvgZones, i)

// ------------------------------------------------------------------------------------------
// STEP 3 : SIGNAL MARKERS
// ------------------------------------------------------------------------------------------
plotshape(buySignal, title = "Buy Signal", location = location.belowbar, style = shape.triangleup, color = entryColor, size = size.tiny)
plotshape(sellSignal, title = "Sell Signal", location = location.abovebar, style = shape.triangledown, color = entryColor, size = size.tiny)

// ------------------------------------------------------------------------------------------
// STEP 4 : ALERTS  (works on any market / any timeframe)
// ------------------------------------------------------------------------------------------
if enableAlerts and buySignal
    alert("SMC Entry Setups: BUY setup triggered on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar)
if enableAlerts and sellSignal
    alert("SMC Entry Setups: SELL setup triggered on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar)

alertcondition(buySignal, title = "SMC Bullish FVG Entry", message = "SMC Entry Setups: Buy setup triggered - check chart for Entry/SL/TP levels.")
alertcondition(sellSignal, title = "SMC Bearish FVG Entry", message = "SMC Entry Setups: Sell setup triggered - check chart for Entry/SL/TP levels.")
````
