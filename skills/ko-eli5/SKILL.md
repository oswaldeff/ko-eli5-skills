---
name: ko-eli5
description: Rewrite an English technical report (agent result, blocker, decision, or any engineering summary) into a Korean report the human owner can understand at a glance, then run the Korean QA pipeline (humanizer → grammar-checker → style-guide). Use this before every report to the human, and whenever the user says "보고해", "정리해서 알려줘", "쉽게 설명해", "사람용으로", "한국어로 보고", "ELI5", or asks what an agent result means.
argument-hint: "[path-to-english-report | paste]"
license: MIT
metadata:
  author: oswaldeff
  version: "0.1.0"
  derived-from: "DreambigOu/ELI5 (structure, audience framing), DaleSeo/korean-skills (Korean QA pipeline)"
---

# KO-ELI5: English agent report → Korean owner report

This skill is a recomposition of two upstream skills:
- **DreambigOu/ELI5** provides the structure (identify audience → read source → craft explanation) and the
  audience-framing tables. Here the audience is *fixed* instead of detected.
- **DaleSeo/korean-skills** (`humanizer`, `grammar-checker`, `style-guide`) provides the Korean QA pass.
  They are used as a quality layer on the Korean output, not as a translation step.

Design rule: **do not write English-simple first and then translate.** Reframe for the reader and write in
Korean in one pass. A translation hop produces translation-ese, which is exactly what `humanizer` then has
to remove. The full-fidelity English source is preserved verbatim as an appendix, so the Korean tier may
simplify without losing anything.

## Step 1: Load the fixed audience

Read `references/audience.md`. That is the reader. You do not detect the audience from the prompt.
Frame around what the reader wants first, in this order:
1. Is it done or not.
2. What was confirmed vs. what is still a guess.
3. What they need to decide now.
4. What was tried and dropped, so they don't suggest it again.

## Step 2: Read the English source

The input is normally an agent message body (`result`, `blocker`, `decision`) or several of them. It may
also be free-form English prose from another agent or session. Extract, in this order:

1. `status` (done / partial / failed / blocked). This becomes the first line of the Korean report.
2. `claims[]` with their `class`: `measured` / `inferred` / `assumed`. **Never merge classes.**
3. `open_questions[]` and `default_if_no_answer`. These become the 결정 필요 block.
4. `tried_and_rejected[]`. Preserved so the human doesn't re-suggest them.
5. `verification[]`. Which tests or commands actually ran, and their outcome.

If the source is prose rather than structured, reconstruct these five before writing anything.
If a claim has no class, treat it as `assumed` and say so. If status is not stated, infer it from the
verification results and label the inference.

## Step 3: Write the Korean summary tier

Follow the ELI5 structure (what → analogy → details → so what), in Korean:

1. **What**: one sentence. Starts with the status word: 완료 / 일부 완료 / 실패 / 막힘.
2. **Analogy**: only if the concept is genuinely unfamiliar to the reader. One analogy, taken from
   `references/analogies-ko.md`. Skip it when the reader already knows the concept; a forced analogy reads
   as padding.
3. **Details**: bullet list. Every bullet carries exactly one evidence-class prefix:
   `[확인]` = measured, `[추정]` = inferred, `[가정]` = assumed.
   Numbers stay as numbers with units. File paths and test names stay as-is in backticks.
4. **So what**: the 결정 필요 block. What the human must decide, the options with a one-line trade-off
   each, and what happens by default if they don't answer.

Language rules for this tier:
- Korean sentences in -해요/-어요 register unless `references/audience.md` says otherwise.
- Korean term first, English in parentheses on first use only: 멱등성(idempotency).
- Terms in `references/glossary.md` are mandatory. Do not invent a second Korean rendering.
- Short. The summary tier should be readable in under a minute.
- ELI5's "80% accuracy is fine" applies here only because the 100% version is attached below.
  Status and evidence labels are never approximated.

Use the layout in `references/output-template.md`.

## Step 4: Attach the English appendix

Paste the English source verbatim inside:

```
<details>
<summary>English technical report (verbatim)</summary>

...

</details>
```

Do not edit, trim, reorder, or reformat it. This appendix is the unit other agents and other sessions use
for cross-checking; a paraphrased appendix defeats that purpose.

If the delivery channel cannot render `<details>` (for example Slack), replace the wrapper with a heading
`### English technical report (verbatim)` and keep the body untouched.

## Step 5: Korean QA pass (summary tier only)

Run these three skills, in this exact order, on the Korean summary tier. Do not run them on the English
appendix. If installed from this repository they are `humanizer`, `grammar-checker`, `style-guide`; if
installed from the upstream plugin they are `korean-skills:humanizer` and so on.

1. **`humanizer`**: remove Korean AI-writing patterns. Pay particular attention to the translation-ese
   category (에 대해 / 통해 / 있어서, 되어진다, 에 의해, 할 수 있다 overuse, ~것이다 overuse) and AI closing
   markers (결론적으로, 요약하면). These are the patterns an English-first draft produces.
2. **`grammar-checker`**: spelling, spacing, particles, punctuation. Run on humanizer's output, not on the
   original; humanizer changes sentences substantially.
3. **`style-guide`**: consistency. The Terminology check is where `references/glossary.md` is enforced:
   load the glossary as the authoritative term list. Also check that the `[확인]/[추정]/[가정]` prefixes are
   used consistently and that number/unit formatting is uniform.

Why this order: humanizer makes the largest sentence-level changes, so grammar runs on the stabilized text,
and style consistency only makes sense once the writing is stable. humanizer treats document-level uniform
formality as an AI signal; style-guide checks paragraph-level consistency. They operate on different layers
and don't conflict when run in this order. Do not reverse it.

**After the pass, the `[확인]/[추정]/[가정]` labels must still be present and unchanged.** If any QA step
removed or reworded a label, restore it. Labels are data, not style.

## Step 6: Final check before delivering

- The status word is on the first line.
- Every detail bullet has exactly one label, and the label matches the source class.
- Glossary terms match `references/glossary.md`; English appears in parentheses only on first use.
- The 결정 필요 block has options and a default action.
- The English appendix is untouched.
- No sentence begins with meta-narration (이제 설명하자면, 정리하면, 결론적으로).

## Example

**Input** (agent `result`, abridged):

```yaml
status: partial
claims:
  - text: "XREADGROUP loop drops no messages across 500 test publishes"
    class: measured
    evidence: "tests/stream_test.py::test_no_loss, 500/500"
  - text: "Pub/Sub path loses messages when consumer is mid tool-call"
    class: inferred
    evidence: "3/3 manual runs lost 1-2 msgs; not automated"
  - text: "Production uses Pub/Sub"
    class: assumed
open_questions: ["Cut over to Streams now, or dual-write for a week?"]
default_if_no_answer: "dual-write"
```

**Output**:

```markdown
## 일부 완료 - T-0412 메시지 유실 원인 확인

Streams 방식은 유실이 없고, 지금 쓰는 방식은 유실이 있을 가능성이 높아요. 운영 환경이 정말 Pub/Sub인지는 아직 확인 안 됐어요.

**확인된 것**
- [확인] Streams(컨슈머 그룹) 루프는 500번 발행 중 유실 0건 (`tests/stream_test.py::test_no_loss`)

**추정 / 가정**
- [추정] Pub/Sub은 받는 쪽이 툴 실행 중이면 메시지를 놓쳐요. 수동 3회 모두 1~2건 유실, 자동화 테스트는 아직 없음
- [가정] 운영이 Pub/Sub이라는 건 확인 안 됨 (확인하려면: `redis-cli PUBSUB CHANNELS`)

**결정 필요**
- 질문: 지금 바로 Streams로 넘길지, 일주일 dual-write 후 넘길지
  - A 바로 전환: 빠르지만 되돌리기 어려움 / B dual-write: 일주일 더 걸리지만 안전
  - 답 없으면 기본 동작: B

<details>
<summary>English technical report (verbatim)</summary>

(원문 그대로)

</details>
```

More input/output pairs: `examples/01-result-done.md`, `examples/02-result-partial.md`, `examples/03-blocker.md`.

## Reminders (kept from ELI5, adapted)

- Never talk down. The reader is technical; precision is respect. Simplicity comes from structure and from
  omitting narration, not from removing terms.
- Purpose before mechanism: say why a change was made before how.
- ELI5's "80% accuracy is fine" applies to the summary tier only, because the 100% version is attached.
- Labels (`[확인]/[추정]/[가정]`) are data. No QA step may alter them.
- Human constraints quoted in the source stay verbatim, in whatever language they were written.
