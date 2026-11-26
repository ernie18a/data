#property copyright "Created by abfs.tech"
#property link      "https://www.abfs.tech/"
#property version   "1.00"
#property description ""

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_color1 0xFFAA00
#property indicator_label1 "Average Real Volume"

#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_color2 0xFB00FF
#property indicator_label2 "Average Tick Volume"

//--- indicator buffers
double Buffer1[];
double Buffer2[];

input int Period_Input = 14;
double myPoint; //initialized in OnInit
int Volumes_handle;
double Volumes[];
int Volumes_handle2;
double Volumes2[];
int MA_handle;
double MA[];
int MA_handle2;
double MA2[];

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | Average Volume @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   Volumes_handle = iVolumes(NULL, PERIOD_CURRENT, VOLUME_REAL);
   if(Volumes_handle < 0)
     {
      Print("The creation of iVolumes has failed: Volumes_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   Volumes_handle2 = iVolumes(NULL, PERIOD_CURRENT, VOLUME_TICK);
   if(Volumes_handle2 < 0)
     {
      Print("The creation of iVolumes has failed: Volumes_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle = iMA(NULL, PERIOD_CURRENT, Period_Input, 0, MODE_SMA, Volumes_handle);
   if(MA_handle < 0)
     {
      Print("The creation of iMA has failed: MA_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   MA_handle2 = iMA(NULL, PERIOD_CURRENT, Period_Input, 0, MODE_SMA, Volumes_handle2);
   if(MA_handle2 < 0)
     {
      Print("The creation of iMA has failed: MA_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
     }
   else
      limit++;
   
   if(BarsCalculated(Volumes_handle) <= 0) 
      return(0);
   if(CopyBuffer(Volumes_handle, 0, 0, rates_total, Volumes) <= 0) return(rates_total);
   ArraySetAsSeries(Volumes, true);
   if(BarsCalculated(MA_handle) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0) return(rates_total);
   ArraySetAsSeries(MA, true);
   if(BarsCalculated(Volumes_handle2) <= 0) 
      return(0);
   if(CopyBuffer(Volumes_handle2, 0, 0, rates_total, Volumes2) <= 0) return(rates_total);
   ArraySetAsSeries(Volumes2, true);
   if(BarsCalculated(MA_handle2) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle2, 0, 0, rates_total, MA2) <= 0) return(rates_total);
   ArraySetAsSeries(MA2, true);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(Volumes[i] > 0 //Volumes > fixed value
      )
        {
         Buffer1[i] = MA[i]; //Set indicator value at Moving Average
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(Volumes2[i] > 0 //Volumes > fixed value
      )
        {
         Buffer2[i] = MA2[i]; //Set indicator value at Moving Average
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+