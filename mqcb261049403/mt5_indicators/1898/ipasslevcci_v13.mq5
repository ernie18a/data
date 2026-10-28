//+------------------------------------------------------------------+
//|                                           i-PassLevCCI_v.1.2.mq5 |
//|                              Идея Gentor, реализация в МТ4 KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
#property copyright "Gentor, KimIV, extesy"
#property link      "http://www.kimiv.ru"
//---- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//----three buffers are used for calculation of drawing of the indicator
#property indicator_buffers 3
//---- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- pink is used for the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//--- displaying the indicator label
#property indicator_label1  "i-PassLevCCI_v.1.3 Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color2  clrLime
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//--- displaying the indicator label
#property indicator_label2 "i-PassLevCCI_v.1.3 Buy"
//+----------------------------------------------+
//|  Indicator stop drawing parameters           |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- blue color is used for the indicator line
#property indicator_color3  clrBlue
//---- indicator 3 line width is equal to 4
#property indicator_width3  4
//--- displaying the indicator label
#property indicator_label3 "i-PassLevCCI_v.1.3 Stop"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint CCI_Period=14;                          // CCI period
input ENUM_APPLIED_PRICE   CCI_Price=PRICE_MEDIAN; // CCI price
input uint BarsForCheck=9;                         // Number of bars to check
input int MaxLevel    =+100;                       // Maximum value of the level
input int MinLevel    =-100;                       // Minimum value of the level
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double SellBuffer[],BuyBuffer[],ExitBuffer[];
//---- Declaration of integer variables for the indicator handles
int CCI_Handle,ATR_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   int ATR_Period=15;
   min_rates_total=int(CCI_Period+BarsForCheck);
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));

//---- getting handle of the iCCI indicator
   CCI_Handle=iCCI(NULL,0,CCI_Period,CCI_Price);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iCCI indicator");
      return(INIT_FAILED);
     }

//---- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(2,ExitBuffer,INDICATOR_DATA);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,118);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExitBuffer,true);

//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="i-PassLevCCI_v.1.3";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- initialization end
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
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//--- declarations of local variables 
   int to_copy,limit,bar;
   double CCI[],ATR[];
   double cci0,cci1,cci2,cci3;
   bool fsb,fss,sig;
   static bool Fsb,Fss;

//--- calculations of the necessary amount of data to be copied and
//---- the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
      Fsb=false;
      Fss=false;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }
//--- estimated number o copied bars    
   to_copy=limit+1;

//---- copy the newly appeared data into the CCI[] and ATR[] arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy+=int(BarsForCheck);
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- Restore variables  
      fsb=Fsb;
      fss=Fss;
      sig=false;

      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      ExitBuffer[bar]=0.0;
      cci0=CCI[bar];
      //--- Buy signal
      if(cci0>MaxLevel)
        {
         for(int sh=0; sh<int(BarsForCheck); sh++)
           {
            if(fsb) break;
            cci1=CCI[bar+sh];
            cci2=CCI[bar+sh+1];

            if(cci1>cci2)
              {
               if(cci2<MinLevel)
                 {
                  BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
                  fsb=true;
                  fss=false;
                  sig=true;
                  break;
                 }
              }
            else break;
           }
        }

      //--- Sell signal
      if(cci0<MinLevel)
        {
         for(int sh=0; sh<int(BarsForCheck); sh++)
           {
            if(fss) break;
            cci1=CCI[bar+sh];
            cci2=CCI[bar+sh+1];

            if(cci1<cci2)
              {
               if(cci2>MaxLevel)
                 {
                  SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
                  fss=true;
                  fsb=false;
                  sig=true;
                  break;
                 }
              }
            else break;
           }
        }

      //--- Signals to exit
      cci3=CCI[bar+1];
      if(cci0*cci3<0 && (fsb || fss) && !sig)
        {
         ExitBuffer[bar]=close[bar];
         fsb=false;
         fss=false;
        }

      //--- Save variables
      if(bar)
        {
         Fsb=fsb;
         Fss=fss;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
