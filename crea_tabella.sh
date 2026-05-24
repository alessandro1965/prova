#!/bin/bash

# Script per creare una tabella con il contenuto di una cartella
# Utilizzo: ./crea_tabella.sh <percorso_cartella>

# Controllo se è stato passato un argomento
if [ $# -eq 0 ]; then
    echo "Errore: Nessuna cartella specificata."
    echo "Utilizzo: $0 <percorso_cartella>"
    exit 1
fi

CARTELLA="$1"

# Controllo se la cartella esiste
if [ ! -d "$CARTELLA" ]; then
    echo "Errore: La cartella '$CARTELLA' non esiste."
    exit 1
fi

FILE_OUTPUT="tabella.txt"

# Creo l'intestazione della tabella
echo "+----------------------+------------+---------+" > "$FILE_OUTPUT"
echo "| Nome                 | Tipo       | Dimensione|" >> "$FILE_OUTPUT"
echo "+----------------------+------------+---------+" >> "$FILE_OUTPUT"

# Itero sui file nella cartella
for entry in "$CARTELLA"/*; do
    # Controllo se esistono file nella cartella
    if [ ! -e "$entry" ]; then
        continue
    fi
    
    # Ottengo il nome del file
    nome=$(basename "$entry")
    
    # Determino il tipo (directory o file)
    if [ -d "$entry" ]; then
        tipo="DIR"
        dimensione="-"
    else
        tipo="FILE"
        # Ottengo la dimensione in byte
        dimensione=$(stat -c%s "$entry" 2>/dev/null || stat -f%z "$entry" 2>/dev/null)
    fi
    
    # Tronco il nome se troppo lungo (max 22 caratteri per allineamento)
    if [ ${#nome} -gt 22 ]; then
        nome="${nome:0:19}..."
    fi
    
    # Formato la riga della tabella
    printf "| %-20s | %-10s | %7s |\n" "$nome" "$tipo" "$dimensione" >> "$FILE_OUTPUT"
done

# Chiudo la tabella
echo "+----------------------+------------+---------+" >> "$FILE_OUTPUT"

echo "Tabella creata con successo nel file '$FILE_OUTPUT'"
echo "Contenuto della cartella: $CARTELLA"
