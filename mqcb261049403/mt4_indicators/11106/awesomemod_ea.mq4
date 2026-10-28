//+------------------------------------------------------------------+
//|                                                AwesomeMod_EA.mq4 |
//|                                                    Manel Sanchon |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Manel Sanchon"
#property link      ""
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Green
 
// External parameters
extern int short_mean = 5;
extern int long_mean = 34;
extern int meanAO = 7;
 
 
//---- indicator buffers
double AO[];
double ExtBuffer[];
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_NONE);
   IndicatorDigits(Digits+1);
   SetIndexDrawBegin(0,34);
   SetIndexDrawBegin(1,34);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,AO);
   SetIndexBuffer(1,ExtBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("AwesomeMod_EA("+short_mean+","+long_mean+";"+meanAO+")");
   SetIndexLabel(0,"AO"); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Awesome Oscillator                                               |
//+------------------------------------------------------------------+
int start()
  {
 
  double ShortMA, LongMA;
  double MAExtBufferCurrent,MAExtBufferPrev;
  int Count;
 
  if(Bars<=long_mean)
    {
      Comment("Not enough bars to make computations"); 
      return(0);
    }
 
  if(meanAO>long_mean)
    {
      Comment("Mean AO has to be smaller than Long mean"); 
      return(0);
    }
 
  int counted_bars = IndicatorCounted();  
  int CalculateBars = Bars-counted_bars-(long_mean+1);
  if(counted_bars>long_mean)
     {
      CalculateBars=Bars-counted_bars-1;
     }    
 
  
//--- handles for MAs
  for(Count = CalculateBars; Count >=0 ; Count--)
   {
     ShortMA = iMA(NULL,0,short_mean,0,MODE_SMMA,PRICE_MEDIAN,Count);
     LongMA = iMA(NULL,0,long_mean,0,MODE_SMMA,PRICE_MEDIAN,Count);
     ExtBuffer[Count] = (ShortMA/LongMA-1)*100;
   }
   
//---- dispatch values between 2 buffers
   bool up=true;
   for(Count = CalculateBars; Count >= 0; Count--)
     {
        AO[Count] = iMAOnArray(ExtBuffer,0,meanAO,0,MODE_SMMA,Count); 
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+