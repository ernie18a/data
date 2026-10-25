//+------------------------------------------------------------------+
//|                                              Спред_Стоплевел.mq4 |
//|                                                     Tokman Yuriy |
//|     5 января 2009 года                     yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window

extern bool Play = true;

extern color color1 = Red;
extern color color2 = Lime;

int SPREAD_prev;
int STOPLEVEL_prev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate("sigl",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("sigl2",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("sig2",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("sig22",OBJ_LABEL,0,0,0,0,0);   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete ("sigl");
   ObjectDelete ("sigl2");
   ObjectDelete ("sig2");
   ObjectDelete ("sig22");   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    double SPREAD=MarketInfo( Symbol(), MODE_SPREAD),d;
    int STOPLEVEL=MarketInfo( Symbol(), MODE_STOPLEVEL),d2;

    d=SPREAD-SPREAD_prev;
    d2=STOPLEVEL-STOPLEVEL_prev;
//////////////////////////////////////спред////////////////////////   
    string name= "СПРЕД: ";
    string par = DoubleToStr(SPREAD,2);
    
    if     (d!=0)  
    {
     ObjectSetText("sigl",name,12,"Arial Black",color1);
     ObjectSetText("sigl2",par,12,"Arial Black",color1);
     if ( Play == true)Alert("Символ: ",Symbol(),";"," Спред изменили: ",SPREAD);

    }
    else if(d==0)  
    {
     ObjectSetText("sigl",name,12,"Arial Black",color2);
     ObjectSetText("sigl2",par,12,"Arial Black",color2);
    }
    
   ObjectSet("sigl",OBJPROP_XDISTANCE,3);
   ObjectSet("sigl2",OBJPROP_XDISTANCE,85);
 
   ObjectSet("sigl",OBJPROP_YDISTANCE,30);
   ObjectSet("sigl2",OBJPROP_YDISTANCE,30);
   
   SPREAD_prev=SPREAD;
//////////////////////////////////////////////////////////////////
///////////////////стоплевел/////////////////////////////////////
    string name2= "СТОПЛЕВЕЛ: ";
    string par2 = DoubleToStr(STOPLEVEL,0);
    
    if     (d2!=0)  
    {
     ObjectSetText("sig2",name2,12,"Arial Black",color1);
     ObjectSetText("sig22",par2,12,"Arial Black",color1);
     if ( Play == true)Alert("Символ: ",Symbol(),";"," Стоплевел изменили: ",STOPLEVEL);
    }
    else if(d2==0)  
    {
     ObjectSetText("sig2",name2,12,"Arial Black",color2);
     ObjectSetText("sig22",par2,12,"Arial Black",color2);
    }
    
   ObjectSet("sig2",OBJPROP_XDISTANCE,3);
   ObjectSet("sig22",OBJPROP_XDISTANCE,125);
 
   ObjectSet("sig2",OBJPROP_YDISTANCE,50);
   ObjectSet("sig22",OBJPROP_YDISTANCE,50);
   
   STOPLEVEL_prev=STOPLEVEL;
//////////////////////////////////////////////////////////////////                  
//----
   return(0);
  }
//+------------------------------------------------------------------+