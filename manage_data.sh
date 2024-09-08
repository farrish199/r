#!/bin/bash

# Fail untuk menyimpan ID kumpulan auto-approve
AUTO_APPROVE_FILE="auto_approve_group_id.txt"

# Fail untuk menyimpan data pengguna
USER_DATA_FILE="user_data.json"

# Fungsi untuk menyimpan ID kumpulan auto-approve
save_auto_approve_group_id() {
    local group_id=$1
    echo "$group_id" > "$AUTO_APPROVE_FILE"
    echo "ID kumpulan auto-approve telah disimpan: $group_id"
}

# Fungsi untuk mendapatkan ID kumpulan auto-approve
get_auto_approve_group_id() {
    if [ -f "$AUTO_APPROVE_FILE" ]; then
        local group_id=$(cat "$AUTO_APPROVE_FILE")
        echo "$group_id"
    else
        echo "0"
    fi
}

# Fungsi untuk menyimpan data pengguna
save_user_data() {
    local user_id=$1
    local user_data=$(jq --arg user_id "$user_id" '.[$user_id] = {"user_id": $user_id}' "$USER_DATA_FILE" 2>/dev/null)
    if [ $? -ne 0 ]; then
        user_data=$(jq -n --arg user_id "$user_id" '{($user_id): {"user_id": $user_id}}')
    fi
    echo "$user_data" > "$USER_DATA_FILE"
    echo "Data pengguna telah disimpan: $user_id"
}

# Fungsi untuk memuatkan data pengguna
load_user_data() {
    local user_id=$1
    local user_data=$(jq -r --arg user_id "$user_id" '.[$user_id]' "$USER_DATA_FILE" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Tiada data untuk pengguna ID: $user_id"
    else
        echo "$user_data"
    fi
}

# Memeriksa pilihan dan menjalankan fungsi yang sesuai
case "$1" in
    save_auto_approve)
        save_auto_approve_group_id "$2"
        ;;
    get_auto_approve)
        get_auto_approve_group_id
        ;;
    save_user)
        save_user_data "$2"
        ;;
    load_user)
        load_user_data "$2"
        ;;
    *)
        echo "Pilihan tidak sah. Gunakan 'save_auto_approve', 'get_auto_approve', 'save_user', atau 'load_user'."
        ;;
esac
