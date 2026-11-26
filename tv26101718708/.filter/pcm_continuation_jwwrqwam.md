# PCM Continuation

- url: https://www.tradingview.com/script/JWwrqwAM/
- type: indicator
- pine_id: PUB;5399594ca9a540d1a03bc76deb0033a4
- version: 4.0

## Description

# PCM Liquidity Heatmap Core

Der PCM Liquidity Heatmap Core ist ein professioneller Multi-Timeframe Momentum- und Liquiditätsindikator für Scalping und Intraday-Trading.

Der Fokus liegt nicht auf klassischen „Buy/Sell“-Indikatoren, sondern auf dem tatsächlichen Verhalten institutioneller Liquidität im Markt.

Die Kernidee:
Der Markt bewegt sich von Liquidität zu Liquidität.

Der Indikator kombiniert deshalb mehrere intelligente Komponenten:

- Liquidity Filter
- Liquidity Sweeps
- Heatmap Trailing
- Momentum-Bestätigung
- Multi-Timeframe-Bias

Das Ziel:
Hochwertige Entries mit starkem Momentum und möglichst viel Strecke bis zur nächsten Zielliquidität.

---

## Kernlogik des Indikators

### 1. Liquidity Filter = Markt-Bias

Der Liquidity Filter analysiert:
- ob Käufer oder Verkäufer dominieren
- ob Momentum nachhaltig ist
- ob der Markt eher trendet oder absorbiert wird

Der Filter dient als Haupt-Bias.

Beispiel:
- grüner Liquidity Filter → bevorzugt LONGS
- roter Liquidity Filter → bevorzugt SHORTS

---

### 2. Liquidity Sweeps = Setup-Erkennung

Der Indikator erkennt gezielte Liquiditätshunts:
- Sweeps über Equal Highs
- Sweeps unter Equal Lows
- Stop Hunts
- Liquidity Grabs

Dadurch werden Entries nicht mitten im Move erzeugt,
sondern möglichst nahe am eigentlichen institutionellen Einstiegspunkt.

---

### 3. Heatmap Trail = Smart Exit Engine

Die Heatmap analysiert:
- Druckzonen
- Momentum-Stärke
- Trendintensität
- dynamische Trailing-Bereiche

Dadurch werden Trades nicht unnötig früh geschlossen.

Das Ziel:
Längere Trends sauber laufen lassen.

---

## Multi-Timeframe-System

Der Indikator arbeitet mit mehreren Zeiteinheiten gleichzeitig.

### Empfohlene Einstellungen:
- Trigger TF → 15 Sekunden
- Confirmation TF → 1 Minute
- Bias TF → 3 Minuten

Dadurch entsteht:
- schneller Entry
- sauberer Bias
- bessere Filterung von Chop

---

## Ideal für:
- Futures Trading
- Nasdaq / S&P 500
- DAX
- Forex
- Intraday-Trading
- Scalping
- Momentum-Trading
- Liquidity-Based Trading

---

## Besonderheiten

✅ Keine klassischen EMA-Crossover-Signale  
✅ Fokus auf institutionelle Liquidität  
✅ Smart Heatmap Trailing  
✅ Sweep-basierte Entries  
✅ Multi-Timeframe Confirmation  
✅ Dynamische Zielzonen  
✅ Fokus auf hohe CRVs  
✅ Entwickelt für längere, saubere Bewegungen statt Mikro-Chop

---

## Wichtiger Hinweis

Der Indikator ist kein automatisches „Geldsystem“.

Er soll dabei helfen:
- hochwertige Setups schneller zu erkennen
- Liquidität besser zu lesen
- Momentum besser einzuordnen
- schlechte Trades zu vermeiden

Wie bei jeder Tradingstrategie sind:
Risikomanagement, Erfahrung und Marktverständnis entscheidend.

## Source Code

````pine
//@version=6
indicator("💶PCM Liquidity + Heatmap3.0", overlay=true, max_labels_count=500)

// ==========================
// Preset
// ==========================
groupPreset = "Preset / Tradingstil"
tradingPreset = input.string("MES Standard", "Tradingstil", options=[
     "Manuell",
     "MNQ aggressiv",
     "MNQ Trend-Scalp",
     "MES aggressiv",
     "MES Standard",
     "MES A+ Qualität",
     "FDXS / DAX Scalping",
     "MCL / Öl Scalping",
     "MGC / Gold Scalping",
     "Intraday Swing Index",
     "Aktien / ETFs Intraday",
     "Aktien / ETFs Daily/Swing",
     "MES M1 aggressiv",
     "MES M1 Standard",
     "MES M1 A+",
     "MNQ M1 aggressiv",
     "MNQ M1 Standard"
], group=groupPreset)

isManual = tradingPreset == "Manuell"
triggerConfirmMode = input.string("Liquidity + Heatmap Pflicht", "Trigger-Bestätigung", options=["Liquidity + Heatmap Pflicht", "Mindestens 1 von 2"], group=groupPreset)

// ==========================
// Inputs
// ==========================
groupTF = "Timeframes / Manuell"
tfTriggerInput = input.timeframe("15S", "Trigger TF", group=groupTF)
tfConfirmInput = input.timeframe("1", "Confirmation TF", group=groupTF)
useThirdTFInput = input.bool(true, "3. TF aktivieren", group=groupTF)
tfThirdInput = input.timeframe("3", "3. Confirmation TF", group=groupTF)

groupSignal = "Signal-Logik / Manuell"
confirmMode = input.string("Mindestens 1 von 2", "Bestätigung pro Timeframe", options=["Mindestens 1 von 2", "Beide müssen gleich sein"], group=groupSignal)
minConfirmedTFsInput = input.int(2, "Mindestanzahl bestätigter Timeframes", minval=1, maxval=3, group=groupSignal)

groupLiq = "Liquidity Trendline"
liqLen = input.int(12, "Liquidity Length", minval=1, group=groupLiq)
liqMult = input.float(2.0, "Liquidity Multiplier", minval=0.1, step=0.1, group=groupLiq)
liqSrc = input.source(close, "Liquidity Source", group=groupLiq)

groupHeat = "Heatmap Trailing Stop"
stopATRlen = input.int(28, "Stop ATR Length", minval=2, group=groupHeat)
stopMult = input.float(5.0, "Stop Multiplier", minval=0.1, step=0.1, group=groupHeat)

groupADX = "ADX Filter / Manuell"
useAdxFilter = input.bool(true, "ADX-Filter aktivieren", group=groupADX)
adxTFInput = input.timeframe("15", "ADX Timeframe", group=groupADX)
adxLen = input.int(14, "ADX Länge", minval=2, group=groupADX)
adxMin = input.float(20.0, "ADX Mindestwert", minval=1, step=0.5, group=groupADX)
requireAdxNotFallingInput = input.bool(false, "ADX darf NICHT fallen", group=groupADX)

groupBias = "Bias Filter / Manuell"
useBiasFilterInput = input.bool(false, "Bias-Filter aktivieren", group=groupBias)
biasTFInput = input.timeframe("15", "Bias Timeframe", group=groupBias)
biasModeInput = input.string("EMA + VWAP", "Bias-Modus", options=["Nur EMA", "Nur VWAP", "EMA + VWAP"], group=groupBias)
emaFastLenInput = input.int(21, "EMA Fast", minval=1, group=groupBias)
emaSlowLenInput = input.int(50, "EMA Slow", minval=1, group=groupBias)

groupBASS = "BASS Bias Filter / Manuell"
useBassFilterInput = input.bool(true, "BASS Filter aktivieren", group=groupBASS)
bassTFInput = input.timeframe("3", "BASS Timeframe", group=groupBASS)
bassModeInput = input.string("Mindestens X von 5", "BASS Modus", options=["Mindestens X von 5", "Alle 5 müssen passen", "Mindestens X von 6 inkl. Volumen", "Alle 6 inkl. Volumen"], group=groupBASS)
bassMinConfirmInput = input.int(4, "Mindestanzahl BASS-Bestätigungen", minval=1, maxval=6, group=groupBASS)

groupVAPI = "VAPI Filter / Manuell"
useVapiFilterInput = input.bool(false, "VAPI Filter aktivieren", group=groupVAPI)
vapiTFInput = input.timeframe("5", "VAPI Timeframe", group=groupVAPI)
vapiLenInput = input.int(10, "VAPI Länge", minval=1, group=groupVAPI)
vapiModeInput = input.string("Nur A+ / Warnung", "VAPI Modus", options=["Nur A+ / Warnung", "Pflichtfilter"], group=groupVAPI)
vapiRequireSlopeInput = input.bool(true, "VAPI muss in Signalrichtung steigen/fallen", group=groupVAPI)

macdScale = input.float(1.0, "MACD Scaling", minval=0, step=0.1, group=groupBASS)
rsiScale = input.float(1.0, "RSI Scaling", minval=0, step=0.1, group=groupBASS)
stochScale = input.float(1.0, "Slow Stochastic Scaling", minval=0, step=0.1, group=groupBASS)
aoScale = input.float(1.0, "Awesome Oscillator Scaling", minval=0, step=0.1, group=groupBASS)
gatorScale = input.float(1.0, "Alligator Scaling", minval=0, step=0.1, group=groupBASS)
volumeScale = input.float(1.0, "Volume Bias Scaling", minval=0, step=0.1, group=groupBASS)
volumeBiasLen = input.int(30, "Volume Bias Length", minval=1, group=groupBASS)

groupVol = "Volume Profile Verbesserung"
useVolumeContext = input.bool(true, "Volume-Context anzeigen", group=groupVol)
volTF1 = input.timeframe("15", "Volume TF 1", group=groupVol)
volTF2 = input.timeframe("60", "Volume TF 2", group=groupVol)
volLen = input.int(50, "Volume Context Länge", minval=5, group=groupVol)
volAtrLen = input.int(14, "ATR Länge für Volumen-Zone", minval=2, group=groupVol)
volNearAtr = input.float(0.75, "Nähe zur Volume-Zone in ATR", minval=0.1, step=0.05, group=groupVol)
highVolMult = input.float(1.5, "High-Volume Faktor", minval=1.0, step=0.1, group=groupVol)
volAPlusScore = input.int(3, "A+ ab Volumen-Score", minval=1, maxval=4, group=groupVol)
volOkScore = input.int(2, "OK ab Volumen-Score", minval=1, maxval=4, group=groupVol)

groupExit = "Exit-Logik"
useSmartExit = input.bool(true, "Smarte Exits anzeigen", group=groupExit)
exitMode = input.string("Gegensignal oder Alignment-Verlust", "Exit-Modus", options=["Gegensignal", "Alignment-Verlust", "Gegensignal oder Alignment-Verlust"], group=groupExit)

groupVisual = "Anzeige"
showTable = input.bool(true, "Status-Tabelle anzeigen", group=groupVisual)
showBackground = input.bool(true, "Hintergrund färben", group=groupVisual)

groupTable = "Tabelle"
tableSizeInput = input.string("Normal", "Tabellengröße", options=["Sehr klein", "Klein", "Normal", "Groß"], group=groupTable)
tablePositionInput = input.string("Oben rechts", "Tabellenposition", options=["Oben rechts", "Oben links", "Unten rechts", "Unten links"], group=groupTable)

tableTextSize =
     tableSizeInput == "Sehr klein" ? size.tiny :
     tableSizeInput == "Klein" ? size.small :
     tableSizeInput == "Groß" ? size.large :
     size.normal

tablePosition =
     tablePositionInput == "Oben links" ? position.top_left :
     tablePositionInput == "Unten rechts" ? position.bottom_right :
     tablePositionInput == "Unten links" ? position.bottom_left :
     position.top_right

groupColors = "Anzeige / Farben"
tableTheme = input.string("Heller Chart", "Tabellen-Theme", options=["Heller Chart", "Dunkler Chart"], group=groupColors)
tableTextMode = input.string("Auto", "Tabellen-Schriftfarbe", options=["Auto", "Weiß", "Schwarz"], group=groupColors)

tableHeaderOpacity = input.int(15, "Header Deckkraft", minval=0, maxval=100, group=groupColors)
tableCellOpacity = input.int(25, "Zellen Deckkraft Long/Short", minval=0, maxval=100, group=groupColors)
tableNeutralOpacity = input.int(75, "Zellen Deckkraft Neutral", minval=0, maxval=100, group=groupColors)

longSignalColor = input.color(color.green, "LONG Signal Farbe", group=groupColors)
shortSignalColor = input.color(color.red, "SHORT Signal Farbe", group=groupColors)
exitSignalColor = input.color(color.orange, "EXIT Signal Farbe", group=groupColors)
signalOpacity = input.int(0, "Signal Deckkraft", minval=0, maxval=100, group=groupColors)
signalTextColor = input.color(color.white, "Signal Schriftfarbe", group=groupColors)

bgLongColor = input.color(color.green, "Hintergrund LONG Farbe", group=groupColors)
bgShortColor = input.color(color.red, "Hintergrund SHORT Farbe", group=groupColors)
bgOpacity = input.int(90, "Hintergrund Deckkraft", minval=0, maxval=100, group=groupColors)

groupAlert = "Alert-Funktion"
useAlertFunction = input.bool(true, "alert() Funktionsaufrufe aktivieren", group=groupAlert)
alertOnCloseOnly = input.bool(true, "Nur bei Kerzenschluss alerten", group=groupAlert)

// ==========================
// Effektive Preset-Werte
// ==========================
effTfTrigger =
     isManual ? tfTriggerInput :
     tradingPreset == "MCL / Öl Scalping" ? "30S" :
     tradingPreset == "MGC / Gold Scalping" ? "30S" :
     tradingPreset == "Intraday Swing Index" ? "1" :
     tradingPreset == "Aktien / ETFs Intraday" ? "1" :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? "15" :
     str.contains(tradingPreset, "M1") ? "1" :
     "15S"

effTfConfirm =
     isManual ? tfConfirmInput :
     tradingPreset == "Aktien / ETFs Intraday" ? "5" :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? "60" :
     tradingPreset == "Intraday Swing Index" ? "3" :
     tradingPreset == "MES M1 A+" ? "5" :
     str.contains(tradingPreset, "M1") ? "3" :
     "1"

effUseThirdTF =
     isManual ? useThirdTFInput :
     tradingPreset == "MNQ aggressiv" ? false :
     tradingPreset == "MES aggressiv" ? false :
     tradingPreset == "FDXS / DAX Scalping" ? false :
     tradingPreset == "MCL / Öl Scalping" ? false :
     tradingPreset == "MES M1 aggressiv" ? false :
     tradingPreset == "MNQ M1 aggressiv" ? false :
     true

effTfThird =
     isManual ? tfThirdInput :
     tradingPreset == "Aktien / ETFs Intraday" ? "15" :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? "240" :
     tradingPreset == "Intraday Swing Index" ? "5" :
     tradingPreset == "MES M1 A+" ? "15" :
     str.contains(tradingPreset, "M1") ? "5" :
     "3"

effMinConfirmedTFs = isManual ? minConfirmedTFsInput : effUseThirdTF ? 2 : 1

effAdxTF =
     isManual ? adxTFInput :
     tradingPreset == "MNQ aggressiv" ? "5" :
     tradingPreset == "MES aggressiv" ? "5" :
     tradingPreset == "FDXS / DAX Scalping" ? "5" :
     tradingPreset == "MES M1 aggressiv" ? "5" :
     tradingPreset == "MNQ M1 aggressiv" ? "5" :
     tradingPreset == "Intraday Swing Index" ? "30" :
     tradingPreset == "Aktien / ETFs Intraday" ? "30" :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? "240" :
     "15"

effUseBiasFilter =
     isManual ? useBiasFilterInput :
     tradingPreset == "MNQ Trend-Scalp" ? true :
     tradingPreset == "MES A+ Qualität" ? true :
     tradingPreset == "MGC / Gold Scalping" ? true :
     tradingPreset == "Intraday Swing Index" ? true :
     tradingPreset == "Aktien / ETFs Intraday" ? true :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? true :
     tradingPreset == "MES M1 A+" ? true :
     tradingPreset == "MNQ M1 Standard" ? true :
     false

effBiasTF =
     isManual ? biasTFInput :
     tradingPreset == "MGC / Gold Scalping" ? "5" :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? "1D" :
     "15"

effBiasMode = isManual ? biasModeInput : "EMA + VWAP"
effUseBassFilter = isManual ? useBassFilterInput : true

effBassTF =
     isManual ? bassTFInput :
     tradingPreset == "MNQ aggressiv" ? "5" :
     tradingPreset == "MES aggressiv" ? "3" :
     tradingPreset == "MES Standard" ? "3" :
     tradingPreset == "FDXS / DAX Scalping" ? "5" :
     tradingPreset == "MCL / Öl Scalping" ? "5" :
     tradingPreset == "MGC / Gold Scalping" ? "5" :
     tradingPreset == "MES M1 aggressiv" ? "3" :
     tradingPreset == "MES M1 Standard" ? "5" :
     tradingPreset == "MNQ M1 aggressiv" ? "5" :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? "240" :
     "15"

effBassMode =
     isManual ? bassModeInput :
     tradingPreset == "MES A+ Qualität" ? "Alle 5 müssen passen" :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? "Alle 5 müssen passen" :
     tradingPreset == "MES M1 A+" ? "Alle 5 müssen passen" :
     "Mindestens X von 5"

effBassMinConfirm =
     isManual ? bassMinConfirmInput :
     tradingPreset == "MES A+ Qualität" ? 5 :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? 5 :
     tradingPreset == "MES M1 A+" ? 5 :
     4

effRequireAdxNotFalling =
     isManual ? requireAdxNotFallingInput :
     tradingPreset == "MES A+ Qualität" ? true :
     tradingPreset == "Intraday Swing Index" ? true :
     tradingPreset == "Aktien / ETFs Intraday" ? true :
     tradingPreset == "Aktien / ETFs Daily/Swing" ? true :
     tradingPreset == "MES M1 A+" ? true :
     false

effEmaFastLen = isManual ? emaFastLenInput : 21
effEmaSlowLen = isManual ? emaSlowLenInput : 50

// ==========================
// Theme
// ==========================
tableTextColor = tableTextMode == "Schwarz" ? color.black : tableTextMode == "Weiß" ? color.white : tableTheme == "Dunkler Chart" ? color.black : color.white
tableHeaderBg = tableTheme == "Dunkler Chart" ? color.new(color.white, tableHeaderOpacity) : color.new(color.gray, tableHeaderOpacity)
tableNeutralBg = tableTheme == "Dunkler Chart" ? color.new(color.white, tableNeutralOpacity) : color.new(color.gray, tableNeutralOpacity)

// ==========================
// Funktionen
// ==========================
f_liquidityLine(_src, _len, _mult) =>
    basis = ta.sma(ta.ema(_src, _len), _len)
    deviation = ta.ema(math.abs(close - basis), _len * 3) * _mult
    upper = basis + deviation
    lower = basis - deviation
    var float liqTrend = 0.0
    if close > upper
        liqTrend := 1
    if close < lower
        liqTrend := -1
    liqLine = liqTrend > 0 ? lower : upper
    [liqLine, liqTrend]

f_heatTrail(_atrLen, _mult) =>
    var float trendUp = na
    var float trendDown = na
    var int heatTrend = 1
    atrTrail = ta.ema(ta.tr, _atrLen)
    stopOffset = _mult * atrTrail
    bullStop = high - stopOffset
    bearStop = low + stopOffset
    trendUp := na(trendUp[1]) ? bullStop : close[1] > trendUp[1] ? math.max(bullStop, trendUp[1]) : bullStop
    trendDown := na(trendDown[1]) ? bearStop : close[1] < trendDown[1] ? math.min(bearStop, trendDown[1]) : bearStop
    heatTrend := close > trendDown[1] ? 1 : close < trendUp[1] ? -1 : nz(heatTrend[1], 1)
    trail = heatTrend == 1 ? trendUp : trendDown
    [trail, heatTrend]

f_adx(_len) =>
    upMove = high - high[1]
    downMove = low[1] - low
    plusDM = upMove > downMove and upMove > 0 ? upMove : 0.0
    minusDM = downMove > upMove and downMove > 0 ? downMove : 0.0
    tr1 = high - low
    tr2 = math.abs(high - nz(close[1], close))
    tr3 = math.abs(low - nz(close[1], close))
    trueRange = math.max(tr1, math.max(tr2, tr3))
    smTR = ta.rma(trueRange, _len)
    smPlusDM = ta.rma(plusDM, _len)
    smMinusDM = ta.rma(minusDM, _len)
    plusDI = smTR != 0 ? 100 * smPlusDM / smTR : 0.0
    minusDI = smTR != 0 ? 100 * smMinusDM / smTR : 0.0
    dxBase = plusDI + minusDI
    dx = dxBase != 0 ? 100 * math.abs(plusDI - minusDI) / dxBase : 0.0
    ta.rma(dx, _len)

f_adxOk() =>
    adxVal = f_adx(adxLen)
    adxStrong = adxVal >= adxMin
    adxNotFalling = adxVal >= adxVal[1]
    adxOk = adxStrong and (not effRequireAdxNotFalling or adxNotFalling)
    [adxOk, adxVal]

f_biasOk() =>
    emaFast = ta.ema(close, effEmaFastLen)
    emaSlow = ta.ema(close, effEmaSlowLen)
    isNewSession = timeframe.change("D")
    [vwapValue, _, _] = ta.vwap(hlc3, isNewSession, 1)
    emaLong = emaFast > emaSlow
    emaShort = emaFast < emaSlow
    vwapLong = close > vwapValue
    vwapShort = close < vwapValue
    longBias = effBiasMode == "Nur EMA" ? emaLong : effBiasMode == "Nur VWAP" ? vwapLong : emaLong and vwapLong
    shortBias = effBiasMode == "Nur EMA" ? emaShort : effBiasMode == "Nur VWAP" ? vwapShort : emaShort and vwapShort
    [longBias, shortBias, emaLong, emaShort, vwapLong, vwapShort]

f_smma(_src, _length) =>
    var float smmaVal = na
    smmaVal := na(smmaVal[1]) ? ta.sma(_src, _length) : (smmaVal[1] * (_length - 1) + _src) / _length
    smmaVal

f_bassBias() =>
    fastMa = ta.ema(close, 12)
    slowMa = ta.ema(close, 26)
    macd = fastMa - slowMa
    signal = ta.ema(macd, 9)
    macdHist = ((macd - signal) * 2.0) * macdScale
    rsiRaw = ta.rsi(close, 14)
    rsiHist = ((rsiRaw - 50.0) / 5.0) * rsiScale
    kRaw = ta.stoch(close, high, low, 21)
    k = (ta.sma(kRaw, 14) - 50.0) / 10.0
    d = ta.sma(k, 14)
    stochHist = ((k - d) * 1.5) * stochScale
    ao = ((ta.sma(hl2, 5) - ta.sma(hl2, 34)) * 0.6) * aoScale
    jaw = f_smma(hl2, 13)
    teeth = f_smma(hl2, 8)
    lips = f_smma(hl2, 5)
    gatorHist = ((lips - teeth) + (teeth - jaw)) * gatorScale
    vwmaVal = ta.vwma(hlc3, volumeBiasLen)
    smaVal = ta.sma(hlc3, volumeBiasLen)
    volumeHist = (vwmaVal - smaVal) * volumeScale
    useVolumeInBass = effBassMode == "Mindestens X von 6 inkl. Volumen" or effBassMode == "Alle 6 inkl. Volumen"
    bassTotal = useVolumeInBass ? 6 : 5
    longCount = (macdHist > 0 ? 1 : 0) + (rsiHist > 0 ? 1 : 0) + (stochHist > 0 ? 1 : 0) + (ao > 0 ? 1 : 0) + (gatorHist > 0 ? 1 : 0) + (useVolumeInBass and volumeHist > 0 ? 1 : 0)
    shortCount = (macdHist < 0 ? 1 : 0) + (rsiHist < 0 ? 1 : 0) + (stochHist < 0 ? 1 : 0) + (ao < 0 ? 1 : 0) + (gatorHist < 0 ? 1 : 0) + (useVolumeInBass and volumeHist < 0 ? 1 : 0)
    requiredBass = effBassMode == "Alle 5 müssen passen" ? 5 : effBassMode == "Alle 6 inkl. Volumen" ? 6 : math.min(effBassMinConfirm, bassTotal)
    bassLong = longCount >= requiredBass and longCount > shortCount
    bassShort = shortCount >= requiredBass and shortCount > longCount
    [bassLong, bassShort, longCount, shortCount, bassTotal, requiredBass]

f_vapiBias() =>
    priceRange = high - low
    x = priceRange != 0 ? (2 * close - high - low) / priceRange : 0.0
    tva = ta.sma(volume * x, vapiLenInput) * vapiLenInput
    tv = ta.sma(volume, vapiLenInput) * vapiLenInput
    va = tv != 0 ? 100 * tva / tv : 0.0
    vapiLong = va > 0 and (not vapiRequireSlopeInput or va >= va[1])
    vapiShort = va < 0 and (not vapiRequireSlopeInput or va <= va[1])
    vapiWeakLong = va < va[1]
    vapiWeakShort = va > va[1]
    [vapiLong, vapiShort, vapiWeakLong, vapiWeakShort, va]

f_volumeContext() =>
    volumeMa = ta.sma(volume, volLen)
    highVolume = volume > volumeMa * highVolMult
    volumeMid = ta.vwma(hlc3, volLen)
    normalMid = ta.sma(hlc3, volLen)
    volAtr = ta.atr(volAtrLen)
    var float lastHighVolPrice = na
    lastHighVolPrice := highVolume ? hlc3 : nz(lastHighVolPrice[1], hlc3)
    nearVolumeZone = math.abs(close - lastHighVolPrice) <= volAtr * volNearAtr
    aboveVolumeMid = close > volumeMid
    belowVolumeMid = close < volumeMid
    volumeTrendLong = volumeMid > normalMid
    volumeTrendShort = volumeMid < normalMid
    longVolumeContext = aboveVolumeMid and volumeTrendLong
    shortVolumeContext = belowVolumeMid and volumeTrendShort
    longReclaim = nearVolumeZone and close > lastHighVolPrice
    shortReject = nearVolumeZone and close < lastHighVolPrice
    [longVolumeContext, shortVolumeContext, longReclaim, shortReject, nearVolumeZone, lastHighVolPrice, volumeMid]

f_mtfState() =>
    [liqLine, liqTrend] = f_liquidityLine(liqSrc, liqLen, liqMult)
    [heatTrail, heatTrend] = f_heatTrail(stopATRlen, stopMult)
    liqLong = close > liqLine
    liqShort = close < liqLine
    heatLong = close > heatTrail
    heatShort = close < heatTrail
    tfLong = confirmMode == "Beide müssen gleich sein" ? liqLong and heatLong : liqLong or heatLong
    tfShort = confirmMode == "Beide müssen gleich sein" ? liqShort and heatShort : liqShort or heatShort
    [tfLong, tfShort, liqLong, liqShort, heatLong, heatShort]

// ==========================
// Requests
// ==========================
[t1Long, t1Short, t1LiqLong, t1LiqShort, t1HeatLong, t1HeatShort] = request.security(syminfo.tickerid, effTfTrigger, f_mtfState(), lookahead=barmerge.lookahead_off)
[t2Long, t2Short, t2LiqLong, t2LiqShort, t2HeatLong, t2HeatShort] = request.security(syminfo.tickerid, effTfConfirm, f_mtfState(), lookahead=barmerge.lookahead_off)
[t3Long, t3Short, t3LiqLong, t3LiqShort, t3HeatLong, t3HeatShort] = request.security(syminfo.tickerid, effTfThird, f_mtfState(), lookahead=barmerge.lookahead_off)

[adxOkRaw, adxValue] = request.security(syminfo.tickerid, effAdxTF, f_adxOk(), lookahead=barmerge.lookahead_off)
[biasLongRaw, biasShortRaw, emaLongRaw, emaShortRaw, vwapLongRaw, vwapShortRaw] = request.security(syminfo.tickerid, effBiasTF, f_biasOk(), lookahead=barmerge.lookahead_off)
[bassLongRaw, bassShortRaw, bassLongCount, bassShortCount, bassTotal, bassRequired] = request.security(syminfo.tickerid, effBassTF, f_bassBias(), lookahead=barmerge.lookahead_off)
[vapiLongRaw, vapiShortRaw, vapiWeakLongRaw, vapiWeakShortRaw, vapiValue] = request.security(syminfo.tickerid, vapiTFInput, f_vapiBias(), lookahead=barmerge.lookahead_off)

[vol1Long, vol1Short, vol1ReclaimLong, vol1RejectShort, vol1NearZone, vol1ZonePrice, vol1Mid] = request.security(syminfo.tickerid, volTF1, f_volumeContext(), lookahead=barmerge.lookahead_off)
[vol2Long, vol2Short, vol2ReclaimLong, vol2RejectShort, vol2NearZone, vol2ZonePrice, vol2Mid] = request.security(syminfo.tickerid, volTF2, f_volumeContext(), lookahead=barmerge.lookahead_off)

// ==========================
// Final Logic
// ==========================
adxFilterOk = not useAdxFilter or adxOkRaw
biasLongOk = not effUseBiasFilter or biasLongRaw
biasShortOk = not effUseBiasFilter or biasShortRaw
bassLongOk = not effUseBassFilter or bassLongRaw
bassShortOk = not effUseBassFilter or bassShortRaw

vapiLongOk = not useVapiFilterInput or vapiModeInput == "Nur A+ / Warnung" or vapiLongRaw
vapiShortOk = not useVapiFilterInput or vapiModeInput == "Nur A+ / Warnung" or vapiShortRaw

activeTFs = effUseThirdTF ? 3 : 2
requiredTFs = math.min(effMinConfirmedTFs, activeTFs)

triggerLongOk = triggerConfirmMode == "Liquidity + Heatmap Pflicht" ? (t1LiqLong and t1HeatLong) : (t1LiqLong or t1HeatLong)
triggerShortOk = triggerConfirmMode == "Liquidity + Heatmap Pflicht" ? (t1LiqShort and t1HeatShort) : (t1LiqShort or t1HeatShort)

longTFCount = (triggerLongOk ? 1 : 0) + (t2Long ? 1 : 0) + (effUseThirdTF and t3Long ? 1 : 0)
shortTFCount = (triggerShortOk ? 1 : 0) + (t2Short ? 1 : 0) + (effUseThirdTF and t3Short ? 1 : 0)

entryLongBase = triggerLongOk and longTFCount >= requiredTFs and longTFCount > shortTFCount
entryShortBase = triggerShortOk and shortTFCount >= requiredTFs and shortTFCount > longTFCount

finalLong = entryLongBase and adxFilterOk and biasLongOk and bassLongOk and vapiLongOk
finalShort = entryShortBase and adxFilterOk and biasShortOk and bassShortOk and vapiShortOk

longVolScore = useVolumeContext ? (vol1Long ? 1 : 0) + (vol2Long ? 1 : 0) + (vol1ReclaimLong ? 1 : 0) + (vol2ReclaimLong ? 1 : 0) : 0
shortVolScore = useVolumeContext ? (vol1Short ? 1 : 0) + (vol2Short ? 1 : 0) + (vol1RejectShort ? 1 : 0) + (vol2RejectShort ? 1 : 0) : 0

longVolWarn = useVolumeContext and finalLong and vol1Short and vol2Short
shortVolWarn = useVolumeContext and finalShort and vol1Long and vol2Long

longVapiWarn = useVapiFilterInput and finalLong and vapiWeakLongRaw
shortVapiWarn = useVapiFilterInput and finalShort and vapiWeakShortRaw

longWarn = finalLong and (longVolWarn or longVapiWarn)
shortWarn = finalShort and (shortVolWarn or shortVapiWarn)

longAPlus = finalLong and useVolumeContext and longVolScore >= volAPlusScore and not longWarn and (not useVapiFilterInput or vapiLongRaw)
shortAPlus = finalShort and useVolumeContext and shortVolScore >= volAPlusScore and not shortWarn and (not useVapiFilterInput or vapiShortRaw)

longOk = finalLong and not longAPlus and not longWarn
shortOk = finalShort and not shortAPlus and not shortWarn

longQualityText = longAPlus ? "A+" : longWarn ? "WARN" : longVolScore >= volOkScore ? "OK" : "BASIC"
shortQualityText = shortAPlus ? "A+" : shortWarn ? "WARN" : shortVolScore >= volOkScore ? "OK" : "BASIC"

// ==========================
// Trade State / Exits
// ==========================
var int tradeDir = 0

newLong = finalLong and tradeDir != 1
newShort = finalShort and tradeDir != -1

longAlignmentLost = tradeDir == 1 and longTFCount < requiredTFs
shortAlignmentLost = tradeDir == -1 and shortTFCount < requiredTFs

oppositeShort = tradeDir == 1 and entryShortBase
oppositeLong = tradeDir == -1 and entryLongBase

exitLong = useSmartExit and tradeDir == 1 and (
     exitMode == "Gegensignal" ? oppositeShort :
     exitMode == "Alignment-Verlust" ? longAlignmentLost :
     oppositeShort or longAlignmentLost)

exitShort = useSmartExit and tradeDir == -1 and (
     exitMode == "Gegensignal" ? oppositeLong :
     exitMode == "Alignment-Verlust" ? shortAlignmentLost :
     oppositeLong or shortAlignmentLost)

if newLong
    tradeDir := 1
else if newShort
    tradeDir := -1
else if exitLong or exitShort
    tradeDir := 0

// ==========================
// Plots
// ==========================
plotshape(newLong and longAPlus, title="PCM LONG A+", style=shape.labelup, location=location.belowbar, text="LONG A+", color=color.new(longSignalColor, signalOpacity), textcolor=signalTextColor, size=size.small)
plotshape(newLong and longOk, title="PCM LONG OK", style=shape.labelup, location=location.belowbar, text="LONG", color=color.new(longSignalColor, signalOpacity), textcolor=signalTextColor, size=size.small)
plotshape(newLong and longWarn, title="PCM LONG WARN", style=shape.labelup, location=location.belowbar, text="LONG ⚠", color=color.new(color.orange, signalOpacity), textcolor=signalTextColor, size=size.small)

plotshape(newShort and shortAPlus, title="PCM SHORT A+", style=shape.labeldown, location=location.abovebar, text="SHORT A+", color=color.new(shortSignalColor, signalOpacity), textcolor=signalTextColor, size=size.small)
plotshape(newShort and shortOk, title="PCM SHORT OK", style=shape.labeldown, location=location.abovebar, text="SHORT", color=color.new(shortSignalColor, signalOpacity), textcolor=signalTextColor, size=size.small)
plotshape(newShort and shortWarn, title="PCM SHORT WARN", style=shape.labeldown, location=location.abovebar, text="SHORT ⚠", color=color.new(color.orange, signalOpacity), textcolor=signalTextColor, size=size.small)

plotshape(exitLong, title="PCM EXIT LONG", style=shape.xcross, location=location.abovebar, text="EXIT L", color=color.new(exitSignalColor, signalOpacity), textcolor=signalTextColor, size=size.tiny)
plotshape(exitShort, title="PCM EXIT SHORT", style=shape.xcross, location=location.belowbar, text="EXIT S", color=color.new(exitSignalColor, signalOpacity), textcolor=signalTextColor, size=size.tiny)

bgcolor(showBackground and tradeDir == 1 ? color.new(bgLongColor, bgOpacity) : showBackground and tradeDir == -1 ? color.new(bgShortColor, bgOpacity) : na)

// ==========================
// Alerts
// ==========================
longMsg  = "PCM Signal - 🟢 LONG " + longQualityText + " " + syminfo.ticker + " | Preset: " + tradingPreset + " | VolScore: " + str.tostring(longVolScore) + "/4 | VAPI: " + str.tostring(vapiValue, "#.##")
shortMsg = "PCM Signal - 🔴 SHORT " + shortQualityText + " " + syminfo.ticker + " | Preset: " + tradingPreset + " | VolScore: " + str.tostring(shortVolScore) + "/4 | VAPI: " + str.tostring(vapiValue, "#.##")
exitMsg  = "PCM Signal - ❌ Exit " + syminfo.ticker + " | Preset: " + tradingPreset

alertcondition(newLong, title="PCM LONG", message="PCM Signal - 🟢 LONG {{ticker}}")
alertcondition(newShort, title="PCM SHORT", message="PCM Signal - 🔴 SHORT {{ticker}}")
alertcondition(exitLong or exitShort, title="PCM EXIT", message="PCM Signal - ❌ Exit {{ticker}}")

alertFreq = alertOnCloseOnly ? alert.freq_once_per_bar_close : alert.freq_once_per_bar

if useAlertFunction
    if newLong
        alert(longMsg, alertFreq)
    if newShort
        alert(shortMsg, alertFreq)
    if exitLong or exitShort
        alert(exitMsg, alertFreq)

// ==========================
// Table
// ==========================
f_stateText(_long, _short) =>
    _long ? "LONG" : _short ? "SHORT" : "NEUTRAL"

f_stateColor(_long, _short) =>
    _long ? color.new(longSignalColor, tableCellOpacity) : _short ? color.new(shortSignalColor, tableCellOpacity) : tableNeutralBg

f_qualityColor(_isLong, _isShort, _warn) =>
    _warn ? color.new(color.orange, tableCellOpacity) : _isLong ? color.new(longSignalColor, tableCellOpacity) : _isShort ? color.new(shortSignalColor, tableCellOpacity) : tableNeutralBg

var table statusTable = table.new(tablePosition, 5, 11, border_width=1)

if barstate.islast and showTable
    table.cell(statusTable, 0, 0, "Preset", text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 1, 0, tradingPreset, text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 2, 0, "TFs", text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 3, 0, effTfTrigger + "/" + effTfConfirm + "/" + (effUseThirdTF ? effTfThird : "-"), text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 4, 0, "Min " + str.tostring(requiredTFs) + "/" + str.tostring(activeTFs), text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)

    table.cell(statusTable, 0, 1, "TF", text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 1, 1, "Liquidity", text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 2, 1, "Heatmap", text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 3, 1, "TF OK", text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)
    table.cell(statusTable, 4, 1, "Final", text_color=tableTextColor, bgcolor=tableHeaderBg, text_size=tableTextSize)

    table.cell(statusTable, 0, 2, effTfTrigger, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 2, f_stateText(t1LiqLong, t1LiqShort), text_color=tableTextColor, bgcolor=f_stateColor(t1LiqLong, t1LiqShort), text_size=tableTextSize)
    table.cell(statusTable, 2, 2, f_stateText(t1HeatLong, t1HeatShort), text_color=tableTextColor, bgcolor=f_stateColor(t1HeatLong, t1HeatShort), text_size=tableTextSize)
    table.cell(statusTable, 3, 2, f_stateText(t1Long, t1Short), text_color=tableTextColor, bgcolor=f_stateColor(t1Long, t1Short), text_size=tableTextSize)
    table.cell(statusTable, 4, 2, finalLong ? "LONG " + longQualityText : finalShort ? "SHORT " + shortQualityText : "WAIT", text_color=tableTextColor, bgcolor=finalLong ? color.new(longSignalColor, tableCellOpacity) : finalShort ? color.new(shortSignalColor, tableCellOpacity) : tableNeutralBg, text_size=tableTextSize)

    table.cell(statusTable, 0, 3, effTfConfirm, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 3, f_stateText(t2LiqLong, t2LiqShort), text_color=tableTextColor, bgcolor=f_stateColor(t2LiqLong, t2LiqShort), text_size=tableTextSize)
    table.cell(statusTable, 2, 3, f_stateText(t2HeatLong, t2HeatShort), text_color=tableTextColor, bgcolor=f_stateColor(t2HeatLong, t2HeatShort), text_size=tableTextSize)
    table.cell(statusTable, 3, 3, f_stateText(t2Long, t2Short), text_color=tableTextColor, bgcolor=f_stateColor(t2Long, t2Short), text_size=tableTextSize)
    table.cell(statusTable, 4, 3, str.tostring(longTFCount) + "L / " + str.tostring(shortTFCount) + "S", text_color=tableTextColor, text_size=tableTextSize)

    table.cell(statusTable, 0, 4, effUseThirdTF ? effTfThird : "3. TF aus", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 4, effUseThirdTF ? f_stateText(t3LiqLong, t3LiqShort) : "-", text_color=tableTextColor, bgcolor=effUseThirdTF ? f_stateColor(t3LiqLong, t3LiqShort) : tableNeutralBg, text_size=tableTextSize)
    table.cell(statusTable, 2, 4, effUseThirdTF ? f_stateText(t3HeatLong, t3HeatShort) : "-", text_color=tableTextColor, bgcolor=effUseThirdTF ? f_stateColor(t3HeatLong, t3HeatShort) : tableNeutralBg, text_size=tableTextSize)
    table.cell(statusTable, 3, 4, effUseThirdTF ? f_stateText(t3Long, t3Short) : "-", text_color=tableTextColor, bgcolor=effUseThirdTF ? f_stateColor(t3Long, t3Short) : tableNeutralBg, text_size=tableTextSize)
    table.cell(statusTable, 4, 4, "Min TF: " + str.tostring(requiredTFs), text_color=tableTextColor, text_size=tableTextSize)

    table.cell(statusTable, 0, 5, "ADX " + effAdxTF, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 5, str.tostring(adxValue, "#.##"), text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 2, 5, useAdxFilter ? "AKTIV" : "AUS", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 3, 5, adxFilterOk ? "OK" : "BLOCK", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 4, 5, effRequireAdxNotFalling ? "Nicht fallend" : "Fallen erlaubt", text_color=tableTextColor, bgcolor=adxFilterOk ? color.new(longSignalColor, tableCellOpacity) : color.new(shortSignalColor, tableCellOpacity), text_size=tableTextSize)

    table.cell(statusTable, 0, 6, "BIAS " + effBiasTF, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 6, effUseBiasFilter ? "AKTIV" : "AUS", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 2, 6, "EMA: " + (emaLongRaw ? "L" : emaShortRaw ? "S" : "-"), text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 3, 6, "VWAP: " + (vwapLongRaw ? "L" : vwapShortRaw ? "S" : "-"), text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 4, 6, effBiasMode, text_color=tableTextColor, text_size=tableTextSize)

    table.cell(statusTable, 0, 7, "BASS " + effBassTF, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 7, effUseBassFilter ? "AKTIV" : "AUS", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 2, 7, str.tostring(bassLongCount) + "L / " + str.tostring(bassShortCount) + "S", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 3, 7, "Min: " + str.tostring(bassRequired) + "/" + str.tostring(bassTotal), text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 4, 7, bassLongRaw ? "LONG" : bassShortRaw ? "SHORT" : "NEUTRAL", text_color=tableTextColor, bgcolor=f_stateColor(bassLongRaw, bassShortRaw), text_size=tableTextSize)

    table.cell(statusTable, 0, 8, "VAPI " + vapiTFInput, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 8, useVapiFilterInput ? "AKTIV" : "AUS", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 2, 8, str.tostring(vapiValue, "#.##"), text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 3, 8, vapiLongRaw ? "LONG" : vapiShortRaw ? "SHORT" : "NEUTRAL", text_color=tableTextColor, bgcolor=f_stateColor(vapiLongRaw, vapiShortRaw), text_size=tableTextSize)
    table.cell(statusTable, 4, 8, vapiModeInput, text_color=tableTextColor, bgcolor=longVapiWarn or shortVapiWarn ? color.new(color.orange, tableCellOpacity) : tableNeutralBg, text_size=tableTextSize)

    table.cell(statusTable, 0, 9, "VOL " + volTF1, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 9, f_stateText(vol1Long, vol1Short), text_color=tableTextColor, bgcolor=f_stateColor(vol1Long, vol1Short), text_size=tableTextSize)
    table.cell(statusTable, 2, 9, vol1NearZone ? "ZONE" : "-", text_color=tableTextColor, bgcolor=vol1NearZone ? color.new(color.orange, tableCellOpacity) : tableNeutralBg, text_size=tableTextSize)
    table.cell(statusTable, 3, 9, vol1ReclaimLong ? "RECLAIM" : vol1RejectShort ? "REJECT" : "-", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 4, 9, "Mid: " + str.tostring(vol1Mid, format.mintick), text_color=tableTextColor, text_size=tableTextSize)

    table.cell(statusTable, 0, 10, "VOL " + volTF2, text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 1, 10, f_stateText(vol2Long, vol2Short), text_color=tableTextColor, bgcolor=f_stateColor(vol2Long, vol2Short), text_size=tableTextSize)
    table.cell(statusTable, 2, 10, vol2NearZone ? "ZONE" : "-", text_color=tableTextColor, bgcolor=vol2NearZone ? color.new(color.orange, tableCellOpacity) : tableNeutralBg, text_size=tableTextSize)
    table.cell(statusTable, 3, 10, "Score L/S", text_color=tableTextColor, text_size=tableTextSize)
    table.cell(statusTable, 4, 10, str.tostring(longVolScore) + " / " + str.tostring(shortVolScore), text_color=tableTextColor, bgcolor=f_qualityColor(finalLong, finalShort, longWarn or shortWarn), text_size=tableTextSize)
````
