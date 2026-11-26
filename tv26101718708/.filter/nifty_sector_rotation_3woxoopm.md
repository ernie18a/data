# Nifty sector rotation

- url: https://www.tradingview.com/script/3woxOOpm-Nifty-sector-rotation/
- type: indicator
- pine_id: PUB;d90af71c9acb47888bf8c158b495082a
- version: 2.0

## Description

Nifty Sector Rotation tracks the real-time velocity and structural strength of key sectors against the Nifty 50 benchmark. By mapping them onto a high-resolution 10x10 grid, it visually filters the market into four actionable zones: Leading (Aggressive Longs), Improving (Early Reversals), Weakening (Trailing Stops), and Lagging (Avoid/Short).

## Source Code

````pine
//@version=6
indicator("Nifty sector rotation", overlay=true)

// 1. Inputs
string benchmark = input.symbol("NSE:NIFTY", "Benchmark Baseline")
int smoothLen    = input.int(14, "Smoothing Period")
int normLen      = input.int(56, "Normalization Lookback")
int momLen       = input.int(10, "Momentum Lookback")

// Table Position Input
string tablePos  = input.string("Top Right", "Table Position", 
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left", "Middle Center"])

// Helper function to resolve chosen text position to TradingView position variables
getPosition(string pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        => position.top_right

// 2. Core RRG Math — returns [RS-Ratio, RS-Momentum]
calcRRG(string ticker, string bench) =>
    float assetClose  = request.security(ticker, timeframe.period, close)
    float benchClose  = request.security(bench, timeframe.period, close)
    float baseRatio   = (assetClose / benchClose) * 100
    float smoothRatio = ta.ema(baseRatio, smoothLen)
    float meanVal     = ta.sma(smoothRatio, normLen)
    float stdVal      = ta.stdev(smoothRatio, normLen)
    float rsRatio     = stdVal != 0 ? 100 + (smoothRatio - meanVal) / stdVal : 100.0

    float momentum    = ta.roc(smoothRatio, momLen)
    float momMean     = ta.sma(momentum, normLen)
    float momStd      = ta.stdev(momentum, normLen)
    float rsMomentum  = momStd != 0 ? 100 + (momentum - momMean) / momStd : 100.0

    [rsRatio, rsMomentum]

// 3. Fetch data for 11 sectors
[bankR, bankM]     = calcRRG("NSE:BANKNIFTY", benchmark)
[itR, itM]         = calcRRG("NSE:CNXIT", benchmark)
[pharmaR, pharmaM] = calcRRG("NSE:CNXPHARMA", benchmark)
[autoR, autoM]     = calcRRG("NSE:CNXAUTO", benchmark)
[fmcgR, fmcgM]     = calcRRG("NSE:CNXFMCG", benchmark)
[metalR, metalM]   = calcRRG("NSE:CNXMETAL", benchmark)
[infraR, infraM]   = calcRRG("NSE:CNXINFRA", benchmark)
[energyR, energyM] = calcRRG("NSE:CNXENERGY", benchmark)
[realtyR, realtyM] = calcRRG("NSE:CNXREALTY", benchmark)
[mediaR, mediaM]   = calcRRG("NSE:CNXMEDIA", benchmark)
[pseR, pseM]       = calcRRG("NSE:CNXPSE", benchmark)

// 4. Quadrant classifier
getQuadrant(float ratio, float mom) =>
    string q = "Improving"
    if ratio >= 100 and mom >= 100
        q := "Leading"
    else if ratio >= 100 and mom < 100
        q := "Weakening"
    else if ratio < 100 and mom < 100
        q := "Lagging"
    q

// 5. Build sector lists (only on last bar — avoids repaint flicker)
var string[] names  = array.new<string>()
var float[]  ratios = array.new<float>()
var float[]  moms   = array.new<float>()

if barstate.islast
    array.clear(names)
    array.clear(ratios)
    array.clear(moms)
    
    array.push(names, "Bank")   , array.push(ratios, bankR)   , array.push(moms, bankM)
    array.push(names, "IT")     , array.push(ratios, itR)     , array.push(moms, itM)
    array.push(names, "Pharma") , array.push(ratios, pharmaR) , array.push(moms, pharmaM)
    array.push(names, "Auto")   , array.push(ratios, autoR)   , array.push(moms, autoM)
    array.push(names, "FMCG")   , array.push(ratios, fmcgR)   , array.push(moms, fmcgM)
    array.push(names, "Metal")  , array.push(ratios, metalR)  , array.push(moms, metalM)
    array.push(names, "Infra")  , array.push(ratios, infraR)  , array.push(moms, infraM)
    array.push(names, "Energy") , array.push(ratios, energyR) , array.push(moms, energyM)
    array.push(names, "Realty") , array.push(ratios, realtyR) , array.push(moms, realtyM)
    array.push(names, "Media")  , array.push(ratios, mediaR)  , array.push(moms, mediaM)
    array.push(names, "PSE")    , array.push(ratios, pseR)    , array.push(moms, pseM)

// 6. Quadrant table (Dynamic location based on input)
var table rrgTable = table.new(getPosition(tablePos), 2, 2, border_width=2, border_color=color.gray, frame_color=color.white, frame_width=2)

if barstate.islast
    string improvingStr = ""
    string leadingStr   = ""
    string laggingStr   = ""
    string weakeningStr = ""
    
    int totalElements = array.size(names)
    if totalElements > 0
        for i = 0 to totalElements - 1
            string nm = array.get(names, i)
            string q  = getQuadrant(array.get(ratios, i), array.get(moms, i))
            
            if q == "Leading"
                leadingStr += nm + "\n"
            else if q == "Weakening"
                weakeningStr += nm + "\n"
            else if q == "Lagging"
                laggingStr += nm + "\n"
            else
                improvingStr += nm + "\n"

    table.cell(rrgTable, 0, 0, "IMPROVING\n\n" + improvingStr, bgcolor=color.new(color.blue, 80),   text_color=color.white, text_size=size.small)
    table.cell(rrgTable, 1, 0, "LEADING\n\n"   + leadingStr,   bgcolor=color.new(color.green, 80),  text_color=color.white, text_size=size.small)
    table.cell(rrgTable, 0, 1, "LAGGING\n\n"   + laggingStr,   bgcolor=color.new(color.red, 80),    text_color=color.white, text_size=size.small)
    table.cell(rrgTable, 1, 1, "WEAKENING\n\n" + weakeningStr, bgcolor=color.new(color.orange, 80), text_color=color.white, text_size=size.small)
````
