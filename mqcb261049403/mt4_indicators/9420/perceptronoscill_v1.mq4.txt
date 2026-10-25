//+------------------------------------------------------------------+
//|                                             PerceptronOscill.mq4 |
//+------------------------------------------------------------------+
// расчёт по алгоритму:                                              |
//   int w10 = x10 - y;                                              |
//   double a1 = Close[i]-Close[i+n];                                |
//   return (w1 * a1  + w2 * a2 + an * wn...)                        |
//-------------------------------------------------------------------+
#property copyright "Copyright © 2009, Tula"
#property link      "http://detkomb.narod.ru/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Aqua
#property indicator_width1 2
//#property indicator_maximum 3
//#property indicator_minimum -3
//---- input parameters
extern string s0 = "N от 2-х до 90";
extern int N = 10;//
//---
int  kk, D=300;
//---
//---- buffers
double ExtSilverBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- additional buffers are used for counting
   IndicatorBuffers(1);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtSilverBuffer);
//----
   IndicatorDigits(2);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtSilverBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("PercOsc_v1("+N+")N");
//----
  if (N<2) N=2;
  if (N>90) N=90;
  //---
  kk = NormalizeDouble(D/(N+1),0);

//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+N; 
      
   for(int i=0; i<limit; i++)
      ExtSilverBuffer[i]=perceptronNN(N,i);
//---- done
   return(0);
  }


//+------------------------------------------------------------------+
double perceptronNN(int Nn,int i) {

   double rez = 0.0;
//----
   for (int c = Nn; c > 1; c--){

//    rez = rez + (((kk*c) - ((kk*(Nn+1))/2)) * (Close[i]-Close[i+c]));
    rez = rez + (((kk*c) - (D/2)) * (Close[i]-Close[i+c]));

    }

   return ( rez);  
}
//+------------------------------------------------------------------+

