# Heikin Ashi Uyumlu BIST Tavan Taban

- url: https://www.tradingview.com/script/5KkgFupj/
- type: indicator
- pine_id: PUB;e05fd450f9ea46eb8b723799215acb00
- version: 1.0

## Description

bıst hisselerinde günlük tavan/taban değerlerini göstermeye yarar

## Source Code

````pine

//@version=6
indicator('Heikin Ashi Uyumlu BIST Tavan Taban', overlay = true)

// Grafik Heikin-Ashi olsa bile GERÇEK (standard) kapanış fiyatını çağır
real_close = request.security(ticker.new(syminfo.prefix, syminfo.ticker), 'D', close[1], lookahead = barmerge.lookahead_on)

// BIST Tavan/Taban Hesaplama Mantığı
tavan = math.floor(real_close * 1.10 / syminfo.mintick) * syminfo.mintick
taban = math.ceil(real_close * 0.90 / syminfo.mintick) * syminfo.mintick
// Etiketler
if barstate.islast
    label.new(bar_index, tavan, 'Tavan: ' + str.tostring(tavan), color = color.green, textcolor = color.white, style = label.style_label_left)
    label.new(bar_index, taban, 'Taban: ' + str.tostring(taban), color = color.red, textcolor = color.white, style = label.style_label_left)
````
