# Korean-context analogy bank

Replaces ELI5's English-culture analogies (phone book, playground, waiter). Use **one** analogy at most, and
only when the concept is genuinely unfamiliar to the reader defined in `audience.md`. When in doubt, skip it.

| Concept | Analogy |
|---|---|
| index / lookup structure | 아파트 우편함 호수표. 전 세대를 돌지 않고 바로 찾는다 |
| message queue / stream | 택배 집하장. 받는 쪽이 자리를 비워도 물건은 쌓여 있다 |
| pub/sub message loss | 방송 안내. 그 순간 자리에 없으면 못 듣고 끝 |
| consumer group + ack | 배달앱 "배달 완료" 버튼. 누르기 전까진 미처리로 남는다 |
| idempotency | 엘리베이터 버튼. 여러 번 눌러도 한 번 온다 |
| race condition | 은행 창구 두 곳에서 같은 통장을 동시에 처리 |
| feature flag | 두꺼비집 차단기. 코드는 두고 스위치만 내린다 |
| regression | 수리 후 다른 곳이 고장 |
| flaky test | 어떤 날은 걸리고 어떤 날은 안 걸리는 지하철 환승 |
| shared decision log | 사무실 화이트보드. 모두가 지나가며 본다 |
| rate limit | 고속도로 톨게이트 |
| technical debt | 미뤄둔 아파트 배관 공사 |
| cache | 책상 위에 꺼내둔 자주 쓰는 서류 |
| retry with backoff | 통화 중일 때 점점 간격을 늘려 다시 거는 것 |
| schema migration | 이사하면서 짐 분류 기준을 바꾸는 것 |
| dual-write migration | 새 주소로 우편물 전달 서비스 걸어두고 이사하는 것 |

Add rows as new concepts appear in reports. Keep analogies to everyday Korean life; avoid ones that need
their own explanation.
