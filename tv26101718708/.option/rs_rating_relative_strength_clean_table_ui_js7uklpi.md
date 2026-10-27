# RS Rating (Relative Strength) - Clean Table UI

- url: https://www.tradingview.com/script/JS7UKlPi-RS-Rating-Relative-Strength-Clean-Table-UI/
- type: indicator
- pine_id: PUB;25009e1b13294e988a291a3a695ff63a
- version: 1.0

## Description

This indicator calculates the Relative Strength (RS) Rating of a stock compared to the S&P 500 (SPY) and displays it as a clean, simple numerical value in a customizable table on your chart.

Unlike many complex swing data indicators that clutter your screen with moving averages, background colors, and multiple data points, this script is specifically designed for minimalist traders, day traders, and scalpers who only need to see the core RS Rating score at a single glance.

How It Works:

Core Calculation: It uses the standard weighted formula for 1-year performance (40% for the most recent quarter, and 20% for each of the previous three quarters) compared against the S&P 500 benchmark.

Percentile Ranking (1-99): Using market environment seed data, the raw score is converted into a true 1 to 99 percentile ranking. For example, an RS Rating of 85 means the stock is currently outperforming 85% of the overall market.

Color-Coded Signals: The numerical value automatically changes color based on the stock's momentum:

Green (>= 80): Strong market leader.

Red (<= 40): Weak laggard.

Custom/White: Neutral performance.

Features:

Zero Chart Clutter: No lines or shapes plotted over your candles. Just a single, elegant table.

Fully Customizable: You can easily change the table's position (Top/Bottom, Left/Right) and text size (Normal, Large, Huge) directly from the indicator settings to fit your exact workspace layout.

(Credits to the original open-source community and Fred6724 for the percentile mapping seed function utilized to power this clean UI version).

## Source Code

````pine
//@version=6
indicator(title="RS Rating (Clean Table)", shorttitle="RS Rating", overlay=true, max_bars_back=253)

// --- SETTINGS ---
posTable = input.string(defval='Top Right', title='Table Position', options=['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right'])
textSize = input.string(defval='Large', title='Text Size', options=['Normal', 'Large', 'Huge'])
bg_col = input.color(color.rgb(20, 24, 35, 20), title='Background Color')
txt_col = input.color(color.white, title='Text Color')

tablePos = switch posTable
    'Top Left'     => position.top_left
    'Top Right'    => position.top_right
    'Bottom Left'  => position.bottom_left
    'Bottom Right' => position.bottom_right

t_size = switch textSize
    'Normal' => size.normal
    'Large'  => size.large
    'Huge'   => size.huge

// --- RS RATING CALCULATION FUNCTIONS ---
f_attributePercentile(totalRsScore, tallerPerf, smallerPerf, rangeUp, rangeDn, weight) =>
    sum = totalRsScore + (totalRsScore-smallerPerf)*weight
    if(sum > tallerPerf - 1)
        sum := tallerPerf - 1
    k1 = smallerPerf/rangeDn
    k2 = (tallerPerf-1)/rangeUp
    k3 = (k1-k2)/(tallerPerf-1-smallerPerf)
    RsRating = sum/(k1-k3*(totalRsScore-smallerPerf))
    if (RsRating > rangeUp)
        RsRating := rangeUp
    if (RsRating < rangeDn)
        RsRating := rangeDn
    RsRating

f_get_rs_rating(ticker) =>
    n63  = bar_index < 63  ? bar_index:63 
    n126 = bar_index < 126 ? bar_index:126
    n189 = bar_index < 189 ? bar_index:189
    n252 = bar_index < 252 ? bar_index:252

    closeDaRs    = request.security(ticker, 'D', close)
    spxcloseDaRs = request.security('SP:SPX', 'D', close)

    perfTicker63  = closeDaRs/closeDaRs[n63]
    perfTicker126 = closeDaRs/closeDaRs[n126]
    perfTicker189 = closeDaRs/closeDaRs[n189]
    perfTicker252 = closeDaRs/closeDaRs[n252]

    perfComp63  = spxcloseDaRs/spxcloseDaRs[n63]
    perfComp126 = spxcloseDaRs/spxcloseDaRs[n126]
    perfComp189 = spxcloseDaRs/spxcloseDaRs[n189]
    perfComp252 = spxcloseDaRs/spxcloseDaRs[n252]

    float rs_stock = 0.4*perfTicker63 + 0.2*perfTicker126 + 0.2*perfTicker189 + 0.2*perfTicker252
    float rs_ref   = 0.4*perfComp63   + 0.2*perfComp126   + 0.2*perfComp189   + 0.2*perfComp252

    float totalRsScore  = (rs_stock) / (rs_ref) * 100
    float totalRsRating = -1

    curveRsPerf  = request.seed('seed_fred6725_rs_rating', 'RSRATING', close)
    delta  = ta.barssince(na(curveRsPerf) != true)

    var float[] different_values = array.new_float(7)
    var int counter = 0

    float first = 0
    float scnd  = 0
    float thrd  = 0
    float frth  = 0
    float ffth  = 0
    float sxth  = 0
    float svth  = 0

    if (true)
        for i = delta to 34+delta
            close_value = nz(curveRsPerf[i])
            if (not array.includes(different_values, close_value) and counter < 7 and close_value!=0)
                array.set(different_values, counter, close_value)
                counter := counter + 1

        first := array.get(different_values, 0)
        scnd  := array.get(different_values, 1)
        thrd  := array.get(different_values, 2)
        frth  := array.get(different_values, 3)
        ffth  := array.get(different_values, 4)
        sxth  := array.get(different_values, 5)
        svth  := array.get(different_values, 6)

    if(totalRsScore >= first)
        totalRsRating := 99
    if(totalRsScore <= svth)
        totalRsRating := 1

    if (totalRsScore < first and totalRsScore >= scnd)
        totalRsRating := f_attributePercentile(totalRsScore, first, scnd, 98, 90, 0.33)
    if (totalRsScore < scnd and totalRsScore >= thrd)
        totalRsRating := f_attributePercentile(totalRsScore, scnd, thrd, 89, 70, 2.1)
    if (totalRsScore < thrd and totalRsScore >= frth)
        totalRsRating := f_attributePercentile(totalRsScore, thrd, frth, 69, 50, 0)
    if (totalRsScore < frth and totalRsScore >= ffth)
        totalRsRating := f_attributePercentile(totalRsScore, frth, ffth, 49, 30, 0)
    if (totalRsScore < ffth and totalRsScore >= sxth)
        totalRsRating := f_attributePercentile(totalRsScore, ffth, sxth, 29, 10, 0)
    if (totalRsScore < sxth and totalRsScore >= svth)
        totalRsRating := f_attributePercentile(totalRsScore, sxth, svth, 9, 2, 0)

    totalRsRating

// --- DISPLAY (TABLE ONLY) ---
totalRsRating = f_get_rs_rating(syminfo.tickerid)

var table t = table.new(tablePos, 2, 1, bgcolor=bg_col, border_width=1, border_color=color.rgb(54, 58, 69))

if barstate.islast
    // Color Setup: 80+ Green, Under 40 Red
    rating_color = totalRsRating >= 80 ? color.new(#089981, 0) : (totalRsRating <= 40 ? color.new(#f23645, 0) : txt_col)
    
    table.cell(t, 0, 0, 'RS Rating:', text_color=color.gray, text_size=t_size)
    table.cell(t, 1, 0, str.tostring(totalRsRating, '0.0'), text_color=rating_color, text_size=t_size)
````
