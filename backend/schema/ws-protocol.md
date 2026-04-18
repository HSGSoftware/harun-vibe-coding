# WebSocket Protocol — Harun Vibe Coding

Authoritative on-wire message shapes live in `plan.md` §6. This file is the in-repo quick reference.

## Endpoint

`ws://<host>:8080/ws` — single endpoint, multiple logical channels.

## Envelope

```json
{
  "channel": "chat",
  "type": "chat.text",
  "id": "uuid-v4",
  "timestamp": 1729300000000,
  "payload": { ... }
}
```

- `channel`: `chat` | `terminal` | `events` | `fs` | `ai_events` | `control`
- `type`: dotted, channel-prefixed (e.g. `chat.text`, `terminal.data`, `events.project_status`)
- `id`: required for resume-on-reconnect (`{"type":"resume","payload":{"from_id":"..."}}`)
- `timestamp`: UNIX millis
- `payload`: snake_case keys

## Client → Server

| Type | Payload | Notes |
|---|---|---|
| `subscribe` | `{channels:[...]}` | Enable channel delivery |
| `unsubscribe` | `{channels:[...]}` | Stop channel delivery |
| `ping` | `{t}` | Keepalive (server replies `control.pong`) |
| `resume` | `{from_id}` | Replay missed messages from 3-minute cache |
| `chat.input` | `{conversation_id, text, context_files[], images[], options{model,max_tokens,extended_thinking}}` | Start/continue AI turn |
| `chat.abort` | `{conversation_id}` | Stop current generation |
| `chat.tool_decision` | `{tool_use_id, decision, remember}` | Reply to permission_request |
| `terminal.attach` | `{terminal_id}` | Subscribe to PTY I/O |
| `terminal.input` | `{terminal_id, data}` | Write to PTY stdin |
| `terminal.resize` | `{terminal_id, cols, rows}` | Resize PTY |

## Server → Client

| Type | Notes |
|---|---|
| `chat.start` | Response stream begins |
| `chat.thinking` | Extended-thinking delta |
| `chat.text` | Text delta (flushed every 50 ms) |
| `chat.tool_call_start` / `chat.tool_input_delta` / `chat.tool_call_end` | Streaming tool call |
| `chat.permission_request` | Pauses CLI; client replies with `chat.tool_decision` |
| `chat.tool_result` | Tool output |
| `chat.done` | Final stats |
| `chat.error` | Generation error |
| `terminal.data` / `terminal.exit` | PTY chunks / exit code |
| `events.project_status` / `events.project_log` / `events.tunnel_ready` / `events.backup_*` / `events.notification` / `events.setup_required` | Server-side events |
| `fs.change` | File mutation (kind: create/modify/delete/rename) |

## Reliability

- Ping every 30 s client-side; 60 s timeout → reconnect with last `id`
- `chat.text` flushed at 50 ms intervals to avoid UI thrash
- Backpressure: up to 1 MB buffered per client; overflow → `chat.error {error:"backpressure_exceeded"}`
