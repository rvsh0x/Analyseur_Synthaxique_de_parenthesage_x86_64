#============================================================
# PROJET PROGRAMMATION ASSEMBLEUR
#
# GHODBANE RACHID  
#
# Ce programme vérifie si la chaîne d'arguments passées en entrée contient des paires valides de parenthèses, elles même passées en entrée.
#
# Entrées du programme : 
#   n paires de parenthèses + la chaine de caractere à analyser
# 
# Résultats du programme sont affichés en fonction des cas :
#
#   "NON" si :
#   - Trop de parenthèses fermantes
#   - Trop de parenthèses ouvrantes
#   - Parenthèses mal appariées
#
#   "OUI" sinon.
#
#============================================================

.data
    message_usage:        .string "Il faut au moins 2 arguments !\n"
    message_non:         .string "\nAnalyse : NON, mauvais parenthesage\n\n"
    message_oui:          .string "\nAnalyse : OUI\n"
    


.text
.global _start

#======================
# Sous-programme : Affiche une chaîne de caractères.
#======================
affiche_chaine:
    xor %rdx, %rdx        # RDX = 0 (compteur de longueur)
    mov %rsi, %rbx        # Charger adresse chaîne dans RBX
boucle_affichage:
    movb (%rbx), %al      # Charger un octet
    test %al, %al         # Fin de chaîne ?
    jz fin_affichage
    inc %rdx              # Longueur++
    inc %rbx
    jmp boucle_affichage

fin_affichage:
    mov $1, %rax          # write
    mov $1, %rdi
    syscall
    jmp fin_programme

#======================
# Sous-programme : usage
#======================
usage:
    mov $message_usage, %rsi
    call affiche_chaine
    jmp fin_programme


#======================
# Sous-programme : Parcours de chaine et vérification des parenthèses
#======================

initialisation_des_registres:
    xor %rax, %rax          # Indicateur de correspondance (0 pour NON, 1 pour OUI)
    xor %rbp, %rbp          # Pointeur de pile
    xor %r12, %r12
    push %rbp               # Initialiser la pile

charger_texte:
    xor %r8, %r8                 # remettre a zero r8
    mov (%r15, %r14, 8), %r8   # Charger l'adresse de la chaîne de texte à analyser dans R8

charger_parenthese:
    xor %r11, %r11              # remettre a zero r11
    mov (%r15, %r13, 8), %r11   # Charger l'adresse de la paire de parenthese courante dans R11
    jmp parcourt_chaine

parcourt_chaine:
    movb (%r8), %al            # Charger un caractère
    test %al, %al              # Fin de chaîne ?
    jz fin_verif
    jmp parcourt_parenthese

empiler_parenthese:
    push (%r11)
    inc %r12                #compteur de pile
    
    jmp caractere_suivant

depiler_parenthese:
    dec %r11                #reviens sur la parenthèse ouvrante correspondant a l a fermante rencontrée
    movb (%rsp), %al       #charger la derniere parenthèse ouvrante empilée au sommet de la pile
    cmpb (%r11), %al       #compare la parenthèse ouvrante au sommet de la pile avec la parenthèse ouvrante correspondante
    jne erreur
    pop %rbp               #retire la parenthèse ouvrante du sommet de la pile si bon appariement  
    dec %r12
    jmp caractere_suivant

parcourt_parenthese:
    cmpb (%r11), %al             # Si parenthese ouvrante
    je empiler_parenthese
    inc %r11
    cmpb (%r11), %al             # Si parenthese fermante
    je depiler_parenthese
    dec %r11
    jmp parenthese_suivant


parenthese_suivant:
    inc %r13
    cmp %r14, %r13
    jne charger_parenthese
    jmp caractere_suivant

caractere_suivant:
    xor %r13, %r13          
    mov $1, %r13               # remettre a zero l'indice de parcours des parenthèses
    inc %r8                    # Passer au caractère suivant 
    jmp parcourt_chaine



fin_verif:
    cmp $0, %r12              # Les compteurs doivent être égaux
    je fin_valide
    jmp erreur


fin_valide:
    mov $message_oui, %rsi
    call affiche_chaine
    jmp fin_programme

erreur:
    mov $message_non, %rsi
    call affiche_chaine

#======================
# Point d'entrée principal
#======================
_start:
    mov %rsp, %r15             # Charger le pointeur de pile dans %r15

    movq (%r15), %rbx          # Charger le nombre d'arguments
    cmp $3, %rbx               # Vérifier qu'il y a au moins 2 arguments
    jl usage                   # Sinon afficher le message d'usage

    movq %rbx, %r14            # Sauvegarder le nombre d'arguments
    xor %r9, %r9               # Nombre de parenthèses stockées
    xor %r10, %r10             # indice de parcours du texte
    mov $1, %r13               # indice de parcours des parenthèses
    call initialisation_des_registres   # Appeler la vérification des parenthèses

fin_programme:
    mov $60, %rax              # Exit
    xor %rdi, %rdi
    syscall


