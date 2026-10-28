# Multi-Indicator Screener: 30 Assets

- url: https://www.tradingview.com/script/fRXnVB3Q-Multi-Indicator-Screener-30-Assets/
- type: indicator
- pine_id: PUB;5062ce9a17914caa81c10e33ae936d7b
- version: 1.0

## Description

🎯 Multi-Indicator Screener: 30 Assets

Catagories:
Stocks & ETFs (default), Cryptocurrency, Commodities, Global Indices, or Custom.

Indicators:
RSI, MACD, EMA Slope, OBV Trend, Supertrend, VWAP, ADX/DMI, BB %B, Stoch RSI, Vol Delta

[b]OVERVIEW[/b]
This indicator simultaneously monitors 30 customizable assets across a single chart panel, classifying each asset's momentum as Strong Bullish, Weak Bullish, Weak Bearish, or Strong Bearish — updated bar by bar. It does this across 10 selectable technical indicators, giving you a real-time breadth map of the entire market without switching charts.

Every asset is displayed as a horizontal color-coded zone stacked vertically, so you can read the mood of the full market in a single glance.

The screener is designed for traders who want to understand market-wide momentum — not just one symbol — so they can make higher-conviction decisions based on whether the broader market is confirming or diverging from their trade thesis.

[b]Asset Categories & Watchlists[/b]
The screener includes 4 built-in asset categories that you can switch between instantly: Stocks & ETFs (default), Cryptocurrency, Commodities, and Global Indices. Each category loads a carefully curated list of 30 relevant tickers with meaningful group breakdowns in the detailed table (e.g., Mega Cap / Large Cap for crypto, Energy / Precious Metals for commodities, USA / Europe / Asia for global indices). You can also select Custom mode to manually enter any 30 symbols you want to monitor. This makes the indicator extremely versatile whether you trade stocks, crypto, futures, or international markets.

THE 10 INDICATOR MODES
You select one active indicator from the settings panel. That indicator is applied identically to all 30 assets simultaneously. The following describes exactly how each indicator classifies an asset into its four states:

RSI (Relative Strength Index)
The RSI is calculated using a user-defined length (default: 14 periods) and then compared against its own Simple Moving Average (default: 14-period SMA of the RSI).
Strong Bull — RSI is above both the 50 midline and its SMA
Weak Bull — RSI is above only one of those conditions
Strong Bear — RSI is below both the 50 midline and its SMA
Weak Bear — RSI is below only one of those conditions
This two-condition filter removes many of the false signals that a raw RSI threshold produces.

MACD (Moving Average Convergence Divergence)
Uses the standard MACD histogram (default 12/26/9).
Strong Bull — histogram is positive and increasing bar-over-bar (accelerating bullish momentum)
Weak Bull — histogram is positive but flat or declining
Strong Bear — histogram is negative and decreasing bar-over-bar (accelerating bearish momentum)
Weak Bear — histogram is negative but flat or recovering
The directional change of the histogram is the key differentiator here.

EMA Slope
Calculates a 20-period EMA and measures the actual geometric slope angle (in degrees), normalized against the asset’s 200-bar price range.
Formula: atan(ema_change / (pts_per_bar × slope_period)) × 180 / π
Strong Bull — slope angle ≥ Reference Angle (default: 45°)
Weak Bull — slope angle positive but below the threshold
Strong Bear — slope angle ≤ -Reference Angle
Weak Bear — slope angle negative but above the negative threshold
Tip: The default 45° is aggressive. Lower it to 10–15° for more frequent Strong signals. Includes division-by-zero protection for flat markets.

OBV Trend (On-Balance Volume)
Applies short and long moving averages to raw OBV (default Short=2, Long=14). MA type is user-selectable (SMA, EMA, SMMA, WMA, VWMA).
Strong Bull — short OBV MA > long OBV MA and long MA is rising
Weak Bull — short > long, but long MA is flat or declining
Strong Bear — short < long and long MA is declining
Weak Bear — short < long, but long MA is flat or rising
Pure volume-flow based momentum detection.

Supertrend
Uses Pine’s built-in Supertrend (default Factor=3.0, ATR Length=10).
Strong Bull — price above Supertrend line and rising (moving away)
Weak Bull — price above line but falling (drifting toward it)
Strong Bear — price below line and falling
Weak Bear — price below line but rising

VWAP (Volume Weighted Average Price)
Uses session VWAP (resets daily).
Best on intraday charts (1min–4H). On daily+ charts it only reflects that session’s VWAP.
Strong Bull — price > VWAP and rising
Weak Bull — price > VWAP but falling
Strong Bear — price < VWAP and falling
Weak Bear — price < VWAP but rising

ADX / DMI
Manual Wilder's calculation for independent ADX per asset (default threshold 25).
Strong Bull — +DI > -DI and ADX ≥ 25
Weak Bull — +DI > -DI but ADX < 25
Strong Bear — -DI > +DI and ADX ≥ 25
Weak Bear — -DI > +DI but ADX < 25

BB %B (Bollinger Band Percent B)
Shows where price sits inside the Bollinger Bands (default 20,2).
Strong Bull — %B ≥ 1.0 (above upper band)
Weak Bull — %B between 0.5 and 1.0
Strong Bear — %B ≤ 0.0 (below lower band)
Weak Bear — %B between 0.0 and 0.5

Stochastic RSI
Stochastic applied to RSI (defaults: RSI 14, Stoch 14, Smooth K=3, D=3).
Strong Bull — K > D and K > 50
Weak Bull — K > D or K > 50
Strong Bear — K < D and K < 50
Weak Bear — K < D or K < 50

Vol Delta
A bar-level volume delta approximation: normalized delta = (2×close − high − low) / (high − low). This value is smoothed with an EMA (default length 3) and ranges roughly from -1 to +1.
Strong Bull — smoothed delta > threshold (default 0.3) and accelerating upward
Weak Bull — smoothed delta > 0 but below threshold or decelerating
Strong Bear — smoothed delta < -threshold and accelerating downward
Weak Bear — smoothed delta < 0 but above -threshold or decelerating
This mode approximates institutional buying/selling pressure within each bar and becomes more accurate on higher-resolution charts.

THE VISUAL SYSTEM

Stacked Zone Layout: 30 horizontal step-lines with adjustable height and gap.
Streak-Based Color Intensity: Color strength reflects how many consecutive closed bars an asset has stayed in its current state.
4 Color Palettes: Classic, Colorblind Safe, Ice & Fire, Monochrome.
3 Color Styles: Standard, Traffic Light, Hue Shift.
Divergence Highlighting: Assets moving against the overall market are highlighted in gold (solid for strong, semi-transparent for weak).
Total Market Line: Thick line at the top showing aggregate market momentum.
Dashboard Table: Momentum score (0–100), market status (including true “MIXED”), counts with delta arrows, and optional detailed sector/group breakdown.
Mini Heatmap: Compact 30-cell color strip at the bottom with ticker labels.

ALERTS
Four configurable alerts (all individually togglable):

Strong Bullish momentum (minimum number of assets)
Strong Bearish momentum
Market sentiment shift
Extreme conditions (≥60% assets in Strong Bull or Strong Bear)

Alerts fire only on confirmed bars.
DEFAULT ASSETS
The built-in presets include Stocks & ETFs (default), Cryptocurrency, Commodities, and Global Indices. In “Stocks & ETFs” mode you get a balanced mix of broad market, sectors, Magnificent 7, key stocks, thematic, and macro assets. All 30 tickers are fully customizable.
INTENDED USE
This is a market breadth and momentum classification tool, not a direct signal generator. Use it to:

Confirm broad market support for your trade direction
Spot early sector rotation
Identify diverging assets
Compare how different indicators are reading the same market
Time entries/exits based on momentum score and delta changes

Works on any timeframe. For best results with VWAP and Vol Delta, prefer intraday charts.

## Source Code

````pine
//@version=6
indicator("📊 Multi-Indicator Screener: 30 Assets", overlay=false, max_bars_back=2000)

// ═══════════════════════════════════════════════════
// ASSET PRESET
// ═══════════════════════════════════════════════════
asset_preset = input.string("Stocks & ETFs", title="Asset Preset",
    options=["Stocks & ETFs", "Cryptocurrency", "Commodities", "Global Indices", "Custom"],
    group="Asset Preset",
    tooltip="Switch between built-in watchlists. Select 'Custom' to manually define all 30 tickers in the Custom Assets group below.")

// ═══════════════════════════════════════════════════
// INDICATOR SELECTION — 10 modes
// ═══════════════════════════════════════════════════
selected_indicator = input.string("RSI", title="Active Indicator",
    options=["RSI", "MACD", "EMA Slope", "OBV Trend", "Supertrend", "VWAP", "ADX/DMI", "BB %B", "Stoch RSI", "Vol Delta"],
    group="Indicator Selection",
    tooltip="VWAP resets per session — most meaningful on intraday charts. On daily charts it reflects that bar's session VWAP only.")

// ═══════════════════════════════════════════════════
// RSI SETTINGS
// ═══════════════════════════════════════════════════
rsi_length  = input.int(14, title="RSI Length",     minval=1, group="RSI Settings")
rsi_sma_len = input.int(14, title="RSI SMA Length", minval=1, group="RSI Settings")

// ═══════════════════════════════════════════════════
// MACD SETTINGS
// ═══════════════════════════════════════════════════
fast_length   = input.int(12, title="Fast Length",   minval=1, group="MACD Settings")
slow_length   = input.int(26, title="Slow Length",   minval=1, group="MACD Settings")
signal_length = input.int(9,  title="Signal Length", minval=1, group="MACD Settings")

// ═══════════════════════════════════════════════════
// EMA SLOPE SETTINGS
// ═══════════════════════════════════════════════════
ema_length      = input.int(20,   title="EMA Length",               minval=1,            group="EMA Slope Settings")
slope_period    = input.int(5,    title="Slope Calculation Period",  minval=1,            group="EMA Slope Settings")
reference_angle = input.float(45, title="Reference Angle (degrees)", minval=0, maxval=90, group="EMA Slope Settings",
    tooltip="Angle required for a Strong Bull/Bear classification. Default 45° is high — try 10–15° for more active signals.")

// ═══════════════════════════════════════════════════
// OBV TREND SETTINGS
// ═══════════════════════════════════════════════════
typeMA               = input.string("SMA", title="OBV MA Method",  options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="OBV Trend Settings")
smoothingLengthShort = input.int(2,  title="OBV Length Short", minval=1, maxval=100, group="OBV Trend Settings")
smoothingLengthLong  = input.int(14, title="OBV Length Long",  minval=1, maxval=100, group="OBV Trend Settings")

// ═══════════════════════════════════════════════════
// SUPERTREND SETTINGS
// Strong Bull/Bear = above/below ST line + price moving away from it
// Weak Bull/Bear   = above/below ST line + price moving toward it
// ═══════════════════════════════════════════════════
st_factor     = input.float(3.0, title="Factor",     minval=0.01, step=0.01, group="Supertrend Settings")
st_atr_length = input.int(10,   title="ATR Length",  minval=1,               group="Supertrend Settings")

// ═══════════════════════════════════════════════════
// ADX/DMI SETTINGS
// Strong Bull/Bear = +DI/-DI dominant AND ADX above threshold
// Weak Bull/Bear   = +DI/-DI dominant AND ADX below threshold
// ═══════════════════════════════════════════════════
adx_di_length = input.int(14,   title="DI Length",              minval=1,             group="ADX/DMI Settings")
adx_smoothing = input.int(14,   title="ADX Smoothing",          minval=1,             group="ADX/DMI Settings")
adx_threshold = input.float(25, title="Strong Trend Threshold", minval=1, maxval=100, group="ADX/DMI Settings",
    tooltip="ADX above this value = strong trend (strong bull or bear). Wilder's standard is 25.")

// ═══════════════════════════════════════════════════
// BB %B SETTINGS
// Strong Bull = above upper band (%B ≥ 1.0)  Weak Bull = upper half (%B 0.5–1.0)
// Strong Bear = below lower band (%B ≤ 0.0)  Weak Bear = lower half (%B 0.0–0.5)
// ═══════════════════════════════════════════════════
bb_length = input.int(20,    title="BB Length",             minval=1,            group="BB %B Settings")
bb_mult   = input.float(2.0, title="BB Std Dev Multiplier", minval=0.1, step=0.1, group="BB %B Settings")

// ═══════════════════════════════════════════════════
// STOCH RSI SETTINGS
// Strong Bull/Bear = K crosses D AND both above/below 50
// Weak Bull/Bear   = K above/below D or above/below 50 (one condition only)
// ═══════════════════════════════════════════════════
srsi_rsi_len   = input.int(14, title="RSI Length",   minval=1, group="Stoch RSI Settings")
srsi_stoch_len = input.int(14, title="Stoch Length", minval=1, group="Stoch RSI Settings")
srsi_smooth_k  = input.int(3,  title="Smooth K",     minval=1, group="Stoch RSI Settings")
srsi_smooth_d  = input.int(3,  title="Smooth D",     minval=1, group="Stoch RSI Settings")

// ═══════════════════════════════════════════════════
// VOL DELTA SETTINGS
// Uses bar-level approximation: norm = (2×close − high − low) / (high − low)
// Maps close position within the bar to [-1, +1] — equivalent to LuxAlgo's
// LTF method as timeframe resolution increases.
// Strong Bull/Bear = smoothed norm beyond threshold AND momentum accelerating
// Weak Bull/Bear   = smoothed norm positive/negative but below threshold or decelerating
// ═══════════════════════════════════════════════════
vd_smooth    = input.int(3,     title="Smooth Length",    minval=1,                       group="Vol Delta Settings",
    tooltip="EMA periods applied to the normalized per-bar delta. Lower = more reactive, higher = smoother.")
vd_threshold = input.float(0.3, title="Strong Threshold", minval=0.0, maxval=1.0, step=0.05, group="Vol Delta Settings",
    tooltip="Normalized delta threshold (0–1) for Strong Bull/Bear classification. Default 0.3 — try 0.2 for more signals, 0.4 for fewer.")

// ═══════════════════════════════════════════════════
// COLOR SETTINGS
// ═══════════════════════════════════════════════════
color_palette   = input.string("Classic",   title="Color Palette", options=["Classic", "Colorblind Safe", "Ice & Fire", "Monochrome"], group="Color Settings", tooltip="Classic=Green/Red | Colorblind Safe=Blue/Orange | Ice & Fire=Cyan/Magenta | Monochrome=Warm tint=Bull, Cool tint=Bear")
color_style     = input.string("Hue Shift", title="Color Style",   options=["Standard", "Traffic Light", "Hue Shift"],                group="Color Settings", tooltip="Standard=intensity fades with age | Traffic Light=3 brightness tiers | Hue Shift=color changes with age")
show_divergence = input.bool(true,          title="Highlight Divergence in Gold",       group="Color Settings", tooltip="Gold highlight = strong signal moving against the overall market direction")
trad_intensity  = input.bool(false,         title="Traditional Intensity (Dim→Bright)", group="Color Settings", tooltip="Standard style only: new signals bright by default. Enable to start dim and brighten with age.")

// ═══════════════════════════════════════════════════
// DISPLAY SETTINGS
// ═══════════════════════════════════════════════════
show_labels  = input.bool(true,         title="Show Labels",            group="Display Settings")
zone_height  = input.float(8.0,         title="Zone Height",            group="Display Settings")
zone_gap     = input.float(3.0,         title="Zone Gap",               group="Display Settings")
max_streak   = input.int(20,            title="Max Streak Length",      minval=1, maxval=50, group="Display Settings")
show_total   = input.bool(true,         title="Show Total Market Line", group="Display Settings")
table_style  = input.string("Detailed", title="Table Style",            options=["Standard", "Detailed"], group="Display Settings", tooltip="Detailed adds group breakdown, momentum score, and delta indicators")
show_heatmap = input.bool(true,         title="Show Mini Heatmap",      group="Display Settings", tooltip="30-asset color strip at the bottom of the chart")

// ═══════════════════════════════════════════════════
// ALERT SETTINGS
// ═══════════════════════════════════════════════════
enable_alerts = input.bool(true, title="Enable Alerts",                    group="Alert Settings")
alert_bull    = input.bool(true, title="Alert on Strong Bullish Momentum", group="Alert Settings")
alert_bear    = input.bool(true, title="Alert on Strong Bearish Momentum", group="Alert Settings")
alert_shift   = input.bool(true, title="Alert on Market Sentiment Shift",  group="Alert Settings")
min_for_alert = input.int(5,     title="Minimum Assets for Alert", minval=1, maxval=15, group="Alert Settings")

// ═══════════════════════════════════════════════════
// CUSTOM TICKER INPUTS
// Only active when Asset Preset = "Custom"
// ═══════════════════════════════════════════════════
ticker1  = input.symbol("AMEX:SPY",     title="Ticker 1",  group="Custom Assets", tooltip="Only used when Asset Preset = Custom")
ticker2  = input.symbol("NASDAQ:QQQ",   title="Ticker 2",  group="Custom Assets")
ticker3  = input.symbol("AMEX:DIA",     title="Ticker 3",  group="Custom Assets")
ticker4  = input.symbol("AMEX:IWM",     title="Ticker 4",  group="Custom Assets")
ticker5  = input.symbol("AMEX:XLK",     title="Ticker 5",  group="Custom Assets")
ticker6  = input.symbol("AMEX:XLF",     title="Ticker 6",  group="Custom Assets")
ticker7  = input.symbol("AMEX:XLE",     title="Ticker 7",  group="Custom Assets")
ticker8  = input.symbol("AMEX:XLV",     title="Ticker 8",  group="Custom Assets")
ticker9  = input.symbol("AMEX:XLY",     title="Ticker 9",  group="Custom Assets")
ticker10 = input.symbol("AMEX:XLC",     title="Ticker 10", group="Custom Assets")
ticker11 = input.symbol("NASDAQ:NVDA",  title="Ticker 11", group="Custom Assets")
ticker12 = input.symbol("NASDAQ:AAPL",  title="Ticker 12", group="Custom Assets")
ticker13 = input.symbol("NASDAQ:MSFT",  title="Ticker 13", group="Custom Assets")
ticker14 = input.symbol("NASDAQ:TSLA",  title="Ticker 14", group="Custom Assets")
ticker15 = input.symbol("NASDAQ:META",  title="Ticker 15", group="Custom Assets")
ticker16 = input.symbol("NASDAQ:AMZN",  title="Ticker 16", group="Custom Assets")
ticker17 = input.symbol("NASDAQ:GOOGL", title="Ticker 17", group="Custom Assets")
ticker18 = input.symbol("NYSE:JPM",     title="Ticker 18", group="Custom Assets")
ticker19 = input.symbol("NYSE:XOM",     title="Ticker 19", group="Custom Assets")
ticker20 = input.symbol("NASDAQ:AVGO",  title="Ticker 20", group="Custom Assets")
ticker21 = input.symbol("NASDAQ:AMD",   title="Ticker 21", group="Custom Assets")
ticker22 = input.symbol("NYSE:GS",      title="Ticker 22", group="Custom Assets")
ticker23 = input.symbol("NASDAQ:SOXX",  title="Ticker 23", group="Custom Assets")
ticker24 = input.symbol("AMEX:ARKK",    title="Ticker 24", group="Custom Assets")
ticker25 = input.symbol("AMEX:GLD",     title="Ticker 25", group="Custom Assets")
ticker26 = input.symbol("NASDAQ:TLT",   title="Ticker 26", group="Custom Assets")
ticker27 = input.symbol("AMEX:HYG",     title="Ticker 27", group="Custom Assets")
ticker28 = input.symbol("AMEX:USO",     title="Ticker 28", group="Custom Assets")
ticker29 = input.symbol("AMEX:UUP",     title="Ticker 29", group="Custom Assets")
ticker30 = input.symbol("AMEX:EEM",     title="Ticker 30", group="Custom Assets")

// ═══════════════════════════════════════════════════
// SYMBOL RESOLUTION
// Each slot resolves to the correct symbol for the active preset.
// ─────────────────────────────────────────────────
// STOCKS & ETFs (default):
//   Broad Market (0–3):  SPY  QQQ  DIA  IWM
//   Sectors      (4–9):  XLK  XLF  XLE  XLV  XLY  XLC
//   Magnificent 7 (10–16): NVDA AAPL MSFT TSLA META AMZN GOOGL
//   Key Stocks   (17–21): JPM  XOM  AVGO AMD  GS
//   Thematic     (22–23): SOXX ARKK
//   Macro        (24–29): GLD  TLT  HYG  USO  UUP  EEM
// ─────────────────────────────────────────────────
// CRYPTOCURRENCY (Binance USDT pairs — no stablecoins, no bridged tokens):
//   Mega Cap     (0–3):  BTC  ETH  SOL  BNB
//   Large Cap    (4–9):  XRP  ADA  AVAX DOT  LINK LTC
//   DeFi / L2    (10–16): UNI ATOM AAVE NEAR INJ  ARB  OP
//   New L1s      (17–21): SUI  APT  TON  FIL  VET
//   Meme         (22–23): DOGE SHIB
//   Alt Layer 1  (24–29): TRX  ICP  ALGO HBAR ETC  XLM
// ─────────────────────────────────────────────────
// COMMODITIES (futures + ETFs for volume coverage):
//   Energy       (0–3):  CL1! NG1! RB1! HO1!
//   Prec. Metals (4–9):  GC1! SI1! PL1! PA1! GLD  SLV
//   Base/Broad   (10–16): HG1! CPER DBB  USO  UNG  DBA  PDBC
//   Grains       (17–21): ZW1! ZC1! ZS1! ZL1! ZM1!
//   Softs I      (22–23): SB1! KC1!
//   Softs II+Lvk (24–29): CC1! CT1! OJ1! LE1! LH1! GF1!
// ─────────────────────────────────────────────────
// GLOBAL INDICES (country ETFs — all NYSE Arca = AMEX in TradingView):
//   USA          (0–3):  SPY  QQQ  DIA  IWM
//   Europe       (4–9):  EWG  EWU  EWQ  EWI  EWP  EWL
//   Asia Pacific (10–16): EWJ FXI  EWY  EWA  EWT  INDA EWS
//   Americas     (17–21): EWZ EWW  EWC  EEM  VEA
//   Global Broad (22–23): EFA EWN
//   Frontier     (24–29): ARGT EWM THD EIDO GXC EZA
// ═══════════════════════════════════════════════════

sym1  = asset_preset == "Cryptocurrency" ? "BINANCE:BTCUSDT"  : asset_preset == "Commodities" ? "NYMEX:CL1!"   : asset_preset == "Global Indices" ? "AMEX:SPY"    : asset_preset == "Custom" ? ticker1  : "AMEX:SPY"
sym2  = asset_preset == "Cryptocurrency" ? "BINANCE:ETHUSDT"  : asset_preset == "Commodities" ? "NYMEX:NG1!"   : asset_preset == "Global Indices" ? "NASDAQ:QQQ"  : asset_preset == "Custom" ? ticker2  : "NASDAQ:QQQ"
sym3  = asset_preset == "Cryptocurrency" ? "BINANCE:SOLUSDT"  : asset_preset == "Commodities" ? "NYMEX:RB1!"   : asset_preset == "Global Indices" ? "AMEX:DIA"    : asset_preset == "Custom" ? ticker3  : "AMEX:DIA"
sym4  = asset_preset == "Cryptocurrency" ? "BINANCE:BNBUSDT"  : asset_preset == "Commodities" ? "NYMEX:HO1!"   : asset_preset == "Global Indices" ? "AMEX:IWM"    : asset_preset == "Custom" ? ticker4  : "AMEX:IWM"
sym5  = asset_preset == "Cryptocurrency" ? "BINANCE:XRPUSDT"  : asset_preset == "Commodities" ? "COMEX:GC1!"   : asset_preset == "Global Indices" ? "AMEX:EWG"    : asset_preset == "Custom" ? ticker5  : "AMEX:XLK"
sym6  = asset_preset == "Cryptocurrency" ? "BINANCE:ADAUSDT"  : asset_preset == "Commodities" ? "COMEX:SI1!"   : asset_preset == "Global Indices" ? "AMEX:EWU"    : asset_preset == "Custom" ? ticker6  : "AMEX:XLF"
sym7  = asset_preset == "Cryptocurrency" ? "BINANCE:AVAXUSDT" : asset_preset == "Commodities" ? "NYMEX:PL1!"   : asset_preset == "Global Indices" ? "AMEX:EWQ"    : asset_preset == "Custom" ? ticker7  : "AMEX:XLE"
sym8  = asset_preset == "Cryptocurrency" ? "BINANCE:DOTUSDT"  : asset_preset == "Commodities" ? "NYMEX:PA1!"   : asset_preset == "Global Indices" ? "AMEX:EWI"    : asset_preset == "Custom" ? ticker8  : "AMEX:XLV"
sym9  = asset_preset == "Cryptocurrency" ? "BINANCE:LINKUSDT" : asset_preset == "Commodities" ? "AMEX:GLD"     : asset_preset == "Global Indices" ? "AMEX:EWP"    : asset_preset == "Custom" ? ticker9  : "AMEX:XLY"
sym10 = asset_preset == "Cryptocurrency" ? "BINANCE:LTCUSDT"  : asset_preset == "Commodities" ? "AMEX:SLV"     : asset_preset == "Global Indices" ? "AMEX:EWL"    : asset_preset == "Custom" ? ticker10 : "AMEX:XLC"
sym11 = asset_preset == "Cryptocurrency" ? "BINANCE:UNIUSDT"  : asset_preset == "Commodities" ? "COMEX:HG1!"   : asset_preset == "Global Indices" ? "AMEX:EWJ"    : asset_preset == "Custom" ? ticker11 : "NASDAQ:NVDA"
sym12 = asset_preset == "Cryptocurrency" ? "BINANCE:ATOMUSDT" : asset_preset == "Commodities" ? "AMEX:CPER"    : asset_preset == "Global Indices" ? "AMEX:FXI"    : asset_preset == "Custom" ? ticker12 : "NASDAQ:AAPL"
sym13 = asset_preset == "Cryptocurrency" ? "BINANCE:AAVEUSDT" : asset_preset == "Commodities" ? "AMEX:DBB"     : asset_preset == "Global Indices" ? "AMEX:EWY"    : asset_preset == "Custom" ? ticker13 : "NASDAQ:MSFT"
sym14 = asset_preset == "Cryptocurrency" ? "BINANCE:NEARUSDT" : asset_preset == "Commodities" ? "AMEX:USO"     : asset_preset == "Global Indices" ? "AMEX:EWA"    : asset_preset == "Custom" ? ticker14 : "NASDAQ:TSLA"
sym15 = asset_preset == "Cryptocurrency" ? "BINANCE:INJUSDT"  : asset_preset == "Commodities" ? "AMEX:UNG"     : asset_preset == "Global Indices" ? "AMEX:EWT"    : asset_preset == "Custom" ? ticker15 : "NASDAQ:META"
sym16 = asset_preset == "Cryptocurrency" ? "BINANCE:ARBUSDT"  : asset_preset == "Commodities" ? "AMEX:DBA"     : asset_preset == "Global Indices" ? "AMEX:INDA"   : asset_preset == "Custom" ? ticker16 : "NASDAQ:AMZN"
sym17 = asset_preset == "Cryptocurrency" ? "BINANCE:OPUSDT"   : asset_preset == "Commodities" ? "NASDAQ:PDBC"  : asset_preset == "Global Indices" ? "AMEX:EWS"    : asset_preset == "Custom" ? ticker17 : "NASDAQ:GOOGL"
sym18 = asset_preset == "Cryptocurrency" ? "BINANCE:SUIUSDT"  : asset_preset == "Commodities" ? "CBOT:ZW1!"    : asset_preset == "Global Indices" ? "AMEX:EWZ"    : asset_preset == "Custom" ? ticker18 : "NYSE:JPM"
sym19 = asset_preset == "Cryptocurrency" ? "BINANCE:APTUSDT"  : asset_preset == "Commodities" ? "CBOT:ZC1!"    : asset_preset == "Global Indices" ? "AMEX:EWW"    : asset_preset == "Custom" ? ticker19 : "NYSE:XOM"
sym20 = asset_preset == "Cryptocurrency" ? "BINANCE:TONUSDT"  : asset_preset == "Commodities" ? "CBOT:ZS1!"    : asset_preset == "Global Indices" ? "AMEX:EWC"    : asset_preset == "Custom" ? ticker20 : "NASDAQ:AVGO"
sym21 = asset_preset == "Cryptocurrency" ? "BINANCE:DOGEUSDT" : asset_preset == "Commodities" ? "CBOT:ZL1!"    : asset_preset == "Global Indices" ? "AMEX:EEM"    : asset_preset == "Custom" ? ticker21 : "NASDAQ:AMD"
sym22 = asset_preset == "Cryptocurrency" ? "BINANCE:SHIBUSDT" : asset_preset == "Commodities" ? "CBOT:ZM1!"    : asset_preset == "Global Indices" ? "AMEX:VEA"    : asset_preset == "Custom" ? ticker22 : "NYSE:GS"
sym23 = asset_preset == "Cryptocurrency" ? "BINANCE:TRXUSDT"  : asset_preset == "Commodities" ? "ICEUS:SB1!"   : asset_preset == "Global Indices" ? "AMEX:EFA"    : asset_preset == "Custom" ? ticker23 : "NASDAQ:SOXX"
sym24 = asset_preset == "Cryptocurrency" ? "BINANCE:FILUSDT"  : asset_preset == "Commodities" ? "ICEUS:KC1!"   : asset_preset == "Global Indices" ? "AMEX:EWN"    : asset_preset == "Custom" ? ticker24 : "AMEX:ARKK"
sym25 = asset_preset == "Cryptocurrency" ? "BINANCE:VETUSDT"  : asset_preset == "Commodities" ? "ICEUS:CC1!"   : asset_preset == "Global Indices" ? "AMEX:ARGT"   : asset_preset == "Custom" ? ticker25 : "AMEX:GLD"
sym26 = asset_preset == "Cryptocurrency" ? "BINANCE:ICPUSDT"  : asset_preset == "Commodities" ? "ICEUS:CT1!"   : asset_preset == "Global Indices" ? "AMEX:EWM"    : asset_preset == "Custom" ? ticker26 : "NASDAQ:TLT"
sym27 = asset_preset == "Cryptocurrency" ? "BINANCE:ALGOUSDT" : asset_preset == "Commodities" ? "ICEUS:OJ1!"   : asset_preset == "Global Indices" ? "AMEX:THD"    : asset_preset == "Custom" ? ticker27 : "AMEX:HYG"
sym28 = asset_preset == "Cryptocurrency" ? "BINANCE:HBARUSDT" : asset_preset == "Commodities" ? "CME:LE1!"     : asset_preset == "Global Indices" ? "AMEX:EIDO"   : asset_preset == "Custom" ? ticker28 : "AMEX:USO"
sym29 = asset_preset == "Cryptocurrency" ? "BINANCE:ETCUSDT"  : asset_preset == "Commodities" ? "CME:HE1!"     : asset_preset == "Global Indices" ? "AMEX:GXC"    : asset_preset == "Custom" ? ticker29 : "AMEX:UUP"
sym30 = asset_preset == "Cryptocurrency" ? "BINANCE:XLMUSDT"  : asset_preset == "Commodities" ? "CME:GF1!"     : asset_preset == "Global Indices" ? "AMEX:EZA"    : asset_preset == "Custom" ? ticker30 : "AMEX:EEM"

// ═══════════════════════════════════════════════════
// TICKER ARRAY — rebuilt every bar so labels always
// match the currently active preset.
// ═══════════════════════════════════════════════════
string[] tickers = array.from(
    sym1,  sym2,  sym3,  sym4,  sym5,
    sym6,  sym7,  sym8,  sym9,  sym10,
    sym11, sym12, sym13, sym14, sym15,
    sym16, sym17, sym18, sym19, sym20,
    sym21, sym22, sym23, sym24, sym25,
    sym26, sym27, sym28, sym29, sym30)

// ═══════════════════════════════════════════════════
// GROUP LABELS — dynamic per preset, aligned to the
// fixed sector-breakdown index ranges (0-3, 4-9, 10-16,
// 17-21, 22-23, 24-29) used in the Detailed table.
// ═══════════════════════════════════════════════════
grp1_label = asset_preset == "Cryptocurrency" ? "Mega Cap   " : asset_preset == "Commodities" ? "Energy     " : asset_preset == "Global Indices" ? "USA        " : "Broad Mkt  "
grp2_label = asset_preset == "Cryptocurrency" ? "Large Cap  " : asset_preset == "Commodities" ? "Prec.Metal " : asset_preset == "Global Indices" ? "Europe     " : "Sectors    "
grp3_label = asset_preset == "Cryptocurrency" ? "DeFi / L2  " : asset_preset == "Commodities" ? "Base/Broad " : asset_preset == "Global Indices" ? "Asia Pac.  " : "Mag 7      "
grp4_label = asset_preset == "Cryptocurrency" ? "New L1s    " : asset_preset == "Commodities" ? "Grains     " : asset_preset == "Global Indices" ? "Americas   " : "Key Stocks "
grp5_label = asset_preset == "Cryptocurrency" ? "Meme       " : asset_preset == "Commodities" ? "Softs I    " : asset_preset == "Global Indices" ? "Global Brd " : "Thematic   "
grp6_label = asset_preset == "Cryptocurrency" ? "Alt L1s    " : asset_preset == "Commodities" ? "Softs+Lvsk " : asset_preset == "Global Indices" ? "Frontier   " : "Macro      "

// ═══════════════════════════════════════════════════
// UTILITY FUNCTIONS
// getName: strips exchange prefix and, for Binance
// crypto pairs, removes the USDT suffix so labels
// display "BTC" not "BTCUSDT".
// ═══════════════════════════════════════════════════
getName(t) =>
    parts = str.split(t, ":")
    raw   = array.size(parts) >= 2 ? array.get(parts, 1) : t
    str.endswith(raw, "USDT") ? str.substring(raw, 0, str.length(raw) - 4) : raw

ma(source, length, type) =>
    switch type
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)

deltaStr(d) =>
    d > 0 ? " ▲" + str.tostring(d) : d < 0 ? " ▼" + str.tostring(math.abs(d)) : ""

sectorColor(b, r) =>
    b > r ? color.rgb(0, 180, 0) : r > b ? color.rgb(200, 0, 0) : color.gray

sectorDots(states, from_i, to_i) =>
    s = ""
    for i = from_i to to_i
        st = array.get(states, i)
        s += st == "strong_bull" ? "🟢" : st == "weak_bull" ? "🔵" : st == "strong_bear" ? "🔴" : st == "weak_bear" ? "🟠" : "⬜"
    s

sectorBull(states, from_i, to_i) =>
    n = 0
    for i = from_i to to_i
        st = array.get(states, i)
        if st == "strong_bull" or st == "weak_bull"
            n += 1
    n

sectorBear(states, from_i, to_i) =>
    n = 0
    for i = from_i to to_i
        st = array.get(states, i)
        if st == "strong_bear" or st == "weak_bear"
            n += 1
    n

calcMomentum(states) =>
    raw = 0.0
    for i = 0 to 29
        st   = array.get(states, i)
        raw += st == "strong_bull" ? 2.0 : st == "weak_bull" ? 1.0 : st == "weak_bear" ? -1.0 : st == "strong_bear" ? -2.0 : 0.0
    math.round((raw + 60.0) / 120.0 * 100.0)

// ═══════════════════════════════════════════════════
// SUPERTREND HELPER FUNCTIONS
// ═══════════════════════════════════════════════════
f_st_line() =>
    [line, dir] = ta.supertrend(st_factor, st_atr_length)
    line

f_st_dir() =>
    [line, dir] = ta.supertrend(st_factor, st_atr_length)
    dir

// ═══════════════════════════════════════════════════
// MANUAL ADX/DMI CALCULATION
// Wilder's formula from fetched h/l/c; ta.rma keeps
// independent state per unique series so each ticker
// gets its own ADX without extra request.security calls.
// ═══════════════════════════════════════════════════
calc_adx(h, l, c) =>
    up   = h - h[1]
    down = l[1] - l
    pdm  = up > down and up > 0 ? up : 0.0
    ndm  = down > up and down > 0 ? down : 0.0
    tr   = math.max(h - l, math.abs(h - c[1]), math.abs(l - c[1]))
    atr  = ta.rma(tr, adx_di_length)
    pdi  = atr != 0 ? 100.0 * ta.rma(pdm, adx_di_length) / atr : 0.0
    ndi  = atr != 0 ? 100.0 * ta.rma(ndm, adx_di_length) / atr : 0.0
    dsum = pdi + ndi
    dx   = dsum != 0 ? 100.0 * math.abs(pdi - ndi) / dsum : 0.0
    adx  = ta.rma(dx, adx_smoothing)
    [pdi, ndi, adx]

// ═══════════════════════════════════════════════════
// DATA FETCH — 30 calls using resolved sym variables
// ═══════════════════════════════════════════════════
fetchAll(sym) =>
    request.security(sym, timeframe.period,
        [close, high, low, ta.obv, ta.vwap, f_st_line(), f_st_dir()])

[c1,  h1,  l1,  obv1,  vwap1,  stl1,  std1]  = fetchAll(sym1)
[c2,  h2,  l2,  obv2,  vwap2,  stl2,  std2]  = fetchAll(sym2)
[c3,  h3,  l3,  obv3,  vwap3,  stl3,  std3]  = fetchAll(sym3)
[c4,  h4,  l4,  obv4,  vwap4,  stl4,  std4]  = fetchAll(sym4)
[c5,  h5,  l5,  obv5,  vwap5,  stl5,  std5]  = fetchAll(sym5)
[c6,  h6,  l6,  obv6,  vwap6,  stl6,  std6]  = fetchAll(sym6)
[c7,  h7,  l7,  obv7,  vwap7,  stl7,  std7]  = fetchAll(sym7)
[c8,  h8,  l8,  obv8,  vwap8,  stl8,  std8]  = fetchAll(sym8)
[c9,  h9,  l9,  obv9,  vwap9,  stl9,  std9]  = fetchAll(sym9)
[c10, h10, l10, obv10, vwap10, stl10, std10] = fetchAll(sym10)
[c11, h11, l11, obv11, vwap11, stl11, std11] = fetchAll(sym11)
[c12, h12, l12, obv12, vwap12, stl12, std12] = fetchAll(sym12)
[c13, h13, l13, obv13, vwap13, stl13, std13] = fetchAll(sym13)
[c14, h14, l14, obv14, vwap14, stl14, std14] = fetchAll(sym14)
[c15, h15, l15, obv15, vwap15, stl15, std15] = fetchAll(sym15)
[c16, h16, l16, obv16, vwap16, stl16, std16] = fetchAll(sym16)
[c17, h17, l17, obv17, vwap17, stl17, std17] = fetchAll(sym17)
[c18, h18, l18, obv18, vwap18, stl18, std18] = fetchAll(sym18)
[c19, h19, l19, obv19, vwap19, stl19, std19] = fetchAll(sym19)
[c20, h20, l20, obv20, vwap20, stl20, std20] = fetchAll(sym20)
[c21, h21, l21, obv21, vwap21, stl21, std21] = fetchAll(sym21)
[c22, h22, l22, obv22, vwap22, stl22, std22] = fetchAll(sym22)
[c23, h23, l23, obv23, vwap23, stl23, std23] = fetchAll(sym23)
[c24, h24, l24, obv24, vwap24, stl24, std24] = fetchAll(sym24)
[c25, h25, l25, obv25, vwap25, stl25, std25] = fetchAll(sym25)
[c26, h26, l26, obv26, vwap26, stl26, std26] = fetchAll(sym26)
[c27, h27, l27, obv27, vwap27, stl27, std27] = fetchAll(sym27)
[c28, h28, l28, obv28, vwap28, stl28, std28] = fetchAll(sym28)
[c29, h29, l29, obv29, vwap29, stl29, std29] = fetchAll(sym29)
[c30, h30, l30, obv30, vwap30, stl30, std30] = fetchAll(sym30)

// ═══════════════════════════════════════════════════
// STATE CALCULATION — 10 indicator modes
// FIX 2: EMA Slope guarded against division by zero
// ═══════════════════════════════════════════════════
calcState(c, h, l, obv_raw, vwap_val, st_line_v, st_dir_v) =>
    state = "neutral"

    if selected_indicator == "RSI"
        rsi_val = ta.rsi(c, rsi_length)
        rsi_sma = ta.sma(rsi_val, rsi_sma_len)
        state  :=
          rsi_val > rsi_sma and rsi_val > 50 ? "strong_bull" :
          rsi_val > rsi_sma or  rsi_val > 50 ? "weak_bull"   :
          rsi_val < rsi_sma and rsi_val < 50 ? "strong_bear" :
          rsi_val < rsi_sma or  rsi_val < 50 ? "weak_bear"   : "neutral"

    else if selected_indicator == "MACD"
        [_, _, hist] = ta.macd(c, fast_length, slow_length, signal_length)
        if not na(hist) and not na(hist[1])
            state :=
              hist >= 0 and hist > hist[1] ? "strong_bull" :
              hist >= 0                    ? "weak_bull"   :
              hist <  0 and hist < hist[1] ? "strong_bear" :
              hist <  0                    ? "weak_bear"   : "neutral"

    else if selected_indicator == "EMA Slope"
        ema_val     = ta.ema(c, ema_length)
        hi200       = ta.highest(h, 200)
        lo200       = ta.lowest(l,  200)
        price_scale = hi200 - lo200
        if price_scale > 0
            pts_per_bar = price_scale / 200
            ema_change  = ema_val - ema_val[slope_period]
            slope_angle = math.atan(ema_change / (pts_per_bar * slope_period)) * 180 / math.pi
            state :=
              slope_angle >=  reference_angle ? "strong_bull" :
              slope_angle >   0               ? "weak_bull"   :
              slope_angle <= -reference_angle ? "strong_bear" :
              slope_angle <   0               ? "weak_bear"   : "neutral"

    else if selected_indicator == "OBV Trend"
        obv_short = ma(obv_raw, smoothingLengthShort, typeMA)
        obv_long  = ma(obv_raw, smoothingLengthLong,  typeMA)
        state    :=
          obv_short > obv_long and obv_long > obv_long[1] ? "strong_bull" :
          obv_short > obv_long                             ? "weak_bull"   :
          obv_short < obv_long and obv_long < obv_long[1] ? "strong_bear" :
          obv_short < obv_long                             ? "weak_bear"   : "neutral"

    else if selected_indicator == "Supertrend"
        if not na(st_line_v)
            is_bull = c > st_line_v
            rising  = c > c[1]
            state  :=
              is_bull and rising          ? "strong_bull" :
              is_bull and not rising      ? "weak_bull"   :
              not is_bull and not rising  ? "strong_bear" : "weak_bear"

    else if selected_indicator == "VWAP"
        if not na(vwap_val)
            is_bull = c > vwap_val
            rising  = c > c[1]
            state  :=
              is_bull and rising          ? "strong_bull" :
              is_bull and not rising      ? "weak_bull"   :
              not is_bull and not rising  ? "strong_bear" : "weak_bear"

    else if selected_indicator == "ADX/DMI"
        [pdi, ndi, adx_v] = calc_adx(h, l, c)
        if not na(adx_v)
            bull_dir     = pdi > ndi
            strong_trend = adx_v >= adx_threshold
            state       :=
              bull_dir and strong_trend      ? "strong_bull" :
              bull_dir and not strong_trend  ? "weak_bull"   :
              not bull_dir and strong_trend  ? "strong_bear" : "weak_bear"

    else if selected_indicator == "BB %B"
        [bb_mid, bb_upper, bb_lower] = ta.bb(c, bb_length, bb_mult)
        bb_range = bb_upper - bb_lower
        bb_b     = bb_range > 0 ? (c - bb_lower) / bb_range : 0.5
        state   :=
          bb_b >= 1.0 ? "strong_bull" :
          bb_b >= 0.5 ? "weak_bull"   :
          bb_b <= 0.0 ? "strong_bear" : "weak_bear"

    else if selected_indicator == "Stoch RSI"
        rsi_v   = ta.rsi(c, srsi_rsi_len)
        stoch_k = ta.stoch(rsi_v, rsi_v, rsi_v, srsi_stoch_len)
        k       = ta.sma(stoch_k, srsi_smooth_k)
        d       = ta.sma(k, srsi_smooth_d)
        state  :=
          k > d and k > 50 ? "strong_bull" :
          k > d or  k > 50 ? "weak_bull"   :
          k < d and k < 50 ? "strong_bear" :
          k < d or  k < 50 ? "weak_bear"   : "neutral"

    else if selected_indicator == "Vol Delta"
        // Bar-level normalized delta: maps close position within the high/low
        // range to [-1, +1]. Equivalent to LuxAlgo's LTF approach as resolution
        // increases. Guard against zero-range doji bars.
        hl     = h - l
        nd     = hl > 0 ? (2.0 * c - h - l) / hl : 0.0
        snd    = ta.ema(nd, vd_smooth)
        state :=
          snd >  vd_threshold and snd > snd[1] ? "strong_bull" :
          snd >  0                              ? "weak_bull"   :
          snd < -vd_threshold and snd < snd[1] ? "strong_bear" :
          snd <  0                              ? "weak_bear"   : "neutral"

    state

// ═══════════════════════════════════════════════════
// STATE + STREAK ARRAYS
// ═══════════════════════════════════════════════════
var current_states = array.new<string>(30, "neutral")
var prev_states    = array.new<string>(30, "neutral")
var up_streaks     = array.new<int>(30, 0)
var down_streaks   = array.new<int>(30, 0)

array.set(current_states, 0,  calcState(c1,  h1,  l1,  obv1,  vwap1,  stl1,  std1))
array.set(current_states, 1,  calcState(c2,  h2,  l2,  obv2,  vwap2,  stl2,  std2))
array.set(current_states, 2,  calcState(c3,  h3,  l3,  obv3,  vwap3,  stl3,  std3))
array.set(current_states, 3,  calcState(c4,  h4,  l4,  obv4,  vwap4,  stl4,  std4))
array.set(current_states, 4,  calcState(c5,  h5,  l5,  obv5,  vwap5,  stl5,  std5))
array.set(current_states, 5,  calcState(c6,  h6,  l6,  obv6,  vwap6,  stl6,  std6))
array.set(current_states, 6,  calcState(c7,  h7,  l7,  obv7,  vwap7,  stl7,  std7))
array.set(current_states, 7,  calcState(c8,  h8,  l8,  obv8,  vwap8,  stl8,  std8))
array.set(current_states, 8,  calcState(c9,  h9,  l9,  obv9,  vwap9,  stl9,  std9))
array.set(current_states, 9,  calcState(c10, h10, l10, obv10, vwap10, stl10, std10))
array.set(current_states, 10, calcState(c11, h11, l11, obv11, vwap11, stl11, std11))
array.set(current_states, 11, calcState(c12, h12, l12, obv12, vwap12, stl12, std12))
array.set(current_states, 12, calcState(c13, h13, l13, obv13, vwap13, stl13, std13))
array.set(current_states, 13, calcState(c14, h14, l14, obv14, vwap14, stl14, std14))
array.set(current_states, 14, calcState(c15, h15, l15, obv15, vwap15, stl15, std15))
array.set(current_states, 15, calcState(c16, h16, l16, obv16, vwap16, stl16, std16))
array.set(current_states, 16, calcState(c17, h17, l17, obv17, vwap17, stl17, std17))
array.set(current_states, 17, calcState(c18, h18, l18, obv18, vwap18, stl18, std18))
array.set(current_states, 18, calcState(c19, h19, l19, obv19, vwap19, stl19, std19))
array.set(current_states, 19, calcState(c20, h20, l20, obv20, vwap20, stl20, std20))
array.set(current_states, 20, calcState(c21, h21, l21, obv21, vwap21, stl21, std21))
array.set(current_states, 21, calcState(c22, h22, l22, obv22, vwap22, stl22, std22))
array.set(current_states, 22, calcState(c23, h23, l23, obv23, vwap23, stl23, std23))
array.set(current_states, 23, calcState(c24, h24, l24, obv24, vwap24, stl24, std24))
array.set(current_states, 24, calcState(c25, h25, l25, obv25, vwap25, stl25, std25))
array.set(current_states, 25, calcState(c26, h26, l26, obv26, vwap26, stl26, std26))
array.set(current_states, 26, calcState(c27, h27, l27, obv27, vwap27, stl27, std27))
array.set(current_states, 27, calcState(c28, h28, l28, obv28, vwap28, stl28, std28))
array.set(current_states, 28, calcState(c29, h29, l29, obv29, vwap29, stl29, std29))
array.set(current_states, 29, calcState(c30, h30, l30, obv30, vwap30, stl30, std30))

// ═══════════════════════════════════════════════════
// FIX 5: STREAK LOGIC — weak states do not zero the opposing streak.
// FIX 8: PREV_STATES — only updates on confirmed bars.
// ═══════════════════════════════════════════════════
if barstate.isconfirmed
    for i = 0 to 29
        state      = array.get(current_states, i)
        prev_state = array.get(prev_states,    i)
        up_str     = array.get(up_streaks,     i)
        dn_str     = array.get(down_streaks,   i)

        if state == "strong_bull"
            array.set(up_streaks,   i, (prev_state == "strong_bull" or prev_state == "weak_bull") ? up_str + 1 : 1)
            array.set(down_streaks, i, 0)
        else if state == "weak_bull"
            array.set(down_streaks, i, 0)
        else if state == "strong_bear"
            array.set(down_streaks, i, (prev_state == "strong_bear" or prev_state == "weak_bear") ? dn_str + 1 : 1)
            array.set(up_streaks,   i, 0)
        else if state == "weak_bear"
            array.set(up_streaks,   i, 0)
        else
            array.set(up_streaks,   i, 0)
            array.set(down_streaks, i, 0)

        array.set(prev_states, i, state)

// ═══════════════════════════════════════════════════
// MARKET COUNTS
// ═══════════════════════════════════════════════════
strong_bull_n = 0
weak_bull_n   = 0
strong_bear_n = 0
weak_bear_n   = 0
neutral_n     = 0

for i = 0 to 29
    st = array.get(current_states, i)
    if st == "strong_bull"
        strong_bull_n += 1
    else if st == "weak_bull"
        weak_bull_n += 1
    else if st == "strong_bear"
        strong_bear_n += 1
    else if st == "weak_bear"
        weak_bear_n += 1
    else
        neutral_n += 1

market_is_bull  = (strong_bull_n + weak_bull_n) > (strong_bear_n + weak_bear_n)
strong_bull_pct = (strong_bull_n / 30) * 100
weak_bull_pct   = (weak_bull_n   / 30) * 100
strong_bear_pct = (strong_bear_n / 30) * 100
weak_bear_pct   = (weak_bear_n   / 30) * 100

// FIX 6: Honest tie-breaking — genuine split returns "MIXED"
total_bull_n = strong_bull_n + weak_bull_n
total_bear_n = strong_bear_n + weak_bear_n

market_status = total_bull_n == total_bear_n ? "MIXED" : total_bull_n > total_bear_n ? (strong_bull_n >= weak_bull_n   ? "STRONG BULL" : "WEAK BULL") : (strong_bear_n >= weak_bear_n   ? "STRONG BEAR" : "WEAK BEAR")

// ═══════════════════════════════════════════════════
// COLOR SYSTEM
// FIX 7: Monochrome warm tint = bull, cool tint = bear
// ═══════════════════════════════════════════════════
calcBullColor(streak) =>
    norm   = math.min(float(streak), float(max_streak)) / float(max_streak)
    isHS   = color_style == "Hue Shift"
    isTL   = color_style == "Traffic Light"
    intv   = isTL ? (streak <= 5 ? 1.0 : streak <= 15 ? 0.65 : 0.35) :
             (trad_intensity ? math.min(norm, 1.0) : math.max(0.2, 1.0 - norm))
    g_c    = isHS ? int(255 - norm * 80)  : int(255 * intv)
    b_c    = isHS ? int(norm * 200)       : 0
    r_cb   = isHS ? int(norm * 30)        : 0
    g_cb   = isHS ? int(150 - norm * 50)  : int(114 * intv)
    b_cb   = isHS ? int(178 + norm * 77)  : int(178 * intv)
    g_if   = isHS ? int(229 - norm * 100) : int(229 * intv)
    b_if   = isHS ? int(255 - norm * 55)  : int(255 * intv)
    m_intv = isHS ? math.max(0.2, 1.0 - norm * 0.75) : intv
    switch color_palette
        "Classic"         => color.rgb(0,    g_c,  b_c)
        "Colorblind Safe" => color.rgb(r_cb, g_cb, b_cb)
        "Ice & Fire"      => color.rgb(0,    g_if, b_if)
        "Monochrome"      => color.rgb(int(255 * m_intv), int(220 * m_intv), int(180 * m_intv))
        => color.rgb(0, int(255 * intv), 0)

calcBearColor(streak) =>
    norm   = math.min(float(streak), float(max_streak)) / float(max_streak)
    isHS   = color_style == "Hue Shift"
    isTL   = color_style == "Traffic Light"
    intv   = isTL ? (streak <= 5 ? 1.0 : streak <= 15 ? 0.65 : 0.35) :
             (trad_intensity ? math.min(norm, 1.0) : math.max(0.2, 1.0 - norm))
    g_c    = isHS ? int(norm * 150)       : 0
    r_cb   = isHS ? int(230 - norm * 30)  : int(230 * intv)
    g_cb   = isHS ? int(159 - norm * 80)  : int(159 * intv)
    b_if   = isHS ? int(128 - norm * 128) : int(128 * intv)
    m_intv = isHS ? math.max(0.15, 1.0 - norm * 0.75) : intv
    switch color_palette
        "Classic"         => color.rgb(255,  g_c,  0)
        "Colorblind Safe" => color.rgb(r_cb, g_cb, 0)
        "Ice & Fire"      => color.rgb(255,  0,    b_if)
        "Monochrome"      => color.rgb(int(180 * m_intv), int(190 * m_intv), int(230 * m_intv))
        => color.rgb(int(255 * intv), 0, 0)

getWeakBullColor() =>
    tl = color_style == "Traffic Light"
    switch color_palette
        "Classic"         => tl ? color.new(color.rgb(30, 144, 255),  50) : color.new(color.green, 70)
        "Colorblind Safe" => tl ? color.new(color.rgb(86, 180, 233),  50) : color.new(color.rgb(0, 114, 178), 70)
        "Ice & Fire"      => tl ? color.new(color.rgb(0, 180, 216),   50) : color.new(color.rgb(0, 229, 255), 70)
        "Monochrome"      => tl ? color.new(color.rgb(200, 185, 160), 50) : color.new(color.rgb(220, 200, 175), 70)
        => color.new(color.green, 70)

getWeakBearColor() =>
    tl = color_style == "Traffic Light"
    switch color_palette
        "Classic"         => tl ? color.new(color.rgb(255, 105, 180), 50) : color.new(color.red, 70)
        "Colorblind Safe" => tl ? color.new(color.rgb(240, 200, 100), 50) : color.new(color.rgb(230, 159, 0), 70)
        "Ice & Fire"      => tl ? color.new(color.rgb(255, 80, 150),  50) : color.new(color.rgb(255, 0, 128), 70)
        "Monochrome"      => tl ? color.new(color.rgb(155, 165, 200), 50) : color.new(color.rgb(140, 150, 185), 70)
        => color.new(color.red, 70)

getColor(index) =>
    state        = array.get(current_states, index)
    up_str       = array.get(up_streaks,     index)
    dn_str       = array.get(down_streaks,   index)
    is_bull      = state == "strong_bull" or state == "weak_bull"
    is_bear      = state == "strong_bear" or state == "weak_bear"
    is_diverging = show_divergence and ((market_is_bull and is_bear) or (not market_is_bull and is_bull))
    if is_diverging and (state == "strong_bull" or state == "strong_bear")
        color.rgb(255, 200, 0)
    else if is_diverging
        color.new(color.rgb(200, 160, 0), 50)
    else if state == "strong_bull" and up_str > 0
        calcBullColor(up_str)
    else if state == "strong_bear" and dn_str > 0
        calcBearColor(dn_str)
    else if state == "weak_bull"
        getWeakBullColor()
    else if state == "weak_bear"
        getWeakBearColor()
    else
        color.rgb(80, 80, 80)

getTotalColor() =>
    bull_streak_sum = 0
    bear_streak_sum = 0
    bull_n          = 0
    bear_n          = 0
    strong_bull_cnt = 0
    strong_bear_cnt = 0
    for i = 0 to 29
        st  = array.get(current_states, i)
        ups = array.get(up_streaks,     i)
        dns = array.get(down_streaks,   i)
        if st == "strong_bull"
            bull_streak_sum += ups
            bull_n          += 1
            strong_bull_cnt += 1
        else if st == "weak_bull"
            bull_n += 1
        else if st == "strong_bear"
            bear_streak_sum += dns
            bear_n          += 1
            strong_bear_cnt += 1
        else if st == "weak_bear"
            bear_n += 1
    if bull_n > bear_n
        avg_streak = strong_bull_cnt > 0 ? math.round(bull_streak_sum / strong_bull_cnt) : 1
        strong_bull_cnt >= bull_n / 2 ? calcBullColor(math.max(avg_streak, 1)) : getWeakBullColor()
    else if bear_n > bull_n
        avg_streak = strong_bear_cnt > 0 ? math.round(bear_streak_sum / strong_bear_cnt) : 1
        strong_bear_cnt >= bear_n / 2 ? calcBearColor(math.max(avg_streak, 1)) : getWeakBearColor()
    else
        color.rgb(80, 80, 80)

// ═══════════════════════════════════════════════════
// POSITION HELPERS
// ═══════════════════════════════════════════════════
getBasePosition(index) =>
    (zone_height + zone_gap) * (30 - index)

getTotalPosition() =>
    (zone_height + zone_gap) * 32

// ═══════════════════════════════════════════════════
// PLOTS
// Note: plot() title= must be a constant string in Pine Script.
// Dynamic asset names appear via the label objects below.
// ═══════════════════════════════════════════════════
total_color = show_total ? getTotalColor() : color.new(color.gray, 100)
plot(getTotalPosition() + zone_height / 2, color=total_color,   title="Total Market", linewidth=7, style=plot.style_stepline)

plot(getBasePosition(0)  + zone_height / 2, color=getColor(0),  title="Slot 01", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(1)  + zone_height / 2, color=getColor(1),  title="Slot 02", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(2)  + zone_height / 2, color=getColor(2),  title="Slot 03", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(3)  + zone_height / 2, color=getColor(3),  title="Slot 04", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(4)  + zone_height / 2, color=getColor(4),  title="Slot 05", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(5)  + zone_height / 2, color=getColor(5),  title="Slot 06", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(6)  + zone_height / 2, color=getColor(6),  title="Slot 07", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(7)  + zone_height / 2, color=getColor(7),  title="Slot 08", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(8)  + zone_height / 2, color=getColor(8),  title="Slot 09", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(9)  + zone_height / 2, color=getColor(9),  title="Slot 10", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(10) + zone_height / 2, color=getColor(10), title="Slot 11", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(11) + zone_height / 2, color=getColor(11), title="Slot 12", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(12) + zone_height / 2, color=getColor(12), title="Slot 13", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(13) + zone_height / 2, color=getColor(13), title="Slot 14", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(14) + zone_height / 2, color=getColor(14), title="Slot 15", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(15) + zone_height / 2, color=getColor(15), title="Slot 16", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(16) + zone_height / 2, color=getColor(16), title="Slot 17", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(17) + zone_height / 2, color=getColor(17), title="Slot 18", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(18) + zone_height / 2, color=getColor(18), title="Slot 19", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(19) + zone_height / 2, color=getColor(19), title="Slot 20", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(20) + zone_height / 2, color=getColor(20), title="Slot 21", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(21) + zone_height / 2, color=getColor(21), title="Slot 22", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(22) + zone_height / 2, color=getColor(22), title="Slot 23", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(23) + zone_height / 2, color=getColor(23), title="Slot 24", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(24) + zone_height / 2, color=getColor(24), title="Slot 25", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(25) + zone_height / 2, color=getColor(25), title="Slot 26", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(26) + zone_height / 2, color=getColor(26), title="Slot 27", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(27) + zone_height / 2, color=getColor(27), title="Slot 28", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(28) + zone_height / 2, color=getColor(28), title="Slot 29", linewidth=5, style=plot.style_stepline)
plot(getBasePosition(29) + zone_height / 2, color=getColor(29), title="Slot 30", linewidth=5, style=plot.style_stepline)

// ═══════════════════════════════════════════════════
// LABELS — fully dynamic: names update with preset switch
// ═══════════════════════════════════════════════════
var label[] asset_labels = array.new<label>()

if barstate.islast and show_labels
    if array.size(asset_labels) > 0
        for i = 0 to array.size(asset_labels) - 1
            lbl = array.get(asset_labels, i)
            if not na(lbl)
                label.delete(lbl)
    array.clear(asset_labels)
    for i = 0 to 29
        name     = getName(array.get(tickers, i))
        lbl_c    = getColor(i)
        st       = array.get(current_states, i)
        arrow    = st == "strong_bull" or st == "weak_bull" ? "↗" : st == "strong_bear" or st == "weak_bear" ? "↘" : "—"
        base_pos = getBasePosition(i)
        lbl = label.new(bar_index, base_pos + zone_height / 2, name + " " + arrow,
             style=label.style_label_left, textcolor=color.white, color=color.new(lbl_c, 70), size=size.small)
        array.push(asset_labels, lbl)
    if show_total
        t_color = getTotalColor()
        bn  = 0
        brn = 0
        for i = 0 to 29
            st = array.get(current_states, i)
            if st == "strong_bull" or st == "weak_bull"
                bn += 1
            else if st == "strong_bear" or st == "weak_bear"
                brn += 1
        t_arrow   = bn > brn ? "↗" : brn > bn ? "↘" : "—"
        total_lbl = label.new(bar_index, getTotalPosition() + zone_height / 2, selected_indicator + " " + t_arrow,
             style=label.style_label_left, textcolor=color.white, color=color.new(t_color, 70), size=size.normal)
        array.push(asset_labels, total_lbl)

// ═══════════════════════════════════════════════════
// FIX 9: DELTA TRACKING — confirmed bars only
// ═══════════════════════════════════════════════════
var int prev_sb  = na
var int prev_wb  = na
var int prev_wbr = na
var int prev_sbr = na

var int dSB  = 0
var int dWB  = 0
var int dWBR = 0
var int dSBR = 0

if barstate.isconfirmed
    if not na(prev_sb)
        dSB  := strong_bull_n - prev_sb
        dWB  := weak_bull_n   - prev_wb
        dWBR := weak_bear_n   - prev_wbr
        dSBR := strong_bear_n - prev_sbr
    prev_sb  := strong_bull_n
    prev_wb  := weak_bull_n
    prev_wbr := weak_bear_n
    prev_sbr := strong_bear_n

// ═══════════════════════════════════════════════════
// DASHBOARD TABLE
// Header now shows the active preset name dynamically.
// Sector breakdown uses preset-aware group labels.
// FIX 6: MIXED status uses distinct amber color.
// ═══════════════════════════════════════════════════
if barstate.islast
    momentum  = calcMomentum(current_states)
    filled    = math.round(momentum / 10)
    mom_bar   = ""
    for b = 1 to 10
        mom_bar += b <= filled ? "█" : "░"
    mom_color = momentum >= 60 ? color.lime : momentum >= 40 ? color.yellow : color.rgb(255, 80, 80)

    sb_c  = market_status == "STRONG BULL" ? color.rgb(5,   250, 0) : color.gray
    wb_c  = market_status == "WEAK BULL"   ? color.rgb(0,   180, 5) : color.gray
    wbr_c = market_status == "WEAK BEAR"   ? color.rgb(180, 0,   0) : color.gray
    sbr_c = market_status == "STRONG BEAR" ? color.rgb(255, 0,   0) : color.gray
    sb_e  = market_status == "STRONG BULL" ? "🟢 " : ""
    wb_e  = market_status == "WEAK BULL"   ? "🟢 " : ""
    wbr_e = market_status == "WEAK BEAR"   ? "🔴 " : ""
    sbr_e = market_status == "STRONG BEAR" ? "🔴 " : ""

    status_color = market_status == "MIXED" ? color.rgb(180, 180, 60) : color.yellow

    var dash  = table.new(position.middle_right, 1, 14, bgcolor=color.new(color.black, 80), border_width=1)
    clr_blank = color.new(color.black, 100)

    table.cell(dash, 0, 0, "📊 " + selected_indicator + " — " + asset_preset,                                                                                                        text_color=color.white,  text_size=size.normal)
    table.cell(dash, 0, 1, "Momentum  " + mom_bar + "  " + str.tostring(momentum) + "/100",                                                                                          text_color=mom_color,    text_size=size.small)
    table.cell(dash, 0, 2, "Market: " + market_status + "   Palette: " + color_palette,                                                                                              text_color=status_color, text_size=size.small)
    table.cell(dash, 0, 3, sb_e  + "Strong Bull: " + str.tostring(strong_bull_pct, "#.0") + "% (" + str.tostring(strong_bull_n) + ")" + deltaStr(dSB),  text_color=sb_c,  text_size=size.auto)
    table.cell(dash, 0, 4, wb_e  + "Weak Bull:   " + str.tostring(weak_bull_pct,   "#.0") + "% (" + str.tostring(weak_bull_n)   + ")" + deltaStr(dWB),  text_color=wb_c,  text_size=size.auto)
    table.cell(dash, 0, 5, wbr_e + "Weak Bear:   " + str.tostring(weak_bear_pct,   "#.0") + "% (" + str.tostring(weak_bear_n)   + ")" + deltaStr(dWBR), text_color=wbr_c, text_size=size.auto)
    table.cell(dash, 0, 6, sbr_e + "Strong Bear: " + str.tostring(strong_bear_pct, "#.0") + "% (" + str.tostring(strong_bear_n) + ")" + deltaStr(dSBR), text_color=sbr_c, text_size=size.auto)
    if table_style == "Detailed"
        g1_b = sectorBull(current_states, 0,  3)
        g1_r = sectorBear(current_states, 0,  3)
        g2_b = sectorBull(current_states, 4,  9)
        g2_r = sectorBear(current_states, 4,  9)
        g3_b = sectorBull(current_states, 10, 16)
        g3_r = sectorBear(current_states, 10, 16)
        g4_b = sectorBull(current_states, 17, 21)
        g4_r = sectorBear(current_states, 17, 21)
        g5_b = sectorBull(current_states, 22, 23)
        g5_r = sectorBear(current_states, 22, 23)
        g6_b = sectorBull(current_states, 24, 29)
        g6_r = sectorBear(current_states, 24, 29)
        table.cell(dash, 0, 7,  "── Group Breakdown ──",                                                                                                                               text_color=color.gray,          text_size=size.small)
        table.cell(dash, 0, 8,  grp1_label + sectorDots(current_states, 0,  3)  + "  " + str.tostring(g1_b) + "↑ " + str.tostring(g1_r) + "↓", text_color=sectorColor(g1_b, g1_r), text_size=size.small)
        table.cell(dash, 0, 9,  grp2_label + sectorDots(current_states, 4,  9)  + "  " + str.tostring(g2_b) + "↑ " + str.tostring(g2_r) + "↓", text_color=sectorColor(g2_b, g2_r), text_size=size.small)
        table.cell(dash, 0, 10, grp3_label + sectorDots(current_states, 10, 16) + "  " + str.tostring(g3_b) + "↑ " + str.tostring(g3_r) + "↓", text_color=sectorColor(g3_b, g3_r), text_size=size.small)
        table.cell(dash, 0, 11, grp4_label + sectorDots(current_states, 17, 21) + "  " + str.tostring(g4_b) + "↑ " + str.tostring(g4_r) + "↓", text_color=sectorColor(g4_b, g4_r), text_size=size.small)
        table.cell(dash, 0, 12, grp5_label + sectorDots(current_states, 22, 23) + "  " + str.tostring(g5_b) + "↑ " + str.tostring(g5_r) + "↓", text_color=sectorColor(g5_b, g5_r), text_size=size.small)
        table.cell(dash, 0, 13, grp6_label + sectorDots(current_states, 24, 29) + "  " + str.tostring(g6_b) + "↑ " + str.tostring(g6_r) + "↓", text_color=sectorColor(g6_b, g6_r), text_size=size.small)
    else
        for r = 7 to 13
            table.cell(dash, 0, r, "", bgcolor=clr_blank, text_color=clr_blank)

// ═══════════════════════════════════════════════════
// MINI HEATMAP — ticker names pulled live from active preset
// ═══════════════════════════════════════════════════
if barstate.islast and show_heatmap
    var hmap = table.new(position.bottom_center, 30, 2, bgcolor=color.new(color.black, 95), border_width=0, frame_width=0)
    for i = 0 to 29
        cell_color = getColor(i)
        cell_name  = getName(array.get(tickers, i))
        table.cell(hmap, i, 0, "  ",       bgcolor=color.new(cell_color, 20), text_size=size.small)
        table.cell(hmap, i, 1, cell_name,  bgcolor=color.new(color.black, 95), text_color=color.gray, text_size=size.tiny)

// ═══════════════════════════════════════════════════
// ALERTS — FIX 4: all alerts respect bull/bear toggles
// ═══════════════════════════════════════════════════
var string prev_market_status = ""
var int    prev_sbn           = 0
var int    prev_srn           = 0
if enable_alerts and barstate.isconfirmed
    if alert_bull and strong_bull_n >= min_for_alert
        alert("🚀 " + selected_indicator + " Strong Bull: " + str.tostring(strong_bull_n) + " assets (" + asset_preset + ")", alert.freq_once_per_bar)
    if alert_bear and strong_bear_n >= min_for_alert
        alert("📉 " + selected_indicator + " Strong Bear: " + str.tostring(strong_bear_n) + " assets (" + asset_preset + ")", alert.freq_once_per_bar)
    if alert_shift and prev_market_status != "" and market_status != prev_market_status
        alert("📊 " + selected_indicator + " Sentiment Changed: " + market_status + " (" + asset_preset + ")", alert.freq_once_per_bar)
    if alert_bull and strong_bull_pct >= 60 and prev_sbn < 18
        alert("🔥 EXTREME " + selected_indicator + " BULLISH: " + str.tostring(strong_bull_pct, "#.0") + "% (" + asset_preset + ")", alert.freq_once_per_bar)
    if alert_bear and strong_bear_pct >= 60 and prev_srn < 18
        alert("⚠️ EXTREME " + selected_indicator + " BEARISH: " + str.tostring(strong_bear_pct, "#.0") + "% (" + asset_preset + ")", alert.freq_once_per_bar)
if barstate.isconfirmed
    prev_market_status := market_status
    prev_sbn           := strong_bull_n
    prev_srn           := strong_bear_n
````
