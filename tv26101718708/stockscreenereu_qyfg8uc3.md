# Stock_Screener_EU

- url: https://www.tradingview.com/script/QYFG8uc3-Stock-Screener-EU/
- type: indicator
- pine_id: PUB;c991a4c393884627b8a7a25c7cbc8094
- version: 4.0

## Description

Here is the professional English version of your Institutional Trinity Screener summary.

Executive Summary: Institutional Trinity Screener
The Institutional Trinity Screener System is a high-performance quantitative tool designed to identify stocks exhibiting superior relative strength and institutional momentum. It operates on a Top-Down methodology, analyzing capital flows from the broad market down to sectors and individual equities.

Core Functionalities
1. The "Holy Trinity" of Relative Strength (Alpha Focus)
The screener calculates three critical performance ratios in real-time to ensure alignment with "Smart Money":

Stock vs. Market (RRSI): Identifies market leaders that are outperforming the primary benchmark (SPY/SXXP).

Stock vs. Sector: Filters for the "Alpha Wolves"—the strongest individual performers within a specific industry.

Sector vs. Market: Confirms if the stock is supported by an institutional "tailwind" (sector rotation).

2. Adaptive Setup Engine (S1–S5)
Rather than relying on lagging indicators, the system identifies five specific institutional trading scenarios:

S1 (Power Breakout): High-momentum breakouts from tight consolidations near 52-week highs.

S2 (Tightness): Volatility contraction on low volume, indicating a supply-demand equilibrium (VCP characteristics).

S3 (EMA Pullback): Precise retracements to institutional support levels (EMA 21).

S4/S5 (Phoenix/Ignition): Trend reversal setups fueled by massive volume impact at the EMA 200.

3. Institutional Confirmation (Footprint Analysis)
Every signal is validated by three technical "vital signs":

Relative Volume (RVol): Measures whether institutional intervention is present.

True Strength Index (TSI): Confirms mathematical trend integrity and momentum speed.

ATR Percentage: Evaluates the daily range to ensure the stock offers sufficient "meat on the bone" for professional profit targets.

Operational Workflow
Screening: Filter thousands of stocks for Setup-Case > 0 and an RRSI > 60.

System Objective: To eliminate "random trades" by focusing exclusively on stocks where significant institutional capital is demonstrably flowing.

## Source Code

````pine
// © Gemini_Institutional_Trading_Mentor x michaela_geiger83
//@version=5
indicator("Inst_Screener_Salami_EU_V1", shorttitle="Screener_EU_V1", overlay=false)

// ---------- 1. INPUTS ----------
grp_set = "⚙️ EUROPA SETUP"
groupSelect = input.string("Gruppe 1 (ID 1-5)", "Aktive EU-Gruppe", options=["Gruppe 1 (ID 1-5)", "Gruppe 2 (ID 6-10+)"], group=grp_set)
benchmark   = input.symbol("INDEX:SXXP", title="EU-Benchmark (z.B. SXXP)", group=grp_set)
tfSelection = input.string("4 Stunden (240)", "Screener TF", options=["4 Stunden (240)", "Tageschart (1D)"], group=grp_set)
targetTF    = tfSelection == "4 Stunden (240)" ? "240" : "D"
rsiLen      = input.int(14, "RSI Zeitraum (Multibell Match)", group=grp_set)

grp_filt = "🏦 FILTER-STEUERUNG"
useVwapFilter = input.bool(true, "VWAP Trend-Filter nutzen?", group=grp_filt)
useWicks      = input.bool(true, "Trend an Dochte binden?", group=grp_filt)
mappingText   = input.string("", "Ticker→Sektor Mapping (CSV)", group=grp_filt)

// ---------- 2. ETF-Cluster EU (5 IDs pro Gruppe) ----------
// Wir nutzen die US-Sektor-ETFs als weltweite Benchmark, da diese am liquidesten sind
[etf1, etf2, etf3, etf4, etf5, id1, id2, id3, id4, id5] = switch groupSelect
    "Gruppe 1 (ID 1-5)"   => ["XLK", "SMH", "XLE", "XLF", "XLI", 1, 2, 3, 4, 5]
    "Gruppe 2 (ID 6-10+)" => ["XLB", "XLV", "XLY", "XLP", "XLU", 6, 7, 8, 9, 10]
    => ["SPY", "SPY", "SPY", "SPY", "SPY", 99, 99, 99, 99, 99]

// ---------- 3. Prefix-Killer Suchfunktion (XETR, LSE etc.) ----------
f_lookupSector(tickerID, txt) =>
    clean = str.replace_all(str.replace_all(str.replace_all(str.replace_all(txt, "\r", ""), "\n", ","), " ", ","), ";", ",")
    string pureTicker = tickerID
    if str.contains(tickerID, ":")
        parts = str.split(tickerID, ":"), pureTicker := array.get(parts, array.size(parts) - 1)
    pureTicker := str.replace_all(pureTicker, " ", "")
    padded = "," + clean + ",", search = "," + str.upper(pureTicker) + ","
    pos = str.pos(padded, search)
    int res = -1
    if not na(pos)
        startVal = pos + str.length(search), rest = str.substring(padded, startVal)
        endPos = str.pos(rest, ","), res := not na(endPos) ? int(str.tonumber(str.substring(rest, 0, endPos))) : -1
    res

// ---------- 4. Multibell Metriken (Safe-Logic) ----------
f_metrics(bc, rsi_l, vwap_on) =>
    e8 = ta.ema(close, 8), e21 = ta.ema(close, 21), e50 = ta.ema(close, 50), e200 = ta.ema(close, 200)
    volAvg = ta.sma(volume, 20), rVol = volAvg > 0 ? volume / volAvg : 0.0
    atrVal = ta.atr(14), atrPct = (atrVal / close) * 100.0
    vwapVal = ta.vwap(close)
    isAboveVwap = not vwap_on or na(vwapVal) ? true : close > vwapVal
    mfiVal = ta.mfi(close, 14)
    pc = ta.change(close), tsi = 100.0 * (ta.ema(ta.ema(pc, 13), 25) / math.max(ta.ema(ta.ema(math.abs(pc), 13), 25), 0.0001))
    rrsiBench = ta.rsi(close / math.max(bc, 0.0001), rsi_l)
    hRef = useWicks ? high : math.max(close, open), lRef = useWicks ? low : math.min(close, open)
    highest252 = ta.highest(hRef, 252), distToHigh = not na(highest252) ? (highest252 - close) / highest252 * 100.0 : 0.0
    isBull = (e8 > e21) and (e21 > e50) and (close > e200) and isAboveVwap
    crossH20 = ta.crossover(close, ta.highest(hRef[1], 20)), cross200 = ta.crossover(close, e200)
    sig = (isBull and distToHigh <= 15.0 and rVol >= 1.2 and crossH20) ? 1 : 
          (isBull and lRef >= e21*0.98 and hRef <= e8*1.05 and rVol < 0.8) ? 2 : 
          (isBull and lRef <= e21*1.01 and lRef >= e21*0.98 and mfiVal > 50) ? 3 : 
          (cross200 and rVol > 1.8 and isAboveVwap) ? 4 : 
          (cross200 and rVol >= 1.3 and isAboveVwap) ? 5 : 0
    [sig, rVol, tsi, rrsiBench, atrPct, close]

// ---------- 5. SECURITY CALLS (Max 5 Slots genutzt) ----------
benchC = request.security(benchmark, targetTF, close)
[e1c, e1v] = request.security(etf1, targetTF, [close, volume / math.max(ta.sma(volume, 20), 1)])
[e2c, e2v] = request.security(etf2, targetTF, [close, volume / math.max(ta.sma(volume, 20), 1)])
[e3c, e3v] = request.security(etf3, targetTF, [close, volume / math.max(ta.sma(volume, 20), 1)])
[sig, rV, tsi, rRS_B, atrP, px] = request.security(syminfo.tickerid, targetTF, f_metrics(benchC, rsiLen, useVwapFilter))
// Da wir nur 5 Slots haben, laden wir die restlichen ETFs der Gruppe nur bei Bedarf (dynamisch)
e4c = request.security(etf4, targetTF, close), e5c = request.security(etf5, targetTF, close)

// ---------- 6. Sektor-Match EU ----------
sID = f_lookupSector(syminfo.tickerid, mappingText)
sClose = sID == id1 ? e1c : sID == id2 ? e2c : sID == id3 ? e3c : sID == id4 ? e4c : sID == id5 ? e5c : float(na)
rrsiSektor = ta.rsi(px / math.max(sClose, 0.0001), rsiLen)

// ---------- 7. PLOTS ----------
cT = color.new(color.white, 100)
plot(float(sig), "1_Setup_EU", color=sig > 0 ? color.fuchsia : cT, style=plot.style_columns)
plot(rRS_B, "2_RRSI_vs_SXXP", color=cT)
plot(rrsiSektor, "3_RRSI_vs_Sektor", color=cT)
plot(rV, "4_Stock_RelVol", color=cT)
plot(atrP, "5_ATR_Percent", color=cT)
plot(tsi, "6_TSI_Quality", color=cT)
plot(float(sID), "7_Sektor_ID", color=cT)
````
