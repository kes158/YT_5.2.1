#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\n==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

WORK_DIR="${WORK_DIR:-/work}"
LOCAL_DIR="$WORK_DIR/.local_build"
INPUT_DIR="$LOCAL_DIR/input"
OUTPUT_DIR="$LOCAL_DIR/output"
BUILD_DIR="$LOCAL_DIR/docker_build"
ARTIFACT_DIR="$LOCAL_DIR/artifacts"
IPA_PATH="$INPUT_DIR/youtube.ipa"

mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"
rm -rf "$BUILD_DIR" "$ARTIFACT_DIR"
mkdir -p "$BUILD_DIR" "$ARTIFACT_DIR"

CYAN_CMD="${CYAN:-/tmp/cyan-venv/bin/cyan}"
if [[ ! -x "$CYAN_CMD" ]]; then
  # cyan CLI가 없으면 python 모듈로 실행
  CYAN_PYTHON="${CYAN_PYTHON:-/tmp/cyan-venv/bin/python3}"
  CYAN_CMD="$CYAN_PYTHON -m cyan"
fi

export THEOS="${THEOS:-/home/builder/theos}"
export PATH="$HOME/.local/bin:$THEOS/bin:$PATH"

OUTPUT_NAME="${OUTPUT_NAME:-YouTubePlus_Local.ipa}"
TWEAK_VERSION="${TWEAK_VERSION:-5.2}"
TWEAK_VERSION="${TWEAK_VERSION#v}"
DISPLAY_NAME="${DISPLAY_NAME:-YouTube}"
BUNDLE_ID="${BUNDLE_ID:-com.google.ios.youtube}"
ENABLE_YOUPIP="${ENABLE_YOUPIP:-0}"
ENABLE_YTUHD="${ENABLE_YTUHD:-1}"
ENABLE_YQ="${ENABLE_YQ:-0}"
ENABLE_RYD="${ENABLE_RYD:-0}"
ENABLE_YTABC="${ENABLE_YTABC:-0}"
ENABLE_DEMC="${ENABLE_DEMC:-0}"
ENABLE_YCQ="${ENABLE_YCQ:-0}"
ENABLE_YOULOOP="${ENABLE_YOULOOP:-1}"
ENABLE_YOUSPEED="${ENABLE_YOUSPEED:-1}"
INCLUDE_OPEN_YOUTUBE="${INCLUDE_OPEN_YOUTUBE:-1}"

if [[ -n "${IPA_URL:-}" ]]; then
  log "Downloading decrypted IPA"
  curl -L --fail --retry 3 --retry-delay 2 -o "$IPA_PATH" "$IPA_URL"
elif [[ -n "${IPA_FILE:-}" ]]; then
  [[ "$IPA_FILE" != "$IPA_PATH" ]] && cp "$IPA_FILE" "$IPA_PATH"
fi

[[ -s "$IPA_PATH" ]] || die "IPA input is missing."
file_type="$(file --mime-type -b "$IPA_PATH" || true)"
case "$file_type" in
  application/x-ios-app|application/zip|application/octet-stream)
    ;;
  *)
    die "Input does not look like an IPA/zip file. Detected MIME type: $file_type"
    ;;
esac

log "Preparing YTLite deb"
if [[ -n "${YTPLUS_DEB_URL:-}" ]]; then
  curl -L --fail --retry 3 --retry-delay 2 -o "$ARTIFACT_DIR/ytplus.deb" "$YTPLUS_DEB_URL"
else
  ytlite_url="https://github.com/dayanch96/YTLite/releases/download/v${TWEAK_VERSION}/com.dvntm.ytlite_${TWEAK_VERSION}_iphoneos-arm.deb"
  curl -L --fail --retry 3 --retry-delay 2 -o "$ARTIFACT_DIR/ytplus.deb" "$ytlite_url"
fi
dpkg-deb --info "$ARTIFACT_DIR/ytplus.deb" >/dev/null

needs_headers=0
needs_ygs=0
needs_ytvo=0

for enabled in "$ENABLE_YOUPIP" "$ENABLE_YTUHD" "$ENABLE_YQ" "$ENABLE_RYD" "$ENABLE_YTABC" "$ENABLE_DEMC" "$ENABLE_YCQ" "$ENABLE_YOULOOP" "$ENABLE_YOUSPEED"; do
  if [[ "$enabled" == "1" ]]; then
    needs_headers=1
  fi
done

if [[ "$ENABLE_YOUPIP" == "1" || "$ENABLE_YTUHD" == "1" || "$ENABLE_YQ" == "1" || "$ENABLE_RYD" == "1" || "$ENABLE_DEMC" == "1" || "$ENABLE_YCQ" == "1" || "$ENABLE_YOULOOP" == "1" || "$ENABLE_YOUSPEED" == "1" ]]; then
  needs_ygs=1
fi

if [[ "$ENABLE_YOUPIP" == "1" || "$ENABLE_YTUHD" == "1" || "$ENABLE_YQ" == "1" || "$ENABLE_YCQ" == "1" || "$ENABLE_YOULOOP" == "1" || "$ENABLE_YOUSPEED" == "1" ]]; then
  needs_ytvo=1
fi

if [[ "$needs_headers" == "1" ]]; then
  log "Cloning shared headers"
  rm -rf "$THEOS/include/YouTubeHeader" "$THEOS/include/PSHeader"
  git clone --quiet --depth=1 https://github.com/PoomSmart/YouTubeHeader.git "$THEOS/include/YouTubeHeader"
  git clone --quiet --depth=1 https://github.com/PoomSmart/PSHeader.git "$THEOS/include/PSHeader"

  if [[ "$ENABLE_DEMC" == "1" ]]; then
    rm -rf "$THEOS/include/YTHeaders"
    cp -R "$THEOS/include/YouTubeHeader" "$THEOS/include/YTHeaders"
  fi

  cd "$BUILD_DIR"
  if [[ "$needs_ygs" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YouGroupSettings.git
  fi
  if [[ "$needs_ytvo" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YTVideoOverlay.git
  fi
  if [[ "$ENABLE_YOUPIP" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YouPiP.git
  fi
  if [[ "$ENABLE_YTUHD" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YTUHD.git
  fi
  if [[ "$ENABLE_YQ" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YouQuality.git
  fi
  if [[ "$ENABLE_YOULOOP" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/bhackel/YouLoop.git
  fi
  if [[ "$ENABLE_YOUSPEED" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YouSpeed.git
  fi
  if [[ "$ENABLE_YCQ" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YouChooseQuality.git

    # Inject Korean localization (using confirmed real key names from screenshot)
    YCQ_BUNDLE=$(find YouChooseQuality/layout -type d -name "*.bundle" 2>/dev/null | head -1)
    if [[ -n "$YCQ_BUNDLE" ]]; then
      mkdir -p "$YCQ_BUNDLE/ko.lproj"
      cat > "$YCQ_BUNDLE/ko.lproj/Localizable.strings" << 'KOEOF'
"TWEAK_NAME" = "YouChooseQuality";
"TWEAK_DESC" = "각 상황별로 지정한 화질과 동일하거나 가장 가까운 화질을 자동으로 선택합니다.";
"ENABLED" = "활성화";
"QUALITY_FOR_SCENARIO_0_SHORT" = "Wi-Fi";
"QUALITY_FOR_SCENARIO_0" = "Wi-Fi 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_1_SHORT" = "셀룰러";
"QUALITY_FOR_SCENARIO_1" = "셀룰러(모바일 데이터) 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_2_SHORT" = "Wi-Fi (AirPlay)";
"QUALITY_FOR_SCENARIO_2" = "AirPlay 사용 중 Wi-Fi 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_3_SHORT" = "셀룰러 (AirPlay)";
"QUALITY_FOR_SCENARIO_3" = "AirPlay 사용 중 셀룰러 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_4_SHORT" = "저전력 모드";
"QUALITY_FOR_SCENARIO_4" = "저전력 모드 활성화 시 기본 화질";
KOEOF
    fi
  fi
  if [[ "$ENABLE_RYD" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/Return-YouTube-Dislikes.git
  fi
  if [[ "$ENABLE_YTABC" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/PoomSmart/YTABConfig.git
  fi
  if [[ "$ENABLE_DEMC" == "1" ]]; then
    git clone --quiet --depth=1 https://github.com/therealFoxster/DontEatMyContent.git
    sed -i '' "s/^CGFloat constant;/extern CGFloat constant;/" DontEatMyContent/Tweak.h
    perl -i -0pe 's/^(static CGFloat videoAspectRatio)/CGFloat constant = 0.0;\n$1/m' DontEatMyContent/Tweak.x
  fi

  if [[ "$needs_ygs" == "1" ]]; then
    log "Building YouGroupSettings"
    cd "$BUILD_DIR/YouGroupSettings"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/ygs.deb"
  fi

  if [[ "$needs_ytvo" == "1" ]]; then
    log "Building YTVideoOverlay"
    cd "$BUILD_DIR/YTVideoOverlay"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/ytvo.deb"
  fi

  if [[ "$ENABLE_YOUPIP" == "1" ]]; then
    log "Building YouPiP"
    cd "$BUILD_DIR/YouPiP"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/youpip.deb"
  fi

  if [[ "$ENABLE_YTUHD" == "1" ]]; then
    log "Building latest YTUHD from PoomSmart/YTUHD"
    cd "$BUILD_DIR/YTUHD"
    make clean package DEBUG=0 FINALPACKAGE=1 SIDELOAD=1
    cp packages/*.deb "$ARTIFACT_DIR/ytuhd.deb"
  fi

  if [[ "$ENABLE_RYD" == "1" ]]; then
    log "Building Return-YouTube-Dislikes"
    cd "$BUILD_DIR/Return-YouTube-Dislikes"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/ryd.deb"
  fi

  if [[ "$ENABLE_YTABC" == "1" ]]; then
    log "Building YTABConfig"
    cd "$BUILD_DIR/YTABConfig"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/ytabc.deb"
  fi

  if [[ "$ENABLE_YQ" == "1" ]]; then
    log "Building YouQuality"
    cd "$BUILD_DIR/YouQuality"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/yq.deb"
  fi

  if [[ "$ENABLE_YCQ" == "1" ]]; then
    log "Building YouChooseQuality (with Korean localization)"
    cd "$BUILD_DIR/YouChooseQuality"

    # Overwrite ko.lproj right before build (using confirmed real key names)
    YCQ_BUNDLE_DIR=$(find layout -type d -name "*.bundle" 2>/dev/null | head -1)
    if [[ -n "$YCQ_BUNDLE_DIR" ]]; then
      mkdir -p "$YCQ_BUNDLE_DIR/ko.lproj"
      cat > "$YCQ_BUNDLE_DIR/ko.lproj/Localizable.strings" << 'KOEOF'
"TWEAK_NAME" = "YouChooseQuality";
"TWEAK_DESC" = "각 상황별로 지정한 화질과 동일하거나 가장 가까운 화질을 자동으로 선택합니다.";
"ENABLED" = "활성화";
"QUALITY_FOR_SCENARIO_0_SHORT" = "Wi-Fi";
"QUALITY_FOR_SCENARIO_0" = "Wi-Fi 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_1_SHORT" = "셀룰러";
"QUALITY_FOR_SCENARIO_1" = "셀룰러(모바일 데이터) 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_2_SHORT" = "Wi-Fi (AirPlay)";
"QUALITY_FOR_SCENARIO_2" = "AirPlay 사용 중 Wi-Fi 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_3_SHORT" = "셀룰러 (AirPlay)";
"QUALITY_FOR_SCENARIO_3" = "AirPlay 사용 중 셀룰러 연결 시 기본 화질";
"QUALITY_FOR_SCENARIO_4_SHORT" = "저전력 모드";
"QUALITY_FOR_SCENARIO_4" = "저전력 모드 활성화 시 기본 화질";
KOEOF
    fi

    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/ycq.deb"
  fi

  if [[ "$ENABLE_DEMC" == "1" ]]; then
    log "Building DontEatMyContent"
    cd "$BUILD_DIR/DontEatMyContent"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/demc.deb"
  fi

  if [[ "$ENABLE_YOULOOP" == "1" ]]; then
    log "Building YouLoop"
    cd "$BUILD_DIR/YouLoop"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/youloop.deb"
  fi

  if [[ "$ENABLE_YOUSPEED" == "1" ]]; then
    log "Building YouSpeed"
    cd "$BUILD_DIR/YouSpeed"
    make clean package DEBUG=0 FINALPACKAGE=1
    cp packages/*.deb "$ARTIFACT_DIR/youspeed.deb"
  fi
fi

if [[ "$INCLUDE_OPEN_YOUTUBE" == "1" ]]; then
  log "Preparing Open in YouTube Safari extension"
  cd "$BUILD_DIR"
  git clone --quiet -n --depth=1 --filter=tree:0 https://github.com/BillyCurtis/OpenYouTubeSafariExtension OpenYoutubeSafariExtension
  cd OpenYoutubeSafariExtension
  git sparse-checkout set --no-cone OpenYouTubeSafariExtension.appex OpenYoutubeSafariExtension.appex
  git checkout --quiet
  find . -maxdepth 1 -type d -name "*.appex" -exec cp -R {} "$ARTIFACT_DIR/" \;
fi

log "Injecting tweaks into IPA"
cd "$ARTIFACT_DIR"
tweaks=()
tweaks+=("$ARTIFACT_DIR/ytplus.deb")
if [[ "$INCLUDE_OPEN_YOUTUBE" == "1" ]]; then
  while IFS= read -r appex; do
    tweaks+=("$appex")
  done < <(find "$ARTIFACT_DIR" -maxdepth 1 -type d -name "*.appex" | sort)
fi
for deb in "$ARTIFACT_DIR"/*.deb; do
  [[ -f "$deb" ]] || continue
  [[ "$(basename "$deb")" == "ytplus.deb" ]] && continue
  tweaks+=("$deb")
done

$CYAN_CMD \
  -i "$IPA_PATH" \
  -o "$OUTPUT_DIR/$OUTPUT_NAME" \
  -uwef "${tweaks[@]}" \
  -n "$DISPLAY_NAME" \
  -b "$BUNDLE_ID"

log "Built $OUTPUT_DIR/$OUTPUT_NAME"
