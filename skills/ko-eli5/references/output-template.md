# Output template (two tiers)

Tier 1 is Korean and may simplify. Tier 2 is the English source, verbatim. Both are always present.

```markdown
## {상태} - {task_id} {한 줄 제목}

{Step 3의 what 한 문장}

{필요할 때만: 비유 한 단락}

**확인된 것**
- [확인] ...

**추정 / 가정**
- [추정] ...
- [가정] ... (확인하려면: ...)

**시도했다가 접은 것**
- ... (이유: ...)

**결정 필요**
- 질문: ...
  - A: ... / B: ...
  - 답 없으면 기본 동작: ...

<details>
<summary>English technical report (verbatim)</summary>

{원문 그대로. 한 글자도 바꾸지 않는다}

</details>
```

Rules:
- `{상태}` is one of 완료 / 일부 완료 / 실패 / 막힘.
- Omit an empty section entirely (e.g. no 시도했다가 접은 것 if the source has none). Do not write "없음".
- If the channel cannot render `<details>` (Slack), use `### English technical report (verbatim)` instead
  and keep the body untouched.

## Terminal variant (default in Claude Code)

HTML does not render in a terminal, so the appendix uses a plain separator. Same tiers, same rules.

```
완료 - {한 줄 제목}

{what 한 문장}

확인된 것
- [확인] ...

추정 / 가정
- [추정] ...
- [가정] ... (확인하려면: ...)

시도했다가 접은 것
- ... (이유: ...)

결정 필요
- 질문: ...
  - A: ... / B: ...
  - 답 없으면 기본 동작: ...

---
Technical appendix (EN)
---
changes: lib/consumer.py:88, modified, XACK batch loop bound
ran: pytest -q -> 42 passed
verified: redelivery test fails on main, passes on branch
not verified: behaviour under XAUTOCLAIM re-delivery
decisions: kept batching over per-message ack (3x fewer round trips)
```

## Short-answer variant

For a factual question with nothing executed: 1-3 sentences, labels inline, no template, no appendix.

```
[확인] `XACK`는 읽은 시점이 아니라 처리가 끝난 뒤에 보내야 해요. 그 전에 보내면 처리 중 죽었을 때 메시지가 사라져요. [추정] 지금 코드는 읽은 직후에 보내는 것처럼 보이는데, `lib/consumer.py`를 직접 열어보진 않았어요.
```
