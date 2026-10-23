//+------------------------------------------------------------------+
//|                                              StochasticStack.mq5 | 
//|                                  Copyright © 2010, Ivan Kornilov |
//|                                         E-mail: excelf@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ivan Kornilov"
#property link      "E-mail: excelf@gmail.com"
#property description "StochasticStack"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator cloud drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the bearish indicator line
#property indicator_color1  clrMagenta,clrDodgerBlue
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bearish label of the indicator
#property indicator_label1  "StochasticStack"
//+----------------------------------------------+
//|  Indicator line drawing parameters           |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- DarkSlateBlue color is used as the color of the bullish line of the indicator
#property indicator_color2  clrDarkSlateBlue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bullish label of the indicator
#property indicator_label2  "StochasticStack Line"

//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  +25
#property indicator_level2   0
#property indicator_level3  -25
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator window size limitation             |
//+----------------------------------------------+
#property indicator_minimum -50
#property indicator_maximum +50
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input double nextPeriod=1.2;
input uint kPeriod1=34;
input uint level=10;
input ENUM_MA_METHOD ma_method=MODE_EMA;   // smoothing type
input ENUM_STO_PRICE price_field=STO_LOWHIGH; // stochastic calculation method
input int Shift=0; //horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double Line1Buffer[];
double Line2Buffer[];
double Line3Buffer[];
//---- declaration of integer variables for the indicators handles
int Sto_Handle[8];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   int dPeriod1 = 0;
   int slowing1 = 0;

   int kPeriod2 = 0;
   int dPeriod2 = 0;
   int slowing2 = 0;

   int kPeriod3 = 0;
   int dPeriod3 = 0;
   int slowing3 = 0;

   int kPeriod4 = 0;
   int dPeriod4 = 0;
   int slowing4 = 0;

   int kPeriod5 = 0;
   int dPeriod5 = 0;
   int slowing5 = 0;

   int kPeriod6 = 0;
   int dPeriod6 = 0;
   int slowing6 = 0;

   int kPeriod7 = 0;
   int dPeriod7 = 0;
   int slowing7 = 0;

   int kPeriod8 = 0;
   int dPeriod8 = 0;
   int slowing8 = 0;
//----
   if(nextPeriod)
     {
      kPeriod2 = int(kPeriod1 * nextPeriod);
      kPeriod3 = int(kPeriod2 * nextPeriod);
      kPeriod4 = int(kPeriod3 * nextPeriod);
      kPeriod5 = int(kPeriod4 * nextPeriod);
      kPeriod6 = int(kPeriod5 * nextPeriod);
      kPeriod7 = int(kPeriod6 * nextPeriod);
      kPeriod8 = int(kPeriod7 * nextPeriod);
     }

   if(!dPeriod1 && !slowing1)
     {
      dPeriod1 = int(kPeriod1 / 2);
      slowing1 = dPeriod1 / 2;
     }

   if(!dPeriod2 && !slowing2)
     {
      dPeriod2 = kPeriod2 / 2;
      slowing2 = dPeriod2 / 2;
     }

   if(!dPeriod3 && !slowing3)
     {
      dPeriod3 = kPeriod3 / 2;
      slowing3 = dPeriod3 / 2;
     }

   if(!dPeriod4 && !slowing4)
     {
      dPeriod4 = kPeriod4 / 2;
      slowing4 = dPeriod4 / 2;
     }

   if(!dPeriod5 && !slowing5)
     {
      dPeriod5 = kPeriod5 / 2;
      slowing5 = dPeriod5 / 2;
     }

   if(!dPeriod6 && !slowing6)
     {
      dPeriod6 = kPeriod6 / 2;
      slowing6 = dPeriod6 / 2;
     }

   if(!dPeriod7 && !slowing7)
     {
      dPeriod7 = kPeriod7 / 2;
      slowing7 = dPeriod7 / 2;
     }

   if(!dPeriod8 && !slowing8)
     {
      dPeriod8 = kPeriod8 / 2;
      slowing8 = dPeriod8 / 2;
     }
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(kPeriod8+dPeriod8+slowing8);

//---- getting handle of the iStochastic indicator
   Sto_Handle[0]=iStochastic(NULL,0,kPeriod1,dPeriod1,slowing1,ma_method,price_field);
   if(Sto_Handle[0]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 1 indicator");
   Sto_Handle[1]=iStochastic(NULL,0,kPeriod2,dPeriod2,slowing2,ma_method,price_field);
   if(Sto_Handle[1]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 2 indicator");
   Sto_Handle[2]=iStochastic(NULL,0,kPeriod3,dPeriod3,slowing3,ma_method,price_field);
   if(Sto_Handle[2]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 3 indicator");
   Sto_Handle[3]=iStochastic(NULL,0,kPeriod4,dPeriod4,slowing4,ma_method,price_field);
   if(Sto_Handle[3]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 4 indicator");
   Sto_Handle[4]=iStochastic(NULL,0,kPeriod5,dPeriod5,slowing5,ma_method,price_field);
   if(Sto_Handle[4]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 5 indicator");
   Sto_Handle[5]=iStochastic(NULL,0,kPeriod6,dPeriod6,slowing6,ma_method,price_field);
   if(Sto_Handle[5]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 6 indicator");
   Sto_Handle[6]=iStochastic(NULL,0,kPeriod7,dPeriod7,slowing7,ma_method,price_field);
   if(Sto_Handle[6]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 7 indicator");
   Sto_Handle[7]=iStochastic(NULL,0,kPeriod8,dPeriod8,slowing8,ma_method,price_field);
   if(Sto_Handle[7]==INVALID_HANDLE) Print(" Failed to get handle of the iStochastic 8 indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Line2Buffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(Line2Buffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Line3Buffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(Line3Buffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,Line1Buffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(Line1Buffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"StochasticStack(",DoubleToString(nextPeriod,2),", ",kPeriod1,", ",level,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);
   for(int numb=0; numb<8; numb++) if(BarsCalculated(Sto_Handle[numb])<rates_total) return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar;
   double sum,iSto1[],iSto2[],iSto3[],iSto4[],iSto5[],iSto6[],iSto7[],iSto8[];

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(iSto1,true);
   ArraySetAsSeries(iSto2,true);
   ArraySetAsSeries(iSto3,true);
   ArraySetAsSeries(iSto4,true);
   ArraySetAsSeries(iSto5,true);
   ArraySetAsSeries(iSto6,true);
   ArraySetAsSeries(iSto7,true);
   ArraySetAsSeries(iSto8,true);

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-1; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+1;

//--- copy newly appeared data in the array
   if(CopyBuffer(Sto_Handle[0],MAIN_LINE,0,to_copy,iSto1)<=0) return(RESET);
   if(CopyBuffer(Sto_Handle[1],MAIN_LINE,0,to_copy,iSto2)<=0) return(RESET);
   if(CopyBuffer(Sto_Handle[2],MAIN_LINE,0,to_copy,iSto3)<=0) return(RESET);
   if(CopyBuffer(Sto_Handle[3],MAIN_LINE,0,to_copy,iSto4)<=0) return(RESET);
   if(CopyBuffer(Sto_Handle[4],MAIN_LINE,0,to_copy,iSto5)<=0) return(RESET);
   if(CopyBuffer(Sto_Handle[5],MAIN_LINE,0,to_copy,iSto6)<=0) return(RESET);
   if(CopyBuffer(Sto_Handle[6],MAIN_LINE,0,to_copy,iSto7)<=0) return(RESET);
   if(CopyBuffer(Sto_Handle[7],MAIN_LINE,0,to_copy,iSto8)<=0) return(RESET);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      sum=0;
      sum += (iSto1[bar] - iSto2[bar]);
      sum += (iSto3[bar] - iSto4[bar]);
      sum += (iSto5[bar] - iSto6[bar]);
      sum += (iSto7[bar] - iSto8[bar]);

      Line1Buffer[bar]=sum;
      
      Line3Buffer[bar]=sum;
      Line2Buffer[bar]=0.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
