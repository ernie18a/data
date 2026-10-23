//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property strict

#property indicator_separate_window
#property indicator_level1 0.0
#property indicator_buffers 1
#property indicator_color1 clrDodgerBlue
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_PRICE_TYPE
  {
   PRICE_TYPE_CLOSE,      // Close / Закрытие   
   PRICE_TYPE_OPEN,       // Open / Открытие   
   PRICE_TYPE_HIGH,       // High / Максимум
   PRICE_TYPE_LOW,        // Low / Минимум
   PRICE_TYPE_MEDIAN,     // Median / Средняя
   PRICE_TYPE_TYPICAL,    // Typical / Типичная
   PRICE_TYPE_WEIGHTED,   // Weighted close / Взвешенное закрытие
   PRICE_TYPE_FULL_MEDIAN // Full median / Полная средняя
  };
//+------------------------------------------------------------------+
input int             i_slowing      = 34;             // Slowing / Запаздывание
input ENUM_PRICE_TYPE i_price        = PRICE_TYPE_WEIGHTED; // Applied price / Используемая цена
input int             i_indBarsCount = 10000;          // The number of bars to display / Количество баров отображения
//--- The indicator's buffers
double            g_indValues[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!IsTuningParametersCorrect())
      return INIT_FAILED;
//---
   if(!BuffersBind())
      return (INIT_FAILED);
//---
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Checking the correctness of input parameters                     |
//+------------------------------------------------------------------+
bool IsTuningParametersCorrect()
  {
   string name=WindowExpertName();
//---
   bool isRussianLang=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
//---
   if(i_slowing<1)
     {
      Alert(name,(isRussianLang)? ": период замедления должен быть более 0. Индикатор отключен." :
            ": period of slowing must be more than zero. The indicator is turned off.");
      return false;
     }
//---
   return (true);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Binding of array and the indicator buffers                       |
//+------------------------------------------------------------------+
bool BuffersBind()
  {
   string name=WindowExpertName();
//---
   bool isRussianLang=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian");
//--- Binding the array and indicator buffer
   if(!SetIndexBuffer(0,g_indValues))
     {
      Alert(name,(isRussianLang)? ": ошибка связывания массивов с буферами индикатора. Ошибка №"+IntegerToString(GetLastError()) :
            ": error of binding of the arrays and the indicator buffers. Error N"+IntegerToString(GetLastError()));
      return false;
     }
//--- Set the type of indicator's buffer
   SetIndexStyle(0,DRAW_LINE);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Initialize of all indicator buffers                              |
//+------------------------------------------------------------------+
void BuffersInitializeAll()
  {
   ArrayInitialize(g_indValues,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Determination of bar index which needed to recalculate           |
//+------------------------------------------------------------------+
int GetRecalcIndex(int &total,const int ratesTotal,const int prevCalculated)
  {
   total=ratesTotal-i_slowing-2;
//---
   if(i_indBarsCount>0 && i_indBarsCount<total)
      total=MathMin(i_indBarsCount,total);
//---
   if(prevCalculated<ratesTotal-1)
     {
      BuffersInitializeAll();
      return total;
     }
//---
   return (MathMin(ratesTotal - prevCalculated, total));
  }
//+------------------------------------------------------------------+
//| Calculation the applied price                                    |
//+------------------------------------------------------------------+
double GetPrice(int barIndex)
  {
   double open=iOpen(NULL,0,barIndex);
   double close= iClose(NULL,0,barIndex);
   double high = iHigh(NULL,0,barIndex);
   double low=iLow(NULL,0,barIndex);
//---
   switch(i_price)
     {
      case PRICE_TYPE_CLOSE:           return close;
      case PRICE_TYPE_OPEN:            return open;
      case PRICE_TYPE_HIGH:            return high;
      case PRICE_TYPE_LOW:             return low;
      case PRICE_TYPE_MEDIAN:          return (high + low) / 2;
      case PRICE_TYPE_TYPICAL:         return (high + low + close) / 3;
      case PRICE_TYPE_WEIGHTED:        return (high + low + 2 * close) / 4;
      case PRICE_TYPE_FULL_MEDIAN:     return (high + low + open + close) / 4;
     }
//---
   return 0.0;
  }
//+------------------------------------------------------------------+
//| Calculation of indicators values                                 |
//+------------------------------------------------------------------+
void CalcIndicatorData(int limit,int total)
  {
   for(int i=limit; i>=0; i--)
      g_indValues[i]=100.0 *(GetPrice(i)-GetPrice(i+i_slowing))/i_slowing;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int &spread[])
  {
   int total;
   int limit=GetRecalcIndex(total,rates_total,prev_calculated);
//---
   CalcIndicatorData(limit,total);
//---
   return rates_total;
  }
//+------------------------------------------------------------------+
