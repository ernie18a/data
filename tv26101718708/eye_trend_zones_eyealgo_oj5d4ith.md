# Eye Trend Zones [EyeAlgo]

- url: https://www.tradingview.com/script/OJ5D4Ith-Eye-Trend-Zones-EyeAlgo/
- type: indicator
- pine_id: PUB;5973ee07a4034da89c37902f82a8cfcb
- version: 1.0

## Description

Eye Trend Zones puts three things on one clean chart: a trend line that gives the direction and the BUY / SELL timing, support & resistance zones built only from swings where price really reacted, and RSI extremes that show where price was stretched. Every signal is checked against the zones and recent RSI extremes and marked with ⭐ or ⭐⭐ when that context is present. A small dashboard sums it all up.

https://www.tradingview.com/x/oueERIvA/


🟢 OVERVIEW

A trend tool tells you the direction, but not where price is likely to react. A support & resistance tool shows levels, but not the trend. Eye Trend Zones answers three questions on one screen:

• Which way is the trend?
• Where are the nearest important price areas above and below?
• Did this BUY / SELL happen at one of those areas, or after an RSI extreme?


🟢 WHAT MAKES IT ORIGINAL

The trend line uses TradingView's built-in Supertrend calculation (ta.supertrend). Everything built around it is original logic written for this script:

▶ Impulse-filtered zones: a swing high or low becomes a zone only if price moved away from it by at least a set number of ATRs. Small swings never create zones.
▶ Wick-to-body zone shape: each zone covers the rejection area of the swing candle (wick extreme to candle body), sized between 0.25 and 1.5 ATR, so a zone is never a thin line or a huge block.
▶ Zone memory: up to 12 zones per side are remembered, but only the ones nearest to price are drawn (2 per side by default). An older level further away is not lost — it reappears when price comes back to it.
▶ Strength shading: clean retests make a zone darker, retests that close deep inside it make it lighter. The dashboard grades the nearest zones Weak / Medium / Strong.
▶ One-time zone flip: broken resistance becomes support (and vice versa) once, drawn with a dotted outline.
▶ Candle-first scaling: zones are clipped to the price range of the candles on screen, so a far-away level never squeezes the chart.
▶ Confluence marks: each trend change is checked against the active zones and recent RSI extremes and labelled ⭐ / ⭐⭐.
▶ Theme-adaptive visuals: zone shading and the dashboard adapt automatically to light and dark charts.


🟢 HOW IT WORKS

1) Trend line and BUY / SELL

• GREEN line = uptrend, RED line = downtrend.
• ▲ BUY appears on the candle where the line turns green, ▼ SELL where it turns red.
• Signals are confirmed on bar close and do not repaint after the candle closes.
• Defaults: ATR Length 25, ATR Factor 2.5 — a responsive setting, so signals print close to swing lows and highs (see "Research behind the defaults").

https://www.tradingview.com/x/Wuz7vzJg/


2) Support & resistance zones

• A swing is confirmed after "Swing Length" bars on each side (default 8).
• A zone is drawn only if price moved at least "Min Move Away" × ATR from the swing (default 1.0 ATR).
• Resistance zone = body of the swing-high candle up to its wick high. Support zone = wick low of the swing-low candle up to its body.
• Overlapping zones on the same side merge (still limited to 1.5 ATR high).
• "Zones Per Side" (default 2) sets how many zones are drawn above and below price. When the memory is full, the zone farthest from price is dropped, never the nearest.
• A zone stays active until price closes through it.

https://www.tradingview.com/x/7vaecz5V/


3) Zone flip

When price closes through a zone, it flips once: broken resistance becomes support, broken support becomes resistance. Flipped zones have a dotted outline. A zone that flips on the same bar as a BUY / SELL does not count as confluence for that signal.

4) RSI extremes

Candles where RSI (default 14) is above 80 get a light green background stripe; candles below 20 get a light red stripe. The stripe runs the full height of the chart, so stretched moves are easy to spot at a glance.

• Green stripe (RSI above 80) = price was stretched UP. Watch for the trend to slow; a SELL that follows within 10 bars gets an RSI ⭐.
• Red stripe (RSI below 20) = price was stretched DOWN. A BUY that follows within 10 bars gets an RSI ⭐.

The levels (80 / 20), the RSI length and the stripe colours can be changed in the "RSI Candle Marks" settings.

Example (Gold 1H, chart below): on 14 Oct gold fell hard and RSI dropped below 20, so those candles show a light red stripe. Price was stretched to the downside there. A few bars later the trend line turned green and the BUY got a ⭐, because it came within 10 bars of that RSI extreme. A green stripe works the same way at the top: RSI above 80 marks a stretched rally, and a SELL soon after it gets a ⭐.

https://www.tradingview.com/x/oueERIvA/

5) Confluence ⭐

• ⭐ = price touched a support zone (within 0.25 ATR) in the last 3 bars and did not close below it, OR RSI was below 20 within the last 10 bars. ⭐⭐ = both.
• With "Show Zones" off, ⭐ can only come from RSI.
• A SELL uses a resistance zone and RSI above 80.
• ⭐⭐ labels are drawn larger. Hover over any label to see which conditions were present.

Important: ⭐ means context, not a better signal. In our tests, signals with zone or RSI context did better on some charts and worse on others.

6) Dashboard

Trend, trend-line level, last signal (with stars and bars ago), nearest support and resistance with strength (Weak / Medium / Strong), and RSI state. When price is above every remembered resistance the dashboard says "None above (new high)".


🟢 RESEARCH BEHIND THE DEFAULTS

We tested the trend line on seven charts: OANDA XAUUSD 15m, 1H and 4H, XAGUSD 1H, EURUSD 1H, BITSTAMP BTCUSD 1H and NSE NIFTY 1H (all bars TradingView loads by default, about 5,000 – 11,000 bars each, October 2026). Each BUY was held until the next SELL and each SELL until the next BUY. Results are in ATR units, before spread and commission.

• 42 combinations (ATR Length 7 – 34 × ATR Factor 1.5 – 5.0) were tested on six of the charts (EURUSD was checked only with the final setting), each split into older 70 % and newer 30 % of bars. On every one of the six charts, the setting that looked best on the older data was not the best on the newer data, so we did not pick the top performer of one chart. ATR 14 / Factor 3.0 was the most consistent: profitable on the older data of all six charts, below a profit factor of 1.00 on the newer data of only 2 of 6, and the highest average newer-data profit factor.
• The default is ATR 25 / Factor 2.5 instead, because it reacts faster: BUY / SELL print closer to swing lows and highs, which many traders prefer on intraday charts. The cost is a few extra signals in sideways markets and weaker results on newer data in our tests (profit factor below 1.00 on 4 of 6 charts, versus 2 of 6 for ATR 14 / Factor 3.0). For fewer, steadier signals, set ATR Length 14 and ATR Factor 3.0.
• With ATR 14 / Factor 3.0, the profit factor (total winning moves ÷ total losing moves) was: Gold 15m 1.04, Gold 1H 1.17, Gold 4H 1.89, Silver 1H 1.14, EURUSD 1H 1.00, NIFTY 1H 1.20, BTCUSD 1H 1.35.
• With ATR 14 / Factor 3.0 only about 35 – 47 % of signals were winners. Trend-following of this kind makes its result from a smaller number of long moves, not from a high win rate.
• Filters we tested and did NOT add, because they did not help consistently across the charts: zone / RSI confluence, EMA-200 and higher-timeframe trend alignment, ADX, choppiness, break-even and fixed stops, and taking half profit at 1 ATR.
• Pullback entries (waiting for a pullback after the flip) raised the profit factor on most charts, but removed about 60 % of signals and failed on Gold 15m. They are not built in, to keep the signals simple.
• Weakest charts: EURUSD 1H and Gold 15m. Strongest: Gold 4H and BTCUSD 1H.

These are historical measurements on a limited sample, not a forecast.


🟢 HOW TO USE

1. Read the trend from the line colour.
2. Treat BUY / SELL as a change in trend, not as an automatic order. An opposite signal is the natural exit.
3. Use the nearest zones as areas where price may react: support below for BUY, resistance above for SELL.
4. Use ⭐ as extra context, not as a reason on its own.
5. Gold 15m was the weakest chart in our tests. Test on your own symbol and timeframe before using anything live.


🟢 HOW TO CHANGE SETTINGS

1. Add the indicator to your chart.
2. Double-click the trend line, or hover the indicator name at the top-left of the chart and click the ⚙ gear icon.
3. Change values in the "Inputs" tab and click OK. Colours are in the same tab; line styles are in the "Style" tab.

Quick guide:
• Fewer, steadier signals → ATR Length 14, ATR Factor 3.0. Earlier signals (more of them) → keep 25 / 2.5 or lower the factor.
• More or fewer zones → "Zones Per Side" (1 – 5).
• Only strong zones → raise "Min Move Away" (e.g. 1.5 – 2.0) or "Swing Length" (e.g. 12 – 15).
• Clean chart → switch off "Show RSI Candle Marks" or "Show Dashboard".
• Alerts → right-click the chart → Add alert → choose "Eye Trend Zones" and the condition (BUY, SELL, Confluence BUY ⭐ …).


🟢 SETTINGS

• Trend Line: ATR Length, ATR Factor, Show BUY / SELL, colours, Trend Fill.
• Support & Resistance Zones: Show Zones, Swing Length, Min Move Away (×ATR), Zones Per Side, Flip Broken Zones, Support and Resistance colours.
• RSI Candle Marks: on / off, RSI Length, Upper Level, Lower Level, colours.
• Confluence: on / off, RSI Look-back (bars).
• Alerts: detailed alert() messages on / off.
• Dashboard: on / off, position, text size.


🟢 ALERTS

• BUY / SELL
• Confluence BUY ⭐ / Confluence SELL ⭐
• RSI above upper level / RSI below lower level
• Detailed alert() message with direction, stars, price and trend line level ("Any alert() function call").


🟢 IMPORTANT NOTES & LIMITATIONS

• The research figures ignore spread, commission, slippage and position sizing. On low timeframes costs can remove a small edge completely.
• In sideways markets the trend line can flip often and give several signals close together.
• Zones need "Swing Length" bars to confirm, so a zone appears a few bars after the swing.
• Zones are drawn only within the price range of the candles on screen. Scroll or zoom out to see levels further away; the dashboard always shows the nearest ones.
• On the live candle the trend line, RSI stripe and dashboard can change until the candle closes. BUY / SELL labels and alerts appear only after the close.
• The script does not place trades.


🟢 DISCLAIMER

This indicator is for educational and analysis purposes only. It is not financial advice. Past behaviour on a chart does not guarantee future results. Always use your own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EyeAlgo
// Eye Trend Zones (original code)
//  • ATR trend line: GREEN = uptrend, RED = downtrend. BUY when it turns green, SELL when it turns red.
//  • Support & resistance zones from impulsive swing points (wick → body of the swing candle),
//    shaded light → dark by strength. A broken zone FLIPS once: broken resistance becomes support and vice versa.
//    Up to 12 zones per side are remembered; only the ones nearest to price are drawn, clipped to the
//    candles on screen so the chart's auto-scale stays on price.
//  • RSI candle marks: full-height background stripe where RSI is above 80 (green) or below 20 (red).
//  • ⭐ Confluence: the BUY / SELL happened at a zone (support / resistance)
//    and/or right after an RSI extreme. ⭐⭐ = both. Context only, not a quality guarantee.
//  • ⭐⭐ labels drawn larger, theme-adaptive zone shading, optional trend fill.
//  • Dashboard: trend, last signal, nearest support / resistance with strength, and RSI state.

//@version=6
indicator("Eye Trend Zones [EyeAlgo]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════════════════
//  SETTINGS
// ═══════════════════════════════════════════════════════════════════════════
GT = "🧭 Trend Line"
atrLen  = input.int(25, "ATR Length", minval=2, group=GT, display=display.none)
factor  = input.float(2.5, "ATR Factor", minval=0.1, step=0.1, group=GT, display=display.none,
     tooltip="Distance of the trend line from price in ATR. Higher = fewer, slower trend changes.")
showSig = input.bool(true, "Show BUY / SELL", group=GT, display=display.none)
cUp     = input.color(color.rgb(38, 208, 124), "Uptrend", inline="tc", group=GT)
cDn     = input.color(color.rgb(255, 82, 82),  "Downtrend", inline="tc", group=GT)
showFill = input.bool(false, "Trend Fill", group=GT, display=display.none,
     tooltip="Very light fill between price and the trend line.")

GZ = "🧱 Support & Resistance Zones"
showZones = input.bool(true, "Show Zones", group=GZ, display=display.none)
swingLen  = input.int(8, "Swing Length", minval=2, group=GZ, display=display.none,
     tooltip="Bars on each side needed to confirm a swing high / low.")
impulse   = input.float(1.0, "Min Move Away (×ATR)", minval=0.0, step=0.25, group=GZ, display=display.none,
     tooltip="Price must move at least this many ATR away from the swing for a zone to be drawn. Higher = fewer, stronger zones.")
zPerSide  = input.int(2, "Zones Per Side", minval=1, maxval=5, group=GZ, display=display.none,
     tooltip="How many zones are drawn above price (resistance) and below price (support). Only the zones nearest to price are drawn; older zones further away are remembered and reappear when price comes back to them.")
showFlip  = input.bool(true, "Flip Broken Zones", group=GZ, display=display.none,
     tooltip="When price closes through a zone, the zone flips once: broken resistance becomes support, broken support becomes resistance. Flipped zones have a dotted outline.")
cRes  = input.color(color.rgb(255, 82, 82),  "Resistance", inline="zc", group=GZ)
cSup  = input.color(color.rgb(38, 208, 124), "Support",    inline="zc", group=GZ,
     tooltip="Base zone colours. Shading (weak → strong) is applied automatically and adapts to light and dark chart themes.")

GR = "📍 RSI Candle Marks"
showRsiL = input.bool(true, "Show RSI Candle Marks", group=GR, display=display.none,
     tooltip="Full-height background stripe on candles where RSI is above the upper level (green) or below the lower level (red).")
rsiLenL  = input.int(14, "RSI Length", minval=2, group=GR, display=display.none)
rsiUpLv  = input.int(80, "Upper Level", minval=50, maxval=100, group=GR, display=display.none)
rsiDnLv  = input.int(20, "Lower Level", minval=0, maxval=50, group=GR, display=display.none)
cRsiUp   = input.color(color.rgb(38, 208, 124), "Upper Mark", inline="rl", group=GR)
cRsiDn   = input.color(color.rgb(255, 82, 82),  "Lower Mark", inline="rl", group=GR)

GS = "⭐ Confluence"
showStar = input.bool(true, "Mark Confluence ⭐", group=GS, display=display.none,
     tooltip="⭐ = the BUY happened at a support zone (SELL at a resistance zone) OR shortly after an RSI extreme. ⭐⭐ = both. This is context, not a quality guarantee.")
rsiLook  = input.int(10, "RSI Look-back (bars)", minval=1, maxval=50, group=GS, display=display.none,
     tooltip="How many bars back an RSI extreme still counts for a ⭐.")

GA = "🔔 Alerts"
detailAlerts = input.bool(true, "Detailed alert() Messages", group=GA, display=display.none,
     tooltip="Sends BUY / SELL with stars, price and trend line level. Create the alert with 'Any alert() function call'.")

GD = "📊 Dashboard"
showDash = input.bool(true, "Show Dashboard", group=GD, display=display.none)
dashPos  = input.string("Top Right", "Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=GD, display=display.none)
dashSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=GD, display=display.none)

// theme-adaptive zone shading (dark charts need more opaque fills to stay visible)
isDark = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) < 128
cResS  = color.new(cRes, isDark ? 60 : 78)
cResW  = color.new(cRes, isDark ? 84 : 93)
cSupS  = color.new(cSup, isDark ? 60 : 78)
cSupW  = color.new(cSup, isDark ? 84 : 93)
cResE  = color.new(cRes, isDark ? 35 : 55)     // zone edge
cSupE  = color.new(cSup, isDark ? 35 : 55)

// fixed zone rules (kept simple for users)
PER_SIDE = 12     // zones remembered per side (the farthest from price is dropped first)
MIN_H    = 0.25   // min zone height × ATR
MAX_H    = 1.5    // max zone height × ATR
NEAR     = 0.25   // "at the zone" tolerance × ATR

// ═══════════════════════════════════════════════════════════════════════════
//  HELPERS & CORE SERIES
// ═══════════════════════════════════════════════════════════════════════════
f_px(float p) =>
    str.tostring(p, format.mintick)

f_txtOn(color c) =>
    (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) > 150 ? color.black : color.white

atr = ta.atr(atrLen)
ll3 = ta.lowest(low, 3)
hh3 = ta.highest(high, 3)

// RSI
rsiL  = ta.rsi(close, rsiLenL)
rsiHi = rsiL > rsiUpLv
rsiLo = rsiL < rsiDnLv
barsSinceHi = ta.barssince(rsiHi)
barsSinceLo = ta.barssince(rsiLo)

// trend line
[tl, tDir] = ta.supertrend(factor, atrLen)
up     = tDir < 0
turnUp = barstate.isconfirmed and tDir < 0 and nz(tDir[1]) > 0
turnDn = barstate.isconfirmed and tDir > 0 and nz(tDir[1]) < 0

float tlShow = tDir == nz(tDir[1]) ? tl : na
color tCol   = up ? cUp : cDn
pTl  = plot(tlShow, "Trend Line", color=tCol, linewidth=2, style=plot.style_linebr)
pMid = plot(hl2, "Price Mid", display=display.none, editable=false)
fill(pMid, pTl, color=showFill ? color.new(tCol, isDark ? 90 : 94) : na, title="Trend Fill")


// ═══════════════════════════════════════════════════════════════════════════
//  SUPPORT & RESISTANCE ZONES
// ═══════════════════════════════════════════════════════════════════════════
type Zone
    float top
    float bot
    bool  res        // true = resistance, false = support
    float imp        // impulse away from the swing, in ATR
    int   tests      // clean retests
    int   dents      // retests that closed deep inside the zone
    bool  inside
    bool  flipped
    int   born       // bar the zone became active
    box   bx
    int   left       // bar where the box starts (the swing bar)
    bool  vis = true // drawn (one of the zones nearest to price)

var array<Zone> zones = array.new<Zone>()
var array<Zone> past  = array.new<Zone>()   // ended zones (kept for drawing history)

f_strength(Zone z) =>
    float base  = math.min(z.imp / 4.0, 1.0) * 0.3
    float test  = math.min(z.tests / 4.0, 1.0) * 0.7
    float clean = (z.tests + 1.0) / (z.tests + z.dents + 1.0)
    math.min(1.0, (base + test) * clean)

f_col(Zone z) =>
    float s = f_strength(z)
    z.res ? color.from_gradient(s, 0.0, 1.0, cResW, cResS) : color.from_gradient(s, 0.0, 1.0, cSupW, cSupS)

f_end(Zone z, int x) =>
    box.set_right(z.bx, x)
    past.push(z)

// add a zone (merges with an overlapping active zone on the same side, keeps the PER_SIDE nearest to price)
f_addZone(float top, float bot, bool res, float imp, bool flipped, int startBar) =>
    bool merged = false
    for z in zones
        if not merged and z.res == res and top >= z.bot and bot <= z.top
            float hMax = nz(atr) * MAX_H
            z.top   := math.max(z.top, top)
            z.bot   := math.min(z.bot, bot)
            // keep merged zones within the max height (trim the side away from the swing extreme)
            if z.top - z.bot > hMax
                if res
                    z.bot := z.top - hMax
                else
                    z.top := z.bot + hMax
            z.tests += 1
            z.imp   := math.max(z.imp, imp)
            if flipped and not z.flipped
                z.flipped := true
                z.born    := bar_index
                box.set_border_color(z.bx, res ? cResE : cSupE)
                box.set_border_width(z.bx, 1)
                box.set_border_style(z.bx, line.style_dotted)
            merged  := true
    if not merged
        Zone n = Zone.new(top, bot, res, imp, 0, 0, false, flipped, bar_index, na)
        color c = f_col(n)
        n.left := startBar
        n.bx := box.new(startBar, top, bar_index + 5, bot, bgcolor=c,
             border_color=res ? cResE : cSupE, border_width=1, border_style=flipped ? line.style_dotted : line.style_solid)
        zones.push(n)
        int cnt = 0
        for z in zones
            if z.res == res
                cnt += 1
        // too many on this side: drop the zone FARTHEST from price (not the oldest),
        // so the levels closest to price are always kept
        while cnt > PER_SIDE
            int   far  = -1
            float farD = -1.0
            for j = 0 to zones.size() - 1
                Zone o = zones.get(j)
                if o.res == res
                    float d = math.abs((o.top + o.bot) / 2 - close)
                    if d > farD
                        farD := d
                        far  := j
            if far >= 0
                f_end(zones.get(far), bar_index)
                zones.remove(far)
            cnt -= 1

ph      = ta.pivothigh(high, swingLen, swingLen)
pl      = ta.pivotlow(low, swingLen, swingLen)
winLow  = ta.lowest(low, swingLen + 1)
winHigh = ta.highest(high, swingLen + 1)

if showZones and barstate.isconfirmed and not na(atr)
    // new zones from impulsive swings
    if not na(ph)
        float impD = (ph - winLow) / atr
        if impD >= impulse
            float bodyTop = math.max(open[swingLen], close[swingLen])
            f_addZone(ph, math.max(ph - atr * MAX_H, math.min(bodyTop, ph - atr * MIN_H)), true, impD, false, bar_index - swingLen)
    if not na(pl)
        float impU = (winHigh - pl) / atr
        if impU >= impulse
            float bodyBot = math.min(open[swingLen], close[swingLen])
            f_addZone(math.min(pl + atr * MAX_H, math.max(bodyBot, pl + atr * MIN_H)), pl, false, impU, false, bar_index - swingLen)

    // update, test, break (and flip) active zones
    array<float> fTop = array.new<float>()
    array<float> fBot = array.new<float>()
    array<bool>  fRes = array.new<bool>()
    array<float> fImp = array.new<float>()
    if zones.size() > 0
        for i = zones.size() - 1 to 0
            Zone z = zones.get(i)
            bool broken = z.res ? close > z.top : close < z.bot
            if broken
                f_end(z, bar_index)
                zones.remove(i)
                if showFlip and not z.flipped
                    fTop.push(z.top)
                    fBot.push(z.bot)
                    fRes.push(not z.res)
                    fImp.push(z.imp)
            else
                bool  touch = z.res ? high >= z.bot : low <= z.top
                float mid   = (z.top + z.bot) / 2
                if touch and not z.inside
                    if z.res ? close > mid : close < mid
                        z.dents += 1     // weak retest: closed deep inside the zone
                    else
                        z.tests += 1     // clean retest: rejected from the zone
                z.inside := touch
                box.set_right(z.bx, bar_index + 5)
                box.set_top(z.bx, z.top)
                box.set_bottom(z.bx, z.bot)
                box.set_bgcolor(z.bx, f_col(z))
    if fTop.size() > 0
        for k = 0 to fTop.size() - 1
            f_addZone(fTop.get(k), fBot.get(k), fRes.get(k), fImp.get(k), true, bar_index)
    // draw only the zPerSide zones nearest to price on each side; the rest stay in memory, hidden,
    // and reappear when price comes back near them
    for z in zones
        float dz = math.abs((z.top + z.bot) / 2 - close)
        int nearer = 0
        for o in zones
            if o.res == z.res and math.abs((o.top + o.bot) / 2 - close) < dz
                nearer += 1
        bool vis = nearer < zPerSide
        z.vis := vis
        box.set_bgcolor(z.bx, vis ? f_col(z) : color(na))
        box.set_border_color(z.bx, vis ? (z.res ? cResE : cSupE) : color(na))
        // a hidden zone is collapsed onto the current bar so it never stretches the chart's auto-scale
        box.set_left(z.bx, vis ? z.left : bar_index)
        box.set_top(z.bx, vis ? z.top : close)
        box.set_bottom(z.bx, vis ? z.bot : close)
    while past.size() > 380
        box.delete(past.shift().bx)

// keep the chart's auto-scale on the candles: zones are clipped to the price range of the
// candles on screen, so a zone far above or below never squeezes the chart
var float vHi = na
var float vLo = na
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    vHi := na(vHi) ? high : math.max(vHi, high)
    vLo := na(vLo) ? low  : math.min(vLo, low)
f_clip(box b, float t, float bt, bool show, color bg, color bd, float hiM, float loM) =>
    float ct = math.min(t, hiM)
    float cb = math.max(bt, loM)
    bool  onScreen = show and ct > cb
    box.set_top(b, onScreen ? ct : hiM)
    box.set_bottom(b, onScreen ? cb : hiM)
    box.set_bgcolor(b, onScreen ? bg : color(na))
    box.set_border_color(b, onScreen ? bd : color(na))
if showZones and barstate.islast and not na(vHi)
    // small margin so a zone just above / below the candles is still drawn
    float hiM = vHi + nz(atr) * 1.5
    float loM = vLo - nz(atr) * 1.5
    for z in zones
        f_clip(z.bx, z.top, z.bot, z.vis, f_col(z), z.res ? cResE : cSupE, hiM, loM)
    // ended zones are clipped from their original levels, so nothing is lost when the view changes
    for p in past
        f_clip(p.bx, p.top, p.bot, p.vis, f_col(p), p.res ? cResE : cSupE, hiM, loM)

// ═══════════════════════════════════════════════════════════════════════════
//  BUY / SELL  (+ ⭐ confirmation from zones and RSI)
// ═══════════════════════════════════════════════════════════════════════════
bool atSup = false
bool atRes = false
float tol = nz(atr) * NEAR
for z in zones
    if z.born == bar_index and z.flipped
        continue    // a zone that just flipped on this bar does not confirm this bar's signal
    if not z.res and ll3 <= z.top + tol and close >= z.bot - tol
        atSup := true
    if z.res and hh3 >= z.bot - tol and close <= z.top + tol
        atRes := true

bool rsiConfL = not na(barsSinceLo) and barsSinceLo <= rsiLook
bool rsiConfS = not na(barsSinceHi) and barsSinceHi <= rsiLook

int starsL = showStar ? (atSup ? 1 : 0) + (rsiConfL ? 1 : 0) : 0
int starsS = showStar ? (atRes ? 1 : 0) + (rsiConfS ? 1 : 0) : 0

f_stars(int n) =>
    n == 2 ? " ⭐⭐" : n == 1 ? " ⭐" : ""

f_why(bool zoneOk, bool rsiOk, bool isBuy) =>
    string w = ""
    if zoneOk
        w += "\n✓ At a " + (isBuy ? "support" : "resistance") + " zone"
    if rsiOk
        w += "\n✓ RSI was " + (isBuy ? "below " + str.tostring(rsiDnLv) : "above " + str.tostring(rsiUpLv)) + " within " + str.tostring(rsiLook) + " bars"
    w

// graded look: ⭐⭐ signals are drawn larger
f_sigCol(color c, int n) =>
    c
f_sigTxt(color c, int n) =>
    f_txtOn(c)
f_sigSize(int n) =>
    n == 2 ? size.normal : size.small

if showSig and turnUp
    label.new(bar_index, low, "▲ BUY" + f_stars(starsL), xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=f_sigCol(cUp, starsL), textcolor=f_sigTxt(cUp, starsL),
         size=f_sigSize(starsL), text_formatting=text.format_bold,
         tooltip="Trend line turned GREEN at " + f_px(tl) + "." + f_why(atSup, rsiConfL, true) + "\nConfirmed on bar close.")
if showSig and turnDn
    label.new(bar_index, high, "▼ SELL" + f_stars(starsS), xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=f_sigCol(cDn, starsS), textcolor=f_sigTxt(cDn, starsS),
         size=f_sigSize(starsS), text_formatting=text.format_bold,
         tooltip="Trend line turned RED at " + f_px(tl) + "." + f_why(atRes, rsiConfS, false) + "\nConfirmed on bar close.")

if detailAlerts and (turnUp or turnDn)
    int st = turnUp ? starsL : starsS
    alert(syminfo.ticker + " " + timeframe.period + " | " + (turnUp ? "BUY" : "SELL") + f_stars(st) + " @ " + f_px(close) + " | Trend line " + f_px(tl), alert.freq_once_per_bar_close)

// remember the last signal for the dashboard
var int   lastSigBar  = na
var bool  lastSigBuy  = false
var int   lastSigStar = 0
if turnUp or turnDn
    lastSigBar  := bar_index
    lastSigBuy  := turnUp
    lastSigStar := turnUp ? starsL : starsS

// ═══════════════════════════════════════════════════════════════════════════
//  RSI CANDLE MARKS
// ═══════════════════════════════════════════════════════════════════════════
bgcolor(showRsiL and (rsiHi or rsiLo) ? color.new(rsiHi ? cRsiUp : cRsiDn, 85) : na, title="RSI Mark Background")


// ═══════════════════════════════════════════════════════════════════════════
//  ALERT CONDITIONS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(turnUp, "BUY",  "Eye Trend Zones: BUY on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(turnDn, "SELL", "Eye Trend Zones: SELL on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(turnUp and starsL > 0, "Confluence BUY ⭐",  "Eye Trend Zones: confluence BUY on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(turnDn and starsS > 0, "Confluence SELL ⭐", "Eye Trend Zones: confluence SELL on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(barstate.isconfirmed and rsiHi and not rsiHi[1], "RSI Above Upper", "Eye Trend Zones: RSI above upper level on {{ticker}}")
alertcondition(barstate.isconfirmed and rsiLo and not rsiLo[1], "RSI Below Lower", "Eye Trend Zones: RSI below lower level on {{ticker}}")


// ═══════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_grade(Zone z) =>
    float s = f_strength(z)
    s >= 0.66 ? "Strong" : s >= 0.33 ? "Medium" : "Weak"

var table dash = table.new(f_pos(dashPos), 2, 7, frame_color=color.new(chart.fg_color, 75), frame_width=1,
     border_color=color.new(chart.fg_color, 88), border_width=1)

// opaque mix of two colours (keeps the panel solid so candles do not show through)
f_mix(color a, color b, float t) =>
    color.from_gradient(t, 0.0, 1.0, a, b)

f_row(int r, string k, string v, color vc, color vbg) =>
    color kbg = f_mix(chart.bg_color, chart.fg_color, 0.07)
    table.cell(dash, 0, r, k, text_color=color.new(chart.fg_color, 25), bgcolor=kbg, text_size=f_size(dashSize), text_halign=text.align_left)
    table.cell(dash, 1, r, v, text_color=vc, bgcolor=vbg, text_size=f_size(dashSize), text_halign=text.align_left, text_formatting=text.format_bold)

if showDash and barstate.islast
    color plain = f_mix(chart.bg_color, chart.fg_color, 0.03)
    table.cell(dash, 0, 0, "Eye Trend Zones", text_color=color.white, bgcolor=color.rgb(33, 87, 196), text_size=f_size(dashSize), text_formatting=text.format_bold)
    table.cell(dash, 1, 0, "", bgcolor=color.rgb(33, 87, 196))
    table.merge_cells(dash, 0, 0, 1, 0)

    // trend
    f_row(1, "Trend", up ? "UP  ▲" : "DOWN  ▼", up ? cUp : cDn, f_mix(chart.bg_color, up ? cUp : cDn, 0.15))
    f_row(2, "Trend Line", na(tl) ? "—" : f_px(tl), chart.fg_color, plain)

    // last signal
    string sig = na(lastSigBar) ? "—" : (lastSigBuy ? "BUY" : "SELL") + f_stars(lastSigStar) + "  ·  " + str.tostring(bar_index - lastSigBar) + " bars ago"
    color  sc  = na(lastSigBar) ? chart.fg_color : lastSigBuy ? cUp : cDn
    f_row(3, "Last Signal", sig, sc, plain)

    // nearest zones (support = highest active support, resistance = lowest active resistance)
    Zone sup = na
    Zone res = na
    for z in zones
        if not z.res and (na(sup) or z.top > sup.top)
            sup := z
        if z.res and (na(res) or z.bot < res.bot)
            res := z
    string supTxt = not showZones ? "Off" : na(sup) ? "None below" : f_px(sup.bot) + " – " + f_px(sup.top) + "  ·  " + f_grade(sup)
    string resTxt = not showZones ? "Off" : na(res) ? "None above (new high)" : f_px(res.bot) + " – " + f_px(res.top) + "  ·  " + f_grade(res)
    f_row(4, "Support", supTxt, cUp, plain)
    f_row(5, "Resistance", resTxt, cDn, plain)

    // RSI
    string rsiTxt = str.tostring(rsiL, "#.0") + "  ·  " + (rsiHi ? "Above " + str.tostring(rsiUpLv) : rsiLo ? "Below " + str.tostring(rsiDnLv) : "Normal")
    f_row(6, "RSI " + str.tostring(rsiLenL), rsiTxt, rsiHi ? cRsiUp : rsiLo ? cRsiDn : chart.fg_color, plain)
````
