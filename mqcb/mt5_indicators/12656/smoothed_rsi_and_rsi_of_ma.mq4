//+------------------------------------------------------------------+
//|                                               RSI_MA_Devries.mq4 |
//|                                              By GGG Macon France |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "NONE "
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict


#property indicator_separate_window
#property indicator_buffers 6
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_color1 White   //RSI color
#property indicator_color2 HotPink
#property indicator_color3 LightBlue   //RSI color
#property indicator_color4 LimeGreen
#property indicator_color5 HotPink   //RSI color
#property indicator_color6 PaleGreen

//--- input parameters
extern bool choose_Smoothed_RSI = true;
extern bool show_both = true;

extern int RSI_Period    = 13;    //8-25
extern int RSI_Price     =  0;     
extern int RSI_Smooth     = 7; 
extern int RSI_MA_Type    = 0;

extern int MA_Per = 7;
extern int MA_Meth = 0;
extern int MA_Prix = 0;
extern int MA_rsi_of_ma = 13;
extern int MA_smoothed_rsi_of_ma = 1; 

       // 0 SMA , 1 EMA , 2 SMMA , 3 LWMA
//--- buffers
double RSI[];
double Smoothed_RSI[];
double RSI_Of_MA[];
double Smoothed_RSI_Of_MA[];
double MA[];


int init()
{
IndicatorShortName("MA of the RSI");
IndicatorBuffers(5);
//---- drawing settings  RSI  (0,......)
SetIndexBuffer(0,RSI);
SetIndexLabel(0,"RSI");                    //SetIndexLabel(0,NULL); wrong
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);  //SetIndexStyle(0,DRAW_NONE);wrong this is draw nothing

//---- drawing settings of Moving Average on RSI
SetIndexBuffer(1,Smoothed_RSI);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);                       //SetIndexStyle(1,DRAW_LINE);


//---- drawing settings of Moving Average on RSI
SetIndexBuffer(2,RSI_Of_MA);
SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);                       //SetIndexStyle(1,DRAW_LINE);

SetIndexBuffer(3,Smoothed_RSI_Of_MA);
SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);                       //SetIndexStyle(1,DRAW_LINE);

SetIndexBuffer(4,MA);
SetIndexLabel(4,"MA");                    //SetIndexLabel(0,NULL); wrong
SetIndexStyle(4,DRAW_NONE);  //SetIndexStyle(0,DRAW_NONE);wrong this is draw nothing

SetLevelValue(0,50);
SetLevelValue(1,68);
SetLevelValue(2,32);
SetLevelStyle(STYLE_DASHDOT,1,Yellow);

return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int start()
{
int counted_bars=IndicatorCounted();
int limit = Bars-counted_bars-1;
 if( choose_Smoothed_RSI == true || show_both == true  )
    {
    for(int i=limit; i>=0; i--) RSI[i]          = iRSI(NULL,0,RSI_Period,RSI_Price,i); 
    for(int i=limit; i>=0; i--) Smoothed_RSI[i] = iMAOnArray(RSI,0,RSI_Smooth,0,RSI_MA_Type,i);
    }
 if( choose_Smoothed_RSI == false || show_both == true  )
    {  
    for(int i=limit; i>=0; i--) MA[i]           = iMA(NULL,0,MA_Per,0,MA_Meth, MA_Prix,i );
    for(int i=limit; i>=0; i--) RSI_Of_MA[i]    = iRSIOnArray(MA,0,MA_rsi_of_ma,i);
    for(int i=limit; i>=0; i--) Smoothed_RSI_Of_MA[i] = iMAOnArray(RSI_Of_MA,0,MA_smoothed_rsi_of_ma,0,RSI_MA_Type,i);
    }
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
return(0);
}
//+------------------------------------------------------------------+
