    ORG $400
    
    *Epaisseur crayon
    MOVE.B #10, D1
    JSR WIDTH_PEN
    
TANTQUEJOUE: 
    *Affichage du menu + choix clique souris
    JSR DESSINE_MENU
    JSR CLIQUESOURIS_MENU
    JSR RESET_FENETRE
    
    *Labyrinthe on fonction du choix menu
    MOVE.L #LABY, A0
    MOVE.L A0, A6
    CMP.B #1, CHOIX_MENU
    BEQ MODEFACILE
    CMP.B #2, CHOIX_MENU
    BEQ MODEMOYEN
    CMP.B #3, CHOIX_MENU
    BEQ MODEDIFFICILE
    CMP.B #4, CHOIX_MENU
    BEQ FINPROG
    
    MODEFACILE:
        MOVE #5, TAILLELABY
        JSR CALCUL_LGTAB
        JSR INITADRRJOUEUR
        BRA FINMODE
    MODEMOYEN:
        MOVE #10, TAILLELABY
        JSR CALCUL_LGTAB
        JSR INITADRRJOUEUR
        BRA FINMODE
    MODEDIFFICILE:
        MOVE #15, TAILLELABY
        JSR CALCUL_LGTAB
        JSR INITADRRJOUEUR
        BRA FINMODE
    FINMODE:
        JSR GENERE_LABY
        MOVE.L A6, A0
    *Definition de la taille en pixel des murs
    JSR DEF_PIX_HL
    
    *Position de base du joueur
    JSR INITPOSJOUEUR
    
    *Dessine le labyrinthe contenu dans A0
    JSR LABY_ALEATOIRE
    JSR RESET_FENETRE
    MOVE.L A6, A0
    JSR DESSINE_LABY

TANTQUE:
    JSR CHOIXMOUVEMENT
    JSR DEPLACEJOUEUR
    CMP.B #5, PRECVAL
    BNE TANTQUE
    
    MOVE.L #GAGNE, A2
    JSR AFFCHAINE
    *Ralentissement
    MOVE.L #0, D0
    POURRALENTIR:
        CMP.L #150000, D0
        BEQ FINPOURRALENTIR
        ADD.L #1, D0
        BRA POURRALENTIR
    FINPOURRALENTIR:
    MOVE.L A6, A0
    JSR RESET_LABY
    JSR RESET_FENETRE
    *Reset précédente valeur
    MOVE.B #0, PRECVAL
    BRA TANTQUEJOUE
    
    FINPROG:
    JSR FINPRG
    
    INCLUDE 'PILE.X68'
    INCLUDE 'BIBGRAPH.X68'
    INCLUDE 'MOTEUR.X68'
    INCLUDE 'AFFICHAGE.X68'
    
    ORG $1000
* ===== Variables ====
*Variables du programme
LARGEUR_FENETRE: DC.W 640
HAUTEUR_FENETRE: DC.W 480
LARGEUR_PIX_MUR: DS.W  1
HAUTEUR_PIX_MUR: DS.W  1
TAILLELABY:      DC.W  5                      ; Taille du labyrinthe
LG_TAB:          DC.W  11
PRECVAL:         DC.B  0                       ; Précédente valeur de la case où le joueur est
GAGNE:           DC.B  'Gagné !',0
CHOIX_MENU       DC.B  0                       ;Choix facile(1), moyen(2), difficile(3) ou quitter(4)
POS_JOUEUR_X     DS.W  1                       ;Position actuelle du joueur dans le labyrinthe X
POS_JOUEUR_Y     DS.W  1                       ;Position actuelle du joueur dans le labyrinthe Y

*Variables fonction DESSINE_LABY
TEMP: DS.B  1
SAUV_D1: DS.W 1

*Variable DESSINE_MENU
TITRE:              DC.B 'LABYRINTHE', 0
FACILE_STR:         DC.B 'Facile', 0
MOYEN_STR:          DC.B 'Moyen', 0
DIFFICILE_STR:      DC.B 'Difficile', 0
QUITTER_STR         DC.B 'Quitter', 0

*Variable LABY_ALEATOIRE
ADRESSE_LABY: DS.L 1
RANDOM: DS.W 1

* ==== Pile ====
*Ceci est une pile d'adresses, chaque case de la pile fait 32 bits de long
ESTVIDE: DC.B 0             ;Booléen, sert à savoir si la pile est vide ou pas (gérer dans la fonction DEPILER)
VALEUR_A_EMPILER: DS.L 1    ;Variable qui sera emplilée lors de l'appel de "EMPILER"
VALEUR_DEPILER: DS.L   1    ;Variable retournée après l'appel de "DEPILER"
POSITION_PILE:  DS.L   1    ;Adresse de la position dans la pile actuelle
DEBUT_PILE: DC.L 0
TAILLE_PILE: DS.L 230      ;Le labyrinthe difficile peut aller jusqu'à 225 cases d'empilées

* ==== Espace labyrinthe ====
LABY: DS.B 1
        
        END $400

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
