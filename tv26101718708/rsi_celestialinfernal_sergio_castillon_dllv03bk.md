# RSI celestial/infernal  ( sergio castillon )

- url: https://www.tradingview.com/script/Dllv03bk/
- type: indicator
- pine_id: PUB;b35e961b170c46b3aef2514a22a7b632
- version: 1.0

## Description

rsi con niveles mas optimos de rebotes , no es infalible debes revisar estructura para tomar decisiones . manejar con absoluta reserva . marca mejore niveles tecnicos pero necesitas mas confirmaciones

## Source Code

````pine
//@version=5
indicator("RSI 50 Niveles PRO", overlay=false)

// Calcular RSI
rsiValue = ta.rsi(close, 50)

// Dibujar RSI
plot(rsiValue, title="RSI", color=color.white, linewidth=2)

// Niveles
hline(30, title="30", color=color.red)
hline(42.5, title="42.5", color=color.orange)
hline(50, title="50", color=color.gray)
hline(57.5, title="57.5", color=color.orange)
hline(70, title="70", color=color.green)
````
