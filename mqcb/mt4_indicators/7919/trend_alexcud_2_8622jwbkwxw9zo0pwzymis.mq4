//+------------------------------------------------------------------+
//|                                                TREND_alexcud.mq4 |
//|                             Copyright © 2007, Aleksander Kudimov |
//|                                               alexcud@rambler.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Aleksander Kudimov"
#property link      "alexcud@rambler.ru"

#property indicator_separate_window

#property indicator_minimum 0
#property indicator_maximum 1

#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

//---- buffers
double UPBuffer[];
double DOWNBuffer[];

extern int maTrendPeriod_1 = 5;
extern int maTrendPeriod_2 = 8;
extern int maTrendPeriod_3 = 13;
extern int maTrendPeriod_4 = 21;
extern int maTrendPeriod_5 = 34;

int m,m1,m2,m3,m4,m5,m6, n,n1,n2,n3,n4,n5,n6;
datetime dt, p,p1,p2,p3,p4,p5,p6, g,g1,g2,g3,g4,g5,g6;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double MaH11,  MaH41, MaD11, MaH1pr1, MaH4pr1, MaD1pr1;
double MaH12,  MaH42, MaD12, MaH1pr2, MaH4pr2, MaD1pr2;
double MaH13,  MaH43, MaD13, MaH1pr3, MaH4pr3, MaD1pr3;
double MaH14,  MaH44, MaD14, MaH1pr4, MaH4pr4, MaD1pr4;
double MaH15,  MaH45, MaD15, MaH1pr5, MaH4pr5, MaD1pr5;
 string H11, H41, D11;
 string H12, H42, D12;
 string H13, H43, D13;
 string H14, H44, D14;
 string H15, H45, D15;
 color co11 , co41 , co61;
 color co12 , co42 , co62;
 color co13 , co43 , co63;
 color co14 , co44 , co64;
 color co15 , co45 , co65;
 
double u1x5, u1x8, u1x13, u1x21, u1x34;
double u2x5, u2x8, u2x13, u2x21, u2x34;
double u3x5, u3x8, u3x13, u3x21, u3x34;
double u1ac, u2ac, u3ac;

double d1x5, d1x8, d1x13, d1x21, d1x34;
double d2x5, d2x8, d2x13, d2x21, d2x34;
double d3x5, d3x8, d3x13, d3x21, d3x34;
double d1ac, d2ac, d3ac;

 string short_name="TREND_alexcud";   
int init()
  {

//---- name for indicator window

   string short_name="TREND_alexcud";
   IndicatorShortName(short_name);

   SetIndexBuffer(0,UPBuffer);
   SetIndexBuffer(1,DOWNBuffer);

  if(!GlobalVariableCheck("Signal_EURUSD")) {GlobalVariableSet("Signal_EURUSD",0);}
  if(!GlobalVariableCheck("Signal_USDCHF")) {GlobalVariableSet("Signal_USDCHF",0);}
  if(!GlobalVariableCheck("Signal_USDJPY")) {GlobalVariableSet("Signal_USDJPY",0);}
  if(!GlobalVariableCheck("Signal_GBPUSD")) {GlobalVariableSet("Signal_GBPUSD",0);}
  if(!GlobalVariableCheck("Signal_EURJPY")) {GlobalVariableSet("Signal_EURJPY",0);}
  if(!GlobalVariableCheck("Signal_GBPJPY")) {GlobalVariableSet("Signal_GBPJPY",0);}
  if(!GlobalVariableCheck("Signal_AUDUSD")) {GlobalVariableSet("Signal_AUDUSD",0);}
  
  if(!GlobalVariableCheck("Signal_EURUSD2")) {GlobalVariableSet("Signal_EURUSD2",0);}
  if(!GlobalVariableCheck("Signal_USDCHF2")) {GlobalVariableSet("Signal_USDCHF2",0);}
  if(!GlobalVariableCheck("Signal_USDJPY2")) {GlobalVariableSet("Signal_USDJPY2",0);}
  if(!GlobalVariableCheck("Signal_GBPUSD2")) {GlobalVariableSet("Signal_GBPUSD2",0);}
  if(!GlobalVariableCheck("Signal_EURJPY2")) {GlobalVariableSet("Signal_EURJPY2",0);}
  if(!GlobalVariableCheck("Signal_GBPJPY2")) {GlobalVariableSet("Signal_GBPJPY2",0);}
  if(!GlobalVariableCheck("Signal_AUDUSD2")) {GlobalVariableSet("Signal_AUDUSD2",0);}
   
  if(!GlobalVariableCheck("Signal_EURUSDtxt")) {GlobalVariableSet("Signal_EURUSDtxt",0.0000);}
  if(!GlobalVariableCheck("Signal_USDCHFtxt")) {GlobalVariableSet("Signal_USDCHFtxt",0.0000);}
  if(!GlobalVariableCheck("Signal_USDJPYtxt")) {GlobalVariableSet("Signal_USDJPYtxt",0.0000);}
  if(!GlobalVariableCheck("Signal_GBPUSDtxt")) {GlobalVariableSet("Signal_GBPUSDtxt",0.0000);}
  if(!GlobalVariableCheck("Signal_EURJPYtxt")) {GlobalVariableSet("Signal_EURJPYtxt",0.0000);}
  if(!GlobalVariableCheck("Signal_GBPJPYtxt")) {GlobalVariableSet("Signal_GBPJPYtxt",0.0000);}
  if(!GlobalVariableCheck("Signal_AUDUSDtxt")) {GlobalVariableSet("Signal_AUDUSDtxt",0.0000);}
 
  if(!GlobalVariableCheck("Signal_EURUSDtxt")) {GlobalVariableSet("Signal_EURUSDtxt2",0.0000);}
  if(!GlobalVariableCheck("Signal_USDCHFtxt")) {GlobalVariableSet("Signal_USDCHFtxt2",0.0000);}
  if(!GlobalVariableCheck("Signal_USDJPYtxt")) {GlobalVariableSet("Signal_USDJPYtxt2",0.0000);}
  if(!GlobalVariableCheck("Signal_GBPUSDtxt")) {GlobalVariableSet("Signal_GBPUSDtxt2",0.0000);}
  if(!GlobalVariableCheck("Signal_EURJPYtxt")) {GlobalVariableSet("Signal_EURJPYtxt2",0.0000);}
  if(!GlobalVariableCheck("Signal_GBPJPYtxt")) {GlobalVariableSet("Signal_GBPJPYtxt2",0.0000);}
  if(!GlobalVariableCheck("Signal_AUDUSDtxt")) {GlobalVariableSet("Signal_AUDUSDtxt2",0.0000);}

  if(!GlobalVariableCheck("Signal_EURUSDschet")) {GlobalVariableSet("Signal_EURUSDschet",0);}
  if(!GlobalVariableCheck("Signal_USDCHFschet")) {GlobalVariableSet("Signal_USDCHFschet",0);}
  if(!GlobalVariableCheck("Signal_USDJPYschet")) {GlobalVariableSet("Signal_USDJPYschet",0);}
  if(!GlobalVariableCheck("Signal_GBPUSDschet")) {GlobalVariableSet("Signal_GBPUSDschet",0);}
  if(!GlobalVariableCheck("Signal_EURJPYschet")) {GlobalVariableSet("Signal_EURJPYschet",0);}
  if(!GlobalVariableCheck("Signal_GBPJPYschet")) {GlobalVariableSet("Signal_GBPJPYschet",0);}
  if(!GlobalVariableCheck("Signal_AUDUSDschet")) {GlobalVariableSet("Signal_AUDUSDschet",0);}

  if(!GlobalVariableCheck("Signal_EURUSDschet2")) {GlobalVariableSet("Signal_EURUSDschet2",0);}
  if(!GlobalVariableCheck("Signal_USDCHFschet2")) {GlobalVariableSet("Signal_USDCHFschet2",0);}
  if(!GlobalVariableCheck("Signal_USDJPYschet2")) {GlobalVariableSet("Signal_USDJPYschet2",0);}
  if(!GlobalVariableCheck("Signal_GBPUSDschet2")) {GlobalVariableSet("Signal_GBPUSDschet2",0);}
  if(!GlobalVariableCheck("Signal_EURJPYschet2")) {GlobalVariableSet("Signal_EURJPYschet2",0);}
  if(!GlobalVariableCheck("Signal_GBPJPYschet2")) {GlobalVariableSet("Signal_GBPJPYschet2",0);}
  if(!GlobalVariableCheck("Signal_AUDUSDschet2")) {GlobalVariableSet("Signal_AUDUSDschet2",0);}

//----
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
datetime dt=CurTime();

p1=GlobalVariableGet("Signal_EURUSDschet");
p2=GlobalVariableGet("Signal_USDCHFschet"); 
p3=GlobalVariableGet("Signal_USDJPYschet"); 
 p=GlobalVariableGet("Signal_GBPUSDschet");
p4=GlobalVariableGet("Signal_EURJPYschet"); 
p5=GlobalVariableGet("Signal_GBPJPYschet"); 
p6=GlobalVariableGet("Signal_AUDUSDschet");

g1=GlobalVariableGet("Signal_EURUSDschet2");
g2=GlobalVariableGet("Signal_USDCHFschet2"); 
g3=GlobalVariableGet("Signal_USDJPYschet2"); 
 g=GlobalVariableGet("Signal_GBPUSDschet2");
g4=GlobalVariableGet("Signal_EURJPYschet2"); 
g5=GlobalVariableGet("Signal_GBPJPYschet2"); 
g6=GlobalVariableGet("Signal_AUDUSDschet2");
  
m1=GlobalVariableGet("Signal_EURUSD"); //if(m1>0){m1--;  GlobalVariableSet("Signal_EURUSD",m1);} if(m1<0){m1++;  GlobalVariableSet("Signal_EURUSD",m1);}
m2=GlobalVariableGet("Signal_USDCHF"); //if(m2>0){m2--;  GlobalVariableSet("Signal_USDCHF",m2);} if(m2<0){m2++;  GlobalVariableSet("Signal_USDCHF",m2);}
m3=GlobalVariableGet("Signal_USDJPY"); //if(m3>0){m3--;  GlobalVariableSet("Signal_USDJPY",m3);} if(m3<0){m3++;  GlobalVariableSet("Signal_USDJPY",m3);}
m=GlobalVariableGet("Signal_GBPUSD"); //if(m>0) {m--;   GlobalVariableSet("Signal_GBPUSD",m );} if(m<0) {m++;   GlobalVariableSet("Signal_GBPUSD",m );}
m4=GlobalVariableGet("Signal_EURJPY"); //if(m4>0){m4--;  GlobalVariableSet("Signal_EURJPY",m4);} if(m4<0){m4++;  GlobalVariableSet("Signal_EURJPY",m4);}
m5=GlobalVariableGet("Signal_GBPJPY"); //if(m5>0){m5--;  GlobalVariableSet("Signal_GBPJPY",m5);} if(m5<0){m5++;  GlobalVariableSet("Signal_GBPJPY",m5);}
m6=GlobalVariableGet("Signal_AUDUSD"); //if(m6>0){m6--;  GlobalVariableSet("Signal_AUDUSD",m6);} if(m6<0){m6++;  GlobalVariableSet("Signal_AUDUSD",m6);}

if(Symbol()=="EURUSD"){n1=GlobalVariableGet("Signal_EURUSD2"); if(n1>0){n1--;  GlobalVariableSet("Signal_EURUSD2",n1);} if(n1<0){n1++;  GlobalVariableSet("Signal_EURUSD2",n1);}}
if(Symbol()=="USDCHF"){n2=GlobalVariableGet("Signal_USDCHF2"); if(n2>0){n2--;  GlobalVariableSet("Signal_USDCHF2",n2);} if(n2<0){n2++;  GlobalVariableSet("Signal_USDCHF2",n2);}}
if(Symbol()=="USDJPY"){n3=GlobalVariableGet("Signal_USDJPY2"); if(n3>0){n3--;  GlobalVariableSet("Signal_USDJPY2",n3);} if(n3<0){n3++;  GlobalVariableSet("Signal_USDJPY2",n3);}}
if(Symbol()=="GBPUSD"){ n=GlobalVariableGet("Signal_GBPUSD2"); if(n>0) {n--;   GlobalVariableSet("Signal_GBPUSD2",n );} if(n<0) {n++;   GlobalVariableSet("Signal_GBPUSD2",n );}}
if(Symbol()=="EURJPY"){n4=GlobalVariableGet("Signal_EURJPY2"); if(n4>0){n4--;  GlobalVariableSet("Signal_EURJPY2",n4);} if(n4<0){n4++;  GlobalVariableSet("Signal_EURJPY2",n4);}}
if(Symbol()=="GBPJPY"){n5=GlobalVariableGet("Signal_GBPJPY2"); if(n5>0){n5--;  GlobalVariableSet("Signal_GBPJPY2",n5);} if(n5<0){n5++;  GlobalVariableSet("Signal_GBPJPY2",n5);}}
if(Symbol()=="AUDUSD"){n6=GlobalVariableGet("Signal_AUDUSD2"); if(n6>0){n6--;  GlobalVariableSet("Signal_AUDUSD2",n6);} if(n6<0){n6++;  GlobalVariableSet("Signal_AUDUSD2",n6);}}

if(m1==0){ObjectCreate("txtRU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRU","EURUSD",9,"Verdana",Silver);ObjectSet("txtRU",OBJPROP_XDISTANCE,390);ObjectSet("txtRU",OBJPROP_YDISTANCE,0);}
if(m2==0){ObjectCreate("txtDC",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDC","USDCHF",9,"Verdana",Silver);ObjectSet("txtDC",OBJPROP_XDISTANCE,390);ObjectSet("txtDC",OBJPROP_YDISTANCE,11);}
if(m3==0){ObjectCreate("txtDJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDJ","USDJPY",9,"Verdana",Silver);ObjectSet("txtDJ",OBJPROP_XDISTANCE,390);ObjectSet("txtDJ",OBJPROP_YDISTANCE,22);}
if(m==0) {ObjectCreate("txtPU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPU","GBPUSD",9,"Verdana",Silver);ObjectSet("txtPU",OBJPROP_XDISTANCE,390);ObjectSet("txtPU",OBJPROP_YDISTANCE,33);}
if(m4==0){ObjectCreate("txtRJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRJ","EURJPY",9,"Verdana",Silver);ObjectSet("txtRJ",OBJPROP_XDISTANCE,390);ObjectSet("txtRJ",OBJPROP_YDISTANCE,44);}
if(m5==0){ObjectCreate("txtPJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPJ","GBPJPY",9,"Verdana",Silver);ObjectSet("txtPJ",OBJPROP_XDISTANCE,390);ObjectSet("txtPJ",OBJPROP_YDISTANCE,55);}
if(m6==0){ObjectCreate("txtDU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDU","AUDUSD",9,"Verdana",Silver);ObjectSet("txtDU",OBJPROP_XDISTANCE,390);ObjectSet("txtDU",OBJPROP_YDISTANCE,66);}

if(m1<0){ObjectCreate("txtRU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRU","EURUSD \\/ ",9,"Verdana",Red);ObjectSet("txtRU",OBJPROP_XDISTANCE,390);ObjectSet("txtRU",OBJPROP_YDISTANCE,0);}
if(m2<0){ObjectCreate("txtDC",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDC","USDCHF \\/ ",9,"Verdana",Red);ObjectSet("txtDC",OBJPROP_XDISTANCE,390);ObjectSet("txtDC",OBJPROP_YDISTANCE,11);}
if(m3<0){ObjectCreate("txtDJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDJ","USDJPY  \\/ ",9,"Verdana",Red);ObjectSet("txtDJ",OBJPROP_XDISTANCE,390);ObjectSet("txtDJ",OBJPROP_YDISTANCE,22);}
if(m<0) {ObjectCreate("txtPU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPU","GBPUSD \\/ ",9,"Verdana",Red);ObjectSet("txtPU",OBJPROP_XDISTANCE,390);ObjectSet("txtPU",OBJPROP_YDISTANCE,33);}
if(m4<0){ObjectCreate("txtRJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRJ","EURJPY  \\/ ",9,"Verdana",Red);ObjectSet("txtRJ",OBJPROP_XDISTANCE,390);ObjectSet("txtRJ",OBJPROP_YDISTANCE,44);}
if(m5<0){ObjectCreate("txtPJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPJ","GBPJPY  \\/ ",9,"Verdana",Red);ObjectSet("txtPJ",OBJPROP_XDISTANCE,390);ObjectSet("txtPJ",OBJPROP_YDISTANCE,55);}
if(m6<0){ObjectCreate("txtDU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDU","AUDUSD \\/ ",9,"Verdana",Red);ObjectSet("txtDU",OBJPROP_XDISTANCE,390);ObjectSet("txtDU",OBJPROP_YDISTANCE,66);}      

if(m1>0){ObjectCreate("txtRU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRU","EURUSD /\\ ",9,"Verdana",DodgerBlue);ObjectSet("txtRU",OBJPROP_XDISTANCE,390);ObjectSet("txtRU",OBJPROP_YDISTANCE,0);}
if(m2>0){ObjectCreate("txtDC",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDC","USDCHF /\\ ",9,"Verdana",DodgerBlue);ObjectSet("txtDC",OBJPROP_XDISTANCE,390);ObjectSet("txtDC",OBJPROP_YDISTANCE,11);}
if(m3>0){ObjectCreate("txtDJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDJ","USDJPY  /\\ ",9,"Verdana",DodgerBlue);ObjectSet("txtDJ",OBJPROP_XDISTANCE,390);ObjectSet("txtDJ",OBJPROP_YDISTANCE,22);}
if(m>0) {ObjectCreate("txtPU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPU","GBPUSD /\\ ",9,"Verdana",DodgerBlue);ObjectSet("txtPU",OBJPROP_XDISTANCE,390);ObjectSet("txtPU",OBJPROP_YDISTANCE,33);}
if(m4>0){ObjectCreate("txtRJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRJ","EURJPY  /\\ ",9,"Verdana",DodgerBlue);ObjectSet("txtRJ",OBJPROP_XDISTANCE,390);ObjectSet("txtRJ",OBJPROP_YDISTANCE,44);}
if(m5>0){ObjectCreate("txtPJ",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPJ","GBPJPY  /\\ ",9,"Verdana",DodgerBlue);ObjectSet("txtPJ",OBJPROP_XDISTANCE,390);ObjectSet("txtPJ",OBJPROP_YDISTANCE,55);}
if(m6>0){ObjectCreate("txtDU",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDU","AUDUSD /\\ ",9,"Verdana",DodgerBlue);ObjectSet("txtDU",OBJPROP_XDISTANCE,390);ObjectSet("txtDU",OBJPROP_YDISTANCE,66);}
  
string txt1=DoubleToStr(GlobalVariableGet("Signal_EURUSDtxt"),4);ObjectCreate("txtRU1",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRU1",txt1,9,"Verdana",Silver);ObjectSet("txtRU1",OBJPROP_XDISTANCE,460);ObjectSet("txtRU1",OBJPROP_YDISTANCE,0 );//ObjectCreate("eurusd"+Day(),OBJ_RECTANGLE,0,p1,GlobalVariableGet("Signal_EURUSDtxt"),dt,GlobalVariableGet("Signal_EURUSDtxt2"));
string txt2=DoubleToStr(GlobalVariableGet("Signal_USDCHFtxt"),4);ObjectCreate("txtDC1",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDC1",txt2,9,"Verdana",Silver);ObjectSet("txtDC1",OBJPROP_XDISTANCE,460);ObjectSet("txtDC1",OBJPROP_YDISTANCE,11);//ObjectCreate("usdchf"+Day(),OBJ_RECTANGLE,0,p2,GlobalVariableGet("Signal_USDCHFtxt"),dt,GlobalVariableGet("Signal_USDCHFtxt2"));
string txt3=DoubleToStr(GlobalVariableGet("Signal_USDJPYtxt"),2);ObjectCreate("txtDJ1",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDJ1",txt3,9,"Verdana",Silver);ObjectSet("txtDJ1",OBJPROP_XDISTANCE,460);ObjectSet("txtDJ1",OBJPROP_YDISTANCE,22);//ObjectCreate("usdjpy"+Day(),OBJ_RECTANGLE,0,p3,GlobalVariableGet("Signal_USDJPYtxt"),dt,GlobalVariableGet("Signal_USDJPYtxt2"));
string txt4=DoubleToStr(GlobalVariableGet("Signal_GBPUSDtxt"),4);ObjectCreate("txtPU1",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPU1",txt4,9,"Verdana",Silver);ObjectSet("txtPU1",OBJPROP_XDISTANCE,460);ObjectSet("txtPU1",OBJPROP_YDISTANCE,33);//ObjectCreate("gbpusd"+Day(),OBJ_RECTANGLE,0,p ,GlobalVariableGet("Signal_GBPUSDtxt"),dt,GlobalVariableGet("Signal_GBPUSDtxt2"));
string txt5=DoubleToStr(GlobalVariableGet("Signal_EURJPYtxt"),2);ObjectCreate("txtRJ1",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRJ1",txt5,9,"Verdana",Silver);ObjectSet("txtRJ1",OBJPROP_XDISTANCE,460);ObjectSet("txtRJ1",OBJPROP_YDISTANCE,44);//ObjectCreate("eurjpy"+Day(),OBJ_RECTANGLE,0,p4,GlobalVariableGet("Signal_EURJPYtxt"),dt,GlobalVariableGet("Signal_EURJPYtxt2"));
string txt6=DoubleToStr(GlobalVariableGet("Signal_GBPJPYtxt"),2);ObjectCreate("txtPJ1",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPJ1",txt6,9,"Verdana",Silver);ObjectSet("txtPJ1",OBJPROP_XDISTANCE,460);ObjectSet("txtPJ1",OBJPROP_YDISTANCE,55);//ObjectCreate("gbpjpy"+Day(),OBJ_RECTANGLE,0,p5,GlobalVariableGet("Signal_GBPJPYtxt"),dt,GlobalVariableGet("Signal_GBPJPYtxt2"));
string txt7=DoubleToStr(GlobalVariableGet("Signal_AUDUSDtxt"),4);ObjectCreate("txtDU1",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDU1",txt7,9,"Verdana",Silver);ObjectSet("txtDU1",OBJPROP_XDISTANCE,460);ObjectSet("txtDU1",OBJPROP_YDISTANCE,66);//ObjectCreate("audusd"+Day(),OBJ_RECTANGLE,0,p6,GlobalVariableGet("Signal_AUDUSDtxt"),dt,GlobalVariableGet("Signal_AUDUSDtxt2"));

string txt10=DoubleToStr(GlobalVariableGet("Signal_EURUSDtxt2"),4);ObjectCreate("txtRU2",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRU2",txt10,9,"Verdana",Silver);ObjectSet("txtRU2",OBJPROP_XDISTANCE,510);ObjectSet("txtRU2",OBJPROP_YDISTANCE,0 );//ObjectSet("eurusd"+Day(),OBJPROP_TIME1,p1);ObjectSet("eurusd"+Day(),OBJPROP_PRICE1,GlobalVariableGet("Signal_EURUSDtxt"));ObjectSet("eurusd"+Day(),OBJPROP_TIME2,dt);ObjectSet("eurusd"+Day(),OBJPROP_PRICE2,GlobalVariableGet("Signal_EURUSDtxt2"));
string txt20=DoubleToStr(GlobalVariableGet("Signal_USDCHFtxt2"),4);ObjectCreate("txtDC2",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDC2",txt20,9,"Verdana",Silver);ObjectSet("txtDC2",OBJPROP_XDISTANCE,510);ObjectSet("txtDC2",OBJPROP_YDISTANCE,11);//ObjectSet("usdchf"+Day(),OBJPROP_TIME1,p2);ObjectSet("usdchf"+Day(),OBJPROP_PRICE1,GlobalVariableGet("Signal_USDCHFtxt"));ObjectSet("usdchf"+Day(),OBJPROP_TIME2,dt);ObjectSet("usdchf"+Day(),OBJPROP_PRICE2,GlobalVariableGet("Signal_USDCHFtxt2"));
string txt30=DoubleToStr(GlobalVariableGet("Signal_USDJPYtxt2"),2);ObjectCreate("txtDJ2",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDJ2",txt30,9,"Verdana",Silver);ObjectSet("txtDJ2",OBJPROP_XDISTANCE,510);ObjectSet("txtDJ2",OBJPROP_YDISTANCE,22);//ObjectSet("usdjpy"+Day(),OBJPROP_TIME1,p3);ObjectSet("usdjpy"+Day(),OBJPROP_PRICE1,GlobalVariableGet("Signal_USDJPYtxt"));ObjectSet("usdjpy"+Day(),OBJPROP_TIME2,dt);ObjectSet("usdjpy"+Day(),OBJPROP_PRICE2,GlobalVariableGet("Signal_USDJPYtxt2"));
string txt40=DoubleToStr(GlobalVariableGet("Signal_GBPUSDtxt2"),4);ObjectCreate("txtPU2",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPU2",txt40,9,"Verdana",Silver);ObjectSet("txtPU2",OBJPROP_XDISTANCE,510);ObjectSet("txtPU2",OBJPROP_YDISTANCE,33);//ObjectSet("gbpusd"+Day(),OBJPROP_TIME1,p );ObjectSet("gbpusd"+Day(),OBJPROP_PRICE1,GlobalVariableGet("Signal_GBPUSDtxt"));ObjectSet("gbpusd"+Day(),OBJPROP_TIME2,dt);ObjectSet("gbpusd"+Day(),OBJPROP_PRICE2,GlobalVariableGet("Signal_GBPUSDtxt2"));
string txt50=DoubleToStr(GlobalVariableGet("Signal_EURJPYtxt2"),2);ObjectCreate("txtRJ2",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtRJ2",txt50,9,"Verdana",Silver);ObjectSet("txtRJ2",OBJPROP_XDISTANCE,510);ObjectSet("txtRJ2",OBJPROP_YDISTANCE,44);//ObjectSet("eurjpy"+Day(),OBJPROP_TIME1,p4);ObjectSet("eurjpy"+Day(),OBJPROP_PRICE1,GlobalVariableGet("Signal_EURJPYtxt"));ObjectSet("eurjpy"+Day(),OBJPROP_TIME2,dt);ObjectSet("eurjpy"+Day(),OBJPROP_PRICE2,GlobalVariableGet("Signal_EURJPYtxt2"));
string txt60=DoubleToStr(GlobalVariableGet("Signal_GBPJPYtxt2"),2);ObjectCreate("txtPJ2",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtPJ2",txt60,9,"Verdana",Silver);ObjectSet("txtPJ2",OBJPROP_XDISTANCE,510);ObjectSet("txtPJ2",OBJPROP_YDISTANCE,55);//ObjectSet("gbpjpy"+Day(),OBJPROP_TIME1,p5);ObjectSet("gbpjpy"+Day(),OBJPROP_PRICE1,GlobalVariableGet("Signal_GBPJPYtxt"));ObjectSet("gbpjpy"+Day(),OBJPROP_TIME2,dt);ObjectSet("gbpjpy"+Day(),OBJPROP_PRICE2,GlobalVariableGet("Signal_GBPJPYtxt2"));
string txt70=DoubleToStr(GlobalVariableGet("Signal_AUDUSDtxt2"),4);ObjectCreate("txtDU2",OBJ_LABEL,WindowFind(short_name),0,0);ObjectSetText("txtDU2",txt70,9,"Verdana",Silver);ObjectSet("txtDU2",OBJPROP_XDISTANCE,510);ObjectSet("txtDU2",OBJPROP_YDISTANCE,66);//ObjectSet("audusd"+Day(),OBJPROP_TIME1,p6);ObjectSet("audusd"+Day(),OBJPROP_PRICE1,GlobalVariableGet("Signal_AUDUSDtxt"));ObjectSet("audusd"+Day(),OBJPROP_TIME2,dt);ObjectSet("audusd"+Day(),OBJPROP_PRICE2,GlobalVariableGet("Signal_AUDUSDtxt2"));

   ObjectCreate("MA", OBJ_LABEL, WindowFind(short_name), 0, 0);
   ObjectSetText("MA", "Moving Average",9, "Verdana", Lime );
   ObjectSet("MA", OBJPROP_XDISTANCE, 75);  
   ObjectSet("MA", OBJPROP_YDISTANCE, 0);
    
   ObjectCreate("label_object1", OBJ_LABEL, WindowFind(short_name), 0, 0);
   ObjectSet("label_object1", OBJPROP_XDISTANCE, 11);  
   ObjectSet("label_object1", OBJPROP_YDISTANCE, 15);
   
   ObjectCreate("label_object2", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("label_object2", OBJPROP_XDISTANCE, 11);  
   ObjectSet("label_object2", OBJPROP_YDISTANCE, 35);
   
   ObjectCreate("label_object3", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("label_object3", OBJPROP_XDISTANCE, 11);  
   ObjectSet("label_object3", OBJPROP_YDISTANCE, 55);
 // ----------------------------------------------------------------------------
   ObjectCreate("H11", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H11", OBJPROP_XDISTANCE, 40);  
   ObjectSet("H11", OBJPROP_YDISTANCE, 15);
   
   ObjectCreate("H12", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H12", OBJPROP_XDISTANCE, 70);  
   ObjectSet("H12", OBJPROP_YDISTANCE, 15);
   
   ObjectCreate("H13", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H13", OBJPROP_XDISTANCE, 100);  
   ObjectSet("H13", OBJPROP_YDISTANCE, 15); 
   
   ObjectCreate("H14", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H14", OBJPROP_XDISTANCE, 130);  
   ObjectSet("H14", OBJPROP_YDISTANCE, 15); 
   
   ObjectCreate("H15", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H15", OBJPROP_XDISTANCE, 160);  
   ObjectSet("H15", OBJPROP_YDISTANCE, 15);    
  //--------------------------------------------------------------------------- 
   ObjectCreate("H41", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H41", OBJPROP_XDISTANCE, 40);  
   ObjectSet("H41", OBJPROP_YDISTANCE, 35);
   
   ObjectCreate("H42", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H42", OBJPROP_XDISTANCE, 70);  
   ObjectSet("H42", OBJPROP_YDISTANCE, 35);
   
   ObjectCreate("H43", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H43", OBJPROP_XDISTANCE, 100);  
   ObjectSet("H43", OBJPROP_YDISTANCE, 35); 
  
   ObjectCreate("H44", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H44", OBJPROP_XDISTANCE, 130);  
   ObjectSet("H44", OBJPROP_YDISTANCE, 35);
   
   ObjectCreate("H45", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("H45", OBJPROP_XDISTANCE, 160);  
   ObjectSet("H45", OBJPROP_YDISTANCE, 35);
  //--------------------------------------------------------------------------- 
   ObjectCreate("D11", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("D11", OBJPROP_XDISTANCE, 40);  
   ObjectSet("D11", OBJPROP_YDISTANCE, 55);
   
   ObjectCreate("D12", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("D12", OBJPROP_XDISTANCE, 70);  
   ObjectSet("D12", OBJPROP_YDISTANCE, 55);
   
   ObjectCreate("D13", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("D13", OBJPROP_XDISTANCE, 100);  
   ObjectSet("D13", OBJPROP_YDISTANCE, 55);  
   
   ObjectCreate("D14", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("D14", OBJPROP_XDISTANCE, 130);  
   ObjectSet("D14", OBJPROP_YDISTANCE, 55);
   
   ObjectCreate("D15", OBJ_LABEL, WindowFind(short_name), 0, 0); 
   ObjectSet("D15", OBJPROP_XDISTANCE, 160);  
   ObjectSet("D15", OBJPROP_YDISTANCE, 55); 
     
     MaH11=iMA(NULL,PERIOD_H1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,0);    MaH1pr1=iMA(NULL,PERIOD_H1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,1);
     MaH12=iMA(NULL,PERIOD_H1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,0);    MaH1pr2=iMA(NULL,PERIOD_H1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,1);
     MaH13=iMA(NULL,PERIOD_H1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr3=iMA(NULL,PERIOD_H1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,1);
     MaH14=iMA(NULL,PERIOD_H1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr4=iMA(NULL,PERIOD_H1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,1);
     MaH15=iMA(NULL,PERIOD_H1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr5=iMA(NULL,PERIOD_H1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,1);
    
     MaH41=iMA(NULL,PERIOD_H4,maTrendPeriod_1 ,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr1=iMA(NULL,PERIOD_H4,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,1);
     MaH42=iMA(NULL,PERIOD_H4,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,0);    MaH4pr2=iMA(NULL,PERIOD_H4,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,1);
     MaH43=iMA(NULL,PERIOD_H4,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr3=iMA(NULL,PERIOD_H4,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,1);
     MaH44=iMA(NULL,PERIOD_H4,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr4=iMA(NULL,PERIOD_H4,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,1);
     MaH45=iMA(NULL,PERIOD_H4,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr5=iMA(NULL,PERIOD_H4,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,1);
     
     MaD11=iMA(NULL,PERIOD_D1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,0);    MaD1pr1=iMA(NULL,PERIOD_D1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,1);
     MaD12=iMA(NULL,PERIOD_D1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,0);    MaD1pr2=iMA(NULL,PERIOD_D1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,1);
     MaD13=iMA(NULL,PERIOD_D1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr3=iMA(NULL,PERIOD_D1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,1);
     MaD14=iMA(NULL,PERIOD_D1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr4=iMA(NULL,PERIOD_D1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,1);
     MaD15=iMA(NULL,PERIOD_D1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr5=iMA(NULL,PERIOD_D1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,1);
     
   //  MaH4=iMA(NULL,PERIOD_M30,34,0,MODE_SMA,PRICE_CLOSE,0);
     if (MaH11 < MaH1pr1){H11 = " V ";   co11 = Red;   u1x5 = 0; d1x5 = 1;}
     if (MaH11 > MaH1pr1){H11 = " /\\ "; co11 = Blue;  u1x5 = 1; d1x5 = 0;} 
     if (MaH11 == MaH1pr1){H11 = " 0 "; co11 = Green;  u1x5 = 0; d1x5 = 0;}           
     if (MaH41 < MaH4pr1){H41 = " V "; co41 = Red;     u2x5 = 0; d2x5 = 1;}            
     if (MaH41 > MaH4pr1){H41 = " /\\ "; co41 = Blue;  u2x5 = 1; d2x5 = 0;}
     if (MaH41 == MaH4pr1){H41 = " 0 "; co41 = Green;  u2x5 = 0; d2x5 = 0;}            
     if (MaD11 < MaD1pr1){D11 = " V "; co61 = Red;     u3x5 = 0; d3x5 = 1;}            
     if (MaD11 > MaD1pr1){D11 = " /\\ "; co61 = Blue;  u3x5 = 1; d3x5 = 0;}
     if (MaD11 == MaD1pr1){D11 = " 0 "; co61 = Green;  u3x5 = 0; d3x5 = 0;}  
     
     if (MaH12 < MaH1pr2){H12 = " V "; co12 = Red;     u1x8 = 0; d1x8 = 1;}
     if (MaH12 > MaH1pr2){H12 = " /\\ "; co12 = Blue;  u1x8 = 1; d1x8 = 0;}
     if (MaH12 == MaH1pr2){H12 = " 0 "; co12 = Green;  u1x8 = 0; d1x8 = 0;}            
     if (MaH42 < MaH4pr2){H42 = " V "; co42 = Red;     u2x8 = 0; d2x8 = 1;}            
     if (MaH42 > MaH4pr2){H42 = " /\\ "; co42 = Blue;   u2x8 = 1; d2x8 = 0;} 
     if (MaH42 == MaH4pr2){H42 = " 0 "; co42 = Green;   u2x8 = 0; d2x8 = 0;}           
     if (MaD12 < MaD1pr2){D12 = " V "; co62 = Red;      u3x8 = 0; d3x8 = 1;}             
     if (MaD12 > MaD1pr2){D12 = " /\\ "; co62 = Blue;   u3x8 = 1; d3x8 = 0;}
     if (MaD12 == MaD1pr2){D12 = " 0 "; co62 = Green;   u3x8 = 0; d3x8 = 0;} 
     
     if (MaH13 < MaH1pr3){H13 = " V "; co13 = Red;    u1x13 = 0; d1x13 = 1;}
     if (MaH13 > MaH1pr3){H13 = " /\\ "; co13 = Blue; u1x13 = 1; d1x13 = 0;}
     if (MaH13 ==MaH1pr3){H13 = " 0 "; co13 = Green;  u1x13 = 0; d1x13 = 0;}              
     if (MaH43 < MaH4pr3){H43 = " V "; co43 = Red; u2x13 = 0; d2x13 = 1;}            
     if (MaH43 > MaH4pr3){H43 = " /\\ "; co43 = Blue; u2x13 = 1; d2x13 = 0;}
     if (MaH43 ==MaH4pr3){H43 = " 0 "; co43 = Green;  u2x13 = 0; d2x13 = 0;}            
     if (MaD13 < MaD1pr3){D13 = " V "; co63 = Red; u3x13 = 0; d3x13 = 1;}            
     if (MaD13 > MaD1pr3){D13 = " /\\ "; co63 = Blue; u3x13 = 1; d3x13 = 0;}
     if (MaD13 ==MaD1pr3){D13 = " 0 "; co63 = Green;  u3x13 = 0; d3x13 = 0;}
     
     if (MaH14 < MaH1pr4){H14 = " V "; co14 = Red;    u1x21 = 0; d1x21 = 1;}
     if (MaH14 > MaH1pr4){H14 = " /\\ "; co14 = Blue; u1x21 = 1; d1x21 = 0;}
     if (MaH14 == MaH1pr4){H14 = " 0 "; co14 = Green; u1x21 = 0; d1x21 = 0;}              
     if (MaH44 < MaH4pr4){H44 = " V "; co44 = Red; u2x21 = 0; d2x21 = 1;}            
     if (MaH44 > MaH4pr4){H44 = " /\\ "; co44 = Blue; u2x21 = 1; d2x21 = 0;}
     if (MaH44 == MaH4pr4){H44 = " 0 "; co44 = Green; u2x21 = 0; d2x21 = 0;}            
     if (MaD14 < MaD1pr4){D14 = " V "; co64 = Red; u3x21 = 0; d3x21 = 1;}            
     if (MaD14 > MaD1pr4){D14 = " /\\ "; co64 = Blue; u3x21 = 1; d3x21 = 0;} 
     if (MaD14 == MaD1pr4){D14 = " 0 "; co64 = Green; u3x21 = 0; d3x21 = 0;}  
     
     if (MaH15 < MaH1pr5){H15 = " V "; co15 = Red;    u1x34 = 0; d1x34 = 1;}
     if (MaH15 > MaH1pr5){H15 = " /\\ "; co15 = Blue; u1x34 = 1; d1x34 = 0;} 
     if (MaH15 == MaH1pr5){H15 = " 0 "; co15 = Green; u1x34 = 0; d1x34 = 0;}             
     if (MaH45 < MaH4pr5){H45 = " V "; co45 = Red;    u2x34 = 0; d2x34 = 1;}            
     if (MaH45 > MaH4pr5){H45 = " /\\ "; co45 = Blue; u2x34 = 1; d2x34 = 0;}
     if (MaH45 == MaH4pr5){H45 = " 0 "; co45 = Green; u2x34 = 0; d2x34 = 0;}            
     if (MaD15 < MaD1pr5){D15 = " V "; co65 = Red;    u3x34 = 0; d3x34 = 1;}            
     if (MaD15 > MaD1pr5){D15 = " /\\ "; co65 = Blue; u3x34 = 1; d3x34 = 0;}
     if (MaD15 == MaD1pr5){D15 = " 0 "; co65 = Green; u3x34 = 0; d3x34 = 0;}                      
             
    // Comment(";JGF:");
     //        "\n", "H4 - ", H41 , 
     //        "\n", "D1 - ", D11   );   
            
             ObjectSetText("label_object1", "H1 - ",11, "Verdana", Lime );
             ObjectSetText("label_object2", "H4 - ",11, "Verdana", Lime );
             ObjectSetText("label_object3", "D1 - ",11, "Verdana", Lime );
             
             ObjectSetText("H11", H11 ,11, "Verdana", co11 );
             ObjectSetText("H12", H12 ,11, "Verdana", co12 );
             ObjectSetText("H13", H13 ,11, "Verdana", co13 );
             ObjectSetText("H14", H14 ,11, "Verdana", co14 );
             ObjectSetText("H15", H15 ,11, "Verdana", co15 );
             
             ObjectSetText("H41", H41 ,11, "Verdana", co41 );
             ObjectSetText("H42", H42 ,11, "Verdana", co42 );
             ObjectSetText("H43", H43 ,11, "Verdana", co43 );
             ObjectSetText("H44", H44 ,11, "Verdana", co44 );
             ObjectSetText("H45", H45 ,11, "Verdana", co45 );
             
             ObjectSetText("D11", D11 ,11, "Verdana", co61 );
             ObjectSetText("D12", D12 ,11, "Verdana", co62 );
             ObjectSetText("D13", D13 ,11, "Verdana", co63 );
             ObjectSetText("D14", D14 ,11, "Verdana", co64 );
             ObjectSetText("D15", D15 ,11, "Verdana", co65 ); 
             
//----------------------------------------------------------------------------
// AC Bil Vil
ObjectCreate("AC", OBJ_LABEL, WindowFind(short_name), 0, 0);
ObjectSetText("AC", "AC",9, "Verdana", Lime );
ObjectSet("AC", OBJPROP_XDISTANCE, 200);  
ObjectSet("AC", OBJPROP_YDISTANCE, 0);

double  ac  = iAC(NULL, 60, 0);
double  ac1 = iAC(NULL, 60, 1);
double  ac2 = iAC(NULL, 60, 2);
double  ac3 = iAC(NULL, 60, 3);
//double  ac4 = iAO(NULL, 0, 4);             
string ach11;
color acco11;

if ((ac1>ac2 && ac2>ac3 && ac<0 && ac>ac1) || (ac>ac1 && ac1>ac2 && ac>0)) 
{ach11 = "/\\ " ; acco11 = Blue; u1ac = 3; d1ac = 0;} 
if ((ac1<ac2 && ac2<ac3 && ac>0 && ac<ac1) || (ac<ac1 && ac1<ac2 && ac<0)) 
{ach11 = "V " ; acco11 = Red; u1ac = 0; d1ac = 3;}
if ((((ac1<ac2 || ac2<ac3) && ac<0 && ac>ac1) || (ac>ac1 && ac1<ac2 && ac>0))||
(((ac1>ac2 || ac2>ac3) && ac>0 && ac<ac1) || (ac<ac1 && ac1>ac2 && ac<0)))
{ach11 = "0 " ; acco11 = Green; u1ac = 0; d1ac = 0;}    

ObjectCreate("AC11", OBJ_LABEL, WindowFind(short_name), 0, 0);
ObjectSetText("AC11", ach11,11, "Verdana", acco11 );
ObjectSet("AC11", OBJPROP_XDISTANCE, 200);  
ObjectSet("AC11", OBJPROP_YDISTANCE, 15);  
  
double  ac03  = iAC(NULL, 1440, 0);
double  ac13 = iAC(NULL, 1440, 1);
double  ac23 = iAC(NULL, 1440, 2);
double  ac33 = iAC(NULL, 1440, 3);
//double  ac4 = iAO(NULL, 0, 4);             
string ach13;
color acco13;

if ((ac13>ac23 && ac23>ac33 && ac03<0 && ac03>ac13) || (ac03>ac13 && ac13>ac23 && ac03>0)) 
{ach13 = "/\\ " ; acco13 = Blue; u3ac = 3; d3ac = 0;}     
if ((ac13<ac23 && ac23<ac33 && ac03>0 && ac03<ac13) || (ac03<ac13 && ac13<ac23 && ac03<0)) 
{ach13 = "V " ; acco13 = Red; u3ac = 0; d3ac = 3;}     
if ((((ac13<ac23 || ac23<ac33) && ac03<0 && ac03>ac13) || (ac03>ac13 && ac13<ac23 && ac03>0))||
(((ac13>ac23 || ac23>ac33) && ac03>0 && ac03<ac13) || (ac03<ac13 && ac13>ac23 && ac03<0)))
{ach13 = "0 " ; acco13 = Green; u3ac = 0; d3ac = 0;}
ObjectCreate("AC13", OBJ_LABEL, WindowFind(short_name), 0, 0);
ObjectSetText("AC13", ach13,11, "Verdana", acco13 );
ObjectSet("AC13", OBJPROP_XDISTANCE, 200);  
ObjectSet("AC13", OBJPROP_YDISTANCE, 55);  

double  ac02  = iAC(NULL, 240, 0);
double  ac12 = iAC(NULL, 240, 1);
double  ac22 = iAC(NULL, 240, 2);
double  ac32 = iAC(NULL, 240, 3);
//double  ac4 = iAO(NULL, 0, 4);             
string ach12;
color acco12;

if ((ac12>ac22 && ac22>ac32 && ac02<0 && ac02>ac12) || (ac02>ac12 && ac12>ac22 && ac02>0)) 
{ach12 = "/\\ " ; acco12 = Blue; u2ac = 3; d2ac = 0;}     
if ((ac12<ac22 && ac22<ac32 && ac02>0 && ac02<ac12) || (ac02<ac12 && ac12<ac22 && ac02<0)) 
{ach12 = "V " ; acco12 = Red; u2ac = 0; d2ac = 3;}     
if ((((ac12<ac22 || ac22<ac32) && ac02<0 && ac02>ac12) || (ac02>ac12 && ac12<ac22 && ac02>0))||
(((ac12>ac22 || ac22>ac32) && ac02>0 && ac02<ac12) || (ac02<ac12 && ac12>ac22 && ac02<0)))
{ach12 = "0 " ; acco12 = Green; u2ac = 0; d2ac = 0;}
ObjectCreate("AC12", OBJ_LABEL, WindowFind(short_name), 0, 0);
ObjectSetText("AC12", ach12,11, "Verdana", acco12 );
ObjectSet("AC12", OBJPROP_XDISTANCE, 200);  
ObjectSet("AC12", OBJPROP_YDISTANCE, 35);     
  
 
 
ObjectCreate("rez", OBJ_LABEL, WindowFind(short_name), 0, 0);
ObjectSetText("rez", "РЕЗУЛЬТАТЫ",9, "Verdana", Lime );
ObjectSet("rez", OBJPROP_XDISTANCE, 240);  
ObjectSet("rez", OBJPROP_YDISTANCE, 0);
 
  
  double uitog1 = (u1x5 + u1x8 + u1x13 + u1x21 + u1x34 + u1ac) * 12.5;
  double uitog2 = (u2x5 + u2x8 + u2x13 + u2x21 + u2x34 + u2ac) * 12.5;
  double uitog3 = (u3x5 + u3x8 + u3x13 + u3x21 + u3x34 + u3ac) * 12.5;
  
  double ditog1 = (d1x5 + d1x8 + d1x13 + d1x21 + d1x34 + d1ac) * 12.5;
  double ditog2 = (d2x5 + d2x8 + d2x13 + d2x21 + d2x34 + d2ac) * 12.5;
  double ditog3 = (d3x5 + d3x8 + d3x13 + d3x21 + d3x34 + d3ac) * 12.5;
  
  string hr1, hr2, hr3, hr4, hr5,hr6;
  string dhr1, dhr2, dhr3, dhr4, dhr5, dhr6;
  if (uitog1> ditog1) {hr1 = "Arial Black"; dhr1 = "Arial";}
  if (uitog1< ditog1) {hr1 = "Arial"; dhr1 = "Arial Black";}
  if (uitog1 == ditog1) {hr1 = "Arial"; dhr1 = "Arial";}
  
  if (uitog2> ditog2) {hr2 = "Arial Black"; dhr2 = "Arial";}
  if (uitog2< ditog2) {hr2 = "Arial"; dhr2 = "Arial Black";}
  if (uitog2 == ditog2) {hr2 = "Arial"; dhr2 = "Arial";}
  
  if (uitog3> ditog3) {hr3 = "Arial Black"; dhr3 = "Arial";}
  if (uitog3< ditog3) {hr3 = "Arial"; dhr3 = "Arial Black";}
  if (uitog3 == ditog3) {hr3 = "Arial"; dhr3 = "Arial";}
  
  ObjectCreate("uitog1", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("uitog1", StringConcatenate("/\\ ", uitog1, "%"),12, hr1, DodgerBlue );
  ObjectSet("uitog1", OBJPROP_XDISTANCE, 235);  
  ObjectSet("uitog1", OBJPROP_YDISTANCE, 15);
  
  ObjectCreate("uitog2", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("uitog2", StringConcatenate("/\\ ",uitog2, "%"),12, hr2, DodgerBlue );
  ObjectSet("uitog2", OBJPROP_XDISTANCE, 235);  
  ObjectSet("uitog2", OBJPROP_YDISTANCE, 35);
  
  ObjectCreate("uitog3", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("uitog3", StringConcatenate("/\\ ",uitog3, "%"),12, hr3, DodgerBlue );
  ObjectSet("uitog3", OBJPROP_XDISTANCE, 235);  
  ObjectSet("uitog3", OBJPROP_YDISTANCE, 55);
  
  ObjectCreate("ditog1", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("ditog1", StringConcatenate("\\/ ", ditog1, "%"),12, dhr1, Red );
  ObjectSet("ditog1", OBJPROP_XDISTANCE, 310);  
  ObjectSet("ditog1", OBJPROP_YDISTANCE, 15);
  
  ObjectCreate("ditog2", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("ditog2", StringConcatenate("\\/ ",ditog2, "%"),12, dhr2, Red );
  ObjectSet("ditog2", OBJPROP_XDISTANCE, 310);  
  ObjectSet("ditog2", OBJPROP_YDISTANCE, 35);
  
  ObjectCreate("ditog3", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("ditog3", StringConcatenate("\\/ ",ditog3, "%"),12, dhr3, Red );
  ObjectSet("ditog3", OBJPROP_XDISTANCE, 310);  
  ObjectSet("ditog3", OBJPROP_YDISTANCE, 55);
  
  
  string txt;
  if (uitog1 > 50 && uitog2 > 50 && uitog3 > 50)
  
  {txt = "Неплохо BUY";
     if(n1==0){if(Symbol()=="EURUSD"){GlobalVariableSet("Signal_EURUSD",0);}}
     if(n2==0){if(Symbol()=="USDCHF"){GlobalVariableSet("Signal_USDCHF",0);}}
     if(n3==0){if(Symbol()=="USDJPY"){GlobalVariableSet("Signal_USDJPY",0);}}
     if(n==0) {if(Symbol()=="GBPUSD"){GlobalVariableSet("Signal_GBPUSD",0);}}
     if(n4==0){if(Symbol()=="EURJPY"){GlobalVariableSet("Signal_EURJPY",0);}}
     if(n5==0){if(Symbol()=="GBPJPY"){GlobalVariableSet("Signal_GBPJPY",0);}}
     if(n6==0){if(Symbol()=="AUDUSD"){GlobalVariableSet("Signal_AUDUSD",0);}}  }
  else
  {txt = "Не открывать ЖДИТЕ.";
     if(n1==0){if(Symbol()=="EURUSD"){GlobalVariableSet("Signal_EURUSD",0);}}
     if(n2==0){if(Symbol()=="USDCHF"){GlobalVariableSet("Signal_USDCHF",0);}}
     if(n3==0){if(Symbol()=="USDJPY"){GlobalVariableSet("Signal_USDJPY",0);}}
     if(n==0) {if(Symbol()=="GBPUSD"){GlobalVariableSet("Signal_GBPUSD",0);}}
     if(n4==0){if(Symbol()=="EURJPY"){GlobalVariableSet("Signal_EURJPY",0);}}
     if(n5==0){if(Symbol()=="GBPJPY"){GlobalVariableSet("Signal_GBPJPY",0);}}
     if(n6==0){if(Symbol()=="AUDUSD"){GlobalVariableSet("Signal_AUDUSD",0);}}  }
  
  if (ditog1 > 50 && ditog2 > 50 && ditog3 > 50)
  {txt = "Неплохой SELL";
     if(n1==0){if(Symbol()=="EURUSD"){GlobalVariableSet("Signal_EURUSD",0);}}
     if(n2==0){if(Symbol()=="USDCHF"){GlobalVariableSet("Signal_USDCHF",0);}}
     if(n3==0){if(Symbol()=="USDJPY"){GlobalVariableSet("Signal_USDJPY",0);}}
     if(n==0) {if(Symbol()=="GBPUSD"){GlobalVariableSet("Signal_GBPUSD",0);}}
     if(n4==0){if(Symbol()=="EURJPY"){GlobalVariableSet("Signal_EURJPY",0);}}
     if(n5==0){if(Symbol()=="GBPJPY"){GlobalVariableSet("Signal_GBPJPY",0);}}
     if(n6==0){if(Symbol()=="AUDUSD"){GlobalVariableSet("Signal_AUDUSD",0);}}  }
    
  if (uitog1 >= 75 && uitog2 >= 75 && uitog3 >= 75)
  {txt = "УДАЧНЫЙ BUY";

      if(m1==0){if(Symbol()=="EURUSD"){GlobalVariableSet("Signal_EURUSDschet",CurTime());GlobalVariableSet("Signal_EURUSDtxt",Bid);PlaySound("trendBayEURUSD.wav");GlobalVariableSet("Signal_EURUSD",10000);}}
      if(m2==0){if(Symbol()=="USDCHF"){GlobalVariableSet("Signal_USDCHFschet",CurTime());GlobalVariableSet("Signal_USDCHFtxt",Bid);PlaySound("trendBayUSDCHF.wav");GlobalVariableSet("Signal_USDCHF",10000);}}
      if(m3==0){if(Symbol()=="USDJPY"){GlobalVariableSet("Signal_USDJPYschet",CurTime());GlobalVariableSet("Signal_USDJPYtxt",Bid);PlaySound("trendBayUSDJPY.wav");GlobalVariableSet("Signal_USDJPY",10000);}}
      if(m==0) {if(Symbol()=="GBPUSD"){GlobalVariableSet("Signal_GBPUSDschet",CurTime());GlobalVariableSet("Signal_GBPUSDtxt",Bid);PlaySound("trendBayGBPUSD.wav");GlobalVariableSet("Signal_GBPUSD",10000);}}
      if(m4==0){if(Symbol()=="EURJPY"){GlobalVariableSet("Signal_EURJPYschet",CurTime());GlobalVariableSet("Signal_EURJPYtxt",Bid);PlaySound("trendBayEURJPY.wav");GlobalVariableSet("Signal_EURJPY",10000);}}
      if(m5==0){if(Symbol()=="GBPJPY"){GlobalVariableSet("Signal_GBPJPYschet",CurTime());GlobalVariableSet("Signal_GBPJPYtxt",Bid);PlaySound("trendBayGBPJPY.wav");GlobalVariableSet("Signal_GBPJPY",10000);}}
      if(m6==0){if(Symbol()=="AUDUSD"){GlobalVariableSet("Signal_AUDUSDschet",CurTime());GlobalVariableSet("Signal_AUDUSDtxt",Bid);PlaySound("trendBayAUDUSD.wav");GlobalVariableSet("Signal_AUDUSD",10000);}}    

      if(Symbol()=="EURUSD") {GlobalVariableSet("Signal_EURUSD2",10);}
      if(Symbol()=="USDCHF") {GlobalVariableSet("Signal_USDCHF2",10);}
      if(Symbol()=="USDJPY") {GlobalVariableSet("Signal_UUSDJPY2",10);}
      if(Symbol()=="GBPUSD") {GlobalVariableSet("Signal_GBPUSD2",10);}
      if(Symbol()=="EURJPY") {GlobalVariableSet("Signal_EURJPY2",10);}
      if(Symbol()=="GBPJPY") {GlobalVariableSet("Signal_GBPJPY2",10);}
      if(Symbol()=="AUDUSD") {GlobalVariableSet("Signal_AUDUSD2",10);}         
   
      if(Symbol()=="EURUSD") {GlobalVariableSet("Signal_EURUSDtxt2",Bid);}
      if(Symbol()=="USDCHF") {GlobalVariableSet("Signal_USDCHFtxt2",Bid);}
      if(Symbol()=="USDJPY") {GlobalVariableSet("Signal_USDJPYtxt2",Bid);}
      if(Symbol()=="GBPUSD") {GlobalVariableSet("Signal_GBPUSDtxt2",Bid);}
      if(Symbol()=="EURJPY") {GlobalVariableSet("Signal_EURJPYtxt2",Bid);}
      if(Symbol()=="GBPJPY") {GlobalVariableSet("Signal_GBPJPYtxt2",Bid);}
      if(Symbol()=="AUDUSD") {GlobalVariableSet("Signal_AUDUSDtxt2",Bid);}
      }
  
  if (ditog1 >= 75 && ditog2 >= 75 && ditog3 >= 75)
  {txt = "УДАЧНЫЙ SELL";

      if(m1==0){if(Symbol()=="EURUSD"){GlobalVariableSet("Signal_EURUSDschet",CurTime());GlobalVariableSet("Signal_EURUSDtxt",Bid);PlaySound("trendSellEURUSD.wav");GlobalVariableSet("Signal_EURUSD",-10000);}}
      if(m2==0){if(Symbol()=="USDCHF"){GlobalVariableSet("Signal_USDCHFschet",CurTime());GlobalVariableSet("Signal_USDCHFtxt",Bid);PlaySound("trendSellUSDCHF.wav");GlobalVariableSet("Signal_USDCHF",-10000);}}
      if(m3==0){if(Symbol()=="USDJPY"){GlobalVariableSet("Signal_USDJPYschet",CurTime());GlobalVariableSet("Signal_USDJPYtxt",Bid);PlaySound("trendSellUSDJPY.wav");GlobalVariableSet("Signal_USDJPY",-10000);}}
      if(m==0) {if(Symbol()=="GBPUSD"){GlobalVariableSet("Signal_GBPUSDschet",CurTime());GlobalVariableSet("Signal_GBPUSDtxt",Bid);PlaySound("trendSellGBPUSD.wav");GlobalVariableSet("Signal_GBPUSD",-10000);}}
      if(m4==0){if(Symbol()=="EURJPY"){GlobalVariableSet("Signal_EURJPYschet",CurTime());GlobalVariableSet("Signal_EURJPYtxt",Bid);PlaySound("trendSellEURJPY.wav");GlobalVariableSet("Signal_EURJPY",-10000);}}
      if(m5==0){if(Symbol()=="GBPJPY"){GlobalVariableSet("Signal_GBPJPYschet",CurTime());GlobalVariableSet("Signal_GBPJPYtxt",Bid);PlaySound("trendSellGBPJPY.wav");GlobalVariableSet("Signal_GBPJPY",-10000);}}
      if(m6==0){if(Symbol()=="AUDUSD"){GlobalVariableSet("Signal_AUDUSDschet",CurTime());GlobalVariableSet("Signal_AUDUSDtxt",Bid);PlaySound("trendSellAUDUSD.wav");GlobalVariableSet("Signal_AUDUSD",-10000);}}     

      if(Symbol()=="EURUSD") {GlobalVariableSet("Signal_EURUSD2",10);}
      if(Symbol()=="USDCHF") {GlobalVariableSet("Signal_USDCHF2",10);}
      if(Symbol()=="USDJPY") {GlobalVariableSet("Signal_UUSDJPY2",10);}
      if(Symbol()=="GBPUSD") {GlobalVariableSet("Signal_GBPUSD2",10);}
      if(Symbol()=="EURJPY") {GlobalVariableSet("Signal_EURJPY2",10);}
      if(Symbol()=="GBPJPY") {GlobalVariableSet("Signal_GBPJPY2",10);}
      if(Symbol()=="AUDUSD") {GlobalVariableSet("Signal_AUDUSD2",10);}
      
      if(Symbol()=="EURUSD") {GlobalVariableSet("Signal_EURUSDtxt2",Bid);}
      if(Symbol()=="USDCHF") {GlobalVariableSet("Signal_USDCHFtxt2",Bid);}
      if(Symbol()=="USDJPY") {GlobalVariableSet("Signal_USDJPYtxt2",Bid);}
      if(Symbol()=="GBPUSD") {GlobalVariableSet("Signal_GBPUSDtxt2",Bid);}
      if(Symbol()=="EURJPY") {GlobalVariableSet("Signal_EURJPYtxt2",Bid);}
      if(Symbol()=="GBPJPY") {GlobalVariableSet("Signal_GBPJPYtxt2",Bid);}
      if(Symbol()=="AUDUSD") {GlobalVariableSet("Signal_AUDUSDtxt2",Bid);}
      }

  ObjectCreate("txt", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("txt", txt,14, "Verdana", Lime );
  ObjectSet("txt", OBJPROP_XDISTANCE, 750);  
  ObjectSet("txt", OBJPROP_YDISTANCE, 35);
  
  ObjectCreate("txt2", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("txt2","Мультитаймфреймный индикатор \"TREND_ALEXCUD\"",9, "Verdana", Silver );
  ObjectSet("txt2", OBJPROP_XDISTANCE, 11);  
  ObjectSet("txt2", OBJPROP_YDISTANCE, 80);
  
  ObjectCreate("txt3", OBJ_LABEL, WindowFind(short_name), 0, 0);
  ObjectSetText("txt3","Copyright © 2007 ALEXCUD",9, "Verdana", Silver );
  ObjectSet("txt3", OBJPROP_XDISTANCE, 410);  
  ObjectSet("txt3", OBJPROP_YDISTANCE, 80);

   return(0);
  }
//+------------------------------------------------------------------+