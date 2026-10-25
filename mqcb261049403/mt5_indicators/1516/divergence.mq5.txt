//+------------------------------------------------------------------+
//|                                                   Divergence.mq5 |
//|                                    Copyright © 2005, Pavel Kulko |
//|                                                  polk@alba.dp.ua |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Pavel Kulko"
#property link      "polk@alba.dp.ua"
#property description "Divergence"
//---- indicator version number
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- ten buffers are used for calculation and drawing the indicator
#property indicator_buffers 10
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used for display
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed,clrMagenta,clrBlue,clrLime
//---- displaying the indicator label
#property indicator_label1  "Divergence Candles Open";"Divergence Candles High";"Divergence Candles Low";"Divergence Candles Close"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0  // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum INDMODE
  {
   MODE_MACD,    // MACD
   MODE_RSI,     // RSI
   MODE_ADX,     // ADX
   MODE_Momentum // Momentum
  };
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum PRICEMODE
  {
   MODE_CLOSE,    // Close
   MODE_HIGHLOW   // High/Low
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input INDMODE ind=MODE_MACD;     //indicator
input uint pds=10;               //indicator periods
input PRICEMODE f=MODE_CLOSE;    //price field
input double dCh=0;              //peak/trough depth minimum (0-1)
input uint xshift=0;             //shift signals back to match divergences
input int Shift=0;               //horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that 
//---- will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
double R1[],R2[],y[],xd[],xu[];

double Ch,fCh;
//---- Declaration of global variables
int min_rates_total;
//---- Declaration of integer variables for the indicator handles
int Ind_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=int(pds);
   Ch=MathMax(MathMin(dCh,1),0);
   fCh=Ch/100.0;

   if(ind!=MODE_MACD) min_rates_total=int(pds+2);
   else min_rates_total=int(12+26+9+2);

//---- get indicator's handle
   switch(ind)
     {
      case MODE_MACD:
         Ind_Handle=iMACD(NULL,0,12,26,9,PRICE_CLOSE);
         if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of iMACD indicator");
         break;

      case MODE_RSI:
         Ind_Handle=iRSI(NULL,0,pds,PRICE_CLOSE);
         if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iRSI indicator");
         break;

      case MODE_ADX:
         Ind_Handle=iADX(NULL,0,pds);
         if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iADX indicator");
         break;

      case MODE_Momentum:
         Ind_Handle=iMomentum(NULL,0,pds,PRICE_CLOSE);
         if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMomentum indicator");
         break;
     }

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- setting dynamic arrays as calculation buffers   
   SetIndexBuffer(5,R1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,R2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,y,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,xd,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,xu,INDICATOR_CALCULATIONS);

//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
   ArraySetAsSeries(R1,true);
   ArraySetAsSeries(R2,true);
   ArraySetAsSeries(y,true);
   ArraySetAsSeries(xd,true);
   ArraySetAsSeries(xu,true);

//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Divergence Candles";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,to_copy,bar,CNmb1,CNmb2,CNmb3,CNmb4;
   double Pkx1,Pkx2,Trx1,Trx2,Pky1,Pky2,Try1,Try2;
   bool Trx,Pkx,Try,Pky;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total-3; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(Ind_Handle,MAIN_LINE,0,to_copy,y)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);

   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(f==MODE_CLOSE)
        {
         xu[bar]=close[bar];
         xd[bar]=close[bar];
        }
      else
        {
         xu[bar]=high[bar];
         xd[bar]=low[bar];
        }

      ExtOpenBuffer [bar]=0.0;
      ExtCloseBuffer[bar]=0.0;
      ExtHighBuffer [bar]=0.0;
      ExtLowBuffer  [bar]=0.0;
     }

//---- main loop of the indicator calculation
   for(bar=limit; bar>=2 && !IsStopped(); bar--)
     {
      CNmb1=0;
      CNmb2=0;
      CNmb3=0;
      CNmb4=0;

      for(int kkk=bar; kkk<rates_total; kkk++)
        {
         Pkx=xu[kkk]<xu[kkk-1] && xu[kkk-1]>xu[kkk-2] && xu[kkk-1]>=(xu[kkk]+xu[kkk-2])/2.0*(1.0+fCh);

         if(Pkx) CNmb1++;
         if(Pkx && CNmb1==1) Pkx1=xu[kkk-1];
         if(Pkx && CNmb1==2) Pkx2=xu[kkk-1];

         Trx=xd[kkk]>xd[kkk-1] && xd[kkk-1]<xd[kkk-2] && xd[kkk-1]<=(xd[kkk]+xd[kkk-2])/2.0*(1.0-fCh);

         if(Trx) CNmb2++;
         if(Trx && CNmb2==1) Trx1=xd[kkk-1];
         if(Trx && CNmb2==2) Trx2=xd[kkk-1];

         Pky=y[kkk]<y[kkk-1] && y[kkk-1]>y[kkk-2] && y[kkk-1]>=(y[kkk]+y[kkk-2])/2.0*(1.0+fCh);

         if(Pky) CNmb3++;
         if(Pky && CNmb3==1) Pky1=y[kkk-1];
         if(Pky && CNmb3==2) Pky2=y[kkk-1];

         Try=y[kkk]>y[kkk-1] && y[kkk-1]<y[kkk-2] && y[kkk-1]<=(y[kkk]+y[kkk-2])/2.0*(1.0-fCh);

         if(Try) CNmb4++;
         if(Try && CNmb4==1) Try1=y[kkk-1];
         if(Try && CNmb4==2) Try2=y[kkk-1];

         if(CNmb1>=2 && CNmb2>=2 && CNmb3>=2 && CNmb4>=2) break;
        }

      Pkx=xu[bar]<xu[bar-1] && xu[bar-1]>xu[bar-2] && xu[bar-1]>=(xu[bar]+xu[bar-2])/2.0*(1.0+fCh);
      Trx=xd[bar]>xd[bar-1] && xd[bar-1]<xd[bar-2] && xd[bar-1]<=(xd[bar]+xd[bar-2])/2.0*(1.0-fCh);
      Pky=y[bar]<y[bar-1] && y[bar-1]>y[bar-2] && y[bar-1]>=(y[bar]+y[bar-2])/2.0*(1.0+fCh);
      Try=y[bar]>y[bar-1] && y[bar-1]<y[bar-2] && y[bar-1]<=(y[bar]+y[bar-2])/2.0*(1.0-fCh);

      R1[bar]=0;
      if(Trx && Try && Trx1<Trx2 && Try1>Try2) R1[bar]=1;

      R2[bar]=0;
      if(Pkx && Pky && Pkx1>Pkx2 && Pky1<Pky2) R2[bar]=1;

      if(R1[bar]-R2[bar]>0)
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         if(close[bar]>open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
        }

      if(R1[bar]-R2[bar]<0)
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         if(open[bar]>close[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
