# Security Policy

## ⚠️ Responsible Use Notice

This repository contains BadUSB scripts that, when executed, can modify system configurations, exfiltrate data, and potentially disrupt normal operations. These tools are designed for **authorized security testing and educational purposes only**.

## 🎓 Educational and Authorized Use Only

**CRITICAL: All scripts in this repository must only be used in the following contexts:**

1. **Personal Systems**: Your own devices and virtual machines
2. **Authorized Penetration Testing**: With explicit written permission from system owners
3. **Security Research**: In isolated, controlled lab environments
4. **Educational Purposes**: Learning about security vulnerabilities and defenses

**UNAUTHORIZED USE IS ILLEGAL AND VIOLATIONS WILL BE REPORTED TO APPROPRIATE AUTHORITIES.**

## 🚫 Liability Disclaimer

### No Warranty

These scripts are provided "AS IS" without warranty of any kind. The repository owner and contributors make no representations about the suitability, reliability, or accuracy of these scripts for any purpose.

### Assumption of Risk

**BY USING THESE SCRIPTS, YOU ACKNOWLEDGE AND ACCEPT THAT:**

- You assume **ALL RESPONSIBILITY** for any consequences resulting from their use
- You will **NOT** hold the repository owner, contributors, or maintainers liable for:
  - System damage or data loss
  - Legal consequences or prosecution  
  - Harm to devices or networks
  - Privacy violations
  - Any other damages whatsoever

### User Responsibility

You are **solely responsible** for:

- Ensuring compliance with all applicable laws and regulations
- Obtaining proper authorization before testing any system
- Understanding what each script does before execution
- Backing up systems before testing
- Any consequences resulting from misuse

## 🔒 Responsible Disclosure

If you discover security vulnerabilities in these scripts or through their use:

### Reporting Vulnerabilities

1. **Do NOT** create public GitHub issues for security vulnerabilities
2. **Do** email security concerns to: resch.jonas@pm.me
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested remediation (if any)

### Response Timeline

- We will acknowledge receipt within **72 hours**
- We aim to provide an initial assessment within **7 days**
- We will work with you on coordinated disclosure timelines

### Coordinated Disclosure

We request a **90-day disclosure window** to address vulnerabilities before public disclosure. We will:

- Work diligently to patch confirmed vulnerabilities
- Keep you informed of remediation progress
- Credit researchers (if desired) when fixes are published

## ⚖️ Legal Compliance

### Know the Law

Users must comply with all applicable laws, including but not limited to:

- **United States**: Computer Fraud and Abuse Act (CFAA), 18 U.S.C. § 1030
- **European Union**: Directive on attacks against information systems
- **United Kingdom**: Computer Misuse Act 1990
- **Your local jurisdiction's** cybercrime and computer misuse laws

### Prohibited Activities

The following uses are **STRICTLY PROHIBITED** and may result in:
- Criminal prosecution
- Civil liability
- Immediate ban from this repository

**Prohibited uses:**
- ❌ Unauthorized access to any computer system
- ❌ Theft of credentials, data, or intellectual property
- ❌ Causing damage or disruption to systems or services
- ❌ Privacy violations or unauthorized surveillance
- ❌ Harassment, stalking, or intimidation
- ❌ Any activity violating local, national, or international law

## 🛡️ Safe Testing Practices

To minimize risk when learning from these scripts:

### Testing Environment Setup

1. **Use Virtual Machines**:
   - VirtualBox, VMware, or Hyper-V
   - Take snapshots before testing
   - Isolate from production networks

2. **Air-Gapped Testing**:
   - Disconnect from internet when testing dangerous scripts
   - Use isolated networks for exfiltration testing
   - Never test on systems with sensitive data

3. **Progressive Testing**:
   - Start with harmless scripts (ASCII art, etc.)
   - Read and understand code before execution
   - Test in stages with increasing complexity

### Before Running Any Script

- ✅ Read the entire script and understand its purpose
- ✅ Check for required modifications (webhooks, URLs, etc.)
- ✅ Backup your test system or take a VM snapshot
- ✅ Ensure you have authorization for the target system
- ✅ Document your testing for legitimate purposes

## 🎯 Ethical Guidelines

As security researchers and penetration testers, we hold ourselves to high ethical standards:

1. **Respect Privacy**: Only access data you're authorized to see
2. **Minimize Harm**: Use the least invasive methods necessary
3. **Be Transparent**: Clearly document your testing activities
4. **Give Back**: Share knowledge to improve security for everyone
5. **Stay Legal**: Never cross legal or ethical boundaries

## 📞 Contact

For security-related questions or concerns:

- **Email**: resch.jonas@pm.me
- **GitHub Issues**: For non-security bugs and feature requests only
- **Responsible Disclosure**: Use email for security vulnerabilities

## 📋 Additional Resources

- [DISCLAIMER.md](DISCLAIMER.md) - Complete legal disclaimer
- [README.md](README.md) - Repository overview and usage guide
- [TESTING.md](TESTING.md) - Safe testing practices and guidelines

---

**Remember: These tools are powerful. Use them wisely, ethically, and always within the boundaries of the law.**

**Last Updated**: December 9, 2025
