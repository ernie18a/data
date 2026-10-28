# Gann Rules of 17

- url: https://www.tradingview.com/script/Qzm9VenG-Gann-Rules-of-17/
- type: indicator
- pine_id: PUB;bf904d5e9e9149ea8d107cf41861df8f
- version: 1.0

## Description

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CREDIT & ATTRIBUTION TO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Original Script: "Gann 17 Rules"
  Author:           roibh108
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SO... WHAT IS THIS THING?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  William Delbert Gann was a finance trader from the early 1900s who believed
  that the market moved in mysterious geometric, mathematical, and even
  *astrological* patterns. Yes. The stars. He also wore a turban sometimes.
  The man was a LEGEND — or a lunatic — depending on how your last trade went.

  This indicator takes 17 of Gann's famous trading rules and turns them into
  a scorecard. Think of it as a report card for the market, except instead of
  getting grounded for bad grades, you lose real money. Fun!

  The script sits on your chart like a wise old wizard in the corner,
  tallying up "Bullish" vs "Bearish" signals and then dramatically announcing
  BUY, SELL, or NEUTRAL — like a judge on a reality cooking show.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WHAT DOES IT ACTUALLY DO? (The 17 Rules)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Rule 1  — Weekly Friday High 
            If Friday made the highest high of the last 5 days, bulls are
            partying into the weekend. Buy signal territory. 

  Rule 2  — Weekly Friday Low 
            If Friday made the lowest low of the last 5 days, bears went home
            happy. Everyone else did not. 

  Rule 3  — Strong Uptrend: Tuesday Low 
            Tuesday low = lowest of 5 days BUT price closed green?
            Gann says bulls bought the dip. Classic. 

  Rule 4  — Strong Downtrend: Wednesday High 
            Wednesday made a 5-day high but closed red?
            Someone sold the top on a Wednesday. Rude.

  Rule 5  — 4-Week High Breakout 
            Price just smashed a 20-bar high. Breakout detected.
            Either genius trade incoming, or a bull trap. 50/50. 

  Rule 6  — 4-Week Low Breakout 
            Price just faceplanted to a 20-bar low.
            Welcome to the pain zone. Bears are dancing.

  Rule 7  — 30 MA Crossover 
            Price crossed above the Moving Average.
            The most classic signal since sliced bread.
            Works great... in hindsight. Always. 

  Rule 8  — 5-Day Rise → 3-Day Correction 
            Went up 5 days, pulled back 2 of the last 3?
            Gann says: healthy dip. Probably. Maybe. 

  Rule 9  — 9-Day Rise → 5-Day Correction 
            Bigger rise, bigger correction expected.
            Like eating a huge meal and needing a nap. 

  Rule 10 — 100pt / 100% Support 
            Today's candle moved more than 2x ATR.
            Something BIG just happened. Check the news.
            (Or don't — and be surprised. Your call.) 

  Rule 11 — 3-Day High Breakout 
            Made a 3-day high AND above the MA?
            Short-term momentum is your friend. Today. 

  Rule 12 — Growing Correction 
            Recent correction is LARGER than the previous one?
            Gann's spider sense says: sellers are gaining strength. 

  Rule 13 — 50% Retracement 
            Price is near the midpoint of a recent swing range.
            This is Gann's sacred equilibrium zone.
            Half-way to heaven or half-way to hell. 

  Rule 14 — Double / Triple Bottom 
            Price made TWO lows and closed green?
            Classic reversal pattern. Bulls digging in. 

  Rule 15 — Double / Triple Top  (upside-down)
            Price made TWO highs and closed red?
            Classic rejection pattern. Bears have arrived. 

  Rule 16 — Volatility Surge ⚡
            ATR is 1.5x its average AND candle size ≥ ATR?
            SOMETHING IS HAPPENING. Buckle up, buttercup. 

  Rule 17 — Quarterly High / Low 
            60-bar high or low breached?
            Big picture trend change territory. Gann loved quarters.
            (Probably because he made a lot of them.) 🪙

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  THE SCORING SYSTEM (a.k.a. The Verdict)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  The script counts up BULL RULES vs BEAR RULES that are currently active.

    🟢 BULL SCORE  →  How many bullish rules fired this bar
    🔴 BEAR SCORE  →  How many bearish rules fired this bar

  If either score crosses the "Minimum Rules" threshold (default: 3) AND beats
  the other side, the script flashes:

    ✅ BUY     — Bulls win. Charge! 
    ❌ SELL    — Bears win. Retreat! 
    😐 NEUTRAL — Nobody won. Go touch grass. 

  This minimum-rules idea is inspired by Gann's own "Rule of 3" — Gann said
  you need at least 3 confirmations before acting. Because apparently 1 or 2
  reasons to buy isn't enough. Gann was high-maintenance like that.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  RECOMMENDED TIMEFRAMES 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Gann was primarily a DAILY chart trader, so this indicator is best suited for:

    ⭐ Daily (1D)     — The sweet spot. Most rules make perfect sense here.
                        Friday rules, Tuesday rules — all calendar-based.
                        This is what Gann wrote about in his original work.

    ✅ Weekly (1W)    — Good for big-picture trend confirmation. Slower signals
                        but more meaningful when they do fire.

    ⚠️  4H / 1H       — Works, but calendar-based rules (Rules 1-4) lose their
                        meaning because there's no "Friday" at 3am.
                        Use with caution and a helmet. 🪖

    ❌ 1M / 5M         — Please don't. Gann is spinning in his grave.
                        Day-of-week rules become total nonsense on a
                        1-minute chart. Don't disrespect the turban. 

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HOW TO USE / INTERPRET THE TABLE 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Step 1 — Add the indicator to your chart. A table appears in the corner
           (you can move it in the settings — because we're civilized).

  Step 2 — Look at the STATUS column:
              ✓ (Green)  = Rule is currently ACTIVE on this bar
              ✗ (Red)    = Rule is inactive. Moving on.

  Step 3 — Check the BULL / BEAR SCORE row at the bottom of the table.
           More bulls = bulls are stronger. More bears = bears are stronger.
           Equal = chaos. Perfectly balanced, as all things should be.

  Step 4 — Read the SIGNAL row:
              BUY     = 3+ bull rules fired and bulls > bears. 🟢
              SELL    = 3+ bear rules fired and bears > bulls. 🔴
              NEUTRAL = Neither side convinced the jury. 

  Step 5 — Use your BRAIN as a final filter. The indicator is a tool, not a
           financial advisor, a therapist, or your mum. Make your own choices.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ALERTS 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  The script can fire alerts when:
    → A new BUY signal appears
    → A new SELL signal appears
    → Key rules (1, 2, 5, 7) individually trigger

 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CUSTOMIZATION OPTIONS 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  → MA Type: SMA / EMA / WMA / VWMA — pick your flavor of average
  → MA Period: default 30 (Gann loved round numbers)
  → Min Rules for Signal: default 3 (Gann's Rule of 3 — triple confirmed)
  → Table Position: put it wherever it offends you the least
  → Font Size: from "I have eagle eyes" (Tiny) to "I trade on a TV" (Huge)
  → Toggle individual rules ON/OFF if some of them hurt your feelings

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚠️  DISCLAIMER (The Important Bit — Please Read)  ⚠️
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  THIS SCRIPT IS FOR EDUCATIONAL AND INFORMATIONAL PURPOSES ONLY. 

  It does NOT constitute financial advice, investment advice, trading advice,
  or advice of any other kind. It will NOT pay your rent, your EMI, your
  Netflix subscription, or your therapist .

  Past performance of ANY indicator, including this one, does NOT guarantee
  future results. The market is a living, breathing, chaos-loving monster
  that has humiliated far smarter people than any of us.

  W.D. Gann himself was a controversial figure — some of his claimed returns
  cannot be independently verified, and his methods remain debated by serious
  market researchers to this day. This indicator is an INTERPRETATION of
  Gann principles — not gospel, not prophecy, not a cheat code.

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  IN SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  This script is a beautifully coded homage to one of trading's most
  mystical and maddening thinkers. roibh108 has done the community genuine
  service by digitizing 17 of Gann's principles into a coherent, readable,
  and actually-useful indicator.
  Use it wisely. Use it humbly. And tip your hat to roibh108. 

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kingshukghosh71

//@version=5
indicator("Gann Rules of 17", overlay=true, max_bars_back=5000)

// ══════════════════════════════════════════════
// INPUT SETTINGS
// ══════════════════════════════════════════════
group_ma     = "📊 MOVING AVERAGE"
group_table  = "📈 TABLE SETTINGS"
group_rules  = "🎯 RULE TOGGLES"
group_signal = "⚖️ SIGNAL SETTINGS"
group_alerts = "🔔 ALERTS"

maType   = input.string("SMA", "MA Type for Rule 7", options=["SMA","EMA","WMA","VWMA"], group=group_ma)
maLength = input.int(30, "MA Period (Rule 7)", minval=5, maxval=200, group=group_ma)

tablePos  = input.string("Top Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=group_table)
fontSize  = input.string("Small", "Font Size", options=["Tiny","Small","Normal","Large","Huge"], group=group_table)
showTable = input.bool(true, "Show Status Table", group=group_table)

minRules     = input.int(3, "Min Rules for Signal (Gann Rule of 3)", minval=1, maxval=11, group=group_signal)
enableAlerts = input.bool(true, "Enable Alerts", group=group_alerts)

rule1Enabled  = input.bool(true, "Rule 1 : Weekly Friday High",         group=group_rules)
rule2Enabled  = input.bool(true, "Rule 2 : Weekly Friday Low",          group=group_rules)
rule3Enabled  = input.bool(true, "Rule 3 : Strong Uptrend - Tue Low",   group=group_rules)
rule4Enabled  = input.bool(true, "Rule 4 : Strong Downtrend - Wed High",group=group_rules)
rule5Enabled  = input.bool(true, "Rule 5 : 4-Week High Breakout",       group=group_rules)
rule6Enabled  = input.bool(true, "Rule 6 : 4-Week Low Breakout",        group=group_rules)
rule7Enabled  = input.bool(true, "Rule 7 : 30 MA Crossover",            group=group_rules)
rule8Enabled  = input.bool(true, "Rule 8 : 5-Day Rise → 3-Day Corr.",  group=group_rules)
rule9Enabled  = input.bool(true, "Rule 9 : 9-Day Rise → 5-Day Corr.",  group=group_rules)
rule10Enabled = input.bool(true, "Rule 10: 100pt/100% Support",         group=group_rules)
rule11Enabled = input.bool(true, "Rule 11: 3-Day High Breakout",        group=group_rules)
rule12Enabled = input.bool(true, "Rule 12: Growing Correction",         group=group_rules)
rule13Enabled = input.bool(true, "Rule 13: 50% Retracement",            group=group_rules)
rule14Enabled = input.bool(true, "Rule 14: Double/Triple Bottom",       group=group_rules)
rule15Enabled = input.bool(true, "Rule 15: Double/Triple Top",          group=group_rules)
rule16Enabled = input.bool(true, "Rule 16: Volatility Surge",           group=group_rules)
rule17Enabled = input.bool(true, "Rule 17: Quarterly High/Low",         group=group_rules)

// ══════════════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════════════
f_ma(src, len, type) =>
    switch type
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        =>        ta.sma(src, len)

f_tablePos(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.top_right

f_fontSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

f_countFalling(len) =>
    cnt = 0
    for i = 0 to len - 1
        if close[i] < close[i + 1]
            cnt += 1
    cnt

// ══════════════════════════════════════════════
// CORE CALCULATIONS
// ══════════════════════════════════════════════
ma30          = f_ma(close, maLength, maType)
atr           = ta.atr(14)
volatilityAvg = ta.sma(atr, 20)
dow           = dayofweek(time)

highest5   = ta.highest(high, 5)
lowest5    = ta.lowest(low,  5)
highest3   = ta.highest(high, 3)
highest10  = ta.highest(high, 10)
lowest10   = ta.lowest(low,  10)
highest20  = ta.highest(high, 20)
lowest20   = ta.lowest(low,  20)
highest60  = ta.highest(high, 60)
lowest60   = ta.lowest(low,  60)

// ══════════════════════════════════════════════
// RULE CONDITIONS
// ══════════════════════════════════════════════
rule1Active  = rule1Enabled  and dow == dayofweek.friday and high == highest5
rule2Active  = rule2Enabled  and dow == dayofweek.friday and low  == lowest5
rule3Active  = rule3Enabled  and dow == dayofweek.tuesday and low == lowest5 and close > open
rule4Active  = rule4Enabled  and dow == dayofweek.wednesday and high == highest5 and close < open
rule5Active  = rule5Enabled  and high == highest20 and high > high[1]
rule6Active  = rule6Enabled  and low  == lowest20  and low  < low[1]
rule7Active  = rule7Enabled  and ta.crossover(close, ma30)
rule8Active  = rule8Enabled  and close > close[4] and high > high[4] and f_countFalling(3) >= 2
rule9Active  = rule9Enabled  and close > close[8] and high > high[8] and f_countFalling(5) >= 3
rule10Active = rule10Enabled and (close - open) >= atr * 2
rule11Active = rule11Enabled and high == highest3 and close > ma30 and high > high[1]
rule12Active = rule12Enabled and math.abs(high[5] - low) > math.abs(high[10] - low[5]) and math.abs(high[5] - low) > atr * 1.5
rule13Active = rule13Enabled and math.abs(close - (highest10 + lowest10) / 2) <= atr
rule14Active = rule14Enabled and low < low[2] and low < low[4] and close > open
rule15Active = rule15Enabled and high > high[2] and high > high[4] and close < open
rule16Active = rule16Enabled and atr > volatilityAvg * 1.5 and math.abs(close - open) >= atr
rule17Active = rule17Enabled and (high == highest60 and high > high[1] or low == lowest60 and low < low[1])

// ══════════════════════════════════════════════
// SCORING & SIGNAL 
// ══════════════════════════════════════════════
bullScore = (rule1Active ? 1 : 0) + (rule3Active ? 1 : 0) + (rule5Active ? 1 : 0) + (rule7Active ? 1 : 0) + (rule10Active ? 1 : 0) + (rule11Active ? 1 : 0) + (rule14Active ? 1 : 0) + (rule8Active and close > ma30 ? 1 : 0) + (rule13Active and close > ma30 ? 1 : 0) + (rule16Active and close > ma30 ? 1 : 0) + (rule17Active and high == highest60 ? 1 : 0)

bearScore = (rule2Active ? 1 : 0) + (rule4Active ? 1 : 0) + (rule6Active ? 1 : 0) + (rule12Active ? 1 : 0) + (rule15Active ? 1 : 0) + (rule9Active and close < ma30 ? 1 : 0) + (rule13Active and close < ma30 ? 1 : 0) + (rule16Active and close < ma30 ? 1 : 0) + (rule17Active and low == lowest60 ? 1 : 0)

buySignal  = bullScore >= minRules and bullScore > bearScore
sellSignal = bearScore >= minRules and bearScore > bullScore
signalText = buySignal ? "BUY" : sellSignal ? "SELL" : "NEUTRAL"
signalColor = buySignal ? #00C853 : sellSignal ? #D50000 : color.gray

// ══════════════════════════════════════════════
// ALERTS (only when enabled)
// ══════════════════════════════════════════════
if enableAlerts
    if buySignal and not buySignal[1]
        alert("🟢 GANN BUY SIGNAL — " + str.tostring(bullScore) + " bullish rules active", alert.freq_once_per_bar)
    if sellSignal and not sellSignal[1]
        alert("🔴 GANN SELL SIGNAL — " + str.tostring(bearScore) + " bearish rules active", alert.freq_once_per_bar)
    if rule1Active and not rule1Active[1]
        alert("Gann Rule 1: Weekly High on Friday — BULLISH", alert.freq_once_per_bar)
    if rule2Active and not rule2Active[1]
        alert("Gann Rule 2: Weekly Low on Friday — BEARISH", alert.freq_once_per_bar)
    if rule5Active and not rule5Active[1]
        alert("Gann Rule 5: 4-Week High Breakout — UPTREND", alert.freq_once_per_bar)
    if rule7Active and not rule7Active[1]
        alert("Gann Rule 7: MA Crossover — TREND CHANGE", alert.freq_once_per_bar)

// ══════════════════════════════════════════════
// DASHBOARD TABLE
// ══════════════════════════════════════════════
f_cell(t, col, row, txt, bg, tc) =>
    table.cell(t, col, row, txt, text_halign=text.align_left, text_size=f_fontSize(fontSize), bgcolor=bg, text_color=tc)

f_statusCell(t, row, active) =>
    table.cell(t, 1, row, active ? "✓" : "✗", text_halign=text.align_center, text_size=f_fontSize(fontSize), bgcolor=#000000, text_color=active ? #00ff08 : #ff1d1d)

if showTable
    var table t = na
    if barstate.islast
        if na(t)
            t := table.new(f_tablePos(tablePos), rows=22, columns=2, border_width=2, border_color=#f1e869, frame_width=2, frame_color=#f1e869)

        // Header
        table.cell(t, 0, 0, "GANN RULES OF 17",  text_halign=text.align_center, text_size=f_fontSize(fontSize), bgcolor=#000000, text_color=color.white)
        table.cell(t, 1, 0, "STATUS",             text_halign=text.align_center, text_size=f_fontSize(fontSize), bgcolor=#000000, text_color=color.white)

        // Rules 1 to 17
        f_cell(t, 0,  1, "Rule 1 : Weekly Friday High",          #000000, color.white) ,  f_statusCell(t,  1, rule1Active)
        f_cell(t, 0,  2, "Rule 2 : Weekly Friday Low",           #000000, color.white) ,  f_statusCell(t,  2, rule2Active)
        f_cell(t, 0,  3, "Rule 3 : Strong Uptrend - Tue Low",    #000000, color.white) ,  f_statusCell(t,  3, rule3Active)
        f_cell(t, 0,  4, "Rule 4 : Strong Downtrend - Wed High", #000000, color.white) ,  f_statusCell(t,  4, rule4Active)
        f_cell(t, 0,  5, "Rule 5 : 4-Week High Breakout",        #000000, color.white) ,  f_statusCell(t,  5, rule5Active)
        f_cell(t, 0,  6, "Rule 6 : 4-Week Low Breakout",         #000000, color.white) ,  f_statusCell(t,  6, rule6Active)
        f_cell(t, 0,  7, "Rule 7 : 30 MA Crossover",             #000000, color.white) ,  f_statusCell(t,  7, rule7Active)
        f_cell(t, 0,  8, "Rule 8 : 5-Day Rise → 3-Day Corr.",   #000000, color.white) ,  f_statusCell(t,  8, rule8Active)
        f_cell(t, 0,  9, "Rule 9 : 9-Day Rise → 5-Day Corr.",   #000000, color.white) ,  f_statusCell(t,  9, rule9Active)
        f_cell(t, 0, 10, "Rule 10: 100pt/100% Support",          #000000, color.white) ,  f_statusCell(t, 10, rule10Active)
        f_cell(t, 0, 11, "Rule 11: 3-Day High Breakout",         #000000, color.white) ,  f_statusCell(t, 11, rule11Active)
        f_cell(t, 0, 12, "Rule 12: Growing Correction",          #000000, color.white) ,  f_statusCell(t, 12, rule12Active)
        f_cell(t, 0, 13, "Rule 13: 50% Retracement",             #000000, color.white) ,  f_statusCell(t, 13, rule13Active)
        f_cell(t, 0, 14, "Rule 14: Double/Triple Bottom",        #000000, color.white) ,  f_statusCell(t, 14, rule14Active)
        f_cell(t, 0, 15, "Rule 15: Double/Triple Top",           #000000, color.white) ,  f_statusCell(t, 15, rule15Active)
        f_cell(t, 0, 16, "Rule 16: Volatility Surge",            #000000, color.white) ,  f_statusCell(t, 16, rule16Active)
        f_cell(t, 0, 17, "Rule 17: Quarterly High/Low",          #000000, color.white) ,  f_statusCell(t, 17, rule17Active)

        // Divider
        table.cell(t, 0, 18, "─────────────────────────", text_halign=text.align_center, text_size=f_fontSize(fontSize), bgcolor=#000000, text_color=#444444)
        table.cell(t, 1, 18, "──────",                    text_halign=text.align_center, text_size=f_fontSize(fontSize), bgcolor=#000000, text_color=#444444)

        // Score row – 
        table.cell(t, 0, 19, "🟢 BULL SCORE: " + str.tostring(bullScore) + "   🔴 BEAR SCORE: " + str.tostring(bearScore), text_halign=text.align_left, text_size=f_fontSize(fontSize), bgcolor=#111111, text_color=color.yellow)
        table.cell(t, 1, 19, str.tostring(bullScore) + " | " + str.tostring(bearScore), text_halign=text.align_center, text_size=f_fontSize(fontSize), bgcolor=#111111, text_color=color.yellow)

        // Signal row
        table.cell(t, 0, 20, "SIGNAL: " + signalText + "  (min " + str.tostring(minRules) + " rules)", text_halign=text.align_left, text_size=f_fontSize(fontSize), bgcolor=#000000, text_color=signalColor)
        table.cell(t, 1, 20, signalText, text_halign=text.align_center, text_size=f_fontSize(fontSize), bgcolor=signalColor, text_color=color.white)

        // Threshold reminder
        table.cell(t, 0, 21, "Gann Rule of 3: need " + str.tostring(minRules) + "+ rules & dominant side", text_halign=text.align_left, text_size=size.tiny, bgcolor=#000000, text_color=#888888)
        table.cell(t, 1, 21, "", bgcolor=#000000)
````
