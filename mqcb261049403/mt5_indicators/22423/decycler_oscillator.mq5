//+------------------------------------------------------------------+
//|                                          Decycler_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "John F.Ehlers Decycler Oscillator"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot DO
#property indicator_label1  "Decycler Osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input double               InpPeriodHP       =  125.0;         // HP period
input double               InpCoefficient    =  1.0;           // Coefficient
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferDO[];
double         BufferHP[];
double         BufferDecycle[];
double         BufferDecycleOsc[];
double         BufferMA[];
//--- global variables
double         period_hp;
double         coefficient;
double         angle1;
double         angle2;
double         alpha1;
double         alpha2;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_hp=(InpPeriodHP<2 ? 2 : InpPeriodHP);
   coefficient=(InpCoefficient==0 ? Point() : InpCoefficient);
   angle1=1.414*M_PI/period_hp;
   angle2=2.0*angle1;
   alpha1=(cos(angle1)+sin(angle1)-1.0)/cos(angle1);
   alpha2=(cos(angle2)+sin(angle2)-1.0)/cos(angle2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferDecycle,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDecycleOsc,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Decycler Oscillator ("+DoubleToString(period_hp,1)+","+DoubleToString(coefficient,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDO,true);
   ArraySetAsSeries(BufferHP,true);
   ArraySetAsSeries(BufferDecycle,true);
   ArraySetAsSeries(BufferDecycleOsc,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferDO,0);
      ArrayInitialize(BufferHP,0);
      ArrayInitialize(BufferDecycle,0);
      ArrayInitialize(BufferDecycleOsc,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double a1=1.0-alpha1;
      double a2=1.0-alpha1/2.0;
      double a3=a1*a1;
      double a4=a2*a2;
      double pr2=2.0*BufferMA[i+1];
      double pr3=BufferMA[i]-pr2+BufferMA[i+2];
      BufferHP[i]=a4*pr3+(2.0*a1*BufferHP[i+1])-(a3*BufferHP[i+2]);
      BufferDecycle[i]=BufferMA[i]-BufferHP[i];
      
      double b1=1.0-alpha2;
      double b2=1.0-alpha2/2.0;
      double b3=b1*b1;
      double b4=b2*b2;
      double pr4=2.0*BufferDecycle[i+1];
      double pr5=BufferDecycle[i]-pr4+BufferDecycle[i+2];
      BufferDecycleOsc[i]=b4*pr5+(2.0*b1*BufferDecycleOsc[i+1])-(b3*BufferDecycleOsc[i+2]);
      BufferDO[i]=(BufferMA[i]!=0 ? 100.0*coefficient*BufferDecycleOsc[i]/BufferMA[i] : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
