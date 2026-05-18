# GUT (Godot Unit Test) Setup

이 폴더는 GUT 플러그인 설치 위치 placeholder입니다. 실제 플러그인 파일은 별도 설치가 필요합니다.

## 설치 (둘 중 하나)

### A. Godot Asset Library (권장)
1. Godot 에디터 실행
2. 상단 탭 `AssetLib` 클릭
3. "Gut" 검색 → "Gut" by bitwes 다운로드
4. Install → `addons/gut` 폴더에 설치됨
5. Project → Project Settings → Plugins → GUT **Enable**

### B. Git Submodule
```bash
cd /Users/sws/bloodline
git submodule add https://github.com/bitwes/Gut.git addons/gut
```

설치 후 `tests/unit/` 의 테스트 실행:
- 메뉴: Project → Tools → GUT → Run All
- 또는 CLI: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit`

## 참고
- 공식 문서: https://gut.readthedocs.io/
- Design Ref: §8.1 L1 — GDScript 단위 테스트
