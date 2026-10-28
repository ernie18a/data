//+------------------------------------------------------------------+
//|                                            All In One Mirror.mq4 |
//|                           Copyright © 2020, Besarion Turmanauli. |
//|                      https://www.mql5.com/en/users/dos.ge/seller |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2020, Besarion Turmanauli."
#property  link      "https://www.mql5.com/en/users/dos.ge/seller"
//---- indicator settings
#property  strict
#property  indicator_separate_window
#property  indicator_level1 0
#property  indicator_levelcolor Yellow
#property  indicator_buffers 3
#property  indicator_color1  Red
#property  indicator_color2  Blue
#property  indicator_color3  Yellow
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2

enum indicator
  {
   ind_macd = 0,//MACD
   ind_rsi = 1,//RSI
   ind_cci = 2,//CCI
   ind_stoch = 3,//Stochastic
  };



//---- indicator parameters
extern indicator BaseIndicator = ind_macd;//Base Indicator
extern int IndicatorPeriod=20;//Indicator Period
extern int SignalSMA=9;//Signal Period
extern bool Alerts      = false;
extern bool Email       = false;
extern bool Push        = false;
//---- indicator buffers
double     MacdBuffer[];
double     Macd2Buffer[];
double     SignalBuffer[];




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string title = "";
   switch(BaseIndicator)
     {
      case 0 :
         title="MACD";
         break;
      case 1 :
         title="RSI";
         break;
      case 2 :
         title="CCI";
         break;
      case 3 :
         title="Stochastic";
         break;
     }

//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(2,SignalSMA);
   IndicatorDigits(Digits+1);

//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,Macd2Buffer);
   SetIndexBuffer(2,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("All In One Mirror ("+title+","+(string)IndicatorPeriod+","+(string)SignalSMA+")");
   SetIndexLabel(0,title);
   SetIndexLabel(1,title+"2");
   SetIndexLabel(2,"Signal");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| MACD MIRROR                          |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0)
      counted_bars--;
   limit=Bars-counted_bars;
//---- macd mirror counted in the 1-st buffer
   for(int i=0; i<limit; i++)
     {

      if(BaseIndicator==0)
        {
         MacdBuffer[i]=iMA(NULL,0,IndicatorPeriod,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,IndicatorPeriod,0,MODE_EMA,PRICE_OPEN,i);
        }
      else
         if(BaseIndicator==1)
           {
            MacdBuffer[i]=iRSI(NULL,0,IndicatorPeriod,PRICE_CLOSE,i)-50;
           }
         else
            if(BaseIndicator==2)
              {
               MacdBuffer[i]=iCCI(NULL,0,IndicatorPeriod,PRICE_CLOSE,i);
              }
            else
               if(BaseIndicator==3)
                 {
                  MacdBuffer[i]=iStochastic(NULL,0,IndicatorPeriod,3,3,MODE_EMA,STO_CLOSECLOSE,MODE_MAIN,i)-50;
                 }


     }

//---- macd mirror counted in the 2-nd buffer
   for(int i=0; i<limit; i++)
     {

      if(BaseIndicator==0)
        {
         Macd2Buffer[i]=iMA(NULL,0,IndicatorPeriod,0,MODE_EMA,PRICE_OPEN,i)-iMA(NULL,0,IndicatorPeriod,0,MODE_EMA,PRICE_CLOSE,i);
        }
      else
         if(BaseIndicator==1)
           {
            Macd2Buffer[i]=50-iRSI(NULL,0,IndicatorPeriod,PRICE_CLOSE,i);
           }
         else
            if(BaseIndicator==2)
              {
               Macd2Buffer[i]=0-iCCI(NULL,0,IndicatorPeriod,PRICE_CLOSE,i);
              }
            else
               if(BaseIndicator==3)
                 {
                  Macd2Buffer[i]=50-iStochastic(NULL,0,IndicatorPeriod,3,3,MODE_EMA,STO_CLOSECLOSE,MODE_MAIN,i);
                 }
     }

//---- signal line mirror counted in the 3-rd buffer
   for(int i=0; i<limit; i++)
     {
      if(BaseIndicator==0)
        {
         SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
        }
      else
         if(BaseIndicator==1)
           {
            SignalBuffer[i]=iRSIOnArray(MacdBuffer,Bars,SignalSMA,i)-50;
           }
         else
            if(BaseIndicator==2)
              {
               SignalBuffer[i]=iCCIOnArray(MacdBuffer,Bars,SignalSMA,i);
              }
            else
               if(BaseIndicator==3)
                 {
                  SignalBuffer[i]=iStochastic(NULL,0,IndicatorPeriod,3,3,MODE_EMA,STO_CLOSECLOSE,MODE_SIGNAL,i)-50;
                 }
     }
     
     
   
   //check for crossunder
   if(SignalBuffer[2]>=MacdBuffer[2] && SignalBuffer[1]<MacdBuffer[1])CrossUnderSignal();
   
   //check for crossover
   if(SignalBuffer[2]<=MacdBuffer[2] && SignalBuffer[1]>MacdBuffer[1])CrossOverSignal();
     
     
//---- done
   return(0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|   Send CrossUnder Notification                                   |
//+------------------------------------------------------------------+
void CrossUnderSignal()
  {
   if(Alerts)
      Alert("CROSSUNDER ON "+Symbol());
   if(Email)
      SendMail("CROSSUNDER ON "+Symbol(),"Signal Sent From AIO Mirror Indicator");
   if(Push)
      SendNotification("AIO Mirror: CROSSUNDER ON "+Symbol());
   Print("CROSSUNDER");
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  Send CrossOver Notification                                     |
//+------------------------------------------------------------------+
void CrossOverSignal()
  {
   if(Alerts)
      Alert("CROSSOVER ON "+Symbol());
   if(Email)
      SendMail("CROSSOVER ON "+Symbol(),"Signal Sent From AIO Mirror Indicator");
   if(Push)
      SendNotification("AIO Mirror: CROSSOVER ON "+Symbol());
   Print("CROSSOVER");
  }
//+------------------------------------------------------------------+
