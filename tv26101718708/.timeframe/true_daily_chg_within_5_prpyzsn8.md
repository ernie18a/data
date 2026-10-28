# True Daily CHG% (Within .5%)

- url: https://www.tradingview.com/script/PRpYzSn8-True-Daily-CHG-Within-5/
- type: indicator
- pine_id: PUB;1708f59e382442b399d719e00e019d4c
- version: 2.0

## Description

Shows the CHG% like trading view does but this one works in replay mode which tradingview cant do its not 1 to 1 bc of the way pine view works but im only 15 so bear with me lol

## Source Code

````pine
//@version=5
indicator("Daily CHG% HUD", overlay=true)

prevClose = request.security(syminfo.tickerid, "D", close[1])
chg = na(prevClose) ? na : (close / prevClose - 1) * 100

var table t = table.new(position.top_right, 1, 1)

if barstate.islast and not na(chg)
    table.cell(t, 0, 0, "CHG: " + str.tostring(chg, "#.##") + "%", text_color=color.white, bgcolor=chg >= 0 ? color.green : color.red)
````
