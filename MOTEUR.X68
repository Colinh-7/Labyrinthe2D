*L'adresse de départ du joueur sera dans A1
INITADRRJOUEUR:
    MOVE.L A0, A1
    MOVE.L #0, D0
    MOVE LG_TAB, D0
    ADD.L D0, A1
    ADD.L #1, A1
    RTS
  
INITPOSJOUEUR:
    MOVE LARGEUR_PIX_MUR, D0
    MOVE HAUTEUR_PIX_MUR, D1
    MOVE D0, POS_JOUEUR_X
    ADD #10, POS_JOUEUR_X
    MOVE D1, POS_JOUEUR_Y
    ADD #10, POS_JOUEUR_Y
    RTS
    
CALCUL_LGTAB:
    MOVE TAILLELABY, D0
    MULU #2, D0
    ADD #1, D0
    MOVE D0, LG_TAB
    RTS
    
CHOIXMOUVEMENT:
WHILECM:
    MOVE #5, D0
    TRAP #15
    CMP.B #90, D1
    BEQ FINWHILECM
    CMP.B #122, D1
    BEQ FINWHILECM
    CMP.B #83, D1
    BEQ FINWHILECM
    CMP.B #115, D1
    BEQ FINWHILECM
    CMP.B #81, D1
    BEQ FINWHILECM
    CMP.B #113, D1
    BEQ FINWHILECM
    CMP.B #68, D1
    BEQ FINWHILECM
    CMP.B #100, D1
    BEQ FINWHILECM
    MOVE D1, D2
    *Reset curseur
    MOVE #$0000, D1
    MOVE #11, D0
    TRAP #15
    MOVE D2, D1
    BRA WHILECM
FINWHILECM:
    MOVE D1, D2
    *Reset curseur
    MOVE #$0000, D1
    MOVE #11, D0
    TRAP #15
    MOVE D2, D1
    RTS

* Mettre cordoonées du joueur dans A1 
DEPLACEJOUEUR:
    MOVE LG_TAB, D0 
    MOVE.B PRECVAL, (A1) ;On remet l'ancienne valeur de la case
    *Sauvegarde D1 dans D5
    MOVE.L D1, D5
    *Mets HAUTEUR_PIX_MUR dans D6, LARGEUR_PIX_MUR dans D7
    MOVE HAUTEUR_PIX_MUR, D6
    MOVE LARGEUR_PIX_MUR, D7
    *==== Efface la position du joueur à l'écran ====
    *Met pen color en noir
    MOVE.L #$00000000, D1
    MOVE #80, D0
    TRAP #15
    *Efface position
    MOVE POS_JOUEUR_X, D1
    MOVE D1, D3
    MOVE POS_JOUEUR_Y, D2
    MOVE D2, D4
    JSR DRAW_LINE
    *Remet pen color bleu
    JSR SETPENCOLORJOUEUR
    *Remet LG_TAB dans D0
    MOVE LG_TAB, D0
    MOVE D5, D1
    * Z ou z
    CMP.B #90, D1
    BEQ HAUT
    CMP.B #122, D1
    BEQ HAUT
    * S ou s
    CMP.B #83, D1
    BEQ BAS
    CMP.B #115, D1
    BEQ BAS
    * Q ou q
    CMP.B #81, D1
    BEQ GAUCHE
    CMP.B #113, D1
    BEQ GAUCHE
    * D ou d
    CMP.B #68, D1
    BEQ DROITE
    CMP.B #100, D1
    BEQ DROITE
    BRA FINDEPLACEJOUEUR
HAUT:
    SUB.L D0, A1
    SUB D6, POS_JOUEUR_Y
    CMP.B #3, (A1)          ;Si c'est un mur externe
    BEQ HAUTFIN
    CMP.B #1, (A1)
    BNE FINDEPLACEJOUEUR    ;Si ce n'est pas un mur
HAUTFIN:
    ADD.L D0, A1              ;Sinon
    ADD D6, POS_JOUEUR_Y
    BRA FINDEPLACEJOUEUR
BAS:
    ADD.L D0, A1
    ADD D6 , POS_JOUEUR_Y
    CMP.B #3, (A1)          ;Si c'est un mur externe
    BEQ BASFIN
    CMP.B #1, (A1)
    BNE FINDEPLACEJOUEUR    ;Si ce n'est pas un mur
BASFIN:
    SUB.L D0, A1              ;Sinon
    SUB D6, POS_JOUEUR_Y
    BRA FINDEPLACEJOUEUR
GAUCHE:
    SUB.L #1, A1
    SUB D7, POS_JOUEUR_X
    CMP.B #3, (A1)          ;Si c'est un mur externe
    BEQ GAUCHEFIN
    CMP.B #1, (A1)
    BNE FINDEPLACEJOUEUR    ;Si ce n'est pas un mur
GAUCHEFIN:
    ADD.L #1, A1              ;Sinon
    ADD D7, POS_JOUEUR_X
    BRA FINDEPLACEJOUEUR
DROITE:
    ADD.L #1, A1
    ADD D7, POS_JOUEUR_X
    CMP.B #3, (A1)          ;Si c'est un mur externe
    BEQ DROITEFIN
    CMP.B #1, (A1)
    BNE FINDEPLACEJOUEUR    ;Si ce n'est pas un mur
DROITEFIN:
    SUB.L #1, A1            ;Sinon
    SUB D7, POS_JOUEUR_X
    BRA FINDEPLACEJOUEUR
FINDEPLACEJOUEUR:
    MOVE.B (A1), PRECVAL
    MOVE.B #2, (A1)
    *Dessine sur le laby
    MOVE POS_JOUEUR_X, D1
    MOVE D1, D3
    MOVE POS_JOUEUR_Y , D2
    MOVE D2, D4
    JSR DRAW_LINE
    RTS
    
GENERE_LABY: * Dans le labyrinthe, chaque mur = 1, chaque passage = 0, le joueur = 2, mur externe = 3 , case non visitée = 4 (sert à l'aldo de génération de labyrinthe aléatoire) et la fin = 5, 10 = Fin laby.        
    MOVE.L #0, D0 ;i
    MOVE.L #0, D1 ;j
    MOVE.L #0, D2
    MOVE LG_TAB, D2
    MOVE.L D2, D3
    SUB.L #1, D3
    POURI:
        CMP.L D2, D0
        BEQ FINPOURI
        POURJ:
            CMP.L D2, D1
            BEQ FINPOURJ
            *Si  i=0 ou i = LG_TAB-1
            CMP.L #0, D0
            BEQ METTREUN3
            CMP.L D3, D0
            BEQ METTREUN3
            *Sj j = 0 ou j = LG_TAB-1
            CMP.L #0, D1
            BEQ METTREUN3
            CMP.L D3, D1
            BEQ METTREUN3
            *Sinon
            *Si i est pair
            MOVE.L D0, D4
            DIVU #2, D4
            SWAP D4
            CMP.B #0, D4
            BEQ METTREUN1
            *Sinon
            MOVE.L D1, D4
            DIVU #2, D4
            SWAP D4
            *Si j est pair
            CMP #0, D4
            BEQ METTREUN1
            *Sinon
                *METTREUN4
                MOVE.B #4, (A0)+
                BRA FINSI
                METTREUN1:
                MOVE.B #1, (A0)+
                BRA FINSI
                METTREUN3:
                MOVE.B #3, (A0)+
         FINSI:
         ADD.L #1, D1
         BRA POURJ
         FINPOURJ:
         MOVE.L #0, D1
         ADD.L #1, D0
         BRA POURI         
    FINPOURI:
    *Mets la position initiale du joueur
    MOVE.B #2, (A1)
    RTS
    
RESET_LABY: *Remet toutes les cases à "FF". Mettre l'adresse de départ du labyrinthe dans A0
    MOVE.L #0, D0 ;i
    MOVE.L #0, D1 ;j
    MOVE.L #0, D2
    MOVE LG_TAB, D2
    POURIR:
        CMP.L D2, D0
        BEQ FINPOURIR
        POURJR:
            CMP.L D2, D1
            BEQ FINPOURJR
            MOVE.B #$FF, (A0)+
            ADD.L #1, D1
            BRA POURJR
         FINPOURJR:
         MOVE.L #0, D1
         ADD.L #1, D0
         BRA POURIR         
    FINPOURIR:
    RTS
    
LABY_ALEATOIRE:
*    MOVE.L A0, ADRESSE_LABY
*    MOVE.L A1, A0
*    MOVE.B #0, COMPTEUR
*    MOVE.L #0, D3
*    MOVE LG_TAB, D3
*    MOVE.L D3, LG_TAB_32BIT
*    *Tant qu'on a pas trouvé un chemin qui va jusqu'à la fin
*    WHILELA:
*        *Nombre "aléatoire" allant de 0 à 3 : 0 = Nord, 1 = Est, 2 = Sud, 3 = Ouest
*        MOVE #8, D0
*        TRAP #15
*        AND.L #$0000FFFF, D1
*        DIVU #4, D1
*        SWAP D1
*        AND.L #$0000FFFF, D1
*        *Dans quel cas sommes nous
*        CMP.B #0, D1
*        BEQ NORD
*        CMP.B #1, D1
*        BEQ EST
*        CMP.B #2, D1
*        BEQ SUD
*        CMP.B #3, D1
*        BEQ OUEST
*        NORD:
*            SUB.L LG_TAB_32BIT, A0
*            CMP.B #3, (A0)
*            BNE SUITENORD
*                *Si c'est un mur externe
*                ADD.L LG_TAB_32BIT, A0
*                BRA FINDIRECTION
*                *Sinon
*            SUITENORD:
*                MOVE.B #0, (A0)
*                SUB.L LG_TAB_32BIT, A0 
*            BRA FINDIRECTION
*        EST:
*            ADD.L #1, A0
*            CMP.B #3, (A0)
*            BNE SUITEEST
*                *Si c'est un mur externe
*                SUB.L #1, A0
*                BRA FINDIRECTION
*                *Sinon
*            SUITEEST:
*                MOVE.B #0, (A0)
*                ADD.L #1, A0
*            BRA FINDIRECTION
*        SUD:
*            ADD.L LG_TAB_32BIT, A0
*            CMP.B #3, (A0)
*            BNE SUITESUD
*                *Si c'est un mur externe
*                SUB.L LG_TAB_32BIT, A0
*                BRA FINDIRECTION
*                *Sinon
*            SUITESUD:
*                MOVE.B #0, (A0)
*                ADD.L LG_TAB_32BIT, A0
*            BRA FINDIRECTION
*        OUEST:
*            SUB.L #1, A0
*            CMP.B #3, (A0)
*            BNE SUITEOUEST
*                *Si c'est un mur externe
*                ADD.L #1, A0
*                BRA FINDIRECTION
*                *Sinon
*            SUITEOUEST:
*                MOVE.B #0, (A0)
*                SUB.L #1, A0
*        FINDIRECTION:
*        *BOUCLE RALENTISSEMENT
**        FOR:
**            ADD.L #1, D2
**            CMP.L #150000, D2
**            BNE FOR
*        *MOVE.L #0, D2
*        MOVE.L A0, A6
*        MOVE.L ADRESSE_LABY, A0
*        JSR RESET_FENETRE
*        JSR DESSINE_LABY
*        MOVE A6, A0
*        ADD.B #1, COMPTEUR
*        CMP.B #75, COMPTEUR
*        BNE WHILELA
*        MOVE.B #5, (A0)
*        MOVE.L ADRESSE_LABY, A0
    JSR INITPILE
    MOVE #8, D0
    TRAP #15
    AND.L #$FFFF, D1
    MOVE D1, RANDOM
    MOVE.L A1, A0 ;Mets la position initiale du joueur dans A0
    ;Tant que la pile n'est pas vide
    WHILELA:
        *Si une case est visitable autour, on y va
        JSR ESTVISITABLE
        CMP.B #1, D3
        BEQ WHILEVISITABLE
        BRA NONVISITABLE
        WHILEVISITABLE:
            *A2 contient toujours l'adresse de la case, D2 contient toujours LG_TAB
            MOVE.L A2, A0
            MOVE RANDOM, D1
            CMP.L #0, D1
            BEQ REFAIRERANDOM
            BRA CONTINUER
                REFAIRERANDOM:
                    MOVE #8, D0
                    TRAP #15
                    AND.L #$FFFF, D1
            CONTINUER:
            MULU D1, D1
            SWAP D1
            AND.L #$FFFF, D1
            MOVE D1, RANDOM
            DIVU #4, D1
            SWAP D1
            AND.L #$F, D1

            CMP.L #0, D1
            BEQ NORD
            CMP.L #1, D1
            BEQ EST
            CMP.L #2, D1
            BEQ SUD
            CMP.L #3, D1
            BEQ OUEST
            BRA WHILEVISITABLE
                NORD:
                    SUB.L D2, A0
                    CMP.B #1, (A0)
                    BEQ NORD1
                    BRA WHILEVISITABLE
                        NORD1:
                            SUB.L D2, A0
                            CMP.B #4, (A0)
                            BEQ NORD2
                            BRA WHILEVISITABLE
                            NORD2:
                                *Casse le mur
                                ADD.L D2, A0
                                MOVE.B #0, (A0)
                                *Met la case comme visitée
                                SUB.L D2, A0
                                MOVE.B #0, (A0)
                                *Empile l'ancienne case
                                MOVE.L A0, ADRESSE_LABY ;Stocke A0 car EMPILER utilise A0
                                MOVE.L A2, VALEUR_A_EMPILER
                                JSR EMPILER
                                MOVE.L ADRESSE_LABY, A0
                                BRA FINVISITABLE
                EST:
                    ADD.L #1, A0
                    CMP.B #1, (A0)
                    BEQ EST1
                    BRA WHILEVISITABLE
                        EST1:
                            ADD.L #1, A0
                            CMP.B #4, (A0)
                            BEQ EST2
                            BRA WHILEVISITABLE
                            EST2:
                                *Casse le mur
                                SUB.L #1, A0
                                MOVE.B #0, (A0)
                                *Met la case comme visitée
                                ADD.L #1, A0
                                MOVE.B #0, (A0)
                                *Empile l'ancienne case
                                MOVE.L A0, ADRESSE_LABY ;Stocke A0 car EMPILER utilise A0
                                MOVE.L A2, VALEUR_A_EMPILER
                                JSR EMPILER
                                MOVE.L ADRESSE_LABY, A0
                                BRA FINVISITABLE
                SUD:
                    ADD.L D2, A0
                    CMP.B #1, (A0)
                    BEQ SUD1
                    BRA WHILEVISITABLE
                        SUD1:
                            ADD.L D2, A0
                            CMP.B #4, (A0)
                            BEQ SUD2
                            BRA WHILEVISITABLE
                            SUD2:
                                *Casse le mur
                                SUB.L D2, A0
                                MOVE.B #0, (A0)
                                *Met la case comme visitée
                                ADD.L D2, A0
                                MOVE.B #0, (A0)
                                *Empile l'ancienne case
                                MOVE.L A0, ADRESSE_LABY ;Stocke A0 car EMPILER utilise A0
                                MOVE.L A2, VALEUR_A_EMPILER
                                JSR EMPILER
                                MOVE.L ADRESSE_LABY, A0
                                BRA FINVISITABLE
                OUEST:
                    SUB.L #1, A0
                    CMP.B #1, (A0)
                    BEQ OUEST1
                    BRA WHILEVISITABLE
                        OUEST1:
                            SUB.L #1, A0
                            CMP.B #4, (A0)
                            BEQ OUEST2
                            BRA WHILEVISITABLE
                            OUEST2:
                                *Casse le mur
                                ADD.L #1, A0
                                MOVE.B #0, (A0)
                                *Met la case comme visitée
                                SUB.L #1, A0
                                MOVE.B #0, (A0)
                                *Empile l'ancienne case
                                MOVE.L A0, ADRESSE_LABY ;Stocke A0 car EMPILER utilise A0
                                MOVE.L A2, VALEUR_A_EMPILER
                                JSR EMPILER
                                MOVE.L ADRESSE_LABY, A0
                                BRA FINVISITABLE
        *Sinon on dépile
        NONVISITABLE:
            JSR DEPILER
            MOVE.L VALEUR_DEPILER, A0
            MOVE.L A0, ADRESSE_LABY
            BRA FINVISITABLE
    FINVISITABLE:
    MOVE.L A6, A0
    JSR RESET_FENETRE
    JSR DESSINE_LABY
    MOVE.L ADRESSE_LABY, A0
    CMP.B #1, ESTVIDE
    BNE WHILELA
    *Remet la pile à non vide
    MOVE.B #0, ESTVIDE
    *Ajoute la sortie du labyrinthe
    MOVE.L A6, A0
    MOVE.L #0, D0
    MOVE TAILLELABY, D0
    MOVE.L #1, D1
    MOVE.L #0, D2
    MOVE LG_TAB, D2
    FOR1:
        CMP.L D0, D1
        BEQ ENDFOR1
        ADD.L #1, D1
        ADD.L #1, A0
        ADD.L #1, A0
        ADD.L D2, A0
        ADD.L D2, A0
        BRA FOR1
    ENDFOR1:
    ADD.L #1, A0
    ADD.L D2, A0
    MOVE.B #5, (A0)
    MOVE.L A6, A0
    JSR RESET_FENETRE
    JSR DESSINE_LABY
    RTS
    
ESTVISITABLE:
*L'adresse de la case actuelle doit être dans A0
*Le retour "booléen" est retourner dans D3.B
*Pour qu'une case soit visitable, elle doit être entourée de mur et sa valeur à l'intérieur doit etre 4
    MOVE.L #0, D2
    MOVE LG_TAB, D2
    MOVE.L A0, A2 ;Sauvegarde de A0 initiale
    *On check la case du dessus
    SUB.L D2, A0
    CMP.B #1, (A0)
    BEQ HAUT1
    BRA DESSOUS
        HAUT1:
            SUB.L D2, A0
            CMP.B #4, (A0)
            BEQ HAUT2
            BRA DESSOUS
                HAUT2:
                    *Case du dessus visitable
                    MOVE.B #1, D3
                    MOVE.L A2, A0
                    BRA FINESTVISITABLE
                    
    *On check la case du dessous
    DESSOUS:
    MOVE.L A2, A0
    ADD.L D2, A0
    CMP.B #1, (A0)
    BEQ DESSOUS1
    BRA DROITEV
        DESSOUS1:
            ADD.L D2, A0
            CMP.B #4, (A0)
            BEQ DESSOUS2
            BRA DROITEV
                DESSOUS2:
                    MOVE.B #1, D3
                    MOVE.L A2, A0
                    BRA FINESTVISITABLE
    *On check la case de droite
    DROITEV:
    MOVE.L A2, A0
    ADD.L #1, A0
    CMP.B #1, (A0)
    BEQ DROITE1
    BRA GAUCHEV
        DROITE1:
            ADD.L #1, A0
            CMP.B #4, (A0)
            BEQ DROITE2
            BRA GAUCHEV
                DROITE2:
                    MOVE.B #1, D3
                    MOVE.L A2, A0
                    BRA FINESTVISITABLE
    *On check la case de gauche
    GAUCHEV:
    MOVE.L A2, A0
    SUB.L #1, A0
    CMP.B #1, (A0)
    BEQ GAUCHE1
    BRA FINESTVISITABLE
        GAUCHE1:
            SUB.L #1, A0
            CMP.B #4, (A0)
            BEQ GAUCHE2
            BRA FINESTVISITABLE
                GAUCHE2:
                    MOVE.B #1, D3
                    MOVE.L A2, A0
    FINESTVISITABLE:
    RTS
    
CLIQUESOURIS_MENU:
    MOVE.L #0, D0
    MOVE.L #0, D1 ;Registre pour récuperer coordonées clic gauche
    WHILECLICKNOTVAL:
        WHILENOCLICK:
            *GET_MOUSE
            MOVE #61, D0
            TRAP #15
            MOVE.L D1, D2
            MOVE.L #0, D1
            *Fin GET_MOUSE
            CMP.B #1, D0
            BNE WHILENOCLICK
        *Si clique
        MOVE.L D2, D1
        AND.L #$0000FFFF, D1 ;D1 = Coord X
        AND.L #$FFFF0000, D2
        SWAP D2              ;D2 = Coord Y
        ;Facile
            CMP #280, D1
            BGT FACILE1
            BRA MOYEN
            FACILE1:
                CMP #$149, D1
                BLT FACILE2
                BRA MOYEN
                    FACILE2:
                        CMP #99, D2
                        BGT FACILE3
                        BRA MOYEN
                            FACILE3:
                                CMP #$70, D2
                                BLT FACILE4
                                BRA MOYEN
                                    FACILE4:
                                        MOVE.B #1, CHOIX_MENU
                                        BRA FINCLIQUESOURIS
                
        MOYEN:
            CMP #$11D, D1
            BGT MOYEN1
            BRA DIFFICILE
            MOYEN1:
                CMP #$148, D1
                BLT MOYEN2
                BRA DIFFICILE
                    MOYEN2:
                        CMP #$98, D2
                        BGT MOYEN3
                        BRA DIFFICILE
                            MOYEN3:
                                CMP #$A5, D2
                                BLT MOYEN4
                                BRA DIFFICILE
                                    MOYEN4:
                                        MOVE.B #2, CHOIX_MENU
                                        BRA FINCLIQUESOURIS
        DIFFICILE:
        CMP #$10C, D1
            BGT DIFFICILE1
            BRA QUITTER
            DIFFICILE1:
                CMP #$156, D1
                BLT DIFFICILE2
                BRA QUITTER
                    DIFFICILE2:
                        CMP #$CA, D2
                        BGT DIFFICILE3
                        BRA QUITTER
                            DIFFICILE3:
                                CMP #$D7, D2
                                BLT DIFFICILE4
                                BRA QUITTER
                                    DIFFICILE4:
                                        MOVE.B #3, CHOIX_MENU
                                        BRA FINCLIQUESOURIS
                                        
        QUITTER:
        CMP #$116, D1
            BGT QUITTER1
            BRA WHILECLICKNOTVAL
            QUITTER1:
                CMP #$14E, D1
                BLT QUITTER2
                BRA WHILECLICKNOTVAL
                    QUITTER2:
                    CMP #$160, D2
                    BGT QUITTER3
                    BRA WHILECLICKNOTVAL
                        QUITTER3:
                        CMP #$16C, D2
                        BLT QUITTER4
                        BRA WHILECLICKNOTVAL
                            QUITTER4:
                                MOVE.B #4, CHOIX_MENU
    FINCLIQUESOURIS:
    RTS
        
        
    











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
