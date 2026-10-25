//+------------------------------------------------------------------+
//|                                                 Sniper Tools.mq4 |
//+------------------------------------------------------------------+
//|                                                 Sniper Tools.mq4 |
//|                                                      Colin Reeve |
//|                                             midworld08@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Colin Reeve"
#property link      "midworld08@gmail.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Gold
#property indicator_style1 DRAW_ARROW

#define graphics_multiplier 200

//---- External inputs from user
extern int  MACD_FastMAPeriod=12,
            MACD_SlowMAPeriod=26,
            MACD_SignalMAPeriod=9;
  
int period[]={1,5,15,30,60,240,1440,10080,43200};  //array used to pass variables repeatedly to indicators
string periodString[]={"M1","M5","M15","M30","H1","H4","D1","W1","MN1"}; //arrays used to show time value above arrows

double Activator_Buffer[];
int ExtCountedBars=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
 //set up the activator symbol to show the sniper active Symbol
   IndicatorBuffers(1);
   SetIndexBuffer(0,Activator_Buffer);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,181);
   SetIndexEmptyValue(0,0.0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
 //time to figure out which bars of the currently shown graph have the MACD travelling in the same direction
   double MACD_Histo, MACD_Histo1, MACD_Histo2, MACD_Histo3;
   int   Current_Chart_Period=Period();   //fetch the current period of the chart
   int   Next_Chart_Period1, Next_Chart_Period2, Next_Chart_Period3;
   int   i=0,Higher_Chart_Period_Pos1,
         Higher_Chart_Period_Pos2,Higher_Chart_Period_Pos3;
   datetime Bar_Time;
   if (Current_Chart_Period!=5) return(0);   //if not in the M5 chart exit indicator
//   while (Current_Chart_Period!=period[i])   //remove from commenting to change to iterate through next higher time periods
//   {  
//      i++;
//   }
   Next_Chart_Period1=60; //period[i+1];   //need to know the next higher time frame
   Next_Chart_Period2=240; //period[i+2];  
   Next_Chart_Period3=1440; //period[i+3];   
//   Next_Chart_Period4=period[i+4];  
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   i = Bars - counted_bars;
   if(counted_bars==0) i--;
      
//---- main calculation loop
   while(i>=0)
   {
      Bar_Time=Time[i];  //fetch the current bar time 
      Higher_Chart_Period_Pos1=iBarShift(NULL,Next_Chart_Period1,Bar_Time); //search the next higher time frame for the bar position containing this time
      Higher_Chart_Period_Pos2=iBarShift(NULL,Next_Chart_Period2,Bar_Time);
      Higher_Chart_Period_Pos3=iBarShift(NULL,Next_Chart_Period3,Bar_Time);
//      Higher_Chart_Period_Pos4=iBarShift(NULL,Next_Chart_Period4,Bar_Time);
      //get the MACD values for the current chart period and bar
      MACD_Histo = iCustom(NULL,Current_Chart_Period,"iMACD",MACD_FastMAPeriod,MACD_SlowMAPeriod,MACD_SignalMAPeriod,2,i);
      MACD_Histo1 = iCustom(NULL,Next_Chart_Period1,"iMACD",MACD_FastMAPeriod,MACD_SlowMAPeriod,MACD_SignalMAPeriod,2,Higher_Chart_Period_Pos1);
      MACD_Histo2 = iCustom(NULL,Next_Chart_Period2,"iMACD",MACD_FastMAPeriod,MACD_SlowMAPeriod,MACD_SignalMAPeriod,2,Higher_Chart_Period_Pos2);
      MACD_Histo3 = iCustom(NULL,Next_Chart_Period3,"iMACD",MACD_FastMAPeriod,MACD_SlowMAPeriod,MACD_SignalMAPeriod,2,Higher_Chart_Period_Pos3);
//      MACD_Histo4 = iCustom(NULL,Next_Chart_Period4,"iMACD",MACD_FastMAPeriod,MACD_SlowMAPeriod,MACD_SignalMAPeriod,2,Higher_Chart_Period_Pos4);
      Activator_Buffer[i]=0.0;    //set buffer to zero for default value
      if (MACD_Histo<0)
         if (MACD_Histo1<0)
            if (MACD_Histo2<0)
               if (MACD_Histo3<0)
                     Activator_Buffer[i]=High[i]; 
      if (MACD_Histo>0)
         if (MACD_Histo1>0)
            if (MACD_Histo2<0)
              if (MACD_Histo3<0)
                     Activator_Buffer[i]=Low[i] ; 
 	   i--;
   }
  return(0);
  }
//+------------------------------------------------------------------+