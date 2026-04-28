# Pine Labs ONE — Support Content Map
> Structure: Product → Topic → Question → Answer steps + Tagged video(s) + Device check flag
> Device check flag: triggers the health check API inline for offline devices only.
> Content gaps marked with `[GAP]` — needs content before prototype/launch.

---

## 1. Offline Devices
> Applies to: Touch · Go · Duo · Mini · VoicePod
> Device health check API available on this path.

---

### 1.1 Terminal & Hardware Issues

---

#### Alert irruption / unauthorised / tampered error on PoS
**Answer**
The machine has been corrupted due to improper handling. This cannot be resolved remotely.
1. Go to Support → Terminal Issues → Raise a Request → Submit.

**Tagged video:** —
**Device check:** No — hardware tamper requires manual intervention, not a remote ping.

---

#### Invalid Batch ROC or Invalid ISO Packet error
**Answer**
Activate and settle the batch, then retry a test transaction.

*Android devices:*
1. Open Payments app → Menu (☰) → Activate → Settle Batch
2. Run a test transaction

*Non-Android devices:*
1. User Menu → Activate → Settle Batch
2. Run a test transaction

If issue persists: Support → Terminal Issues → Raise a Request → Submit.

**Tagged video:** How to do batch settlement on Plutus Smart
**Device check:** Yes — run connectivity check to confirm gateway is reachable before advising batch settle.

---

#### No SIM or SIM Lock showing on PoS
**Answer**
1. Restart the PoS machine
2. Try a test transaction

If issue persists: Support → Terminal Issues → Raise a Request → Submit.

**Tagged video:** How to activate or check connectivity of a Pine Labs PoS
**Device check:** Yes — ping device to confirm SIM/network status before suggesting restart.

---

#### Batch Locked error
**Answer**
1. Restart the PoS machine
2. Activate and settle the batch
3. Run a test transaction

If issue persists: Support → Terminal Support → Raise a Request → Fill in details → Submit.

**Tagged video:** How to do batch settlement on Plutus Smart
**Device check:** Yes — connectivity check to confirm device can reach payment gateway.

---

#### Terminal restarting during transactions
**Answer**
1. Restart the terminal manually using the power button
2. Wait for it to fully boot
3. Run a test transaction

If issue persists: Support → Terminal Issues → Raise a Request → Fill in details → Submit.

**Tagged video:** How to use a Pine Labs PoS Terminal
**Device check:** Yes — run health check to determine if restart is software or connectivity triggered.

---

#### PoS terminal not responding during a transaction
**Answer**
1. Restart the machine
2. Settle the batch
3. Run a test transaction

If issue persists: Support → Terminal Issues → Raise a Request → Submit.

**Tagged video:** How to activate or check connectivity of a Pine Labs PoS
**Device check:** Yes — connectivity and app process check before escalation.

---

#### PoS machine display is blank
**Answer**
This may indicate a PoS application issue or a damaged screen.
1. Attempt a manual restart using the power button
2. If screen remains blank: Support → Terminal Issues → Raise a Request → Submit.

**Tagged video:** —
**Device check:** Yes — ping device to confirm if it is online or fully unresponsive.

---

#### Paper roll not coming out of printer
**Answer**
1. Open the printer compartment
2. Clean inside with a dry cotton cloth or tissue
3. Re-insert the paper roll with the **smooth/shiny side facing up**
4. Close the compartment and test print

If issue persists: Support → Terminal Issues → Raise a Request → Submit.

**Tagged video:** What to do if receipt doesn't print on a Pine Labs PoS
**Device check:** No — printer issue is mechanical, not network-related.

---

#### Battery or charger issues
**Answer**
1. Charge using the official Pine Labs charger for 4–5 hours
2. Try a different power socket
3. Try a different charger if available

If issue persists: Support → Terminal Issues → Raise a Request → Fill in details → Submit.

**Tagged video:** —
**Device check:** No — battery/charger is a hardware issue.

---

#### GPRS connectivity or network issues
**Answer**
1. Open Payments app → Menu → Set Connection → Set GPRS as top priority
2. Configure the following settings:
   - Transaction IP: `180.179.219.225`, Port: `8094`
   - Secondary IPs: `103.215.234.2` and `103.215.234.21`, Port: `8094`
   - Timeout: 60s send / 120s receive
   - User ID: `PINE1234` | Password: `PINE4321`
   - APN by carrier: Airtel → `airteliot.com` · VI → `apn.pinelabs` · Jio → `jio.net`
3. Submit → Activate

If issue persists: Support → Terminal Issues → Raise a Request → Submit.

**Tagged video:** How to activate or check connectivity of a Pine Labs PoS
**Device check:** Yes — run connectivity check first to confirm which layer is failing (SIM, APN, gateway).

---

#### What is my user ID and password for the PoS?
**Answer**
Use **1234** as both the user ID and password.

**Tagged video:** How to use a Pine Labs PoS Terminal
**Device check:** No.

---

### 1.2 Payments & Transactions

---

#### Failed transaction — what to do
**Answer**
A failed transaction means the payment did not go through. The customer has not been charged.
1. Check device connectivity
2. Ask the customer to retry with the same or a different payment method

**Tagged video:** How to accept credit/debit cards via Dip and Swipe on Plutus Smart
**Device check:** Yes — run connectivity check to confirm gateway is reachable before retrying.

---

#### Pending transaction — how to check status
**Answer**
Use the Get Status option for the relevant device type:

*MINI Pro (Dynamic):*
1. Long press green button → Check Status → Press green button to view

*ICT / IWL / Move 2500:*
1. User Menu → Run Application → Menu → UPI → Get Status → Select transaction → Enter invoice number → Green button

*PAX:*
1. Payments tab → Tap to see → Browse other options → UPI → Get Status → Select transaction → Enter billing invoice details → Submit

> Note: Get Status is not available on Mini static device.

**Tagged video:** How to do UPI transactions on Pine Labs PoS
**Device check:** Yes — connectivity check to confirm device can reach the transaction status endpoint.

---

#### Session expired transaction — what to do
**Answer**
A session expired transaction means the payment did not go through. The customer has not been charged.
1. Ask the customer to retry

**Tagged video:** —
**Device check:** Yes — if sessions are expiring repeatedly, run connectivity check to diagnose gateway latency.

---

#### How to cancel or void a transaction
**Answer**
Follow the steps for your device type. Video walkthrough recommended.

**Tagged video:** How to void a sale transaction on Plutus Smart · How to void a transaction on Pine Labs PoS
**Device check:** No.

---

#### Where to find transaction data beyond 6 months
**Answer**
Up to 2 years of data is available.
1. Go to Reports → Transaction Detail Reports tab
2. Select the required date range

**Tagged video:** —
**Device check:** No.

---

### 1.3 Brand & Bank EMI

---

#### What is Brand EMI?
**Answer**
Brand EMI is a facility offered by brands that lets merchants sell products on EMI. It is available on the terminal after activation.

**Tagged video:** How to do Brand EMI transactions on a Pine Labs PoS
**Device check:** No.

---

#### Who can do brand or bank EMI transactions?
**Answer**
Eligibility depends on the merchant category code (MCC) associated with your business.
1. Support → Activate Brand EMI → Apply for Brand EMI → Select Store → Choose Brand & Product → Enter DMS/Dealer Code

**Tagged video:** How to do Brand EMI transactions on a Pine Labs PoS
**Device check:** No.

---

#### How to check if Brand EMI is active
**Answer**
1. Support → Activate Brand EMI → View active Brand EMIs → Select the relevant Store
(Available on both app and web.)

**Tagged video:** How to offer Brand EMI via Home app on Plutus Smart PoS
**Device check:** No.

---

#### What do I need to activate Brand EMI?
**Answer**
You will need:
- Brand name
- PoS ID / TID
- DMS Code

Raise a request: Support → Activate Brand EMI → Apply for Brand EMI.

**Tagged video:** How to offer Brand EMI via Catalogue app on Plutus Smart PoS
**Device check:** No.

---

#### How to track a Brand or Bank EMI activation request
**Answer**
1. Support → click "View All" next to Recent Support Tickets

**Tagged video:** —
**Device check:** No.

---

#### How to perform Brand EMI transactions on PoS
**Answer**
Follow the video tutorial for a step-by-step walkthrough using the Home app on Plutus Smart.

**Tagged video:** How to offer Brand EMI via Home app on Plutus Smart PoS · How to do Brand EMI transactions on a Pine Labs PoS
**Device check:** No.

---

#### How to perform Bank EMI transactions on PoS
**Answer**
Follow the video tutorial for a step-by-step walkthrough.

**Tagged video:** How to offer Bank EMI on Plutus Smart PoS · How to do Bank EMI transaction on a Pine Labs PoS
**Device check:** No.

---

#### How to settle batch for EMI transactions
**Answer**
EMI batch settlement follows a slightly different flow. Follow the video for the correct steps.

**Tagged video:** How to settle a batch for EMI transactions on Pine Labs PoS
**Device check:** No.

---

### 1.4 Settlements & MPR

---

#### What is MPR?
**Answer**
MPR stands for Merchant Payout Report. It contains:
- Payout amount
- Transaction date
- MDR charges
- Fund transfer date

Only aggregator merchants are eligible.

**Tagged video:** —
**Device check:** No.

---

#### How to receive or generate my MPR report
**Answer**
1. Reports → Settlements Report → MPR Report
2. Select date range → Generate Report

**Tagged video:** How to settle my batch on Android PoS · How to settle my batch on Non-Android PoS
**Device check:** No.

---

#### How to check MDR charges on a transaction or settlement
**Answer**
1. Login to Pine Labs One Web Portal
2. Payments → Settlement → View All Settlements
3. Select the relevant settlement → Click "View Deductions"

**Tagged video:** —
**Device check:** No.

---

#### Do I need to settle the batch to receive payment?
**Answer**
Yes. The batch must be settled at end of day. Failing to settle within 24 hours may result in late settlement charges from the acquiring bank.

**Tagged video:** How to do batch settlement on Plutus Smart
**Device check:** No.

---

## 2. Pine Checkout
> Applies to: Online / browser-based checkout
> No device health check on this path — no physical hardware to ping.

---

### 2.1 Payment Acceptance

---

#### Failed transaction — what to do
**Answer**
A failed transaction means the payment did not go through. The customer has not been charged.
1. Ask the customer to retry with the same or a different payment method
2. Check your internet connection if failures are repeated

**Tagged video:** —
**Device check:** No — no physical device.

---

#### Pending transaction — how to check status
**Answer**
1. Go to the Payments section in your Pine Labs One dashboard
2. Locate the transaction and use "Get Status"

**Tagged video:** —
**Device check:** No.

---

#### Session expired transaction — what to do
**Answer**
The payment did not go through. Ask the customer to retry.

**Tagged video:** —
**Device check:** No.

---

#### How to cancel or void a transaction
**Answer**
Follow the steps in the Pine Labs One dashboard under Payments → Transactions → select transaction → Void.

**Tagged video:** —
**Device check:** No.

---

### 2.2 Settlements

---

#### Settlement not received — what to do
**Answer**
1. Check that your batch was settled before the cutoff time
2. Login to Pine Labs One → Payments → Settlement → View All Settlements
3. If settlement is missing, raise a ticket with the settlement date and expected amount

**Tagged video:** —
**Device check:** No.

---

#### How to check MDR deductions
**Answer**
1. Pine Labs One Web Portal → Payments → Settlement → View All Settlements
2. Select settlement → Click "View Deductions"

**Tagged video:** —
**Device check:** No.

---

#### How to generate MPR report
**Answer**
1. Reports → Settlements Report → MPR Report
2. Select date range → Generate Report

**Tagged video:** —
**Device check:** No.

---

## 3. Other Products

---

### 3.1 UPI

---

#### Pending UPI transaction — how to check status
**Answer**
Device-specific steps:

*MINI Pro (Dynamic):*
1. Long press green button → Check Status → Green button to view

*ICT / IWL / Move 2500:*
1. User Menu → Run Application → Menu → UPI → Get Status → Select transaction → Invoice number → Green button

*PAX:*
1. Payments tab → UPI → Get Status → Select transaction → Enter billing invoice details → Submit

**Tagged video:** How to do UPI transactions on Pine Labs PoS · How to accept UPI payments via static QR on the Pine Labs terminal · How to accept payments via UPI on Plutus Smart
**Device check:** Yes — for offline devices using UPI, run connectivity check if status retrieval is failing.

---

#### UPI transaction failed — what to do
**Answer**
The payment did not go through. The customer has not been charged.
1. Confirm connectivity on the device
2. Ask the customer to retry

**Tagged video:** How to accept payments via UPI on Plutus Smart
**Device check:** Yes — for offline devices, run connectivity check.

---

### 3.2 DCC (Dynamic Currency Conversion)

#### How to enable DCC for international customers
**Answer**
Follow the video walkthrough to enable DCC so international customers can pay in their local currency.

**Tagged video:** How to enable Dynamic Currency Conversion (DCC) to help customers pay in their local currency
**Device check:** No.

> `[GAP]` No FAQ article exists for DCC troubleshooting (e.g. DCC not showing at checkout, incorrect rates). Content needed before launch.

---

### 3.3 VAS (Value Added Services)

#### How to offer One Assist Product Insurance
**Tagged video:** How to offer One Assist Product Insurance on Plutus Smart
**Device check:** No.

> `[GAP]` No FAQ article. Video-only currently.

#### How to offer HDFC Cardless EMI
**Tagged video:** How to use Pine Labs Plutus Smart to offer HDFC Cardless EMI options
**Device check:** No.

> `[GAP]` No FAQ article. Video-only currently.

#### How to offer PayLater EMI on Two Wheelers
**Tagged video:** How to use Pine Labs Plutus Smart to give your customers low-cost PayLater EMIs on Two Wheelers
**Device check:** No.

> `[GAP]` No FAQ article. Video-only currently.

#### Pine Labs Instant EMIs
**Tagged video:** Pine Labs Instant EMIs on Plutus Smart
**Device check:** No.

> `[GAP]` No FAQ article. Video-only currently.

#### Loyalty — Prepaid customer registration
**Tagged video:** Loyalty Solutions — Prepaid customer registration process on Plutus Smart
**Device check:** No.

> `[GAP]` No FAQ article. Video-only currently.

---

### 3.4 GrowthHub

> `[GAP]` No FAQs or videos exist for GrowthHub. Entire topic needs content before it can be included in the support flow.

---

### 3.5 Training Requests

#### How to request device training
**Answer**
1. Support → Training Requests → Device Training → Select Store → Submit request

**Tagged video:** How to use a Pine Labs PoS Terminal
**Device check:** No.

#### How to make a transaction in integration mode
**Tagged video:** How to make a transaction in 'integration mode' on Pine Labs PoS
**Device check:** No.

#### How to accept Debit/Credit card payments via Bharat QR
**Tagged video:** How to accept payments via Bharat QR on Plutus Smart
**Device check:** No.

---

## Appendix — Full video library (28 terminal + 4 EMI + 2 MPR)

### Terminal videos
1. How to re-print transaction charge-slip
2. What to do in case receipt doesn't print on a Pine Labs PoS
3. How to activate or check connectivity of a Pine Labs PoS
4. How to void a sale transaction on Plutus Smart
5. How to do batch settlement on Plutus Smart
6. Prevent payment fraud: Do's and Don'ts for business
7. How to use a Pine Labs PoS Terminal
8. How to make a transaction in 'integration mode' on Pine Labs PoS
9. How to void a transaction on Pine Labs PoS
10. How to test print on Pine Labs PoS
11. How to settle a batch for EMI transactions on Pine Labs PoS
12. How to accept UPI payments via static QR on the Pine Labs terminal
13. How to use Pine Labs Plutus Smart to offer HDFC Cardless EMI options
14. Pine Labs Instant EMIs on Plutus Smart
15. How to use Pine Labs Plutus Smart to give your customers low-cost PayLater EMIs on Two Wheelers
16. How to enable Dynamic Currency Conversion (DCC) to help customers pay in their local currency
17. How to offer One Assist Product Insurance on Plutus Smart
18. How to accept Debit/Credit card payments via Tap & Pay on Plutus Smart
19. How to accept payments via Bharat QR on Plutus Smart
20. How to accept credit/debit cards via Dip and Swipe on Plutus Smart
21. How to accept payments via UPI on Plutus Smart
22. How to offer Brand EMI via Catalogue app on Plutus Smart PoS
23. How to offer Brand EMI via Home app on Plutus Smart PoS
24. How to offer Bank EMI on Plutus Smart PoS
25. Loyalty Solutions — Prepaid customer registration process on Plutus Smart
26. How to do Brand EMI transactions on a Pine Labs PoS
27. How to do Bank EMI transaction on a Pine Labs PoS
28. How to do UPI transactions on Pine Labs PoS

### Brand EMI videos
1. How to perform brand EMI transactions on my PoS
2. How to offer Brand EMI via Catalogue app on Plutus Smart PoS
3. How to offer Brand EMI via Home app on Plutus Smart PoS
4. How to do Brand EMI transactions on a Pine Labs PoS

### MPR / Settlement videos
1. How to settle my batch on Android PoS
2. How to settle my batch on Non-Android PoS

---

## Device check trigger summary

| FAQ | Device check? | Reason |
|-----|--------------|--------|
| Invalid Batch ROC / ISO Packet | Yes | Confirm gateway reachable |
| No SIM / SIM Lock | Yes | Confirm SIM/network status |
| Batch Locked | Yes | Confirm gateway connectivity |
| Terminal restarting | Yes | Diagnose connectivity vs software |
| PoS not responding | Yes | Connectivity + app process check |
| Blank display | Yes | Confirm device online vs fully dead |
| GPRS / network issues | Yes | Identify failing network layer |
| Failed transaction | Yes | Confirm gateway reachable |
| Pending transaction | Yes | Confirm status endpoint reachable |
| Session expired (repeat) | Yes | Diagnose gateway latency |
| UPI pending (offline device) | Yes | Connectivity check |
| UPI failed (offline device) | Yes | Connectivity check |
| Alert irruption / tampered | No | Hardware fault, remote check irrelevant |
| Paper roll not printing | No | Mechanical issue |
| Battery / charger | No | Hardware issue |
| User ID / password | No | Informational only |
| Void / cancel transaction | No | Account action, not connectivity |
| EMI topics (all) | No | Not connectivity-dependent |
| Settlement / MPR topics | No | Not connectivity-dependent |
| Pine Checkout (all) | No | No physical device |
