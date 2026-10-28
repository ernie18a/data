//+------------------------------------------------------------------+
//|                                   Advanced_Fractal_Envelopes.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Advanced Fractal Envelopes"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot Top
#property indicator_label1  "Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Central
#property indicator_label2  "Central"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "Bottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot FrUP
#property indicator_label4  "Fractal up"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot FrDN
#property indicator_label5  "Fractal down"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrLimeGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodAVG      =  5;          // Average
input ENUM_INPUT_YES_NO InpShowCentral    =  INPUT_YES;  // Show central line
input ENUM_INPUT_YES_NO InpShowFractals   =  INPUT_YES;  // Show fractals
//--- indicator buffers
double         BufferTop[];
double         BufferCentral[];
double         BufferBottom[];
double         BufferFractUP[];
double         BufferFractDN[];
//--- global variables
int            period_avg;
int            handle_fr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_avg=int(InpPeriodAVG<1 ? 1 : InpPeriodAVG);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCentral,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferFractUP,INDICATOR_DATA);
   SetIndexBuffer(4,BufferFractDN,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Advanced Fractal Envelopes ("+(string)period_avg+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,(InpShowCentral ? DRAW_SECTION : DRAW_NONE));
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,(InpShowFractals ? DRAW_ARROW : DRAW_NONE));
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,(InpShowFractals ? DRAW_ARROW : DRAW_NONE));
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(3,PLOT_ARROW,217);
   PlotIndexSetInteger(4,PLOT_ARROW,218);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferCentral,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferFractUP,true);
   ArraySetAsSeries(BufferFractDN,true);
//--- create handles
   ResetLastError();
   handle_fr=iFractals(NULL,PERIOD_CURRENT);
   if(handle_fr==INVALID_HANDLE)
     {
      Print("The iFractals object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_avg,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_avg-2;
      ArrayInitialize(BufferTop,0);
      ArrayInitialize(BufferCentral,0);
      ArrayInitialize(BufferBottom,0);
      ArrayInitialize(BufferFractUP,0);
      ArrayInitialize(BufferFractDN,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fr,UPPER_LINE,0,count,BufferFractUP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_fr,LOWER_LINE,0,count,BufferFractDN);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double average=0, fractal=BufferFractUP[i];
      int k=1,total=1;
      if(fractal>0 && fractal<EMPTY_VALUE)
        {
         average=fractal;
      //--- Average
         while(total<period_avg && i+k<rates_total-2)
           {
            if(BufferFractUP[i+k]>0 && BufferFractUP[i+k]<EMPTY_VALUE)
              {
               average+=BufferFractUP[i+k];
               total++;
              }
            k++;
           }
         BufferTop[i]=average/period_avg;
      //--- Next Fractal to fill all the bars with the average value
         int m=1,next=WRONG_VALUE;
         while(next==WRONG_VALUE && i-m>WRONG_VALUE)
           {
            if(i-m<=0)
              {
               next=0;
               break;
              }
            else
              {
               if(BufferFractUP[i-m]>0 && BufferFractUP[i-m]<EMPTY_VALUE)
                  next=i-m;
              }
            m++;
           }
         for(int j=i; j>=next && j>=0; j--)
            BufferTop[j]=BufferTop[i];
        }
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double average=0, fractal=BufferFractDN[i];
      int k=1,total=1;
      if(fractal>0 && fractal<EMPTY_VALUE)
        {
         average=fractal;
         //
      //--- Average
         while(total<period_avg && i+k<rates_total-2)
           {
            if(BufferFractDN[i+k]>0 && BufferFractDN[i+k]<EMPTY_VALUE)
              {
               average+=BufferFractDN[i+k];
               total++;
              }
            k++;
           }
         BufferBottom[i]=average/period_avg;
      //--- Next Fractal to fill all the bars with the average value
         int m=1,next=WRONG_VALUE;
         while(next==WRONG_VALUE && i-m>WRONG_VALUE)
           {
            if(i-m<=0)
              {
               next=0;
               break;
              }
            else
              {
               if(BufferFractDN[i-m]>0 && BufferFractDN[i-m]<EMPTY_VALUE)
                  next=i-m;
              }
            m++;
           }
         for(int j=i; j>=next && j>=0; j--)
           {
            BufferBottom[j]=BufferBottom[i];
           }
        }
      BufferCentral[i]=(BufferTop[i]+BufferBottom[i])/2.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
