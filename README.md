# claude-yawn-theme

Claude Code 다크 테마 + 터미널 ANSI 최소 보정.

| 조각 | 담당 | 영향 범위 |
|---|---|---|
| `claude/yawn.json` | Claude Code TUI — 테두리, 상태색, diff 배경, 스피너 | Claude Code 만 |
| `terminals/*` | 코드 블록 신택스 색 | 그 터미널 전체 |

---

## 먼저 읽을 것 — 이 테마로 안 되는 것

Claude Code 의 신택스 하이라이팅은 **IDE 수준으로 만들 수 없다.** 색을 고르는
문제가 아니라 구조적 상한이다.

하이라이터는 highlight.js 의 스코프 36개를 **ANSI 16색에 밀어넣는다.** 여러
스코프가 한 슬롯을 공유하므로, 같은 슬롯에 묶인 것끼리는 **어떤 팔레트로도
분리할 수 없다.**

| 구분하고 싶은 것 | 슬롯 | 가능? |
|---|---|---|
| 객체 키 ↔ 타입명 | cyan ↔ blue | ✅ 이 테마가 해결 |
| 메서드 호출 ↔ 나머지 | yellow | ✅ |
| 주석·숫자 ↔ 코드 | green | ✅ |
| 문자열 ↔ 코드 | red | ✅ |
| **키워드 ↔ 클래스·타입명** | 둘 다 `blue` | ❌ **불가능** |
| **변수명 ↔ 괄호·연산자·프로퍼티** | 둘 다 색 없음 | ❌ **불가능** |

```ts
// const 와 ExecutionContext 가 같은 파랑으로 보이는 이유:
//   const            -> keyword     -> blue
//   ExecutionContext -> title.class -> blue     같은 슬롯
const ctx: ExecutionContext = ...

// req, user, options 에 색이 없는 이유:
//   하이라이터가 변수에 스코프를 아예 붙이지 않는다.
//   색 코드가 안 나가므로 터미널 기본 전경색으로 렌더된다.
const req = user.getRequest(options);
```

IDE 는 언어 서버가 의미 분석을 해서 심볼 종류별로 칠하지만, 여기 하이라이터는
정규식 기반이고 출력 채널이 ANSI 16색이다. 이 상한은 팔레트로 넘을 수 없다.

**`/theme` 커스텀 테마로도 안 된다.** 테마의 72개 토큰에 신택스 항목은 0개다.
테마가 관할하는 것은 TUI(테두리·상태색·diff 배경·스피너)뿐이다.

### 스코프 → ANSI 슬롯 전체 매핑

`type` 은 cyan 에 dim 속성이 붙는다. 슬롯이 같으므로 색상은 분리 불가.

| 슬롯 | highlight.js 스코프 | 코드에서 보이는 것 |
|---|---|---|
| `blue (ANSI 4)` | keyword, literal, class, name, title.class | import const class private readonly / true false null / 클래스·타입 이름 |
| `cyan (ANSI 6)` | built_in, attr, type* | 객체 키, 파라미터 이름, 내장 객체, 타입 표기 |
| `green (ANSI 2)` | number, comment, doctag, addition | 숫자, 주석, JSDoc, diff 추가줄 |
| `red (ANSI 1)` | string, regexp, deletion | 문자열, 정규식, diff 삭제줄 |
| `yellow (ANSI 3)` | function, title.function | 함수 선언, 메서드 호출 |
| `brightBlack (ANSI 8)` | meta, tag | 어노테이션(@Injectable), HTML 태그 |
| `(색 없음)` | variable, params, title, property, subst, symbol,
section, attribute, bullet, code, quote | 변수명, 파라미터, 객체 프로퍼티, 괄호, 연산자, 쉼표 |

직접 확인하려면:

```bash
npm i highlight.js
node -e "const h=require('highlight.js');
const r=h.highlight('const a: Foo = b.c(1)',{language:'typescript'});
(function w(n,s){if(typeof n==='string'){n.trim()&&console.log(n.trim(),'->',s??'(스코프 없음)');return}
const x=n.scope??n.kind??s;for(const c of n.children??[])w(c,x)})(r._emitter.rootNode,null)"
```

---

## 설치

### 1. Claude Code 테마

```bash
chmod +x install.sh && ./install.sh
```

그다음 `/theme` → `yawn`. 수동으로 할 경우 `claude/yawn.json` 을
`~/.claude/themes/` 에 복사하고 `~/.claude/settings.json` 에
`"theme": "custom:yawn"` 을 넣는다.

### 2. 터미널 (선택 — 이걸 안 하면 코드 색은 그대로다)

| 터미널 | 파일 | 위치 |
|---|---|---|
| Windows Terminal | `windows-terminal.json` | `settings.json` 의 `schemes` 에 추가 후 `profiles.defaults.colorScheme` 지정 |
| VS Code | `vscode-settings.json` | User `settings.json` 에 병합 |
| Alacritty | `alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
| kitty | `kitty.conf` | `~/.config/kitty/kitty.conf` |
| Ghostty | `ghostty.conf` | `~/.config/ghostty/config` |
| WezTerm | `wezterm.lua` | `~/.wezterm.lua` |

`terminals/` 의 나머지 파일은 **`windows-terminal.json` 에서 기계적으로 생성**한다 —
정본은 그 한 파일이다. 색을 고칠 땐 거기서 고치고 나머지를 다시 생성한다(각 파일
머리에도 같은 문구를 적어 뒀다). 예전엔 `blue`·`cyan` 두 칸만 담았지만, 지금은
팔레트 전체를 갈아타므로 16색 + 배경/전경을 전부 담는다.

## 팔레트: Argonaut 기반, 한 칸만 보정

Windows Terminal 기본(Campbell)의 `blue #0037DA` 는 검정 배경에서 2.4:1 이라
`import`/`const`/`class` 가 안 읽힌다. 그래서 배경이 거의 검정이면서 채도가 가장
높은 팔레트로 갈아탔다 — **Argonaut**(배경 `#0e1019`, 채도 77로 후보 중 최고).

원본에서 바꾼 값은 딱 하나다.

| slot | before | after | 이유 |
|---|---|---|---|
| `brightBlack` (ANSI 8) | `#444444` | `#828282` | 배경 대비 1.9:1 → 4.9:1. Claude Code 가 경로·힌트·요약 줄에 이 색을 쓰는데 안 읽혔다 (값은 Firefly Traditional 에서 가져옴) |

측정값 (배경 `#0e1019` 기준):

| 항목 | 값 |
|---|---|
| 키워드 `blue #008df8` | 5.6:1 |
| 객체 키 `cyan #00d8eb` | 8.6:1 |
| 본문 `#fffaf4` | 18.3:1 |
| 슬롯 최저(문자열 `red`) | 4.8:1 |
| 슬롯 간 최소 색차 ΔE | 63.8 (blue↔cyan) |

`red` `green` `yellow` 는 여전히 빨강·초록·노랑이라 `git diff` 추가/삭제, 에러
메시지, `ls` 색 같은 **ANSI 슬롯의 관습은 그대로 유지**된다. ANSI 슬롯은 색 이름이
아니라 **의미**를 담고 있어서, `green` 에 회색을 넣으면 `git diff` 추가 줄이 회색이
되고 `red` 에 초록을 넣으면 에러 메시지가 초록으로 나온다 — 팔레트를 갈아탈 때
그 관습이 살아 있는지부터 본다.

> 이전 판은 Campbell 에서 `blue`·`cyan` 두 칸만 바꾼 `Campbell Readable` 이었다.
> 최소 보정이라는 장점은 있었지만 배경(`#0C0C0C`)과 채도가 그대로라 코드가 밋밋했다.
> 그 정의가 필요하면 git 이력에서 꺼내 쓰면 된다.

### herdr 를 함께 쓴다면

`herdr_custom` 의 herdr 설정은 `[theme] name = "terminal"` 이라 herdr 가 이
팔레트를 그대로 따른다. 그때 **선택된 탭/pane 의 배경(accent)** 이 팔레트의
`blue #008df8` 가 되는데, 그 위에 얹히는 흐린 글자는 대비 1.1:1 로 안 보인다.
그래서 herdr 쪽에 `[theme.custom] accent = "#1e3a5f"` 를 함께 둔다
(그 위 본문 11.1:1, 흐린 글자 3.0:1). **팔레트를 바꾸면 accent 도 같이 봐야 한다.**
