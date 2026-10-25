//+----------------------------------------------------------------------------------+
//|                                                                 Din_fibo_Nex.mq5 | 
//|             Copyright © 2006, unknown author, get from kaizer, conversed by Rosh | 
//|link to kaizer: http://forum.alpari-idc.ru/profile.php?mode=viewprofile&u=4196161 | 
//+----------------------------------------------------------------------------------+
#property copyright "Copyright © 2006, unknown author, get from kaizer, conversed by Rosh"
#property link "http://forum.alpari-idc.ru/profile.php?mode=viewprofile&u=4196161"
#property description "Trailing stop line indicator"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- number of indicator buffers 3
#property indicator_buffers 3
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // A constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- the color of the indicator
#property indicator_color1  clrTeal
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "Din_fibo_Nex MaH"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the color of the indicator
#property indicator_color2  clrMaroon
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  "Din_fibo_Nex MaL"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint      Fibo_Channel_Period=3;
input double    Ratio=0.786;
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],tvBuffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Check - range separator or not                                   |
//+------------------------------------------------------------------+
bool isDelimeter(int TimeFrame,int Rates_total,const datetime &Time[],int shift)
  {
//---
   bool result=false;
   MqlDateTime tm;
   TimeToStruct(Time[shift],tm);
//--- 
   switch(TimeFrame)
     {
      case PERIOD_M1:result=(tm.min==0); break;
      case PERIOD_M2:result=(tm.min==0); break;
      case PERIOD_M3:result=(tm.min==0); break;
      case PERIOD_M4:result=(tm.min==0); break;
      case PERIOD_M5:result=(tm.min==0); break;
      case PERIOD_M6:result=(tm.min==0); break;
      case PERIOD_M10:result=(tm.min==0); break;
      case PERIOD_M12:result=(tm.min==0); break;
      case PERIOD_M15:result=(tm.min==0); break;
      case PERIOD_M20:result=(tm.min==0); break;
      case PERIOD_M30:result=(tm.min==0) && (MathMod(tm.hour,4.0)==0); break;
      case PERIOD_H1:result=(tm.min==0) && (MathMod(tm.hour,4.0)==0); break;
      case PERIOD_H2:result=(tm.min==0) && (MathMod(tm.hour,4.0)==0); break;
      case PERIOD_H3:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H4:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H6:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H8:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H12:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_D1:result=(tm.day_of_week==MONDAY) && (tm.hour==0); break;
      case PERIOD_W1:
        {
         MqlDateTime tm1;
         TimeToStruct(Time[MathMin(Rates_total-1,shift+1)],tm1);
         result=(tm.day==1) || (tm.day==2 && tm1.day!=1) || (tm.day==3 && tm1.day!=2); break;
        }
      default: Print("Invalid timeframe!!!");
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Set MaH and MaL at the range border                              |
//+------------------------------------------------------------------+
void SetHnL(int Rates_total,const double &Low[],const double &High[],const double &Close[],int shift)
  {
//--- 
   int i=shift+1;
   int counterPeriod=0;
   int first=0;
   while(counterPeriod<int(Fibo_Channel_Period))
     {
      while(i<Rates_total && !tvBuffer[i]) i++;
      if(!first) first=i;
      counterPeriod++;
      i++;
     }
   i--;
//---  
   int hh=ArrayMaximum(High,shift+1,i-shift);
   int ll=ArrayMinimum(Low,shift+1,i-shift);
//---   
   double tv=NormalizeDouble((High[hh]+Low[ll]+Close[shift+1])/3.0,_Digits);
   double diff=NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,_Digits);
   double MaH=tv+diff;
   double MaL=tv-diff;
   tvBuffer[shift]=tv;
   ExtLineBuffer1[shift]=MaH;
   ExtLineBuffer2[shift]=MaL;
   SetMovingHnL(first,shift);
//---
   return;
  }
//+------------------------------------------------------------------+
//| Set MaH and MaL inside the range                                 |
//+------------------------------------------------------------------+
void SetMovingHnL(int DelimeterBar,int CurBar)
  {
   int m_cnt;
   double deltaH,deltaL;
//--- 
   deltaH=(ExtLineBuffer1[DelimeterBar]-ExtLineBuffer1[CurBar])/(DelimeterBar-CurBar);
   deltaL=(ExtLineBuffer2[DelimeterBar]-ExtLineBuffer2[CurBar])/(DelimeterBar-CurBar);
//---  
   for(m_cnt=DelimeterBar-1; m_cnt>CurBar; m_cnt--)
     {
      ExtLineBuffer1[m_cnt]=ExtLineBuffer1[m_cnt+1]-deltaH;
      ExtLineBuffer2[m_cnt]=ExtLineBuffer2[m_cnt+1]-deltaL;
     }
//---     
   for(m_cnt=DelimeterBar-1; m_cnt>CurBar; m_cnt--)
     {
      ExtLineBuffer1[m_cnt]=NormalizeDouble(ExtLineBuffer1[m_cnt],_Digits);
      ExtLineBuffer2[m_cnt]=NormalizeDouble(ExtLineBuffer2[m_cnt],_Digits);
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Set MaH and MaL on the right edge                                |
//+------------------------------------------------------------------+
void SetValuesNullBar(int Rates_total,const double &Low[],const double &High[],const double &Close[],int shift)
  {
//--- 
   int i=shift;
   while(!tvBuffer[i]) i++;
   for(int j=i-1; j>shift; j--)
     {
      ExtLineBuffer1[j]=0.0;
      ExtLineBuffer2[j]=0.0;
     }
//--- 
   int first=0;
   i=shift;
   int counterPeriod=0;
   while(counterPeriod<int(Fibo_Channel_Period))
     {
      while(i<Rates_total && !tvBuffer[i]) i++;
      if(!first) first=i;
      counterPeriod++;
      i++;
     }
   i--;
//--- 
   int hh=ArrayMaximum(High,shift,i-shift);
   int ll=ArrayMinimum(Low,shift,i-shift);
//--- 
   double tv=NormalizeDouble((High[hh]+Low[ll]+Close[shift])/3.0,_Digits);
   double diff=NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,_Digits);
   double MaH=tv+diff;
   double MaL=tv-diff;
   ExtLineBuffer1[shift]=MaH;
   ExtLineBuffer2[shift]=MaL;
   SetMovingHnL(first,shift);
  }
//+------------------------------------------------------------------+   
//| SL_ATR indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- check the validity of the timeframe 
   if(Period()==PERIOD_MN1)
     {
      Print("Invalid timeframe!!!");
      return(INIT_FAILED);
     }

//--- initialization of variables of the start of data calculation
   min_rates_total=int(20*Fibo_Channel_Period)+1;

//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,tvBuffer,INDICATOR_CALCULATIONS);

//---- set the position, from which the indicator drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- Indexing buffer elements as timeseries   
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(tvBuffer,true);

//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Din_fibo_Nex(",Fibo_Channel_Period,",",DoubleToString(Ratio,4),")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| SL_ATR iteration function                                        | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);

//--- declarations of local variables 
   int limit,bar;

//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      //--- find the first and second separator and set limit
      bar=rates_total-1;
      while(!isDelimeter(Period(),rates_total,time,bar)) bar--;
      int first=bar;
      bar--;
      int counterPeriod=0;
      while(counterPeriod<int(Fibo_Channel_Period))
        {
         while(!isDelimeter(Period(),rates_total,time,bar)) bar--;
         bar--;
         counterPeriod++;
        }
      bar++;
      int hh=ArrayMaximum(high,bar+1,first-bar);
      int ll=ArrayMinimum(low,bar+1,first-bar);

      double tv=NormalizeDouble((high[hh]+low[ll]+close[bar+1])/3.0,_Digits);
      double MaH=tv+NormalizeDouble((high[hh]-low[ll])/2.0*Ratio,_Digits);
      double MaL=tv-NormalizeDouble((high[hh]-low[ll])/2.0*Ratio,_Digits);
      tvBuffer[bar]=tv;
      ExtLineBuffer1[bar]=MaH;
      ExtLineBuffer2[bar]=MaL;
      limit=bar-1; // starting number for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars

//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      tvBuffer[bar]=0.0;
      if(isDelimeter(Period(),rates_total,time,bar)) SetHnL(rates_total,low,high,close,bar);
      if(!bar) SetValuesNullBar(rates_total,low,high,close,bar);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
