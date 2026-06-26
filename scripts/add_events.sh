#!/bin/bash

echo "========================================="
echo "  ADDING SECURITY EVENTS TO BLOCKCHAIN"
echo "========================================="
echo ""

# Array of users
USERS=("azfar" "MAK" "testuser" "testuser5" "newadmin" "alice" "bob" "charlie" "diana" "eve")

# Array of event types
EVENTS=("LOGIN_SUCCESS" "LOGIN_FAILED" "ADMIN_ACTION" "TAMPER_DETECTED" "EVIDENCE_ADDED")

# Array of descriptions
DESCRIPTIONS=(
    "User logged in successfully"
    "User login attempt failed"
    "Admin action performed"
    "Tampering detected in logs"
    "New evidence added to case"
    "Security breach detected"
    "Unauthorized access attempt"
    "Privilege escalation detected"
    "Malware detected in system"
    "Suspicious activity flagged"
)

echo "📝 Adding 30 security events to blockchain..."
echo ""

for i in {1..30}
do
    # Random selections
    USER=${USERS[$RANDOM % ${#USERS[@]}]}
    EVENT=${EVENTS[$RANDOM % ${#EVENTS[@]}]}
    DESC=${DESCRIPTIONS[$RANDOM % ${#DESCRIPTIONS[@]}]}
    
    echo "🔹 Adding event $i: $EVENT - $DESC ($USER)"
    
    curl -s -X POST http://localhost:8000/api/blockchain/add-log/ \
        -H "Content-Type: application/json" \
        -d "{
            \"event_type\": \"$EVENT\",
            \"description\": \"$DESC for user $USER\",
            \"user_address\": \"0x4e0A20b9e3D7FaC87743f76dBA08b4f8CdF55Dba\"
        }" > /dev/null
    
    sleep 0.5
done

echo ""
echo "========================================="
echo "  ✅ DONE! Added 30 events"
echo "========================================="
echo ""
echo "Refresh your dashboard to see the events!"
