#!/bin/bash

# Phase 1 : Configurations --------------------

CONFIG="$(dirname "$0")/config.sh"
[[ -f "$CONFIG" ]] || { echo "Missing config: $CONFIG (copy config.example.sh)"; exit 1; }
source "$CONFIG" # loads SRC and DST (runs config.sh inside this script, so SRC and DST exist here)

shopt -s nocaseglob
re='^([A-Za-z0-9._& -]+)\.([0-9]{4})\.'
#    BASH_REMATCH[1]  BASH_REMATCH[2]

# Phase 2 : Security -----------------------

# Problem_1 : SRC must be a folder, or the script stops loudly (exit 1)
# Solution_1: Check that SRC is a folder, or else: print the error and stop.
[[ -d "$SRC" ]] || { echo "Not a folder: $SRC"; exit 1; }

# Problem_2 : DST must exist, create it if missing, stop loudly (exit 1) if that fails
# Solution_2 : Check that DST exists (create it if needed), or else: print the error and stop.
mkdir -p "$DST" || { echo "Cannot create: $DST"; exit 1; }

# Phase 3 : Code ----------------------

# OUTER LOOP : → the folder ends up as Movies/French Kiss (1995)/
for m in "$SRC"/*/; do
  name=$(basename "$m") # French.Kiss.1995.1080p.BluRay.H264.AAC
  [[ "$name" =~ $re ]] || continue # if French.Kiss.1995.1080p.BluRay.H264.AAC does not match regex pattern, then skip this folder (Problem it solves : moving the wrong files, like a Music file or else)
  TITLE=$( echo "${BASH_REMATCH[1]}" | tr "." " ") # Witness ; French Kiss...
  YEAR="${BASH_REMATCH[2]}"
  NEW="$TITLE ($YEAR)"
  [[ -e "$DST/$NEW" ]] && { echo "Already exists: $NEW"; continue; } # Check for Duplicate : # if name already exists in Movies, warn and skip to the next one

  # INNER LOOP : → the file ends up as French Kiss (1995).mp4
  for e in "$m"*.{mp4,avi,mkv}; do # /tmp/SAB/French.Kiss…AAC/French.Kiss.1995.1080p.BluRay.H264.AAC.mp4
    [[ -f "$e" ]] || continue # Checks if not a real video file (e.g., no .mp4 or .avi or .mkv in this folder, then skip)
    EXT="${e##*.}" # parameter expansion to only get extension of the current video (mp4, avi, mkv)
    EXT="${EXT,,}" # same but forces lower cases (prevents MKV, MkV, MP4 → mkv, mp4, avi)
    TARGET="$m$NEW.$EXT"
    # if French.Kiss.1995.1080p.BluRay.H264.AAC already renamed to French Kiss (1995).mp4 then skip :
    [[ "$e" == "$TARGET" ]] && continue # Prevents noise of renaming file that have already been renamed exactly the same
    mv -n "$e" "$TARGET" # Rename the current video to: this folder / New name . extension.
  done

  mv -n "$m" "$DST/$NEW"

done

