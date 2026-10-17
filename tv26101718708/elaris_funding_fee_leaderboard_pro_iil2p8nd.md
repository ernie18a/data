# Elaris Funding Fee Leaderboard Pro

- url: https://www.tradingview.com/script/iIl2p8nd-Elaris-Funding-Fee-Leaderboard-Pro/
- type: indicator
- pine_id: PUB;a9460aaffab24b61977320a7c1ad59d8
- version: 1.0

## Description

# Elaris Funding Fee Leaderboard Pro

Elaris Funding Fee Leaderboard Pro is a funding-rate analytics indicator designed for cryptocurrency futures traders who want to monitor market positioning and sentiment through perpetual funding behavior.

The indicator estimates and visualizes funding conditions using Binance premium index data while also ranking a curated universe of major Binance Futures markets in real time.

Instead of only displaying the current chart’s funding estimate, the indicator includes a leaderboard that highlights the highest and lowest funding environments across multiple futures pairs, helping traders quickly identify crowded positioning, elevated speculation, or potential mean-reversion conditions.

---

## Features

### Funding Fee Estimation

* Calculates estimated funding conditions using premium index behavior
* Smooth weighted averaging logic for cleaner readings
* Dynamic funding visualization with positive/negative market bias

### Top & Bottom Funding Leaderboard

* Displays the highest estimated funding markets
* Displays the lowest estimated funding markets
* Real-time ranking dashboard directly on the main chart

### Professional Dashboard UI

* Optimized for both dark and light TradingView themes
* Minimal and clean visual design
* Main-chart overlay dashboard with organized funding statistics

### Multi-Asset Futures Monitoring

Tracks a curated set of major Binance Futures pairs including:

* BTC
* ETH
* SOL
* BNB
* XRP
* DOGE
* AVAX
* LINK
* ADA
* and more

### Alerts

Includes alert conditions for:

* Extreme positive funding conditions
* Extreme negative funding conditions
* Leaderboard funding extremes
* Current chart funding thresholds

---

## How Traders Commonly Use Funding Data

Funding conditions are often used by traders to:

* Monitor speculative positioning
* Detect crowded market conditions
* Identify elevated long or short bias
* Observe potential exhaustion environments
* Compare relative sentiment across futures markets

Funding information should be used as contextual market data and not as a standalone trading signal.

---

## Notes

* The leaderboard operates on a curated Binance Futures universe due to Pine Script symbol-request limitations.
* Uses non-repainting request logic with lookahead disabled.
* Intended for educational and analytical purposes only.
* This script does not provide financial advice or guaranteed market predictions.

## Source Code

````pine
//@version=6
indicator("Elaris Funding Fee Leaderboard Pro", "Elaris Funding Pro", precision=4, format=format.percent, overlay=false, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore = "Core Funding Engine"
interestRate = input.float(0.01, "Interest Rate Baseline (%)", step=0.001, group=groupCore)
clampInner  = input.float(0.05, "Premium Clamp (%)", step=0.01, group=groupCore)
clampOuter  = input.float(2.50, "Funding Clamp Max (%)", step=0.10, group=groupCore)
fallbackLen = input.int(96, "Fallback Average Length", minval=1, group=groupCore)

groupChart = "Chart Symbol Display"
useCustomSymbol = input.bool(false, "Use Custom Symbol For Main Plot", group=groupChart)
customBase      = input.string("BTC", "Custom Base Symbol", group=groupChart)
showFundingPlot = input.bool(true, "Show Funding Plot", group=groupChart)
showPremiumPlot = input.bool(false, "Show Premium Index Plot", group=groupChart)

groupDash = "Leaderboard Dashboard"
showDashboard = input.bool(true, "Show Dashboard On Main Chart", group=groupDash)
dashPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group=groupDash)
themeMode = input.string("Dark", "Dashboard Theme", options=["Dark", "Light"], group=groupDash)
highlightExtreme = input.float(0.05, "Extreme Funding Highlight (%)", step=0.01, group=groupDash)

groupAlerts = "Smart Alerts"
alertCurrentExtreme = input.float(0.05, "Current Symbol Extreme Alert (%)", step=0.01, group=groupAlerts)
alertLeaderboardExtreme = input.float(0.08, "Leaderboard Extreme Alert (%)", step=0.01, group=groupAlerts)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_pos(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Middle Right" ? position.middle_right :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Top Left" ? position.top_left :
     position.bottom_left

f_clamp(_v, _min, _max) =>
    math.min(math.max(_v, _min), _max)

f_premium_symbol(_base) =>
    "BINANCE:" + str.upper(_base) + "USDT_PREMIUM"

f_avg_len() =>
    timeframe.isminutes ? math.max(1, int(math.round(480 / timeframe.multiplier))) : fallbackLen

f_funding_from_premium(_premium) =>
    _len = f_avg_len()
    _avgPremium = ta.wma(_premium, _len)
    _funding = _avgPremium + f_clamp(interestRate - _avgPremium, -clampInner, clampInner)
    f_clamp(_funding, -clampOuter, clampOuter)

f_get_premium(_base) =>
    request.security(f_premium_symbol(_base), timeframe.period, close * 100, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

f_get_funding(_base) =>
    _premium = f_get_premium(_base)
    f_funding_from_premium(_premium)

f_pick(_values, _names, _wantHigh, _rank) =>
    used = array.new_int()
    string pickedName = "—"
    float pickedValue = na

    for r = 0 to _rank
        float bestValue = na
        string bestName = "—"
        int bestIndex = na

        for i = 0 to array.size(_values) - 1
            v = array.get(_values, i)

            alreadyUsed = false
            if array.size(used) > 0
                for u = 0 to array.size(used) - 1
                    if array.get(used, u) == i
                        alreadyUsed := true

            valid = not na(v) and not alreadyUsed

            if valid
                better = na(bestValue) or (_wantHigh ? v > bestValue : v < bestValue)
                if better
                    bestValue := v
                    bestName := array.get(_names, i)
                    bestIndex := i

        if not na(bestIndex)
            array.push(used, bestIndex)
            pickedName := bestName
            pickedValue := bestValue

    [pickedName, pickedValue]

f_fmt(_v) =>
    na(_v) ? "n/a" : str.format("{0,number,#.####}%", _v)

isDark = themeMode == "Dark"

bgMain      = isDark ? color.rgb(12, 16, 24) : color.rgb(245, 247, 250)
bgHeader    = isDark ? color.rgb(25, 35, 55) : color.rgb(225, 232, 245)
bgSubHeader = isDark ? color.rgb(18, 25, 38) : color.rgb(235, 240, 248)
bgRow       = isDark ? color.rgb(16, 20, 30) : color.rgb(252, 253, 255)
bgAltRow    = isDark ? color.rgb(20, 26, 38) : color.rgb(242, 245, 250)
txtMain     = isDark ? color.white : color.rgb(20, 25, 35)
txtMuted    = isDark ? color.rgb(150, 160, 175) : color.rgb(85, 95, 110)
borderCol   = isDark ? color.rgb(55, 65, 85) : color.rgb(190, 200, 215)

f_val_color(_v) =>
    na(_v) ? txtMuted :
     _v >= highlightExtreme ? color.rgb(0, 220, 140) :
     _v <= -highlightExtreme ? color.rgb(255, 80, 100) :
     _v >= 0 ? color.rgb(0, 180, 120) :
     color.rgb(220, 65, 85)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BINANCE FUTURES UNIVERSE
// Edit this section to add/remove symbols.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
btc  = f_get_funding("BTC")
eth  = f_get_funding("ETH")
bnb  = f_get_funding("BNB")
sol  = f_get_funding("SOL")
xrp  = f_get_funding("XRP")
doge = f_get_funding("DOGE")
ada  = f_get_funding("ADA")
avax = f_get_funding("AVAX")
link = f_get_funding("LINK")
dot  = f_get_funding("DOT")
trx  = f_get_funding("TRX")
ltc  = f_get_funding("LTC")
bch  = f_get_funding("BCH")
near = f_get_funding("NEAR")
apt  = f_get_funding("APT")
arb  = f_get_funding("ARB")
op   = f_get_funding("OP")
sui  = f_get_funding("SUI")
inj  = f_get_funding("INJ")
fil  = f_get_funding("FIL")
etc  = f_get_funding("ETC")
atom = f_get_funding("ATOM")
uni  = f_get_funding("UNI")
aave = f_get_funding("AAVE")

fundingValues = array.from(btc, eth, bnb, sol, xrp, doge, ada, avax, link, dot, trx, ltc, bch, near, apt, arb, op, sui, inj, fil, etc, atom, uni, aave)
symbolNames   = array.from("BTC", "ETH", "BNB", "SOL", "XRP", "DOGE", "ADA", "AVAX", "LINK", "DOT", "TRX", "LTC", "BCH", "NEAR", "APT", "ARB", "OP", "SUI", "INJ", "FIL", "ETC", "ATOM", "UNI", "AAVE")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN SYMBOL FUNDING PLOT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mainBase = useCustomSymbol ? str.upper(customBase) : syminfo.basecurrency
mainPremium = f_get_premium(mainBase)
mainFunding = f_funding_from_premium(mainPremium)

fundingColor = mainFunding >= 0 ? color.rgb(0, 200, 130) : color.rgb(240, 70, 90)

plot(showFundingPlot ? mainFunding : na, "Estimated Funding Rate", color=fundingColor, linewidth=2, style=plot.style_area)
plot(showPremiumPlot ? mainPremium : na, "Premium Index", color=color.rgb(255, 210, 80), linewidth=2)

hline(0, "Zero Line", color=color.gray)
hline(0.01, "Baseline 0.01%", color=color.new(color.white, 45), linestyle=hline.style_dotted)
hline(alertCurrentExtreme, "Positive Extreme", color=color.new(color.lime, 70), linestyle=hline.style_dotted)
hline(-alertCurrentExtreme, "Negative Extreme", color=color.new(color.red, 70), linestyle=hline.style_dotted)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN-CHART DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(
     f_pos(dashPosition),
     5,
     8,
     bgcolor=bgMain,
     frame_color=borderCol,
     frame_width=1,
     border_color=borderCol,
     border_width=1,
     force_overlay=true
)

if barstate.islast and showDashboard
    table.clear(dash, 0, 0, 4, 7)

    table.cell(dash, 0, 0, "#", text_color=txtMain, bgcolor=bgHeader, text_size=size.small)
    table.cell(dash, 1, 0, "TOP FUNDING", text_color=color.rgb(0, 220, 140), bgcolor=bgHeader, text_size=size.small)
    table.cell(dash, 2, 0, "RATE", text_color=txtMain, bgcolor=bgHeader, text_size=size.small)
    table.cell(dash, 3, 0, "LOW FUNDING", text_color=color.rgb(255, 85, 105), bgcolor=bgHeader, text_size=size.small)
    table.cell(dash, 4, 0, "RATE", text_color=txtMain, bgcolor=bgHeader, text_size=size.small)

    for r = 0 to 4
        [highName, highVal] = f_pick(fundingValues, symbolNames, true, r)
        [lowName, lowVal]   = f_pick(fundingValues, symbolNames, false, r)

        row = r + 1
        rowBg = r % 2 == 0 ? bgRow : bgAltRow

        table.cell(dash, 0, row, "#" + str.tostring(row), text_color=txtMuted, bgcolor=rowBg)
        table.cell(dash, 1, row, highName + "USDT", text_color=txtMain, bgcolor=rowBg)
        table.cell(dash, 2, row, f_fmt(highVal), text_color=f_val_color(highVal), bgcolor=rowBg)
        table.cell(dash, 3, row, lowName + "USDT", text_color=txtMain, bgcolor=rowBg)
        table.cell(dash, 4, row, f_fmt(lowVal), text_color=f_val_color(lowVal), bgcolor=rowBg)

    table.cell(dash, 0, 6, "CURRENT", text_color=txtMuted, bgcolor=bgSubHeader)
    table.cell(dash, 1, 6, mainBase + "USDT", text_color=txtMain, bgcolor=bgSubHeader)
    table.cell(dash, 2, 6, f_fmt(mainFunding), text_color=f_val_color(mainFunding), bgcolor=bgSubHeader)
    table.cell(dash, 3, 6, "WINDOW", text_color=txtMuted, bgcolor=bgSubHeader)
    table.cell(dash, 4, 6, str.tostring(f_avg_len()) + " bars", text_color=txtMain, bgcolor=bgSubHeader)

    table.cell(dash, 0, 7, "MODE", text_color=txtMuted, bgcolor=bgMain)
    table.cell(dash, 1, 7, "Funding Estimate", text_color=txtMuted, bgcolor=bgMain)
    table.cell(dash, 2, 7, "Non-Repaint", text_color=txtMuted, bgcolor=bgMain)
    table.cell(dash, 3, 7, "Universe", text_color=txtMuted, bgcolor=bgMain)
    table.cell(dash, 4, 7, "24 Pairs", text_color=txtMuted, bgcolor=bgMain)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 4, 7)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
leaderHigh = array.max(fundingValues)
leaderLow  = array.min(fundingValues)

alertcondition(barstate.isconfirmed and mainFunding >= alertCurrentExtreme, "Current Symbol High Funding", "Current symbol funding estimate is extremely positive.")
alertcondition(barstate.isconfirmed and mainFunding <= -alertCurrentExtreme, "Current Symbol Low Funding", "Current symbol funding estimate is extremely negative.")
alertcondition(barstate.isconfirmed and leaderHigh >= alertLeaderboardExtreme, "Leaderboard High Funding Extreme", "One of the tracked Binance futures symbols has extremely positive funding.")
alertcondition(barstate.isconfirmed and leaderLow <= -alertLeaderboardExtreme, "Leaderboard Low Funding Extreme", "One of the tracked Binance futures symbols has extremely negative funding.")
````
