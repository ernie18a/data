<!-- tradingview-pine-id: PUB;d41bfb9067f84eb78c51793cb4943bc5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Breakout Failure Radar

Source: https://www.tradingview.com/script/UUftcSTg/

## Description

Breakout Failure Radar
Follow the breakout. Keep the original level. Recognize when the structure fails.

Breakout Failure Radar tracks what happens after a price-channel breakout. It freezes the original breakout level and volatility reference, then monitors whether price holds a retest or closes back through the failure threshold.

READ THE COLORS

Blue B+ / B− — Breakout detected
A new upward or downward breakout enters observation.

Green R+ / R− — Retest held
Price touches the frozen retest zone and closes back on the breakout side. Monitoring continues.

Orange F+ / F− — Breakout failed
Price closes beyond the failure threshold on the opposite side of the original level.

Gray square — Window complete
The observation window ends without a defined failure. This does not indicate a profitable trade.

The + and − signs always refer to the original breakout direction. F+ identifies a failed upward breakout; F− identifies a failed downward breakout.

HOW A BREAKOUT IS DETECTED

The default channel uses the highest high and lowest low of the previous 20 completed candles. The current candle is excluded.

An upward breakout requires:
• A close more than 0.10 ATR14 above the upper channel.
• The previous close to have been at or below its own previous upper channel.

Downward breakouts use the opposite conditions.

The channel boundary and ATR are frozen when the breakout is confirmed. Later price movements do not move these reference values.

RETEST OR FAILURE?

The default observation window covers the next five candles, excluding the breakout candle.

The retest zone extends 0.25 frozen ATR on either side of the original level. A held retest requires the candle’s range to intersect this zone and its close to finish more than 0.10 frozen ATR on the original breakout side.

A failure occurs when price closes more than 0.10 frozen ATR on the opposite side of the original level.

A held retest does not end the observation. The same breakout can hold a retest and still fail later.

WORKED EXAMPLE
Hypothetical prices using the default settings.

An upward breakout freezes a level of 100 and an ATR of 4. Price closes at 102, satisfying the breakout conditions.

• Retest zone: 99 to 101.
• Held retest: The candle touches this zone and closes above 100.40.
• Failure: A subsequent candle closes below 99.60 within the observation window.
• Still unresolved: A close at 99.80 is below the original level but has not crossed the failure threshold.

The buffers distinguish a small move around the level from a confirmed condition. They do not guarantee that price will continue or reverse.

MONITORING RULES

• Only one breakout is monitored at a time. Additional breakouts during an active observation are ignored.
• A held retest is reported only once per setup.
• A gap that skips the entire retest zone does not count as a touch.
• Failure takes priority over window completion on the final observation candle.
• A first held retest and window completion can occur on the same final candle.
• A new observation can start no earlier than the candle after the previous observation ends.
• A rejected crossing is not automatically activated later; a fresh channel crossing is required.

DISPLAY AND ALERTS

The frozen level and retest zone are displayed through the observation’s final candle. Historical markers remain on the candles where their conditions were confirmed.

The status panel shows:
• Original breakout direction and latest status.
• Frozen breakout level.
• Number of candles monitored.
• Distance from the latest confirmed close to the frozen level, measured in frozen ATR. Positive values indicate the original breakout side.
• Whether a held retest occurred during the observation.

Five alert conditions are available:
1. New breakout under observation.
2. Retest held.
3. Upward breakout failed.
4. Downward breakout failed.
5. Monitoring window complete.

Choose Once Per Bar Close when creating alerts.

CONFIRMED-CANDLE BEHAVIOR

State changes and event markers are confirmed at candle close. The script does not use future candles, backdated signals or lookahead requests.

Historical data corrections, changes to chart history and different input settings can still change historical results. Use standard candles for interpreting the price-based rules.

RESEARCH AND LIMITATIONS

The default rules were examined on daily BTC, ETH, SOL, BNB and XRP USD histories from January 2021 through September 10, 2026.

The proportion of completed observations meeting the failure definition was:
• 2021–2023: 44.93% across 276 observations.
• 2024–2025: 46.63% across 178 observations.
• 2026: 55.38% across 65 observations.

These figures describe how frequently the chosen failure condition occurred. They are not prediction accuracy or trading win rates.

Average price movement after a warning changed direction between the examined periods. The study therefore did not establish a stable advantage from automatically trading against failed breakouts.

The analysis does not model portfolio exposure, execution costs, funding, stop-losses or actual fills. The five cryptocurrencies are a selected and correlated sample.

The indicator can calculate on stocks and other timeframes, but this research covers cryptocurrency daily candles with the default settings only.

WHAT MAKES THIS TOOL DISTINCT

The implementation combines a Donchian-style channel and Wilder ATR with frozen reference levels, a defined observation window and continued monitoring after a held retest. Each component serves the specific purpose of tracking how an individual breakout develops.

It operates independently of Crypto Breakout Compass and does not import that indicator’s signals.

Breakout Failure Radar is a market-structure monitoring tool. A failure warning identifies a condition that has already occurred; it is not an automatic instruction to enter the opposite trade.

---

## Source Code

````pine
//@version=6
// Original implementation for BotTradeLab. Closed-bar market-structure monitor.
indicator("Breakout Failure Radar", "Failure Radar", overlay = true)

int channelLen = input.int(20, "Channel lookback", minval = 2, maxval = 500, group = "Detection")
int atrLen = input.int(14, "ATR length", minval = 2, maxval = 100, group = "Detection")
float breakBuffer = input.float(0.10, "Breakout buffer (ATR)", minval = 0, step = 0.05, group = "Detection")
int windowBars = input.int(5, "Monitor next N bars", minval = 1, maxval = 50, group = "Monitoring")
float failBuffer = input.float(0.10, "Failure buffer inside level (ATR)", minval = 0, step = 0.05, group = "Monitoring")
float touchBuffer = input.float(0.25, "Retest zone half-width (ATR)", minval = 0, step = 0.05, group = "Monitoring")
bool showChannel = input.bool(false, "Show rolling detection channel", group = "Display")
bool showZone = input.bool(true, "Show frozen retest zone", group = "Display")
bool showPanel = input.bool(true, "Show status panel", group = "Display")

float upper = ta.highest(high, channelLen)[1]
float lower = ta.lowest(low, channelLen)[1]
float atr = ta.atr(atrLen)
bool ready = bar_index >= math.max(channelLen + 1, atrLen) and not na(atr) and atr > 0 and close > 0
// First crossing only: a rejected close is not promoted later without a fresh crossing.
bool upCandidate = ready and close > upper + breakBuffer * atr and close[1] <= upper[1]
bool downCandidate = ready and close < lower - breakBuffer * atr and close[1] >= lower[1]

var bool active = false
var bool retested = false
var int side = 0
var int startBar = na
var int lastAge = 0
var float level = na
var float frozenAtr = na
var float lastDistance = na
// 0 waiting, 1 monitoring, 2 retest held (still monitoring), 3 failed, 4 window complete.
var int state = 0
bool newUp = false
bool newDown = false
bool heldUp = false
bool heldDown = false
bool failedUp = false
bool failedDown = false
bool expired = false

if barstate.isconfirmed
    if active
        lastAge := bar_index - startBar
        float signedDistance = side * (close - level)
        bool failed = signedDistance < -failBuffer * frozenAtr
        bool touched = low <= level + touchBuffer * frozenAtr and high >= level - touchBuffer * frozenAtr
        bool held = touched and signedDistance > breakBuffer * frozenAtr
        // Failure has priority; a held retest never ends monitoring early.
        if failed
            failedUp := side == 1
            failedDown := side == -1
            active := false
            state := 3
        else
            if held and not retested
                retested := true
                heldUp := side == 1
                heldDown := side == -1
                state := 2
            if lastAge >= windowBars
                expired := true
                active := false
                state := 4
    else if upCandidate or downCandidate
        side := upCandidate ? 1 : -1
        level := upCandidate ? upper : lower
        frozenAtr := atr
        startBar := bar_index
        lastAge := 0
        retested := false
        active := true
        state := 1
        newUp := side == 1
        newDown := side == -1
    if not na(level)
        lastDistance := side * (close - level) / frozenAtr

color stateColor = state == 1 ? color.aqua : state == 2 ? color.lime : state == 3 ? color.orange : color.gray
bool visibleLevel = active or failedUp or failedDown or expired
plot(showChannel ? upper : na, "Rolling upper channel", color.new(color.gray, 75))
plot(showChannel ? lower : na, "Rolling lower channel", color.new(color.gray, 75))
plot(visibleLevel ? level : na, "Frozen breakout level", stateColor, 2, plot.style_linebr)
zTop = plot(showZone and visibleLevel ? level + touchBuffer * frozenAtr : na, "Retest zone top", color.new(stateColor, 80), style = plot.style_linebr)
zBottom = plot(showZone and visibleLevel ? level - touchBuffer * frozenAtr : na, "Retest zone bottom", color.new(stateColor, 80), style = plot.style_linebr)
fill(zTop, zBottom, color.new(stateColor, 92), title = "Frozen ATR retest zone")
plot(visibleLevel ? level - side * failBuffer * frozenAtr : na, "Failure threshold", color.new(color.orange, 50), style = plot.style_circles)
plotshape(newUp, "Up breakout", shape.triangleup, location.belowbar, color.aqua, text = "B+", textcolor = color.aqua, size = size.tiny)
plotshape(newDown, "Down breakout", shape.triangledown, location.abovebar, color.aqua, text = "B-", textcolor = color.aqua, size = size.tiny)
plotshape(heldUp, "Up retest held", shape.circle, location.belowbar, color.lime, text = "R+", textcolor = color.lime, size = size.tiny)
plotshape(heldDown, "Down retest held", shape.circle, location.abovebar, color.lime, text = "R-", textcolor = color.lime, size = size.tiny)
plotshape(failedUp, "Up breakout failed", shape.xcross, location.abovebar, color.orange, text = "F+", textcolor = color.orange, size = size.small)
plotshape(failedDown, "Down breakout failed", shape.xcross, location.belowbar, color.orange, text = "F-", textcolor = color.orange, size = size.small)
plotshape(expired, "Window complete", shape.square, location.bottom, color.gray, size = size.tiny)

var table panel = table.new(position.bottom_right, 2, 6, border_width = 1)
if barstate.islast and showPanel
    color panelBg = color.new(color.black, 12)
    string status = state == 0 ? "Waiting" : state == 1 ? "Monitoring" : state == 2 ? "Retest held / monitoring" : state == 3 ? "FAILED" : "Window complete"
    table.cell(panel, 0, 0, "FAILURE RADAR", text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 1, 0, "Last closed bar", text_color = color.silver, bgcolor = panelBg)
    table.cell(panel, 0, 1, side == 1 ? "Up breakout" : side == -1 ? "Down breakout" : "No setup", text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 1, 1, status, text_color = stateColor, bgcolor = panelBg)
    table.cell(panel, 0, 2, "Frozen level", text_color = color.silver, bgcolor = panelBg)
    table.cell(panel, 1, 2, str.tostring(level, format.mintick), text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 0, 3, "Bars monitored", text_color = color.silver, bgcolor = panelBg)
    table.cell(panel, 1, 3, str.tostring(lastAge) + " / " + str.tostring(windowBars), text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 0, 4, "Distance / frozen ATR", text_color = color.silver, bgcolor = panelBg)
    table.cell(panel, 1, 4, str.tostring(lastDistance, "#.##"), text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 0, 5, "Retest during window", text_color = color.silver, bgcolor = panelBg)
    table.cell(panel, 1, 5, retested ? "Yes (not a guarantee)" : "No", text_color = color.white, bgcolor = panelBg)

alertcondition(newUp or newDown, "New breakout under observation", "{{ticker}} {{interval}}: Failure Radar detected a new breakout at bar close.")
alertcondition(heldUp or heldDown, "Retest held", "{{ticker}} {{interval}}: Frozen-level retest held. Monitoring continues.")
alertcondition(failedUp, "Up breakout FAILED", "{{ticker}} {{interval}}: Up breakout failed below its frozen threshold. Warning, not an automatic short entry.")
alertcondition(failedDown, "Down breakout FAILED", "{{ticker}} {{interval}}: Down breakout failed above its frozen threshold. Warning, not an automatic long entry.")
alertcondition(expired, "Monitoring window complete", "{{ticker}} {{interval}}: Monitoring window ended without a failure. This is not a profit or success signal.")
````
