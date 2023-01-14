AFFCHAINE:  ;Affiche la chaine contenue dans A2
    MOVE #6, D0
WHILEAC:
    MOVE.B (A2), D1
    CMP.B #0, D1
    BEQ FINWHILEAC
    TRAP #15
    ADD.L #1, A2
    BRA WHILEAC
FINWHILEAC:
    RTS 
    
PRINTHEX:
    CMP.B #9, D1
    BGT GT9
    ADD.B #48, D1
    BRA FINGT9
GT9:
    SUB.B #10, D1
    ADD.B #65, D1
FINGT9:
    MOVE #6, D0
    TRAP #15
    RTS

*Bien mettre le labyrinthe dans A0, taillelaby dans D0 (2 bytes)
PRINTLABY:
    MOVE.L #1, D3
    MOVE.L A0, A2
    MOVE LG_TAB, D4
WHILEPL:
    MOVE.B (A0)+, D1
    JSR PRINTHEX
    CMP.L D4, D3
    BNE SUITEPL
    JSR RETOURCHAR
    MOVE.L #0, D3
SUITEPL:
    ADD.L #1, D3
    CMP.B #10, (A0)
    BNE WHILEPL
    MOVE.L A2, A0
    RTS
    
RETOURCHAR:
    MOVE.B #13, D1
    MOVE #6, D0
    TRAP #15
    MOVE.B #10, D1
    TRAP #15
    RTS
    
SETPENCOLORLABY:
    MOVE.L #$000000FF, D1
    JSR SET_PEN_COLOR
    RTS
SETPENCOLORJOUEUR:
    MOVE.L #$00FF0000, D1
    JSR SET_PEN_COLOR
    RTS
SETPENCOLORFIN:
    MOVE.L #$0000FF00, D1
    JSR SET_PEN_COLOR
    RTS
    
DEF_PIX_HL:
    *Mets les registres à 0 sur 32bits
    MOVE.L #0, D0
    MOVE.L #0, D1
    MOVE.L #0, D2
    
    MOVE LARGEUR_FENETRE, D0
    MOVE HAUTEUR_FENETRE, D1
    *taille laby
    MOVE LG_TAB, D2
    *Calcul taille des murs
    *Mur horizontaux (D0)
    DIVU D2, D0
    AND.L #$0000FFFF, D0
    MOVE D0, LARGEUR_PIX_MUR
    *Mur verticaux (D1)
    DIVU D2, D1
    AND.L #$0000FFFF, D1
    MOVE D1, HAUTEUR_PIX_MUR
    RTS 

*Mettre le labyrinthe à dessiner dans A0
DESSINE_LABY:
    *Couleur crayon
    JSR SETPENCOLORLABY
    
    MOVE #10, D1 ;X1
    MOVE #10, D2 ;Y1
    MOVE #10, D3 ;X2
    MOVE #10, D4 ;Y2
    
    MOVE.B #0, D5 ; i
    MOVE.B #0, D6 ; j
    *Calcul taille laby
    MOVE LG_TAB, D7
    SUB #1, D7
    MOVE.B D7, TEMP ; TEMP = TAILLELABY-1
    ADD #1, D7
    *Pour i allant de 0 à D7
    POURIDL:
        CMP.B D7, D5
        BEQ FINPOURIDL
        *Pour j allant de 0 à D7
        POURJDL:
            CMP.B D7, D6
            BEQ FINPOURJDL
            ;Si i = 0 ou  i = TAILLELABY-1
            CMP.B #0, D5
            BEQ POTEAUEXTERNEH
            CMP.B TEMP, D5
            BEQ POTEAUEXTERNEH
            ;Si j = 0 ou j = TAILLELABY - 1
            CMP.B #0, D6
            BEQ POTEAUEXTERNEV
            CMP.B TEMP, D6
            BEQ POTEAUEXTERNEV
            ;Sinon
                ;Si on est sur un piquet
                CMP.B #1, (A0)
                BEQ PIQUET
                CMP.B #3, (A0)
                BEQ PIQUET
                ;Sinon
                CMP.B #2, (A0)
                BEQ JOUEUR
                CMP.B #5, (A0)
                BEQ FINLABY
                BRA FINSIDL
                POTEAUEXTERNEH:
                    ;Si i = 0 ou i = taillelaby-1 ET j = 0 ou j = taillelaby-1
                    CMP.B #0, D6
                    BEQ DESSINE_POINT
                    CMP.B TEMP, D6
                    BEQ DESSINE_POINT 
                    JSR DESSINE_MUR_EXTERNEH
                    BRA FINSIDL
                        DESSINE_POINT:
                            JSR DRAW_LINE
                            BRA FINSIDL
                POTEAUEXTERNEV:
                    JSR DESSINE_MUR_EXTERNEV
                    BRA FINSIDL
                PIQUET:
                    JSR DESSINE_MUR
                    BRA FINSIDL
                JOUEUR:
                    MOVE D1, SAUV_D1
                    JSR SETPENCOLORJOUEUR
                    MOVE SAUV_D1, D1
                    JSR DRAW_LINE
                    JSR SETPENCOLORLABY
                    MOVE SAUV_D1, D1 
                    BRA FINSIDL
                FINLABY:
                    MOVE D1, SAUV_D1
                    JSR SETPENCOLORFIN
                    MOVE SAUV_D1, D1
                    JSR DRAW_LINE
                    JSR SETPENCOLORLABY
                    MOVE SAUV_D1, D1  
            FINSIDL:
                    
            ADD LARGEUR_PIX_MUR, D1
            MOVE D1, D3
            MOVE D2, D4
            ADD.L #1, A0
            ADD.B #1, D6
            BRA POURJDL 
        FINPOURJDL:
        *Finpour J
        
        MOVE.B #0, D6
        ADD.B #1, D5
        *Nouvelle coordonées
        MOVE #10, D1
        ADD HAUTEUR_PIX_MUR, D2
        MOVE D1, D3
        MOVE D2, D4
        BRA POURIDL
    FINPOURIDL:
    *Finpour I
    RTS
 
DESSINE_MUR:    ;L'adresse du poteau doit être dans A0
    MOVE.L A0, A5
    MOVE.L A0, A2
    MOVE.L A0, A3
    MOVE.L A0, A4
    
    MOVE LG_TAB, D0

    SUB.L D0, A5 ;Poteau haut
    ADD.L D0, A2 ;Poteau bas
    ADD.L #1, A3 ;Poteau droit
    SUB.L #1, A4 ;Poteau gauche
 
    *Si la case du dessus est un poteau
    CMP.B #1, (A5)
    BEQ PO_HAUT
    CMP.B #3, (A5)
    BEQ PO_HAUT
    BRA FIN_PO_HAUT
    PO_HAUT:
        SUB HAUTEUR_PIX_MUR, D4
        JSR DRAW_LINE
        MOVE D2, D4
    FIN_PO_HAUT:
    *Si la case de droite est un poteau
    CMP.B #1, (A3)
    BEQ PO_DROIT
    CMP.B #3, (A3)
    BEQ PO_DROIT
    BRA FIN_PO_DROIT
    PO_DROIT:
        ADD LARGEUR_PIX_MUR, D3
        JSR DRAW_LINE
        MOVE D1, D3
    FIN_PO_DROIT:
    *Si la case de gauche est un poteau
    CMP.B #1, (A4)
    BEQ PO_GAUCHE
    CMP.B #3, (A4)
    BEQ PO_GAUCHE
    BRA FIN_PO_GAUCHE
    PO_GAUCHE:
        SUB LARGEUR_PIX_MUR, D3
        JSR DRAW_LINE
        MOVE D1, D3
    FIN_PO_GAUCHE:
    *Si la case du bas est un poteau
    CMP.B #1, (A2)
    BEQ PO_BAS
    CMP.B #3, (A2)
    BEQ PO_BAS
    BRA FIN_PO_BAS
    PO_BAS:
        ADD HAUTEUR_PIX_MUR, D4
        JSR DRAW_LINE
        MOVE D2, D4
    FIN_PO_BAS:
    RTS
    
DESSINE_MUR_EXTERNEV:
    MOVE.L A0, A5
    MOVE.L A0, A2
    
    MOVE LG_TAB, D0

    SUB.L D0, A5 ;Poteau haut
    ADD.L D0, A2 ;Poteau bas
    
    *Si la case du dessus est un poteau
    CMP.B #3, (A5)
    BEQ PO_HAUT2
    BRA FIN_PO_HAUT2
    PO_HAUT2:
        SUB HAUTEUR_PIX_MUR, D4
        JSR DRAW_LINE
        MOVE D2, D4
    FIN_PO_HAUT2:
    *Si la case du bas est un poteau
    CMP.B #3, (A2)
    BEQ PO_BAS2
    BRA FIN_PO_BAS2
    PO_BAS2:
        ADD HAUTEUR_PIX_MUR, D4
        JSR DRAW_LINE
        MOVE D2, D4
    FIN_PO_BAS2:
    RTS
    
DESSINE_MUR_EXTERNEH:
    MOVE.L A0, A3
    MOVE.L A0, A4

    ADD.L #1, A3 ;Poteau droit
    SUB.L #1, A4 ;Poteau gauche
 
    *Si la case de droite est un poteau
    CMP.B #3, (A3)
    BEQ PO_DROIT2
    BRA FIN_PO_DROIT2
    PO_DROIT2:
        ADD LARGEUR_PIX_MUR, D3
        JSR DRAW_LINE
        MOVE D1, D3
    FIN_PO_DROIT2:
    *Si la case de gauche est un poteau
    CMP.B #3, (A4)
    BEQ PO_GAUCHE2
    BRA FIN_PO_GAUCHE2
    PO_GAUCHE2:
        SUB LARGEUR_PIX_MUR, D3
        JSR DRAW_LINE
        MOVE D1, D3
    FIN_PO_GAUCHE2:
    RTS
    
RESET_FENETRE:
    MOVE.W #$FF00, D1
    MOVE #11, D0
    TRAP #15
    RTS
    
DESSINE_MENU:
    MOVE.L #0, D1
    *==== Affiche le titre ====
    *Centre le titre
    MOVE LARGEUR_FENETRE, D1
    DIVU #2, D1
    SUB #50, D1
    MOVE #10, D2
    *Chaine
    MOVE #TITRE, A1
    JSR DRAW_STRING
    
    *==== Affiche "Facile" ====
    ADD #12, D1
    MOVE #100, D2
    MOVE #FACILE_STR, A1
    JSR DRAW_STRING
    *==== Affiche "Moyen" ====
    ADD #4, D1
    MOVE #150, D2
    MOVE #MOYEN_STR, A1
    JSR DRAW_STRING
    *==== Affiche "Difficile" ====
    SUB #16, D1
    MOVE #200, D2
    MOVE #DIFFICILE_STR, A1
    JSR DRAW_STRING
    *==== Affiche "Quitter" ====
    ADD #5, D1
    MOVE #350, D2
    MOVE #QUITTER_STR, A1
    JSR DRAW_STRING
    RTS
    
FINPRG:
    MOVE #9, D0
    TRAP #15
    
    











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
