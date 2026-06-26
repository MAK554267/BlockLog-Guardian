#!/bin/bash

echo "========================================="
echo "  ADDING FORENSIC EVIDENCE"
echo "========================================="
echo ""

# Evidence data
evidence_data=(
  "EVID-001|LOGIN_RECORD|Successful login from IP 192.168.1.100|0x8a7b6c5d4e3f2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5|azfar"
  "EVID-002|TAMPER_RECORD|Blockchain tampering detected at block 0x12a3|0x7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9|MAK"
  "EVID-003|MALWARE_RECORD|Malware detected in system file|0x6c5d4e3f2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3|security_analyst"
  "EVID-004|ACCESS_RECORD|Unauthorized access attempt from IP 10.0.0.50|0x5d4e3f2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2|azfar"
  "EVID-005|FORENSIC_REPORT|Forensic report #2026-001|0x4e3f2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1|MAK"
  "EVID-006|LOGIN_RECORD|Login from unknown location IP 203.0.113.45|0x3f2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0|security_analyst"
  "EVID-007|TAMPER_RECORD|Evidence tampering detected in case INVEST-001|0x2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9|azfar"
  "EVID-008|MALWARE_RECORD|Ransomware signature detected in email attachment|0x1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8|MAK"
  "EVID-009|ACCESS_RECORD|Privilege escalation detected for user testuser5|0x9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7|azfar"
  "EVID-010|FORENSIC_REPORT|Digital forensics report: Data exfiltration|0x8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6|security_analyst"
)

for item in "${evidence_data[@]}"; do
  IFS='|' read -r ID TYPE DESC HASH COLLECTOR <<< "$item"
  
  echo "📝 Adding evidence: $ID ($TYPE)"
  
  curl -s -X POST http://localhost:8000/api/blockchain/add-evidence/ \
    -H "Content-Type: application/json" \
    -d "{
      \"evidence_id\": \"$ID\",
      \"evidence_type\": \"$TYPE\",
      \"description\": \"$DESC\",
      \"hash\": \"$HASH\",
      \"collector\": \"$COLLECTOR\"
    }"
  
  echo " ✅"
  sleep 0.5
done

echo ""
echo "========================================="
echo "  ✅ Added ${#evidence_data[@]} evidence items"
echo "========================================="
