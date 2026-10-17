# VEK Position Size Calculator

- url: https://www.tradingview.com/script/pknhE8QR/
- type: indicator
- pine_id: PUB;aa32d7c2896c4e23875005ff2d856bf1
- version: 1.0

## Description

VEK Position Size Calculator — Free & Open Source Risk Management Tool

VEK Position Size Calculator is a free and open-source risk management tool designed to help traders calculate an appropriate position size before entering a trade.

The purpose of the script is simple: instead of choosing a position size first and accepting whatever risk results from it, the trader defines the maximum amount of capital they are prepared to risk and the location of the Stop Loss. The calculator then determines the position size that corresponds to those parameters.

The script does not generate trading signals and does not attempt to predict market direction. Entry and Stop Loss levels are defined by the trader.

HOW TO USE

1. Enter your account capital.
2. Select your account currency.
3. Define the percentage of capital you are willing to risk.
4. Place your planned Entry price.
5. Place your Stop Loss price.
6. The calculator measures the Entry-to-Stop-Loss distance.
7. It determines the applicable point/contract value and performs currency conversion when required.
8. It calculates the corresponding position size.
9. The resulting size is rounded down according to the applicable size increment.
10. The dashboard displays both the requested risk and the estimated real risk after position-size rounding.

In Entry + SL mode, the Entry and Stop Loss levels can be placed and moved directly on the chart.

The script automatically determines the direction of the planned trade from the relationship between Entry and Stop Loss:

• Stop Loss below Entry = BUY
• Stop Loss above Entry = SELL

POSITION SIZING METHODOLOGY

The calculation begins by determining the monetary amount the trader has chosen to risk:

Requested Risk = Account Capital × Risk %

For example, an account capital of 10,000 with a selected risk of 1% represents a requested maximum risk of 100 in the selected account currency.

The script then calculates the absolute price distance between the planned Entry and Stop Loss.

The monetary value of a 1.0 price movement for one unit of position size is determined using the applicable instrument specifications. When the instrument's profit currency differs from the selected account currency, the value is converted into the account currency when currency-rate data is available through TradingView.

The raw position size is then calculated as:

Position Size = Requested Risk / (Entry-to-SL Price Distance × Point Value)

POSITION SIZE ROUNDING AND REAL RISK

A theoretical position size is not always executable because instruments and brokers can impose minimum position sizes and size increments.

For this reason, the calculator rounds the calculated position size DOWN to the applicable size increment.

Rounding down is intentional. The calculator does not round a theoretical size upward when doing so could increase the actual risk above the amount requested by the trader.

After rounding, the script recalculates the estimated monetary risk of the resulting position:

Real Risk = Entry-to-SL Price Distance × Point Value × Final Position Size

The dashboard displays this Real Risk both as an amount in the selected account currency and as a percentage of account capital.

This allows the trader to compare the initially requested risk with the estimated risk represented by the final calculated position size.

If the calculated position size is below the minimum size defined for the instrument, the script does not automatically increase the position to the minimum.

Instead, it displays a "BELOW MINIMUM SIZE" status and shows the estimated risk that the minimum position size would represent.

SUPPORTED MARKETS AND CONTRACT HANDLING

The calculator is designed to work across multiple asset classes.

It includes predefined handling for:

• Forex
• Gold
• Silver
• Bitcoin
• Nasdaq
• US30
• US500
• DAX
• F40
• AUS200
• UK100
• JP225

The script also includes Native and Custom modes for instruments or broker specifications that do not correspond to the predefined mappings.

AUTO, NATIVE AND CUSTOM MODES

AUTO MODE

In Auto mode, predefined broker-style lot conventions are applied automatically to supported IC Markets symbols.

For other brokers, feeds and asset classes that are not mapped to those predefined families, the script falls back to TradingView's available native contract metadata.

This approach is intentional because contract specifications can vary between brokers even when instruments have similar names.

NATIVE MODE

Native mode forces the calculator to use TradingView's available native symbol information, including point value and minimum contract information when available.

Depending on the asset class, the resulting position may therefore be expressed as shares, contracts or units rather than Forex-style lots.

CUSTOM MODE

Custom mode is available when the automatic or native specifications do not match the trader's broker.

It allows the user to manually define:

• Point value
• Profit currency
• Minimum position size
• Position-size increment

This makes it possible to adapt the calculation to broker-specific contract specifications.

MANUAL SL DISTANCE MODE

In addition to the interactive Entry + SL mode, the calculator includes a Manual SL Distance mode.

In this mode, the trader:

• Selects BUY or SELL
• Defines the Entry
• Enters the desired Stop Loss distance manually

For Forex, the distance is expressed in pips where applicable.

For predefined CFD families, the distance is expressed in points.

For universal/native instruments, the distance is expressed in price units.

The script then reconstructs the Stop Loss location and applies the same risk and position-sizing methodology.

ACCOUNT CURRENCY CONVERSION

The calculator supports the following account currencies:

EUR, USD, GBP, CHF, JPY, AUD, CAD and NZD.

When the instrument's profit currency differs from the selected account currency, the calculator requests the corresponding currency conversion rate through TradingView and converts the point value before calculating position size.

If the required conversion data is unavailable, the dashboard reports that the currency conversion is unavailable instead of silently producing a position size from incomplete information.

DASHBOARD AND CHART DISPLAY

The dashboard provides a summary of the planned position, including:

• Asset
• Trade direction
• Account capital
• Requested risk in percentage and account currency
• Entry price
• Stop Loss price
• Stop Loss distance
• Calculated position size
• Estimated real risk after rounding
• Calculator status

The chart can also display the Entry level, Stop Loss level, Entry-to-SL risk zone and calculated position size.

PURPOSE AND LIMITATIONS

VEK Position Size Calculator is intentionally focused on position sizing and risk management.

It does NOT:

• Generate BUY or SELL signals
• Predict market direction
• Select trades
• Recommend an Entry
• Recommend a Stop Loss
• Provide Take Profit targets
• Calculate projected trading profits
• Provide Break Even management
• Provide Profit Lock management
• Promise or estimate trading performance

The trader remains responsible for the market analysis, Entry and Stop Loss used in the calculation.

The calculator's purpose is to answer one specific risk-management question:

"Given my account size, my chosen risk and my Stop Loss distance, what position size should I use?"

IMPORTANT

Contract sizes, point values, minimum quantities and position-size increments can differ between brokers and data feeds.

Users should always verify the instrument specifications displayed by their broker before placing a trade.

If the automatic assumptions do not correspond to the broker's specifications, Native or Custom mode should be used as appropriate.

OPEN SOURCE

VEK Position Size Calculator is published as an open-source script.

The source code is publicly available so traders can inspect the calculation methodology, understand how position sizing is determined, verify the assumptions used by the calculator and adapt the educational concepts to their own risk-management process.

This tool is provided for risk-management and educational purposes. It does not constitute financial advice or a recommendation to enter any trade.

Risk first. Size second.

## Source Code

````pine
//@version=6
indicator("VEK Position Size Calculator", shorttitle="VEK Position Size", overlay=true, max_lines_count=20, max_labels_count=20, max_boxes_count=10)

//=============================================================================
// VEK LOT CALCULATOR V1.3 - PUBLIC FINAL
// Risk first. Size second.
//
// PUBLIC VERSION — intentionally focused on position sizing:
// • Interactive Entry + Stop Loss
// • Manual SL distance alternative
// • Automatic position sizing from capital + risk %
// • Automatic currency conversion
// • Automatic VEK / IC Markets lot presets on IC Markets symbols
// • TradingView-native sizing by default on other brokers / asset classes
// • Universal fallback for stocks, ETFs, futures, crypto, CFDs and other symbols
//   exposing native point value / minimum contract data
// • Manual family mapping and Custom mode remain available when broker specs require it
//
// NO signal engine.
// NO TP / RR target.
// NO projected profit.
// NO Break Even / Profit Lock.
//
// PUBLIC NOTE:
// Auto mode is deliberately conservative across brokers. When broker contract
// metadata or lot conventions differ, use Native or Custom and verify the symbol
// specifications supplied by the broker / TradingView feed.
//=============================================================================

//=============================================================================
// GROUPS
//=============================================================================
const string groupMain   = "🚀 VEK Position Size Calculator"
const string groupRisk   = "💰 Risk"
const string groupAsset  = "🏦 Asset & Broker"
const string groupVisual = "🎨 Display"

//=============================================================================
// LANGUAGE
//=============================================================================
string language = input.string(
     "English",
     "🌐 Language / Langue / Idioma",
     options=["English", "Français", "Español"],
     group=groupMain,
     display=display.none)

f_tr(string en, string fr, string es) =>
    language == "Français" ? fr : language == "Español" ? es : en

//=============================================================================
// QUICK CALCULATION SETTINGS
//=============================================================================
string calcMode = input.string(
     "Entry + SL",
     "Calculation Mode",
     options=["Entry + SL", "Manual SL Distance"],
     group=groupMain,
     tooltip="Entry + SL = place and drag both prices on the chart.\nManual SL Distance = enter the stop distance manually.",
     display=display.none)

float plannedEntry = input.price(
     0.0,
     "🎯 Entry",
     confirm=true,
     group=groupMain,
     tooltip="Interactive Entry price. Drag the level directly on the chart.",
     display=display.none)

float plannedSL = input.price(
     0.0,
     "🛑 Stop Loss",
     confirm=true,
     group=groupMain,
     tooltip="Used in Entry + SL mode. Drag the level directly on the chart.",
     display=display.none)

string manualSide = input.string(
     "BUY",
     "Direction — Manual Mode",
     options=["BUY", "SELL"],
     group=groupMain,
     tooltip="Used only when Calculation Mode = Manual SL Distance.",
     display=display.none)

float manualSLDistance = input.float(
     25.0,
     "📏 Manual SL Distance",
     minval=0.00000001,
     step=0.1,
     group=groupMain,
     tooltip="Forex = pips. VEK CFD families = points. Universal native assets = price units.",
     display=display.none)

//=============================================================================
// RISK SETTINGS
//=============================================================================
float accountSize = input.float(
     10000,
     "🏦 Account Capital",
     minval=1,
     step=100,
     group=groupRisk,
     display=display.none)

float riskPercent = input.float(
     1.0,
     "⚠️ Risk %",
     minval=0.01,
     step=0.1,
     group=groupRisk,
     tooltip="Requested maximum risk for the position before executable-size rounding.",
     display=display.none)

string accountCurrency = input.string(
     "USD",
     "💱 Account Currency",
     options=["EUR", "USD", "GBP", "CHF", "JPY", "AUD", "CAD", "NZD"],
     group=groupRisk,
     display=display.none)

//=============================================================================
// ASSET / BROKER SETTINGS
//=============================================================================
string assetOverride = input.string(
     "Auto",
     "🧩 Asset Mapping",
     options=[
         "Auto",
         "Forex",
         "Gold",
         "Silver",
         "BTC",
         "Nasdaq",
         "US30",
         "US500",
         "DAX",
         "F40",
         "AUS200",
         "UK100",
         "JP225",
         "Native",
         "Custom"
     ],
     group=groupAsset,
     tooltip="Auto uses VEK / IC Markets lot presets only on IC Markets symbols. On other brokers and asset classes it uses TradingView native point value and minimum contract data. Manual family mappings use VEK-style contract assumptions; verify your broker specs or use Custom when they differ.",
     display=display.none)

float customPointValue = input.float(
     1.0,
     "Custom Point Value / 1 Size Unit",
     minval=0.00000001,
     step=0.01,
     group=groupAsset,
     tooltip="Monetary value, in the asset profit currency, of a 1.0 price move for one custom size unit.",
     display=display.none)

string customProfitCurrency = input.string(
     "USD",
     "Custom Profit Currency",
     options=["EUR", "USD", "GBP", "CHF", "JPY", "AUD", "CAD", "NZD"],
     group=groupAsset,
     display=display.none)

float customMinSize = input.float(
     0.01,
     "Custom Minimum Size",
     minval=0.00000001,
     step=0.01,
     group=groupAsset,
     display=display.none)

float customSizeStep = input.float(
     0.01,
     "Custom Size Step",
     minval=0.00000001,
     step=0.01,
     group=groupAsset,
     display=display.none)

//=============================================================================
// DISPLAY
//=============================================================================
bool showDashboard = input.bool(true, "📊 Dashboard", group=groupVisual, display=display.none)
bool showRiskZone  = input.bool(true, "🟥 Entry → SL Risk Zone", group=groupVisual, display=display.none)
bool showLabels    = input.bool(true, "🏷 Chart Labels", group=groupVisual, display=display.none)
int visualBars     = input.int(30, "📏 Visual Length", minval=10, maxval=80, group=groupVisual, display=display.none)

//=============================================================================
// SYMBOL DETECTION
//=============================================================================
string tickerUpper = str.upper(syminfo.ticker)
string typeLower   = str.lower(syminfo.type)
string brokerUpper = str.upper(syminfo.prefix)

// Public-safe Auto mode:
// VEK broker-lot presets are applied automatically only to IC Markets symbols.
// Every other broker/feed falls back to TradingView native contract metadata.
bool isICMarkets = str.contains(brokerUpper, "ICMARKETS") or str.contains(brokerUpper, "IC MARKETS")
bool autoVEKBroker = assetOverride == "Auto" and isICMarkets

bool forceNative = assetOverride == "Native"
bool forceCustom = assetOverride == "Custom"

bool isNasdaq =
     assetOverride == "Nasdaq" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "USTEC") or
         str.contains(tickerUpper, "US100") or
         str.contains(tickerUpper, "NAS100") or
         str.contains(tickerUpper, "NASDAQ")))

bool isUS30 =
     assetOverride == "US30" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "US30") or
         str.contains(tickerUpper, "DJ30") or
         str.contains(tickerUpper, "DOW")))

bool isSP500 =
     assetOverride == "US500" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "US500") or
         str.contains(tickerUpper, "SPX500") or
         str.contains(tickerUpper, "SP500") or
         str.contains(tickerUpper, "SPX")))

bool isDAX =
     assetOverride == "DAX" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "DE40") or
         str.contains(tickerUpper, "GER40") or
         str.contains(tickerUpper, "DAX")))

bool isF40 =
     assetOverride == "F40" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "F40") or
         str.contains(tickerUpper, "FRA40") or
         str.contains(tickerUpper, "CAC40")))

bool isAUS200 =
     assetOverride == "AUS200" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "AUS200") or
         str.contains(tickerUpper, "AU200") or
         str.contains(tickerUpper, "ASX200")))

bool isUK100 =
     assetOverride == "UK100" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "UK100") or
         str.contains(tickerUpper, "FTSE100") or
         str.contains(tickerUpper, "FTSE")))

bool isJP225 =
     assetOverride == "JP225" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "JP225") or
         str.contains(tickerUpper, "JPN225") or
         str.contains(tickerUpper, "NIKKEI")))

bool isGold =
     assetOverride == "Gold" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "XAU") or
         str.contains(tickerUpper, "GOLD")))

bool isSilver =
     assetOverride == "Silver" or
     (autoVEKBroker and (
         str.contains(tickerUpper, "XAG") or
         str.contains(tickerUpper, "SILVER")))

bool isBTC =
     assetOverride == "BTC" or
     (autoVEKBroker and str.contains(tickerUpper, "BTC") and (typeLower == "cfd" or typeLower == "forex"))

bool isForex =
     assetOverride == "Forex" or
     (autoVEKBroker and typeLower == "forex" and not isGold and not isSilver and not isBTC)

bool isIndex = isNasdaq or isUS30 or isSP500 or isDAX or isF40 or isAUS200 or isUK100 or isJP225
bool isKnownVEKFamily = isForex or isGold or isSilver or isBTC or isIndex

// Auto universal fallback: any symbol not mapped to a known VEK broker-lot family
// uses TradingView native contract metadata.
bool useNative = forceNative or (assetOverride == "Auto" and not isKnownVEKFamily)
bool useCustom = forceCustom

//=============================================================================
// SIZE MODE / LABELS
//=============================================================================
string nativeUnitName =
     typeLower == "stock" or typeLower == "fund" or typeLower == "dr" ? f_tr("shares", "actions", "acciones") :
     typeLower == "futures" ? f_tr("contracts", "contrats", "contratos") :
     typeLower == "cfd" ? f_tr("contracts", "contrats", "contratos") :
     typeLower == "crypto" ? f_tr("units", "unités", "unidades") :
     typeLower == "index" ? f_tr("contracts", "contrats", "contratos") :
     f_tr("units", "unités", "unidades")

string sizeUnitName =
     isKnownVEKFamily ? f_tr("lots", "lots", "lotes") :
     useCustom ? f_tr("units", "unités", "unidades") :
     nativeUnitName

//=============================================================================
// PROFIT CURRENCY + CURRENCY CONVERSION
//=============================================================================
string nativeSymbolCurrency = syminfo.currency == "" ? accountCurrency : syminfo.currency

string profitCurrency =
     isForex ? syminfo.currency :
     isDAX or isF40 ? "EUR" :
     isUK100 ? "GBP" :
     isJP225 ? "JPY" :
     isAUS200 ? "AUD" :
     isGold or isSilver or isBTC or isNasdaq or isUS30 or isSP500 ? "USD" :
     useCustom ? customProfitCurrency :
     nativeSymbolCurrency

float currencyConversion =
     profitCurrency == accountCurrency ? 1.0 : request.currency_rate(profitCurrency, accountCurrency, true)

//=============================================================================
// VALUE PER 1.0 PRICE MOVE FOR ONE SIZE UNIT
//=============================================================================
float nativePointValue =
     isForex ? 100000.0 :
     isGold ? 100.0 :
     isSilver ? 1000.0 :
     isBTC ? 1.0 :
     isIndex ? 1.0 :
     useCustom ? customPointValue :
     syminfo.pointvalue

float pointValueAccount =
     not na(nativePointValue) and nativePointValue > 0 and not na(currencyConversion)
     ? nativePointValue * currencyConversion
     : na

//=============================================================================
// MINIMUM SIZE / SIZE STEP
// Known VEK families retain broker-style lot conventions.
// Universal native mode uses TradingView's minimum contract as both minimum and
// practical quantity increment fallback because Pine exposes no universal broker
// lot-step field for every possible symbol.
//=============================================================================
float tvMinContract = not na(syminfo.mincontract) and syminfo.mincontract > 0 ? syminfo.mincontract : 1.0

float minSize =
     isJP225 ? 1.00 :
     isIndex ? 0.10 :
     isForex or isGold or isSilver or isBTC ? 0.01 :
     useCustom ? customMinSize :
     tvMinContract

float sizeStep =
     isJP225 ? 1.00 :
     isIndex ? 0.10 :
     isForex or isGold or isSilver or isBTC ? 0.01 :
     useCustom ? customSizeStep :
     tvMinContract

//=============================================================================
// DISPLAY DISTANCE UNIT
//=============================================================================
bool symbolIsSpotForex =
     typeLower == "forex" and
     not str.contains(tickerUpper, "XAU") and
     not str.contains(tickerUpper, "XAG") and
     not str.contains(tickerUpper, "BTC") and
     not str.contains(tickerUpper, "ETH")

bool usePipDistance = isForex or (useNative and symbolIsSpotForex)

float displayUnitSize =
     usePipDistance ? (str.contains(tickerUpper, "JPY") ? 0.01 : 0.0001) : 1.0

string distanceUnit =
     usePipDistance ? "pips" :
     isKnownVEKFamily ? f_tr("points", "points", "puntos") :
     f_tr("price units", "unités de prix", "unidades de precio")

//=============================================================================
// ENTRY / STOP GEOMETRY
//=============================================================================
bool entryConfigured = plannedEntry > 0
float activeEntry = plannedEntry

float manualPriceDistance = manualSLDistance * displayUnitSize

float activeSL =
     calcMode == "Entry + SL" ? plannedSL :
     manualSide == "BUY" ? activeEntry - manualPriceDistance : activeEntry + manualPriceDistance

bool slConfigured = calcMode == "Entry + SL" ? plannedSL > 0 : manualSLDistance > 0

float priceRiskDistance =
     entryConfigured and slConfigured ? math.abs(activeEntry - activeSL) : na

float displayedSLDistance =
     not na(priceRiskDistance) ? priceRiskDistance / displayUnitSize : na

string tradeSide =
     calcMode == "Entry + SL" ?
         activeSL < activeEntry ? "BUY" : activeSL > activeEntry ? "SELL" : "-" :
         manualSide

bool isBuy = tradeSide == "BUY"

//=============================================================================
// POSITION SIZE ENGINE
//=============================================================================
float requestedRisk = accountSize * riskPercent / 100.0

float rawSize =
     not na(priceRiskDistance) and priceRiskDistance > 0 and
     not na(pointValueAccount) and pointValueAccount > 0
     ? requestedRisk / (priceRiskDistance * pointValueAccount)
     : na

// Conservative free calculator: always round DOWN to the executable/native step.
float calculatedSize =
     not na(rawSize) and sizeStep > 0
     ? math.floor(rawSize / sizeStep + 1e-9) * sizeStep
     : na

bool belowMinimumSize = not na(calculatedSize) and calculatedSize < minSize
float finalSize = belowMinimumSize ? 0.0 : calculatedSize

float realRisk =
     finalSize > 0 and not na(priceRiskDistance) and not na(pointValueAccount)
     ? priceRiskDistance * pointValueAccount * finalSize
     : na

float realRiskPct =
     not na(realRisk) and accountSize > 0 ? realRisk / accountSize * 100.0 : na

float minimumSizeRisk =
     not na(priceRiskDistance) and not na(pointValueAccount)
     ? priceRiskDistance * pointValueAccount * minSize
     : na

float minimumSizeRiskPct =
     not na(minimumSizeRisk) and accountSize > 0
     ? minimumSizeRisk / accountSize * 100.0
     : na

//=============================================================================
// READINESS / STATUS
//=============================================================================
bool geometryReady =
     entryConfigured and slConfigured and not na(priceRiskDistance) and priceRiskDistance > 0

bool currencyReady = not na(currencyConversion)
bool pointValueReady = not na(nativePointValue) and nativePointValue > 0
bool sizeRulesReady = minSize > 0 and sizeStep > 0

bool calculatorReady =
     geometryReady and currencyReady and pointValueReady and sizeRulesReady and finalSize > 0

string status =
     not entryConfigured ? f_tr("PLACE ENTRY", "PLACEZ L’ENTRÉE", "COLOQUE LA ENTRADA") :
     not slConfigured ? f_tr("PLACE STOP LOSS", "PLACEZ LE STOP LOSS", "COLOQUE EL STOP LOSS") :
     not currencyReady ? f_tr("FX CONVERSION UNAVAILABLE", "CONVERSION DEVISE INDISPONIBLE", "CONVERSIÓN DE DIVISA NO DISPONIBLE") :
     not pointValueReady ? f_tr("POINT VALUE UNAVAILABLE → USE CUSTOM", "VALEUR DU POINT INDISPONIBLE → UTILISEZ CUSTOM", "VALOR DEL PUNTO NO DISPONIBLE → USE CUSTOM") :
     belowMinimumSize ? f_tr("BELOW MINIMUM SIZE", "SOUS LA TAILLE MINIMALE", "POR DEBAJO DEL TAMAÑO MÍNIMO") :
     calculatorReady ? f_tr("READY", "PRÊT", "LISTO") :
     f_tr("CHECK SETTINGS", "VÉRIFIEZ LES RÉGLAGES", "REVISE LOS AJUSTES")

//=============================================================================
// FORMATTING
//=============================================================================
f_money(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##") + " " + accountCurrency

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_size(float value) =>
    na(value) or value <= 0 ? "-" :
     value >= 1000 ? str.tostring(value, "#.##") :
     value >= 1 ? str.tostring(value, "#.####") :
     str.tostring(value, "#.########")

//=============================================================================
// CHART VISUALS
//=============================================================================
var line entryLine = na
var line slLine = na
var label entryLabel = na
var label slLabel = na
var label sizeBadge = na
var box riskBox = na

if barstate.islast
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(sizeBadge)
        label.delete(sizeBadge)
    if not na(riskBox)
        box.delete(riskBox)

    if geometryReady
        int x1 = math.max(0, bar_index - visualBars)
        int x2 = bar_index + 3

        if showRiskZone
            riskBox := box.new(
                 left=x1,
                 top=math.max(activeEntry, activeSL),
                 right=x2,
                 bottom=math.min(activeEntry, activeSL),
                 xloc=xloc.bar_index,
                 border_color=color.new(color.red, 74),
                 bgcolor=color.new(color.red, 91))

        entryLine := line.new(
             x1,
             activeEntry,
             x2,
             activeEntry,
             xloc=xloc.bar_index,
             color=isBuy ? color.aqua : color.orange,
             width=2,
             style=line.style_dashed)

        slLine := line.new(
             x1,
             activeSL,
             x2,
             activeSL,
             xloc=xloc.bar_index,
             color=color.red,
             width=2)

        if showLabels
            entryLabel := label.new(
                 x2,
                 activeEntry,
                 f_tr("ENTRY", "ENTRÉE", "ENTRADA"),
                 xloc=xloc.bar_index,
                 style=label.style_label_right,
                 textcolor=color.white,
                 color=color.new(isBuy ? color.teal : color.orange, 15),
                 size=size.tiny)

            slLabel := label.new(
                 x2,
                 activeSL,
                 f_tr("STOP LOSS", "STOP LOSS", "STOP LOSS") +
                 "\n" +
                 str.tostring(displayedSLDistance, "#.##") + " " + distanceUnit,
                 xloc=xloc.bar_index,
                 style=label.style_label_right,
                 textcolor=color.white,
                 color=color.new(color.red, 15),
                 size=size.tiny)

        if calculatorReady
            float badgeOffset = math.max(priceRiskDistance * 0.25, syminfo.mintick * 10)
            float badgeY = isBuy ? activeEntry + badgeOffset : activeEntry - badgeOffset

            sizeBadge := label.new(
                 bar_index,
                 badgeY,
                 f_tr("VEK POSITION SIZE", "TAILLE POSITION VEK", "TAMAÑO POSICIÓN VEK") +
                 "\n" +
                 f_size(finalSize) + " " + str.upper(sizeUnitName),
                 xloc=xloc.bar_index,
                 style=isBuy ? label.style_label_down : label.style_label_up,
                 textcolor=color.white,
                 color=color.new(color.blue, 10),
                 size=size.normal)

//=============================================================================
// DASHBOARD — adaptive light/dark theme
//=============================================================================
color dashBase = color.from_gradient(0.10, 0.0, 1.0, chart.bg_color, chart.fg_color)
color dashAlt  = color.from_gradient(0.17, 0.0, 1.0, chart.bg_color, chart.fg_color)
color dashText = chart.fg_color

color bluePanel    = color.new(color.blue, 42)
color greenPanel   = color.new(color.green, 42)
color redPanel     = color.new(color.red, 40)
color orangePanel  = color.new(color.orange, 42)
color tealPanel    = color.new(color.teal, 42)
color neutralPanel = dashAlt

f_cell(table t, int row, string leftText, string rightText, color rightColor) =>
    table.cell(t, 0, row, leftText, text_color=dashText, bgcolor=dashBase)
    table.cell(t, 1, row, rightText, text_color=dashText, bgcolor=rightColor)

var table dash = table.new(
     position.top_right,
     2,
     12,
     border_width=1,
     border_color=color.new(chart.fg_color, 65))

if barstate.islast
    table.clear(dash, 0, 0, 1, 11)

    if showDashboard
        table.cell(
             dash,
             0,
             0,
             "VEK POSITION SIZE",
             text_color=color.white,
             bgcolor=bluePanel,
             text_size=size.normal)

        table.cell(
             dash,
             1,
             0,
             "RISK TOOL",
             text_color=color.white,
             bgcolor=bluePanel,
             text_size=size.normal)

        f_cell(
             dash,
             1,
             f_tr("Risk first.", "Le risque d'abord.", "Primero el riesgo."),
             f_tr("Size second.", "Le lot ensuite.", "Después el tamaño."),
             color.new(color.blue, 60))

        f_cell(
             dash,
             2,
             f_tr("Asset", "Actif", "Activo"),
             syminfo.ticker,
             neutralPanel)

        f_cell(
             dash,
             3,
             f_tr("Direction", "Direction", "Dirección"),
             tradeSide,
             tradeSide == "BUY" ? color.new(color.green, 50) : tradeSide == "SELL" ? color.new(color.red, 50) : neutralPanel)

        f_cell(
             dash,
             4,
             f_tr("Account", "Capital", "Capital"),
             f_money(accountSize),
             neutralPanel)

        f_cell(
             dash,
             5,
             f_tr("Requested Risk", "Risque demandé", "Riesgo solicitado"),
             str.tostring(riskPercent, "#.##") + "%  •  " + f_money(requestedRisk),
             orangePanel)

        f_cell(
             dash,
             6,
             f_tr("Entry", "Entrée", "Entrada"),
             f_price(activeEntry),
             tealPanel)

        f_cell(
             dash,
             7,
             "Stop Loss",
             f_price(activeSL),
             redPanel)

        f_cell(
             dash,
             8,
             f_tr("SL Distance", "Distance SL", "Distancia SL"),
             not na(displayedSLDistance) ? str.tostring(displayedSLDistance, "#.##") + " " + distanceUnit : "-",
             orangePanel)

        string sizeDisplay =
             calculatorReady ? f_size(finalSize) + " " + sizeUnitName :
             belowMinimumSize ? "< " + f_size(minSize) + " " + sizeUnitName : "-"

        f_cell(
             dash,
             9,
             f_tr("POSITION SIZE", "TAILLE POSITION", "TAMAÑO POSICIÓN"),
             sizeDisplay,
             calculatorReady ? greenPanel : redPanel)

        string realRiskDisplay =
             calculatorReady ? f_money(realRisk) + "  •  " + str.tostring(realRiskPct, "#.##") + "%" : "-"

        f_cell(
             dash,
             10,
             f_tr("Real Risk", "Risque réel", "Riesgo real"),
             realRiskDisplay,
             calculatorReady ? greenPanel : neutralPanel)

        string statusDisplay =
             belowMinimumSize
             ? f_tr("Min size risk: ", "Risque taille mini : ", "Riesgo tamaño mín.: ") +
               f_money(minimumSizeRisk) + " (" + str.tostring(minimumSizeRiskPct, "#.##") + "%)"
             : status

        f_cell(
             dash,
             11,
             f_tr("Status", "État", "Estado"),
             statusDisplay,
             calculatorReady ? greenPanel : belowMinimumSize ? orangePanel : redPanel)
````
