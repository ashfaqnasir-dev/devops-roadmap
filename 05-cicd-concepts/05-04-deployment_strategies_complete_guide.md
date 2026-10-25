# 🚀 05.04 Deployment Strategies — Complete Guide

> **Deployment Strategy** woh tareeqa-e-kaar (pattern) hai jiske tehat application ka naya version live users tak pohnchaya jata hai. Sahi deployment strategy choose karne ka maqsad **zero downtime**, **minimal user impact**, aur masla aane par **fastest rollback** achieve karna hota hai.

---

## Quick Comparison Matrix

| Strategy | Downtime | Resource Cost | Rollback Speed | Risk Level | Complexity |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Blue-Green** | **None** ($0$) | **Double** ($2\times$) | **Instant** (DNS/Router switch) | Bohat Kam | Moderate |
| **Canary** | **None** ($0$) | Thora zyada ($+10-20\%$) | **Fast** (Traffic dial back) | Minimal | High (Monitoring required) |
| **Rolling** | **None** ($0$) | Normal ($1\times$ ya $+1$ node) | Slow (Reverse rolling rollout) | Low to Medium | Low (Built into K8s) |
| **Recreate** | **Mawjood** (Minutes) | Sabse Kam ($1\times$) | Slow (Purana version re-deploy) | High | Minimal |
| **Feature Flags** | **None** ($0$) | No extra infra | **Instant** (Toggle switch) | Lowest | Requires App Code changes |

---

## 1. Blue-Green Deployment (Instant Switchover)

Blue-Green strategy mein do aik jaise (identical) production environments chalte hain:
* **Blue:** Current live environment (jahan asal users ka traffic ja raha hai).
* **Green:** Idle/Staging environment (jahan naya version deploy hota hai aur test kiya jata hai).

```
Step 1: Testing Phase
                    ┌──────────────┐
                    │ Load Balancer│ ──100% Traffic──► [ Blue (v1.0 - Live) ]
                    └──────────────┘
                           │
                      (No traffic) ─────────────────► [ Green (v2.0 - Staging/Testing) ]

Step 2: Instant Switchover
                    ┌──────────────┐
                    │ Load Balancer│ ──100% Traffic──► [ Green (v2.0 - Live Now) ]
                    └──────────────┘
                           │
                      (Standby) ────────────────────► [ Blue (v1.0 - Idle / Fallback) ]
```

### Flow:
1. Naya version Green environment par deploy kiya jata hai.
2. Internal QA team Green par automated smoke tests chalati hai.
3. Jab sab verify ho jaye, Router / Load Balancer / DNS ko switch kar diya jata hai taake sara public traffic Green par transfer ho jaye.
4. Blue environment ko standby rakha jata hai taake agar koi emergency bug mile toh **foran switch back** kiya ja sake.

* **Fawaid:** Zero downtime, instant rollback, production par direct testing ka moka.
* **Nuqsaan:** Infrastructure ka kharcha double ho jata hai kyunki aik hi waqt mein do poore setups chalte hain. Database schema changes ko dono versions ke sath backwards-compatible rakhna parta hai.

---

## 2. Canary Deployment (Percentage-based Risk Mitigation)

Canary strategy mein naye version ko aik dam sab users ke samne lane ke bajaye **chhotay percentage (e.g. 5%)** ke samne laya jata hai.

> 💡 **Naam ki Tareekh:** Purane zamane mein koyle ki kanon (coal mines) mein karkun aik Canary chiriya sath le jate the. Agar zaharili gas leak hoti toh chiriya pehle asar leti thi, jisse karkun foran bahr nikal aate the. Software mein 5% users hamare Canary test hotay hain!

```
                    ┌─────────────────────────┐
Traffic Entry ─────►│ Ingress / API Gateway   │
                    └───────────┬─────────────┘
                                │
                 ┌──────────────┴──────────────┐
                 ▼ (95% Traffic)               ▼ (5% Traffic)
        [ Baseline (v1.0) ]           [ Canary Pods (v2.0) ]
                 │                             │
                 ▼                             ▼
        Stable Error Rate            Metrics Monitor (APM / Prometheus)
                                     - Error rate < 0.1%?
                                     - Latency normal?
                                          ├── ✅ YES: 5% ──► 25% ──► 50% ──► 100%
                                          └── ❌ NO: Auto-revert traffic to 0%
```

### Flow:
1. Naya code Canary pods par deploy hota hai jo kul capacity ka aik chhota hissa hote hain.
2. Routing layer (Service Mesh, Ingress, ya CDN) 5% request Canary ki taraf redirect karti hai.
3. Automated monitoring (Prometheus, Datadog) HTTP 5xx errors aur latency spikes check karti hai.
4. Agar metrics stable rahein toh traffic badha kar 10%, 25%, 50%, aur aakhir mein 100% kar diya jata hai.

* **Fawaid:** Agar koi fatal bug ya memory leak ho toh sirf chand users mutasir hotay hain, 100% outage se bacha ja sakta hai.
* **Nuqsaan:** High observability setup (Grafana, alerts, automated traffic shifters jaise Argo Rollouts ya Flagger) zaroori hota hai.

---

## 3. Rolling Deployment (Phased Pod Replacement)

Rolling deployment Kubernetes aur modern container orchestrators ka **default pattern** hai. Isme purane containers/servers ko aik aik karke (ya batch wise) naye version se replace kiya jata hai.

```
Initial:      [ v1 ]  [ v1 ]  [ v1 ]  [ v1 ]   (100% v1)
Step 1:       [ v2 ]  [ v1 ]  [ v1 ]  [ v1 ]   (25% v2, 75% v1)
Step 2:       [ v2 ]  [ v2 ]  [ v1 ]  [ v1 ]   (50% v2, 50% v1)
Step 3:       [ v2 ]  [ v2 ]  [ v2 ]  [ v1 ]   (75% v2, 25% v1)
Complete:     [ v2 ]  [ v2 ]  [ v2 ]  [ v2 ]   (100% v2)
```

### Kubernetes Example (`maxSurge` aur `maxUnavailable`):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Rollout ke dauran zyada se zyada 1 extra pod ban sakta hai
      maxUnavailable: 0  # Rollout ke dauran koi bhi pod down nahi hona chahiye
  template:
    metadata:
      labels:
        app: payment
    spec:
      containers:
      - name: app
        image: payment-service:v2.0
```

* **Fawaid:** Zero downtime, extra hardware ka kharcha na hone ke barabar, Kubernetes mein built-in support.
* **Nuqsaan:** Rollout ke dauran v1 aur v2 dono aik sath chal rahe hotay hain, isliye application aur database ko backward aur forward compatible hona laazmi hai.

---

## 4. Recreate Deployment (Stop All, Start All)

Recreate strategy sabse aasan magar sabse purana tareeqa hai: Pehle chalne wale purane tamam instances ko **aik sath band (kill)** kar diya jata hai, aur phir naye version ke instances start kiye jaate hain.

```
State 1:  [ v1 ]  [ v1 ]  [ v1 ]   (Running)
State 2:    ❌      ❌      ❌     (Shutdown - DOWNTIME START ⚠️)
State 3:  [ v2 ]  [ v2 ]  [ v2 ]   (Booting up & Serving)
```

* **Fawaid:**
  * Do alag versions aik sath kabhi nahi chalte, isliye complex database migrations ya breaking API changes ke waqt asan rehta hai.
  * Resources aur orchestration ki koi tension nahi hoti.
* **Nuqsaan:**
  * **Guaranteed Downtime:** Jab tak naya container boot up ho kar traffic lene ke qabil nahi banta, users ko 502/503 errors ya maintenance page milta hai.
* **Ideal Use Case:** Internal non-critical portals, staging/dev environments, ya batch processing pipelines jahan downtime manzoor ho.

---

## 5. Feature Flags (Decoupling Deploy from Release)

Traditional software mein code deploy karne ka matlab hota tha ke feature fauran live ho gaya. **Feature Flags (Toggles)** code deploy karne aur feature ko user ke liye on karne ke darmiyan farq paida karte hain:

> *"Code deploy ho chuka hai, magar feature off hai!"*

```
[ Incoming Request ]
         │
         ▼
if (FeatureFlag.isEnabled("NEW_CHECKOUT_FLOW", user)) {
    // Naya feature code chalayein
    return renderReactCheckout();
} else {
    // Purana stable code chalayein
    return renderLegacyCheckout();
}
```

```
                     ┌──────────────────────────────────┐
                     │ Feature Flag Dashboard           │
                     │ (e.g. LaunchDarkly / Unleash)    │
                     └────────────────┬─────────────────┘
                                      │
                     Toggle: NEW_CHECKOUT = ON (Beta Testers Only)
                                      │
                 ┌────────────────────┴────────────────────┐
                 ▼                                         ▼
      [ Internal Beta Testers ]                   [ General Public ]
         Sees: New UI v2                             Sees: Old UI v1
```

### Best Practices:
1. **Kill Switch:** Agar naye feature mein achanak database crash ho jaye, toh pipeline rollback kiye bina control room se flag `OFF` kar dein.
2. **Targeted Rollout:** Feature ko sirf specific country ya beta users (`user.isBeta == true`) ke liye open karein.
3. **Flag Cleanup (Technical Debt):** Jab feature 100% stable ho jaye, purana `if/else` block delete karke flag code se remove karna zaroori hota hai.

---
**Status:** ✅ Complete