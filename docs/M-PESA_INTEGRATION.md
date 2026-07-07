# M-Pesa Integration Guide

## Overview

Qorvexa integrates M-Pesa for secure mobile money payments using Safaricom's Daraja API.

## Prerequisites

1. M-Pesa business account
2. Daraja API credentials
3. Business till number or Paybill number
4. SSL certificate

## Setup Steps

### 1. Daraja Registration

1. Visit [developer.safaricom.co.ke](https://developer.safaricom.co.ke)
2. Register for a developer account
3. Create an app to get:
   - Consumer Key
   - Consumer Secret
   - Business Shortcode
   - Passkey

### 2. Environment Configuration

Add to `.env`:

```
MPESA_CONSUMER_KEY=your_consumer_key
MPESA_CONSUMER_SECRET=your_consumer_secret
MPESA_BUSINESS_SHORTCODE=174379
MPESA_PASSKEY=your_passkey
MPESA_CALLBACK_URL=https://yourdomain.com/api/mpesa/callback
MPESA_ENVIRONMENT=sandbox  # or 'production'
```

### 3. Supabase Edge Function Setup

Create Edge Function for M-Pesa transactions:

```javascript
// supabase/functions/mpesa-payment/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const CONSUMER_KEY = Deno.env.get("MPESA_CONSUMER_KEY");
const CONSUMER_SECRET = Deno.env.get("MPESA_CONSUMER_SECRET");
const BUSINESS_SHORTCODE = Deno.env.get("MPESA_BUSINESS_SHORTCODE");
const PASSKEY = Deno.env.get("MPESA_PASSKEY");
const CALLBACK_URL = Deno.env.get("MPESA_CALLBACK_URL");

serve(async (req) => {
  if (req.method === "POST") {
    const { phone, amount, orderId } = await req.json();

    // Get access token
    const authString = btoa(`${CONSUMER_KEY}:${CONSUMER_SECRET}`);
    const tokenResponse = await fetch(
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
      {
        headers: {
          Authorization: `Basic ${authString}`,
        },
      }
    );
    const { access_token } = await tokenResponse.json();

    // Initiate STK push
    const timestamp = new Date().toISOString().slice(0, 19).replace(/[-:]/g, "");
    const shortcode = BUSINESS_SHORTCODE;
    const passkey = PASSKEY;
    const password = btoa(`${shortcode}${passkey}${timestamp}`);

    const stkResponse = await fetch(
      "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${access_token}`,
        },
        body: JSON.stringify({
          BusinessShortCode: shortcode,
          Password: password,
          Timestamp: timestamp,
          TransactionType: "CustomerPayBillOnline",
          Amount: amount,
          PartyA: phone,
          PartyB: shortcode,
          PhoneNumber: phone,
          CallBackURL: CALLBACK_URL,
          AccountReference: orderId,
          TransactionDesc: "Qorvexa Order Payment",
        }),
      }
    );

    return new Response(await stkResponse.json(), {
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

### 4. Flutter Implementation

```dart
// mobile/lib/services/payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> initiateMPesaPayment({
    required String phoneNumber,
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'mpesa-payment',
        body: {
          'phone': phoneNumber,
          'amount': amount.toInt(),
          'orderId': orderId,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Payment initiation failed: $e');
    }
  }
}
```

### 5. Callback Handler

Create endpoint to handle M-Pesa callbacks:

```javascript
// supabase/functions/mpesa-callback/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL"),
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
);

serve(async (req) => {
  const body = await req.json();
  const { Body } = body;
  const { stkCallback } = Body;
  const { ResultCode, CallbackMetadata } = stkCallback;

  if (ResultCode === 0) {
    // Payment successful
    const { CallbackMetadata } = stkCallback;
    const items = CallbackMetadata.Item;
    const receiptNumber = items.find((item) => item.Name === "MpesaReceiptNumber")
      ?.Value;
    const orderId = items.find((item) => item.Name === "AccountReference")?.Value;

    // Update order in database
    await supabase
      .from("orders")
      .update({
        payment_status: "completed",
        m_pesa_receipt_number: receiptNumber,
        status: "processing",
      })
      .eq("id", orderId);
  } else {
    // Payment failed
    const orderId = stkCallback.CallbackMetadata.Item.find(
      (item) => item.Name === "AccountReference"
    )?.Value;

    await supabase
      .from("orders")
      .update({
        payment_status: "failed",
        status: "cancelled",
      })
      .eq("id", orderId);
  }

  return new Response(
    JSON.stringify({ ResultCode: 0, ResultDesc: "Accepted" }),
    {
      headers: { "Content-Type": "application/json" },
      status: 200,
    }
  );
});
```

## Testing

### Sandbox Testing

1. Use Daraja sandbox credentials
2. **Test phone number**: 254707273543 (or 0707273543 with country code)
3. Test amount: Any amount
4. Confirm payment via prompt

### Test Credentials

- **Test Phone**: 0707273543 (254707273543 with country code)
- **Test Amount**: Any amount (100, 500, 1000, etc.)
- **Environment**: sandbox
- **Expected Response**: STK Push prompt on the test phone

### Production Deployment

1. Update credentials to production
2. Update URLs from sandbox to production
3. Ensure callback URL is publicly accessible
4. Enable HTTPS on callback endpoint
5. Test with real transactions before full launch

## Error Handling

```dart
try {
  await paymentService.initiateMPesaPayment(
    phoneNumber: '254707273543',
    amount: 1000,
    orderId: 'order_123',
  );
} on Exception catch (e) {
  showErrorDialog('Payment failed: $e');
}
```

## Security Considerations

1. **Never log sensitive data** - Phone numbers, amounts, receipt numbers
2. **Validate signatures** - Verify callback authenticity
3. **Rate limiting** - Prevent payment spam
4. **PCI DSS Compliance** - Don't store M-Pesa credentials on device
5. **HTTPS Only** - All M-Pesa communication must be encrypted

## Troubleshooting

### Issue: "Invalid Consumer Key/Secret"

- Verify credentials in `.env`
- Check Daraja dashboard for correct values
- Ensure IP whitelist includes your server

### Issue: "Callback not received"

- Verify callback URL is publicly accessible
- Check server logs for incoming requests
- Ensure HTTPS is enabled

### Issue: "STK Push not showing"

- Verify phone number format (2547xxxxxxxx or 07xxxxxxxx)
- Check test phone has M-Pesa enabled
- Try different amount
- Test with number: 0707273543

### Issue: "Transaction timeout"

- Check network connectivity
- Verify M-Pesa account has active services
- Check M-Pesa account balance

## References

- [Safaricom Daraja API](https://developer.safaricom.co.ke/apis)
- [M-Pesa Documentation](https://www.safaricom.co.ke/business/m-pesa-api)
- [STK Push Documentation](https://developer.safaricom.co.ke/documentation)

## Support Phone Number

For testing purposes, use: **0707273543**

This is a dedicated test number in Safaricom's sandbox environment for M-Pesa integration testing.
