FasdUAS 1.101.10   ��   ��    k             l   � ����  O    �  	  k   � 
 
     I   	������
�� .miscactv****      � ****��  ��        l  
 
��������  ��  ��        r   
     m   
    �      o      ���� 0 filecontents fileContents      r        4    �� 
�� 
alis  l    ����  l    ����  I   ��  
�� .earsffdralis        afdr   f      �� ��
�� 
rtyp  m    ��
�� 
ctxt��  ��  ��  ��  ��    o      ���� 0 
homeordner         l   �� ! "��   ! 0 *display dialog "homeordner: " & homeordner    " � # # T d i s p l a y   d i a l o g   " h o m e o r d n e r :   "   &   h o m e o r d n e r    $ % $ r      & ' & n     ( ) ( m    ��
�� 
ctnr ) o    ���� 0 
homeordner   ' o      ���� 0 homeordnerpfad   %  * + * l  ! !�� , -��   , 2 ,set main to file "datum.c" of homeordnerpfad    - � . . X s e t   m a i n   t o   f i l e   " d a t u m . c "   o f   h o m e o r d n e r p f a d +  / 0 / r   ! ( 1 2 1 b   ! & 3 4 3 l  ! $ 5���� 5 c   ! $ 6 7 6 o   ! "���� 0 homeordnerpfad   7 m   " #��
�� 
TEXT��  ��   4 m   $ % 8 8 � 9 9  d a t u m . c 2 o      ���� 0 filepfad   0  : ; : l  ) )�� < =��   < , &display dialog "filepfad: " & filepfad    = � > > L d i s p l a y   d i a l o g   " f i l e p f a d :   "   &   f i l e p f a d ;  ? @ ? l  ) )�� A B��   A ! tell application "TextEdit"    B � C C 6 t e l l   a p p l i c a t i o n   " T e x t E d i t " @  D E D I  ) .������
�� .miscactv****      � ****��  ��   E  F G F r   / = H I H l  / 9 J���� J I  / 9�� K L
�� .rdwropenshor       file K 4   / 3�� M
�� 
file M o   1 2���� 0 filepfad   L �� N��
�� 
perm N m   4 5��
�� boovtrue��  ��  ��   I o      ���� 0 refnum RefNum G  O P O Q   >� Q R S Q k   A� T T  U V U r   A J W X W l  A H Y���� Y I  A H�� Z��
�� .rdwrread****        **** Z o   A D���� 0 refnum RefNum��  ��  ��   X o      ���� 0 filecontents fileContents V  [ \ [ l  K K��������  ��  ��   \  ] ^ ] l  K K�� _ `��   _ 7 1display dialog "inhalt: " & return & fileContents    ` � a a b d i s p l a y   d i a l o g   " i n h a l t :   "   &   r e t u r n   &   f i l e C o n t e n t s ^  b c b r   K U d e d n   K Q f g f 4   L Q�� h
�� 
cpar h m   O P����  g o   K L���� 0 filecontents fileContents e o      ���� 0 datum Datum c  i j i l  V V�� k l��   k &  display dialog "Datum: " & Datum    l � m m @ d i s p l a y   d i a l o g   " D a t u m :   "   &   D a t u m j  n o n r   V _ p q p I  V [������
�� .misccurdldt    ��� null��  ��   q o      ���� 	0 heute   o  r s r l  ` `�� t u��   t &  display dialog "heute: " & heute    u � v v @ d i s p l a y   d i a l o g   " h e u t e :   "   &   h e u t e s  w x w r   ` k y z y n   ` g { | { 1   c g��
�� 
year | o   ` c���� 	0 heute   z o      ���� 0 jahrtext   x  } ~ } r   l w  �  n   l s � � � m   o s��
�� 
mnth � o   l o���� 	0 heute   � o      ���� 0 	monattext   ~  � � � l  x x�� � ���   � * $display dialog "monat: " & monattext    � � � � H d i s p l a y   d i a l o g   " m o n a t :   "   &   m o n a t t e x t �  � � � r   x � � � � n   x � � � � 7  � ��� � �
�� 
ctxt � m   � ������� � m   � ������� � l  x � ����� � b   x � � � � m   x { � � � � �  0 � n   { � � � � 1   ~ ���
�� 
day  � o   { ~���� 	0 heute  ��  ��   � o      ���� 0 tag   �  � � � l  � ��� � ���   � " display dialog "tag: " & tag    � � � � 8 d i s p l a y   d i a l o g   " t a g :   "   &   t a g �  � � � r   � � � � � J   � � � �  � � � m   � ���
�� 
jan  �  � � � m   � ���
�� 
feb  �  � � � m   � ���
�� 
mar  �  � � � l 	 � � ����� � m   � ���
�� 
apr ��  ��   �  � � � m   � ���
�� 
may  �  � � � m   � ���
�� 
jun  �  � � � m   � ���
�� 
jul  �  � � � m   � ���
�� 
aug  �  � � � l 	 � � ����� � m   � ���
�� 
sep ��  ��   �  � � � m   � ���
�� 
oct  �  � � � m   � ���
�� 
nov  �  ��� � m   � ���
�� 
dec ��   � o      ���� 0 monatsliste MonatsListe �  � � � Y   � � ��� � ��� � Z   � � � ����� � =   � � � � � o   � ����� 0 	monattext   � n   � � � � � 4   � ��� �
�� 
cobj � o   � ����� 0 i   � o   � ����� 0 monatsliste MonatsListe � k   � � � �  � � � r   � � � � � n   � � � � � 7  � ��� � �
�� 
ctxt � m   � ������� � m   � ������� � l  � � ����� � b   � � � � � m   � � � � � � �  0 � o   � ����� 0 i  ��  ��   � o      ���� 	0 monat   �  ��� � l  � � � � � �  S   � � � - ' wenn true, wird die Schleife verlassen    � � � � N   w e n n   t r u e ,   w i r d   d i e   S c h l e i f e   v e r l a s s e n��  ��  ��  �� 0 i   � m   � �����  � m   � ����� ��   �  � � � l  � ��� � ���   � &  display dialog "monat: " & monat    � � � � @ d i s p l a y   d i a l o g   " m o n a t :   "   &   m o n a t �  � � � r   � � � � l 	 � ����� � l  � ����� � n  � � � � 7 �� � �
�� 
cha  � m  
����  � m  ����  � l  � ����� � c   � � � � o   � ���� 0 jahrtext   � m   ��
�� 
ctxt��  ��  ��  ��  ��  ��   � o      �� 0 jahr   �  � � � l �~ � ��~   � ? 9display dialog "jahr: " & jahr & " jahrtext: " & jahrtext    � � � � r d i s p l a y   d i a l o g   " j a h r :   "   &   j a h r   &   "   j a h r t e x t :   "   &   j a h r t e x t �  � � � r  $ � � � n    � � � m   �}
�} 
nmbr � n   � � � 2 �|
�| 
cha  � o  �{�{ 0 datum Datum � o      �z�z 0 l   �  � � � l %%�y � ��y   � 1 +set neuesDatum to text -l thru -13 of Datum    � � � � V s e t   n e u e s D a t u m   t o   t e x t   - l   t h r u   - 1 3   o f   D a t u m �  � � � l %8 �  � r  %8 n  %4 7 (4�x
�x 
ctxt m  ,.�w�w  m  /3�v�v  o  %(�u�u 0 datum Datum o      �t�t 0 
neuesdatum 
neuesDatum  $  Anfang bis und mit Leerschlag    � <   A n f a n g   b i s   u n d   m i t   L e e r s c h l a g � 	
	 r  9T b  9P b  9L b  9H b  9D b  9@ o  9<�s�s 0 
neuesdatum 
neuesDatum o  <?�r�r 0 tag   m  @C �  . o  DG�q�q 	0 monat   m  HK �  . o  LO�p�p 0 jahrtext   o      �o�o 0 
neuesdatum 
neuesDatum
  l UU�n�n   0 *display dialog "neuesDatum: " & neuesDatum    � T d i s p l a y   d i a l o g   " n e u e s D a t u m :   "   &   n e u e s D a t u m  !  r  Ug"#" b  Uc$%$ b  U_&'& n  U[()( 4  V[�m*
�m 
cpar* m  YZ�l�l ) o  UV�k�k 0 filecontents fileContents' o  [^�j
�j 
ret % o  _b�i�i 0 
neuesdatum 
neuesDatum# o      �h�h 0 	neuertext 	neuerText! +,+ l hh�g-.�g  - 3 -set paragraph 2 of fileContents to neuesDatum   . �// Z s e t   p a r a g r a p h   2   o f   f i l e C o n t e n t s   t o   n e u e s D a t u m, 010 I hw�f2�e
�f .sysodlogaskr        TEXT2 b  hs343 b  ho565 m  hk77 �88  n e u e r T e x t :  6 o  kn�d
�d 
ret 4 o  or�c�c 0 	neuertext 	neuerText�e  1 9:9 I x��b;<
�b .rdwrseofnull���     ****; o  x{�a�a 0 refnum RefNum< �`=�_
�` 
set2= m  ~�^�^  �_  : >?> I ���]@A
�] .rdwrwritnull���     ****@ o  ���\�\ 0 	neuertext 	neuerTextA �[B�Z
�[ 
refnB o  ���Y�Y 0 refnum RefNum�Z  ? C�XC I ���WD�V
�W .rdwrclosnull���     ****D o  ���U�U 0 refnum RefNum�V  �X   R R      �T�S�R
�T .ascrerr ****      � ****�S  �R   S I ���QE�P
�Q .rdwrclosnull���     ****E o  ���O�O 0 refnum RefNum�P   P F�NF l ���M�L�K�M  �L  �K  �N   	 m     GG�                                                                                  MACS   alis    r  Macintosh HD               ŕ��H+     u
Finder.app                                                       v��R�u        ����  	                CoreServices    ŕt�      �Rve       u   1   0  3Macintosh HD:System:Library:CoreServices:Finder.app    
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��  ��  ��    H�JH l     �I�H�G�I  �H  �G  �J       �FIJ�F  I �E
�E .aevtoappnull  �   � ****J �DK�C�BLM�A
�D .aevtoappnull  �   � ****K k    �NN  �@�@  �C  �B  L �?�? 0 i  M DG�> �=�<�;�:�9�8�7�6�5 8�4�3�2�1�0�/�.�-�,�+�*�)�(�' ��&�%�$�#�"�!� ����������� �����������7�
�	������
�> .miscactv****      � ****�= 0 filecontents fileContents
�< 
alis
�; 
rtyp
�: 
ctxt
�9 .earsffdralis        afdr�8 0 
homeordner  
�7 
ctnr�6 0 homeordnerpfad  
�5 
TEXT�4 0 filepfad  
�3 
file
�2 
perm
�1 .rdwropenshor       file�0 0 refnum RefNum
�/ .rdwrread****        ****
�. 
cpar�- 0 datum Datum
�, .misccurdldt    ��� null�+ 	0 heute  
�* 
year�) 0 jahrtext  
�( 
mnth�' 0 	monattext  
�& 
day �%���$ 0 tag  
�# 
jan 
�" 
feb 
�! 
mar 
�  
apr 
� 
may 
� 
jun 
� 
jul 
� 
aug 
� 
sep 
� 
oct 
� 
nov 
� 
dec � � 0 monatsliste MonatsListe
� 
cobj� 	0 monat  
� 
cha � � 0 jahr  
� 
nmbr� 0 l  � � 0 
neuesdatum 
neuesDatum
� 
ret � 0 	neuertext 	neuerText
�
 .sysodlogaskr        TEXT
�	 
set2
� .rdwrseofnull���     ****
� 
refn
� .rdwrwritnull���     ****
� .rdwrclosnull���     ****�  �  �A���*j O�E�O*�)��l /E�O��,E�O��&�%E�O*j O*��/�el E` O]_ j E�O�a l/E` O*j E` O_ a ,E` O_ a ,E` Oa _ a ,%[�\[Za \Zi2E` Oa a  a !a "a #a $a %a &a 'a (a )a *a +vE` ,O :ka +kh  _ _ ,a -�/  a .�%[�\[Za \Zi2E` /OY h[OY��O_ �&[a 0\[Zm\Za 12E` 2O_ a 0-a 3,E` 4O_ [�\[Zk\Za 52E` 6O_ 6_ %a 7%_ /%a 8%_ %E` 6O�a k/_ 9%_ 6%E` :Oa ;_ 9%_ :%j <O_ a =jl >O_ :a ?_ l @O_ j AW X B C_ j AOPU ascr  ��ޭ