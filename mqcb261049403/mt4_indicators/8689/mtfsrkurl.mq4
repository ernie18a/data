//KurlFX 2009.01.30
//+-------------------------------------------------------------------------+
//|    MultiTimeFrameSupportResistance-Lines    *** MTFSR ***               |
//+-------------------------------------------------------------------------+
#property copyright "Copyright (c) 2009,Kurl FX"
#property indicator_chart_window

//sub2
extern int FastEMA = 5;
extern int SlowEMA = 100;
extern int SignalSMA=3;

//sub3
extern int K_Period = 5;
extern int D_Period = 3;
extern int Slowing=3;

extern string MyCurrency="USD";
extern string FreeComnt=" ";
extern bool Alerts=false;
extern color ZoneCol=Pink;

color Txcol=Green;       //line text color
color STxcol=Olive;      //signal line text color ;support
color RTxcol=Crimson;    //signal line text color ;resistance

int TF[6]={5,15,30,60,240,1440};   //timeframe M5 - D1
string TMstr[6]={"M5","M15","M30","H1","H4","D1"},Settm[6];
color Rcol[6]={DeepPink,Red,C'235,0,0',C'215,0,0',C'195,0,0',C'175,0,0'};  //"R"color
color Scol[6]={Green,Lime,C'0,230,0',C'0,205,0',C'0,180,0',C'0,155,0'};    //"S"color
double BS[6],GS[6];           //main variables
static double pAlrt1,pAlrt2;  //former alert value

string Label,MyC,QtC;
datetime Tmgap,Rftm;
string Tdn="Ѓ@ЃҐ",Tup="Ѓ@ЃЈ ";
int Lotsz;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- Label
   Label="MTFSR:MACD("+FastEMA+","+SlowEMA+","+SignalSMA+"),Stochastic("+K_Period+","+D_Period+","+Slowing+"),HeikinAshi";

   int    obj_total=ObjectsTotal();
   string name;
   for(int i=0; i<obj_total; i++)
     {
      name=ObjectName(obj_total-1-i);
      if(StringSubstr(name,0,5)=="MTFSR") ObjectDelete(name);
     }
//----
   Rftm=TimeLocal();
   Tmgap=Rftm-TimeCurrent();
   QtC=StringSubstr(Symbol(),3,3);
   MyC=MyCurrency;
   Lotsz=MarketInfo(Symbol(),MODE_LOTSIZE);

//--"Resistance"
   ObjectCreate("MTFSR_lb_R",OBJ_LABEL,0,0,0);
   ObjectSetText("MTFSR_lb_R","Resistance",14,"Arial",Red);
   ObjectSet("MTFSR_lb_R",OBJPROP_CORNER,1);
   ObjectSet("MTFSR_lb_R",OBJPROP_YDISTANCE,2);
   ObjectSet("MTFSR_lb_R",OBJPROP_XDISTANCE,2);
//--"Support"   
   ObjectCreate("MTFSR_lb_S",OBJ_LABEL,0,0,0);
   ObjectSetText("MTFSR_lb_S","Support",14,"Arial",Green);
   ObjectSet("MTFSR_lb_S",OBJPROP_CORNER,1);
   ObjectSet("MTFSR_lb_S",OBJPROP_YDISTANCE,16);
   ObjectSet("MTFSR_lb_S",OBJPROP_XDISTANCE,2);

   for(i=0;i<=5;i++)
     {
      //--"S"
      ObjectCreate("MTFSR_lb_S "+TMstr[i],OBJ_LABEL,0,0,0);
      ObjectSetText("MTFSR_lb_S "+TMstr[i],"S",14,"Arial",Scol[i]);
      ObjectSet("MTFSR_lb_S "+TMstr[i],OBJPROP_CORNER,1);
      ObjectSet("MTFSR_lb_S "+TMstr[i],OBJPROP_YDISTANCE,16*i+35);
      ObjectSet("MTFSR_lb_S "+TMstr[i],OBJPROP_XDISTANCE,18);
      //--"R"
      ObjectCreate("MTFSR_lb_R "+TMstr[i],OBJ_LABEL,0,0,0);
      ObjectSetText("MTFSR_lb_R "+TMstr[i],"R",14,"Arial",Rcol[i]);
      ObjectSet("MTFSR_lb_R "+TMstr[i],OBJPROP_CORNER,1);
      ObjectSet("MTFSR_lb_R "+TMstr[i],OBJPROP_YDISTANCE,16*i+35);
      ObjectSet("MTFSR_lb_R "+TMstr[i],OBJPROP_XDISTANCE,2);
      //--Pts.
      ObjectCreate("MTFSR_lb_Pt"+TMstr[i],OBJ_LABEL,0,0,0);
      ObjectSetText("MTFSR_lb_Pt"+TMstr[i]," ",14,"Arial",0);
      ObjectSet("MTFSR_lb_Pt"+TMstr[i],OBJPROP_CORNER,1);
      ObjectSet("MTFSR_lb_Pt"+TMstr[i],OBJPROP_YDISTANCE,16*i+35);
      ObjectSet("MTFSR_lb_Pt"+TMstr[i],OBJPROP_XDISTANCE,34);
      //--line text
      ObjectCreate("MTFSR_tx_Pt"+TMstr[i],OBJ_TEXT,0,0,0);
      ObjectSetText("MTFSR_tx_Pt"+TMstr[i],"init",9,"Arial",0);
     }
//--spread zone    
   ObjectCreate("MTFSR_sp_zone",OBJ_RECTANGLE,0,0,Bid,D'2020.01.01 00:00',Ask);
   ObjectSet("MTFSR_sp_zone",OBJPROP_COLOR,ZoneCol);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int    obj_total=ObjectsTotal();
   string name;
   for(int i=0; i<obj_total; i++)
     {
      name=ObjectName(obj_total-1-i);
      string chk=StringSubstr(name,0,5);
      if(chk=="MFTSR") ObjectDelete(name);
     }
   Comment(" ");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   ObjectSet("MTFSR_sp_zone",OBJPROP_PRICE1,Bid);
   ObjectSet("MTFSR_sp_zone",OBJPROP_PRICE2,Ask);
   int symsp=MarketInfo(Symbol(),MODE_SPREAD);
   int cntbar=IndicatorCounted();
   int bvc=WindowBarsPerChart()/4;
   color col[6];
   string mgstr,spstr,strt[6],cmnt="",cmntd;
   double bb,ep;

   if(QtC==MyC) bb=1.0;//
   else
     {
      double qm,mq;
      qm=iClose(QtC+MyC,0,0);mq=iClose(MyC+QtC,0,0);
      if(qm!=0) bb=qm;
      else
        {
         if(mq!=0) bb=1/mq;
         else
           {
            double bbu,ubb,uq,qu,mu,um;
            qu=iClose(QtC+"USD",0,0);uq=iClose("USD"+QtC,0,0);
            mu=iClose(MyC+"USD",0,0);um=iClose("USD"+MyC,0,0);
            if(qu!=0) bbu=qu;
            else if(uq!=0) bbu=1/uq;
            if(um!=0) ubb=um;
            else if(mu!=0) ubb=1/mu;
            bb=bbu*ubb;
           }
        }
     }
   bb*=Lotsz/MathPow(10,Digits);
   mgstr="1 Pt. = "+DoubleToStr(bb,Digits)+" "+MyC+"/Lot";
   spstr= "Spread = "+DoubleToStr(symsp,0)+" Pts. = "+ DoubleToStr(symsp*bb,0)+" "+MyC+"/Lot";

   int cntis=0,cntir=0;
   double hisup=0,lores=999;
   for(int i=5; i>=0; i--)
     {
      double pGS=GS[i];
      BS[i]=iCustom(NULL,TF[i],"MTFPI-sub1",FastEMA,SlowEMA,SignalSMA,K_Period,D_Period,Slowing,0,0);
      GS[i]=iCustom(NULL,TF[i],"MTFPI-sub1",FastEMA,SlowEMA,SignalSMA,K_Period,D_Period,Slowing,1,0);

      if(BS[i]==0)//no line,erase
        {
         if(ObjectFind("MTFSR_"+TMstr[i]+" Support ")!=-1)ObjectDelete("MTFSR_"+TMstr[i]+" Support ");
         if(ObjectFind("MTFSR_"+TMstr[i]+" Resistance ")!=-1)ObjectDelete("MTFSR_"+TMstr[i]+" Resistance ");
         ObjectSetText("MTFSR_tx_Pt"+TMstr[i]," ",9,"Arial",0);
         ObjectSetText("MTFSR_lb_Pt"+TMstr[i]," ",14,"Arial",0);
         strt[i]=TMstr[i];
         cmntd="--"+"\n";
        }
      else//line 
        {
         if(BS[i]==-1)//resistance
           {
            col[i]=Rcol[i];
            strt[i]=TMstr[i]+" Resistance ";
            if(ObjectFind("MTFSR_"+TMstr[i]+" Support ")!=-1)ObjectDelete("MTFSR_"+TMstr[i]+" Support ");
            string typ="Sell ";double bidask=Ask;color slc=RTxcol;ep=Bid;cntir++;
            if(GS[i]<lores)lores=GS[i];
           }
         else//support
           {
            col[i]=Scol[i];
            strt[i]=TMstr[i]+" Support ";
            if(ObjectFind("MTFSR_"+TMstr[i]+" Resistance ")!=-1)ObjectDelete("MTFSR_"+TMstr[i]+" Resistance ");
            typ="Buy ";bidask=Bid;slc=STxcol;ep=Ask;cntis++;
            if(GS[i]>hisup)hisup=GS[i];
           }

         if(ObjectFind("MTFSR_"+strt[i])!=-1)//already exist
           {
            if(GS[i]!=pGS)//move
              {
               ObjectSet("MTFSR_"+strt[i],OBJPROP_PRICE1,GS[i]);
               if(cntbar==0) Settm[i]=" ";
               else Settm[i]="#Local time: "+TimeToStr(TimeLocal(),TIME_SECONDS);
              }
           }
         else//create new
           {
            ObjectCreate("MTFSR_"+strt[i],OBJ_HLINE,0,0,GS[i]);
            ObjectSet("MTFSR_"+strt[i],OBJPROP_COLOR,col[i]);
            ObjectSet("MTFSR_"+strt[i],OBJPROP_WIDTH,2);
            if(cntbar==0) Settm[i]=" ";
            else   Settm[i]="#Local time: "+TimeToStr(TimeLocal(),TIME_SECONDS);
            if(i==0)
              {
               ObjectSet("MTFSR_"+strt[0],OBJPROP_WIDTH,3);
               if(BS[0]==1){int cnti=cntis;double stp=hisup;double tg=lores;}else{cnti=cntir;stp=lores;tg=hisup;}
               double spa=symsp*Point;
               if(MathAbs(ep-stp)>spa*2.4 && MathAbs(tg-ep)>spa*3.0)int f=1;else f=0;
               if(cntbar!=0 && stp!=pAlrt1 && stp!=pAlrt2 && cnti>=3 && f==1)
                 {
                  if(Alerts==true)
                    {
                     if(pAlrt1==0)string pal1="";else pal1=DoubleToStr(pAlrt1,Digits)+">>";
                     if(pAlrt2==0)string pal2="";else pal2=DoubleToStr(pAlrt2,Digits)+">>";
                     Alert("MTFSR_M5 "+typ+Symbol()+" @"+DoubleToStr(ep,Digits)+" //*"+pal2+pal1+DoubleToStr(stp,Digits));
                     pAlrt2=pAlrt1;pAlrt1=stp;
                    }
                  string tm=TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES);
                  datetime ct=TimeCurrent();//servertime
                  if(ObjectFind("SGNL"+typ+tm)!=-1)
                    {
                     ObjectSet("SGNL"+typ+tm,OBJPROP_PRICE1,ep);
                     ObjectSet("SGNL"+"stp"+typ+tm,OBJPROP_PRICE1,stp);
                     ObjectSet("SGNL"+"jnt"+typ+tm,OBJPROP_PRICE1,ep);
                     ObjectSet("SGNL"+"jnt"+typ+tm,OBJPROP_PRICE2,stp);
                    }
                  else
                    {
                     //--entry
                     ObjectCreate("SGNL"+typ+tm,OBJ_ARROW,0,ct,ep);
                     ObjectSet("SGNL"+typ+tm,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
                     ObjectSet("SGNL"+typ+tm,OBJPROP_COLOR,col[0]);
                     //--stop
                     ObjectCreate("SGNL"+"stp"+typ+tm,OBJ_ARROW,0,ct,stp);
                     ObjectSet("SGNL"+"stp"+typ+tm,OBJPROP_ARROWCODE,213);
                     ObjectSet("SGNL"+"stp"+typ+tm,OBJPROP_COLOR,col[0]);
                     //--joint
                     ObjectCreate("SGNL"+"jnt"+typ+tm,OBJ_TREND,0,ct,ep,ct,stp);
                     ObjectSet("SGNL"+"jnt"+typ+tm,OBJPROP_COLOR,col[0]);
                     ObjectSet("SGNL"+"jnt"+typ+tm,OBJPROP_RAY,FALSE);
                     ObjectSet("SGNL"+"jnt"+typ+tm,OBJPROP_STYLE,STYLE_DOT);
                    }
                 }
              }
           }
         string mrg,mrgl,mrgc,mrgsig;
         double mrgp=(bidask-GS[i])*MathPow(10,Digits);
         if(mrgp>=0)mrgsig=Tup; else mrgsig=Tdn;
         mrg=DoubleToStr(mrgp,0);
         mrgl=DoubleToStr(mrgp*bb,0);
         mrgc=mrg+" P( "+mrgl+" "+MyC+"/Lot )";
         cmntd=DoubleToStr(GS[i],Digits)+mrgsig+mrg+" P= "+mrgl+" "+MyC+"/Lot "+Settm[i]+"\n";

         double pr1=ObjectGet("MTFSR_"+strt[i],OBJPROP_PRICE1);
         ObjectSet("MTFSR_tx_Pt"+TMstr[i],OBJPROP_PRICE1,pr1);
         ObjectSet("MTFSR_tx_Pt"+TMstr[i],OBJPROP_TIME1,Time[bvc]);
         if(i==0)color c=slc;else c=Txcol;
         ObjectSetText("MTFSR_tx_Pt"+TMstr[i],mrgc,9,"Arial",c);
         ObjectSetText("MTFSR_lb_Pt"+TMstr[i],mrg+" Pts.",14,"Arial",col[i]);
        }
      cmnt=cmnt+strt[i]+": "+cmntd;
     }
   Comment(Label,"\n",mgstr,"\n",spstr,"\n",cmnt,QtC,"/",MyC,":",bb,"\n",TimeToStr(Rftm,TIME_DATE|TIME_SECONDS),"\n",FreeComnt);

   return(0);
  }
//+------------------------------------------------------------------+
