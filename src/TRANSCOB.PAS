{
Ce programme transforme les fichiers ASCII en fichiers textes aux formats
suivants:    - la premiŠre lettre de chaque mot est en majuscule (ou en minusc)
             - les suivantes sont en minuscules (ou en majusc suivant le choix)
             - les textes definis comme des commentaires en Turbo Pascal 4 sont
         ignor‚s et se retrouveront donc inchang‚s
             - les textes entre cottes: 'exemple' sont eux aussi ignor‚s.
}
Program Transcrit_Cobol;     { mise … jour : 09 - 02 - 1991 }
                             { version 2.0 du 1 - 1 - 1991 }
{
Auteur: Pr‚martin Patrick
Date: 22/08/1991.
Langage: Turbo Pascal 6.0
}

Uses
    Crt,
    Olf_Software,
    U_Aff_Chaine,
    U_Fenetre,
    U_Ger_Chaine,
    U_Sgf;

Const Num_Version   : String [3]  = '2.2';
      Date_Version  : String [10] = '09-02-1991';
      Ctrl_Z        : Char        = #$1A; { = 17 = caractŠre de fin de fichier }
      Touche_Return : Char        = #13;

Var Ligne_Fichier,          { contient la ligne modifi‚e au fur et … mesure }
    Fichier1,               { nom externe du fichier source                 }
    Fichier2,               { nom externe du fichier destination            }
    Fichier3   : String;    { nom du fichier source .BAK                    }
    Fic_Orig,               { nom interne du fichier source                 }
    Fic_Dest   : Text;      { nom interne du fichier destination            }
    Longueur_Ligne,         { longueur de la ligne modifi‚e                 }
    Type_Modif,             { type de modification … effectuer:
                                      0 - Borland;
                                      1 - MAJUSCULES;
                                      2 - minuscules
                            }
    Indice     : Integer;   { indice dans la ligne modifi‚e                 }
    Carcou     : Char;      { caractŠre courant                             }
    Fin_Fichier,            { indicateur de fin du fichier.                 }
    Comment,                { dans une chaine ou pas ?                      }
    Mot,                    { position: sur mot ou pas ?                    }
    Ecriture,               { affichage des modifications … l'‚cran ?       }
    Bug        : Boolean;   { arrˆt du programme en cas d'erreur sp‚ciale   }

Procedure Vide_Tampon_Clavier;
Var Carac : Char;
Begin { vide_tampon_clavier }
  While Keypressed Do
    Carac := Readkey
  {endwhile}
End; { vide_tampon_clavier }

Procedure Ask_Type_Modification;
Var Carac : Char;
Begin { ask_type_modification }
  Type_Cadre := 3;
  Window_Cadre_Bis (5, 19, 75, 23, White, Lightgray);
  Window_Titre ('Type de modifications', White, Black);
  Clrscr;
  Writeln ('1 - Type_Borland;');
  Writeln ('2 - MAJUSCULES;');
  Writeln ('3 - minuscules.');
  Vide_Tampon_Clavier;
  Repeat
    Gotoxy (1, 4);
    Clreol;
    Write ('Votre choix: ', Type_Modif+1);
    Carcou := Readkey;
  Until (Carcou In ['1', '2', '3', Touche_Return]);
  If (Carcou <> Touche_Return)
  Then
    Type_Modif := Ord (Carcou)-Ord ('1')
  {endif};
  Clear_Window
End; { ask_type_modification }

Procedure Ask_Fichier;
Begin { ask_fichier }
  Type_Cadre := 1;
  Window_Cadre_Bis (2, 20, 79, 23, Green, Black);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Repeat
    Write ('Nom du fichier … modifier: ');
    Readln (Fichier1)
  Until (Fichier1 <> '');
  Met_Extension (Fichier1, '.CBL', Fichier1);
  If Exist (Fichier1)
  Then { le fichier ‚xiste et est un fichier .CBL, on peut le modifier }
    Begin
      Assign (Fic_Orig, Fichier1);
      Reset (Fic_Orig);
      Met_Extension (Fichier1, '.$$$', Fichier2);
      Met_Extension (Fichier1, '.BAK', Fichier3);
      Writeln ('Modification de: ', Fichier1);
      Writeln ('Sauvegarde temporaire dans: ', Fichier2);
      Assign (Fic_Dest, Fichier2);
      Rewrite (Fic_Dest);
      Write ('Affichage du r‚sultat … l''‚cran ? (O/N) ');
      Repeat
        Vide_Tampon_Clavier;
        Carcou := Upcase (Readkey);
        Write (Carcou);
        Gotoxy (Pred (Wherex), Wherey);
        Clreol
      Until ((Carcou = 'O') Or (Carcou = 'N'));
      { Sortie en cas d'appuit sur O,o,N ou n. }
      Writeln;
      Ecriture := (Carcou = 'O');
      If Not (Ecriture)
      Then
        Writeln ('Veuillez patienter, je travaille...')
      {endif};
      Writeln
    End
  Else { le fichier n'‚xiste pas, on ne peut rien faire }
    Begin
      Writeln ('Ce fichier n''‚xiste pas.');
      Writeln ('V‚rifiez, puis revenez me voir...');
      Carcou := Readkey;
      Bug := True
    End
  {endif};
  Clear_Window
End; { ask_fichier }

Procedure Presentation;
Begin { presentation }
    Type_Cadre := 7;
    Window_Cadre_Bis (2, 2, 79, 13, Lightgray, Blue);
    Window_Titre ('Transcri version Cobol.', White+Blink, Red);
    Textcolor (Lightgray);
    Textbackground (Black);
    Clrscr;
    Affic_Center_Ln (Concat ('Version ', Num_Version, ' de Pr‚martin Patrick.'));
    Affic_Center_Ln (Concat ('› ', Date_Version));
    Writeln;
    Write   ('   Ce programme modifie les listings de code Cobol en sautant les commentaires');
    Writeln ('et les chaines entre guillemets "...".');
    Writeln;
    Writeln ('   Les modifications sont de trois types … choisir par l''utilisateur.');
    Writeln;
    Writeln ('   Ce programme est en Freeware, il ne peut ˆtre vendu.');
    Writeln;
    Write   ('   La version originale n''‚tait pas v‚rol‚e, essayez de faire de mˆme avec les');
    Write   ('copies ‚ventuelles...')
End; { presentation }

Procedure Initialisations;
Begin { initialisations }
  Mot := False;                       { Hors d'un mot au d‚but.         }
  Comment := False;                   { Hors d'un commentaire au d‚but. }
  Ecriture := False;
  Bug := False;
  Fin_Fichier := False;
  Fichier1 := '';
  Fichier2 := '';
  Fichier3 := '';
  Ligne_Fichier := '';
  Indice := 0;
  Longueur_Ligne := 0;
  Type_Modif := 1                     { en majuscules par d‚faut        }
End; { initialisations }

Procedure Init_Ecriture;
Begin { init_ecriture }
  If (Ecriture)
  Then
    Begin
      Case (Type_Modif) Of
        0 : Ligne_Fichier := 'Modifications de type Borland.';
        1 : Ligne_Fichier := 'Modification en majuscules.';
        2 : Ligne_Fichier := 'Modification en minuscules.'
      End;
      Type_Cadre := 7;
      Window_Cadre_Bis (1, 3, 80, 23, Black, White);
      Window_Titre (Ligne_Fichier, White, Red);
      Textbackground (Lightgray);
      Textcolor (Black);
      Clrscr
    End
  Else
    Begin
      Type_Cadre := 5;
      Window_Cadre_Bis (10, 20, 40, 20, Red, Green);
      Textcolor (White);
      Textbackground (Blue);
      Write ('Patience, travail en cours...');
      Clreol
    End
  {endif}
End; { init_ecriture }

Procedure Ecrit (Caractere:Char);
Begin { ecrit }
  Ligne_Fichier [Indice] := Caractere;
  If (((Indice >= Longueur_Ligne) Or (Indice > 71)) And (Not Fin_Fichier))
  Then
    Begin
      If (Ecriture)
      Then
        Writeln (Ligne_Fichier)
      {endif};
      Writeln (Fic_Dest, Ligne_Fichier)
    End
  {endif}
End; { ecrit }

Procedure Lecture;
Begin { lecture }
  If ((Indice >= Longueur_Ligne) Or (Indice > 71))
  Then
    Begin
      Fin_Fichier := Eof (Fic_Orig);
      If Not (Fin_Fichier)
      Then
        Begin
          Indice := 6;
          Mot := False;
          Readln (Fic_Orig, Ligne_Fichier);
          Longueur_Ligne := Length (Ligne_Fichier)
        End
      {endif}
    End
  {endif};
  Inc (Indice);
  Carcou := Ligne_Fichier [Indice]
End; { lecture }

Procedure Saute_Ligne;
Begin { saute_ligne }
  While ((Carcou = '*') And (Not Fin_Fichier)) Do
    Begin
      Indice := Pred (Longueur_Ligne);
      Lecture;
      Ecrit (Carcou);
      Lecture
    End
End; { saute_ligne }

Procedure Saute_Texte;
Begin { saute_texte }
  Comment := True;
  While ((Not Fin_Fichier) And (Comment) And (Indice < 72)) Do
    Begin
      Ecrit (Carcou);
      Lecture;
      Comment := (Not (Carcou = '"'))
    End
  {endwhile};
  Comment := False;
  Mot := False
End; { saute_texte }

Begin { transcrit_cobol }
  Init_Licence ('transcri');
  Init_Olf_Message (mess_freeware);
  Init_Olf_Software ('Transcrit Cobol '+Num_Version, #155' PREPAT '+Date_Version);
  Reset_Screen;
  Repeat
    Presentation;
    Initialisations;
    Ask_Type_Modification;
    Ask_Fichier;
{ D‚but de la cession de travail. }
    If Not (Bug)
    Then      { le fichier … modifier ‚xiste et est ouvert. }
      Begin
        Init_Ecriture;
{ traitement du fichier }
        Fin_Fichier := Eof (Fic_Orig);
        While Not Fin_Fichier Do
          Begin
            Lecture;
            If ((Carcou = '*') And (Indice = 7))
            Then
              Saute_Ligne
            {endif};
            If (Carcou = '"')
            Then
              Saute_Texte
            {endif};

            If Not (Mot)
            Then  { On n'est pas dans un mot. }
              Begin
                Mot:=(( Upcase (Carcou) >= 'A') And (Upcase (Carcou) <= 'Z'));
                Case (Type_Modif) Of
                  0, 1 : Ecrit (Upcase (Carcou));
                  2    : Ecrit (Downcase (Carcou))
                End
              End
            Else  { On est dans un mot. }
              Begin
                Mot:=(( Upcase (Carcou) >= 'A') And (Upcase (Carcou) <= 'Z'));
                Case (Type_Modif) Of
                  0, 2 : Ecrit (Downcase (Carcou));
                  1    : Ecrit (Upcase (Carcou))
                End
              End
            {endif}
          End
        {endwhile};
{ fin du traitement du fichier }
        Close (Fic_Orig); { fermeture du fichier de d‚part }
        Write (Fic_Dest, Ctrl_Z);
        Close (Fic_Dest); { fermeture du fichier destination }

        Clear_Window;
        Window (1, 20, 80, 24);
        Textbackground (Black);
        Textcolor (White);
        Clrscr;
        Writeln ('Transformation de ''', Fichier1, ''' en ''', Fichier3, '''.');
        Cree_Bak (Fichier1);
        Write ('Effacement de: ''', Fichier1, ''' pour le remplacer par ''');
        Writeln (Fichier2, '''.');
        Bug := Efface (Fichier1);
        Bug := Renomme (Fichier2, Fichier1);
        Writeln ('Fin des modifications sur: ', Fichier1, '.')
      End
    {endif};
{ Fin du processus de modification. }
    Type_Cadre := 7;
    Window_Cadre_Bis (2, 20, 79, 21, White, Blue);
    Textcolor (Lightgray);
    Textbackground (Black);
    Clrscr;
    Affic_Center ('Voulez-vous modifier un autre texte ? (Oui / Non) ');
    Repeat
      Carcou := Upcase (Readkey);
      Write (Carcou);
      Gotoxy (Pred (Wherex), Wherey)
    Until ((Carcou = 'O') Or (Carcou = 'N'))
  Until (Carcou = 'N');
  Reset_Screen
End. { transcrit_cobol }
