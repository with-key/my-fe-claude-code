# API 연동 스펙: {{기능명}}

> 원본 문서: {{원본 경로}}
> 생성일: {{날짜}}

## 개요

{{API 연동 요약}}

---

## 엔드포인트 목록

| Method | Path | 설명 |
|--------|------|------|
| `{{METHOD}}` | `{{/api/path}}` | {{설명}} |

---

## 엔드포인트 상세

### {{METHOD}} {{/api/path}}

**설명:** {{엔드포인트 설명}}

#### Request

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

**Path Parameters:**
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| {{param}} | `{{타입}}` | {{Y/N}} | {{설명}} |

**Query Parameters:**
| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| {{param}} | `{{타입}}` | {{Y/N}} | {{기본값}} | {{설명}} |

**Request Body:**
```typescript
interface {{RequestType}} {
  {{필드}}: {{타입}};
}
```

**예시:**
```json
{
  "{{필드}}": "{{값}}"
}
```

#### Response

**성공 (200):**
```typescript
interface {{ResponseType}} {
  {{필드}}: {{타입}};
}
```

**예시:**
```json
{
  "{{필드}}": "{{값}}"
}
```

---

## 에러 처리

| Status Code | 에러 코드 | 메시지 | 처리 방법 |
|-------------|-----------|--------|-----------|
| 400 | `{{코드}}` | {{메시지}} | {{처리}} |
| 401 | `UNAUTHORIZED` | 인증 실패 | 로그인 페이지로 이동 |
| 403 | `FORBIDDEN` | 권한 없음 | 권한 안내 표시 |
| 404 | `NOT_FOUND` | 리소스 없음 | 빈 상태 표시 |
| 500 | `INTERNAL_ERROR` | 서버 오류 | 에러 화면 표시 + 재시도 |

---

## 프론트엔드 타입 정의

```typescript
// Request
interface {{RequestType}} {
  {{필드}}: {{타입}};
}

// Response
interface {{ResponseType}} {
  {{필드}}: {{타입}};
}

// Error
interface ApiError {
  code: string;
  message: string;
  details?: Record<string, string>;
}
```

---

## 호출 패턴

```typescript
// React Query 사용 예시
const use{{기능}}Query = (params: {{RequestType}}) => {
  return useQuery({
    queryKey: ['{{키}}', params],
    queryFn: () => api.{{method}}('{{path}}', params),
  });
};

const use{{기능}}Mutation = () => {
  return useMutation({
    mutationFn: (data: {{RequestType}}) => api.{{method}}('{{path}}', data),
  });
};
```

---

## 주의사항

- {{주의사항 1}}
- {{주의사항 2}}
