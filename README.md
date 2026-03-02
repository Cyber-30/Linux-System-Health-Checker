# 🔐 LSHC – Linux Security Health Checker

LSHC (Linux Security Hardening Checker) is a modular Bash-based security auditing and hardening tool designed to evaluate and improve the security posture of Linux systems.

It performs multi-layered system checks, calculates a weighted security score, identifies risks, and provides actionable remediation recommendations.

---

## 🚀 Features

- ✅ User Security Audit  
- ✅ Filesystem Security Audit  
- ✅ Network Security Audit  
- ✅ Service Security Audit  
- ✅ Interactive System Hardening  
- ✅ Advanced Scoring Engine (Capped & Weighted)
- ✅ Risk Classification System
- ✅ Real-time Recommendations
- ✅ Compromise Detection Flagging

---

## 📊 Security Scoring Model

LSHC evaluates security across five categories:

| Category              | Max Score |
|-----------------------|-----------|
| User Security         | 45        |
| Filesystem Security   | 58        |
| Network Security      | 65        |
| Service Security      | 70        |
| System Hardening      | 20        |
| **Total Maximum**     | **258**   |

The final percentage determines system risk level:

| Score %        | Risk Level       |
|---------------|------------------|
| 85 – 100%     | 🟢 SECURE        |
| 65 – 84%      | 🟡 MODERATE RISK |
| 40 – 64%      | 🟠 HIGH RISK     |
| Below 40%     | 🔴 CRITICAL RISK |
| Compromise    | 🚨 COMPROMISED   |

---

## 🛠 What LSHC Checks

### 🔹 User Security
- UID 0 account validation
- Empty password detection
- Password policy checks
- Privilege misconfiguration

### 🔹 Filesystem Security
- World-writable file detection
- SUID/SGID binary audit
- Sensitive file permission checks
- Suspicious `/tmp` executables

### 🔹 Network Security
- Open ports analysis
- SSH configuration audit
- Telnet detection
- Firewall status check

### 🔹 Service Security
- Running service evaluation
- Insecure legacy services detection
- High-risk daemon identification

### 🔹 Interactive Hardening
- Disable SSH root login
- Enforce key-based authentication
- Fix `/etc/passwd` permissions
- Restrict home directory access
- Remove world-writable permissions
- Firewall configuration guidance

---


## ⚙️ Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/LSHC.git
cd LSHC
```
Make the file executable
```bash
chmod +x lshc.sh
```
Run the tool
```bash
sudo ./lshc.sh
```

--- 
# 🧠 Example Output
```markdown
=========================================
              FINAL REPORT
=========================================
User Security       : 45 / 45
Filesystem Security : 56 / 58
Network Security    : 64 / 65
Service Security    : 70 / 70
System Hardening    : 15 / 20
-----------------------------------------
FINAL SECURITY SCORE: 250 / 258 (96%)
RISK LEVEL          : SECURE
=========================================
```

---
# 🔎 Why This Tool?

Most basic Linux security scripts:

- Do not provide scoring

- Do not offer structured risk classification

- Do not allow interactive hardening

- Do not cap score inflation

LSHC introduces:

- Structured scoring system

- Overflow protection

- Accurate percentage calculation

- Compromise override flag

- Modular architecture

# 🎯 Use Cases

- Personal Linux hardening

- Kali Linux lab security validation

- Cybersecurity student projects

- Security baseline validation

- Pre-deployment system checks

# ⚠️ Disclaimer

This tool is intended for:

- Educational use

- Ethical security auditing

- Personal system hardening

- Do not use on systems you do not own or have explicit permission to audit.

# 📈 Future Improvements

- JSON report export

- PDF report generation

- Color-coded output

- Automated remediation mode

- Enterprise compliance mapping (CIS Benchmarks)

- Cron-based scheduled audits

---
# 👨‍💻 Author

## Sourya Dutta
Cybersecurity Enthusiast | Linux Security | System Hardening


---
# ⭐ If You Like This Project

Give it a star ⭐ on GitHub and share feedback!