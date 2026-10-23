//+------------------------------------------------------------------+
//|                                                     SWISSEPH.mqh |
//|                                                        J.S. 2012 |
//|                                     http://www.eselstreckdich.de |
//+------------------------------------------------------------------+
#property copyright "J.S. 2012"
#property link      "http://www.eselstreckdich.de"

//  Dokumentation und DLL swedll32.dll (in das Verzeichnis Libraries kopieren)
//
//  ftp://ftp.astro.com/pub/swisseph/

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

enum BODY { Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto,
            Mean_Node, True_Node, Mean_Apog, Oscu_Apog, Earth,
            Chiron, Pholus, Ceres, Pallas, Juno, Vesta };

/* values for gregflag in swe_julday() and swe_revjul() */
#define SE_JUL_CAL	0
#define SE_GREG_CAL	1

/* planet numbers for the ipl parameter in swe_calc() */
#define SE_ECL_NUT          -1      
#define SE_SUN               0       
#define SE_MOON              1       
#define SE_MERCURY           2       
#define SE_VENUS             3       
#define SE_MARS              4       
#define SE_JUPITER           5       
#define SE_SATURN            6       
#define SE_URANUS            7       
#define SE_NEPTUNE           8       
#define SE_PLUTO             9       
#define SE_MEAN_NODE         10   // Mondknoten geglдttet   
#define SE_TRUE_NODE         11   // Mondknoten real
#define SE_MEAN_APOG         12   // Gegenseite SE_MEAN_NODE   
#define SE_OSCU_APOG         13    
#define SE_EARTH             14 
#define SE_CHIRON            15 
#define SE_PHOLUS            16 
#define SE_CERES             17 
#define SE_PALLAS            18 
#define SE_JUNO              19
#define SE_VESTA             20
#define SE_INTP_APOG         21
#define SE_INTP_PERG         22
#define SE_NPLANETS          23
#define SE_FICT_OFFSET       40
#define SE_NFICT_ELEM        15

/* Hamburger or Uranian "planets" */
#define SE_CUPIDO            40
#define SE_HADES             41
#define SE_ZEUS              42
#define SE_KRONOS            43
#define SE_APOLLON           44
#define SE_ADMETOS           45
#define SE_VULKANUS          46
#define SE_POSEIDON          47

/* other fictitious bodies */
#define SE_ISIS              48
#define SE_NIBIRU            49
#define SE_HARRINGTON        50
#define SE_NEPTUNE_LEVERRIER 51
#define SE_NEPTUNE_ADAMS     52
#define SE_PLUTO_LOWELL      53
#define SE_PLUTO_PICKERING   54
#define SE_AST_OFFSET     10000

/* Flags */
#define SEFLG_JPLEPH          1     // use JPL ephemeris 
#define SEFLG_SWIEPH          2     // use SWISSEPH ephemeris, default
#define SEFLG_MOSEPH          4     // use Moshier ephemeris 
#define SEFLG_HELCTR          8     // return heliocentric position 
#define SEFLG_TRUEPOS        16     // return true positions, not apparent 
#define SEFLG_J2000          32     // no precession, i.e. give J2000 equinox 
#define SEFLG_NONUT          64     // no nutation, i.e. mean equinox of date 
#define SEFLG_SPEED3        128     // speed from 3 positions (do not use it, SEFLG_SPEED is faster and preciser.) 
#define SEFLG_SPEED         256     // high precision speed (analyt. comp.)
#define SEFLG_NOGDEFL       512     // turn off gravitational deflection 
#define SEFLG_NOABERR      1024     // turn off 'annual' aberration of light 
#define SEFLG_EQUATORIAL   2048     // equatorial positions are wanted 
#define SEFLG_XYZ          4096     // cartesian, not polar, coordinates 
#define SEFLG_RADIANS      8192     // coordinates in radians, not degrees 
#define SEFLG_BARYCTR     16384     // barycentric positions 
#define SEFLG_TOPOCTR   (32*1024)   // topocentric positions 
#define SEFLG_SIDEREAL  (64*1024)   // sidereal positions 
#define SEFLG_ICRS     (128*1024)   // ICRS (DE406 reference frame) 


//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
#import "swedll32.dll"

void swe_version(char &svers[]);
double swe_julday(int year, int month, int day, double hour, int gregflag); 
int swe_calc( double tjd_et, int ipl, int iflag, double &xx[], char &serr[]);
int swe_calc_ut( double tjd_ut, int ipl, int iflag, double &xx[], char &serr[]);
void swe_set_topo(double geolon, double geolat, double altitude);
void swe_get_planet_name(int ipl, char &spname[]); 
void swe_utc_time_zone(int iyear, int imonth, int iday, int ihour, int imin, double dsec,
                       double d_timezone,
                       int &iyear_out, int &imonth_out, int &iday_out, int &ihour_out, int &imin_out, double &dsec_out);
int swe_utc_to_jd(int iyear, int imonth, int iday, int ihour, int imin, double dsec,
                  int gregflag, double &dret[], char &serr[]);
void swe_close();

#import

//+------------------------------------------------------------------+
//| Position eines Kцrpers berechnen                                 |
//+------------------------------------------------------------------+
bool calculate(datetime dt, int ipl, double &data[], int iflag=0) {

   static char err[256];
   int rv;
   double julday;
   MqlDateTime ds;
   
   TimeToStruct(dt, ds);
   julday=swe_julday(ds.year, ds.mon, ds.day,
                     ds.hour+(ds.min*60+ds.sec)/3600.0, SE_GREG_CAL);

   iflag |= SEFLG_MOSEPH | SEFLG_SPEED;
   rv=swe_calc_ut( julday, ipl, iflag, data, err);
   if(rv<0) {
      Print("SWISSEPH.calulate Error \""+CharArrayToString(err)+"\"");
      return(false);
   }
   //Print("rv ",rv," iflag ",iflag);
   return(rv==iflag);
}

//+------------------------------------------------------------------+
//| Position eines Kцrpers berechnen                                 |
//+------------------------------------------------------------------+
bool calculate(int year, int month, int day, int hour, int minute, double timezone,
               int ipl, double &data[], int iflag=0) {
               
   static char err[256];
   int y, mon, d, h, min, rv;
   double sec, dret[2];
              
   swe_utc_time_zone(year, month, day, hour, minute, 0, timezone,
                     y, mon, d, h, min, sec);

   swe_utc_to_jd(y, mon, d, h, min, sec, SE_GREG_CAL, dret, err);
                   
   iflag |= SEFLG_MOSEPH | SEFLG_SPEED;
   rv=swe_calc_ut( dret[0], ipl, iflag, data, err);
   if(rv<0) {
      Print("SWISSEPH.calulate Error \""+CharArrayToString(err)+"\"");
      return(false);
   }
   //Print("rv ",rv," iflag ",iflag);
   return(rv==iflag);
}
