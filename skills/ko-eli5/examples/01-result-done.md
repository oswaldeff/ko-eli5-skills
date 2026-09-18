# Example 01: `result` with status done

## Input (English agent report)

```yaml
type: result
task_id: T-0418
status: done
summary: >
  Added a regression test for the stream consumer and fixed the off-by-one in XACK batching that caused
  the last message of each batch to be re-delivered. All 42 tests pass.
claims:
  - text: "Last message of every XREADGROUP batch was re-delivered once"
    class: measured
    evidence: "tests/consumer_test.py::test_no_redelivery (fails on main, passes on branch)"
  - text: "Root cause is `range(len(ids) - 1)` in lib/consumer.py:88"
    class: measured
    evidence: "lib/consumer.py:88 diff"
  - text: "No other call site has the same pattern"
    class: inferred
    evidence: "grep for 'range(len(' in lib/ returned 1 hit"
changes:
  - {path: "lib/consumer.py", kind: modified, note: "XACK batching loop bound"}
  - {path: "tests/consumer_test.py", kind: added, note: "regression test"}
verification:
  - {cmd: "pytest -q", outcome: pass, excerpt: "42 passed in 3.1s"}
tried_and_rejected:
  - {approach: "Ack each message individually", why_rejected: "3x more round trips; batching bug was fixable"}
open_questions: []
```

## Output (Korean report)

```markdown
## 완료 - T-0418 마지막 메시지 중복 전달 수정

각 묶음의 마지막 메시지가 한 번씩 다시 전달되던 문제를 고쳤고, 재발 방지용 회귀 테스트도 넣었어요.

**확인된 것**
- [확인] 묶음(batch)마다 마지막 메시지가 한 번 더 전달되고 있었음 (`tests/consumer_test.py::test_no_redelivery`, main에서는 실패, 수정 브랜치에서는 통과)
- [확인] 원인은 `lib/consumer.py:88`의 반복 범위가 하나 짧았던 것
- [확인] 전체 테스트 42개 통과 (`pytest -q`, 3.1초)

**추정 / 가정**
- [추정] 같은 패턴이 다른 곳에는 없음 (lib/ 안에서 `range(len(` 검색 결과 1건)

**시도했다가 접은 것**
- 메시지를 하나씩 처리 확인(ack)하는 방식 (이유: 왕복 횟수가 3배로 늘어남. 묶음 처리 버그 자체가 고칠 수 있는 것이었음)

<details>
<summary>English technical report (verbatim)</summary>

(위 YAML 원문 그대로)

</details>
```

Notes: no 결정 필요 block because `open_questions` is empty; the section is omitted, not written as "없음".
No analogy because the reader knows what batching is.
