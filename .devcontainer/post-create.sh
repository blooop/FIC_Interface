#!/usr/bin/env bash
# Once per container: the first-run setup fic-entrypoint does in the plain
# image (devpod replaces the entrypoint), then a build of this checkout.
set -euo pipefail

cd "$(dirname "$0")/.."

# Build output and the restore marker fic-state writes into FIC_ROOT stay
# out of `git status` (this clone only; the repository has no .gitignore).
exclude="$(git rev-parse --git-path info/exclude)"
for pattern in /fic_ws/build/ /fic_ws/install/ /fic_ws/log/ /.fic-state-restored; do
    grep -qxF "${pattern}" "${exclude}" 2>/dev/null || echo "${pattern}" >> "${exclude}"
done

# Settings that skip the setup wizard and enable the simulation extensions.
cp --update=none /etc/fic/robot_selector_gui_settings.yaml "${HOME}/.robot_selector_gui_settings.yaml"
for sub in experiments excitation_runs lemniscate_plots extensions; do
    mkdir -p "${HOME}/FIC_Studio/${sub}"
done

./build.sh
