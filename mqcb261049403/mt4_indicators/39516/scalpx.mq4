//+------------------------------------------------------------------+
//|                                                           ScalpX |
//|                                    Copyright 2022, Capek Systems |
//|                                        miguel.marina.g@gmail.com |
//+------------------------------------------------------------------+
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_color1 White
#property indicator_label1 "KalmanUP"
#property indicator_color2 White
#property indicator_label2 "KalmanDN"
#property indicator_color3 Magenta
#property indicator_label3 "KalmanXUP"
#property indicator_color4 Aqua
#property indicator_label4 "KalmanXDN"

enum ENUM_TYPE
  {
   Buy,
   Sell
  };

extern ENUM_TYPE Type=Buy;
double Buy_K=60;
double Buy_Sharpness=4;
double Sell_K=60;
double Sell_Sharpness=4;
double KX_K=24;
double KX_Sharpness=3;
int    draw_begin=500;

double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtKalmanXBufferUp[];
double ExtKalmanXBufferDown[];

#define KalmanUp     0
#define KalmanDown   1
#define KalmanXUp    2
#define KalmanXDown  3

int ExtCountedBars=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS));

   SetIndexBuffer(KalmanUp,ExtMapBufferUp,INDICATOR_DATA);
   SetIndexBuffer(KalmanDown,ExtMapBufferDown,INDICATOR_DATA);
   SetIndexBuffer(KalmanXUp,ExtKalmanXBufferUp,INDICATOR_DATA);
   SetIndexBuffer(KalmanXDown,ExtKalmanXBufferDown,INDICATOR_DATA);

   SetIndexStyle(KalmanUp,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(KalmanDown,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(KalmanXUp,DRAW_LINE,STYLE_SOLID,5);
   SetIndexStyle(KalmanXDown,DRAW_LINE,STYLE_SOLID,5);

   SetIndexDrawBegin(KalmanUp,draw_begin);
   SetIndexDrawBegin(KalmanDown,draw_begin);
   SetIndexDrawBegin(KalmanXUp,draw_begin);
   SetIndexDrawBegin(KalmanXDown,draw_begin);

   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iValue(int mode,int shift)
  {
   switch(mode)
     {
      case PRICE_CLOSE:
         return(iClose(NULL,0,shift));
      case PRICE_OPEN:
         return(iOpen(NULL,0,shift));
      case PRICE_HIGH:
         return(iHigh(NULL,0,shift));
      case PRICE_LOW:
         return(iLow(NULL,0,shift));
      case PRICE_MEDIAN:
         return((iHigh(NULL,0,shift)+iLow(NULL,0,shift))/2);
      case PRICE_TYPICAL:
         return((iHigh(NULL,0,shift)+iLow(NULL,0,shift)+iClose(NULL,0,shift))/3);
      case PRICE_WEIGHTED:
         return((iHigh(NULL,0,shift)+iLow(NULL,0,shift)+iClose(NULL,0,shift)+iClose(NULL,0,shift))/4);
      default:
         return(0);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=draw_begin)
     {
      return(0);
     }

   int i;

   double Velocity=0;
   double Distance=0;
   double Error=0;
   double value=iValue(PRICE_TYPICAL,draw_begin+1);

   double KX_Velocity=0;
   double KX_Distance=0;
   double KX_Error=0;
   double KX_value;

   if(Type == Buy)
     {
      KX_value=iValue(PRICE_LOW,draw_begin+1);
     }
   else
     {
      KX_value=iValue(PRICE_HIGH,draw_begin+1);
     }

   for(i=draw_begin; i>=0; i--)
     {
      if(i==0)
        {
         if(Type == Buy)
           {
            Distance=Ask-value;
            KX_Distance=Ask-KX_value;
           }
         else
           {
            Distance=Bid-value;
            KX_Distance=Bid-KX_value;
           }
        }
      else
        {
         Distance=iValue(PRICE_TYPICAL,i)-value;

         if(Type == Buy)
           {
            KX_Distance=iValue(PRICE_LOW,i)-KX_value;
           }
         else
           {
            KX_Distance=iValue(PRICE_HIGH,i)-KX_value;
           }
        }

      if(Type == Buy)
        {
         Error=value+Distance*MathSqrt(Buy_Sharpness*Buy_K/100);
         Velocity=Velocity+Distance*Buy_K/100;
         value=Error+Velocity;
        }
      else
        {
         Error=value+Distance*MathSqrt(Sell_Sharpness*Sell_K/100);
         Velocity=Velocity+Distance*Sell_K/100;
         value=Error+Velocity;
        }

      KX_Error=KX_value+KX_Distance*MathSqrt(KX_Sharpness*KX_K/100);
      KX_Velocity=KX_Velocity+KX_Distance*KX_K/100;
      KX_value=KX_Error+KX_Velocity;

      if(Type == Sell)
        {
         if(KX_Velocity>=0)
           {
            ExtKalmanXBufferUp[i]=KX_value;
            ExtKalmanXBufferDown[i]=EMPTY_VALUE;
           }
        }
      else
        {
         if(KX_Velocity>=0)
           {
            //Do Nothing
           }
         else
           {
            ExtKalmanXBufferUp[i]=EMPTY_VALUE;
            ExtKalmanXBufferDown[i]=KX_value;
           }
        }

      if(Velocity>=0)
        {
         ExtMapBufferUp[i]=value;
         ExtMapBufferDown[i]=EMPTY_VALUE;
         //----
         if(ExtMapBufferUp[i+1]==EMPTY_VALUE)
            ExtMapBufferUp[i+1]=ExtMapBufferDown[i+1];
        }
      else
        {
         ExtMapBufferUp[i]=EMPTY_VALUE;
         ExtMapBufferDown[i]=value;
         if(ExtMapBufferDown[i+1]==EMPTY_VALUE)
            ExtMapBufferDown[i+1]=ExtMapBufferUp[i+1];
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
