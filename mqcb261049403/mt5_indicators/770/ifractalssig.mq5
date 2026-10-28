//+------------------------------------------------------------------+
//|                                               i-Fractals-sig.mq5 |
//|                                                  3172552 & KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
#property copyright "3172552 & KimIV"
#property link      "http://www.kimiv.ru"
#property description "Signals indicator"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- Magenta color is used for the indicator
#property indicator_color1  Magenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- displaying the indicator label
#property indicator_label1  "i-Fractals Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- Blue color is used for the indicator
#property indicator_color2  Blue
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- bearish indicator label display
#property indicator_label2 "i-Fractals Buy"

#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int bd =7;  // Last bar body length
input int bdd=40; // Body lenght for double top/buttom bars 
input int sd =11; // Shadow difference for fractal bars 
input int sdd=6;  // Shadow difference for double tops/buttoms bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//----
int  StartBars;
double Bd,Bdd,Sd,Sdd,ArrowInterval;
//+------------------------------------------------------------------+
//| Returning the signal pointers installation interval              |
//+------------------------------------------------------------------+
int GetArrowInterval()
  {
//----
   switch(Period())
     {
      case PERIOD_M1:  return(5);
      case PERIOD_M2:  return(5);
      case PERIOD_M3:  return(6);
      case PERIOD_M4:  return(6);
      case PERIOD_M5:  return(7);
      case PERIOD_M6:  return(8);
      case PERIOD_M10: return(9);
      case PERIOD_M12: return(9);
      case PERIOD_M15: return(10);
      case PERIOD_M20: return(12);
      case PERIOD_M30: return(15);
      case PERIOD_H1:  return(20);
      case PERIOD_H2:  return(23);
      case PERIOD_H3:  return(27);
      case PERIOD_H4:  return(30);
      case PERIOD_H6:  return(35);
      case PERIOD_H8:  return(50);
      case PERIOD_H12: return(65);
      case PERIOD_D1:  return(80);
      case PERIOD_W1:  return(150);
      case PERIOD_MN1: return(250);
     }
//----
   return(10);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables   
   StartBars=7;
   Bd=bd*_Point;
   Sd=sd*_Point;
   Bdd=bdd*_Point;
   Sdd=sdd*_Point;
   ArrowInterval=GetArrowInterval()*_Point;

//---- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="i-Fractals-sig";
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(RESET);

//---- declarations of local variables 
   int limit,bar;
   bool bc1,bc2,bc3,sc1,sc2,sc3;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-StartBars;         // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;      
      bc1=false;
      bc2=false;
      bc3=false;
      sc1=false;
      sc2=false;
      sc3=false;
      
      //--- just unconfirmed fractal with last bar White
      bc1=((low[bar+3]-low[bar+2])>Sd
           && (low[bar+4]-low[bar+2])>Sd
           && (low[bar+1]-low[bar+2])>Sd
           && (close[bar+1]-open[bar+1])>Bd
           );
      //--- just unconfirmed fractal with last bar Black
      sc1=((high[bar+2]-high[bar+3])>Sd
           && (high[bar+2]-high[bar+4])>Sd
           && (high[bar+2]-high[bar+1])>Sd
           && (open[bar+1]-close[bar+1])>Bd
           );
      //--- double buttom fractal
      bc2=((low[bar+4]-low[bar+2])>Sd
           && (low[bar+5]-low[bar+2])>Sd
           && (low[bar+1]-low[bar+2])>Sd
           && (close[bar+1]-open[bar+1])>Bd
           && (MathAbs(low[bar+3]-low[bar+2]))<Sdd
           );
      //--- double top fractal
      sc2=((high[bar+2]-high[bar+4])>Sd
           && (high[bar+2]-high[bar+5])>Sd
           && (high[bar+2]-high[bar+1])>Sd
           && (open[bar+1]-close[bar+1])>Bd
           && (MathAbs(high[bar+3]-high[bar+2]))<Sdd
           );
      //--- long bars double buttom fractal
      bc3=((low[bar+3]-low[bar+2])>Sd
           && (low[bar+4]-low[bar+2])>Sd
           && (MathAbs(low[bar+1]-low[bar+2]))<Sdd
           && (close[bar+1]-open[bar+1])>Bdd
           && (open[bar+2]-close[bar+2])>Bdd
           );
      //--- long bars double top fractal
      sc3=((high[bar+2]-low[bar+3])>Sd
           && (high[bar+2]-high[bar+4])>Sd
           && (MathAbs(high[bar+2]-high[bar+1]))<Sdd
           && (open[bar+1]-close[bar+1])>Bdd
           && (close[bar+2]-open[bar+2])>Bdd
           );
      if(bc1 || bc2 || bc3) BuyBuffer[bar]=low[bar]-ArrowInterval;
      if(sc1 || sc2 || sc3) SellBuffer[bar]=high[bar]+ArrowInterval;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
