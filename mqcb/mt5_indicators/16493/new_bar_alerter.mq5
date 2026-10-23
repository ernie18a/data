//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input bool alertsOn      = false; // Turn alerts on?
input bool alertsMessage = true;  // Display messageas on alerts?
input bool alertsSound   = false; // Play sound on alerts?
input bool alertsEmail   = false; // Send email on alerts?
input bool alertsShow    = false; // Display alerter comment text?


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit() { return(0); }
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
{
   static datetime prevTime=0;
      if (prevTime!=time[rates_total-1])
      if (prevTime!=0)
            doAlert(time[rates_total-1],"new bar formed");
      prevTime=time[rates_total-1];
   if (alertsShow) Comment("New bar alerter last checked status at : "+TimeToString(TimeLocal(),TIME_SECONDS));
   return(rates_total);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      message = TimeToString(TimeLocal(),TIME_SECONDS)+" "+_Symbol+" new bar alerter : "+doWhat;
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(_Symbol+" new bar alerter",message);
         if (alertsSound)   PlaySound("alert2.wav");
   }
}