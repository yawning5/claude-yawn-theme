# claude-yawn-theme

Claude Code 다크 테마 + 터미널 ANSI 최소 보정.

## 구성

| 조각 | 담당 | 영향 범위 |
|---|---|---|
| `claude/yawn.json` | Claude Code TUI — 테두리, 상태색, diff 배경, 스피너 | Claude Code 만 |
| `terminals/*` | 코드 블록 신택스 색 | 그 터미널 전체 |

## 설치

### 1. Claude Code 테마

```bash
./install.sh
```

그다음 `/theme` → `yawn` 선택. 수동으로 할 경우 `claude/yawn.json` 을
`~/.claude/themes/` 에 복사하고 `~/.claude/settings.json` 에
`"theme": "custom:yawn"` 을 넣는다.

### 2. 터미널 (선택, 2색만)

| 터미널 | 파일 | 위치 |
|---|---|---|
| Windows Terminal | `windows-terminal.json` | `settings.json` 의 `schemes` 에 추가 후 `profiles.defaults.colorScheme` 지정 |
| VS Code | `vscode-settings.json` | User `settings.json` 에 병합 |
| Alacritty | `alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
| kitty | `kitty.conf` | `~/.config/kitty/kitty.conf` |
| Ghostty | `ghostty.conf` | `~/.config/ghostty/config` |
| WezTerm | `wezterm.lua` | `~/.wezterm.lua` |

## 왜 터미널을 건드려야 하는가

Claude Code 의 신택스 하이라이터는 색을 직접 지정하지 않는다. chalk 의 ANSI
코드(`chalk.blue` → `\033[34m`)만 내보내고 실제 색은 터미널이 정한다.
커스텀 테마의 72개 토큰에 신택스 항목은 **하나도 없다**. 즉 코드 블록 색은
`/theme` 으로 바꿀 수 없고 터미널 팔레트로만 바꿀 수 있다.

## 바꾸는 색은 2개뿐

기본 팔레트(Windows Terminal 은 Campbell)에서 두 색만 교체한다.

| slot | before | after | 이유 |
|---|---|---|---|
| `blue` (ANSI 4) | `#0037DA` | `#4C7FFF` | 배경 대비 2.4:1 → 5.4:1. `import`/`const`/`class` 등 keyword 가 남색이라 안 읽히던 문제 |
| `cyan` (ANSI 6) | `#3A96DD` | `#4EC9E0` | 색상 206° → 189°. `attr`(객체 키, 파라미터명)와 `title.class`(타입명)가 둘 다 파랑 계열이라 안 구분되던 문제 |

`red` `green` `yellow` 등 나머지는 건드리지 않는다. 그래서 `git diff`
추가=초록/삭제=빨강, 에러=빨강, `ls` 색 전부 관습대로 유지된다.

전체 팔레트를 바꾸는 테마들이 흔히 이 부분을 깨뜨린다. ANSI 슬롯은 색 이름이
아니라 **의미**를 담고 있어서, `green` 에 회색을 넣으면 `git diff` 의 추가
줄이 회색이 된다.

## 어디까지 되고 어디부터 안 되는가

Claude Code 는 highlight.js 의 스코프를 ANSI 16색에 밀어넣는다. 여러 스코프가
한 슬롯을 공유하므로 팔레트로 분리할 수 없는 조합이 있다.

| 구분 대상 | 슬롯 | 가능 |
|---|---|---|
| 객체 키 ↔ 타입명 | cyan ↔ blue | O |
| 메서드 호출 ↔ 나머지 | yellow | O |
| 주석 ↔ 코드 | green | O |
| **키워드 ↔ 클래스명** | 둘 다 blue | **X** |
| **변수 ↔ 괄호·연산자** | 둘 다 색 없음 | **X** |

변수명은 하이라이터가 스코프를 붙이지 않아 터미널 기본 전경색으로 렌더된다.
IDE 처럼 심볼 종류별로 칠하는 것은 이 구조에서 불가능하다.
