# Example 03: `blocker`

## Input (English agent report)

```yaml
type: blocker
task_id: T-0421
question: "Which Redis instance is production? Two hosts respond and both have an agents:msgs key."
why_blocking: "Cannot run PUBSUB CHANNELS / XINFO on the right host without knowing which one is live."
tried:
  - "Checked .env files in repo: REDIS_URL points to redis-a, but docker-compose.prod.yml points to redis-b"
  - "Asked worker-infra via question msg 7f3a...; no reply in 30 min"
options:
  - {label: "A", tradeoff: "Treat redis-a as prod (matches .env); risk: wrong host, wasted diagnosis"}
  - {label: "B", tradeoff: "Wait for human confirmation; risk: idle time"}
default_if_no_answer: "halt"
```

## Output (Korean report)

```markdown
## 막힘 - T-0421 운영 Redis가 어느 쪽인지 확인 필요

운영 Redis 서버가 두 대 중 어느 쪽인지 몰라서 진단을 시작하지 못하고 있어요. 답이 없으면 멈춘 상태로 기다려요.

**확인된 것**
- [확인] 저장소 `.env`는 `redis-a`, `docker-compose.prod.yml`은 `redis-b`를 가리킴. 둘이 서로 다름
- [확인] 두 호스트 모두 응답하고 둘 다 `agents:msgs` 키가 있음
- [확인] worker-infra에 질문을 보냈지만 30분간 답 없음 (메시지 `7f3a...`)

**결정 필요**
- 질문: 운영 Redis는 `redis-a`인가 `redis-b`인가
  - A `redis-a`로 간주(.env 기준): 바로 진행 가능하지만 틀리면 진단이 헛수고 / B 확인될 때까지 대기: 안전하지만 시간 소모
  - 답 없으면 기본 동작: 멈춤(halt)

<details>
<summary>English technical report (verbatim)</summary>

(위 YAML 원문 그대로)

</details>
```

Notes: everything in `tried[]` is `measured` (the agent did those things), so all bullets are `[확인]`.
The `question` and `default_if_no_answer` fields map directly to the 결정 필요 block.
