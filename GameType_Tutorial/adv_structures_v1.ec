mission "Adv. Structures"
{
  // ** Konstanten **
  consts
  {
    // Spielerrassen
    raceUCS   = 1;
    raceED    = 2;
    raceLC    = 3;
    raceAlien = 4;
    
    // Ressourcentypen
    resCrystal = 0;
    resMetal   = 1;
    resWater   = 2;
  }
  
  
  // ** Funktionen **
  
  function void InitUCSPlayer(player p, int x, int y)
  {
    // Gib dem Spieler 5000 Metall.
    p.AddResource(resMetal, 5000);
    
    // Nun f�ge die Starteinheiten am Startpunkt hinzu.
    // Drohne.
   	p.CreateObject("U_CH_AR_08_1", x+1, y, 0, 0);
    //Infanterie
    p.CreateObject("U_IN_TE_01_1", x, y, 0, 0);
    p.CreateObject("U_IN_TE_01_1", x, y+1, 0, 0);
    p.CreateObject("U_IN_TE_01_1", x, y-1, 0, 0);
    // Reloader
   	p.CreateObject("U_CH_AS_09_1", x-1, y, 0, 0);    
    //Termiten
    p.CreateObject("U_CH_AH_10_1", x+1, y-1, 0, 0);
    p.CreateObject("U_CH_AH_10_1", x-1, y-1, 0, 0);
    p.CreateObject("U_CH_AH_10_1", x-2, y-1, 0, 0);    
  }
  
  function void InitEDPlayer(player p, int x, int y)
  {
    // Gib dem Spieler 5000 Wasser.
    p.AddResource(resWater, 5000);
    
    // Nun f�ge die Starteinheiten am Startpunkt hinzu.
    //Infanterie
    p.CreateObject("E_IN_MA_01_1", x, y-1, 0, 0);
    p.CreateObject("E_IN_MA_01_1", x, y+1, 0, 0);
    // Vologdas
    p.CreateObject("E_CH_AH_12", x+1, y, 0, 0);
    p.CreateObject("E_CH_AH_12", x, y, 0, 0);
  }
  
  function void InitLCPlayer(player p, int x, int y)
  {
    // Gib dem Spieler 5000 Kristall.
    p.AddResource(resCrystal, 5000);
    
    // Nun f�ge die Starteinheiten am Startpunkt hinzu.
    // Infanterie
    p.CreateObject("L_IN_RG_01_1", x, y, 0, 0);
    p.CreateObject("L_IN_RG_01_1", x-1, y, 0, 0);
  }
  
  function void InitAlienPlayer(player p, int x, int y)
  {
    // F�ge Mantian Ladys hinzu.
    p.CreateObject("A_CH_NU_01_1", x-1, y, 0, 0);
    p.CreateObject("A_CH_NU_01_1", x+1, y, 0, 0);
    p.CreateObject("A_CH_NU_01_1", x, y-1, 0, 0);
  }
  
  function void InitPlayers()
  {
    int i; 
    player p;
    int x;
    int y;
    
    // Durchlaufe alle 8 m�glichen Spieler
    for (i = 1; i <= 8; ++i)
    {
      // Hole das Objekt, das den Spieler mit Startnummer i repr�sentiert.
      p = GetPlayer(i);
      
      // Standardtest, ob es diesen Spieler �berhaupt gibt: 
      // - Zun�chst der Vergleich mit null: Haben wir �berhaupt ein g�ltiges
      //   Spielerobjekt erhalten?
      // - Dann die Abfrage, ob dieser Spieler �berhaupt noch am Leben ist.
      //   Zu diesem Zeitpunkt im Prinzip �berfl�ssig, schadet aber auch nicht.
      if (p != null && p.IsAlive())
      {
        // Setze die Kameraposition des Spielers auf seinen Startpunkt.
        // Daf�r zun�chst die Koordinaten des Startpunktes holen:
        GetStartingPoint(i, x, y);
        // Nun die Kamera auf diesen Punkt ausrichten:
        p.LookAt(x, y, 40, 0, 20);

        // Schlage die Rasse des Spielers nach und rufe die entsprechende 
        // Init-Funktion auf.
        if (p.GetRace() == raceUCS)
          InitUCSPlayer(p, x, y);
        else if (p.GetRace() == raceED)
          InitEDPlayer(p, x, y);
        else if (p.GetRace() == raceLC)
          InitLCPlayer(p, x, y);
        else // p.GetRace() == raceAlien
          InitAlienPlayer(p, x, y);
        
      }
    }
  }
  
  
  
  // ** State-Deklarationen **
  
  state Initialize;
  state Nothing;
  
  
  // ** State-Implementationen **
  
  state Initialize
  {
    // Initialisierungsphase:
    // 1. alle n�tigen Variablen initialisieren
    // 2. Startbedingungen f�r alle Spieler einstellen
    InitPlayers();
    
    // Initialisierung abgeschlossen, neuer State Nothing
    return Nothing;
  }
  
  state Nothing
  {
    // Aktiver State w�hrend dem regul�ren Skriptablauf.
    return Nothing;
  }
  
  
  // ** Events **
  
  event SpecialLevelFlags()
  {
    // Setze die Maske der erlaubten Maps.
    return 0x01;
  }
  
  event AIPlayerFlags()
  {
    // Setze die Maske der erlaubten KI-Skripts.
    return 0x01;
  }
  
  event RemoveUnits()
  {
    // Entferne die von der Map vorgegebenen Einheiten, Geb�ude und Rassen.
    return true;
  }

  
  event PreLoadGame()
  {
    // Lade das Custom Balancing des Rebalancing Projekts.
    LoadCustomParameters("IEO_Rebalancing\\IEO_Rebalancing_Beta_v8.2.par");
  }
}
