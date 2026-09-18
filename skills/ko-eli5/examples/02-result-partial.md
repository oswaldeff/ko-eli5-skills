# Example 02: `result` with status partial

## Input (English agent report)

```yaml
type: result
task_id: T-0412
status: partial
summary: >
  Streams path verified loss-free under test. Pub/Sub loss reproduced manually but not yet automated.
  Production transport not confirmed.
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

## Output (Korean report)

```markdown
## 일부 완료 - T-0412 메시지 유실 원인 확인

Streams 방식은 유실이 없고, 지금 쓰는 방식은 유실이 있을 가능성이 높아요. 운영 환경이 정말 Pub/Sub인지는 아직 확인 안 됐어요.

**확인된 것**
- [확인] Streams(컨슈머 그룹) 루프는 500번 발행 중 유실 0건 (`tests/stream_test.py::test_no_loss`)

**추정 / 가정**
- [추정] Pub/Sub은 받는 쪽이 툴 실행 중이면 메시지를 놓쳐요. 수동 3회 모두 1~2건 유실, 자동화 테스트는 아직 없음
- [가정] 운영이 Pub/Sub이라는 건 확인 안 됨 (확인하려면: `redis-cli PUBSUB CHANNELS`)

**결정 필요**
- 질문: 지금 바로 Streams로 넘길지, 일주일 이중 쓰기(dual-write) 후 넘길지
  - A 바로 전환: 빠르지만 되돌리기 어려움 / B 이중 쓰기: 일주일 더 걸리지만 안전
  - 답 없으면 기본 동작: B

<details>
<summary>English technical report (verbatim)</summary>

(위 YAML 원문 그대로)

</details>
```
