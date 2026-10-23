//+------------------------------------------------------------------+
//|                                                 Hamyar Panel.mq4 |
//|                               Copyright © 2010,Farshad Saremifar |
//|                                                   www.4xline.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,Farshad Saremifar"
#property link      "www.4xline.com"

#property indicator_chart_window

//-----------------------------
//---- Indicators parameters
extern string    Copyright="Copyright © 2010,Farshad Saremifar,www.4xline.com";
extern string    Help="!!!Attach HamyarZone Indicator Before Attaching this to chart!!!";

extern bool      BackTesting = false;
extern color     VUmeter_Back=Black;
extern color     VUmeter_Border=Gray;
extern color     VUmeter_RightDegree=Lime;
extern color     VUmeter_LeftDegree=Red;
extern color     MainPanel=Chocolate;
extern color     MainFontColor=Black;
extern color     UpFontColor=Chartreuse;
extern color     DnFontColor=Indigo;
extern color     PinColor=Yellow;
extern color     AlertBox=White;
extern color     AlertBox_Font=Black;


datetime  BackTest_Time;  
datetime  LastAlert;  
double s1[];
 double powerup,powerdn;
 int NumberOfDays=5;

int ATR_Period=25;
 int StartHour=9;
 int StartMinute=0;
 int Quarter=0;
 int LondonTZ = 0;
int Tehran = 210;
int TokyoTZ = 540;
int NewYorkTZ = -300;


datetime localTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorShortName("Hamyar Panel");
ObjectDelete("BacktestTime");
if(BackTesting) 
  {
  ObjectCreate("BacktestTime",OBJ_VLINE,0,Time[5],0);
  ObjectSet("BacktestTime",OBJPROP_COLOR,Green);
  ObjectSet("BacktestTime",OBJPROP_STYLE, STYLE_DASH);
 
  }
LastAlert=Time[2];



   
   
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
 for(int i=ObjectsTotal()-1;i>=0;i--)
  if(StringFind(ObjectName(i),"Hamyar",0)>=0||StringFind(ObjectName(i),"VU",0)>=0)
   {
   ObjectDelete(ObjectName(i));
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int dst;
    int GMT_SHIFT=GlobalVariableGet("GMT_SHIFT"+WindowHandle(Symbol(),Period())+Symbol()+Period());
    bool DayLightSaving=GlobalVariableGet("DayLightSaving"+WindowHandle(Symbol(),Period())+Symbol()+Period());
   if (DayLightSaving==true)dst=2;
   else dst=1;
   datetime GMT = TimeLocal() - GMT_SHIFT * 60;
  
 //Print(GMT_SHIFT);
   datetime london = GMT + (LondonTZ + (dst*60 - 1*60)) * 60;
   datetime tokyo = GMT + (TokyoTZ) * 60;
   datetime newyork = GMT + (NewYorkTZ + (dst*60 - 1*60)) * 60;
   datetime tehran=TimeLocal();
  //--------------------------------
  

 datetime barshift;
    int shift;
 

   if( BackTesting == true ) {BackTest_Time=ObjectGet("BacktestTime",OBJPROP_TIME1);shift=iBarShift(NULL,0,BackTest_Time,false);barshift=BackTest_Time;}
   else    {shift=0;barshift=Time[0];}
     
//----
  StartHour=GlobalVariableGet("StartHour"+WindowHandle(Symbol(),Period())+Symbol()+Period());
  StartMinute=GlobalVariableGet("StartMinute"+WindowHandle(Symbol(),Period())+Symbol()+Period());
  ATR_Period= GlobalVariableGet("ATR_Period"+WindowHandle(Symbol(),Period())+Symbol()+Period());
  Quarter=GlobalVariableGet("Quarter"+WindowHandle(Symbol(),Period())+Symbol()+Period());
  NumberOfDays=GlobalVariableGet("NumberOfDays"+WindowHandle(Symbol(),Period())+Symbol()+Period());
 

//-------------
Createobject();
  powerup=Powers("Up",Time[shift]);
  powerdn=Powers("Dn",Time[shift]);
    
   paintBearsNeedle(powerdn);
   paintBullsNeedle(powerup);
   paintCentreNeedle(powerdn);
    
    objectCreate("HamyarBull", 33, 114,1, "Bull",8,"Arial", VUmeter_RightDegree);  
    objectCreate("HamyarBear", 126, 114,1, "Bear",8,"Arial", VUmeter_LeftDegree);  
    objectCreate("HamyarBullpercent", 18, 104,1, DoubleToStr(powerup,0)+"%",9,"Digiface", VUmeter_RightDegree);  
    objectCreate("HamyarBearpercent", 136, 104,1,DoubleToStr(powerdn,0)+"%",9,"Digiface", VUmeter_LeftDegree);  
    objectCreate("Hamyarpanel1", 4, 101,1, "*",130,"Webdings", MainPanel);  
    ObjectSet   ("Hamyarpanel1",OBJPROP_BACK      , true );
   
    objectCreate("Hamyarpanel2", 15, 221,1, "*",130,"Webdings", MainPanel);  
    ObjectSet   ("Hamyarpanel2",OBJPROP_ANGLE , 10);
  
   objectCreate("Hamyarpanel22", 15, 360,1, "*",100,"Webdings", MainPanel);  
   objectCreate("Hamyargire22", 1, 332,1, "\'",50,"Webdings", PinColor);  
    ObjectSet   ("Hamyarpanel22",OBJPROP_BACK      , true );
    
   objectCreate("Hamyargire", 1, 202,1, "\'",50,"Webdings", PinColor);  
   double BuyZone=iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,2,shift);
   double SellZone=iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,1,shift);
   double Buytp1=iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,4,shift);
   double Selltp1=iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,3,shift);
   
   objectCreate("HamyarBuylabel", 50, 150,1, "Buy @" +DoubleToStr(BuyZone,Digits),9,"Arial Bold", MainFontColor);  
   objectCreate("HamyarBuyTp1", 70, 165,1, "Buy TP1:" +DoubleToStr(Buytp1,Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarBuyTp2", 70, 175,1, "Buy TP2:" +DoubleToStr(iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,6,shift),Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarBuyTp3", 70, 185,1, "Buy TP3:" +DoubleToStr(iCustom(NULL,0,"HamyarTP\'s",4,shift),Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarBuySL", 43, 195,1, "Buy StopLoss:" +DoubleToStr(iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,1,shift),Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarBuyBreak", 62, 205,1, "BE TP3 @:" +DoubleToStr(iCustom(NULL,0,"HamyarTP\'s",2,shift),Digits),8,"Arial Bold", MainFontColor);  
  
   
   objectCreate("HamyarSelllabel", 50, 280,1, "Sell @" +DoubleToStr(SellZone,Digits),9,"Arial Bold", MainFontColor);  
   objectCreate("HamyarSellTp1", 70, 295,1, "Sell TP1:" +DoubleToStr(Selltp1,Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarSellTp2", 70, 305,1, "Sell TP2:" +DoubleToStr(iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,5,shift),Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarSellTp3", 70, 315,1, "Sell TP3:" +DoubleToStr(iCustom(NULL,0,"HamyarTP\'s",3,shift),Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarSellSL", 43, 325,1, "Sell StopLoss:" +DoubleToStr(iCustom(NULL,0,"Hamyar Zones","",NumberOfDays,ATR_Period,StartHour,Quarter,2,shift),Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("HamyarSellBreak", 62, 335,1, "BE TP3 @:" +DoubleToStr(iCustom(NULL,0,"HamyarTP\'s",1,shift),Digits),8,"Arial Bold", MainFontColor);  
   objectCreate("Hamyarpanel3", 11, 1,0, "*",110,"Webdings", MainPanel);  
   ObjectSet   ("Hamyarpanel3",OBJPROP_ANGLE , 350);
   double i;
   int m,s,k;
   m=Time[0]+Period()*60-CurTime();
   i=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
  
   objectCreate("HamyarSpread", 35, 394,1, "Spread:" +DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0)+" Points",9,"Arial Bold", MainFontColor);  
   objectCreate("Hamyarleverage", 45, 408,1, "Leverage:" +AccountLeverage(),9,"Arial Bold", MainFontColor);  
   objectCreate("HamyarTimer", 32, 427,1, "Timer:("+m+":"+s+") Left",9,"Arial Bold", MainFontColor);  
 
   objectCreate("Hamyargire2", 5, 0,0, "\'",30,"Webdings", PinColor);  
   objectCreate("Hamyarworldclock", 29, 48,0, "World Clock",9,"Arial Bold", MainFontColor);  
  
   if (TimeHour(london)>=0&&TimeHour(london)<=8)
     objectCreate("Hamyarworldclocktokyo", 20, 62,0, "Tokyo:"+TimeToStr(tokyo,TIME_MINUTES),9,"Arial Bold", UpFontColor);  
   else  objectCreate("Hamyarworldclocktokyo", 20, 62,0, "Tokyo:"+TimeToStr(tokyo,TIME_MINUTES),9,"Arial Bold", MainFontColor);  
   if (TimeHour(london)>=6&&TimeHour(london)<=15)
     objectCreate("HamyarworldclockLonon", 20, 75,0, "London:"+TimeToStr(london,TIME_MINUTES),9,"Arial Bold", UpFontColor);  
   else 
     objectCreate("HamyarworldclockLonon", 20, 75,0, "London:"+TimeToStr(london,TIME_MINUTES),9,"Arial Bold", MainFontColor);  
   if (TimeHour(london)>=12&&TimeHour(london)<=21)
     objectCreate("Hamyarworldclockny", 26, 89,0, "NewYork:"+TimeToStr(newyork,TIME_MINUTES),9,"Arial Bold", UpFontColor); 
   else 
     objectCreate("Hamyarworldclockny", 26, 89,0, "NewYork:"+TimeToStr(newyork,TIME_MINUTES),9,"Arial Bold", MainFontColor); 
   
     objectCreate("HamyarworldclockTehran",31, 103,0, "Local:"+TimeToStr(tehran,TIME_MINUTES),9,"Arial Bold", MainFontColor);  
 
   objectCreate("Hamyargire3", 0, 100,0, "\'",30,"Webdings", PinColor);  
   objectCreate("Hamyarpanel4", 1, 105,0, "*",110,"Webdings", MainPanel);  
   ObjectSet   ("Hamyarpanel4",OBJPROP_ANGLE , 355);
   objectCreate("HamyarworldRSI", 30, 141,0, "RSI - Signal",9,"Arial Bold", MainFontColor);  
   double rsilevel=iRSI(NULL,0,8,0,shift);
   double rsilevel3=iRSI(NULL,0,8,0,shift+2);
   
   double rsilevelfast=iRSI(NULL,0,3,0,shift);
   double rsilevel3fast=iRSI(NULL,0,3,0,shift+2);
   bool rsicrossup,rsicrossdn;
   if (rsilevel>50&&rsilevel<=70) objectCreate("HamyarworldRSIlelev", 25, 160,0, "Current Level:"+DoubleToStr(rsilevel,0),9,"Arial Bold",UpFontColor );  
   else if (rsilevel<=50&&rsilevel>=30) objectCreate("HamyarworldRSIlelev", 25, 160,0, "Current Level:"+DoubleToStr(rsilevel,0),9,"Arial Bold",DnFontColor );  
   else if (rsilevel>70||rsilevel<30) objectCreate("HamyarworldRSIlelev", 25, 160,0, "Current Level:"+DoubleToStr(rsilevel,0),9,"Arial Bold",MainFontColor );  
  
  if (rsilevel>rsilevel3) objectCreate("HamyarworldRSIlelev2",15, 175,0, "Heading: Up",9,"Arial Bold",UpFontColor );  
  else if (rsilevel<rsilevel3) objectCreate("HamyarworldRSIlelev2", 15, 175,0, "Heading: Down",9,"Arial Bold",DnFontColor );  
  else objectCreate("HamyarworldRSIlelev2", 15, 175,0, "Heading: Flat",9,"Arial Bold",MainFontColor );  
 
    objectCreate("HamyarrsiCross", 25, 195,0, "Cross:",9,"Arial Bold", MainFontColor);  
    if (rsilevelfast>rsilevel&&rsilevel3fast<rsilevel3) {rsicrossup=true; objectCreate("HamyarrsiCross", 25, 195,0, "Cross: Up",9,"Arial Bold", UpFontColor); } 
    else if (rsilevelfast<rsilevel&&rsilevel3fast>rsilevel3){rsicrossdn=true; objectCreate("HamyarrsiCross", 25, 195,0,"Cross: Down",9,"Arial Bold", DnFontColor);}  
   
  objectCreate("Hamyarpanel5", 0, 220,0, "*",110,"Webdings", MainPanel);  
  objectCreate("Hamyargire4",5, 205,0, "\'",30,"Webdings", PinColor);  
  objectCreate("Hamyargire5", 100, 216,0, "\'",30,"Webdings", PinColor);  
  objectCreate("Hamyarworldsto", 25, 253,0, "Stochastic-Signal",9,"Arial Bold", MainFontColor);  
  
  double stolevel= iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_MAIN,shift); 
  double stolevel2=iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_MAIN,shift+1); 
   
   double stolevel3=iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_MAIN,shift+2); 
   
  double stolevelsignal= iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_SIGNAL,shift); 
  double stolevel2signal=iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_SIGNAL,shift+1); 
   
   
   if (stolevel>50&&stolevel<=70)  objectCreate("Hamyarstolevel", 30, 265,0, "Current Level:"+DoubleToStr(stolevel,0),9,"Arial Bold", UpFontColor);  
    else if (stolevel<=50&&stolevel>=30) objectCreate("Hamyarstolevel", 30, 265,0, "Current Level:"+DoubleToStr(stolevel,0),9,"Arial Bold", DnFontColor);  
   else if (stolevel>70||stolevel<30) objectCreate("Hamyarstolevel", 30, 265,0, "Current Level:"+DoubleToStr(stolevel,0),9,"Arial Bold", MainFontColor);  
  
   if (stolevel>stolevel3)  objectCreate("Hamyarstohead", 30, 280,0, "Heading: Up",9,"Arial Bold", UpFontColor);  
    else if (stolevel<stolevel3) objectCreate("Hamyarstohead", 30, 280,0,"Heading: Down",9,"Arial Bold", DnFontColor);  
   else objectCreate("Hamyarstohead", 30, 280,0, "Heading: Flat",9,"Arial Bold", MainFontColor);  
  
  objectCreate("HamyarstoCross", 30, 295,0, "Cross:",9,"Arial Bold", MainFontColor);  

    if (stolevelsignal>stolevel&&stolevel2signal<stolevel2)  objectCreate("HamyarstoCross", 30, 295,0, "Cross: Down",9,"Arial Bold", DnFontColor);  
    else if (stolevelsignal<stolevel&&stolevel2signal>stolevel2) objectCreate("HamyarstoCross", 30, 295,0,"Cross: Up",9,"Arial Bold", UpFontColor);  
      bool stocrossup,stocrossdn; 
 
  
    if (stolevelsignal>stolevel&&stolevel2signal<stolevel2) {stocrossdn=true;stocrossup=false;}  
    else if (stolevelsignal<stolevel&&stolevel2signal>stolevel2){stocrossdn=false;stocrossup=true;} 
 objectCreate("Hamyarpanel6", 0, 1,2, "Q",115,"HamyarFont", White);  
  
 objectCreate("Hamyarpanel7", 3, 1,2, "Q",110,"HamyarFont", Black);  
 
 ObjectSet   ("Hamyarpanel6",OBJPROP_BACK      , true );
 ObjectSet   ("Hamyarpanel7",OBJPROP_BACK      , true );
   
  objectCreate("HamyarCopyright", 36, 23,2, "Hamyar V 3.0",9,"Arial Bold", White);  
 objectCreate("HamyarCopyrigh2t", 33, 2,2, "Farshad Saremifar",8,"Arial", White);  
  objectCreate("HamyarCopyrigh3t", 33, 12,2, "www.4xline.com",9,"Arial", Yellow);  
  double Predict=Analysis("get",shift);
 
 string analysisdn=DoubleToStr(Analysis("ValueDn",shift),0);
 string analysisup=DoubleToStr(Analysis("ValueUp",shift),0);

if (Predict==1&&StrToDouble(analysisup)>=40)
{
objectCreate("HamyarAlertBox", 126, 70,2, ")",120,"Webdings", AlertBox);  
objectCreate("HamyarAlertBoxinfo", 150, 158,2, "Im Looking For Buy",9,"Arial Bold", AlertBox_Font);  
objectCreate("HamyarAlertBoxinfo2", 155, 140,2, "My Analysis:%"+analysisup,9,"Arial Bold", AlertBox_Font);  


 LastAlert=TimeCurrent();
}
else if (Predict==2&&StrToDouble(analysisdn)>=40)
{ 
objectCreate("HamyarAlertBox", 126, 70,2, ")",120,"Webdings", AlertBox);  
objectCreate("HamyarAlertBoxinfo", 150, 158,2, "Im Looking For Sell",9,"Arial Bold", AlertBox_Font);  
objectCreate("HamyarAlertBoxinfo2", 155, 140,2, "My Analysis:%"+analysisdn,9,"Arial Bold", AlertBox_Font);  
 
 LastAlert=TimeCurrent();
}
else if (Predict==3&&StrToDouble(analysisup)>=40)
{
objectCreate("HamyarAlertBox", 126, 70,2, ")",120,"Webdings", AlertBox);  
objectCreate("HamyarAlertBoxinfo", 145, 158,2, "Up Range!!(Buy @ OS)",8,"Arial Bold", AlertBox_Font);  
objectCreate("HamyarAlertBoxinfo2", 155, 140,2, "My Analysis%:"+analysisup,9,"Arial Bold", AlertBox_Font);  
 LastAlert=TimeCurrent();
}
else if (Predict==4&&StrToDouble(analysisdn)>=40)
{
objectCreate("HamyarAlertBox", 126, 70,2, ")",120,"Webdings", AlertBox);  
objectCreate("HamyarAlertBoxinfo", 145, 158,2, "Down Range!!(Sell @ OB) ",8,"Arial Bold", AlertBox_Font);  
objectCreate("HamyarAlertBoxinfo2", 155, 140,2, "My Analysis%:"+analysisdn,9,"Arial Bold", AlertBox_Font);  
 LastAlert=TimeCurrent();
}
else 
{
objectCreate("HamyarAlertBox", 126, 70,2, ")",8,"Webdings", AlertBox);  
ObjectDelete("HamyarAlertBoxinfo");
ObjectDelete("HamyarAlertBoxinfo2");

}

 objectCreate("Hamyarpanel11", 157, 1,2, "\"",120,"HamyarFont", MainPanel);  
 
double powerup_pre=Powers("Up",Time[shift+1]);
double powerdn_pre=Powers("Dn",Time[shift+1]);
double powerup_pre2=Powers("Up",Time[shift+2]);
double powerdn_pre2=Powers("Dn",Time[shift+2]);
double powerup_pre3=Powers("Up",Time[shift+3]);
double powerdn_pre3=Powers("Dn",Time[shift+3]);

     
datetime PivotDayStartTime=GlobalVariableGet("PivotDayStartTime"+WindowHandle(Symbol(),Period())+Symbol()+Period());

int bar=iBarShift(NULL,0,PivotDayStartTime,false);
bool Condition;
if (High[bar]<BuyZone&&SellZone<Low[bar]&&High[bar-1]<BuyZone&&SellZone<Low[bar-1]){objectCreate("HamyarType1", 172, 70,2, "Initial Conditions:Good",9,"Arial Bold", UpFontColor);Condition=true;}  
else  {objectCreate("HamyarType1", 172, 70,2, "Initial Conditions:Bad",9,"Arial Bold", DnFontColor); Condition=false;}  
 

   objectCreate("HamyarType2", 180, 55,2, "Type#1 Signal:None",9,"Arial Bold", MainFontColor);
   objectCreate("HamyarType3", 180, 40,2, "Type#2 Signal:None",9,"Arial Bold", MainFontColor);
   objectCreate("HamyarType4", 180, 25,2, "Type#3 Signal:None",9,"Arial Bold", MainFontColor);
   
      if (Close[shift]<BuyZone&&Close[shift]>SellZone)
      {
         if (powerup>65&&(rsilevel>50||(rsilevel<50&&stocrossup==true))&&StrToDouble(analysisup)>65.0) objectCreate("HamyarType2", 180, 55,2, "Type#1 Signal:Buy",9,"Arial Bold", UpFontColor);
         if (powerdn>65&&(rsilevel<50||(rsilevel>50&&stocrossdn==true))&&StrToDouble(analysisdn)>65.0) objectCreate("HamyarType2", 180, 55,2, "Type#1 Signal:Sell",9,"Arial Bold", DnFontColor);
      }
      else if ((Close[shift]>=BuyZone&&Close[shift]<Buytp1)||(Close[shift]>Selltp1&&Close[shift]<=SellZone))
      {
         if (powerup>70&&((stocrossup==true&&rsilevel<60)||(rsilevel>rsilevel3&&rsilevel>45))&&StrToDouble(analysisup)>70.0) objectCreate("HamyarType3", 180, 40,2, "Type#2 Signal:Buy",9,"Arial Bold", UpFontColor);
         if (powerdn>70&&((rsilevel<rsilevel3&&rsilevel<45)||(rsilevel>60&&stocrossdn==true))&&StrToDouble(analysisdn)>70.0) objectCreate("HamyarType3", 180, 40,2, "Type#2 Signal:Sell",9,"Arial Bold", DnFontColor);
      }
      
 if(powerup_pre>=85||powerup_pre2>=85||powerup_pre3>=85){if(powerup<=85&&(Predict==4||Predict==2)&&StrToDouble(analysisdn)>=50)objectCreate("HamyarType4", 180, 25,2, "Type#3 Signal:Sell",9,"Arial Bold", DnFontColor);}
 
 if (powerdn_pre>=85||powerdn_pre2>=85||powerup_pre3>=85){if(powerdn<=85&&(Predict==3||Predict==1)&&StrToDouble(analysisup)>=50)objectCreate("HamyarType4", 180, 25,2, "Type#3 Signal:Buy",9,"Arial Bold", UpFontColor);}
   
   return(0);
  }
//+------------------------------------------------------------------+

  void paintBearsNeedle(double value)
  {
  if (value == 100) objectCreateVUPos(120, 10, 55, VUmeter_LeftDegree);
  if (value >= 95 && value < 100) objectCreateVUPos(110, 9, 50, VUmeter_LeftDegree);
  if (value >= 90 && value < 95) objectCreateVUPos(100, 8, 45, VUmeter_LeftDegree);
  if (value >= 85 && value < 90) objectCreateVUPos(90, 9, 40, VUmeter_LeftDegree);
  if (value >= 80 && value < 85) objectCreateVUPos(84, 11, 35, VUmeter_LeftDegree);
  if (value >= 75 && value < 80) objectCreateVUPos(74, 13, 30, VUmeter_LeftDegree);
  if (value >= 70 && value < 75) objectCreateVUPos(66, 16, 25, VUmeter_LeftDegree);
  if (value >= 65 && value < 70) objectCreateVUPos(57, 18, 20, VUmeter_LeftDegree);
  if (value >= 60 && value < 65) objectCreateVUPos(49, 17, 15, VUmeter_LeftDegree);
  if (value >= 55 && value < 60) objectCreateVUPos(47, 25, 10, VUmeter_LeftDegree);
  }
  
  void paintCentreNeedle(double value)
  {
  if (value >= 45 && value <= 55) objectCreateVUPos(33, 36, 0, Yellow);
  }
  
  void paintBullsNeedle(double value)
  {
  if (value == 100) objectCreateVUPos(1, 112, 305, VUmeter_RightDegree);
  if (value >= 95 && value < 100) objectCreateVUPos(1, 106, 310, VUmeter_RightDegree);
  if (value >= 90 && value < 95) objectCreateVUPos(1, 100, 315, VUmeter_RightDegree);
  if (value >= 85 && value < 90) objectCreateVUPos(3, 91, 320, VUmeter_RightDegree);
  if (value >= 80 && value < 85) objectCreateVUPos(5, 82, 325, VUmeter_RightDegree);
  if (value >= 75 && value < 80) objectCreateVUPos(7, 73, 330, VUmeter_RightDegree);
  if (value >= 70 && value < 75) objectCreateVUPos(9, 64, 335, VUmeter_RightDegree);
  if (value >= 65 && value < 70) objectCreateVUPos(12, 58, 340, VUmeter_RightDegree);
  if (value >= 60 && value < 65) objectCreateVUPos(18, 55, 345, VUmeter_RightDegree);
  if (value >= 55 && value < 60) objectCreateVUPos(23, 46, 350, VUmeter_RightDegree);
  }
  
  
  
  

 void Createobject()
  {
    // Bulls/Bears VU Meter -------------------------------------
  
  objectCreate("VUMainPanel", 5, 0,1, "B",130,"HamyarFont", VUmeter_Border);  
  objectCreate("VUMainPanel1", 19, 18,1, "B",110,"HamyarFont", VUmeter_Back);  
  objectCreate("VUMainPanelNumberLeft", 18, 8,1, "C",115,"HamyarFont", VUmeter_LeftDegree);  
  objectCreate("VUMainPanelNumberRight", 14, 9,1, "D",115,"HamyarFont", VUmeter_RightDegree);  
  objectCreate("VUMainBear100", 172, 35,1, "100",9,"Digiface", VUmeter_LeftDegree);  
  objectCreate("VUMainBull100", 2, 35,1, "100",9,"Digiface", VUmeter_RightDegree);  
  objectCreate("VUMain50", 90, 2,1, "50",9,"Digiface", Yellow);  
  objectCreate("VUMainBull75", 39, 9,1, "75",9,"Digiface", VUmeter_RightDegree);  
  objectCreate("VUMainBear75", 137, 9,1, "75",9,"Digiface", VUmeter_LeftDegree);  
  
  
}



void objectCreate(string lblname, int xOffset, int yOffset,int iCorner, string Text, int FontSize, string FontName,color txtcolor)  
{      
   if (ObjectFind( lblname)>0) ObjectDelete(lblname);
   ObjectCreate(lblname,OBJ_LABEL         , 0, 0, 0 );
   ObjectSet   (lblname,OBJPROP_CORNER    , iCorner);
   ObjectSet   (lblname,OBJPROP_XDISTANCE , xOffset); 
   ObjectSet   (lblname,OBJPROP_YDISTANCE , yOffset);
   ObjectSet   (lblname,OBJPROP_BACK      , false );
   ObjectSetText( lblname, Text, FontSize, FontName, txtcolor );   
}  
void objectCreateVUPos(int xOffset, int yOffset,double angle ,color txtcolor)  
{      
   if (ObjectFind( "VUPos")>0) ObjectDelete("VUPos");
   ObjectCreate("VUPos",OBJ_LABEL         , 0, 0, 0 );
   ObjectSet   ("VUPos",OBJPROP_CORNER    , 1);
   ObjectSet   ("VUPos",OBJPROP_XDISTANCE , xOffset); 
   ObjectSet   ("VUPos",OBJPROP_YDISTANCE , yOffset);
   ObjectSet   ("VUPos",OBJPROP_BACK      , false );
   ObjectSet   ("VUPos",OBJPROP_ANGLE , angle);
  
   ObjectSetText( "VUPos", "T", 75, "HamyarFont", txtcolor );   
  
}  

//+------------------------------------------------------------------+
string FormatDateTime(int nYear,int nMonth,int nDay,int nHour,int nMin,int nSec)
  {
   string sMonth,sDay,sHour,sMin,sSec;
//----
   sMonth=100+nMonth;
   sMonth=StringSubstr(sMonth,1);
   sDay=100+nDay;
   sDay=StringSubstr(sDay,1);
   sHour=100+nHour;
   sHour=StringSubstr(sHour,1);
   sMin=100+nMin;
   sMin=StringSubstr(sMin,1);
   sSec=100+nSec;
   sSec=StringSubstr(sSec,1);
//----
   return(StringConcatenate(nYear,".",sMonth,".",sDay," ",sHour,":",sMin,":",sSec));
  }
//--------------------

double Powers(string cmd,datetime bar)
{



int       FastMAPeriod          =           14;  
int       MediumMAPeriod        =           50;  
int       SlowMAPeriod          =          100;  
int       MAMethod              =     MODE_EMA;  
int       MAPrice               =  PRICE_CLOSE; 


int       CCIPeriod             =           14;  
int       CCIPrice              =  PRICE_CLOSE;  


int       MACDFast              =           12;  
int       MACDSlow              =           26;  
int       MACDSignal            =            9;  


int       ADXPeriod             =           14;  
int       ADXPrice              =  PRICE_CLOSE;  


int       BULLSPeriod           =           13;  
int       BULLSPrice            =  PRICE_CLOSE;  


int       BEARSPeriod           =           13; 
int       BEARSPrice            =  PRICE_CLOSE;  


int       STOKPeriod            =            5;  
int       STODPeriod            =            3;  
int       STOSlowing            =            3;  


int       RSIPeriod             =           14;  


int       FIPeriod              =           14;  
int       FIMethod              =     MODE_SMA;  
int       FIPrice               =  PRICE_CLOSE;  


int       MOMPeriod             =           14;  
int       MOMPrice              =  PRICE_CLOSE; 


int       DEMPeriod             =           14;  


double    shift_indicators      =                   0;  
double UP_1, UP_2, UP_3, UP_4, UP_5, UP_6, UP_7, UP_8, UP_9, UP_10;
double UP_11, UP_12, UP_13, UP_14, UP_15, UP_16, UP_17, UP_18, UP_19, UP_20;
double UP_21, UP_22, UP_23, UP_24, UP_25, UP_26, UP_27, UP_28, UP_29, UP_30;
double UP_31, UP_32, UP_33, UP_34, UP_35, UP_36, UP_37, UP_38, UP_39, UP_40;
double UP_41, UP_42, UP_43, UP_44, UP_45, UP_46, UP_47, UP_48, UP_49, UP_50;
double UP_51, UP_52, UP_53, UP_54, UP_55, UP_56, UP_57, UP_58, UP_59, UP_60;
double UP_61, UP_62, UP_63, UP_64;

double DOWN_1, DOWN_2, DOWN_3, DOWN_4, DOWN_5, DOWN_6, DOWN_7, DOWN_8, DOWN_9, DOWN_10;
double DOWN_11, DOWN_12, DOWN_13, DOWN_14, DOWN_15, DOWN_16, DOWN_17, DOWN_18, DOWN_19, DOWN_20;
double DOWN_21, DOWN_22, DOWN_23, DOWN_24, DOWN_25, DOWN_26, DOWN_27, DOWN_28, DOWN_29, DOWN_30;
double DOWN_31, DOWN_32, DOWN_33, DOWN_34, DOWN_35, DOWN_36, DOWN_37, DOWN_38, DOWN_39, DOWN_40;
double DOWN_41, DOWN_42, DOWN_43, DOWN_44, DOWN_45, DOWN_46, DOWN_47, DOWN_48, DOWN_49, DOWN_50;
double DOWN_51, DOWN_52, DOWN_53, DOWN_54, DOWN_55, DOWN_56, DOWN_57, DOWN_58, DOWN_59, DOWN_60;
double DOWN_61, DOWN_62, DOWN_63, DOWN_64;

double UP_65, UP_66, UP_67, UP_68, UP_69, UP_70;
double UP_71, UP_72, UP_73, UP_74, UP_75, UP_76, UP_77, UP_78, UP_79, UP_80;
double UP_81, UP_82, UP_83, UP_84, UP_85, UP_86, UP_87, UP_88, UP_89, UP_90;
double UP_91, UP_92, UP_93, UP_94, UP_95, UP_96, UP_97, UP_98, UP_99, UP_100;
double UP_101, UP_102, UP_103, UP_104, UP_105, UP_106, UP_107, UP_108, UP_109, UP_110;
double UP_111, UP_112;

double DOWN_65, DOWN_66, DOWN_67, DOWN_68, DOWN_69, DOWN_70;
double DOWN_71, DOWN_72, DOWN_73, DOWN_74, DOWN_75, DOWN_76, DOWN_77, DOWN_78, DOWN_79, DOWN_80;
double DOWN_81, DOWN_82, DOWN_83, DOWN_84, DOWN_85, DOWN_86, DOWN_87, DOWN_88, DOWN_89, DOWN_90;
double DOWN_91, DOWN_92, DOWN_93, DOWN_94, DOWN_95, DOWN_96, DOWN_97, DOWN_98, DOWN_99, DOWN_100;
double DOWN_101, DOWN_102, DOWN_103, DOWN_104, DOWN_105, DOWN_106, DOWN_107, DOWN_108, DOWN_109, DOWN_110;
double DOWN_111, DOWN_112;

double count_m1, count_m5, count_m15, count_m30, count_h1, count_h4, count_d1;

count_m1 = 1; 
count_m5 = 1; 
 count_m15 = 1; 
 count_m30 = 1; 
count_h1 = 1; 
count_h4 = 1; 
 count_d1 = 1; 
  
  double count_tf = count_m1 + count_m5 + count_m15 + count_m30 + count_h1 + count_h4 + count_d1;
  double TotalPoint = 7;
 
   

  double shift_1, shift_5, shift_15, shift_30, shift_60, shift_240, shift_1440, shift_10080;
    shift_1=iBarShift(NULL,PERIOD_M1,bar,false);
    shift_5=iBarShift(NULL,PERIOD_M5,bar,false);
    shift_15=iBarShift(NULL,PERIOD_M15,bar,false);
    shift_30=iBarShift(NULL,PERIOD_M30,bar,false);
    shift_60=iBarShift(NULL,PERIOD_H1,bar,false);
    shift_240=iBarShift(NULL,PERIOD_H4,bar,false);
    shift_1440=iBarShift(NULL,PERIOD_D1,bar,false);
    shift_10080=iBarShift(NULL,PERIOD_W1,bar,false);
   
// Indicator (Moving Average)

   // FAST
   
 
   
   double FastMA_1_1 = iMA(NULL,PERIOD_M1,FastMAPeriod,0,MAMethod,MAPrice,shift_1);
   double FastMA_2_1 = iMA(NULL,PERIOD_M1,FastMAPeriod,0,MAMethod,MAPrice,shift_1+1);
   if ((FastMA_1_1 > FastMA_2_1)) { UP_1 = 1; DOWN_1 = 0; }
   if ((FastMA_1_1 < FastMA_2_1)) { UP_1 = 0; DOWN_1 = 1; }
  
  
   
   double FastMA_1_5 = iMA(NULL,PERIOD_M5,FastMAPeriod,0,MAMethod,MAPrice,shift_5);
   double FastMA_2_5 = iMA(NULL,PERIOD_M5,FastMAPeriod,0,MAMethod,MAPrice,shift_5+1);
   if ((FastMA_1_5 > FastMA_2_5)) { UP_2 = 1; DOWN_2 = 0; }
   if ((FastMA_1_5 < FastMA_2_5)) { UP_2 = 0; DOWN_2 = 1; }
   
   
     
   double FastMA_1_15 = iMA(NULL,PERIOD_M15,FastMAPeriod,0,MAMethod,MAPrice,shift_15);
   double FastMA_2_15 = iMA(NULL,PERIOD_M15,FastMAPeriod,0,MAMethod,MAPrice,shift_15+1);
   if ((FastMA_1_15 > FastMA_2_15)) { UP_3 = 1; DOWN_3 = 0; }
   if ((FastMA_1_15 < FastMA_2_15)) { UP_3 = 0; DOWN_3 = 1; }
   
   
    
   double FastMA_1_30 = iMA(NULL,PERIOD_M30,FastMAPeriod,0,MAMethod,MAPrice,shift_30);
   double FastMA_2_30 = iMA(NULL,PERIOD_M30,FastMAPeriod,0,MAMethod,MAPrice,shift_30+1);
   if ((FastMA_1_30 > FastMA_2_30)) { UP_4 = 1; DOWN_4 = 0; }
   if ((FastMA_1_30 < FastMA_2_30)) { UP_4 = 0; DOWN_4 = 1; }
   
   
   
   double FastMA_1_60 = iMA(NULL,PERIOD_H1,FastMAPeriod,0,MAMethod,MAPrice,shift_60);
   double FastMA_2_60 = iMA(NULL,PERIOD_H1,FastMAPeriod,0,MAMethod,MAPrice,shift_60+1);
   if ((FastMA_1_60 > FastMA_2_60)) { UP_5 = 1; DOWN_5 = 0; }
   if ((FastMA_1_60 < FastMA_2_60)) { UP_5 = 0; DOWN_5 = 1; }
   
   
  
   double FastMA_1_240 = iMA(NULL,PERIOD_H4,FastMAPeriod,0,MAMethod,MAPrice,shift_240);
   double FastMA_2_240 = iMA(NULL,PERIOD_H4,FastMAPeriod,0,MAMethod,MAPrice,shift_240+1);
   if ((FastMA_1_240 > FastMA_2_240)) { UP_6 = 1; DOWN_6 = 0; }
   if ((FastMA_1_240 < FastMA_2_240)) { UP_6 = 0; DOWN_6 = 1; }
   
   
  
   
   double FastMA_1_1440 = iMA(NULL,PERIOD_D1,FastMAPeriod,0,MAMethod,MAPrice,shift_1440);
   double FastMA_2_1440 = iMA(NULL,PERIOD_D1,FastMAPeriod,0,MAMethod,MAPrice,shift_1440+1);
   if ((FastMA_1_1440 > FastMA_2_1440)) { UP_7 = 1; DOWN_7 = 0; }
   if ((FastMA_1_1440 < FastMA_2_1440)) { UP_7 = 0; DOWN_7 = 1; }
   
   
   
   // MEDIUM
   

  
   
   double MediumMA_1_1 = iMA(NULL,PERIOD_M1,MediumMAPeriod,0,MAMethod,MAPrice,shift_1);
   double MediumMA_2_1 = iMA(NULL,PERIOD_M1,MediumMAPeriod,0,MAMethod,MAPrice,shift_1+1);
   if ((MediumMA_1_1 > MediumMA_2_1)) { UP_9 = 1; DOWN_9 = 0; }
   if ((MediumMA_1_1 < MediumMA_2_1)) { UP_9 = 0; DOWN_9 = 1; }
  
   double MediumMA_1_5 = iMA(NULL,PERIOD_M5,MediumMAPeriod,0,MAMethod,MAPrice,shift_5);
   double MediumMA_2_5 = iMA(NULL,PERIOD_M5,MediumMAPeriod,0,MAMethod,MAPrice,shift_5+1);
   if ((MediumMA_1_5 > MediumMA_2_5)) { UP_10 = 1; DOWN_10 = 0; }
   if ((MediumMA_1_5 < MediumMA_2_5)) { UP_10 = 0; DOWN_10 = 1; }
   
   

   double MediumMA_1_15 = iMA(NULL,PERIOD_M15,MediumMAPeriod,0,MAMethod,MAPrice,shift_15);
   double MediumMA_2_15 = iMA(NULL,PERIOD_M15,MediumMAPeriod,0,MAMethod,MAPrice,shift_15+1);
   if ((MediumMA_1_15 > MediumMA_2_15)) { UP_11 = 1; DOWN_11 = 0; }
   if ((MediumMA_1_15 < MediumMA_2_15)) { UP_11 = 0; DOWN_11 = 1; }
   
   
  
  
   double MediumMA_1_30 = iMA(NULL,PERIOD_M30,MediumMAPeriod,0,MAMethod,MAPrice,shift_30);
   double MediumMA_2_30 = iMA(NULL,PERIOD_M30,MediumMAPeriod,0,MAMethod,MAPrice,shift_30+1);
   if ((MediumMA_1_30 > MediumMA_2_30)) { UP_12 = 1; DOWN_12 = 0; }
   if ((MediumMA_1_30 < MediumMA_2_30)) { UP_12 = 0; DOWN_12 = 1; }
   
   
   
   
   double MediumMA_1_60 = iMA(NULL,PERIOD_H1,MediumMAPeriod,0,MAMethod,MAPrice,shift_60);
   double MediumMA_2_60 = iMA(NULL,PERIOD_H1,MediumMAPeriod,0,MAMethod,MAPrice,shift_60+1);
   if ((MediumMA_1_60 > MediumMA_2_60)) { UP_13 = 1; DOWN_13 = 0; }
   if ((MediumMA_1_60 < MediumMA_2_60)) { UP_13 = 0; DOWN_13 = 1; }
   
   
   

   double MediumMA_1_240 = iMA(NULL,PERIOD_H4,MediumMAPeriod,0,MAMethod,MAPrice,shift_240);
   double MediumMA_2_240 = iMA(NULL,PERIOD_H4,MediumMAPeriod,0,MAMethod,MAPrice,shift_240+1);
   if ((MediumMA_1_240 > MediumMA_2_240)) { UP_14 = 1; DOWN_14 = 0; }
   if ((MediumMA_1_240 < MediumMA_2_240)) { UP_14 = 0; DOWN_14 = 1; }
   
   
  

   double MediumMA_1_1440 = iMA(NULL,PERIOD_D1,MediumMAPeriod,0,MAMethod,MAPrice,shift_1440);
   double MediumMA_2_1440 = iMA(NULL,PERIOD_D1,MediumMAPeriod,0,MAMethod,MAPrice,shift_1440+1);
   if ((MediumMA_1_1440 > MediumMA_2_1440)) { UP_15 = 1; DOWN_15 = 0; }
   if ((MediumMA_1_1440 < MediumMA_2_1440)) { UP_15 = 0; DOWN_15 = 1; }
  
   
   
   // SLOW
   

  

   double SlowMA_1_1 = iMA(NULL,PERIOD_M1,SlowMAPeriod,0,MAMethod,MAPrice,shift_1);
   double SlowMA_2_1 = iMA(NULL,PERIOD_M1,SlowMAPeriod,0,MAMethod,MAPrice,shift_1+1);
   if ((SlowMA_1_1 > SlowMA_2_1)) { UP_17 = 1; DOWN_17 = 0; }
   if ((SlowMA_1_1 < SlowMA_2_1)) { UP_17 = 0; DOWN_17 = 1; }
   
   
   

   double SlowMA_1_5 = iMA(NULL,PERIOD_M5,SlowMAPeriod,0,MAMethod,MAPrice,shift_5);
   double SlowMA_2_5 = iMA(NULL,PERIOD_M5,SlowMAPeriod,0,MAMethod,MAPrice,shift_5+1);
   if ((SlowMA_1_5 > SlowMA_2_5)) { UP_18 = 1; DOWN_18 = 0; }
   if ((SlowMA_1_5 < SlowMA_2_5)) { UP_18 = 0; DOWN_18 = 1; }
   
   
   

   double SlowMA_1_15 = iMA(NULL,PERIOD_M15,SlowMAPeriod,0,MAMethod,MAPrice,shift_15);
   double SlowMA_2_15 = iMA(NULL,PERIOD_M15,SlowMAPeriod,0,MAMethod,MAPrice,shift_15+1);
   if ((SlowMA_1_15 > SlowMA_2_15)) { UP_19 = 1; DOWN_19 = 0; }
   if ((SlowMA_1_15 < SlowMA_2_15)) { UP_19 = 0; DOWN_19 = 1; }
   
   
  

   double SlowMA_1_30 = iMA(NULL,PERIOD_M30,SlowMAPeriod,0,MAMethod,MAPrice,shift_30);
   double SlowMA_2_30 = iMA(NULL,PERIOD_M30,SlowMAPeriod,0,MAMethod,MAPrice,shift_30+1);
   if ((SlowMA_1_30 > SlowMA_2_30)) { UP_20 = 1; DOWN_20 = 0; }
   if ((SlowMA_1_30 < SlowMA_2_30)) { UP_20 = 0; DOWN_20 = 1; }
   
   
   

   double SlowMA_1_60 = iMA(NULL,PERIOD_H1,SlowMAPeriod,0,MAMethod,MAPrice,shift_60);
   double SlowMA_2_60 = iMA(NULL,PERIOD_H1,SlowMAPeriod,0,MAMethod,MAPrice,shift_60+1);
   if ((SlowMA_1_60 > SlowMA_2_60)) { UP_21 = 1; DOWN_21 = 0; }
   if ((SlowMA_1_60 < SlowMA_2_60)) { UP_21 = 0; DOWN_21 = 1; }
   
   
   

   double SlowMA_1_240 = iMA(NULL,PERIOD_H4,SlowMAPeriod,0,MAMethod,MAPrice,shift_240);
   double SlowMA_2_240 = iMA(NULL,PERIOD_H4,SlowMAPeriod,0,MAMethod,MAPrice,shift_240+1);
   if ((SlowMA_1_240 > SlowMA_2_240)) { UP_22 = 1; DOWN_22 = 0; }
   if ((SlowMA_1_240 < SlowMA_2_240)) { UP_22 = 0; DOWN_22 = 1; }
   
   
  

   double SlowMA_1_1440 = iMA(NULL,PERIOD_D1,SlowMAPeriod,0,MAMethod,MAPrice,shift_1440);
   double SlowMA_2_1440 = iMA(NULL,PERIOD_D1,SlowMAPeriod,0,MAMethod,MAPrice,shift_1440+1);
   if ((SlowMA_1_1440 > SlowMA_2_1440)) { UP_23 = 1; DOWN_23 = 0; }
   if ((SlowMA_1_1440 < SlowMA_2_1440)) { UP_23 = 0; DOWN_23 = 1; }
   
   
   
// Indicator (CCI)
   

  

   double CCI_1=iCCI(NULL,PERIOD_M1,CCIPeriod,CCIPrice,shift_1);
   if ((CCI_1 > 0)) { UP_25 = 1; DOWN_25 = 0; }
   if ((CCI_1 < 0)) { UP_25 = 0; DOWN_25 = 1; }
   
   
   

   double CCI_5=iCCI(NULL,PERIOD_M5,CCIPeriod,CCIPrice,shift_5);
   if ((CCI_5 > 0)) { UP_26 = 1; DOWN_26 = 0; }
   if ((CCI_5 < 0)) { UP_26 = 0; DOWN_26 = 1; }
   
   
   

   double CCI_15=iCCI(NULL,PERIOD_M15,CCIPeriod,CCIPrice,shift_15);
   if ((CCI_15 > 0)) { UP_27 = 1; DOWN_27 = 0; }
   if ((CCI_15 < 0)) { UP_27 = 0; DOWN_27 = 1; }
   
   
  

   double CCI_30=iCCI(NULL,PERIOD_M30,CCIPeriod,CCIPrice,shift_30);
   if ((CCI_30 > 0)) { UP_28 = 1; DOWN_28 = 0; }
   if ((CCI_30 < 0)) { UP_28 = 0; DOWN_28 = 1; }
   
   
   

   double CCI_60=iCCI(NULL,PERIOD_H1,CCIPeriod,CCIPrice,shift_60);
   if ((CCI_60 > 0)) { UP_29 = 1; DOWN_29 = 0; }
   if ((CCI_60 < 0)) { UP_29 = 0; DOWN_29 = 1; }
   
   
   

   double CCI_240=iCCI(NULL,PERIOD_H4,CCIPeriod,CCIPrice,shift_240);
   if ((CCI_240 > 0)) { UP_30 = 1; DOWN_30 = 0; }
   if ((CCI_240 < 0)) { UP_30 = 0; DOWN_30 = 1; }
   
   
  

   double CCI_1440=iCCI(NULL,PERIOD_D1,CCIPeriod,CCIPrice,shift_1440);
   if ((CCI_1440 > 0)) { UP_31 = 1; DOWN_31 = 0; }
   if ((CCI_1440 < 0)) { UP_31 = 0; DOWN_31 = 1; }
   
   
   
// Indicator (MACD)
   

  

   double MACD_m_1=iMACD(NULL,PERIOD_M1,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_MAIN,shift_1);
   double MACD_s_1=iMACD(NULL,PERIOD_M1,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_SIGNAL,shift_1);
   if ((MACD_m_1 > MACD_s_1)) { UP_33 = 1; DOWN_33 = 0; }
   if ((MACD_m_1 < MACD_s_1)) { UP_33 = 0; DOWN_33 = 1; }
   
   
   

   double MACD_m_5=iMACD(NULL,PERIOD_M5,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_MAIN,shift_5);
   double MACD_s_5=iMACD(NULL,PERIOD_M5,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_SIGNAL,shift_5);
   if ((MACD_m_5 > MACD_s_5)) { UP_34 = 1; DOWN_34 = 0; }
   if ((MACD_m_5 < MACD_s_5)) { UP_34 = 0; DOWN_34 = 1; }
   
   
   

   double MACD_m_15=iMACD(NULL,PERIOD_M15,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_MAIN,shift_15);
   double MACD_s_15=iMACD(NULL,PERIOD_M15,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_SIGNAL,shift_15);
   if ((MACD_m_15 > MACD_s_15)) { UP_35 = 1; DOWN_35 = 0; }
   if ((MACD_m_15 < MACD_s_15)) { UP_35 = 0; DOWN_35 = 1; }
   
   
  

   double MACD_m_30=iMACD(NULL,PERIOD_M30,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_MAIN,shift_30);
   double MACD_s_30=iMACD(NULL,PERIOD_M30,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_SIGNAL,shift_30);
   if ((MACD_m_30 > MACD_s_30)) { UP_36 = 1; DOWN_36 = 0; }
   if ((MACD_m_30 < MACD_s_30)) { UP_36 = 0; DOWN_36 = 1; }
   
   
   

   double MACD_m_60=iMACD(NULL,PERIOD_H1,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_MAIN,shift_60);
   double MACD_s_60=iMACD(NULL,PERIOD_H1,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_SIGNAL,shift_60);
   if ((MACD_m_60 > MACD_s_60)) { UP_37 = 1; DOWN_37 = 0; }
   if ((MACD_m_60 < MACD_s_60)) { UP_37 = 0; DOWN_37 = 1; }
   
   
   

   double MACD_m_240=iMACD(NULL,PERIOD_H4,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_MAIN,shift_240);
   double MACD_s_240=iMACD(NULL,PERIOD_H4,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_SIGNAL,shift_240);
   if ((MACD_m_240 > MACD_s_240)) { UP_38 = 1; DOWN_38 = 0; }
   if ((MACD_m_240 < MACD_s_240)) { UP_38 = 0; DOWN_38 = 1; }
   
   
  

   double MACD_m_1440=iMACD(NULL,PERIOD_D1,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_MAIN,shift_1440);
   double MACD_s_1440=iMACD(NULL,PERIOD_D1,MACDFast,MACDSlow,MACDSignal,PRICE_CLOSE,MODE_SIGNAL,shift_1440);
   if ((MACD_m_1440 > MACD_s_1440)) { UP_39 = 1; DOWN_39 = 0; }
   if ((MACD_m_1440 < MACD_s_1440)) { UP_39 = 0; DOWN_39 = 1; }
   
   
   
// Indicator (ADX)
   
 
  

   double ADX_plus_1=iADX(NULL,PERIOD_M1,ADXPeriod,ADXPrice,MODE_PLUSDI,shift_1);
   double ADX_minus_1=iADX(NULL,PERIOD_M1,ADXPeriod,ADXPrice,MODE_MINUSDI,shift_1);
   if ((ADX_plus_1 > ADX_minus_1)) { UP_41 = 1; DOWN_41 = 0; }
   if ((ADX_plus_1 < ADX_minus_1)) { UP_41 = 0; DOWN_41 = 1; }
   
   
   

   double ADX_plus_5=iADX(NULL,PERIOD_M5,ADXPeriod,ADXPrice,MODE_PLUSDI,shift_5);
   double ADX_minus_5=iADX(NULL,PERIOD_M5,ADXPeriod,ADXPrice,MODE_MINUSDI,shift_5);
   if ((ADX_plus_5 > ADX_minus_5)) { UP_42 = 1; DOWN_42 = 0; }
   if ((ADX_plus_5 < ADX_minus_5)) { UP_42 = 0; DOWN_42 = 1; }
   
   
   

   double ADX_plus_15=iADX(NULL,PERIOD_M15,ADXPeriod,ADXPrice,MODE_PLUSDI,shift_15);
   double ADX_minus_15=iADX(NULL,PERIOD_M15,ADXPeriod,ADXPrice,MODE_MINUSDI,shift_15);
   if ((ADX_plus_15 > ADX_minus_15)) { UP_43 = 1; DOWN_43 = 0; }
   if ((ADX_plus_15 < ADX_minus_15)) { UP_43 = 0; DOWN_43 = 1; }
   
   
  

   double ADX_plus_30=iADX(NULL,PERIOD_M30,ADXPeriod,ADXPrice,MODE_PLUSDI,shift_30);
   double ADX_minus_30=iADX(NULL,PERIOD_M30,ADXPeriod,ADXPrice,MODE_MINUSDI,shift_30);
   if ((ADX_plus_30 > ADX_minus_30)) { UP_44 = 1; DOWN_44 = 0; }
   if ((ADX_plus_30 < ADX_minus_30)) { UP_44 = 0; DOWN_44 = 1; }
   
   
   

   double ADX_plus_60=iADX(NULL,PERIOD_H1,ADXPeriod,ADXPrice,MODE_PLUSDI,shift_60);
   double ADX_minus_60=iADX(NULL,PERIOD_H1,ADXPeriod,ADXPrice,MODE_MINUSDI,shift_60);
   if ((ADX_plus_60 > ADX_minus_60)) { UP_45 = 1; DOWN_45 = 0; }
   if ((ADX_plus_60 < ADX_minus_60)) { UP_45 = 0; DOWN_45 = 1; }
   
   
   

   double ADX_plus_240=iADX(NULL,PERIOD_H4,ADXPeriod,ADXPrice,MODE_PLUSDI,shift_240);
   double ADX_minus_240=iADX(NULL,PERIOD_H4,ADXPeriod,ADXPrice,MODE_MINUSDI,shift_240);
   if ((ADX_plus_240 > ADX_minus_240)) { UP_46 = 1; DOWN_46 = 0; }
   if ((ADX_plus_240 < ADX_minus_240)) { UP_46 = 0; DOWN_46 = 1; }
   
   
  

   double ADX_plus_1440=iADX(NULL,PERIOD_D1,ADXPeriod,ADXPrice,MODE_PLUSDI,shift_1440);
   double ADX_minus_1440=iADX(NULL,PERIOD_D1,ADXPeriod,ADXPrice,MODE_MINUSDI,shift_1440);
   if ((ADX_plus_1440 > ADX_minus_1440)) { UP_47 = 1; DOWN_47 = 0; }
   if ((ADX_plus_1440 < ADX_minus_1440)) { UP_47 = 0; DOWN_47 = 1; }
   
  
   
// Indicator (BULLS)
   

  

   double bulls_1=iBullsPower(NULL,PERIOD_M1,BULLSPeriod,BULLSPrice,shift_1);
   if ((bulls_1 > 0)) { UP_49 = 1; DOWN_49 = 0; }
   if ((bulls_1 < 0)) { UP_49 = 0; DOWN_49 = 1; }
   
   
   

   double bulls_5=iBullsPower(NULL,PERIOD_M5,BULLSPeriod,BULLSPrice,shift_5);
   if ((bulls_5 > 0)) { UP_50 = 1; DOWN_50 = 0; }
   if ((bulls_5 < 0)) { UP_50 = 0; DOWN_50 = 1; }
   
   
   

   double bulls_15=iBullsPower(NULL,PERIOD_M15,BULLSPeriod,BULLSPrice,shift_15);
   if ((bulls_15 > 0)) { UP_51 = 1; DOWN_51 = 0; }
   if ((bulls_15 < 0)) { UP_51 = 0; DOWN_51 = 1; }
   
   
  

   double bulls_30=iBullsPower(NULL,PERIOD_M30,BULLSPeriod,BULLSPrice,shift_30);
   if ((bulls_30 > 0)) { UP_52 = 1; DOWN_52 = 0; }
   if ((bulls_30 < 0)) { UP_52 = 0; DOWN_52 = 1; }
  
   
   

   double bulls_60=iBullsPower(NULL,PERIOD_H1,BULLSPeriod,BULLSPrice,shift_60);
   if ((bulls_60 > 0)) { UP_53 = 1; DOWN_53 = 0; }
   if ((bulls_60 < 0)) { UP_53 = 0; DOWN_53 = 1; }
   
   
   

   double bulls_240=iBullsPower(NULL,PERIOD_H4,BULLSPeriod,BULLSPrice,shift_240);
   if ((bulls_240 > 0)) { UP_54 = 1; DOWN_54 = 0; }
   if ((bulls_240 < 0)) { UP_54 = 0; DOWN_54 = 1; }
   
   
  

   double bulls_1440=iBullsPower(NULL,PERIOD_D1,BULLSPeriod,BULLSPrice,shift_1440);
   if ((bulls_1440 > 0)) { UP_55 = 1; DOWN_55 = 0; }
   if ((bulls_1440 < 0)) { UP_55 = 0; DOWN_55 = 1; }
   
   
   
// Indicator (BEARS)
   
 
  

   double bears_1=iBearsPower(NULL,PERIOD_M1,BEARSPeriod,BEARSPrice,shift_1);
   if ((bears_1 > 0)) { UP_57 = 1; DOWN_57 = 0; }
   if ((bears_1 < 0)) { UP_57 = 0; DOWN_57 = 1; }
   
   
   

   double bears_5=iBearsPower(NULL,PERIOD_M5,BEARSPeriod,BEARSPrice,shift_5);
   if ((bears_5 > 0)) { UP_58 = 1; DOWN_58 = 0; }
   if ((bears_5 < 0)) { UP_58 = 0; DOWN_58 = 1; }
   
   
   

   double bears_15=iBearsPower(NULL,PERIOD_M15,BEARSPeriod,BEARSPrice,shift_15);
   if ((bears_15 > 0)) { UP_59 = 1; DOWN_59 = 0; }
   if ((bears_15 < 0)) { UP_59 = 0; DOWN_59 = 1; }
   
   
  

   double bears_30=iBearsPower(NULL,PERIOD_M30,BEARSPeriod,BEARSPrice,shift_30);
   if ((bears_30 > 0)) { UP_60 = 1; DOWN_60 = 0; }
   if ((bears_30 < 0)) { UP_60 = 0; DOWN_60 = 1; }
   
   
   

   double bears_60=iBearsPower(NULL,PERIOD_H1,BEARSPeriod,BEARSPrice,shift_60);
   if ((bears_60 > 0)) { UP_61 = 1; DOWN_61 = 0; }
   if ((bears_60 < 0)) { UP_61 = 0; DOWN_61 = 1; }
   
   
   

   double bears_240=iBearsPower(NULL,PERIOD_H4,BEARSPeriod,BEARSPrice,shift_240);
   if ((bears_240 > 0)) { UP_62 = 1; DOWN_62 = 0; }
   if ((bears_240 < 0)) { UP_62 = 0; DOWN_62 = 1; }
   
   
  

   double bears_1440=iBearsPower(NULL,PERIOD_D1,BEARSPeriod,BEARSPrice,shift_1440);
   if ((bears_1440 > 0)) { UP_63 = 1; DOWN_63 = 0; }
   if ((bears_1440 < 0)) { UP_63 = 0; DOWN_63 = 1; }
   
   
   
// Indicator (STOCH)

  
  

   double stoch_m_1=iStochastic(NULL,PERIOD_M1,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_MAIN,shift_1);
   double stoch_s_1=iStochastic(NULL,PERIOD_M1,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_SIGNAL,shift_1);
   if (stoch_m_1 >= stoch_s_1) { UP_65 = 1; DOWN_65 = 0; }
   if (stoch_m_1 < stoch_s_1) { UP_65 = 0; DOWN_65 = 1; }
   
   
   

   double stoch_m_5=iStochastic(NULL,PERIOD_M5,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_MAIN,shift_5);
   double stoch_s_5=iStochastic(NULL,PERIOD_M5,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_SIGNAL,shift_5);
   if (stoch_m_5 >= stoch_s_5) { UP_66 = 1; DOWN_66 = 0; }
   if (stoch_m_5 < stoch_s_5) { UP_66 = 0; DOWN_66 = 1; }
   
   
   

   double stoch_m_15=iStochastic(NULL,PERIOD_M15,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_MAIN,shift_15);
   double stoch_s_15=iStochastic(NULL,PERIOD_M15,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_SIGNAL,shift_15);
   if (stoch_m_15 >= stoch_s_15) { UP_67 = 1; DOWN_67 = 0; }
   if (stoch_m_15 < stoch_s_15) { UP_67 = 0; DOWN_67 = 1; }
   
   
  

   double stoch_m_30=iStochastic(NULL,PERIOD_M30,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_MAIN,shift_30);
   double stoch_s_30=iStochastic(NULL,PERIOD_M30,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_SIGNAL,shift_30);
   if (stoch_m_30 >= stoch_s_30) { UP_68 = 1; DOWN_68 = 0; }
   if (stoch_m_30 < stoch_s_30) { UP_68 = 0; DOWN_68 = 1; }
   
   
   

   double stoch_m_60=iStochastic(NULL,PERIOD_H1,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_MAIN,shift_60);
   double stoch_s_60=iStochastic(NULL,PERIOD_H1,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_SIGNAL,shift_60);
   if (stoch_m_60 >= stoch_s_60) { UP_69 = 1; DOWN_69 = 0; }
   if (stoch_m_60 < stoch_s_60) { UP_69 = 0; DOWN_69 = 1; }
   
   
   

   double stoch_m_240=iStochastic(NULL,PERIOD_H4,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_MAIN,shift_240);
   double stoch_s_240=iStochastic(NULL,PERIOD_H4,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_SIGNAL,shift_240);
   if (stoch_m_240 >= stoch_s_240) { UP_70 = 1; DOWN_70 = 0; }
   if (stoch_m_240 < stoch_s_240) { UP_70 = 0; DOWN_70 = 1; }
   
   
  

   double stoch_m_1440=iStochastic(NULL,PERIOD_D1,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_MAIN,shift_1440);
   double stoch_s_1440=iStochastic(NULL,PERIOD_D1,STOKPeriod,STODPeriod,STOSlowing,MODE_SMA,1,MODE_SIGNAL,shift_1440);
   if (stoch_m_1440 >= stoch_s_1440) { UP_71 = 1; DOWN_71 = 0; }
   if (stoch_m_1440 < stoch_s_1440) { UP_71 = 0; DOWN_71 = 1; }
   
   
   
// Indicator (RSI)
   

  

   double rsi_1=iRSI(NULL,PERIOD_M1,RSIPeriod,PRICE_CLOSE,shift_1);
   if (rsi_1 >= 50) { UP_73 = 1; DOWN_73 = 0; }
   if (rsi_1 < 50) { UP_73 = 0; DOWN_73 = 1; }
   
   
   

   double rsi_5=iRSI(NULL,PERIOD_M5,RSIPeriod,PRICE_CLOSE,shift_5);
   if (rsi_5 >= 50) { UP_74 = 1; DOWN_74 = 0; }
   if (rsi_5 < 50) { UP_74 = 0; DOWN_74 = 1; }
   
   
   

   double rsi_15=iRSI(NULL,PERIOD_M15,RSIPeriod,PRICE_CLOSE,shift_15);
   if (rsi_15 >= 50) { UP_75 = 1; DOWN_75 = 0; }
   if (rsi_15 < 50) { UP_75 = 0; DOWN_75 = 1; }
   
   
  

   double rsi_30=iRSI(NULL,PERIOD_M30,RSIPeriod,PRICE_CLOSE,shift_30);
   if (rsi_30 >= 50) { UP_76 = 1; DOWN_76 = 0; }
   if (rsi_30 < 50) { UP_76 = 0; DOWN_76 = 1; }
   
   
   

   double rsi_60=iRSI(NULL,PERIOD_H1,RSIPeriod,PRICE_CLOSE,shift_60);
   if (rsi_60 >= 50) { UP_77 = 1; DOWN_77 = 0; }
   if (rsi_60 < 50) { UP_77 = 0; DOWN_77 = 1; }
   
   
   

   double rsi_240=iRSI(NULL,PERIOD_H4,RSIPeriod,PRICE_CLOSE,shift_240);
   if (rsi_240 >= 50) { UP_78 = 1; DOWN_78 = 0; }
   if (rsi_240 < 50) { UP_78 = 0; DOWN_78 = 1; }
   
   
  

   double rsi_1440=iRSI(NULL,PERIOD_D1,RSIPeriod,PRICE_CLOSE,shift_1440);
   if (rsi_1440 >= 50) { UP_79 = 1; DOWN_79 = 0; }
   if (rsi_1440 < 50) { UP_79 = 0; DOWN_79 = 1; }
  
   
   
// Indicator (FORCE INDEX)
   
 
  

   double fi_1=iForce(NULL,PERIOD_M1,FIPeriod,FIMethod,FIPrice,shift_1);
   if (fi_1 >= 0) { UP_81 = 1; DOWN_81 = 0; }
   if (fi_1 < 0) { UP_81 = 0; DOWN_81 = 1; }
   
   
   

   double fi_5=iForce(NULL,PERIOD_M5,FIPeriod,FIMethod,FIPrice,shift_5);
   if (fi_5 >= 0) { UP_82 = 1; DOWN_82 = 0; }
   if (fi_5 < 0) { UP_82 = 0; DOWN_82 = 1; }
   
   
   

   double fi_15=iForce(NULL,PERIOD_M15,FIPeriod,FIMethod,FIPrice,shift_15);
   if (fi_15 >= 0) { UP_83 = 1; DOWN_83 = 0; }
   if (fi_15 < 0) { UP_83 = 0; DOWN_83 = 1; }
   
   
  

   double fi_30=iForce(NULL,PERIOD_M30,FIPeriod,FIMethod,FIPrice,shift_30);
   if (fi_30 >= 0) { UP_84 = 1; DOWN_84 = 0; }
   if (fi_30 < 0) { UP_84 = 0; DOWN_84 = 1; }
   
   
   

   double fi_60=iForce(NULL,PERIOD_H1,FIPeriod,FIMethod,FIPrice,shift_60);
   if (fi_60 >= 0) { UP_85 = 1; DOWN_85 = 0; }
   if (fi_60 < 0) { UP_85 = 0; DOWN_85 = 1; }
   
   
   

   double fi_240=iForce(NULL,PERIOD_H4,FIPeriod,FIMethod,FIPrice,shift_240);
   if (fi_240 >= 0) { UP_86 = 1; DOWN_86 = 0; }
   if (fi_240 < 0) { UP_86 = 0; DOWN_86 = 1; }
   
   
  

   double fi_1440=iForce(NULL,PERIOD_D1,FIPeriod,FIMethod,FIPrice,shift_1440);
   if (fi_1440 >= 0) { UP_87 = 1; DOWN_87 = 0; }
   if (fi_1440 < 0) { UP_87 = 0; DOWN_87 = 1; }
   
   
   
// Indicator (MOMENTUM)
   
  
  

   double momentum_1=iMomentum(NULL,PERIOD_M1,MOMPeriod,MOMPrice,shift_1);
   if (momentum_1 >= 100) { UP_89 = 1; DOWN_89 = 0; }
   if (momentum_1 < 100) { UP_89 = 0; DOWN_89 = 1; }
   
   
   

   double momentum_5=iMomentum(NULL,PERIOD_M5,MOMPeriod,MOMPrice,shift_5);
   if (momentum_5 >= 100) { UP_90 = 1; DOWN_90 = 0; }
   if (momentum_5 < 100) { UP_90 = 0; DOWN_90 = 1; }
   
   
   

   double momentum_15=iMomentum(NULL,PERIOD_M15,MOMPeriod,MOMPrice,shift_15);
   if (momentum_15 >= 100) { UP_91 = 1; DOWN_91 = 0; }
   if (momentum_15 < 100) { UP_91 = 0; DOWN_91 = 1; }
   
   
  

   double momentum_30=iMomentum(NULL,PERIOD_M30,MOMPeriod,MOMPrice,shift_30);
   if (momentum_30 >= 100) { UP_92 = 1; DOWN_92 = 0; }
   if (momentum_30 < 100) { UP_92 = 0; DOWN_92 = 1; }
   
   
   

   double momentum_60=iMomentum(NULL,PERIOD_H1,MOMPeriod,MOMPrice,shift_60);
   if (momentum_60 >= 100) { UP_93 = 1; DOWN_93 = 0; }
   if (momentum_60 < 100) { UP_93 = 0; DOWN_93 = 1; }
   
   
   

   double momentum_240=iMomentum(NULL,PERIOD_H4,MOMPeriod,MOMPrice,shift_240);
   if (momentum_240 >= 100) { UP_94 = 1; DOWN_94 = 0; }
   if (momentum_240 < 100) { UP_94 = 0; DOWN_94 = 1; }
   
   
  

   double momentum_1440=iMomentum(NULL,PERIOD_D1,MOMPeriod,MOMPrice,shift_1440);
   if (momentum_1440 >= 100) { UP_95 = 1; DOWN_95 = 0; }
   if (momentum_1440 < 100) { UP_95 = 0; DOWN_95 = 1; }
   
   
   
// Indicator (DE MARKER)
   
   
  
  

   double demarker_1_0=iDeMarker(NULL,PERIOD_M1,DEMPeriod,shift_1);
   double demarker_1_1=iDeMarker(NULL,PERIOD_M1,DEMPeriod,shift_1+1);
   if (demarker_1_0 >= demarker_1_1) { UP_97 = 1; DOWN_97 = 0; }
   if (demarker_1_0 < demarker_1_1) { UP_97 = 0; DOWN_97 = 1; }
   
   
   

   double demarker_5_0=iDeMarker(NULL,PERIOD_M5,DEMPeriod,shift_5);
   double demarker_5_1=iDeMarker(NULL,PERIOD_M5,DEMPeriod,shift_5+1);
   if (demarker_5_0 >= demarker_5_1) { UP_98 = 1; DOWN_98 = 0; }
   if (demarker_5_0 < demarker_5_1) { UP_98 = 0; DOWN_98 = 1; }
   
   
   

   double demarker_15_0=iDeMarker(NULL,PERIOD_M15,DEMPeriod,shift_15);
   double demarker_15_1=iDeMarker(NULL,PERIOD_M15,DEMPeriod,shift_15+1);
   if (demarker_15_0 >= demarker_15_1) { UP_99 = 1; DOWN_99 = 0; }
   if (demarker_15_0 < demarker_15_1) { UP_99 = 0; DOWN_99 = 1; }
   
   
  

   double demarker_30_0=iDeMarker(NULL,PERIOD_M30,DEMPeriod,shift_30);
   double demarker_30_1=iDeMarker(NULL,PERIOD_M30,DEMPeriod,shift_30+1);
   if (demarker_30_0 >= demarker_30_1) { UP_100 = 1; DOWN_100 = 0; }
   if (demarker_30_0 < demarker_30_1) { UP_100 = 0; DOWN_100 = 1; }
   
   
   

   double demarker_60_0=iDeMarker(NULL,PERIOD_H1,DEMPeriod,shift_60);
   double demarker_60_1=iDeMarker(NULL,PERIOD_H1,DEMPeriod,shift_60+1);
   if (demarker_60_0 >= demarker_60_1) { UP_101 = 1; DOWN_101 = 0; }
   if (demarker_60_0 < demarker_60_1) { UP_101 = 0; DOWN_101 = 1; }
   
   
   

   double demarker_240_0=iDeMarker(NULL,PERIOD_H4,DEMPeriod,shift_240);
   double demarker_240_1=iDeMarker(NULL,PERIOD_H4,DEMPeriod,shift_240+1);
   if (demarker_240_0 >= demarker_240_1) { UP_102 = 1; DOWN_102 = 0; }
   if (demarker_240_0 < demarker_240_1) { UP_102 = 0; DOWN_102 = 1; }
   
   
  

   double demarker_1440_0=iDeMarker(NULL,PERIOD_D1,DEMPeriod,shift_1440);
   double demarker_1440_1=iDeMarker(NULL,PERIOD_D1,DEMPeriod,shift_1440+1);
   if (demarker_1440_0 >= demarker_1440_1) { UP_103 = 1; DOWN_103 = 0; }
   if (demarker_1440_0 < demarker_1440_1) { UP_103 = 0; DOWN_103 = 1; }
   
   
   

   
  

//---- Count Indicators

   double Indy_count = UP_1 + UP_9 + UP_17 + UP_25 + UP_33 + UP_41 + UP_49 + UP_57 + UP_65 + UP_73 + UP_81 + UP_89 + UP_97 + UP_105
                     + UP_2 + UP_10 + UP_18 + UP_26 + UP_34 + UP_42 + UP_50 + UP_58 + UP_66 + UP_74 + UP_82 + UP_90 + UP_98 + UP_106
                     + UP_3 + UP_11 + UP_19 + UP_27 + UP_35 + UP_43 + UP_51 + UP_59 + UP_67 + UP_75 + UP_83 + UP_91 + UP_99 + UP_107
                     + UP_4 + UP_12 + UP_20 + UP_28 + UP_36 + UP_44 + UP_52 + UP_60 + UP_68 + UP_76 + UP_84 + UP_92 + UP_100 + UP_108
                     + UP_5 + UP_13 + UP_21 + UP_29 + UP_37 + UP_45 + UP_53 + UP_61 + UP_69 + UP_77 + UP_85 + UP_93 + UP_101 + UP_109
                     + UP_6 + UP_14 + UP_22 + UP_30 + UP_38 + UP_46 + UP_54 + UP_62 + UP_70 + UP_78 + UP_86 + UP_94 + UP_102 + UP_110
                     + UP_7 + UP_15 + UP_23 + UP_31 + UP_39 + UP_47 + UP_55 + UP_63 + UP_71 + UP_79 + UP_87 + UP_95 + UP_103 + UP_111
                     + DOWN_1 + DOWN_9 + DOWN_17 + DOWN_25 + DOWN_33 + DOWN_41 + DOWN_49 + DOWN_57 + DOWN_65 + DOWN_73 + DOWN_81 + DOWN_89 + DOWN_97 + DOWN_105
                     + DOWN_2 + DOWN_10 + DOWN_18 + DOWN_26 + DOWN_34 + DOWN_42 + DOWN_50 + DOWN_58 + DOWN_66 + DOWN_74 + DOWN_82 + DOWN_90 + DOWN_98 + DOWN_106
                     + DOWN_3 + DOWN_11 + DOWN_19 + DOWN_27 + DOWN_35 + DOWN_43 + DOWN_51 + DOWN_59 + DOWN_67 + DOWN_75 + DOWN_83 + DOWN_91 + DOWN_99 + DOWN_107
                     + DOWN_4 + DOWN_12 + DOWN_20 + DOWN_28 + DOWN_36 + DOWN_44 + DOWN_52 + DOWN_60 + DOWN_68 + DOWN_76 + DOWN_84 + DOWN_92 + DOWN_100 + DOWN_108
                     + DOWN_5 + DOWN_13 + DOWN_21 + DOWN_29 + DOWN_37 + DOWN_45 + DOWN_53 + DOWN_61 + DOWN_69 + DOWN_77 + DOWN_85 + DOWN_93 + DOWN_101 + DOWN_109
                     + DOWN_6 + DOWN_14 + DOWN_22 + DOWN_30 + DOWN_38 + DOWN_46 + DOWN_54 + DOWN_62 + DOWN_70 + DOWN_78 + DOWN_86 + DOWN_94 + DOWN_102 + DOWN_110
                     + DOWN_7 + DOWN_15 + DOWN_23 + DOWN_31 + DOWN_39 + DOWN_47 + DOWN_55 + DOWN_63 + DOWN_71 + DOWN_79 + DOWN_87 + DOWN_95 + DOWN_103 + DOWN_111;
                       
   
   double UP_m1 = (UP_1 + UP_9 + UP_17 + UP_25 + UP_33 + UP_41 + UP_49 + UP_57 + UP_65 + UP_73 + UP_81 + UP_89 + UP_97 + UP_105) * 1;
   double UP_m5 = (UP_2 + UP_10 + UP_18 + UP_26 + UP_34 + UP_42 + UP_50 + UP_58 + UP_66 + UP_74 + UP_82 + UP_90 + UP_98 + UP_106) * 1;
   double UP_m15 = (UP_3 + UP_11 + UP_19 + UP_27 + UP_35 + UP_43 + UP_51 + UP_59 + UP_67 + UP_75 + UP_83 + UP_91 + UP_99 + UP_107) * 1;
   double UP_m30 = (UP_4 + UP_12 + UP_20 + UP_28 + UP_36 + UP_44 + UP_52 + UP_60 + UP_68 + UP_76 + UP_84 + UP_92 + UP_100 + UP_108) * 1;
   double UP_H1 = (UP_5 + UP_13 + UP_21 + UP_29 + UP_37 + UP_45 + UP_53 + UP_61 + UP_69 + UP_77 + UP_85 + UP_93 + UP_101 + UP_109) * 1;
   double UP_H4 = (UP_6 + UP_14 + UP_22 + UP_30 + UP_38 + UP_46 + UP_54 + UP_62 + UP_70 + UP_78 + UP_86 + UP_94 + UP_102 + UP_110) * 1;
   double UP_D1 = (UP_7 + UP_15 + UP_23 + UP_31 + UP_39 + UP_47 + UP_55 + UP_63 + UP_71 + UP_79 + UP_87 + UP_95 + UP_103 + UP_111) * 1;
   
   double TrendUP = UP_m1 + UP_m5 + UP_m15 + UP_m30 + UP_H1 + UP_H4 + UP_D1;
   
   double DOWN_m1 = (DOWN_1 + DOWN_9 + DOWN_17 + DOWN_25 + DOWN_33 + DOWN_41 + DOWN_49 + DOWN_57 + DOWN_65 + DOWN_73 + DOWN_81 + DOWN_89 + DOWN_97 + DOWN_105) * 1;
   double DOWN_m5 = (DOWN_2 + DOWN_10 + DOWN_18 + DOWN_26 + DOWN_34 + DOWN_42 + DOWN_50 + DOWN_58 + DOWN_66 + DOWN_74 + DOWN_82 + DOWN_90 + DOWN_98 + DOWN_106) * 1;
   double DOWN_m15 = (DOWN_3 + DOWN_11 + DOWN_19 + DOWN_27 + DOWN_35 + DOWN_43 + DOWN_51 + DOWN_59 + DOWN_67 + DOWN_75 + DOWN_83 + DOWN_91 + DOWN_99 + DOWN_107) * 1;
   double DOWN_m30 = (DOWN_4 + DOWN_12 + DOWN_20 + DOWN_28 + DOWN_36 + DOWN_44 + DOWN_52 + DOWN_60 + DOWN_68 + DOWN_76 + DOWN_84 + DOWN_92 + DOWN_100 + DOWN_108) * 1;
   double DOWN_H1 = (DOWN_5 + DOWN_13 + DOWN_21 + DOWN_29 + DOWN_37 + DOWN_45 + DOWN_53 + DOWN_61 + DOWN_69 + DOWN_77 + DOWN_85 + DOWN_93 + DOWN_101 + DOWN_109) * 1;
   double DOWN_H4 = (DOWN_6 + DOWN_14 + DOWN_22 + DOWN_30 + DOWN_38 + DOWN_46 + DOWN_54 + DOWN_62 + DOWN_70 + DOWN_78 + DOWN_86 + DOWN_94 + DOWN_102 + DOWN_110) * 1;
   double DOWN_D1 = (DOWN_7 + DOWN_15 + DOWN_23 + DOWN_31 + DOWN_39 + DOWN_47 + DOWN_55 + DOWN_63 + DOWN_71 + DOWN_79 + DOWN_87 + DOWN_95 + DOWN_103 + DOWN_111) * 1;
   
   double TrendDOWN = DOWN_m1 + DOWN_m5 + DOWN_m15 + DOWN_m30 + DOWN_H1 + DOWN_H4 + DOWN_D1;
   
   string Trend_UP = DoubleToStr(((TrendUP/Indy_count)*100),0);
   string Trend_DOWN = DoubleToStr((100 - StrToDouble(Trend_UP)),0);
   if (cmd=="Up") return((TrendUP/Indy_count)*100); 
   if (cmd=="Dn") return(100 - StrToDouble(Trend_UP));                              
                                
  
}
double Analysis(string cmd, int shift)
{
           
   double rsilevel=iRSI(NULL,0,8,0,shift);
   double rsilevel3=iRSI(NULL,0,8,0,shift+2);
   double rsilevelfast=iRSI(NULL,0,3,0,shift);
   double rsilevel3fast=iRSI(NULL,0,3,0,shift+2);
   
   double stolevel= iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_MAIN,shift); 
   double stolevel2=iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_MAIN,shift+1); 
    
   double stolevel3=iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_MAIN,shift+2); 
   double stolevelsignal= iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_SIGNAL,shift); 
   double stolevel2signal=iStochastic( NULL, 0, 10,3, 3, 0,0, MODE_SIGNAL,shift+1); 
   int UpRSI,DnRSI;
   int UpRSICross,DnRSICross;
   int UpRSILevel,DnRSILevel;
   int RSIOB,RSIOS;
   
   int UpSTO,DnSTO;
   int UpSTOCross,DnSTOCross;
   int UpSTOLevel,DnSTOLevel;
   int STOOB,STOOS;
   
      if (rsilevel>rsilevel3) {UpRSI=1;DnRSI=0;}  
       else if (rsilevel<rsilevel3){UpRSI=0;DnRSI=1;}    
        else {UpRSI=0;DnRSI=0;}   
 
      if (rsilevelfast>rsilevel&&rsilevel3fast<rsilevel3){UpRSICross=1;DnRSICross=0;}  
       else if (rsilevelfast<rsilevel&&rsilevel3fast>rsilevel3){UpRSICross=0;DnRSICross=1;}  
       else {UpRSICross=0;DnRSICross=0;}  
       
      if (rsilevel>50&&rsilevel<=70) {UpRSILevel=1;DnRSILevel=0;}  
       else if (rsilevel<=50&&rsilevel>=30) {UpRSILevel=0;DnRSILevel=1;}  
        else if (rsilevel>70) {RSIOB=1;RSIOS=0;}  
         else if (rsilevel<30) {RSIOB=0;RSIOS=1;}  
  
       
   
   if (stolevel>50&&stolevel<=70){UpSTOLevel=1;DnSTOLevel=0;}  
    else if (stolevel<=50&&stolevel>=30) {UpSTOLevel=0;DnSTOLevel=1;}  
    else if (stolevel>70) {STOOB=1;STOOS=0;} 
     else if (stolevel<30) {STOOB=0;STOOS=1;} 
  
   if (stolevel>stolevel3) {UpSTO=1;DnSTO=0;}  
    else if (stolevel<stolevel3) {UpSTO=0;DnSTO=1;}  
   else {UpSTO=0;DnSTO=0;}  
  

    if (stolevelsignal>stolevel&&stolevel2signal<stolevel2){UpSTOCross=1;DnSTOCross=0;}  
    else if (stolevelsignal<stolevel&&stolevel2signal>stolevel2){UpSTOCross=1;DnSTOCross=0;}  
    
double Indy_count =UpRSI+DnRSI+UpRSICross+DnRSICross+UpRSILevel+DnRSILevel+UpSTO+DnSTO+UpSTOCross+DnSTOCross+UpSTOLevel+DnSTOLevel;
double TrendUP=UpRSI+UpRSICross+UpRSILevel+UpSTO+UpSTOCross+UpSTOLevel;
double TrendDOWN = DnRSI+DnRSICross+DnRSILevel+DnSTO+DnSTOCross+DnSTOLevel;
double Up=(TrendUP/Indy_count)*100;
double Dn=100 - Up;
if (cmd=="ValueUp")
{
return(Up);
}
else if (cmd=="ValueDn")
{
return(Dn);

}
else
{
if (Up>=40&&powerup>65)return(1); 
if (Dn>=40&&powerdn>65)return(2); 

if (Up>=40&&powerup<55)return(3); 
if (Dn>=40&&powerdn<55)return(4); 
}

}

  

