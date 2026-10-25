//+------------------------------------------------------------------+
//|                                                  NonLagMA_v1.mq5 |
//|                                Copyright © 2012, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  Silver,DeepSkyBlue,OrangeRed
#property indicator_width1  2

#define pi     3.1415926535

input ENUM_TIMEFRAMES      TimeFrame   =     0;
input ENUM_APPLIED_PRICE   Price       = PRICE_CLOSE; //Apply to
input int                  Length      =     9;       //Length in bars  
input double               PointFilter =     0;       //Filter in pips 
input double               PctFilter   =     0;       //Dynamic Filter in decimal(ex.0.5)
input int                  Shift       =     0;       //Shift in bars
input int                  ColorMode   =     0;       //Color Mode(0-off,1-on) 
input int                  CountBars   =     0;       //CountBars(0-full history)

double  nlma[];
double  trend[];

ENUM_TIMEFRAMES  tf;
int Price_handle, mtf_handle, prevBars, Len;
double  alpha[], mtf_nlma[], mtf_trend[1], price[], Weight, point;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   if(TimeFrame <= Period()) tf = Period(); else tf = TimeFrame;   
//--- 
   SetIndexBuffer(0, nlma,        INDICATOR_DATA); PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
   SetIndexBuffer(1,trend, INDICATOR_COLOR_INDEX);
//--- 
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- 
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- 
   string short_name = "NonLagMA_v1["+timeframeToString(TimeFrame)+"]("+priceToString(Price)+","+(string)Length+","+(string)PointFilter+","+(string)PctFilter+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,"NonLagMA_v1["+timeframeToString(TimeFrame)+"]");
//--- 
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2);
     
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
      
//---
   Price_handle = iMA(NULL,tf,1,0,0,Price);
   
   if(TimeFrame > 0) mtf_handle = iCustom(NULL,TimeFrame,"NonLagMA_v1",0,Price,Length,PointFilter,PctFilter,Shift,ColorMode,CountBars);
   else
   {
   double t, coeff, g, phase, cycle = 4;;
   
   coeff = 3*pi;
   phase = Length - 1;
   Len   = (int)(Length*4 + phase);  
   
   ArrayResize(alpha,Len);
   
   Weight = 0;    
      for(int i = 0;i < Len;i++)
      {
      if(i <= phase - 1) t = 1.0*i/(phase - 1); else t = 1.0 + (i - phase + 1)*(2*cycle - 1.0)/(cycle*Length - 1.0); 
      if(t <= 0.5) g = 1.0; else g = 1/(coeff*t + 1);   
      alpha[i] = g*MathCos(pi*t);
      Weight += alpha[i];
      }
   }
   
   point   = _Point*MathPow(10,_Digits%2);
//---   
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Len);
//--- initialization done   
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double   &Open[],
                const double   &High[],
                const double   &Low[],
                const double   &Close[],
                const long     &TickVolume[],
                const long     &Volume[],
                const int      &Spread[])
{
   int i, x, y, shift, limit, mtflimit, copied = 0;
   double filter, sumDel, avgDel, sumPow, stdDev;
   datetime mtf_time;
//--- preliminary calculations
        
   if(prev_calculated == 0) 
   {
   limit  = 0; 
   mtflimit = rates_total - 1;
   ArrayInitialize(nlma,EMPTY_VALUE);
   }
   else 
   {
   limit = rates_total - 1;
   mtflimit = PeriodSeconds(tf)/PeriodSeconds(Period());
   }
     
   copied = CopyBuffer(Price_handle,0,Time[rates_total-1],Time[0],price);
   
   if(copied<0)
   {
   Print("not all prices copied. Will try on next tick Error =",GetLastError(),", copied =",copied);
   return(0);
   }
   
   if(tf > Period())
   { 
   ArraySetAsSeries(Time,true);   
  
      for(shift=0,y=0;shift<mtflimit;shift++)
      {
      if(Time[shift] < iTime(NULL,TimeFrame,y)) y++; 
      mtf_time = iTime(NULL,TimeFrame,y);
      
      copied = CopyBuffer(mtf_handle,0,mtf_time,mtf_time,mtf_nlma);
      if(copied <= 0) return(0);
      
      x = rates_total - shift - 1;
      nlma[x] = mtf_nlma[0];
     
      
         if(ColorMode > 0)
         {
         copied = CopyBuffer(mtf_handle,1,mtf_time,mtf_time,mtf_trend);   
         trend[x] = mtf_trend[0];   
         }
         else trend[x] = 0; 
      }
   }
   else
   {
      for(shift=limit;shift<rates_total;shift++)
      {
      if((CountBars > 0 && shift < rates_total - CountBars)||shift < Len) continue;  
   
      double sum = price[shift]*alpha[0];
      for(i = 1; i < Len; i++) sum += price[shift-i]*alpha[i];
   
      if(Weight > 0) nlma[shift] = sum/Weight;
        
      if(PctFilter > 0 && ((CountBars > 0 && shift < rates_total - CountBars + Len + Length)||(CountBars == 0 && shift < Len + Length))) continue;   
   
         if(PctFilter > 0 && nlma[shift-1] > 0)
         {
         sumDel = MathAbs(nlma[shift] - nlma[shift-1]);
         for (i=1;i<Length;i++) sumDel += MathAbs(nlma[shift-i] - nlma[shift-i-1]);
         avgDel = sumDel/Length;
    
         sumPow = MathPow(MathAbs(nlma[shift] - nlma[shift-1])-avgDel,2);
         for (i=1;i<Length;i++) sumPow += MathPow(MathAbs(nlma[shift-i] - nlma[shift-i-1])-avgDel,2);
         stdDev = MathSqrt(sumPow/Length); 
     
         filter = PctFilter*stdDev;
         }
         else if(PointFilter > 0) filter = PointFilter*point; 
         else filter = 0;
   
      if(MathAbs(nlma[shift] - nlma[shift-1]) < filter ) nlma[shift] = nlma[shift-1];
   
      
         if(shift > 0)
         {
            if(ColorMode > 0 && nlma[shift-1] > 0)
            {
            trend[shift] = trend[shift-1];
            if(nlma[shift] > nlma[shift-1]) trend[shift] = 1;
            if(nlma[shift] < nlma[shift-1]) trend[shift] = 2;    
            }    
            else trend[shift] = 0; 
         }
      }
   }
      
   
   return(rates_total);
}
//+------------------------------------------------------------------+
string timeframeToString(ENUM_TIMEFRAMES TF)
{
   switch(TF)
   {
   case PERIOD_CURRENT  : return("Current");
   case PERIOD_M1       : return("M1");   
   case PERIOD_M2       : return("M2");
   case PERIOD_M3       : return("M3");
   case PERIOD_M4       : return("M4");
   case PERIOD_M5       : return("M5");      
   case PERIOD_M6       : return("M6");
   case PERIOD_M10      : return("M10");
   case PERIOD_M12      : return("M12");
   case PERIOD_M15      : return("M15");
   case PERIOD_M20      : return("M20");
   case PERIOD_M30      : return("M30");
   case PERIOD_H1       : return("H1");
   case PERIOD_H2       : return("H2");
   case PERIOD_H3       : return("H3");
   case PERIOD_H4       : return("H4");
   case PERIOD_H6       : return("H6");
   case PERIOD_H8       : return("H8");
   case PERIOD_H12      : return("H12");
   case PERIOD_D1       : return("D1");
   case PERIOD_W1       : return("W1");
   case PERIOD_MN1      : return("MN1");      
   default              : return("Current");
   }
}

string priceToString(ENUM_APPLIED_PRICE app_price)
{
   switch(app_price)
   {
   case PRICE_CLOSE   :    return("Close");
   case PRICE_HIGH    :    return("High");
   case PRICE_LOW     :    return("Low");
   case PRICE_MEDIAN  :    return("Median");
   case PRICE_OPEN    :    return("Open");
   case PRICE_TYPICAL :    return("Typical");
   case PRICE_WEIGHTED:    return("Weighted");
   default            :    return("");
   }
}

datetime iTime(string symbol,ENUM_TIMEFRAMES TF,int index)
{
   if(index < 0) return(-1);
   static datetime timearray[];
   if(CopyTime(symbol,TF,index,1,timearray) > 0) return(timearray[0]); else return(-1);
}
