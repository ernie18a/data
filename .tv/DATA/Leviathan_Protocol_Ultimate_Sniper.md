<!-- tradingview-pine-id: PUB;776930d2a9cc48c1b817779f59c2b476 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Leviathan Protocol [Ultimate Sniper]

Source: https://www.tradingview.com/script/ztHPkWXF/

## Description

Description:

The Leviathan Protocol is a comprehensive technical analysis tool designed to track institutional liquidity pools, momentum exhaustion (RSI Divergences), and Support/Resistance Flips (Retests).

Most retail traders fall victim to fakeouts by trading raw breakouts. This indicator was built to filter out market noise and identify the precise moments when "Smart Money" captures liquidity to reverse the market.

HOW THE MATH & LOGIC WORKS:

1. Liquidity Zones (Pivots): The script calculates ta.pivothigh and ta.pivotlow based on a 29-period swing to identify major pools of stop-losses. It plots these as dotted Red (Resistance) and Green (Support) lines.
2. Liquidity Sweeps & Divergence: When the price pierces a liquidity line but closes back inside (leaving a wick), it triggers a Sweep. The script then cross-references this action with a 14-period RSI. If a Top Sweep occurs alongside a lower RSI high, it plots a BEAR DIV label. If a Bottom Sweep occurs with a higher RSI low, it plots a BULL DIV label.
3. S/R Flip Retest (Sniper Mode): When a major liquidity line is completely broken by a candle close, the script saves this level in memory using var variables. If the price returns to test this broken support (now resistance) and gets rejected, it plots an Orange Cross (RETEST SHORT). Vice versa for Longs (RETEST LONG).
4. Predictive EMA 200: Plots a 200 EMA and calculates its angular inertia over the last 5 bars to project a dashed line 30 candles into the future, helping to estimate dynamic support/resistance collisions.

FEATURES & SETTINGS:

* Toggle "Ignore GAP Signals" to prevent false divergence readings in traditional markets (Stocks/Forex) where overnight gaps occur.

Disclaimer: This indicator is for educational and analytical purposes only. It does not constitute financial advice. Always combine these signals with Order Flow analysis (e.g., Spot CVD) and proper risk management.

---

## Source Code

````pine
//@version=6
indicator("Leviathan Protocol [Ultimate Sniper]", overlay=true, max_lines_count=100)

// ==========================================
// 1. GENERAL SETTINGS
// ==========================================
length = input.int(29, "Liquidity Period (Swing)", minval=3)
rsiLen = input.int(14, "RSI Period")

grp_ema = "EMA 200 Settings"
emaLen = input.int(200, "Main EMA Period", group=grp_ema)
futuro = input.int(30, "EMA Future Projection (Candles)", group=grp_ema)
suavizacao = input.int(5, "Inertia Smoothing", group=grp_ema)

grp_filtros = "Visual Filters"
ignorarGaps = input.bool(true, "Ignore GAP Signals (Stocks/Forex)", group=grp_filtros)
mostrarSimples = input.bool(false, "Show Simple Sweeps (No Divergence)", group=grp_filtros)

// ==========================================
// 2. EMA 200 & LASER PROJECTION
// ==========================================
ema200 = ta.ema(close, emaLen)
plot(ema200, color=color.yellow, linewidth=2, title="Real EMA 200")

velocidade = (ema200 - ema200[suavizacao]) / suavizacao
var line linhaProjecao = na

if barstate.islast
    line.delete(linhaProjecao)
    y_futuro = ema200 + (velocidade * futuro)
    linhaProjecao := line.new(x1=bar_index, y1=ema200, x2=bar_index + futuro, y2=y_futuro, color=color.new(color.yellow, 40), width=2, style=line.style_dashed)

// ==========================================
// 3. RSI & DIVERGENCES
// ==========================================
rsi = ta.rsi(close, rsiLen)

// ==========================================
// 4. LIQUIDITY LOGIC & PIVOTS
// ==========================================
ph = ta.pivothigh(high, length, length)
pl = ta.pivotlow(low, length, length)

var float topLiquidity = na
var float bottomLiquidity = na
var float topRsi = na
var float botRsi = na

// Sniper Memory (S/R Flip Retest)
var float brokenSupport = na
var float brokenResistance = na

// Update Main Highs and Lows
if not na(ph)
    topLiquidity := high[length]
    topRsi := rsi[length]
if not na(pl)
    bottomLiquidity := low[length]
    botRsi := rsi[length]

plot(topLiquidity, title="Top Liquidity", color=color.new(color.red, 30), linewidth=2, style=plot.style_circles, offset=-length)
plot(bottomLiquidity, title="Bottom Liquidity", color=color.new(color.green, 30), linewidth=2, style=plot.style_circles, offset=-length)

// ==========================================
// 5. BREAKOUT DETECTORS (CRIME SCENE)
// ==========================================
if (close < bottomLiquidity and close[1] >= bottomLiquidity)
    brokenSupport := bottomLiquidity

if (close > topLiquidity and close[1] <= topLiquidity)
    brokenResistance := topLiquidity

plot(brokenSupport, title="Retest Target (Short)", color=color.new(color.orange, 50), style=plot.style_cross, linewidth=1)
plot(brokenResistance, title="Retest Target (Long)", color=color.new(color.aqua, 50), style=plot.style_cross, linewidth=1)

// ==========================================
// 6. SWEEP & DIVERGENCE TRIGGERS
// ==========================================
isGap = (low > high[1]) or (high < low[1])

sweepUp = (high > topLiquidity and close < topLiquidity) and (not isGap or not ignorarGaps)
sweepDown = (low < bottomLiquidity and close > bottomLiquidity) and (not isGap or not ignorarGaps)

bearDiv = sweepUp and (rsi < topRsi)
bullDiv = sweepDown and (rsi > botRsi)

// ==========================================
// 7. SNIPER TRIGGER: THE RETEST (S/R FLIP)
// ==========================================
retesteBaixa = (high >= brokenSupport) and (close < brokenSupport) and (open < brokenSupport)
retesteAlta = (low <= brokenResistance) and (close > brokenResistance) and (open > brokenResistance)

// ==========================================
// 8. PLOTTING (FIGHTER HUD)
// ==========================================
// Simple Signals (Toggleable)
plotshape(mostrarSimples and sweepUp and not bearDiv and not sweepUp[1], title="Simple Top Sweep", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)
plotshape(mostrarSimples and sweepDown and not bullDiv and not sweepDown[1], title="Simple Bottom Sweep", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)

// Main Signals (Gold)
plotshape(bearDiv and not bearDiv[1], title="BEAR DIV", location=location.abovebar, color=color.purple, style=shape.labeldown, text="BEAR\nDIV", textcolor=color.white, size=size.small)
plotshape(bullDiv and not bullDiv[1], title="BULL DIV", location=location.belowbar, color=color.teal, style=shape.labelup, text="BULL\nDIV", textcolor=color.white, size=size.small)

// Retest Signals
plotshape(retesteBaixa and not retesteBaixa[1], title="SHORT RETEST", location=location.abovebar, color=color.orange, style=shape.xcross, text="RETEST\nSHORT", textcolor=color.orange, size=size.small)
plotshape(retesteAlta and not retesteAlta[1], title="LONG RETEST", location=location.belowbar, color=color.aqua, style=shape.xcross, text="RETEST\nLONG", textcolor=color.aqua, size=size.small)

// ==========================================
// 9. ALERTS
// ==========================================
alertcondition(bearDiv and not bearDiv[1], title="🔴 SELL (Top)", message="Short Opportunity (Divergence & Sweep)")
alertcondition(bullDiv and not bullDiv[1], title="🟢 BUY (Bottom)", message="Long Opportunity (Divergence & Sweep)")
alertcondition(retesteBaixa and not retesteBaixa[1], title="⚠️ SNIPER ALERT: Short Retest", message="Price retesting broken support. Short Opportunity!")
alertcondition(retesteAlta and not retesteAlta[1], title="⚠️ SNIPER ALERT: Long Retest", message="Price retesting broken resistance. Long Opportunity!")
````
