# Template Configuration Files

## Info.plist Keys

Add these keys to your app's Info.plist file:

```xml
<!-- In-App Purchase Configuration -->
<key>IAPProductID</key>
<string>com.yourcompany.yourapp.full_unlock</string>

<key>IAPValidationURL</key>
<string>https://your-api.com/api/iap/validate</string>

<key>IAPValidationURLSandbox</key>
<string>https://your-api.com/api/iap/validate/sandbox</string>
```

## Configuration Values

### IAP Product ID
Replace `com.yourcompany.yourapp.full_unlock` with your actual App Store Connect product identifier.

This should match:
- The product ID in App Store Connect
- The product ID in `configuration.storekit` for local testing

### Validation URLs
Replace the validation URLs with your actual backend endpoints:
- **Production**: Used for production environment purchases
- **Sandbox**: Used for sandbox/testing environment purchases

The Purchase Manager automatically selects the appropriate URL based on the transaction environment.

## StoreKit Configuration File

Update `configuration.storekit` with your product details:

1. Open `configuration.storekit` in Xcode
2. Update the product ID to match your Info.plist
3. Set the display price and reference name
4. Configure family sharing if needed

## Testing Configuration

For local testing with StoreKit Testing:
1. Xcode will automatically use `configuration.storekit`
2. No real payment processing occurs
3. Transactions are verified locally
4. The `isSandboxOverrideEnabled` flag is automatically set in DEBUG builds

## Production Checklist

Before releasing:
- [ ] Product created in App Store Connect
- [ ] Product ID matches in Info.plist, configuration.storekit, and App Store Connect  
- [ ] Validation URLs point to your production backend
- [ ] Backend validation endpoint is deployed and tested
- [ ] Tax and pricing configured in App Store Connect
- [ ] App metadata mentions IAP if required by your app type
