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
