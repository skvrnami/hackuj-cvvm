# Hackuj CVVM

Skripty pro naačtení .sav souborů stažených z [Českého sociálněvědního datového archivu](http://nesstar.soc.cas.cz/webview/) do R, jejich spojení do jednoho data.frame-u a uložení do .csv souboru. 

Vytovřeno na Hackuj státu 2018, další navazující skripty jsou [tady](https://gitlab.com/jakubbares/hackujstat/) vytvořené na hackathonu týmem _"druhá fáze"_. 

Postup:  

1. Stáhnout data a konvertovat
    * stáhnout .sav soubory (SPSS formát) z ČSDA do složky `/data`
    * spusit skript `convert_to_csv.R` 
    * výstup jsou dva soubory - `output/questions.csv` (obsahující kód otázky a název otázky, pokud má otázka víc různých popisů napříč soubory, vezme se pouze první název) a 
    `output/surveys.csv` (obsahující všechny soubory spojené do jednoho)
    * `topic_one.R` je příklad použití dat - vývoj zmiňování migrace jako nejzávažnějšího společenského tématu
    
2. ?

3. Profit (hypoteticky, data z ČSDA jsou licencovaná pro nekomerční použití)
    
