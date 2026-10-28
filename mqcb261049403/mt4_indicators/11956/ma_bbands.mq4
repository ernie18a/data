//+------------------------------------------------------------------+
//|                                                    MA_BBands.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//|                                        E-MAIL:40468962@qq.com    |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 White
#property indicator_color2 White
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Yellow

#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  1
#property  indicator_width4  1
#property  indicator_width5  1


extern int MoveShift = 12;
extern int MAPeriod = 9 ;
extern int OsMA = 3 ; 
extern int Dist2 = 20 ;
//-------------------------

extern double Std = 0.4 ; //0.5
extern int BPeriod = 20 ;


//-------------------------

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
//-------------------

int init()
  {
  
   IndicatorBuffers(5);
  
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);   

   
   return(0);
  }
//----------------------------------------
 
int deinit()
  {return(0);}
//---------------------------------------- 
int start()
  { 
  Comment( " MA_BBands_USDJPY_M5" );  
    int counted_bars=IndicatorCounted();    
    if(counted_bars<0) return(-1); 
    if(counted_bars>0) counted_bars--;
    int limit=Bars-counted_bars;   
    double OsMA_Now, OsMA_Pre; 
    
    for(int i=limit-1; i>=0; i--)    
     {           
           double MAUP1 = iMA(NULL,0,MAPeriod,-MoveShift,MODE_SMA,PRICE_HIGH,i); 
           double BB_UP = iBands(NULL,0,BPeriod,Std,0,PRICE_HIGH,MODE_UPPER,i);
           double MA_HIGH = iMA(NULL,0,4,0,MODE_LWMA,PRICE_HIGH,i);  
           
           double MADN1 = iMA(NULL,0,MAPeriod,-MoveShift,MODE_SMA,PRICE_LOW,i); 
           double BB_DN = iBands(NULL,0,BPeriod,Std,0,PRICE_LOW ,MODE_LOWER,i);
           double MA_LOW = iMA(NULL,0,4,0,MODE_LWMA,PRICE_LOW,i);  
           
       
          if (MAUP1>BB_UP) {ExtMapBuffer1[i]=MAUP1+Dist2*Point; BB_UP=EMPTY_VALUE ;}     
          else if (MAUP1<BB_UP) {ExtMapBuffer1[i]=BB_UP ; MAUP1=EMPTY_VALUE ;}
//--------------------------------------------------------------------             
           
                      
            
         if( MADN1 >0.0 ) 
         {
          if ( MADN1<BB_DN)  {ExtMapBuffer2[i]=MADN1-Dist2*Point; BB_DN=EMPTY_VALUE ;}                        
          else if (MADN1>BB_DN) { ExtMapBuffer2[i]=BB_DN ; MADN1=EMPTY_VALUE ; }
         }
       
         if (MADN1 ==0.0 ) { ExtMapBuffer2[i]=BB_DN; MADN1=EMPTY_VALUE ;}          
//------------------------------------------------------------       
       OsMA_Now = iOsMA(NULL,0,5,9,OsMA,PRICE_CLOSE,i) ;
       OsMA_Pre = iOsMA(NULL,0,5,9,OsMA,PRICE_CLOSE,i+1) ;

//-------------------
        if((OsMA_Now>0 && OsMA_Pre<0)&&(MA_LOW < ExtMapBuffer2[i]) && (Low[i] < ExtMapBuffer2[i]) ) 
       {
        ExtMapBuffer3[i+1] = Low[i]-30*Point;
       }
              
       if((OsMA_Now<0 && OsMA_Pre>0) && (MA_HIGH > ExtMapBuffer1[i]) && (High[i] > ExtMapBuffer1[i]) ) 
       {
        ExtMapBuffer4[i+1] = High[i]+30*Point;
       }  
       
       
       ExtMapBuffer5[i] = (ExtMapBuffer1[i] +ExtMapBuffer2[i])/2.0 ;
        
     } 
     
   return(0);
   RefreshRates(); 
   
  } 
//--------------------------------

