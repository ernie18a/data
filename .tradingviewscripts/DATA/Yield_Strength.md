<!-- tradingview-pine-id: PUB;98fa7ae0f23c4d5d8a7e0b75c9e2abe6 -->
<!-- tradingviewscripts-format: 1 -->
# Yield Strength

Source: https://www.tradingview.com/script/GaFO05fw/

## Description

[symbol="OANDA:NZDCHF"]OANDA:NZDCHF[/symbol] Yield Strength — Bond Yield Spread Indicator Between Currencies

This indicator measures the relative strength of major currencies based on the yield differential (interest rates) of each country's government bonds, rather than price.

How it works:

Fetches the government bond yield (2Y, 5Y, or 10Y, selectable) for 8 economies: US, Eurozone, UK, Japan, Australia, New Zealand, Canada, and Switzerland.
Calculates the yield spread between the current chart pair (e.g., EURUSD = EUR yield − USD yield) and plots it alongside two EMAs (fast and slow) of that spread, signaling trend crossovers with a color change (green = bullish, red = bearish).
In parallel, calculates the yield spread for all 28 possible pairs among these 8 currencies and applies the same EMA-crossover logic to each.
Consolidates everything into a scoreboard in the corner of the screen: each currency gains or loses points depending on whether it's on the "strong" or "weak" side of the yield in each of the 28 pairs — producing a relative strength ranking of currencies based purely on implied monetary policy/interest rates, not price.

Why it's useful:
Yield differential is one of the main drivers of flow in forex (carry trade, rate expectations). This indicator translates that macro concept into a visual signal and an objective ranking, useful as a context/trend filter for swing trading, without relying on traditional price-based indicators.

How to use it:

Recommended timeframe: works best on higher timeframes — H1, H4, or D1. Since it's based on yield differentials (a slow-moving macro driver), it's not suited for scalping or very low timeframes, where price noise dominates and the interest-rate signal loses relevance.
Best used with the trend. Use it as a context filter, not a standalone entry trigger. When the spread and EMAs are aligned with the pair's price trend direction, it reinforces that the macro flow is "pushing" the pair in the same direction — giving more confidence to trade with that trend.
Scoreboard: use the strength ranking of the 8 currencies to spot "stretched" pairs (strong currency vs. weak currency) — usually the best candidates for trend-following entries backed by this macro driver.
Color crossovers (green/red) on the spread's EMAs signal a regime change — useful for confirming the yield trend is still active before entering, rather than already exhausted.

Technical: Pine Script v6. All 28 spreads are calculated locally from just 8 request.security calls (one per currency), working around TradingView's 40-security limit even while analyzing 28 pairs.[image]https://www.tradingview.com/x/Yt3QQH6o/[/image][image]https://www.tradingview.com/x/TWajXo7N/[/image][image]https://www.tradingview.com/x/XENTnnmj/[/image]

---

## Source Code

````pine
//@version=6
indicator("Yield Strength", overlay=true, scale=scale.right)

// === Inputs ===
yield_tf  = input.timeframe("60", "Yield timeframe")
ema_tf    = input.timeframe("60", "EMA timeframe")
maturity  = input.string("10Y", "Yield Maturity", options=["02Y", "05Y", "10Y"])
ema_fast  = input.int(120, "EMA Curta")
ema_slow  = input.int(216, "EMA Longa")

// === Funções ===
f_yieldSymbol(curr) =>
    baseSym = switch curr
        "USD" => "US"
        "EUR" => "DE"
        "JPY" => "JP"
        "GBP" => "GB"
        "CHF" => "CH"
        "AUD" => "AU"
        "NZD" => "NZ"
        "CAD" => "CA"
        => ""
    baseSym == "" ? "" : "TVC:" + baseSym + maturity

getYield(curr) =>
    request.security(f_yieldSymbol(curr), yield_tf, close)

// === YIELDS (8 securities) ===
y_USD = getYield("USD")
y_EUR = getYield("EUR")
y_GBP = getYield("GBP")
y_JPY = getYield("JPY")
y_AUD = getYield("AUD")
y_NZD = getYield("NZD")
y_CAD = getYield("CAD")
y_CHF = getYield("CHF")

// === PAR ATUAL ===
base  = str.substring(syminfo.ticker, 0, 3)
quote = str.substring(syminfo.ticker, 3, 6)

yBase  = base=="USD"?y_USD:base=="EUR"?y_EUR:base=="GBP"?y_GBP:base=="JPY"?y_JPY:base=="AUD"?y_AUD:base=="NZD"?y_NZD:base=="CAD"?y_CAD:y_CHF
yQuote = quote=="USD"?y_USD:quote=="EUR"?y_EUR:quote=="GBP"?y_GBP:quote=="JPY"?y_JPY:quote=="AUD"?y_AUD:quote=="NZD"?y_NZD:quote=="CAD"?y_CAD:y_CHF

spread = yBase - yQuote

// === EMAs DO PAR ATUAL no ema_tf (1 security via tuple) ===
[ema1, ema2] = request.security(syminfo.tickerid, ema_tf,
     [ta.ema(spread, ema_fast),
      ta.ema(spread, ema_slow)])

bull_cross = ta.crossover(ema1,  ema2)
bear_cross = ta.crossunder(ema1, ema2)

var color currentColor = color.gray
if bull_cross
    currentColor := color.lime
else if bear_cross
    currentColor := color.red

plot(spread, "Spread", color=color.gray)
plot(ema1, "EMA Curta", color=currentColor, linewidth=2)
plot(ema2, "EMA Longa", color=currentColor, linewidth=2)

// === TREND VIA TUPLE (yield já calculado localmente, sem request extra) ===
// spread de cada par calculado direto dos yields já buscados
// EMAs no ema_tf via único request por par
pairTrend(spd) =>
    [e1, e2] = request.security(syminfo.tickerid, ema_tf,
         [ta.ema(spd, ema_fast), ta.ema(spd, ema_slow)])
    e1 > e2 ? 1 : -1

// === SPREADS DOS 28 PARES (calculados localmente, sem securities extras) ===
sp_EUR_USD = y_EUR - y_USD
sp_EUR_GBP = y_EUR - y_GBP
sp_EUR_AUD = y_EUR - y_AUD
sp_EUR_NZD = y_EUR - y_NZD
sp_EUR_CAD = y_EUR - y_CAD
sp_EUR_CHF = y_EUR - y_CHF
sp_EUR_JPY = y_EUR - y_JPY
sp_GBP_USD = y_GBP - y_USD
sp_GBP_AUD = y_GBP - y_AUD
sp_GBP_NZD = y_GBP - y_NZD
sp_GBP_CAD = y_GBP - y_CAD
sp_GBP_CHF = y_GBP - y_CHF
sp_GBP_JPY = y_GBP - y_JPY
sp_AUD_USD = y_AUD - y_USD
sp_AUD_NZD = y_AUD - y_NZD
sp_AUD_CAD = y_AUD - y_CAD
sp_AUD_CHF = y_AUD - y_CHF
sp_AUD_JPY = y_AUD - y_JPY
sp_NZD_USD = y_NZD - y_USD
sp_NZD_CAD = y_NZD - y_CAD
sp_NZD_CHF = y_NZD - y_CHF
sp_NZD_JPY = y_NZD - y_JPY
sp_USD_CAD = y_USD - y_CAD
sp_USD_CHF = y_USD - y_CHF
sp_USD_JPY = y_USD - y_JPY
sp_CAD_CHF = y_CAD - y_CHF
sp_CAD_JPY = y_CAD - y_JPY
sp_CHF_JPY = y_CHF - y_JPY

// === SCORES (28 calls — mas todos no mesmo syminfo.tickerid) ===
USD = 0.0, EUR = 0.0, GBP = 0.0, JPY = 0.0
AUD = 0.0, NZD = 0.0, CAD = 0.0, CHF = 0.0

float t = na

t := pairTrend(sp_EUR_USD), EUR += t, USD -= t
t := pairTrend(sp_EUR_GBP), EUR += t, GBP -= t
t := pairTrend(sp_EUR_AUD), EUR += t, AUD -= t
t := pairTrend(sp_EUR_NZD), EUR += t, NZD -= t
t := pairTrend(sp_EUR_CAD), EUR += t, CAD -= t
t := pairTrend(sp_EUR_CHF), EUR += t, CHF -= t
t := pairTrend(sp_EUR_JPY), EUR += t, JPY -= t
t := pairTrend(sp_GBP_USD), GBP += t, USD -= t
t := pairTrend(sp_GBP_AUD), GBP += t, AUD -= t
t := pairTrend(sp_GBP_NZD), GBP += t, NZD -= t
t := pairTrend(sp_GBP_CAD), GBP += t, CAD -= t
t := pairTrend(sp_GBP_CHF), GBP += t, CHF -= t
t := pairTrend(sp_GBP_JPY), GBP += t, JPY -= t
t := pairTrend(sp_AUD_USD), AUD += t, USD -= t
t := pairTrend(sp_AUD_NZD), AUD += t, NZD -= t
t := pairTrend(sp_AUD_CAD), AUD += t, CAD -= t
t := pairTrend(sp_AUD_CHF), AUD += t, CHF -= t
t := pairTrend(sp_AUD_JPY), AUD += t, JPY -= t
t := pairTrend(sp_NZD_USD), NZD += t, USD -= t
t := pairTrend(sp_NZD_CAD), NZD += t, CAD -= t
t := pairTrend(sp_NZD_CHF), NZD += t, CHF -= t
t := pairTrend(sp_NZD_JPY), NZD += t, JPY -= t
t := pairTrend(sp_USD_CAD), USD += t, CAD -= t
t := pairTrend(sp_USD_CHF), USD += t, CHF -= t
t := pairTrend(sp_USD_JPY), USD += t, JPY -= t
t := pairTrend(sp_CAD_CHF), CAD += t, CHF -= t
t := pairTrend(sp_CAD_JPY), CAD += t, JPY -= t
t := pairTrend(sp_CHF_JPY), CHF += t, JPY -= t

pairTrendCur = pairTrend(spread)

// === SCOREBOARD ===
var table painel = table.new(position.top_right, 2, 9, border_width=1)

colorFor(v) => v > 0 ? color.lime : color.red

show(nome, valor, row) =>
    table.cell(painel, 0, row, nome,               text_color=color.white)
    table.cell(painel, 1, row, str.tostring(valor), text_color=colorFor(valor))

if barstate.islast
    table.cell(painel, 0, 0, base + quote, text_color=color.yellow)
    table.cell(painel, 1, 0, str.tostring(pairTrendCur), text_color=colorFor(pairTrendCur))
    show("USD", USD, 1)
    show("EUR", EUR, 2)
    show("GBP", GBP, 3)
    show("JPY", JPY, 4)
    show("AUD", AUD, 5)
    show("NZD", NZD, 6)
    show("CAD", CAD, 7)
    show("CHF", CHF, 8)
````
