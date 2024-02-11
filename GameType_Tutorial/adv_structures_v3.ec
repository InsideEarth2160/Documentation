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
  
  
  // ** Globale Variablen **  
  int playerConstructedBuildings[]; // Flag, ob Spieler schon Gebäude gebaut hat
  int checkDefeatConditions; // Flag, ob die Niederlagebedingungen überprüft werden sollen
  
  
  // ** Funktionen **
  
  function void InitUCSPlayer(player p, int x, int y)
  {
    // Gib dem Spieler 5000 Metall.
    p.AddResource(resMetal, 5000);
    
    // Nun füge die Starteinheiten am Startpunkt hinzu.
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
    
    // Nun füge die Starteinheiten am Startpunkt hinzu.
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
    
    // Nun füge die Starteinheiten am Startpunkt hinzu.
    // Infanterie
    p.CreateObject("L_IN_RG_01_1", x, y, 0, 0);
    p.CreateObject("L_IN_RG_01_1", x-1, y, 0, 0);
  }
  
  function void InitAlienPlayer(player p, int x, int y)
  {
    // Füge Mantian Ladys hinzu.
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
    
    // Durchlaufe alle 8 möglichen Spieler
    for (i = 1; i <= 8; ++i)
    {
      // Hole das Objekt, das den Spieler mit Startnummer i repräsentiert.
      p = GetPlayer(i);
      
      // Standardtest, ob es diesen Spieler überhaupt gibt: 
      // - Zunächst der Vergleich mit null: Haben wir überhaupt ein gültiges
      //   Spielerobjekt erhalten?
      // - Dann die Abfrage, ob dieser Spieler überhaupt noch am Leben ist.
      //   Zu diesem Zeitpunkt im Prinzip überflüssig, schadet aber auch nicht.
      if (p != null && p.IsAlive())
      {
        // Setze die Kameraposition des Spielers auf seinen Startpunkt.
        // Dafür zunächst die Koordinaten des Startpunktes holen:
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
    // 1. alle nötigen Variablen initialisieren
    // 2. Startbedingungen für alle Spieler einstellen
    int i;
    
    playerConstructedBuildings.Create(8);
    for (i = 0; i < 8; ++i)
      playerConstructedBuildings[i] = false;
    
    InitPlayers();
    
    // Aktiviere den Timer, der die Niederlagebedingungen prüft.
    SetTimer(0, 3*30);
    
    // Initialisierung abgeschlossen, neuer State Nothing
    return Nothing;
  }
  
  state Nothing
  {
    // Aktiver State während dem regulären Skriptablauf.
    return Nothing;
  }
  
  
  // ** Events **
  
  event Timer0()
  {
    // Überprüfe die Niederlagebedingungen, falls die Flag gesetzt ist.
    int i;
    int j;
    player p;
    player p2;
    int numObjects;
    int playerKilled;
    int activeEnemies;
    
    if (checkDefeatConditions)
    {
      checkDefeatConditions = false;
      for (i = 1; i <= 8; ++i)
      {
        // hole Spielerobjekt.
        p = GetPlayer(i);
        if (p != null && p.IsAlive())
        {
          playerKilled = false;
          if (p.GetRace() != raceAlien)
          {
            // Prüfe Niederlagebedingung für UCS, ED, LC.
            // Schaue, ob der Spieler vorher bereits Gebäude gebaut hat:
            if (playerConstructedBuildings[i])
            {
              // In diesem Fall hat der Spieler verloren, falls seine Anzahl Gebäude
              // auf 0 sinkt:
              if (p.GetNumberOfBuildings() == 0)
              {
                // setze Niederlageflag auf ja.
                playerKilled = true;
              }
            }
            else
            {
              // Der Spieler hat noch keine Gebäude, dann verliert er, wenn er alle
              // Starteinheiten verliert:
              if (p.GetNumberOfUnits() == 0)
              {
                // setze Niederlageflag auf ja.
                playerKilled = true;
              }
            }
          }
          else
          {
            // Prüfe Niederlagebedingung für Aliens.
            numObjects = p.GetNumberOfBuildings()  // Anzahl Verteidigungstürme
              + p.GetNumberOfUnitsWithChasis("A_CH_NU_01_1", false) // Ladys
              + p.GetNumberOfUnitsWithChasis("A_CH_NU_02_1", false) // Princess
              + p.GetNumberOfUnitsWithChasis("A_CH_NU_03_1", false) // Queens
              + p.GetNumberOfTransformationCopulas() // Kokoons
            ;
            if (numObjects == 0)
            {
              // Alienspieler besiegt
              playerKilled = true;
            }
          
          }
          
          if (playerKilled)
          {
            // Niederlage des Spielers wurde festgestellt.
            p.GameDefeat(true);
          }
        }
      }
    }
    
    
    // Prüfe, ob es noch verbliebene verfeindete Spieler gibt. Falls nicht,
    // beende das Spiel für alle verbliebenen Spieler mit einem Sieg.
    activeEnemies = false;
    for (i = 1; i <= 7; ++i)
    {
      p = GetPlayer(i);
      if (p != null && p.IsAlive())
      {
        // prüfe mit jedem anderen noch aktiven Spieler, ob diese in feindlichem
        // Verhältnis zueinander stehen.
        for (j = i+1; j <= 8; ++j)
        {
          p2 = GetPlayer(j);
          if (p2 != null && p2.IsAlive())
          {
            // stehen die Spieler sich feindlich gegenüber, zumindest von einer Seite?
            if (p.IsEnemy(p2) || p2.IsEnemy(p))
            {
              // dann gibt es noch aktive Feinde.
              activeEnemies = true;
              break;
            }
          }
        }
        // falls aktive Feinde, können wir die Schleife vorzeitig abbrechen.
        if (activeEnemies)
          break;
      }
    }
    
    // falls KEINE aktiven Feinde mehr gefunden wurden, beenden wir das Spiel für
    // alle verbliebenen Spieler mit einem Sieg.
    if (!activeEnemies)
    {
      for (i = 1; i <= 8; ++i)
      {
        p = GetPlayer(i);
        if (p != null && p.IsAlive())
          p.GameVictory(false, true);
      }
    }
  }
  
  
  event RemovedUnit(unit destroyed, unit fromUnit, int mode)
  {
    // Einheit zerstört, prüfe die Niederlagebedingungen.
    checkDefeatConditions = true;
  }
  
  event AddedBuilding(unit added, int mode)
  {
    // Neues Gebäude gebaut, setze die Flag des betreffenden Spielers auf true.
    playerConstructedBuildings[added.GetIFFNum()] = true;
  }
  
  event RemovedBuilding(unit destroyed, unit fromUnit, int mode)
  {
    // Gebäude zerstört, prüfe die Niederlagebedingungen.
    checkDefeatConditions = true;
  }
  
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
    // Entferne die von der Map vorgegebenen Einheiten, Gebäude und Rassen.
    return true;
  }

  
  event PreLoadGame()
  {
    // Lade das Custom Balancing des Rebalancing Projekts.
    LoadCustomParameters("IEO_Rebalancing\\IEO_Rebalancing_Beta_v8.2.par");
  }
}
