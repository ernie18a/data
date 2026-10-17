# Mi Primer Rastreador de Fuerza

- url: https://www.tradingview.com/script/9h97XfY5/
- type: indicator
- pine_id: PUB;b367129f10b64a10b4c378ac67cc070b
- version: 1.0

## Description

Les comparto mi primer script, creado desde 0 para tener una primera estrategia, espero leds agrade

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © stalynhu

//@version=6
indicator("Mi Primer Rastreador de Fuerza", overlay = false)
//CALCULAMOS UNA MEDIA MOVIL RAPIDA
mediaRapida = ta.ema(close,20)

//DEFINIMOS LA CONDICION: ¿ELCIERRE ES MAYOR A LA MEDIA?
estaFuerte= close > mediaRapida

//SI estaFuerte es VERDAD, usa VERDE; SI NO, usa ROJO
colorVela=estaFuerte ? color.green : color.red

// DIBUJAMOS EL RESULTADO COMO UN HISTOGRAMA
plot(1, title = "Fuerza de Impulso", color=colorVela, style=plot.style_columns)

//DEFINIMOS CUANDO SE DISPARA LA ALERTA
alertaCompra=estaFuerte and not estaFuerte[1] //PASA DE DEBIL A FUERTE
alertaVenta= not estaFuerte and estaFuerte [1] // PASA DE ESTAS FUERTE A DEBIL

//CONFIGURACION DE LAS NOTIFICACIONES
alertcondition(alertaCompra, title = "Oro con Fuerza", message= "El impulso en XAUUSD es ALCISTA")
alertcondition(alertaVenta, title = "Oro PERDIENDO fuerza", message = "El impulso en XAUUSD es BAJISTA")
````
