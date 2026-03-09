---
name: deploy
description: "배포 전 검증(checklist/verify)과 릴리스 핸드오프 문서를 생성합니다."
user-invocable: true
argument-hint: "[checklist|verify|handoff]"
agent: deploy-assistant
allowed-tools: Read, Grep, Glob, Bash
---

# /deploy — 배포 검증 및 핸드오프

> 트리거 키워드: 배포, deploy, release, 롤백, handoff, 운영 전달

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 액션별 동작

**`/deploy checklist`** — 배포 전 체크리스트 생성
1. 현재 변경사항(`git diff`)을 기반으로 배포 영향 범위를 정리한다.
2. 아래 항목을 포함한 체크리스트를 출력한다:
   - 테스트 결과 확인
   - 보안/품질 리뷰 결과 확인
   - 환경 변수/설정 점검
   - 모니터링 및 롤백 계획 확인

**`/deploy verify`** — 배포 적합성 검증
1. 가능한 범위에서 테스트/빌드/타입체크 명령을 실행한다.
2. 실패 항목을 Blocker/Warning으로 분류한다.
3. 배포 가능 여부(`Ready`/`Not Ready`)를 근거와 함께 출력한다.

**`/deploy handoff`** — 릴리스 핸드오프 문서 생성
1. 변경 요약(무엇이 바뀌었는지)과 영향 범위를 정리한다.
2. 운영 전달용 정보(릴리스 노트, 관찰 지표, 롤백 절차)를 출력한다.

## 출력 형식

```
┌─ Deploy Verification ─────────────────────┐
│ Scope:   <검증 범위>                        │
│ Status:  Ready / Not Ready                │
│ Blocker: <개수>  Warning: <개수>            │
└────────────────────────────────────────────┘
```

## 주의사항
- 배포를 자동으로 실행하지 않는다. 검증/체크리스트/핸드오프만 제공한다.
- 프로젝트별 배포 환경이 다르면 명시적으로 가정/제약을 함께 출력한다.
