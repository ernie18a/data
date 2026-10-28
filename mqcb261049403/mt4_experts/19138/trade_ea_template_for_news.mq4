//+------------------------------------------------------------------+
//|                                   Trade EA Template for News.mq4 |
//|                                              Copyright 2017, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Tor"
#property link      "http://einvestor.ru/"
#property version   "1.00"
#property strict

extern   string   _comment1=" ----------- News settings ----------- ";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeNS
  {
   INVEST=0,   // Investing.com
   DAILYFX=1,  // Dailyfx.com
  };
//--- input parameters 
extern TypeNS SourceNews=INVEST;
extern bool     LowNews             = true;
extern int      LowIndentBefore     = 15;
extern int      LowIndentAfter      = 15;
extern bool     MidleNews           = true;
extern int      MidleIndentBefore   = 30;
extern int      MidleIndentAfter    = 30;
extern bool     HighNews            = true;
extern int      HighIndentBefore    = 60;
extern int      HighIndentAfter     = 60;
extern bool     NFPNews             = true;
extern int      NFPIndentBefore     = 180;
extern int      NFPIndentAfter      = 180;

extern bool    DrawNewsLines        = true;
extern color   LowColor             = clrGreen;
extern color   MidleColor           = clrBlue;
extern color   HighColor            = clrRed;
extern int     LineWidth            = 1;
extern ENUM_LINE_STYLE LineStyle    = STYLE_DOT;
extern bool    OnlySymbolNews       = true;
extern int  GMTplus=3;     // Your Time Zone, GMT (for news)

int NomNews=0,Now=0,MinBefore=0,MinAfter=0;
string NewsArr[4][1000];
datetime LastUpd;
string ValStr;
int   Upd            = 86400;      // Period news updates in seconds
bool  Next           = false;      // Draw only the future of news line
bool  Signal         = false;      // Signals on the upcoming news
datetime TimeNews[300];
string Valuta[300],News[300],Vazn[300];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string v1=StringSubstr(_Symbol,0,3); string v2=StringSubstr(_Symbol,3,3);
   ValStr=v1+","+v2;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
   del("NS_");
  }
//+------------------------------------------------------------------+
//| Expert tick function    OnTick()                                 |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string TextDisplay="";

/*  Check News   */
   bool trade=true; string nstxt=""; int NewsPWR=0; datetime nextSigTime=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(SourceNews==0)
        {// Investing
         if(CheckInvestingNews(NewsPWR,nextSigTime)){ trade=false; } // news time
        }
      if(SourceNews==1)
        {//DailyFX
         if(CheckDailyFXNews(NewsPWR,nextSigTime)){ trade=false; } // news time
        }
     }
   if(trade)
     {// No News, Trade enabled
      nstxt="No News";
      if(ObjectFind(0,"NS_Label")!=-1){ ObjectDelete(0,"NS_Label"); }

        }else{// waiting news , check news power
      color clrT=LowColor;
      if(NewsPWR>3)
        {
         nstxt= "Waiting Non-farm Payrolls News";
         clrT = HighColor;
           }else{
         if(NewsPWR>2)
           {
            nstxt= "Waiting High News";
            clrT = HighColor;
              }else{
            if(NewsPWR>1)
              {
               nstxt= "Waiting Midle News";
               clrT = MidleColor;
                 }else{
               nstxt= "Waiting Low News";
               clrT = LowColor;
              }
           }
        }
      // Make Text Label
      if(nextSigTime>0){ nstxt=nstxt+" "+TimeToString(nextSigTime,TIME_MINUTES); }
      if(ObjectFind(0,"NS_Label")==-1)
        {
         LabelCreate(StringConcatenate(nstxt),clrT);
        }
      if(ObjectGetInteger(0,"NS_Label",OBJPROP_COLOR)!=clrT)
        {
         ObjectDelete(0,"NS_Label");
         LabelCreate(StringConcatenate(nstxt),clrT);
        }
     }
   nstxt="\n"+nstxt;
/*  End Check News   */

   if(IsTradeAllowed() && trade)
     {// No news and Trade Allowed
      ManageTrade(); // Your trade functions
     }

   TextDisplay=TextDisplay+nstxt;
   Comment(TextDisplay);

   return;
  }
//+------------------------------------------------------------------+
void ManageTrade()
  {
   int tkt=0;
   if(iOpen(_Symbol,PERIOD_H1,1)<iClose(_Symbol,PERIOD_H1,0) && OrdersTotal()<1)
     {
      tkt=OrderSend(Symbol(),OP_BUY,0.01,Ask,2,Ask-100*_Point,Ask+100*_Point,"",0,0,clrBlue);
     }
   if(iOpen(_Symbol,PERIOD_H1,1)>iClose(_Symbol,PERIOD_H1,0) && OrdersTotal()<1)
     {
      tkt=OrderSend(Symbol(),OP_SELL,0.01,Bid,2,Bid+100*_Point,Bid-100*_Point,"",0,0,clrRed);
     }
   return;
  }
//////////////////////////////////////////////////////////////////////////////////
string ReadCBOE()
  {

   string cookie=NULL,headers;
   char post[],result[];     string TXT="";
   int res;
//--- to work with the server, you must add the URL "https://www.google.com/finance"  
//--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"): 
   string google_url="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
//--- 
   ResetLastError();
//--- download html-pages
   int timeout=5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
//--- error checking
   if(res==-1)
     {
      Print("WebRequest error, err.code  =",GetLastError());
      MessageBox("You must add the address 'http://ec.forexprostools.com/' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
      //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
     }
   else
     {
      //--- successful download
      //PrintFormat("File successfully downloaded, the file size in bytes  =%d.",ArraySize(result)); 
      //--- save the data in the file
      int filehandle=FileOpen("news-log.html",FILE_WRITE|FILE_BIN);
      //--- проверка ошибки 
      if(filehandle!=INVALID_HANDLE)
        {
         //---save the contents of the array result [] in file 
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- close file 
         FileClose(filehandle);

         int filehandle2=FileOpen("news-log.html",FILE_READ|FILE_BIN);
         TXT=FileReadString(filehandle2,ArraySize(result));
         FileClose(filehandle2);
           }else{
         Print("Error in FileOpen. Error code =",GetLastError());
        }
     }

   return(TXT);
  }
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)
  {
   string s=NewsArr[0][nomf];
   string time=StringConcatenate(StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
   return((datetime)(StringToTime(time) + GMTplus*3600));
  }
//////////////////////////////////////////////////////////////////////////////////
void UpdateNews()
  {
   string TEXT=ReadCBOE();
   int sh = StringFind(TEXT,"pageStartAt>")+12;
   int sh2= StringFind(TEXT,"</tbody>");
   TEXT=StringSubstr(TEXT,sh,sh2-sh);

   sh=0;
   while(!IsStopped())
     {
      sh = StringFind(TEXT,"event_timestamp",sh)+17;
      sh2= StringFind(TEXT,"onclick",sh)-2;
      if(sh<17 || sh2<0)break;
      NewsArr[0][NomNews]=StringSubstr(TEXT,sh,sh2-sh);

      sh = StringFind(TEXT,"flagCur",sh)+10;
      sh2= sh+3;
      if(sh<10 || sh2<3)break;
      NewsArr[1][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][NomNews])<0)continue;

      sh = StringFind(TEXT,"title",sh)+7;
      sh2= StringFind(TEXT,"Volatility",sh)-1;
      if(sh<7 || sh2<0)break;
      NewsArr[2][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(NewsArr[2][NomNews],"High")>=0 && !HighNews)continue;
      if(StringFind(NewsArr[2][NomNews],"Moderate")>=0 && !MidleNews)continue;
      if(StringFind(NewsArr[2][NomNews],"Low")>=0 && !LowNews)continue;

      sh=StringFind(TEXT,"left event",sh)+12;
      int sh1=StringFind(TEXT,"Speaks",sh);
      sh2=StringFind(TEXT,"<",sh);
      if(sh<12 || sh2<0)break;
      if(sh1<0 || sh1>sh2)NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      else NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh1-sh);

      NomNews++;
      if(NomNews==300)break;
     }
  }
//+------------------------------------------------------------------+
int del(string name) // Спец. ф-ия deinit()
  {
   for(int n=ObjectsTotal()-1; n>=0; n--)
     {
      string Obj_Name=ObjectName(n);
      if(StringFind(Obj_Name,name,0)!=-1)
        {
         ObjectDelete(Obj_Name);
        }
     }
   return 0;                                      // Выход из deinit()
  }
//+------------------------------------------------------------------+
bool CheckInvestingNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false; pwr=0; int maxPower=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(TimeCurrent()-LastUpd>=Upd){Print("Investing.com News Loading...");UpdateNews();LastUpd=TimeCurrent();Comment("");}
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0;i<NomNews;i++)
           {
            string Name=StringSubstr("NS_"+TimeToStr(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
            if(NewsArr[3][i]!="")if(ObjectFind(Name)==0)continue;
            if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][i])<0)continue;
            if(TimeNewsFunck(i)<TimeCurrent() && Next)continue;

            color clrf=clrNONE;
            if(HighNews && StringFind(NewsArr[2][i],"High")>=0)clrf=HighColor;
            if(MidleNews && StringFind(NewsArr[2][i],"Moderate")>=0)clrf=MidleColor;
            if(LowNews && StringFind(NewsArr[2][i],"Low")>=0)clrf=LowColor;

            if(clrf==clrNONE)continue;

            if(NewsArr[3][i]!="")
              {
               ObjectCreate(0,Name,OBJ_VLINE,0,TimeNewsFunck(i),0);
               ObjectSet(Name,OBJPROP_COLOR,clrf);
               ObjectSet(Name,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Name,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Name,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      int ii;
      CheckNews=false;
      for(ii=0;ii<NomNews;ii++)
        {
         int power=0;
         if(HighNews && StringFind(NewsArr[2][ii],"High")>=0){ power=3; MinBefore=HighIndentBefore; MinAfter=HighIndentAfter; }
         if(MidleNews && StringFind(NewsArr[2][ii],"Moderate")>=0){ power=2; MinBefore=MidleIndentBefore; MinAfter=MidleIndentAfter; }
         if(LowNews && StringFind(NewsArr[2][ii],"Low")>=0){ power=1; MinBefore=LowIndentBefore; MinAfter=LowIndentAfter; }
         if(NFPNews && StringFind(NewsArr[3][ii],"Nonfarm Payrolls")>=0){ power=4; MinBefore=NFPIndentBefore; MinAfter=NFPIndentAfter; }
         if(power==0)continue;

         if(TimeCurrent()+MinBefore*60>TimeNewsFunck(ii) && TimeCurrent()-MinAfter*60<TimeNewsFunck(ii) && (!OnlySymbolNews || (OnlySymbolNews && StringFind(ValStr,NewsArr[1][ii])>=0)))
           {
            if(power>maxPower){   maxPower=power; mintime=TimeNewsFunck(ii); }
              }else{
            CheckNews=false;
           }
        }
      if(maxPower>0){ CheckNews=true; }
     }
   pwr=maxPower;
   return(CheckNews);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(const string text="Label",const color clr=clrRed)
  {
   long x_distance;  long y_distance; long chart_ID=0;  string name="NS_Label"; int sub_window=0;
   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER;
   string font="Arial"; int font_size=28; double angle=0.0; ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER;
   bool back=false; bool selection=false;  bool hidden=true;  long z_order=0;
//--- определим размеры окна 
   ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance);
   ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,(int)(x_distance/2.7));
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,(int)(y_distance/1.5));
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateDFX()
  {
   string DF=""; string MF="";
   int DeltaGMT=GMTplus; // 0 -(TimeGMTOffset()/60/60)-DeltaTime;
   int ChasPoyasServera=DeltaGMT;
   datetime NowTimeD1=Time[0];
   datetime LastSunday=NowTimeD1-TimeDayOfWeek(NowTimeD1)*86399;
   int DayFile=TimeDay(LastSunday);
   if(DayFile<10) DF="0"+(string)DayFile;
   else DF=(string)DayFile;
   int MonthFile=TimeMonth(LastSunday);
   if(MonthFile<10) MF="0"+(string)MonthFile;
   else MF=(string)MonthFile;
   int YearFile=TimeYear(LastSunday);
   string DateFile=MF+"-"+DF+"-"+(string)YearFile;
   string FileName= DateFile+"_dfx.csv";
   int handle;

   if(!FileIsExist(FileName))
     {
      string url="http://www.dailyfx.com/files/Calendar-"+DateFile+".csv";
      string cookie=NULL,headers;
      char post[],result[]; string TXT=""; int res; string text="";
      ResetLastError();
      int timeout=5000;
      res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);
      if(res==-1)
        {
         Print("WebRequest error, err.code  =",GetLastError());
         MessageBox("You must add the address 'http://www.dailyfx.com/' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
        }
      else
        {
         int filehandle=FileOpen(FileName,FILE_WRITE|FILE_BIN);
         if(filehandle!=INVALID_HANDLE)
           {
            FileWriteArray(filehandle,result,0,ArraySize(result));
            FileClose(filehandle);
              }else{
            Print("Error in FileOpen. Error code =",GetLastError());
           }
        }
     }
   handle=FileOpen(FileName,FILE_READ|FILE_CSV);
   string data,time,month,valuta;
   int startStr=0;
   if(handle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(handle))
        {
         int str_size=FileReadInteger(handle,INT_VALUE);
         string str=FileReadString(handle,str_size);
         string value[10];
         int k=StringSplit(str,StringGetCharacter(",",0),value);
         data = value[0];
         time = value[1];
         if(time==""){ continue; }
         month=StringSubstr(data,4,3);
         if(month=="Jan") month="01";
         if(month=="Feb") month="02";
         if(month=="Mar") month="03";
         if(month=="Apr") month="04";
         if(month=="May") month="05";
         if(month=="Jun") month="06";
         if(month=="Jul") month="07";
         if(month=="Aug") month="08";
         if(month=="Sep") month="09";
         if(month=="Oct") month="10";
         if(month=="Nov") month="11";
         if(month=="Dec") month="12";
         TimeNews[startStr]=StrToTime((string)YearFile+"."+month+"."+StringSubstr(data,8,2)+" "+time)+ChasPoyasServera*3600;
         valuta=value[3];
         if(valuta=="eur" ||valuta=="EUR")Valuta[startStr]="EUR";
         if(valuta=="usd" ||valuta=="USD")Valuta[startStr]="USD";
         if(valuta=="jpy" ||valuta=="JPY")Valuta[startStr]="JPY";
         if(valuta=="gbp" ||valuta=="GBP")Valuta[startStr]="GBP";
         if(valuta=="chf" ||valuta=="CHF")Valuta[startStr]="CHF";
         if(valuta=="cad" ||valuta=="CAD")Valuta[startStr]="CAD";
         if(valuta=="aud" ||valuta=="AUD")Valuta[startStr]="AUD";
         if(valuta=="nzd" ||valuta=="NZD")Valuta[startStr]="NZD";
         News[startStr]=value[4];
         News[startStr]=StringSubstr(News[startStr],0,60);
         Vazn[startStr]=value[5];
         if(Vazn[startStr]!="High" && Vazn[startStr]!="HIGH" && Vazn[startStr]!="Medium" && Vazn[startStr]!="MEDIUM" && Vazn[startStr]!="MED" && Vazn[startStr]!="Low" && Vazn[startStr]!="LOW")Vazn[startStr]=FileReadString(handle);
         startStr++;
        }
        }else{
      PrintFormat("Error in FileOpen = %s. Error code= %d",FileName,GetLastError());
     }
   NomNews=startStr-1;
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckDailyFXNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false; pwr=0; int maxPower=0; color clrf=clrNONE; mintime=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(Time[0]-LastUpd>=Upd){Print("News DailyFX Loading...");UpdateDFX();LastUpd=Time[0];}
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0;i<NomNews;i++)
           {
            string Lname=StringSubstr("NS_"+TimeToStr(TimeNews[i],TIME_MINUTES)+"_"+News[i],0,63);
            if(News[i]!="")if(ObjectFind(0,Lname)==0){  continue; }
            if(TimeNews[i]<TimeCurrent() && Next){ continue; }
            if((Vazn[i]=="High" || Vazn[i]=="HIGH") && HighNews==false){ continue; }
            if((Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED") && MidleNews==false){ continue; }
            if((Vazn[i]=="Low" || Vazn[i]=="LOW") && LowNews==false){ continue; }
            if(Vazn[i]=="High" || Vazn[i]=="HIGH"){ clrf=HighColor; }
            if(Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED"){ clrf=MidleColor; }
            if(Vazn[i]=="Low" || Vazn[i]=="LOW"){ clrf=LowColor; }
            if(News[i]!="" && ObjectFind(0,Lname)<0)
              {
               if(OnlySymbolNews && (Valuta[i]!=StringSubstr(_Symbol,0,3) && Valuta[i]!=StringSubstr(_Symbol,3,3))){ continue; }
               ObjectCreate(0,Lname,OBJ_VLINE,0,TimeNews[i],0);
               ObjectSet(Lname,OBJPROP_COLOR,clrf);
               ObjectSet(Lname,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Lname,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Lname,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      for(int i=0;i<NomNews;i++)
        {
         int power=0;
         if(HighNews && (Vazn[i]=="High" || Vazn[i]=="HIGH")){ power=3; MinBefore=HighIndentBefore; MinAfter=HighIndentAfter; }
         if(MidleNews && (Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED")){ power=2; MinBefore=MidleIndentBefore; MinAfter=MidleIndentAfter; }
         if(LowNews && (Vazn[i]=="Low" || Vazn[i]=="LOW")){ power=1; MinBefore=LowIndentBefore; MinAfter=LowIndentAfter; }
         if(NFPNews && StringFind(News[i],"Non-farm Payrolls")>=0){ power=4; MinBefore=NFPIndentBefore; MinAfter=NFPIndentAfter; }
         if(power==0)continue;

         if(TimeCurrent()+MinBefore*60>TimeNews[i] && TimeCurrent()-MinAfter*60<TimeNews[i] && (!OnlySymbolNews || (OnlySymbolNews && (StringSubstr(Symbol(),0,3)==Valuta[i] || StringSubstr(Symbol(),3,3)==Valuta[i]))))
           {
            if(power>maxPower){ maxPower=power; mintime=TimeNews[i]; }
           }
         else
           {
            CheckNews=false;
           }
        }
      if(maxPower>0){ CheckNews=true; }
     }
   pwr=maxPower;
   return(CheckNews);
  }
//+------------------------------------------------------------------+
