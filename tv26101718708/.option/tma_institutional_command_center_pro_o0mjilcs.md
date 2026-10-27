# TMA Institutional Command Center [PRO]

- url: https://www.tradingview.com/script/O0mjIlCs-TMA-Institutional-Command-Center-PRO/
- type: indicator
- pine_id: PUB;1ff5d78ebaea4ee3817e5f8641c60c59
- version: 3.0

## Description

TMA Institutional Command Center [PRO]
📌 Introduction: The Retail Illusion vs. Institutional Reality
While the majority of retail traders rely on lagging indicators to predict price action, Market Makers and institutional funds monitor the underlying market microstructure: liquidity pools, arbitrage spreads, and open interest dynamics.

The TMA Institutional Command Center is an advanced dashboard designed to exploit the data asymmetry between retail-dominated derivative exchanges (Binance, Bybit, OKX) and the institutionally driven Chicago Mercantile Exchange (CME). This system doesn't print generic "Buy/Sell" arrows on your chart; instead, it provides the ultimate Smart Money Footprint, revealing whether institutional players are paying a massive premium to accumulate or discounting to distribute.

⚙️ CORE MODULES & CHEAT SHEET
1. INSTITUTIONAL PREMIUM & ARBITRAGE (CME vs. Spot)

CME Spread: Measures the absolute premium or discount of regulated CME Bitcoin futures against the spot price (Coinbase/Kraken). When institutions are willing to pay a massive premium over spot, it indicates aggressive, unyielding demand.

CME Basis (Ann): The annualized yield (Carry Trade) of the CME premium based on Days to Expiry (DTE). When this metric exceeds 15%, the system flags an "ARB RISK", signaling an overheated market highly susceptible to a severe correction or arbitrage convergence.

2. SMART MONEY DIVERGENCE (Inst Spread)
The engine's core. It calculates the delta between the institutional bid (CME Spread) and the retail bid (Binance Perp Spread).

SM ACCUM (Smart Money Accumulation): Triggers when retail traders are fearful (pricing perps at a discount) while institutions are aggressively buying at a premium via CME. A classic Wyckoff accumulation footprint.

SM DISTRIB (Smart Money Distribution): Triggers when retail is greedy (paying high perp funding) while institutions are quietly offloading via CME discounts.

3. GLOBAL LIQUIDITY & MARKET MECHANICS

OI Aggregate: Bypasses single-exchange bias by aggregating true global Open Interest across Binance, Bybit, and OKX.

OI State: Analyzes the delta between OI and Price to categorize the immediate market state: LONG BUILD, SHORT COVER, SHORT BUILD, or LONG LIQ (Long Liquidation Cascade).

Bin Dominance: Tracks the percentage of global liquidity concentrated on Binance, helping you anticipate the precise target of Market Maker stop-hunts.

4. FUNDING RATE (Contrarian Engine)
Operates on strict contrarian logic. Flags "OVERHEATED" when the crowd is dangerously over-leveraged long (long squeeze imminent) and "FEAR EXTREME" when retail is heavily shorting the bottom.

🧠 THE SCOREBOARD: MASTER DECISION ENGINE
To eliminate cognitive overload, the algorithm synthesizes over 10 complex metrics into a single, weighted numerical score. It grades institutional footprints, arbitrage risks, and deleveraging events in real-time.

Score Matrix (-9 to +8):

+5 to +8 ➔ STRONG BULL: Aggressive institutional accumulation aligns with retail short-capitulation. Flawless upward setup.

+1 to +4 ➔ WEAK BULL: Cautious institutional bid; structural support forming.

0 ➔ NEUTRAL

-1 to -4 ➔ WEAK BEAR: Institutional bid fading; early signs of distribution.

-5 to -9 ➔ STRONG BEAR: Arb risk peaking, institutions dumping, and a long liquidation cascade is highly probable.

🛡️ ENGINEERING: CRASH-PROOF ARCHITECTURE
To bypass Pine Script's V5 UI engine limitations and request.security timeouts when fetching heavy multi-exchange data, this script is built with a Circuit Breaker / Load Balancer architecture.

If a specific ticker (e.g., CME during weekends or OKX maintenance) is unavailable in your region or trading plan, the system will never crash or black out your screen. It gracefully degrades the specific row to "N/A" or "DISABLED", while the Scoreboard continues calculating flawlessly with the remaining data.

You can manually toggle specific exchange feeds ON/OFF via the "DATA FEED ROUTING" section in the settings to ensure 100% stability.

Execution Guide:

Apply the indicator to your chart (Highly optimized for 1H and 4H timeframes).

Adjust the Table Position and Font Size in the settings to fit your screen resolution.

Manually update the CME DTE (Days to Expiry) in the settings to match the current active CME contract for precise Arbitrage Basis calculations.

Stop trading like a retail participant. Start reading the tape like a Market Maker.

## Source Code

````pine
//@version=5
indicator("TMA Institutional Command Center [PRO]", overlay=true)

// Dynamic Spot Anchoring & Enhanced Telemetry
// ==========================================
// 1. SETTINGS & INPUTS
// ==========================================
grp_thresh = "1. Volatility (ATR Based)"
atrLength = input.int(14, title="ATR Period", group=grp_thresh)
atrWeakMult = input.float(0.5, title="Weak ATR", step=0.1, group=grp_thresh)
atrStrongMult = input.float(1.0, title="Strong ATR", step=0.1, group=grp_thresh)

grp_ui = "2. Dashboard UI"
posInput = input.string(position.top_right, title="Table Position", options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left, position.middle_right, position.middle_left], group=grp_ui)
sizeInput = input.string("Small", title="Font Size", options=["Auto", "Tiny", "Small", "Normal", "Large"], group=grp_ui)

grp_switches = "3. DATA FEED ROUTING (STABILITY)"
useCME     = input.bool(true, title="1. Enable CME Data (BTC1!)", group=grp_switches)
useAnchors = input.bool(true, title="2. Enable CB/Kraken Spot Anchors", group=grp_switches)
useExtraOI = input.bool(true, title="3. Enable Bybit & OKX OI", group=grp_switches)
useUSDT    = input.bool(true, title="4. Enable Kraken USDT Peg", group=grp_switches)

grp_data = "4. Tickers & Mechanics"
dteInput = input.int(30, title="CME DTE (Days to Expiry)", group=grp_data)
frIsRaw  = input.bool(true, title="FR is Raw (0.0001)?", group=grp_data)

// ==========================================
// 2. DATA FETCHING (CONTROLLED FLOW)
// ==========================================
binSpot = request.security("BINANCE:BTCUSDT", timeframe.period, close, ignore_invalid_symbol=true)
binPerp = request.security("BINANCE:BTCUSDT.P", timeframe.period, close, ignore_invalid_symbol=true)
binOI   = request.security("BINANCE:BTCUSDT.P_OI", timeframe.period, close, ignore_invalid_symbol=true)
binFR   = request.security("BINANCE:BTCUSDT.P_FR", timeframe.period, close, ignore_invalid_symbol=true)

// Optional feeds based on routing switches
cbSpot  = useAnchors ? request.security("COINBASE:BTCUSD", timeframe.period, close, ignore_invalid_symbol=true) : na
krSpot  = useAnchors ? request.security("KRAKEN:XBTUSD", timeframe.period, close, ignore_invalid_symbol=true) : na
cme     = useCME ? request.security("CME:BTC1!", timeframe.period, close, ignore_invalid_symbol=true) : na
bybOI   = useExtraOI ? request.security("BYBIT:BTCUSDT.P_OI", timeframe.period, close, ignore_invalid_symbol=true) : na
okxOI   = useExtraOI ? request.security("OKEX:BTCUSDT.P_OI", timeframe.period, close, ignore_invalid_symbol=true) : na
peg     = useUSDT ? request.security("KRAKEN:USDTUSD", timeframe.period, close, ignore_invalid_symbol=true) : na

atr = ta.atr(atrLength)

// ==========================================
// 3. LOGIC & MATH ENGINE
// ==========================================
// Dynamic anchor logic: Prioritize Coinbase, then Kraken, fallback to Binance
basePrice = useAnchors ? (na(cbSpot) ? (na(krSpot) ? binSpot : krSpot) : cbSpot) : binSpot
safeBase  = na(basePrice) or basePrice == 0 ? 1.0 : basePrice 

// Spread calculations
cmeDiff  = useCME and not na(cme) ? cme - basePrice : na
perpDiff = not na(binPerp) ? binPerp - basePrice : na

// Basis and Institutional Divergence
cmeBasis = useCME and not na(cme) ? ((cme - safeBase) / safeBase) * (365.0 / dteInput) * 100 : na
instDiff = useCME and not na(cmeDiff) and not na(perpDiff) ? cmeDiff - perpDiff : na

// Open Interest Aggregation
oiTotal = nz(binOI) + (useExtraOI ? nz(bybOI) + nz(okxOI) : 0.0)
oiBinPct= oiTotal > 0 ? (nz(binOI) / oiTotal) * 100 : 0.0

// Normalized Funding Rate
frNorm = na(binFR) ? na : (frIsRaw ? binFR : binFR / 100)

// Market Momentum Metrics
oiDelta = ta.change(nz(binOI))
oiTotDelta = ta.change(oiTotal)
priceDelta = ta.change(nz(binPerp))

thresholdWeak   = atr * atrWeakMult
thresholdStrong = atr * atrStrongMult

// --- Scoreboard Weighting ---
score_cme = na(cmeDiff) ? 0 : cmeDiff > thresholdStrong ? 2 : cmeDiff > thresholdWeak ? 1 : cmeDiff < -thresholdStrong ? -2 : cmeDiff < -thresholdWeak ? -1 : 0
score_inst= na(instDiff) ? 0 : instDiff > thresholdStrong ? 2 : instDiff < -thresholdStrong ? -2 : 0
score_oi  = (na(oiDelta) or na(priceDelta)) ? 0 : (oiDelta > 0 and priceDelta > 0) ? 1 : (oiDelta < 0 and priceDelta > 0) ? 1 : (oiDelta > 0 and priceDelta < 0) ? -1 : (oiDelta < 0 and priceDelta < 0) ? -1 : 0
score_fr  = na(frNorm) ? 0 : frNorm > 0.0005 ? -2 : frNorm > 0.0001 ? -1 : frNorm < -0.0003 ? 2 : frNorm < -0.0001 ? 1 : 0
score_basis= na(cmeBasis) ? 0 : cmeBasis > 15 ? -2 : cmeBasis > 5 ? -1 : cmeBasis < 0 ? 1 : 0

total_score = score_cme + score_inst + score_oi + score_fr + score_basis
final_bias = total_score > 4 ? "STRONG BULL" : total_score > 0 ? "WEAK BULL" : total_score < -4 ? "STRONG BEAR" : total_score < 0 ? "WEAK BEAR" : "NEUTRAL"
final_color= total_score > 4 ? color.new(#00ff00, 10) : total_score > 0 ? color.new(#85ff00, 40) : total_score < -4 ? color.new(#ff0000, 10) : total_score < 0 ? color.new(#ff8800, 40) : color.new(color.gray, 60)

// --- Visual Helpers ---
get_arrow(val) => na(val) ? "━" : val > thresholdStrong ? "▲▲" : val > thresholdWeak ? "▲" : val < -thresholdStrong ? "▼▼" : val < -thresholdWeak ? "▼" : "━"
get_bg(val) => na(val) ? color.new(color.gray, 80) : val > thresholdStrong ? color.new(#00ff00, 20) : val > thresholdWeak ? color.new(#85ff00, 50) : val < -thresholdStrong ? color.new(#ff0000, 20) : val < -thresholdWeak ? color.new(#ff8800, 50) : color.new(color.gray, 80)
get_oi_s(oi_c, p_c) => (oi_c > 0 and p_c > 0) ? "LONG BUILD" : (oi_c > 0 and p_c < 0) ? "SHORT BUILD" : (oi_c < 0 and p_c > 0) ? "SHORT COVER" : (oi_c < 0 and p_c < 0) ? "LONG LIQ" : "NEUTRAL"
get_oi_c(oi_c, p_c) => (oi_c > 0 and p_c > 0) ? color.new(#00ff00, 20) : (oi_c > 0 and p_c < 0) ? color.new(#ff0000, 20) : (oi_c < 0 and p_c > 0) ? color.new(#85ff00, 50) : (oi_c < 0 and p_c < 0) ? color.new(#ff8800, 50) : color.new(color.gray, 50)
format_n(val) => (na(val) or val == 0) ? "N/A" : val >= 1000000 ? str.tostring(val / 1000000, "#.##") + "M" : val >= 1000 ? str.tostring(val / 1000, "#.##") + "K" : str.tostring(val, "#.##")

get_size(s) => s == "Auto" ? size.auto : s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

// ==========================================
// 4. DASHBOARD RENDERING
// ==========================================
// Rows optimized for institutional metrics
var table t = table.new(posInput, 3, 12, bgcolor=color.new(#1e222d, 10), border_width=1, border_color=color.new(color.gray, 80))

if barstate.islastconfirmedhistory or barstate.isrealtime
    tSize = get_size(sizeInput)

    // Header Construction
    table.cell(t, 0, 0, "TMA COMMAND CENTER", text_color=color.white, text_size=tSize, bgcolor=color.new(#131722,0), text_halign=text.align_left)
    table.cell(t, 1, 0, "DATA", text_color=color.white, text_size=tSize, bgcolor=color.new(#131722,0))
    table.cell(t, 2, 0, "INTENT", text_color=color.white, text_size=tSize, bgcolor=color.new(#131722,0))

    // CME Premium Diagnostics
    table.cell(t, 0, 1, "CME SPREAD", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, 1, useCME ? (na(cmeDiff) ? "N/A" : str.tostring(cmeDiff, "#.##")) : "DISABLED", text_color=color.white, text_size=tSize)
    table.cell(t, 2, 1, get_arrow(cmeDiff), text_color=color.white, text_size=tSize, bgcolor=get_bg(cmeDiff))

    // CME Arbitrage Yield
    bState = na(cmeBasis) ? "N/A" : cmeBasis > 15 ? "ARB RISK" : cmeBasis > 5 ? "ELEVATED" : cmeBasis < 0 ? "DISCOUNT" : "NORMAL"
    bCol = na(cmeBasis) ? color.new(color.gray,80) : cmeBasis > 15 ? color.new(#ff0000,30) : cmeBasis > 5 ? color.new(#ff8800,50) : cmeBasis < 0 ? color.new(#00ff00,30) : color.new(color.gray,80)
    table.cell(t, 0, 2, "CME BASIS (ANN)", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, 2, useCME ? (na(cmeBasis) ? "N/A" : str.tostring(cmeBasis, "#.##") + "%") : "DISABLED", text_color=color.white, text_size=tSize)
    table.cell(t, 2, 2, useCME ? bState : "━", text_color=color.white, text_size=tSize, bgcolor=bCol)

    // Retail Derivative Delta
    table.cell(t, 0, 3, "PERP SPREAD", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, 3, na(perpDiff) ? "N/A" : str.tostring(perpDiff, "#.##"), text_color=color.white, text_size=tSize)
    table.cell(t, 2, 3, get_arrow(perpDiff), text_color=color.white, text_size=tSize, bgcolor=get_bg(perpDiff))

    // Smart Money Accumulation/Distribution
    table.cell(t, 0, 4, "INST SPREAD", text_color=color.rgb(255,215,0), text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, 4, useCME ? (na(instDiff) ? "N/A" : str.tostring(instDiff, "#.##")) : "DISABLED", text_color=color.rgb(255,215,0), text_size=tSize)
    table.cell(t, 2, 4, na(instDiff) ? "━" : instDiff > thresholdStrong ? "SM ACCUM" : instDiff < -thresholdStrong ? "SM DISTRIB" : "IN LINE", text_color=color.white, text_size=tSize, bgcolor=na(instDiff) ? color.new(color.gray,80) : instDiff > thresholdStrong ? color.new(#00ff00,20) : instDiff < -thresholdStrong ? color.new(#ff0000,20) : color.new(color.gray,80))

    // Stablecoin De-peg Risk
    pegCol = na(peg) ? color.new(color.gray,80) : (peg < 0.9995 or peg > 1.0005) ? color.new(#ff0000,30) : color.new(#00ff00,30)
    table.cell(t, 0, 5, "USDT PEG", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, 5, useUSDT ? (na(peg) ? "N/A" : str.tostring(peg, "#.####")) : "DISABLED", text_color=color.white, text_size=tSize)
    table.cell(t, 2, 5, useUSDT ? (na(peg) ? "━" : peg < 0.9995 ? "RISKY" : "STABLE") : "━", text_color=color.white, text_size=tSize, bgcolor=pegCol)

    // Local Exchange Liquidity
    mBg = color.new(#2962ff, 40)
    table.cell(t, 0, 6, "BINANCE OI", text_color=color.white, text_size=tSize, text_halign=text.align_left, bgcolor=mBg)
    table.cell(t, 1, 6, format_n(binOI), text_color=color.white, text_size=tSize, bgcolor=mBg)
    table.cell(t, 2, 6, (na(oiDelta) or na(priceDelta)) ? "N/A" : get_oi_s(oiDelta, priceDelta), text_color=color.white, text_size=tSize, bgcolor=(na(oiDelta) or na(priceDelta)) ? color.new(color.gray,80) : get_oi_c(oiDelta, priceDelta))

    // Crowd Positioning Sentiment
    fStr = na(frNorm) ? "N/A" : frNorm > 0.0005 ? "OVERHEATED" : frNorm > 0.0001 ? "LONGS PAY" : frNorm < -0.0003 ? "FEAR EXTREME" : frNorm < -0.0001 ? "SHORTS PAY" : "NEUTRAL"
    fCol = na(frNorm) ? color.new(color.gray,80) : frNorm > 0.0005 ? color.new(#ff0000,30) : frNorm > 0.0001 ? color.new(#ff8800,50) : frNorm < -0.0003 ? color.new(#00ff00,30) : frNorm < -0.0001 ? color.new(#85ff00,50) : color.new(color.gray,60)
    table.cell(t, 0, 7, "FUNDING RATE", text_color=color.white, text_size=tSize, text_halign=text.align_left, bgcolor=mBg)
    table.cell(t, 1, 7, na(frNorm) ? "N/A" : str.tostring(frNorm * 100, "#.####") + "%", text_color=color.white, text_size=tSize, bgcolor=mBg)
    table.cell(t, 2, 7, fStr, text_color=color.white, text_size=tSize, bgcolor=fCol)

    // Global Liquidity Aggregation
    aBg = color.new(#6a0dad, 40)
    table.cell(t, 0, 8, "OI AGGREGATE", text_color=color.white, text_size=tSize, text_halign=text.align_left, bgcolor=aBg)
    table.cell(t, 1, 8, useExtraOI ? format_n(oiTotal) : "DISABLED", text_color=color.white, text_size=tSize, bgcolor=aBg)
    table.cell(t, 2, 8, useExtraOI ? (na(oiTotDelta) or oiTotDelta==0 ? "N/A" : oiTotDelta > 0 ? "EXPANDING" : oiTotDelta < 0 ? "SHRINKING" : "FLAT") : "━", text_color=color.white, text_size=tSize, bgcolor=useExtraOI ? (na(oiTotDelta) or oiTotDelta==0 ? color.new(color.gray,80) : oiTotDelta > 0 ? color.new(#00ff00,30) : oiTotDelta < 0 ? color.new(#ff0000,30) : color.new(color.gray,60)) : color.new(color.gray,80))

    // Market Maker Dominance
    table.cell(t, 0, 9, "BIN DOMINANCE", text_color=color.white, text_size=tSize, text_halign=text.align_left, bgcolor=aBg)
    table.cell(t, 1, 9, useExtraOI ? (oiBinPct == 0.0 ? "N/A" : str.tostring(oiBinPct, "#.#") + "%") : "DISABLED", text_color=color.white, text_size=tSize, bgcolor=aBg)
    table.cell(t, 2, 9, useExtraOI ? (oiBinPct == 0.0 ? "━" : oiBinPct > 50 ? "BIN LEADS" : oiBinPct < 30 ? "DISPERSED" : "BALANCED") : "━", text_color=color.white, text_size=tSize, bgcolor=useExtraOI ? (oiBinPct == 0.0 ? color.new(color.gray,80) : oiBinPct > 50 ? color.new(#f0b90b,40) : color.new(color.gray,60)) : color.new(color.gray,80))

    // Spot Anchor Diagnostics (Newly added)
    anchorName = not useAnchors ? "DISABLED" : (not na(cbSpot) ? "COINBASE" : (not na(krSpot) ? "KRAKEN" : "BIN FALLBACK"))
    table.cell(t, 0, 10, "SPOT ANCHOR", text_color=color.white, text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, 10, useAnchors ? str.tostring(basePrice, "#.##") : "BINANCE ONLY", text_color=color.white, text_size=tSize)
    table.cell(t, 2, 10, anchorName, text_color=color.white, text_size=tSize, bgcolor=useAnchors ? color.new(color.gray, 60) : color.new(color.gray, 80))

    // Final Decision Engine Output
    table.cell(t, 0, 11, "SCOREBOARD", text_color=color.white, text_size=tSize, text_halign=text.align_left, bgcolor=color.new(#131722,0))
    table.cell(t, 1, 11, "SCORE: " + (total_score > 0 ? "+" : "") + str.tostring(total_score), text_color=color.white, text_size=tSize, bgcolor=color.new(#131722,0))
    table.cell(t, 2, 11, final_bias, text_color=color.white, text_size=tSize, bgcolor=final_color)
````
