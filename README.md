# Pomodoro Timer pre zvukového inžiniera

Tento repozitár obsahuje ukážkový SwiftUI kód pre jednoduchú iOS aplikáciu,
ktorá využíva vlastný pomodoro cyklus. Pracovné intervaly sú nasledovné:

1. 25 minút práca
2. 5 minút pauza
3. 25 minút práca
4. 5 minút pauza
5. 25 minút práca
6. 5 minút pauza
7. 25 minút práca
8. 30 minút dlhšia pauza

Po skončení každej pauzy sa zobrazí otázka, či chcete začať nový cyklus práce.
Aplikácia prehrá zvukový signál a pošle notifikáciu na konci každého úseku.

## Použitie

1. Vytvorte v Xcode nový projekt **App** so SwiftUI.
2. Nahraďte automaticky vytvorený súbor `ContentView.swift` a `MyApp.swift`
   obsahom súboru [`PomodoroApp.swift`](PomodoroApp.swift).
   Po spustení uvidíte kruhový ukazovateľ odpočtu a tlačidlo **Štart/Zastaviť**.
   Ak timer zastavíte, tlačidlo začne blikať s textom **Štart**.
   Klepnutím na zobrazený čas prepnete spôsob odpočtu medzi režimom 25 → 0
   a opačným 0 → 25.
3. Spustite aplikáciu na simulátore alebo zariadení.

Aplikácia vyžaduje povolenie notifikácií, aby mohla upozorňovať aj keď beží
na pozadí.

## Tipy na zobrazenie náhľadu a spustenie na iPhone

1. V Xcode otvoríte súbor `PomodoroApp.swift` a v pravom paneli kliknete na
   `Resume` pri štruktúre `ContentView_Previews`. Tak sa zobrazí SwiftUI
   náhľad obrazovky.
2. Ak chcete aplikáciu otestovať na fyzickom zariadení, pripojte iPhone k
   počítaču, v nastaveniach targetu zvoľte svoje Apple ID ako **Team** a
   kliknite na **Run**. Xcode vytvorí dočasný profil na podpis a aplikáciu
   nainštaluje.
