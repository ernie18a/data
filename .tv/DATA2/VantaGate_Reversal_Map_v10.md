<!-- tradingview-pine-id: PUB;859f7725808f4d20ad1c2b1a0540a148 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VantaGate Reversal Map v1.0

Source: https://www.tradingview.com/script/dd0RxHTI-VantaGate-Reversal-Map-v1-0/

## Description

VantaGate Reversal Map

VantaGate is a reversal indicator designed to find areas where price may be stretched and ready to turn. It brings together price location, volatility, momentum, candle rejection, volume, and recent liquidity behavior to produce clear LONG and SHORT signals directly on the chart.

How it works

The silver line represents the current center of price movement. Think of it as an estimate of where price would be considered balanced.

The aqua area below price is the discount reversal zone. This is where VantaGate starts watching for a possible bottom and long opportunity.

The red area above price is the premium reversal zone. This is where VantaGate starts watching for a possible top and short opportunity.

The faint stepped lines show recent highs and lows where orders may be resting. Price often reacts around these areas because traders place entries, stops, and profit targets near previous turning points.

What the diamonds mean

An aqua diamond appears when price enters the lower reversal area and shows evidence that buyers may be responding. This can happen when price briefly moves below a recent low and recovers, or when a candle closes strongly after rejecting lower prices.

A pink diamond appears when price enters the upper reversal area and shows evidence that sellers may be responding. This can happen when price briefly moves above a recent high and falls back, or when a candle closes weakly after rejecting higher prices.

A diamond does not mean enter immediately. It means that side of the market has become active and VantaGate is watching for confirmation.

What creates a LONG or SHORT signal

A LONG signal appears when the lower reversal zone has recently been activated and the internal VantaSpring calculation confirms that downward pressure is beginning to turn upward.

A SHORT signal appears when the upper reversal zone has recently been activated and the internal VantaSpring calculation confirms that upward pressure is beginning to turn downward.

The zone remains active for a limited number of candles after the diamond appears. This gives price enough time to form a proper reversal instead of requiring every condition to happen on the same candle.

Signals are confirmed only after the candle closes. A signal will not appear during the candle and then disappear before the candle finishes.

What makes VantaGate different

VantaGate does not treat every overbought or oversold reading as a trade.

It first asks whether price has moved far enough away from its normal center to matter. It then looks for a real response from buyers or sellers. Finally, it checks whether momentum is beginning to turn.

This creates a simple progression.

Price becomes stretched.

A reversal zone becomes active.

The market shows rejection or a liquidity recovery.

Momentum begins turning.

VantaGate prints a confirmed LONG or SHORT signal.

Understanding the settings

Regression Center Length controls how quickly the silver center line adjusts to price. Lower values react faster. Higher values create a slower and broader view of the market.

Zone ATR Length controls how volatility is measured. The default value is 34. If you use a separate ATR indicator for stop calculations, set it to length 34 with RMA smoothing so it matches VantaGate.

Zone Entry Distance controls how far price must move from the center before entering a reversal area.

Zone Outer Distance controls the outside boundary of each reversal area.

Liquidity Lookback controls how far back VantaGate searches for recent highs and lows.

Zone Permission Memory controls how many candles a reversal zone remains active after qualifying evidence appears.

Rejection Close Threshold controls how strongly a candle must recover from its high or low to count as rejection.

Show Prior Liquidity Levels displays or hides the faint stepped levels.

Color Confirmed Bars changes the color of candles that receive a confirmed LONG or SHORT signal.

Alerts

VantaGate includes separate alerts for LONG and SHORT signals along with one combined alert named VantaGate Any Green Light. The combined alert is the easiest choice when both directions should be monitored with a single TradingView alert.

Suggested use

VantaGate is designed as a decision tool rather than a complete trading system. A LONG or SHORT label identifies a qualified reversal opportunity, but traders should still consider market conditions, available room to the next obstacle, position size, and risk.

The default settings use a 34 period ATR. One possible risk method is placing the stop approximately 2.05 ATR from the reference point and using a reward target equal to twice the amount being risked.

Always test the indicator on the market and timeframe you intend to trade before using real funds. No indicator can predict every reversal, and strong trends can continue farther than expected.

This indicator is provided for educational and informational purposes only. It is not financial advice or a guarantee of future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
indicator("VantaGate Reversal Map v1.0", shorttitle="VantaGate v1", overlay=true)

mapLength = input.int(55, "Regression Center Length", minval=10)
atrLength = input.int(34, "Zone ATR Length", minval=5)
innerDistance = input.float(1.10, "Zone Entry Distance", minval=0.25, step=0.05)
outerDistance = input.float(1.80, "Zone Outer Distance", minval=0.50, step=0.05)
liquidityLength = input.int(20, "Liquidity Lookback", minval=5)
zoneMemory = input.int(12, "Zone Permission Memory", minval=1, maxval=50)
rejectionThreshold = input.float(0.62, "Rejection Close Threshold", minval=0.50, maxval=0.90, step=0.01)
showLiquidity = input.bool(true, "Show Prior Liquidity Levels")
colorConfirmedBars = input.bool(true, "Color Confirmed Bars")

mapCenter = ta.linreg(hlc3, mapLength, 0)
mapAtr = math.max(ta.atr(atrLength), syminfo.mintick)
upperInner = mapCenter + mapAtr * innerDistance
upperOuter = mapCenter + mapAtr * outerDistance
lowerInner = mapCenter - mapAtr * innerDistance
lowerOuter = mapCenter - mapAtr * outerDistance
priorLiquidityHigh = ta.highest(high[1], liquidityLength)
priorLiquidityLow = ta.lowest(low[1], liquidityLength)
candleRangeMap = math.max(high - low, syminfo.mintick)
closeLocation = (close - low) / candleRangeMap

lowerZoneTouch = low <= lowerInner
upperZoneTouch = high >= upperInner
lowerLiquiditySweep = low < priorLiquidityLow and close > priorLiquidityLow
upperLiquiditySweep = high > priorLiquidityHigh and close < priorLiquidityHigh
lowerAbsorption = lowerZoneTouch and closeLocation >= rejectionThreshold and close > open
upperAbsorption = upperZoneTouch and closeLocation <= 1.0 - rejectionThreshold and close < open
lowerZoneEvent = lowerZoneTouch and (lowerLiquiditySweep or lowerAbsorption)
upperZoneEvent = upperZoneTouch and (upperLiquiditySweep or upperAbsorption)
barsSinceLowerEvent = nz(ta.barssince(lowerZoneEvent), 100000)
barsSinceUpperEvent = nz(ta.barssince(upperZoneEvent), 100000)
lowerZoneReady = barsSinceLowerEvent <= zoneMemory
upperZoneReady = barsSinceUpperEvent <= zoneMemory

vantaEquilibrium = ta.ema(hlc3, 34)
vantaVolatility = math.max(ta.atr(34), syminfo.mintick)
vantaStretch = (hlc3 - vantaEquilibrium) / vantaVolatility
vantaVelocity = (hlc3 - hlc3[5]) / (vantaVolatility * math.sqrt(5.0))
vantaRecoil = vantaVelocity - ta.ema(vantaVelocity, 5)
vantaCandleRange = math.max(high - low, syminfo.mintick)
vantaUpperRejection = (high - math.max(open, close)) / vantaCandleRange
vantaLowerRejection = (math.min(open, close) - low) / vantaCandleRange
vantaRejectionBias = vantaUpperRejection - vantaLowerRejection
vantaVolumeBaseline = ta.ema(nz(volume, 0.0), 34)
vantaVolumeSurge = vantaVolumeBaseline > 0.0 ? math.max(0.0, math.min(nz(volume, 0.0) / vantaVolumeBaseline - 1.0, 2.0)) : 0.0
vantaParticipatingRejection = vantaRejectionBias * (1.0 + 0.35 * vantaVolumeSurge)
vantaFieldRaw = 0.46 * vantaStretch + 0.24 * vantaVelocity + 0.18 * vantaRecoil + 0.12 * vantaParticipatingRejection
vantaField = ta.ema(vantaFieldRaw, 3)
vantaNatural = 50.0 + 50.0 * vantaField / (1.0 + math.abs(vantaField))

var int vantaUpperAge = 0
var int vantaLowerAge = 0
vantaUpperAge := vantaNatural >= 78.0 ? nz(vantaUpperAge[1]) + 1 : 0
vantaLowerAge := vantaNatural <= 22.0 ? nz(vantaLowerAge[1]) + 1 : 0
vantaExtremeAge = math.max(vantaUpperAge, vantaLowerAge)
vantaRelease = 1.0 / (1.0 + math.max(vantaExtremeAge - 5, 0) * 0.12)
vantaSpring = 50.0 + (vantaNatural - 50.0) * vantaRelease

vantaBaseAlpha = 2.0 / 8.0
vantaTension = math.min(math.abs(vantaSpring - 50.0) / 50.0, 1.0)
vantaAdaptiveAlpha = vantaBaseAlpha * (1.0 - 0.45 * vantaTension)
var float vantaGravity = na
vantaGravity := na(vantaGravity[1]) ? vantaSpring : vantaGravity[1] + vantaAdaptiveAlpha * (vantaSpring - vantaGravity[1])

vantaBottomArmed = ta.lowest(vantaSpring, 12) <= 22.0
vantaTopArmed = ta.highest(vantaSpring, 12) >= 78.0
vantaBuy = ta.crossover(vantaSpring, vantaGravity) and vantaBottomArmed and vantaSpring < 50.0 and vantaField > vantaField[1]
vantaSell = ta.crossunder(vantaSpring, vantaGravity) and vantaTopArmed and vantaSpring > 50.0 and vantaField < vantaField[1]
longGreenLight = barstate.isconfirmed and vantaBuy and lowerZoneReady
shortGreenLight = barstate.isconfirmed and vantaSell and upperZoneReady

centerPlot = plot(mapCenter, "Regression Center", color=color.new(color.silver, 20), linewidth=2)
upperInnerPlot = plot(upperInner, "Upper Zone Entry", color=color.new(color.red, 35))
upperOuterPlot = plot(upperOuter, "Upper Zone Outer", color=color.new(color.red, 65))
lowerInnerPlot = plot(lowerInner, "Lower Zone Entry", color=color.new(color.aqua, 35))
lowerOuterPlot = plot(lowerOuter, "Lower Zone Outer", color=color.new(color.aqua, 65))

fill(upperInnerPlot, upperOuterPlot, color=upperZoneReady ? color.new(color.red, 78) : color.new(color.red, 91), title="Premium Reversal Zone")
fill(lowerInnerPlot, lowerOuterPlot, color=lowerZoneReady ? color.new(color.aqua, 78) : color.new(color.aqua, 91), title="Discount Reversal Zone")

plot(showLiquidity ? priorLiquidityHigh : na, "Prior Liquidity High", color=color.new(color.red, 72), style=plot.style_stepline)
plot(showLiquidity ? priorLiquidityLow : na, "Prior Liquidity Low", color=color.new(color.teal, 72), style=plot.style_stepline)

plotshape(lowerZoneEvent and barstate.isconfirmed, title="Lower Zone Armed", style=shape.diamond, location=location.belowbar, color=color.aqua, size=size.tiny)
plotshape(upperZoneEvent and barstate.isconfirmed, title="Upper Zone Armed", style=shape.diamond, location=location.abovebar, color=color.fuchsia, size=size.tiny)
plotshape(longGreenLight, title="Combined Long Green Light", style=shape.labelup, location=location.belowbar, color=color.rgb(0, 230, 150), size=size.small, text="LONG", textcolor=color.black)
plotshape(shortGreenLight, title="Combined Short Green Light", style=shape.labeldown, location=location.abovebar, color=color.rgb(255, 70, 105), size=size.small, text="SHORT", textcolor=color.white)

barcolor(colorConfirmedBars ? longGreenLight ? color.rgb(0, 230, 150) : shortGreenLight ? color.rgb(255, 70, 105) : na : na)

alertcondition(longGreenLight or shortGreenLight, title="VantaGate — Any Green Light", message="VantaGate combined VantaSpring and price-zone confirmation on {{ticker}} {{interval}} at {{close}}")
alertcondition(longGreenLight, title="VantaGate — Long Green Light", message="VantaGate LONG confirmation on {{ticker}} {{interval}} at {{close}}")
alertcondition(shortGreenLight, title="VantaGate — Short Green Light", message="VantaGate SHORT confirmation on {{ticker}} {{interval}} at {{close}}")
````
