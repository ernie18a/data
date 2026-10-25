//+------------------------------------------------------------------+
//|                                          Ausbruch Trader 1.0.mq5 |
//|                                     Copyright 2024, Igor Widiger |
//|                  https://www.mql5.com/de/users/deinschanz/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Pay24Money"
#property link      "https://p24m.eu"
#property version   "1.00"

#include <Controls\Defines.mqh>
#undef CONTROLS_FONT_NAME
#undef CONTROLS_FONT_SIZE

#undef CONTROLS_BUTTON_COLOR
#undef CONTROLS_BUTTON_COLOR_BG
#undef CONTROLS_BUTTON_COLOR_BORDER

#undef CONTROLS_DIALOG_COLOR_BORDER_LIGHT
#undef CONTROLS_DIALOG_COLOR_BORDER_DARK
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BORDER

#define CONTROLS_FONT_NAME                font_name
#define CONTROLS_FONT_SIZE                font_size

#define CONTROLS_BUTTON_COLOR             button_color
#define CONTROLS_BUTTON_COLOR_BG          button_color_bg
#define CONTROLS_BUTTON_COLOR_BORDER      button_color_border

#define CONTROLS_DIALOG_COLOR_BORDER_LIGHT dialog_color_border_light
#define CONTROLS_DIALOG_COLOR_BORDER_DARK dialog_color_border_dark
#define CONTROLS_DIALOG_COLOR_BG          dialog_color_bg
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT dialog_color_caption_text
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   dialog_color_client_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BORDER dialog_color_client_border

#include <Controls\Dialog.mqh>
CAppDialog AppWindow;
#include <Controls\Label.mqh>
CLabel Spread_label, BidLabel, AskLabel, Tagesspanne_Label, TagesspanneWert_Label,Verlust_Label, VerlustWert_Label,
       Gewinn_Label,GewinnWert_Label, MinusTag_Label, TradingAnfang_Label, TradingEnde_Label, Reverse_Label, StopArt_Label,
       Austoper_Label, Risk_Label, Lots_Label, EquityCall_Label, Stop_Label, StopWert_Label, Ziel_Label, HeuteVerdient_Label;

input datetime Datum_Start = D'2019.03.01';     // Start Datum einstellen!!
input ulong   Magic                 = 12345;    // Magicnummer
input double  StartKapital          = 10000;    // Startkapital
input double  Lots                  = 1;        // Volumeneingabe
input double  Risk                  = 1;        // Risiko pro Order in %
input bool    Reverse               = true;     // Reverse erlauben?
input bool  Anzahl_Verlust_Orders_verwenden = true; // Austoper am Tag verwenden oder nicht
input int     Verlusst_Tag          = 3;        // Anzahl negative Orders am Tag
input int     Profit_Tage           = 3;        // 1+2+3 Profit Tag Formel. Stop Loss pro Tag.
input bool    Stop_Kerze            = true;     // Stop unter Signalkerze?
input bool    Stop_Spanne           = true;     // Stop nach Tagesspanne?
input bool    Stop_Punkte           = true;     // Stop nach punkten?
input int     Stoploss              = 250;      // Stoploss, Trailing und Trailingstep
input bool    Trailing_Erlauben     = true;     // Trailing erlauben?
input double  StopGross             = 3;        // Wenn Tagesspanne höher als in (%) stop erhöhen?
input int     Takeprofit            = 5000;     // Takeprofit
input int     RestMarge             = 75;       // Equity Call. Depotschutz bei verbleibenden Betrag %?
input double  RestMarge2            = 2;        // Wenn in Gewinn Equity Call ((100 - 75)/2) erhöhen um?
input int     ProfitMarge           = 50;       // Das Ziel in %?
input double  Spanne                = 8;        // Spanne zum DayHigh und DayLow
input double  Aenderung             = 0.50;     // Trade, wenn Tagesspanne höher als (%)?
input double  Aenderung2            = 3;        // Kein Trade, wenn Tagesspanne höher als (%)?
input bool    TverkaufErlauben      = true;     // Teilverkauf erlauben?
input double  Tverkaufmal           = 1;        // Teilverkauf mal Risk
input double  Tverkaufmal2          = 3;        // Minlot mal?
input string  Mon_filter            = "Monatshandel Einstellungen";
input bool    JAN                   = true;     // Januar
input bool    FEB                   = true;     // Febuar
input bool    MAR                   = true;     // März
input bool    APR                   = true;     // April
input bool    MAI                   = true;     // Mai
input bool    JUN                   = true;     // Juni
input bool    JUL                   = true;     // Juli
input bool    AUG                   = true;     // August
input bool    SEP                   = true;     // September
input bool    OKT                   = true;     // Oktober
input bool    NOV                   = true;     // November
input bool    DEZ                   = true;     // Dezember
input string  Weekday_filter        = "Handelstage Einstellungen";
input bool    MON                   = true;     // Montag
input bool    TUE                   = true;     // Dienstag
input bool    WED                   = true;     // Mittwoch
input bool    THU                   = true;     // Donnerstag
input bool    FRI                   = true;     // Freitag
input string  Time_period           = "Trading start und Ende (00:00)";
input bool    Filter_zum_Zeithandel = true;     // Tradingzeit ab, oder anschalten true= an false= aus
input string  Trade_start           = "10:00";  // Trading start period 00:00:00
input string  Trade_Ende            = "22:50";  // Trading ende period 00:00:00
input int     TimeClose             = 23;       // Order wird geschlossen
input bool    Close_nach_Zeit       = false;    // Order nach Zeit schliessen?
input int     CloseMinuten          = 5;        // Wenn Order im Minus ist, schliessen nach (Minuten)?
input bool    Minustag              = true;     // Tag in Minus! Handel beenden.
input double  MinusProzent          = 3;        // Der Tag im Minus von Startkapital in %?
input bool    Plustag               = true;     // Tag in Plus! Handel beenden.
input double  PlusTagProzent        = 10;       // Der Tag im Gewinn von Startkapital in %?
input bool    Pluswoche             = true;     // Die Woche im Plus! Pause bis nächste Woche.
input double  PlusWocheProzent      = 10;       // Die Woche im Gewinn von Startkapital in %?
input bool    Minuswoche            = true;     // Woche in Minus! Pause bis nächste Woche.
input double  MinusWocheProzent     = 1;        // Woche Velrust von Startkapital in %?
input string  Panel_Text                 = "---------- Panel Einstellungen!";
input bool     Panel_ON                   = true; // Panel on/off
input string   font_name                  = "Trebuchet MS";
input int      font_size                  = 10;
input color    dialog_color_border_light  = White;
input color    dialog_color_border_dark   = DarkGray;
input color    dialog_color_bg            = LightSkyBlue;
input color    dialog_color_caption_text  = Black;
input color    dialog_color_client_bg     = C'242,242,242';
input color    dialog_color_client_border = Silver;

#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
CTrade m_trade;
CSymbolInfo m_symbol;
CPositionInfo  m_position;
CHistoryOrderInfo m_history;


MqlDateTime tm;
double lot, Vol;
static int qount_verlustorder=0;
static double balance=0;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {

   if(Panel_ON) {

      //--- Erstellen des Dialogs der Anwendung
      if(!AppWindow.Create(ChartID(),"Ausbruch Trader 1.0",0,20,20,267,480))
         return(INIT_FAILED);
      //--- Starten der Anwendung
      AppWindow.Run();
      //--- war erfolgreich
      string currency = " " +AccountInfoString(ACCOUNT_CURRENCY);


      if(!Spread_label.Create(0,"SPREAD",0,110,22,20,200)) {
         return(INIT_FAILED);
      }
      Spread_label.Text(DoubleToString(0,_Digits)+"");
      Spread_label.Color(clrBlue);
      Spread_label.FontSize(10);
      AppWindow.Add(Spread_label);

      if(!BidLabel.Create(0,"BIDPREIS",0,15,20,20,200)) {
         return(INIT_FAILED);
      }
      BidLabel.Text(DoubleToString(0,_Digits)+"");
      BidLabel.Color(clrRed);
      BidLabel.FontSize(14);
      AppWindow.Add(BidLabel);


      if(!AskLabel.Create(0,"ASKPREIS",0,145,20,20,200)) {
         return(INIT_FAILED);
      }
      AskLabel.Text(DoubleToString(0,_Digits)+"");
      AskLabel.Color(clrGreen);
      AskLabel.FontSize(14);
      AppWindow.Add(AskLabel);

      if(!Tagesspanne_Label.Create(0,"TAGESSPANNE",0,7,60,20,200)) {
         return(INIT_FAILED);
      }
      Tagesspanne_Label.Text("Tagesspanne:");
      Tagesspanne_Label.FontSize(font_size);
      AppWindow.Add(Tagesspanne_Label);

      if(!TagesspanneWert_Label.Create(0,"TAGESSPANNEWERT",0,180,60,20,200)) {
         return(INIT_FAILED);
      }
      TagesspanneWert_Label.Text(""+DoubleToString(0,2)+" %");
      TagesspanneWert_Label.FontSize(font_size);
      AppWindow.Add(TagesspanneWert_Label);

      if(!Verlust_Label.Create(0,"VERLUSTORDERS",0,7,80,20,200)) {
         return(INIT_FAILED);
      }
      Verlust_Label.Text("Verlust Orders:");
      Verlust_Label.FontSize(font_size);
      AppWindow.Add(Verlust_Label);

      if(!VerlustWert_Label.Create(0,"VERLUSTORDERSWERT",0,180,80,20,200)) {
         return(INIT_FAILED);
      }
      VerlustWert_Label.Text(""+DoubleToString(0,0));
      VerlustWert_Label.FontSize(font_size);
      AppWindow.Add(VerlustWert_Label);

      if(!Gewinn_Label.Create(0,"GEWINNORDERS",0,7,100,20,200)) {
         return(INIT_FAILED);
      }
      Gewinn_Label.Text("Gewinn Orders:");
      Gewinn_Label.FontSize(font_size);
      AppWindow.Add(Gewinn_Label);

      if(!GewinnWert_Label.Create(0,"GEWINNORDERSWERT",0,180,100,20,200)) {
         return(INIT_FAILED);
      }
      GewinnWert_Label.Text(""+DoubleToString(0,0));
      GewinnWert_Label.FontSize(font_size);
      AppWindow.Add(GewinnWert_Label);

      if(!MinusTag_Label.Create(0,"MINUSTAG",0,7,120,20,200)) {
         return(INIT_FAILED);
      }
      MinusTag_Label.Text(""+DoubleToString(0,_Digits));
      MinusTag_Label.FontSize(font_size);
      AppWindow.Add(MinusTag_Label);

      if(!TradingAnfang_Label.Create(0,"TRADINGANFANG",0,7,150,20,200)) {
         return(INIT_FAILED);
      }
      TradingAnfang_Label.Text(""+DoubleToString(0,_Digits));
      TradingAnfang_Label.FontSize(font_size);
      AppWindow.Add(TradingAnfang_Label);

      if(Filter_zum_Zeithandel == true) {
         if(!TradingEnde_Label.Create(0,"TRADINGENDEG",0,7,170,20,200)) {
            return(INIT_FAILED);
         }
         TradingEnde_Label.Text(""+DoubleToString(0,_Digits));
         TradingEnde_Label.FontSize(font_size);
         AppWindow.Add(TradingEnde_Label);
      }

      if(!Reverse_Label.Create(0,"REVERSE",0,7,190,20,200)) {
         return(INIT_FAILED);
      }
      Reverse_Label.Text(""+DoubleToString(0,_Digits));
      Reverse_Label.FontSize(font_size);
      AppWindow.Add(Reverse_Label);

      if(!StopArt_Label.Create(0,"STOPART",0,7,210,20,200)) {
         return(INIT_FAILED);
      }
      StopArt_Label.Text(""+DoubleToString(0,_Digits));
      StopArt_Label.FontSize(font_size);
      AppWindow.Add(StopArt_Label);

      if(!Austoper_Label.Create(0,"AUSSTOPER",0,7,230,20,200)) {
         return(INIT_FAILED);
      }
      Austoper_Label.Text(""+DoubleToString(0,_Digits));
      Austoper_Label.FontSize(font_size);
      AppWindow.Add(Austoper_Label);

      if(!Risk_Label.Create(0,"RISK",0,7,295,20,200)) {
         return(INIT_FAILED);
      }
      Risk_Label.Text(""+DoubleToString(0,_Digits));
      Risk_Label.FontSize(font_size);
      AppWindow.Add(Risk_Label);

      if(!Lots_Label.Create(0,"LOTS",0,145,295,20,200)) {
         return(INIT_FAILED);
      }
      Lots_Label.Text(""+DoubleToString(0,_Digits));
      Lots_Label.FontSize(font_size);
      AppWindow.Add(Lots_Label);

      if(!EquityCall_Label.Create(0,"EQUITYCALL",0,7,315,20,200)) {
         return(INIT_FAILED);
      }
      EquityCall_Label.Text(""+DoubleToString(0,_Digits));
      EquityCall_Label.FontSize(font_size);
      AppWindow.Add(EquityCall_Label);

      if(!Stop_Label.Create(0,"STOPTEXT",0,7,335,20,200)) {
         return(INIT_FAILED);
      }
      Stop_Label.Text(""+DoubleToString(0,_Digits));
      Stop_Label.FontSize(font_size);
      AppWindow.Add(Stop_Label);

      if(!StopWert_Label.Create(0,"STOPWERT",0,160,335,20,200)) {
         return(INIT_FAILED);
      }
      StopWert_Label.Text(""+DoubleToString(0,_Digits));
      StopWert_Label.FontSize(font_size);
      AppWindow.Add(StopWert_Label);


      if(!Ziel_Label.Create(0,"DASZIEL",0,7,355,20,200)) {
         return(INIT_FAILED);
      }
      Ziel_Label.Text(""+DoubleToString(0,_Digits));
      Ziel_Label.FontSize(font_size);
      AppWindow.Add(Ziel_Label);

      if(!HeuteVerdient_Label.Create(0,"HEUTEVERDIENT",0,7,375,20,200)) {
         return(INIT_FAILED);
      }
      HeuteVerdient_Label.Text(""+DoubleToString(0,_Digits));
      HeuteVerdient_Label.FontSize(font_size);
      AppWindow.Add(HeuteVerdient_Label);

   }// Panel ON Ende

   if(!m_symbol.Name(_Symbol)) // sets symbol name
      RefreshRates();
//---
   m_trade.SetExpertMagicNumber(Magic);
//---
   m_trade.SetMarginMode();
   m_trade.SetDeviationInPoints(100);
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
// TradingMon
   if(JAN)
      TradingMon[1] =true;
   if(FEB)
      TradingMon[2] =true;
   if(MAR)
      TradingMon[3] =true;
   if(APR)
      TradingMon[4] =true;
   if(MAI)
      TradingMon[5] =true;
   if(JUN)
      TradingMon[6] =true;
   if(JUL)
      TradingMon[7] =true;
   if(AUG)
      TradingMon[8] =true;
   if(SEP)
      TradingMon[9] =true;
   if(OKT)
      TradingMon[10]=true;
   if(NOV)
      TradingMon[11]=true;
   if(DEZ)
      TradingMon[12]=true;
//--- ok
   if(MON)
      TradingDay[1]=true;
   if(TUE)
      TradingDay[2]=true;
   if(WED)
      TradingDay[3]=true;
   if(THU)
      TradingDay[4]=true;
   if(FRI)
      TradingDay[5]=true;

   return(INIT_SUCCEEDED);

}// Ende OnInit

//+------------------------------------------------------------------+
//| Ereignisfunktion des Charts des Experten                         |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Ereignis ID
                  const long& lparam,   // Ereignisparameter vom Typ long
                  const double& dparam, // Ereignisparameter vom Typ double
                  const string& sparam) { // Ereignisparameter vom Typ string
   AppWindow.ChartEvent(id,lparam,dparam,sparam);
}

// Monats Variablen
bool TradingMon[13] = { false,false,false,false,false,false,false,false,false,false,false,false,false };
// Wochentage Variablen
bool TradingDay[6] = { false,false,false,false,false,false };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   AppWindow.Destroy(reason);

   ObjectDelete(0,"Alarm");
   ObjectDelete(0,"Alarm2");
   ObjectDelete(0,"HighLinie");
   ObjectDelete(0,"HighZone");
   ObjectDelete(0,"LowLinie");
   ObjectDelete(0,"LowZone");
   Comment("");
}// Ende OnDeinit

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {

   double AB            = AccountInfoDouble(ACCOUNT_BALANCE);
   double AE            = AccountInfoDouble(ACCOUNT_EQUITY);
   double Ask           = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid           = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   ulong  Spread        = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   double DayHigh       = iHigh(NULL,PERIOD_D1,0);
   double DayLow        = iLow(NULL,PERIOD_D1,0);
   double DaySpanne     = NormalizeDouble((DayHigh - DayLow)/_Point,_Digits);
   double SpanneProzent = NormalizeDouble(((DayHigh - DayLow) / DayHigh * 100),2);
   double SpanneDiff    = Aenderung + ((Aenderung2 - Aenderung)/2);
   double SpanneResult;
   if(SpanneProzent >= Aenderung && SpanneProzent >= SpanneDiff) {
      SpanneResult   = 4;
   } else {
      SpanneResult   = Spanne;
   }
   double zonen         = DaySpanne/SpanneResult;
   double HighZone      = NormalizeDouble(DayHigh,_Digits) - zonen*_Point;
   double LowZone       = NormalizeDouble(DayLow,_Digits) + zonen*_Point;
   double close         = iClose(NULL,PERIOD_CURRENT,1);
   double open          = iOpen(NULL,PERIOD_CURRENT,1);
   double high          = iHigh(NULL,PERIOD_CURRENT,1);
   double low           = iLow(NULL,PERIOD_CURRENT,1);
   double open0         = iOpen(NULL,PERIOD_CURRENT,0);
   double buykerze      = (high - low)/_Point;
   double sellkerze     = (low - high)/_Point;

   // Trailing
   if(Trailing_Erlauben == true) {
      Trailing();
   }



   if(Panel_ON) {
      Spread_label.Text(DoubleToString(Spread,0)+"");
      BidLabel.Text(DoubleToString(Bid,_Digits)+"");
      AskLabel.Text(DoubleToString(Ask,_Digits)+"");
      TagesspanneWert_Label.Text(""+DoubleToString(SpanneProzent,2)+" %");
      TagesspanneWert_Label.Color(SpanneProzent > Aenderung&&SpanneProzent < Aenderung2?clrGreen:clrRed);
      VerlustWert_Label.Text(""+DoubleToString(Verlust(0),0));
      VerlustWert_Label.Color(clrRed);
      GewinnWert_Label.Text(""+DoubleToString(Gewinn(0),0));
      GewinnWert_Label.Color(clrGreen);
      double tag_plus_in_prozent = (StartKapital*PlusTagProzent)/100;
      double tag_in_minus = (StartKapital*MinusProzent)/100;
      double woche_in_prozent = (StartKapital*MinusWocheProzent)/100;
      double woche_plus_in_prozent = (StartKapital*PlusWocheProzent)/100;
      if(Minustag == true && Profit(0) < -tag_in_minus) {
         MinusTag_Label.Text("Tag im Minus! Pause bis Morgen");
         MinusTag_Label.Color(Profit(0) < 0?clrRed:clrGreen);
      } else if(Plustag == true && Profit(0) > tag_plus_in_prozent) {
         MinusTag_Label.Text("Tag im Plus! Pause bis Morgen");
         MinusTag_Label.Color(Profit(0) > 0?clrGreen:clrRed);
      } else if(Minuswoche == true && ProfitWeek(0) < -woche_in_prozent) {
         MinusTag_Label.Text("Pause bis nächste Woche!");
         MinusTag_Label.Color(ProfitWeek(0) < 0?clrRed:clrGreen);
      } else if(Pluswoche == true && ProfitWeek(0) > woche_plus_in_prozent) {
         MinusTag_Label.Text("Pause bis nächste Woche!");
         MinusTag_Label.Color(ProfitWeek(0) > 0?clrGreen:clrRed);
      } else {
         MinusTag_Label.Text("Gewinn/Verlust:          "+DoubleToString(AProfit(),2));
         MinusTag_Label.Color(AProfit() > 0?clrGreen:clrRed);
      }
      if(Filter_zum_Zeithandel == true) {
         TradingAnfang_Label.Text("Trading beginnt um:   "+Trade_start+" Uhr");
         TradingEnde_Label.Text("Trading endet um:     "+Trade_Ende+" Uhr");
      } else {
         TradingAnfang_Label.Text("Tradingzeit abgeschaltet!");
         TradingAnfang_Label.Color(clrRed);
      }
      if(Reverse == true) {
         Reverse_Label.Text("Reverse an!");
         Reverse_Label.Color(clrGreen);
      } else {
         Reverse_Label.Text("Reverse aus!");
         Reverse_Label.Color(clrRed);
      }

      if(Stop_Kerze == true) {
         StopArt_Label.Text("Stop unter/über Signalkerze!");
      } else if(Stop_Spanne == true) {
         StopArt_Label.Text("Stop nach Tagesspanne!");
      } else {
         StopArt_Label.Text("Stop nach Punkten!");
      }

      Risk_Label.Text("Risiko: "+DoubleToString(Risk,2)+" %");
      string currency = " " +AccountInfoString(ACCOUNT_CURRENCY);
      // Equity Call
      double EquityBerechnen = NormalizeDouble(StartKapital - GewinnAll(),2);
      double KapitalBleibt   = NormalizeDouble((StartKapital*RestMarge)/100,2);
      if(EquityBerechnen <= KapitalBleibt) {
         EquityCall_Label.Text("Equity Call bei: "+DoubleToString(KapitalBleibt,2)+" "+currency);
         EquityCall_Label.Color(clrRed);
      } else {
         EquityCall_Label.Text("Equity Call bei: "+DoubleToString(KapitalBleibt,2)+" "+currency);
      }// Equity Call Ende

      // Stoploss Funktion
      double StopEntscheidung;
      if(Stop_Spanne == true) {
         StopEntscheidung = DaySpanne;
         Stop_Label.Text("SL nach Tagesspanne: ");
         StopWert_Label.Text(" "+DoubleToString(DaySpanne,0)+" pp");
      } else if(Stop_Kerze == true) {
         Stop_Label.Text("SL unter/über Signalkerze! ");
         StopWert_Label.Text(" ");
      } else if(Stop_Punkte == true) {
         // Stop Erhöhung nach Punkten wählen
         if(SpanneProzent > StopGross && SpanneProzent < Aenderung2) {
            StopEntscheidung = Stoploss / 0.75;
         } else {
            StopEntscheidung  = Stoploss;
         }
         // Stop Erhöhung nach Punkten wählen Ende
         Stop_Label.Text("Stop in Punkten: ");
         StopWert_Label.Text(""+DoubleToString(StopEntscheidung,0));
      } else {
         StopEntscheidung = 0;
      }
      // Stoploss Funktion Ende
      // Austoperanzahl am Tag
      if(Anzahl_Verlust_Orders_verwenden == false) {
         if(Panel_ON == true) {
            Austoper_Label.Text("Stopanzahl am Tag aus!!");
            Austoper_Label.Color(clrRed);
         }
      }// Austoperanzahl am Tag

      // Profit Killpreis
      if(AE > StartKapital + (((StartKapital*ProfitMarge)/100))) {
         Ziel_Label.Text("Das Ziel von "+DoubleToString(ProfitMarge,_Digits)+" % erreicht!");
         Ziel_Label.Color(clrGreen);
      } else {
         Ziel_Label.Text("Das Ziel "+DoubleToString(ProfitMarge,2)+" %");
      }
      // Profit Killpreis Ende
      HeuteVerdient_Label.Text("Heute verdient: "+DoubleToString(Profit(0),2)+" "+currency);
      HeuteVerdient_Label.Color(Profit(0) > 0?clrGreen:clrRed);
   }// Panel_ON Ende

// Profit Killpreis
   if(AE > StartKapital + (((StartKapital*ProfitMarge)/100))) {
      for(int i=PositionsTotal()-1; i>=0; i--) // Gibt die Anzahl der aktuellen Positionen zurück
         if(m_position.SelectByIndex(i)) // wählt die Position nach Index für den weiteren Zugriff auf seine Eigenschaften aus
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==Magic) {
               ClosePos2();
            }
      return;
   }

// Kontoschutz plus Equity Trailling
   double EquityBerechnen = NormalizeDouble(StartKapital - GewinnAll(),2);
   double KapitalBleibt   = NormalizeDouble((StartKapital*RestMarge)/100,2);

   if(EquityBerechnen <= KapitalBleibt) {
      for(int i=PositionsTotal()-1; i>=0; i--) // Gibt die Anzahl der aktuellen Positionen zurück
         if(m_position.SelectByIndex(i)) // wählt die Position nach Index für den weiteren Zugriff auf seine Eigenschaften aus
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==Magic) {
               ClosePos2();
            }
      return;
   }


   bool back=true;
   ObjectDelete(0,"HighLinie");
   ObjectCreate(0,"HighLinie",OBJ_HLINE,0,0,DayHigh);
   ObjectSetInteger(0,"HighLinie",OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,"HighLinie",OBJPROP_WIDTH,1);
   ObjectSetInteger(0,"HighLinie",OBJPROP_BACK,back);

   ObjectDelete(0,"HighZone");
   ObjectCreate(0,"HighZone",OBJ_HLINE,0,0,HighZone);
   ObjectSetInteger(0,"HighZone",OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0,"HighZone",OBJPROP_WIDTH,1);
   ObjectSetInteger(0,"HighZone",OBJPROP_BACK,back);

   ObjectDelete(0,"LowLinie");
   ObjectCreate(0,"LowLinie",OBJ_HLINE,0,0,DayLow);
   ObjectSetInteger(0,"LowLinie",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"LowLinie",OBJPROP_WIDTH,1);
   ObjectSetInteger(0,"LowLinie",OBJPROP_BACK,back);

   ObjectDelete(0,"LowZone");
   ObjectCreate(0,"LowZone",OBJ_HLINE,0,0,LowZone);
   ObjectSetInteger(0,"LowZone",OBJPROP_COLOR,clrBrown);
   ObjectSetInteger(0,"LowZone",OBJPROP_WIDTH,1);
   ObjectSetInteger(0,"LowZone",OBJPROP_BACK,back);


//+------------------------------------------------------------------+
//| Tradingtime Function                                             |
//+------------------------------------------------------------------+
   // Schliest offene Position in angegebene Stunde
   ClosePos();

   if(TradingMon[MonOfYear()] == false)
      return;
   if(TradingDay[DayOfWeek()] == false)
      return;
   if(time() == false)
      return;


//+------------------------------------------------------------------+
//| Teilverkauf Funktion                                             |
//+------------------------------------------------------------------+
   if(TverkaufErlauben == true) {
      double ResultTeilV  = (AB*Risk/100)*Tverkaufmal;
      double ResultTeilV2 = -(AB*Risk/100)/2;
      double profit = AProfit();
      if(profit > ResultTeilV) {
         TeilVerkauf();
      } else if(profit < ResultTeilV2/* && Stop_Kerze == false*/) {
         TeilVerkauf();
      } else {

      }
   }

//+-----------------------------------------------------------------+
//  Anzahl negative Orders am Tag!                                  |
//+-----------------------------------------------------------------+
   if(Anzahl_Verlust_Orders_verwenden == true) {
      double pr = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE), 2);
      double pe = Stoploss * pr;
      double eg = Profit_Tage*pe;
      int     x = Verlusst_Tag; // Verlussttag
      int     z = Profit_Tage;  // Profittage
      int     y;
      double op_vorvorgestern = Profit(3);
      double    op_vorgestern = Profit(2);
      double       op_gestern = Profit(1);

      if(op_vorvorgestern > eg*lot && op_vorgestern > (eg+eg)*lot && op_gestern > (eg+eg+eg)*lot) {
         y = z + z + z;
      } else if(op_vorgestern > eg*lot && op_gestern > (eg+eg)*lot) {
         y = z + z;
      } else if(op_gestern > eg*lot) {
         y = z;
      } else {
         y = x;
      }
      if(y>0) {
         if(Fun_New_Bar(_Symbol,PERIOD_D1)==true) {
            qount_verlustorder=0;
         }
         if(AB>balance) {
            balance=AB;
         }
         if(AB<balance) {
            balance=AB;
            qount_verlustorder=qount_verlustorder+1;
         }
         if(qount_verlustorder>=y) {
            return;
         }
      }
      // Anzahl Stopps am Tag
      if(Panel_ON == true) {
         Austoper_Label.Text("Stopanzahl am Tag      "+DoubleToString(y,0)+" (st)");
         Austoper_Label.Color(clrRed);
      }// Anzahl Stopps am Tag Ende

      //Austopper am Tag
      if(Verlust(0)>=y) {
         return;
      }

   }

   // Ausstoper am Tag Ende



// Handel beenden nach Zeit wenn Order in Minus
   if(Close_nach_Zeit == true) {
      datetime zeit=TimeCurrent();
      HistorySelect(0,TimeCurrent());
      for(int pos=HistoryDealsTotal()-1; pos>=0; pos--) {
         if(m_position.SelectByIndex(pos)) {
            // Read deal out and get deal time
            if(m_position.Symbol()==_Symbol && m_position.Magic()==Magic) {
               datetime close_time = m_position.Time();
               datetime adierentime = close_time + (CloseMinuten*60);

               if(zeit>=adierentime && AProfit() < 0) {
                  ClosePos2();
                  return;
               }
            }
         }
      }
   }

   // Handel beenden, wenn die Woche in Plus ist
   if(Pluswoche == true) {
      double woche_plus_in_prozent = (StartKapital*PlusWocheProzent)/100;
      if(ProfitWeek(0) > woche_plus_in_prozent || AProfit() > woche_plus_in_prozent) {
         ClosePos2();
         return;
      }
   }
// Handel beenden, wenn die Woche in Minus ist
   if(Minuswoche == true) {
      double woche_in_prozent = (StartKapital*MinusWocheProzent)/100;
      if(ProfitWeek(0) < -woche_in_prozent || AProfit() < -woche_in_prozent) {
         ClosePos2();
         return;
      }
   }
// Handel beenden, wenn der Tag in Minus ist
   if(Minustag == true) {
      double tag_in_minus = (StartKapital*MinusProzent)/100;
      if(Profit(0) < -tag_in_minus || AProfit() < -tag_in_minus) {
         ClosePos2();
         return;
      }
   }
// Handel beenden, wenn der Tag in plus ist
   double tag_plus_in_prozent = (StartKapital*PlusTagProzent)/100;
   if(Plustag == true) {
      if(AProfit() > tag_plus_in_prozent || Profit(0) > tag_plus_in_prozent) {
         ClosePos2();
         return;
      }
   }

   static ENUM_POSITION_TYPE tipe_letzte_position=-1;
   for(int i=PositionsTotal()-1; i>=0; i--) // Gibt die Anzahl der aktuellen Positionen zurück
      if(m_position.SelectByIndex(i)) // wählt die Position nach Index für den weiteren Zugriff auf seine Eigenschaften aus
         if(m_position.Symbol()== _Symbol && m_position.Magic()==Magic) {
            tipe_letzte_position=m_position.PositionType();  // Ruft den Positionstyp ab
            return;
         }


// Order Buy
   Spread       = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   double spreadresult =  (Spread * _Point) *2;
   if(SpanneProzent > Aenderung && SpanneProzent < Aenderung2
         && buykerze > spreadresult && close > HighZone && open0 >= close && Bid > HighZone) {
      OrderBuy();
   }
// Order Sell
   if(SpanneProzent > Aenderung && SpanneProzent < Aenderung2
         && buykerze > spreadresult && close < LowZone && open0 <= close && Ask < LowZone) {
      OrderSell();
   }

   // Reverse Orders
   if(Reverse == true && Profit(0) > 0 && SpanneProzent > (Aenderung/0.75) && close > LowZone
         && close < HighZone && tipe_letzte_position==POSITION_TYPE_SELL) {
      OrderBuy();
   } else if(Reverse == true && Profit(0) > 0 && SpanneProzent > (Aenderung/0.75)
             && close < HighZone && close > LowZone && tipe_letzte_position==POSITION_TYPE_BUY) {
      OrderSell();
   }



}// Ende OnTick
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates() {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
}
//+------------------------------------------------------------------+
//| Tradingtime Funktion                                             |
//+------------------------------------------------------------------+
int DayOfWeek() {
   TimeCurrent(tm);
   return(tm.day_of_week);
}
//+------------------------------------------------------------------+
//| Monat im Jahr Funktion                                           |
//+------------------------------------------------------------------+
int MonOfYear() {
   TimeCurrent(tm);
   return(tm.mon);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool time() {
   datetime         dt = TimeCurrent();
   datetime time_start = StringToTime(Trade_start);
   datetime  time_stop = StringToTime(Trade_Ende);

   if((dt>time_start) && (dt<time_stop) && (DayOfWeek()>=1) && (DayOfWeek()<=5)) {
      return(true);
   }

   if(Filter_zum_Zeithandel == false) {
      return(true);
   }
   return(false);
}
// Trailingstop
void Trailing() {
   if(Stoploss==0)
      return;

   for(int i=PositionsTotal()-1; i>=0; i--) // Gibt die Anzahl der offenen Positionen zurück
      if(m_position.SelectByIndex(i)) {
         RefreshRates();
         //---
         double price_current = m_position.PriceCurrent();
         double price_open    = m_position.PriceOpen();
         double stop_loss     = m_position.StopLoss();
         double take_profit   = m_position.TakeProfit();

         double DayHigh       = iHigh(NULL,PERIOD_D1,0);
         double DayLow        = iLow(NULL,PERIOD_D1,0);
         double SpanneProzent = NormalizeDouble(((DayHigh - DayLow) / DayHigh * 100),2);
         // Stop nach Tagesspanne wählen
         double SLNEU;
         if(SpanneProzent > StopGross && SpanneProzent < Aenderung2) {
            SLNEU = Stoploss / 0.75;
         } else {
            SLNEU = Stoploss;
         }

         // Stop nach Tagesspanne wählen Ende

         double TralStop = SLNEU * _Point;
         double TralStep = SLNEU * _Point;
         //---
         if(m_position.Symbol()== _Symbol && m_position.Magic()==Magic) { // Prüft nach Symbol und Magicnummer
            if(m_position.PositionType()==POSITION_TYPE_BUY) {
               if(price_current-price_open>TralStop)
                  if(stop_loss<price_current-(TralStop+TralStep))
                     if(!m_trade.PositionModify(m_position.Ticket(),
                                                m_symbol.NormalizePrice(price_current-TralStop),take_profit))
                        RefreshRates();
               continue;
            } else {
               if(price_open-price_current>TralStop)
                  if((stop_loss>(price_current+(TralStop+TralStep))) || (stop_loss==0))
                     if(!m_trade.PositionModify(m_position.Ticket(),
                                                m_symbol.NormalizePrice(price_current+TralStop),take_profit))
                        RefreshRates();

            }
         }
      }
}
//+------------------------------------------------------------------+
//| Money Management                                                 |
//+------------------------------------------------------------------+
double GetLots() {
   double clots = AccountInfoDouble(ACCOUNT_BALANCE)/10000*Lots;
   clots = MathMax(clots, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   clots = MathMin(clots, SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   clots = NormalizeDouble(clots,2);
   return(clots);
}
//+-----------------------------------------------------------------
double LotsByRisk(int op_type,double risk,int sloss) {
   double  lot_min = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double  lot_max = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double  lotcost = ((SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE)*_Point)/(SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)));
   lot = 0.0;
   double UsdPerPip = 0.0;

   lot = AccountInfoDouble(ACCOUNT_BALANCE)*risk/100;
   UsdPerPip = lot/sloss;
   if(UsdPerPip <= 0.0)
      return(0);
   lot = NormalizeDouble(UsdPerPip/lotcost, 2);
   if(lot <= 0.0)
      return(0);
   lot = NormalizeDouble(lot/lot_step, 0) * lot_step;
   if(lot < lot_min)
      lot = lot_min;
   if(lot > lot_max)
      lot = lot_max;
   return(lot);
}

// Order Buy Funktion
void OrderBuy() {
   double DayHigh       = iHigh(NULL,PERIOD_D1,0);
   double DayLow        = iLow(NULL,PERIOD_D1,0);
   double DaySpanne     = NormalizeDouble((DayHigh - DayLow)/_Point,_Digits);
   double SpanneProzent = NormalizeDouble(((DayHigh - DayLow) / DayHigh * 100),2);
   double SpanneDiff    = Aenderung + ((Aenderung2 - Aenderung)/2);
   double SpanneResult;
   if(SpanneProzent >= Aenderung && SpanneProzent >= SpanneDiff) {
      SpanneResult    = 4;
   } else {
      SpanneResult    = Spanne;
   }
   double zonen         = DaySpanne/SpanneResult;
   double HighZone      = NormalizeDouble(DayHigh,_Digits) - zonen*_Point;
   double LowZone       = NormalizeDouble(DayLow,_Digits) + zonen*_Point;
   double high          = iHigh(NULL,PERIOD_CURRENT,1);
   double low           = iLow(NULL,PERIOD_CURRENT,1);
   ulong  Spread        = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);

   int    digits        = (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS); // number of decimal places
   double ask           = SymbolInfoDouble(_Symbol,SYMBOL_ASK);          // current buy price
   double price         = ask;                                           // unnormalized open price
   price         = NormalizeDouble(price,digits);                 // normalizing open price

   double SL            = LowZone;                                       // Stop Loss in points
   SL            = NormalizeDouble(SL,digits);                    // normalizing Stop Loss
   double TK = 0;
   TK            = NormalizeDouble(TK,digits);
   TK            = price + Takeprofit * _Point;

// Stop Erhöhung nach Punkten wählen
   double SLNEU;
   if(SpanneProzent > StopGross && SpanneProzent < Aenderung2) {
      SLNEU = Stoploss/0.75;
   } else {
      SLNEU = Stoploss;
   }

// Stop Erhöhung nach Punkten wählen Ende

// Stoploss Funktion
   double StopEntscheidung;
   if(Stop_Spanne == true) {
      StopEntscheidung =  ask - DaySpanne*_Point;
      double Stop       =  DaySpanne;
      string Lotgroesse = DoubleToString(LotsByRisk(ORDER_TYPE_BUY,Risk,(int)Stop),2);
      Lots_Label.Text("Lots: "+DoubleToString(lot,2));
   } else if(Stop_Kerze == true) {
      StopEntscheidung  = low - Spread * _Point;
      double buykerze   = Spread + (high - low)/_Point;
      string Lotgroesse = DoubleToString(LotsByRisk(ORDER_TYPE_BUY,Risk,(int)buykerze),2);
      Lots_Label.Text("Lots: "+DoubleToString(lot,2));
   } else if(Stop_Punkte == true) {
      StopEntscheidung = ask - SLNEU * _Point;
      double stoppunkte = SLNEU;
      string Lotgroesse = DoubleToString(LotsByRisk(ORDER_TYPE_BUY,Risk,(int)stoppunkte),2);
      Lots_Label.Text("Lots: "+DoubleToString(lot,2));
   } else {
      StopEntscheidung = 0;
   } // Stoploss Funktion Ende

   m_trade.Buy(NormalizeDouble(lot,_Digits),NULL,price,StopEntscheidung,TK,NULL);
   RefreshRates();
}
// Order Sell Funktion
void OrderSell() {
   double DayHigh       = iHigh(NULL,PERIOD_D1,0);
   double DayLow        = iLow(NULL,PERIOD_D1,0);
   double DaySpanne     = NormalizeDouble((DayHigh - DayLow)/_Point,_Digits);
   double SpanneProzent = NormalizeDouble(((DayHigh - DayLow) / DayHigh * 100),2);
   double SpanneDiff    = Aenderung + ((Aenderung2 - Aenderung)/2);
   double SpanneResult;
   if(SpanneProzent >= Aenderung && SpanneProzent >= SpanneDiff) {
      SpanneResult   = 4;
   } else {
      SpanneResult   = Spanne;
   }
   double zonen         = DaySpanne/SpanneResult;
   double HighZone      = NormalizeDouble(DayHigh,_Digits) - zonen*_Point;
   double LowZone       = NormalizeDouble(DayLow,_Digits) + zonen*_Point;
   double high          = iHigh(NULL,PERIOD_CURRENT,1);
   double low           = iLow(NULL,PERIOD_CURRENT,1);

   int    digits        = (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);  // number of decimal places
   double bid           = SymbolInfoDouble(_Symbol,SYMBOL_BID);           // current buy price
   double price         = bid;                                            // unnormalized open price
   price         = NormalizeDouble(price,digits);                  // normalizing open price
   high          = iHigh(NULL,PERIOD_CURRENT,1);
   ulong  Spread        = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);

   double SL            = HighZone;                                       // Stop Loss in points
   SL            = NormalizeDouble(SL,digits);                     // normalizing Stop Loss

   double TK            = 0;
   TK            = NormalizeDouble(TK,digits);
   TK            = price - Takeprofit * _Point;

// Stop Erhöhung nach Punkten wählen
   double SLNEU;
   if(SpanneProzent > StopGross && SpanneProzent < Aenderung2) {
      SLNEU = Stoploss/0.75;
   } else {
      SLNEU = Stoploss;
   }

// Stop Erhöhung nach Punkten wählen Ende

// Stoploss Funktion
   double StopEntscheidung;
   if(Stop_Spanne == true) {
      StopEntscheidung  =  bid + DaySpanne*_Point;
      double Stop       =  DaySpanne;
      string Lotgroesse = DoubleToString(LotsByRisk(ORDER_TYPE_BUY,Risk,(int)Stop),2);
      Lots_Label.Text("Lots: "+DoubleToString(lot,2));
   } else if(Stop_Kerze == true) {
      StopEntscheidung = high + Spread * _Point;
      double sellkerze = Spread + (high - low)/_Point;
      string Lotgroesse = DoubleToString(LotsByRisk(ORDER_TYPE_BUY,Risk,(int)sellkerze),2);
      Lots_Label.Text("Lots: "+DoubleToString(lot,2));
   } else if(Stop_Punkte == true) {
      StopEntscheidung = bid + SLNEU * _Point;
      double stoppunkte = SLNEU;
      string Lotgroesse = DoubleToString(LotsByRisk(ORDER_TYPE_BUY,Risk,(int)stoppunkte),2);
      Lots_Label.Text("Lots: "+DoubleToString(lot,2));
   } else {
      StopEntscheidung = 0;
   }

   m_trade.Sell(NormalizeDouble(lot,_Digits),NULL,price,StopEntscheidung,TK,NULL);
   RefreshRates();
}
// Position nach Zeit schliessen
void ClosePos() {
   datetime zeit      = TimeCurrent();
   datetime time_ende = StringToTime((string)TimeClose);

   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) {
         RefreshRates();
         //---
         if(m_position.Symbol()== _Symbol && m_position.Magic()==Magic) { // Prüft nach Symbol und Magicnummer
            if(zeit >= time_ende) {
               m_trade.PositionClose(m_position.Ticket());
            }
         }
      }
}
//Teilverkauf Funktion
void TeilVerkauf() {
   for(int i=PositionsTotal()-1; i>=0; i--) // Gibt die Anzahl der offenen Positionen zurück
      if(m_position.SelectByIndex(i)) {
         RefreshRates();
         //---
         if(m_position.Symbol()== _Symbol && m_position.Magic()==Magic) { // Prüft nach Symbol und Magicnummer
            if(m_position.PositionType()==POSITION_TYPE_BUY) {
               double  lot_min  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
               double  Pvolumen = m_position.Volume();
               double  volumen  = lot_min * Tverkaufmal2;

               if(Pvolumen > volumen) {
                  Vol = volumen;
               } else {
                  Vol = lot_min;
               }

               if(!m_trade.PositionClosePartial(m_position.Ticket(),Vol))
                  RefreshRates();
               continue;
            } else {
               double  lot_min  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
               double  Pvolumen = m_position.Volume();
               double  volumen  = lot_min * Tverkaufmal2;

               if(Pvolumen > volumen) {
                  Vol = volumen;
               } else {
                  Vol = lot_min;
               }

               if(!m_trade.PositionClosePartial(m_position.Ticket(),Vol))
                  RefreshRates();

            }
         }
      }
}
//------------- Verlust Orders Funktion ---------------------------
double Verlust(int ai_0) {
   RefreshRates();

// HistorySelect(von_datum,zum_datum);
   HistorySelect(iTime(_Symbol,PERIOD_D1,ai_0),iTime(_Symbol,PERIOD_D1,ai_0)+60*60*24);
   double verlorene_trade=0.0;
   uint total=HistoryDealsTotal();
   ulong    ticket=0;

//--- for all deals
   for(uint i=0; i<total; i++) {
      //--- Sucht nach Tickets die grösser als Null sind
      if((ticket=HistoryDealGetTicket(i))>0) {
         long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(entry==DEAL_ENTRY_IN)
            continue;

         string          symbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
         long       order_magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double       deal_swap = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double     deal_profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double          profit = deal_commission+deal_swap+deal_profit;
         if(order_magic ==Magic) {
            //... processing of deal with some DEAL_MAGIC
            if(symbol==_Symbol) {
               if(profit<0.0)
                  verlorene_trade++;
            }
         }
      }
   }
   return(verlorene_trade);
}
//------------- Gewinn Orders Funktion ---------------------------
double Gewinn(int ai_0) {
   RefreshRates();

// HistorySelect(von_datum,zum_datum);
   HistorySelect(iTime(_Symbol,PERIOD_D1,ai_0),iTime(_Symbol,PERIOD_D1,ai_0)+60*60*24);
   double gewonnene_trade=0.0;
   uint total=HistoryDealsTotal();
   ulong    ticket=0;

//--- for all deals
   for(uint i=0; i<total; i++) {
      //--- Sucht nach Tickets die grösser als Null sind
      if((ticket=HistoryDealGetTicket(i))>0) {
         long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(entry==DEAL_ENTRY_IN)
            continue;

         string          symbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
         long       order_magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double       deal_swap = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double     deal_profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double          profit = deal_commission+deal_swap+deal_profit;
         if(order_magic ==Magic) {
            //... processing of deal with some DEAL_MAGIC
            if(symbol==_Symbol) {
               if(profit>0.0)
                  gewonnene_trade++;
            }
         }
      }
   }
   return(gewonnene_trade);
}
//------------- Profit ausrechnen Funktion ---------------------------
double Profit(int ai_0) {
   RefreshRates();

// HistorySelect(von_datum,zum_datum);
   HistorySelect(iTime(_Symbol,PERIOD_D1,ai_0),iTime(_Symbol,PERIOD_D1,ai_0)+60*60*24);
   double gewonnene_trade = 0.0;
   double verlorene_trade = 0.0;
   double total_profit    = 0.0;
   uint   total           = HistoryDealsTotal();
   ulong  ticket          = 0;

//--- for all deals
   for(uint i=0; i<total; i++) {
      //--- Sucht nach Tickets die grösser als Null sind
      if((ticket=HistoryDealGetTicket(i))>0) {
         long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(entry==DEAL_ENTRY_IN)
            continue;

         string symbol          = HistoryDealGetString(ticket,DEAL_SYMBOL);
         long   order_magic     = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double deal_swap       = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double deal_profit     = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double profit=deal_commission+deal_swap+deal_profit;
         if(order_magic==Magic) {
            //... processing of deal with some DEAL_MAGIC
            if(symbol ==_Symbol) {
               if(profit>0.0)
                  gewonnene_trade+=profit;
               if(profit<0.0)
                  verlorene_trade+=profit;
               total_profit+=profit;
            }
         }
      }
   }
   return(total_profit);
}
//------------- Woche Profit ausrechnen Funktion ---------------------------
double ProfitWeek(int ai_0) {
   RefreshRates();

// HistorySelect(von_datum,zum_datum);
   HistorySelect(iTime(_Symbol,PERIOD_W1,ai_0),iTime(_Symbol,PERIOD_W1,ai_0)+60*60*24*7);
   double gewonnene_trade = 0.0;
   double verlorene_trade = 0.0;
   double total_profit    = 0.0;
   uint   total           = HistoryDealsTotal();
   ulong  ticket          = 0;

//--- for all deals
   for(uint i=0; i<total; i++) {
      //--- Sucht nach Tickets die grösser als Null sind
      if((ticket=HistoryDealGetTicket(i))>0) {
         long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(entry==DEAL_ENTRY_IN)
            continue;

         string symbol          = HistoryDealGetString(ticket,DEAL_SYMBOL);
         long   order_magic     = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double deal_swap       = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double deal_profit     = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double profit=deal_commission+deal_swap+deal_profit;
         if(order_magic==Magic) {
            //... processing of deal with some DEAL_MAGIC
            if(symbol ==_Symbol) {
               if(profit>0.0)
                  gewonnene_trade+=profit;
               if(profit<0.0)
                  verlorene_trade+=profit;
               total_profit+=profit;
            }
         }
      }
   }
   return(total_profit);
}
//+------------------------------------------------------------------+
//|                                                                  |
double AProfit() {
   RefreshRates();
   double pft=0;
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket=PositionGetTicket(i);
      if(ticket>0) {
         if(PositionGetInteger(POSITION_MAGIC)==Magic && PositionGetString(POSITION_SYMBOL)==_Symbol) {
            pft+=PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   return(pft);
}
//------------- Hystory All Gewinn Orders Funktion ---------------------------
double GewinnAll() {
   RefreshRates();

// HistorySelect(von_datum,zum_datum);
   HistorySelect(Datum_Start,TimeCurrent());
   double gewonnene_trade=0.0;
   double verlorene_trade=0.0;
   double total_profit=0.0;
   uint total=HistoryDealsTotal();
   ulong    ticket=0;

//--- for all deals
   for(uint i=0; i<total; i++) {
      //--- Sucht nach Tickets die grösser als Null sind
      if((ticket=HistoryDealGetTicket(i))>0) {
         long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(entry==DEAL_ENTRY_IN)
            continue;

         string          symbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
         long       order_magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double       deal_swap = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double     deal_profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double          profit = deal_commission+deal_swap+deal_profit;
         // if(order_magic ==Magic )
         //  {
         //... processing of deal with some DEAL_MAGIC
         if(symbol==_Symbol && order_magic == Magic) {
            if(profit>0.0)
               gewonnene_trade+=profit;
            if(profit<0.0)
               verlorene_trade+=profit;
            total_profit+=profit;
         }
         //  }
      }
   }
   return(total_profit);
}
//+------------------------------------------------------------------+
//| Funktion Timeframe und Chartperiod                               |
//+------------------------------------------------------------------+
bool Fun_New_Bar(string symbol,ENUM_TIMEFRAMES timeframe) {
   static datetime Prev_Time=0;
   if(Prev_Time == 0) {
      Prev_Time = iTime(symbol,timeframe,0);
      return(false);
   }
   if(Prev_Time!=iTime(symbol,timeframe,0)) {
      Prev_Time = iTime(symbol,timeframe,0);
      return(true);
   }
   return(false);
}
//+------------------------------------------------------------------+
void ClosePos2() {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         m_trade.PositionClose(m_position.Ticket());


   if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==Magic) { // Prüft nach Symbol und Magicnummer
      m_trade.PositionClose(m_position.Ticket());
      RefreshRates();
   }
}

//+------------------------------------------------------------------+
