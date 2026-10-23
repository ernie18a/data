//+------------------------------------------------------------------+
//|                                                 JS.Levels.V2.mq4 |
//|     Trading systems developer, contact js_sergey@list.ru  © 2009 |
//+------------------------------------------------------------------+
 
#property copyright " js_sergey@list.ru "
#property link      " http://multiexperts.ru/ "
 
#property indicator_chart_window
 
extern int    Months = 120;
extern color  color1_High  = RoyalBlue;
extern color  color1_Low   = Crimson;
extern int    style1  = 0;
extern int    width = 1;
extern bool   ray    = True;
 
 
string lineLow[300];
string lineHigh[300];
double dLow[300];
double dHigh[300];
double dTime[300];
//+------------------------------------------------------------------+
int start()
  {
//----
 
    for (int i=0; i<Months; i++) {
   
    dLow[i] = iLow(Symbol(),43200,i);
    dHigh[i] = iHigh(Symbol(),43200,i);
    dTime[i] = iTime(Symbol(),43200,i);
    
    datetime Ts = Time[0]+Period()*40*(WindowBarsPerChart());
    int YY=TimeYear(dTime[i]);   
    int MN=TimeMonth(dTime[i]);
  
    lineLow[i] = "Level.Low Date "+MN+" . "+YY;
    lineHigh[i]= "Level.High Date "+MN+" . "+YY;
    
    if(ObjectFind(lineLow[i])!=0)
    ObjectDelete(lineLow[i]);
    if(ObjectFind(lineLow[i])<0){
    ObjectCreate(lineLow[i], OBJ_TREND, 0, Ts, dLow[i], Time[10],dLow[i]);
    ObjectSet(lineLow[i], OBJPROP_STYLE, style1);
    ObjectSet(lineLow[i], OBJPROP_WIDTH, width); 
    ObjectSet(lineLow[i], OBJPROP_COLOR, color1_Low);
    ObjectSet(lineLow[i], OBJPROP_BACK,  true);
    ObjectSet(lineLow[i], OBJPROP_RAY,   ray); // ray
    ObjectSetText(lineLow[i],"",10);
   } else {
      ObjectMove(lineLow[i], 1, Time[10],dLow[i]);
      ObjectMove(lineLow[i], 0, Ts,dLow[i]);
      ObjectSetText(lineLow[i],"",10);
   }
   
   
    if(ObjectFind(lineHigh[i])!=0)
    ObjectDelete(lineHigh[i]);
    if(ObjectFind(lineHigh[i])<0){
    ObjectCreate(lineHigh[i], OBJ_TREND, 0, Ts, dHigh[i], Time[10],dHigh[i]);
    ObjectSet(lineHigh[i], OBJPROP_STYLE, style1);
    ObjectSet(lineHigh[i], OBJPROP_WIDTH, width); 
    ObjectSet(lineHigh[i], OBJPROP_COLOR, color1_High);
    ObjectSet(lineHigh[i], OBJPROP_BACK,  true);
    ObjectSet(lineHigh[i], OBJPROP_RAY,   ray); // ray
    ObjectSetText(lineHigh[i],"",10);  
   } else {
      ObjectMove(lineHigh[i], 1,Time[10],dHigh[i]);
      ObjectMove(lineHigh[i], 0,Ts,dHigh[i]);
      ObjectSetText(lineHigh[i],"",10);
   }
 }
//----
   return(0);
}
//+------------------------------------------------------------------+
int deinit()
  {
  //----
    for (int i=0; i<Months; i++) {
    dTime[i] = iTime(Symbol(),43200,i);
    int YY=TimeYear(dTime[i]);
    int MN=TimeMonth(dTime[i]);
    lineLow[i] = "Level.Low Date "+MN+" . "+YY;
    lineHigh[i]= "Level.High Date"+MN+" . "+YY;
   
    ObjectDelete(lineLow[i]);
    ObjectDelete(lineHigh[i]);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+