//+------------------------------------------------------------------+
//|                                          #!DivStochv5onchart.mq4 |
//|                                    Copyright @2011, Rockyhoangdn |
//|                                           rockyhoangdn@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright @2011, Rockyhoangdn"
#property link      "rockyhoangdn@gmail.com"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  DarkGreen
#property indicator_color2  Red
#property indicator_color3  Blue
#property indicator_color4  DeepPink
#property indicator_color5  Blue
#property indicator_color6  Aqua
#property indicator_color7  Red

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 2
 
extern int StochPeriod=20;
extern int Sensitive=5;
extern double overbought_value=99.9;
extern double oversold_value=99.9;
double buf[];
double bufinv[];
double mabuf[];
double mabufinv[];
double buf2[];
double overbought[];
double oversold[];
double shortentry[];
double longentry[];
double zigzag[];
string TOP_BOTText[];
int shift=0;
int deinit()
{

ObjectsDeleteAll();
   return(0);
}
int init()
  {
   SetIndexBuffer(0,buf);
   SetIndexStyle(0,DRAW_NONE);
   
   SetIndexBuffer(1,bufinv);
   SetIndexStyle(1,DRAW_NONE);
   
   SetIndexBuffer(2,mabuf);
   SetIndexStyle(2,DRAW_NONE);
   
   SetIndexBuffer(3,mabufinv);
   SetIndexStyle(3,DRAW_NONE);
   
   SetIndexBuffer(4,shortentry);
   SetIndexStyle(4,DRAW_SECTION);
   
   SetIndexBuffer(5,longentry);
   SetIndexStyle(5,DRAW_SECTION);
   
   SetIndexBuffer(6,zigzag);
   SetIndexStyle(6,DRAW_SECTION);

   IndicatorShortName("Div-Stochv3 - rockyhoangdn@gmail.com");
   return(0);
  }
 
int start()
  {
//   int limit=Bars;
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+3;
   
   for (int z = Bars-1; z >=0 ; z--) 
      { 
      ObjectDelete("pattern-" + z);
      }
   ArrayResize(buf2,limit); 
   ArraySetAsSeries(buf2,true);
   for(int i=0; i<limit; i++)
    {
       buf2[i]=(iStochastic(NULL,0,StochPeriod,3,3,MODE_EMA,1,MODE_MAIN,i)+
                iStochastic(NULL,0,StochPeriod*2.5,3,3,MODE_EMA,1,MODE_MAIN,i)*2.5+
                iStochastic(NULL,0,StochPeriod*5,3,3,MODE_EMA,1,MODE_MAIN,i)*5+
                iStochastic(NULL,0,StochPeriod*10,3,3,MODE_EMA,1,MODE_MAIN,i)*10
       )/18.5;
    }
    if (limit>0) 
    {
    ArrayResize (overbought,limit+1);
    ArrayResize (oversold,limit+1);
    ArrayResize (TOP_BOTText,limit+1);
    }
   for(i=0; i<limit; i++) 
      {
      buf[i]=iMAOnArray(buf2,limit,1,0,MODE_EMA,i);  
      bufinv[i]=100-buf[i];
      if(buf[i] >= overbought_value) overbought[i]=buf[i];
      if(bufinv[i] >= oversold_value) oversold[i]=bufinv[i];
     }

   for(int ii=0; ii<limit; ii++) 
      {
      mabuf[ii]=iMAOnArray(buf,limit,Sensitive,0,MODE_LWMA,ii);  
      mabufinv[ii]=iMAOnArray(bufinv,limit,Sensitive,0,MODE_LWMA,ii);
      }
   for(int iii=0; iii<limit; iii++) 
      {
      if((buf[iii+1] >= overbought_value && buf[iii] <=  mabuf[iii])
          ||(buf[iii+2] >= overbought_value && buf[iii] <=  mabuf[iii])
          ||(buf[iii+3] >= overbought_value && buf[iii] <=  mabuf[iii])
            )   
         {
         shortentry[iii] = Open[iii];
         }
            else shortentry[iii] =0;
            
      if((bufinv[iii+1] >= overbought_value && bufinv[iii] <=  mabufinv[iii])
         ||(bufinv[iii+2] >= overbought_value && bufinv[iii] <=  mabufinv[iii])
         ||(bufinv[iii+3] >= overbought_value && bufinv[iii] <=  mabufinv[iii])
      
      )   
         {
         longentry[iii] = Open[iii];
         }
            else longentry[iii] =0;
      }
   for(iii=0; iii<limit; iii++) 
      {
         if(shortentry[iii]!=0) zigzag[iii] = Open[iii];
         if(longentry[iii] !=0) zigzag[iii] = Open[iii];
      }
   for (int j = limit; j >=0 ; j--) 
      { 
      TOP_BOTText[j] = "pattern-" + j;
      }
   for (shift=limit-1;shift>=0;shift--)
     {
     if(longentry[shift+1]!=0)
      {
      ObjectCreate(TOP_BOTText[shift+1], OBJ_TEXT, 0, Time[shift+1], Low[shift+1] - (High[shift+1] - Low[shift+1])/4 );
      ObjectSetText(TOP_BOTText[shift+1], DoubleToStr(longentry[shift+1],Digits)  , 7, "Times New Roman", Aqua);
      }
      
     if(shortentry[shift+1]!=0)
      {
      ObjectCreate(TOP_BOTText[shift+1], OBJ_TEXT, 0, Time[shift+1], High[shift+1] + (High[shift+1] - Low[shift+1])/4 );
      ObjectSetText(TOP_BOTText[shift+1],DoubleToStr(shortentry[shift+1],Digits)  , 7, "Times New Roman", Pink);
      }
     }
   return(0);
  }