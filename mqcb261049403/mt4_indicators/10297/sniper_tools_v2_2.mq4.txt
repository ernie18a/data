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

//---- External inputs from user
extern int  Higher_TF1 = 60,
Higher_TF2 = 240,
Higher_TF3 = 1440,
MACD_M1_FastMAPeriod=12,
MACD_M1_SlowMAPeriod=26,
MACD_M1_SignalMAPeriod=5,
MACD_M5_FastMAPeriod=12,
MACD_M5_SlowMAPeriod=26,
MACD_M5_SignalMAPeriod=5,
MACD_M15_FastMAPeriod=12,
MACD_M15_SlowMAPeriod=26,
MACD_M15_SignalMAPeriod=5,
MACD_M30_FastMAPeriod=12,
MACD_M30_SlowMAPeriod=26,
MACD_M30_SignalMAPeriod=5,
MACD_H1_FastMAPeriod=12,
MACD_H1_SlowMAPeriod=26,
MACD_H1_SignalMAPeriod=5,
MACD_H4_FastMAPeriod=12,
MACD_H4_SlowMAPeriod=26,
MACD_H4_SignalMAPeriod=5,
MACD_D_FastMAPeriod=12,
MACD_D_SlowMAPeriod=26,
MACD_D_SignalMAPeriod=5;
extern color Signal_Color=Gold;

int MACD_Var[7,3];
int period[]={1,5,15,30,60,240,1440,10080,43200};  //array used to pass variables repeatedly to indicators
string periodString[]={"M1","M5","M15","M30","H1","H4","D1","W1","MN1"}; //arrays used to show time value above arrows

double Activator_Buffer[];
int ExtCountedBars=0;
bool First_Signal=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//set up the MACD Variables array 
   MACD_Var[0,0] = MACD_M1_FastMAPeriod;
   MACD_Var[0,1] = MACD_M1_SlowMAPeriod;
   MACD_Var[0,2] = MACD_M1_SignalMAPeriod;
   MACD_Var[1,0] = MACD_M5_FastMAPeriod;
   MACD_Var[1,1] = MACD_M5_SlowMAPeriod;
   MACD_Var[1,2] = MACD_M5_SignalMAPeriod;
   MACD_Var[2,0] = MACD_M15_FastMAPeriod;
   MACD_Var[2,1] = MACD_M15_SlowMAPeriod;
   MACD_Var[2,2] = MACD_M15_SignalMAPeriod;
   MACD_Var[3,0] = MACD_M30_FastMAPeriod;
   MACD_Var[3,1] = MACD_M30_SlowMAPeriod;
   MACD_Var[3,2] = MACD_M30_SignalMAPeriod;
   MACD_Var[4,0] = MACD_H1_FastMAPeriod;
   MACD_Var[4,1] = MACD_H1_SlowMAPeriod;
   MACD_Var[4,2] = MACD_H1_SignalMAPeriod;
   MACD_Var[5,0] = MACD_H4_FastMAPeriod;
   MACD_Var[5,1] = MACD_H4_SlowMAPeriod;
   MACD_Var[5,2] = MACD_H4_SignalMAPeriod;
   MACD_Var[6,0] = MACD_D_FastMAPeriod;
   MACD_Var[6,1] = MACD_D_SlowMAPeriod;
   MACD_Var[6,2] = MACD_D_SignalMAPeriod;

//set up the activator symbol to show the sniper active Symbol
   SetIndexStyle(0,DRAW_ARROW,EMPTY,EMPTY,Signal_Color);
   SetIndexArrow(0,181);
   SetIndexBuffer(0,Activator_Buffer);
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
   double MACD_Histo[4];
   int   i=0,Chart_Pos[4],Base_Chart_Period;
   datetime Bar_Time;
   if(Period()>30) return(0);
   while(Period()!=period[i]) //loop until next higher time period is found
     {
      i++;
     }
   Base_Chart_Period=i;    //store value to be used again
                           //Chart_Pos[0]=Bars-2;
//if(ExtCountedBars>2) Chart_Pos[0]=Bars-ExtCountedBars-1;

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   Chart_Pos[0]=Bars-counted_bars;
   if(counted_bars==0) Chart_Pos[0]--;

//---- main calculation loop
   while(Chart_Pos[0]>=0)
     {
      Bar_Time=Time[Chart_Pos[0]];  //fetch the current bar time
      i=Base_Chart_Period;
      MACD_Histo[0]=iCustom(NULL,Period(),"iMACD",MACD_Var[i,0],MACD_Var[i,1],MACD_Var[i,2],2,Chart_Pos[0]);
      i=4;
      Chart_Pos[1]=iBarShift(NULL,Higher_TF1,Bar_Time);      //find the bar in the next higher time frame
      MACD_Histo[1]=iCustom(NULL,Higher_TF1,"iMACD",MACD_Var[i,0],MACD_Var[i,1],MACD_Var[i,2],2,Chart_Pos[1]);
      i++;
      Chart_Pos[2]=iBarShift(NULL,Higher_TF2,Bar_Time);
      MACD_Histo[2]=iCustom(NULL,Higher_TF2,"iMACD",MACD_Var[i,0],MACD_Var[i,1],MACD_Var[i,2],2,Chart_Pos[2]);
      i++;
      Chart_Pos[3]=iBarShift(NULL,Higher_TF3,Bar_Time);
      MACD_Histo[3]=iCustom(NULL,Higher_TF3,"iMACD",MACD_Var[i,0],MACD_Var[i,1],MACD_Var[i,2],2,Chart_Pos[3]);
      Activator_Buffer[Chart_Pos[0]]=0.0;    //set buffer to zero for default value
                                             //check to see if we have an MACD alignment
      if((First_Signal==false) && (MACD_Histo[0]<0) && (MACD_Histo[1]<0) && (MACD_Histo[2]<0) && (MACD_Histo[3]<0))
        {
         Activator_Buffer[Chart_Pos[0]]=High[Chart_Pos[0]];
        }
      if((First_Signal==false) && (MACD_Histo[0]>0) && (MACD_Histo[1]>0) && (MACD_Histo[2]<0) && (MACD_Histo[3]<0))
        {
         Activator_Buffer[Chart_Pos[0]]=Low[Chart_Pos[0]];
        }
      Chart_Pos[0]--;
     }
   return(0);
  }
//+------------------------------------------------------------------+
