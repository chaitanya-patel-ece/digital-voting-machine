# 📖 Digital Voting Machine — User Guide

## Step-by-Step Voting Instructions

---

### Before You Start
- Make sure the Basys 3 board is powered ON
- All switches (SW[0], SW[1]) should be in the DOWN position
- The display will show `1 1` by default (Party 1, Candidate 1)

---

### How to Cast a Vote

#### Step 1 — Select Your Party
Press **BTNU** (Up button) or **BTND** (Down button) to scroll through parties.

```
Display leftmost digit:
  "1" = Party 1 selected  (LED[0] ON)
  "2" = Party 2 selected  (LED[1] ON)
  "3" = Party 3 selected  (LED[2] ON)
```

#### Step 2 — Select Your Candidate
Flip exactly ONE switch UP:

```
SW[0] UP = Candidate 1  (display 2nd digit shows "1", LED[3] ON)
SW[1] UP = Candidate 2  (display 2nd digit shows "2", LED[4] ON)
```

> ⚠️ Do NOT flip both switches UP — that is invalid!

#### Step 3 — Cast Your Vote
Press **BTNC** (Center button) firmly once.

```
✅ SUCCESS: LED[15] (rightmost LED) flashes briefly
❌ INVALID: LED[14] flashes — check your switches
```

---

### How to View Results

Press **BTNL** (Left button) to enter result mode.
- The **decimal point** on the display turns ON
- **LED[13]** lights up

Keep pressing **BTNL** to cycle through all results:

```
Press 1 → P1-C1 (Party 1, Candidate 1 votes)
Press 2 → P1-C2 (Party 1, Candidate 2 votes)
Press 3 → P2-C1 (Party 2, Candidate 1 votes)
Press 4 → P2-C2 (Party 2, Candidate 2 votes)
Press 5 → P3-C1 (Party 3, Candidate 1 votes)
Press 6 → P3-C2 (Party 3, Candidate 2 votes)
Press 7 → wraps back to P1-C1
```

The display shows: `[Party][Candidate][Tens][Ones]`

Example: `2 1 3 5` = Party 2, Candidate 1 has **35 votes**

---

### How to Reset (Admin Only)

Press **BTNR** (Right button) to clear ALL votes to zero.

> ⚠️ This cannot be undone! All 6 vote counters will reset to 0.

---

### Troubleshooting

| Problem | Solution |
|---------|----------|
| LED[14] flashing | Fix switches — only one should be UP |
| Vote not counting | Hold BTNC for at least 1 full second |
| Display showing wrong party | Press BTNU/BTND to navigate |
| Decimal point stuck ON | Press BTNC once to return to voting mode |
| Nothing working | Check USB power connection |
