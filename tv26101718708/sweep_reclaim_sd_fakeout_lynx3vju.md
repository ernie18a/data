# Sweep + Reclaim | S&D Fakeout

- url: https://www.tradingview.com/script/LyNX3Vju-Sweep-Reclaim-S-D-Fakeout/
- type: indicator
- pine_id: PUB;d962de7538954b028f3fcd829a991e3a
- version: 2.0

## Description

Sweep + Reclaim | S&D Fakeout

Trade the fakeout, not the breakout.

Most breakouts fail. This indicator finds fresh supply and demand zones, then waits for price to sweep liquidity through the zone and reclaim it — the classic stop-hunt reversal — before flagging a trade.

How it works

Zone detection — A supply/demand zone is drawn when a tight base (a few small, overlapping candles) breaks out with a strong displacement candle.
Liquidity sweep — The indicator watches for a wick through the zone's edge that closes back inside. That's trapped traders.
Reclaim trigger — A LONG or SHORT label fires when price closes back through the far edge of the zone with a strong-bodied candle, confirming the fakeout.
What you see

🟩 Green boxes = demand zones (potential longs)
🟥 Red boxes = supply zones (potential shorts)
LONG / SHORT labels = completed sweep + reclaim
Zones are removed once triggered, broken, or expired — only live, actionable zones stay on your chart
Built-in filters

EMA-200 trend filter (on by default): longs only above the EMA, shorts only below — no fighting the trend
Zones expire after 300 bars; max 20 zones kept on screen to avoid clutter
All parameters adjustable: base size, displacement strength, sweep tolerance, reclaim window
Alerts included

Set TradingView alerts on "Sweep+Reclaim LONG" and "Sweep+Reclaim SHORT" to get notified the moment a signal prints — no screen-watching required.

Suggested use

Works on any timeframe; designed around 1H–4H. This is a setup detector, not a standalone buy/sell signal — use the reclaim candle's structure for entries, place stops beyond the sweep extreme, target at least 2:1 reward-to-risk, and always backtest on your symbol and timeframe before trading live.

Educational tool only — not financial advice. No indicator predicts the market.

Two tips for publishing: pick a clean screenshot showing a LONG and a SHORT label with their zones as your preview image, and publish it as open-source so people can see the logic — transparency gets more trust (and more followers) than invite-only.

## Source Code

````pine
//@version=6
indicator("Sweep + Reclaim | S&D Fakeout", shorttitle="SweepReclaim", overlay=true, max_boxes_count=200, max_labels_count=200)
// v6.1 — description cleanup, no logic changes
// ── How it works ───────────────────────────────────────
// 1. Finds supply/demand zones: tight base (a few small candles) + strong displacement candle.
// 2. Waits for a liquidity SWEEP: wick through the zone edge, close back inside.
// 3. Fires LONG/SHORT on the RECLAIM: strong close through the far edge within N bars.
// Signals confirm on bar close. Backtest before using live.

// ── Inputs ──
baseLen     = input.int(3, "Base candles", 2, 10)
baseAtrMult = input.float(1.0, "Base max range (x ATR)", 0.3, 2.0, 0.1)
dispAtrMult = input.float(1.0, "Displacement body (x ATR)", 0.5, 3.0, 0.1)
atrLen      = input.int(14, "ATR length")
sweepTol    = input.float(0.2, "Sweep tolerance (x ATR)", 0.0, 1.0, 0.05)
reclaimBars = input.int(5, "Reclaim window (bars)", 1, 20)
useTrend    = input.bool(false, "Trend filter (EMA 200)")
trendLen    = input.int(200, "Trend EMA length")
maxZones    = input.int(20, "Max zones kept", 5, 50)
zoneAge     = input.int(300, "Zone max age (bars)", 20, 500)

// ── Core calcs ──
atr     = ta.atr(atrLen)
atrSafe = nz(atr, 0.000001)
body    = math.abs(close - open)
emaT    = ta.ema(close, trendLen)
bullTrend = not useTrend or close > emaT
bearTrend = not useTrend or close < emaT

// Base = bars 1..baseLen back; displacement = the just-closed bar
baseHi = ta.highest(high[1], baseLen)
baseLo = ta.lowest(low[1], baseLen)
baseOk = not na(baseHi) and not na(baseLo) and not na(atr)
isBase = baseOk and (baseHi - baseLo) < baseAtrMult * atr[1]

bullDisp = isBase and body > dispAtrMult * atr[1] and close > open and close > baseHi
bearDisp = isBase and body > dispAtrMult * atr[1] and close < open and close < baseLo

// Recent extremes for sweep detection
winLow  = ta.lowest(low, reclaimBars)
winHigh = ta.highest(high, reclaimBars)

// ── Zone storage ──
var box[]   zBox  = array.new_box()
var float[] zTop  = array.new_float()
var float[] zBot  = array.new_float()
var int[]   zBorn = array.new_int()
var int[]   zDir  = array.new_int()   // 1 = demand, -1 = supply

addZone(float top, float bot, int dir) =>
    if array.size(zBox) >= maxZones
        oldBox = array.shift(zBox)
        box.delete(oldBox)
        array.shift(zTop)
        array.shift(zBot)
        array.shift(zBorn)
        array.shift(zDir)
    newBox = box.new(bar_index - baseLen, top, bar_index + 15, bot,
         border_color = dir == 1 ? color.new(color.green, 20) : color.new(color.red, 20),
         bgcolor      = dir == 1 ? color.new(color.green, 88) : color.new(color.red, 88))
    array.push(zBox, newBox)
    array.push(zTop, top)
    array.push(zBot, bot)
    array.push(zBorn, bar_index)
    array.push(zDir, dir)

dropZone(int i) =>
    box.delete(array.get(zBox, i))
    array.remove(zBox, i)
    array.remove(zTop, i)
    array.remove(zBot, i)
    array.remove(zBorn, i)
    array.remove(zDir, i)

// ── New zones ──
if bullDisp
    addZone(baseHi, baseLo, 1)
if bearDisp
    addZone(baseHi, baseLo, -1)

// ── Sweep + reclaim scan ──
longSignal  = false
shortSignal = false

n = array.size(zBox)
if n > 0
    for i = n - 1 to 0
        top  = array.get(zTop, i)
        bot  = array.get(zBot, i)
        dir  = array.get(zDir, i)
        born = array.get(zBorn, i)
        box.set_right(array.get(zBox, i), bar_index + 15)
        if bar_index - born > zoneAge
            dropZone(i)
        else if bar_index > born   // don't judge a zone on its birth bar
            if dir == 1
                // DEMAND: wicked below the zone within the window, closed back above it = sweep
                broken  = close < bot - atrSafe
                swept   = winLow < bot - sweepTol * atrSafe and close > bot
                trigger = swept and close > top and close > open and body > 0.5 * atrSafe and bullTrend
                if broken
                    dropZone(i)
                else if trigger
                    longSignal := true
                    label.new(bar_index, low, "LONG\nSweep+Reclaim", style=label.style_label_up,
                         color=color.new(color.green, 10), textcolor=color.white, size=size.small)
                    dropZone(i)
            else
                // SUPPLY: wicked above the zone within the window, closed back below it = sweep
                broken  = close > top + atrSafe
                swept   = winHigh > top + sweepTol * atrSafe and close < top
                trigger = swept and close < bot and close < open and body > 0.5 * atrSafe and bearTrend
                if broken
                    dropZone(i)
                else if trigger
                    shortSignal := true
                    label.new(bar_index, high, "SHORT\nSweep+Reclaim", style=label.style_label_down,
                         color=color.new(color.red, 10), textcolor=color.white, size=size.small)
                    dropZone(i)

// ── Alerts (pick these in TradingView's alert dialog) ──
alertcondition(longSignal,  title="Sweep+Reclaim LONG",  message="Sweep+Reclaim LONG on {{ticker}} ({{interval}})")
alertcondition(shortSignal, title="Sweep+Reclaim SHORT", message="Sweep+Reclaim SHORT on {{ticker}} ({{interval}})")
````
