#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PAYLOAD_DIR="$SCRIPT_DIR/payload"
FILE_LIST="$SCRIPT_DIR/FILES.txt"
HASH_LIST="$SCRIPT_DIR/SHA256SUMS.txt"

is_game_root() {
    [ -f "$1/Binaries/Win64/UDK.exe" ] && [ -d "$1/UDKGame/CookedPC" ]
}

normalize_root() {
    candidate=$1
    case "$candidate" in
        */UDKGame|*/UDKGame/) candidate=$(dirname -- "${candidate%/}") ;;
    esac
    CDPATH= cd -- "$candidate" 2>/dev/null && pwd
}

GAME_ROOT=${1-}
if [ -z "$GAME_ROOT" ] && is_game_root "$PWD"; then
    GAME_ROOT=$PWD
fi
if [ -z "$GAME_ROOT" ] && is_game_root "$HOME/renegade_x"; then
    GAME_ROOT=$HOME/renegade_x
fi
if [ -z "$GAME_ROOT" ]; then
    printf '请输入 Renegade X 游戏根目录（里面应有 Binaries 和 UDKGame）：\n> '
    IFS= read -r GAME_ROOT
fi

GAME_ROOT=$(normalize_root "$GAME_ROOT") || {
    printf '错误：游戏目录不存在。\n' >&2
    exit 1
}
if ! is_game_root "$GAME_ROOT"; then
    printf '错误：%s 不是 Renegade X 游戏根目录。\n' "$GAME_ROOT" >&2
    exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
    (cd "$SCRIPT_DIR" && sha256sum -c SHA256SUMS.txt >/dev/null) || {
        printf '错误：安装包文件校验失败，请重新解压。\n' >&2
        exit 1
    }
fi

STAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_ROOT="$GAME_ROOT/Chinese_Localization_Backup_$STAMP"
mkdir -p "$BACKUP_ROOT"

while IFS= read -r rel || [ -n "$rel" ]; do
    [ -n "$rel" ] || continue
    src="$PAYLOAD_DIR/$rel"
    dst="$GAME_ROOT/$rel"
    bak="$BACKUP_ROOT/$rel"
    [ -f "$src" ] || {
        printf '错误：安装包缺少 %s\n' "$rel" >&2
        exit 1
    }
    mkdir -p "$(dirname -- "$dst")" "$(dirname -- "$bak")"
    if [ -f "$dst" ]; then
        cp -p -- "$dst" "$bak"
    fi
    cp -p -- "$src" "$dst"
done < "$FILE_LIST"

printf '\n安装完成。\n'
printf '游戏目录：%s\n' "$GAME_ROOT"
printf '原文件备份：%s\n' "$BACKUP_ROOT"
printf '启动时请添加参数：-language=chn\n'
