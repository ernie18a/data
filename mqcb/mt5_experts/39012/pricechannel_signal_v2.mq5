//+------------------------------------------------------------------+
//|                                       PriceChannel_Signal_v2.mq5 |
//|                                Copyright © 2013, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   6


#property indicator_label1  "UpTrend Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "DnTrend Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "UpTrend Re-Entry"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDeepSkyBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "DnTrend Re-Entry"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

#property indicator_label5  "UpTrend Exit"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrDeepSkyBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

#property indicator_label6  "DnTrend Exit"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrOrangeRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2

//---- indicator parameters
input ENUM_TIMEFRAMES      TimeFrame      =  0;
input int                  Length         =  9;    // Price Channel Period
input ENUM_APPLIED_PRICE   Price          =  PRICE_CLOSE;    // Applied Price
input double               Risk           =  3;    // Risk Factor in units (0...10)
input double               ExitLevel      =  5;    // Exit Level in units (>Risk)
input int                  UseReEntry     =  1;    // Re-Entry Mode: 0-off,1-on
input int                  UseExit        =  1;    // Exit Mode: 0-off,1-on
input int                  AlertMode      =  0;    // Alert Mode: 0-off,1-on
input int                  WarningMode    =  0;    // Warning Mode: 0-off,1-on
input string               WarningSound   =  "tick.wav";

//---- indicator buffers
double UpSignal[];
double DnSignal[];
double UpEntry[];
double DnEntry[];
double UpExit[];
double DnExit[];
double price[];
double atr[];
double trend[];

double UpBand[3], LoBand[3], UpExitLevel[2], LoExitLevel[2];
int    Price_handle, atr_handle;
datetime prevTime, prevAlertTime;
bool   UpTrendAlert = false, DownTrendAlert = false;
int    min_rates_total, mtf_handle;
ENUM_TIMEFRAMES  tf;
double   mtf_UpSignal[1], mtf_DnSignal[1], mtf_UpEntry[1], mtf_DnEntry[1], mtf_UpExit[1], mtf_DnExit[1];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   if(TimeFrame <= Period())
      tf = Period();
   else
      tf = TimeFrame;
//--- indicator buffers mapping
   SetIndexBuffer(0,UpSignal,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_ARROW,108);
   SetIndexBuffer(1,DnSignal,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_ARROW,108);
   SetIndexBuffer(2, UpEntry,INDICATOR_DATA);
   PlotIndexSetInteger(2,PLOT_ARROW,217);
   SetIndexBuffer(3, DnEntry,INDICATOR_DATA);
   PlotIndexSetInteger(3,PLOT_ARROW,218);
   SetIndexBuffer(4,  UpExit,INDICATOR_DATA);
   PlotIndexSetInteger(4,PLOT_ARROW,251);
   SetIndexBuffer(5,  DnExit,INDICATOR_DATA);
   PlotIndexSetInteger(5,PLOT_ARROW,251);
   SetIndexBuffer(6,   price,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,     atr,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,   trend,INDICATOR_CALCULATIONS);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0.0);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   string short_name = "PriceChannel_Signal_v2["+timeframeToString(TimeFrame)+"]("+(string)Length+","+priceToString(Price)+","+DoubleToString(Risk,2)+","+(string)UseReEntry+","+(string)UseExit+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- sets first bar from what index will be drawn
   int begin = (int)MathMax(2,Length);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,begin);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,begin);
//---
   Price_handle = iMA(NULL,0,1,0,0,Price);
   atr_handle   = iATR(NULL,0,Length);
   if(TimeFrame > 0)
      mtf_handle   = iCustom(Symbol(),TimeFrame,"PriceChannel_Signal_v2",0,Length,Price,Risk,ExitLevel,UseReEntry,UseExit,0,0,"");
//--- initialization done
  }
//+------------------------------------------------------------------+
//| PriceChannel_Signal_v2                                           |
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
   int shift, limit, mtflimit,  x, y, copied = 0;
   double up, lo;
   datetime mtf_time;
//--- preliminary calculations
   if(prev_calculated == 0)
     {
      limit    = Length;
      mtflimit = rates_total - 1;
     }
   else
     {
      limit = prev_calculated-1;
      mtflimit = PeriodSeconds(tf)/PeriodSeconds(Period());
     }
   copied = CopyBuffer(Price_handle,0,0,rates_total-1,price);
   if(copied<0)
     {
      Print("not all prices copied. Will try on next tick Error =",GetLastError(),", copied =",copied);
      return(0);
     }
   copied = CopyBuffer(atr_handle,0,0,rates_total-1,atr);
   if(copied<0)
     {
      Print("not all ATRs copied. Will try on next tick Error =",GetLastError(),", copied =",copied);
      return(0);
     }
//--- the main loop of calculations
   if(tf > Period())
     {
      ArraySetAsSeries(Time,true);
      for(shift=0,y=0; shift<mtflimit; shift++)
        {
         //---
         UpSignal[x]=0.0;
         DnSignal[x]=0.0;
         UpEntry[x]=0.0;
         DnEntry[x]=0.0;
         UpExit[x]=0.0;
         DnExit[x]=0.0;
         //---
         if(Time[shift] < iTime(NULL,TimeFrame,y))
            y++;
         mtf_time = iTime(NULL,TimeFrame,y);
         x = rates_total - shift - 1;
         copied = CopyBuffer(mtf_handle,0,mtf_time,mtf_time,mtf_UpSignal);
         if(copied <= 0)
            return(0);
         copied = CopyBuffer(mtf_handle,1,mtf_time,mtf_time,mtf_DnSignal);
         if(copied <= 0)
            return(0);
         UpSignal[x] = mtf_UpSignal[0];
         DnSignal[x] = mtf_DnSignal[0];
         if(UseReEntry > 0)
           {
            copied = CopyBuffer(mtf_handle,2,mtf_time,mtf_time,mtf_UpEntry);
            if(copied <= 0)
               return(0);
            copied = CopyBuffer(mtf_handle,3,mtf_time,mtf_time,mtf_DnEntry);
            if(copied <= 0)
               return(0);
            UpEntry[x] = mtf_UpEntry[0];
            DnEntry[x] = mtf_DnEntry[0];
           }
         if(UseExit > 0)
           {
            copied = CopyBuffer(mtf_handle,4,mtf_time,mtf_time,mtf_UpExit);
            if(copied <= 0)
               return(0);
            copied = CopyBuffer(mtf_handle,5,mtf_time,mtf_time,mtf_DnExit);
            if(copied <= 0)
               return(0);
            UpExit[x] = mtf_UpExit[0];
            DnExit[x] = mtf_DnExit[0];
           }
        }
     }
   else
      for(shift=limit; shift<rates_total; shift++)
        {
         if(prevTime != Time[shift])
           {
            UpBand[2] = UpBand[1];
            UpBand[1] = UpBand[0];
            LoBand[2] = LoBand[1];
            LoBand[1] = LoBand[0];
            UpExitLevel[1] = UpExitLevel[0];
            LoExitLevel[1] = LoExitLevel[0];
            prevTime  = Time[shift];
           }
         up = 0;
         lo = 10000000000;
         for(int i=0; i<Length; i++)
           {
            up = MathMax(up,High[shift-i]);
            lo = MathMin(lo,Low [shift-i]);
           }
         UpBand[0] = up - (33 - Risk)*(up - lo)/100;
         LoBand[0] = lo + (33 - Risk)*(up - lo)/100;
         UpExitLevel[0] = up - (33 - ExitLevel)*(up - lo)/100;
         LoExitLevel[0] = lo + (33 - ExitLevel)*(up - lo)/100;
         //---
         UpSignal[shift]=0.0;
         DnSignal[shift]=0.0;
         UpEntry[shift]=0.0;
         DnEntry[shift]=0.0;
         UpExit[shift]=0.0;
         DnExit[shift]=0.0;
         //---
         trend[shift] = trend[shift-1];
         if(price[shift] > UpBand[0])
            trend[shift] = 1;
         if(price[shift] < LoBand[0])
            trend[shift] =-1;
         if(trend[shift] > 0)
           {
            if(trend[shift-1] < 0)
              {
               UpSignal[shift] = Low[shift] - 0.5*atr[shift];
               if(WarningMode > 0 && shift == rates_total - 1)
                  PlaySound(WarningSound);
              }
            else
               if(UseReEntry > 0 && price[shift] > UpBand[0] && price[shift-1] <= UpBand[1])
                 {
                  UpEntry[shift] = Low[shift] - 0.5*atr[shift];
                  if(WarningMode > 0 && shift == rates_total - 1)
                     PlaySound(WarningSound);
                 }
            if(UseExit > 0 && price[shift] < UpExitLevel[0] && price[shift-1] >= UpExitLevel[1])
               UpExit[shift] = High[shift] + 0.5*atr[shift];
           }
         else
            if(trend[shift] < 0)
              {
               if(trend[shift-1] > 0)
                 {
                  DnSignal[shift] = High[shift] + 0.5*atr[shift];
                  if(WarningMode > 0 && shift == rates_total - 1)
                     PlaySound(WarningSound);
                 }
               else
                  if(UseReEntry > 0 && price[shift] < LoBand[0] && price[shift-1] >= LoBand[1])
                    {
                     DnEntry[shift] = High[shift] + 0.5*atr[shift];
                     if(WarningMode > 0 && shift == rates_total - 1)
                        PlaySound(WarningSound);
                    }
               if(UseExit > 0 && price[shift] > LoExitLevel[0] && price[shift-1] <= LoExitLevel[1])
                  DnExit[shift] = Low[shift] - 0.5*atr[shift];
              }
         string message = "";
         if(shift == rates_total - 1 && AlertMode > 0)
           {
            if(trend[shift-1] > 0)
              {
               if(trend[shift-2] < 0 && !UpTrendAlert)
                 {
                  message = " " + Symbol() + timeframeToString(Period()) + ": PriceChannel Signal for BUY";
                  Alert(message);
                  UpTrendAlert = true;
                  DownTrendAlert = false;
                 }
               if(UseReEntry > 0 && trend[shift-2] > 0 && price[shift-1] > UpBand[1] && price[shift-2] <= UpBand[2] && Time[shift] != prevAlertTime)
                 {
                  message = " " + Symbol() + timeframeToString(Period()) + ": PriceChannel Re-Entry for BUY";
                  Alert(message);
                  prevAlertTime = Time[shift];
                 }
               if(UseExit > 0 && price[shift-1] < UpBand[1] && price[shift-2] >= UpBand[2] && Time[shift] != prevAlertTime)
                 {
                  message = " " + Symbol() + timeframeToString(Period()) + ": PriceChannel Possible Exit for BUY";
                  Alert(message);
                  prevAlertTime = Time[shift];
                 }
              }
            else
               if(trend[shift-1] < 0)
                 {
                  if(trend[shift-2] > 0 && !DownTrendAlert)
                    {
                     message = " " + Symbol() + timeframeToString(Period()) + ": PriceChannel Signal for SELL";
                     Alert(message);
                     DownTrendAlert=true;
                     UpTrendAlert=false;
                    }
                  if(UseReEntry>0 && trend[shift-2] < 0 && price[shift-1] < LoBand[1] && price[shift-2] >= LoBand[shift-2] && Time[shift] != prevAlertTime)
                    {
                     message = " " + Symbol() + timeframeToString(Period()) + ": PriceChannel Re-Entry for SELL";
                     Alert(message);
                     prevAlertTime = Time[shift];
                    }
                  if(UseExit > 0 && price[shift-1] > LoBand[1] && price[shift-2] <= LoBand[2] && Time[shift] != prevAlertTime)
                    {
                     message = " " + Symbol() + timeframeToString(Period()) + ": PriceChannel Possible Exit for SELL";
                     Alert(message);
                     prevAlertTime = Time[shift];
                    }
                 }
           }
        }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string priceToString(ENUM_APPLIED_PRICE app_price)
  {
   switch(app_price)
     {
      case PRICE_CLOSE   :
         return("Close");
      case PRICE_HIGH    :
         return("High");
      case PRICE_LOW     :
         return("Low");
      case PRICE_MEDIAN  :
         return("Median");
      case PRICE_OPEN    :
         return("Open");
      case PRICE_TYPICAL :
         return("Typical");
      case PRICE_WEIGHTED:
         return("Weighted");
      default            :
         return("");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframeToString(ENUM_TIMEFRAMES TF)
  {
   switch(TF)
     {
      case PERIOD_CURRENT  :
         return("Current");
      case PERIOD_M1       :
         return("M1");
      case PERIOD_M2       :
         return("M2");
      case PERIOD_M3       :
         return("M3");
      case PERIOD_M4       :
         return("M4");
      case PERIOD_M5       :
         return("M5");
      case PERIOD_M6       :
         return("M6");
      case PERIOD_M10      :
         return("M10");
      case PERIOD_M12      :
         return("M12");
      case PERIOD_M15      :
         return("M15");
      case PERIOD_M20      :
         return("M20");
      case PERIOD_M30      :
         return("M30");
      case PERIOD_H1       :
         return("H1");
      case PERIOD_H2       :
         return("H2");
      case PERIOD_H3       :
         return("H3");
      case PERIOD_H4       :
         return("H4");
      case PERIOD_H6       :
         return("H6");
      case PERIOD_H8       :
         return("H8");
      case PERIOD_H12      :
         return("H12");
      case PERIOD_D1       :
         return("D1");
      case PERIOD_W1       :
         return("W1");
      case PERIOD_MN1      :
         return("MN1");
      default              :
         return("Current");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime iTime2(string symbol,ENUM_TIMEFRAMES TF,int index)
  {
   if(index < 0)
      return(-1);
   static datetime timearray[];
   if(CopyTime(symbol,TF,index,1,timearray) > 0)
      return(timearray[0]);
   else
      return(-1);
  }
//+------------------------------------------------------------------+
