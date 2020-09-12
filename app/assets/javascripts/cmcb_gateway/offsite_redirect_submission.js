function submitPaymentRedirect() {
  var form = document.getElementById("form-payment-redirect");
  if (!form) return false;

  console.log(form);
  form.submit();
}

document.addEventListener("DOMContentLoaded", (event) => {
  submitPaymentRedirect();
});
