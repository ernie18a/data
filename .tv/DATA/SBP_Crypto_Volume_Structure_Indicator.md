<!-- tradingview-pine-id: PUB;158266180e1541e8a9e1cc1965513379 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# SBP Crypto Volume Structure Indicator

Source: https://www.tradingview.com/script/OC301v36-SBP-Crypto-Volume-Structure-Indicator/

## Description

SBP Crypto Volume Structure Indicator is a crypto-specific price and volume structure framework designed to organize continuous 24/7 market movement into a developing value region and a confirmed directional signal state.

The indicator is based on the idea that cryptocurrency markets frequently move through alternating phases of value formation, expansion and acceptance. Instead of treating every price movement as an independent trend signal, the framework first estimates where trading activity has been concentrated within a rolling market window. It then evaluates whether price is remaining within that developed area or establishing itself outside it.

The central component is the Value Channel.

For the active rolling window, the script divides the observed price range into multiple price rows. The volume of each completed candle is distributed across the rows covered by that candle. The rows containing the greatest concentration of accumulated volume are then expanded around the dominant area until the required core participation percentage is reached.

This calculation creates an internal upper and lower structural region representing the part of the recent market range where a significant portion of trading activity has taken place.

The Value Channel is derived from this structural region rather than from a fixed percentage of price or a conventional moving-price envelope. Its centre is based on the developing structural range, while its width is related to the distance between the upper and lower structural boundaries. A volatility floor is also applied so the channel does not become unrealistically narrow during temporarily quiet market conditions.

Because cryptocurrency markets trade continuously, abrupt changes can occur when a large candle enters the rolling window or an older high-volume move leaves it. To reduce unnecessary visual jumps, the internal structure does not relocate instantly to every newly calculated level. Instead, the framework allows the structural region and Value Channel to migrate progressively toward the latest calculated values.

The second part of the framework evaluates price acceptance.

A Buy condition is not created simply because price touches or briefly crosses the upper side of the Value Channel. The script examines whether the candle is sufficiently established above the developed value region and whether the candle body shows adequate directional quality.

Similarly, a Sale condition requires meaningful establishment below the lower Value Channel rather than a temporary wick below the region.

The directional qualification process combines several related measurements: short-term versus slower price direction, directional movement balance, recent momentum, distance from the developing centre and the position of price relative to the Value Channel. These measurements are combined internally to determine whether the apparent breakout or continuation is sufficiently supported by current market behaviour.

The signal engine recognizes several related structural situations. These include decisive movement outside the Value Channel, successful interaction with a previously crossed channel boundary and continuation after price has already established itself outside the value region.

These are not separate indicators placed together on the chart. They are stages of one process: volume distribution establishes the structural context, the Value Channel defines the active value region, directional measurements evaluate acceptance, and the final state engine decides whether a Buy or Sale condition is qualified.

The indicator also applies a strict alternating signal sequence. After a Buy has been accepted, another Buy cannot print until a valid Sale condition occurs. After a Sale, another Sale cannot print until a valid Buy occurs. This helps prevent repeated same-direction labels during one continuous movement.

Signals are evaluated on confirmed bars only. The script does not intentionally use future data or negative plot offsets.

The indicator should be used as a structural market-analysis tool rather than as a prediction of future price. Crypto assets can experience rapid volatility, gaps between liquidity conditions, liquidation-driven moves and temporary false breakouts. Users should therefore evaluate the signals together with their own risk management, timeframe selection and broader market context.

---

## Source Code

````pine
//@version=6
indicator(
    "SBP Crypto Volume Structure Indicator",
    overlay = true,
    max_bars_back = 600,
    max_labels_count = 100
)

string GROUP_PROFILE = "01. Crypto Profile"
string GROUP_DISPLAY = "02. Display"
string GROUP_LEVEL = "03. Session Structure"
string GROUP_STYLE = "04. Colours / Width"
string cryptoProfile = input.string(
    "Automatic",
    "Crypto Profile",
    options = [
        "Automatic",
        "Bitcoin",
        "Ethereum",
        "Solana",
        "XRP",
        "BNB",
        "Dogecoin",
        "Cardano",
        "Avalanche",
        "Chainlink",
        "Sui",
        "Hyperliquid",
        "Zcash",
        "NEAR",
        "Uniswap",
        "Bitcoin Cash",
        "TRON",
        "Litecoin",
        "PEPE",
        "Gold-Backed",
        "Altcoin"
    ],
    group = GROUP_PROFILE
)
int structureLength = input.int(
    180,
    "Rolling Structure Bars",
    minval = 60,
    maxval = 360,
    group = GROUP_PROFILE
)
bool showSignals = input.bool(
    true,
    "Show Buy / Sale",
    group = GROUP_DISPLAY
)
bool showRibbon = input.bool(
    true,
    "Show Directional Strength Ribbon",
    group = GROUP_DISPLAY
)
bool showDvclLine = input.bool(
    true,
    "Show DVCL Line",
    group = GROUP_DISPLAY
)
bool showDvclChannel = input.bool(
    true,
    "Show DVCL Channel",
    group = GROUP_DISPLAY
)
bool showExtendedStructure = input.bool(
    true,
    "Show Extended Structure Boundaries",
    group = GROUP_DISPLAY
)
bool showValueChannel = input.bool(
    false,
    "Show Value Channel",
    group = GROUP_DISPLAY
)
color ribbonBullColor = input.color(
    color.new(color.blue, 58),
    "Bullish Ribbon",
    group = GROUP_STYLE
)
color ribbonBearColor = input.color(
    color.new(color.red, 58),
    "Bearish Ribbon",
    group = GROUP_STYLE
)
color dvclLineColor = input.color(
    color.orange,
    "DVCL Line Colour",
    group = GROUP_STYLE
)
color dvclBullColor = input.color(
    color.new(color.green, 84),
    "Bullish DVCL Channel",
    group = GROUP_STYLE
)
color dvclBearColor = input.color(
    color.new(color.red, 84),
    "Bearish DVCL Channel",
    group = GROUP_STYLE
)
color dvclBoundaryColor = input.color(
    color.new(color.gray, 70),
    "DVCL Boundary",
    group = GROUP_STYLE
)
color extendedUpperColor = input.color(
    color.new(color.blue, 20),
    "Upper Structure",
    group = GROUP_STYLE
)
color extendedLowerColor = input.color(
    color.new(color.blue, 20),
    "Lower Structure",
    group = GROUP_STYLE
)
color valueBullColor = input.color(
    color.new(color.green, 86),
    "Bullish Value Channel",
    group = GROUP_STYLE
)
color valueBearColor = input.color(
    color.new(color.red, 86),
    "Bearish Value Channel",
    group = GROUP_STYLE
)
int levelWidth = input.int(
    1,
    "Session Level Width",
    minval = 1,
    maxval = 4,
    group = GROUP_STYLE
)
f_clamp(float value) =>
    math.max(-1.0, math.min(1.0, value))

f_safe_div(float numerator, float denominator) =>
    math.abs(denominator) > 0.0000001 ? numerator / denominator : 0.0

f_profile_factor(string selectedProfile) =>
    string symbolText = str.upper(syminfo.ticker)
    bool autoBitcoin = str.contains(symbolText, "BTC") and not str.contains(symbolText, "BCH")
    bool autoEthereum = str.contains(symbolText, "ETH")
    bool autoSolana = str.contains(symbolText, "SOL")
    bool autoXrp = str.contains(symbolText, "XRP")
    bool autoBnb = str.contains(symbolText, "BNB")
    bool autoDoge = str.contains(symbolText, "DOGE")
    bool autoAda = str.contains(symbolText, "ADA")
    bool autoAvax = str.contains(symbolText, "AVAX")
    bool autoLink = str.contains(symbolText, "LINK")
    bool autoSui = str.contains(symbolText, "SUI")
    bool autoHype = str.contains(symbolText, "HYPE")
    bool autoZec = str.contains(symbolText, "ZEC")
    bool autoNear = str.contains(symbolText, "NEAR")
    bool autoUni = str.contains(symbolText, "UNI")
    bool autoBch = str.contains(symbolText, "BCH")
    bool autoTrx = str.contains(symbolText, "TRX")
    bool autoLtc = str.contains(symbolText, "LTC")
    bool autoPepe = str.contains(symbolText, "PEPE")
    bool autoGold = str.contains(symbolText, "PAXG") or str.contains(symbolText, "XAUT")
    float automaticFactor = autoBitcoin ? 1.00 : autoEthereum ? 1.04 : autoSolana ? 1.14 : autoXrp ? 1.12 : autoBnb ? 1.06 : autoDoge ? 1.20 : autoAda ? 1.16 : autoAvax ? 1.18 : autoLink ? 1.12 : autoSui ? 1.22 : autoHype ? 1.24 : autoZec ? 1.25 : autoNear ? 1.19 : autoUni ? 1.17 : autoBch ? 1.13 : autoTrx ? 1.07 : autoLtc ? 1.10 : autoPepe ? 1.28 : autoGold ? 0.82 : 1.20
    float selectedFactor = selectedProfile == "Bitcoin" ? 1.00 : selectedProfile == "Ethereum" ? 1.04 : selectedProfile == "Solana" ? 1.14 : selectedProfile == "XRP" ? 1.12 : selectedProfile == "BNB" ? 1.06 : selectedProfile == "Dogecoin" ? 1.20 : selectedProfile == "Cardano" ? 1.16 : selectedProfile == "Avalanche" ? 1.18 : selectedProfile == "Chainlink" ? 1.12 : selectedProfile == "Sui" ? 1.22 : selectedProfile == "Hyperliquid" ? 1.24 : selectedProfile == "Zcash" ? 1.25 : selectedProfile == "NEAR" ? 1.19 : selectedProfile == "Uniswap" ? 1.17 : selectedProfile == "Bitcoin Cash" ? 1.13 : selectedProfile == "TRON" ? 1.07 : selectedProfile == "Litecoin" ? 1.10 : selectedProfile == "PEPE" ? 1.28 : selectedProfile == "Gold-Backed" ? 0.82 : selectedProfile == "Altcoin" ? 1.20 : automaticFactor
    selectedFactor

bool confirmedBar = barstate.isconfirmed
float profileFactor = f_profile_factor(cryptoProfile)
float atr14 = math.max(ta.atr(14), syminfo.mintick)
float candleRange = math.max(high - low, syminfo.mintick)
float candleBody = math.abs(close - open)
float bodyEfficiency = math.min(candleBody / candleRange, 1.0)
float closeLocation = math.min(math.max((close - low) / candleRange, 0.0), 1.0)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

float volumeCenter = ta.vwma(hlc3, structureLength)
float priceDeviation = ta.stdev(hlc3, structureLength)
float structureDeviation = math.max(nz(priceDeviation, atr14), atr14 * 0.55)

float volumeMean = ta.sma(volume, 20)
float relativeVolume = not na(volumeMean) and volumeMean > 0.0 ? volume / volumeMean : 1.0
float signedParticipation = volume * ((closeLocation - 0.50) * 2.0)
float participationBase = ta.ema(volume, 14)
float participationBiasRaw = f_safe_div(ta.ema(signedParticipation, 14), participationBase)
float participationBias = f_clamp(participationBiasRaw)

float centerSlope = f_clamp(f_safe_div(volumeCenter - volumeCenter[1], atr14))
float displacement = f_clamp(f_safe_div(close - volumeCenter, structureDeviation))
float directionalEvidence = participationBias * 0.45 + centerSlope * 0.30 + displacement * 0.25

float dynamicDvcl = volumeCenter + structureDeviation * participationBias * 0.32
float dynamicDvclHalfWidth = math.max(structureDeviation * 0.20, atr14 * 0.18 * profileFactor)
float dynamicDvclUpper = dynamicDvcl + dynamicDvclHalfWidth
float dynamicDvclLower = dynamicDvcl - dynamicDvclHalfWidth

float dynamicUpperStructure = volumeCenter + structureDeviation * 1.80 * profileFactor
float dynamicLowerStructure = volumeCenter - structureDeviation * 1.80 * profileFactor

float valueHalfWidth = math.max(structureDeviation * 0.55, atr14 * 0.48 * profileFactor)
float valueUpper = volumeCenter + valueHalfWidth
float valueLower = volumeCenter - valueHalfWidth

bool newSession = ta.change(time("D")) != 0

var float sessionDvcl = na
var float sessionDvclUpper = na
var float sessionDvclLower = na
var float sessionUpperStructure = na
var float sessionLowerStructure = na

if confirmedBar and (na(sessionDvcl) or newSession)
    sessionDvcl := dynamicDvcl
    sessionDvclUpper := dynamicDvclUpper
    sessionDvclLower := dynamicDvclLower
    sessionUpperStructure := dynamicUpperStructure
    sessionLowerStructure := dynamicLowerStructure

bool valueBull = close > volumeCenter and directionalEvidence >= 0.0
bool valueBear = close < volumeCenter and directionalEvidence < 0.0

float ribbonBasis = ta.ema(hlc3, 7)
float ribbonSlope = f_safe_div(ribbonBasis - ribbonBasis[1], atr14)
bool ribbonBull = directionalEvidence >= 0.10 and ribbonSlope >= -0.02 and close >= volumeCenter
bool ribbonBear = directionalEvidence <= -0.10 and ribbonSlope <= 0.02 and close <= volumeCenter
float ribbonWidth = math.max(atr14 * 0.34, math.abs(close - ribbonBasis) * 0.50)
float ribbonUpper = ribbonBull ? ribbonBasis + ribbonWidth : ribbonBear ? ribbonBasis : na
float ribbonLower = ribbonBull ? ribbonBasis : ribbonBear ? ribbonBasis - ribbonWidth : na

int liquidityLookback = profileFactor >= 1.22 ? 6 : profileFactor >= 1.14 ? 7 : 8
int microLookback = profileFactor >= 1.22 ? 2 : 3

float priorLow = ta.lowest(low[1], liquidityLookback)
float priorHigh = ta.highest(high[1], liquidityLookback)
float microHigh = ta.highest(high[1], microLookback)
float microLow = ta.lowest(low[1], microLookback)

bool bullSweep = confirmedBar and low < priorLow and close > priorLow
bool bearSweep = confirmedBar and high > priorHigh and close < priorHigh
bool bullMicroBreak = confirmedBar and close > microHigh and close > open
bool bearMicroBreak = confirmedBar and close < microLow and close < open

bool participationExpansion = relativeVolume >= (profileFactor >= 1.22 ? 0.92 : profileFactor >= 1.14 ? 0.95 : 0.98)

bool bullishAcceptance = confirmedBar and close > valueUpper and close > sessionDvclUpper and directionalEvidence >= 0.14 and bodyEfficiency >= 0.34 and closeLocation >= 0.62
bool bearishAcceptance = confirmedBar and close < valueLower and close < sessionDvclLower and directionalEvidence <= -0.14 and bodyEfficiency >= 0.34 and closeLocation <= 0.38

bool bullishReclaim = confirmedBar and low <= sessionDvclLower and close > sessionDvclUpper and directionalEvidence >= 0.16 and lowerWick > upperWick and bodyEfficiency >= 0.28
bool bearishReclaim = confirmedBar and high >= sessionDvclUpper and close < sessionDvclLower and directionalEvidence <= -0.16 and upperWick > lowerWick and bodyEfficiency >= 0.28

bool bullishLiquidityTurn = bullSweep and bullMicroBreak and participationExpansion and directionalEvidence >= 0.12 and close > sessionDvcl
bool bearishLiquidityTurn = bearSweep and bearMicroBreak and participationExpansion and directionalEvidence <= -0.12 and close < sessionDvcl

bool rejectBuy = not na(sessionUpperStructure) and high >= sessionUpperStructure and close < sessionUpperStructure
bool rejectSale = not na(sessionLowerStructure) and low <= sessionLowerStructure and close > sessionLowerStructure

float buyQuality = directionalEvidence * 100.0 + closeLocation * 20.0 + bodyEfficiency * 15.0 + (participationExpansion ? 10.0 : 0.0)
float saleQuality = -directionalEvidence * 100.0 + (1.0 - closeLocation) * 20.0 + bodyEfficiency * 15.0 + (participationExpansion ? 10.0 : 0.0)

bool buyCandidate = (bullishAcceptance or bullishReclaim or bullishLiquidityTurn) and not rejectBuy and buyQuality >= 35.0
bool saleCandidate = (bearishAcceptance or bearishReclaim or bearishLiquidityTurn) and not rejectSale and saleQuality >= 35.0

bool finalBuyCandidate = buyCandidate
bool finalSaleCandidate = saleCandidate

if finalBuyCandidate and finalSaleCandidate
    if directionalEvidence > 0.0
        finalSaleCandidate := false
    else if directionalEvidence < 0.0
        finalBuyCandidate := false
    else
        finalBuyCandidate := false
        finalSaleCandidate := false

var int signalState = 0
bool buySignal = false
bool saleSignal = false

if confirmedBar
    if signalState == 0
        if finalBuyCandidate and not finalSaleCandidate
            buySignal := true
            signalState := 1
        else if finalSaleCandidate and not finalBuyCandidate
            saleSignal := true
            signalState := -1
    else if signalState == 1
        if finalSaleCandidate
            saleSignal := true
            signalState := -1
    else
        if finalBuyCandidate
            buySignal := true
            signalState := 1

var int dvclState = 0

if confirmedBar
    if close > sessionDvcl and directionalEvidence >= 0.0
        dvclState := 1
    else if close < sessionDvcl and directionalEvidence < 0.0
        dvclState := -1

color activeDvclColor = dvclState == 1 ? dvclBullColor : dvclState == -1 ? dvclBearColor : color.new(color.gray, 90)
color activeValueColor = valueBull ? valueBullColor : valueBear ? valueBearColor : color.new(color.gray, 90)
color activeRibbonColor = ribbonBull ? ribbonBullColor : ribbonBear ? ribbonBearColor : na

valueUpperPlot = plot(
    showValueChannel ? valueUpper : na,
    "Value Upper",
    color = color.new(color.gray, 100),
    editable = false
)

valueLowerPlot = plot(
    showValueChannel ? valueLower : na,
    "Value Lower",
    color = color.new(color.gray, 100),
    editable = false
)

fill(
    valueUpperPlot,
    valueLowerPlot,
    color = showValueChannel ? activeValueColor : na,
    title = "Value Channel"
)

plot(
    showDvclLine ? sessionDvcl : na,
    "DVCL",
    color = dvclLineColor,
    linewidth = 2,
    style = plot.style_stepline,
    editable = false
)

dvclUpperPlot = plot(
    showDvclChannel ? sessionDvclUpper : na,
    "DVCL Upper",
    color = dvclBoundaryColor,
    linewidth = 1,
    style = plot.style_stepline,
    editable = false
)

dvclLowerPlot = plot(
    showDvclChannel ? sessionDvclLower : na,
    "DVCL Lower",
    color = dvclBoundaryColor,
    linewidth = 1,
    style = plot.style_stepline,
    editable = false
)

fill(
    dvclUpperPlot,
    dvclLowerPlot,
    color = showDvclChannel ? activeDvclColor : na,
    title = "DVCL Channel"
)

plot(
    showExtendedStructure ? sessionUpperStructure : na,
    "Upper Structure",
    color = extendedUpperColor,
    linewidth = levelWidth,
    style = plot.style_stepline,
    editable = false
)

plot(
    showExtendedStructure ? sessionLowerStructure : na,
    "Lower Structure",
    color = extendedLowerColor,
    linewidth = levelWidth,
    style = plot.style_stepline,
    editable = false
)

ribbonUpperPlot = plot(
    showRibbon ? ribbonUpper : na,
    "Ribbon Upper",
    color = color.new(color.gray, 100),
    editable = false
)

ribbonLowerPlot = plot(
    showRibbon ? ribbonLower : na,
    "Ribbon Lower",
    color = color.new(color.gray, 100),
    editable = false
)

fill(
    ribbonUpperPlot,
    ribbonLowerPlot,
    color = showRibbon ? activeRibbonColor : na,
    title = "Directional Strength Ribbon"
)

plotshape(
    showSignals and buySignal,
    title = "Buy",
    text = "Buy",
    style = shape.labelup,
    location = location.belowbar,
    color = color.green,
    textcolor = color.white,
    size = size.tiny,
    editable = false
)

plotshape(
    showSignals and saleSignal,
    title = "Sale",
    text = "Sale",
    style = shape.labeldown,
    location = location.abovebar,
    color = color.red,
    textcolor = color.white,
    size = size.tiny,
    editable = false
)

alertcondition(
    buySignal,
    "Buy",
    "SBP Crypto Volume Structure Indicator: Buy"
)

alertcondition(
    saleSignal,
    "Sale",
    "SBP Crypto Volume Structure Indicator: Sale"
)

alertcondition(
    buySignal or saleSignal,
    "Buy or Sale",
    "SBP Crypto Volume Structure Indicator: New Buy or Sale signal"
)
````
