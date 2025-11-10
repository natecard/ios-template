# API Specification

Backend API endpoints for purchase validation and account management.

## Overview

The PurchaseManager posts transaction data to your backend for server-side validation. This ensures purchases are legitimate and helps detect fraud.

---

## Purchase Validation Endpoint

### POST /api/iap/validate

Validates an in-app purchase transaction.

#### Request

```http
POST /api/iap/validate
Content-Type: application/json

{
  "transactionId": "ABCD1234567890",
  "productId": "com.yourcompany.app.full_unlock",
  "revoked": false
}
```

#### Request Body

| Field | Type | Description |
|-------|------|-------------|
| `transactionId` | string | StoreKit transaction ID (UInt64 as string) |
| `productId` | string | Product identifier from App Store Connect |
| `revoked` | boolean | `true` if purchase was refunded/revoked |

#### Response (Success)

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "status": "verified",
  "transactionId": "ABCD1234567890",
  "productId": "com.yourcompany.app.full_unlock",
  "timestamp": "2025-11-06T12:34:56Z"
}
```

#### Response (Error)

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "invalid_transaction",
  "message": "Transaction could not be verified"
}
```

#### Status Codes

- `200 OK` - Transaction validated successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required (if you implement auth)
- `404 Not Found` - Transaction not found
- `500 Internal Server Error` - Server error

---

## Sandbox Validation Endpoint

### POST /api/iap/validate/sand

Same as production endpoint, but for sandbox transactions during testing.

**Note**: The app automatically routes to this endpoint when:
- Running in DEBUG mode
- Transaction environment is `.sandbox`
- `isSandboxOverrideEnabled` flag is set

---

## Implementation Notes

### Transaction Verification

Your backend should:

1. **Receive the transaction data** from the app
2. **Verify with Apple's servers** using App Store Server API
3. **Store the transaction** in your database
4. **Return verification status** to the app

### Security Considerations

- **Use HTTPS** for all endpoints
- **Validate transaction signatures** with Apple's public keys
- **Check for duplicate transactions** before granting entitlements
- **Implement rate limiting** to prevent abuse
- **Log all validation attempts** for audit trails

### Example Backend (Node.js/Express)

```javascript
const express = require('express');
const axios = require('axios');

const app = express();
app.use(express.json());

app.post('/api/iap/validate', async (req, res) => {
  const { transactionId, productId, revoked } = req.body;
  
  try {
    // Verify with Apple
    const appleResponse = await verifyWithApple(transactionId);
    
    if (appleResponse.valid) {
      // Store in database
      await db.transactions.upsert({
        transactionId,
        productId,
        revoked,
        verifiedAt: new Date(),
        environment: appleResponse.environment
      });
      
      res.json({
        status: 'verified',
        transactionId,
        productId,
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(400).json({
        error: 'invalid_transaction',
        message: 'Transaction verification failed'
      });
    }
  } catch (error) {
    console.error('Validation error:', error);
    res.status(500).json({
      error: 'server_error',
      message: 'Internal server error'
    });
  }
});

async function verifyWithApple(transactionId) {
  // Use Apple's App Store Server API
  // https://developer.apple.com/documentation/appstoreserverapi
  
  const response = await axios.post(
    'https://api.storekit.itunes.apple.com/inApps/v1/transactions/' + transactionId,
    {},
    {
      headers: {
        'Authorization': `Bearer ${generateJWT()}`,
        'Content-Type': 'application/json'
      }
    }
  );
  
  return {
    valid: response.status === 200,
    environment: response.data.environment
  };
}

function generateJWT() {
  // Generate JWT for App Store Server API
  // See: https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests
}

app.listen(3000);
```

### Example Backend (Python/Flask)

```python
from flask import Flask, request, jsonify
import jwt
import requests
from datetime import datetime

app = Flask(__name__)

@app.route('/api/iap/validate', methods=['POST'])
def validate_purchase():
    data = request.json
    transaction_id = data.get('transactionId')
    product_id = data.get('productId')
    revoked = data.get('revoked', False)
    
    try:
        # Verify with Apple
        apple_response = verify_with_apple(transaction_id)
        
        if apple_response['valid']:
            # Store in database
            store_transaction(
                transaction_id=transaction_id,
                product_id=product_id,
                revoked=revoked,
                environment=apple_response['environment']
            )
            
            return jsonify({
                'status': 'verified',
                'transactionId': transaction_id,
                'productId': product_id,
                'timestamp': datetime.utcnow().isoformat()
            }), 200
        else:
            return jsonify({
                'error': 'invalid_transaction',
                'message': 'Transaction verification failed'
            }), 400
            
    except Exception as e:
        print(f'Validation error: {e}')
        return jsonify({
            'error': 'server_error',
            'message': 'Internal server error'
        }), 500

def verify_with_apple(transaction_id):
    # Use App Store Server API
    url = f'https://api.storekit.itunes.apple.com/inApps/v1/transactions/{transaction_id}'
    headers = {
        'Authorization': f'Bearer {generate_jwt()}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(url, headers=headers)
    
    return {
        'valid': response.status_code == 200,
        'environment': response.json().get('environment') if response.ok else None
    }

def generate_jwt():
    # Generate JWT for App Store Server API
    # Reference: https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests
    pass

def store_transaction(transaction_id, product_id, revoked, environment):
    # Store in your database
    pass

if __name__ == '__main__':
    app.run(port=3000)
```

---

## App Store Server API

### Getting Started

1. **Create API Key** in App Store Connect
2. **Download Private Key** (.p8 file)
3. **Note Key ID and Issuer ID**
4. **Generate JWT** for authentication
5. **Call Apple's endpoints** to verify transactions

### Resources

- [App Store Server API Documentation](https://developer.apple.com/documentation/appstoreserverapi)
- [Generating Tokens](https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests)
- [Get Transaction Info](https://developer.apple.com/documentation/appstoreserverapi/get_transaction_info)
- [App Store Server Notifications](https://developer.apple.com/documentation/appstoreservernotifications)

---

## Testing

### Local Testing

During development:

1. App posts to sandbox endpoint
2. Use StoreKit Testing (no server validation needed)
3. Transactions are automatically verified locally
4. Server validation is attempted but not required

### Production Testing

Before release:

1. Create test user in App Store Connect
2. Install production build (not from Xcode)
3. Make test purchase
4. Verify backend receives and validates transaction
5. Check database for stored transaction
6. Test refund flow (revoked = true)

---

## Database Schema

Recommended transaction storage:

```sql
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(255) UNIQUE NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255),
    environment VARCHAR(50) NOT NULL,  -- 'Production' or 'Sandbox'
    revoked BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id)
);
```

---

## Error Handling

### Client-Side (PurchaseManager)

The PurchaseManager handles validation errors gracefully:

- **Network errors**: Logged but don't block purchase
- **Server errors**: Logged for debugging
- **Validation is non-blocking**: Purchase proceeds even if validation fails

### Server-Side

Your backend should:

- **Log all errors** for debugging
- **Return appropriate status codes**
- **Handle rate limiting**
- **Implement retries** for transient failures

---

## Monitoring

### Recommended Metrics

Track these metrics in your backend:

- **Validation success rate**
- **Response time**
- **Error rates** by type
- **Refund rate**
- **Duplicate transaction attempts**

### Alerts

Set up alerts for:

- High error rates
- Slow response times
- Unusual refund patterns
- Potential fraud attempts

---

## Next Steps

- See [Integration Guide](INTEGRATION_GUIDE.md) for client setup
- Review [Configuration](CONFIGURATION.md) for endpoint URLs
- Read Apple's [App Store Server API docs](https://developer.apple.com/documentation/appstoreserverapi)
