//+------------------------------------------------------------------+
//|                                     ForexCandlestickPatterns.mq4 |
//|                           Copyright 2019, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Roberto Jacobs (3rjfx) ~ Date Create: 2019/03/19"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property strict
#property description "ForexCandlestickPatterns with alert are forex indicators based on Japanese Candlestick Strategies"
#property description "by the legendary Japanese Munehisa Homma, which can help traders penetrate inside of financial markets."
//--
#property indicator_chart_window
//--
enum corner
 {  
   LeftHand=0,
   RightHand=1
 };
//--
enum YN
 {
   No,
   Yes
 };
//---
input int    avg_period = 20;              // Period of averaging
input corner cor        = RightHand;       // Corner Position
input color  BuyColor   = clrDodgerBlue;   // Bullish Color
input color  SellColor  = clrOrangeRed;    // Bearish Color
input color  clrfont    = clrSnow;         // Font Color
input color  clrtime    = clrLime;         // Time Color
input YN     UseAlert   = Yes;             // Active Alert
//---
//--
//-- buffers
double Hi[],Op[],Lo[],Cl[];
datetime Tm[];
//--
static int 
    cal,
    pal;
static int 
    nbb1,nbs1;
int xdis,
    ydis,
    patx,
    paty,
    xpip;
int avbars;
//--
double pips,
       space,
       e_pread;
color clrNT=clrCrimson;
//--
ENUM_TIMEFRAMES tf1;
datetime ctime,ptime;
static datetime tms1;
string day[]={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
string patname[]={"MARIBOZU","DOJI","SPINNING TOP","HAMMER","TURN HAMMER","LONG","SHORT","STAR"};
color barcolor[]={clrAqua,clrDeepPink,clrMagenta,clrDodgerBlue,clrMediumOrchid,clrLime,clrLightCoral,clrCrimson};
color cancolor[]={clrAqua,clrAqua,clrDeepPink,clrMagenta,clrDodgerBlue,clrMediumOrchid,clrLime,clrLime,clrLightCoral,clrCrimson,clrCrimson};
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    tf1=PERIOD_CURRENT;
    xdis=cor==1 ? 190 : 17;
    patx=cor==1 ? 10 : 198;
    paty=218;
    ydis=80;
    avbars=avg_period+1;
    ptime=iTime(_Symbol,tf1,1);
    //--
//--- indicator buffers mapping
    //--
    IndicatorShortName("CandlestickPatterns");
    IndicatorDigits(_Digits);
    //--
    //-- Checking the Digits Point
    if(_Digits==3||_Digits==5) {xpip=10; pips=xpip*_Point; space=0.15*pips;}
    else if(_Digits==2||_Digits==4) {xpip=1; pips=xpip*_Point; space=1.5*pips;}
    //--
    ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
    ChartSetInteger(0,CHART_FOREGROUND,0,false);
    ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrWhite);
    //--
    for(int i=0;i<ArraySize(patname);i++)
      {
        ObjectCreate(0,patname[i],OBJ_LABEL,0,0,0);
        ObjectSetString(0,patname[i],OBJPROP_FONT,"Arial Black");
        ObjectSetInteger(0,patname[i],OBJPROP_FONTSIZE,7);
        ObjectSetInteger(0,patname[i],OBJPROP_CORNER,cor);
        ObjectSetInteger(0,patname[i],OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0,patname[i],OBJPROP_XDISTANCE,patx);
        ObjectSetInteger(0,patname[i],OBJPROP_YDISTANCE,paty+i*14);
        ObjectSetInteger(0,patname[i],OBJPROP_COLOR,barcolor[i]);
        ObjectSetString(0,patname[i],OBJPROP_TEXT,patname[i]);
     }
    //--
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
   if(reason==1)
     {
       ObjectsDeleteAll();
       GlobalVariablesDeleteAll();
     }
//----
   return;
  }
//---------//
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
    ResetLastError();
    ChartRedraw(0);
    RefreshRates();
//--- check for rates total
    int limit=rates_total-prev_calculated;
    if(rates_total<(int)WindowBarsPerChart())
      return(0);
    ArraySetAsSeries(time,true);
    //--
    ctime=iTime(_Symbol,tf1,0);
    if(ctime!=ptime)
      Bars_Candlestick();
    color barclr;
    double e_ask=MarketInfo(_Symbol,MODE_ASK);
    double e_bid=MarketInfo(_Symbol,MODE_BID);
    double askbid=e_ask-e_bid;
    e_pread = (e_ask-e_bid)/pips;
    //--- create indicator labels time
    int djd=cor==1 ? -11 : 11;
    CreateLabel(0,"txDay",day[DayOfWeek()],"Verdana",14,clrNT,cor,xdis,ydis);
    CreateLabel(0,"txTime",TimeToString(TimeCurrent(),TIME_DATE),"Verdana",10,clrtime,cor,xdis,ydis+21);
    CreateLabel(0,"txDate",TimeToString(TimeCurrent(),TIME_SECONDS),"Verdana",8,clrtime,cor,xdis+djd,ydis+35);
    //--
    if(ctime!=ptime)
      {
        //--
        cal=0;
        string pattern="";
        string textbar="";
        string trigger="";
        string textprice="";
        string direction="";
        string pattalert="";
        double barprice=0;
        double trigprice=0;
        datetime bartime=0;
        color  signalclr=0;
        string exname="*"+WindowExpertName()+": ";
        string symtf=_Symbol+", TF: "+strTF(_Period);
        string altime=", @ "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
        //--
        CANDLE_STRUCTURE bar1;
        RecognizeCandle(_Symbol,tf1,time[1],avbars,bar1);
        CANDLE_STRUCTURE bar2;
        RecognizeCandle(_Symbol,tf1,time[2],avbars,bar2);
        CANDLE_STRUCTURE bar3;
        RecognizeCandle(_Symbol,tf1,time[3],avbars,bar3);
        CANDLE_STRUCTURE bar4;
        RecognizeCandle(_Symbol,tf1,time[4],avbars,bar4);
        CANDLE_STRUCTURE bar5;
        RecognizeCandle(_Symbol,tf1,time[5],avbars,bar5);
        //--
        int Hies=iHighest(_Symbol,tf1,MODE_HIGH,5,0);
        int Lows=iLowest(_Symbol,tf1,MODE_LOW,5,0);
        //--
        //-- Bullish Bearish Candle Patterns
        //-- Long White Body (Maribozu Long bullish model)
        if((bar1.high<bar2.high)&&(bar1.trend==RISE)&&(bar1.low<=iLow(_Symbol,tf1,Lows))&&(bar1.type==CAND_MARIBOZU_LONG)&&
           (bar1.hiwick==TINY_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Maribozu_Long_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Maribozu Long";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=1;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==1)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Long Bear Body (Maribozu Long bearish model)
        else
        if((bar1.low>bar2.low)&&(bar1.trend==DOWN)&&(bar1.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.type==CAND_MARIBOZU_LONG)&&
           (bar1.hiwick==TINY_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Maribozu_Long_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Maribozu Long";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-1;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-1)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Hammer
        else
        if((bar1.high<bar2.high)&&(bar1.trend==RISE)&&(bar1.low<=iLow(_Symbol,tf1,Lows))&&(bar1.type==CAND_HAMMER)&&
           (bar1.hiwick==TINY_WICK)&&(bar1.lowick==LONG_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Hammer_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Hammer";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=2;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==2)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Shooting Star
        else
        if((bar1.low>bar2.low)&&(bar1.trend==DOWN)&&(bar1.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.type==CAND_INVERT_HAMMER)&&
           (bar1.hiwick==LONG_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Shooting_Star_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Shooting Star";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-2;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-2)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Belt Hold Bull
        else
        if((bar1.high<bar2.low)&&(bar1.trend==RISE)&&(bar1.low<=iLow(_Symbol,tf1,Lows))&&(bar1.type==CAND_LONG || bar1.type==CAND_MARIBOZU_LONG)&&
           (bar1.bodysize>bar2.bodysize)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Belt_Hold_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Belt Hold";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=3;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==3)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Belt Hold Bear
        else
        if((bar1.low>bar2.high)&&(bar1.trend==DOWN)&&(bar1.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.type==CAND_LONG || bar1.type==CAND_MARIBOZU_LONG)&&
           (bar1.bodysize>bar2.bodysize)&&(bar1.hiwick==TINY_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Belt_Hold_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Belt Hold";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-3;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-3)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Engulfing Bull
        else
        if((bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar1.open==bar2.close)&&(bar1.high>bar2.high)&&(bar1.bodysize>bar2.bodysize)&&
           (bar2.type==CAND_MEDIAN||bar2.type==CAND_MARIBOZU||bar2.type==CAND_LONG||bar2.type==CAND_MARIBOZU_LONG)&&
           (bar2.hiwick==SMALL_WICK||bar2.hiwick==TINY_WICK)&&(bar2.lowick==SMALL_WICK||bar2.lowick==TINY_WICK)&&
           (bar1.hiwick==SMALL_WICK||bar1.hiwick==TINY_WICK)&&(bar1.lowick==SMALL_WICK||bar1.lowick==TINY_WICK)&&
           (bar2.low<=iLow(_Symbol,tf1,Lows)||bar1.low<=iLow(_Symbol,tf1,Lows))&&(bar1.type==CAND_LONG||bar1.type==CAND_MARIBOZU_LONG))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Engulfing_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Engulfing Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=4;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==4)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Engulfing Bear
        else
        if((bar2.trend==RISE)&&(bar1.trend==DOWN)&&(bar1.open==bar2.close)&&(bar1.low<bar2.low)&&(bar1.bodysize>bar2.bodysize)&&
           (bar2.type==CAND_MEDIAN||bar2.type==CAND_MARIBOZU||bar2.type==CAND_LONG||bar2.type==CAND_MARIBOZU_LONG)&&
           (bar2.hiwick==SMALL_WICK||bar2.hiwick==TINY_WICK)&&(bar2.lowick==SMALL_WICK||bar2.lowick==TINY_WICK)&&
           (bar1.hiwick==SMALL_WICK||bar1.hiwick==TINY_WICK)&&(bar1.lowick==SMALL_WICK||bar1.lowick==TINY_WICK)&&
           (bar2.high>=iHigh(_Symbol,tf1,Hies)||bar1.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.type==CAND_LONG||bar1.type==CAND_MARIBOZU_LONG))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Engulfing_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Engulfing Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-4;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-4)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Harami Bull
        else
        if((bar2.trend==DOWN)&&(bar2.type==CAND_LONG)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&(bar1.open>=bar2.close)&&(bar1.bodysize<bar2.bodysize)&&
          (bar1.HiLo<bar2.HiLo)&&(bar1.low>bar2.low)&&(bar1.high<bar2.high)&&(bar1.trend==RISE)&&(bar1.type==CAND_SHORT)&&
          (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Harami_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Harami Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=5;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==5)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
        
          }
        //--
        //-- Harami Bear
        else
        if((bar2.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar2.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.open<=bar2.close)&&(bar1.bodysize<bar2.bodysize)&&
          (bar1.HiLo<bar2.HiLo)&&(bar1.low>bar2.low)&&(bar1.high<bar2.high)&&(bar1.trend==DOWN)&&(bar1.type==CAND_SHORT)&&
          (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Harami_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Harami Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish Reversal";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-5;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-5)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--      
        //-- Harami Cross Bull
        else
        if((bar2.trend==DOWN)&&(bar2.type==CAND_LONG)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&(bar1.open>=bar2.close)&&(bar1.bodysize<bar2.bodysize)&&
          (bar1.HiLo<bar2.HiLo)&&(bar1.low>bar2.low)&&(bar1.high<bar2.high)&&(bar1.trend==RISE)&&(bar1.type==CAND_DOJI)&&
          (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Harami_Corss_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Harami Cross Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=6;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==6)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Harami Cross Bear
        else
        if((bar2.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar2.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.open<=bar2.close)&&(bar1.bodysize<bar2.bodysize)&&
          (bar1.HiLo<bar2.HiLo)&&(bar1.low>bar2.low)&&(bar1.high<bar2.high)&&(bar1.trend==DOWN)&&(bar1.type==CAND_DOJI)&&
          (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Harami_Cross_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Harami Cross Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish Reversal";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-6;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-6)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Doji Star Bull
        else
        if((bar2.trend==DOWN)&&(bar2.type==CAND_LONG)&&(bar1.low<=iLow(_Symbol,tf1,Lows))&&(bar1.bodysize<bar2.bodysize)&&
          (bar1.open>=bar2.close)&&(bar1.HiLo<bar2.HiLo)&&(bar1.low>=bar2.low)&&(bar1.high<bar2.high)&&(bar1.type==CAND_DOJI)&&
          (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Doji_Star_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Doji Star Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=7;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==7)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Doji Star Bear
        else
        if((bar2.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar1.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.bodysize<bar2.bodysize)&&
          (bar1.open<=bar2.close)&&(bar1.HiLo<bar2.HiLo)&&(bar1.low>bar2.low)&&(bar1.high<bar2.high)&&(bar1.type==CAND_DOJI)&&
          (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Doji_Star_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Doji Star Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish Reversal";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-7;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-7)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //-- 
        //-- Piercing Line Bull
        else
        if((bar2.trend==DOWN)&&(bar2.type==CAND_LONG)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&(bar1.open==bar2.close)&&
           (bar1.close>(bar2.open+bar2.low)/2)&&(bar1.trend==RISE)&&(bar1.type==CAND_LONG)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Piercing_Line_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Piercing Line Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=8;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==8)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Dark Cloud Cover
        else
        if((bar2.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar2.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.open==bar2.close)&&
           (bar1.close<(bar2.open+bar2.low)/2)&&(bar1.trend==DOWN)&&(bar1.type==CAND_LONG)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Dark_Cloud_Cover_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Dark Cloud Cover Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish Reversal";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-8;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-8)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Tweezers Bull
        else
        if((bar2.trend==DOWN)&&(bar2.type==CAND_LONG)&&(bar1.low==bar2.low)&&(bar1.open>bar2.close)&&(bar1.trend==RISE)&&
           (bar1.type==CAND_SHORT)&&(bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Tweezers_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Tweezers Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=9;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==9)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Tweezers Bear
        else
        if((bar2.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar1.high==bar2.high)&&(bar1.open<=bar2.close)&&(bar1.trend==DOWN)&&
           (bar1.type==CAND_SHORT)&&(bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Tweezers_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Tweezers Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish Reversal";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-9;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-9)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Homing Pigeon Bull
        else
        if((bar2.trend==DOWN)&&(bar2.type==CAND_LONG)&&(bar1.trend==DOWN)&&(bar1.type==CAND_SHORT)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&
           (bar1.bodysize<bar2.bodysize)&&(bar1.open>bar2.close)&&(bar1.low>bar2.close)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Homing_Pigeon_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Homing Pigeon Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=10;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==10)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Three Inside Down Bear
        else
        if((bar3.trend==RISE)&&(bar3.type==CAND_LONG)&&(bar2.trend==DOWN)&&(bar2.type==CAND_SHORT)&&(bar1.trend==DOWN)&&(bar1.type==CAND_LONG)&&
           (bar2.bodysize<bar3.bodysize)&&(bar1.bodysize>bar2.bodysize)&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&
           (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Three_Inside_Down_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Inside Down";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish Reversal";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-10;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-10)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Three White Soldier Bull
        else
        if(((bar3.trend==RISE)&&(bar2.trend==RISE)&&(bar1.trend==RISE))&&(((bar3.type==CAND_MARIBOZU)&&(bar2.type==CAND_MARIBOZU)&&
           (bar1.type==CAND_MARIBOZU))||((bar3.type==CAND_MARIBOZU_LONG)&&(bar2.type==CAND_MARIBOZU_LONG)&&(bar1.type==CAND_MARIBOZU_LONG)))&&
           (bar3.low<=iLow(_Symbol,tf1,Lows)&&(bar3.open<bar4.close)&&(bar2.open<bar3.close)&&
           (bar1.open<bar2.close)&&(bar3.lowick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Three_White_Soldier_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three White Soldier";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=11;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==11)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Three Black Crows Bear
        else
        if(((bar3.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.trend==DOWN))&&(((bar3.type==CAND_MARIBOZU)&&(bar2.type==CAND_MARIBOZU)&&
           (bar1.type==CAND_MARIBOZU))||((bar3.type==CAND_MARIBOZU_LONG)&&(bar2.type==CAND_MARIBOZU_LONG)&&(bar1.type==CAND_MARIBOZU_LONG)))&&
           (bar3.high>=iHigh(_Symbol,tf1,Hies)&&(bar3.open>bar4.close)&&(bar2.open>bar3.close)&&
           (bar1.open>bar2.close)&&(bar3.hiwick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Three Black Crows_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Black Crows";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish Reversal";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-11;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-11)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Morning Star Bull
        else
        if((bar3.trend==DOWN)&&(bar3.type==CAND_LONG)&&(bar2.trend==DOWN)&&(bar2.type==CAND_STAR)&&(bar1.trend==RISE)&&
           (bar1.type==CAND_MARIBOZU || bar1.type==CAND_MARIBOZU_LONG)&&(bar2.open<=bar3.close)&&(bar1.close<bar3.open)&&
           (bar1.close>((bar3.open+bar3.close)/2))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==TINY_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Morning_Star_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Morning Star Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=12;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==12)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Evening Star Bear
        else
        if((bar3.trend==RISE)&&(bar3.type==CAND_LONG)&&(bar2.trend==RISE)&&(bar2.type==CAND_STAR)&&(bar1.trend==DOWN)&&
           (bar1.type==CAND_MARIBOZU || bar1.type==CAND_MARIBOZU_LONG)&&(bar2.open>=bar3.close)&&(bar1.close>bar3.open)&&
           (bar1.close<((bar3.close+bar3.open)/2))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Evening_Star_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Evening Star Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-12;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-12)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Morning Doji Star Bull
        else
        if((bar3.trend==DOWN)&&(bar3.type==CAND_LONG)&&(bar2.trend==DOWN)&&(bar2.type==CAND_DOJI)&&(bar1.trend==RISE)&&
           (bar1.type==CAND_MARIBOZU_LONG || bar1.type==CAND_MARIBOZU)&&(bar2.open<=bar3.close)&&(bar1.close<bar3.open)&&
           (bar1.close>((bar3.open+bar3.close)/2))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Morning_Doji_Star_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Morning Doji Star Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=13;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==13)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Evening Doji Star Bear
        else
        if((bar3.trend==RISE)&&(bar3.type==CAND_LONG)&&(bar2.trend==RISE)&&(bar2.type==CAND_DOJI)&&(bar1.trend==DOWN)&&
           (bar1.type==CAND_MARIBOZU_LONG || bar1.type==CAND_MARIBOZU)&&(bar2.open>=bar3.close)&&(bar1.close>bar3.open)&&
           (bar1.close<((bar3.close+bar3.open)/2))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Evening_Doji_Star_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Evening Doji Star Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-13;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-13)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Three Star in the South Bull
        else
        if((bar3.trend==DOWN)&&(bar3.type==CAND_LONG)&&(bar2.trend==DOWN)&&(bar2.type==CAND_SHORT || bar1.type==CAND_STAR)&&
           (bar1.trend==DOWN)&&(bar1.type==CAND_MARIBOZU || bar1.type==CAND_STAR)&&(bar2.low>bar3.low)&&(bar3.low<=iLow(_Symbol,tf1,Lows)&&
           (bar3.high<iHigh(_Symbol,tf1,Hies))&&(bar1.low>bar2.low))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==LONG_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==TINY_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Three_Star_in_the_South_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Star in the South";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=14;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==14)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Deliberation Bear
        else
        if((bar3.trend==RISE)&&(bar3.type==CAND_LONG)&&(bar2.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar1.trend==RISE)&&
           (bar1.type==CAND_STAR || bar1.type==CAND_SPIN_TOP)&&(bar2.open<=bar3.close)&&(bar1.open>bar2.close)&&
           (bar3.low>iLow(_Symbol,tf1,Lows))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Deliberation_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Deliberation Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-14;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-14)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Three Outside Up Bull
        else
        if((bar3.trend==DOWN)&&(bar2.trend==RISE)&&(bar1.trend==RISE)&&(bar2.open>=bar3.close)&&(bar2.low>=bar3.low)&&(bar2.high>bar3.high)&&
           (bar2.close>bar3.open)&&(bar2.bodysize>bar3.bodysize)&&(bar1.open>=bar2.close)&&(bar1.close>bar2.high)&&
           (bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&
           (bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Three_Outside_Up_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Outside Up";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=15;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==15)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Three Outside Down Bear
        else
        if((bar3.trend==RISE)&&(bar2.trend==DOWN)&&(bar1.trend==DOWN)&&(bar2.open<=bar3.close)&&(bar2.high<=bar3.high)&&(bar2.low<bar3.low)&&
           (bar2.close<bar3.open)&&(bar2.bodysize>bar3.bodysize)&&(bar1.open<=bar2.close)&&(bar1.close<bar2.low)&&
           (bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&
           (bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Three_Outside_Down_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Outside Down";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-15;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-15)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Three Inside Up Bull
        else
        if((bar3.trend==DOWN)&&(bar3.type==CAND_LONG)&&(bar2.trend==RISE)&&(bar2.type==CAND_SHORT)&&(bar1.trend==RISE)&&
           (bar1.type==CAND_LONG)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&(bar2.close<((bar3.open+bar3.close)/2))&&
           (bar1.close>fmax(bar2.high,bar3.high))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&
           (bar2.hiwick==LONG_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Three_Inside_Up_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Inside Up";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=16;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==16)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Three Inside Down Bear
        else
        if((bar3.trend==RISE)&&(bar3.type==CAND_LONG)&&(bar2.trend==DOWN)&&(bar2.type==CAND_SHORT)&&(bar1.trend==DOWN)&&
           (bar1.type==CAND_LONG)&&(bar2.high>=iHigh(_Symbol,tf1,Hies))&&(bar2.close>((bar3.close+bar3.open)/2))&&
           (bar1.close<fmin(bar2.low,bar3.low))&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&
           (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==LONG_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Three_Inside_Down_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Inside Down";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-16;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-16)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Three Star Bull
        else
        if((bar3.type==CAND_DOJI)&&(bar2.type==CAND_DOJI)&&(bar1.type==CAND_DOJI)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&
           (bar1.open==bar2.open)&&(bar2.open==bar3.open))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Three_Star_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Star Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=17;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==17)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Three Star Bear
        else
        if((bar3.type==CAND_DOJI)&&(bar2.type==CAND_DOJI)&&(bar1.type==CAND_DOJI)&&(bar2.high>=iHigh(_Symbol,tf1,Hies))&&
           (bar1.open==bar2.open)&&(bar2.open==bar3.open))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Three_Star_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Star Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-17;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-17)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Three Line Strike Bull
        else
        if((bar4.type==CAND_LONG)&&(bar3.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&(bar1.type==CAND_LONG)&&
           (bar4.trend==RISE)&&(bar3.trend==RISE)&&(bar2.trend==RISE)&&(bar1.trend==DOWN)&&
           (bar1.open==bar2.close)&&(bar1.close<bar4.low)&&(bar2.high>=iHigh(_Symbol,tf1,Hies))&&
           (bar4.hiwick==SMALL_WICK)&&(bar4.lowick==SMALL_WICK)&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&
           (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Three_Line_Strike_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Line Strike Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish Reversal";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=18;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==18)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Three Line Strike Bear
        else
        if((bar4.type==CAND_LONG)&&(bar3.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&(bar1.type==CAND_LONG)&&
           (bar4.trend==DOWN)&&(bar3.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.trend==RISE)&&
           (bar1.open==bar2.close)&&(bar1.close>bar4.high)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&
           (bar4.hiwick==SMALL_WICK)&&(bar4.lowick==SMALL_WICK)&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&
           (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Three_Line_Strike_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Three Line Strike Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-18;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-18)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Meeting Lines the bullish model
        else
        if((bar1.trend==RISE)&&(bar2.trend==DOWN)&&(bar1.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&
           (bar1.open<bar2.low)&&(bar1.close==bar2.close)&&(bar1.bodysize>bar2.bodysize))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Meeting_Lines_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Meeting Lines Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=19;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==19)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Meeting Lines, the bearish model
        else
        if((bar1.trend==DOWN)&&(bar2.trend==RISE)&&(bar1.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&
           (bar1.open>bar2.high)&&(bar1.close==bar2.close)&&(bar1.bodysize>bar2.bodysize))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Meeting_Lines_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Meeting Lines Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-19;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-19)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Matching Low, the bullish model
        else
        if((bar1.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.close==bar2.close)&&(bar1.open>bar2.close)&&
           (bar1.bodysize<bar2.bodysize)&&(bar2.lowick==TINY_WICK)&&(bar1.lowick==TINY_WICK)&&
           (bar2.hiwick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Matching_Low_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Matching Low Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=20;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==20)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Upside Gap Two Crows, the bearish model
        else
        if((bar1.trend==DOWN)&&(bar2.trend==DOWN)&&(bar3.trend==RISE)&&(bar1.type==CAND_LONG || bar1.type==CAND_MARIBOZU_LONG)&&
           (bar3.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&(bar2.type==CAND_SHORT)&&(bar1.bodysize>bar2.bodysize)&&
           (bar2.open>bar3.high)&&(bar2.low>bar3.high)&&(bar1.open>bar2.high)&&(bar1.low<bar2.low)&&(bar1.close<bar2.close)&&
           (bar1.low>bar3.high)&&(bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Upside_Gap_Two_Crows_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Upside Gap Two Crows";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-20;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-20)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Unique Three River Bottom, the bullish model
        else
        if((bar3.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar3.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&
           (bar2.type==CAND_HAMMER)&&(bar1.type==CAND_SHORT)&&(bar2.low<=iLow(_Symbol,tf1,Lows))&&(bar2.open>bar3.close)&&
           (bar2.close>bar3.close)&&(bar1.open>bar3.close)&&(bar1.open<bar2.close)&&(bar1.close<bar2.close)&&(bar1.high>bar2.close)&&
           (bar3.lowick==SMALL_WICK)&&(bar3.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Unique_Three_River_Bottom_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Unique Three River Bottom";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=21;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==21)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Two Crows, the bearish model
        else
        if((bar1.trend==DOWN)&&(bar2.trend==DOWN)&&(bar3.trend==RISE)&&(bar1.type==CAND_LONG || bar1.type==CAND_MARIBOZU_LONG)&&
           (bar3.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&(bar2.type==CAND_SHORT)&&(bar1.bodysize>bar2.bodysize)&&
           (bar2.open>bar3.high)&&(bar2.low>bar3.high)&&(bar1.open>bar2.close)&&(bar1.open<bar2.open)&&(bar1.close<bar3.close)&&
           (bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar2.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Two_Crows_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Two Crows";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-21;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-21)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Inverted Hammer Bullish model
        else
        if((bar1.trend==RISE)&&(bar1.low<=iLow(_Symbol,tf1,Lows))&&(bar1.type==CAND_INVERT_HAMMER)&&
           (bar1.high>bar2.high)&&(bar1.hiwick==LONG_WICK)&&(bar1.lowick==TINY_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Inverted_Hammer_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Inverted Hammer";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=22;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==22)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Hanging Man Bearish model
        else
        if((bar1.trend==DOWN)&&(bar1.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.type==CAND_HAMMER)&&
           (bar1.low<bar2.low)&&(bar1.lowick==LONG_WICK)&&(bar1.hiwick==TINY_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Hanging_Man_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Hanging Man Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-22;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-22)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Upside Tasuki Gap Bullish model
        else
        if((bar3.trend==RISE)&&(bar2.trend==RISE)&&(bar1.trend==DOWN)&&(bar2.low>bar3.high)&&(bar1.open<bar2.close)&&(bar1.open>bar2.open)&&
           (bar1.low>bar3.high)&&(bar1.close<=bar2.low)&&(bar3.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&(bar1.type==CAND_LONG)&&
           (bar3.lowick==SMALL_WICK)&&(bar3.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Upside_Tasuki_Gap_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Upside Tasuki Gap";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=23;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==23)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Downside Tasuki Gap Bearish model
        else
        if((bar3.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar2.high<bar3.low)&&(bar1.open>bar2.close)&&(bar1.open<bar2.open)&&
           (bar1.high<bar3.low)&&(bar1.close<=bar2.high)&&(bar3.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&(bar1.type==CAND_LONG)&&
           (bar3.lowick==SMALL_WICK)&&(bar3.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&
           (bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Downside_Tasuki_Gap_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Downside Tasuki Gap";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-23;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-23)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Upside Gap Three Method Bullish model
        else
        if((bar3.trend==RISE)&&(bar2.trend==RISE)&&(bar1.trend==DOWN)&&(bar2.open>bar3.high)&&(bar1.open<bar2.close)&&(bar1.open>bar2.open)&&
           (bar1.close<bar3.close)&&(bar3.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&(bar1.type==CAND_LONG)&&(bar3.lowick==SMALL_WICK)&&
           (bar3.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Upside_Tasuki_Gap_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Upside Tasuki Gap";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=24;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==24)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Downside Gap Three Method Bearish model
        else
        if((bar3.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar2.open<bar3.low)&&(bar1.open>bar2.close)&&(bar1.open<bar2.open)&&
           (bar1.close>bar3.close)&&(bar3.type==CAND_LONG)&&(bar2.type==CAND_LONG)&&(bar1.type==CAND_LONG)&&(bar3.lowick==SMALL_WICK)&&
           (bar3.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Downside_Tasuki_Gap_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Downside Tasuki Gap";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-24;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-24)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Kicking Bullish model
        else
        if((bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar1.open>bar2.high)&&(bar2.type==CAND_MARIBOZU_LONG || bar2.type==CAND_MARIBOZU)&&
           (bar1.type==CAND_MARIBOZU_LONG || bar1.type==CAND_MARIBOZU)&&(bar2.lowick==TINY_WICK)&&(bar2.hiwick==TINY_WICK)&&
           (bar1.lowick==TINY_WICK)&&(bar1.hiwick==TINY_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Kicking_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Kicking Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=25;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==25)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Kicking Bearish model
        else
        if((bar2.trend==RISE)&&(bar1.trend==DOWN)&&(bar1.open<bar2.low)&&(bar2.type==CAND_MARIBOZU_LONG || bar2.type==CAND_MARIBOZU)&&
           (bar1.type==CAND_MARIBOZU_LONG || bar1.type==CAND_MARIBOZU)&&(bar2.lowick==TINY_WICK)&&(bar2.hiwick==TINY_WICK)&&
           (bar1.lowick==TINY_WICK)&&(bar1.hiwick==TINY_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Kicking_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Kicking Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-25;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-25)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Breakaway Bullish model
        else
        if((bar5.trend==DOWN)&&(bar4.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar5.type==CAND_LONG)&&(bar4.type==CAND_SHORT)&&
           (bar3.type==CAND_SHORT)&&(bar2.type==CAND_SHORT)&&(bar1.type==CAND_LONG)&&(bar4.open<bar5.low)&&(bar3.low<=iLow(_Symbol,tf1,Lows))&&
           (bar1.open>=bar2.close)&&(bar1.close<bar5.close)&&(bar5.lowick==SMALL_WICK)&&(bar5.hiwick==SMALL_WICK)&&(bar4.lowick==SMALL_WICK)&&
           (bar4.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar3.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Kicking_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Kicking Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=25;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==25)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Breakaway Bearish model
        else
        if((bar5.trend==RISE)&&(bar4.trend==RISE)&&(bar2.trend==RISE)&&(bar1.trend==DOWN)&&(bar5.type==CAND_LONG)&&(bar4.type==CAND_SHORT)&&
           (bar3.type==CAND_SHORT)&&(bar2.type==CAND_SHORT)&&(bar1.type==CAND_LONG)&&(bar4.open>bar5.high)&&(bar3.low>=iHigh(_Symbol,tf1,Hies))&&
           (bar1.open<=bar2.close)&&(bar1.close>bar5.close)&&(bar5.lowick==SMALL_WICK)&&(bar5.hiwick==SMALL_WICK)&&(bar4.lowick==SMALL_WICK)&&
           (bar4.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar3.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar2.hiwick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Kicking_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Kicking Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-25;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-25)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Cocealing Baby Swallow Bullish model
        else
        if((bar4.trend==DOWN)&&(bar3.trend==DOWN)&&(bar2.trend==DOWN)&&(bar1.trend==DOWN)&&(bar4.type==CAND_LONG || bar4.type==CAND_MARIBOZU_LONG)&&
           (bar3.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&(bar2.type==CAND_SHORT)&&(bar1.type==CAND_MARIBOZU_LONG)&&
           (bar2.open<bar3.close)&&(bar2.high>bar2.close)&&(bar1.open>bar2.high)&&(bar1.close<bar2.low)&&
           (bar1.bodysize>bar2.bodysize)&&(bar4.lowick==TINY_WICK)&&(bar4.hiwick==TINY_WICK)&&(bar3.lowick==TINY_WICK)&&
           (bar3.hiwick==TINY_WICK)&&(bar2.hiwick==LONG_WICK)&&(bar2.lowick==TINY_WICK)&&(bar1.lowick==TINY_WICK)&&(bar1.hiwick==TINY_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Cocealing_Baby_Swallow_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Cocealing Baby Swallow";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=26;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==26)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //-- Thrusting Line Bearish model
        else
        if((bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar1.open<bar2.low)&&(bar1.close<(bar2.open+bar2.close)/2)&&
           (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Thrusting_Line_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Thrusting Line Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-26;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-26)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- Abandoned Baby Bullish model
        else
        if((bar3.trend==DOWN)&&(bar2.trend==LATERAL)&&(bar1.trend==RISE)&&(bar3.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&
           (bar2.type==CAND_DOJI)&&(bar1.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&(bar2.high<bar3.low)&&
           (bar2.low<=iLow(_Symbol,tf1,Lows))&&(bar1.open<bar3.close)&&(bar1.close>bar3.close)&&(bar1.close<bar3.open)&&
           (bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbb1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbs1=EMPTY;
            textprice="Abandoned_Baby_Bull_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Abandoned Baby Bull";
            textbar="Bar Shift: "+string(nbb1);
            direction="Direction: Bullish";
            trigger="Trigger: BUY above ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=27;
            pattalert=" -- Bar:"+string(nbb1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
            
                       bar1.time,
                       bar1.low-space,
                       bar1.high,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==27)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              }
          }
        //--
        //--
        //-- Abandoned Baby Bearish model
        else
        if((bar3.trend==RISE)&&(bar2.trend==LATERAL)&&(bar1.trend==DOWN)&&(bar3.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&
           (bar2.type==CAND_DOJI)&&(bar1.type==CAND_LONG || bar3.type==CAND_MARIBOZU_LONG)&&(bar2.low>bar3.high)&&
           (bar2.high>=iHigh(_Symbol,tf1,Hies))&&(bar1.open>bar3.close)&&(bar1.close>bar3.open)&&(bar1.close<bar3.close)&&
           (bar3.hiwick==SMALL_WICK)&&(bar3.lowick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="Abandoned_Baby_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="Abandoned Baby Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-27;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-27)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- On Neck Line Bearish model
        else
        if((bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar1.open<bar2.low)&&(bar1.close<bar2.low)&&
           (bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="On_Neck_Line_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="On Neck Line Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-28;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-28)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        //-- In Neck Line Bearish model
        else
        if((bar2.trend==DOWN)&&(bar1.trend==RISE)&&(bar2.type==CAND_LONG)&&(bar1.open<bar2.low)&&(bar1.close>bar2.low)&&
           (bar1.bodysize<bar2.bodysize)&&(bar2.hiwick==SMALL_WICK)&&(bar2.lowick==SMALL_WICK)&&(bar1.lowick==SMALL_WICK)&&(bar1.hiwick==SMALL_WICK))
          {
            nbs1=iBarShift(_Symbol,tf1,bar1.time,false);
            nbb1=EMPTY;
            textprice="In_Neck_Line_Bear_"+TimeToString(bar1.time,TIME_DATE|TIME_MINUTES);
            pattern="In Neck Line Bear";
            textbar="Bar Shift: "+string(nbs1);
            direction="Direction: Bearish";
            trigger="Trigger: SELL below ";
            signalclr=cancolor[bar1.bclr];
            tms1=time[1];
            cal=-29;
            pattalert=" -- Bar:"+string(nbs1)+" appears as "+pattern+" pattern";
            DrawSignal(textprice,
                       bar1.time,
                       bar1.high+space,
                       bar1.low,
                       askbid,
                       textbar,
                       pattern,
                       direction,
                       trigger,
                       signalclr);
            //--
            if((UseAlert==1)&&(cal==-29)&&(cal!=pal))
              {
                Alert(exname+symtf+altime+pattalert); 
                pal=cal;
              } 
          }
        //--
        else
        if(nbb1==0&&nbs1==0)
          {
            CreateLabel(0,"Pattern","Pattern: Not Found","Verdana",8,clrfont,cor,xdis,ydis+60);
            CreateLabel(0,"Position","Bar Shift: Not Found","Verdana",8,clrfont,cor,xdis,ydis+75);
            CreateLabel(0,"Direction","Direction: Not Found","Verdana",8,clrfont,cor,xdis,ydis+90);
            CreateLabel(0,"Trigger","Trigger: Not Found","Verdana",8,clrfont,cor,xdis,ydis+105); 
          }
        else
        if((nbb1!=EMPTY&&nbs1==EMPTY)||(nbs1!=EMPTY&&nbb1==EMPTY))
          {
            CreateLabel(0,"Position","Bar Shift: " +string(iBarShift(_Symbol,tf1,tms1,false)),"Verdana",8,clrfont,cor,xdis,ydis+75);
          }
        //--
      }
    //--
    //--- create indicator OHLC price
    int aj=cor==1 ? -2 : 2;
    if(iClose(_Symbol,tf1,0)>iOpen(_Symbol,tf1,0)) {barclr=BuyColor;}
    else if(iClose(_Symbol,tf1,0)<iOpen(_Symbol,tf1,0)) {barclr=SellColor;}
    else {barclr=clrNT;}
    CreateLabel(0,"OPEN","O: "+DoubleToString(iOpen(_Symbol,tf1,0),_Digits),"Verdana",9,barclr,cor,xdis+djd,ydis+125);
    CreateLabel(0,"HIGH","H: "+DoubleToString(iHigh(_Symbol,tf1,0),_Digits),"Verdana",9,barclr,cor,xdis+djd,ydis+140);
    CreateLabel(0,"LOW","L: "+DoubleToString(iLow(_Symbol,tf1,0),_Digits),"Verdana",9,barclr,cor,xdis+aj+djd,ydis+155);
    CreateLabel(0,"CLOSE","C: "+DoubleToString(iClose(_Symbol,tf1,0),_Digits),"Verdana",9,barclr,cor,xdis+djd,ydis+170);
    CreateLabel(0,"ASK","Ask: "+DoubleToString(e_ask,_Digits),"Verdana",8,clrfont,cor,xdis,ydis+190);
    CreateLabel(0,"BID","Bid : "+DoubleToString(e_bid,_Digits),"Verdana",8,clrfont,cor,xdis,ydis+205);
    CreateLabel(0,"SPREAD","Spread: "+DoubleToString(e_pread,2)+" pips","Verdana",8,clrfont,cor,xdis,ydis+220);
    //--
    ptime=ctime;
    //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---------//

void CurrentArrayFree(void)
  { 
//---
     //-- free the arrays
     ArrayFree(Hi);
     ArrayFree(Op);
     ArrayFree(Lo);
     ArrayFree(Cl);
     ArrayFree(Tm);
     //--
//---
  } //-end CurrentArrayFree()
//---------//

bool ResizeArray(void) 
 { 
//--- exit if the size of the used memory exceeds the size of the physical memory
    if(TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL)/TerminalInfoInteger(TERMINAL_MEMORY_USED)<2)
       return(false);
    //--
//--- attempt to allocate memory
    ArrayResize(Hi,avbars);
    ArrayResize(Op,avbars);
    ArrayResize(Lo,avbars);
    ArrayResize(Cl,avbars);
    ArrayResize(Tm,avbars);
    //--
    ArraySetAsSeries(Hi,true);
    ArraySetAsSeries(Op,true);
    ArraySetAsSeries(Lo,true);
    ArraySetAsSeries(Cl,true);
    ArraySetAsSeries(Tm,true);
    //--
   return(true);
//---
  } //-end ResizeArray()
//---------//

void Bars_Candlestick()
  {
   //---
   CurrentArrayFree();
   ResizeArray();
   RefreshRates();
   //--
//--- last bar counting position
   for(int v=avbars-1; v>=0 && !IsStopped(); v--)
     {
       Hi[v]=iHigh(_Symbol,tf1,v);
       Op[v]=iOpen(_Symbol,tf1,v);
       Lo[v]=iLow(_Symbol,tf1,v);
       Cl[v]=iClose(_Symbol,tf1,v);
       Tm[v]=iTime(_Symbol,tf1,v);
     }
   //--
   return;
   //---
  } //-end Bars_Candlestick()
//---------//

//+------------------------------------------------------------------+
//|   ENUM TYPE CANDLESTICK                                          |
//+------------------------------------------------------------------+
enum TYPE_CANDLESTICK
  {
   CAND_MARIBOZU,       //Maribozu
   CAND_MARIBOZU_LONG,  //Maribozu long
   CAND_DOJI,           //Doji
   CAND_SPIN_TOP,       //Spins
   CAND_HAMMER,         //Hammer
   CAND_INVERT_HAMMER,  //Inverted Hammer
   CAND_LONG,           //Long
   CAND_MEDIAN,         //Median
   CAND_SHORT,          //Short
   CAND_STAR,           //Star
   CAND_MINI            //Mini
  };
//---------//
//+------------------------------------------------------------------+
//|   ENUM CANDLESTICK COLOR                                         |
//+------------------------------------------------------------------+
enum BAR_COLOR
  {
   CMARIBOZU,       //Maribozu Color
   CMARIBOZU_LONG,  //Maribozu long Color
   CDOJI,           //Doji Color
   CSPIN_TOP,       //Spins Color
   CHAMMER,         //Hammer Color
   CINVERT_HAMMER,  //Inverted Hammer Color
   CLONG,           //Long Color
   CMEDIAN,         //Long Color
   CSHORT,          //Short Color
   CSTAR,           //Star
   CMINI            //Mini
  };
//---------//
//+------------------------------------------------------------------+
//|   TYPE_TREND                                                     |
//+------------------------------------------------------------------+
enum TYPE_TREND
  {
   RISE,    //Ascending
   DOWN,    //Descending
   LATERAL  //Lateral
  };
//---------//
//+------------------------------------------------------------------+
//|   TYPE_TREND                                                     |
//+------------------------------------------------------------------+
enum TYPE_WICK
  {
   LONG_WICK,   //Long Wick
   SMALL_WICK,  //Small Wick
   TINY_WICK    //Tiny Wick
  };
//---------//
//+------------------------------------------------------------------+
//|   CANDLE_STRUCTURE                                               |
//+------------------------------------------------------------------+
struct CANDLE_STRUCTURE
  {
   double            open,high,low,close; // OHLC
   datetime          time;                //Time
   TYPE_TREND        trend;               //Trend
   bool              bull;                //Bullish candlestick
   double            HiLo;                //Size of High - Low
   double            bodysize;            //Size of body
   double            shigh;               //Size of High Wick
   double            shlow;               //Size of Low Wick
   TYPE_WICK         hiwick;              //Size of Wick High
   TYPE_WICK         lowick;              //Size of Wick Low
   BAR_COLOR         bclr;                //Candle Color
   TYPE_CANDLESTICK  type;                //Type of candlestick
  };
//---------//
//+------------------------------------------------------------------+
//|   Function of determining of candlestick                         |
//+------------------------------------------------------------------+
void RecognizeCandle(string symbol,ENUM_TIMEFRAMES period,datetime time,int aver_period,CANDLE_STRUCTURE &res)
  {
//--- Get details of the previous candlestick
   int bar=iBarShift(symbol,period,time,false);
   Bars_Candlestick();
   res.open=Op[bar];
   res.high=Hi[bar];
   res.low=Lo[bar];
   res.close=Cl[bar];
   res.time=Tm[bar];
//--- Determine direction of trend
   //--
   if(res.open<res.close) res.trend=RISE;
   else if(res.open>res.close) res.trend=DOWN;
   else res.trend=LATERAL;
//--- Determine if it's a bullish or a bearish candlestick
   res.bull=res.close>=res.open;
//--- Get the absolute size of body of candlestick
   res.bodysize=fabs(res.open-res.close);
   //--
   res.HiLo=res.high-res.low;
//--- Get sizes of shadows
   res.shlow=res.close-res.low;
   res.shigh=res.high-res.open;
   if(res.bull)
     {
      res.shlow=res.open-res.low;
      res.shigh=res.high-res.close;
     }
   //--
   if(res.shigh>res.bodysize*2) res.hiwick=LONG_WICK;
   if(res.shigh<res.bodysize*2 && res.shigh>res.bodysize*0.16) res.hiwick=SMALL_WICK;
   if(res.shigh<res.bodysize*0.1) res.hiwick=TINY_WICK;
   //--
   if(res.shlow>res.bodysize*2) res.lowick=LONG_WICK;
   if(res.shlow<res.bodysize*2 && res.shlow>res.bodysize*0.16) res.lowick=SMALL_WICK;
   if(res.shlow<res.bodysize*0.1) res.lowick=TINY_WICK;
   //--
//--- Calculate average size of body of previous candlesticks
   double sum=0;
   for(int i=1; i<avbars; i++)
      sum=sum+fabs(Op[i]-Cl[i]);
   sum=sum/(aver_period);
   //--
//--- Determine type of candlestick
//--- long 
   if(res.bodysize>sum*1.35) {res.type=CAND_LONG; res.bclr=CLONG;}
//--- median 
   if(res.bodysize>sum*1.0 && res.bodysize<=sum*1.35) {res.type=CAND_MEDIAN; res.bclr=CLONG;}
//--- sort 
   if(res.bodysize>=sum*0.5 && res.bodysize<=sum*1.0) {res.type=CAND_SHORT; res.bclr=CSHORT;}
//--- mini 
   if(res.bodysize<sum*0.5) {res.type=CAND_MINI; res.bclr=CSTAR;} 
//--- doji
   if(res.bodysize<res.HiLo*0.03 || res.trend==LATERAL) {res.type=CAND_DOJI; res.bclr=CDOJI;}
//--- maribozu
   if((res.lowick==TINY_WICK || res.hiwick==TINY_WICK) && res.bodysize>0)
     {
      if(res.type==CAND_LONG)
         {res.type=CAND_MARIBOZU_LONG; res.bclr=CMARIBOZU_LONG;}
      else
      if(res.type==CAND_MEDIAN)
         {res.type=CAND_MARIBOZU; res.bclr=CMARIBOZU;}
     }
//--- hammer
   if(res.type==CAND_MINI && res.lowick==LONG_WICK && res.hiwick==TINY_WICK) {res.type=CAND_HAMMER; res.bclr=CHAMMER;}
//--- invert hammer
   if(res.type==CAND_MINI && res.lowick==TINY_WICK && res.hiwick==LONG_WICK) {res.type=CAND_INVERT_HAMMER; res.bclr=CINVERT_HAMMER;}
//--- spinning top
   if(res.type==CAND_MINI && res.shlow>res.bodysize && res.shigh>res.bodysize) {res.type=CAND_SPIN_TOP; res.bclr=CSPIN_TOP;}
//--- star
   if(res.type==CAND_MINI && ((res.lowick==SMALL_WICK||res.hiwick==TINY_WICK)||(res.lowick==TINY_WICK||res.hiwick==SMALL_WICK)))
     {res.type=CAND_STAR; res.bclr=CSTAR;}
//---
   return;
  }
//---------//

string strTF(int period)
  {
//---
   string periodcur;
   switch(period)
     {
       //--
       case PERIOD_M1:  periodcur="M1";  break;
       case PERIOD_M5:  periodcur="M5";  break;
       case PERIOD_M15: periodcur="M15"; break;
       case PERIOD_M30: periodcur="M30"; break;
       case PERIOD_H1:  periodcur="H1";  break;
       case PERIOD_H4:  periodcur="H4";  break;
       case PERIOD_D1:  periodcur="D1";  break;
       case PERIOD_W1:  periodcur="W1";  break;
       case PERIOD_MN1: periodcur="MN";  break;
       //--
     }
   //--
   return(periodcur);
   //---
  } //-end strTF()
//---------//

void DrawSignal(string   txtprice,
                datetime bartm,
                double   barprc,
                double   triprc,
                double   dspread,
                string   txtbar,
                string   txtpatt,
                string   txtdirect,
                string   txttrig,
                color    sigclr)
  { 
//---
     string trigprice=StringFind(txttrig,"BUY",0)>0 ? DoubleToString(triprc+dspread,_Digits) : DoubleToString(triprc-dspread,_Digits);
     int anchor=StringFind(txttrig,"BUY",0)>0 ? ANCHOR_UPPER : ANCHOR_LOWER;
     CreateText(0,txtprice,bartm,barprc,CharToString(108),"Wingdings",8,sigclr,anchor);
     CreateLabel(0,"Pattern","Pattern: "+txtpatt,"Verdana",8,clrfont,cor,xdis,ydis+60);
     CreateLabel(0,"Position",txtbar,"Verdana",8,clrfont,cor,xdis,ydis+75);
     CreateLabel(0,"Direction",txtdirect,"Verdana",8,clrfont,cor,xdis,ydis+90);
     CreateLabel(0,"Trigger",txttrig+trigprice,"Verdana",8,clrfont,cor,xdis,ydis+105);
   //---
   return;
  }
//---------//

void CreateLabel(long   chart_id, 
                 string lable_name, 
                 string label_text,
                 string font_model,
                 int    font_size,
                 color  label_color,
                 int    chart_corner,
                 int    x_cor, 
                 int    y_cor) 
  { 
//--- 
   if(ObjectFind(chart_id,lable_name)<0)
     {
       if(ObjectCreate(chart_id,lable_name,OBJ_LABEL,0,0,0,0,0)) 
         { 
           ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
           ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
           ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,x_cor);
           ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
         } 
       else 
          {Print("Failed to create the object OBJ_LABEL ",lable_name,", Error code = ", GetLastError());}
     }
   else
     {
       ObjectSetString(chart_id,lable_name,OBJPROP_TEXT,label_text);
       ObjectSetString(chart_id,lable_name,OBJPROP_FONT,font_model); 
       ObjectSetInteger(chart_id,lable_name,OBJPROP_FONTSIZE,font_size);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_COLOR,label_color);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_CORNER,chart_corner);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_XDISTANCE,x_cor);
       ObjectSetInteger(chart_id,lable_name,OBJPROP_YDISTANCE,y_cor);
     }
   //---
   return;
  }
//---------//

void CreateText(long   chart_id, 
                string text_name,
                datetime txt_time,
                double   txt_price,
                string label_text,
                string font_model,
                int    font_size,
                color  text_color,
                int    anchor)
  { 
//--- 
   if(ObjectFind(chart_id,text_name)<0)
     {
       if(ObjectCreate(chart_id,text_name,OBJ_TEXT,0,txt_time,txt_price))
         { 
           ObjectSetString(chart_id,text_name,OBJPROP_TEXT,label_text);
           ObjectSetString(chart_id,text_name,OBJPROP_FONT,font_model); 
           ObjectSetInteger(chart_id,text_name,OBJPROP_FONTSIZE,font_size);
           ObjectSetInteger(chart_id,text_name,OBJPROP_COLOR,text_color);
           ObjectSetInteger(chart_id,text_name,OBJPROP_ANCHOR,anchor);
         } 
       else 
          {Print("Failed to create the object OBJ_TEXT ",text_name,", Error code = ", GetLastError());}
     }
   else
     {
       ObjectSetString(chart_id,text_name,OBJPROP_TEXT,label_text);
       ObjectSetString(chart_id,text_name,OBJPROP_FONT,font_model); 
       ObjectSetInteger(chart_id,text_name,OBJPROP_FONTSIZE,font_size);
       ObjectSetInteger(chart_id,text_name,OBJPROP_COLOR,text_color);
       ObjectSetInteger(chart_id,text_name,OBJPROP_ANCHOR,anchor);
     }
   //---
   return;
  }
//---------//
//+------------------------------------------------------------------+