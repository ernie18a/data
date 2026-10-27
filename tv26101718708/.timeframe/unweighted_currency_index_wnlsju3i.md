# Unweighted Currency Index

- url: https://www.tradingview.com/script/wNlSjU3i-Unweighted-Currency-Index/
- type: indicator
- pine_id: PUB;474a680cf1bd499186aaed2c4d7fe4a1
- version: 5.0

## Description

[b]Unweighted Currency Index (UCI)[/b] — Equal-weighted strength index for the 8 major Forex currencies, displayed as synthetic Japanese candlesticks.

[b]🔍 Concept[/b]
This indicator measures the "pure" strength of a currency by computing the [b]geometric mean[/b] of its 7 bilateral pairs against the other majors (USD, EUR, GBP, JPY, AUD, NZD, CAD, CHF). Unlike the DXY, which is weighted and limited to a basket of 6 currencies, the unweighted approach gives equal influence to every cross, providing a more balanced view of the currency's true momentum.

Formula for currency X:
[i]Index_X = ( ∏ (X/Y) for Y ≠ X )^(1/7)[/i]

[b]📊 Features[/b]
- Full OHLC calculation (open, high, low, close) for true Japanese candlestick rendering
- 8 individually selectable currencies: USD, EUR, GBP, JPY, AUD, NZD, CAD, CHF
- Configurable data source (FX_IDC, FX, OANDA, FOREXCOM, SAXO, ICEUS) to match your broker/feed
- Optional normalization to 100 for comparing relative strength over time
- Customizable bullish/bearish candle colors
- Dynamic label displaying the active currency

[b]🛠️ How to use[/b]
1. Add the indicator to your chart
2. Open the settings and select the [b]currency[/b] to analyze
3. To track multiple currencies simultaneously, add the indicator multiple times and configure each instance with a different currency

[b]💡 Use cases[/b]
- Identify the strongest / weakest currency to optimally pair your trades
- Detect divergences between a currency's strength and the price of a specific pair
- Confirm a cross's direction by checking both component currencies' indexes
- Filter setups: only trade pairs combining a strong currency vs a weak one

[b]⚙️ Technical note[/b]
If some pairs fail to load (typically exotic crosses like NZDCHF or CADCHF with FX_IDC), switch the source to OANDA or FX depending on your TradingView subscription.

[b]📌 Limitations[/b]
- Requires access to all 28 Forex bilateral pairs (28 × request.security calls)
- Absolute values are not comparable across currencies without normalization (use the "Normalize to 100" mode)

[i]Built for Forex traders looking to measure fundamental currency strength beyond traditional weighted indexes.[/i]

[i]⚠️ This indicator is provided for informational and educational purposes only. It does not constitute investment advice.[/i]

## Source Code

````pine
//@version=6
indicator("Unweighted Currency Index (true OHLC)", "UCI", overlay = false)

// ----------------------- INPUTS ----------------------------------------------
ccy       = input.string("USD", "Devise", options = ["USD","EUR","GBP","JPY","AUD","NZD","CAD","CHF"])
prefix    = input.string("FX_IDC", "Source", options = ["FX_IDC","FX","OANDA","FOREXCOM","SAXO","ICEUS"])
baseTF    = input.timeframe("5", "Résolution interne (high/low)", options = ["1","3","5","15","30","60"])
normalize = input.bool(false, "Normaliser à 100 (base = 1ère barre)")
bullCol   = input.color(color.new(#26a69a, 0), "Couleur haussière")
bearCol   = input.color(color.new(#ef5350, 0), "Couleur baissière")

// ----------------------- Helpers ---------------------------------------------
// Hiérarchie standard de cotation : la devise de plus haut rang est la base de la paire
rnk(c) =>
    switch c
        "EUR" => 1
        "GBP" => 2
        "AUD" => 3
        "NZD" => 4
        "USD" => 5
        "CAD" => 6
        "CHF" => 7
        => 8   // JPY

// [symbole, faut-il inverser le prix pour obtenir le taux ccy/x]
makePair(pfx, b, x) =>
    bBase = rnk(b) < rnk(x)
    sym   = bBase ? b + x : x + b
    [pfx + ":" + sym, not bBase]

// Les 7 autres devises (≠ ccy)
buildOthers(sel) =>
    res = array.new<string>()
    all = array.from("EUR","GBP","JPY","AUD","NZD","CAD","CHF","USD")
    for i = 0 to array.size(all) - 1
        cur = array.get(all, i)
        if cur != sel
            array.push(res, cur)
    res

var others = buildOthers(ccy)
exp7 = 1.0 / 7.0

// ----------------------- Récupération + combinaison --------------------------
prod = array.new<float>(0)   // produit des 7 ratios, pour chaque sous-barre
int   n   = 0
float chO = 1.0              // produit OHLC au TF du graphe (close exact + repli approx)
float chH = 1.0
float chL = 1.0
float chC = 1.0

for i = 0 to 6
    x = array.get(others, i)
    [sym, inv] = makePair(prefix, ccy, x)

    // OHLC au TF du graphe : close/open exacts + reconstruction approx pour le repli
    [co, ch, cl, cc] = request.security(sym, timeframe.period, [open, high, low, close])
    chO := chO * (inv ? 1.0 / co : co)
    chC := chC * (inv ? 1.0 / cc : cc)
    chH := chH * (inv ? 1.0 / cl : ch)   // index haut : paire basse si inversée
    chL := chL * (inv ? 1.0 / ch : cl)

    // Sous-barres intraday → high/low réels, cohérents entre UT
    arr = request.security_lower_tf(sym, baseTF, close, ignore_invalid_timeframe = true)
    sz  = array.size(arr)
    if i == 0
        n := sz
        if sz > 0
            for s = 0 to sz - 1
                v = array.get(arr, s)
                array.push(prod, inv ? 1.0 / v : v)
    else
        n := math.min(n, sz)
        while array.size(prod) > n
            array.pop(prod)
        if n > 0
            for s = 0 to n - 1
                v = array.get(arr, s)
                array.set(prod, s, array.get(prod, s) * (inv ? 1.0 / v : v))

// ----------------------- Construction OHLC géométrique -----------------------
float o = math.pow(chO, exp7)   // open & close : exacts et identiques sur toutes les UT
float c = math.pow(chC, exp7)
float h = na
float l = na

sizeP = array.size(prod)
if sizeP > 0
    float hi = na
    float lo = na
    for s = 0 to sizeP - 1
        g = math.pow(array.get(prod, s), exp7)
        hi := na(hi) ? g : math.max(hi, g)
        lo := na(lo) ? g : math.min(lo, g)
    h := hi
    l := lo
else
    h := math.pow(chH, exp7)    // repli (barres trop anciennes / base ≥ UT graphe)
    l := math.pow(chL, exp7)

// les mèches englobent toujours le corps
h := math.max(h, math.max(o, c))
l := math.min(l, math.min(o, c))

// ----------------------- Normalisation optionnelle ---------------------------
var float baseVal = na
if na(baseVal) and not na(c)
    baseVal := c
scale = normalize ? 100.0 / baseVal : 1.0

// ----------------------- Tracé ------------------------------------------------
col = (c * scale) >= (o * scale) ? bullCol : bearCol
plotcandle(o * scale, h * scale, l * scale, c * scale, "UCI", color = col, bordercolor = col, wickcolor = color.gray)

var table tbl = table.new(position.top_right, 1, 1, border_width = 1)
if barstate.islast
    table.cell(tbl, 0, 0, ccy, bgcolor = color.new(col, 30), text_color = color.white, text_size = size.normal)
````
