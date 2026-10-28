//+------------------------------------------------------------------+
//|                                        CamarillaFlatandClear.mq4 |
//|                                                     Erdem Bozyel |
//|                                      mailto:bozyel67@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Erdem Bozyel"
#property link      "mailto:bozyel67@hotmail.com"
#property version   "19.07"
#property strict
#property indicator_chart_window

extern color DestekRenk = Red;
extern color DirencRenk = Green;
extern color PivotRenk = Maroon;

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
   
   double PivotGun=NormalizeDouble((YuksekGun+DusukGun+KapanisGun)/3,Digits);
   double H5 = NormalizeDouble((YuksekGun/DusukGun)*KapanisGun,Digits);
   double H4 = NormalizeDouble((1.1*(YuksekGun-DusukGun)/2)+KapanisGun,Digits); 
   double H3 = NormalizeDouble((1.1*(YuksekGun-DusukGun)/4)+KapanisGun,Digits);
   double H2 = NormalizeDouble((1.1*(YuksekGun-DusukGun)/6)+KapanisGun,Digits);
   double H1 = NormalizeDouble((1.1*(YuksekGun-DusukGun)/12)+KapanisGun,Digits); 
   double L1 = NormalizeDouble(KapanisGun-(1.1*(YuksekGun-DusukGun)/12),Digits);
   double L2 = NormalizeDouble(KapanisGun-(1.1*(YuksekGun-DusukGun)/6),Digits);
   double L3 = NormalizeDouble(KapanisGun-(1.1*(YuksekGun-DusukGun)/4),Digits);
   double L4 = NormalizeDouble(KapanisGun-(1.1*(YuksekGun-DusukGun)/2),Digits);
   double L5 = NormalizeDouble(KapanisGun-(H5-KapanisGun),Digits);
//+--------------------------------------+
//| Günlük Ana Çizgileri Oluştur         |
//+--------------------------------------+
   ObjectDelete("H5");                        ObjectCreate("H5",OBJ_HLINE,0,0,H5);
   ObjectSet("H5",OBJPROP_COLOR,DirencRenk);  ObjectSet("H5",OBJPROP_WIDTH,2);
   ObjectSet("H5",OBJPROP_STYLE,0);           ObjectSet("H5",OBJPROP_RAY,false);
   ObjectSetText("H5","H5 LB Target",0,"",DirencRenk);
   
   ObjectDelete("H4");                        ObjectCreate("H4",OBJ_HLINE,0,0,H4);
   ObjectSet("H4",OBJPROP_COLOR,DirencRenk);  ObjectSet("H4",OBJPROP_WIDTH,2);
   ObjectSet("H4",OBJPROP_STYLE,0);           ObjectSet("H4",OBJPROP_RAY,false);
   ObjectSetText("H4","H4 Long BreakOut",0,"",DirencRenk);

   ObjectDelete("H3");                        ObjectCreate("H3",OBJ_HLINE,0,0,H3);
   ObjectSet("H3",OBJPROP_COLOR,DestekRenk);  ObjectSet("H3",OBJPROP_WIDTH,1);
   ObjectSet("H3",OBJPROP_STYLE,2);           ObjectSet("H3",OBJPROP_RAY,false);
   ObjectSetText("H3","H3 Short",0,"",DestekRenk);
   
   ObjectDelete("PivotGun");                          ObjectCreate("PivotGun",OBJ_HLINE,0,0,PivotGun);
   ObjectSet("PivotGun",OBJPROP_COLOR,PivotRenk);     ObjectSet("PivotGun",OBJPROP_WIDTH,1);
   ObjectSet("PivotGun",OBJPROP_STYLE,2);             ObjectSet("PivotGun",OBJPROP_RAY,false);
   ObjectSetText("PivotGun","Pivot",0,"",PivotRenk);

   ObjectDelete("L3");                        ObjectCreate("L3",OBJ_HLINE,0,0,L3);
   ObjectSet("L3",OBJPROP_COLOR,DirencRenk);  ObjectSet("L3",OBJPROP_WIDTH,1);
   ObjectSet("L3",OBJPROP_STYLE,2);           ObjectSet("L3",OBJPROP_RAY,false);
   ObjectSetText("L3","L3 Long",0,"",DirencRenk);
   
   ObjectDelete("L4");                        ObjectCreate("L4",OBJ_HLINE,0,0,L4);
   ObjectSet("L4",OBJPROP_COLOR,DestekRenk);  ObjectSet("L4",OBJPROP_WIDTH,2);
   ObjectSet("L4",OBJPROP_STYLE,0);           ObjectSet("L4",OBJPROP_RAY,false);
   ObjectSetText("L4","L4 Short BreakOut",0,"",DestekRenk);
   
   ObjectDelete("L5");                        ObjectCreate("L5",OBJ_HLINE,0,0,L5);
   ObjectSet("L5",OBJPROP_COLOR,DestekRenk);  ObjectSet("L5",OBJPROP_WIDTH,2);
   ObjectSet("L5",OBJPROP_STYLE,0);           ObjectSet("L5",OBJPROP_RAY,false);
   ObjectSetText("L5","L5 SB Target",0,"",DestekRenk);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
