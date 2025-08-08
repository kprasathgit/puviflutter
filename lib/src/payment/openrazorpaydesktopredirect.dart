import 'dart:html' as html;

/// This function works only on Flutter Web.
/// It creates and submits a form to redirect to Razorpay Payment Page.
void openRazorpayDesktopRedirect(Map<String, dynamic> orderData) {
  final razorpayKey = 'rzp_test_pF5x3pp39sVSZs'; // replace with your key

  // Create a form element
  final form = html.FormElement();
  form.method = 'POST';
  form.action = 'https://api.razorpay.com/v1/checkout/embedded'; // Full redirect endpoint
  form.target = '_self'; // open in same tab

  // Add required fields
  void addField(String name, String value) {
    final input = html.InputElement()
      ..type = 'hidden'
      ..name = name
      ..value = value;
    form.children.add(input);
  }

  addField('key_id', razorpayKey);
  addField('order_id', orderData['razorpayOrderId']);
  addField('name', orderData['name']);
  addField('description', 'Puvipure Order');
  addField('prefill[contact]', orderData['mobileno']);
  addField('prefill[email]', 'test@example.com'); // Optional
  addField('theme[color]', '#00b894');

  // Add the form to the document and submit
  html.document.body!.append(form);
  form.submit();
  form.remove(); // clean up
}
