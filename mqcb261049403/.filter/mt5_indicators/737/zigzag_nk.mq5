/*
//----- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+ 
//Version: Final, November 01, 2008                                  |
Editing:   Nikolay Kositsin  farria@mail.redcom.ru                   |
//----- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+ 
This  variant of the  ZigZag indicator is recalculated  at  each  tick 
only  at the bars that were not calculated yet and, therefore, it does
not  overload  CPU  at  all  which  is  different  from  the  standard
indicator.  Besides, in this indicator drawing of a line  is  executed
exactly in the ZIGZAG style and, therefore,  the  indicator  correctly 
and  simultaneously  displays two of its extreme points (High and Low)
at the same bar!
Nikolay Kositsin
//----- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
Depth is a minimum number of bars without the second maximum (minimum)
which is Deviation pips less (more) than the previous one, i.e. ZigZag
always can diverge but it may converge (or dislocate entirely) for the
value more than  Deviation  only  after  the  Depth  number  of  bars.
Backstep is a minimum number of bars between maximums (minimums).
//----- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
Zigzag  indicator  is  a  number of trendlines that unite considerable
tops  and  bottoms  on  a  price  chart.  The parameter concerning the
minimum  prices  changes determines the per cent value where the price
must move to generate a  new  "Zig"  or  "Zag"  line.  This  indicator
filters  the  changes  on an analyzed chart that are less than the set
value. Therefore, Zigzag reflects only considerable amedments.  Zigzag
is used mainly for the simplified visualization of charts, as it shows
only the most important changes and reverses.  Also, it can be used to
reveal  the Elliott Waves and different chart figures. It is necessary
to  remember  that  the last indicator segment can change depending on
the changes of the analyzed data. It is one of the few indicators that
can  change  their  previous  value, in case of an asset price change.
Such  an  ability to correct its values according to the further price
changings  makes Zigzag an excellent tool for the already formed price
changes.  Therefore,  there  is  no point in creating a trading system
based  on Zigzag as it is most suitable for the analysis of historical
data not forecasting.
 Copyright © 2005, MetaQuotes Software Corp.
 */
//+------------------------------------------------------------------+ 
//|                                                    ZigZag_NK.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+ 
//---- author of the indicator
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- link to the website of the author
#property link      "https://www.metaquotes.net/"
//---- indicator version
#property version   "1.00"
#property description "ZigZag"
//+----------------------------------------------+ 
//|  Indicator drawing parameters                |
//+----------------------------------------------+ 
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- 2 buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only 1 plot is used
#property indicator_plots   1
//---- ZIGZAG is used for the indicator
#property indicator_type1   DRAW_ZIGZAG
//---- displaying the indicator label
#property indicator_label1  "ZigZag_NK"
//---- use blue violet color for the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a long dashed line
#property indicator_style1  STYLE_DASH
//---- indicator line width is equal to 1
#property indicator_width1  1
//+----------------------------------------------+ 
//|  Indicator input parameters                  |
//+----------------------------------------------+ 
input int ExtDepth=12;
input int ExtDeviation=5;
input int ExtBackstep =3;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double HighestBuffer[];
double LowestBuffer[];
//---- declaration of memory variables for recalculation of the indiator only at the previously not calculated bars
int LASTlowpos,LASThighpos;
double LASTlow0,LASTlow1,LASThigh0,LASThigh1;
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars=ExtDepth+ExtBackstep;

//---- set LowestBuffer[] and HighestBuffer[] dynamic arrays into indicator buffers
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- create labels to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag Lowest");
   PlotIndexSetString(1,PLOT_LABEL,"ZigZag Highest");
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
//---- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"ZigZag (ExtDepth=",
                     ExtDepth,"ExtDeviation = ",ExtDeviation,"ExtBackstep = ",ExtBackstep,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- declarations of local variables 
   int limit,bar,back,lasthighpos,lastlowpos;
   double curlow,curhigh,lasthigh0=0.0,lastlow0=0.0,lasthigh1,lastlow1,val,res;

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-StartBars; // starting index for calculation of all bars

      lastlow1=-1;
      lasthigh1=-1;
      lastlowpos=-1;
      lasthighpos=-1;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars

      //---- restore values of the variables
      lastlow0=LASTlow0;
      lasthigh0=LASThigh0;

      lastlow1=LASTlow1;
      lasthigh1=LASThigh1;

      lastlowpos=LASTlowpos+limit;
      lasthighpos=LASThighpos+limit;
     }

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- first big indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
        {
         LASTlow0=lastlow0;
         LASThigh0=lasthigh0;
        }

      //--- low
      val=low[ArrayMinimum(low,bar,ExtDepth)];
      if(val==lastlow0) val=0.0;
      else
        {
         lastlow0=val;
         if((low[bar]-val)>(ExtDeviation*_Point))val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowestBuffer[bar+back];
               if((res!=0) && (res>val))LowestBuffer[bar+back]=0.0;
              }
           }
        }
      LowestBuffer[bar]=val;

      //--- high
      val=high[ArrayMaximum(high,bar,ExtDepth)];
      if(val==lasthigh0) val=0.0;
      else
        {
         lasthigh0=val;
         if((val-high[bar])>(ExtDeviation*_Point))val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighestBuffer[bar+back];
               if((res!=0) && (res<val))HighestBuffer[bar+back]=0.0;
              }
           }
        }
      HighestBuffer[bar]=val;

     }

//---- the second big indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
        {
         LASTlow1=lastlow1;
         LASThigh1=lasthigh1;

         LASTlowpos=lastlowpos;
         LASThighpos=lasthighpos;
        }

      curlow=LowestBuffer[bar];
      curhigh=HighestBuffer[bar];
      //---
      if((curlow==0) && (curhigh==0))continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh1>0)
           {
            if(lasthigh1<curhigh)HighestBuffer[lasthighpos]=0;
            else HighestBuffer[bar]=0;
           }
         //---
         if(lasthigh1<curhigh || lasthigh1<0)
           {
            lasthigh1=curhigh;
            lasthighpos=bar;
           }
         lastlow1=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow1>0)
           {
            if(lastlow1>curlow) LowestBuffer[lastlowpos]=0;
            else LowestBuffer[bar]=0;
           }
         //---
         if((curlow<lastlow1) || (lastlow1<0))
           {
            lastlow1=curlow;
            lastlowpos=bar;
           }
         lasthigh1=-1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
