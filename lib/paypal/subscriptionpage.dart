import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatelessWidget {
  final String subscriptionUrl = 'https://www.paypal.com/webapps/billing/plans/subscribe?plan_id=P-7G230830CD9983044NAM7V4I';
  Future<void> startSubscription() async {
    final Uri uri = Uri.parse(subscriptionUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Konnte PayPal-Seite nicht öffnen';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Abonnement abschließen')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Schließe dein Abonnement ab. Du erhältst eine E-Mail von PayPal mit einer Subscription ID. Verwende diese ID, um auf die Webseite zuzugreifen.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startSubscription,
              child: Text('Jetzt abonnieren'),
            ),
          ],
        ),
      ),
    );
  }
}


