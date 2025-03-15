-- Test the payment API function
DECLARE
  l_payload CLOB;
  l_response CLOB;
BEGIN
  -- Load the sample payload from the payload.json file
  l_payload := '{
    "userId": "test-user",
    "billId": "BILL-001",
    "billCategory": 60,
    "year": 2025,
    "billNumber": 4,
    "customer": {
      "id": 12345,
      "primaryName": "John Doe",
      "secondaryName": "Johnny",
      "phoneNumber": "+1-555-555-5555",
      "email": "john@example.com",
      "address": {
        "addressLine1": "123 Main St",
        "city": "Anytown",
        "state": "ST",
        "zipCode": "12345",
        "country": "USA"
      }
    },
    "amount": 100.00,
    "effectiveDate": "2025-03-14T14:16:50.759Z",
    "paymentLines": [
      {
        "id": "LINE-001",
        "code": "PMT",
        "amount": 100.00,
        "paymentLineAmounts": [
          {
            "type": "PRINCIPAL",
            "amount": 100.00
          }
        ]
      }
    ],
    "transactionNumber": 1001,
    "tender": {
      "method": {
        "tenderType": "CREDIT_CARD",
        "externalId": "4111111111111111",
        "classification": "VISA"
      },
      "paidBy": "John Doe",
      "deposit": "123456",
      "memo": "Payment for services",
      "reference": "AUTH-12345"
    },
    "externalSystem": {
      "externalBatchId": 1,
      "externalBatchNumber": 1001,
      "externalPaymentId": 12345
    }
  }';

  -- Call the process_payment function
  l_response := process_payment(l_payload);
  
  -- Display the response
  DBMS_OUTPUT.PUT_LINE('Response from payment API:');
  DBMS_OUTPUT.PUT_LINE(l_response);
END;
/