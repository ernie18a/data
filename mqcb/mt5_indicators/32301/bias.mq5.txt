//+------------------------------------------------------------------+
//|                                                         BIAS.mq5 |
//|                                                        Submarine |
//|                                      WeChart : shunmaolinhongwen |
//+------------------------------------------------------------------+
#property copyright "Submarine"
#property link      "https://www.mql5.com/en/users/carllin000"
#property version   "1.00"
#property description "BIAS"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Long
#property indicator_label1  "Long"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Mid
#property indicator_label2  "Mid"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Short
#property indicator_label3  "Short"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1



//--- indicator buffers
double         LongBuffer[];
double         MidBuffer[];
double         ShortBuffer[];

int Long_h;
int Mid_h;
int Short_h;
int Close_h;

input ENUM_TIMEFRAMES InPeriod = PERIOD_CURRENT;
input int InLong  = 6;
input int InMid   = 12;
input int InShort = 24;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping
   SetIndexBuffer(0, LongBuffer);
   SetIndexBuffer(1, MidBuffer);
   SetIndexBuffer(2, ShortBuffer);
   IndicatorSetString(INDICATOR_SHORTNAME,"BIAS("+string(InLong)+","+string(InMid)+","+string(InShort)+")");

   Long_h  = iMA(NULL,InPeriod,InLong,0,0,0);
   Mid_h   = iMA(NULL,InPeriod,InMid,0,0,0);
   Short_h = iMA(NULL,InPeriod,InShort,0,0,0);
   Close_h = iMA(NULL,InPeriod,1,0,0,0);

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

   double Long[];
   if(CopyBuffer(Long_h,0,0,rates_total,Long)<=0)
      return(0);

   double Mid[];
   if(CopyBuffer(Mid_h,0,0,rates_total,Mid)<=0)
      return(0);

   double Short[];
   if(CopyBuffer(Short_h,0,0,rates_total,Short)<=0)
      return(0);

   double Close[];
   if(CopyBuffer(Close_h,0,0,rates_total,Close)<=0)
      return(0);

   int start=100;
   if(prev_calculated>0)
      start=prev_calculated-1;
   for(int i=start; i<rates_total; i++)
     {


      LongBuffer[i]  = ((Close[i]-Long[i]) / (Long[i]) *100);
      MidBuffer[i]   = ((Close[i]-Mid[i])  / (Mid[i])  *100);
      ShortBuffer[i] = ((Close[i]-Short[i])/ (Short[i])*100);


      /*
       BIAS1 : (CLOSE-MA(CLOSE,L1））/MA(CLOSE,L1）*100;
       BIAS2 : (CLOSE-MA(CLOSE,L2））/MA(CLOSE,L2）*100;
       BIAS3 : (CLOSE-MA(CLOSE,L3））/MA(CLOSE,L3）*100;
      */
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
