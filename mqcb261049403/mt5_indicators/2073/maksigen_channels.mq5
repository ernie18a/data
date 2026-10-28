//+----------------------------------------------------------------------------+
//|                                                     MaksiGen_Channels.mq5  |
//|                                                Copyright © 2006, MaksiGen  |
//|                                                                            |
//+----------------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2006, MaksiGen"
#property link      ""
//--- Indicator version
#property version   "1.00"
//--- indicator description
#property description ""
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- four buffers are used for indicator calculation and drawing
#property indicator_buffers 4
//--- four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Upper line 2 drawing parameters             |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- blue color is used as the color of a bullish candlestick
#property indicator_color1  clrBlue
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- display of the indicator bullish label
#property indicator_label1  "Upper 2"
//+----------------------------------------------+
//|  Upper line 1 drawing parameters             |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- green color is used as the color of the indicator bearish line
#property indicator_color2  clrLime
//--- the line of the indicator 2 is a continuous curve
#property indicator_style2  STYLE_SOLID
//--- indicator 2 line width is equal to 5
#property indicator_width2  5
//--- display of the bearish indicator label
#property indicator_label2  "Upper 1"
//+----------------------------------------------+
//|  Lower line 1 drawing parameters             |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//--- red color is used as the color of the bullish line of the indicator 
#property indicator_color3  clrRed
//--- the line of the indicator 3 is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator 3 line width is equal to 5
#property indicator_width3  5
//--- display of the indicator bullish label
#property indicator_label3  "Lower 1"
//+----------------------------------------------+
//|  Lower line 2 drawing parameters             |
//+----------------------------------------------+
//--- drawing the indicator 4 as a line
#property indicator_type4   DRAW_LINE
//--- pink is used for the color of the bearish indicator line
#property indicator_color4  clrMagenta
//--- the line of the indicator 4 is a continuous curve
#property indicator_style4  STYLE_SOLID
//--- indicator 4 line width is equal to 2
#property indicator_width4  2
//--- display of the bearish indicator label
#property indicator_label4  "Lower 2"
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Hour //Type of constant
  {
   H00=0,    //00
   H01,      //01
   H02,      //02
   H03,      //03
   H04,      //04
   H05,      //05
   H06,      //06
   H07,      //07
   H08,      //08
   H09,      //09
   H10,      //10
   H11,      //11
   H12,      //12
   H13,      //13
   H14,      //14
   H15,      //15
   H16,      //16
   H17,      //17
   H18,      //18
   H19,      //19
   H20,      //20
   H21,      //21
   H22,      //22
   H23,      //23
  };
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Min //Type of constant
  {
   M00=0,    //00
   M01,      //01
   M02,      //02
   M03,      //03
   M04,      //04
   M05,      //05
   M06,      //06
   M07,      //07
   M08,      //08
   M09,      //09
   M10,      //10
   M11,      //11
   M12,      //12
   M13,      //13
   M14,      //14
   M15,      //15
   M16,      //16
   M17,      //17
   M18,      //18
   M19,      //19
   M20,      //20
   M21,      //21
   M22,      //22
   M23,      //23
   M24,      //24
   M25,      //25
   M26,      //26
   M27,      //27
   M28,      //28
   M29,      //29
   M30,      //30
   M31,      //31
   M32,      //32
   M33,      //33
   M34,      //34
   M35,      //35
   M36,      //36
   M37,      //37
   M38,      //38
   M39,      //39
   M40,      //40
   M41,      //41
   M42,      //42
   M43,      //43
   M44,      //44
   M45,      //45
   M46,      //46
   M47,      //47
   M48,      //48
   M49,      //49
   M50,      //50
   M51,      //51
   M52,      //52
   M53,      //53
   M54,      //54
   M55,      //55
   M56,      //56
   M57,      //57
   M58,      //58
   M59       //59
  };
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Hour   StartHour1=H00;         // Session start hour for the channel width
input Min    StartMinute1=M00;       // Minute start hour for the channel width
input Hour   EndHour1=H08;           // Session end hour for the channel width
input Min    EndMinute1=M15;         // Session end minute for the channel width
//---
input Hour   StartHour2=H08;         // Session 1 start hour
input Min    StartMinute2=M15;       // Session 1 start minute
input Hour   EndHour2=H12;           // Session 1 end hour
input Min    EndMinute2=M30;         // Session 1 end minute
//---
input Hour   StartHour3=H14;         // Session 2 start hour
input Min    StartMinute3=M00;       // Session 2 start minute
input Hour   EndHour3=H17;           // Session 2 end hour
input Min    EndMinute3=M30;         // Session 2 end minute
//--- 
input uint   Dispersion=100;         // Spread of the second channel width in points
input int    Shift=0;                // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Up2Buffer[];
double Up1Buffer[];
double Dn1Buffer[];
double Dn2Buffer[];
double dDispersion;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(PeriodSeconds(PERIOD_D1)/PeriodSeconds()+1);
   dDispersion=Dispersion*_Point;
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,Up2Buffer,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Up2Buffer,true);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,Up1Buffer,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Up1Buffer,true);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(2,Dn1Buffer,INDICATOR_DATA);
//--- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Dn1Buffer,true);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(3,Dn2Buffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 4 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Dn2Buffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"MaksiGen_Channels");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Checking the chart period
   if(Period()>PERIOD_H1)
     {
      Comment("Indicator MaksiGen_Channels requires timeframe below H2!");
      return(RESET);
     }
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int bar,limit;
   static double HH,LL;
   static int day;
///--- calculating the starting nummber limit for bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-3; // starting index for calculation of all bars
      day=-1;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
//--- the main loop of indicator 1 calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Up1Buffer[bar]=0.0;
      Dn1Buffer[bar]=0.0;
      Up2Buffer[bar]=0.0;
      Dn2Buffer[bar]=0.0;

      MqlDateTime tmb;
      TimeToStruct(time[bar],tmb);

      if(((tmb.hour==EndHour1 && tmb.min>EndMinute1) || tmb.hour>EndHour1) && tmb.day!=day)
        {
         day=tmb.day;
         int start1=0;
         int end1=0;

         for(int index=bar+1; index<rates_total-1 && !IsStopped(); index++)
           {
            MqlDateTime tmi,tmr,tmf;
            TimeToStruct(time[index],tmi);
            TimeToStruct(time[index+1],tmr);
            TimeToStruct(time[index-1],tmf);

            if((tmi.hour==StartHour1 && tmr.hour!=StartHour1)
               || (tmi.hour==StartHour1 && tmr.hour==StartHour1 && tmi.min>=StartMinute1 && tmr.min<StartMinute1))
              {
               start1=index;
               break;
              }

            if((tmi.hour==EndHour1 && tmf.hour!=EndHour1)
               || (tmi.hour==EndHour1 && tmf.hour==EndHour1 && tmi.min<=EndMinute1 && tmf.min>EndMinute1))
              {
               end1=index;
              }
           }

         if(!start1 && !end1)continue;

         int count=start1-end1;
         HH=high[ArrayMaximum(high,end1,count)];
         LL=low[ArrayMinimum(low,end1,count)];
        }

      if(((tmb.hour==StartHour2 && tmb.min>=StartMinute2) || tmb.hour>StartHour2)
         && ((tmb.hour==EndHour2 && tmb.min<=StartMinute2) || tmb.hour<EndHour2))
        {
         Up1Buffer[bar]=HH;
         Dn1Buffer[bar]=LL;
         Up2Buffer[bar]=HH+dDispersion;
         Dn2Buffer[bar]=LL-dDispersion;
        }
      if(((tmb.hour==StartHour3 && tmb.min>=StartMinute3) || tmb.hour>StartHour3)
         && ((tmb.hour==EndHour3 && tmb.min<=StartMinute3) || tmb.hour<EndHour3))
        {
         Up1Buffer[bar]=HH;
         Dn1Buffer[bar]=LL;
         Up2Buffer[bar]=HH+dDispersion;
         Dn2Buffer[bar]=LL-dDispersion;
        }
     }
//---         
   return(rates_total);
  }
//+------------------------------------------------------------------+
