# Impulse Regime Engine [JOAT]

- url: https://www.tradingview.com/script/38kr6fCI-Impulse-Regime-Engine-JOAT/
- type: indicator
- pine_id: PUB;31ba290071034cc0bba43fd50c92d1df
- version: 1.0

## Description

[b]Impulse Regime Engine [JOAT][/b]

[b]Introduction[/b]

Impulse Regime Engine [JOAT] is a hybrid breakout-and-trend indicator designed to detect when participation expands, when that expansion compresses into a tradeable box, and when price finally resolves that box with directional intent. It combines a volume regime engine with an RSI-projected price trend framework, creating a clean overlay built for timing impulsive releases without sacrificing directional context.

This indicator is especially useful for traders who like breakout structures but do not want to trade every range break blindly. The regime box defines the event. The projected trend framework defines the context.

[image]https://www.tradingview.com/x/tgzQUNRu/[/image]

[b]Why This Indicator Exists[/b]

[list]
[*][b]Participation Regime Classification:[/b] Distinguishes low-quality price movement from meaningful volume expansion
[*][b]Lifecycle-Based Box Engine:[/b] Separates the setup into building, armed, and resolved states
[*][b]Projected Trend Overlay:[/b] Maps RSI into price space for contextual trend direction
[*][b]Strength-Based Candle Coloring:[/b] Visualizes conviction without overloading the chart
[*][b]Active Risk Map:[/b] Adds optional stop and target staging after valid breaks
[/list]

[b]Core Components Explained[/b]

[b]1. Volume Regime Engine[/b]

[pine]
volRatio = shortVolMA / longVolMA
[/pine]

Volume is classified into Low, Normal, High, and Extreme states by comparing short-term participation to a longer-term baseline. Only elevated regimes are allowed to build a valid impulse box.

[b]2. Regime Box Lifecycle[/b]

[list]
[*][b]Building:[/b] While elevated volume persists, the box expands to contain the active burst
[*][b]Armed:[/b] Once the burst cools, the box freezes and waits for release
[*][b]Resolved:[/b] A confirmed close beyond the boundary triggers the breakout event and resets the cycle
[/list]

The script now includes a cooldown between resolved boxes so repeated high-volume churn does not keep repainting fresh structures on every minor burst.

[b]3. RSI Projection Framework[/b]

[pine]
projected = priceLow + smoothedRsi * priceRange / 100.0
avgLine   = ta.ema(projected, smoothLen)
[/pine]

Instead of reading RSI only as a sub-pane oscillator, the script converts RSI into projected price space. This produces a trend reference line directly on the chart.

[b]4. Dynamic Tolerance Bands[/b]

[pine]
tolerance = avgBody * toleranceMultiplier
marginUp  = avgLine + tolerance
marginDn  = avgLine - tolerance
[/pine]

Price above the upper band confirms bullish projected trend. Price below the lower band confirms bearish projected trend. This acts like a directional bias filter around the projection basis.

[b]5. Breakout Risk Framework[/b]

When price resolves the armed box, the script can draw one stop and three profit levels using either ATR-derived or percentage-derived distance. The lines auto-expire so old trade maps do not crowd the chart.

[b]Visual Elements[/b]

[list]
[*][b]Regime Box:[/b] Semi-transparent box during build and armed phases
[*][b]Projection Basis:[/b] Gold-accent projected trend line
[*][b]Tolerance Bands:[/b] Bull and bear projection boundaries
[*][b]Gradient Candles:[/b] Optional candle coloring by directional strength
[*][b]Breakout Markers:[/b] Compact IRE triangles on confirmed release
[*][b]TP/SL Lines:[/b] Optional risk staging while the active breakout remains valid
[*][b]Dashboard:[/b] Volume regime, ratio, bias, box state, signal state, RSI, and strength
[/list]

[b]Input Parameters[/b]

[b]Regime Engine:[/b]
[list]
[*]Short / Long Volume MA
[*]Low / Normal / High thresholds
[*]Max build bars
[*]Max armed bars
[*]New box cooldown bars
[/list]

[b]Trend Projection:[/b]
[list]
[*]RSI length and smoothing
[*]Projection range bars
[*]Projection EMA
[*]Tolerance multiplier
[*]Strength lookback
[/list]

[b]Risk Framework:[/b]
[list]
[*]ATR period
[*]ATR stop multiplier
[*]TP1 / TP2 / TP3 risk-reward ratios
[*]TP/SL maximum life
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Wait for elevated participation to build the impulse box.  
[b]Step 2:[/b] Let the box transition into the armed state.  
[b]Step 3:[/b] Read whether projected trend bias agrees with the likely breakout direction.  
[b]Step 4:[/b] Use confirmed breaks, not intrabar pokes, as the actual event trigger.  
[b]Step 5:[/b] Manage the trade against the active risk map or your own execution rules.

[b]Best Practices[/b]

[list]
[*]Use on instruments with reliable participation data
[*]Prefer breakouts aligned with the projected trend state
[*]Treat extreme volume bursts as high-opportunity but also high-volatility events
[*]Use the cooldown to avoid overreacting in noisy compression cycles
[*]Disable extra visuals if you want a cleaner execution chart
[/list]

[b]Indicator Limitations[/b]

[list]
[*]Volume regime logic depends on the quality of the feed
[*]Not every armed box will produce a sustained move
[*]Projected RSI trend is a contextual guide, not a guarantee
[*]Breakouts can fail or reverse quickly in low liquidity
[*]Repeated tests of the same area reduce signal quality
[/list]

[b]Technical Implementation[/b]

Built in Pine Script v6 using:
[list]
[*]Short-vs-long volume regime classification
[*]Stateful box lifecycle logic
[*]RSI-to-price projection
[*]Body-based tolerance bands
[*]Strength-gradient candle coloring
[*]Optional ATR or percent risk mapping
[*]Confirmed-bar breakout and trend-shift alerts
[/list]

[b]Originality Statement[/b]

This indicator is original in the way it combines regime participation, lifecycle breakout structure, and projected momentum context into one overlay. Its edge is not just detecting expansion, but framing when expansion is worth respecting.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Breakout trading involves risk, including false breaks and fast reversals. Always manage risk carefully and confirm signals with your own process.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Impulse Regime Engine [JOAT]", shorttitle="IRE [JOAT]", overlay=true, max_labels_count=200, max_lines_count=200, max_boxes_count=50)

// INPUTS
grp_regime = "Regime Engine"
grp_trend = "Trend Projection"
grp_risk = "Risk Framework"
grp_vis = "Visual Controls"
grp_table = "Dashboard"

i_short_vol = input.int(5, "Short Volume MA", minval=1, maxval=50, group=grp_regime)
i_long_vol = input.int(100, "Long Volume MA", minval=10, maxval=500, group=grp_regime)
i_low_mult = input.float(0.7, "Low Regime Threshold", minval=0.1, maxval=5.0, step=0.1, group=grp_regime)
i_norm_mult = input.float(1.2, "Normal Regime Threshold", minval=0.1, maxval=5.0, step=0.1, group=grp_regime)
i_high_mult = input.float(1.8, "High Regime Threshold", minval=0.1, maxval=10.0, step=0.1, group=grp_regime)
i_max_build_bars = input.int(80, "Max Build Bars", minval=5, maxval=500, group=grp_regime)
i_max_armed_bars = input.int(40, "Max Armed Bars", minval=5, maxval=250, group=grp_regime)
i_box_cooldown = input.int(5, "New Box Cooldown Bars", minval=0, maxval=100, group=grp_regime)

i_rsi_len = input.int(14, "RSI Length", minval=2, maxval=100, group=grp_trend)
i_rsi_ma_len = input.int(9, "RSI Smoothing", minval=1, maxval=100, group=grp_trend)
i_price_rng_bars = input.int(30, "Projection Range Bars", minval=5, maxval=200, group=grp_trend)
i_smooth_len = input.int(10, "Projection EMA", minval=1, maxval=100, group=grp_trend)
i_tol_mult = input.float(2.5, "Tolerance Multiplier", minval=0.1, maxval=20.0, step=0.1, group=grp_trend)
i_strength_lookback = input.int(20, "Strength Lookback", minval=5, maxval=100, group=grp_trend)

i_show_tpsl = input.bool(true, "Show Active TP/SL", group=grp_risk)
i_use_atr_sl = input.bool(true, "Use ATR Stop", group=grp_risk)
i_atr_period = input.int(14, "ATR Period", minval=1, maxval=100, group=grp_risk)
i_sl_atr_mult = input.float(1.5, "Stop ATR Multiplier", minval=0.1, maxval=10.0, step=0.1, group=grp_risk)
i_rr_tp1 = input.float(1.0, "TP1 R:R", minval=0.1, maxval=20.0, step=0.1, group=grp_risk)
i_rr_tp2 = input.float(2.0, "TP2 R:R", minval=0.1, maxval=20.0, step=0.1, group=grp_risk)
i_rr_tp3 = input.float(3.0, "TP3 R:R", minval=0.1, maxval=20.0, step=0.1, group=grp_risk)
i_trade_line_bars = input.int(35, "TP/SL Max Bars", minval=5, maxval=200, group=grp_risk)

i_show_regime_box = input.bool(true, "Show Regime Box", group=grp_vis)
i_show_projection = input.bool(true, "Show Projection Lines", group=grp_vis)
i_show_projection_glow = input.bool(true, "Show Projection Glow", group=grp_vis)
i_show_break_markers = input.bool(true, "Show Breakout Markers", group=grp_vis)
i_show_trend_barcolor = input.bool(true, "Show Trend Candle Colors", group=grp_vis)
i_keep_box_on_break = input.bool(false, "Keep Last Box After Break", group=grp_vis)
i_bull_col = input.color(#26a69a, "Bull Color", group=grp_vis)
i_bear_col = input.color(#ef5350, "Bear Color", group=grp_vis)
i_neutral_col = input.color(#ffd700, "Neutral Accent", group=grp_vis)

i_show_table = input.bool(true, "Show Dashboard", group=grp_table)
i_table_pos = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grp_table)
i_table_size = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_table)

f_tpos(s) =>
    switch s
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        => position.bottom_right

f_tsize(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

shortVolMA = ta.sma(volume, i_short_vol)
longVolMA = ta.sma(volume, i_long_vol)
volRatio = shortVolMA / math.max(longVolMA, 1e-10)
regimeReady = bar_index + 1 >= math.max(i_long_vol, math.max(i_price_rng_bars, math.max(i_strength_lookback, 100)))

isLowVol = volRatio < i_low_mult
isNormVol = volRatio >= i_low_mult and volRatio < i_norm_mult
isHighVol = volRatio >= i_norm_mult and volRatio < i_high_mult
isExtrVol = volRatio >= i_high_mult
buildRegime = isHighVol or isExtrVol

regimeStr = isExtrVol ? "EXTREME" : isHighVol ? "HIGH" : isNormVol ? "NORMAL" : "LOW"
regimeCol = isExtrVol ? i_neutral_col : isHighVol ? i_bull_col : isNormVol ? color.new(color.silver, 0) : color.new(color.gray, 10)

rsiVal = ta.rsi(close, i_rsi_len)
rsiSmooth = ta.sma(rsiVal, i_rsi_ma_len)
priceLow = ta.lowest(low, i_price_rng_bars)
priceHigh = ta.highest(high, i_price_rng_bars)
priceRange = math.max(priceHigh - priceLow, 1e-10)
projected = priceLow + rsiSmooth * priceRange / 100.0
avgLine = ta.ema(projected, i_smooth_len)
avgBody = ta.sma(math.abs(close - open), 100)
tolerance = avgBody * i_tol_mult
marginUp = avgLine + tolerance
marginDown = avgLine - tolerance

var bool isUptrend = false
if barstate.isconfirmed
    if close > marginUp
        isUptrend := true
    else if close < marginDown
        isUptrend := false

trendChangeBull = regimeReady and barstate.isconfirmed and isUptrend and not isUptrend[1]
trendChangeBear = regimeReady and barstate.isconfirmed and not isUptrend and isUptrend[1]

distFromLine = math.abs(close - avgLine)
maxDist = math.max(ta.highest(distFromLine, i_strength_lookback), 1e-10)
strength = math.min(distFromLine / maxDist, 1.0)
impulseScore = math.min(volRatio / math.max(i_high_mult, 1e-10), 2.5) * 40.0 + strength * 60.0
weakBull = color.new(i_bull_col, 75)
weakBear = color.new(i_bear_col, 75)
candleCol = i_show_trend_barcolor ? (isUptrend ? color.from_gradient(strength, 0.0, 1.0, weakBull, i_bull_col) : color.from_gradient(strength, 0.0, 1.0, weakBear, i_bear_col)) : na
barcolor(candleCol, title="IRE Trend Candle Color")

var int boxState = 0
var float boxTop = na
var float boxBottom = na
var int boxStart = na
var int boxBuildBars = 0
var int boxArmedBars = 0
var int lastResolvedBar = na
var box regimeBox = na

if barstate.isconfirmed
    cooldownComplete = na(lastResolvedBar) or bar_index - lastResolvedBar > i_box_cooldown
    if regimeReady and boxState == 0 and buildRegime and not buildRegime[1] and cooldownComplete
        boxState := 1
        boxTop := high
        boxBottom := low
        boxStart := bar_index
        boxBuildBars := 1
        boxArmedBars := 0
        if not na(regimeBox)
            box.delete(regimeBox)
        regimeBox := box.new(bar_index, high, bar_index + 1, low, bgcolor=color.new(i_neutral_col, 88), border_color=color.new(i_neutral_col, 35), border_width=1)
    else if boxState == 1
        if buildRegime and boxBuildBars < i_max_build_bars
            boxTop := math.max(boxTop, high)
            boxBottom := math.min(boxBottom, low)
            boxBuildBars += 1
            if not na(regimeBox)
                box.set_top(regimeBox, boxTop)
                box.set_bottom(regimeBox, boxBottom)
                box.set_right(regimeBox, bar_index + 1)
        else if buildRegime and boxBuildBars >= i_max_build_bars
            if not na(regimeBox)
                box.delete(regimeBox)
            lastResolvedBar := bar_index
            boxState := 0
            boxTop := na
            boxBottom := na
            boxStart := na
            regimeBox := na
            boxBuildBars := 0
            boxArmedBars := 0
        else
            boxState := 2
            boxArmedBars := 0
            if not na(regimeBox)
                box.set_right(regimeBox, bar_index + 1)
                box.set_bgcolor(regimeBox, color.new(i_neutral_col, 90))
                box.set_border_color(regimeBox, color.new(i_neutral_col, 20))
    else if boxState == 2
        boxArmedBars += 1
        if not na(regimeBox)
            box.set_right(regimeBox, bar_index + 1)
        if boxArmedBars > i_max_armed_bars
            if not na(regimeBox)
                box.delete(regimeBox)
            lastResolvedBar := bar_index
            boxState := 0
            boxTop := na
            boxBottom := na
            boxStart := na
            regimeBox := na
            boxBuildBars := 0
            boxArmedBars := 0

breakoutUp = regimeReady and barstate.isconfirmed and boxState == 2 and not na(boxTop) and close > boxTop and close[1] <= boxTop
breakoutDown = regimeReady and barstate.isconfirmed and boxState == 2 and not na(boxBottom) and close < boxBottom and close[1] >= boxBottom

if breakoutUp or breakoutDown
    if not na(regimeBox)
        if i_keep_box_on_break
            box.set_right(regimeBox, bar_index)
            box.set_border_color(regimeBox, breakoutUp ? color.new(i_bull_col, 0) : color.new(i_bear_col, 0))
            box.set_bgcolor(regimeBox, breakoutUp ? color.new(i_bull_col, 88) : color.new(i_bear_col, 88))
        else
            box.delete(regimeBox)
    lastResolvedBar := bar_index
    boxState := 0
    boxTop := na
    boxBottom := na
    boxStart := na
    regimeBox := na
    boxBuildBars := 0
    boxArmedBars := 0

if not i_show_regime_box and not na(regimeBox)
    box.set_bgcolor(regimeBox, color.new(color.black, 100))
    box.set_border_color(regimeBox, color.new(color.black, 100))

atrVal = ta.atr(i_atr_period)

var int activeTradeDir = 0
var float activeEntry = na
var float activeStop = na
var float activeTp1 = na
var float activeTp2 = na
var float activeTp3 = na
var int activeTradeBars = 0
var line lnSl = na
var line lnTp1 = na
var line lnTp2 = na
var line lnTp3 = na

if barstate.isconfirmed
    if breakoutUp or breakoutDown
        if not na(lnSl)
            line.delete(lnSl)
            lnSl := na
        if not na(lnTp1)
            line.delete(lnTp1)
            lnTp1 := na
        if not na(lnTp2)
            line.delete(lnTp2)
            lnTp2 := na
        if not na(lnTp3)
            line.delete(lnTp3)
            lnTp3 := na
        riskDist = i_use_atr_sl ? atrVal * i_sl_atr_mult : close * 0.01 * i_sl_atr_mult
        dir = breakoutUp ? 1 : -1
        activeTradeDir := dir
        activeEntry := close
        activeStop := close - dir * riskDist
        activeTp1 := close + dir * riskDist * i_rr_tp1
        activeTp2 := close + dir * riskDist * i_rr_tp2
        activeTp3 := close + dir * riskDist * i_rr_tp3
        activeTradeBars := 0
        if i_show_tpsl
            tpColor = dir == 1 ? i_bull_col : i_bear_col
            lnSl := line.new(bar_index, activeStop, bar_index + 1, activeStop, color=color.new(i_bear_col, 15), width=1, style=line.style_dashed)
            lnTp1 := line.new(bar_index, activeTp1, bar_index + 1, activeTp1, color=color.new(tpColor, 20), width=1, style=line.style_dashed)
            lnTp2 := line.new(bar_index, activeTp2, bar_index + 1, activeTp2, color=color.new(tpColor, 10), width=1, style=line.style_dashed)
            lnTp3 := line.new(bar_index, activeTp3, bar_index + 1, activeTp3, color=color.new(tpColor, 0), width=1, style=line.style_dotted)
    else if activeTradeDir != 0
        activeTradeBars += 1
        stopHit = activeTradeDir == 1 ? low <= activeStop : high >= activeStop
        tp3Hit = activeTradeDir == 1 ? high >= activeTp3 : low <= activeTp3
        expired = activeTradeBars > i_trade_line_bars
        if stopHit or tp3Hit or expired
            if not na(lnSl)
                line.delete(lnSl)
                lnSl := na
            if not na(lnTp1)
                line.delete(lnTp1)
                lnTp1 := na
            if not na(lnTp2)
                line.delete(lnTp2)
                lnTp2 := na
            if not na(lnTp3)
                line.delete(lnTp3)
                lnTp3 := na
            activeTradeDir := 0
            activeEntry := na
            activeStop := na
            activeTp1 := na
            activeTp2 := na
            activeTp3 := na
            activeTradeBars := 0
        else if i_show_tpsl
            if not na(lnSl)
                line.set_x2(lnSl, bar_index + 1)
            if not na(lnTp1)
                line.set_x2(lnTp1, bar_index + 1)
            if not na(lnTp2)
                line.set_x2(lnTp2, bar_index + 1)
            if not na(lnTp3)
                line.set_x2(lnTp3, bar_index + 1)

pProjGlow = plot(i_show_projection and i_show_projection_glow ? avgLine : na, "Projection Glow Outer", color=color.new(i_neutral_col, 88), linewidth=7)
pProjBasis = plot(i_show_projection ? avgLine : na, "Projection Basis", color=color.new(isUptrend ? i_bull_col : i_bear_col, 15), linewidth=2)
pProjUpper = plot(i_show_projection ? marginUp : na, "Projection Upper", color=color.new(i_bull_col, 55), linewidth=1)
pProjLower = plot(i_show_projection ? marginDown : na, "Projection Lower", color=color.new(i_bear_col, 55), linewidth=1)
fill(pProjUpper, pProjLower, color=color.new(isUptrend ? i_bull_col : i_bear_col, 93), title="Projection Pocket Fill")
fill(pProjGlow, pProjBasis, color=color.new(i_neutral_col, 96), title="Projection Metallic Fill")

plotshape(i_show_break_markers and breakoutUp, title="Bullish Regime Break", style=shape.triangleup, location=location.belowbar, color=i_bull_col, size=size.small, text="IRE")
plotshape(i_show_break_markers and breakoutDown, title="Bearish Regime Break", style=shape.triangledown, location=location.abovebar, color=i_bear_col, size=size.small, text="IRE")
plotshape(i_show_break_markers and trendChangeBull, title="Bull Trend Shift", style=shape.circle, location=location.belowbar, color=color.new(i_neutral_col, 0), size=size.tiny)
plotshape(i_show_break_markers and trendChangeBear, title="Bear Trend Shift", style=shape.circle, location=location.abovebar, color=color.new(i_neutral_col, 0), size=size.tiny)
bgcolor(i_show_projection and impulseScore >= 75 ? color.new(isUptrend ? i_bull_col : i_bear_col, 95) : na)

var table dash = na
if i_show_table
    if na(dash)
        dash := table.new(position.top_right, 2, 9, bgcolor=#161824, border_color=#30344d, border_width=1, frame_color=#444b6e, frame_width=1)
    if barstate.islast
        sz = size.normal
        stateStr = boxState == 1 ? "BUILDING" : boxState == 2 ? "ARMED" : "IDLE"
        signalStr = breakoutUp ? "BULL BREAK" : breakoutDown ? "BEAR BREAK" : activeTradeDir == 1 ? "LONG ACTIVE" : activeTradeDir == -1 ? "SHORT ACTIVE" : "NONE"
        signalCol = breakoutUp ? i_bull_col : breakoutDown ? i_bear_col : activeTradeDir == 1 ? i_bull_col : activeTradeDir == -1 ? i_bear_col : color.gray
        table.cell(dash, 0, 0, "IRE [JOAT]", text_color=i_neutral_col, text_size=sz, bgcolor=#0d0f18, text_halign=text.align_center)
        table.cell(dash, 1, 0, "STATE", text_color=color.silver, text_size=sz, bgcolor=#0d0f18, text_halign=text.align_center)
        table.cell(dash, 0, 1, "Volume Regime", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 1, regimeStr, text_color=regimeCol, text_size=sz, bgcolor=#141726)
        table.cell(dash, 0, 2, "Volume Ratio", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 2, str.tostring(volRatio, "#.###"), text_color=color.white, text_size=sz, bgcolor=#141726)
        table.cell(dash, 0, 3, "Trend Bias", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 3, isUptrend ? "BULLISH" : "BEARISH", text_color=isUptrend ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#141726)
        table.cell(dash, 0, 4, "Box Lifecycle", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 4, stateStr, text_color=boxState == 0 ? color.gray : i_neutral_col, text_size=sz, bgcolor=#141726)
        table.cell(dash, 0, 5, "Signal", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 5, signalStr, text_color=signalCol, text_size=sz, bgcolor=#141726)
        table.cell(dash, 0, 6, "RSI", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 6, str.tostring(rsiVal, "#.##"), text_color=color.white, text_size=sz, bgcolor=#141726)
        table.cell(dash, 0, 7, "Strength", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 7, str.tostring(strength * 100.0, "#.0") + "%", text_color=isUptrend ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#141726)
        table.cell(dash, 0, 8, "Impulse Score", text_color=color.silver, text_size=sz, bgcolor=#141726)
        table.cell(dash, 1, 8, str.tostring(impulseScore, "#.0"), text_color=impulseScore >= 65 ? i_neutral_col : regimeCol, text_size=sz, bgcolor=#141726)

alertcondition(breakoutUp, "IRE: Bullish Regime Break", "Impulse Regime Engine [JOAT]: bullish regime breakout detected on {{ticker}} {{interval}}.")
alertcondition(breakoutDown, "IRE: Bearish Regime Break", "Impulse Regime Engine [JOAT]: bearish regime breakout detected on {{ticker}} {{interval}}.")
alertcondition(trendChangeBull, "IRE: Trend Shift Bullish", "Impulse Regime Engine [JOAT]: trend projection shifted bullish on {{ticker}} {{interval}}.")
alertcondition(trendChangeBear, "IRE: Trend Shift Bearish", "Impulse Regime Engine [JOAT]: trend projection shifted bearish on {{ticker}} {{interval}}.")
````
