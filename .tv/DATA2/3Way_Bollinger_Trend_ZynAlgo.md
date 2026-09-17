<!-- tradingview-pine-id: PUB;a8e2fc05a2d34dc9ac92da678ea7cd1d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 3-Way Bollinger Trend [ZynAlgo]

Source: https://www.tradingview.com/script/LM69E8gZ-3-Way-Bollinger-Trend-ZynAlgo/

## Description

1. Overview
3-Way Bollinger Trend combines 3 layers of analysis into a single price band, rather than relying on a plain moving average: a fast center line, a volatility band (classic Bollinger-style, auto widening/narrowing with recent volatility), and momentum-based coloring (Bullish / Bearish / Sideway). On top of this it generates signals with a "pullback to the center line" logic - not a reversal-at-the-band-edge approach - to catch pullback continuations within a trend rather than only tops and bottoms.
https://www.tradingview.com/x/Fv0RCpQK/

2. The Three Components

[*]Center line - reacts quickly to price with clearly less lag than a same-length standard moving average, while staying smooth enough to avoid noise. Band Settings -> HMA Length (default 20).
[*]Volatility band - width reflects recent volatility; one single band tier (no inner/outer). Band Settings -> Band Width (x StDev) (default 2.0).
[*]Momentum-based coloring - the center line and band both change color with the momentum state: Green = BULLISH (strong upward momentum), Red = BEARISH (strong downward momentum), Yellow = SIDEWAY (direction unclear). RSI Settings -> Bullish above / Bearish below. These thresholds do not just change color - they decide which trade direction is allowed (see section 3).

https://www.tradingview.com/x/5SivnsVv/

3. Reading the Signal

[*]Pullback logic - the signal is built in two stages. Trigger: price closes back on the trend side of the center line. Confirmation: price holds on that side for a set number of extra bars (Signal Settings -> Confirmation Bars) without crossing back. Only when both complete does the signal fire; a cross-back during confirmation cancels it and a fresh Trigger is required.
[*]Why confirmation - crossing the center line is a frequent event, so firing instantly would expose it to whipsaws. Confirmation is the only filter used; no candle-shape pattern (pin bar, engulfing) is required.
[*]Effective Trend (most misunderstood) - the indicator remembers the most recent official trend whenever momentum reads clearly Bullish or Bearish. In the Sideway zone it does NOT clear that memory - it keeps using the last recorded trend to decide direction. Bullish -> only Buy allowed; Bearish -> only Sell allowed; Sideway -> follows the last effective trend. Sideway does not mean both directions are open.
[*]Entry & Stop - Entry is the open of the bar immediately after the final confirmation bar (never the signal bar). Stop is an ATR distance from entry, computed at the confirmation bar, not from candle wicks. Signal Settings -> SL Distance (x ATR).

https://www.tradingview.com/x/fnNJT5Zr/

4. Take Profit & R-Multiple Management

[*]Three R-based targets (R = the SL distance): TP1 = 1.0R (always on), TP2 = 2.0R (Enable TP2), TP3 = 3.0R (Enable TP3).
[*]Automatic trailing stop: TP1 hit -> SL to breakeven; TP2 hit -> SL up to TP1.
[*]Time-based exit: a trade open too long (default 200 bars) without hitting SL or the final TP closes as a TIMEOUT - neither win nor loss.
[*]Adjustable under Risk & Reward (TP1/TP2/TP3, Enable TP2/TP3, Max Trade Duration).

5. Trade Mode - the Master Switch

[*]OFF (default) - center line and colored band stay visible; signal arrows still fire with a hover explanation; Stability Mode and Smart Signal Filter are bypassed; no SL/TP boxes or Win Rate/PF tracking. Best for observing before live trading.
[*]ON - center line and band hidden; full SL/TP boxes with a real-time trailing SL line; Stability Mode and Smart Signal Filter take effect; dashboard adds Trades / Win Rate / Profit Factor. Best for simulating real trading performance.

6. Execution Filters (active only when Trade Mode is ON)

[*]Stability Mode (default On) - blocks new signals while a trade is already open.
[*]Smart Signal Filter (default Off) - forces Buy/Sell to alternate.
[*]Cooldown (Bars) (default 5) - minimum spacing between two consecutive signals.

7. Dashboard

[*]RSI - current momentum reading.
[*]Momentum Zone - BULLISH / BEARISH / SIDEWAY (color-coded).
[*]Trades (Trade Mode ON) - total trades recorded.
[*]Win Rate / PF (Trade Mode ON) - win rate and Profit Factor. A breakeven exit counts as 0.5 of a win; Profit Factor is unaffected since a breakeven trade adds 0 to both profit and loss.

Dashboard position and text size are adjustable under Display / Dashboard.

8. Alerts

[*]Reversal Buy - fires when a Buy signal is officially confirmed.
[*]Reversal Sell - fires when a Sell signal is officially confirmed.

9. Notes

[*]The Trades / Win Rate / Profit Factor figures come from an internal, non-executed simulation over the visible history on the chart. They are a study of the settings on past data - not a backtest, not a broker report, and not indicative of future results.
[*]No candle-shape requirement - the signal is defined only by the Trigger + Confirmation pairing described above.
[*]All signal logic processes fully closed bars only, never a still-forming bar, so signals do not repaint.
[*]Sideway does not mean fully neutral - always check the last effective trend (section 3) before wondering why a yellow band only shows Sell or Buy.
[*]This indicator is a tool for study and education, not financial advice, and does not guarantee any trading outcome. Always apply your own analysis and risk management.

10. Practical Tips

[*]New to it? Keep Trade Mode off for a while, watch when the arrows appear, and read the hover explanations first.
[*]Market whipsawing around the center line? Raise Confirmation Bars to 3-4 to filter more false signals.
[*]Want fewer, higher-conviction signals? Increase Cooldown (Bars) and consider enabling Smart Signal Filter.
[*]SL too wide or tight for the instrument? Adjust SL Distance (x ATR) - it drives the whole R-multiple TP structure.

---

## Source Code

````pine
//@version=6
indicator("3-Way Bollinger Trend [ZynAlgo]", shorttitle="3-Way Bollinger Trend [ZynAlgo]", overlay=true, max_lines_count=100, max_labels_count=200, max_boxes_count=200)

// =============================================================================
// 1. INPUTS
// =============================================================================
grp_mode = "Toggles & UI Mode"
tradeMode = input.bool(false, "Enable Trade Mode", group=grp_mode, tooltip="OFF: bands stay visible, signal marker still fires with a reason tooltip, Stability Mode / Smart Signal Filter are bypassed, no box/SL-TP tracking. ON: full position box + trailing SL + Win Rate/PF tracking activates, and Stability Mode / Smart Signal Filter start actually gating entries.")

grp_band = "Band Settings"
hmaLength      = input.int(20, "HMA Length (center line)", minval=2, group=grp_band, tooltip="Hull MA reacts faster than a same-length SMA/TMA - chosen specifically to reduce lag while still smoothing price.")
bandStdevMult  = input.float(2.0, "Band Width (x StDev)", minval=0.5, step=0.1, group=grp_band, tooltip="Bands = HMA +/- this many standard deviations of price over the same length as the HMA - the same construction as a classic Bollinger Band, just centered on the HMA instead of an SMA.")

grp_rsi = "RSI Settings"
rsiLength          = input.int(14, "RSI Length", minval=2, group=grp_rsi)
rsiColorUpper      = input.float(55, "Bullish above (also used as trend filter)", minval=51, maxval=99, group=grp_rsi, tooltip="RSI above this turns the band/center line green (bullish) - this same threshold now also blocks Sell signals while active.")
rsiColorLower      = input.float(45, "Bearish below (also used as trend filter)", minval=1, maxval=49, group=grp_rsi, tooltip="RSI below this turns the band/center line red (bearish) - this same threshold now also blocks Buy signals while active. Between the two thresholds, the band is neutral gray and both directions are allowed.")

grp_signal = "Signal Settings"
confirmBars  = input.int(2, "Confirmation Bars", minval=1, group=grp_signal, tooltip="After price closes back on the trend side of the HMA (the trigger), this many MORE consecutive bars must also stay on that side before the signal actually fires. If price crosses back to the wrong side at any point during this window, the setup is cancelled. This exists specifically to filter out whipsaw noise from price flickering across the HMA.")
slAtrMult    = input.float(1.5, "SL Distance (x ATR)", minval=0.1, step=0.1, group=grp_signal, tooltip="SL = entry price minus/plus this many ATR(14) - no longer based on any candle wick.")

grp_display = "Display"
string uiSizeInput = input.string("Small", "UI Text Size (chart + dashboard)", options=["Tiny", "Small", "Normal", "Large"], group=grp_display)

grp_risk = "Risk & Reward"
tp1R               = input.float(1.0, "TP1 (R)", minval=0.1, step=0.1, group=grp_risk)
tp2R               = input.float(2.0, "TP2 (R)", minval=0.1, step=0.1, group=grp_risk)
tp3R               = input.float(3.0, "TP3 (R)", minval=0.1, step=0.1, group=grp_risk)
enableTP2          = input.bool(true, "Enable TP2", group=grp_risk)
enableTP3          = input.bool(true, "Enable TP3", group=grp_risk)
maxTradeDuration   = input.int(200, "Max Trade Duration (Bars)", minval=10, group=grp_risk)
maxStoredTrades    = input.int(30, "Max Stored Trade Records (history)", minval=5, group=grp_risk)

grp_filters = "Execution Filters"
useStabilityMode    = input.bool(true, "Stability Mode (no new signal while a trade is open)", group=grp_filters)
useSmartFilter      = input.bool(false, "Smart Signal Filter (force alternating Buy/Sell)", group=grp_filters)
reversalLockBars    = input.int(5, "Cooldown (Bars) - min bars before the next signal", minval=0, group=grp_filters, tooltip="After a signal fires, this many bars must pass before the next one is allowed - a simple spacing filter that keeps rapid back-to-back signals from firing.")

grp_dash = "Dashboard"
string dashCornerInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_dash)

uiSize  = uiSizeInput == "Tiny" ? size.tiny : uiSizeInput == "Normal" ? size.normal : uiSizeInput == "Large" ? size.large : size.small
dashPos = dashCornerInput == "Top Left" ? position.top_left : dashCornerInput == "Bottom Right" ? position.bottom_right : dashCornerInput == "Bottom Left" ? position.bottom_left : position.top_right

// =============================================================================
// 2. HMA CENTER + VOLATILITY BANDS
// =============================================================================
float atrVal = ta.atr(14)

float hmaCenter = ta.hma(close, hmaLength)
float priceStdev = ta.stdev(close, hmaLength)
float bandUpper = hmaCenter + bandStdevMult * priceStdev
float bandLower = hmaCenter - bandStdevMult * priceStdev

// =============================================================================
// 3. RSI + MOMENTUM COLOR
// =============================================================================
float rsiValue = ta.rsi(close, rsiLength)

color bandColor = rsiValue > rsiColorUpper ? color.new(#1a935b, 0) : rsiValue < rsiColorLower ? color.new(#ff4757, 0) : color.new(color.yellow, 0)

plot(not tradeMode ? hmaCenter : na, title="HMA Center", color=bandColor, linewidth=2)
p1 = plot(not tradeMode ? bandUpper : na, title="Upper Band", color=bandColor, linewidth=1)
p2 = plot(not tradeMode ? bandLower : na, title="Lower Band", color=bandColor, linewidth=1)
fill(p1, p2, color=color.new(bandColor, 92), title="Band Fill")

// =============================================================================
// 4. SIGNAL — Pullback to the HMA center line, not a reversal at the outer band. Trigger: price
//    crosses back to the trend side of the HMA. Confirmation: holds there for confirmBars more
//    bars (filters whipsaw around the HMA). Direction allowed is gated by the EFFECTIVE trend:
//    bullish (green) -> Buy only; bearish (red) -> Sell only; Sideway (yellow) -> carries over
//    whichever trend was last established (does not reset to "either direction").
//    Everything here is gated by barstate.isconfirmed - without it, the confirmation counter and
//    the trend-color read could each be evaluated multiple times against still-forming (not yet
//    closed) bar data as new ticks arrive on the live bar, letting a signal fire against a stale/
//    mid-formation band color.
// =============================================================================
var bool awaitingConfirmBuy  = false
var bool awaitingConfirmSell = false
var int  confirmCounter      = 0
var int  lastTrendDir        = 0    // 1 = bullish, -1 = bearish, 0 = no trend established yet
var bool reversalBuyRaw      = false
var bool reversalSellRaw     = false

if barstate.isconfirmed
    bool bandBullish = rsiValue > rsiColorUpper
    bool bandBearish = rsiValue < rsiColorLower

    // Sideway (neither bullish nor bearish) leaves lastTrendDir untouched, so it carries over
    // whichever trend color was last seen instead of resetting to "no bias".
    if bandBullish
        lastTrendDir := 1
    else if bandBearish
        lastTrendDir := -1

    bool triggerBuy  = close > hmaCenter and close[1] <= hmaCenter[1]
    bool triggerSell = close < hmaCenter and close[1] >= hmaCenter[1]

    if triggerBuy
        awaitingConfirmBuy  := true
        awaitingConfirmSell := false
        confirmCounter := 0
    else if triggerSell
        awaitingConfirmSell := true
        awaitingConfirmBuy  := false
        confirmCounter := 0
    else if awaitingConfirmBuy
        if close <= hmaCenter
            awaitingConfirmBuy := false
            confirmCounter := 0
        else
            confirmCounter += 1
    else if awaitingConfirmSell
        if close >= hmaCenter
            awaitingConfirmSell := false
            confirmCounter := 0
        else
            confirmCounter += 1

    bool confirmedBuy  = awaitingConfirmBuy  and confirmCounter >= confirmBars
    bool confirmedSell = awaitingConfirmSell and confirmCounter >= confirmBars

    if confirmedBuy
        awaitingConfirmBuy := false
        confirmCounter := 0
    if confirmedSell
        awaitingConfirmSell := false
        confirmCounter := 0

    bool trendOkBuy  = lastTrendDir == 1
    bool trendOkSell = lastTrendDir == -1

    reversalBuyRaw  := confirmedBuy  and trendOkBuy
    reversalSellRaw := confirmedSell and trendOkSell
else
    reversalBuyRaw  := false
    reversalSellRaw := false

// =============================================================================
// 5. STATE — TRADES (parallel arrays, one slot per concurrent trade)
// =============================================================================
var int  lastSignalBar = na
var int  lastSignalDir = 0
var bool anyTradeOpen  = false

var array<float> tEntry            = array.new_float(0)
var array<float> tSL               = array.new_float(0)
var array<float> tR                = array.new_float(0)
var array<bool>  tIsBuy            = array.new_bool(0)
var array<int>   tEntryBar         = array.new_int(0)
var array<int>   tMaxTp            = array.new_int(0)
var array<bool>  tActive           = array.new_bool(0)
var array<float> tHighestTpPrice   = array.new_float(0)
var array<int>   tHighestTpBar     = array.new_int(0)
var array<box>   tRewardBox        = array.new_box(0)
var array<box>   tRiskBox          = array.new_box(0)
var array<line>  tEntryLine        = array.new_line(0)
var array<line>  tStopLine         = array.new_line(0)
var array<label> tEntryLabel       = array.new_label(0)

var int   totalTrades  = 0
var float totalWins    = 0.0   // float: breakeven exits bank as 0.5
var int   totalLosses  = 0
var float totalProfitR = 0.0
var float totalLossR   = 0.0

var int   pendingDir      = 0
var int   pendingEntryBar = na

// Filtered fire flags exposed to alertcondition so the alert matches the on-chart
// marker exactly (fires only after cooldown / stability / smart-filter gating).
var bool  sigFireBuy      = false
var bool  sigFireSell     = false

// =============================================================================
// 6. SIGNAL FILTERS + ENTRY (Trade Mode = master switch)
// =============================================================================
if barstate.isconfirmed
    bool cooldownOk       = na(lastSignalBar) or (bar_index - lastSignalBar) >= reversalLockBars
    bool stabilityAllowed = not tradeMode or not (useStabilityMode and anyTradeOpen)
    bool smartBuyAllowed  = not tradeMode or not (useSmartFilter and lastSignalDir == 1)
    bool smartSellAllowed = not tradeMode or not (useSmartFilter and lastSignalDir == -1)

    bool fireBuy  = reversalBuyRaw  and cooldownOk and stabilityAllowed and smartBuyAllowed
    bool fireSell = reversalSellRaw and cooldownOk and stabilityAllowed and smartSellAllowed

    // Expose the FILTERED fire to the alerts so an alert never fires without a matching
    // on-chart marker (and vice versa) - same gated event the visual signal uses.
    sigFireBuy  := fireBuy
    sigFireSell := fireSell

    if fireBuy or fireSell
        pendingDir      := fireBuy ? 1 : -1
        pendingEntryBar := bar_index + 1
        lastSignalBar   := bar_index
        lastSignalDir   := pendingDir

    if not na(pendingEntryBar) and bar_index == pendingEntryBar
        float entryPx = open
        bool  isBuy   = pendingDir == 1
        float slDist  = slAtrMult * atrVal
        float slPx    = isBuy ? entryPx - slDist : entryPx + slDist

        if slDist > 0
            float tp1Px = isBuy ? entryPx + tp1R * slDist : entryPx - tp1R * slDist
            float tp2Px = isBuy ? entryPx + tp2R * slDist : entryPx - tp2R * slDist
            float tp3Px = isBuy ? entryPx + tp3R * slDist : entryPx - tp3R * slDist
            float finalTargetPrice = enableTP3 ? tp3Px : enableTP2 ? tp2Px : tp1Px
            float finalTargetR     = enableTP3 ? tp3R : enableTP2 ? tp2R : tp1R

            string labelText  = isBuy ? "▲" : "▼"
            color  labelColor = isBuy ? color.new(#1a935b, 0) : color.new(#ff4757, 0)
            string labelStyle = isBuy ? label.style_label_up : label.style_label_down
            float  labelY     = isBuy ? low - atrVal * 1.0 : high + atrVal * 1.0
            string reasonText = "Pullback " + (isBuy ? "Buy" : "Sell") + " (" + (rsiValue > rsiColorUpper ? "bullish band" : rsiValue < rsiColorLower ? "bearish band" : "sideway band, carrying over the last established trend") + "): price crossed back to the " + (isBuy ? "bullish (above)" : "bearish (below)") + " side of the HMA and held there for " + str.tostring(confirmBars) + " confirmation bar(s) without crossing back"
            label newLbl = label.new(bar_index, labelY, labelText, style=labelStyle, color=labelColor, textcolor=color.white, size=uiSize, tooltip=reasonText)

            if tradeMode
                array.push(tEntry, entryPx)
                array.push(tSL, slPx)
                array.push(tR, slDist)
                array.push(tIsBuy, isBuy)
                array.push(tEntryBar, bar_index)
                array.push(tMaxTp, 0)
                array.push(tActive, true)
                array.push(tHighestTpPrice, entryPx)
                array.push(tHighestTpBar, na)

                box riskBox = box.new(bar_index, isBuy ? entryPx : slPx, bar_index, isBuy ? slPx : entryPx, border_color=color.new(#F5474A, 100), bgcolor=color.new(#F5474A, 82))
                box rewardBox = box.new(bar_index, isBuy ? finalTargetPrice : entryPx, bar_index, isBuy ? entryPx : finalTargetPrice, border_color=color.new(#00D97E, 100), bgcolor=color.new(#00D97E, 86))
                line entryLine = line.new(bar_index, entryPx, bar_index, entryPx, color=color.new(color.white, 65), width=1, style=line.style_dotted)
                line stopLine  = line.new(bar_index, slPx, bar_index, slPx, color=color.new(color.red, 65), width=1, style=line.style_dotted)
                array.push(tRewardBox, rewardBox)
                array.push(tRiskBox, riskBox)
                array.push(tEntryLine, entryLine)
                array.push(tStopLine, stopLine)
                array.push(tEntryLabel, newLbl)

                totalTrades += 1
                anyTradeOpen := true

        pendingEntryBar := na
else
    sigFireBuy  := false
    sigFireSell := false

// =============================================================================
// 7. TRADE MANAGEMENT (multi-trade array loop; Trade Mode ON only)
// =============================================================================
if barstate.isconfirmed and tradeMode and array.size(tActive) > 0
    for i = array.size(tActive) - 1 to 0
        if array.get(tActive, i)
            bool  isBuy      = array.get(tIsBuy, i)
            float entryPx    = array.get(tEntry, i)
            float slOriginal = array.get(tSL, i)
            float rDist      = array.get(tR, i)
            int   maxTp      = array.get(tMaxTp, i)
            int   entryBar   = array.get(tEntryBar, i)

            float tp1Px = isBuy ? entryPx + tp1R * rDist : entryPx - tp1R * rDist
            float tp2Px = isBuy ? entryPx + tp2R * rDist : entryPx - tp2R * rDist
            float finalTargetPrice = enableTP3 ? (isBuy ? entryPx + tp3R * rDist : entryPx - tp3R * rDist) : enableTP2 ? tp2Px : tp1Px
            float finalTargetR     = enableTP3 ? tp3R : enableTP2 ? tp2R : tp1R

            float currentSL = maxTp >= 2 ? tp1Px : maxTp >= 1 ? entryPx : slOriginal
            bool  hitSL          = isBuy ? low <= currentSL : high >= currentSL
            bool  hitFinalTarget = isBuy ? high >= finalTargetPrice : low <= finalTargetPrice

            box  rb = array.get(tRewardBox, i)
            box  rk = array.get(tRiskBox, i)
            line el = array.get(tEntryLine, i)
            line sl_line = array.get(tStopLine, i)
            box.set_right(rb, bar_index)
            box.set_right(rk, bar_index)
            line.set_x2(el, bar_index)
            line.set_x2(sl_line, bar_index)
            line.set_y1(sl_line, currentSL)
            line.set_y2(sl_line, currentSL)

            bool   closeNow = false
            string resultKind = ""
            bool   justReachedNewTp = false

            if hitSL
                closeNow := true
                resultKind := maxTp > 0 ? "TP" : "SL"
            else if hitFinalTarget
                closeNow := true
                resultKind := "WIN"
                array.set(tHighestTpPrice, i, finalTargetPrice)
                array.set(tHighestTpBar, i, bar_index)
            else
                bool hitTp1 = isBuy ? high >= tp1Px : low <= tp1Px
                bool hitTp2 = enableTP2 and (isBuy ? high >= tp2Px : low <= tp2Px)

                if maxTp < 1 and hitTp1
                    maxTp := 1
                    array.set(tMaxTp, i, 1)
                    array.set(tHighestTpPrice, i, tp1Px)
                    array.set(tHighestTpBar, i, bar_index)
                    justReachedNewTp := true
                if maxTp == 1 and hitTp2
                    maxTp := 2
                    array.set(tMaxTp, i, 2)
                    array.set(tHighestTpPrice, i, tp2Px)
                    array.set(tHighestTpBar, i, bar_index)
                    justReachedNewTp := true

                bool timedOut = (bar_index - entryBar) >= maxTradeDuration
                if timedOut
                    closeNow := true
                    resultKind := "TIMEOUT"

            if justReachedNewTp and not closeNow
                label.new(bar_index, isBuy ? high : low, "TP" + str.tostring(array.get(tMaxTp, i)), style=label.style_none, textcolor=color.new(#00D97E, 0), size=size.tiny, yloc=isBuy ? yloc.abovebar : yloc.belowbar)

            if closeNow
                array.set(tActive, i, false)

                bool  cleanLoss = resultKind == "SL" and array.get(tMaxTp, i) == 0
                float rResult   = resultKind == "WIN" ? finalTargetR : array.get(tMaxTp, i) >= 2 ? tp1R : 0.0

                if resultKind == "SL" or resultKind == "WIN" or resultKind == "TP"
                    if cleanLoss
                        totalLosses += 1
                        totalLossR  += 1.0
                    else
                        totalWins    += rResult == 0.0 ? 0.5 : 1.0
                        totalProfitR += rResult

                string rSign = rResult >= 0 ? "+" : ""
                string resText = resultKind == "SL" ? "SL -1R" : resultKind == "WIN" ? "WIN +" + str.tostring(rResult, "#.#") + "R" : resultKind == "TIMEOUT" ? "TIMEOUT" : "TP " + rSign + str.tostring(rResult, "#.#") + "R"
                string barsText = str.tostring(bar_index - entryBar) + " bars"
                label entryLbl = array.get(tEntryLabel, i)
                if not na(entryLbl)
                    label.set_tooltip(entryLbl, resText + "\n" + barsText)

                int achievedBar = na(array.get(tHighestTpBar, i)) ? bar_index : array.get(tHighestTpBar, i)
                float achievedPrice = array.get(tHighestTpPrice, i)
                box.set_right(rb, achievedBar)
                box.set_right(rk, achievedBar)
                if isBuy
                    box.set_top(rb, achievedPrice)
                    box.set_bottom(rb, entryPx)
                else
                    box.set_top(rb, entryPx)
                    box.set_bottom(rb, achievedPrice)
                // risk box height intentionally NOT trimmed (rule 3.2) - right edge only

                if resultKind == "SL" and cleanLoss
                    label.new(bar_index, isBuy ? low : high, "x", style=label.style_none, textcolor=color.new(#EF4444, 0), size=size.small, yloc=isBuy ? yloc.belowbar : yloc.abovebar)

    bool stillOpen = false
    if array.size(tActive) > 0
        for k = 0 to array.size(tActive) - 1
            if array.get(tActive, k)
                stillOpen := true
    anyTradeOpen := stillOpen

    if array.size(tActive) > maxStoredTrades
        if not array.get(tActive, 0)
            box  b1 = array.get(tRewardBox, 0)
            box  b2 = array.get(tRiskBox, 0)
            line l1 = array.get(tEntryLine, 0)
            line l2 = array.get(tStopLine, 0)
            if not na(b1)
                box.delete(b1)
            if not na(b2)
                box.delete(b2)
            if not na(l1)
                line.delete(l1)
            if not na(l2)
                line.delete(l2)
            array.shift(tEntry)
            array.shift(tSL)
            array.shift(tR)
            array.shift(tIsBuy)
            array.shift(tEntryBar)
            array.shift(tMaxTp)
            array.shift(tActive)
            array.shift(tHighestTpPrice)
            array.shift(tHighestTpBar)
            array.shift(tRewardBox)
            array.shift(tRiskBox)
            array.shift(tEntryLine)
            array.shift(tStopLine)
            array.shift(tEntryLabel)

// =============================================================================
// 8. DASHBOARD
// =============================================================================
var table dash = table.new(dashPos, 2, 6, bgcolor=color.new(#131722, 10), border_width=1)

if barstate.islast
    string rsiZoneText  = rsiValue > rsiColorUpper ? "BULLISH" : rsiValue < rsiColorLower ? "BEARISH" : "SIDEWAY"
    color  rsiZoneColor = rsiValue > rsiColorUpper ? color.new(#1a935b, 0) : rsiValue < rsiColorLower ? color.new(#ff4757, 0) : color.new(color.yellow, 0)

    table.cell(dash, 0, 0, "3-WAY BOLL TREND", text_color=color.white, text_size=uiSize, bgcolor=color.new(#2962ff, 20))
    table.cell(dash, 1, 0, "", bgcolor=color.new(#2962ff, 20))

    table.cell(dash, 0, 1, "RSI", text_color=color.gray, text_size=uiSize)
    table.cell(dash, 1, 1, str.tostring(rsiValue, "#.#"), text_color=rsiZoneColor, text_size=uiSize)

    table.cell(dash, 0, 2, "Momentum Zone", text_color=color.gray, text_size=uiSize)
    table.cell(dash, 1, 2, rsiZoneText, text_color=rsiZoneColor, text_size=uiSize)

    if tradeMode
        float winRate = (totalWins + totalLosses) > 0 ? (totalWins / (totalWins + totalLosses)) * 100.0 : 0.0
        float pf = totalLossR > 0 ? totalProfitR / totalLossR : totalProfitR > 0 ? 999.0 : 0.0

        table.cell(dash, 0, 3, "Trades", text_color=color.gray, text_size=uiSize)
        table.cell(dash, 1, 3, str.tostring(totalTrades), text_color=color.white, text_size=uiSize)

        table.cell(dash, 0, 4, "Win Rate / PF", text_color=color.gray, text_size=uiSize)
        table.cell(dash, 1, 4, str.tostring(winRate, "#.#") + "% / " + str.tostring(pf, "#.##"), text_color=winRate >= 50 ? color.new(#10B981, 0) : color.new(#EF4444, 0), text_size=uiSize)

// =============================================================================
// 9. ALERTS
// =============================================================================
alertcondition(sigFireBuy,  title="3-Way Bollinger Trend Reversal Buy",  message="3-Way Bollinger Trend [ZynAlgo]: Reversal BUY on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(sigFireSell, title="3-Way Bollinger Trend Reversal Sell", message="3-Way Bollinger Trend [ZynAlgo]: Reversal SELL on {{ticker}} ({{interval}}) at {{close}}")
````
