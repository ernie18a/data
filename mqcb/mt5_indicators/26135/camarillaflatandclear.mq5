//+------------------------------------------------------------------+
//|                                        CamarillaFlatandClear.mq5 |
//|                                                     Erdem Bozyel |
//|                                      mailto:bozyel67@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Erdem Bozyel"
#property link      "mailto:bozyel67@hotmail.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
//+--------------------------------------+
//| Camarilla Hesaplama                  |
//+--------------------------------------+
   double YuksekGun=iHigh(NULL,PERIOD_D1,1);    double DusukGun=iLow(NULL,PERIOD_D1,1);
   double KapanisGun=iClose(NULL,PERIOD_D1,1);  
   
   double PivotGun=(YuksekGun+DusukGun+KapanisGun)/3;
   double H5 = (YuksekGun/DusukGun)*KapanisGun;
   double H4 = (1.1*(YuksekGun-DusukGun)/2)+KapanisGun; 
   double H3 = (1.1*(YuksekGun-DusukGun)/4)+KapanisGun;
   double H2 = (1.1*(YuksekGun-DusukGun)/6)+KapanisGun;
   double H1 = (1.1*(YuksekGun-DusukGun)/12)+KapanisGun; 
   double L1 = KapanisGun-(1.1*(YuksekGun-DusukGun)/12);
   double L2 = KapanisGun-(1.1*(YuksekGun-DusukGun)/6);
   double L3 = KapanisGun-(1.1*(YuksekGun-DusukGun)/4);
   double L4 = KapanisGun-(1.1*(YuksekGun-DusukGun)/2);
   double L5 = KapanisGun-(H5-KapanisGun);
//+--------------------------------------+
//| Günlük Ana Çizgileri Oluştur         |
//+--------------------------------------+
   ObjectDelete(0,"H5");                                    ObjectCreate(0,"H5",OBJ_HLINE,0,0,H5);
   ObjectSetInteger(0,"H5",OBJPROP_COLOR,clrGreen);         ObjectSetInteger(0,"H5",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"H5",OBJPROP_WIDTH,2);                ObjectSetInteger(0,"H5",OBJPROP_BACK,false);
   ObjectSetString(0,"H5",OBJPROP_TEXT,"H5 LB Target");     ObjectSetDouble(0,"H5",OBJPROP_PRICE,H5);
   
   ObjectDelete(0,"H4");                                    ObjectCreate(0,"H4",OBJ_HLINE,0,0,H4);
   ObjectSetInteger(0,"H4",OBJPROP_COLOR,clrGreen);         ObjectSetInteger(0,"H4",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"H4",OBJPROP_WIDTH,2);                ObjectSetInteger(0,"H4",OBJPROP_BACK,false);
   ObjectSetString(0,"H4",OBJPROP_TEXT,"H4 Long BreakOut"); ObjectSetDouble(0,"H4",OBJPROP_PRICE,H4);
   
   ObjectDelete(0,"H3");                                    ObjectCreate(0,"H3",OBJ_HLINE,0,0,H3);
   ObjectSetInteger(0,"H3",OBJPROP_COLOR,clrRed);           ObjectSetInteger(0,"H3",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"H3",OBJPROP_WIDTH,1);                ObjectSetInteger(0,"H3",OBJPROP_BACK,false);
   ObjectSetString(0,"H3",OBJPROP_TEXT,"H3 Short");         ObjectSetDouble(0,"H3",OBJPROP_PRICE,H3);
   
   ObjectDelete(0,"PivotGun");                              ObjectCreate(0,"PivotGun",OBJ_HLINE,0,0,PivotGun);
   ObjectSetInteger(0,"PivotGun",OBJPROP_COLOR,clrMaroon);  ObjectSetInteger(0,"PivotGun",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"PivotGun",OBJPROP_WIDTH,1);          ObjectSetInteger(0,"PivotGun",OBJPROP_BACK,false);
   ObjectSetString(0,"PivotGun",OBJPROP_TEXT,"Pivot");      ObjectSetDouble(0,"PivotGun",OBJPROP_PRICE,PivotGun);
   
   ObjectDelete(0,"L3");                                    ObjectCreate(0,"L3",OBJ_HLINE,0,0,L3);
   ObjectSetInteger(0,"L3",OBJPROP_COLOR,clrGreen);         ObjectSetInteger(0,"L3",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"L3",OBJPROP_WIDTH,1);                ObjectSetInteger(0,"L3",OBJPROP_BACK,false);
   ObjectSetString(0,"L3",OBJPROP_TEXT,"L3 Long");          ObjectSetDouble(0,"L3",OBJPROP_PRICE,L3);
   
   ObjectDelete(0,"L4");                                    ObjectCreate(0,"L4",OBJ_HLINE,0,0,L4);
   ObjectSetInteger(0,"L4",OBJPROP_COLOR,clrRed);           ObjectSetInteger(0,"L4",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"L4",OBJPROP_WIDTH,2);                ObjectSetInteger(0,"L4",OBJPROP_BACK,false);
   ObjectSetString(0,"L4",OBJPROP_TEXT,"L4 Short BreakOut");ObjectSetDouble(0,"L4",OBJPROP_PRICE,L4);
   
   ObjectDelete(0,"L5");                                    ObjectCreate(0,"L5",OBJ_HLINE,0,0,L5);
   ObjectSetInteger(0,"L5",OBJPROP_COLOR,clrRed);           ObjectSetInteger(0,"L5",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"L5",OBJPROP_WIDTH,2);                ObjectSetInteger(0,"L5",OBJPROP_BACK,false);
   ObjectSetString(0,"L5",OBJPROP_TEXT,"L5 SB Target");     ObjectSetDouble(0,"L5",OBJPROP_PRICE,L5);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
