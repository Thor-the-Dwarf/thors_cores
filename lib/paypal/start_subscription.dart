import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

Future<void> startSubscription(String planId, String customerKey) async {
  final String clientId = 'YOUR_CLIENT_ID'; // Von PayPal Developer Portal
  final String secret = 'YOUR_SECRET';
  final String url = 'https://api-m.sandbox.paypal.com/v1/billing/subscriptions'; // Für Live: api-m.paypal.com

  // Hole Access Token
  final authResponse = await http.post(
    Uri.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token'),
    headers: {
      'Authorization': 'Basic ' + base64Encode('$clientId:$secret'.codeUnits),
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials',
  );

  final accessToken = jsonDecode(authResponse.body)['access_token'];

  // Erstelle Abonnement
  final subscriptionResponse = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'plan_id': planId,
      'custom_id': customerKey, // Der Key des Kunden
      'application_context': {
        'brand_name': 'Deine App',
        'locale': 'de-DE',
        'return_url': 'https://deinewebseite.de/success',
        'cancel_url': 'https://deinewebseite.de/cancel',
      },
    }),
  );

  final approvalUrl = jsonDecode(subscriptionResponse.body)['links']
      .firstWhere((link) => link['rel'] == 'approve')['href'];

  // Öffne PayPal-Seite im Browser
  await launchUrl(Uri.parse(approvalUrl), mode: LaunchMode.externalApplication);
}