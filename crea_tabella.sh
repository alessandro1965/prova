#!/bin/bash

# Controlla se è stato fornito un argomento, altrimenti usa la cartella corrente
if [ $# -eq 0 ]; then
    directory="."
else
    directory="$1"
fi

output_file="tabella.txt"

# Controlla se la directory esiste
if [ ! -d "$directory" ]; then
    echo "Errore: La directory '$directory' non esiste."
    exit 1
fi

# Rilevamento del sistema operativo per il comando stat
if stat --version &>/dev/null; then
    # Linux
    GET_SIZE="stat -c %s"
    GET_DATE="stat -c %w" 
    SYSTEM="LINUX"
else
    # macOS / BSD
    GET_SIZE="stat -f %z"
    GET_DATE="stat -f %SB"
    SYSTEM="MAC"
fi

# Funzione per formattare la data
format_date() {
    local raw_date="$1"
    if [ "$raw_date" == "-" ] || [ -z "$raw_date" ]; then
        echo "N/D"
    else
        echo "${raw_date:0:19}"
    fi
}

# Scrive l'intestazione della tabella
{
    printf "+%-22s+%-8s+%-12s+%-20s+\n" "$(printf '=%.0s' {1..22})" "$(printf '=%.0s' {1..8})" "$(printf '=%.0s' {1..12})" "$(printf '=%.0s' {1..20})"
    printf "| %-20s | %-6s | %10s | %-18s |\n" "Nome" "Tipo" "Dimensione" "Data Creazione"
    printf "+%-22s+%-8s+%-12s+%-20s+\n" "$(printf '=%.0s' {1..22})" "$(printf '=%.0s' {1..8})" "$(printf '=%.0s' {1..12})" "$(printf '=%.0s' {1..20})"
} > "$output_file"

# Ciclo attraverso i file
shopt -s nullglob
for item in "$directory"/*; do
    name=$(basename "$item")
    
    if [ ${#name} -gt 20 ]; then
        display_name="${name:0:17}..."
    else
        display_name="$name"
    fi
    
    if [ -d "$item" ]; then
        tipo="DIR"
        size="-"
        date_created="-"
    elif [ -f "$item" ]; then
        tipo="FILE"
        size=$($GET_SIZE "$item" 2>/dev/null)
        raw_date=$($GET_DATE "$item" 2>/dev/null)
        
        if [ "$SYSTEM" == "LINUX" ] && ([ "$raw_date" == "-" ] || [ -z "$raw_date" ]); then
            raw_date=$(stat -c %y "$item" 2>/dev/null)
        fi
        
        date_created=$(format_date "$raw_date")
        
        if [ -z "$size" ]; then size="?"; fi
    else
        tipo="ALTRO"
        size="?"
        date_created="?"
    fi
    
    printf "| %-20s | %-6s | %10s | %-18s |\n" "$display_name" "$tipo" "$size" "$date_created" >> "$output_file"
done

printf "+%-22s+%-8s+%-12s+%-20s+\n" "$(printf '=%.0s' {1..22})" "$(printf '=%.0s' {1..8})" "$(printf '=%.0s' {1..12})" "$(printf '=%.0s' {1..20})" >> "$output_file"

echo "Tabella creata con successo in '$output_file'"
