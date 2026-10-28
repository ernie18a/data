//+————————————————————————————————————————————————————————————————————————————+
//|                                                                 C_AO_Boids |
//|                                            Copyright 2007-2024, Andrey Dik |
//|                                          https://www.mql5.com/ru/users/joo |
//—————————————————————————————————————————————————————————————————————————————+

//Article: https://www.mql5.com/ru/articles/14576

#include "#C_AO.mqh"

//——————————————————————————————————————————————————————————————————————————————
struct S_Boids_Agent
{
    double x  [];
    double dx [];
    double m;

    void Init (int coords)
    {
      ArrayResize (x,  coords);
      ArrayResize (dx, coords);
    }
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
class C_AO_Boids : public C_AO
{
  public: //--------------------------------------------------------------------
  ~C_AO_Boids () { }
  C_AO_Boids ()
  {
    ao_name = "Boids";
    ao_desc = "Boids Algorithm";
    ao_link = "https://www.mql5.com/ru/articles/14576";

    popSize          = 50;   //population size

    cohesionWeight   = 0.6;
    cohesionDist     = 0.001;

    separationWeight = 0.005;
    separationDist   = 0.03;

    alignmentWeight  = 0.1;
    alignmentDist    = 0.1;

    maxSpeed         = 0.001;
    minSpeed         = 0.0001;

    ArrayResize (params, 9);

    params [0].name = "popSize";          params [0].val = popSize;

    params [1].name = "cohesionWeight";   params [1].val = cohesionWeight;
    params [2].name = "cohesionDist";     params [2].val = cohesionDist;


    params [3].name = "separationWeight"; params [3].val = separationWeight;
    params [4].name = "separationDist";   params [4].val = separationDist;

    params [5].name = "alignmentWeight";  params [5].val = alignmentWeight;
    params [6].name = "alignmentDist";    params [6].val = alignmentDist;

    params [7].name = "maxSpeed";         params [7].val = maxSpeed;
    params [8].name = "minSpeed";         params [8].val = minSpeed;
  }

  void SetParams ()
  {
    popSize          = (int)params [0].val;

    cohesionWeight   = params [1].val;
    cohesionDist     = params [2].val;

    separationWeight = params [3].val;
    separationDist   = params [4].val;

    alignmentWeight  = params [5].val;
    alignmentDist    = params [6].val;

    maxSpeed         = params [7].val;
    minSpeed         = params [8].val;
  }

  bool Init (const double &rangeMinP  [], //minimum search range
             const double &rangeMaxP  [], //maximum search range
             const double &rangeStepP [], //step search
             const int     epochsP = 0);  //number of epochs

  void Moving   ();
  void Revision ();
  void Injection (const int popPos, const int coordPos, const double value);

  //----------------------------------------------------------------------------
  double cohesionWeight;   //cohesion weight
  double cohesionDist;     //cohesion distance

  double separationWeight; //separation weight
  double separationDist;   //separation distance

  double alignmentWeight;  //alignment weight
  double alignmentDist;    //alignment distance

  double minSpeed;         //minimum velocity
  double maxSpeed;         //maximum velocity

  S_Boids_Agent agent [];

  private: //-------------------------------------------------------------------
  double distanceMax;
  double speedMax [];

  void   CalculateMass    ();
  void   Cohesion         (S_Boids_Agent &boid, int pos);
  void   Separation       (S_Boids_Agent &boid, int pos);
  void   Alignment        (S_Boids_Agent &boid, int pos);
  void   LimitSpeed       (S_Boids_Agent &boid);
  void   KeepWithinBounds (S_Boids_Agent &boid);
  double Distance         (S_Boids_Agent &boid1, S_Boids_Agent &boid2);
};
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
bool C_AO_Boids::Init (const double &rangeMinP  [], //minimum search range
                       const double &rangeMaxP  [], //maximum search range
                       const double &rangeStepP [], //step search
                       const int     epochsP = 0)   //number of epochs
{
  if (!StandardInit (rangeMinP, rangeMaxP, rangeStepP)) return false;

  //----------------------------------------------------------------------------
  ArrayResize (agent, popSize);
  for (int i = 0; i < popSize; i++) agent [i].Init (coords);

  distanceMax = 0;
  ArrayResize (speedMax, coords);

  for (int c = 0; c < coords; c++)
  {
    speedMax [c] = rangeMax [c] - rangeMin [c];
    distanceMax += pow (speedMax [c], 2);
  }

  distanceMax = sqrt (distanceMax);

  GlobalVariableSet ("#reset", 1.0);

  GlobalVariableSet ("1cohesionWeight",   params [1].val);
  GlobalVariableSet ("2cohesionDist",     params [2].val);

  GlobalVariableSet ("3separationWeight", params [3].val);
  GlobalVariableSet ("4separationDist",   params [4].val);

  GlobalVariableSet ("5alignmentWeight",  params [5].val);
  GlobalVariableSet ("6alignmentDist",    params [6].val);

  GlobalVariableSet ("7maxSpeed",         params [7].val);
  GlobalVariableSet ("8minSpeed",         params [8].val);


  return true;
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_Boids::Moving ()
{
  double reset = GlobalVariableGet ("#reset");
  if (reset == 1.0)
  {
    revision = false;
    GlobalVariableSet ("#reset", 0.0);
  }

  cohesionWeight   = GlobalVariableGet ("1cohesionWeight");
  cohesionDist     = GlobalVariableGet ("2cohesionDist");

  separationWeight = GlobalVariableGet ("3separationWeight");
  separationDist   = GlobalVariableGet ("4separationDist");

  alignmentWeight  = GlobalVariableGet ("5alignmentWeight");
  alignmentDist    = GlobalVariableGet ("6alignmentDist");

  maxSpeed         = GlobalVariableGet ("7maxSpeed");
  minSpeed         = GlobalVariableGet ("8minSpeed");

  if (!revision)
  {
    for (int i = 0; i < popSize; i++)
    {
      for (int c = 0; c < coords; c++)
      {
        agent [i].x [c] = u.RNDfromCI (rangeMin [c], rangeMax [c]);
        agent [i].dx [c] = (rangeMax [c] - rangeMin [c]) * u.RNDfromCI (-1.0, 1.0) * 0.001;

        a [i].c [c] = u.SeInDiSp  (agent [i].x [c], rangeMin [c], rangeMax [c], rangeStep [c]);
      }
    }

    revision = true;
    return;
  }

  //----------------------------------------------------------------------------
  for (int i = 0; i < popSize; i++)
  {
    CalculateMass    ();
    Cohesion         (agent [i], i);
    Separation       (agent [i], i);
    Alignment        (agent [i], i);
    LimitSpeed       (agent [i]);
    KeepWithinBounds (agent [i]);

    for (int c = 0; c < coords; c++)
    {
      agent [i].x [c] += agent [i].dx [c];
      a [i].c [c] = u.SeInDiSp  (agent [i].x [c], rangeMin [c], rangeMax [c], rangeStep [c]);
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_Boids::CalculateMass ()
{
  double maxMass = -DBL_MAX;
  double minMass =  DBL_MAX;

  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > maxMass) maxMass = a [i].f;
    if (a [i].f < minMass) minMass = a [i].f;
  }

  for (int i = 0; i < popSize; i++)
  {
    agent [i].m = u.Scale (a [i].f, minMass, maxMass, 0.0, 1.0);
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Find the center of mass of the other boids and adjust velocity slightly to
// point towards the center of mass.
void C_AO_Boids::Cohesion (S_Boids_Agent &boid, int pos)
{
  double centerX [];
  ArrayResize     (centerX, coords);
  ArrayInitialize (centerX, 0.0);

  int    numNeighbors = 0;
  double sumMass      = 0;

  for (int i = 0; i < popSize; i++)
  {
    if (pos != i) sumMass += agent [i].m;
  }

  for (int i = 0; i < popSize; i++)
  {
    if (pos != i)
    {
      if (Distance (boid, agent [i]) < distanceMax * cohesionDist)
      {
        for (int c = 0; c < coords; c++)
        {
          centerX [c] += agent [i].x [c] * agent [i].m;
        }

        numNeighbors++;
      }
    }
  }

  if (numNeighbors > 0)
  {
    for (int c = 0; c < coords; c++)
    {
      //centerX [c] /= numNeighbors;
      centerX [c] /= sumMass;
      boid.dx [c] += (centerX [c] - boid.x [c]) * cohesionWeight;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Move away from other boids that are too close to avoid colliding
void C_AO_Boids::Separation (S_Boids_Agent &boid, int pos)
{
  double moveX [];
  ArrayResize     (moveX, coords);
  ArrayInitialize (moveX, 0.0);

  for (int i = 0; i < popSize; i++)
  {
    if (pos != i)
    {
      if (Distance (boid, agent [i]) < distanceMax * separationDist)
      {
        for (int c = 0; c < coords; c++)
        {
          moveX [c] += boid.x [c] - agent [i].x [c];
        }
      }
    }
  }

  for (int c = 0; c < coords; c++)
  {
    boid.dx [c] += moveX [c] * separationWeight;
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Find the average velocity (speed and direction) of the other boids and
// adjust velocity slightly to match.
void C_AO_Boids::Alignment (S_Boids_Agent &boid, int pos)
{
  double avgDX [];
  ArrayResize     (avgDX, coords);
  ArrayInitialize (avgDX, 0.0);

  int numNeighbors = 0;

  for (int i = 0; i < popSize; i++)
  {
    if (pos != i)
    {
      if (Distance (boid, agent [i]) < distanceMax * alignmentDist)
      {
        for (int c = 0; c < coords; c++)
        {
          avgDX [c] += agent [i].dx [c];
        }

        numNeighbors++;
      }
    }
  }

  if (numNeighbors > 0)
  {
    for (int c = 0; c < coords; c++)
    {
      avgDX   [c] /= numNeighbors;
      boid.dx [c] += (avgDX [c] - boid.dx [c]) * alignmentWeight;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Speed will naturally vary in flocking behavior, but real animals can't go
// arbitrarily fast.
void C_AO_Boids::LimitSpeed (S_Boids_Agent &boid)
{
  double speed = 0;

  for (int c = 0; c < coords; c++)
  {
    speed += boid.dx [c] * boid.dx [c];
  }

  speed = sqrt (speed);

  double d = 0;

  for (int c = 0; c < coords; c++)
  {
    d = (rangeMax [c] - rangeMin [c]) * minSpeed;

    boid.dx [c] = (boid.dx [c] / speed) * speedMax [c] * maxSpeed;

    if (fabs (boid.dx [c]) < d)
    {
      if (boid.dx [c] < 0.0) boid.dx [c] = -d;
      else                   boid.dx [c] =  d;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
// Constrain a boid to within the window. If it gets too close to an edge,
// nudge it back in and reverse its direction.
void C_AO_Boids::KeepWithinBounds (S_Boids_Agent &boid)
{
  for (int c = 0; c < coords; c++)
  {
    double margin     = 0; //(rangeMax [c] - rangeMin [c])* 0.00001;
    double turnFactor = (rangeMax [c] - rangeMin [c]) * 0.0001;

    /*
    if (boid.x [c] < rangeMin [c] + margin)
    {
      boid.dx [c] += turnFactor;
    }
    if (boid.x [c] > rangeMax [c] - margin)
    {
      boid.dx [c] -= turnFactor;
    }
    */
    if (boid.x [c] < rangeMin [c])
    {
      //boid.x [c] = rangeMax [c];
      boid.dx [c] *= -1;

    }
    if (boid.x [c] > rangeMax [c])
    {
      //boid.x [c] = rangeMin [c];
      boid.dx [c] *= -1;
    }
  }
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
double C_AO_Boids::Distance (S_Boids_Agent &boid1, S_Boids_Agent &boid2)
{
  double dist = 0;

  for (int c = 0; c < coords; c++)
  {
    dist += pow (boid1.x [c] - boid2.x [c], 2);
  }

  return sqrt (dist);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_Boids::Revision ()
{
  int ind = -1;

  for (int i = 0; i < popSize; i++)
  {
    if (a [i].f > fB)
    {
      fB = a [i].f;
      ind = i;
    }
  }

  if (ind != -1) ArrayCopy (cB, a [ind].c, 0, 0, WHOLE_ARRAY);
}
//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
void C_AO_Boids::Injection (const int popPos, const int coordPos, const double value)
{
  if (popPos   < 0 || popPos   >= popSize) return;
  if (coordPos < 0 || coordPos >= coords) return;

  if (value < rangeMin [coordPos])
  {
    a [popPos].c [coordPos] = rangeMin [coordPos];
  }

  if (value > rangeMax [coordPos])
  {
    a [popPos].c [coordPos] = rangeMax [coordPos];
  }

  a [popPos].c [coordPos] = u.SeInDiSp (value, rangeMin [coordPos], rangeMax [coordPos], rangeStep [coordPos]);
}
//——————————————————————————————————————————————————————————————————————————————
