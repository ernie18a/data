# KGV & KUV

- url: https://www.tradingview.com/script/L7Mlwbrd/
- type: indicator
- pine_id: PUB;81de521c25754263ae375b1eb122036a
- version: 1.0

## Description

Indikator für einen schnellen Überblick über die Entwicklung des KGV&KUV

## Source Code

````pine
//@version=6
indicator("KGV & KUV", overlay = false)

useDiluted = input.bool(false, "Verwässertes EPS verwenden")
showPE     = input.bool(true,  "KGV anzeigen")
showPS     = input.bool(true,  "KUV anzeigen")

epsMetric = useDiluted ? "EARNINGS_PER_SHARE_DILUTED" : "EARNINGS_PER_SHARE"

// KGV
epsTTM = request.financial(syminfo.tickerid, epsMetric, "TTM", ignore_invalid_symbol = true)
pe = (not na(epsTTM) and epsTTM > 0) ? close / epsTTM : na

// KUV
revTTM = request.financial(syminfo.tickerid, "TOTAL_REVENUE",            "TTM", ignore_invalid_symbol = true)
shares = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ",  ignore_invalid_symbol = true)
sps = (not na(revTTM) and not na(shares) and shares > 0) ? revTTM / shares : na
ps  = (not na(sps) and sps > 0) ? close / sps : na

plot(showPE ? pe : na, "KGV", color = color.teal,   linewidth = 2)
plot(showPS ? ps : na, "KUV", color = color.purple, linewidth = 2)
````
