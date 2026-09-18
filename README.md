# ko-eli5-skills

에이전트가 쓴 영어 기술 보고를 한국어로, 한눈에 읽히는 형태로 바꿔주는 Claude Code 스킬 모음입니다.

> **원 저자 표시**
>
> 이 저장소의 스킬은 제가 처음부터 만든 것이 아닙니다. 아래 두 저장소의 스킬을 가져와 **제 용도에 맞게 편의상 재구성**한 것입니다. 원 저작권과 라이선스(MIT)는 각 원 저자에게 있습니다.
>
> | 원 스킬 | 원 저자 | 저장소 | 이 저장소에서의 사용 |
> |---|---|---|---|
> | `eli5` | DreambigOu | https://github.com/DreambigOu/ELI5 | `skills/ko-eli5/`의 뼈대(3단계 구조, 청중 프레이밍 표, 평가 하네스)를 가져와 고쳤습니다 |
> | `humanizer` | DaleSeo | https://github.com/DaleSeo/korean-skills | `skills/humanizer/`에 **원본 그대로** 포함 |
> | `grammar-checker` | DaleSeo | https://github.com/DaleSeo/korean-skills | `skills/grammar-checker/`에 **원본 그대로** 포함 |
> | `style-guide` | DaleSeo | https://github.com/DaleSeo/korean-skills | `skills/style-guide/`에 **원본 그대로** 포함 |
>
> 원본을 직접 쓰고 싶다면 위 저장소로 가세요. 원본 쪽이 더 자주 업데이트됩니다.

## 왜 만들었나

멀티에이전트 개발 환경에서 에이전트끼리는 영어와 개발 용어로 대화하게 두고, 대장 에이전트가 사람(한국인)에게 보고하는 마지막 한 번만 한국어로 바꾸고 싶었습니다.

기존 스킬을 그대로 이어 붙이면 문제가 있었습니다.

- ELI5는 영어 전용이고 청중을 매번 프롬프트에서 탐지합니다. 보고 받는 사람은 늘 같은데 매번 탐지할 이유가 없고, 기본값 "5살"은 개발자에게 맞지 않습니다.
- "영어로 쉽게 쓴 뒤 한국어로 번역"하면 번역투가 생깁니다. korean-skills의 humanizer가 잡아내는 패턴(에 대해 / 통해 / 되어진다)이 바로 그 번역 과정에서 나옵니다.
- 쉽게 쓰는 과정에서 "확인된 사실"과 "추정"이 섞이면 보고를 믿을 수 없게 됩니다.

그래서 다음처럼 재구성했습니다.

| 원본 | 이 저장소 |
|---|---|
| ELI5: 청중을 프롬프트에서 탐지, 기본값 Age 5 | `references/audience.md`에 청중 고정. 탐지 없음 |
| ELI5: 영어 출력, 영어 문화권 비유 | 한국어 출력, `references/analogies-ko.md`의 한국 맥락 비유 |
| ELI5: 단순화 우선("80% 정확도면 충분") | 요약 티어에만 허용. 영어 원문은 부록으로 그대로 붙임 |
| ELI5: 평가 하네스 `run-evals.py` | 경로만 바꿔 재사용. 한국어 기준 assertion 6개 |
| korean-skills: 사람이 붙인 텍스트를 검수 | 에이전트가 자기 한국어 출력을 검수하는 마지막 단계로 사용. 순서(humanizer → grammar-checker → style-guide)는 원본 README 권장 그대로 |
| (없음) | 모든 항목에 `[확인]/[추정]/[가정]` 라벨을 강제. QA 단계가 라벨을 건드리면 복원 |
| (없음) | `references/glossary.md` 용어집을 style-guide의 Terminology 검사에 연결 |

## 구조

```
skills/
├── ko-eli5/                  # 이 저장소에서 만든 스킬 (ELI5 기반)
│   ├── SKILL.md
│   ├── references/
│   │   ├── audience.md       # 고정 청중. 바꾸려면 이 파일만 수정
│   │   ├── analogies-ko.md   # 한국 맥락 비유 뱅크
│   │   ├── glossary.md       # EN → KO 고정 용어집
│   │   └── output-template.md
│   ├── examples/             # 입력(영어 보고) → 출력(한국어 보고) 쌍 3개
│   └── evals/                # ELI5 하네스 + 한국어 기준 테스트 6개
├── humanizer/                # DaleSeo/korean-skills 원본 그대로
├── grammar-checker/          # DaleSeo/korean-skills 원본 그대로
└── style-guide/              # DaleSeo/korean-skills 원본 그대로
```

## 설치

```bash
git clone https://github.com/oswaldeff/ko-eli5-skills.git
cp -r ko-eli5-skills/skills/* ~/.claude/skills/
```

`humanizer` / `grammar-checker` / `style-guide`를 이미 원본 플러그인(`korean-skills`)으로 설치했다면 `ko-eli5`만 복사해도 됩니다. `ko-eli5`는 그 세 스킬을 이름으로 부르기 때문에 어느 쪽이 설치돼 있어도 동작합니다.

```bash
cp -r ko-eli5-skills/skills/ko-eli5 ~/.claude/skills/
```

플러그인으로 설치할 수도 있습니다.

```bash
claude /plugin marketplace add oswaldeff/ko-eli5-skills
claude /plugin install ko-eli5-skills@ko-eli5-skills
```

## 사용

두 가지 모드가 있습니다 (SKILL.md Step 0).

- **Relay 모드**: 다른 에이전트의 영어 보고를 받아 한국어로 옮길 때. `/ko-eli5 <영어 보고 붙여넣기 또는 파일 경로>`
- **Self-report 모드**: Claude Code가 자기 작업 결과나 답변을 터미널로 사용자에게 보고할 때. 인자 없이 자동 적용. 영어 원문이 없으니 부록은 `changes / ran / verified / not verified / decisions` 형태의 짧은 영어 기술 기록으로 대신합니다.

크기도 자동으로 맞춥니다. 단순 질문 답변은 라벨 붙인 1~3문장, 파일을 고치거나 명령을 돌린 작업 결과는 전체 템플릿. 터미널에서는 HTML이 안 보이므로 `<details>` 대신 `---` 구분선을 씁니다.

### 터미널 답변에 항상 적용하기 (Claude Code)

`~/.claude/CLAUDE.md` 맨 위에 넣습니다. 스킬 description만으로는 매 답변마다 확실히 붙지 않으므로 CLAUDE.md 규칙이 필요합니다.

```markdown
# 사용자 보고 형식: ko-eli5 (최우선순위, 답변 형식에 한정)

사용자에게 터미널로 보내는 모든 최종 답변은 `ko-eli5` 스킬(`~/.claude/skills/ko-eli5/SKILL.md`)을 먼저 읽고 그 형식으로 쓴다.

- 한국어. 작업 결과는 첫 줄에 상태어(완료 / 일부 완료 / 실패 / 막힘). 모든 주장에 [확인]/[추정]/[가정] 라벨. 선택이 남아 있으면 `결정 필요` 블록과 기본 동작.
- 크기는 스킬 Step 0을 따른다. 단순 질문은 라벨 붙인 1~3문장, 템플릿 없이.
- 적용 범위는 사용자에게 보내는 답변만. 서브에이전트·다른 에이전트에게 보내는 메시지는 영어 그대로. 코드, 커밋 메시지, PR 본문, 파일 내용에는 적용하지 않는다.
- 코드 펜스 안의 내용은 번역하거나 고치지 않는다.
```

### korean-skills 설치 확인

Step 5의 QA는 `humanizer` / `grammar-checker` / `style-guide`가 설치돼 있어야 실제로 돌아갑니다. 없으면 스킬이 패턴 목록으로 수동 검수하지만 품질이 떨어집니다. 이 저장소의 `skills/`를 전부 복사했거나, 원본 플러그인을 설치했으면 됩니다. 원본 플러그인을 `settings.json`으로 등록하는 방법:

```json
"enabledPlugins": { "korean-skills@korean-skills": true },
"extraKnownMarketplaces": {
  "korean-skills": { "source": { "source": "github", "repo": "DaleSeo/korean-skills" } }
}
```

보고 전담 서브에이전트를 두는 경우 `.claude/agents/reporter.md`:

```yaml
---
name: reporter
description: Turns English agent reports into Korean owner-facing reports.
skills:
  - ko-eli5
  - humanizer
  - grammar-checker
  - style-guide
---
You receive English technical reports and produce the two-tier Korean report defined by the ko-eli5 skill.
Never act on the report; only rewrite it. Never alter the English appendix.
```

## 출력 형태

```markdown
## 일부 완료 - T-0412 메시지 유실 원인 확인

Streams 방식은 유실이 없고, 지금 쓰는 방식은 유실이 있을 가능성이 높아요.

**확인된 것**
- [확인] Streams(컨슈머 그룹) 루프는 500번 발행 중 유실 0건 (`tests/stream_test.py::test_no_loss`)

**추정 / 가정**
- [추정] Pub/Sub은 받는 쪽이 툴 실행 중이면 메시지를 놓쳐요. 수동 3회 모두 1~2건 유실
- [가정] 운영이 Pub/Sub이라는 건 확인 안 됨 (확인하려면: `redis-cli PUBSUB CHANNELS`)

**결정 필요**
- 질문: 지금 바로 Streams로 넘길지, 일주일 이중 쓰기(dual-write) 후 넘길지
  - A 바로 전환: 빠르지만 되돌리기 어려움 / B 이중 쓰기: 일주일 더 걸리지만 안전
  - 답 없으면 기본 동작: B

<details><summary>English technical report (verbatim)</summary>
(영어 원문 그대로)
</details>
```

위쪽 한국어는 요약이라 단순화가 허용되고, 아래 영어 원문은 한 글자도 바꾸지 않습니다. 다른 에이전트나 세션과 결과를 대조할 때는 영어 원문을 씁니다.

## 청중 바꾸기

`skills/ko-eli5/references/audience.md` 하나만 고치면 됩니다. 기본값은 "기술 배경이 있는 의사결정자"이고, 문장 끝은 -해요체입니다.

## 평가

ELI5의 하네스를 그대로 씁니다. `claude` CLI가 필요합니다.

```bash
cd skills/ko-eli5/evals
python run-evals.py                          # 스킬 있음 vs 없음 비교
python run-evals.py --test=2                 # 특정 케이스만
python run-evals.py --a ../SKILL.md --b ~/experiments/SKILL-v2.md   # 두 버전 A/B
```

테스트 6개: `result` 완료 / 일부 완료 / 실패, `blocker`, 라벨 없는 산문 입력(전부 `[가정]`으로 내려가는지), 용어집 준수.

하네스는 ELI5 원본 그대로라 `claude -p`로만 생성·채점합니다. 다른 런타임(Agent SDK, 다른 모델)이나 채점자 분리는 아직 지원하지 않습니다. 또 `claude -p`가 `~/.claude/skills/`의 humanizer 3종을 찾지 못하면 Step 5가 빠진 채 채점되어 수치가 실제보다 좋게 나올 수 있으니, 평가 전에 세 스킬이 설치돼 있는지 확인하세요.

## 원본 대비 바꾼 파일 / 안 바꾼 파일

- **바꿈:** `skills/ko-eli5/SKILL.md` (ELI5 `skills/eli5/SKILL.md`에서 파생), `skills/ko-eli5/evals/run-evals.py` (ELI5 `eli5-workspace/run-evals.py`에서 기본 경로와 라벨만 변경), `skills/ko-eli5/evals/evals.json` (형식만 같고 내용은 새로 작성)
- **새로 작성:** `skills/ko-eli5/references/*`, `skills/ko-eli5/examples/*`
- **원본 그대로:** `skills/humanizer/`, `skills/grammar-checker/`, `skills/style-guide/` (DaleSeo/korean-skills v1.x 시점 스냅샷)

## 라이선스

MIT. 원본 저작권 고지는 `LICENSE`와 `NOTICE.md`에 있습니다.

- DreambigOu/ELI5: MIT
- DaleSeo/korean-skills: MIT, Copyright (c) 2026 Dale Seo
