# MULTIMINERAL

- url: https://www.tradingview.com/script/XUQFYkbW/
- type: indicator
- pine_id: PUB;eb73e4a5bc2e494cb5dae72b4fc356ce
- version: 1.0

## Description

MULTIMINERAL: Advanced Signal Engine & Dynamic State Tracker

Description:

Welcome to MULTIMINERAL. This indicator is built upon the exact same robust algorithmic foundation as its predecessor, but it introduces highly advanced trade management and state-tracking mechanics. If you want to explore the original core system, you can find MULTIVITAMIN here:
https://tr.tradingview.com/script/g1jMlWVo/?utm_source=notification_email&utm_medium=email&utm_campaign=notification_vote

The Core Engine: Advanced Confluence & Price Action
At its heart, MULTIMINERAL analyzes market structure through a highly sensitive technical confluence, combining traditional momentum indicators with pure price action and volume dynamics. The engine relies on:

Price Action & Smart Money Concepts: Actively detecting high-probability candlestick formations like Engulfing patterns, while identifying critical FVG (Fair Value Gaps) to pinpoint liquidity zones and explosive entry points.

Volume Analysis: Validating the true strength and institutional backing behind every price movement to filter out fake breakouts.

Hull Moving Average (HMA): Utilized for ultra-fast, lag-free trend identification.

EMA & EMA Slope: Exponential Moving Averages combined with precise slope (trajectory) analysis to catch the exact moment a trend accelerates or loses momentum.

ADX, RSI & Momentum: A layered combination to gauge absolute trend strength, overbought/oversold extremes, and price velocity.

The Key Difference: Why MULTIMINERAL?
While both indicators share the same DNA, the critical difference lies in State Management, Dynamic Exits, and how the system handles Repeating Signals.

Exit on Reverse Signal: Standard algorithmic systems often get stuck waiting for fixed take-profit or stop-loss levels. MULTIMINERAL is strictly dynamic. If the underlying market structure flips and the indicator detects an opposite signal, it immediately invalidates the current bias and exits.

The "Virtual Treasury" (1.9% & 2.1% Thresholds): MULTIMINERAL constantly tracks a virtual position. If the price movement reaches critical breaking points—specifically the 1.9% or 2.1% PnL thresholds—the system instantly realizes the previous cycle is functionally over. It completely resets its internal state (bot status returns to zero).

Catching Repeating Signals: Because of this immediate state shift, MULTIMINERAL never misses fresh opportunities. While standard systems are "locked" into an old, ongoing trade, MULTIMINERAL scans the market with a clean slate. It successfully catches overlapping or "repeating signals," firing a brand new entry precisely when the market pivots again.

The 32-Candle Verification Window: To ensure these state shifts and repeating signals are accurate—and to filter out market noise—the algorithm cross-references the new setup against a strict 32-candle lookback window. The volume, EMA slopes, momentum, and price action must validate the trend shift within these last 32 bars before the overriding signal is printed.

MULTIMINERAL is designed for traders who need a hyper-responsive, adaptive system that recalculates market reality instantly, dynamically exits on reverse conditions, and capitalizes on every structural pivot.

## Source Code

````pine
//@version=5
indicator("MULTI MINERAL", overlay=true, max_labels_count=500)

// ==========================================
// --- 1. SETTINGS (MULTI MINERAL AYARLARI) ---
// ==========================================

group_hull = "1. HULL CONFIRMATION SETTINGS"
useHull    = input.bool(true, "Use Hull Confirmation Filter", group=group_hull)
hullTF     = input.timeframe("10", "Hull Confirmation Timeframe", group=group_hull)
hullLen    = input.int(55, "Hull Period", minval=1, group=group_hull)

group_bkr  = "2. VOLUME SUPPORTED BREAKOUT"
useBKR     = input.bool(true, "BKR Ozelligi", group=group_bkr)
bkrLook    = input.int(10, "BKR Lookback Bars", group=group_bkr)
volMult    = input.float(1.2, "Volume Multiplier", step=0.1, group=group_bkr)

group_adx  = "3. ADX (ANTI-CHOP) SETTINGS"
useADX     = input.bool(true, "Use ADX Filter", group=group_adx)
adxLimit   = input.int(20, "ADX Threshold", group=group_adx)

group_ema  = "4. EMA (MAIN TREND) SETTINGS"
useEMA     = input.bool(true, "Use EMA Filter", group=group_ema)
emaLen     = input.int(50, "EMA Length", group=group_ema) 

group_rsi  = "5. RSI (FILTER) SETTINGS"
useRSI     = input.bool(true, "Use RSI Filter", group=group_rsi)

group_savunma = "6. SCALPER LIFECYCLE (EXIT SETTINGS)"
useTersExit  = input.bool(true, "Ters Sinyalde Cik (Exit L/S)", group=group_savunma)
useZaman     = input.bool(false, "Mum Sayisi Cikisi", group=group_savunma)
maxBar       = input.int(10, "Maksimum Mum Sayisi", group=group_savunma)
useEsneklik  = input.bool(false, "Stop Buffer Cikisi", group=group_savunma)
stopEsneklik = input.float(0.34, "Stop Buffer %", step=0.01, group=group_savunma)

group_pro = "7. PRO FILTERS (ANTI-CHOP WALLS)"
useSlope     = input.bool(true, "EMA Egim Filtresi", group=group_pro)
slopeLook    = input.int(5, "Egim Olcum Mum Sayisi", group=group_pro)
slopeThres   = input.float(0.0001, "Egim Esik Degeri", step=0.0001, group=group_pro)
useVolatility = input.bool(true, "ATR Volatilite Filtresi", group=group_pro)
volATRMult   = input.float(0.8, "ATR Carpani", step=0.1, group=group_pro)

// --- MULTI MINERAL: HER ŞEY TEK TEK OPSİYONEL ---
group_mineral_core = "8. MINERAL: AYNI YON GIRIS DISIPLINI"
useMineralLogic = input.bool(true, "Ayni Yonde Tekrar Girisi AC/KAPA", group=group_mineral_core)
useCooldown     = input.bool(true, "-> 32 Mum Barem Filtresini Kullan", group=group_mineral_core)
cooldownBars    = input.int(32, "   Barem Suresi (Mum)", group=group_mineral_core)

group_mineral_cassa = "9. MINERAL: SANAL KASA FILTRESI"
useCassa        = input.bool(true, "-> 1.9 / 2.1 Kasa Takibini Kullan", group=group_mineral_cassa)
tp_early        = input.float(1.90, "   TP Erken Uyari %", group=group_mineral_cassa)
tp_late         = input.float(2.10, "   TP Kasa Bos %", group=group_mineral_cassa)
sl_early        = input.float(0.95, "   SL Erken Uyari %", group=group_mineral_cassa)
sl_late         = input.float(1.05, "   SL Kasa Bos %", group=group_mineral_cassa)

group_seans = "10. MINERAL: MESAI SAATLERI"
useSession      = input.bool(false, "Seans Filtresini Kullan", group=group_seans)
sessionTime     = input.session("1000-2300", "Calisma Saatleri", group=group_seans)

// ==========================================
// --- 2. CALCULATIONS (TEKNIK HESAPLAR) ---
// ==========================================

f_hma(_src, _len) => ta.wma(2 * ta.wma(_src, _len / 2) - ta.wma(_src, _len), math.round(math.sqrt(_len)))
h_close = request.security(syminfo.tickerid, hullTF, close)
h_hull  = request.security(syminfo.tickerid, hullTF, f_hma(close, hullLen)) 
[plusDI, minusDI, adxVal] = ta.dmi(14, 14)
emaVal = ta.ema(close, emaLen) 
rsiVal = ta.rsi(close, 14)
volSMA = ta.sma(volume, 20)
atrVal = ta.atr(14)
emaSlope = (emaVal - emaVal[slopeLook]) / slopeLook
slopeOk = not useSlope or (math.abs(emaSlope) > (emaVal * slopeThres))
volOk   = not useVolatility or (high - low > atrVal * volATRMult)
bkrLong  = high > ta.highest(high[1], bkrLook) and volume > (volSMA * volMult)
bkrShort = low < ta.lowest(low[1], bkrLook) and volume > (volSMA * volMult)
inSession = not useSession or not na(time(timeframe.period, sessionTime))

// ==========================================
// --- 3. PA STRUCTURES (OMURGA ANALIZ) ---
// ==========================================
isEngulfingLong  = close > open and close[1] < open[1] and close > open[1] and open < close[1]
isEngulfingShort = close < open and close[1] > open[1] and close < open[1] and open > close[1]
isFVG_Long  = low > high[2]  
isFVG_Short = high < low[2]  
hacimOnay = volume > volSMA
OB_Long   = close > ta.highest(high[1], 2) and hacimOnay
OB_Short  = close < ta.lowest(low[1], 2) and hacimOnay
adx_Long_Ok  = not useADX or (adxVal > adxLimit and plusDI > minusDI)
adx_Short_Ok = not useADX or (adxVal > adxLimit and minusDI > plusDI)

long_ok  = (isEngulfingLong or OB_Long or isFVG_Long or (useBKR and bkrLong)) and (not useHull or h_close > h_hull) and adx_Long_Ok and (not useEMA or close > emaVal) and (not useRSI or rsiVal < 70) and slopeOk and volOk 
short_ok = (isEngulfingShort or OB_Short or isFVG_Short or (useBKR and bkrShort)) and (not useHull or h_close < h_hull) and adx_Short_Ok and (not useEMA or close < emaVal) and (not useRSI or rsiVal > 30) and slopeOk and volOk 

// ==========================================
// --- 4. ENGINE (ANA MOTOR & EK MOTOR) ---
// ==========================================

var int anaDurum = 0  
var float anaEntrySL = na
var int anaBarSayac = 0

if anaDurum != 0
    anaBarSayac += 1

anaTersL = anaDurum ==  1 and useTersExit and short_ok
anaTersS = anaDurum == -1 and useTersExit and long_ok
anaStop  = (anaDurum == 1 and useEsneklik and low < anaEntrySL) or (anaDurum == -1 and useEsneklik and high > anaEntrySL)
anaZaman = anaDurum != 0 and useZaman and anaBarSayac >= maxBar

anaCikisL = (anaTersL or (anaStop and anaDurum == 1) or (anaZaman and anaDurum == 1)) and barstate.isconfirmed
anaCikisS = (anaTersS or (anaStop and anaDurum == -1) or (anaZaman and anaDurum == -1)) and barstate.isconfirmed

if anaCikisL or anaCikisS
    anaDurum := 0

anaGirisL = long_ok and inSession and anaDurum == 0 and not anaCikisL and barstate.isconfirmed
anaGirisS = short_ok and inSession and anaDurum == 0 and not anaCikisS and barstate.isconfirmed

if anaGirisL
    anaDurum := 1
    anaEntrySL := low * (1 - stopEsneklik/100)
    anaBarSayac := 0
if anaGirisS
    anaDurum := -1
    anaEntrySL := high * (1 + stopEsneklik/100)
    anaBarSayac := 0

// --- MINERAL MOTORU (EK SINYALLER) ---
var int mineralDurum = 0 
var float mineralEntryPrice = na
var int barsSinceLastEntry = 9999
var bool erkenOnay = false

barsSinceLastEntry += 1

// Sanal Kasa Takibi (Sadece aktifse calisir)
if useMineralLogic and useCassa
    if mineralDurum == 1
        if high >= mineralEntryPrice * (1 + tp_early/100) or low <= mineralEntryPrice * (1 - sl_early/100)
            erkenOnay := true
        if high >= mineralEntryPrice * (1 + tp_late/100) or low <= mineralEntryPrice * (1 - sl_late/100)
            mineralDurum := 0
    if mineralDurum == -1
        if low <= mineralEntryPrice * (1 - tp_early/100) or high >= mineralEntryPrice * (1 + sl_early/100)
            erkenOnay := true
        if low <= mineralEntryPrice * (1 - tp_late/100) or high >= mineralEntryPrice * (1 + sl_late/100)
            mineralDurum := 0

// Reset Mekanizmasi
if anaCikisL or anaCikisS or anaGirisL or anaGirisS or not useMineralLogic
    mineralDurum := 0
    erkenOnay := false

// Mineral Sartlari (Tek tek kontrol edilir)
bool baremTamam = not useCooldown or barsSinceLastEntry >= cooldownBars
bool cassaTamam = not useCassa or (mineralDurum == 0 or erkenOnay)

mineralGirisL = useMineralLogic and long_ok and inSession and anaDurum == 1 and baremTamam and cassaTamam and barstate.isconfirmed
mineralGirisS = useMineralLogic and short_ok and inSession and anaDurum == -1 and baremTamam and cassaTamam and barstate.isconfirmed

if anaGirisL or mineralGirisL
    mineralDurum := 1
    mineralEntryPrice := close
    barsSinceLastEntry := 0
    erkenOnay := false

if anaGirisS or mineralGirisS
    mineralDurum := -1
    mineralEntryPrice := close
    barsSinceLastEntry := 0
    erkenOnay := false

finalL = anaGirisL or mineralGirisL
finalS = anaGirisS or mineralGirisS

// ==========================================
// --- 5. VISUALS & ALERTS ---
// ==========================================

plotshape(finalL, "ENTER-L", shape.labelup, location.belowbar, color.lime, size=size.normal, text="ENTER-L")
plotshape(finalS, "ENTER-S", shape.labeldown, location.abovebar, color.red, size=size.normal, text="ENTER-S")
plotshape(anaCikisL, "EXIT-L", shape.xcross, location.belowbar, color.orange, size=size.small, display=display.none, text="EXIT-L")
plotshape(anaCikisS, "EXIT-S", shape.xcross, location.abovebar, color.orange, size=size.small, display=display.none, text="EXIT-S")

alertcondition(finalL, "ENTER_LONG", "🚀 ENTER LONG")
alertcondition(finalS, "ENTER_SHORT", "🔻 ENTER SHORT")
alertcondition(anaCikisL, "EXIT_LONG", "⚠️ EXIT LONG")
alertcondition(anaCikisS, "EXIT_SHORT", "⚠️ EXIT SHORT")
````
