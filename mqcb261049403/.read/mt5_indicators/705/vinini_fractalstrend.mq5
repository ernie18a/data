//+------------------------------------------------------------------+
//|                                         VininI_FractalsTrend.mq5 |
//|                     Copyright © 2011, Victor Niclolaev aka Vinin |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Victor Niclolaev aka Vinin"
//---- link to the website of the author
#property link      "vinin@mail.ru"
#property description "VininI_FractalsTrend"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- 2 buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- 1 plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0                               // the constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "VininI_FractalsTrend" // the constant for the indicator name
//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ZIGZAG
//---- magenta color is used for the indicator
#property indicator_color1  Magenta
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ZIGZAG
//---- magenta color is used for the indicator
#property indicator_color2  Magenta
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2 INDICATOR_NAME
//+----------------------------------------------+
//---- declaration of dynamic arrays that further в 
//---- will be used as indicator buffers
double HighBuffer[];
double LowBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of variables for the indicators handles
int FRA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables 
   min_rates_total=6;
//---- getting handle of the ATR indicator
   FRA_Handle=iFractals(NULL,0);
   if(FRA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");

//---- set HighBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,HighBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(HighBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set LowBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,LowBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(LowBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
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
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int to_copy,limit,Fractals;
   double UpFractal[],DnFractal[];
   bool bFractalsUpper,bFractalsLower;
   static int dir,PrevLowPos,PrevHighPos;
   int dir_=0,PrevLowPos_=0,PrevHighPos_=0;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total;                   // calculated number of all copied data
      limit=rates_total-min_rates_total-1;   // starting index for calculation of all bars
      PrevLowPos_=rates_total;
      PrevHighPos_=rates_total;
      dir_=0;
     }
   else
     {
      to_copy=rates_total-prev_calculated+5; // calculated number of new copied data only
      limit=rates_total-prev_calculated+4;   // starting index for calculation of new bars
     }

//---- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(CopyBuffer(FRA_Handle,0,0,to_copy,UpFractal)<=0) return(RESET);
   if(CopyBuffer(FRA_Handle,1,0,to_copy,DnFractal)<=0) return(RESET);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(UpFractal,true);
   ArraySetAsSeries(DnFractal,true);

   dir=dir_;
   PrevLowPos=PrevLowPos_;
   PrevHighPos=PrevHighPos_;

//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(bar==4)
        {
         dir_=dir;
         PrevLowPos_=PrevLowPos;
         PrevHighPos_=PrevHighPos;
        }

      if(UpFractal[bar]!=EMPTY_VALUE&&UpFractal[bar]) bFractalsUpper=true; else bFractalsUpper=false;
      if(DnFractal[bar]!=EMPTY_VALUE&&DnFractal[bar]) bFractalsLower=true; else bFractalsLower=false;
      Fractals=bFractalsUpper*2+bFractalsLower;

      HighBuffer[bar]=0;
      LowBuffer[bar]=0;

      switch(Fractals)
        {
         case 3:
            if(!dir)
              {
               HighBuffer[bar]=high[bar];
               LowBuffer[bar]=low[bar];
               PrevHighPos=bar;
               PrevLowPos=bar;
              }

            if(dir==+1)
              {
               LowBuffer[bar]=low[bar];
               PrevLowPos=bar;

               if(high[bar]>high[PrevHighPos])
                 {

                  HighBuffer[bar]=high[bar];
                  HighBuffer[PrevHighPos]=0;
                  PrevHighPos=bar;
                 }
              }

            if(dir==-1)
              {
               HighBuffer[bar]=high[bar];
               PrevHighPos=bar;

               if(low[bar]<low[PrevLowPos])
                 {
                  LowBuffer[bar]=low[bar];
                  LowBuffer[PrevLowPos]=0;
                  PrevLowPos=bar;
                 }
              }

            dir*=-1;
            break;

         case 2:
            if(dir==+1)
              {
               if(high[bar]>high[PrevHighPos])
                 {
                  HighBuffer[PrevHighPos]=0;
                  HighBuffer[bar]=high[bar];
                  PrevHighPos=bar;
                 }
              }
            else
              {
               HighBuffer[bar]=high[bar];
               PrevHighPos=bar;
               dir=+1;
              }
            break;

         case 1:
            if(dir==-1)
              {
               if(low[bar]<low[PrevLowPos])
                 {
                  LowBuffer[PrevLowPos]=0;
                  LowBuffer[bar]=low[bar];
                  PrevLowPos=bar;
                 }
              }
            else
              {
               LowBuffer[bar]=low[bar];
               PrevLowPos=bar;
               dir=-1;
              }
            break;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
