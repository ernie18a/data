//+------------------------------------------------------------------+
//|     MA Cross 3MACross Alert WarnSig(barabashkakvn's edition).mq5 |
//|                                             2008forextsd mladen  |
//|                 Copyright © 1999-2007, MetaQuotes Software Corp. |
//+------------------------------------------------------------------+
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot Arrows 
#property indicator_label1  "Cross Up" 
#property indicator_type1   DRAW_ARROW 
#property indicator_color1  clrBlue 
#property indicator_width1  1 

#property indicator_label2  "Cross Down" 
#property indicator_type2   DRAW_ARROW 
#property indicator_color2  clrRed
#property indicator_width2  1 

#property indicator_label3  "Cross Ghost Up" 
#property indicator_type3   DRAW_ARROW 
#property indicator_color3  clrYellow
#property indicator_width3  1 

#property indicator_label4  "Cross Ghost Down" 
#property indicator_type4   DRAW_ARROW 
#property indicator_color4  clrGold
#property indicator_width4  1 
//--- input parameters
sinput string        _0_               = "Parameters of the first Moving Average";
input int            InpMAPeriodFirst  = 5;           // Period of the first Moving Average
input int            InpMAShiftFirst   = 0;           // Shift of the first Moving Average
input ENUM_MA_METHOD InpMAMethodFirst  = MODE_SMMA;   // Method of the first Moving Average
sinput string        _1_               = "Parameters of the second Moving Average";
input int            InpMAPeriodSecond = 13;          // Period of the second Moving Average
input int            InpMAShiftSecond  = 0;           // Shift of the second Moving Average
input ENUM_MA_METHOD InpMAMethodSecond = MODE_SMMA;   // Method of the second Moving Average
sinput string        _2_               = "Parameters of the Third Moving Average";
input int            InpMAPeriodThird  = 34;          // Period of the third Moving Average
input int            InpMAShiftThird   = 0;           // Shift of the third Moving Average
input ENUM_MA_METHOD InpMAMethodThird  = MODE_SMMA;   // Method of the third Moving Average
input bool crossesOnCurrent=true;
input bool alertsOn        =true;
input bool alertsMessage   =true;
input bool alertsSound     =false;
input bool alertsEmail     =false;
//---
int                  handle_iMA_First;                // variable for storing the handle of the iMA indicator 
int                  handle_iMA_Second;               // variable for storing the handle of the iMA indicator 
int                  handle_iMA_Third;                // variable for storing the handle of the iMA indicator 
//---
double CrossUp[];
double CrossDown[];
double CrossGhostUp[];
double CrossGhostDown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpMAPeriodFirst<=0)
     {
      Print("The \"Period of the first Moving Average\" parameter can't be less or is equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMAPeriodSecond<=0)
     {
      Print("The \"Period of the second Moving Average\" parameter can't be less or is equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMAPeriodThird<=0)
     {
      Print("The \"Period of the third Moving Average\" parameter can't be less or is equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMAPeriodFirst>=InpMAPeriodSecond)
     {
      Print("Parameter \"Period of the first Moving Average\" can't be more or is equal to a paramter of \"Period of the second Moving Average\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpMAPeriodSecond>=InpMAPeriodThird)
     {
      Print("Parameter \"Period of the second Moving Averagee\" can't be more or is equal to a paramter of \"Period of the third Moving Average\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- create handle of the indicator iMA
   handle_iMA_First=iMA(Symbol(),Period(),InpMAPeriodFirst,InpMAShiftFirst,InpMAMethodFirst,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_First==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Second=iMA(Symbol(),Period(),InpMAPeriodSecond,InpMAShiftSecond,InpMAMethodSecond,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Second==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Third=iMA(Symbol(),Period(),InpMAPeriodThird,InpMAShiftThird,InpMAMethodThird,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Third==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,CrossUp,INDICATOR_DATA);
   SetIndexBuffer(1,CrossDown,INDICATOR_DATA);
   SetIndexBuffer(2,CrossGhostUp,INDICATOR_DATA);
   SetIndexBuffer(3,CrossGhostDown,INDICATOR_DATA);
//--- Define the symbol code for drawing in PLOT_ARROW 
   PlotIndexSetInteger(0,PLOT_ARROW,241);
   PlotIndexSetInteger(1,PLOT_ARROW,242);
   PlotIndexSetInteger(2,PLOT_ARROW,241);
   PlotIndexSetInteger(3,PLOT_ARROW,242);
//--- Set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,5);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-5);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,5);
   PlotIndexSetInteger(3,PLOT_ARROW_SHIFT,-5);
//--- Set as an empty value 0 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
   ArraySetAsSeries(CrossUp,true);
   ArraySetAsSeries(CrossDown,true);
   ArraySetAsSeries(CrossGhostUp,true);
   ArraySetAsSeries(CrossGhostDown,true);
//---
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
//---
   if(rates_total<10 || rates_total<InpMAPeriodThird) // very few bars
      return(0);
   int limit=rates_total-prev_calculated+1;
   if(prev_calculated==0)
      limit=rates_total-1;

   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   for(int i=limit;i>=0;i--)
     {
      //--- we look for crossing of two indicators
      double   First[];
      double   Second[];
      double   Third[];
      ArraySetAsSeries(First,true);
      ArraySetAsSeries(Second,true);
      ArraySetAsSeries(Third,true);
      int      buffer_num=0;           // indicator buffer number 
      int      start_pos=i;            // start position      
      int      count=2;                // amount to copy 
      bool get_first = true;
      bool get_second= true;
      bool get_third = true;
      get_first   = iMAGet(handle_iMA_First,buffer_num,start_pos,count,First);
      get_second  = iMAGet(handle_iMA_Second,buffer_num,start_pos,count,Second);
      get_third   = iMAGet(handle_iMA_Third,buffer_num,start_pos,count,Third);
      if(!get_first || !get_second || !get_third)
         continue;
      //--- for debug in tester:
      //Comment("First[0] ",DoubleToString(First[0],Digits()+1),", First[1] ",DoubleToString(First[1],Digits()+1),"\n",
      //        "Second[0] ",DoubleToString(Second[0],Digits()+1),", Second[1] ",DoubleToString(Second[1],Digits()+1),"\n",
      //        "Third[0] ",DoubleToString(Third[0],Digits()+1),", Third[1] ",DoubleToString(Third[1],Digits()+1),"\n");
      double Range=0.0;
      int counter=i-9;
      counter=(counter<0)?0:counter;
      for(int j=counter;j<=i;j++)
         Range+=MathAbs(high[j]-low[j]);
      Range/=10.0;               // "10.0"this amount of the taken values
      //--- avoid current bar if not allowed to check crosses on current (i==0)
      if(crossesOnCurrent==false && i==0)
         continue;
      //---
      int    crossID = 0;
      double curr    = 0.0;
      double prev    = 0.0;
      double point   = 0.0;
      while(true)
        {
         curr= First[0]- Second[0];
         prev= First[1]- Second[1];
         point=(First[0]+First[1])/2;
         if(curr*prev<=0)
           {
            crossID=1;
            break;
           }
         curr=First[0]- Third[0];
         prev=First[1]- Third[1];
         if(curr*prev<=0)
           {
            crossID=2;
            break;
           }
         curr=Second[0]- Third[0];
         prev=Second[1]- Third[1];
         point=(Second[0]+Second[1])/2;
         if(curr*prev<=0)
           {
            crossID=3;
            break;
           }
         break;
        }
      //    the interesting thing is the direction of the crossing
      //    which MA is the primary and which one the secondary
      //    if you do not know that you can not determine the "direction"
      //    of the cross
      CrossUp[i]        =EMPTY_VALUE;
      CrossDown[i]      =EMPTY_VALUE;
      CrossGhostUp[i]   =EMPTY_VALUE;
      CrossGhostDown[i] =EMPTY_VALUE;
      if(crossID>0)
        {
         if(alertsOn)
           {
            double curr_norm=NormalizeDouble(curr,Digits());
            if((i==0 && crossesOnCurrent==true) || (i==1 && crossesOnCurrent==false))
              {
               switch(crossID)
                 {
                  case 1:
                     if(curr_norm>0.0)
                     doAlert(" 3MACross: \"First MA\" crossed \"Second MA\" UP",time[i],close[i]);
                     else if(curr_norm<0.0)
                        doAlert(" 3MACross: \"First MA\" crossed \"Second MA\" DOWN",time[i],close[i]);
                     break;
                  case 2:
                     if(curr_norm>0.0)
                     doAlert(" 3MACross: \"First MA\" crossed \"Third MA\" UP",time[i],close[i]);
                     else if(curr_norm<0.0)
                        doAlert(" 3MACross: \"First MA\" crossed \"Third MA\" DOWN",time[i],close[i]);
                     break;
                  case 3:
                     if(curr_norm>0.0)
                     doAlert(" 3MACross: \"Second MA\" crossed \"Third MA\" UP",time[i],close[i]);
                     else if(curr_norm<0.0)
                        doAlert(" 3MACross: \"Second MA\" crossed \"Third MA\" DOWN",time[i],close[i]);
                     break;
                 }
              }
            //---
            if(i==0)
              {
               if(curr_norm>0.0)
                  CrossGhostUp[i]=point-Range*0.5;
               else if(curr_norm<0.0)
                  CrossGhostDown[i]=point+Range*0.5;
              }
            else
              {
               if(curr_norm>0.0)
                  CrossUp[i]=point-Range*0.5;
               else if(curr_norm<0.0)
                  CrossDown[i]=point+Range*0.5;
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
bool iMAGet(int    handle_iMA,   // indicator handle 
            int    buffer_num,   // indicator buffer number 
            int    start_pos,    // start position 
            int    count,        // amount to copy 
            double &buffer[]     // target array to copy 
            )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,buffer_num,start_pos,count,buffer)!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string doWhat,datetime time_last_bar,double close)
  {
   static string   previousAlert="nothing";
   static datetime previousTime=0;
   string message;
//----
   if(previousAlert!=doWhat || previousTime!=time_last_bar)
     {
      previousAlert =doWhat;
      previousTime  =time_last_bar;
      //        if time needed :
      //        message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," @",Bid," ", doWhat);
      message=Symbol()+" at "+DoubleToString(close,Digits())+" "+doWhat;
      if(alertsMessage)
         Alert(message);
      if(alertsEmail)
         SendMail(Symbol()+" 3MACross:"+" M"+EnumToString(Period()),message);
      if(alertsSound)
         PlaySound("alert2.wav");
     }
  }
//+------------------------------------------------------------------+
