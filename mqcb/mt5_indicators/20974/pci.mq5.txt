//+------------------------------------------------------------------+
//|                                                          PCI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Phase Change Index indicator"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 6
#property indicator_plots   3
//--- plot H1
#property indicator_label1  "Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot H3
#property indicator_label2  "H3"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrLightSteelBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot PCI
#property indicator_label3  "PCI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriod         =  34;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpOverbought     =  80.0;          // Overbought
input double               InpOversold       =  20.0;          // Oversold
//--- indicator buffers
double         BufferH1[];
double         BufferColors[];
double         BufferH3[];
double         BufferPCI[];
double         BufferMA[];
double         BufferSignal[];
//--- global variables
double         overbought;
double         oversold;
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   oversold=(InpOversold<0 ? 0 : InpOversold>99.9 ? 99.9 : InpOversold);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   if(overbought<=oversold) overbought=oversold+0.1;
   if(oversold>=overbought) oversold=overbought-0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferH1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferH3,INDICATOR_DATA);
   SetIndexBuffer(3,BufferPCI,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSignal,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Phase Change Index ("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_SOLID);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,50.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,oversold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPCI,true);
   ArraySetAsSeries(BufferH3,true);
   ArraySetAsSeries(BufferH1,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferSignal,true);
//--- create MA's handles
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
      limit=rates_total-period-1;
      ArrayInitialize(BufferH1,EMPTY_VALUE);
      ArrayInitialize(BufferH3,EMPTY_VALUE);
      ArrayInitialize(BufferPCI,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferSignal,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Momentum=(BufferMA[i]-BufferMA[i+period-1])/period;
      double Up=0,Dn=0;
      for(int j=0; j<=period; j++)
        {
         double Gradient=BufferMA[i+period]+Momentum*j;
         if(BufferMA[i+period-j]-Gradient>0.)
            Up+=fabs(BufferMA[i+period-j]-Gradient);
         else if(BufferMA[i+period-j]-Gradient<0.)
            Dn+=fabs(BufferMA[i+period-j]-Gradient);
        }

      BufferPCI[i]=(Up+Dn!=0 ? 100.0*Up/(Up+Dn) : 0);
      if(Momentum>0)
        {
         if(BufferPCI[i]<oversold)
            BufferSignal[i]=1;
         else
            BufferSignal[i]=BufferSignal[i+1];
        }
      else
        {
         if(BufferPCI[i]>overbought)
            BufferSignal[i]=-1;
         else
            BufferSignal[i]=BufferSignal[i+1];
        }

      if(BufferSignal[i]==1)
        {
         if(BufferPCI[i]>50)
           {
            BufferH1[i]=BufferPCI[i];
            BufferH3[i]=50;
           }
         else
           {
            BufferH1[i]=50;
            BufferH3[i]=BufferPCI[i];
           }
         BufferColors[i]=0;
        }
      else
        {
         if(BufferSignal[i]==-1)
           {
            if(BufferPCI[i]>50)
              {
               BufferH1[i]=BufferPCI[i];
               BufferH3[i]=50;
               BufferColors[i]=1;
              }
            else
              {
               BufferH1[i]=50.;
               BufferH3[i]=BufferPCI[i];
              }
            BufferColors[i]=1;
           }
        }

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
