# Sistem Sniper V3: Pre-Breakout + SMA 200 Filtru

- url: https://www.tradingview.com/script/0GMQXBHg-Sistem-Sniper-V3-Pre-Breakout-SMA-200-Filtru/
- type: indicator
- pine_id: PUB;b90b33920f2c47d098bcedb539dc6e2f
- version: 1.0

## Description

**Sniper V3 System: Technical Interpretation & Execution Guide**

 **1. System Architecture & Philosophy**

The Sniper V3 is a mechanical, rules-based indicator designed specifically for Small and Mid-Cap equities. It does not predict the future; rather, it identifies **Volatility Contraction Patterns (VCP)** combined with anomalous institutional volume, effectively highlighting the final stages of an accumulation phase (Wyckoff Phase C/D) before a potential breakout occurs.

The system enforces strict mathematical discipline by calculating a fixed 1:2 Risk/Reward ($R:R$) ratio at the exact moment of the signal, removing emotional bias from trade management.

---

 **2. Visual Dashboard (Legend)**

When applied to a logarithmic chart, the indicator plots several critical overlays. Here is how to interpret them:

| Visual Element | Technical Definition | Interpretation |
| --- | --- | --- |
| **Turquoise Line** | EMA 20 (Short-Term Momentum) | Indicates immediate price direction. |
| **Pink Line** | EMA 50 (Medium-Term Trend) | Acts as dynamic support within the accumulation base. |
| **Thick Yellow Line** | SMA 200 (Institutional Anchor) | **The Macro Filter.** If the price is below this line, the asset is in a bear market. Signals are structurally invalid and blocked. |
| **Grey Continuous Line** | Chandelier Exit (ATR Trailing) | Measures market volatility. A tightening grey line indicates severe volatility contraction (dry-up), which is highly favorable before a breakout. |
| **"SNIPER" Label** | Master Trigger | The exact daily candle where all mathematical conditions (Time, Volume, Trend) align. |

---

**3. Trade Management Lines (The "Frozen" Math)**

Upon a valid "SNIPER" signal, three horizontal lines will appear on the chart. These lines are mathematically "frozen" based on the exact moment the signal was triggered. They dictate your mechanical execution:

* **Blue Line (Entry Price):** The exact closing price of the signal candle. This is your baseline execution level.
* **Red Line (Stop Loss):** Calculated using the Chandelier Exit ([symbol="AMEX:HIGH"]AMEX:HIGH[/symbol] - 3 \times ATR$). This represents structural failure. If the price closes below this line, the accumulation thesis is void.
* **Green Line (Take Profit):** Automatically projected at a strict **1:2 $R:R$ ratio** based on the distance between the Blue and Red lines.

---

 **4. Step-by-Step Execution Protocol**

Do not trade the alert blindly. When you receive the email notification, follow this strict protocol:

**Step 1: Structural Validation (The "Space" Test)**
Look at the Green Line (Take Profit). Is there a massive historical resistance level (a prior double top, heavy supply zone) *below* the Green Line?

* *Action:* If the profit target is blocked by structural overhead supply, **skip the trade**. The system requires a clear path to achieve the 1:2 ratio.

**Step 2: The "Gap" Rule (Pre-Market Reality Check)**
Small/Mid-Cap stocks are highly susceptible to overnight gaps. If the stock opens the next day with a massive "Gap Up" (significantly higher than your Blue Entry Line), your calculated $R:R$ is destroyed because your Stop Loss (Red Line) is now much further away.

* *Action:* **Do not chase the price.** Place a *Limit Order* at the Blue Line. If the price does not retrace to fill your order, you miss the trade. Protecting capital is superior to entering a mathematically compromised position.

**Step 3: Mechanical Exit**
Once the trade is active, no human intervention is required. The trade concludes only under two conditions:

1. The price hits the Green Line (Take Profit execution).
2. The price hits the Red Line (Stop Loss execution).

---

 **5. The Devil's Advocate (System Limitations)**

To use this system professionally, you must understand its vulnerabilities:

* **The Bull Case (Why it works):** By buying *inside* the upper third of the accumulation range (Pre-Breakout) rather than buying the actual breakout, your Stop Loss is incredibly tight. This asymmetric risk profile means you can be wrong 50% of the time and still be highly profitable, as winners pay out twice the risk.
* **The Bear Case (The Liquidity Trap):** The system relies on a 2-day volume spike. In highly illiquid Small-Caps, a single retail "pump" or a newsletter mention can artificially trigger the volume parameter without genuine institutional backing. The price will trigger the "SNIPER" label, only to immediately reverse and bleed back to the bottom of the range (a "Fakeout"), triggering your Stop Loss.
* **Mitigation:** Only apply this indicator to a pre-vetted Watchlist of fundamentally sound companies with adequate baseline liquidity (e.g., Average Daily Volume > $500k).

## Source Code

````pine
//@version=6
indicator('Sistem Sniper V3: Pre-Breakout + SMA 200 Filtru', overlay = true)

// 1. Parametri Input
lookbackPeriod = input.int(50, title = 'Zile Structură Acumulare', minval = 2)
volLength = input.int(20, title = 'Perioadă Medie Volum', minval = 1)
rvolMult = input.float(1.3, title = 'Prag Minim RVOL', minval = 0.1, step = 0.1)
ema1Length = input.int(20, title = 'Perioadă EMA 1 (Scurt)', minval = 1)
ema2Length = input.int(50, title = 'Perioadă EMA 2 (Mediu)', minval = 1)
useEmaFilter = input.bool(true, title = 'Filtru Activ: EMA1 > EMA2')
sma200Length = input.int(200, title = 'Perioadă SMA Trend Major', minval = 1)
useSmaFilter = input.bool(true, title = 'Filtru Activ: Preț > SMA 200')
chandelierPeriod = input.int(22, title = 'Chandelier ATR Period', minval = 1)
chandelierMult = input.float(3.0, title = 'Chandelier Multiplier', minval = 0.1, step = 0.1)

// 2. Calcule Medii Mobile
ema1 = ta.ema(close, ema1Length)
ema2 = ta.ema(close, ema2Length)
sma200 = ta.sma(close, sma200Length)

// 3. Calculul Structurii de Acumulare
highestHigh = ta.highest(high[1], lookbackPeriod)
lowestLow = ta.lowest(low[1], lookbackPeriod)
rangeWidth = highestHigh - lowestLow
upperThirdZone = lowestLow + rangeWidth * 0.65
isInsideAccumulation = not na(highestHigh) and not na(lowestLow) and rangeWidth > 0 and close > upperThirdZone and close <= highestHigh

// 4. Logica de Volum
volAvg = ta.sma(volume, volLength)
volumeIncreasing = volume > volume[1] and volume[1] > volume[2]
isVolumeValid = volume > volAvg * rvolMult

// 5. Calculul Chandelier Exit
atrValue = ta.atr(chandelierPeriod)
highestHighChandelier = ta.highest(high, chandelierPeriod)
chandelierExitValue = highestHighChandelier - chandelierMult * atrValue

// 6. Condiții de Trend
emaCondition = useEmaFilter ? ema1 > ema2 : true
smaCondition = useSmaFilter ? close > sma200 : true

// 7. Trigger brut
baseSignal = isInsideAccumulation and volumeIncreasing and isVolumeValid and emaCondition and smaCondition

// 8. Algoritmul Matematic
var float entryPrice = na
var float stopLoss = na
var float takeProfit = na
var bool inTrade = false

tempStop = chandelierExitValue >= close ? close - 2.0 * atrValue : chandelierExitValue
currentRisk = close - tempStop

validRisk = not na(currentRisk) and currentRisk > 0
triggerSignal = baseSignal and not inTrade and validRisk

exitCondition = inTrade and not na(stopLoss) and not na(takeProfit) and (low <= stopLoss or high >= takeProfit)

if triggerSignal
    entryPrice := close
    stopLoss := tempStop
    takeProfit := close + 2.0 * currentRisk
    inTrade := true
    inTrade
else if exitCondition
    entryPrice := na
    stopLoss := na
    takeProfit := na
    inTrade := false
    inTrade

// 9. Randare Grafică
plot(ema1, title = 'EMA Scurt', color = color.new(#00f5d4, 0), linewidth = 1)
plot(ema2, title = 'EMA Mediu', color = color.new(#ff007f, 0), linewidth = 1)
plot(sma200, title = 'SMA 200', color = color.new(#ffb703, 0), linewidth = 2)

plot(inTrade ? entryPrice : na, title = 'Intrare', color = color.blue, style = plot.style_linebr, linewidth = 2)
plot(inTrade ? stopLoss : na, title = 'Stop Loss', color = color.red, style = plot.style_linebr, linewidth = 2)
plot(inTrade ? takeProfit : na, title = 'Take Profit', color = color.green, style = plot.style_linebr, linewidth = 2)

plot(chandelierExitValue, title = 'Chandelier', color = color.new(color.gray, 70), style = plot.style_line)
plotshape(triggerSignal, title = 'Sniper', style = shape.labelup, location = location.belowbar, color = color.green, text = 'SNIPER', textcolor = color.white, size = size.normal)

// 10. Alerte
alertcondition(triggerSignal, title = 'Alertă Sniper V3', message = 'Semnal VALIDAT! Structura confirmata de volum pe graficul Algo.')
````
