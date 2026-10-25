//+------------------------------------------------------------------+ 
//|                                                   ZigZag_INT.mq5 |
//|                                        Copyright © 2005, Integer |
//|                                                http://dmffx.com/ |
//+------------------------------------------------------------------+ 
//---- author of the indicator
#property copyright "Copyright © 2005, Integer"
//---- link to the website of the author
#property link      "http://dmffx.com/"
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
#property indicator_type1   DRAW_SECTION
//---- displaying the indicator label
#property indicator_label1  "ZigZag_INT"
//---- magenta color is used for the indicator line
#property indicator_color1 Magenta
//---- indicator line style is a dashed line
#property indicator_style1  STYLE_DASH
//---- indicator line width is equal to 1
#property indicator_width1  1
//+----------------------------------------------+ 
//|  Indicator input parameters                  |
//+----------------------------------------------+ 
extern int  HLPeriod = 12;  // Indicator period (equivalent to ExtDepth of ZigZag indicator)
extern int  MinHight = 1;   // Minimum vertical knee height (in points)
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ZZBuffer[];
//---- 
double dMinHight;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=HLPeriod;

//---- initialization of variables
   dMinHight=MinHight*_Point;

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ZZBuffer,INDICATOR_DATA);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ZZBuffer,true);
//---- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"ZigZag(",HLPeriod,", ",MinHight,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int limit,bar,lht0,llt0;
   static int cDir,pDir,lht1,llt1;

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      cDir=0;
      pDir=0;
      lht1=1;
      llt1=1;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//---- indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(prev_calculated!=rates_total)
         pDir=cDir;
      else cDir=pDir;

      int hb=ArrayMaximum(High,bar,HLPeriod);
      int lb=ArrayMinimum(Low, bar,HLPeriod);

      int lhb=rates_total-lht1;
      int llb=rates_total-llt1;
      lht0=lht1;
      llt0=llt1;
      ZZBuffer[bar]=0;

      if(llb>lhb) ZZBuffer[lhb]=High[lhb];
      else        ZZBuffer[llb]=Low[llb];

      if(hb==lb)
        {
         if(hb==bar)
           {
            switch(cDir)
              {
               case 1:
                  if(High[bar]>ZZBuffer[lhb])
                    {
                     ZZBuffer[lhb]=0;
                     ZZBuffer[bar]=High[bar];
                     lht0=rates_total-bar;
                    }
                  else if(Low[bar]<=ZZBuffer[lhb]-dMinHight)
                    {
                     ZZBuffer[bar]=Low[bar];
                     llt0=rates_total-bar;
                     cDir=-1;
                    }
                  break;

               case -1:
                  if(Low[bar]<ZZBuffer[llb])
                    {
                     ZZBuffer[llb]=0;
                     ZZBuffer[bar]=Low[bar];
                     llt0=rates_total-bar;
                    }
                  else if(High[bar]>=ZZBuffer[llb]+dMinHight)
                    {
                     ZZBuffer[bar]=High[bar];
                     lht0=rates_total-bar;
                     cDir=1;
                    }
                  break;
              }
           }
        }
      else if(lb>hb)
        {
         if(hb==bar)
           {
            if(cDir==1)
              {
               if(High[bar]>ZZBuffer[lhb])
                 {
                  ZZBuffer[lhb]=0;
                  ZZBuffer[bar]=High[bar];
                  lht0=rates_total-bar;
                 }
              }
            else if(High[bar]>=ZZBuffer[llb]+dMinHight)
              {
               ZZBuffer[bar]=High[bar];
               lht0=rates_total-bar;
               cDir=1;
              }
           }
        }
      else if(hb>lb)
        {
         if(lb==bar)
           {
            if(cDir==-1)
              {
               if(Low[bar]<ZZBuffer[llb])
                 {
                  ZZBuffer[llb]=0;
                  ZZBuffer[bar]=Low[bar];
                  llt0=rates_total-bar;
                 }
              }
            else if(Low[bar]<=ZZBuffer[lhb]-dMinHight)
              {
               ZZBuffer[bar]=Low[bar];
               llt0=rates_total-bar;
               cDir=-1;
              }
           }
        }

      if(bar>0)
        {
         llt1=llt0;
         lht1=lht0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
