# RizA_Ultra_v23

- url: https://www.tradingview.com/script/rmTnE3vC/
- type: indicator
- pine_id: PUB;e1082ccff1894160863db50260c0ef55
- version: 1.0

## Description

RizA Ultra v23 - Multi-Timeframe Trend & Liquidity Engine
RizA_Ultra_v23 is a highly adaptive, institutional-grade technical analysis indicator designed for multi-timeframe trend alignment, liquidity tracking, and dynamic risk management. By fusing dual Multi-Timeframe (MTF) Simple Moving Averages, an advanced MTF Momentum Confirmation Filter (WaveTrend), and real-time Liquidity Swing Zones, this tool provides traders with a pristine macro-to-micro view of any market.

Whether you trade Indices (NAS100, GER40), Crypto (BTCUSD), or Forex/Metals (XAUUSD), this indicator eliminates the noise and delivers precise execution signals.

🌟 Key Features
1. Smart Asset Profiles (Broker-Independent)
Say goodbye to constantly changing your indicator settings when switching assets. The script features built-in, optimized presets for four major symbols that apply automatically by scanning your chart ticker:

NAS100 (Nasdaq)

BTCUSD (Bitcoin)

XAUUSD (Gold)

GER40 (Dax)

Note: Includes a fully customizable manual mode for any other asset of your choice.

2. Dual MTF Trend Alignment (MTF1 & MTF2)
The core engine tracks two distinct higher timeframes simultaneously using customizable Short/Long SMA pairs.

Visual Ribbons: Fills the space between the short and long moving averages with color-coded sentiment bands (Bullish/Bearish).

Execution Matrix: Signals are only triggered when the faster MTF cross aligns with the directional bias of the slower MTF trend.

3. MTF MAC Confirmation (WaveTrend Filter)
To filter out false breakouts and choppy consolidation zones, an integrated WaveTrend Oscillator Engine functions on a third customizable timeframe. It validates the structural health of the move, preventing you from buying a premium or selling a discount.

4. Institutional Liquidity Swings
Tracks market structure in real-time by identifying key Pivot Highs and Pivot Lows.

Wick & Range Extremities: Draws clear, real-time institutional liquidity blocks.

Intrabar Precision: Utilizes lower timeframe lower-tf lookups to calculate historical volume/count depth within the swing areas.

Breach Tracking: Solid lines turn to dashed lines once liquidity is swept or invalidated by price action.

5. Dynamic Trailing Stop Loss (TSL)
Protects your capital with a fully automated, trailing stop-loss visualizer:

Fixed Initial Risk: Plots a standard initial stop loss based on your fixed percentage input.

Profit Activation Engine: Once price reaches a specific percentage threshold, a Trailing Stop activates, dynamically locking in profits bar-by-bar until a violation candle closes out the position.

6. Heads-Up Display (HUD) Dashboard
Includes a clean, highly readable info-table positioned on your chart to track the real-time status of your MTF1, MTF2, and MAC momentum filters simultaneously without cluttering your price action view.

📥 Settings & Customization
Timeframes & Periods: Fully configure intervals and lengths for all MTF filters.

Liquidity Options: Adjust Pivot Lookbacks, select filter parameters (Volume vs. Count), and customize visual zones.

Risk Metrics: Tweak initial stop-loss percentages, TSL activation points, and trailing tighter percentages.

UI/UX: Toggle visual components, change colors, adjust transparency, and reposition the dashboard table.

🚨 Real-Time Alerts Included
Never miss a setup. This indicator comes equipped with ready-made alert conditions for automation or push notifications:

Long Signal — Triggered when multi-timeframe structures align bullishly with MAC confirmation.

Short Signal — Triggered when multi-timeframe structures align bearishly with MAC confirmation.

Disclaimer: Trading financial instruments involves high risk. This tool is designed for educational and analytical purposes and does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator(title="RizA_Ultra_v23", shorttitle="RizA_Ultra_v23", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ============================================
// ===== MTF1 AYARLARI (MANUEL / VARSAYILAN) =====
// ============================================
mtf1Group = "MTF1 Ayarlari"
string mtf1_tf_manual = input.timeframe("3", "MTF1 Zaman Dilimi", group=mtf1Group)
bool showMtf1Short_manual = input.bool(true, "MTF1 SMA Kisa Goster", group=mtf1Group, inline="mtf1tick")
bool showMtf1Long_manual = input.bool(true, "MTF1 SMA Uzun Goster", group=mtf1Group, inline="mtf1tick")
int mtf1_short_manual = input.int(12, "MTF1 SMA Kisa", group=mtf1Group, inline="mtf1sma")
int mtf1_long_manual = input.int(200, "MTF1 SMA Uzun", group=mtf1Group, inline="mtf1sma")

// ============================================
// ===== MTF2 AYARLARI (MANUEL / VARSAYILAN) =====
// ============================================
mtf2Group = "MTF2 Ayarlari"
string mtf2_tf_manual = input.timeframe("15", "MTF2 Zaman Dilimi", group=mtf2Group)
bool showMtf2Short_manual = input.bool(true, "MTF2 SMA Kisa Goster", group=mtf2Group, inline="mtf2tick")
bool showMtf2Long_manual = input.bool(true, "MTF2 SMA Uzun Goster", group=mtf2Group, inline="mtf2tick")
int mtf2_short_manual = input.int(8, "MTF2 SMA Kisa", group=mtf2Group, inline="mtf2sma")
int mtf2_long_manual = input.int(21, "MTF2 SMA Uzun", group=mtf2Group, inline="mtf2sma")

// ============================================
// ===== MTF MAC ONAY AYARLARI (MANUEL / ORTAK) =====
// ============================================
macGroup = "MTF MAC Onay Ayarlari"
bool mac_on_manual = input.bool(true, "MTF MAC Onay Aktif (Manuel)", group=macGroup)
string mac_tf_manual = input.timeframe("30", "MAC Zaman Dilimi (Manuel)", group=macGroup)
int mac_n1 = input.int(10, "MAC Channel Length", group=macGroup, inline="macparam")
int mac_n2 = input.int(21, "MAC Average Length", group=macGroup, inline="macparam")

// ============================================
// ===== OZEL SEMBOL AYARLARI =====
// ============================================

// --- SEMBOL 1 (NAS100) ---
sym1Group = "Sembol 1 Ayarlari"
bool sym1_enabled = input.bool(true, "Sembol 1 Aktif", group=sym1Group)
bool sym1_mac_on = input.bool(true, "Sembol 1 MTF MAC Onay Aktif", group=sym1Group)
string sym1_mac_tf = input.timeframe("180", "Sembol 1 MAC Zaman Dilimi", group=sym1Group)
string sym1_ticker = input.string("NAS100", "Sembol 1 (sadece ad)", group=sym1Group, tooltip="Sadece sembol adi: NAS100, BTCUSD, XAUUSD")

string sym1_mtf1_tf = input.timeframe("15", "Sembol 1 MTF1 Zaman Dilimi", group=sym1Group)
bool sym1_showMtf1Short = input.bool(true, "Sembol 1 MTF1 SMA Kisa Goster", group=sym1Group, inline="sym1mtf1tick")
bool sym1_showMtf1Long = input.bool(true, "Sembol 1 MTF1 SMA Uzun Goster", group=sym1Group, inline="sym1mtf1tick")
int sym1_mtf1_short = input.int(9, "Sembol 1 MTF1 SMA Kisa", group=sym1Group, inline="sym1mtf1sma")
int sym1_mtf1_long = input.int(189, "Sembol 1 MTF1 SMA Uzun", group=sym1Group, inline="sym1mtf1sma")

string sym1_mtf2_tf = input.timeframe("180", "Sembol 1 MTF2 Zaman Dilimi", group=sym1Group)
bool sym1_showMtf2Short = input.bool(true, "Sembol 1 MTF2 SMA Kisa Goster", group=sym1Group, inline="sym1mtf2tick")
bool sym1_showMtf2Long = input.bool(true, "Sembol 1 MTF2 SMA Uzun Goster", group=sym1Group, inline="sym1mtf2tick")
int sym1_mtf2_short = input.int(8, "Sembol 1 MTF2 SMA Kisa", group=sym1Group, inline="sym1mtf2sma")
int sym1_mtf2_long = input.int(21, "Sembol 1 MTF2 SMA Uzun", group=sym1Group, inline="sym1mtf2sma")

// --- SEMBOL 2 (BTCUSD) ---
sym2Group = "Sembol 2 Ayarlari"
bool sym2_enabled = input.bool(true, "Sembol 2 Aktif", group=sym2Group)
bool sym2_mac_on = input.bool(true, "Sembol 2 MTF MAC Onay Aktif", group=sym2Group)
string sym2_mac_tf = input.timeframe("60", "Sembol 2 MAC Zaman Dilimi", group=sym2Group)
string sym2_ticker = input.string("BTCUSD", "Sembol 2 (sadece ad)", group=sym2Group)

string sym2_mtf1_tf = input.timeframe("10", "Sembol 2 MTF1 Zaman Dilimi", group=sym2Group)
bool sym2_showMtf1Short = input.bool(true, "Sembol 2 MTF1 SMA Kisa Goster", group=sym2Group, inline="sym2mtf1tick")
bool sym2_showMtf1Long = input.bool(true, "Sembol 2 MTF1 SMA Uzun Goster", group=sym2Group, inline="sym2mtf1tick")
int sym2_mtf1_short = input.int(12, "Sembol 2 MTF1 SMA Kisa", group=sym2Group, inline="sym2mtf1sma")
int sym2_mtf1_long = input.int(200, "Sembol 2 MTF1 SMA Uzun", group=sym2Group, inline="sym2mtf1sma")

string sym2_mtf2_tf = input.timeframe("120", "Sembol 2 MTF2 Zaman Dilimi", group=sym2Group)
bool sym2_showMtf2Short = input.bool(true, "Sembol 2 MTF2 SMA Kisa Goster", group=sym2Group, inline="sym2mtf2tick")
bool sym2_showMtf2Long = input.bool(true, "Sembol 2 MTF2 SMA Uzun Goster", group=sym2Group, inline="sym2mtf2tick")
int sym2_mtf2_short = input.int(7, "Sembol 2 MTF2 SMA Kisa", group=sym2Group, inline="sym2mtf2sma")
int sym2_mtf2_long = input.int(23, "Sembol 2 MTF2 SMA Uzun", group=sym2Group, inline="sym2mtf2sma")

// --- SEMBOL 3 (XAUUSD) ---
sym3Group = "Sembol 3 Ayarlari"
bool sym3_enabled = input.bool(true, "Sembol 3 Aktif", group=sym3Group)
bool sym3_mac_on = input.bool(true, "Sembol 3 MTF MAC Onay Aktif", group=sym3Group)
string sym3_mac_tf = input.timeframe("30", "Sembol 3 MAC Zaman Dilimi", group=sym3Group)
string sym3_ticker = input.string("XAUUSD", "Sembol 3 (sadece ad)", group=sym3Group)

string sym3_mtf1_tf = input.timeframe("3", "Sembol 3 MTF1 Zaman Dilimi", group=sym3Group)
bool sym3_showMtf1Short = input.bool(true, "Sembol 3 MTF1 SMA Kisa Goster", group=sym3Group, inline="sym3mtf1tick")
bool sym3_showMtf1Long = input.bool(true, "Sembol 3 MTF1 SMA Uzun Goster", group=sym3Group, inline="sym3mtf1tick")
int sym3_mtf1_short = input.int(12, "Sembol 3 MTF1 SMA Kisa", group=sym3Group, inline="sym3mtf1sma")
int sym3_mtf1_long = input.int(200, "Sembol 3 MTF1 SMA Uzun", group=sym3Group, inline="sym3mtf1sma")

string sym3_mtf2_tf = input.timeframe("15", "Sembol 3 MTF2 Zaman Dilimi", group=sym3Group)
bool sym3_showMtf2Short = input.bool(true, "Sembol 3 MTF2 SMA Kisa Goster", group=sym3Group, inline="sym3mtf2tick")
bool sym3_showMtf2Long = input.bool(true, "Sembol 3 MTF2 SMA Uzun Goster", group=sym3Group, inline="sym3mtf2tick")
int sym3_mtf2_short = input.int(8, "Sembol 3 MTF2 SMA Kisa", group=sym3Group, inline="sym3mtf2sma")
int sym3_mtf2_long = input.int(21, "Sembol 3 MTF2 SMA Uzun", group=sym3Group, inline="sym3mtf2sma")

// --- SEMBOL 4 (GER40) ---
sym4Group = "Sembol 4 Ayarlari"
bool sym4_enabled = input.bool(true, "Sembol 4 Aktif", group=sym4Group)
bool sym4_mac_on = input.bool(true, "Sembol 4 MTF MAC Onay Aktif", group=sym4Group)
string sym4_mac_tf = input.timeframe("60", "Sembol 4 MAC Zaman Dilimi", group=sym4Group)
string sym4_ticker = input.string("GER40", "Sembol 4 (sadece ad)", group=sym4Group, tooltip="Sadece sembol adi: GER40, DAX, DE40 (tum kurumlarda calisir)")

string sym4_mtf1_tf = input.timeframe("15", "Sembol 4 MTF1 Zaman Dilimi", group=sym4Group)
bool sym4_showMtf1Short = input.bool(true, "Sembol 4 MTF1 SMA Kisa Goster", group=sym4Group, inline="sym4mtf1tick")
bool sym4_showMtf1Long = input.bool(true, "Sembol 4 MTF1 SMA Uzun Goster", group=sym4Group, inline="sym4mtf1tick")
int sym4_mtf1_short = input.int(9, "Sembol 4 MTF1 SMA Kisa", group=sym4Group, inline="sym4mtf1sma")
int sym4_mtf1_long = input.int(189, "Sembol 4 MTF1 SMA Uzun", group=sym4Group, inline="sym4mtf1sma")

string sym4_mtf2_tf = input.timeframe("120", "Sembol 4 MTF2 Zaman Dilimi", group=sym4Group)
bool sym4_showMtf2Short = input.bool(true, "Sembol 4 MTF2 SMA Kisa Goster", group=sym4Group, inline="sym4mtf2tick")
bool sym4_showMtf2Long = input.bool(true, "Sembol 4 MTF2 SMA Uzun Goster", group=sym4Group, inline="sym4mtf2tick")
int sym4_mtf2_short = input.int(8, "Sembol 4 MTF2 SMA Kisa", group=sym4Group, inline="sym4mtf2sma")
int sym4_mtf2_long = input.int(21, "Sembol 4 MTF2 SMA Uzun", group=sym4Group, inline="sym4mtf2sma")

// ============================================
// ===== AKTIF AYAR SECIMI (BROKER BAGIMSIZ) =====
// ============================================
bool matchSym1 = sym1_enabled and str.contains(syminfo.ticker, sym1_ticker)
bool matchSym2 = sym2_enabled and str.contains(syminfo.ticker, sym2_ticker)
bool matchSym3 = sym3_enabled and str.contains(syminfo.ticker, sym3_ticker)
bool matchSym4 = sym4_enabled and str.contains(syminfo.ticker, sym4_ticker)

string mtf1_tf       = matchSym1 ? sym1_mtf1_tf       : matchSym2 ? sym2_mtf1_tf       : matchSym3 ? sym3_mtf1_tf       : matchSym4 ? sym4_mtf1_tf       : mtf1_tf_manual
bool showMtf1Short   = matchSym1 ? sym1_showMtf1Short : matchSym2 ? sym2_showMtf1Short : matchSym3 ? sym3_showMtf1Short : matchSym4 ? sym4_showMtf1Short : showMtf1Short_manual
bool showMtf1Long    = matchSym1 ? sym1_showMtf1Long  : matchSym2 ? sym2_showMtf1Long  : matchSym3 ? sym3_showMtf1Long  : matchSym4 ? sym4_showMtf1Long  : showMtf1Long_manual
int mtf1_short       = matchSym1 ? sym1_mtf1_short    : matchSym2 ? sym2_mtf1_short    : matchSym3 ? sym3_mtf1_short    : matchSym4 ? sym4_mtf1_short    : mtf1_short_manual
int mtf1_long        = matchSym1 ? sym1_mtf1_long     : matchSym2 ? sym2_mtf1_long     : matchSym3 ? sym3_mtf1_long     : matchSym4 ? sym4_mtf1_long     : mtf1_long_manual

string mtf2_tf       = matchSym1 ? sym1_mtf2_tf       : matchSym2 ? sym2_mtf2_tf       : matchSym3 ? sym3_mtf2_tf       : matchSym4 ? sym4_mtf2_tf       : mtf2_tf_manual
bool showMtf2Short   = matchSym1 ? sym1_showMtf2Short : matchSym2 ? sym2_showMtf2Short : matchSym3 ? sym3_showMtf2Short : matchSym4 ? sym4_showMtf2Short : showMtf2Short_manual
bool showMtf2Long    = matchSym1 ? sym1_showMtf2Long  : matchSym2 ? sym2_showMtf2Long  : matchSym3 ? sym3_showMtf2Long  : matchSym4 ? sym4_showMtf2Long  : showMtf2Long_manual
int mtf2_short       = matchSym1 ? sym1_mtf2_short    : matchSym2 ? sym2_mtf2_short    : matchSym3 ? sym3_mtf2_short    : matchSym4 ? sym4_mtf2_short    : mtf2_short_manual
int mtf2_long        = matchSym1 ? sym1_mtf2_long     : matchSym2 ? sym2_mtf2_long     : matchSym3 ? sym3_mtf2_long     : matchSym4 ? sym4_mtf2_long     : mtf2_long_manual

bool mac_on          = matchSym1 ? sym1_mac_on : matchSym2 ? sym2_mac_on : matchSym3 ? sym3_mac_on : matchSym4 ? sym4_mac_on : mac_on_manual
string mac_tf        = matchSym1 ? sym1_mac_tf : matchSym2 ? sym2_mac_tf : matchSym3 ? sym3_mac_tf : matchSym4 ? sym4_mac_tf : mac_tf_manual

// ============================================
// ===== MTF1 DOLGU RENKLERI =====
// ============================================
mtf1ColorGroup = "MTF1 Dolgu Renkleri"
color mtf1_fill_bullish = input.color(color.rgb(5, 90, 43), "MTF1 Yukselis Dolgu Rengi", group=mtf1ColorGroup, inline="mtf1fill")
color mtf1_fill_bearish = input.color(color.rgb(95, 7, 43), "MTF1 Dusus Dolgu Rengi", group=mtf1ColorGroup, inline="mtf1fill")
int mtf1_fill_transparency = input.int(95, "MTF1 Dolgu Saydamligi", minval=0, maxval=100, group=mtf1ColorGroup)

// ============================================
// ===== MTF2 DOLGU RENKLERI =====
// ============================================
mtf2ColorGroup = "MTF2 Dolgu Renkleri"
color mtf2_fill_bullish = input.color(color.rgb(0, 75, 65), "MTF2 Yukselis Dolgu Rengi", group=mtf2ColorGroup, inline="mtf2fill")
color mtf2_fill_bearish = input.color(color.rgb(117, 11, 15), "MTF2 Dusus Dolgu Rengi", group=mtf2ColorGroup, inline="mtf2fill")
int mtf2_fill_transparency = input.int(95, "MTF2 Dolgu Saydamligi", minval=0, maxval=100, group=mtf2ColorGroup)

// ============================================
// ===== LIQUIDITY SWINGS AYARLARI =====
// ============================================
liqGroup = "Liquidity Swings"
int pivotLength = input.int(30, "Pivot Lookback", group=liqGroup)
string swingArea = input.string("Wick Extremity", "Swing Area", options=["Wick Extremity", "Full Range"], group=liqGroup)
bool intraPrecision = input.bool(true, "Intrabar Precision", inline="intrabar", group=liqGroup)
string intrabarTf = input.timeframe("1", "", inline="intrabar", group=liqGroup)
string filterOptions = input.string("Count", "Filter Areas By", options=["Count", "Volume"], inline="filter", group=liqGroup)
float filterValue = input.float(0, "", inline="filter", group=liqGroup)

liqStyleGroup = "Liquidity Swings - Stil"
bool showSwingHigh = input.bool(true, "Swing High", inline="top", group=liqStyleGroup)
color topCss = input.color(color.red, "", inline="top", group=liqStyleGroup)
color topAreaCss = input.color(color.new(color.red, 50), "Area", inline="top", group=liqStyleGroup)

bool showSwingLow = input.bool(true, "Swing Low", inline="btm", group=liqStyleGroup)
color btmCss = input.color(color.teal, "", inline="btm", group=liqStyleGroup)
color btmAreaCss = input.color(color.new(color.teal, 50), "Area", inline="btm", group=liqStyleGroup)

string labelSize = input.string("Tiny", "Labels Size", options=["Tiny", "Small", "Normal"], group=liqStyleGroup)

// ============================================
// ===== TRAILING STOP (GORSEL) =====
// ============================================
tslGroup = "Trailing Stop (Gorsel)"
bool useTSL = input.bool(true, "TSL Cizgisi Goster", group=tslGroup)
float tslPct = input.float(0.75, "Trailing Stop %", minval=0.1, step=0.1, group=tslGroup) / 100
float tslActivationPct = input.float(0.75, "TSL Aktivasyon %", minval=0.1, step=0.1, group=tslGroup) / 100
float slPct = input.float(0.5, "Baslangic Sabit Stop %", minval=0.1, step=0.1, group=tslGroup) / 100

// ============================================
// ===== TRADE / SINYAL GOSTERIM =====
// ============================================
tradeGroup = "Sinyal Gosterimi"
bool showLongTrades = input.bool(true, "Long Sinyallerini Goster", group=tradeGroup)
bool showShortTrades = input.bool(true, "Short Sinyallerini Goster", group=tradeGroup)

// ============================================
// ===== VISUALIZATION =====
// ============================================
vizGroup = "Gorsellestirme"
showMTF1 = input.bool(false, "MTF1 SMA Goster", group=vizGroup)
showMTF2 = input.bool(true, "MTF2 SMA Goster", group=vizGroup)
showFill = input.bool(true, "Dolgu Goster", group=vizGroup)

// ============================================
// ===== TABLO AYARLARI =====
// ============================================
tableGroup = "Tablo Ayarlari"
string tablePos = input.string("Sag Ust", "Tablo Konumu", options=["Sag Ust", "Sag Alt", "Sol Ust", "Sol Alt", "Orta Ust", "Orta Alt"], group=tableGroup)
string tableSize = input.string("Normal", "Yazi Boyutu", options=["Tiny", "Small", "Normal", "Large"], group=tableGroup)
color tableTextColor = input.color(color.black, "Tablo Yazi Rengi", group=tableGroup)
color tableBgColor = input.color(color.new(color.black, 100), "Tablo Arka Plan (100=seffaf)", group=tableGroup)
color trendBuyColor = input.color(color.rgb(5, 45, 6), "Trend BUY / LONG Rengi", group=tableGroup, inline="trendcol")
color trendSellColor = input.color(color.red, "Trend SELL / SHORT Rengi", group=tableGroup, inline="trendcol")

// ============================================
// ===== MTF1 SMA HESAPLAMA =====
// ============================================
mtf1SmaShort = request.security(syminfo.tickerid, mtf1_tf, ta.sma(close, mtf1_short), barmerge.gaps_off, barmerge.lookahead_on)
mtf1SmaLong = request.security(syminfo.tickerid, mtf1_tf, ta.sma(close, mtf1_long), barmerge.gaps_off, barmerge.lookahead_on)
bool mtf1Bullish = mtf1SmaShort > mtf1SmaLong
bool mtf1Bearish = mtf1SmaShort < mtf1SmaLong
color mtf1TrendColor = mtf1Bullish ? mtf1_fill_bullish : mtf1Bearish ? mtf1_fill_bearish : color.gray

// ============================================
// ===== MTF2 SMA HESAPLAMA =====
// ============================================
mtf2SmaShort = request.security(syminfo.tickerid, mtf2_tf, ta.sma(close, mtf2_short), barmerge.gaps_off, barmerge.lookahead_on)
mtf2SmaLong = request.security(syminfo.tickerid, mtf2_tf, ta.sma(close, mtf2_long), barmerge.gaps_off, barmerge.lookahead_on)
bool mtf2Bullish = mtf2SmaShort > mtf2SmaLong
bool mtf2Bearish = mtf2SmaShort < mtf2SmaLong
color mtf2TrendColor = mtf2Bullish ? mtf2_fill_bullish : mtf2Bearish ? mtf2_fill_bearish : color.gray

// ============================================
// ===== MTF MAC (WAVETREND) HESAPLAMA =====
// ============================================
calcWT(int n1, int n2) =>
    ap = hlc3
    esa = ta.ema(ap, n1)
    d = ta.ema(math.abs(ap - esa), n1)
    ci = (ap - esa) / (0.015 * d)
    tci = ta.ema(ci, n2)
    wt1_val = tci
    wt2_val = ta.sma(wt1_val, 4)
    [wt1_val, wt2_val]

[macWt1, macWt2] = request.security(syminfo.tickerid, mac_tf, calcWT(mac_n1, mac_n2), barmerge.gaps_off, barmerge.lookahead_on)

bool macOkLong = not mac_on or macWt1 > 0
bool macOkShort = not mac_on or macWt1 < 0

// ============================================
// ===== PLOTTING - MTF1 =====
// ============================================
plot_mtf1Short = plot(showMTF1 and showMtf1Short ? mtf1SmaShort : na, "MTF1 SMA Kisa", color=mtf1TrendColor, linewidth=2)
plot_mtf1Long = plot(showMTF1 and showMtf1Long ? mtf1SmaLong : na, "MTF1 SMA Uzun", color=mtf1TrendColor, linewidth=2)
mtf1AreaColor = mtf1Bullish ? color.new(mtf1_fill_bullish, mtf1_fill_transparency) : mtf1Bearish ? color.new(mtf1_fill_bearish, mtf1_fill_transparency) : na
fill(plot_mtf1Short, plot_mtf1Long, color=showFill and showMtf1Short and showMtf1Long ? mtf1AreaColor : na, title="MTF1 Dolgu")

// ============================================
// ===== PLOTTING - MTF2 =====
// ============================================
plot_mtf2Short = plot(showMTF2 and showMtf2Short ? mtf2SmaShort : na, "MTF2 SMA Kisa", color=mtf2TrendColor, linewidth=1)
plot_mtf2Long = plot(showMTF2 and showMtf2Long ? mtf2SmaLong : na, "MTF2 SMA Uzun", color=mtf2TrendColor, linewidth=1)
mtf2AreaColor = mtf2Bullish ? color.new(mtf2_fill_bullish, mtf2_fill_transparency) : mtf2Bearish ? color.new(mtf2_fill_bearish, mtf2_fill_transparency) : na
fill(plot_mtf2Short, plot_mtf2Long, color=showFill and showMtf2Short and showMtf2Long ? mtf2AreaColor : na, title="MTF2 Dolgu")

// ============================================
// ===== SINYAL MANTIGI =====
// ============================================
bool bothBullish = mtf1Bullish and mtf2Bullish
bool bothBearish = mtf1Bearish and mtf2Bearish

bool mtf1CrossUp = mtf1Bullish and not mtf1Bullish[1]
bool mtf1CrossDown = mtf1Bearish and not mtf1Bearish[1]

bool mtf2CrossUp = mtf2Bullish and not mtf2Bullish[1]
bool mtf2CrossDown = mtf2Bearish and not mtf2Bearish[1]

bool rawSignalLong = mtf1CrossUp and mtf2Bullish
bool rawSignalShort = mtf1CrossDown and mtf2Bearish
bool alignLong = mtf1Bullish and mtf2CrossUp
bool alignShort = mtf1Bearish and mtf2CrossDown

bool finalLong = (rawSignalLong or alignLong) and macOkLong
bool finalShort = (rawSignalShort or alignShort) and macOkShort

// ============================================
// ===== UCGEN SINYALLER =====
// ============================================
plotshape(showLongTrades and finalLong, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small)
plotshape(showShortTrades and finalShort, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small)

// ============================================
// ===== LIQUIDITY SWINGS =====
// ============================================
n = bar_index

get_data() => [high, low, volume]
[h, l, v] = request.security_lower_tf(syminfo.tickerid, intrabarTf, get_data())

get_counts(condition, top, btm) =>
    var count = 0
    var vol = 0.
    if condition
        count := 0
        vol := 0.
    else
        if intraPrecision
            if n > pivotLength
                if array.size(v[pivotLength]) > 0
                    for [index, element] in v[pivotLength]
                        vol += array.get(l[pivotLength], index) < top and array.get(h[pivotLength], index) > btm ? element : 0
        else
            vol += low[pivotLength] < top and high[pivotLength] > btm ? volume[pivotLength] : 0
        count += low[pivotLength] < top and high[pivotLength] > btm ? 1 : 0
    [count, vol]

set_label(count, vol, x, y, css, lbl_style) =>
    var label lbl = na
    label_size_val = switch labelSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
    target = switch filterOptions
        "Count" => count
        "Volume" => vol
    if ta.crossover(target, filterValue)
        lbl := label.new(x, y, str.tostring(vol, format.volume), style=lbl_style, size=label_size_val, color=#00000000, textcolor=css)
    if target > filterValue
        label.set_text(lbl, str.tostring(vol, format.volume))

set_level(condition, crossed, value, count, vol, css) =>
    var line lvl = na
    target = switch filterOptions
        "Count" => count
        "Volume" => vol
    if condition
        if target[1] < filterValue[1]
            line.delete(lvl[1])
        else if not crossed[1]
            line.set_x2(lvl, n - pivotLength)
        lvl := line.new(n - pivotLength, value, n, value, color=na)
    if not crossed[1]
        line.set_x2(lvl, n + 3)
    if crossed and not crossed[1]
        line.set_x2(lvl, n)
        line.set_style(lvl, line.style_dashed)
    if target > filterValue
        line.set_color(lvl, css)

set_zone(condition, x, top, btm, count, vol, css) =>
    var box bx = na
    target = switch filterOptions
        "Count" => count
        "Volume" => vol
    if ta.crossover(target, filterValue)
        bx := box.new(x, top, x + count, btm, border_color=na, bgcolor=css)
    if target > filterValue
        box.set_right(bx, x + count)

// === PIVOT HIGH ===
var float ph_top = na
var float ph_btm = na
var bool ph_crossed = false
var int ph_x1 = 0
var box ph_bx = box.new(na, na, na, na, bgcolor=color.new(topAreaCss, 80), border_color=na)

ph = ta.pivothigh(pivotLength, pivotLength)
bool ph_found = not na(ph)
[ph_count, ph_vol] = get_counts(ph_found, ph_top, ph_btm)

if ph_found and showSwingHigh
    ph_top := high[pivotLength]
    ph_btm := switch swingArea
        "Wick Extremity" => math.max(close[pivotLength], open[pivotLength])
        "Full Range" => low[pivotLength]
    ph_x1 := n - pivotLength
    ph_crossed := false
    box.set_lefttop(ph_bx, ph_x1, ph_top)
    box.set_rightbottom(ph_bx, ph_x1, ph_btm)
else
    ph_crossed := close > ph_top ? true : ph_crossed
    if ph_crossed
        box.set_right(ph_bx, ph_x1)
    else
        box.set_right(ph_bx, n + 3)

if showSwingHigh
    set_zone(ph_found, ph_x1, ph_top, ph_btm, ph_count, ph_vol, topAreaCss)
    set_level(ph_found, ph_crossed, ph_top, ph_count, ph_vol, topCss)
    set_label(ph_count, ph_vol, ph_x1, ph_top, topCss, label.style_label_down)

// === PIVOT LOW ===
var float pl_top = na
var float pl_btm = na
var bool pl_crossed = false
var int pl_x1 = 0
var box pl_bx = box.new(na, na, na, na, bgcolor=color.new(btmAreaCss, 80), border_color=na)

pl = ta.pivotlow(pivotLength, pivotLength)
bool pl_found = not na(pl)
[pl_count, pl_vol] = get_counts(pl_found, pl_top, pl_btm)

if pl_found and showSwingLow
    pl_top := switch swingArea
        "Wick Extremity" => math.min(close[pivotLength], open[pivotLength])
        "Full Range" => high[pivotLength]
    pl_btm := low[pivotLength]
    pl_x1 := n - pivotLength
    pl_crossed := false
    box.set_lefttop(pl_bx, pl_x1, pl_top)
    box.set_rightbottom(pl_bx, pl_x1, pl_btm)
else
    pl_crossed := close < pl_btm ? true : pl_crossed
    if pl_crossed
        box.set_right(pl_bx, pl_x1)
    else
        box.set_right(pl_bx, n + 3)

if showSwingLow
    set_zone(pl_found, pl_x1, pl_top, pl_btm, pl_count, pl_vol, btmAreaCss)
    set_level(pl_found, pl_crossed, pl_btm, pl_count, pl_vol, btmCss)
    set_label(pl_count, pl_vol, pl_x1, pl_btm, btmCss, label.style_label_up)

// ============================================
// ===== TSL HESAPLAMASI VE GORSEL (POZISYON TAKIPLI) =====
// ============================================
var int   pos_dir = 0
var float entry_price = na
var float long_tsl_price = na
var float short_tsl_price = na
var bool active_trade_l = false
var bool active_trade_s = false

// Sadece YON DEGISIMINDE entry sifirlansin (aynı yonde tekrar sinyal gelirse dokunma)
if finalLong and pos_dir != 1
    pos_dir := 1
    entry_price := close
    long_tsl_price := na
    short_tsl_price := na
    active_trade_l := false
    active_trade_s := false

if finalShort and pos_dir != -1
    pos_dir := -1
    entry_price := close
    long_tsl_price := na
    short_tsl_price := na
    active_trade_l := false
    active_trade_s := false

// LONG TSL
if pos_dir == 1
    if high > entry_price * (1 + tslActivationPct)
        active_trade_l := true
    fixed_stop_l = entry_price * (1 - slPct)
    trail_stop_l = high * (1 - tslPct)
    if active_trade_l
        prev_valid_l = na(long_tsl_price) ? fixed_stop_l : long_tsl_price
        long_tsl_price := math.max(trail_stop_l, prev_valid_l)
    else
        long_tsl_price := fixed_stop_l
    short_tsl_price := na
    // TSL kirilma kontrolu: ONCEKI bar TSL degerine gore (ayni bar kapanmasin)
    if not na(long_tsl_price[1]) and low < long_tsl_price[1]
        pos_dir := 0
        long_tsl_price := na
        active_trade_l := false

// SHORT TSL
if pos_dir == -1
    if low < entry_price * (1 - tslActivationPct)
        active_trade_s := true
    fixed_stop_s = entry_price * (1 + slPct)
    trail_stop_s = low * (1 + tslPct)
    if active_trade_s
        prev_valid_s = na(short_tsl_price) ? fixed_stop_s : short_tsl_price
        short_tsl_price := math.min(trail_stop_s, prev_valid_s)
    else
        short_tsl_price := fixed_stop_s
    long_tsl_price := na
    if not na(short_tsl_price[1]) and high > short_tsl_price[1]
        pos_dir := 0
        short_tsl_price := na
        active_trade_s := false

plot(useTSL and pos_dir == 1 ? long_tsl_price : na, color=color.blue, style=plot.style_linebr, linewidth=1, title="Long TSL")
plot(useTSL and pos_dir == -1 ? short_tsl_price : na, color=color.fuchsia, style=plot.style_linebr, linewidth=1, title="Short TSL")

plotshape(ta.change(active_trade_l) and active_trade_l, "TSL Act L", shape.diamond, location.abovebar, color.blue, size=size.tiny, text="Karli", textcolor=color.blue)
plotshape(ta.change(active_trade_s) and active_trade_s, "TSL Act S", shape.diamond, location.belowbar, color.fuchsia, size=size.tiny, text="Karli", textcolor=color.fuchsia)

// ============================================
// ===== TABLO =====
// ============================================
getTimeframeName(string tf) =>
    string name = tf
    if tf == "M"
        name := "Aylik"
    else if tf == "W"
        name := "Haftalik"
    else if tf == "D"
        name := "Gunluk"
    else if tf == "720"
        name := "12S"
    else if tf == "360"
        name := "6S"
    else if tf == "240"
        name := "4S"
    else if tf == "180"
        name := "3S"
    else if tf == "120"
        name := "2S"
    else if tf == "60"
        name := "1S"
    else if tf == "30"
        name := "30D"
    else if tf == "15"
        name := "15D"
    else if tf == "10"
        name := "10D"
    else if tf == "5"
        name := "5D"
    else if tf == "3"
        name := "3D"
    else if tf == "1"
        name := "1D"
    name

txtSize = switch tableSize
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    => size.normal

var table trendTable = table.new(tablePos == "Sag Ust" ? position.top_right : tablePos == "Sag Alt" ? position.bottom_right : tablePos == "Sol Ust" ? position.top_left : tablePos == "Sol Alt" ? position.bottom_left : tablePos == "Orta Ust" ? position.top_center : position.bottom_center, columns=3, rows=4, bgcolor=tableBgColor, border_width=0, frame_width=0)

if barstate.islast
    table.cell(trendTable, 0, 0, "Zaman", text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 1, 0, "SMA", text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 2, 0, "Trend", text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 0, 1, "MTF1:" + getTimeframeName(mtf1_tf), text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 1, 1, str.tostring(mtf1_short) + "/" + str.tostring(mtf1_long), text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 2, 1, mtf1Bullish ? "BUY" : "SELL", text_color=mtf1Bullish ? trendBuyColor : trendSellColor, text_size=txtSize)
    table.cell(trendTable, 0, 2, "MTF2:" + getTimeframeName(mtf2_tf), text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 1, 2, str.tostring(mtf2_short) + "/" + str.tostring(mtf2_long), text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 2, 2, mtf2Bullish ? "BUY" : "SELL", text_color=mtf2Bullish ? trendBuyColor : trendSellColor, text_size=txtSize)
    string macTxt = mac_on ? "MAC:" + getTimeframeName(mac_tf) : "MAC:KAPALI"
    string macTrendTxt = not mac_on ? "-" : macWt1 > 0 ? "LONG" : "SHORT"
    color macTrendCol = not mac_on ? tableTextColor : macWt1 > 0 ? trendBuyColor : trendSellColor
    table.cell(trendTable, 0, 3, macTxt, text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 1, 3, str.tostring(macWt1, "#.##"), text_color=tableTextColor, text_size=txtSize)
    table.cell(trendTable, 2, 3, macTrendTxt, text_color=macTrendCol, text_size=txtSize)

// ============================================
// ===== ALERT =====
// ============================================
alertcondition(finalLong and showLongTrades, title="Long Signal", message="RizA_Ultra_v23 LONG")
alertcondition(finalShort and showShortTrades, title="Short Signal", message="RizA_Ultra_v23 SHORT")
````
