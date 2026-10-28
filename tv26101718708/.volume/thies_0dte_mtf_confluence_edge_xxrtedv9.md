# [Thies] 0DTE MTF Confluence Edge

- url: https://www.tradingview.com/script/xxRtEdv9-Thies-0DTE-MTF-Confluence-Edge/
- type: indicator
- pine_id: PUB;2fa2b7122b7b47c685b98f23df89ebdc
- version: 3.0

## Description

[b]0DTE Multi-Timeframe Confluence Detector[/b]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Summary[/b] 
This indicator helps traders identify when multiple timeframes align bullish or bearish using a combination of:
[list]
[*]Price direction
[*]Volume participation
[*]Delta-style pressure
[*] [symbol="AMEX:SPY"]AMEX:SPY[/symbol] + [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] confirmation
[*]VIX1D volatility regime analysis
[/list]

Instead of relying on a single chart signal, this script evaluates four customizable timeframes simultaneously and combines them into one aggregate confluence score.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW IT WORKS[/b]

Each timeframe receives a score:

[list]
[*][b]+1[/b] = Bullish alignment
[*][b]-1[/b] = Bearish alignment
[*][b]0[/b] = Neutral / mixed conditions
[/list]

A timeframe is considered bullish when:

[list]
[*]Volume is above its moving average
[*]Delta pressure is positive
[*]Price closes above the open
[/list]

A timeframe is considered bearish when:

[list]
[*]Volume is above its moving average
[*]Delta pressure is negative
[*]Price closes below the open
[/list]

The four timeframe scores are combined into a total confluence score ranging from [b]-4 to +4[/b].

━━━━━━━━━━━━━━━━━━

[b]CONFLUENCE SCORE GUIDE[/b]

[list]
[*][b]+4[/b] = Maximum bullish alignment
[*][b]+3[/b] = Strong bullish confluence
[*][b]+1 to +2[/b] = Mixed bullish pressure
[*][b]0[/b] = No directional edge
[*][b]-1 to -2[/b] = Mixed bearish pressure
[*][b]-3[/b] = Strong bearish confluence
[*][b]-4[/b] = Maximum bearish alignment
[/list]

━━━━━━━━━━━━━━━━━━

[b]VIX1D REGIME FILTER[/b]

The script also classifies the current short-term implied volatility environment using VIX1D.

[list]
[*][b]COMPRESSED[/b] = Low volatility environment
[*][b]NORMAL[/b] = Balanced conditions
[*][b]ELEVATED[/b] = Increased movement potential
[*][b]EXTREME[/b] = High-risk / high-volatility environment
[/list]

This helps contextualize whether momentum conditions are expanding or compressing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]DASHBOARD FEATURES[/b]

The built-in dashboard displays:

[list]
[*]Signal direction for each timeframe
[*]Bullish / bearish alignment
[*]Aggregate confluence score
[*]Current VIX1D regime
[*]Real-time NY session clock
[/list]

Strong signals also trigger background highlighting for quick visual recognition.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW TO USE[/b]

[list]
[*]Use strong bullish readings to confirm long setups
[*]Use strong bearish readings to confirm short setups
[*]Avoid low-confluence environments when score hovers near zero
[*]Combine with VWAP, market structure, liquidity levels, or opening range analysis
[*]Use VIX1D regime data to adjust expectations for volatility and expansion
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]BEST USED FOR[/b]

[list]
[*]0DTE options trading
[*]Intraday index trading
[*]SPY and ES momentum analysis
[*]Scalping and day trading
[*]Multi-timeframe directional confirmation
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kingthies
//@version=6
indicator("[Thies] 0DTE MTF Confluence Edge v2", shorttitle="MTF Edge v2", overlay=false)

// ============ INPUTS ============
spySymbol   = input.symbol("AMEX:SPY",      "SPY Symbol",   group="Symbols")
esSymbol    = input.symbol("CME_MINI:ES1!", "ES Symbol",    group="Symbols")
vix1dSymbol = input.symbol("CBOE:VIX1D",    "VIX1D Symbol", group="Symbols")

tf1 = input.timeframe("1",  "Timeframe 1", group="Timeframes")
tf2 = input.timeframe("5",  "Timeframe 2", group="Timeframes")
tf3 = input.timeframe("15", "Timeframe 3", group="Timeframes")
tf4 = input.timeframe("60", "Timeframe 4", group="Timeframes")

volMaLen    = input.int(20,    "Volume MA Length",        minval=1,             group="Settings")
deltaMaLen  = input.int(9,     "Delta EMA Length",        minval=1,             group="Settings")
strongThr   = input.int(3,     "Strong Signal Min",       minval=1, maxval=4,   group="Settings")
relVolThr   = input.float(1.0, "Relative Volume Min",     minval=0.1, step=0.1, group="Settings",
     tooltip="Volume must exceed this multiple of its own MA to count as active. 1.0 = at average.")

useConfirmed = input.bool(false, "Non-Repainting Mode", group="Signal Quality",
     tooltip="Uses last COMPLETED bar on each timeframe. No mid-bar flips, but signals lag by one HTF bar.")
persistBars  = input.int(2, "Alert Persistence (bars)", minval=1, maxval=10, group="Signal Quality",
     tooltip="Score must hold at/beyond threshold for this many chart bars before alerting. Kills churn.")

useSession = input.bool(true, "RTH Session Filter", group="Session")
sessStr    = input.session("0930-1600", "Session (ET)", group="Session")

// ============ PER-SYMBOL DATA (runs inside security, in target TF context) ============
// Fix #1/#2: each symbol normalized against its OWN volume MA (relative volume), no shares-vs-contracts mixing
// Fix #3: delta EMA computed here, so it runs on the target timeframe, not chart bars
// Fix #4: proportional intrabar pressure (close position within range) instead of binary candle sign
f_data() =>
    rng  = high - low
    pos  = rng > 0 ? (close - low) / rng * 2.0 - 1.0 : 0.0   // -1 (close at low) to +1 (close at high)
    vMA  = ta.sma(volume, volMaLen)
    relV = vMA > 0 ? volume / vMA : 0.0                        // relative volume, unitless
    dEma = ta.ema(relV * pos, deltaMaLen)                      // normalized signed pressure, EMA on target TF
    up   = close > open
    dn   = close < open
    // Fix #5: in confirmed mode, index [1] here = last COMPLETED bar in HTF context (non-repainting)
    relVOut = useConfirmed ? relV[1] : relV
    dEmaOut = useConfirmed ? dEma[1] : dEma
    upOut   = useConfirmed ? up[1]   : up
    dnOut   = useConfirmed ? dn[1]   : dn
    [relVOut, dEmaOut, upOut, dnOut]

// ============ CONFLUENCE SCORE PER TF ============
f_score(tf) =>
    [sRv, sDe, sUp, sDn] = request.security(spySymbol, tf, f_data(), barmerge.gaps_off, barmerge.lookahead_off)
    [eRv, eDe, eUp, eDn] = request.security(esSymbol,  tf, f_data(), barmerge.gaps_off, barmerge.lookahead_off)
    relV  = (nz(sRv) + nz(eRv)) / 2.0          // average relative volume, both instruments weighted equally
    delta = nz(sDe) + nz(eDe)                   // combined normalized pressure
    volActive = relV > relVolThr
    score = 0
    if volActive and delta > 0 and sUp and eUp  // both instruments must agree on direction
        score := 1
    else if volActive and delta < 0 and sDn and eDn
        score := -1
    [score, relV, delta]

// ============ SESSION FILTER (Fix #6) ============
inSession = not useSession or not na(time(timeframe.period, sessStr, "America/New_York"))

// ============ CALCULATE EACH TF ============
[s1raw, rv1, d1] = f_score(tf1)
[s2raw, rv2, d2] = f_score(tf2)
[s3raw, rv3, d3] = f_score(tf3)
[s4raw, rv4, d4] = f_score(tf4)

s1 = inSession ? s1raw : 0
s2 = inSession ? s2raw : 0
s3 = inSession ? s3raw : 0
s4 = inSession ? s4raw : 0

totalScore = s1 + s2 + s3 + s4

// ============ HYSTERESIS / PERSISTENCE (Fix #7) ============
bullHold = math.sum(totalScore >=  strongThr ? 1 : 0, persistBars) == persistBars
bearHold = math.sum(totalScore <= -strongThr ? 1 : 0, persistBars) == persistBars
bullTrigger = bullHold and not bullHold[1]
bearTrigger = bearHold and not bearHold[1]

// ============ VIX1D REGIME ============
vix1d = request.security(vix1dSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
vixRegime = vix1d < 12 ? "COMPRESSED" : vix1d < 18 ? "NORMAL" : vix1d < 25 ? "ELEVATED" : "EXTREME"

// ============ PLOTS ============
scoreColor = totalScore >= strongThr ? color.lime :
             totalScore <= -strongThr ? color.red :
             totalScore > 0 ? color.new(color.green, 50) :
             totalScore < 0 ? color.new(color.red,   50) :
             color.gray

plot(totalScore, "Confluence Score", color=scoreColor, style=plot.style_columns, linewidth=4)
hline(0,          "Zero",        color=color.gray)
hline(strongThr,  "Bull Strong", color=color.new(color.green, 50), linestyle=hline.style_dashed)
hline(-strongThr, "Bear Strong", color=color.new(color.red,   50), linestyle=hline.style_dashed)
hline(4,  "Max Bull", color=color.new(color.green, 80))
hline(-4, "Max Bear", color=color.new(color.red,   80))

// ============ ALERTS (persistence-gated) ============
alertcondition(bullTrigger, "Bullish Confluence",
     "Strong bullish confluence held across timeframes")
alertcondition(bearTrigger, "Bearish Confluence",
     "Strong bearish confluence held across timeframes")

// ============ DASHBOARD ============
f_cellColor(s) =>
    s ==  1 ? color.new(color.green, 40) :
      s == -1 ? color.new(color.red, 40) :
      color.new(color.gray, 60)
f_arrow(s) => s == 1 ? "▲ BULL" : s == -1 ? "▼ BEAR" : "— FLAT"

var table dash = table.new(position.top_right, 4, 9, border_width=1)
if barstate.islast
    table.cell(dash, 0, 0, "TF",     bgcolor=color.new(color.navy, 30), text_color=color.white)
    table.cell(dash, 1, 0, "Signal", bgcolor=color.new(color.navy, 30), text_color=color.white)
    table.cell(dash, 2, 0, "RelVol", bgcolor=color.new(color.navy, 30), text_color=color.white)
    table.cell(dash, 3, 0, "Delta",  bgcolor=color.new(color.navy, 30), text_color=color.white)

    table.cell(dash, 0, 1, tf1 + "m", text_color=color.white)
    table.cell(dash, 1, 1, f_arrow(s1), bgcolor=f_cellColor(s1), text_color=color.white)
    table.cell(dash, 2, 1, str.tostring(rv1, "#.##") + "x", text_color=rv1 > relVolThr ? color.yellow : color.gray)
    table.cell(dash, 3, 1, str.tostring(d1, "#.##"), text_color=d1 > 0 ? color.lime : d1 < 0 ? color.red : color.gray)

    table.cell(dash, 0, 2, tf2 + "m", text_color=color.white)
    table.cell(dash, 1, 2, f_arrow(s2), bgcolor=f_cellColor(s2), text_color=color.white)
    table.cell(dash, 2, 2, str.tostring(rv2, "#.##") + "x", text_color=rv2 > relVolThr ? color.yellow : color.gray)
    table.cell(dash, 3, 2, str.tostring(d2, "#.##"), text_color=d2 > 0 ? color.lime : d2 < 0 ? color.red : color.gray)

    table.cell(dash, 0, 3, tf3 + "m", text_color=color.white)
    table.cell(dash, 1, 3, f_arrow(s3), bgcolor=f_cellColor(s3), text_color=color.white)
    table.cell(dash, 2, 3, str.tostring(rv3, "#.##") + "x", text_color=rv3 > relVolThr ? color.yellow : color.gray)
    table.cell(dash, 3, 3, str.tostring(d3, "#.##"), text_color=d3 > 0 ? color.lime : d3 < 0 ? color.red : color.gray)

    table.cell(dash, 0, 4, tf4 + "m", text_color=color.white)
    table.cell(dash, 1, 4, f_arrow(s4), bgcolor=f_cellColor(s4), text_color=color.white)
    table.cell(dash, 2, 4, str.tostring(rv4, "#.##") + "x", text_color=rv4 > relVolThr ? color.yellow : color.gray)
    table.cell(dash, 3, 4, str.tostring(d4, "#.##"), text_color=d4 > 0 ? color.lime : d4 < 0 ? color.red : color.gray)

    table.cell(dash, 0, 5, "TOTAL", bgcolor=color.new(color.purple, 30), text_color=color.white)
    totalLabel = totalScore >=  strongThr ? "STRONG BULL" :
                 totalScore <= -strongThr ? "STRONG BEAR" :
                 totalScore  >  0         ? "Mixed Bull"  :
                 totalScore  <  0         ? "Mixed Bear"  : "No Edge"
    table.cell(dash, 1, 5, totalLabel, bgcolor=scoreColor, text_color=color.white)
    table.cell(dash, 2, 5, str.tostring(totalScore), bgcolor=scoreColor, text_color=color.white)
    table.cell(dash, 3, 5, bullHold ? "HELD ✓" : bearHold ? "HELD ✓" : "", text_color=color.white)

    table.cell(dash, 0, 6, "VIX1D",   bgcolor=color.new(color.gray, 60), text_color=color.white)
    table.cell(dash, 1, 6, vixRegime, text_color=vix1d > 20 ? color.red : vix1d > 15 ? color.yellow : color.lime)
    table.cell(dash, 2, 6, str.tostring(vix1d, "#.##"), text_color=color.white)
    table.cell(dash, 3, 6, "", text_color=color.white)

    table.cell(dash, 0, 7, "Mode",   bgcolor=color.new(color.gray, 60), text_color=color.white)
    table.cell(dash, 1, 7, useConfirmed ? "CONFIRMED" : "LIVE", text_color=useConfirmed ? color.aqua : color.orange)
    table.cell(dash, 2, 7, inSession ? "RTH" : "CLOSED", text_color=inSession ? color.lime : color.gray)
    table.cell(dash, 3, 7, "", text_color=color.white)

    table.cell(dash, 0, 8, "Time", bgcolor=color.new(color.gray, 60), text_color=color.white)
    table.cell(dash, 1, 8, str.format_time(time, "HH:mm", "America/New_York"), text_color=color.white)
    table.cell(dash, 2, 8, "ET", text_color=color.white)
    table.cell(dash, 3, 8, "", text_color=color.white)

// Background tint on strong signals
bgcolor(totalScore >=  strongThr ? color.new(color.green, 90) :
        totalScore <= -strongThr ? color.new(color.red,   90) : na)
````
