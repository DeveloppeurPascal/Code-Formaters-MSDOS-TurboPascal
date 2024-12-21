Program Transcrit_Pascal;    { Version 1.7 dat‚e du 09/03/1991 }
{
Auteur: Pr‚martin Patrick.
Date: 1.6 dat‚e du 29/12/1990.
      1.7 dat‚e du 09/03/1991.
Langage: Turbo Pascal 4.0
      22/08/1991.
Langage: Turbo Pascal 6.0

Ce programme transforme les fichiers ASCII en fichiers textes aux formats
suivants:    - la premiŠre lettre de chaque mot est en majuscule (ou en minusc)
             - les suivantes sont en minuscules (ou en majusc suivant le choix)
             - les textes definis comme des commentaires en Turbo Pascal 4 sont
         ignor‚s et se retrouveront donc inchang‚s
             - les textes entre cottes: 'exemple' sont eux aussi ignor‚s.
}

Uses
    Crt,
    Dos,
    Olf_Software,
    U_Aff_Chaine,
    U_Fenetre,
    U_Ger_Chaine,
    U_Sgf;

Const Num_Version   : String [3]  = '1.7';
      Date_Version  : String [10] = '09/03/1991';
      Ctrl_Z        : Char        = #$1A; { = 17 = caractŠre de fin de fichier }
      Touche_Return : Char        = #13;

Type T_Tab_Fichier = Array [0..100] Of String [12];

Var Ligne_Fichier,          { contient la ligne modifi‚e au fur et … mesure }
    Fichier1,               { nom externe du fichier source }
    Fichier2,               { nom externe du fichier destination }
    Fichier3   : String;    { nom du fichier source .BAK }
    T_Fichier  : Searchrec; { nom global pour recherche du fichier … modifier. }
    Fic_Orig,               { nom interne du fichier source }
    Fic_Dest   : Text;      { nom interne du fichier destination }
    Longueur_Ligne,         { longueur de la ligne modifi‚e }
    Type_Modif,             { type de modification … effectuer:
                                      0 - Borland;
                                      1 - MAJUSCULES;
                                      2 - minuscules
                            }
    Indice     :Integer;    { indice dans la ligne modifi‚e }
    Carcou     : Char;      { caractŠre courant }
    Fin_Fichier,            { indicateur de fin du fichier. }
    Mot,                    { position: sur mot ou pas ? }
    Comment,                {           dans commentaire, chaine ou pas ? }
    Ecriture,               { affichage des modifications … l'‚cran ? }
    Bug        : Boolean;   { arrˆt du programme en cas d'erreur sp‚ciale }
    Tab_Fichier : T_Tab_Fichier;
    Nb_Fichier,
    Num_Fichier : Integer;

{ Cette proc‚dure vide le buffer du clavier. }
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

Procedure Enreg_Fichier;
Begin { enreg_fichier }
  For Nb_Fichier := 0 To 100 Do
    Tab_Fichier [Nb_Fichier] := ''
  {endfor};
  Num_Fichier := 1;
  Nb_Fichier := 0;
  Findfirst (Fichier1, Anyfile, T_Fichier);
  While Not ((T_Fichier.Name = Tab_Fichier [Nb_Fichier]) Or (Nb_Fichier = 100)) Do
    Begin
      Inc (Nb_Fichier);
      Tab_Fichier [Nb_Fichier] := T_Fichier.Name;
      Findnext (T_Fichier)
    End
  {endhwile};
  Fichier1 := Tab_Fichier [Num_Fichier]
End; { enreg_fichier }

{ Cette proc‚dure s'enquiert du nom de fichier  '.PAS' … modifier. }
Procedure Ask_Fichier;
Begin { ask_fichier }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 20, 79, 23, Green, Black);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Repeat
    Write ('Nom du fichier … modifier: ');
    Readln (Fichier1)
  Until (Fichier1 <> '');
  Met_Extension (Fichier1, '.PAS', Fichier1);
  Enreg_Fichier;
  If Exist (Fichier1)
  Then { le fichier ‚xiste et est un fichier .PAS, on peut le modifier }
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

{ Utilisation des jokers pour les instructions FINDFIRST et FINDNEXT. }
Procedure Fichier_Suivant;
Begin { fichier_suivant }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 20, 79, 23, Green, Black);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Inc (Num_Fichier);
  If ((Num_Fichier > Nb_Fichier) Or (Fichier1 = Tab_Fichier [Num_Fichier]))
  Then
    Bug := True
  Else
    Begin
      Bug := False;
      Fichier1 := Tab_Fichier [Num_Fichier]
    End
  {endif};
  If (Exist (Fichier1) And (Fichier1 <> '') And Not Bug)
  Then { le fichier ‚xiste et est un fichier .PAS, on peut le modifier }
    Begin
      Assign (Fic_Orig, Fichier1);
      Reset (Fic_Orig);
      Met_Extension (Fichier1, '.$$$', Fichier2);
      Met_Extension (Fichier1, '.BAK', Fichier3);
      Writeln ('Modification de: ', Fichier1);
      Writeln ('Sauvegarde temporaire dans: ', Fichier2);
      Assign (Fic_Dest, Fichier2);
      Rewrite (Fic_Dest);
      If Not (Ecriture)
      Then
        Writeln ('Veuillez patienter, je travaille...')
      {endif};
      Writeln
    End
  Else
    Bug := True
  {endif}
End; { fichier_suivant }

{ Cette proc‚dure ecrit les caractŠres dans le fichier, et … l'ecran. }
Procedure Ecrit (Caractere:Char);
Begin { ecrit }
  Ligne_Fichier [Indice] := Caractere;
  If ((Indice >= Longueur_Ligne) And (Not Fin_Fichier))
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

{ Cette proc‚dure lit un caractŠre et donne son code ASCII. }
Procedure Lecture;
Begin { lecture }
  If (Indice >= Longueur_Ligne)
  Then
    Begin
      Repeat
        Fin_Fichier := Eof (Fic_Orig);
        If Not (Fin_Fichier)
        Then
          Begin
            Indice := 0;
            Mot := False;
            Readln (Fic_Orig, Ligne_Fichier);
            Longueur_Ligne := Length (Ligne_Fichier);
            If (Longueur_Ligne < 1)
            Then
              Ecrit (#0)
            {endif}
          End
        {endif}
      Until (Fin_Fichier Or (Longueur_Ligne > 0))
    End
  {endif};
  Inc (Indice);
  Carcou := Ligne_Fichier [Indice]
End; { lecture }

{ Cette proc‚dure saute les commentaires entre (* ... *). }
Procedure Saute_Commentaires_Parentheses;

  { Cette proc‚dure teste si c'est un d‚but de commentaire. }
  Procedure Test_Comment_Open;
  Begin { test_comment_open }
    Ecrit (Carcou);
    Lecture;
    Comment := (Carcou = '*')
  End; { test_comment_open }

  { Cette proc‚dure teste si c'est une fin de commentaire. }
  Procedure Test_Comment_Close;
  Begin { test_comment_close }
    Ecrit (Carcou);
    Lecture;
    Comment := Not (Carcou = ')')
  End; { test_comment_close }

Begin { saute_commentaires_parentheses }
  Test_Comment_Open;
  While ((Not Fin_Fichier) And (Comment)) Do
    Begin
      Ecrit (Carcou);
      Lecture;
      If (Carcou = '*')
      Then
        Test_Comment_Close
      {endif}
    End
  {endwhile};
  Mot := False
End; { saute_commentaires_parentheses }

{ Cette proc‚dure saute les commentaires entre accolades. }
Procedure Saute_Commentaires_Accolades;
Begin { saute_commentaires_accolades }
  Comment := True;
  While ((Not Fin_Fichier) And (Comment)) Do
    Begin
      Ecrit (Carcou);
      Lecture;
      Comment := (Not (Carcou = '}'))
    End
  {endwhile};
  Mot := False
End; { saute_commentaires_accolades }

{ Cette proc‚dure saute les textes entre cottes. }
Procedure Saute_Texte;
Begin { saute_texte }
  Comment := True;
  While ((Not Fin_Fichier) And (Comment)) Do
    Begin
      Ecrit (Carcou);
      Lecture;
      Comment := (Not (Carcou = ''''))
    End
  {endwhile};
  Mot := False
End; { saute_texte }

Procedure Presentation;
Begin { presentation }
  Reset_Screen;
  Type_Cadre := 7;
  Window_Fond_Cadre_Bis (2, 2, 79, 13, Brown, Red, Blue);
  Window_Titre ('Transcrit version Turbo Pascal.', Black, Blue);
  Textcolor (Black);
  Textbackground (Brown);
  Affic_Center_Ln ('Auteur: Patrick Pr‚martin.');
  Affic_Center_Ln (Concat ('Date: ', Date_Version));
  Affic_Center_Ln (Concat ('Version: ', Num_Version));
  Writeln;
  Writeln ('    Ce programme permet de modifier les fichiers textes d''extension .PAS.');
  Writeln ('Vous allez ainsi pouvoir taper vos listings en Pascal comme vous voudrez');
  Writeln ('et ensuite, vous les passerez … ce programme. Il se chargera de modifier');
  Writeln ('leur typographie.');
  Writeln;
  Writeln ('    Vous avez le choix entre trois types d''‚critures, le fichier sera');
  Writeln ('modifi‚ dans sa totalit‚ (sauf les commentaires {...} (*...*), et les chaines');
  Write   ('entre cottes ''...''.');
End; { presentation }

Procedure Initialisations;
Begin { initialisations }
  Mot := False;                       { Hors d'un mot au d‚but. }
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
  Type_Modif := 0
End; { initialisations }

Procedure Travail_En_Cours;
Begin { travail_en_cours }
  Presentation;
  Type_Cadre := 5;
  Window_Cadre_Bis (10, 20, 40, 21, Red, Green);
  Textcolor (White);
  Textbackground (Blue);
  Writeln ('Patience, travail en cours...');
  Write   ('Sur: ', Fichier1)
End; { travail_en_cours }


{
Corps du Programme.
}
Begin { transcrit_pascal }
  Init_Licence ('transcri');
  Init_Olf_Message (mess_freeware);
  Init_Olf_Software ('Transcrit Pascal '+Num_Version, #155' PREPAT '+Date_Version);
  Repeat
    Presentation;
    Initialisations;
    Ask_Type_Modification;
    Ask_Fichier;

    Repeat
{ D‚but de la cession de travail. }
      If Not (Bug)
      Then      { le fichier … modifier ‚xiste et est ouvert. }
        Begin
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
              Window_Cadre_Bis (1, 4, 80, 23, Black, White);
              Window_Titre (Concat ('Fichier: ', Fichier1), White, Red);
              Textbackground (Lightgray);
              Textcolor (Black);
              Clrscr
            End
          Else
            Travail_En_Cours
          {endif};
{ traitement du fichier }
          Fin_Fichier := Eof (Fic_Orig);
          While Not Fin_Fichier Do
            Begin
              Lecture;
              If (Carcou = '(')
              Then
                Saute_Commentaires_Parentheses
              {endif};
              If (Carcou = '{')
              Then
                Saute_Commentaires_Accolades
              {endif};
              If (Carcou = '''')
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
      { else no instruction if bug }
      {endif};
      Fichier_Suivant
    Until (Bug);

{ Fin du processus de modification. }
    Window (1, 25, 80, 25);
    Textbackground (Black);
    Textcolor (White);
    Gotoxy (1, 1);
    Clreol;
    Write ('Voulez-vous modifier un autre texte ? (O/N)');
    Repeat
      Carcou := Upcase (Readkey)
    Until ((Carcou = 'O') Or (Carcou = 'N'))
  Until (Carcou = 'N');
  Window (1, 1, 80, 25);
  Clrscr
End. { transcrit_pascal }
