#!/bin/bash

# Gantikan dengan token bot anda
BOT_TOKEN="${7483230333:AAG04p0WSD7n3B9doqfgMVfPpBxgj1JQ8s4}"
API_URL="https://api.telegram.org/bot${BOT_TOKEN}"

# Fail untuk menyimpan ID kumpulan auto-approve
AUTO_APPROVE_FILE="auto_approve_group_id.txt"
# Fail untuk menyimpan data pengguna
USER_DATA_FILE="user_data.json"

# Hantar mesej ke chat
hantar_mesej() {
    local chat_id="$1"
    local teks="$2"
    curl -s -X POST "${API_URL}/sendMessage" -d "chat_id=${chat_id}&text=${teks}"
}

# Hantar foto ke chat
hantar_foto() {
    local chat_id="$1"
    local foto="$2"
    curl -s -X POST "${API_URL}/sendPhoto" -F "chat_id=${chat_id}" -F "photo=@${foto}"
}

# Hantar dokumen ke chat
hantar_dokumen() {
    local chat_id="$1"
    local dokumen="$2"
    curl -s -X POST "${API_URL}/sendDocument" -F "chat_id=${chat_id}" -F "document=@${dokumen}"
}

# Dapatkan kemas kini dari bot
dapatkan_kemas_kini() {
    curl -s -X GET "${API_URL}/getUpdates"
}

# Simpan ID kumpulan auto-approve ke fail
simpan_auto_approve() {
    local group_id="$1"
    echo "$group_id" > "$AUTO_APPROVE_FILE"
}

# Dapatkan ID kumpulan auto-approve dari fail
dapatkan_auto_approve() {
    if [ -f "$AUTO_APPROVE_FILE" ]; then
        cat "$AUTO_APPROVE_FILE"
    else
        echo "0"
    fi
}

# Simpan data pengguna ke dalam fail JSON
simpan_data_pengguna() {
    local user_id="$1"
    if [ ! -f "$USER_DATA_FILE" ]; then
        echo "{}" > "$USER_DATA_FILE"
    fi
    jq --arg user_id "$user_id" '. + {($user_id): {"user_id": ($user_id | tonumber)}}' "$USER_DATA_FILE" > tmp.$$.json && mv tmp.$$.json "$USER_DATA_FILE"
}

# Tangani ahli chat baru
tangani_ahli_baru() {
    local chat_id="$1"
    local user_id="$2"
    local bot_id

    # Dapatkan ID bot
    bot_id=$(curl -s -X GET "${API_URL}/getMe" | jq -r '.result.id')

    if [ "$user_id" == "$bot_id" ]; then
        simpan_auto_approve "$chat_id"
        hantar_mesej "$chat_id" "Auto Approve kini diaktifkan untuk kumpulan ini."
    fi

    local auto_approve_id
    auto_approve_id=$(dapatkan_auto_approve)

    if [ "$auto_approve_id" != "0" ] && [ "$chat_id" == "$auto_approve_id" ]; then
        # Hantar permintaan kelulusan
        curl -s -X POST "${API_URL}/approveChatJoinRequest" -d "chat_id=${chat_id}&user_id=${user_id}"
    fi
}

# Tangani mesej /start
tangani_perintah_start() {
    local chat_id="$1"
    local user_id="$2"

    simpan_data_pengguna "$user_id"

    local markup
    markup=$(jq -n \
        --arg cb1 "service" --arg cb2 "dev_bot" --arg cb3 "support_bot" --arg cb4 "clone_bot" \
        '{keyboard: [[{text: "Service", callback_data: $cb1}, {text: "Dev Bot", callback_data: $cb2}], [{text: "Support Bot", callback_data: $cb3}, {text: "Clone Bot", callback_data: $cb4}]], one_time_keyboard: true}' | jq -c '.')

    hantar_mesej "$chat_id" "Selamat datang! Sila pilih pilihan dari menu di bawah:&reply_markup=${markup}"
}

# Tunjukkan submenu perkhidmatan
tunjukkan_submenu_perkhidmatan() {
    local chat_id="$1"
    local markup
    markup=$(jq -n \
        --arg cb1 "free_version" --arg cb2 "premium_version" \
        '{keyboard: [[{text: "Free Version", callback_data: $cb1}], [{text: "Premium Version", callback_data: $cb2}]], one_time_keyboard: true}' | jq -c '.')

    hantar_mesej "$chat_id" "Sila pilih pilihan dari perkhidmatan di bawah:&reply_markup=${markup}"
}

# Tunjukkan submenu versi
tunjukkan_submenu_versi() {
    local chat_id="$1"
    local version_type="$2"
    local markup
    markup=$(jq -n \
        --arg cb1 "${version_type}_convert" --arg cb2 "${version_type}_broadcast" --arg cb3 "${version_type}_auto_approve" --arg cb4 "${version_type}_downloader" --arg cb5 "${version_type}_chatgpt" \
        '{keyboard: [[{text: "Convert", callback_data: $cb1}], [{text: "Broadcast", callback_data: $cb2}], [{text: "Auto Approve", callback_data: $cb3}], [{text: "Downloader", callback_data: $cb4}], [{text: "ChatGPT", callback_data: $cb5}]], one_time_keyboard: true}' | jq -c '.')

    hantar_mesej "$chat_id" "Sila pilih pilihan untuk ${version_type}:&reply_markup=${markup}"
}

# Tunjukkan submenu downloader
tunjukkan_submenu_downloader() {
    local chat_id="$1"
    local version_type="$2"
    local markup
    markup=$(jq -n \
        --arg cb1 "${version_type}_fb" --arg cb2 "${version_type}_ig" --arg cb3 "${version_type}_tg" --arg cb4 "${version_type}_tt" --arg cb5 "${version_type}_yt" \
        '{keyboard: [[{text: "FB", callback_data: $cb1}], [{text: "IG", callback_data: $cb2}], [{text: "TG", callback_data: $cb3}], [{text: "TT", callback_data: $cb4}], [{text: "YT", callback_data: $cb5}]], one_time_keyboard: true}' | jq -c '.')

    hantar_mesej "$chat_id" "Sila pilih pilihan untuk ${version_type} Downloader:&reply_markup=${markup}"
}

# Tunjukkan submenu convert
tunjukkan_submenu_convert() {
    local chat_id="$1"
    local markup
    markup=$(jq -n \
        --arg cb1 "bug_vless" --arg cb2 "text_to_img" --arg cb3 "img_to_text" --arg cb4 "img_to_pdf" --arg cb5 "pdf_to_img" --arg cb6 "mp4_to_audio" \
        '{keyboard: [[{text: "Bug Vless", callback_data: $cb1}], [{text: "Text to Img", callback_data: $cb2}], [{text: "Img to Text", callback_data: $cb3}], [{text: "Img to PDF", callback_data: $cb4}], [{text: "PDF to Img", callback_data: $cb5}], [{text: "MP4 to Audio", callback_data: $cb6}]], one_time_keyboard: true}' | jq -c '.')

    hantar_mesej "$chat_id" "Sila pilih pilihan untuk Convert:&reply_markup=${markup}"
}

# Tunjukkan submenu broadcast
tunjukkan_submenu_broadcast() {
    local chat_id="$1"
    local markup
    markup=$(jq -n \
        --arg cb1 "broadcast_user" --arg cb2 "broadcast_group" --arg cb3 "broadcast_channel" --arg cb4 "broadcast_all" --arg cb5 "schedule_user" --arg cb6 "schedule_group" --arg cb7 "schedule_channel" --arg cb8 "schedule_all" \
        '{keyboard: [[{text: "Broadcast User", callback_data: $cb1}], [{text: "Broadcast Group", callback_data: $cb2}], [{text: "Broadcast Channel", callback_data: $cb3}], [{text: "Broadcast All", callback_data: $cb4}], [{text: "Schedule User", callback_data: $cb5}], [{text: "Schedule Group", callback_data: $cb6}], [{text: "Schedule Channel", callback_data: $cb7}], [{text: "Schedule All", callback_data: $cb8}]], one_time_keyboard: true}' | jq -c '.')

    hantar_mesej "$chat_id" "Sila pilih pilihan untuk Broadcast:&reply_markup=${markup}"
}

# Tunjukkan info ChatGPT
tunjukkan_info_chatgpt() {
    local chat_id="$1"
    hantar_mesej "$chat_id" "Info ChatGPT belum disediakan."
}

# Tangani callback query
tangani_callback_query() {
    local chat_id="$1"
    local callback_data="$2"

    case "$callback_data" in
        service)
            tunjukkan_submenu_perkhidmatan "$chat_id"
            ;;
        dev_bot)
            tunjukkan_submenu_versi "$chat_id" "dev_bot"
            ;;
        support_bot)
            tunjukkan_submenu_versi "$chat_id" "support_bot"
            ;;
        clone_bot)
            tunjukkan_submenu_versi "$chat_id" "clone_bot"
            ;;
        free_version)
            tunjukkan_submenu_versi "$chat_id" "free_version"
            ;;
        premium_version)
            tunjukkan_submenu_versi "$chat_id" "premium_version"
            ;;
        *)
            if [[ "$callback_data" == *"_convert" ]]; then
                tunjukkan_submenu_convert "$chat_id"
            elif [[ "$callback_data" == *"_broadcast" ]]; then
                tunjukkan_submenu_broadcast "$chat_id"
            elif [[ "$callback_data" == *"_downloader" ]]; then
                tunjukkan_submenu_downloader "$chat_id" "${callback_data%_downloader}"
            elif [[ "$callback_data" == *"_chatgpt" ]]; then
                tunjukkan_info_chatgpt "$chat_id"
            else
                hantar_mesej "$chat_id" "Pilihan tidak dikenali."
            fi
            ;;
    esac
}

# Proses kemas kini dari Telegram
proses_kemas_kini() {
    local kemas_kini
    kemas_kini=$(dapatkan_kemas_kini)

    # Proses setiap kemas kini
    echo "$kemas_kini" | jq -c '.result[]' | while read -r update; do
        local message_type chat_id user_id callback_data
        message_type=$(echo "$update" | jq -r '.message.text // .callback_query.data // empty')
        chat_id=$(echo "$update" | jq -r '.message.chat.id // .callback_query.message.chat.id')
        user_id=$(echo "$update" | jq -r '.message.from.id // .callback_query.from.id')
        callback_data=$(echo "$update" | jq -r '.callback_query.data // empty')

        if [ -n "$callback_data" ]; then
            tangani_callback_query "$chat_id" "$callback_data"
        elif [ "$message_type" == "/start" ]; then
            tangani_perintah_start "$chat_id" "$user_id"
        elif echo "$update" | jq -e '.message.new_chat_members' > /dev/null; then
            tangani_ahli_baru "$chat_id" "$user_id"
        fi
    done
}

# Gelung utama untuk terus memeriksa kemas kini
utama() {
    while true; do
        proses_kemas_kini
        sleep 5  # Tidur sekejap sebelum memeriksa kemas kini baru
    done
}

# Mulakan bot
utama
