#!/usr/bin/env bash
set -euo pipefail

SPOONS_DIR="${HOME}/.hammerspoon/Spoons"
HAMMERSPOON_DIR="${HOME}/.hammerspoon"
APPS_DIR="${HAMMERSPOON_DIR}/apps"
HAMMERSPOON_INIT="${HAMMERSPOON_DIR}/init.lua"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$SPOONS_DIR"
mkdir -p "$APPS_DIR"

if [[ ! -e "$HAMMERSPOON_INIT" ]]; then
    cat > "$HAMMERSPOON_INIT" <<'LUA'
local fs = hs.fs
local appsPath = os.getenv("HOME") .. "/.hammerspoon/apps"

for file in fs.dir(appsPath) do
    if file:match("%.lua$") then
        local moduleName = "apps." .. file:gsub("%.lua$", "")

        print("Loading:", moduleName)

        local ok, err = pcall(require, moduleName)

        if not ok then
            print("Failed loading " .. moduleName)
            print(err)
        end
    end
end
LUA
    echo "created:  $HAMMERSPOON_INIT"
fi

found=0
apps_found=0

while IFS= read -r -d '' spoon_path; do
    spoon_name="$(basename "$spoon_path")"
    target="${SPOONS_DIR}/${spoon_name}"

    if [[ -L "$target" ]]; then
        rm "$target"
        ln -s "$spoon_path" "$target"
        echo "updated:  $target -> $spoon_path"
    elif [[ -e "$target" ]]; then
        echo "warning:  $target already exists and is not a symlink — skipping"
    else
        ln -s "$spoon_path" "$target"
        echo "linked:   $target -> $spoon_path"
    fi

    (( found++ )) || true
done < <(find "$REPO_ROOT" -type d -name '*.spoon' -print0)

while IFS= read -r -d '' app_init; do
    app_dir="$(dirname "$(dirname "$app_init")")"
    app_name="$(basename "$app_dir")"
    app_file="$(basename "$app_init")"
    target="${APPS_DIR}/${app_name}.lua"

    if [[ "$app_file" != "${app_name}.lua" ]]; then
        continue
    fi

    cp "$app_init" "$target"
    echo "copied:   $target"
    (( apps_found++ )) || true
done < <(find "$REPO_ROOT" -path '*/init/*.lua' -type f -print0)

if [[ $found -eq 0 ]]; then
    echo "no .spoon directories found under $REPO_ROOT"
else
    echo "done — $found spoon(s) processed"
fi

if [[ $apps_found -eq 0 ]]; then
    echo "no app init scripts found under $REPO_ROOT"
else
    echo "done — $apps_found app init script(s) copied"
fi
