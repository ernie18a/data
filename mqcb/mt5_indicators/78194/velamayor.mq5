//+------------------------------------------------------------------+
//|                                                   VelaMayor.mq5  |
//|                 Indicador Multi-Timeframe de Velas Mayores       |
//|               Cajas Transparentes, Mechas y Etiquetas en MT5     |
//+------------------------------------------------------------------+
#property copyright   "juanluistrading@gmail.com"
#property version     "1.00"
#property description "Dibuja las ultimas X velas de un Timeframe Mayor, como cajas transparentes con mechas, sobre el grafico actual."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//====================================================================
//                       PARAMETROS DE ENTRADA
//====================================================================
sinput string InpSep_1_1             = "";     //⠀
input group "─── ■■■■■■■ [ 1. Timeframe y Alcance ] ───"
input ENUM_TIMEFRAMES InpTimeframe   = PERIOD_H1;  // Timeframe de la Vela Mayor
input int             InpBarsCount   = 25;          // Cantidad de Velas Mayores a dibujar (X ultimas)
input bool            InpIncludeCurrent = true;    // Incluir vela en formacion (Vela actual)

sinput string InpSep_1_2             = "";     //⠀
input group "─── ■■■■■■■ [ 2. Representacion Visual y Estilo ] ───"
input bool            InpDrawBody    = true;       // Dibujar Caja del Cuerpo (Open a Close)
input bool            InpFillBody    = true;       // Rellenar caja del cuerpo con color
input bool            InpDrawWicks   = true;       // Dibujar Mechas (High a Low)
input int             InpWickWidth   = 4;          // Grosor de las mechas
input ENUM_LINE_STYLE InpWickStyle   = STYLE_SOLID;// Estilo de linea de las mechas
input int             InpBorderWidth = 4;          // Grosor del borde de la caja
input ENUM_LINE_STYLE InpBorderStyle = STYLE_SOLID;// Estilo del borde de la caja
input bool            InpSeparateBoxes  = true;    // Separar Cajas (true=limites de velas contenidas, false=continua)
input bool            InpBackground  = true;       // Dibujar en el fondo (detras de las velas)

sinput string InpSep_1_3             = "";     //⠀
input group "─── ■■■■■■■ [ 3. Colores de Cuerpo (Relleno) ] ───"
input color           InpBullColor        = clrPaleGreen;    // Color Relleno Alcista (Cierre >= Apertura)
input color           InpBearColor        = clrLightSalmon;  // Color Relleno Bajista (Cierre < Apertura)
input color           InpDojiColor        = clrSilver;       // Color Relleno Doji (Cierre == Apertura)

sinput string InpSep_1_3b            = "";     //⠀
input group "─── ■■■■■■■ [ 3.1 Colores de Bordes ] ───"
input bool            InpUseCustomBorderColor = true;        // Personalizar color de los bordes
input color           InpBullBorderColor  = clrMediumSeaGreen;// Color Borde Alcista
input color           InpBearBorderColor  = clrTomato;        // Color Borde Bajista
input color           InpDojiBorderColor  = clrGray;          // Color Borde Doji
input bool            InpWickUseBorderColor = true;          // Usar color del borde en las mechas

sinput string InpSep_1_4             = "";     //⠀
input group "─── ■■■■■■■ [ 4. Rango Total (High - Low) Opcional ] ───"
input bool            InpDrawFullRange =  false;    // Dibujar Caja Externa de Rango Total (High a Low)
input color           InpFullRangeColor= clrSlateGray;// Color de la caja de rango total
input ENUM_LINE_STYLE InpFullRangeStyle= STYLE_DOT;// Estilo de linea de la caja de rango total

sinput string InpSep_1_5             = "";     //⠀
input group "─── ■■■■■■■ [ 5. Etiquetas Informativas (Opcional) ] ───"
input bool            InpShowLabels  = false;       // Mostrar etiquetas de texto sobre cada vela mayor
input int             InpFontSize    = 8;           // Tamano de fuente
input color           InpLabelColor  = clrNavy;     // Color del texto
input bool            InpShowOHLC    = false;       // Mostrar precios OHLC
input bool            InpShowPoints  = false;       // Mostrar rango total en puntos
input int             InpTextOffsetPts = 50;        // Distancia sobre el High (en puntos)

//====================================================================
//                       CONSTANTES Y GLOBALES
//====================================================================
#define OBJ_PREFIX "VelaMayor_"

datetime g_lastCalculatedTime = 0;

//+------------------------------------------------------------------+
//| Formatea el Timeframe a texto legible                            |
//+------------------------------------------------------------------+
string TFToString(ENUM_TIMEFRAMES tf) {
   string s = EnumToString(tf);
   StringReplace(s, "PERIOD_", "");
   return s;
}

//+------------------------------------------------------------------+
//| Comprueba que el TF del grafico sea estrictamente inferior al TF |
//| del input para permitir el dibujado.                             |
//+------------------------------------------------------------------+
bool IsCurrentTFValid() {
   int chartSec  = PeriodSeconds((ENUM_TIMEFRAMES)_Period);
   int targetSec = PeriodSeconds(InpTimeframe);
   return (chartSec > 0 && targetSec > 0 && chartSec < targetSec);
}

//+------------------------------------------------------------------+
//| Elimina de forma exhaustiva todos los objetos creados por el EA  |
//+------------------------------------------------------------------+
void DeleteAllMyObjects() {
   ObjectsDeleteAll(0, OBJ_PREFIX, -1, -1);
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--) {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, OBJ_PREFIX) == 0) {
         ObjectDelete(0, name);
      }
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Cuenta la cantidad de objetos creados por este indicador         |
//+------------------------------------------------------------------+
int CountMyObjects() {
   int count = 0;
   int total = ObjectsTotal(0, -1, -1);
   for(int i = 0; i < total; i++) {
      if(StringFind(ObjectName(0, i, -1, -1), OBJ_PREFIX) == 0) count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Ayudante: Crea o actualiza una linea de tendencia (mechas)       |
//+------------------------------------------------------------------+
void SetTrendLine(const string name, datetime t1, double p1, datetime t2, double p2,
                  color clr, int width, ENUM_LINE_STYLE style, bool back) {
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_BACK, back);
}

//+------------------------------------------------------------------+
//| Ayudante: Crea o actualiza un rectangulo (cuerpo, borde o rango) |
//+------------------------------------------------------------------+
void SetRectangle(const string name, datetime t1, double p1, datetime t2, double p2,
                  color clr, int width, ENUM_LINE_STYLE style, bool fill, bool back) {
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FILL, fill);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_BACK, back);
}

//+------------------------------------------------------------------+
//| Inicializacion del Indicador                                     |
//+------------------------------------------------------------------+
int OnInit() {
   IndicatorSetString(INDICATOR_SHORTNAME, "VelaMayor(" + TFToString(InpTimeframe) + ")");

   DeleteAllMyObjects();
   g_lastCalculatedTime = 0;

   if(!IsCurrentTFValid()) {
      PrintFormat("ℹ️ [VelaMayor] Grafico actual (%s) no es inferior al Timeframe configurado (%s). Solo se dibujara al cambiar a un TF menor.",
                  TFToString((ENUM_TIMEFRAMES)_Period), TFToString(InpTimeframe));
      return INIT_SUCCEEDED;
   }

   EventSetTimer(1);

   if(DrawHigherTFCandles()) {
      g_lastCalculatedTime = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   }

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Desinicializacion del Indicador                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
   DeleteAllMyObjects();
}

//+------------------------------------------------------------------+
//| Dibuja si faltan objetos (por cambio de TF o sincronizacion)     |
//+------------------------------------------------------------------+
void RefreshIfMissing() {
   if(!IsCurrentTFValid()) {
      DeleteAllMyObjects();
      g_lastCalculatedTime = 0;
      return;
   }
   if(CountMyObjects() == 0) {
      if(DrawHigherTFCandles()) {
         g_lastCalculatedTime = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
      }
   }
}

//+------------------------------------------------------------------+
//| Calculo del Indicador                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   
   if(!IsCurrentTFValid()) {
      DeleteAllMyObjects();
      g_lastCalculatedTime = 0;
      return rates_total;
   }

   datetime curTime = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
   bool needFullDraw = (curTime != g_lastCalculatedTime || prev_calculated == 0 || CountMyObjects() == 0);

   if(needFullDraw) {
      if(DrawHigherTFCandles()) {
         g_lastCalculatedTime = curTime;
      }
   } else if(InpIncludeCurrent) {
      UpdateCurrentMacroCandle();
   }

   return rates_total;
}

//+------------------------------------------------------------------+
//| Temporizador para recuperar cajas tras cambios de TF o sin ticks |
//+------------------------------------------------------------------+
void OnTimer() {
   RefreshIfMissing();
}

//+------------------------------------------------------------------+
//| Evento de Grafico: Detecta cambios de TF o redimensionado        |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   if(id == CHARTEVENT_CHART_CHANGE) {
      RefreshIfMissing();
   }
}

//+------------------------------------------------------------------+
//| Calcula los limites horizontales (boxStart, boxEnd, tMid)        |
//| para que la caja solo cubra las velas inferiores correspondientes|
//+------------------------------------------------------------------+
bool GetMacroCandleBounds(int macroBarIndex, datetime macroStartTime,
                          datetime &outBoxStart, datetime &outBoxEnd, datetime &outMid) {
   int secLower = PeriodSeconds((ENUM_TIMEFRAMES)_Period);
   int secMacro = PeriodSeconds(InpTimeframe);
   if(secLower <= 0 || secMacro <= 0) return false;

   // 1. Buscar la primera vela inferior correspondiente a la macro vela
   int shiftStart = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, macroStartTime, false);
   if(shiftStart < 0) return false;

   datetime tStartLower = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, shiftStart);
   while(shiftStart > 0 && tStartLower < macroStartTime) {
      shiftStart--;
      tStartLower = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, shiftStart);
   }
   if(tStartLower >= macroStartTime + secMacro) return false;

   // 2. Determinar la ultima vela inferior correspondiente
   datetime tLastLower = tStartLower;
   if(macroBarIndex == 0) {
      datetime tCurr = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, 0);
      if(tCurr >= tStartLower && tCurr < macroStartTime + secMacro) {
         tLastLower = tCurr;
      }
   } else {
      datetime tTargetEnd = macroStartTime + secMacro - 1;
      int shiftEnd = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, tTargetEnd, false);
      if(shiftEnd >= 0) {
         datetime tCandidate = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, shiftEnd);
         int maxBars = iBars(_Symbol, (ENUM_TIMEFRAMES)_Period);
         while(shiftEnd < maxBars - 1 && tCandidate >= macroStartTime + secMacro) {
            shiftEnd++;
            tCandidate = iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, shiftEnd);
         }
         if(tCandidate >= tStartLower && tCandidate < macroStartTime + secMacro) {
            tLastLower = tCandidate;
         }
      }
   }

   if(InpSeparateBoxes) {
      if(tStartLower == tLastLower) {
         int halfBar = (int)MathMax(1, secLower / 4);
         outBoxStart = tStartLower - halfBar;
         outBoxEnd   = tStartLower + halfBar;
         outMid      = tStartLower;
      } else {
         int margin = (int)MathMax(1, secLower * 0.15);
         datetime fullEnd = tLastLower + secLower;
         outBoxStart = tStartLower + margin;
         outBoxEnd   = fullEnd - margin;
         outMid      = tStartLower + (fullEnd - tStartLower) / 2;
      }
   } else {
      outBoxStart = macroStartTime;
      outBoxEnd   = macroStartTime + secMacro;
      outMid      = macroStartTime + secMacro / 2;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Renderiza una unica vela mayor (indice b)                        |
//+------------------------------------------------------------------+
bool RenderMacroCandle(int b) {
   datetime tStart = iTime(_Symbol, InpTimeframe, b);
   if(tStart <= 0) return false;

   datetime boxStart, boxEnd, tMid;
   if(!GetMacroCandleBounds(b, tStart, boxStart, boxEnd, tMid)) return false;

   double o = iOpen(_Symbol, InpTimeframe, b);
   double h = iHigh(_Symbol, InpTimeframe, b);
   double l = iLow(_Symbol, InpTimeframe, b);
   double c = iClose(_Symbol, InpTimeframe, b);
   if(h <= 0.0 || l <= 0.0) return false;

   string barId = IntegerToString((long)tStart);
   color candleClr = (c > o) ? InpBullColor : ((c < o) ? InpBearColor : InpDojiColor);
   color borderClr = candleClr;
   if(InpUseCustomBorderColor) {
      borderClr = (c > o) ? InpBullBorderColor : ((c < o) ? InpBearBorderColor : InpDojiBorderColor);
   }
   color wickClr = InpWickUseBorderColor ? borderClr : candleClr;

   double topPrice = MathMax(o, c);
   double botPrice = MathMin(o, c);
   if(topPrice == botPrice) { topPrice += _Point; botPrice -= _Point; }

   // 1. Mechas Superior e Inferior
   string wickUpName = OBJ_PREFIX + "WUP_" + barId;
   if(InpDrawWicks && h > topPrice) {
      SetTrendLine(wickUpName, tMid, topPrice, tMid, h, wickClr, InpWickWidth, InpWickStyle, InpBackground);
   } else {
      if(ObjectFind(0, wickUpName) >= 0) ObjectDelete(0, wickUpName);
   }

   string wickDnName = OBJ_PREFIX + "WDN_" + barId;
   if(InpDrawWicks && l < botPrice) {
      SetTrendLine(wickDnName, tMid, l, tMid, botPrice, wickClr, InpWickWidth, InpWickStyle, InpBackground);
   } else {
      if(ObjectFind(0, wickDnName) >= 0) ObjectDelete(0, wickDnName);
   }

   // 2. Caja del Cuerpo (Relleno y Borde)
   string bodyName   = OBJ_PREFIX + "BODY_" + barId;
   string borderName = OBJ_PREFIX + "BDR_"  + barId;

   if(InpDrawBody) {
      if(InpFillBody) {
         SetRectangle(bodyName, boxStart, topPrice, boxEnd, botPrice, candleClr, 1, STYLE_SOLID, true, InpBackground);
      } else {
         if(ObjectFind(0, bodyName) >= 0) ObjectDelete(0, bodyName);
      }
      SetRectangle(borderName, boxStart, topPrice, boxEnd, botPrice, borderClr, InpBorderWidth, InpBorderStyle, false, InpBackground);
   } else {
      if(ObjectFind(0, bodyName) >= 0) ObjectDelete(0, bodyName);
      if(ObjectFind(0, borderName) >= 0) ObjectDelete(0, borderName);
   }

   // 3. Caja de Rango Total (High a Low) Opcional
   string rngName = OBJ_PREFIX + "RNG_" + barId;
   if(InpDrawFullRange) {
      SetRectangle(rngName, boxStart, h, boxEnd, l, InpFullRangeColor, 1, InpFullRangeStyle, false, InpBackground);
   } else {
      if(ObjectFind(0, rngName) >= 0) ObjectDelete(0, rngName);
   }

   // 4. Etiqueta Informativa Opcional
   string lblName = OBJ_PREFIX + "LBL_" + barId;
   if(InpShowLabels) {
      double pt = _Point;
      if(_Digits == 3 || _Digits == 5) pt *= 10.0;
      double lblPrice = h + InpTextOffsetPts * pt;

      string lblText = "[" + TFToString(InpTimeframe) + "]";
      if(b == 0) lblText += " (En curso)";

      if(InpShowOHLC) {
         lblText += StringFormat(" | O:%.*f H:%.*f L:%.*f C:%.*f", _Digits, o, _Digits, h, _Digits, l, _Digits, c);
      }
      if(InpShowPoints) {
         double rangePts = (h - l) / pt;
         lblText += StringFormat(" (%.1f pts)", rangePts);
      }

      if(ObjectFind(0, lblName) < 0) {
         ObjectCreate(0, lblName, OBJ_TEXT, 0, boxStart, lblPrice);
         ObjectSetInteger(0, lblName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, lblName, OBJPROP_HIDDEN, false);
         ObjectSetInteger(0, lblName, OBJPROP_BACK, false);
         ObjectSetString(0, lblName, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, InpFontSize);
         ObjectSetInteger(0, lblName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      }
      ObjectSetInteger(0, lblName, OBJPROP_TIME, 0, boxStart);
      ObjectSetDouble(0, lblName, OBJPROP_PRICE, 0, lblPrice);
      ObjectSetString(0, lblName, OBJPROP_TEXT, lblText);
      ObjectSetInteger(0, lblName, OBJPROP_COLOR, InpLabelColor);
   } else {
      if(ObjectFind(0, lblName) >= 0) ObjectDelete(0, lblName);
   }

   return true;
}

//+------------------------------------------------------------------+
//| Dibuja las Velas Mayores en el Grafico                           |
//+------------------------------------------------------------------+
bool DrawHigherTFCandles() {
   if(!IsCurrentTFValid()) {
      DeleteAllMyObjects();
      return false;
   }

   int startBar = InpIncludeCurrent ? 0 : 1;
   int totalHigherBars = iBars(_Symbol, InpTimeframe);
   if(totalHigherBars <= 0) return false;

   int maxBars = MathMin(InpBarsCount + startBar, totalHigherBars);
   int drawnCount = 0;

   for(int b = startBar; b < maxBars; b++) {
      if(RenderMacroCandle(b)) drawnCount++;
   }

   // Limpieza de velas antiguas mas alla del alcance configurado
   datetime oldestAllowed = iTime(_Symbol, InpTimeframe, maxBars - 1);
   if(oldestAllowed > 0) {
      CleanOldObjects(oldestAllowed);
   }

   ChartRedraw(0);
   return (drawnCount > 0);
}

//+------------------------------------------------------------------+
//| Actualiza dinamicamente la vela mayor en curso (Vela 0)          |
//+------------------------------------------------------------------+
void UpdateCurrentMacroCandle() {
   if(!InpIncludeCurrent || !IsCurrentTFValid()) return;
   if(RenderMacroCandle(0)) {
      ChartRedraw(0);
   }
}

//+------------------------------------------------------------------+
//| Elimina objetos de velas que exceden el numero configurado       |
//+------------------------------------------------------------------+
void CleanOldObjects(datetime oldestAllowed) {
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--) {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, OBJ_PREFIX) == 0) {
         string parts[];
         int count = StringSplit(name, '_', parts);
         if(count >= 3) {
            datetime barTime = (datetime)StringToInteger(parts[2]);
            if(barTime > 0 && barTime < oldestAllowed) {
               ObjectDelete(0, name);
            }
         } else {
            datetime objTime = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME, 0);
            if(objTime < oldestAllowed - PeriodSeconds((ENUM_TIMEFRAMES)_Period)) {
               ObjectDelete(0, name);
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
