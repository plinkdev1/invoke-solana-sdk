# MAGMA_BACKEND_REFERENCE.md
## Backend Reference Implementation — Extracted from MAGMA Protocol (Fastify)
### For GodotMWA SDK — Godot Engine Android Solana Wallet Adapter

---

## Section 1: RPC Proxy Setup

### How Solana RPC is configured
No dedicated proxy route. RPC is called directly from services using
the Connection object. The connection is instantiated at service level:
```typescript
// Priority order: Helius RPC → devnet fallback
const rpc = process.env.HELIUS_RPC_URL
         || process.env.EXPO_PUBLIC_HELIUS_RPC_URL
         || 'https://api.devnet.solana.com';
const connection = new Connection(rpc, 'confirmed');
```

Devnet vs mainnet is determined by whether HELIUS_RPC_URL contains
'devnet' in the URL string — not a separate env var:
```typescript
const isDevnet = (process.env.HELIUS_RPC_URL || '').includes('devnet')
              || !process.env.HELIUS_RPC_URL;
```

### CORS config for mobile clients
Wildcard CORS on all routes — applied as a Fastify onRequest hook:
```typescript
server.addHook('onRequest', async (request, reply) => {
  reply.header('Access-Control-Allow-Origin', '*');
  reply.header('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  reply.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (request.method === 'OPTIONS') {
    reply.send(); // preflight
  }
});
```
No origin restriction. Fine for mobile-only beta. Tighten for mainnet.

### Caching on RPC responses
No caching layer on RPC calls. Every request hits Helius/devnet fresh.
Exception: Pyth price data is cached in Redis (magma-pyth queue refreshes
every 30s via pythWorker). All other RPC calls are uncached.

For GodotMWA: consider caching blockhash (max 60s valid), slot number
(valid ~400ms), and account state (application-dependent TTL).

---

## Section 2: Transaction Handling

### How transactions are built
Transactions are built server-side from backend instructions, then
sent to the mobile client for signing via MWA. The pattern:
```
Client → POST /v1/narratives/:id/back
Backend → fetches blockhash, builds Transaction
Backend → returns serialized tx OR instruction data
Client → signs via wallet.signTransactions() in transact()
Client → sends signed tx to Solana RPC
Client → polls for confirmation
```

In MAGMA's current impl (useMagmaTransactions.ts), instructions are
fetched from backend endpoints, deserialized client-side, assembled
into a Transaction, then signed via MWA. The backend does NOT sign
transactions — only the oracle keypair signs oracle-specific txns
(Kamino deposits/withdrawals).

### Blockhash freshness
Blockhash is fetched inside transact() callback immediately before
signing — not pre-fetched:
```typescript
const { recentBlockhash } = await connection.getLatestBlockhash();
transaction.recentBlockhash = recentBlockhash;
```
This is correct. Blockhash expires after ~60s (150 blocks). Fetching
it inside the MWA session ensures it's fresh when the user signs.
The gotcha: if the user takes >60s to approve in the wallet, the
blockhash expires and the tx will fail with BlockhashNotFound.
MAGMA has no retry on expired blockhash. For GodotMWA: detect
BlockhashNotFound and retry with a fresh blockhash automatically.

### Failed transaction retry
MAGMA has NO retry logic on failed transactions. One attempt, surface
error to user. For GodotMWA: implement exponential backoff retry
for network errors, NOT for user-rejected or simulation-failed errors.

### Confirmation polling strategy
MAGMA uses connection.confirmTransaction() with the durable nonce
pattern (blockhash + lastValidBlockHeight):
```typescript
const confirmation = await connection.confirmTransaction({
  signature,
  blockhash: recentBlockhash,
  lastValidBlockHeight: await connection.getBlockHeight(),
});
if (confirmation.value.err) {
  throw new Error('Transaction failed');
}
```
This is the correct modern pattern. The old signature-only
confirmTransaction() is deprecated. Always use the object form.

---

## Section 3: Auth/Session Patterns

### Wallet public key verification server-side
MAGMA does NOT verify wallet ownership server-side. The wallet address
is passed as a string in request body and trusted:
```typescript
// From backing route:
const { wallet_address, amount_sol } = request.body;
// wallet_address is used directly — no signature verification
```
This is acceptable for beta/devnet. For mainnet: require a signed
message proving wallet ownership before recording any on-chain action.

### Signed message verification pattern (not in MAGMA — recommended)
For GodotMWA backend:
```typescript
// Verify wallet owns the address they claim
const message = `MAGMA auth: ${timestamp}`;
const messageBytes = new TextEncoder().encode(message);
const signatureBytes = base58.decode(providedSignature);
const publicKeyBytes = new PublicKey(walletAddress).toBytes();
const valid = await ed.verify(signatureBytes, messageBytes, publicKeyBytes);
```

### Session tied to wallet address
Sessions are NOT server-side tracked. There is no session table,
no JWT, no server-side session store. The wallet address is the
identity — passed on every request in the request body or as a
header (x-admin-wallet for admin routes).

For admin routes, auth is middleware-checked against an env var list:
```typescript
const ADMIN_WALLETS = process.env.ADMIN_WALLETS?.split(',') || [];
if (!ADMIN_WALLETS.includes(adminWallet)) {
  return reply.status(403).send({ error: 'Unauthorized' });
}
```

---

## Section 4: Error Patterns Specific to Solana

### Solana-specific errors and handling

| Error | MAGMA handling | Correct handling |
|-------|---------------|-----------------|
| Transaction simulation failed | Generic throw | Surface simulation logs to client |
| BlockhashNotFound | NOT HANDLED | Retry with fresh blockhash |
| Transaction expired | NOT HANDLED | Retry with fresh blockhash |
| Insufficient lamports | Generic throw | Check balance before signing |
| Account not found | NOT HANDLED | Check account exists before tx |
| RPC timeout | Generic catch | Retry with backoff, fallback RPC |
| confirmTransaction timeout | NOT HANDLED | Poll with timeout + fallback |

### Transaction expired surfacing
MAGMA does not surface transaction expiry errors specifically. They
fall into the generic error handler. For GodotMWA: check
`error.message.includes('Blockhash not found')` and retry automatically.

### Network timeouts from Solana RPC
No explicit timeout on RPC calls. Node.js default fetch timeout applies
(typically 30s+). For GodotMWA: wrap all RPC calls with AbortSignal
timeout (10s for reads, 30s for confirmation):
```kotlin
// Kotlin equivalent
withTimeout(10_000) {
    rpcClient.getLatestBlockhash()
}
```

---

## Section 5: Rate Limiting

### Global rate limit
100 requests per minute per IP globally:
```typescript
rateLimit({
  global: true,
  max: 100,
  timeWindow: '1 minute',
  keyGenerator: (request) =>
    request.headers['x-forwarded-for']?.split(',')[0].trim() || request.ip,
})
```
Uses x-forwarded-for first (Railway/proxy header), falls back to IP.
Important: Railway sets x-forwarded-for — always use it, not request.ip.

### Per-route overrides
```typescript
// Backing: 10/min per wallet address
narrativeBackRateLimit = {
  config: { rateLimit: {
    max: 10, timeWindow: '1 minute',
    keyGenerator: (req) => req.body?.wallet_address || req.ip,
  }}
}

// Agent feed: 60/min per API key
agentFeedRateLimit = {
  config: { rateLimit: {
    max: 60, timeWindow: '1 minute',
    keyGenerator: (req) => req.headers['x-api-key'] || req.ip,
  }}
}

// Agent register: 5/hour per IP (anti-spam)
agentRegisterRateLimit = {
  config: { rateLimit: { max: 5, timeWindow: '1 hour' }}
}
```

Rate limit error response format:
```json
{
  "statusCode": 429,
  "error": "Too Many Requests",
  "message": "Rate limit exceeded. Retry in 42s.",
  "retryAfter": 42
}
```

---

## Section 6: Yield Integration (Kamino) — Solana-specific pattern

### Devnet/mainnet bifurcation pattern
MAGMA uses a simulation path for devnet that returns realistic mock data:
```typescript
if (!keypair || isDevnet) {
  // Return simulated result — never throws, always succeeds
  return {
    success: true,
    receipt: 'sim_' + narrativeId + '_' + Date.now(),
    estimatedApy: calculateDynamicApy(7.2, uncertaintyScore),
  };
}
// Mainnet path below — uses real Kamino SDK
```
The sim_ prefix on receipt is the devnet/mainnet discriminator used
throughout the codebase. On withdrawal: if receipt.startsWith('sim_')
→ return mock yield calculation.

### Non-blocking yield pattern
Kamino deposit failure does NOT fail the backing operation:
```typescript
try {
  kaminoResult = await depositToKamino(...);
  if (kaminoResult.success) {
    // update backing record with receipt
  } else {
    console.warn('[kamino] Deposit failed — backing still recorded');
    // backing is saved regardless
  }
} catch (kErr) {
  console.warn('[kamino] non-blocking:', kErr.message);
}
```
This is intentional — the backing is the primary action, yield is
additive. Never gate a backing transaction on an external protocol call.
For GodotMWA: apply same pattern to any DeFi integration.

### Dynamic APY formula
```typescript
// APY adjusts based on how uncertain the narrative is
// More uncertain = lower APY offered to backers
effectiveApy = baseApy * (1 - (uncertaintyScore / 200))
// Floor: 3.5% | Ceiling: 9.5%
effectiveApy = Math.min(9.5, Math.max(3.5, effectiveApy))
```

---

## Section 7: Mobile Client Specifics

### Request format from React Native client
All requests use JSON body. No special mobile headers required.
Content-Type: application/json only.

### Network interruption handling
MAGMA has NO retry logic for interrupted requests from the mobile
client. One attempt, error surfaced. For GodotMWA: implement request
retry with exponential backoff for network-class errors (timeout,
connection reset) but NOT for business logic errors (insufficient
funds, invalid input).

### Health check endpoint
Simple health check for monitoring and client connectivity test:
```
GET /v1/health → { "ok": true }
GET /health → { "ok": true }
```
MAGMA app uses this to check connectivity before attempting transactions.
For GodotMWA: poll /health before opening MWA session.

### Webhook pattern for on-chain events
MAGMA uses Helius webhooks for on-chain event detection:
```
POST /v1/webhooks/backing
  ← called by Helius when NarrativeBacked event fires on-chain
  ← verifies tx, updates DB, triggers scoring queue
```
For GodotMWA backend: register Helius webhooks for any on-chain
program events you need to react to server-side.

---

## Section 8: What I'd Do Differently for a GodotMWA Backend

**Carry over:**
- Fastify with pino logger — fast, structured, Railway-friendly
- Per-route rate limiting with wallet address as key
- Non-blocking DeFi integrations (yield failure ≠ action failure)
- Devnet simulation path with sim_ prefix discriminator
- durable nonce confirmTransaction pattern (blockhash + lastValidBlockHeight)
- x-forwarded-for for IP detection behind Railway/proxy

**Add for GodotMWA:**

1. **Signed message auth** — verify wallet ownership before recording
   any action. MAGMA skips this at beta; production needs it.

2. **Blockhash endpoint** — expose GET /v1/blockhash that returns fresh
   blockhash + lastValidBlockHeight. Godot client fetches this
   immediately before building a transaction, not from RPC directly.

3. **Transaction relay endpoint** — POST /v1/relay with signed tx bytes.
   Client signs in Godot via MWA, posts serialized tx to backend,
   backend submits and polls confirmation. Removes Solana RPC dependency
   from the Godot client entirely.

4. **Explicit retry on BlockhashNotFound** — detect this specific error
   on relay endpoint, fetch new blockhash, rebuild and re-submit once.

5. **Request timeout headers** — add server-side timeout (15s) on all
   RPC-touching routes. MAGMA relies on default Node.js timeouts.

6. **Mobile-specific error codes** — return machine-readable error codes
   alongside messages so Godot client can handle them programmatically:
```json
   { "error": "BLOCKHASH_EXPIRED", "message": "...", "retryable": true }
   { "error": "INSUFFICIENT_FUNDS", "message": "...", "retryable": false }
   { "error": "WALLET_REJECTED", "message": "...", "retryable": false }
```

---

*Extracted from MAGMA Protocol backend · ExiDante Corp · 2026-03-20*
*Feed to GodotMWA SDK agent at start of every backend implementation session*